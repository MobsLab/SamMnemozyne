function fix_CollectBehavResources
% copy behavResources already pre-processed back into new folders.
% This is usefull when mistakes force you to reprocess. You won't have to
% redo the morph and linearalize maze.

Dir = pwd;
FindBehav = dir(fullfile(pwd, '**', 'behavResources.*')); %find behavioral folder

for isess = 1:length(FindBehav)
    outPath = FindBehav(isess).folder;
    disp(['Saving' outPath]);
    if isess < 10
        copyfile([Dir '/behavResources-0' num2str(isess) '.mat'],[outPath '/behavResources.mat']);
    else
        copyfile([Dir '/behavResources-' num2str(isess) '.mat'],[outPath '/behavResources.mat']);
    end
end
disp('ALL DONE')