%ER2_OccupancyMapsExamples - Plot basic behavior comparisons of ERC experiment avergaed across mice.
%
% Plot occupance in the shock zone in the PreTests vs PostTests
% Plot number of entries in the shock zone in the PreTests vs PostTests
% Plot time to enter in the shock zone in the PreTests vs PostTests
% Plot average speed in the shock zone in the PreTests vs PostTests
% 
% 
%  OUTPUT
%
%    Figure
%
%       See
%   
%       QuickCheckBehaviorERC, PathForExperimentERC_Dima, BehaviorERC
% 
%       2018 by Dmitri Bryzgalov

%% Parameters
% Directory to save and name of the figure to save
dir_out = '/home/mobsrick/Dropbox/MOBS_workingON/Sam/StimMFBWake/SFN2019/';
fig_out1 = 'MeanOccupancyMap2';
fig_out2 = 'Example';
sav = 1;

% Numbers of mice to run analysis on
% Mice_to_analyze = [797 798 828 861 882 905 906 911 912];
Mice_to_analyze = [936 941 934 935 863 913];
ExampleMouse = 941;

SessNames={'TestPre' 'TestPost' };
XLinPos = [0:0.05:1];

    Dir = PathForExperimentsERC_SL('StimMFBWake');
    Dir = RestrictPathForExperiment(Dir,'nMice', Mice_to_analyze);
    DirExample{ss} = RestrictPathForExperiment(Dir,'nMice', ExampleMouse);

for i = 1:length(Dir.path)
    a{i} = load([Dir.path{i}{1} '/behavResources.mat'], 'behavResources');
end



%% Find indices of PreTests and PostTest and Cond session in the structure
id_Pre = cell(1,length(a));
id_Post = cell(1,length(a));

for i=1:length(a)
    for i=1:length(a)
        id_Pre{i} = zeros(1,length(a{i}.behavResources));
        id_Post{i} = zeros(1,length(a{i}.behavResources));
        for k=1:length(a{i}.behavResources)
            if ~isempty(strfind(a{i}.behavResources(k).SessionName,'TestPre'))
                id_Pre{i}(k) = 1;
            end
            if ~isempty(strfind(a{i}.behavResources(k).SessionName,'TestPost'))
                id_Post{i}(k) = 1;
            end
        end
        id_Pre{i}=find(id_Pre{i});
        id_Post{i}=find(id_Post{i});
    end
end

for ss = 1 : length(SessNames)
    

    
    % Initialize
    Files.(SessNames{ss}) = cell(1,length(Dir.path));
    
    OccupMap.(SessNames{ss}) = zeros(101,101);
    
    FreezeTime.(SessNames{ss}) = [];
    
    LinPos.(SessNames{ss}) = [];
    
    ZoneTimeTest.(SessNames{ss}) = [];
    
    ZoneTimeTestTot.(SessNames{ss}) = [];
    
    SpeedDistrib.(SessNames{ss}) = [];
    
    ZoneNumTest.(SessNames{ss}) = [];
    
    FirstZoneTimeTest.(SessNames{ss}) = [];
    
    for mm = 1:length(Dir.path)
        cd(Dir.path{mm}{1})
        load('behavResources.mat','Vtsd','AlignedXtsd','AlignedYtsd','ZoneEpochAligned','LinearDist');
        load('ExpeInfo.mat')
        TotalEpoch = intervalSet(0,max(Range(Vtsd)));
        
        
        CoordinatesExample{ss} = load([DirExample{ss}.path{1}{1} 'behavResources.mat'],'AlignedXtsd','AlignedYtsd');
        
        % occupation map
        [OccupMap_temp,xx,yy] = hist2d(Data(AlignedXtsd),Data(AlignedYtsd),[0:0.01:1],[0:0.01:1]);
        OccupMap_temp = OccupMap_temp/sum(OccupMap_temp(:));
        OccupMap.(SessNames{ss}) = OccupMap.(SessNames{ss}) + OccupMap_temp;
        
%         % speed
%         [YSp,XSp] = hist(log(Data(Restrict(Vtsd,TotalEpoch-FreezeAccEpoch))),[-15:0.1:1]);
%         YSp = YSp/sum(YSp);
%         SpeedDistrib.(SessNames{ss})= [SpeedDistrib;YSp];
        
        
        % time in different zones
        for k=1:5
            % mean episode duration
            ZoneTime(k)=nanmean(Stop(ZoneEpochAligned{k},'s')-Start(ZoneEpochAligned{k},'s'));
            % total duration
            ZoneTimeTot(k)=nansum(Stop(ZoneEpochAligned{k},'s')-Start(ZoneEpochAligned{k},'s'));
            
            % number of visits
            RealVisit = dropShortIntervals(ZoneEpochAligned{k},1*1e4);
            ZoneEntr(k)=length(Stop(RealVisit,'s')-Start(RealVisit,'s'));
            
            % time to first entrance
            if not(isempty(Start(RealVisit)))
                FirstZoneTime(k) =min(Start(RealVisit,'s'));
            else
                FirstZoneTime(k) =200;
            end
        end
        
        ZoneTimeTest.(SessNames{ss}) = [ZoneTimeTest.(SessNames{ss});ZoneTime];
        ZoneTimeTestTot.(SessNames{ss}) = [ZoneTimeTestTot.(SessNames{ss});ZoneTimeTot];
        ZoneNumTest.(SessNames{ss}) = [ZoneNumTest.(SessNames{ss});ZoneEntr];
        FirstZoneTimeTest.(SessNames{ss}) = [FirstZoneTimeTest.(SessNames{ss});FirstZoneTime];
        
        %         % freezing time in different zones
        %         for k=1:5
        %             ZoneTime(k)=sum(Stop(and(Behav.FreezeAccEpoch,Behav.ZoneEpochAligned{k}),'s')-Start(and(Behav.ZoneEpochAligned{k},Behav.FreezeAccEpoch),'s'));
        %         end
        %         FreezeTime.(SessNames{ss}).(MouseGroup{mg}){ExpeInfo.SessionNumber} = ...
        %             [FreezeTime.(SessNames{ss}).(MouseGroup{mg}){ExpeInfo.SessionNumber};ZoneTime];
        %
        
        % Linear Position
        [YPos,XPos] = hist(Data(LinearDist),XLinPos);
        YPos = YPos/sum(YPos);
        LinPos.(SessNames{ss}) = [LinPos.(SessNames{ss});YPos];

    end
    
end
%% Plot occupancy
fh = figure('units', 'normalized', 'outerposition', [0 0 0.85 0.65]);
maze = [0.04 0.05; 0.35 0.05; 0.35 0.8; 0.65 0.8; 0.65 0.05; 0.95 0.05; 0.95 0.97; 0.04 0.97; 0.04 0.05];
xmaze = maze(:,1)*101;
ymaze = maze(:,2)*101;

BW = poly2mask(xmaze, ymaze, 101,101);
BW = double(BW);
BW(find(BW==0))=Inf;

for ss = 1 : length(SessNames)
    
    subplot(1,2,ss)
    toplot = (log(OccupMap.(SessNames{ss}))/sum(sum(OccupMap.(SessNames{ss}))))';
    imagesc(yy,xx,toplot.*BW)
    %     imagesc(yy,xx,toplot)
    colormap hot
%     colormap(inferno)
    axis xy
    set(gca,'XTick',[],'YTick',[])
    caxis([-1.3 -0.4])
    hold on
    plot(maze(:,1),maze(:,2),'w','LineWidth',5)
    if ss == 1
        title('Pre', 'FontWeight','bold','FontSize',18)
    elseif ss == 2
        title('Post', 'FontWeight','bold','FontSize',18)
    end
end



%% Save it
if sav
    saveas(gcf, [dir_out fig_out1 '.fig']);
    saveFigure(gcf,fig_out1,dir_out);
end

% 
% %% Plot example
% fh2 = figure('units', 'normalized', 'outerposition', [0 0 0.85 0.65]);
% maze = [0.04 0.05; 0.35 0.05; 0.35 0.8; 0.65 0.8; 0.65 0.05; 0.95 0.05; 0.95 0.97; 0.04 0.97; 0.04 0.05;];
% xmaze = maze(:,1)*101;
% ymaze = maze(:,2)*101;
% 
% BW = poly2mask(xmaze, ymaze, 101,101);
% BW = double(BW);
% BW(find(BW==0))=Inf;
% 
% for ss = 1 : length(SessNames)
%     
%     subplot(1,2,ss)
%     plot(Data(CoordinatesExample{ss}.AlignedXtsd),Data(CoordinatesExample{ss}.AlignedYtsd));
% %     imagesc(yy,xx,toplot)
%     axis xy
%     set(gca,'XTick',[],'YTick',[])
% %     caxis([-1.6 -0.8])
%     hold on
%     plot(maze(:,1),maze(:,2),'k','LineWidth',5)
%     if ss == 1
%         title('Pre', 'FontWeight','bold','FontSize',18)
%     elseif ss == 2
%         title('Post', 'FontWeight','bold','FontSize',18)
%     end
% end
% 


%% Save it
% if sav
%     saveas(fh2, [dir_out fig_out2 '.fig']);
%     saveFigure(fh2,fig_out2,dir_out);
% end
%% Clear variables
clear