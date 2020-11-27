function [Oc,OcS,OcR,OcRS]=OccupancyMapSL(X,Y,varargin)
%OccupancyMapDB Calculate and plot occupancy map. Modified by Dima in March 2018 from OccupancyMapKB
%   Inputs:
%
%   X - X-coordinates in tsd format;
%   Y - Y-coordinates in tsd format;
%   
%   Varargin inputs:
% 
%   smoothing (scalar) - smoothing factor for the map (default = 2);
%   scale (0 or 1) - log-transformation of the maps (default = 0);
%   epoch (ts-object) - epoch(s) to calculate (default - all recording);
%   list (vector) - indices of epoch in epoch ts-object if there are many (default - all);
%   size (scalar) - size of spatial bin for the map (default = 50);
%   axis (vector) - color axis for imagesc figure;
%   video (scalar) - frame rate (default = 15);
%   largematrix (0 or 1) - create edges in the map (defualt = 1);
%   plotfig (0 or 1) - plot figures (default = 1);
%   histlimits (vector) - limits of the histogram you want to get (default = []) EXAMPLE = [10 50 10 60] 
% 
% 
%   Outputs:
% 
%   Oc - occupancy map;
%   OcS - occupancy map smoothed;
%   OcR - occupancy map normalized for the averaged occupancy across whole environment;
%   OcRS -occupancy map smoothed normalized for the averaged occupancy across whole environment;
% 
%   EXAMPLE: [Oc,OcS,OcR,OcRS]=OccupancyMapDB(Xtsd,Ytsd,'smoothing', 1.5, 'size', 50, 'video', 15, 'plotfig', 0);

%% Parse inputs
for i = 1:2:length(varargin),

              switch(lower(varargin{i})),
                
                  % Smoothing parameter (default = 2);
                case 'smoothing',
                  smo = varargin{i+1};
                  if ~isa(smo,'numeric'),
                    error('Incorrect value for property ''smoothing'' (type ''help ICSSexplo'' for details).');
                  end
                  
                  % Log-transformation(0/1) (default = 0)
                case 'scale',
                  logg = varargin{i+1};
                  if ~isa(logg,'numeric'),
                    error('Incorrect value for property ''figure'' (type ''help ICSSexplo'' for details).');
                  end
                  % epoch ((default - all recording)
                case 'epoch',
                  GoodEpoch = varargin{i+1};
                 
                  % List of epochs (default - all)
               case 'list',
                  list = varargin{i+1};
               
                  % size of spatial bin (default = 50)
                 case 'size',
                  sizeMap = varargin{i+1};
                  if ~isa(sizeMap,'numeric'),
                    error('Incorrect value for property ''figure'' (type ''help ICSSexplo'' for details).');
                  end 
                  
                  % Axis in color
                  case 'axis',
                  ca = varargin{i+1};
                  
                  % Video frame rate (default = 15);
                  case 'video',
                  freqVideo = varargin{i+1};
                  if ~isa(freqVideo,'numeric'),
                    error('Incorrect value for property ''figure'' (type ''help PlaceField'' for details).');
                  end
                  
                  % Create edges in the map(0/1) (default = 1)
                  case 'largematrix',
                  LMatrix = varargin{i+1};  
                  
                  % Do you want to plot a figure(0/1) (default = 1)
                  case 'plotfig',
                  plotfig = varargin{i+1};  
                  
                  % Limits for hist2d (see )
                  case 'histlimits',
                  histlimits = varargin{i+1};  
                  
              end
end


%% Default values
try
    sizeMap;
    if size(sizeMap,1)==2
    sizeMap1=sizeMap(1);
    sizeMap2=sizeMap(2);
    else
    sizeMap1=sizeMap;
    sizeMap2=sizeMap;
        
    end
    
catch
    sizeMap1=50;
    sizeMap2=50;
    sizeMap=[sizeMap1,sizeMap2];
end
try
    smo;
catch
    smo=2;
end

try
    logg;
catch
    logg=0;
end

try
    GoodEpoch;
catch
    rg=Range(X);
    GoodEpoch=intervalSet(rg(1),rg(end));
end

try
    list;
catch
    list=[1:length(Start(GoodEpoch))];
end

try
    LMatrix;
catch
    LMatrix=1;
end

try
    
freqVideo;
catch
    freqVideo=15;
end

try
    
plotfig;
catch
    plotfig=1;
end

try
    
histlimits;
catch
    histlimits=[];
end

%% Calculate occupancy
if isempty(histlimits)
    [occH, x1, x2] = hist2d(Data(X), Data(Y), sizeMap, sizeMap);
else
    [occH, x1, x2] = hist2dDB(Data(X), Data(Y), sizeMap, sizeMap, 'histlimits', histlimits);
end
    
if LMatrix
        largerMatrix = zeros(sizeMap+floor(sizeMap/4),sizeMap+floor(sizeMap/4));
        largerMatrix(1+floor(sizeMap/8):sizeMap+floor(sizeMap/8),1+floor(sizeMap/8):sizeMap+floor(sizeMap/8)) = occH';
        occH=largerMatrix;
        occHS=SmoothDec(largerMatrix/freqVideo, [smo,smo]);
else
    occH=occH';
    occHS=SmoothDec(occH/freqVideo,[smo,smo]);   
end

%% testing - SL: rotating map
occHS = rot90(occHS);
x1_temp = x1;
x1 = x2;
x2 = x1_temp;

%% Plot figures    
if plotfig
    
    % Trajectory figure
    figure('Color',[1 1 1]), 
    subplot(2,1,1), hold on
    
    if length(list)>1
        for i=list(i)
            subepoch=subset(GoodEpoch,i);
            plot(Data(Restrict(X,subepoch)),Data(Restrict(Y,subepoch)),'b')  
            Xsub=Data(Restrict(X,subepoch));
            Ysub=Data(Restrict(Y,subepoch));    
            plot(Xsub(1),Ysub(1),'bo','markerfacecolor','b','linewidth',5)
        end
    else
        plot(Data(Restrict(X,GoodEpoch)),Data(Restrict(Y,GoodEpoch)),'b')  
        Xsub=Data(Restrict(X,GoodEpoch));
        Ysub=Data(Restrict(Y,GoodEpoch));    
        plot(Xsub(1),Ysub(1),'bo','markerfacecolor','b','linewidth',5)
    end
    
    subplot(2,1,2), imagesc(x1,x2,occHS), axis xy
    caxis([.02 2]);
end

%% Outputs
if logg==1
OcS=log(occHS);
else
OcS=occHS;
end

Oc=occH;
OcS=occHS;
OcR=Oc/sum(sum(Oc))*100;
OcRS=OcS/sum(sum(OcS))*100;
