function DoMorphLinearization_SL_v2(sess)

Dir = pwd;

for isess = 1:length(sess)
    cd([pwd '/' sess{isess} '/']);
    FindBehav = dir(fullfile(pwd, '**', 'behavResources.*')); %find behavioral folder
    try
        cd(FindBehav.folder); %switch to behavioral folder
    catch
        cd(FindBehav(1).folder);
    end
    outPath = FindBehav.folder;
    disp(['Processing' sess{isess}]);
    % Morphing
    load('behavResources.mat','AlignedXtsd');
    if ~exist('AlignedXtsd','var')
        % Align
        load behavResources.mat  
        [AlignedXtsd,AlignedYtsd,ZoneEpochAligned,XYOutput] = MorphMazeToSingleShape_SL(Xtsd,Ytsd,...
            Zone{1},ref,Ratio_IMAonREAL);
        save('behavResources.mat', 'AlignedXtsd', 'AlignedYtsd', 'ZoneEpochAligned', 'XYOutput',  '-append');
        disp(['Morphing on ' sess{isess} ' done.']);
        close all
    else
        disp('Alignement already done.');
    end
    clear AlignedXtsd AlignedYtsd 'ZoneEpochAligned' 'XYOutput';

    % Linear
    load('behavResources.mat','LinearDist')
    if ~exist('LinearDist','var')
        load behavResources.mat
        figure('units', 'normalized', 'outerposition', [0.5 1 0.5 0.8]);
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

        saveas(gcf,[outPath '/lineartraj.fig']);
        saveFigure(gcf,'lineartraj', outPath);
        close(gcf);

        LinearDist=tsd(Range(Xtsd),t);

        save('behavResources.mat', 'LinearDist','-append');
        close all
    else
        disp('Linear config already done.');
    end
    clear LinearDist AlignedXtsd
    cd(Dir) 
end
end