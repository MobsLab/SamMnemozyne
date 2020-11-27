function check_stiminfluence(varargin)

%==========================================================================
% Details: Verify in which stages stim occured and influence on sleep/wake 
%
% INPUTS:
%       - 
%
% OPTIONAL inputs:
%       - dropbox_save: specify location where to save the data in
%         in /home/mobs/Dropbox/MOBS_workingON/
%
% OUTPUT:
%       - figures including:
%           - 
%
% NOTES:
%       
%
%   Written by Samuel Laventure - 12-08-2019
%      
%==========================================================================

% load working variables
load('LFPData/DigInfo3.mat');
% load('SleepScoring_OBGamma.mat','Wake','SWSEpoch','REMEpoch','Sleep');  % from SleepScoring_Accelero_OBgamma.m
load('IdFigureData.mat');
load('SleepScoring_OBGamma.mat','SmoothGamma','SmoothTheta');

%set folders
[parentdir,~,~]=fileparts(pwd);
pathOut = [pwd '/Figures/'];
if ~exist(pathOut,'dir')
    mkdir(pathOut);
end

% var init
dbox=0;
wake_id=0;
sleep_id=0;
rem_id=0;
nrem_id=0;

tlaps = 40000;
epoch_dur = 100000; % in 1/10 of ms (desired length /2)

% Parse parameter list
for i = 1:2:length(varargin)
    if ~ischar(varargin{i})
        error(['Parameter ' num2str(i+2) ' is not a property.']);
    end
    switch(lower(varargin{i}))
        case 'dropbox_save'
            dropbox_save = varargin{i+1};
            if ~ischar(dropbox_save)
                error('dropbox_save should be string (name of folder where to save data)');
            else
                dbox=1;
                pathDBox = ['/home/mobs/Dropbox/MOBS_workingON/' dropbox_save];
                if ~exist(pathDBox,'dir')
                    mkdir(pathDBox);
                end
            end

        otherwise
            error(['Unknown property ''' num2str(varargin{i}) '''.']);
    end
end

%% MAIN

% get stim information
StimSent = thresholdIntervals(DigTSD,0.99,'Direction','Above');
nbStim = length(Start(StimSent));
sStim = Start(StimSent);
eStim = End(StimSent);
sStim_prev = sStim-tlaps;
eStim_after = eStim+tlaps;
sStimHz_prev = (sStim-tlaps)*1.250;
eStimHz_after = (eStim+tlaps)*1.250;
 
%get stages info during stim
% epochStart = Start(Epoch); % get all epochs starting time
for istim=1:nbStim
%     Range(Restrict(SleepStages,Epochs{ep}),'s')/3600 ,Data(Restrict(SleepStages,Epochs{ep}))
    sStage{istim} = Data(Restrict(SleepStages,sStim(istim),eStim(istim)));
    sStage_prev{istim} = Data(Restrict(SleepStages,sStim_prev(istim)));  
    sStage_after{istim} = Data(Restrict(SleepStages,eStim_after(istim)));  
    
    %gamma
    sStage_gamma_prev{istim} = Data(Restrict(SmoothGamma,sStimHz_prev(istim)));
    sStage_gamma_after{istim} = Data(Restrict(SmoothGamma,eStimHz_after(istim)));  
    
    %theta
    sStage_theta_prev{istim} = Data(Restrict(SmoothTheta,sStimHz_prev(istim)));
    sStage_theta_after{istim} = Data(Restrict(SmoothTheta,eStimHz_after(istim)));  
    
    %epoch covering before and after stim for ploting
    stimepoch_d{istim} = Data(Restrict(SleepStages,sStim(istim),eStim(istim)));
end
stages= [sStage_prev' sStage' sStage_after'];
stages_gamma = [sStage_gamma_prev' sStage_gamma_after'];
stages_theta = [sStage_theta_prev' sStage_theta_after'];

% get gamma and theta for figure 3
[Mg,Tg] = PlotRipRaw(SmoothGamma,sStim/1e4,epoch_dur/10,0,1,1);
[Mt,Tt] = PlotRipRaw(SmoothTheta,sStim/1e4,epoch_dur/10,0,1,1);


[gamma, theta, SleepEpoch] = MakeIDfunc_ScoringBulb;

%% FIGURE

% % Figure 1
% 
% figure('Color',[1 1 1],'units','normalized', 'position', [0 0 .4 .4]);
%     %axes
%     Sleepscoring_Axes = axes('position', [0.25 0.3 0.5 0.6]);
%     SleepscoringTheta_Axes = axes('position', [0.15 0.3 0.08 0.6]);
%     SleepscoringGamma_Axes = axes('position', [0.25 0.2 0.5 0.1]);
%     
%     axes(Sleepscoring_Axes);
%     if not(isempty(Data(gamma.rem)))
%         plot(log(Data(gamma.rem)),log(Data(theta.rem)),'.','color',[1 0.2 0.2],'MarkerSize',1); hold on
%     else
%         plot(median(log(Data(gamma.sws))),median(log(Data(theta.sws))),'.','color',[1 0.2 0.2],'MarkerSize',1); hold on    
%     end
%     plot(log(Data(gamma.sws)),log(Data(theta.sws)),'.','color',[0.4 0.5 1],'MarkerSize',1); hold on
%     plot(log(Data(gamma.wake)),log(Data(theta.wake)),'.','color',[0.6 0.6 0.6],'MarkerSize',1); hold on
%     for istim=1:nbStim
%         plot(log(sStage_gamma_prev{istim}),log(sStage_theta_prev{istim}),'o','color',[0.2 0.1 0.2],'MarkerSize',3); hold on
%         plot(log(sStage_gamma_after{istim}),log(sStage_theta_after{istim}),'o','color',[0.5 0.1 0.5],'MarkerSize',3); hold on
%     end
%     [~,icons,~,~]=legend('REM','SWS','Wake'); hold on
%     set(icons(5),'MarkerSize',20)
%     set(icons(7),'MarkerSize',20)
%     set(icons(9),'MarkerSize',20)
%     ys=get(gca,'Ylim');
%     xs=get(gca,'Xlim');
%     box on
%     set(gca,'XTick',[],'YTick',[])
% 
%     axes(SleepscoringTheta_Axes);
%     [~, rawN, ~] = nhist(log(Data(Restrict(theta.smooth, SleepEpoch))),'maxx',max(log(Data(Restrict(theta.smooth, SleepEpoch)))),'noerror','xlabel','Theta power','ylabel',[]); axis xy
%     view(90,-90)
%     line([log(theta.threshold) log(theta.threshold)],[0 max(rawN)],'linewidth',4,'color','r')
%     set(gca,'YTick',[],'Xlim',ys)
% 
%     axes(SleepscoringGamma_Axes);
%     [~, rawN, ~] = nhist(log(Data(gamma.smooth)),'maxx',max(log(Data(gamma.smooth))),'noerror','xlabel','Gamma power','ylabel',[]);
%     line([log(gamma.threshold) log(gamma.threshold)],[0 max(rawN)],'linewidth',4,'color','r')
%     set(gca,'YTick',[],'Xlim',xs)
%    
%     % print
%     print([pathOut 'StimPCA'], '-dpng', '-r300');
% 
% % Parameters for figure 2
% 
% % set Y values
% ylabel_substage = {'N3','N2','N1','REM','WAKE'};
% ytick_substage = [1 1.5 2 3 4]; %ordinate in graph
% % set X values
% xtick_sec = [epoch_dur/1e4*-1:epoch_dur/1e4];
% 
% for ix=1:length(xtick_sec)
%     xlab{ix} = num2str(xtick_sec(ix));
% end
% % set colors
% colori = {[0.5 0.3 1], [1 0.5 1], [0.8 0 0.7], [0.1 0.7 0], [0.5 0.2 0.1]}; %substage color
% 
% for istim=1:nbStim
%     figure('Color',[1 1 1],'units','normalized', 'position', [0 0 .5 .3]); 
%         plot(Range(Restrict(SleepStages,sStim(istim)-epoch_dur,eStim(istim)+epoch_dur)), ...
%             Data(Restrict(SleepStages,sStim(istim)-epoch_dur,eStim(istim)+epoch_dur)),'k') 
%         hold on
% %         for ep=1:length(Epochs)
% %             plot(Range(Restrict(Restrict(SleepStages,Epochs{ep}),sStim(istim)-epoch_dur,eStim(istim)+epoch_dur)), ... 
% %                 Data(Restrict(Restrict(SleepStages,Epochs{ep}),sStim(istim)-epoch_dur,eStim(istim)+epoch_dur)),'.','Color',colori{ep})
% %             hold on
% %         end
% 
%         ylim([0.5 5])
%         yL = get(gca,'YLim');
%         line([sStim(istim) sStim(istim)],yL,'Color','r');
%         for itick=1:length(xtick_sec)
%             xt(itick)= Range(Restrict(SleepStages,sStim(istim)+xtick_sec(itick)*1e4));
%         end
%         set(gca,'Xtick',xt,'XTickLabel',xlab)
%         set(gca,'Ytick',ytick_substage,'YTickLabel',ylabel_substage)
%         hold on,
% 
%         title(['Hypnogram - Stim: ' num2str(istim)]); 
%         xlabel('Time (Seconds)')
% 
%         print([pathOut 'Hypnogram_stims' num2str(istim)], '-dpng', '-r300');
% end

% Figure 3

figure('Color',[1 1 1],'units','normalized', 'position', [0 0 .3 .4]); 
    s1=subplot(6,1,1)    
        mtit('Frequency dynamics', 'fontsize',14, 'xoff', 0, 'yoff', 0) %set global title 
        delete(s1)
    subplot(6,1,2:3)
        imagesc(Tg)
        title('Gamma dynamic'); 
        xlabel('Time (ms)');
        ylabel('Stims');
        set(gca,'Ytick',1:nbStim)
        box off
    
    subplot(6,1,5:6)
        imagesc(Tt)
        title('Theta dynamic'); 
        xlabel('Time (ms)');   
        ylabel('Stims');
        set(gca,'Ytick',1:nbStim)
        box off
    
    %save    
    print([pathOut 'FreqChanges'], '-dpng', '-r300');


disp('Done');


end