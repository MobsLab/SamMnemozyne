

load('ExpeInfo.mat');

for i=1:length(ExpeInfo.PreProcessingInfo.FolderForConcatenation_Ephys)
    ExpeInfo.PreProcessingInfo.FolderForConcatenation_Ephys{1,i} = strrep(ExpeInfo.PreProcessingInfo.FolderForConcatenation_Ephys{1,i},'MOBS127','MOBS135');
    ExpeInfo.PreProcessingInfo.FolderForConcatenation_Behav{1,i} = strrep(ExpeInfo.PreProcessingInfo.FolderForConcatenation_Behav{1,i},'MOBS127','MOBS135');
end
