%-----------  LOADING
clear all
dirpost = '/media/mobs/DataMOBS94/M0882/StimWakeMFB/6-PostTests/';
dirpre = '/media/mobs/DataMOBS94/M0882/StimWakeMFB/3-PreTests/';
predata = load([dirpre 'behavResources.mat'],'behavResources');
postdata = load([dirpost 'behavResources.mat'],'behavResources','Xtsd','Ytsd');

%----------- SAVING PARAMETERS ----------
% Outputs
    dirout = '/home/mobs/Dropbox/MOBS_workingON/Sam/WakeStimMFB/';
    if ~exist(dirout, 'dir')
        mkdir(dirout);
    end
    sav=1;      % Do you want to save a figure? Y=1; N=0

%------------- FIGURE PARAMETERS -------------
clrs = {'ko', 'bo', 'ro','go', 'co', 'mo','',''; 'w','y', 'r', 'g', 'c', 'm', 'b', 'k'; 'kp', 'bp', 'rp', 'gp', 'cp', 'mp','',''};

%-------------- MAP PARAMETERS -----------
freqVideo=15;       %frame rate
smo=2;            %smoothing factor
sizeMap=50;         %Map size

%-------------- TASK PARAMETERS -----------
nbtrials = 8;



%% GET OCCUPANCY

for itrials=1:nbtrials
    %pre
    [occH, x1, x2] = hist2(Data(predata.behavResources(itrials).Xtsd), Data(predata.behavResources(itrials).Ytsd), 240, 320);
    occHSpre(itrials,1:320,1:240) = SmoothDec(occH/freqVideo,[smo,smo]); 
    xpre(itrials,1:240)=x1;
    ypre(itrials,1:320)=x2;
    %post
    [occH, x1, x2] = hist2(Data(postdata.behavResources(itrials).Xtsd), Data(postdata.behavResources(itrials).Ytsd), 240, 320);
    occHSpost(itrials,1:320,1:240) = SmoothDec(occH/freqVideo,[smo,smo]); 
    xpost(itrials,1:240)=x1;
    ypost(itrials,1:320)=x2;
end

occHmpre = squeeze(mean(occHSpre(:,:,:,:)));
occHmpost = squeeze(mean(occHSpost(:,:,:,:)));

%% Figure

 % FIGURE 1 - Trajectories and heatmap per mouse
    supertit = ['Trajectories and occupancy heatmaps'];
    figure('Color',[1 1 1], 'rend','painters','pos',[10 10 1800 600],'Name', supertit, 'NumberTitle','off')
        
    %PRE
        % Trajectories superposed on heatmaps
        subplot(1,2,1), 

        

        % -- heatmap
        % --- set x and y vector data for image
        xx=squeeze(xpre(itrials,:));
        yi=permute(ypre,[2,1]);
        yy=yi(:,itrials);
        % --- image
        imagesc(xx,yy,squeeze(occHmpre)) 
        caxis([0 .005]) % control color intensity here
        colormap(hot)
        rectangle('position',[38 45 10 100],'FaceColor',[1 1 1],'EdgeColor','none')
        rectangle('position',[48 58 13.5 14],'EdgeColor','c','linewidth',3)
        hold on
        box off
        % -- trajectories 
        for itrials=1:8
            p1 = plot((predata.behavResources(itrials).PosMat(:,3)),(predata.behavResources(itrials).PosMat(:,2)),...
                clrs{2,itrials}, 'linewidth',1)  ;  
            p1.Color(4) = .8;    %control line color intensity here
            hold on
        end
        
        set(gca, 'XTick', []);
        set(gca, 'YTick', []);

        title(['Pre-tests occupancy'], 'fontsize',14)
        
     % POST   
        subplot(1,2,2), 

        box off

        % -- heatmap
        % --- set x and y vector data for image
        xx=squeeze(xpost(itrials,:));
        yi=permute(ypost,[2,1]);
        yy=yi(:,itrials);
        % --- image
        imagesc(xx,yy,squeeze(occHmpost)) 
        caxis([0 .005]) % control color intensity here
        colormap(hot)
        colorbar('eastoutside')
        rectangle('position',[31 45 10 100],'FaceColor',[1 1 1],'EdgeColor','none')
        rectangle('position',[41 59 14.5 14],'EdgeColor','c','linewidth',3)
        hold on
        % -- trajectories 
        for itrials=1:8
            p1 = plot((postdata.behavResources(itrials).PosMat(:,3)),(postdata.behavResources(itrials).PosMat(:,2)),...
                    clrs{2,itrials}, 'linewidth',1)  ;  
            p1.Color(4) = .8;    %control line color intensity here
            hold on
        end
        
        legend('t1','t2','t3','t4','t5','t6','t7','t8','location','south')
       
        set(gca, 'XTick', []);
        set(gca, 'YTick', []);
        
        title(['Post-tests occupancy'], 'fontsize',14)
        
        % Supertitle
        mtit(supertit, 'fontsize',16, 'xoff', 0, 'yoff', 0.03);
        
        % script name at bottom
%         AddScriptName

        if sav
            print([dirout 'M0882_StimWakeMFB_heatmaps_all'], '-dpng', '-r300');
        end