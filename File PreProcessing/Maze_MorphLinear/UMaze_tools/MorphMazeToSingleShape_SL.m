

function [AlignedXtsd,AlignedYtsd,ZoneEpochAligned,XYOutput] = MorphMazeToSingleShape_SL(Xtsd,Ytsd,ShockZone,Ref,Ratio_IMAonREAL,XYInput,ZoneDef)


%% Function that morphs UMaze coordinates into system with 0,0 as the bottom corner of shock zone and rest of maze going from 0 to 1
%% Input
% Xtsd,Ytsd : tsd of positions
% ShockZone : for user input, the mask of the shock znoe
% Ref : for user input, the reference image of the maze
% ZoneDef : optionaml , defines the shock, safe, centre, shockcentre and
% safecentre regions in the new coordinate system
% XYInput : optional, if the same reference image is used multiple times,
% the user can avoid clicking repeatedly by spplying the coordinates
%% Output


%% Initiation
colors = {'r','b','k','m','c','y','g'};

% Default definition of zones
if ~exist('ZoneDef')

% Small Zone
    ZoneDef{1} = [0 0.35;0 0.4]; % shock
    ZoneDef{2} = [0.65 1;0 0.4]; % safe
    ZoneDef{3} = [0.35 0.65; 0.7 1]; % centre
    ZoneDef{4} = [0 0.35;0.4 0.8]; % shock centre
    ZoneDef{5} = [0.65 1;0.4 0.8]; % safe centre
    ZoneDef{6} = [0 0.35;0.8 1]; % shock far
    ZoneDef{7} = [0.65 1;0.8 1]; % safe far
    
%     
%     % Small Zone
%     ZoneDef{1} = [0 0.35;0 0.4]; % shock
%     ZoneDef{2} = [0.65 1;0 0.4]; % safe
%     ZoneDef{3} = [0.35 0.65; 0.7 1]; % centre
%     ZoneDef{4} = [0 0.35;0.4 1]; % shock centre
%     ZoneDef{5} = [0.65 1;0.4 1]; % safe centre

    % Large zone
%     ZoneDef{1} = [0 0.35;0 0.6]; % shock
%     ZoneDef{2} = [0.65 1;0 0.6]; % safe
%     ZoneDef{3} = [0.35 0.65; 0.6 1]; % centre
%     ZoneDef{4} = [0 0.35;0.6 1]; % shock centre
%     ZoneDef{5} = [0.65 1;0.6 1]; % safe centre
end

% get user input
if exist('XYInput')
    x = XYInput(1,:);
    y = XYInput(2,:);
else
    figure
    imagesc(double(Ref)), colormap jet, hold on
    plot(Data(Ytsd)*Ratio_IMAonREAL,Data(Xtsd)*Ratio_IMAonREAL,'color',[0.8 0.8 0.8])
    A = regionprops(ShockZone,'Centroid');
    clim
    plot(A.Centroid(1),A.Centroid(2),'r.','MarkerSize',50)
    plot(A.Centroid(1),A.Centroid(2),'w*','MarkerSize',10)
    title('Shock ext. corner - Safe ext. corner - Shock side far wall')
    [x,y]  = ginput(3);
end
XYOutput(1,:) = y;
XYOutput(2,:) = x;
close all

% Transformation of coordinates
Coord1 = [x(2)-x(1),y(2)-y(1)];
Coord2 = [x(3)-x(1),y(3)-y(1)];
TranssMat = [Coord1',Coord2'];
XInit = Data(Ytsd).*Ratio_IMAonREAL-x(1);
YInit = Data(Xtsd).*Ratio_IMAonREAL-y(1);

% The Xtsd and Ytsd in new coordinates
A = ((pinv(TranssMat)*[XInit,YInit]')');
AlignedXtsd = tsd(Range(Xtsd),A(:,1));
AlignedYtsd = tsd(Range(Ytsd),A(:,2));

% give us a look at the result
figure
hold on
for z = 1:7
    ZoneEpochAligned_X1 = thresholdIntervals(AlignedXtsd,ZoneDef{z}(1,1),'Direction','Above');
    ZoneEpochAligned_X2 = thresholdIntervals(AlignedXtsd,ZoneDef{z}(1,2),'Direction','Below');
    ZoneEpochAligned_Y1 = thresholdIntervals(AlignedYtsd,ZoneDef{z}(2,1),'Direction','Above');
    ZoneEpochAligned_Y2 = thresholdIntervals(AlignedYtsd,ZoneDef{z}(2,2),'Direction','Below');
    ZoneEpochAligned{z} = and(and(and(ZoneEpochAligned_X1,ZoneEpochAligned_X2),ZoneEpochAligned_Y1),ZoneEpochAligned_Y2);
    plot(Data(Restrict(AlignedXtsd,ZoneEpochAligned{z})),Data(Restrict(AlignedYtsd,ZoneEpochAligned{z})),'color',colors{z})
end
line([0 0],[0 1])
line([1 1],[0 1])
line([0 1],[0 0])
line([0 1],[1 1])
xlim([-0.2 1.2])
ylim([-0.2 1.2])
legend({'SHK','SF','CNT','SHKCNT','SFCNT','SHKFAR','SFFAR'})

end
