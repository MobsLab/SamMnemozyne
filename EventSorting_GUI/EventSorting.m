function EventSorting(evtType)

%==========================================================================
% Details: visiualize and manually clean events (ripples or spindles). Will
%          create a copy of the original [SWR_original.mat] and upon changes saved a
%          addtional .mat file named [SWRSorted.mat].
%
% Note: spindles is not yet finalize
%
% INPUTS:
%       - evtType           ripples or spindles
%    
%
% NOTES:
%
%   Written by Samuel Laventure - 2021/12
%      
%==========================================================================

%% Init variables
global ievt; ievt=1;
global irej; irej=0;
global evt; 
global change; change=0;
global evtName; evtName = evtType; 
global twin; twin=2000; % time duration (1sec * 1e4) for half a window (default)

%% load event data
switch evtType
    case 'ripples'
        if exist([pwd '/SWRSorted.mat'],'file')
            load([pwd '/SWRSorted.mat']);
        else
            load([pwd '/SWR.mat']);
        end
        load([pwd '/ChannelsToAnalyse/dHPC_rip.mat'],'channel');
        evt.time = ripples;
        evt.epoch = RipplesEpoch;
        evt.T = T;
        evt.ts = Data(tRipples);
        evt.mean = meanVal;
        evt.std = stdVal;
        evt.info = ripples_Info;
        % make a copy of original
        if ~exist('Ripples_original.mat','file')
            copyfile('SWR.mat','SWR_original.mat');
        end
    case 'spindles'
        if exist([pwd '/SpindlesSorted.mat'],'file')
            load([pwd '/SpindlesSorted.mat']);
        else
            load([pwd '/sSpindles.mat']);
        end
        load([pwd '/ChannelsToAnalyse/PFCx_spindle.mat'],'channel');
end

evt.rejected.id = [];
evt.rejected.time = [];

evt.original.time = evt.time;
% load LFP (temp)3
load([pwd '/LFPData/LFP' num2str(channel)]);


% Create a figure window
fig = uifigure('Position',[100 100 700 500],...
            'KeyPressFcn', @keyPress);

% Create a UI axes
ax = uiaxes('Parent',fig,...
            'Units','pixels',...
            'Position', [35, 65, 600, 301]);   

target = intervalSet(evt.time(1,2)*1E4-twin,evt.time(1,2)*1E4+twin);
mainplot = plot(ax,Data(Restrict(LFP,target)));
xline(ax,length(Data(Restrict(LFP,target)))/2,'r');
            

%% Set texts and inputs
lb_evtnb = uilabel(fig);
lb_evtnb.Text = [upper(evtName) ' #:                 of ' num2str(size(evt.time,1))];
lb_evtnb.Position = [272 470 300 22];
lb_evtnb.FontSize = 14;

txt_evtnb = uieditfield(fig,'numeric',...
      'Position',[350 470 50 22],...
      'Limits', [1 size(evt.time,1)],...
      'LowerLimitInclusive','on',...
      'UpperLimitInclusive','on',...
      'Value', ievt, ...
      'ValueChangedFcn',@(txt_evtnb,event) changeEvtNb(txt_evtnb,ax,LFP));

%% Create buttons
% next
bnext = uibutton(fig,'push',...
               'Position',[500, 420, 150, 40],...
               'ButtonPushedFcn', @(btn,event) plot_btnNext(ax,LFP,txt_evtnb));
bnext.Text='Next';
set(fig, 'KeyPressFcn', @(src,event) KeyPress(src,event,bnext))
           
% Previous
bprev = uibutton(fig,'push',...
               'Position',[50, 420, 150, 40],...
               'ButtonPushedFcn', @(btn,event) plot_btnPrev(ax,LFP,txt_evtnb));
bprev.Text='Previous';
set(fig, 'KeyPressFcn', @(src,event) KeyPress(src,event,bprev))

% Reject
brej = uibutton(fig,'push',...
               'Position',[275, 420, 150, 40],...
               'ButtonPushedFcn', @(btn,event) plot_btnRej(ax,LFP,lb_evtnb));
brej.Text='Reject';

% Save and Close
bclose = uibutton(fig,'push',...
               'Position',[500, 10, 150, 40],...
               'ButtonPushedFcn', @(btn,event) plot_btnClose(fig,LFP));
bclose.Text='Save & Close';

%% Create sliders
% amplitue
sld_amp = uislider(fig,...
        'Orientation','vertical', ...
        'Position',[640 125 3 200], ...
        'ValueChangedFcn',@(sld_amp,event) ampchange(sld_amp,ax));
sld_amp.Limits = [250 10000];
sld_amp.Value = ax.YLim(2); 

% time window
sld_dur = uislider(fig,...
        'Position',[225 50 200 3], ...
        'ValueChangedFcn',@(sld_dur,event) durchange(sld_dur,ax,LFP));
sld_dur.Limits = [20 500];
% sld_dur.Value = ax.XLim(2)*1000/1250;
sld_dur.Value = twin/10*2;
end

%% Functions

% Key press function: UIFigure
function KeyPress(src,event,butt)
    key = event.Key;
    switch key
        case 'rightarrow'
            kp = get(butt, 'ButtonPushedFcn');
            kp{1}(src, [], kp{2:end})
        case 'leftarrow'
            kp = get(butt, 'ButtonPushedFcn');
            kp(src, [])
    end
end


% Create the function for the ButtonPushedFcn callback
function plot_btnNext(ax,LFP,txt_evtnb)
    global ievt
    global twin
    global evt

    if ievt<=size(evt.time,1)
        ievt=ievt+1;
        target = intervalSet(evt.time(ievt,2)*1E4-twin,evt.time(ievt,2)*1E4+twin);
        plot(ax,Data(Restrict(LFP,target)))
        xline(ax,length(Data(Restrict(LFP,target)))/2,'r');
        txt_evtnb.Value = ievt;
    end
end

function plot_btnPrev(ax,LFP,txt_evtnb)
    global ievt
    global twin
    global evt
    
    if ievt>1
        ievt=ievt-1;
        target = intervalSet(evt.time(ievt,2)*1E4-twin,evt.time(ievt,2)*1E4+twin);
        plot(ax,Data(Restrict(LFP,target)))
        xline(ax,length(Data(Restrict(LFP,target)))/2,'r');
        txt_evtnb.Value = ievt;
    end
end

function plot_btnRej(ax,LFP,lb_evtnb)
    global ievt
    global evt
    global irej
    global twin
    global evtName
    global change
    
    irej=irej+1;
    evt.rejected.id(irej) = ievt;
    evt.rejected.time(irej,1:size(evt.time,2)) = evt.time(ievt,:);
    
    % change event var
    evt.time(ievt,:) = [];
    st = evt.time(ievt,1)*1e4 -10; 
    en = evt.time(ievt,3)*1e4 + 10;
    is = intervalSet(st,en);
    evt.epoch = evt.epoch-intervalSet(st,en);
    evt.ts(ievt) = [];
    change = 1;
    
    %go to next event
    if ievt<=size(evt.time,1)
        target = intervalSet(evt.time(ievt,2)*1E4-twin,evt.time(ievt,2)*1E4+twin);
    else
        ievt=ievt-1;
        target = intervalSet(evt.time(ievt,2)*1E4-twin,evt.time(ievt,2)*1E4+twin);
    end
    plot(ax,Data(Restrict(LFP,target)))
    xline(ax,length(Data(Restrict(LFP,target)))/2,'r');
    lb_evtnb.Text = [upper(evtName) ' #:                     of ' num2str(size(evt.time,1))];
end

function plot_btnClose(fig,LFP)
    global evtName
    global evt 
    global change
        switch evtName
            case 'ripples'
                if change
                    ripples = evt.time;
                    RipplesEpoch = evt.epoch;
                    tRipples = ts(evt.ts);
                    meanVal = evt.mean;
                    stdVal = evt.std;
                    ripples_Info = evt.info;
                    % Plot Raw stuff
                    disp('Plotting new averaged ripple...')
                    [M,T]=PlotRipRaw(LFP, ripples(:,1:3), [-60 60],0,0);
                    if exist('SWRSorted.mat','file')
                        save('SWRSorted.mat','ripples','RipplesEpoch', ...
                            'tRipples','M','T','evt','-append');
                    else
                        save('SWRSorted.mat','ripples','RipplesEpoch', ...
                            'tRipples','M','T','meanVal','stdVal', ...
                            'ripples_Info','evt');
                    end
                end
            case 'spindles'
                Spindles = evt.time;
                save('SpindlesSorted.mat','ripples','evt','-append');
        end
        close(fig);
end

function changeEvtNb(txt_evtnb,ax,LFP)
    global ievt
    global twin
    global evt

    ievt = txt_evtnb.Value;
    target = intervalSet(evt.time(ievt,2)*1E4-twin,evt.time(ievt,2)*1E4+twin);
    plot(ax,Data(Restrict(LFP,target)))
    xline(ax,length(Data(Restrict(LFP,target)))/2,'r');
end

function ampchange(sld_amp,ax)
    ax.YLim = [-sld_amp.Value sld_amp.Value];
end

function durchange(sld_dur,ax,LFP)
    global twin
    global ievt
    global evt
    
    twin = sld_dur.Value*10;
    target = intervalSet(evt.time(ievt,2)*1E4-twin,evt.time(ievt,2)*1E4+twin);
    plot(ax,Data(Restrict(LFP,target)))
    xline(ax,length(Data(Restrict(LFP,target)))/2,'r');
    %     ax.XLim = [1 sld_dur.Value/(1e4/1250)];
end