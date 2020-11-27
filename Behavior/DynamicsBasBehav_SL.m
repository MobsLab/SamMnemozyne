%DynamicsBasBehav_ERC2 - Plot basic behavior comparisons of ERC experiment across trials.
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
%       BehaviorERC, PathForExperimentERC_Dima
% 
%       2018 by Dmitri Bryzgalov

%% Parameters
% Directory to save and name of the figure to save
dir_out = '/home/mobsrick/Dropbox/MOBS_workingON/Dima/Ongoing results/Behavior/';
fig_post = 'DynamicsBehavior_ERC2';
% Before Vtsd correction == 1
old = 0;
sav = 0;
safe = 0; % Do you want to plot statistics for safe

% Numbers of mice to run analysis on
% Mice_to_analyze = [797 798 828 861 882 905 906 911 912];
Mice_to_analyze = [797 798 828 861 882 905 912];

% Get directories
Dir = PathForExperimentsERC_Dima('UMazePAG');
Dir = RestrictPathForExperiment(Dir,'nMice', Mice_to_analyze);

clrs = {'ko', 'ro', 'go','co'; 'k','r', 'g', 'c'};

% Axes
% fh = figure('units', 'normalized', 'outerposition', [0 0 0.65 0.65]);
% Occupancy_Axes = axes('position', [0.07 0.55 0.41 0.41]);
% NumEntr_Axes = axes('position', [0.55 0.55 0.41 0.41]);
% First_Axes = axes('position', [0.07 0.05 0.41 0.41]);
% Speed_Axes = axes('position', [0.55 0.05 0.41 0.41]);

%% Get data

for i = 1:length(Dir.path)
    % PreTests
    a{i} = load([Dir.path{i}{1} '/behavResources.mat'], 'behavResources');
end

%% Find indices of PreTests and PostTest session in the structure
id_Pre = cell(1,length(a));
id_Post = cell(1,length(a));

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

%% Calculate average occupancy
% Calculate occupancy de novo
for i=1:length(a)
    for k=1:length(id_Pre{i})
        for t=1:length(a{i}.behavResources(id_Pre{i}(k)).Zone)
            Pre_Occup(i,k,t)=size(a{i}.behavResources(id_Pre{i}(k)).CleanZoneIndices{t},1)./...
                size(Data(a{i}.behavResources(id_Pre{i}(k)).CleanXtsd),1);
        end
    end
    for k=1:length(id_Post{i})
        for t=1:length(a{i}.behavResources(id_Post{i}(k)).Zone)
            Post_Occup(i,k,t)=size(a{i}.behavResources(id_Post{i}(k)).CleanZoneIndices{t},1)./...
                size(Data(a{i}.behavResources(id_Post{i}(k)).CleanXtsd),1);
        end
    end
end
% Shock
Pre_Occup_Shock = squeeze(Pre_Occup(:,:,1));
Post_Occup_Shock = squeeze(Post_Occup(:,:,1));

Pre_Occup_Shock_mean = mean(Pre_Occup_Shock,1);
Pre_Occup_Shock_std = std(Pre_Occup_Shock,0,1);
Post_Occup_Shock_mean = mean(Post_Occup_Shock,1);
Post_Occup_Shock_std = std(Post_Occup_Shock,0,1);

% Safe
Pre_Occup_Safe = squeeze(Pre_Occup(:,:,1));
Post_Occup_Safe = squeeze(Post_Occup(:,:,1));

Pre_Occup_Safe_mean = mean(Pre_Occup_Safe,1);
Pre_Occup_Safe_std = std(Pre_Occup_Safe,0,1);
Post_Occup_Safe_mean = mean(Post_Occup_Safe,1);
Post_Occup_Safe_std = std(Post_Occup_Safe,0,1);

%% Prepare the 'first enter to shock zone' array
for i = 1:length(a)
    for k=1:length(id_Pre{i})
        if isempty(a{i}.behavResources(id_Pre{i}(k)).CleanZoneIndices{1})
            Pre_FirstTime(i,k) = 240;
        else
            Pre_FirstZoneIndices{i}{k} = a{i}.behavResources(id_Pre{i}(k)).CleanZoneIndices{1}(1);
            Pre_FirstTime(i,k) = a{i}.behavResources(id_Pre{i}(k)).CleanPosMat(Pre_FirstZoneIndices{i}{k}(1),1)-...
                a{i}.behavResources(id_Pre{i}(k)).CleanPosMat(1,1);
        end
    end
    
    for k=1:length(id_Post{i})
        if isempty(a{i}.behavResources(id_Post{i}(k)).CleanZoneIndices{1})
            Post_FirstTime(i,k) = 240;
        else
            Post_FirstZoneIndices{i}{k} = a{i}.behavResources(id_Post{i}(k)).CleanZoneIndices{1}(1);
            Post_FirstTime(i,k) = a{i}.behavResources(id_Post{i}(k)).CleanPosMat(Post_FirstZoneIndices{i}{k}(1),1)-...
                 a{i}.behavResources(id_Post{i}(k)).CleanPosMat(1,1);
        end
    end
end
    
Pre_FirstTime_mean = mean(Pre_FirstTime);
Pre_FirstTime_std = std(Pre_FirstTime);
Post_FirstTime_mean = mean(Post_FirstTime);
Post_FirstTime_std = std(Post_FirstTime);

%% Calculate number of entries into the shock zone
% Check with smb if it's correct way to calculate (plus one entry even if one frame it was outside )
for i = 1:length(a)
    for k=1:length(id_Pre{i})
        if isempty(a{i}.behavResources(id_Pre{i}(k)).CleanZoneIndices{1})
            Pre_entnum(i,k) = 0;
        else
            Pre_entnum(i,k)=length(find(diff(a{i}.behavResources(id_Pre{i}(k)).CleanZoneIndices{1})>1))+1;
        end
    end
    
    for k=1:length(id_Post{i})   
        if isempty(a{i}.behavResources(id_Post{i}(k)).CleanZoneIndices{1})
            Post_entnum(i,k) = 0;
        else
            Post_entnum(i,k)=length(find(diff(a{i}.behavResources(id_Post{i}(k)).CleanZoneIndices{1})>1))+1;
        end
    end
    
end
Pre_entnum_mean = mean(Pre_entnum,1);
Pre_entnum_std = std(Pre_entnum,0,1);
Post_entnum_mean = mean(Post_entnum,1);
Post_entnum_std = std(Post_entnum,0,1);

%% Calculate speed in the safe zone and in the noshock + shock vs everything else
% I skip the last point in ZoneIndices because length(Xtsd)=length(Vtsd)+1
% - UPD 18/07/2018 - Could do length(Start(ZoneEpoch))
for i = 1:length(a)
    for k=1:length(id_Pre{i})
        % PreTest SafeZone speed
        if isempty(a{i}.behavResources(id_Pre{i}(k)).CleanZoneIndices{2})
            VZmean_pre(i,k) = 0;
        else
            if old
                Vtemp_pre{i}{k} = tsd(Range(a{i}.behavResources(id_Pre{i}(k)).CleanVtsd),...
                    (Data(a{i}.behavResources(id_Pre{i}(k)).CleanVtsd)./...
                    ([diff(a{i}.behavResources(id_Pre{i}(k)).CleanPosMat(:,1));-1])));
            else
                Vtemp_pre{i}{k}=Data(a{i}.behavResources(id_Pre{i}(k)).CleanVtsd);
            end
            VZone_pre{i}{k}=Vtemp_pre{i}{k}(a{i}.behavResources(id_Pre{i}(k)).CleanZoneIndices{2}(1:end-1),1);
            VZmean_pre(i,k)=nanmean(VZone_pre{i}{k},1);
        end
    end
    
    % PostTest SafeZone speed
    for k=1:length(id_Post{i})
        % PreTest SafeZone speed
        if isempty(a{i}.behavResources(id_Post{i}(k)).CleanZoneIndices{2})
            VZmean_post(i,k) = 0;
        else
            if old
                Vtemp_post{i}{k} = tsd(Range(a{i}.behavResources(id_Post{i}(k)).CleanVtsd),...
                    (Data(a{i}.behavResources(id_Post{i}(k)).CleanVtsd)./...
                    ([diff(a{i}.behavResources(id_Post{i}(k)).CleanPosMat(:,1));-1])));
            else
                Vtemp_post{i}{k}=Data(a{i}.behavResources(id_Post{i}(k)).CleanVtsd);
            end
            VZone_post{i}{k}=Vtemp_post{i}{k}(a{i}.behavResources(id_Post{i}(k)).CleanZoneIndices{2}(1:end-1),1);
            VZmean_post(i,k)=nanmean(VZone_post{i}{k},1);
        end
    end
    
end

Pre_VZmean_mean = mean(VZmean_pre,1);
Pre_VZmean_std = std(VZmean_pre,0,1);
Post_VZmean_mean = mean(VZmean_post,1);
Post_VZmean_std = std(VZmean_post,0,1);

%% Plot
% Occupancy
fh1 = figure('units', 'normalized', 'outerposition', [0 0 0.8 0.6])
b = barwitherr([Pre_Occup_Shock_std*100; Post_Occup_Shock_std*100]',...
[Pre_Occup_Shock_mean*100; Post_Occup_Shock_mean*100]');
set(gca, 'FontSize', 14, 'FontWeight',  'bold');
set(gca, 'LineWidth', 3);
b(1).BarWidth = 0.8;
b(1).FaceColor = 'k';
b(2).FaceColor = 'w';
b(1).LineWidth = 3;
b(2).LineWidth = 3;
x = [b(1).XData + [b(1).XOffset]; b(1).XData - [b(1).XOffset]];
hold on
set(gca,'Xtick',[1:4],'XtickLabel',{'Test1', 'Test2', 'Test3', 'Test4'})
ylabel('% Occupancy')
hold off
box off
set(gca, 'FontSize', 14, 'FontWeight',  'bold');
set(gca, 'LineWidth', 3);
title('Dynamics of occupancy') 
lg = legend('PreTests', 'PostTests');
lg.FontSize = 14;

% Number of enters
fh2 = figure('units', 'normalized', 'outerposition', [0 0 0.8 0.6])
b = barwitherr([Pre_entnum_std; Post_entnum_std]',[Pre_entnum_mean; Post_entnum_mean]');
set(gca, 'FontSize', 14, 'FontWeight',  'bold');
set(gca, 'LineWidth', 3);
b(1).BarWidth = 0.8;
b(1).FaceColor = 'k';
b(2).FaceColor = 'w';
b(1).LineWidth = 3;
b(2).LineWidth = 3;
x = [b(1).XData + [b(1).XOffset]; b(1).XData - [b(1).XOffset]];
hold on
set(gca,'Xtick',[1:4],'XtickLabel',{'Test1', 'Test2', 'Test3', 'Test4'})
ylabel('# Entries')
hold off
box off
set(gca, 'FontSize', 14, 'FontWeight',  'bold');
set(gca, 'LineWidth', 3);
title('Dynamics of #entries to the shock zone') 
lg = legend('PreTests', 'PostTests');
lg.FontSize = 14;

% First time to enter
fh3 = figure('units', 'normalized', 'outerposition', [0 0 0.8 0.6])
b = barwitherr([Pre_FirstTime_std; Post_FirstTime_std]',[Pre_FirstTime_mean; Post_FirstTime_mean]');
set(gca, 'FontSize', 14, 'FontWeight',  'bold');
set(gca, 'LineWidth', 3);
b(1).BarWidth = 0.8;
b(1).FaceColor = 'k';
b(2).FaceColor = 'w';
b(1).LineWidth = 3;
b(2).LineWidth = 3;
x = [b(1).XData + [b(1).XOffset]; b(1).XData - [b(1).XOffset]];
hold on
set(gca,'Xtick',[1:4],'XtickLabel',{'Test1', 'Test2', 'Test3', 'Test4'})
ylabel('Time (s)')
hold off
box off
set(gca, 'FontSize', 14, 'FontWeight',  'bold');
set(gca, 'LineWidth', 3);
title('Dynamics of 1st time to enter the shock zone')  
lg = legend('PreTests', 'PostTests');
lg.FontSize = 14;

% Speed in Safe
fh4 = figure('units', 'normalized', 'outerposition', [0 0 0.8 0.6])
b = barwitherr([Pre_VZmean_mean; Post_VZmean_mean]',[Pre_VZmean_mean; Post_VZmean_mean]');
set(gca, 'FontSize', 14, 'FontWeight',  'bold');
set(gca, 'LineWidth', 3);
b(1).BarWidth = 0.8;
b(1).FaceColor = 'k';
b(2).FaceColor = 'w';
b(1).LineWidth = 3;
b(2).LineWidth = 3;
x = [b(1).XData + [b(1).XOffset]; b(1).XData - [b(1).XOffset]];
hold on
set(gca,'Xtick',[1:4],'XtickLabel',{'Test1', 'Test2', 'Test3', 'Test4'})
ylabel('Speed (cm/s)')
hold off
box off
set(gca, 'FontSize', 14, 'FontWeight',  'bold');
set(gca, 'LineWidth', 3);
title('Dynamics of speed in the safe zone') 
lg = legend('PreTests', 'PostTests');
lg.FontSize = 14;