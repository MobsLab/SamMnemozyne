function rip_checkdepth(Dir)
%%%% LinearizeTrack_SL

for isess = 1:length(sess)
    cd([pwd '/' sess{isess} '/']);
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
    f_linear(pwd,isubj)
    else
    disp('Linear config already done.');
    clear LinearDist;
    end
end

function f_align()
    load behavResources.mat
    [AlignedXtsd,AlignedYtsd,ZoneEpochAligned,XYOutput] = MorphMazeToSingleShape_SL(Xtsd,Ytsd,...
        Zone{1},ref,Ratio_IMAonREAL);

    save('behavResources.mat', 'AlignedXtsd', 'AlignedYtsd', 'ZoneEpochAligned', 'XYOutput',  '-append');
    clear
end

function f_linear(outPath,isubj)
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

        saveas(gcf,[outPath '/lineartraj.fig']);
        saveFigure(gcf,'lineartraj', outPath);
        close(gcf);

        LinearDist=tsd(Range(Xtsd),t);

        save('behavResources.mat', 'LinearDist','-append');
        clear
end