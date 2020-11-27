clear all
dirpost = '/media/mobs/DataMOBS94/M0882/StimWakeMFB/6-PostTests/';
dirpre = '/media/mobs/DataMOBS94/M0882/StimWakeMFB/3-PreTests/';
dir_out = '/home/mobs/Dropbox/MOBS_workingON/Sam/WakeStimMFB/';
sav = 1;

nbtrials = 8;

predata = load([dirpre 'behavResources.mat'],'behavResources');
postdata = load([dirpost 'behavResources.mat'],'behavResources');


%occupancy

for itrials=1:nbtrials
    for izone=1:5
        Pre_Occup(itrials,izone)=size(predata.behavResources(itrials).ZoneIndices{izone},1)./...
        size(Data(predata.behavResources(itrials).Xtsd),1);
    end
    
    for izone=1:5
        Post_Occup(itrials,izone)=size(postdata.behavResources(itrials).ZoneIndices{izone},1)./...
        size(Data(postdata.behavResources(itrials).Xtsd),1);
    end
end
Pre_Occup = squeeze(Pre_Occup(:,:,1));
Post_Occup = squeeze(Post_Occup(:,:,1));
Pre_Occup_mean = mean(Pre_Occup);
Pre_Occup_std = std(Pre_Occup,0);
Post_Occup_mean = mean(Post_Occup);
Post_Occup_std = std(Post_Occup,0);

% first entry
for itrials=1:nbtrials
    if isempty(predata.behavResources(itrials).ZoneIndices{1})
        Pre_FirstTime(itrials) = 60;
    else
        Pre_FirstZoneIndices(itrials) = predata.behavResources(itrials).ZoneIndices{1}(1);
        Pre_FirstTime(itrials) = predata.behavResources(itrials).PosMat(Pre_FirstZoneIndices(itrials),1)-...
            predata.behavResources(itrials).PosMat(1,1);
    end
    if isempty(postdata.behavResources(itrials).ZoneIndices{1})
        Post_FirstTime(itrials) = 60;
    else
        Post_FirstZoneIndices(itrials) = postdata.behavResources(itrials).ZoneIndices{1}(1);
        Post_FirstTime(itrials) = postdata.behavResources(itrials).PosMat(Post_FirstZoneIndices(itrials),1)-...
            postdata.behavResources(itrials).PosMat(1,1);
    end
end
Pre_FirstTime_mean = mean(Pre_FirstTime,2);
Pre_FirstTime_std = std(Pre_FirstTime,0,2);
Post_FirstTime_mean = mean(Post_FirstTime,2);
Post_FirstTime_std = std(Post_FirstTime,0,2);


%Number of entry in the shock zone
for itrials=1:nbtrials
    if isempty(predata.behavResources(itrials).ZoneIndices{1})
        Pre_entnum(itrials) = 0;
    else
        Pre_entnum(itrials)=length(find(diff(predata.behavResources(itrials).ZoneIndices{1})>1))+1;
    end
    if isempty(postdata.behavResources(itrials).ZoneIndices{1})
        Post_entnum(itrials) = 0;
    else
        Post_entnum(itrials)=length(find(diff(postdata.behavResources(itrials).ZoneIndices{1})>1))+1;
    end
end
Pre_entnum_mean = mean(Pre_entnum,2);
Pre_entnum_std = std(Pre_entnum,0,2);
Post_entnum_mean = mean(Post_entnum,2);
Post_entnum_std = std(Post_entnum,0,2);

%Speed


 % PreTest ShockZone speed
 for itrials=1:nbtrials
    if isempty(predata.behavResources(itrials).ZoneIndices{2})
        VZmean_pre(itrials) = NaN;
    else
        Vtemp_pre{itrials}=Data(predata.behavResources(itrials).Vtsd);
        VZone_pre{itrials}=Vtemp_pre{itrials}(predata.behavResources(itrials).ZoneIndices{2}(1:end-1),1);
        VZmean_pre(itrials)=mean(VZone_pre{itrials},1);
    end
    
    if isempty(postdata.behavResources(itrials).ZoneIndices{2})
        VZmean_post(itrials) = NaN;
    else
        Vtemp_post{itrials}=Data(postdata.behavResources(itrials).Vtsd);
        VZone_post{itrials}=Vtemp_post{itrials}(postdata.behavResources(itrials).ZoneIndices{2}(1:end-1),1);
        VZmean_post(itrials)=mean(VZone_post{itrials},1);
    end
 end
Pre_VZmean_mean = mean(VZmean_pre,2);
Pre_VZmean_std = std(VZmean_pre,0,2);
Post_VZmean_mean = mean(VZmean_post,2);
Post_VZmean_std = std(VZmean_post,0,2);
 
 %% Plot
% Axes
fh = figure('units', 'normalized', 'outerposition', [0 0 0.65 0.65]);
Occupancy_Axes = axes('position', [0.07 0.55 0.41 0.41]);
NumEntr_Axes = axes('position', [0.55 0.55 0.41 0.41]);
First_Axes = axes('position', [0.07 0.05 0.41 0.41]);
Speed_Axes = axes('position', [0.55 0.05 0.41 0.41]);

% Occupancy
axes(Occupancy_Axes);
[p_occ,h_occ, her_occ] = PlotErrorBarN_DB([Pre_Occup(:,1)*100 Post_Occup(:,1)*100], 'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'showpoints',0);
%b1 = bar([Pre_Occup_mean(1)*100 Post_Occup_mean(1)*100]);
h_occ.FaceColor = 'flat';
h_occ.CData(2,:) = [1 1 1];
set(gca,'Xtick',[1:2],'XtickLabel',{'PreTest', 'PostTest'});
set(gca, 'FontSize', 12);
set(gca, 'LineWidth', 3);
set(h_occ, 'LineWidth', 3);
set(her_occ, 'LineWidth', 3);
line(xlim,[21.5 21.5],'Color',[0.5 0.5 0.5],'LineStyle','--','LineWidth',2);
text(0.1,23.2,'Random Occupancy', 'FontSize',9, 'Color',[0.5 0.5 0.5]);
ylabel('% time');
title('Reward zone occupancy', 'FontSize', 14);
ylim([0 60])


axes(NumEntr_Axes);
[p_nent,h_nent, her_nent] = PlotErrorBarN_DB([Pre_entnum' Post_entnum'], 'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'showpoints',0);
h_nent.FaceColor = 'flat';
h_nent.CData(2,:) = [1 1 1];
set(gca,'Xtick',[1:2],'XtickLabel',{'PreTest', 'PostTest'});
set(gca, 'FontSize', 12);
set(gca, 'LineWidth', 3);
set(h_nent, 'LineWidth', 3);
set(her_nent, 'LineWidth', 3);
ylabel('Number of entries');
title('# of entries to the reward zone', 'FontSize', 14);
ylim([0 5])

axes(First_Axes);
[p_first,h_first, her_first] = PlotErrorBarN_DB([Pre_FirstTime' Post_FirstTime'], 'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'showpoints',0);
h_first.FaceColor = 'flat';
h_first.CData(2,:) = [1 1 1];
set(gca,'Xtick',[1:2],'XtickLabel',{'PreTest', 'PostTest'});
set(gca, 'FontSize', 12);
set(gca, 'LineWidth', 3);
set(h_first, 'LineWidth', 3);
set(her_first, 'LineWidth', 3);
ylabel('Time (s)');
title('First time to enter the reward zone', 'FontSize', 14);

axes(Speed_Axes);
[p_speed,h_speed, her_speed] = PlotErrorBarN_DB([VZmean_pre' VZmean_post'], 'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'showpoints',0);
h_speed.FaceColor = 'flat';
h_speed.CData(2,:) = [1 1 1];
set(gca,'Xtick',[1:2],'XtickLabel',{'PreTest', 'PostTest'});
set(gca, 'FontSize', 12);
set(gca, 'LineWidth', 3);
set(h_speed, 'LineWidth', 3);
set(her_speed, 'LineWidth', 3);
ylabel('Speed (cm/s)');
title('Average speed in the reward zone', 'FontSize', 14);
ylim([0 6])

%% Save it
fig_post = 'M0882_WakeStimMFB_Behav_all';
if sav
    saveas(gcf, [dir_out fig_post '.fig']);
    saveFigure(gcf,fig_post,dir_out);
end