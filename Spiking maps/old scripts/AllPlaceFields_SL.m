%% Parameters
dir_out = [dropbox '\DataSL\StimMFBwake\Place Cells\'];
%set folders
if ~exist(dir_out,'dir')
    mkdir(dir_out);
end

%% Mice
Dir = PathForExperimentsERC_SL_home('StimMFBWake');
Mice_to_analyze = [882];
Dir = RestrictPathForExperiment(Dir,'nMice', Mice_to_analyze);


%% Load Data
for i=1:length(Dir.path)
    Spikes{i} = load([Dir.path{i}{1} '/SpikeData.mat']);
    beh{i} = load([Dir.path{i}{1} '/behavResources.mat'], 'SessionEpoch','AlignedXtsd','AlignedYtsd','CleanVtsd');    
end

%% Calculate number of cells
totalCells = 0;
for i=1:length(Dir.path)
    totalCells = totalCells + length(Spikes{i}.S);
end

%% Calculate rate maps
a = 0;
b=0;
for i=1:length(Dir.path)
    c=0;
    LocomotionEpoch = thresholdIntervals(tsd(Range(beh{i}.CleanVtsd),movmedian(Data(beh{i}.CleanVtsd),5)),...
        2,'Direction','Above');
    for j=1:length(Spikes{i}.S)
        b=b+1;
        try
            [map{b},mapS,stat{b},px,py,FR{b}]=PlaceField_DB(Restrict(Spikes{i}.S{j},and(beh{i}.SessionEpoch.Hab2,LocomotionEpoch)),...
                Restrict(beh{i}.AlignedXtsd,and(beh{i}.SessionEpoch.Hab2,LocomotionEpoch)),...
                Restrict(beh{i}.AlignedYtsd,and(beh{i}.SessionEpoch.Hab2,LocomotionEpoch)),'threshold',0.5);close;
        catch
            stat{b}=[];
        end
        if ~isempty(stat{b})
            if stat{b}.spatialInfo > 0.8 && FR{b} > 0.25
                a = a+1;
                c=c+1;
                stats{a} = stat{b};
                mapout{a} = map{b};
                idx{a}=[i j];
                PlaceCell{i}.idx(c) = j;
            end
        end
    end
end


perc_PC = length(idx)/totalCells*100;
mazeMap = [7 8; 7 58; 58 58; 58 8; 40 8; 40 43; 25 43; 25 8; 7 8];
ShockZoneMap = [7 8; 7 30; 25 30; 25 8; 7 8];

mazeMap2 = [24 15; 24 77; 85 77; 85 15; 63 15;  63 58; 46 58; 46 15; 24 15];
ShockZoneMap2 = [24 15; 24 48; 46 48; 46 15; 24 15];

%% Find SZ-overlapping spikes
FakeSZ = zeros (62,62);
FakeSZ (7:25,8:30) = 1;

d=0;
for i=1:length(stats)
    if iscell(stats{i}.field)
        for k=1:2
%             OverlappedFields = FakeSZ & stats{i}.field{k};
            OverlappedFields = stats{i}.field{k};
            numOverlap(i,j) = nnz(OverlappedFields);
            if numOverlap(i,j) > 0
                d=d+1;
                overlapCells(d) = i;
            end
        end
    else
%         OverlappedFields = FakeSZ & stats{i}.field;
        OverlappedFields = stats{i}.field;
        numOverlap(i,j) = nnz(OverlappedFields);
        if numOverlap(i,j) > 0
            d=d+1;
            overlapCells(d) = i;
        end
    end
end

for i=1:length(Dir.path)
    PlaceCell{i}.SZ= 0;
end

for i=1:length(overlapCells)
    PlaceCell{idx{overlapCells(i)}(1)}.SZ(end+1)= idx{overlapCells(i)}(2);
end
for i=1:length(Dir.path)
    PlaceCell{i}.SZ= nonzeros(PlaceCell{i}.SZ);
end

%% Save the place cell information in the apppropriate folders
for i=1:length(Dir.path)
    PlaceCells = PlaceCell{i};
    save([Dir.path{i}{1} 'SpikeData.mat'],'PlaceCells','-append');
end

%% Figure


%Prepare an array
result=zeros(62,62);
for i=1:length(stats)
    if iscell(stats{i}.field)
        for k=1:2
            result = result+stats{i}.field{k};
        end
    else
        result = result+stats{i}.field;
    end
end

fh = figure('Color',[1 1 1], 'rend','painters','pos',[10 10 800 500])

    imagesc(result);
    axis xy
    % caxis([0 2])
    hold on
    plot(mazeMap(:,1),mazeMap(:,2),'w','LineWidth',3)
    plot(ShockZoneMap(:,1),ShockZoneMap(:,2),'r','LineWidth',3)
    set(gca,'XTickLabel',{},'YTickLabel',{});

    title([num2str(length(Dir.path)) ' mice, ' num2str(length(stats)) ' PCs, ', num2str(perc_PC) '% of all units found, ' ...
        num2str(length(overlapCells)) ' PCs overlapping with SZ'], 'FontWeight','bold','FontSize',18);

    print([dir_out 'allPF_' num2str(Mice_to_analyze)], '-dpng', '-r300');

% Fields separately
fi = figure('Color',[1 1 1], 'rend','painters','pos',[10 10 800 500])

    for i=1:length(idx)
        subplot(6,5,i)
        if iscell(stats{i}.field)
            imagesc(stats{i}.field{1}+stats{i}.field{2})
            axis xy
            hold on
            plot(mazeMap(:,1),mazeMap(:,2),'w','LineWidth',3)
            plot(ShockZoneMap(:,1),ShockZoneMap(:,2),'r','LineWidth',3)
            title([Dir.name{idx{i}(1)} ' Cl' num2str(idx{i}(2))])
        else
            imagesc(stats{i}.field)
            axis xy
            hold on
            plot(mazeMap(:,1),mazeMap(:,2),'w','LineWidth',3)
            plot(ShockZoneMap(:,1),ShockZoneMap(:,2),'r','LineWidth',3)
            title([Dir.name{idx{i}(1)} ' Cl' num2str(idx{i}(2))])
        end
        hold off
    end
    print([dir_out 'SeperatedPF' num2str(Mice_to_analyze)], '-dpng', '-r300');

%% Plot all the place cells
fa = figure('Color',[1 1 1], 'rend','painters','pos',[10 10 800 500])
    for i=1:length(stats)
        subplot(6,5,i)
        imagesc(mapout{i}.rate)
        axis xy
        hold on
        plot(mazeMap(:,1),mazeMap(:,2),'w','LineWidth',3)
        plot(ShockZoneMap(:,1),ShockZoneMap(:,2),'r','LineWidth',3)
        hold off
    end
    print([dir_out 'SeperatedPC' num2str(Mice_to_analyze)], '-dpng', '-r300');


