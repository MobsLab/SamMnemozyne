function heatmaps_compare ()

%==========================================================================
% Details: this function (still in script format), returns a figure showing
% heat maps of activity during pretests and postests. It also return a
% third subplot showing significant changes in activity in the U-Maze.
%
% INPUTS:
%       - None yet
%
% OUTPUT:
%       - Heatmaps of activity (see above) and difference.
%
% NOTES:
%       - Has to be used with n >= 2 subjects
%       - Lots of information is still hardcoded such as file directories
%       - Part of this script was taken from OccupancyMapDB.m (the heatmap
%       generater
%
%   Written by Samuel Laventure - 23-10-2018
%==========================================================================

clear all
%% Parameters

% ---------- HARDCODED -----------

% exp name
exp_name='StimMFBWake';

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

%-------------------------------------
% Saving file    
    sav=1;      % Do you want to save a figure? Y=1; N=0
    dirout = [dropbox '/DataSL/' exp_name '/Behavior/' date '/']; % Where to save?
    %set folders
    if ~exist(dirout,'dir')
        mkdir(dirout);
    end
    
% Numbers of mice to run analysis on
% Mice_to_analyze = [936 941 934 935 863 913]; % MFBStimSleep
Mice_to_analyze = [882 941 934 863 913]; % MFBStimWake
% Mice_to_analyze = [936];

% Get directories
Dir = PathForExperimentsERC_SL_home(exp_name);
Dir = RestrictPathForExperiment(Dir,'nMice', Mice_to_analyze);

%Nbr of trials per test
ntest = 4;

%Map parameter
freqVideo=15;       %frame rate
smo=4;            %smoothing factor
sizeMap=50;         %Map size
sizeMapx=240;         %Map size
sizeMapy=320;         %Map size

%Figures parameters
clrs = {'ko', 'bo', 'ro','go'; 'k','b', 'r', 'g'; 'kp', 'bp', 'rp', 'gp'};
set(0,'defaulttextinterpreter','latex');
set(0,'DefaultTextFontname', 'Arial')
set(0,'DefaultAxesFontName', 'Arial')
set(0,'defaultAxesFontSize',10)

%#####################################################################
%#
%#                           M A I N
%#
%#####################################################################

%% Get data

for i = 1:length(Dir.path)
    a{i} = load([Dir.path{i}{1} '/behavResources.mat'], 'behavResources');
end

%% Find indices of PreTests, PostTests and Cond sessions in the structure
id_Pre = cell(1,length(a));
id_Post = cell(1,length(a));
id_Cond = cell(1,length(a));

for i=1:length(a)
    id_Pre{i} = zeros(1,length(a{i}.behavResources));
    id_Post{i} = zeros(1,length(a{i}.behavResources));
    id_Cond{i} = zeros(1,length(a{i}.behavResources));
    for k=1:length(a{i}.behavResources)
        if ~isempty(strfind(a{i}.behavResources(k).SessionName,'TestPre'))
            id_Pre{i}(k) = 1;
        end
        if ~isempty(strfind(a{i}.behavResources(k).SessionName,'TestPost'))
            id_Post{i}(k) = 1;
        end
        if ~isempty(strfind(a{i}.behavResources(k).SessionName,'Cond'))
            id_Cond{i}(k) = 1;
        end
    end
    id_Pre{i}=find(id_Pre{i});
    id_Post{i}=find(id_Post{i});
    id_Cond{i}=find(id_Cond{i});
end


%% GET OCCUPANCY
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
    %Cond
    for k=1:length(id_Cond{i})
        [occH_Cond, x1, x2] = hist2(Data(a{i}.behavResources(id_Cond{i}(k)).AlignedXtsd),...
            Data(a{i}.behavResources(id_Cond{i}(k)).AlignedYtsd), 240, 320);
        occHS_Cond(i,k,1:320,1:240) = SmoothDec(occH_Cond/freqVideo,[smo,smo]); 
        x_Cond(i,k,1:240)=x1;
        y_Cond(i,k,1:320)=x2;
    end % loop nb sess  
    
    %for each mouse, keep 1 average map for pre and post tests
    occup_pre{i}=squeeze(mean(occHS_pre(i,:,:,:)));
    occup_pre_arr(i,1:sizeMapy,1:sizeMapx) = squeeze(mean(occHS_pre(i,:,:,:)));
    occup_post{i}=squeeze(mean(occHS_post(i,:,:,:)));
    occup_post_arr(i,1:sizeMapy,1:sizeMapx) = squeeze(mean(occHS_post(i,:,:,:)));
    occup_cond{i}=squeeze(mean(occHS_Cond(i,:,:,:)));
    occup_cond_arr(i,1:sizeMapy,1:sizeMapx) = squeeze(mean(occHS_Cond(i,:,:,:)));
    
    
end % loop mice
    
occup_pre_glob = sum(cat(3,occup_pre{:}),3);
occup_post_glob = sum(cat(3,occup_post{:}),3);
occup_cond_glob = sum(cat(3,occup_cond{:}),3);
occup_pre_glob(occup_pre_glob==0) = nan;
occup_post_glob(occup_post_glob==0) = nan;
occup_cond_glob(occup_cond_glob==0) = nan;

%% ------  STATISTIQUES
if bts
    pre_tmp = reshape(occup_pre_arr,length(a),[]);
    post_tmp = reshape(occup_post_arr,length(a),[]);

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


%Statistical correction
if fdr_corr
    p_corr = mafdr(reshape(p,1,sizeMapy*sizeMapx));
    p_corr = reshape(p_corr,1,sizeMapy,sizeMapx);
    ind_p = find(p_corr<alpha);
    sig_pix(1,sizeMapy,sizeMapx) = zeros;
    caxis([0 .1]);
    sig_pix(ind_p) = 1;
    icorr=2;
elseif bonfholm
    [cor_p, h_bh]=bonf_holm(p,alpha);
    sig_pix=h_bh;
    icorr=3;
elseif bonf
%     ind_p = find(p<(alpha/length(p)^2));
    ind_p = find(p<(alpha/((size(p,3)*size(p,2))-((320*.75)*(240*.342)))^2));   % alpha divided by the number of points SHOWN in the map
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
    
figure('Color',[1 1 1], 'rend','painters','pos',[10 10 2000 400])
    
    subplot(1,4,1), imagesc(occup_pre_glob), axis xy
        caxis([0 .08]);
        t_str = 'Pre-tests';
        title(t_str, 'FontSize', 13, 'interpreter','latex',...
                'HorizontalAlignment', 'center');
        colormap(gca,'hot')
%         cb1=colorbar;
%         cb1.Location = 'westoutside';
        set(gca,'xtick',[])
        set(gca,'ytick',[])
        hold on
        %add shapes & text
        f_draw_umaze
    
    subplot(1,4,2), imagesc(occup_cond_glob), axis xy
        caxis([0 .08]);
        t_str = 'Conditioning'; 
        title(t_str, 'FontSize', 13, 'interpreter','latex',...
                'HorizontalAlignment', 'center');
        colormap(gca,'hot')
        set(gca,'xtick',[])
        set(gca,'ytick',[])  
        hold on
        %add shapes & text
        f_draw_umaze
    
    subplot(1,4,3), imagesc(occup_post_glob), axis xy
        caxis([0 .08]);
        t_str = 'Post-tests'; 
        title(t_str, 'FontSize', 13, 'interpreter','latex',...
                'HorizontalAlignment', 'center');
        colormap(gca,'hot')
        set(gca,'xtick',[])
        set(gca,'ytick',[])  
        hold on
        %add shapes & text
        f_draw_umaze
    
    
    subplot(1,4,4), imagesc(squeeze(tsig)), axis xy
        caxis([-1*max(max(squeeze(tsig))) max(max(squeeze(tsig)))]);
        t_str = {'Significant changes'; 'in occupancy post- vs pre-tests'}; 
        title(t_str, 'FontSize', 13, 'interpreter','latex',...
                'HorizontalAlignment', 'center');

        set(gca,'xtick',[])
        set(gca,'ytick',[])
        colormap(gca, bluewhitered)
%         cb3 = colorbar;
        hold on
        %add shapes & text
        f_draw_umaze
    
%     % script name at bottom
%     AddScriptName

    
    if sav
        if bts
            if wilc
                print([dirout 'GlobalActivityPost-Pre_bts_' corr{icorr} '_ranksum'], '-dpng', '-r300');
            elseif tt
                print([dirout 'GlobalActivityPost-Pre_bts_' corr{icorr} '_ttest'], '-dpng', '-r300');
            end
        else
            print([dirout 'GlobalActivityPost-Pre_' corr{icorr}], '-dpng', '-r300');
        end
    end
    
function f_draw_umaze
    rectangle('Position',[sizeMapx*.34 0 sizeMapx*.342 sizeMapy*.75], 'Linewidth', 1, 'FaceColor','w')
    rectangle('Position',[2 2 sizeMapx*.33 sizeMapy*.35], 'Linewidth', 1, 'EdgeColor','g') 
end
end
   