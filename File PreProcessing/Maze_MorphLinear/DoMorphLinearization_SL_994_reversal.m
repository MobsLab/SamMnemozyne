%%%% LinearizeTrack_SL
clear all

%% Which data
Mice_to_analyze = 994;

%Folders/Sessions
sess = {'1-Explo','3-Hab',...
        '4-Pre/pre1','4-Pre/pre2','4-Pre/pre3','4-Pre/pre4',...
        '5-Cond/cond1','5-Cond/cond2','5-Cond/cond3','5-Cond/cond4',...
        '7-Post/post1','7-Post/post2','7-Post/post3','7-Post/post4',...
        '8-Extinct'};

global Dir; Dir = PathForExperimentsERC_SL('Reversal');
Dir = RestrictPathForExperiment(Dir, 'nMice', Mice_to_analyze);

% Morph
for isubj = 1:length(Dir.path)
    for isess = 1:length(sess)
        cd([Dir.path{isubj}{1} sess{isess} '/']);
        FindBehav = dir(fullfile(pwd, '**', 'behavResources.*')); %find behavioral folder
        cd(FindBehav.folder); %switch to behavioral folder
        
        % Morphing
        load('behavResources.mat','AlignedXtsd');
        if ~exist('AlignedXtsd','var')
            f_align()
            disp(['Morphing on ' sess{isess} ' done.']);
            close all
        else
            disp('Alignement already done.');
            clear AlignedXtsd;
        end
        
        % Linear
        load('behavResources.mat','LinearDist')
        if ~exist('LinearDist','var')
            f_linear(Dir,isubj)
        else
            disp('Linear config already done.');
            clear LinearDist;
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

function f_linear(Dir,isubj)
    load behavResources.mat
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

        saveas(gcf,[Dir.path{isubj}{1} 'lineartraj.fig']);
        saveFigure(gcf,'lineartraj', Dir.path{isubj}{1});
        close(gcf);

        LinearDist=tsd(Range(Xtsd),t);

        save('behavResources.mat', 'LinearDist','-append');
        clear
end