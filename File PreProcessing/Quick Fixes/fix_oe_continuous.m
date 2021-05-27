% ONLY FOR Open Ephys files
% Quick fix when pre-processing has aborted and need to restart
% Rename continuous_original to continuous

FileList = dir(fullfile(cd, '**', 'continuous_original.dat'));
for i=1:length(FileList)
    movefile([FileList(i).folder '/continuous_original.dat'],[FileList(i).folder '/continuous.dat']);
end