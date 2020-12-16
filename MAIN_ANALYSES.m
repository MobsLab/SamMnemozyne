%%   MAIN ANALYSES
clear all

%% Global Parameters
expe = 'StimMFBWake';   % experiment name
mice_num = [117];       % mice ID #
dirPath = [dropbox '/DataSL/StimMFBWake/ripples/Sleep/' date '/'];  % folder where to save




%% Behavior
BehaviorERC_SL_8trials(expe,mice_num);


%% Ripples
% during sleep
Ripples_sleep(mice_num);

% ripples during task
RipplesDuringTask_SL(expe,mice_num);

% compare pre/post ripples
H = compRipStages(expe, [mice_num]);
    figName = ['GlobalAnalyses_ripples_' num2str(mice_num)];
    saveF(H.global,figName,dirPath,'sformat',{'dpng'},'res',300,'savfig',0)
    figName = ['DiffAnalyses_ripples_' num2str(mice_num)];
    saveF(H.diff,figName,dirPath)

