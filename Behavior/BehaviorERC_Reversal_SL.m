%BehaviorERC - Plot basic behavior comparisons of ERC experiment avergaed across mice.
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
%       QuickCheckBehaviorERC, PathForExperimentERC_Dima
% 
%       2018 by Dmitri Bryzgalov
%       Modified by S. Laventure on 03/10/2019
%               - plot trajectories 
%               - can plot occupancy
%               - plot barplot of stim vs no stim
%

%% Parameters
% Directory to save and name of the figure to save
% dir_out = '/home/mobs/Dropbox/MOBS_workingON/Sam/StimMFBWake/Behavior/';
dir_out = '/home/mobs/Dropbox/MOBS_workingON/Sam/Reversal/Behavior/';

%set folders
if ~exist(dir_out,'dir')
    mkdir(dir_out);
end

% Before Vtsd correction == 1
old = 0;
sav = 1;

% Numbers of mice to run analysis on
% Mice_to_analyze = [936 941 934 935 863 913]; % MFBStimWake
% mice_str = {'936','941','934','935','863','913'};

% Mice_to_analyze = [863 913 934 941]; % MFBStimWake
% mice_str = {'863','913','934','941'};

Mice_to_analyze = [994]; % MFBStimWake
mice_str = {'994'};


% Get directories
% Dir = PathForExperimentsERC_SL('StimMFBWake');
Dir = PathForExperimentsERC_SL('Reversal');
Dir = RestrictPathForExperiment(Dir,'nMice', Mice_to_analyze);

%-------------- MAP PARAMETERS -----------
freqVideo=15;       %frame rate
smo=2;            %smoothing factor
sizeMap=50;         %Map size

%------------- FIGURE PARAMETERS -------------
clrs = {'ko', 'bo', 'ro','go', 'co', 'mo'; 'k','r','b','m','g','c'; 'kp', 'bp', 'rp', 'gp', 'cp', 'mp'};

%------------- VAR INIT -------------
OccupMap_pre = zeros(101,101);
OccupMap_post = zeros(101,101);
%#####################################################################
%#
%#                           M A I N
%#
%#####################################################################

%% Get data

for i = 1:length(Dir.path)
    a{i} = load([Dir.path{i}{1} '/behavResources.mat'], 'behavResources');
end

%% Find indices of PreTests and PostTest and Cond session in the structure
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
            Pre_Occup(i,k,t)=size(a{i}.behavResources(id_Pre{i}(k)).ZoneIndices{t},1)./...
                size(Data(a{i}.behavResources(id_Pre{i}(k)).Xtsd),1);
        end
    end
    for k=1:length(id_Post{i})
        for t=1:length(a{i}.behavResources(id_Post{i}(k)).Zone)
            Post_Occup(i,k,t)=size(a{i}.behavResources(id_Post{i}(k)).ZoneIndices{t},1)./...
                size(Data(a{i}.behavResources(id_Post{i}(k)).Xtsd),1);
        end
    end
end

Pre_Occup_stim = squeeze(Pre_Occup(:,:,1));
Pre_Occup_nostim = squeeze(Pre_Occup(:,:,2));
%Pre_Occup = squeeze(Pre_Occup(:,:,1));
Post_Occup_stim = squeeze(Post_Occup(:,:,1));
Post_Occup_nostim = squeeze(Post_Occup(:,:,2));
%Post_Occup = squeeze(Post_Occup(:,:,1));

%----  PRE
% Shock
Pre_Occup_stim_mean = mean(Pre_Occup_stim,2);
% nostim
Pre_Occup_nostim_mean = mean(Pre_Occup_nostim,2);


%----  POST
% Shock
Post_Occup_stim_mean = mean(Post_Occup_stim,2);
Post_Occup_stim_trial_mean = mean(Post_Occup_stim,1);
% nostim
Post_Occup_nostim_mean = mean(Post_Occup_nostim,2);
Post_Occup_nostim_trial_mean = mean(Post_Occup_nostim,1);



%% Prepare the 'first enter to shock zone' array
for i = 1:length(a)
    for k=1:length(id_Pre{i})
        if isempty(a{i}.behavResources(id_Pre{i}(k)).ZoneIndices{1})
            Pre_FirstTime(i,k) = 240;
        else
            Pre_FirstZoneIndices{i}{k} = a{i}.behavResources(id_Pre{i}(k)).ZoneIndices{1}(1);
            Pre_FirstTime(i,k) = a{i}.behavResources(id_Pre{i}(k)).PosMat(Pre_FirstZoneIndices{i}{k}(1),1)-...
                a{i}.behavResources(id_Pre{i}(k)).PosMat(1,1);
        end
    end
    
    for k=1:length(id_Post{i})
        if isempty(a{i}.behavResources(id_Post{i}(k)).ZoneIndices{1})
            Post_FirstTime(i,k) = 240;
        else
            Post_FirstZoneIndices{i}{k} = a{i}.behavResources(id_Post{i}(k)).ZoneIndices{1}(1);
            Post_FirstTime(i,k) = a{i}.behavResources(id_Post{i}(k)).PosMat(Post_FirstZoneIndices{i}{k}(1),1)-...
                 a{i}.behavResources(id_Post{i}(k)).PosMat(1,1);
        end
    end
end
    
Pre_FirstTime_mean = mean(Pre_FirstTime,2);
Pre_FirstTime_std = std(Pre_FirstTime,0,2);
Post_FirstTime_mean = mean(Post_FirstTime,2);
Post_FirstTime_std = std(Post_FirstTime,0,2);
% Wilcoxon test
p_FirstTime_pre_post = signrank(Pre_FirstTime_mean,Post_FirstTime_mean);

%% Calculate number of entries into the shock zone
% Check with smb if it's correct way to calculate (plus one entry even if one frame it was outside )
for i = 1:length(a)
    for k=1:length(id_Pre{i})
        if isempty(a{i}.behavResources(id_Pre{i}(k)).ZoneIndices{1})
            Pre_entnum(i,k) = 0;
        else
            Pre_entnum(i,k)=length(find(diff(a{i}.behavResources(id_Pre{i}(k)).ZoneIndices{1})>1))+1;
        end
    end
    
    for k=1:length(id_Post{i})   
        if isempty(a{i}.behavResources(id_Post{i}(k)).ZoneIndices{1})
            Post_entnum(i,k) = 0;
        else
            Post_entnum(i,k)=length(find(diff(a{i}.behavResources(id_Post{i}(k)).ZoneIndices{1})>1))+1;
        end
    end
    
end
Pre_entnum_mean = mean(Pre_entnum,2);
Pre_entnum_std = std(Pre_entnum,0,2);
Post_entnum_mean = mean(Post_entnum,2);
Post_entnum_std = std(Post_entnum,0,2);
% Wilcoxon test
p_entnum_pre_post = signrank(Pre_entnum_mean, Post_entnum_mean);

%% Calculate speed in the Reward zone and in the noshock + shock vs everything else
% I skip the last point in ZoneIndices because length(Xtsd)=length(Vtsd)+1
% - UPD 18/07/2018 - Could do length(Start(ZoneEpoch))
for i = 1:length(a)
    for k=1:length(id_Pre{i})
        % PreTest nostimZone speed
        if isempty(a{i}.behavResources(id_Pre{i}(k)).ZoneIndices{1})
            VZmean_pre(i,k) = 0;
        else
            if old
                Vtemp_pre{i}{k} = tsd(Range(a{i}.behavResources(id_Pre{i}(k)).Vtsd),...
                    (Data(a{i}.behavResources(id_Pre{i}(k)).Vtsd)./...
                    ([diff(a{i}.behavResources(id_Pre{i}(k)).PosMat(:,1));-1])));
            else
                Vtemp_pre{i}{k}=Data(a{i}.behavResources(id_Pre{i}(k)).Vtsd);
            end
            VZone_pre{i}{k}=Vtemp_pre{i}{k}(a{i}.behavResources(id_Pre{i}(k)).ZoneIndices{1}(1:end-1),1);
            VZmean_pre(i,k)=mean(VZone_pre{i}{k},1);
        end
    end
    % PostTest nostimZone speed
    for k=1:length(id_Post{i})
        % PreTest nostimZone speed
        if isempty(a{i}.behavResources(id_Post{i}(k)).ZoneIndices{1})
            VZmean_post(i,k) = 0;
        else
            if old
                Vtemp_post{i}{k} = tsd(Range(a{i}.behavResources(id_Post{i}(k)).Vtsd),...
                    (Data(a{i}.behavResources(id_Post{i}(k)).Vtsd)./...
                    ([diff(a{i}.behavResources(id_Post{i}(k)).PosMat(:,1));-1])));
            else
                Vtemp_post{i}{k}=Data(a{i}.behavResources(id_Post{i}(k)).Vtsd);
            end
            VZone_post{i}{k}=Vtemp_post{i}{k}(a{i}.behavResources(id_Post{i}(k)).ZoneIndices{1}(1:end-1),1);
            VZmean_post(i,k)=mean(VZone_post{i}{k},1);
        end
    end
    
end

Pre_VZmean_mean = mean(VZmean_pre,2);
Pre_VZmean_std = std(VZmean_pre,0,2);
Post_VZmean_mean = mean(VZmean_post,2);
Post_VZmean_std = std(VZmean_post,0,2);
% Wilcoxon test
p_VZmean_pre_post = signrank(Pre_VZmean_mean, Post_VZmean_mean);

%% GET OCCUPANCY DATA

for i=1:length(a)
    %Pre-tests
    for k=1:length(id_Pre{i})
        [occH_pre, x1, x2] = hist2(Data(a{i}.behavResources(id_Pre{i}(k)).AlignedXtsd),...
            Data(a{i}.behavResources(id_Pre{i}(k)).AlignedYtsd), 240, 320);
        occHS_pre(i,k,1:320,1:240) = SmoothDec(occH_pre/freqVideo,[smo,smo]); 
        x_pre(i,k,1:240)=x1;
        y_pre(i,k,1:320)=x2;
    end % loop nb sess 
    %Post-tests
    for k=1:length(id_Post{i})
        [occH_post, x1, x2] = hist2(Data(a{i}.behavResources(id_Post{i}(k)).AlignedXtsd),...
            Data(a{i}.behavResources(id_Post{i}(k)).AlignedYtsd), 240, 320);
        occHS_post(i,k,1:320,1:240) = SmoothDec(occH_post/freqVideo,[smo,smo]); 
        x_post(i,k,1:240)=x1;
        y_post(i,k,1:320)=x2;
    end % loop nb sess 
end % loop mice

for i=1:length(a)
    %Pre-tests
    for k=1:length(id_Pre{i})
        % occupation map
        [OccupMap_temp,xx,yy] = hist2d(Data(a{i}.behavResources(id_Pre{i}(k)).AlignedXtsd),...
            Data(a{i}.behavResources(id_Pre{i}(k)).AlignedYtsd),[0:0.01:1],[0:0.01:1]);
        OccupMap_temp = OccupMap_temp/sum(OccupMap_temp(:));
%         OccupMap_pre(i,k,1:101,1:101) = OccupMap_pre(i,k,:,:) + OccupMap_temp;
        OccupMap_pre(1:101,1:101) = OccupMap_pre(:,:) + OccupMap_temp;
    end % loop nb sess 
    %Post-tests
    for k=1:length(id_Post{i})
                % occupation map
        [OccupMap_temp,xx,yy] = hist2d(Data(a{i}.behavResources(id_Post{i}(k)).AlignedXtsd),...
            Data(a{i}.behavResources(id_Post{i}(k)).AlignedYtsd),[0:0.01:1],[0:0.01:1]);
        OccupMap_temp = OccupMap_temp/sum(OccupMap_temp(:));
%         OccupMap_post(i,k,1:101,1:101) = OccupMap_post(i,k,:,:) + OccupMap_temp;
        OccupMap_post(1:101,1:101) = OccupMap_post(:,:) + OccupMap_temp;
    end
end

%% Get data by zones

%var init
trajzone_pre{length(a),4}=nan;
trajzone_post{length(a),4}=nan;

for i=1:length(a)
    for itrial=1:4
        nzones = size(a{i}.behavResources(id_Pre{i}(itrial)).ZoneIndices,2)-2; %there are two zones in position 6 and 7 that are not used. *sigh*
        for izone=1:nzones
            if izone<6
                trajzone_pre{i,itrial}(a{i}.behavResources(id_Pre{i}(itrial)).ZoneIndices{izone}) = izone;
                trajzone_cond{i,itrial}(a{i}.behavResources(id_Cond{i}(itrial)).ZoneIndices{izone}) = izone;
                trajzone_post{i,itrial}(a{i}.behavResources(id_Post{i}(itrial)).ZoneIndices{izone}) = izone;
            else
                trajzone_pre{i,itrial}(a{i}.behavResources(id_Pre{i}(itrial)).ZoneIndices{izone+2}) = izone;
                trajzone_cond{i,itrial}(a{i}.behavResources(id_Cond{i}(itrial)).ZoneIndices{izone+2}) = izone;
                trajzone_post{i,itrial}(a{i}.behavResources(id_Post{i}(itrial)).ZoneIndices{izone+2}) = izone;
            end   
            trajzone_pre_temp_id{i,itrial,izone} = find(trajzone_pre{i,itrial}(:)==izone);
            trajzone_pre_temp{i,itrial}(izone,trajzone_pre_temp_id{i,itrial,izone}) = 1;   
            trajzone_cond_temp_id{i,itrial,izone} = find(trajzone_cond{i,itrial}(:)==izone);
            trajzone_cond_temp{i,itrial}(izone,trajzone_cond_temp_id{i,itrial,izone}) = 1;   
            trajzone_post_temp_id{i,itrial,izone} = find(trajzone_post{i,itrial}(:)==izone);
            trajzone_post_temp{i,itrial}(izone,trajzone_post_temp_id{i,itrial,izone}) = 1; 
        end
        
        trajzone_cumul_pre = cumsum(trajzone_pre_temp{i,itrial}');
        trajzone_pre_ratio{i,itrial} = trajzone_cumul_pre ./ sum(trajzone_cumul_pre,2);
        trajzone_cumul_cond = cumsum(trajzone_cond_temp{i,itrial}');
        trajzone_cond_ratio{i,itrial} = trajzone_cumul_cond ./ sum(trajzone_cumul_cond,2);
        trajzone_cumul_post = cumsum(trajzone_post_temp{i,itrial}');
        trajzone_post_ratio{i,itrial} = trajzone_cumul_post ./ sum(trajzone_cumul_post,2);
        
        % re-order in a linear pattern for visualization
        trajzone_pre_ratio{i,itrial} = trajzone_pre_ratio{i,itrial}(:,[1 4 6 3 7 5 2]);
        trajzone_cond_ratio{i,itrial} = trajzone_cond_ratio{i,itrial}(:,[1 4 6 3 7 5 2]);
        trajzone_post_ratio{i,itrial} = trajzone_post_ratio{i,itrial}(:,[1 4 6 3 7 5 2]);
    end
end



    
for i=1:length(a)
    supertit = ['Mouse ' num2str(Mice_to_analyze(i))  ' - trial dynamics'];
    figure('Color',[1 1 1], 'rend','painters','pos',[10 10 2000 1200],'Name', supertit, 'NumberTitle','off')
    % prepare data visualization (stim, nostim for each trial in the same vector)   
%         datpre = nan(8);
%         datpost = nan(8);
        itrial=1;
        for ii=1:3:10
            datpre(ii) = squeeze(Pre_Occup(i,itrial,1));
            datpre(ii+1) = squeeze(Pre_Occup(i,itrial,2));
            datpre(ii+2) = nan;
            datpost(ii) = squeeze(Post_Occup(i,itrial,1));
            datpost(ii+1) = squeeze(Post_Occup(i,itrial,2));
            datpost(ii+2) = nan;
            itrial=itrial+1;
        end
        
        subplot(3,6,1:2)
            [p_occ,h_occ, her_occ] = PlotErrorBarN_DB(datpre*100,...
                'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'showpoints',0);
            h_occ.FaceColor = 'flat';
            h_occ.CData([2 5 8 11],:) = repmat([1 1 1],4,1);
            set(gca,'Xtick',[1:12],'XtickLabel',{'','trial 1','','','trial 2','','',...
                    'trial 3','','','trial 4',''});
            set(gca, 'FontSize', 14);
            set(gca, 'LineWidth', 1);
            set(h_occ, 'LineWidth', 1);
            set(her_occ, 'LineWidth', 1);
            line(xlim,[21.5 21.5],'Color','k','LineStyle','--','LineWidth',1);
            ylabel('% time');
            ylim([0 100])
            title('Pre-tests')
            
        subplot(3,6,5:6)
            [p_occ,h_occ, her_occ] = PlotErrorBarN_DB(datpost*100,...
                'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'showpoints',0);
            h_occ.FaceColor = 'flat';
            h_occ.CData([2 5 8 11],:) = repmat([1 1 1],4,1);
            set(gca,'Xtick',[1:12],'XtickLabel',{'','trial 1','','','trial 2','','',...
                    'trial 3','','','trial 4',''});
            set(gca, 'FontSize', 14);
            set(gca, 'LineWidth', 1);
            set(h_occ, 'LineWidth', 1);
            set(her_occ, 'LineWidth', 1);
            line(xlim,[21.5 21.5],'Color','k','LineStyle','--','LineWidth',1);
            ylabel('% time');
            ylim([0 100])   
            title('Post-tests')
        
        for itrial=1:2    
            subplot(3,6,itrial+6)    
                area(trajzone_pre_ratio{i,itrial}*100)
                ylim([0 100])
                xlim([1 size(trajzone_pre_ratio{i,itrial},1)])
                title(['Trial #' num2str(itrial)])
                if itrial==1
                    xlabel('time')
                    ylabel('% of occupancy')
                    axP = get(gca,'Position');
                     
                    legend({'Stim','Stim-Near','Stim-Far',...
                        'Center','NoStim-Far','NoStim-Near','NoStim'},'Location','WestOutside')
                    set(gca, 'Position', axP)
                end
            
            subplot(3,6,itrial+12)    
                area(trajzone_pre_ratio{i,itrial+2}*100)
                ylabel('% of occupancy')
                ylim([0 100])
                xlim([1 size(trajzone_pre_ratio{i,itrial+2},1)])
                title(['Trial #' num2str(itrial+2)])
                if itrial==1
                xlabel('time')
                    ylabel('% of occupancy')
                end
             
               
            subplot(3,6,itrial+10)    
                area(trajzone_post_ratio{i,itrial}*100)
                ylim([0 100])
                xlim([1 size(trajzone_post_ratio{i,itrial},1)])
                title(['Trial #' num2str(itrial)])
            
            subplot(3,6,itrial+16)    
                area(trajzone_post_ratio{i,itrial+2}*100)
                ylim([0 100])
                xlim([1 size(trajzone_post_ratio{i,itrial+2},1)])
                title(['Trial #' num2str(itrial+2)])
         end
    
          % Supertitle
        mtit(supertit, 'fontsize',14, 'xoff', 0, 'yoff', 0.05);

        if sav
            print([dir_out 'Behav_pertrial_cumul_'  num2str(Mice_to_analyze(i))], '-dpng', '-r300');
        end
end
fh = figure('units', 'normalized', 'outerposition', [0 0 0.85 0.65]);
    maze = [0.04 0.05; 0.35 0.05; 0.35 0.8; 0.65 0.8; 0.65 0.05; 0.95 0.05; 0.95 0.97; 0.04 0.97; 0.04 0.05];
    xmaze = maze(:,1)*101;
    ymaze = maze(:,2)*101;

    BW = poly2mask(xmaze, ymaze, 101,101);
    BW = double(BW);
    BW(find(BW==0))=Inf;
    subplot(1,2,1)
        toplot = (log(OccupMap_pre)/sum(sum(OccupMap_pre)))';
        imagesc(yy,xx,toplot.*BW)
        %     imagesc(yy,xx,toplot)
%         colormap hot
        colormap(inferno)
        axis xy
        set(gca,'XTick',[],'YTick',[])
        caxis([-1.3 -0.4])
        hold on
        plot(maze(:,1),maze(:,2),'w','LineWidth',5)
        title('Pre', 'FontWeight','bold','FontSize',18)
    
    subplot(1,2,2)
        toplot = (log(OccupMap_post)/sum(sum(OccupMap_post)))';
        imagesc(yy,xx,toplot.*BW)
        %     imagesc(yy,xx,toplot)
        colormap hot
    %     colormap(inferno)
        axis xy
        set(gca,'XTick',[],'YTick',[])
        caxis([-1.3 -0.4])
        hold on
        plot(maze(:,1),maze(:,2),'w','LineWidth',5)
        title('Post', 'FontWeight','bold','FontSize',18)


% calculate occupancy means
x_pre_mean = squeeze(mean(mean(x_pre,1)));
y_pre_mean = squeeze(mean(mean(y_pre,1)));
occHS_pre_mean = squeeze(mean(mean(occHS_pre,1)));
x_post_mean = squeeze(mean(mean(x_post,1)));
y_post_mean = squeeze(mean(mean(y_post,1)));
occHS_post_mean = squeeze(mean(mean(occHS_post,1)));


figure('Color',[1 1 1], 'render','painters','position',[10 10 1700 1000])
    % occupancy
    subplot(1,3,1)
        % --- image
        imagesc(x_pre_mean,y_pre_mean,flip(squeeze(occHS_pre_mean))) 
        caxis([0 .04]) % control color intensity here
        colormap(hot)
        axis off
        set(gca, 'XTickLabel', []);
        set(gca, 'YTickLabel', []);
        t_str = {'PRE-TESTS'};
        title(t_str, 'FontSize', 14, 'interpreter','latex',...
         'HorizontalAlignment', 'center');
     
    subplot(1,3,3)
        % --- image
        imagesc(x_post_mean,y_post_mean,flip(squeeze(occHS_post_mean)))
        caxis([0 .04]) % control color intensity here
        colormap(hot)
        axis off
        set(gca, 'XTickLabel', []);
        set(gca, 'YTickLabel', []);
        t_str = {'POST-TESTS'};
        title(t_str, 'FontSize', 14, 'interpreter','latex',...
         'HorizontalAlignment', 'center'); 






%% Plot

% FIGURE 1 - Trajectories per mouse

    supertit = 'Post-test trajectories per trial';
    figure('Color',[1 1 1], 'rend','painters','pos',[1 1 2000 1000],'Name', supertit, 'NumberTitle','off')
        for itrial=1:4
            subplot(2,4,itrial) 
                for i=1:length(a)
                    % -- trajectories    
                    p1(i) = plot(Data(a{i}.behavResources(id_Post{i}(itrial)).AlignedXtsd),...
                        Data(a{i}.behavResources(id_Post{i}(itrial)).AlignedYtsd),...
                             'linewidth',1.5);  
                    hold on
                        tempX = Data(a{i}.behavResources(id_Post{i}(itrial)).AlignedXtsd);
                        tempY = Data(a{i}.behavResources(id_Post{i}(itrial)).AlignedYtsd);
                        plot(tempX(a{i}.behavResources(id_Post{i}(itrial)).PosMat(:,4)==1),tempY(a{i}.behavResources(id_Post{i}(itrial)).PosMat(:,4)==1),...
                            'p','Color','k','MarkerFaceColor','g','MarkerSize',16);
                        clear tempX tempY
                    axis off

                    xlim([0 1])
                    ylim([0 1])
                    title(['Trial #' num2str(itrial)])
                    % constructing the u maze
                    f_draw_umaze 
                    if itrial == 1 && i== length(a)
                        axP = get(gca,'Position');
                        lg = legend(p1([1]),mice_str,'Location','WestOutside');
                        title(lg,'Mice')
                        set(gca, 'Position', axP)
                    end
                end
                

            subplot(2,4,itrial+4)

                [p_occ,h_occ, her_occ] = PlotErrorBarN_SL([Post_Occup_stim(:,itrial)*100 Post_Occup_nostim(:,itrial)*100],...
                    'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'paired',0, 'colorpoints',1);
                h_occ.FaceColor = 'flat';
                h_occ.CData(2,:) = [1 1 1];
                set(gca,'Xtick',[1:2],'XtickLabel',{' Stim \newline zone ', ' No-stim \newline zone '});
                set(gca, 'FontSize', 14);
                set(gca, 'LineWidth', 1);
                set(h_occ, 'LineWidth', 1);
                set(her_occ, 'LineWidth', 1);
                ylabel('% time');
                ylim([0 100])    
        end
        
        if sav
            print([dir_out 'Behav_per_Post_Trial'], '-dpng', '-r300');
        end
        
    
%% Trajectories, barplot (stim/no-stim)    
    
for i=1:length(a )
    supertit = ['Mouse ' num2str(Mice_to_analyze(i))  ' - Trajectories'];
    figure('Color',[1 1 1], 'rend','painters','pos',[1 1 2000 1200],'Name', supertit, 'NumberTitle','off')

        subplot(3,3,1) 
            for k=1:4    
                % -- trajectories    
                p1(k) = plot(Data(a{i}.behavResources(id_Pre{i}(k)).AlignedXtsd),...
                    Data(a{i}.behavResources(id_Pre{i}(k)).AlignedYtsd),...
                         'linewidth',.5);  
                hold on
                tempX = Data(a{i}.behavResources(id_Pre{i}(k)).AlignedXtsd);
                tempY = Data(a{i}.behavResources(id_Pre{i}(k)).AlignedYtsd);
                plot(tempX(a{i}.behavResources(id_Pre{i}(k)).PosMat(:,4)==1),tempY(a{i}.behavResources(id_Pre{i}(k)).PosMat(:,4)==1),...
                    'p','Color','k','MarkerFaceColor','g','MarkerSize',16);
                clear tempX tempY
            end
            axis off
            xlim([0 1])
            ylim([0 1])
            title('Pre-tests')
            % constructing the u maze
            f_draw_umaze
            %legend
            axP = get(gca,'Position');
            lg = legend(p1([1 2 3 4]),'1','2','3','4','Location','WestOutside');
            title(lg,'Trial #')
            set(gca, 'Position', axP)
        
            
        subplot(3,3,3) 
            for k=1:4   
                % -- trajectories    
                p3(k) = plot(Data(a{i}.behavResources(id_Post{i}(k)).AlignedXtsd),...
                    Data(a{i}.behavResources(id_Post{i}(k)).AlignedYtsd),...
                         'linewidth',.5);  
                hold on
                tempX = Data(a{i}.behavResources(id_Post{i}(k)).AlignedXtsd);
                tempY = Data(a{i}.behavResources(id_Post{i}(k)).AlignedYtsd);
                plot(tempX(a{i}.behavResources(id_Post{i}(k)).PosMat(:,4)==1),tempY(a{i}.behavResources(id_Post{i}(k)).PosMat(:,4)==1),...
                    'p','Color','k','MarkerFaceColor','g','MarkerSize',16);
                clear tempX tempY
            end
            axis off
            xlim([0 1])    
            ylim([0 1])
            title('Post-tests')   
            % constructing the u maze
            f_draw_umaze

        
        subplot(3,3,4)
            [p_occ,h_occ, her_occ] = PlotErrorBarN_DB([squeeze(Pre_Occup(i,:,1))'*100 squeeze(Pre_Occup(i,:,2))'*100],...
                'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'showpoints',0);
            h_occ.FaceColor = 'flat';
            h_occ.CData(2,:) = [1 1 1];
            set(gca,'Xtick',[1:2],'XtickLabel',{' Stim \newline zone ', ' No-stim \newline zone '});
            set(gca, 'FontSize', 14);
            set(gca, 'LineWidth', 1);
            set(h_occ, 'LineWidth', 1);
            set(her_occ, 'LineWidth', 1);
            line(xlim,[21.5 21.5],'Color','k','LineStyle','--','LineWidth',1);
            ylabel('% time');
            ylim([0 100])
            
        subplot(3,3,6)
            [p_occ,h_occ, her_occ] = PlotErrorBarN_DB([squeeze(Post_Occup(i,:,1))'*100 squeeze(Post_Occup(i,:,2))'*100],...
                'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'showpoints',0);
            h_occ.FaceColor = 'flat';
            h_occ.CData(2,:) = [1 1 1];
            set(gca,'Xtick',[1:2],'XtickLabel',{' Stim \newline zone ', ' No-stim \newline zone '});
            set(gca, 'FontSize', 14);
            set(gca, 'LineWidth', 1);
            set(h_occ, 'LineWidth', 1);
            set(her_occ, 'LineWidth', 1);
            line(xlim,[21.5 21.5],'Color','k','LineStyle','--','LineWidth',1);
            ylabel('% time');
            ylim([0 100])
        
        % prepare data visualization (stim, nostim for each trial in the same vector)   
%         datpre = nan(8);
%         datpost = nan(8);
        itrial=1;
        for ii=1:3:10
            datpre(ii) = squeeze(Pre_Occup(i,itrial,1));
            datpre(ii+1) = squeeze(Pre_Occup(i,itrial,2));
            datpre(ii+2) = nan;
            datpost(ii) = squeeze(Post_Occup(i,itrial,1));
            datpost(ii+1) = squeeze(Post_Occup(i,itrial,2));
            datpost(ii+2) = nan;
            itrial=itrial+1;
        end
        
        subplot(3,3,7)
            [p_occ,h_occ, her_occ] = PlotErrorBarN_DB(datpre*100,...
                'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'showpoints',0);
            h_occ.FaceColor = 'flat';
            h_occ.CData([2 5 8 11],:) = repmat([1 1 1],4,1);
            set(gca,'Xtick',[1:12],'XtickLabel',{'','trial 1','','','trial 2','','',...
                    'trial 3','','','trial 4',''});
            set(gca, 'FontSize', 14);
            set(gca, 'LineWidth', 1);
            set(h_occ, 'LineWidth', 1);
            set(her_occ, 'LineWidth', 1);
            line(xlim,[21.5 21.5],'Color','k','LineStyle','--','LineWidth',1);
            ylabel('% time');
            ylim([0 100])
            
        subplot(3,3,9)
            [p_occ,h_occ, her_occ] = PlotErrorBarN_DB(datpost*100,...
                'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'showpoints',0);
            h_occ.FaceColor = 'flat';
            h_occ.CData([2 5 8 11],:) = repmat([1 1 1],4,1);
            set(gca,'Xtick',[1:12],'XtickLabel',{'','trial 1','','','trial 2','','',...
                    'trial 3','','','trial 4',''});
            set(gca, 'FontSize', 14);
            set(gca, 'LineWidth', 1);
            set(h_occ, 'LineWidth', 1);
            set(her_occ, 'LineWidth', 1);
            line(xlim,[21.5 21.5],'Color','k','LineStyle','--','LineWidth',1);
            ylabel('% time');
            ylim([0 100])            
            
        % Supertitle
        mtit(supertit, 'fontsize',14, 'xoff', 0, 'yoff', 0.05);

        if sav
            print([dir_out 'Behav_Trajectories_'  num2str(Mice_to_analyze(i))], '-dpng', '-r300');
        end
end % loop mice





% Axes
fh = figure('units', 'normalized', 'outerposition', [0 0 0.65 0.65]);
    Occupancy_Axes = axes('position', [0.07 0.55 0.41 0.41]);
    NumEntr_Axes = axes('position', [0.55 0.55 0.41 0.41]);
    First_Axes = axes('position', [0.07 0.05 0.41 0.41]);
    Speed_Axes = axes('position', [0.55 0.05 0.41 0.41]);

    % Occupancy
    axes(Occupancy_Axes);
    [p_occ,h_occ, her_occ] = PlotErrorBarN_SL([Pre_Occup_stim_mean*100 Post_Occup_stim_mean*100],...
        'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'colorPoints',1);
    h_occ.FaceColor = 'flat';
    h_occ.CData(2,:) = [1 1 1];
    set(gca,'Xtick',[1:2],'XtickLabel',{'PreTest', 'PostTest'});
    set(gca, 'FontSize', 12);
    set(gca, 'LineWidth', 1);
    set(h_occ, 'LineWidth', 1);
    set(her_occ, 'LineWidth', 1);
    line(xlim,[21.5 21.5],'Color','k','LineStyle','--','LineWidth',1);
    text(1.85,23.2,'Random Occupancy','FontSize',10);
    ylabel('% time');
    title('Occupancy in rewarded zone', 'FontSize', 14);
    ylim([0 70])

    axes(NumEntr_Axes);
    [p_nent,h_nent, her_nent] = PlotErrorBarN_SL([Pre_entnum_mean Post_entnum_mean],...
        'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'colorPoints',1);
    h_nent.FaceColor = 'flat';
    h_nent.CData(2,:) = [1 1 1];
    set(gca,'Xtick',[1:2],'XtickLabel',{'PreTest', 'PostTest'});
    set(gca, 'FontSize', 12);
    set(gca, 'LineWidth', 1);
    set(h_nent, 'LineWidth', 1);
    set(her_nent, 'LineWidth', 1);
    ylabel('Number of entries');
    title('# of entries to the rewarded zone', 'FontSize', 14);
    ylim([0 5])

    axes(First_Axes);
    [p_first,h_first, her_first] = PlotErrorBarN_SL([Pre_FirstTime_mean Post_FirstTime_mean],...
        'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'colorPoints',1);
    h_first.FaceColor = 'flat';
    h_first.CData(2,:) = [1 1 1];
    set(gca,'Xtick',[1:2],'XtickLabel',{'PreTest', 'PostTest'});
    set(gca, 'FontSize', 12);
    set(gca, 'LineWidth', 1);
    set(h_first, 'LineWidth', 1);
    set(her_first, 'LineWidth', 1);
    ylabel('Time (s)');
    title('First time to enter the reward zone', 'FontSize', 14);

    axes(Speed_Axes);
    [p_speed,h_speed, her_speed] = PlotErrorBarN_SL([Pre_VZmean_mean Post_VZmean_mean],...
        'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'colorPoints',1);
    h_speed.FaceColor = 'flat';
    h_speed.CData(2,:) = [1 1 1];
    set(gca,'Xtick',[1:2],'XtickLabel',{'PreTest', 'PostTest'});
    set(gca, 'FontSize', 12);
    set(gca, 'LineWidth', 1);
    set(h_speed, 'LineWidth', 1);
    set(her_speed, 'LineWidth', 1);
    ylabel('Speed (cm/s)');
    title('Average speed in the reward zone', 'FontSize', 14);
    ylim([0 5])

    %% Save it
    if sav
        print([dir_out 'general_basic_stats'], '-dpng', '-r300');
    end


figure('Color',[1 1 1], 'render','painters','position',[10 10 1700 1000])
%     % occupancy
%     subplot(2,2,1)
%         % --- image
%         imagesc(x_pre_mean,y_pre_mean,squeeze(occHS_pre_mean)) 
%         caxis([0 .015]) % control color intensity here
%         colormap(hot)
%         set(gca, 'XTickLabel', []);
%         set(gca, 'YTickLabel', []);
%         t_str = {'PRE-TESTS'};
%         title(t_str, 'FontSize', 14, 'interpreter','latex',...
%          'HorizontalAlignment', 'center');
% 
%     subplot(2,2,2)
%         % --- image
%         imagesc(x_post_mean,y_post_mean,squeeze(occHS_post_mean)) 
%         caxis([0 .015]) % control color intensity here
%         colormap(hot)
%         set(gca, 'XTickLabel', []);
%         set(gca, 'YTickLabel', []);
%         t_str = {'POST-TESTS'};
%         title(t_str, 'FontSize', 14, 'interpreter','latex',...
%          'HorizontalAlignment', 'center'); 
    
%     % Trajectories pre and post from one single mouse
%     subplot(2,3,1) 
%         for k=1:4    
%             % -- trajectories    
%             p1 = plot(Data(a{2}.behavResources(id_Pre{2}(k)).AlignedXtsd),...
%                 Data(a{2}.behavResources(id_Pre{2}(k)).AlignedYtsd),...
%                      'linewidth',1.5);  
% 
%             hold on 
%         end
%         axis off
%         xlim([0 1])
%         ylim([0 1])
%         t_str = {'PRE-TESTS (4x2 min)'};
%         title(t_str, 'FontSize', 15, 'interpreter','latex',...
%             'HorizontalAlignment', 'center');
%         f_draw_umaze
% 
%         
%     subplot(2,3,3) 
%         for k=1:4   
%             % -- trajectories    
%             p3(k) = plot(Data(a{2}.behavResources(id_Post{2}(k)).AlignedXtsd),...
%                 Data(a{2}.behavResources(id_Post{2}(k)).AlignedYtsd),...
%                     'linewidth',1.5);  
%             box off
%             hold on 
%         end
%         
%         
%         axis off
%         xlim([0 1])    
%         ylim([0 1])
%         t_str = {'POST-TESTS (4x2 min)'};
%         title(t_str, 'FontSize', 15, 'interpreter','latex',...
%             'HorizontalAlignment', 'center'); 
%         f_draw_umaze    
%         axP = get(gca,'Position');
%         lg = legend(p3([1 2 3 4]),'1','2','3','4','Location','EastOutside');
%         title(lg,'Trial #')
%         set(gca, 'Position', axP)
% 
%     % Barplot mean occupancies (pre vs post) in stim vs no-stim zones
%     
%     subplot(2,3,4)
%         [p_occ,h_occ, her_occ] = PlotErrorBarN_DB([Pre_Occup_stim_mean*100 Pre_Occup_nostim_mean*100], 'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'showpoints',0);
%         h_occ.FaceColor = 'flat';
%         h_occ.CData(2,:) = [1 1 1];
%         set(gca,'Xtick',[1:2],'XtickLabel',{' Stim \newline zone ', ' No-stim \newline zone '});
%         set(gca, 'FontSize', 14);
%         set(gca, 'LineWidth', 1);
%         set(h_occ, 'LineWidth', 1);
%         set(her_occ, 'LineWidth', 1);
%         ylabel('% time');
%         ylim([0 100])
%         %title
% %         t_str = {'PRE-TESTS';'Mean occupancy in the';'stimulated VS non-stimulated zone'};
% 
% 
%     subplot(2,3,6)
%         [p_occ,h_occ, her_occ] = PlotErrorBarN_DB([Post_Occup_stim_mean*100 Post_Occup_nostim_mean*100],...
%             'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'showpoints',0);
%         h_occ.FaceColor = 'flat';
%         h_occ.CData(2,:) = [1 1 1];
%         set(gca,'Xtick',[1:2],'XtickLabel',{' Stim \newline zone ', ' No-stim \newline zone '});
%         set(gca, 'FontSize', 14);
%         set(gca, 'LineWidth', 1);
%         set(h_occ, 'LineWidth', 1);
%         set(her_occ, 'LineWidth', 1);
%         ylabel('% time');
%         ylim([0 100])    
% 
%           
% %     set global title
% %     mtit('Mean occupancy in the stimulated VS non-stimulated zone', 'fontsize',14,'xoff',0,'yoff',.1) 
% %     annotation('textbox', [.46, .67, .2, .3], 'string', 'TRAJECTORIES',...
% %         'FitBoxToText','on','interpreter','latex', 'FontSize',18,'EdgeColor','none') 
% %     
% %     annotation('textbox', [.42, .2, .2, .3], 'string', 'AVERAGED OCCUPANCY',...
% %         'FitBoxToText','on','interpreter','latex', 'FontSize',18,'EdgeColor','none') 
% 
%     text(-9, 185, {'TRAJECTORIES'},'Rotation',90,'FontSize',18,...
%         'interpreter','latex','HorizontalAlignment', 'center','FontWeight','bold')
%     text(-9, 55, {'AVERAGE'; 'OCCUPANCY'},'Rotation',90,'FontSize',18,...
%         'interpreter','latex','HorizontalAlignment', 'center','FontWeight','bold')
%     
%     if sav
%         print([dir_out 'RewardVSNoReward_occupancy'], '-dpng', '-r300');
%     end
    
    
    function f_draw_umaze
        % constructing the u maze
        line([0 0],[0 1],'Color','black') % left outside arm
        line([1 1],[0 1],'Color','black') % right outside arm
        line([0 .35],[0 0],'Color','black') % bottom left outside
        line([.65 1],[0 0],'Color','black') % bottom right outside
        line([.35 .35],[0 .75],'Color','black') % left inside arm
        line([.65 .65],[0 .75],'Color','black') % right inside arm
        line([.35 .65],[.75 .75],'Color','black') % center inside arm
        line([0 1],[1 1],'Color','black') % up outside
        % stim zone
        line([0.001 0.001],[0.001 .35],'Color','green','LineWidth',1.5) % left stim
        line([.3495 .3495],[0.001 .35],'Color','green','LineWidth',1.5) % right stim
        line([.001 .3495],[0.001 .001],'Color','green','LineWidth',1.5) % top stim
        line([.001 .3495],[.35 .35],'Color','green','LineWidth',1.5) % bottom stim    
    end