if ~exist('Mice_to_analyze','var')
    Mice_to_analyze = [936];
end

% Folders/Sessions
sess = {'1-Explo','3-Hab',...
        '4-Pre/pre1','4-Pre/pre2','4-Pre/pre3','4-Pre/pre4',...
        '5-Cond/cond1','5-Cond/cond2','5-Cond/cond3','5-Cond/cond4',...
        '7-Post/post1','7-Post/post2','7-Post/post3','7-Post/post4',...
        '8-Extinct'};
    
Zlabels = {'Shock','NoShock','Centre','CentreShock','CentreNoShock',...
                'Inside','Outside','FarShock','FarNoShock'};

Dir = PathForExperimentsERC_SL('StimMFBWake');
Dir = RestrictPathForExperiment(Dir, 'nMice', Mice_to_analyze);

% Morph
for i = 1:length(Dir.path)
    for isess = 1:length(sess)
        cd([Dir.path{i}{1} sess{isess} '/']);
        FindBehav = dir(fullfile(pwd, '**', 'behavResources.*')); %find behavioral folder
        cd(FindBehav.folder); %switch to behavioral folder
        
        load('behavResources.mat');
        if ~(length(ZoneLabels)==9)
            ZoneLabels = Zlabels;
            save('behavResources');
        end
    end
end

        