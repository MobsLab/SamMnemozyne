function Dir=PathForExperimentsPAGTest_SL(experiment)

% input: 
% NAME OF EXPERIMENT
%   -possible choices:
%               'PAG'
%               'CalibB', 'CalibC'
%               'ContextADay1' 'ContextADay2' 'ContextBDay1' 'ContextBDay2' 'ContextCDay1' 'ContextCDay2'
%               'Hab' 'TestPre' 'Cond' 'TestImmediat' 'TestPost' 'TestPost24h', 'TestPost48h'
%               'TestPrePooled', 'TestImmediat', TestPostPooled' 'TestPost24hPooled' 'TestPost48hPooled'
%               'ExperimentDay'
%
% GROUPS:
% 'ContextB', 'ContextC'
% 'Anterior', 'Posterior'
% 'FirstTime', 'SecondTime'

% output
% Dir = structure containing paths / names / strains / name of the
% experiment (manipe) / correction for amplification (default=1000)
%
%
% example:
% Dir=PathForExperimentsPAGTest_Dima('Calib_B');
%
% 	merge two Dir:
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
% PathForExperimentsERC_Dima.m

%% strains inputs

MICEgroups={'Ephys'};

% Animals that were recorded
Ephys={'M784' 'M789' 'M790' 'M791' 'M792'};

% Groups
ContextB = [1 3 7];   %784ant, 789ant, 792ant
ContextC = [2 4 5 6 8];  %784post, 789post, 790post, 791ant, 792post

Anterior = [1 3 6 7];   %784ant, 789ant, 791ant, 792ant
Posterior = [2 4 5 8];  %784post, 789post, 790post, 792post

First = [2 3 5 6 8]; % 784post, 789ant, 790post, 791ant, 792post 
Second = [1 4 7]; % 784ant, 789post, 792ant

ContextB24 = [1 3 7]; %784ant, 789ant, 792ant
ContextC24 = [2 4 5 6 8];  %784post, 789post, 790post, 791ant, 792post

Anterior24 = [1 3 6 7];   %784ant, 789ant, 791ant, 792ant
Posterior24 = [2 4 5 8];  %784post, 789post, 790post, 792post

First24 = [2 3 5 6 8]; % 784post, 789ant, 790post, 791ant, 792post 
Second24 = [1 4 7]; % 784ant, 789post, 792ant

ContextB48 = [1 3 7]; %784ant, 789ant, 792ant
ContextC48 = [2 5 6 8];  %784post, 789post, 790post, 791ant, 792post

Anterior48 = [1 3 6 7];   %784ant, 789ant, 791ant, 792ant
Posterior48 = [2 5 8];  %784post, 789post, 790post, 792post

First48 = [2 3 5 6 8]; % 784post, 789ant, 790post, 791ant, 792post 
Second48 = [1 7]; % 784ant, 792ant


%% Path
% Init var
a=0;

%%

    
    %#####################################################################
    %#
    %#                          EXPERIMENT
    %#
    %#####################################################################
    
if strcmp(experiment,'PAG')
    %Mouse784
    a=a+1;Dir.path{a}{1}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M784/';
    %Mouse789
    a=a+1;Dir.path{a}{1}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M789/';
    %Mouse790
    a=a+1;Dir.path{a}{1}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M790/';
    %Mouse791
    a=a+1;Dir.path{a}{1}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M791/';
     %Mouse792
    a=a+1;Dir.path{a}{1}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M792/';

    
    %#####################################################################
    %#
    %#                     CALIBRATION CONTEXT B
    %#
    %#####################################################################

elseif strcmp(experiment,'CalibB')
    %Mouse784
    a=a+1;Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M784/18092018/CalibContextB/Calib0.0V/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{2}='/media/DataMOBsRAIDN/ProjetPAGTest/M784/18092018/CalibContextB/Calib0.5V/';
    load([Dir.path{a}{2},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{3}='/media/DataMOBsRAIDN/ProjetPAGTest/M784/18092018/CalibContextB/Calib1.0V/';
    load([Dir.path{a}{3},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{4}='/media/DataMOBsRAIDN/ProjetPAGTest/M784/18092018/CalibContextB/Calib0.5V/';
    load([Dir.path{a}{4},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{5}='/media/DataMOBsRAIDN/ProjetPAGTest/M784/18092018/CalibContextB/Calib2.0V/';
    load([Dir.path{a}{5},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{6}='/media/DataMOBsRAIDN/ProjetPAGTest/M784/18092018/CalibContextB/Calib2.5V/';
    load([Dir.path{a}{6},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{7}='/media/DataMOBsRAIDN/ProjetPAGTest/M784/18092018/CalibContextB/Calib3.0V/';
    load([Dir.path{a}{7},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{8}='/media/DataMOBsRAIDN/ProjetPAGTest/M784/18092018/CalibContextB/Calib3.5V/';
    load([Dir.path{a}{8},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{9}='/media/DataMOBsRAIDN/ProjetPAGTest/M784/18092018/CalibContextB/Calib4.0V/';
    load([Dir.path{a}{9},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{10}='/media/DataMOBsRAIDN/ProjetPAGTest/M784/18092018/CalibContextB/Calib4.5V/';
    load([Dir.path{a}{10},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    
    %Mouse789
    a=a+1;Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M789/18092018/CalibContextB/Calib0.0V/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{2}='/media/DataMOBsRAIDN/ProjetPAGTest/M789/18092018/CalibContextB/Calib0.5V/';
    load([Dir.path{a}{2},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{3}='/media/DataMOBsRAIDN/ProjetPAGTest/M789/18092018/CalibContextB/Calib1.0V/';
    load([Dir.path{a}{3},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{4}='/media/DataMOBsRAIDN/ProjetPAGTest/M789/18092018/CalibContextB/Calib1.5V/';
    load([Dir.path{a}{4},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{5}='/media/DataMOBsRAIDN/ProjetPAGTest/M789/18092018/CalibContextB/Calib2.0V/';
    load([Dir.path{a}{5},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    
    %Mouse790
    a=a+1;Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M790/18092018/CalibContextB/Calib0.0V/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{2}='/media/DataMOBsRAIDN/ProjetPAGTest/M790/18092018/CalibContextB/Calib1.0V/';
    load([Dir.path{a}{2},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{3}='/media/DataMOBsRAIDN/ProjetPAGTest/M790/18092018/CalibContextB/Calib1.5V/';
    load([Dir.path{a}{3},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{4}='/media/DataMOBsRAIDN/ProjetPAGTest/M790/18092018/CalibContextB/Calib2.5V/';
    load([Dir.path{a}{4},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{5}='/media/DataMOBsRAIDN/ProjetPAGTest/M790/18092018/CalibContextB/Calib4.0V/';
    load([Dir.path{a}{5},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

    %Mouse791
    a=a+1;Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M791/18092018/CalibContextB/Calib0.0V/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{2}='/media/DataMOBsRAIDN/ProjetPAGTest/M791/18092018/CalibContextB/Calib2.0V/';
    load([Dir.path{a}{2},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    
    %Mouse792
    a=a+1;Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M792/18092018/CalibContextB/Calib0.0V/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{2}='/media/DataMOBsRAIDN/ProjetPAGTest/M792/18092018/CalibContextB/Calib1.0V/';
    load([Dir.path{a}{2},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{3}='/media/DataMOBsRAIDN/ProjetPAGTest/M792/18092018/CalibContextB/Calib2.0V/';
    load([Dir.path{a}{3},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    
    
    
    %#####################################################################
    %#
    %#                     CALIBRATION CONTEXT C
    %#
    %#####################################################################
        
    
    
elseif strcmp(experiment,'CalibC')
    %Mouse784
    a=a+1;Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M784/18092018/CalibContextC/Calib0.0V/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{2}='/media/DataMOBsRAIDN/ProjetPAGTest/M784/18092018/CalibContextC/Calib0.5V/';
    load([Dir.path{a}{2},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{3}='/media/DataMOBsRAIDN/ProjetPAGTest/M784/18092018/CalibContextC/Calib1.0V/';
    load([Dir.path{a}{3},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{4}='/media/DataMOBsRAIDN/ProjetPAGTest/M784/18092018/CalibContextC/Calib1.5V/';
    load([Dir.path{a}{4},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{5}='/media/DataMOBsRAIDN/ProjetPAGTest/M784/18092018/CalibContextC/Calib2.0V/';
    load([Dir.path{a}{5},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{6}='/media/DataMOBsRAIDN/ProjetPAGTest/M784/18092018/CalibContextC/Calib2.5V/';
    load([Dir.path{a}{6},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{7}='/media/DataMOBsRAIDN/ProjetPAGTest/M784/18092018/CalibContextC/Calib3.0V/';
    load([Dir.path{a}{7},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{8}='/media/DataMOBsRAIDN/ProjetPAGTest/M784/18092018/CalibContextC/Calib3.5V/';
    load([Dir.path{a}{8},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{9}='/media/DataMOBsRAIDN/ProjetPAGTest/M784/18092018/CalibContextC/Calib4.0V/';
    load([Dir.path{a}{9},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{10}='/media/DataMOBsRAIDN/ProjetPAGTest/M784/18092018/CalibContextC/Calib4.5V/';
    load([Dir.path{a}{10},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{11}='/media/DataMOBsRAIDN/ProjetPAGTest/M784/18092018/CalibContextC/Calib5.0V/';
    load([Dir.path{a}{11},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{12}='/media/DataMOBsRAIDN/ProjetPAGTest/M784/18092018/CalibContextC/Calib5.5V/';
    load([Dir.path{a}{12},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{13}='/media/DataMOBsRAIDN/ProjetPAGTest/M784/18092018/CalibContextC/Calib6.0V/';
    load([Dir.path{a}{13},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        
    %Mouse789
    a=a+1;Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M789/18092018/CalibContextC/Calib0.0V/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{2}='/media/DataMOBsRAIDN/ProjetPAGTest/M789/18092018/CalibContextC/Calib1.0V/';
    load([Dir.path{a}{2},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{3}='/media/DataMOBsRAIDN/ProjetPAGTest/M789/18092018/CalibContextC/Calib1.5V/';
    load([Dir.path{a}{3},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{4}='/media/DataMOBsRAIDN/ProjetPAGTest/M789/18092018/CalibContextC/Calib2.0V/';
    load([Dir.path{a}{4},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{5}='/media/DataMOBsRAIDN/ProjetPAGTest/M789/18092018/CalibContextC/Calib2.5V/';
    load([Dir.path{a}{5},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{6}='/media/DataMOBsRAIDN/ProjetPAGTest/M789/18092018/CalibContextC/Calib3.5V/';
    load([Dir.path{a}{6},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{7}='/media/DataMOBsRAIDN/ProjetPAGTest/M789/18092018/CalibContextC/Calib4.0V/';
    load([Dir.path{a}{7},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{8}='/media/DataMOBsRAIDN/ProjetPAGTest/M789/18092018/CalibContextC/Calib4.5V/';
    load([Dir.path{a}{8},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    
    %Mouse790
    a=a+1;Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M790/18092018/CalibContextC/Calib0.0V/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{2}='/media/DataMOBsRAIDN/ProjetPAGTest/M790/18092018/CalibContextC/Calib1.0V/';
    load([Dir.path{a}{2},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{3}='/media/DataMOBsRAIDN/ProjetPAGTest/M790/18092018/CalibContextC/Calib1.5V/';
    load([Dir.path{a}{3},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{5}='/media/DataMOBsRAIDN/ProjetPAGTest/M790/18092018/CalibContextC/Calib2.5V/';
    load([Dir.path{a}{5},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{6}='/media/DataMOBsRAIDN/ProjetPAGTest/M790/18092018/CalibContextC/Calib3.0V/';
    load([Dir.path{a}{6},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{7}='/media/DataMOBsRAIDN/ProjetPAGTest/M790/18092018/CalibContextC/Calib3.5V/';
    load([Dir.path{a}{7},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{8}='/media/DataMOBsRAIDN/ProjetPAGTest/M790/18092018/CalibContextC/Calib4.0V/';
    load([Dir.path{a}{8},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{9}='/media/DataMOBsRAIDN/ProjetPAGTest/M790/18092018/CalibContextC/Calib4.5V/';
    load([Dir.path{a}{9},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    
    %Mouse791
    a=a+1;Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M791/18092018/CalibContextC/Calib0.0V/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{2}='/media/DataMOBsRAIDN/ProjetPAGTest/M791/18092018/CalibContextC/Calib1.0V/';
    load([Dir.path{a}{2},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{3}='/media/DataMOBsRAIDN/ProjetPAGTest/M791/18092018/CalibContextC/Calib2.0V/';
    load([Dir.path{a}{3},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{5}='/media/DataMOBsRAIDN/ProjetPAGTest/M791/18092018/CalibContextC/Calib3.5V/';
    load([Dir.path{a}{5},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{6}='/media/DataMOBsRAIDN/ProjetPAGTest/M791/18092018/CalibContextC/Calib4.0V/';
    load([Dir.path{a}{6},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{7}='/media/DataMOBsRAIDN/ProjetPAGTest/M791/18092018/CalibContextC/Calib5.0V/';
    load([Dir.path{a}{7},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{8}='/media/DataMOBsRAIDN/ProjetPAGTest/M791/18092018/CalibContextC/Calib6.0V/';
    load([Dir.path{a}{8},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{9}='/media/DataMOBsRAIDN/ProjetPAGTest/M791/18092018/CalibContextC/Calib7.0V/';
    load([Dir.path{a}{9},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    
    %Mouse792    
    a=a+1;Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M792/18092018/CalibContextC/Calib0.0V/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;    
    Dir.path{a}{2}='/media/DataMOBsRAIDN/ProjetPAGTest/M792/18092018/CalibContextC/Calib1.0V/';
    load([Dir.path{a}{2},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;    
    Dir.path{a}{4}='/media/DataMOBsRAIDN/ProjetPAGTest/M792/18092018/CalibContextC/Calib3.0V/';
    load([Dir.path{a}{4},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;    
    Dir.path{a}{5}='/media/DataMOBsRAIDN/ProjetPAGTest/M792/18092018/CalibContextC/Calib4.0V/';
    load([Dir.path{a}{5},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;    
    Dir.path{a}{6}='/media/DataMOBsRAIDN/ProjetPAGTest/M792/18092018/CalibContextC/Calib5.0V/';
    load([Dir.path{a}{6},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;    
    Dir.path{a}{7}='/media/DataMOBsRAIDN/ProjetPAGTest/M792/18092018/CalibContextC/Calib5.5V/';
    load([Dir.path{a}{7},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;    
    Dir.path{a}{8}='/media/DataMOBsRAIDN/ProjetPAGTest/M792/18092018/CalibContextC/Calib6.5V/';
    load([Dir.path{a}{8},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;    
    Dir.path{a}{9}='/media/DataMOBsRAIDN/ProjetPAGTest/M792/18092018/CalibContextC/Calib7.0V/';
    load([Dir.path{a}{9},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

    %#####################################################################
    %#
    %#                            CONTEXT A - NEUTRAL - BASELINE
    %#
    %#####################################################################
    
elseif strcmp(experiment,'ContextADay1')
    %Mouse784
    a=a+1;Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M784/18092018/CalibContextA/';
    %Mouse789
    a=a+1;Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M789/18092018/CalibContextA/';
    %Mouse790
    a=a+1;Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M790/18092018/CalibContextA/';
    %Mouse791
    a=a+1;Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M791/18092018/CalibContextA/';
     %Mouse792
    a=a+1;Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M792/18092018/CalibContextA/';
    
    %#####################################################################
    %#
    %#                            CONTEXT A - NEUTRAL - TEST
    %#
    %#####################################################################
    
elseif strcmp(experiment,'ContextADay2')
    %Mouse784
    a=a+1;Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M784/19092018/PostCalib-ContextA/';
    %Mouse789
    a=a+1;Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M789/19092018/PostCalib-ContextA/';
    %Mouse790
    a=a+1;Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M790/19092018/PostCalib-ContextA/';
    %Mouse791
    a=a+1;Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M791/19092018/PostCalib-ContextA/';
     %Mouse792
    a=a+1;Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M792/19092018/PostCalib-ContextA/';
    
    
    %#####################################################################
    %#
    %#                      CONTEXT B - ROOM 1 - CALIBRATION
    %#
    %#####################################################################
    
elseif strcmp(experiment,'ContextBDay1')
    %Mouse784
    a=a+1;Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M784/18092018/CalibContextB/Calib4.5V/';
    %Mouse789
    a=a+1;Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M789/18092018/CalibContextB/Calib2.0V/';
    %Mouse790
    a=a+1;Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M790/18092018/CalibContextB/Calib4.0V/';
    %Mouse791
    a=a+1;Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M791/18092018/CalibContextB/Calib2.0V/';
     %Mouse792
    a=a+1;Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M792/18092018/CalibContextB/Calib2.0V/';
    
    %#####################################################################
    %#
    %#                         CONTEXT B - ROOM 1 - TEST
    %#
    %#####################################################################
    
    
elseif strcmp(experiment,'ContextBDay2')
    %Mouse784
    a=a+1;Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M784/19092018/PostCalib-ContextB/';
    %Mouse789
    a=a+1;Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M789/19092018/PostCalib-ContextB/';
    %Mouse790
    a=a+1;Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M790/19092018/PostCalib-ContextB/';
    %Mouse791
    a=a+1;Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M791/19092018/PostCalib-ContextB/';
    %Mouse792
    a=a+1;Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M792/19092018/PostCalib-ContextB/';
    
    %#####################################################################
    %#
    %#                      CONTEXT C - ROOM 2 - CALIBRATION
    %#
    %#####################################################################
    
elseif strcmp(experiment,'ContextCDay1')
    %Mouse784
    a=a+1;Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M784/18092018/CalibContextC/Calib6.0V/';
    %Mouse789
    a=a+1;Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M789/18092018/CalibContextC/Calib4.5V/';
    %Mouse790
    a=a+1;Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M790/18092018/CalibContextC/Calib4.5V/';
    %Mouse791
    a=a+1;Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M791/18092018/CalibContextC/Calib7.0V/';
    %Mouse792
    a=a+1;Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M792/18092018/CalibContextC/Calib7.0V/';
    
    %#####################################################################
    %#
    %#                         CONTEXT C - ROOM 2 - TEST
    %#
    %#####################################################################
    
    
elseif strcmp(experiment,'ContextCDay2')
    %Mouse784
    a=a+1;Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M784/19092018/PostCalib-ContextC/';
    %Mouse789
    a=a+1;Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M789/19092018/PostCalib-ContextC/';
    %Mouse790
    a=a+1;Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M790/19092018/PostCalib-ContextC/';
    %Mouse791
    a=a+1;Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M791/19092018/PostCalib-ContextC/';
    %Mouse792
    a=a+1;Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M792/19092018/PostCalib-ContextC/';
    
    
    
    
    
    %#####################################################################
    %#
    %#                            HABITUATION
    %#
    %#####################################################################
        
    
elseif strcmp(experiment,'Hab')
    
    %Mouse784
    a=a+1;
    Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M784/20092018/AnteriorStim/Hab/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    a=a+1;
    Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M784/19092018/PosteriorStim/Hab/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    
    %Mouse789
    a=a+1;
    Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M789/19092018/AnteriorStim/Hab/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    a=a+1;
    Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M789/20092018/PosteriorStim/Hab/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    
    %Mouse790
    a=a+1;
    Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M790/19092018/PosteriorStim/Hab/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    
    %Mouse791
    a=a+1;
    Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M791/20092018/AnteriorStim/Hab/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    
    %Mouse792
    a=a+1;
    Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M792/20092018/AnteriorStim/Hab/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    a=a+1;   
    Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M792/19092018/PosteriorStim/Hab/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;  
    
    
    %#####################################################################
    %#
    %#                            PRE-TESTS
    %#
    %#####################################################################
  
elseif strcmp(experiment,'TestPre')
    
    % Mouse784
    %Anterior
    a=a+1;
    cc=1;
    for c=1:4
        Dir.path{a}{cc}=['/media/DataMOBsRAIDN/ProjetPAGTest/M784/20092018/AnteriorStim/Pretests/pre' num2str(c) '/'];
        load([Dir.path{a}{cc}([1:end-6,1]),'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        cc=cc+1;
    end
    %Posterior  
    a=a+1;
    cc=1;
    for c=1:4
        Dir.path{a}{cc}=['/media/DataMOBsRAIDN/ProjetPAGTest/M784/19092018/PosteriorStim/Pretests/pre' num2str(c) '/'];
        load([Dir.path{a}{cc}([1:end-6,1]),'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        cc=cc+1;
    end
    
    % Mouse789
    a=a+1;
    cc=1;
    %Anterior
    for c=1:4
        Dir.path{a}{cc}=['/media/DataMOBsRAIDN/ProjetPAGTest/M789/19092018/AnteriorStim/Pretests/pre' num2str(c) '/'];
        load([Dir.path{a}{cc}([1:end-6,1]),'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        cc=cc+1;
    end
    a=a+1;
    cc=1;
    %Posterior    
    for c=1:4
        Dir.path{a}{cc}=['/media/DataMOBsRAIDN/ProjetPAGTest/M789/20092018/PosteriorStim/Pretests/pre' num2str(c) '/'];
        load([Dir.path{a}{cc}([1:end-6,1]),'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        cc=cc+1;
    end
    
    % Mouse790
    a=a+1;
    cc=1;
    %Anterior
    for c=1:4
        Dir.path{a}{cc}=['/media/DataMOBsRAIDN/ProjetPAGTest/M790/19092018/PosteriorStim/Pretests/pre' num2str(c) '/'];
        load([Dir.path{a}{cc}([1:end-6,1]),'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        cc=cc+1;
    end
    
    % Mouse791
    a=a+1;
    cc=1;
    %Anterior
    for c=1:4
        Dir.path{a}{cc}=['/media/DataMOBsRAIDN/ProjetPAGTest/M791/20092018/AnteriorStim/Pretests/pre' num2str(c) '/'];
        load([Dir.path{a}{cc}([1:end-6,1]),'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        cc=cc+1;
    end
    
    % Mouse792
    a=a+1;
    cc=1;
    %Anterior
    for c=1:4
        Dir.path{a}{cc}=['/media/DataMOBsRAIDN/ProjetPAGTest/M792/20092018/AnteriorStim/Pretests/pre' num2str(c) '/'];
        load([Dir.path{a}{cc}([1:end-6,1]),'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        cc=cc+1;
    end
    a=a+1;
    cc=1;
    %Posterior    
    for c=1:4
        Dir.path{a}{cc}=['/media/DataMOBsRAIDN/ProjetPAGTest/M792/19092018/PosteriorStim/Pretests/pre' num2str(c) '/'];
        load([Dir.path{a}{cc}([1:end-6,1]),'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        cc=cc+1;
    end

    
    %#####################################################################
    %#
    %#                            CONDITIONNING
    %#
    %#####################################################################
    
    
elseif strcmp(experiment,'Cond')
    
    % Mouse784
    a=a+1;
    cc=1;
    %Anterior
    for c=1:4
        Dir.path{a}{cc}=['/media/DataMOBsRAIDN/ProjetPAGTest/M784/20092018/AnteriorStim/Cond/Cond' num2str(c),'/'];
        load([Dir.path{a}{cc}([1:end-7,1]),'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        cc=cc+1;
    end
    a=a+1;
    cc=1;
    %Posterior    
    for c=1:4
        Dir.path{a}{cc}=['/media/DataMOBsRAIDN/ProjetPAGTest/M784/20092018/AnteriorStim/Cond/Cond' num2str(c) '/'];
        load([Dir.path{a}{cc}([1:end-7,1]),'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        cc=cc+1;
    end
    % Mouse789
    a=a+1;
    cc=1;
    %Anterior
    for c=1:4
        Dir.path{a}{cc}=['/media/DataMOBsRAIDN/ProjetPAGTest/M789/19092018/AnteriorStim/Cond/Cond' num2str(c) '/'];
        load([Dir.path{a}{cc}([1:end-7,1]),'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        cc=cc+1;
    end
    a=a+1;
    cc=1;
    %Posterior    
    for c=1:4
        Dir.path{a}{cc}=['/media/DataMOBsRAIDN/ProjetPAGTest/M789/20092018/PosteriorStim/Cond/Cond' num2str(c) '/'];
        load([Dir.path{a}{cc}([1:end-7,1]),'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        cc=cc+1;
    end
    
    % Mouse790
    a=a+1;
    cc=1;
    %Anterior
    for c=1:4
        Dir.path{a}{cc}=['/media/DataMOBsRAIDN/ProjetPAGTest/M790/19092018/PosteriorStim/Cond/Cond' num2str(c) '/'];
        load([Dir.path{a}{cc}([1:end-7,1]),'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        cc=cc+1;
    end
    
    % Mouse791
    a=a+1;
    cc=1;
    %Anterior
    for c=1:4
        Dir.path{a}{cc}=['/media/DataMOBsRAIDN/ProjetPAGTest/M791/20092018/AnteriorStim/Cond/Cond' num2str(c) '/'];
        load([Dir.path{a}{cc}([1:end-7,1]),'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        cc=cc+1;
    end
    
    % Mouse792
    a=a+1;
    cc=1;
    %Anterior
    for c=1:4
        Dir.path{a}{cc}=['/media/DataMOBsRAIDN/ProjetPAGTest/M792/20092018/AnteriorStim/Cond/Cond' num2str(c) '/'];
        load([Dir.path{a}{cc}([1:end-7,1]),'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        cc=cc+1;
    end
    a=a+1;
    cc=1;
    %Posterior    
    for c=1:4
        Dir.path{a}{cc}=['/media/DataMOBsRAIDN/ProjetPAGTest/M792/19092018/PosteriorStim/Cond/Cond' num2str(c) '/'];
        load([Dir.path{a}{cc}([1:end-7,1]),'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        cc=cc+1;
    end
    
    
    
    %#####################################################################
    %#
    %#                        POST-TESTS (IMMEDIAT)
    %#
    %#####################################################################
    
elseif strcmp(experiment,'TestImmediat')
    
    % Mouse784
    a=a+1;
    cc=1;
    %Anterior
    for c=1:4
        Dir.path{a}{cc}=['/media/DataMOBsRAIDN/ProjetPAGTest/M784/20092018/AnteriorStim/PostTests/posttest' num2str(c) '/'];
        load([Dir.path{a}{cc}([1:end-11,1]),'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        cc=cc+1;
    end
    %Posterior   
    a=a+1;
    cc=1; 
    for c=1:4
        Dir.path{a}{cc}=['/media/DataMOBsRAIDN/ProjetPAGTest/M784/20092018/AnteriorStim/PostTests/posttest' num2str(c) '/'];
        load([Dir.path{a}{cc}([1:end-11,1]),'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        cc=cc+1;
    end
    % Mouse789
    a=a+1;
    cc=1;
    %Anterior
    for c=1:4
        Dir.path{a}{cc}=['/media/DataMOBsRAIDN/ProjetPAGTest/M789/19092018/AnteriorStim/PostTests/posttest' num2str(c) '/'];
        load([Dir.path{a}{cc}([1:end-11,1]),'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        cc=cc+1;
    end
    a=a+1;
    cc=1;
    %Posterior    
    for c=1:4
        Dir.path{a}{cc}=['/media/DataMOBsRAIDN/ProjetPAGTest/M789/20092018/PosteriorStim/PostTests/posttest' num2str(c) '/'];
        load([Dir.path{a}{cc}([1:end-11,1]),'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        cc=cc+1;
    end
    
    % Mouse790
    a=a+1;
    cc=1;
    %Anterior
    for c=1:4
        Dir.path{a}{cc}=['/media/DataMOBsRAIDN/ProjetPAGTest/M790/19092018/PosteriorStim/PostTests/posttest' num2str(c) '/'];
        load([Dir.path{a}{cc}([1:end-11,1]),'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        cc=cc+1;
    end
    
    % Mouse791
    a=a+1;
    cc=1;
    %Anterior (ONLY 3 TRIALS RECORDED)
    for c=1:3
        Dir.path{a}{cc}=['/media/DataMOBsRAIDN/ProjetPAGTest/M791/20092018/AnteriorStim/PostTests/posttest' num2str(c) '/'];
        load([Dir.path{a}{cc}([1:end-11,1]),'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        cc=cc+1;
    end
    
    % Mouse792
    a=a+1;
    cc=1;
    %Anterior
    for c=1:4
        Dir.path{a}{cc}=['/media/DataMOBsRAIDN/ProjetPAGTest/M792/20092018/AnteriorStim/PostTests/posttest' num2str(c) '/'];
        load([Dir.path{a}{cc}([1:end-11,1]),'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        cc=cc+1;
    end
    a=a+1;
    cc=1;
    %Posterior    
    for c=1:4
        Dir.path{a}{cc}=['/media/DataMOBsRAIDN/ProjetPAGTest/M792/19092018/PosteriorStim/PostTests/posttest' num2str(c) '/'];
        load([Dir.path{a}{cc}([1:end-11,1]),'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        cc=cc+1;
    end
    
    
    
    %#####################################################################
    %#
    %#                            POST-SLEEP
    %#
    %#####################################################################
    
    
elseif strcmp(experiment,'TestPost')
    
    % Mouse784
    a=a+1;
    cc=1;
    %Anterior
    for c=1:4
        Dir.path{a}{cc}=['/media/DataMOBsRAIDN/ProjetPAGTest/M784/20092018/AnteriorStim/PostSleep/postsleep' num2str(c) '/'];
        load([Dir.path{a}{cc}([1:end-12,1]),'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        cc=cc+1;
    end
    a=a+1;
    cc=1;
    %Posterior    
    for c=1:4
        Dir.path{a}{cc}=['/media/DataMOBsRAIDN/ProjetPAGTest/M784/20092018/AnteriorStim/PostSleep/postsleep' num2str(c) '/'];
        load([Dir.path{a}{cc}([1:end-12,1]),'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        cc=cc+1;
    end
    % Mouse789
    a=a+1;
    cc=1;
    %Anterior
    for c=1:4
        Dir.path{a}{cc}=['/media/DataMOBsRAIDN/ProjetPAGTest/M789/19092018/AnteriorStim/PostSleep/postsleep' num2str(c) '/'];
        load([Dir.path{a}{cc}([1:end-12,1]),'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        cc=cc+1;
    end
    a=a+1;
    cc=1;
    %Posterior    
    for c=1:4
        Dir.path{a}{cc}=['/media/DataMOBsRAIDN/ProjetPAGTest/M789/20092018/PosteriorStim/PostSleep/postsleep' num2str(c) '/'];
        load([Dir.path{a}{cc}([1:end-12,1]),'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        cc=cc+1;
    end
    
    % Mouse790
    a=a+1;
    cc=1;
    %Anterior
    for c=1:4
        Dir.path{a}{cc}=['/media/DataMOBsRAIDN/ProjetPAGTest/M790/19092018/PosteriorStim/PostSleep/postsleep' num2str(c) '/'];
        load([Dir.path{a}{cc}([1:end-12,1]),'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        cc=cc+1;
    end
    
    % Mouse791
    a=a+1;
    cc=1;
    %Anterior
    for c=1:4
        Dir.path{a}{cc}=['/media/DataMOBsRAIDN/ProjetPAGTest/M791/20092018/AnteriorStim/PostSleep/postsleep' num2str(c) '/'];
        load([Dir.path{a}{cc}([1:end-12,1]),'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        cc=cc+1;
    end
    
    % Mouse792
    a=a+1;
    cc=1;
    %Anterior
    for c=1:4
        Dir.path{a}{cc}=['/media/DataMOBsRAIDN/ProjetPAGTest/M792/20092018/AnteriorStim/PostSleep/postsleep' num2str(c) '/'];
        load([Dir.path{a}{cc}([1:end-12,1]),'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        cc=cc+1;
    end
    a=a+1;
    cc=1;
    %Posterior    
    for c=1:4
        Dir.path{a}{cc}=['/media/DataMOBsRAIDN/ProjetPAGTest/M792/19092018/PosteriorStim/PostSleep/postsleep' num2str(c) '/'];
        load([Dir.path{a}{cc}([1:end-12,1]),'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        cc=cc+1;
    end
    
    
    
    %#####################################################################
    %#
    %#                            POST-24H
    %#
    %#####################################################################
    
    
elseif strcmp(experiment,'TestPost24h')
    
    % Mouse784
    a=a+1;
    cc=1;
    %Anterior
    for c=1:4
        Dir.path{a}{cc}=['/media/DataMOBsRAIDN/ProjetPAGTest/M784/21092018/AnteriorStim/Post24h/post24h' num2str(c) '/'];
        load([Dir.path{a}{cc}([1:end-10,1]),'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        cc=cc+1;
    end
    a=a+1;
    cc=1;
    %Posterior    
    for c=1:4
        Dir.path{a}{cc}=['/media/DataMOBsRAIDN/ProjetPAGTest/M784/20092018/PosteriorStim/Post24h/post24h' num2str(c) '/'];
        load([Dir.path{a}{cc}([1:end-10,1]),'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        cc=cc+1;
    end
    % Mouse789
    a=a+1;
    cc=1;
    %Anterior
    for c=1:4
        Dir.path{a}{cc}=['/media/DataMOBsRAIDN/ProjetPAGTest/M789/20092018/AnteriorStim/Post24h/post24h' num2str(c) '/'];
        load([Dir.path{a}{cc}([1:end-10,1]),'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        cc=cc+1;
    end
    a=a+1;
    cc=1;
    %Posterior    
    for c=1:4
        Dir.path{a}{cc}=['/media/DataMOBsRAIDN/ProjetPAGTest/M789/21092018/PosteriorStim/Post24h/post24h' num2str(c) '/'];
        load([Dir.path{a}{cc}([1:end-10,1]),'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        cc=cc+1;
    end
    
    % Mouse790
    a=a+1;
    cc=1;
    %Anterior
    for c=1:4
        Dir.path{a}{cc}=['/media/DataMOBsRAIDN/ProjetPAGTest/M790/20092018/PosteriorStim/Post24h/post24h' num2str(c) '/'];
        load([Dir.path{a}{cc}([1:end-10,1]),'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        cc=cc+1;
    end
    
    % Mouse791
    a=a+1;
    cc=1;
    %Anterior
    for c=1:4
        Dir.path{a}{cc}=['/media/DataMOBsRAIDN/ProjetPAGTest/M791/21092018/AnteriorStim/Post24h/post24h' num2str(c) '/'];
        load([Dir.path{a}{cc}([1:end-10,1]),'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        cc=cc+1;
    end
    
    % Mouse792
    a=a+1;
    cc=1;
    %Anterior
    for c=1:4
        Dir.path{a}{cc}=['/media/DataMOBsRAIDN/ProjetPAGTest/M792/21092018/AnteriorStim/Post24h/post24h' num2str(c) '/'];
        load([Dir.path{a}{cc}([1:end-10,1]),'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        cc=cc+1;
    end
    a=a+1;
    cc=1;
    %Posterior    
    for c=1:4
        Dir.path{a}{cc}=['/media/DataMOBsRAIDN/ProjetPAGTest/M792/20092018/PosteriorStim/Post24h/post24h' num2str(c) '/'];
        load([Dir.path{a}{cc}([1:end-10,1]),'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        cc=cc+1;
    end
    
    
    %#####################################################################
    %#
    %#                            POST-48H
    %#
    %#####################################################################
    
elseif strcmp(experiment,'TestPost48h')
    
    % Mouse784
    a=a+1;
    cc=1;
    %Anterior
    for c=1:4
        Dir.path{a}{cc}=['/media/DataMOBsRAIDN/ProjetPAGTest/M784/22092018/AnteriorStim/Post48h/post48h' num2str(c) '/'];
        load([Dir.path{a}{cc}([1:end-10,1]),'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        cc=cc+1;
    end
    a=a+1;
    cc=1;
    %Posterior    
    for c=1:4
        Dir.path{a}{cc}=['/media/DataMOBsRAIDN/ProjetPAGTest/M784/21092018/PosteriorStim/Post48h/post48h' num2str(c) '/'];
        load([Dir.path{a}{cc}([1:end-10,1]),'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        cc=cc+1;
    end
    % Mouse789
    a=a+1;
    cc=1;
    %Anterior
    for c=1:4
        Dir.path{a}{cc}=['/media/DataMOBsRAIDN/ProjetPAGTest/M789/21092018/AnteriorStim/Post48h/post48h' num2str(c) '/'];
        load([Dir.path{a}{cc}([1:end-10,1]),'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        cc=cc+1;
    end
    %Posterior (NO 48h - mouse died before - may use 24h instead)   
%     a=a+1;
%     cc=1; 
%     for c=1:4
%         Dir.path{a}{cc}=['/media/DataMOBsRAIDN/ProjetPAGTest/M789/21092018/PosteriorStim/Post24h/post24h' num2str(c) '/'];
%         load([Dir.path{a}{cc}([1:end-10,1]),'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
%         cc=cc+1;
%     end
    
    % Mouse790
    a=a+1;
    cc=1;
    %Anterior
    for c=1:4
        Dir.path{a}{cc}=['/media/DataMOBsRAIDN/ProjetPAGTest/M790/21092018/PosteriorStim/Post48h/post48h' num2str(c) '/'];
        load([Dir.path{a}{cc}([1:end-10,1]),'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        cc=cc+1;
    end
    
    % Mouse791
    a=a+1;
    cc=1;
    %Anterior
    for c=1:4
        Dir.path{a}{cc}=['/media/DataMOBsRAIDN/ProjetPAGTest/M791/22092018/AnteriorStim/Post48h/post48h' num2str(c) '/'];
        load([Dir.path{a}{cc}([1:end-10,1]),'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        cc=cc+1;
    end
    
    % Mouse792
    a=a+1;
    cc=1;
    %Anterior
    for c=1:4
        Dir.path{a}{cc}=['/media/DataMOBsRAIDN/ProjetPAGTest/M792/22092018/AnteriorStim/Post48h/post48h' num2str(c) '/'];
        load([Dir.path{a}{cc}([1:end-10,1]),'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        cc=cc+1;
    end
    a=a+1;
    cc=1;
    %Posterior    
    for c=1:4
        Dir.path{a}{cc}=['/media/DataMOBsRAIDN/ProjetPAGTest/M792/21092018/PosteriorStim/Post48h/post48h' num2str(c) '/'];
        load([Dir.path{a}{cc}([1:end-10,1]),'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        cc=cc+1;
    end   
    
    
    
    %#####################################################################
    %#
    %#                      POOLED PRE-TESTS
    %#
    %#####################################################################
    
    
elseif strcmp(experiment,'TestPrePooled')

    % Mouse784
        a=a+1;
        %Anterior
        Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M784/20092018/AnteriorStim/Pretests/';
        load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

        a=a+1;
        %Posterior    
        Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M784/19092018/PosteriorStim/Pretests/';
        load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    
    % Mouse789
        a=a+1;
        %Anterior
        Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M789/19092018/AnteriorStim/Pretests/';
        load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

        a=a+1;
        %Posterior    
        Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M789/20092018/PosteriorStim/Pretests/';
        load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        
    % Mouse790
        a=a+1;
        %Posterior    
        Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M790/19092018/PosteriorStim/Pretests/';
        load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    
        
    % Mouse791
        a=a+1;
        %Anterior
        Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M791/20092018/AnteriorStim/Pretests/';
        load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    
        
    % Mouse792
        a=a+1;
        %Anterior
        Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M792/20092018/AnteriorStim/Pretests/';
        load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

        a=a+1;
        %Posterior    
        Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M792/19092018/PosteriorStim/Pretests/';
        load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        
        
        
    
    %#####################################################################
    %#
    %#                      POOLED POST-TESTS (IMMEDIATS)
    %#
    %#####################################################################
       
        
elseif strcmp(experiment,'TestImmediatPooled')
    % Mouse784
        a=a+1;
        %Anterior
        Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M784/20092018/AnteriorStim/PostTests/';
        load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

        a=a+1;
        %Posterior    
        Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M784/19092018/PosteriorStim/PostTests/';
        load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    
    % Mouse789
        a=a+1;
        %Anterior
        Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M789/19092018/AnteriorStim/PostTests/';
        load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

        a=a+1;
        %Posterior    
        Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M789/20092018/PosteriorStim/PostTests/';
        load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        
    % Mouse790
        a=a+1;
        %Posterior    
        Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M790/19092018/PosteriorStim/PostTests/';
        load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    
        
    % Mouse791
        a=a+1;
        %Anterior
        Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M791/20092018/AnteriorStim/PostTests/';
        load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    
        
    % Mouse792
        a=a+1;
        %Anterior
        Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M792/20092018/AnteriorStim/PostTests/';
        load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

        a=a+1;
        %Posterior    
        Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M792/19092018/PosteriorStim/PostTests/';
        load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;    

        
        
    
    %#####################################################################
    %#
    %#                      POOLED POST-SLEEP
    %#
    %#####################################################################
        
elseif strcmp(experiment,'TestPostPooled')
        
    % Mouse784
        a=a+1;
        %Anterior
        Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M784/20092018/AnteriorStim/PostSleep/';
        load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

        a=a+1;
        %Posterior    
        Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M784/19092018/PosteriorStim/PostSleep/';
        load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    
    % Mouse789
        a=a+1;
        %Anterior
        Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M789/19092018/AnteriorStim/PostSleep/';
        load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

        a=a+1;
        %Posterior    
        Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M789/20092018/PosteriorStim/PostSleep/';
        load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        
    % Mouse790
        a=a+1;
        %Posterior    
        Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M790/19092018/PosteriorStim/PostSleep/';
        load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    
        
    % Mouse791
        a=a+1;
        %Anterior
        Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M791/20092018/AnteriorStim/PostSleep/';
        load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    
        
    % Mouse792
        a=a+1;
        %Anterior
        Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M792/20092018/AnteriorStim/PostSleep/';
        load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

        a=a+1;
        %Posterior    
        Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M792/19092018/PosteriorStim/PostSleep/';
        load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        

        
    
    %#####################################################################
    %#
    %#                      POOLED POST-24H
    %#
    %#####################################################################
        
elseif strcmp(experiment,'TestPost24hPooled')
        
    % Mouse784
        a=a+1;
        %Anterior
        Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M784/21092018/AnteriorStim/Post24h/';
        load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

        a=a+1;
        %Posterior    
        Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M784/20092018/PosteriorStim/Post24h/';
        load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    
    % Mouse789
        a=a+1;
        %Anterior
        Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M789/20092018/AnteriorStim/Post24h/';
        load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

        a=a+1;
        %Posterior    
        Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M789/21092018/PosteriorStim/Post24h/';
        load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        
    % Mouse790
        a=a+1;
        %Posterior    
        Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M790/20092018/PosteriorStim/Post24h/';
        load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    
        
    % Mouse791
        a=a+1;
        %Anterior
        Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M791/21092018/AnteriorStim/Post24h/';
        load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    
        
    % Mouse792
        a=a+1;
        %Anterior
        Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M792/21092018/AnteriorStim/Post24h/';
        load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

        a=a+1;
        %Posterior    
        Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M792/20092018/PosteriorStim/Post24h/';
        load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
  
        
    
    %#####################################################################
    %#
    %#                      POOLED POST-48H
    %#
    %#####################################################################
        
        
elseif strcmp(experiment,'TestPost48hPooled')
        
    % Mouse784
        a=a+1;
        %Anterior
        Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M784/22092018/AnteriorStim/Post48h/';
        load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

        a=a+1;
        %Posterior    
        Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M784/21092018/PosteriorStim/Post48h/';
        load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    
    % Mouse789
        a=a+1;
        %Anterior
        Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M789/21092018/AnteriorStim/Post48h/';
        load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

        % Note: no Post48h for this mouse on the posterior electrode. Was
        % killed after other 48h test.
        % Use PostTest24h instead... 

        a=a+1;
        %Posterior    
        Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M789/21092018/PosteriorStim/Post24h/';
        load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;        
        
    % Mouse790
        a=a+1;
        %Posterior    
        Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M790/21092018/PosteriorStim/Post48h/';
        load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    
        
    % Mouse791
        a=a+1;
        %Anterior
        Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M791/22092018/AnteriorStim/Post48h/';
        load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    
        
    % Mouse792
        a=a+1;
        %Anterior
        Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M792/22092018/AnteriorStim/Post48h/';
        load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

        a=a+1;
        %Posterior    
        Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M792/21092018/PosteriorStim/Post48h/';
        load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
        
        
    
    %#####################################################################
    %#
    %#                      EXPERIMENT DAY
    %#
    %#####################################################################
        
        
elseif strcmp(experiment,'ExperimentDay')
        
    % Mouse784
        a=a+1;
        %Anterior
        Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M784/20092018/';

        a=a+1;
        %Posterior    
        Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M784/19092018/';
    
    % Mouse789
        a=a+1;
        %Anterior
        Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M789/19092018/';

        a=a+1;
        %Posterior    
        Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M789/20092018/';
        
    % Mouse790
        a=a+1;
        %Posterior    
        Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M790/19092018/';
    
        
    % Mouse791
        a=a+1;
        %Anterior
        Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M791/20092018/';
        
    % Mouse792
        a=a+1;
        %Anterior
        Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M792/20092018/';

        a=a+1;
        %Posterior    
        Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetPAGTest/M792/19092018/';
    
else
    error('Invalid name of experiment')
end



%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    

    %#####################################################################
    %#
    %#                      MICE NAMES
    %#
    %#####################################################################



%% Get mice names
for i=1:length(Dir.path)
    Dir.manipe{i}=experiment;
    
    % find mouse #    
    
    temp=strfind(Dir.path{i}{1},'PAGTest/M');
    if isempty(temp)
        mnum  = ['Mouse',Dir.path{i}{1}(strfind(Dir.path{i}{1},'PAGTest/'):strfind(Dir.path{i}{1},'PAGTest/')+11)];
    else
        mnum  = ['Mouse',Dir.path{i}{1}(temp+9:temp+11)];
    end
    
    Dir.name{i} = mnum;
    disp(Dir.name{i});
end

    %#####################################################################
    %#
    %#                      GROUPS
    %#
    %#####################################################################

for i=1:length(Dir.path)
    Dir.manipe{i}=experiment;
    if strcmp(Dir.manipe{i},'TestPre') || strcmp(Dir.manipe{i},'Cond') || strcmp(Dir.manipe{i},'TestPost') ... 
            || strcmp(Dir.manipe{i},'Hab') || strcmp(Dir.manipe{i},'TestPrePooled') || strcmp(Dir.manipe{i},'CondPooled')  ...
            || strcmp(Dir.manipe{i},'TestPostPooled') || strcmp(Dir.manipe{i},'ExperimentDay')
            
        for j=1:length(ContextB)
            Dir.group{1}{ContextB(j)} = 'ContextB';
        end
        for j=1:length(ContextC)
            Dir.group{1}{ContextC(j)} = 'ContextC';
        end
        
        for j=1:length(Anterior)
            Dir.group{2}{Anterior(j)} = 'Anterior';
        end
        for j=1:length(Posterior)
            Dir.group{2}{Posterior(j)} = 'Posterior';
        end
        
        for j=1:length(First)
            Dir.group{3}{First(j)} = 'First';
        end
        for j=1:length(Second)
            Dir.group{3}{Second(j)} = 'Second';
        end
    end
    
    if strcmp(Dir.manipe{i},'TestPost24h') || strcmp(Dir.manipe{i},'TestPost24hPooled')
        for j=1:length(ContextB24)
            Dir.group{1}{ContextB24(j)} = 'ContextB';
        end
        for j=1:length(ContextC24)
            Dir.group{1}{ContextC24(j)} = 'ContextC';
        end
        
        for j=1:length(Anterior24)
            Dir.group{2}{Anterior24(j)} = 'Anterior';
        end
        for j=1:length(Posterior24)
            Dir.group{2}{Posterior24(j)} = 'Posterior';
        end
        
        for j=1:length(First24)
            Dir.group{3}{First24(j)} = 'First';
        end
        for j=1:length(Second24)
            Dir.group{3}{Second24(j)} = 'Second';
        end
    end
    
    if strcmp(Dir.manipe{i},'TestPost48h') || strcmp(Dir.manipe{i},'TestPost48hPooled')
        for j=1:length(ContextB48)
            Dir.group{1}{ContextB48(j)} = 'ContextB';
        end
        for j=1:length(ContextC48)
            Dir.group{1}{ContextC48(j)} = 'ContextC';
        end
        
        for j=1:length(Anterior48)
            Dir.group{2}{Anterior48(j)} = 'Anterior';
        end
        for j=1:length(Posterior48)
            Dir.group{2}{Posterior48(j)} = 'Posterior';
        end
        
        for j=1:length(First48)
            Dir.group{3}{First48(j)} = 'First';
        end
        for j=1:length(Second48)
            Dir.group{3}{Second48(j)} = 'Second';
        end
    end
end


end



















































