
load('ExpeInfo.mat');
for i=1:length(ExpeInfo.PreProcessingInfo.FolderForConcatenation_Ephys)
    ExpeInfo.PreProcessingInfo.FolderForConcatenation_Ephys{1,i}= ...
        strrep(ExpeInfo.PreProcessingInfo.FolderForConcatenation_Ephys{1,i},'-New','-Known')
end

for i=1:length(ExpeInfo.PreProcessingInfo.FolderForConcatenation_Ephys)
    ExpeInfo.PreProcessingInfo.FolderForConcatenation_Behav{1,i}= ...
        strrep(ExpeInfo.PreProcessingInfo.FolderForConcatenation_Behav{1,i},'-New','-Known')
end

save('ExpeInfo.mat','ExpeInfo');