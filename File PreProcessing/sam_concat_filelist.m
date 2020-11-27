

for i=1:27
    newStr = strrep(ExpeInfo.PreProcessingInfo.FolderForConcatenation_Ephys{i},'MFBCondWake','StimWakeMFB');
    ExpeInfo.PreProcessingInfo.FolderForConcatenation_Ephys{i} = newStr;
    newStr = strrep(ExpeInfo.PreProcessingInfo.FolderForConcatenation_Behav{i},'MFBCondWake','StimWakeMFB');
    ExpeInfo.PreProcessingInfo.FolderForConcatenation_Behav{i} = newStr;
end
save('ExpeInfo.mat','ExpeInfo')