function Dir=PathForExperimentsERC1_SL(experiment)

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
                    
%% Groups
% Concatenated
LFP = [1]; % Good LFP
Neurons = []; % Good Neurons
ECG = [1]; % Good ECG

% The rest
LFP1 = []; % Good LFP
Neurons1 = []; % Good Neurons
ECG1 = []; % Good ECG

%% Learn or NotLearn by experiment
% StimMFBSleep

% StimMFBWake
learn_stimmfbwake = {'863','913','934','941'};
notlearn_stimmfbwake = {'935','936'};

%Reversal




%% Path
a=0;


%%

if strcmp(experiment,'StimMFBWake')    
    % Mouse882
    a=a+1;Dir.path{a}{1}='/media/nas5/ProjetERC1/M0882/StimMFBwake/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    % Mouse936
%     a=a+1;Dir.path{a}{1}='/media/nas5/ProjetERC1/M0936/StimMFBWake/';
%     a=a+1;Dir.path{a}{1}='/media/mobs/DataMOBS94/M0936/StimMFBWake/';
    a=a+1;Dir.path{a}{1}='/media/mobs/DataMOBS94/M0936/StimMFBWake/take2/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    % Mouse941
    a=a+1;Dir.path{a}{1}='/media/nas5/ProjetERC1/M0941/StimMFBWake/';
%     a=a+1;Dir.path{a}{1}='/media/mobs/DataMOBS94/M0941/StimMFBWake/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    % Mouse934
    a=a+1;Dir.path{a}{1}='/media/mobs/DataMOBS94/M0934/StimMFBWake/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    % Mouse935
    a=a+1;Dir.path{a}{1}='/media/mobs/DataMOBS94/M0935/StimMFBWake/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    % Mouse863
    a=a+1;Dir.path{a}{1}='/media/mobs/DataMOBS94/M0863/StimMFBWake/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    % Mouse913
    a=a+1;Dir.path{a}{1}='/media/mobs/DataMOBS94/M0913/StimMFBWake/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

    
elseif strcmp(experiment,'StimMFBSleep')
    % Mouse936
    a=a+1;Dir.path{a}{1}='/media/mobs/DataMOBS94/M0936/SleepMFB/test7-26-07-2019/';
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
        if strcmp(Dir.path{i}{1}(temp+6),'/')
            Dir.name{i}=['Mouse',Dir.path{i}{1}(temp+3:temp+5)];
        else
            Dir.name{i}=['Mouse',Dir.path{i}{1}(temp+2:temp+4)];
        end
            
    end
    fprintf(Dir.name{i});
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