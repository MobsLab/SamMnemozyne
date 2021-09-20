%%   MAIN ANALYSES
clear all

%% Global Parameters
% expe{1} = 'UMazePAG';
expe{1} = 'StimMFBWake';
expe{1} = 'Novel';

mice_num{1} = 1199;
numexpe{1} = 2;

% all MFB
mice_num{1} = [882 941 1117 1161 1162 1168 1199 1199 1223 1228];  % mice ID #
numexpe{1} = [1 1 1 1 1 1 1 2 1 1];
% MFB with spindles and deltas
mice_num{1} = [882 1117 1161 1162 1168 1199 1199 1228];  % mice ID #
numexpe{1} = [1 1 1 1 1 1 2 1];

expe{2} = 'UMazePAG';
mice_num{2} = [797 798 828 861 882 905 912 977 994 1117 1124 1161 1162 1168 1182 1186 1199]; 
% mice_num{2} = [797 798 828 861 882 905 906 911 912 977 994 1117 1124 1161 1162 1168]; 
same_id = [1 5; 3 12; 4 14; 5 15; 6 16];

expe = 'StimMFBWake'; 
mice_num = [882];
mice_num =  [882 941 117 161 162 168];  
mice_num =  [863 934 913 882 941 081 117 124 161 162 168 182];  

expe = 'UMazePAG';
mice_num = [798 828 861 882 905 906 911 912 977 994 1117 1124 1161 1162 1168];

% specific params
limtrials = 1; % limited pre- post-tests trials
recompute = 0; % recalculate (way slower but necesssary if change in past code)

%% Saving folder paths
iexp=1;
% behavior
dirPath_behav = [dropbox '/DataSL/' expe{iexp} '/Behavior/'];
% ripples
dirPath_sMFBW_rip = [dropbox 'DataSL/' expe{iexp} '/ripples/Sleep/' date '/'];  
% spindles
dirPath_sMFBW_spin = [dropbox 'DataSL/' expe{iexp} '/spindles/Sleep/' date '/'];
% sleep
dirPath_sMFBW_sleep = [dropbox 'DataSL/' expe{iexp} '/Sleep/' date '/'];  % folder where to save
% sleep arch comp mfb vs pag
dirPath_sleepArch_mfbvspag = [dropbox 'DataSL/MFBvsPAG/Sleep/' date '/']; 
% mfb vs pag speed analyses
dirPath_speed_mfbvspag = [dropbox 'DataSL/MFBvsPAG/Speed/' date '/']; 

%% Behavior
iexp=1;
[figH_ind figH] = BehaviorERC_SL_v3(expe{1},mice_num{1},numexpe{1},limtrials,recompute);
    for i=1:length(mice_num{1})
        % individual
        if isfield(figH_ind,'dirspeed')
            figName = [num2str(mice_num{iexp}(i)) '_Behav_speedDirection_exp' ...
                num2str(numexpe{1}(i)) '_limt' num2str(limtrials) '_' date];
            saveF(figH_ind.dirspeed{i},figName,[dirPath_behav  num2str(mice_num{iexp}(i)) '/'], ...
                'sformat',{'dpng'},'res',300,'savfig',0)
        end
        if isfield(figH_ind,'trajdyn')
            figName = [num2str(mice_num{iexp}(i)) '_Behav_pertrial_zonedyna_exp' ...
                num2str(numexpe{1}(i)) '_limt' num2str(limtrials) '_' date];
            saveF(figH_ind.trajdyn{i},figName,[dirPath_behav  num2str(mice_num{iexp}(i)) '/'], ...
                'sformat',{'dpng'},'res',300,'savfig',0)
        end
        if isfield(figH_ind,'firstentry')
            figName = [num2str(mice_num{iexp}(i)) '_Behav_latency1stentry_exp' ...
                num2str(numexpe{1}(i)) '_limt' num2str(limtrials) '_' date];
            saveF(figH_ind.firstentry{i},figName,[dirPath_behav  num2str(mice_num{iexp}(i)) '/'], ...
                'sformat',{'dpng'},'res',300,'savfig',0)
        end
        if isfield(figH_ind,'trajoccup')
            figName = [num2str(mice_num{iexp}(i)) '_Behav_Trajectories_per_exp' ...
                num2str(numexpe{1}(i)) '_trial_limt' num2str(limtrials) '_' date];
            saveF(figH_ind.trajoccup{i},figName,[dirPath_behav  num2str(mice_num{iexp}(i)) '/'], ...
                'sformat',{'dpng'},'res',300,'savfig',0)
        end
    end
    % global
    if isfield(figH,'globalspeed')
        figName = ['global_SpeedDir_limt' num2str(limtrials)];
        saveF(figH.globalspeed,figName,dirPath_behav,'sformat',{'dpng'},'res',300,'savfig',0)
    end
    if isfield(figH,'globalstats')
        figName = ['general_basic_stats_limt' num2str(limtrials)];
        saveF(figH.globalstats,figName,dirPath_behav,'sformat',{'dpng'},'res',300,'savfig',0)
    end
    if isfield(figH,'heatmaps')
        figName = ['Heatmaps_precondpost_limt' num2str(limtrials)];
        saveF(figH.heatmaps,figName,dirPath_behav,'sformat',{'dpng'},'res',300,'savfig',0)
    end
    if isfield(figH,'finalfig')
        figName = ['finalfig_limt' num2str(limtrials)];
        saveF(figH.finalfig,figName,dirPath_behav,'sformat',{'dpng'},'res',300,'savfig',0)
    end
    if isfield(figH,'heatstat')
        figName = ['Heatstat_limt' num2str(limtrials)];
        saveF(figH.heatstat,figName,dirPath_behav,'sformat',{'dpng'},'res',300,'savfig',0)
    end

%% Sleep
% Hsleep = sam_sleep_prevspost(expe,mice_num,'stim',0);
% Need to run s_launchDeltaDetect first
Hsleep = sam_sleep_prevspost_bysess(expe,mice_num{1},numexpe{1},'stim',0); % plot using delta detection restricted to sleep sessions
    for i=1:length(mice_num{1})
        figName = ['M' num2str(mice_num{1}(i)) '_exp' num2str(numexpe{1}) '_sleeparch_prepost'];
        saveF(Hsleep.SleepArch_single{i},figName,dirPath_sMFBW_sleep,'sformat',{'dpng'},'res',300,'savfig',0)
        disp(['M' num2str(mice_num{1}(i)) ' saved']);
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

%% Ripples
% during sleep
Ripples_sleep(expe,mice_num);

% ripples during task
RipplesDuringTask_SL(expe,mice_num{1},numexpe{1});

% compare pre/post ripples
H = compRipStages(expe, [mice_num{1}], numexpe{1});
    figName = ['GlobalAnalyses_ripples_' num2str(mice_num{1})];
    saveF(H.global,figName,dirPath_sMFBW_rip,'sformat',{'dpng'},'res',300,'savfig',0)
    figName = ['DiffAnalyses_ripples_' num2str(mice_num{1})];
    saveF(H.diff,figName,dirPath_sMFBW_rip)
    
%% SPINDLES
% compare pre/post spindles
H = compSpindleStages(expe, [mice_num{1}], numexpe{1});
    figName = ['GlobalAnalyses_spindles_' num2str(mice_num{1})];
    saveF(H.global,figName,dirPath_sMFBW_spin,'sformat',{'dpng'},'res',300,'savfig',0)
    figName = ['DiffAnalyses_spindles_' num2str(mice_num{1})];
    saveF(H.diff,figName,dirPath_sMFBW_spin)
    

H = PAGvsMFB_Speed(expe,mice_num)
    figName = ['Speed_MFBvsPAG'];
    saveF(H,figName,dirPath_speed_mfbvspag,'sformat',{'dpng'},'res',900,'savfig',0)

