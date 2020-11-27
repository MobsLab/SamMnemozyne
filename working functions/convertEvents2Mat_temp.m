function convertEvents2Mat(eventPath,recPath)
%==========================================================================
% Details: execute python script converting all open ephys events files
% into .mat
%
% INPUTS: 
%         - evenPath: full directory to the event folder 
%           (ex: '/media/mobs/DataMOBS127/NREMstim_sham/recording2/events')  
%         - recPath: full directory to the event folder 
%           (ex: '/media/mobs/DataMOBS127/NREMstim_sham/recording2/events')  
%
%
%   Written by Samuel Laventure - 29-06-2020
%      
%==========================================================================

sourcePath = pwd;
% 
% % Get path to files
% % 1-Event path
% FileList = dir(fullfile(cd, '**', 'metadata.npy'));
% cd(FileList.folder);
% cd ..
% cd .. % get to the event folder 
% eventPath = pwd;
% 
% %2-Recording path
% cd ..
% FileList = dir(fullfile(cd, '**', 'continuous.dat'));
% recPath = pwd;


commandStr = ...
    ['python ' dropbox '/Kteam/PrgMatlab/OnlinePlaceDecoding/matlab/convertEvents2Mat.py -p ' eventPath];
 [status, commandOut] = system(commandStr); 
if status==0
 fprintf('Event files successfully created \n');
else
 fprintf('Path to event files incorrect \n');
end
 
commandStr = ...
    ['python ' dropbox '/Kteam/PrgMatlab/OnlinePlaceDecoding/matlab/convertEvents2Mat.py -p ' recPath];
[status, commandOut] = system(commandStr);
[parentdir,~,~]=fileparts(pwd);
copyfile([pwd '/continuous_Rhythm_FPGA-100.0.mat'],parentdir);
    
cd(parentdir);
[parentdir,~,~]=fileparts(pwd);
movefile([pwd '/continuous_Rhythm_FPGA-100.0.mat'],parentdir);

if status==0
 fprintf('Recording file successfully created \n');
else
 fprintf('Path to recording files incorrect \n');
end

cd(sourcePath)


