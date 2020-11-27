function heatmap_globalexp_prepre ()

%==========================================================================
% Details: this function (still in script format), returns a figure showing
% heat maps of activity during the FIRST pretests VS the SECOND pretests. It also return a
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
%       - Part of this script was taken from OccupancyMapDB.m (the heatmap
%       generater
%       - Caution: there is two types of rotation. The first is a flip
%       (mirror) to orient the shock zone, the second is a pure rotation to
%       fit all the maps together
%
%   Written by Samuel Laventure - 15-11-2018
%==========================================================================

clear all
%% Parameters

% ---------- HARDCODED -----------

%bootsrapping options
    bts=1;      %bootstrap: 1 = yes; 0 = no
    draws=50;   %nbr of draws for the bts
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
%-------------------------------------
% Saving file    
    sav=0;      % Do you want to save a figure? Y=1; N=0
    dirout = '/home/mobs/Dropbox/MOBS_workingON/Sam/PAGTests/'; % Where to save?

% input folders

sd = 14;        % # of sam + dima's mice

indir1 = {
    %Sam's mice (n=8)
    '/media/DataMOBsRAIDN/ProjetPAGTest/M784/'; %post
    '/media/DataMOBsRAIDN/ProjetPAGTest/M789/'; %ant
    '/media/DataMOBsRAIDN/ProjetPAGTest/M792/';  %post
    %Dima's mice (n=7)
    '/media/DataMOBsRAIDN/ProjetPAGTest/Mouse-785/'; %ant
    '/media/DataMOBsRAIDN/ProjetPAGTest/Mouse-786/'; %post
    '/media/DataMOBsRAIDN/ProjetPAGTest/Mouse-787/'; %ant
    };

indir2 = {
    %Sam's mice (n=8)
    '/media/DataMOBsRAIDN/ProjetPAGTest/M784/'; %ant
    '/media/DataMOBsRAIDN/ProjetPAGTest/M789/'; %post
    '/media/DataMOBsRAIDN/ProjetPAGTest/M792/'; %ant
    
    %Dima's mice (n=7)
    '/media/DataMOBsRAIDN/ProjetPAGTest/Mouse-785/'; %post
    '/media/DataMOBsRAIDN/ProjetPAGTest/Mouse-786/'; %ant
    '/media/DataMOBsRAIDN/ProjetPAGTest/Mouse-787/'; %post
    };

%Exp day
Day3 = {
    %Sam's mice
    '19092018';
    '19092018';
    '19092018';
    %Dima's mice
    '11092018'
    '10092018';
    '11092018';
    };

%Post test (48h later)
Day4 = {
    '20092018';
    '20092018';
    '20092018';
    %Dima's mice (post-tests)
    '12092018';
    '12092018';
    '12092018';
    };

%Post test (48h later)
post = {
    '20092018';
    '20092018';
    '20092018';
    %Dima's mice (post-tests)
    '11092018';
    '12092018';
    '11092018';

    };


%Nbr of trials per test
ntest = 4;

%Directories details
elec = {'AnteriorStim','PosteriorStim'};
ielec1 = [2 1 2 0 0 0];
ielec2 = [1 2 1 0 0 0];
room1 = [2 1 2 2 2 2];
room2 = [1 2 1 1 1 1];
sufDir = {'Pretests'; 'Cond'; 'Post48h'};
suf = {'pre'; 'Cond'; 'post48h'};
suf_db = {'TestPre'; 'TestPost'};

%Map parameter
freqVideo=15;       %frame rate
smo=1.5;            %smoothing factor
sizeMap=50;         %Map size



%% Get trajectories
    % PreTests 1
for j=1:length(indir1)
    
    %% Get DATA
    try
        a{j} = load([indir1{j} Day3{j} '/' elec{ielec1(j)} '/' sufDir{1} '/behavResources.mat'], 'Xtsd', 'Ytsd', 'Zone');
    catch
        a{j} = load([indir1{j} Day3{j} '/' suf_db{1} '/behavResources.mat'], 'Xtsd', 'Ytsd', 'Zone');
    end
    
    %% Prepare data for mapping
    
    %GET PRETEST DATA
    [occH_pre, x1_pre, x2_pre] = hist2d(Data(a{j}.Xtsd), Data(a{j}.Ytsd), sizeMap, sizeMap);
    occHS_pre=SmoothDec(occH_pre/freqVideo,[smo,smo]); 

%     %find shock zone and change orientation
%     [dim1 dim2] = find(a{j}.Zone{1,1}==1);
%     if room1(j)==1 %(inversed U-shaped on screen)
%         if dim2(1)>160            
%             occHS_pre = flip(occHS_pre,2);          
%         end
%     else %(inversed C-shaped on screen)
%         if dim1(1)<120
%             occHS_pre = flip(occHS_pre);       
%         end    
%     end

    % rotating map if orientation is diff (from one room to the other)
    if room1(j)==2 
        occHS_pre = rot90(occHS_pre,3);
        x1_temp = x1_pre;
        x1_pre = x2_pre;
        x2_pre = x1_temp;
    end
    
    occup_pre_arr(j,1:sizeMap,1:sizeMap) = occHS_pre;
    occup_pre{j} = occHS_pre;   
end
    
% Pre-tests 2
for i=1:length(indir2)
    % PreTests 2
    try 
        c{i} = load([indir2{i} Day4{i} '/' elec{ielec2(i)} '/' sufDir{1} '/behavResources.mat'],'Xtsd', 'Ytsd','Zone');
    catch
        % Dima's post-test
        c{i} = load([indir2{i} Day4{i} '/' suf_db{1} '/behavResources.mat'],'Xtsd', 'Ytsd', 'Zone');
    end
        %% Prepare data for mapping

    %GET POSTTEST DATA
    [occH_post, x1_post, x2_post] = hist2d(Data(c{i}.Xtsd), Data(c{i}.Ytsd), sizeMap, sizeMap);
    occHS_post=SmoothDec(occH_post/freqVideo,[smo,smo]); 


    %find shock zone of last exp and change orientation
    [dim1 dim2] = find(a{i}.Zone{1,1}==1);
    if room2(i)==1 %(inversed U-shaped on screen)
        if dim2(1)>160            
            occHS_post = flip(occHS_post,2);            
        end
    else %(inversed C-shaped on screen)
        if dim1(1)<120
            occHS_post = flip(occHS_post);         
        end    
    end

    % rotating map if orientation is diff (from one room to the other)
    if room2(i)==2 
        occHS_post = rot90(occHS_post,3);
        x1_temp = x1_post;
        x1_post = x2_post;
        x2_post = x1_temp;
    end
    
    occup_post_arr(i,1:sizeMap,1:sizeMap) = occHS_post;
    occup_post{i} = occHS_post;
end

occup_pre_glob = sum(cat(3,occup_pre{:}),3);
occup_post_glob = sum(cat(3,occup_post{:}),3);
occup_pre_glob(occup_pre_glob==0) = nan;
occup_post_glob(occup_post_glob==0) = nan;


%% ------  STATISTIQUES
if bts
        pre_tmp = reshape(occup_pre_arr,j,[]);
        post_tmp = reshape(occup_post_arr,i,[]);

        [bts_pre_tmp btsam_pre_tmp] = bootstrp(draws, @mean, pre_tmp);
        [bts_post_tmp btsam_post_tmp] = bootstrp(draws, @mean, post_tmp);


        bts_pre = reshape(bts_pre_tmp,draws,sizeMap,sizeMap);
        bts_post = reshape(bts_post_tmp,draws,sizeMap,sizeMap);

    %test with random sample
    if ~(rnd)
        % T-Test
        [h,p,ci,stats] = ttest2(bts_post,bts_pre);
    else
        ind_sel = randperm(7,7);
        rnd_sel(1:3,:,:) = occup_pre_arr(ind_sel(1:3),:,:);
        rnd_sel(4:7,:,:) = occup_post_arr(ind_sel(4:7),:,:);
        rnd_tmp = reshape(rnd_sel,j,[]);
        [bts_rnd_tmp btsam_rnd_tmp] = bootstrp(draws, @mean, rnd_tmp);
        bts_rnd = reshape(bts_rnd_tmp,draws,sizeMap,sizeMap); 
        [h,p,ci,stats] = ttest2(bts_post,bts_rnd);

    end
else
    % T-Test
    [h,p,ci,stats] = ttest2(occup_post_arr,occup_pre_arr);

end


%FDR correction
if fdr_corr
    p_corr = mafdr(reshape(p,1,sizeMap*sizeMap));
    p_corr = reshape(p_corr,1,sizeMap,sizeMap);
    ind_p = find(p_corr<alpha);
    sig_pix(1,sizeMap,sizeMap) = zeros;
    sig_pix(ind_p) = 1;
    icorr=2;
elseif bonfholm
    [cor_p, h_bh]=bonf_holm(p,alpha);
    sig_pix=h_bh;
    icorr=3;
elseif bonf
    ind_p = find(p<(alpha/length(p)^2));
    sig_pix(1,sizeMap,sizeMap) = zeros;
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
    caxis([0 30]);
    title('Global activity during first pre-tests');
    colormap(gca,'jet')
    cb1=colorbar;
    set(gca,'xtick',[])
    set(gca,'ytick',[])
    hold on
%     %add shapes & text
%     text(7,10,'SHOCK ZONE', 'fontsize', 8, 'Color', 'r');
    rectangle('Position',[22 0 8 40], 'Linewidth', 2, 'FaceColor','k');
%     rectangle('Position',[0 0 22 20], 'Linewidth', 1, 'EdgeColor','r');
    
    
    %freezeColors
    
    
    subplot(3,1,2), imagesc(occup_post_glob), axis xy
    caxis([0 30]);
    title('Global activity during second pre-tests'); 
    colormap(gca,'jet')
    cb2=colorbar;
    set(gca,'xtick',[])
    set(gca,'ytick',[])    
    
    
    hold on
    %add shapes & text
    text(7,10,'SHOCK ZONE', 'fontsize', 8, 'Color', 'r');
    rectangle('Position',[22 0 8 40], 'Linewidth', 2, 'FaceColor','k');
    rectangle('Position',[0 0 22 20], 'Linewidth', 1, 'EdgeColor','r');
    
    %freezeColors
    
    subplot(3,1,3), imagesc(squeeze(tsig)), axis xy
    caxis([-1*max(max(squeeze(tsig))) max(max(squeeze(tsig)))]);
    title('Difference in activity between first pre- and second pre-test'); 
    
    set(gca,'xtick',[])
    set(gca,'ytick',[])
    colormap(gca, bluewhitered)
    cb3 = colorbar;
    
    hold on
    %add shapes & text
    text(7,10,'SHOCK ZONE', 'fontsize', 8, 'Color', 'r');
    rectangle('Position',[22 0 8 40], 'Linewidth', 2, 'FaceColor','k');
    rectangle('Position',[0 0 22 20], 'Linewidth', 1, 'EdgeColor','r');
    
    % script name at bottom
    AddScriptName

    
    
    if sav
        if bts
            print([dirout 'GlobalActivityFirst-vs-Second_bts_' corr{icorr} '_' num2str(alpha)], '-dpng', '-r300');
        else
            print([dirout 'GlobalActivityFirst-vs-Second_' corr{icorr}], '-dpng', '-r300');
        end
    end
   