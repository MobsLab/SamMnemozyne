%%   MAIN ANALYSES
clear all

%% Global Parameters
expe = 'StimMFBWake';   % experiment name
mice_num = [117 882];       % mice ID #
% folders where to save
dirPath_sMFBW_rip = [dropbox '/DataSL/StimMFBWake/ripples/Sleep/' date '/'];  
dirPath_sMFBW_sleep = [dropbox '/DataSL/StimMFBWake/Sleep/' date '/'];  % folder where to save




%% Behavior
BehaviorERC_SL_8trials(expe,mice_num);


%% Sleep
Hsleep = sam_sleep_prevspost('StimMFBWake',mice_num,'stim',0);
    for i=1:length(mice_num)
        figName = ['M' num2str(mice_num(i)) '_sleeparch_prepost'];
        saveF(Hsleep.SleepArch_single{i},figName,dirPath_sMFBW_sleep,'sformat',{'dpng'},'res',300,'savfig',0)
        disp(['M' num2str(mice_num(i)) ' saved']);
    end
    
%% Ripples
% during sleep
Ripples_sleep(mice_num);

% ripples during task
RipplesDuringTask_SL(expe,mice_num);

% compare pre/post ripples
H = compRipStages(expe, [mice_num]);
    figName = ['GlobalAnalyses_ripples_' num2str(mice_num)];
    saveF(H.global,figName,dirPath_sMFBW_rip,'sformat',{'dpng'},'res',300,'savfig',0)
    figName = ['DiffAnalyses_ripples_' num2str(mice_num)];
    saveF(H.diff,figName,dirPath_sMFBW_rip)

