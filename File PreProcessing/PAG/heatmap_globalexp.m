function heatmap_globalexp_PAG ()

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
    draws=50;   %nbr of draws for the bts
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
    sav=1;      % Do you want to save a figure? Y=1; N=0
    dirout = '/home/mobs/Dropbox/MOBS_workingON/Sam/PAGTests/'; % Where to save?

% input folders

sd = 14;        % # of sam + dima's mice

indir = {
    %Sam's mice (n=8)
    '/media/DataMOBsRAIDN/ProjetPAGTest/M784/'; %ant
    '/media/DataMOBsRAIDN/ProjetPAGTest/M784/'; %post
    '/media/DataMOBsRAIDN/ProjetPAGTest/M789/'; %ant
    '/media/DataMOBsRAIDN/ProjetPAGTest/M789/'; %post
    '/media/DataMOBsRAIDN/ProjetPAGTest/M790/'; %post
    '/media/DataMOBsRAIDN/ProjetPAGTest/M791/'; %ant
    '/media/DataMOBsRAIDN/ProjetPAGTest/M792/'; %ant
    '/media/DataMOBsRAIDN/ProjetPAGTest/M792/';  %post
    %Dima's mice (n=7)
%     '/media/DataMOBsRAIDN/ProjetPAGTest/Mouse-785/'; %ant
    '/media/DataMOBsRAIDN/ProjetPAGTest/Mouse-785/'; %post 2
    '/media/DataMOBsRAIDN/ProjetPAGTest/Mouse-786/'; %ant 1
    '/media/DataMOBsRAIDN/ProjetPAGTest/Mouse-786/'; %post 2
    '/media/DataMOBsRAIDN/ProjetPAGTest/Mouse-787/'; %ant 1
    '/media/DataMOBsRAIDN/ProjetPAGTest/Mouse-787/'; %post 2
    '/media/DataMOBsRAIDN/ProjetPAGTest/Mouse-788/'; %ant 1
    %Sophie's mice (n=11)
%     '/media/DataMOBsRAID/ProjectEmbReact/Mouse431/'; 
%     '/media/DataMOBsRAID/ProjectEmbReact/Mouse436/';
%     '/media/DataMOBsRAID/ProjectEmbReact/Mouse437/';
%     '/media/DataMOBsRAID/ProjectEmbReact/Mouse438/';
%     '/media/DataMOBsRAIDN/ProjectEmbReact/Mouse439/';
%     '/media/DataMOBsRAIDN/ProjectEmbReact/Mouse490/';
%     '/media/DataMOBsRAIDN/ProjectEmbReact/Mouse507/';
%     '/media/DataMOBsRAIDN/ProjectEmbReact/Mouse508/';
%     '/media/DataMOBsRAIDN/ProjectEmbReact/Mouse509/';
%     '/media/DataMOBsRAIDN/ProjectEmbReact/Mouse510/';
%     '/media/DataMOBsRAIDN/ProjectEmbReact/Mouse512/';
%     '/media/DataMOBsRAIDN/ProjectEmbReact/Mouse514/'
};

%Exp day
Day3 = {
    %Sam's mice
    '20092018';
    '19092018';
    '19092018';
    '20092018';
    '19092018';
    '20092018';
    '20092018';
    '19092018';
    %Dima's mice
%     '12092018';
    '11092018';
    '12092018';
    '10092018';
    '11092018';
    '12092018';
    '10092018';
    %Sophie's mice
%     '20160803/ProjetctEmbReact_M431_20160803_TestPre/'; 
%     '20160811/ProjectEmbReact_M436_20160811_TestPre/';
%     '20160812/ProjectEmbReact_M437_20160812_TestPre/';
%     '20160819/ProjectEmbReact_M438_20160819_TestPre/';
%     '20160820/ProjectEmbReact_M439_20160820_TestPre/';
%     '20161201/ProjectEmbReact_M490_20161201_TestPre/';
%     '20170201/ProjectEmbReact_M507_20170201_TestPre/';
%     '20170203/ProjectEmbReact_M508_20170203_TestPre/';
%     '20170204/ProjectEmbReact_M509_20170204_TestPre/';
%     '20170209/ProjectEmbReact_M510_20170209_TestPre/';
%     '20170208/ProjectEmbReact_M512_20170208_TestPre/';
%     '20170316/ProjectEmbReact_M514_20170316_TestPre/'
    };

%Post test (48h later)
Day4 = {
    '22092018';
    '21092018';
    '21092018';
    '21092018';
    '21092018';
    '22092018';
    '22092018';
    '21092018';
    %Dima's mice (post-tests)
%     '12092018';
    '11092018';
    '12092018';
    '10092018';
    '11092018';
    '12092018';
    '10092018';
    %Sophie's mice
%     '20160803/ProjetctEmbReact_M431_20160803_TestPost/'; 
%     '20160811/ProjectEmbReact_M436_20160811_TestPost/';
%     '20160812/ProjectEmbReact_M437_20160812_TestPost/';
%     '20160819/ProjectEmbReact_M438_20160819_TestPost/';
%     '20160820/ProjectEmbReact_M439_20160820_TestPost/';
%     '20161201/ProjectEmbReact_M490_20161201_TestPost/';
%     '20170201/ProjectEmbReact_M507_20170201_TestPost/';
%     '20170203/ProjectEmbReact_M508_20170203_TestPost/';
%     '20170204/ProjectEmbReact_M509_20170204_TestPost/';
%     '20170209/ProjectEmbReact_M510_20170209_TestPost/';
%     '20170208/ProjectEmbReact_M512_20170208_TestPost/';
%     '20170316/ProjectEmbReact_M514_20170316_TestPost/'
   
    
    };

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
smo=1.5;            %smoothing factor
sizeMap=50;         %Map size



%% Get trajectories

for j=1:length(indir)
    
    %% Get DATA
    
    if j>sd
        for itest=1:2
            % Set Sophie's files
            % pre-test
            for i = 1:ntest
                if itest==1
                    s{i} = load([indir{j} Day3{j} '/' suf_db{itest} num2str(i) '/behavResources.mat']);
                else
                    s{i} = load([indir{j} Day4{j} '/' suf_db{itest} num2str(i) '/behavResources.mat']);
                end
            end

            for i = 1:ntest
                TimeTemp{i} = Range(s{i}.Ytsd);
                duration(i) = TimeTemp{i}(end) - TimeTemp{i}(1);
                offset(i) = TimeTemp{i}(1);
                lind(i) = length(TimeTemp{i});
                lasttime(i) = TimeTemp{i}(end);
            end
            clear TimeTemp

            % Concatenate Ytsd (type single tsd)
            %var init
            for i = 1:4
                YtsdTimeTemp{i} = [];
                YtsdDataTemp{i} = [];
            end
            for i=1:ntest
                YtsdTimeTemp{i} = Range(s{i}.Ytsd);
                YtsdDataTemp{i} = Data(s{i}.Ytsd);
            end
            for i = 1:(ntest-1)
                YtsdTimeTemp{i+1} = YtsdTimeTemp{i+1}+sum(duration(1:i)+offset(i+1));
            end
            YtsdTime = [YtsdTimeTemp{1}; YtsdTimeTemp{2}; YtsdTimeTemp{3}; YtsdTimeTemp{4}];
            ch = find(diff(YtsdTime) < 0); % check where
            YtsdData = [YtsdDataTemp{1}; YtsdDataTemp{2}; YtsdDataTemp{3}; YtsdDataTemp{4}];


            % Concatenate Xtsd (type single tsd)
            %var init
            for i = 1:4
                XtsdTimeTemp{i} = [];
                XtsdDataTemp{i} = [];
            end

            for i=1:ntest
                XtsdTimeTemp{i} = Range(s{i}.Xtsd);
                XtsdDataTemp{i} = Data(s{i}.Xtsd);
            end
            for i = 1:(ntest-1)
                XtsdTimeTemp{i+1} = XtsdTimeTemp{i+1}+sum(duration(1:i)+offset(i+1));
            end
            XtsdTime = [XtsdTimeTemp{1}; XtsdTimeTemp{2}; XtsdTimeTemp{3}; XtsdTimeTemp{4}];
            ch = find(diff(XtsdTime) < 0);
            XtsdData = [XtsdDataTemp{1}; XtsdDataTemp{2}; XtsdDataTemp{3}; XtsdDataTemp{4}];

            if itest==1
                a{j}.Ytsd = tsd(YtsdTime, YtsdData);
                a{j}.Xtsd = tsd(XtsdTime, XtsdData);
                a{j}.Zone = s{1}.Zone;
            else
                c{j}.Ytsd = tsd(YtsdTime, YtsdData);
                c{j}.Xtsd = tsd(XtsdTime, XtsdData);
                c{j}.Zone = s{1}.Zone;
            end
        end
    else
        % PreTests
        try
            a{j} = load([indir{j} Day3{j} '/' elec{ielec(j)} '/' sufDir{1} '/behavResources.mat'], 'Xtsd', 'Ytsd', 'Zone','PosMat');
        catch
            a{j} = load([indir{j} Day3{j} '/' suf_db{1} '/behavResources.mat'], 'Xtsd', 'Ytsd', 'Zone','PosMat');
        end
        % PostTests
        try 
            c{j} = load([indir{j} Day4{j} '/' elec{ielec(j)} '/' sufDir{3} '/behavResources.mat'],'Xtsd', 'Ytsd','Zone','PosMat');
        catch
            try
                % post-test after 24h
                c{j} = load([indir{j} Day4{j} '/' elec{ielec(j)} '/Post24h/behavResources.mat'],'Xtsd', 'Ytsd', 'Zone','PosMat');
            catch
                % Dima's post-test
                c{j} = load([indir{j} Day4{j} '/' suf_db{2} '/behavResources.mat'],'Xtsd', 'Ytsd', 'Zone','PosMat');
            end
        end
    end
    
    
%% Prepare data for mapping
    
    %GET PRETEST DATA
    [occH_pre, x1_pre, x2_pre] = hist2d(Data(a{j}.Xtsd), Data(a{j}.Ytsd), sizeMap, sizeMap);
    occHS_pre=SmoothDec(occH_pre/freqVideo,[smo,smo]); 
    PreTest_PosMat =  a{j}.PosMat
    

    %GET POSTTEST DATA
    [occH_post, x1_post, x2_post] = hist2d(Data(c{j}.Xtsd), Data(c{j}.Ytsd), sizeMap, sizeMap);
    occHS_post=SmoothDec(occH_post/freqVideo,[smo,smo]); 


    %find shock zone and change orientation
    [dim1 dim2] = find(c{j}.Zone{1,1}==1);
    if room(j)==1 %(inversed U-shaped on screen)
        if dim2(1)>160            
            occHS_pre = flip(occHS_pre,2);
            occHS_post = flip(occHS_post,2);            
        end
    else %(inversed C-shaped on screen)
        if dim1(1)<120
            occHS_pre = flip(occHS_pre);
            occHS_post = flip(occHS_post);         
        end    
    end

    % rotating map if orientation is diff (from one room to the other)
    if room(j)==2 
        occHS_pre = rot90(occHS_pre,3);
        x1_temp = x1_pre;
        x1_pre = x2_pre;
        x2_pre = x1_temp;

        occHS_post = rot90(occHS_post,3);
        x1_temp = x1_post;
        x1_post = x2_post;
        x2_post = x1_temp;
    end
    
    occup_pre_arr(j,1:sizeMap,1:sizeMap) = occHS_pre;
    occup_pre{j} = occHS_pre;   
    occup_post_arr(j,1:sizeMap,1:sizeMap) = occHS_post;
    occup_post{j} = occHS_post;

    
end

occup_pre_glob = sum(cat(3,occup_pre{:}),3);
occup_post_glob = sum(cat(3,occup_post{:}),3);
occup_pre_glob(occup_pre_glob==0) = nan;
occup_post_glob(occup_post_glob==0) = nan;


%% ------  STATISTIQUES
if bts
        pre_tmp = reshape(occup_pre_arr,j,[]);
        post_tmp = reshape(occup_post_arr,j,[]);

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
    [h,p,ci,stats] = ttest(occup_post_arr,occup_pre_arr);

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
    
    subplot(6,1,1), imagesc(occup_pre_glob), axis xy
    caxis([0 30]);
    title('Global activity during pre-tests');
    colormap(gca,'jet')
    cb1=colorbar;
    set(gca,'xtick',[])
    set(gca,'ytick',[])
    hold on
    %add shapes & text
    text(7,10,'SHOCK ZONE', 'fontsize', 8, 'Color', 'r');
    rectangle('Position',[22 0 8 40], 'Linewidth', 2, 'FaceColor','k');
    rectangle('Position',[0 0 22 20], 'Linewidth', 1, 'EdgeColor','r');
    
    
    
    subplot(6,1,2), 
%     imagesc(Pre_mask),
    axis xy
    caxis([0 30]);
    title('Trajectories during pre-tests');
    colormap(gray)
    hold on
%     imagesc(Pre_Zone{1}, 'AlphaData', 0.3);
%     hold on
    for l=1:1:ntest
        plot(PostTest_PosMat{l}(:,2)*Post_Ratio_IMAonREAL,PostTest_PosMat{l}(:,3)*Post_Ratio_IMAonREAL,...
            clrs{2,l},'linewidth',1.5)
        hold on
    end
    set(gca, 'XTickLabel', []);
    set(gca, 'YTickLabel', []);
    
    
    
    %freezeColors
    
    
    subplot(6,1,3), imagesc(occup_post_glob), axis xy
    caxis([0 30]);
    title('Global activity during post-tests'); 
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
    
    subplot(6,1,5:6), imagesc(squeeze(tsig)), axis xy
    caxis([-1*max(max(squeeze(tsig))) max(max(squeeze(tsig)))]);
    title('Difference in activity between post-pre'); 
    
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
            print([dirout 'GlobalActivityPost-Pre_bts_' corr{icorr} '_' num2str(alpha)], '-dpng', '-r300');
        else
            print([dirout 'GlobalActivityPost-Pre_' corr{icorr}], '-dpng', '-r300');
        end
    end
   