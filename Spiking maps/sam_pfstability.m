MakeData_Spikes('mua',1,'recompute',1);
try 
    load('behavResources.mat');
catch
    [parentdir,~,~]=fileparts(pwd);
    load(fullfile(parentdir,'behavResources.mat'));
end
load('SpikeData.mat');

LocomotionEpoch = thresholdIntervals(Vtsd,5,'Direction', 'Above');
hist(Data(Vtsd), 100)

for i=1:length(S) 
 
[map,mapS,stats ]= ...
        PlaceField_DB(Restrict(Restrict(S{i},LocomotionEpoch),SessionEpoch.Explo2), ...
                Restrict(Restrict(Xtsd,LocomotionEpoch),SessionEpoch.Explo2), ... 
                Restrict(Restrict(Ytsd,LocomotionEpoch),SessionEpoch.Explo2), ... 
                'smoothing',1.5, 'size', 50,'plotresults',0);
 map1(i) = map;
 stat1(i) = stats;
 mtit(['PRE - ' cellnames{i}], 'fontsize',14, 'xoff', -.6, 'yoff', 0) %set global title for each figure (tetrode and cluster #)
 print([pwd '/PlaceCells/PRE-' cellnames{i}], '-dpng', '-r300'); %'-SI-' num2str(stats{i}.spatialInfo)
 
 map=[];
 stats=[];
 
 [map, mapS, stats]= ...
        PlaceField_DB(Restrict(Restrict(S{i},LocomotionEpoch),SessionEpoch.Explo4), ...
                Restrict(Restrict(Xtsd,LocomotionEpoch),SessionEpoch.Explo4), ... 
                Restrict(Restrict(Ytsd,LocomotionEpoch),SessionEpoch.Explo4), ... 
                'smoothing',1.5, 'size', 50,'plotresults',0);  
 map3(i) = map;
 stat3(i) = stats;
 mtit(['POST - ' cellnames{i}], 'fontsize',14, 'xoff', -.6, 'yoff', 0) %set global title for each figure (tetrode and cluster #)
 print([pwd '/PlaceCells/POST-' cellnames{i}], '-dpng', '-r300'); %'-SI-' num2str(stats{i}.spatialInfo)
end

figure('Color',[1 1 1], 'render','painters','position',[10 10 1600 600])

    subplot(1,2,1)
    imagesc(map1(2).rate)
    title('Pre')

    subplot(1,2,2)
    imagesc(map3(2).rate)
    title('Post')


     

