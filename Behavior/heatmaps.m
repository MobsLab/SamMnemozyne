function heatmaps ()

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
%       - Lots of information is still hardcoded such as file directories
%       and some part about the orientation of the maze (2 options out of
%       4)
%       - At this point, t-tests are not corrected
%       - Part of this script was taken from OccupancyMapDB.m (the heatmap
%       generater
%       - Caution: there is two types of rotation. The first is a flip
%       (mirror) to orient the shock zone, the second is a pure rotation to
%       fit all the maps together
%
%   Written by Samuel Laventure - 23-10-2018
%==========================================================================

clear all
%% Parameters

% ---------- HARDCODED -----------

%bootsrapping options
    bts=1;      %bootstrap: 1 = yes; 0 = no
    draws=30;   %nbr of draws for the bts
    rnd=0;      %test against a random sampling of pre-post maps

%stats correction 
    alpha=.001; % p-value seeked for significance
        % only one must be chosen
        %----------
        fdr_corr=0;
        bonfholm=0;
        bonf=1;
        %----------
    corr = {'uncorr','fdr','bonfholm','bonf'};
%-------------------------------------
% Saving file    
    sav=0;      % Do you want to save a figure? Y=1; N=0
    dirout = '/home/mobs/Dropbox/MOBS_workingON/Sam/StimMFBWake/'; % Where to save?

% Numbers of mice to run analysis on
Mice_to_analyze = [936 941 934 935 863 913]; % MFBStimSleep

% Get directories
Dir = PathForExperimentsERC_SL('StimMFBWake');
Dir = RestrictPathForExperiment(Dir,'nMice', Mice_to_analyze);

%Nbr of trials per test
ntest = 4;

%Directories details
elec = {'AnteriorStim','PosteriorStim'};
ielec = [1 2 1 2 2 1 1 2 0 0 0 0 0 0];
room = [1 2 1 2 2 2 1 2 2 1 2 1 2 1 1 1 1 1 1 1 1 1 1 1 1 1];
sufDir = {'Pretests'; 'Cond'; 'Post48h'};
suf = {'pre'; 'Cond'; 'post48h'};
suf_db = {'TestPre'; 'TestPost'};

%Map parameter
freqVideo=15;       %frame rate
smo=3;            %smoothing factor
sizeMap=50;         %Map size
sizeMapx=240;         %Map size
sizeMapy=320;         %Map size

%Figures parameters
clrs = {'ko', 'bo', 'ro','go'; 'k','b', 'r', 'g'; 'kp', 'bp', 'rp', 'gp'};

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
    
end % loop mice
    
occup_pre_glob = sum(cat(3,occup_pre{:}),3);
occup_post_glob = sum(cat(3,occup_post{:}),3);
occup_pre_glob(occup_pre_glob==0) = nan;
occup_post_glob(occup_post_glob==0) = nan;


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
        % T-Test
        [h,p,ci,stats] = ttest2(bts_post,bts_pre);
    else
        ind_sel = randperm(7,7);
        rnd_sel(1:3,:,:) = occup_pre_arr(ind_sel(1:3),:,:);
        rnd_sel(4:7,:,:) = occup_post_arr(ind_sel(4:7),:,:);
        rnd_tmp = reshape(rnd_sel,length(a),[]);
        [bts_rnd_tmp btsam_rnd_tmp] = bootstrp(draws, @mean, rnd_tmp);
        bts_rnd = reshape(bts_rnd_tmp,draws,sizeMapy,sizeMapx); 
        [h,p,ci,stats] = ttest2(bts_post,bts_rnd);

    end
else
    % T-Test
    [h,p,ci,stats] = ttest(occup_post_arr,occup_pre_arr);

end


%FDR correction
if fdr_corr
    p_corr = mafdr(reshape(p,1,sizeMapy*sizeMapx));
    p_corr = reshape(p_corr,1,sizeMapy,sizeMapx);
    ind_p = find(p_corr<alpha);
    sig_pix(1,sizeMapy,sizeMapx) = zeros;
    sig_pix(ind_p) = 1;
    icorr=2;
elseif bonfholm
    [cor_p, h_bh]=bonf_holm(p,alpha);
    sig_pix=h_bh;
    icorr=3;
elseif bonf
    ind_p = find(p<(alpha/length(p)^2));
    sig_pix(1,sizeMapy,sizeMapx) = zeros;
    sig_pix(ind_p) = 1;
    icorr=4;
else
    sig_pix = h;
    icorr=1;
end
    
%---------------

tsig = stats.tstat.*sig_pix;

%% Plot figures    

% Activity figure
    
figure('Color',[1 1 1], 'rend','painters','pos',[10 10 600 1400])
    
    subplot(3,1,1), imagesc(occup_pre_glob), axis xy
    caxis([0 .1]);
    title('Global activity during pre-tests');
    colormap(gca,'jet')
    cb1=colorbar;
    set(gca,'xtick',[])
    set(gca,'ytick',[])
    hold on
    %add shapes & text
    f_draw_umaze
    
    
    
%Trajectories can't work on this form because data has been concatenated
    
%     subplot(6,1,2), 
% %     imagesc(Pre_mask),
%     axis xy
%     caxis([0 30]);
%     title('Trajectories during pre-tests');
%     hold on
%     for l=1:length(indir)
%         pl= plot(PreTest_PosMat{l}(:,2)*Pre_Ratio_IMAonREAL{l},PreTest_PosMat{l}(:,3)*Pre_Ratio_IMAonREAL{l},...
%             'linewidth',1.5)
%         hold on
%     end
%     set(gca, 'XTickLabel', []);
%     set(gca, 'YTickLabel', []);
    
    
    
    %freezeColors
    
    
    subplot(3,1,2), imagesc(occup_post_glob), axis xy
    caxis([0 .1]);
    title('Global activity during post-tests'); 
    colormap(gca,'jet')
    cb2=colorbar;
    set(gca,'xtick',[])
    set(gca,'ytick',[])    
    
    
    hold on
    %add shapes & text
    %text(7,10,'SHOCK ZONE', 'fontsize', 8, 'Color', 'r');
    f_draw_umaze
    
    
    
    
    
    
    %freezeColors
    
    subplot(3,1,3), imagesc(squeeze(tsig)), axis xy
    caxis([-1*max(max(squeeze(tsig))) max(max(squeeze(tsig)))]);
    title('Difference in activity post vs pre'); 
    
    set(gca,'xtick',[])
    set(gca,'ytick',[])
    colormap(gca, bluewhitered)
    cb3 = colorbar;
    
    hold on
    %add shapes & text
    f_draw_umaze
    
    % script name at bottom
    AddScriptName

    
    
    if sav
        if bts
            print([dirout 'GlobalActivityPost-Pre_bts_' corr{icorr} '_' num2str(alpha)], '-dpng', '-r300');
        else
            print([dirout 'GlobalActivityPost-Pre_' corr{icorr}], '-dpng', '-r300');
        end
    end
    
function f_draw_umaze
    rectangle('Position',[sizeMapx*.32 0 sizeMapx*.345 sizeMapy*.8], 'Linewidth', 2, 'FaceColor','k')
    rectangle('Position',[2 2 sizeMapx*.31 sizeMapy*.35], 'Linewidth', 1, 'EdgeColor','g') 
end
end
   