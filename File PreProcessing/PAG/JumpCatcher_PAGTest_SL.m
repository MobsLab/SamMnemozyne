%%% JumpCatcher_PAGTest - catches and plot the amplitudes of jumps 
%
% This function looks for the positive extremum in the accelerometer
% reponse, triggered on stimulation. In other words, it catches the
% amplitude of the stimulation induced jump.
% This version is customized to work with PAGTest data.
% Default version - JumpCatcher.m
%
% 05.10.2018 Dima
%
% Calculate the amplitude of a jump
%
% function CondJumpCatcher(mice,tSmall, saveresults, varargin)
%
% INPUT:
% - dirin                          - a list of folders to process (cell array)
% - artS                           - time around the small stimulation epoch (in s)
% - saveresults                    - save extremi or not (0 or 1)
% - tBig (optional)                - time around the big stimulation epoch (in s) - used just for plotting (default = 5)
% - Smoothing (optional)           - Smoothing factor for accelerometer (default = 5)
% - PlotFig (optional)             - Do you want to plot a figure (0 - no, 1 - yes) (default = 1)
% - SaveFig (optional)             - Do you want to save a figure (0 - no, 1 - yes) (default = 0)
%
% OUTPUT:
% - extremi in behavResources.mat 
% - plot showing the triggered accelerometer response (optional)
%
%
%   see also JumpCatcher
%       
%

function JumpCatcher_PAGTest_SL(dirin,artS, saveresults, varargin)
%% CHECK INPUTS

if nargin < 3 || mod(length(varargin),2) ~= 0
  error('Incorrect number of parameters.');
end


% Parse parameter list
for i = 1:2:length(varargin)
    if ~ischar(varargin{i})
        error(['Parameter ' num2str(i+2) ' is not a property.']);
    end
    switch(lower(varargin{i}))
        case 'tbig'
            artB = varargin{i+1};
            if ~isa(artB,'numeric') && artB <= 0
                error('Wrong value for the big epoch limits');
            end
        case 'smoothing'
            sm = varargin{i+1};
            if ~isa(sm,'numeric') && sm <= 1
                error('Wrong value for smoothing factor');
            end
        case 'plotfig'
            ploto = varargin{i+1};
            if ploto ~= 0 && ploto ~=1
                error('Wrong value for PlotFig');
            end
        case 'savefig'
            savefig = varargin{i+1};
            if savefig ~= 0 && savefig ~=1
                error('Wrong value for SaveFig');
            end 
        otherwise
            error(['Unknown property ''' num2str(varargin{i}) '''.']);
    end
end

%% Parameters (default)
try
   dirin;
catch
   dirin = {
       ''
       };
end

try
   artS;
catch
   artS = 1;
end

try
   saveresults;
catch
   saveresults = 0; 
end

try
   artB;
catch
   artB = 5; 
end

try
   sm;
catch
   sm = 5; 
end

try
   ploto;
catch
   ploto = 1; 
end

try
   savefig;
catch
   savefig = 1; 
end

for k = 1:length(dirin)
    %% Get data
    Acc{k} = load([dirin{k} '/behavResources.mat'],'MovAcctsd', 'TTLInfo');

    %% Prepare data
    % Accelero
    MovAcctsd{k} = Acc{k}.MovAcctsd;
    % Stimulations
    StimEpoch{k} = Acc{k}.TTLInfo.StimEpoch;

 %% Trigger accelerometer on stimulations

    % Epochs
    BigEpoch{k} = intervalSet((Start(StimEpoch{k})-artB*1E4), End(StimEpoch{k})+artB*1E4);
    SmallEpoch{k} = intervalSet((Start(StimEpoch{k})-artS*1E4), End(StimEpoch{k})+artS*1E4);

    A{k} = 500; % No reason - it works
    for i=1:length(Start(BigEpoch{k}))
        try
            AccBigData{k}(i, 1:A{k}) = Data(Restrict(MovAcctsd{k}, subset(BigEpoch{k},i)));
            delme1 = runmean(AccBigData{k}(i, A{k}/2+1:end),sm);
            delme2 = runmean(AccBigData{k}(i, 1:A{k}/2),sm);
            AccBigData{k}(i,1:A{k}) = [delme2 delme1];
        catch
            rmme = Data(Restrict(MovAcctsd{k}, subset(BigEpoch{k},i)));
            AccBigData{k}(i, 1:A{k}) = rmme(1:end-1);
            delme1 = runmean(AccBigData{k}(i, A{k}/2+1:end),sm);
            delme2 = runmean(AccBigData{k}(i, 1:A{k}/2),sm);
            AccBigData{k}(i,1:A{k}) = [delme2 delme1];
        end
    end
    lBig{k} = A{k};

    % Average Big
    AccBigDataMean{k} = mean(AccBigData{k},1);
    AccBigDataSTD{k} = std(AccBigData{k},1);

    A{k} = 100; % No reason - it works
    for i=1:length(Start(SmallEpoch{k}))
        try
            AccSmallData{k}(i, 1:A{k}) = Data(Restrict(MovAcctsd{k}, subset(SmallEpoch{k},i)));
            delme1 = runmean(AccSmallData{k}(i, A{k}/2+1:end),sm);
            delme2 = runmean(AccSmallData{k}(i, 1:A{k}/2),sm);
            AccSmallData{k}(i,1:A{k}) = [delme2 delme1];
        catch
            rmme = Data(Restrict(MovAcctsd{k}, subset(SmallEpoch{k},i)));
            AccSmallData{k}(i, 1:A{k}) = rmme(1:end-1);
            delme1 = runmean(AccSmallData{k}(i, A{k}/2+1:end),sm);
            delme2 = runmean(AccSmallData{k}(i, 1:A{k}/2),sm);
            AccSmallData{k}(i,1:A{k}) = [delme2 delme1];
        end
    end
    lSmall{k} = A{k};

    % Average Small
    AccSmallDataMean{k} = mean(AccSmallData{k},1);
    AccSmallDataSTD{k} = std(AccSmallData{k},1);

    clear rmme delme1 delme2

    %% Get time
    % BigEpoch
    [rBig{k},iBig{k}] = Sync(Range(MovAcctsd{k})/1e4,Start(StimEpoch{k})/1e4,'durations',[-artB artB]);
    [m,tBig{k}] = SyncMap(rBig{k},iBig{k},'durations', [-artB artB], 'nBins', lBig{k});
    % Small Epoch
    [rSmall{k},iSmall{k}] = Sync(Range(MovAcctsd{k})/1e4,Start(StimEpoch{k})/1e4,'durations',[-artS artS]);
    [m,tSmall{k}] = SyncMap(rSmall{k},iSmall{k},'durations', [-artS artS], 'nBins', lSmall{k});

    %% Find the maximum after and before the stimulation
    ID_TimeMoreZeroBig{k} = find(tBig{k}>0, 1,'first');
    ID_TimeLessZeroBig{k} = find(tBig{k}<0, 1,'last');
    MBigAfter{k} = max(AccBigDataMean{k}(ID_TimeMoreZeroBig{k}:end)); % Find max after stimulation
    MBigBefore{k} = max(AccBigDataMean{k}(1:ID_TimeLessZeroBig{k})); % Find max before stimulation
    ind_maxBigAfter{k} = find(AccBigDataMean{k}==MBigAfter{k});
    ind_maxBigBefore{k} = find(AccBigDataMean{k}==MBigBefore{k});
    

    ID_TimeMoreZeroSmall{k} = find(tSmall{k}>0, 1,'first');
    ID_TimeLessZeroSmall{k} = find(tSmall{k}<0, 1,'last');
    MSmallAfter{k} = max(AccSmallDataMean{k}(ID_TimeMoreZeroSmall{k}:end)); % Find max after stimulation
    MSmallBefore{k} = max(AccSmallDataMean{k}(1:ID_TimeLessZeroSmall{k})); % Find max before stimulation
    ind_maxSmallAfter{k} = find(AccSmallDataMean{k}==MSmallAfter{k});
    ind_maxSmallBefore{k} = find(AccSmallDataMean{k}==MSmallBefore{k});
    
    AccRatio{k} = MSmallAfter{k}/MSmallBefore{k};
    
    disp(['StartleIndex = ' num2str(AccRatio{k})]);

    %% Plot
    if ploto
        fb{k} = figure('units','normalized', 'outerposition',[0 0 1 0.6]);
        subplot(121)
        shadedErrorBar(tBig{k}, AccBigDataMean{k}, AccBigDataSTD{k}, 'k', 1);
        hold on
        plot(tBig{k}(ind_maxBigAfter{k}), AccBigDataMean{k}(ind_maxBigAfter{k}), 'r*', 'MarkerSize', 16);
        hold on
        plot(tBig{k}(ind_maxBigBefore{k}), AccBigDataMean{k}(ind_maxBigBefore{k}), 'b*', 'MarkerSize', 16);
        ylabel('Amplitude of accelerometer');
        xlabel('Time in sec');
        set(gca, 'FontSize',13);
        line([0 0],ylim,'color','r', 'LineWidth', 3)

        subplot(122)
        shadedErrorBar(tSmall{k}, AccSmallDataMean{k}, AccSmallDataSTD{k}, 'k', 1);
        hold on
        plot(tSmall{k}(ind_maxSmallAfter{k}), AccSmallDataMean{k}(ind_maxSmallAfter{k}), 'r*',  'MarkerSize', 16);
        hold on
        plot(tSmall{k}(ind_maxSmallBefore{k}), AccSmallDataMean{k}(ind_maxSmallBefore{k}), 'b*',  'MarkerSize', 16);
        set(gca,'YTickLabel',[]);
        xlabel('Time in sec');
        set(gca, 'FontSize',13);
        line([0 0],ylim,'color','r', 'LineWidth', 3)
        
        %% Supertitle
        templ1 = 's/M';
        templ2 = 'CalibContext';
        %templ3 = '.5V';
        %templ4 = 'V';
        ind1 = strfind(dirin{k}, templ1);
        ind2 = strfind(dirin{k}, templ2);
        %ind3 = strfind(dirin{k}, templ3);
        
        mtit(fb{k}, ['Mouse #' dirin{k}(ind1+3:ind1+5) ' - Context ' dirin{k}(ind2+12) ' - ' dirin{k}(length(dirin{k})-4:length(dirin{k})-1)], 'fontsize',14);
        
%         if ~isempty(ind3)
%             mtit(fb{k}, [dirin{k}(ind1:ind1+8) ' Context' dirin{k}(ind2+11) ' ' dirin{k}(ind3-1:ind3+2)], 'fontsize',14);
%         else
%             ind4 = strfind(dirin{k}, templ4);
%             mtit(fb{k}, [dirin{k}(ind1:ind1+8) ' Context' dirin{k}(ind2+11) ' ' dirin{k}(ind4-1:ind4)], 'fontsize',14);
%         end
        
        %%
        if savefig
            saveas(fb{k}, [dirin{k} 'AccTrigStim.fig']);
            saveFigure(fb{k},'AccTriggStim',dirin{k});
        end
    end

    %% Save
    if saveresults
        StartleStimMaxAmp = MSmallAfter{k};
        BeforeStartleMaxAmp = MSmallBefore{k};
        StartleIndex = AccRatio{k};
        if exist([dirin{k} 'behavResources.mat']) == 2
            save([dirin{k} 'behavResources.mat'], 'StartleStimMaxAmp', 'BeforeStartleMaxAmp', 'StartleIndex', '-append');
        else
            save([dirin{k} 'behavResources.mat'], 'StartleStimMaxAmp', 'BeforeStartleMaxAmp', 'StartleIndex');
        end
    end


end
end