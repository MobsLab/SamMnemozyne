%%   MAIN ANALYSES
clear all

%% Global Parameters
expe{1} = 'StimMFBWake';  
mice_num{1} = 882;

expe{2} = 'UMazePAG';
mice_num{1} = [882 941 1117 1161 1162 1168];       % mice ID #
mice_num{2} = [798 828 861 882 905 906 911 912 977 994 1117 1124 1161 1162 1168]; 
% mice_num{2} = [797 798 828 861 882 905 906 911 912 977 994 1117 1124 1161 1162 1168]; 
same_id = [1 5; 3 12; 4 14; 5 15; 6 16];

expe = 'StimMFBWake'; 
mice_num = [882]
mice_num =  [882 941 117 161 162 168];  
mice_num =  [863 934 913 882 941 081 117 124 161 162 168 182];  


expe = 'UMazePAG';
mice_num = [798 828 861 882 905 906 911 912 977 994 1117 1124 1161 1162 1168];



% specific params
limtrials = 0; % limited pre- post-tests trials
recompute = 0; % recalculate (way slower but necesssary if change in past code)

%% Saving folder paths
% behavior
dirPath_behav = [dropbox '/DataSL/' expe '/Behavior/' date '/'];
% ripples
dirPath_sMFBW_rip = [dropbox 'DataSL/' expe '/ripples/Sleep/' date '/'];  
% spindles
dirPath_sMFBW_spin = [dropbox 'DataSL/' expe '/spindles/Sleep/' date '/'];
% sleep
dirPath_sMFBW_sleep = [dropbox 'DataSL/' expe '/Sleep/' date '/'];  % folder where to save
% sleep arch comp mfb vs pag
dirPath_sleepArch_mfbvspag = [dropbox 'DataSL/MFBvsPAG/Sleep/' date '/']; 
% mfb vs pag speed analyses
dirPath_speed_mfbvspag = [dropbox 'DataSL/MFBvsPAG/Speed/' date '/']; 


%% Behavior
[figH_ind figH] = BehaviorERC_SL_v3(expe,mice_num,limtrials,recompute);
    for i=1:length(mice_num)
        % individual
        if isfield(figH_ind,'dirspeed')
            figName = ['Behav_speedDirection__limt' num2str(limtrials) '_'  num2str(mice_num(i))];
            saveF(figH_ind.dirspeed{i},figName,dirPath_behav,'sformat',{'dpng'},'res',300,'savfig',0)
        end
        if isfield(figH_ind,'trajdyn')
            figName = ['Behav_pertrial_zonedyna_'  num2str(mice_num(i))];
            saveF(figH_ind.trajdyn{i},figName,dirPath_behav,'sformat',{'dpng'},'res',300,'savfig',0)
        end
        if isfield(figH_ind,'firstentry')
            figName = ['Behav_latency1stentry_'  num2str(mice_num(i))];
            saveF(figH_ind.firstentry{i},figName,dirPath_behav,'sformat',{'dpng'},'res',300,'savfig',0)
        end
        if isfield(figH_ind,'trajoccup')
            figName = ['Behav_Trajectories_per_trial_'  num2str(mice_num(i))];
            saveF(figH_ind.trajoccup{i},figName,dirPath_behav,'sformat',{'dpng'},'res',300,'savfig',0)
        end
    end
    % global
    if isfield(figH,'globalspeed')
        figName = ['global_SpeedDir_limt' num2str(limtrials)];
        saveF(figH.globalspeed,figName,dirPath_behav,'sformat',{'dpng'},'res',300,'savfig',0)
    end
    if isfield(figH,'globalstats')
        figName = 'general_basic_stats';
        saveF(figH.globalstats,figName,dirPath_behav,'sformat',{'dpng'},'res',300,'savfig',0)
    end
    if isfield(figH,'heatmaps')
        figName = 'Heatmaps_precondpost';
        saveF(figH.heatmaps,figName,dirPath_behav,'sformat',{'dpng'},'res',300,'savfig',0)
    end
    if isfield(figH,'finalfig')
        figName = 'finalfig';
        saveF(figH.finalfig,figName,dirPath_behav,'sformat',{'dpng'},'res',300,'savfig',0)
    end
    if isfield(figH,'heatstat')
        figName = 'Heatstat';
        saveF(figH.heatstat,figName,dirPath_behav,'sformat',{'dpng'},'res',300,'savfig',0)
    end

%% Sleep
% Hsleep = sam_sleep_prevspost(expe,mice_num,'stim',0);
% Need to run s_launchDeltaDetect first
Hsleep = sam_sleep_prevspost_bysess(expe,mice_num,'stim',0); % plot using delta detection restricted to sleep sessions
    for i=1:length(mice_num)
        figName = ['M' num2str(mice_num(i)) '_sleeparch_prepost'];
        saveF(Hsleep.SleepArch_single{i},figName,dirPath_sMFBW_sleep,'sformat',{'dpng'},'res',300,'savfig',0)
        disp(['M' num2str(mice_num(i)) ' saved']);
    end
    
% SLEEP ARCHITECTURE comparison between MFB vs PAG 
% suf =  '_120min';
Harch = compSleepArch_exp(expe, mice_num);
    figName = ['SleepArch_MFBvsPAG_duration' suf];
    saveF(Harch.dur,figName,dirPath_sleepArch_mfbvspag,'sformat',{'dpng'},'res',300,'savfig',0)
    figName = ['SleepArch_MFBvsPAG_perc' suf];
    saveF(Harch.perc,figName,dirPath_sleepArch_mfbvspag,'sformat',{'dpng'},'res',300,'savfig',0)
    figName = ['SleepArch_MFBvsPAG_perc_nowake' suf];
    saveF(Harch.perc_now,figName,dirPath_sleepArch_mfbvspag,'sformat',{'dpng'},'res',300,'savfig',0)
    figName = ['SleepArch_MFBvsPAG_measures' suf];
    saveF(Harch.measures,figName,dirPath_sleepArch_mfbvspag,'sformat',{'dpng'},'res',300,'savfig',0)
    disp(['Figures saved']);    

% %% Ripples
% % during sleep
% Ripples_sleep(expe,mice_num);
% 
% % ripples during task
% RipplesDuringTask_SL(expe,mice_num);
% 
% compare pre/post ripples
% H = compRipStages(expe, [mice_num]);
%     figName = ['GlobalAnalyses_ripples_' num2str(mice_num)];
%     saveF(H.global,figName,dirPath_sMFBW_rip,'sformat',{'dpng'},'res',300,'savfig',0)
%     figName = ['DiffAnalyses_ripples_' num2str(mice_num)];
%     saveF(H.diff,figName,dirPath_sMFBW_rip)
%     
% %% SPINDLES
% % compare pre/post spindles
% H = compSpindleStages(expe, [mice_num]);
%     figName = ['GlobalAnalyses_spindles_' num2str(mice_num)];
%     saveF(H.global,figName,dirPath_sMFBW_spin,'sformat',{'dpng'},'res',300,'savfig',0)
%     figName = ['DiffAnalyses_spindles_' num2str(mice_num)];
%     saveF(H.diff,figName,dirPath_sMFBW_spin)
%     

H = PAGvsMFB_Speed(expe,mice_num)
    figName = ['Speed_MFBvsPAG'];
    saveF(H,figName,dirPath_speed_mfbvspag,'sformat',{'dpng'},'res',900,'savfig',0)

