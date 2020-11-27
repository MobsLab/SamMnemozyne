function Dir=PathForExperimentsERC_SL(experiment)

% input:
% name of the experiment.
% possible choices:
% 'StimMFBWake' 'StimMFBSleep'
%
%       ex: 'Hab1' 'BaselineSleep' 'Hab2' 'TestPre' 'Cond' 'PostSleep' 'TestPost' 'Extinct' 'ConfirmMFB' 

% output
% Dir = structure containing paths / names / strains / name of the
% experiment (manipe) / correction for amplification (default=1000)
%
%
% example:
% Dir=PathForExperimentsML('EPM');
%
% merge two Dir:
% Dir=MergePathForExperiment(Dir1,Dir2);
%
%   restrict Dir to mice or group:
% Dir=RestrictPathForExperiment(Dir,'nMice',[245 246])
% Dir=RestrictPathForExperiment(Dir,'Group',{'OBX','hemiOBX'})
% Dir=RestrictPathForExperiment(Dir,'Group','OBX')
%
% similar functions:
% PathForExperimentFEAR.m
% PathForExperimentsDeltaSleep.m
% PathForExperimentsKB.m PathForExperimentsKBnew.m
% PathForExperimentsML.m



%% strains inputs
MICEgroups={'Ephys','Behaviour'};
% Animals with Ephys
Ephys={'M882','M936','M941'};
% Animals with behaviour only
Behaviour={'M863','M913','M934','M935'};
                    

%% Learn or NotLearn by experiment
% StimMFBSleep

% StimMFBWake
learn_stimmfbwake = {'863','882','913','934','941'};
notlearn_stimmfbwake = {'935','936','081','083'};

%Reversal




%% Path
a=0;


%%

if strcmp(experiment,'StimMFBWake')    
    % Mouse882
    a=a+1;Dir.path{a}{1}='/media/nas5/ProjetERC1/StimMFBWake/M0882/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    % Mouse936
    a=a+1;Dir.path{a}{1}='/media/nas5/ProjetERC1/StimMFBWake/M0936/';
%     a=a+1;Dir.path{a}{1}='/media/mobs/DataMOBS94/M0936/StimMFBWake/';
% %     a=a+1;Dir.path{a}{1}='/media/mobs/DataMOBS94/M0936/StimMFBWake/take2/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    % Mouse941
    a=a+1;Dir.path{a}{1}='/media/nas5/ProjetERC1/StimMFBWake/M0941/';
% %     a=a+1;Dir.path{a}{1}='/media/mobs/DataMOBS94/M0941/StimMFBWake/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    % Mouse934
    a=a+1;Dir.path{a}{1}='/media/nas5/ProjetERC1/StimMFBWake/M0934/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    % Mouse935
    a=a+1;Dir.path{a}{1}='/media/nas5/ProjetERC1/StimMFBWake/M0935/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    % Mouse863
    a=a+1;Dir.path{a}{1}='/media/nas5/ProjetERC1/StimMFBWake/M0863/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    % Mouse913
    a=a+1;Dir.path{a}{1}='/media/nas5/ProjetERC1/StimMFBWake/M0913/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    % Mouse1081
    a=a+1;Dir.path{a}{1}='/media/mobs/DataMOBS127/M1081/StimMFBWake/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    % Mouse1083
    a=a+1;Dir.path{a}{1}='/media/mobs/DataMOBS127/M1083/StimMFBWake/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

    % 8 x 2 min pre and post tests mice    
    % Mouse1117
    a=a+1;Dir.path{a}{1}='/media/mobs/DataMOBS135/M1117/SleepMFBWake/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    % Mouse1124
    a=a+1;Dir.path{a}{1}='/media/mobs/DataMOBS135/M1124/StimMFBWake/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

elseif strcmp(experiment,'Novel')
    % Mouse 1081
    a=a+1;Dir.path{a}{1}='/media/mobs/DataMOBS127/M1081/Novel/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo; 
    % Mouse 1083
    a=a+1;Dir.path{a}{1}='/media/mobs/DataMOBS127/M1083/Novel/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo; 
    
elseif strcmp(experiment,'Reversal')    
    % Mouse994
%     a=a+1;Dir.path{a}{1}='/media/mobs/DataMOBs116/M0994/Reversal/';
    a=a+1;Dir.path{a}{1}='/media/nas5/ProjetERC3/M994/Reversal/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;    
    
elseif strcmp(experiment,'StimMFBSleep')
    % Mouse936
    a=a+1;Dir.path{a}{1}='/media/mobs/DataMOBS94/M0936/SleepMFB/test7-26-07-2019/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo; 

elseif strcmp(experiment,'CalibMFB')
    % Mouse936
    a=a+1;Dir.path{a}{1}='/media/mobs/DataMOBs116/M0936/MFBr_dual/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo; 
    % Mouse882
    a=a+1;Dir.path{a}{1}='/media/mobs/DataMOBs116/M0882/Calib/MFB/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo; 
    % Mouse 941
    a=a+1;Dir.path{a}{1}='/media/mobs/DataMOBs116/M0941/Calib/MFB_Dual/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    % Mouse016
    a=a+1;Dir.path{a}{1}='/media/mobs/DataMOBs116/M1016/Calib/CalibMFBr_Dual/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo; 

elseif strcmp(experiment,'CalibDual')
    % Mouse936
    a=a+1;Dir.path{a}{1}='/media/mobs/DataMOBs116/M0936/MFBr_dual/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo; 
    % Mouse941
    a=a+1;Dir.path{a}{1}='/media/mobs/DataMOBs116/M0941/Calib/MFB_Dual/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo; 
    % Mouse016
    a=a+1;Dir.path{a}{1}='/media/mobs/DataMOBs116/M1016/Calib/CalibMFBr_Dual/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo; 

elseif strcmp(experiment,'Encoding')
    % Mouse1081
    a=a+1;Dir.path{a}{1}='/media/mobs/DataMOBS127/M1081/Encoding/20200710/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo; 
else
    error('Invalid name of experiment')
end




%% Get mice names
for i=1:length(Dir.path)
    Dir.manipe{i}=experiment;
    temp=strfind(Dir.path{i}{1},'/M');
    if isempty(temp)
        disp('Error in Filename - No MOUSE number')
    else
        if strcmp(Dir.path{i}{1}(temp(1)+5),'/')
            Dir.name{i}=['Mouse',Dir.path{i}{1}(temp(1)+2:temp+4)];
        else
            Dir.name{i}=['Mouse',Dir.path{i}{1}(temp(1)+3:temp+5)];
        end
            
    end
    fprintf(Dir.name{i});
    temp=[];
end


%% Get Groups
% 
% for i=1:length(Dir.path)
%     Dir.manipe{i}=experiment;
%     if strcmp(Dir.manipe{i},'WakeStimMFB')
%         for j=1:length(LFP)
%             Dir.group{1}{LFP(j)} = 'LFP';
%         end
%         for j=1:length(Neurons)
%             Dir.group{2}{Neurons(j)} = 'Neurons';
%         end
%         for j=1:length(ECG)
%             Dir.group{3}{ECG(j)} = 'ECG';
%         end
%     end
% end

end