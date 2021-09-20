function [figH_ind figH] = BehaviorERC_wrapper(expe,Mice_to_analyze,fixtrial,recompute)
%BehaviorERC - Plot basic behavior comparisons of ERC experiment avergaed across mice.
%
% Plot occupance in the shock zone in the PreTests vs PostTests
% Plot number of entries in the shock zone in the PreTests vs PostTests
% Plot time to enter in the shock zone in the PreTests vs PostTests
% Plot average speed in the shock zone in the PreTests vs PostTests
% 
% 
%  OUTPUT: Figure
% 
%       2018 by Dmitri Bryzgalov
%       Modified by S. Laventure on 03/10/2019
%               - plot trajectories 
%               - can plot occupancy
%               - plot barplot of stim vs no stim
%       Modified by S. Laventure 28/02/20
%               - modify calculation and figures depending on conditionning
%               trial existence
%       See
%   
%       QuickCheckBehaviorERC, PathForExperimentERC_SL or Dima
%==========================================================================

%% DEFAULT Parameters
%-------------- CHOOSE FIGURE TO OUTPUT ----------
% per mouse
dirspeed = 1; %Trajectories with direction and speed analyses 
cumuloccup = 1; % Trajectories + barplot + zone dynamics 
firstentry = 1; % 1st entry barplot per mouse
trajoccup = 1; % trajectories and mean occupancy

globalspeed =0;
globalstats = 0; % global statistiques (not complete)
heatmaps = 0; % heatmaps all mice
traj_all = 0; %trajectories all mice
hmaps_occup = 0;
heatstat = 0;


%------------- FIGURE PARAMETERS -------------
clrs = {'ko', 'bo', 'ro','go', 'co', 'mo'; 'k','r','b','m','g','c'; 'kp', 'bp', 'rp', 'gp', 'cp', 'mp'};
figH_ind = [];
figH = [];

%------------- VAR INIT -------------
OccupMap_pre = zeros(101,101);
OccupMap_post = zeros(101,101);

%------------ HEATMAP COMPARE PARAMETERS-----------
%bootsrapping options
    bts=1;      %bootstrap: 1 = yes; 0 = no
    draws=40;   %nbr of draws for the bts
    rnd=0;      %test against a random sampling of pre-post maps
%stats correction 
    alpha=.0001; % p-value seeked for significance
        % only one must be chosen
        %----------
        fdr_corr=0;
        bonfholm=0;
        bonf=1;
        %----------
    corr = {'uncorr','fdr','bonfholm','bonf'};
% statisical analyses
wilc = 1;   %ranksum/wilcoxon
tt = 0;     %ttest2
%Map parameter
sizeMapx=240;         %Map size
sizeMapy=320;         %Map size
%Map reduction function
fun = @(block_struct) mean2(block_struct.data);


%% 
%###############################################
%           M A I N    S E C T I O N
%###############################################

%------------ GET DIRECTORIES---------------
% Dir = PathForExperimentsERC_SL(expe);
Dir = PathForExperimentsERC(expe);
Dir = RestrictPathForExperiment(Dir,'nMice', Mice_to_analyze);
%--------------- GET DATA-------------------
for i = 1:length(Dir.path)
    a{i} = load([Dir.path{i}{1} '/behavResources.mat'], 'behavResources');
end

%% Set cond sessions
if strcmp(expe,'StimMFBSleep')
    % cond happens during sleep // add any expe without cond session in umaze here
    cond=0;  
else
    cond=1;
end

%% Find indices of PreTests and PostTest and Cond session in the structure
id_Sess = cell(3,length(a));

for i=1:length(a)
    id_Sess{1,i} = FindSessionID_ERC(a{i}.behavResources, 'TestPre');
    id_Sess{2,i} = FindSessionID_ERC(a{i}.behavResources, 'TestPost');
    if cond
        id_Sess{3,i} = FindSessionID_ERC(a{i}.behavResources, 'Cond');
    end
    % set trials number
    if cond
        nbcond{i} = length(id_Sess{3,i});
    end
    if fixtrial
        id_Sess{1,i} = id_Sess{1,i}(1:4);
        id_Sess{3,i} = id_Sess{2,i}(1:4);
        nbprepost(i) = 4;
    else
        nbprepost(i) = length(id_Sess{1,i}); % pre and post should always be the same (correct this line if not)
    end
end

%% 
% ==============================================
%              O C C U P A N C Y
% ==============================================
disp('------------------------------------------')
DISP('OCCUPANCY:')
disp('  - Occupancy by zone-')
disp(' ')
% returns OccupZone.data(imouse,isess,itrial,izone) 
%         OccupZone.meanSess(isess,izone)
OccupZone = fZoneOccup(a,id_Sess,cond); 
disp('    Done.')

disp(' ')
disp('  - Occupancy by pixel-')
disp(' ')

% returns OccupPixel.img(imouse,isess,itrial,iy,ix) 
%         OccupPixel.x(imouse,isess,itrial)
%         OccupPixel.x(imouse,isess,itrial)
%         img_sessavg(imouse,isess,iy,ix)
OccupPixel = fPixelOccup(a,id_Sess,cond); 
disp('    Done.')

disp(' ')
disp('  - Cummulative occupancy (by zone)')
disp(' ')

OccupCumul = fCumulOccup(a,id_Sess,cond); 
disp('    Done.')


%% 
% ==============================================
%                 L A T E N C Y    
%            T O    S T I M    Z O N E
% ==============================================
disp(' ')
disp('------------------------------------------')
disp('LATENCY TO ENTER STIM ZONE')
disp(' ')

ZoneLatency = fLatencyToZone(a,id_Sess);
disp('    Done.')

%% 
% ==============================================
%         N U M B E R   O F   E N T R Y     
%         I N T O    S T I M    Z O N E
% ==============================================
disp(' ')
disp('------------------------------------------')
disp('NUMBER OF ENTRY INTO STIM ZONE')
disp(' ')

NumEntries = fNumEntries(a,id_Sess);
disp('    Done.')

%% 
% ==============================================
%               S P E E D   I N      
%         S T I M / N O - S T I M / A L L
% ==============================================
disp(' ')
disp('------------------------------------------')
disp('SPEED IN STIM vs NO-STIM vs (ALL-STIM)')
disp(' ')

Speed = fUMazeSpeed(a,id_Sess);
disp('    Done.')

%% 
% ==============================================       
%              D I R E C T I O N
%                    A N D
%                  S P E E D 
% ==============================================
disp(' ')
disp('------------------------------------------')
disp('DIRECTION AND SPEED')
disp(' ')

SpeedDir = fSpeedDir(a,id_Sess,cond);
disp('    Done.')


%% 
%###############################################
%        S E C T I O N    F I G U R E S 
%###############################################

%-------------------------------------------
%   I N D I V I D U A L    F I G U R E S
%-------------------------------------------
%   Trajectories direction and speed 
%-------------------------------------------
if dirspeed
    figH_ind.dirspeed = FigSpeedDir(SpeedDir,a,id_Sess,Mice_to_analyze,cond);
end
%-------------------------------------------
%   Trajectories + barplot + zone dynamics
if cumuloccup
    figH_ind.cumuloccup = FigCumulOccup(OccupCumul,OccupZone,a,id_Sess,Mice_to_analyze,cond);
end
%------------------------------------------
%   First entry - latency
if firstentry 
    figH_ind.firstentry = FigLatencyToZone(ZoneLatency.data,a,id_Sess,Mice_to_analyze);
end
%------------------------------------------
%   Trajectories and occupancy
if trajoccup    
    figH_ind.trajoccup = FigTrajOccup(OccupZone.data,a,id_Sess,Mice_to_analyze,cond);
end


%-----------------------------------------
%   G L O B A L    F I G U R E S 
%           (BY GROUPS)
%-----------------------------------------
%   GENERAL BASIC STATS
%-----------------------------------------
if globalstats
   figH.globalstats = FigTrajOccup(OccupZone.sessavg,NumEntries.sessavg,...
        squeeze(ZoneLatency.sessavg(:,:,1)),squeeze(Speed.sessavg(:,:,1))); 
end
%   SPEED BY DIRECTIONS
%-----------------------------------------
if globalspeed
    figH.dspeed = FigSpeedDir_global(SpeedDir.sessavg);
end
%   GLOBAL HEAT MAPS (PRE, COND, POST)
%-----------------------------------------
if heatmaps
    figH.heatmaps = FigHeatMaps_global(OccupPixel);
end
%   TRAJECTORIES ALL MICE
%-----------------------------------------
if traj_all
    figH.traj_all = FigPostTraj_global(OccupZone.data,a,id_Sess,Mice_to_analyze,cond);
end   
%   HEATMAPS - PRE VS POST
%-----------------------------------------
if hmaps_occup
    figH.hmaps_occup = FigHMaps_Occup_global(OccupPixel,OccupZone.sessavg);
end          
            

%% FIGURE OCCUPANCY
%--------------------------------------------------------------------------
%---------------------------HEATMAPS - STAT COMPARE------------------------
%--------------------------------------------------------------------------
if heatstat
    % downscale the resolution of the maps 
    xx = [16];  % factor of downscaling (if multiple inputed will create one figure for each
    xorg = sizeMapx;
    yorg = sizeMapy;
    pre = occup_pre_glob;
    post = occup_post_glob;
    cond = occup_cond_glob;
    for iloop=1:length(xx)
        occup_pre_arrred = [];
        occup_post_arrred = [];
        sizered = xx(iloop);
        sizeMapy = ceil(yorg/sizered);
        sizeMapx = ceil(xorg/sizered);
        occup_pre_glob = blockproc(pre,[sizered sizered],fun);
        occup_cond_glob = blockproc(cond,[sizered sizered],fun);
        occup_post_glob = blockproc(post,[sizered sizered],fun);
        for i=1:length(a)
            occup_pre_arrred(i,:,:) = blockproc(squeeze(occup_pre_arr(i,:,:)),[sizered sizered],fun);
            occup_post_arrred(i,:,:) = blockproc(squeeze(occup_post_arr(i,:,:)),[sizered sizered],fun);    
        end

        %% ------  STATISTIQUES
        if bts
            bts_pre_tmp = []; bts_pre=[];
            bts_post_tmp = []; bts_post=[];
            p=[]; zval=[];
            pre_tmp = reshape(occup_pre_arrred,length(a),[]);
            post_tmp = reshape(occup_post_arrred,length(a),[]);

            [bts_pre_tmp btsam_pre_tmp] = bootstrp(draws, @mean, pre_tmp);
            [bts_post_tmp btsam_post_tmp] = bootstrp(draws, @mean, post_tmp);

            bts_pre = reshape(bts_pre_tmp,draws,sizeMapy,sizeMapx);
            bts_post = reshape(bts_post_tmp,draws,sizeMapy,sizeMapx);

            %test with random sample
            if ~(rnd)

                if wilc
                    for ix=1:sizeMapx
                        for iy=1:sizeMapy
                            % ranksum - wilcoxon
                            [p(iy,ix),h,stats(iy,ix)] = ranksum(bts_post(:,iy,ix),bts_pre(:,iy,ix));
                            zval(iy,ix)=stats(iy,ix).zval;
        %                     stats = mwwtest(bts_post(:,iy,ix)',bts_pre(:,iy,ix)');
        %                     if stats.mr(1) < stats.mr(2)
        %                         stats.Zsign = stats.Z*-1;
        %                     else
        %                         stats.Zsign = stats.Z;
        %                     end
        %                     p(iy,ix) = stats.Zsign;
                        end
                    end
                elseif tt
                    % T-Test
                    [h,p,ci,stats] = ttest2(bts_post,bts_pre);
                end
            else
                ind_sel = randperm(length(Mice_to_analyze),length(Mice_to_analyze));
                rnd_sel(1:floor(length(Mice_to_analyze)/2),:,:) = occup_pre_arr(ind_sel(1:floor(length(Mice_to_analyze)/2)),:,:);
                rnd_sel(ceil(length(Mice_to_analyze)/2):length(Mice_to_analyze),:,:) = ...
                    occup_post_arr(ind_sel(ceil(length(Mice_to_analyze)/2)):length(Mice_to_analyze),:,:);
                rnd_tmp = reshape(rnd_sel,length(a),[]);
                [bts_rnd_tmp btsam_rnd_tmp] = bootstrp(draws, @mean, rnd_tmp);
                bts_rnd = reshape(bts_rnd_tmp,draws,sizeMapy,sizeMapx); 
                [h,p,ci,stats] = ttest2(bts_post,bts_rnd);

            end
        else
            if wilc
                % ranksum - wilcoxon
        %         [p,h,stats] = ranksum(bts_post_w,bts_pre_w);
            elseif tt
                % T-Test
                 [h,p,ci,stats] = ttest(occup_post_arr,occup_pre_arr);
            end

        end

        sig_pix = [];
        %Statistical correction
        if fdr_corr
            p_corr = mafdr(reshape(p,1,sizeMapy*sizeMapx));
            p_corr = reshape(p_corr,1,sizeMapy,sizeMapx);
            ind_p = find(p_corr<alpha);
            sig_pix(1,sizeMapy,sizeMapx) = zeros;caxis([0 .1]);
            sig_pix(ind_p) = 1;
            icorr=2;
        elseif bonfholm
            [cor_p, h_bh]=bonf_holm(p,alpha);
            sig_pix=h_bh;
            icorr=3;
        elseif bonf
        %     ind_p = find(p<(alpha/length(p)^2));
            ind_p = find(p<(alpha/((size(p,3)*size(p,2))-((sizeMapy*.75)*(sizeMapx*.342)))^2));   % alpha divided by the number of points SHOWN in the map
            sig_pix(1,sizeMapy,sizeMapx) = zeros;
            sig_pix(ind_p) = 1;
            icorr=4;
        else
            sig_pix = h;
            icorr=1;
        end

        %---------------
        if tt
            tsig = stats.tstat.*sig_pix;
        elseif wilc
            tsig = zval.*squeeze(sig_pix);
        end

        %% Plot figures    

        % Activity figure
        supertit = ['Occupancy by session: ' num2str(sizered) 'x' num2str(sizered) ' bins'];
        figH.heatstat = figure('Color',[1 1 1], 'rend','painters','pos',[10 10 1550 800],'Name',supertit)

            subplot(2,9,1:3), imagesc(occup_pre_glob), axis xy
                caxis([0 .15]);
                t_str = 'Pre-tests';
                title(t_str, 'FontSize', 13);
                colormap(gca,'hot')
        %         cb1=colorbar;
        %         cb1.Location = 'westoutside';
                set(gca,'xtick',[])
                set(gca,'ytick',[])
                hold on
                %add visuals
                f_draw_umaze2(sizeMapx,sizeMapy)

            subplot(2,9,4:6), imagesc(occup_cond_glob), axis xy
                caxis([0 .15]);
                t_str = 'Conditioning'; 
                title(t_str, 'FontSize',13);
                colormap(gca,'hot')
                set(gca,'xtick',[])
                set(gca,'ytick',[])  
                hold on
                %add visuals
                f_draw_umaze2(sizeMapx,sizeMapy)

            subplot(2,9,7:9), imagesc(occup_post_glob), axis xy
                caxis([0 .15]);
                t_str = 'Post-tests'; 
                title(t_str, 'FontSize', 13);
                colormap(gca,'hot')
                set(gca,'xtick',[])
                set(gca,'ytick',[])  
                hold on
                %add visuals
                f_draw_umaze2(sizeMapx,sizeMapy)


            subplot(2,9,11:13), imagesc(squeeze(tsig)), axis xy
                caxis([-1*max(max(squeeze(tsig))) max(max(squeeze(tsig)))]);
                t_str = {'Significant changes'; 'in occupancy post- vs pre-tests'}; 
                title(t_str, 'FontSize', 13);

                set(gca,'xtick',[])
                set(gca,'ytick',[])
                colormap(gca, bluewhitered)
        %         cb3 = colorbar;
                hold on
                %add visuals
                f_draw_umaze2(sizeMapx,sizeMapy)

                %*-------------
                % stim zone only
                %*-------------

    %          voidtmp = nan(5,1);    
    %         subplot(2,6,10:11)
    %             [p_occ,h_occ, her_occ] = PlotErrorBarN_DB([Pre_Occup_stim_mean*100  Cond_Occup_stim_mean*100 Post_Occup_stim_mean*100],...
    %                 'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'showpoints',0);
    %             set(gca,'Xtick',[1:3],'XtickLabel',{'Pre','Cond','Post',});
    %             set(gca, 'FontSize', 12);
    %             set(gca, 'LineWidth', 1);
    %             set(h_occ, 'LineWidth', 1);
    %             set(her_occ, 'LineWidth', 1);
    %             ylabel('% time');
    %             ylim([0 85])
    %             t_str = {'Time spent in stim zone by session'};
    %             title(t_str, 'FontSize', 14, 'interpreter','latex',...
    %              'HorizontalAlignment', 'center'); 

                %*-------------
                % stim + no-stim zones
                %*-------------

            voidtmp = nan(length(Dir.path),1);    
            subplot(2,9,15:17)
                [p_occ,h_occ, her_occ] = PlotErrorBarN_DB([Pre_Occup_stim_mean*100 Pre_Occup_nostim_mean*100 voidtmp  Cond_Occup_stim_mean*100 Cond_Occup_nostim_mean*100 voidtmp Post_Occup_stim_mean*100 Post_Occup_nostim_mean*100],...
                    'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'showpoints',0);
                set(gca,'Xtick',[1:8],'XtickLabel',{'        Pre', '','',...
                    '        Cond', '','', ...
                    '        Post', ''});
                h_occ.FaceColor = 'flat';
                h_occ.CData(2,:) = [1 1 1];
                h_occ.CData(5,:) = [1 1 1];
                h_occ.CData(8,:) = [1 1 1];
                set(gca, 'FontSize', 12);
                set(gca, 'LineWidth', 1);
                set(h_occ, 'LineWidth', 1);
                set(her_occ, 'LineWidth', 1);
                ylabel('% time');
                ylim([0 115])
                t_str = {'Time spent in zones by session'};
                title(t_str, 'FontSize', 14); 
                % creating legend with hidden-fake data (hugly but effective)
                    b2=bar([-2],[ 1],'FaceColor','flat');
                    b1=bar([-3],[ 1],'FaceColor','flat');
                    b1.CData(1,:) = repmat([0 0 0],1);
                    b2.CData(1,:) = repmat([1 1 1],1);
                    legend([b1 b2],{'Stim','No-stim'},'Location','EastOutside')
                makepretty_erc
    end
end


    
    

%% 
%==========================================================================
%                               FUNCTIONS
%==========================================================================

% DRAWING UMAZE SHAPE
function f_draw_umaze
    % constructing the u maze
    line([0 0],[0 1.05],'Color','black','LineWidth',2) % left outside arm
    line([1 1],[0 1.05],'Color','black','LineWidth',2) % right outside arm
    line([0 .375],[0 0],'Color','black','LineWidth',2) % bottom left outside
    line([.625 1],[0 0],'Color','black','LineWidth',2) % bottom right outside
    line([.375 .375],[0 .75],'Color','black','LineWidth',2) % left inside arm
    line([.625 .625],[0 .75],'Color','black','LineWidth',2) % right inside arm
    line([.375 .625],[.75 .75],'Color','black','LineWidth',2) % center inside arm
    line([0 1],[1.05 1.05],'Color','black','LineWidth',2) % up outside
    % stim zone
    line([-.01 -.01],[-.01 .385],'Color','green','LineWidth',1.5) % left stim
    line([.376 .376],[-.01 .385],'Color','green','LineWidth',1.5) % right stim
    line([-.01 .385],[-.01 -.01],'Color','green','LineWidth',1.5) % top stim
    line([-.01 .385],[.385 .385],'Color','green','LineWidth',1.5) % bottom stim    
end

%DRAWING ZONES IN PLOT
function f_draw_zones(trial_data, nzones)
    defaultcolors = get(gca,'colororder');
    if nzones == 5
        rectangle('Position',[0,0,length(trial_data),.2],'FaceColor',defaultcolors(1,1:3),'LineStyle','none')
        rectangle('Position',[0,.2,length(trial_data),.25],'FaceColor',defaultcolors(2,1:3),'LineStyle','none')
        rectangle('Position',[0,.45,length(trial_data),.1],'FaceColor',defaultcolors(3,1:3),'LineStyle','none')
        rectangle('Position',[0,.55,length(trial_data),.25],'FaceColor',defaultcolors(4,1:3),'LineStyle','none')
        rectangle('Position',[0,.80,length(trial_data),.2],'FaceColor',defaultcolors(5,1:3),'LineStyle','none')
    elseif nzones == 7
        rectangle('Position',[0,0,length(trial_data),.2],'FaceColor',defaultcolors(1,1:3),'LineStyle','none')
        rectangle('Position',[0,.2,length(trial_data),.14],'FaceColor',defaultcolors(2,1:3),'LineStyle','none')
        rectangle('Position',[0,.34,length(trial_data),.11],'FaceColor',defaultcolors(3,1:3),'LineStyle','none')
        rectangle('Position',[0,.45,length(trial_data),.1],'FaceColor',defaultcolors(4,1:3),'LineStyle','none')
        rectangle('Position',[0,.55,length(trial_data),.11],'FaceColor',defaultcolors(5,1:3),'LineStyle','none')
        rectangle('Position',[0,.66,length(trial_data),.14],'FaceColor',defaultcolors(6,1:3),'LineStyle','none')
        rectangle('Position',[0,.80,length(trial_data),.2],'FaceColor',defaultcolors(7,1:3),'LineStyle','none')
    end
end

function f_draw_umaze2(sizeMapx,sizeMapy)
%     rectangle('Position',[sizeMapx*.34 0 sizeMapx*.342 sizeMapy*.75], 'Linewidth', 1, 'FaceColor','w')
%     rectangle('Position',[1.5 1.5 sizeMapx*.33 sizeMapy*.35], 'Linewidth', 1, 'EdgeColor','g') 

    % the following code adapt the maze boundaries to a 320 x 240 map or
    % similar x/y ratio
    
    rectangle('Position',[sizeMapx*((1/sizeMapx)*ceil(.32*sizeMapx))+.5 0 ...
        sizeMapx*((1/sizeMapx)*floor(.342*sizeMapx)) sizeMapy*((1/sizeMapy)*ceil(.7*sizeMapy))+.5], 'Linewidth', 1, 'FaceColor','w')
    rectangle('Position',[0 0 sizeMapx*((1/sizeMapx)*ceil(.32*sizeMapx))+.5 sizeMapy*((1/sizeMapy)*ceil(.35*sizeMapy))+.5], 'Linewidth', 1, 'EdgeColor','g') 
end    

end