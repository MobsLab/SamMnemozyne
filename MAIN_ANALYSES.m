%%   MAIN ANALYSES
clear all

%% Global Parameters
expe{1} = 'UMazePAG';
expe{1} = 'StimMFBWake';
expe{1} = 'Novel';
expe{1} = 'BaselineSleep';
expe{1} = 'Known';

% specific params
limtrials = 0; % limited pre- post-tests trials
recompute = 0; % recalculate (way slower but necesssary if change in past code)

%==========================================================================
%                         E X P E R I M E N T S
%                                 A N D 
%                        M I C E    N U M B E R S
%==========================================================================
% ALL MICE
% MFB
expe{1} = 'StimMFBWake';
mice_num{1} = [882 941 1081 1117 1161 1162 1168 1182 1182 1199 1199 1223 1228 1239 1239 1257 1281 1317 1317 1334];  % mice ID #
numexpe{1} = [1 1 1 1 1 1 1 1 2 1 2 1 1 1 2 1 1 1 2 1];
% PAG 
expe{2} = 'UMazePAG';
mice_num{2} = [797 798 828 861 882 905 906 911 912 977 994 1117 1124 1161 1162 1168 1182 1186 1199];
numexpe{2} = [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
% Novel 
expe{3} = 'Novel';
mice_num{3} = [1016 1081 1083 1116 1117 1161 1182 1183 1185 1223 1228 1230];
numexpe{3} = [1 1 1 1 1 1 1 1 1 1 1 1];
% BaselineSleep
expe{4} = 'BaselineSleep';
mice_num{4} = [1162 1162 1168 1168 1168 1185 1199 1230];
numexpe{4} = [1 2 1 2 3 1 1 1];
% Known
expe{5} = 'Known';
mice_num{5} = [1230 1239];
numexpe{5} = [1 1];
% --------------------------------
% ONLY WITH SUBSTAGING
% MFB with spindles and deltas
expe{1} = 'StimMFBWake';
mice_num{1} = [882 1081 1117 1161 1162 1168 1182 1199 1199 1228];  % mice ID #
numexpe{1} = [1 1 1 1 1 1 1 1 2 1];
% PAG with spindles and deltas
expe{2} = 'UMazePAG';
mice_num{2} = [797 798 828 861 882 905 912 994 1117 1124 1161 1162 1168 1182 1199]; 
numexpe{2} = [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
% Novel with spindles and deltas
expe{3} = 'Novel';
mice_num{3} = [1016 1081 1083 1116 1161 1182 1183 1185 1228 1230];
numexpe{3} = [1 1 1 1 1 1 1 1 1 1];
% -------------------------------
% ONLY NEURONS MICE
% MFB 
expe{1} = 'StimMFBWake';
mice_num{1} =  [1117 1162 1223 1228 1239 1239];  % mice ID #
numexpe{1} = [1 1 1 1 1 2];expe{1} = 'Novel';
% PAG 
expe{2} = 'UMazePAG';
mice_num{2} = [905 906 911 994 1161 1162 1168];
numexpe{2} = [1 1 1 1 1 1 1];
% Novel 
expe{3} = 'Novel';
mice_num{3} = [];
numexpe{3} = [1 1 1 1 1 1 1 1 1];
% BaselineSleep
expe{1} = 'BaselineSleep';
mice_num{1} = [1162 1162 1168 1168 1168 1185 1199 1230];
numexpe{1} = [1 2 1 2 3 1 1 1];
% Known
expe{2} = 'Known';
mice_num{2} = [1230 1239];
numexpe{2} = [1 1];

 %-------------------------------------------------------------------------
 %                           SPECIAL CASES
 %-------------------------------------------------------------------------
mice_num{1} = [1317 1317];
mice_num{1} = [1334];
numexpe{1} = [1 2];

% all MFB
mice_num{1} = [882 941 1081 1117 1161 1162 1168 1182 1182 1199 1199 1223 1228 1239 1239];  % mice ID #
numexpe{1} = [1 1 1 1 1 1 1 1 2 1 2 1 1 1 2];

% get experiment names
for iexp=1:length(expe)
    switch expe{iexp}
        case 'StimMFBWake'
            expname{iexp}='MFB';
        case 'Novel'
            expname{iexp}='Novel';
        case 'UMazePAG'
            expname{iexp}='PAG';
        case 'Known'
            expname{iexp}='Known';
        case 'BaselineSleep'
            expname{iexp}='BaselineSleep';
        otherwise
            expname{iexp}=expe{iexp};
    end
    
[figH_ind figH] = BehaviorERC_SL_v3(expe{1},mice_num{1},limtrials,recompute);
    % behavior
    dirPath_behav = [dropbox '/DataSL/' expe{iexp} '/Behavior/'];
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
end
 %% 
 %-------------------------------------------------------------------------
 %                             B E H A V I O R
 %-------------------------------------------------------------------------
iexp=1;
[figH_ind figH] = BehaviorERC_SL_v3(expe{1},mice_num{1},limtrials,recompute);
    % behavior
    dirPath_behav = [dropbox '/DataSL/' expe{iexp} '/Behavior/'];
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

 %% 
 %-------------------------------------------------------------------------
 %                S L E E P   P R E   &   P O S T
 %                C H A R A C T E R I Z A T I O N
 %-------------------------------------------------------------------------
% Hsleep = sam_sleep_prevspost(expe,mice_num,'stim',0);
% Need to run s_launchDeltaDetect first
dirPath_sMFBW_sleep = [dropbox '/DataSL/' expe{1} '/Sleep/' date '/']; 
Hsleep = sam_sleep_prevspost_bysess(expe{1},mice_num{1},numexpe{1},'stim',0); % plot using delta detection restricted to sleep sessions
    for i=1:length(mice_num{1})
        figName = ['M' num2str(mice_num{1}(i)) '_exp' num2str(numexpe{1}) '_sleeparch_prepost'];
        saveF(Hsleep.SleepArch_single{i},figName,dirPath_sMFBW_sleep,'sformat',{'dpng'},'res',300,'savfig',0)
        disp(['M' num2str(mice_num{1}(i)) ' saved']);
    end
    
 %% 
 %-------------------------------------------------------------------------
 %                S L E E P   A R C H I T E C T U R E 
 %                  G R O U P    C O M P A R I S O N
 %-------------------------------------------------------------------------
% SLEEP ARCHITECTURE comparison between Multi-Experiments
suf =  '_50min';
suf = '';
[Harch, sstage] = compSleepArch_exp(expe,mice_num,3000);
    dirPath_sleepArch = [dropbox '/DataSL/Sleep/Architecture/' [expe{:}] '/' date '/'];
    % saving figures 
    figName = ['SleepArch_' expe{1} 'vs' expe{2} '_duration' suf];
    saveF(Harch.dur,figName,dirPath_sleepArch,'sformat',{'dpng'},'res',300,'savfig',0)
    figName = ['SleepArch_' expe{1} 'vs' expe{2} '_perc' suf];
    saveF(Harch.perc,figName,dirPath_sleepArch,'sformat',{'dpng'},'res',300,'savfig',0)
    figName = ['SleepArch_' expe{1} 'vs' expe{2} '_perc_nowake' suf];
    saveF(Harch.perc_now,figName,dirPath_sleepArch,'sformat',{'dpng'},'res',300,'savfig',0)
    figName = ['SleepArch_' expe{1} 'vs' expe{2} '_perc_substg_nowake' suf];
    saveF(Harch.percsub_now,figName,dirPath_sleepArch,'sformat',{'dpng'},'res',300,'savfig',0)
    figName = ['SleepArch_' expe{1} 'vs' expe{2} '_measures' suf];
    saveF(Harch.measures,figName,dirPath_sleepArch,'sformat',{'dpng'},'res',300,'savfig',0)
    figName = ['SleepArch_' expe{1} 'vs' expe{2} '_differences' suf];
    saveF(Harch.diff,figName,dirPath_sleepArch,'sformat',{'dpng'},'res',300,'savfig',0)
    % saving data
    save([dirPath_sleepArch 'SubStage_Results' suf '.mat'],'sstage');
    if isunix
        system(['sudo chown -R hobbes /' dirPath_sleepArch]);
    end
    disp(['Figures saved']);    

 %% 
 %-------------------------------------------------------------------------
 %              S L E E P   E V E N T S  (R I P   &   S P I N)
 %-------------------------------------------------------------------------

%% EVENT PRE/POST SLEEP COMPARISON
for iexp=1:3
    % Ripples
    % compare pre/post ripples
    dirPath_rip = [dropbox '/DataSL/' expe{iexp} '/ripples/Sleep/' date '/']; 
    [H, ripples_data] = compRipStages(expe{iexp}, [mice_num{iexp}], numexpe{iexp});
        % saving figures
        figName = ['GlobalAnalyses_ripples_' num2str(mice_num{iexp})];
        saveF(H.global,figName,dirPath_rip,'sformat',{'dpng'},'res',300,'savfig',0)
        figName = ['DiffAnalyses_ripples_' num2str(mice_num{iexp})];
        saveF(H.diff,figName,dirPath_rip)

        % saving data
        save([dirPath_rip 'ripples_data.mat'],'ripples_data')


    % SPINDLES
    % compare pre/post spindles 
    dirPath_spin = [dropbox '/DataSL/' expe{iexp} '/spindles/Sleep/' date '/'];
    [H, spindles_data] = compSpindleStages(expe{iexp}, [mice_num{iexp}], numexpe{iexp});
        % saving figures
        figName = ['GlobalAnalyses_spindles_' num2str(mice_num{iexp})];
        saveF(H.global,figName,dirPath_spin,'sformat',{'dpng'},'res',300,'savfig',0)
        figName = ['DiffAnalyses_spindles_' num2str(mice_num{iexp})];
        saveF(H.diff,figName,dirPath_spin)

        % saving data
        save([dirPath_spin 'spindles_data.mat'],'spindles_data')
end

 %% 
 %-------------------------------------------------------------------------
 %                         S L E E P   E V E N T S 
 %                   (G R O U P   C O M P A R I S O N S)
 %-------------------------------------------------------------------------

% RIPPLES GROUP COMPARISON
limit = 3000;
[figH ripples_data] = compRipGroups(expe,mice_num,limit);
    % saving figures
    dirPath_ripgr = [dropbox '/DataSL/Ripples/'];
    charName = {'Amplitude','Frequency','Duration','GlobalDen','LocalDen'};
    for i=1:5
            figName = ['Rip_GrpAnalysis_' charName{i} '_' date '_limit' num2str(limit)];
            saveF(figH{i},figName,[dirPath_ripgr], ...
                'sformat',{'dpng'},'res',300,'savfig',0)
    end
    % saving data
    save([dirPath_ripgr 'ripples_data.mat'],'ripples_data')
    system(['sudo chown -R hobbes ' dirPath_ripgr]);

% SPINDLES GROUP COMPARISON
limit = 600;
[figH spindles_data] = compSpiGroups(expe,mice_num,limit);
    % saving figures
    dirPath_spigr = [dropbox '/DataSL/Spindles/'];
    charName = {'Amplitude','Frequency','Duration','GlobalDen','LocalDen'};
    for i=1:5
            figName = ['Spi_GrpAnalysis_' charName{i} '_' date '_limit' num2str(limit)];
            saveF(figH{i},figName,[dirPath_spigr], ...
                'sformat',{'dpng'},'res',300,'savfig',0)
    end
    % saving data
    save([dirPath_spigr 'spindles_data.mat'],'spindles_data')
    system(['sudo chown -R hobbes ' dirPath_spigr]);

 %% 
 %-------------------------------------------------------------------------
 %                            R I P P L E S
 %-------------------------------------------------------------------------
% during sleep
Ripples_sleep(expe,mice_num);

% ripples during task
RipplesDuringTask_SL(expe{iexp},mice_num{iexp},numexpe{iexp});
        
% look at ripples characteristics (amp, dur, freq, density for a whole session (NREM) 
% and for the first minutes)
ripstudy

% mfb vs pag speed analyses
dirPath_speed_mfbvspag = [dropbox '/DataSL/MFBvsPAG/Speed/' date '/']; 
H = PAGvsMFB_Speed(expe,mice_num);
    figName = ['Speed_MFBvsPAG'];
    saveF(H,figName,dirPath_speed_mfbvspag,'sformat',{'dpng'},'res',900,'savfig',0)

 sam_sleeparch_comp(expe{1},mice_num{1})
 
 %% 
 %-------------------------------------------------------------------------
 %                              W A K E
 %-------------------------------------------------------------------------
dir = get_expdir(expe,mice_num);
params = [360 15]; %[300 15];
[figH wake_data] = wakebycycle(dir,expe,mice_num,'remparams',params,'plotfig',1);
    dirPath_wakecycle = [dropbox '/DataSL/Wake/'];
    % saving data
    save([dirPath_wakecycle 'wake_data.mat'],'wake_data')
    system(['sudo chown -R hobbes ' dirPath_wakecycle]);
    % saving figures
    for iexp=1:length(expe)
        for isuj=1:length(mice_num{iexp})
            figName = [expname{iexp} '_M' num2str(mice_num{iexp}(isuj)) ...
                '_' num2str(numexpe{iexp}(isuj)) '_WakeByCycle'];
            saveF(figH{iexp,isuj},figName,dirPath_wakecycle, ...
                'sformat',{'dpng'},'res',300,'savfig',0);
        end
    end
% Group analyses
wakebycycle_granalyses(dir,expe,mice_num,'remparams',params,'plotfig',1);   % figures saved inside script
    
% sleep cycle study
dir = get_expdir(expe,mice_num);
params = [120 180 210 240 270 300 360 420; ...
          15 15 15 15 15 15 15 15];
[sleepcycle] = sleepcycle_study(dir,expe,mice_num,'remparams',params,'plotfig',1);
    dirPath_sleepcycle = [dropbox '/DataSL/SleepCycles/'];
    % saving data
    save([dirPath_sleepcycle 'sleepcycle_data.mat'],'sleepcycle')
    system(['sudo chown -R hobbes ' dirPath_sleepcycle]);


 %% 
 %-------------------------------------------------------------------------
 %                         D A T A    P R E P 
 %                          F O R    S P S S 
 %-------------------------------------------------------------------------
id = [mice_num{:}];
%group
k=1;
for i=1:length(expe)
    gr(k:k+length(mice_num{i}-1),1) = i;
    k=k+length(mice_num{i});
end

k=1;
for iexp=1:length(expe)
    for idat=1:length(mat)
        for isess=1:2
            if ~isnan(mat(iexp,isess,idat))
                arr(k,isess) = mat(iexp,isess,idat);
            else
                arr(k,isess) = [];
            end
        end
        k=k+1;
    end
end