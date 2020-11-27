function Dir=PathForExperimentsERC3_SL(experiment)

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


% Animals with Ephys
Ephys={'M994'};
                    
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
%Reversal




%% Path
a=0;


%%

if strcmp(experiment,'Reversal')    
    % Mouse994
%     a=a+1;Dir.path{a}{1}='/media/mobs/DataMOBs116/M0994/Reversal/';
    a=a+1;Dir.path{a}{1}='/media/nas5/ProjetERC3/M994/Reversal/';
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