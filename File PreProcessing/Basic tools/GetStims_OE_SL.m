% Copy pasta from GetStims_DB
% modified for Open Ephys files : 17/06/2020
% by Samuel laventure
% Description: Get All the ttls (UMaze Experiment)
%           Out all the digital inputs in the same format


%% Set data path
fileSignal = 'Rhythm_FPGA-100.0_TTL_1.mat';
SignalPath = dir(fullfile(pwd, '**', fileSignal));

fileDetect = 'Spk_Srt_+_Stim-106.0_TTL_1.mat';
DetectPath = dir(fullfile(pwd, '**', fileDetect));
clear timestamps
   
% load detection
load([SignalPath.folder '/' fileSignal],'timestamps'); %detection file    
RecStart = double(timestamps(1))/2; % Openephys sampling rate 20KHz

load([DetectPath.folder '/' fileDetect]); %detection file    
tstamps = (double(timestamps)/2)-RecStart; % Openephys sampling rate 20KHz

StartSession=tstamps(1:2:end);
StopSession=tstamps(2:2:end);

load('ExpeInfo.mat')

%Stim
StimEpoch = intervalSet(tstamps(1:2:end),tstamps(2:2:end)); 

TTLInfo.StartSession=StartSession;
TTLInfo.StopSession=StopSession;
TTLInfo.StimEpoch=StimEpoch;

save('behavResources.mat', 'TTLInfo', '-append');
