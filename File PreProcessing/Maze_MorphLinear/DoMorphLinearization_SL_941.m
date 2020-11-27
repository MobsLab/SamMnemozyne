%%%% LinearizeTrack_SL
clear all

%% Which data
% Mice_to_analyze = [797 798 828 861 882 905 906 911 912];
Mice_to_analyze = 941;

%Folders/Sessions


sess = {'1-Explo','3-Hab',...
        '4-Pre/pre1','4-Pre/pre2','4-Pre/pre3','4-Pre/pre4',...
        '5-Cond/cond1','5-Cond/cond2','5-Cond/cond3','5-Cond/cond4'};%,...
%         '7-Post/post1','7-Post/post2','7-Post/post3','7-Post/post4',...
%         '8-Extinct'};

Dir = PathForExperimentsERC_SL('FirstExploNew');
Dir = RestrictPathForExperiment(Dir, 'nMice', Mice_to_analyze);



% DirHab = PathForExperimentsERC_SL('Hab');
% DirHab = RestrictPathForExperiment(DirHab, 'nMice', Mice_to_analyze);
% 
% DirPre = PathForExperimentsERC_SL('TestPre');
% DirPre = RestrictPathForExperiment(DirPre, 'nMice', Mice_to_analyze);
% 
% DirCond = PathForExperimentsERC_SL('Cond');
% DirCond = RestrictPathForExperiment(DirCond, 'nMice', Mice_to_analyze );
% 
% DirPost = PathForExperimentsERC_SL('TestPost');
% DirPost = RestrictPathForExperiment(DirPost, 'nMice', Mice_to_analyze );

% Morph
for i = 1:length(Dir.path)
    for isess = 1:length(sess)
        cd([Dir.path{i}{1} sess{isess} '/']);
        FindBehav = dir(fullfile(pwd, '**', 'behavResources.*')); %find behavioral folder
        cd(FindBehav.folder); %switch to behavioral folder
        
        % Morphing
        try load(behavResources.mat,'AlignedXtsd')
            disp('Alignement already done.');
            clear AlignXtsd;
        catch
            f_align
        end
        disp(['Morphing on ' sess{isess} ' done.']);
        close all
        
        % Linear
        try load(BehavResources.mat,'LinearDist')
            disp('Linear config already done.');
            clear LinearDist;
        catch
            f_linear
        end
        
        
    end
end


function f_align()
    load behavResources.mat
    [AlignedXtsd,AlignedYtsd,ZoneEpochAligned,XYOutput] = MorphMazeToSingleShape_SL(Xtsd,Ytsd,...
        Zone{1},ref,Ratio_IMAonREAL);

    save('behavResources.mat', 'AlignedXtsd', 'AlignedYtsd', 'ZoneEpochAligned', 'XYOutput',  '-append');
    clear
end

function f_linear()
    figure('units', 'normalized', 'outerposition', [0 1 0.5 0.8]);
        imagesc(mask+Zone{1})
        curvexy=ginput(4);
        clf

        mapxy=[Data(Ytsd)';Data(Xtsd)']';
        [xy,distance,t] = distance2curve(curvexy,mapxy*Ratio_IMAonREAL,'linear');

        subplot(211)
        imagesc(mask+Zone{1})
        hold on
        plot(Data(Ytsd)'*Ratio_IMAonREAL,Data(Xtsd)'*Ratio_IMAonREAL)
        subplot(212)
        plot(t), ylim([0 1])

        saveas(gcf,[DirHab.path{i}{1} 'lineartraj.fig']);
        saveFigure(gcf,'lineartraj', DirHab.path{i}{1});
        close(gcf);

        LinearDist=tsd(Range(Xtsd),t);

        save('behavResources.mat', 'LinearDist','-append');
end