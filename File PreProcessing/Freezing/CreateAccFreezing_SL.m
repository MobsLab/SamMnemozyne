% FreezeAccEpoch = CreateAccFreezing (,th_immob, MovAcctsd, ZoneEpoch, Xtsd)
% CreateAccFreezing
% Create FreezingEpoch derived from accelerometer


% Numbers of mice to run analysis on
Mice_to_analyze = 882;

% Get directories
Dir = PathForExperimentsERC_SL_home('StimMFBWake');
Dir = RestrictPathForExperiment(Dir,'nMice', Mice_to_analyze);

%% Parameters
thtps_immob=2;
smoofact_Acc = 15;
th_immob_Acc = 17000000;

%% Do the job
for i=1:length(Dir.path)
    DirCur=Dir.path{i}{1};
    
    cd(DirCur);
    
    load('behavResources.mat');
    
    if exist('MovAcctsd')>0
        NewMovAcctsd=tsd(Range(MovAcctsd),runmean(Data(MovAcctsd),smoofact_Acc));
        FreezeAccEpoch=thresholdIntervals(NewMovAcctsd,th_immob_Acc,'Direction','Below');
        FreezeAccEpoch=mergeCloseIntervals(FreezeAccEpoch,0.3*1e4);
        FreezeAccEpoch=dropShortIntervals(FreezeAccEpoch,thtps_immob*1e4);
        save ('behavResources.mat', 'FreezeAccEpoch', 'thtps_immob', 'smoofact_Acc', 'th_immob_Acc',  '-append');
%         if exist('ZoneEpoch')>0
%             for i = 1:length(ZoneEpoch)
%                 FreezeTime(i)=length(Data(Restrict(Xtsd,and(FreezeAccEpoch,ZoneEpoch{i}))))./length(Data((Restrict(Xtsd,ZoneEpoch{i}))));
%             end
%             save ('behavResources.mat', 'FreezeTime', '-append');
%         end
    end

    clearvars -except Dir thtps_immob smoofact_Acc th_immob_Acc
end
