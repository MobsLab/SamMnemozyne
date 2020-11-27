function FiguresPlaceCellMap_singleSession

%==========================================================================
% Details: Output firing location in space
%
% INPUTS:
%       - session: session name to be mapped (string in cell: {'Hab1','Hab2'})
%
% OUTPUT:
%       - figures including:
%           - Trajectories with firing locations
%           - Firing maps (real and poisson dist)
%
% NOTES:
%
%   Written by Samuel Laventure - 18-04-2019
%      
%==========================================================================

%INIT VAR


%% MAIN SCRIPT
load('behavResources.mat');
SetCurrentSession('same');
MakeData_Spikes('mua',1,'recompute',1);
load('SpikeData.mat');

LocomotionEpoch = thresholdIntervals(CleanVtsd,.2,'Direction', 'Above');
hist(Data(Vtsd), 100)

if ~exist([pwd '/PlaceCells/'],'dir')
    mkdir([pwd '/PlaceCells/']);
end

for i=1:length(S) 
    map{i}=PlaceField_DB_tmp(Restrict(S{i},Range(Vtsd)), ...
        Restrict(CleanXtsd,Range(Vtsd)), ... 
        Restrict(CleanYtsd,Range(Vtsd)), ...
        'epoch',LocomotionEpoch, ... 
        'smoothing',2, 'SizeMap', 50,'plotresults',1);

    hold on
    mtit(cellnames{i}, 'fontsize',14, 'xoff', -.6, 'yoff', 0) %set global title for each figure (tetrode and cluster #)
    print([pwd '/PlaceCells/' cellnames{i}], '-dpng', '-r300'); %'-SI-' num2str(stats{i}.spatialInfo)
end