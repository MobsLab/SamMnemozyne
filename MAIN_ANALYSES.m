%%   MAIN ANALYSES
clear all


%% Global Parameters
expe = 'StimMFBWake';
mice_num = [124];

%% Behavior
BehaviorERC_SL_8trials(expe,mice_num);


%% Ripples
% during sleep
Ripples_sleep(mice_num);
% ripples during task
RipplesDuringTask_SL(expe,mice_num);

