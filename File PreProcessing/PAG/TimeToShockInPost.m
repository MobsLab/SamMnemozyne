%==========================================================================
% Details: this script get the time it took the mouse to enter the zone and 
% stay there for a fixed amount of time (seconds)
%
% INPUTS:
%       - None yet
%
% OUTPUT:
%       - Figure per mouse of time-to-shockzone
%       - Figure average  
%
% NOTES:
%       - 
%       
%   Written by Samuel Laventure - 29-10-2018
%==========================================================================

clear all
%% Parameters

% ---------- HARDCODED -----------

% Saving file    
    sav=1;      % Do you want to save a figure? Y=1; N=0
    dirout = '/home/mobs/Dropbox/MOBS_workingON/Sam/PAGTests/'; % Where to save?

% input folders
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
    %     '/media/DataMOBsRAIDN/ProjetPAGTest/Mouse-785/'; %post
    %     '/media/DataMOBsRAIDN/ProjetPAGTest/Mouse-786/'; %ant
    %     '/media/DataMOBsRAIDN/ProjetPAGTest/Mouse-786/'; %post
    %     '/media/DataMOBsRAIDN/ProjetPAGTest/Mouse-787/'; %ant
    %     '/media/DataMOBsRAIDN/ProjetPAGTest/Mouse-787/'; %post
    %     '/media/DataMOBsRAIDN/ProjetPAGTest/Mouse-788/'; %ant
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
        %'/media/DataMOBsRAIDN/ProjectEmbReact/Mouse514/'
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
    %     '11092018';
    %     '12092018';
    %     '10092018';
    %     '11092018';
    %     '12092018';
    %     '10092018';
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
        %'20170316/ProjectEmbReact_M514_20170316_TestPre/'
        };

    %Post-24h
    Day4 = {
        '21092018';
        '20092018';
        '20092018';
        '21092018';
        '20092018';
        '21092018';
        '21092018';
        '20092018';
    };
    
    %Post test (48h later)
    Day5 = {
        '22092018';
        '21092018';
        '21092018';
        '22092018'; %do not exist
        '21092018';
        '22092018';
        '22092018';
        '21092018';
        
        %Dima's mice (post-tests)
    %     '12092018';
    %     '11092018';
    %     '12092018';
    %     '10092018';
    %     '11092018';
    %     '12092018';
    %     '10092018';
        %Sophie's mice
    %     '20160803/ProjetctEmbReact_M431_20160803_TestPost/'; shock24h(imouse,itest) = t_post24h;
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
        %'20170316/ProjectEmbReact_M514_20170316_TestPost/'
    };

%Nbr of trials per test
ntest = 4;

%Directories details
elec = {'AnteriorStim','PosteriorStim'};
ielec = [1 2 1 2 2 1 1 2 0 0 0 0 0 0 0];
room = [1 2 1 2 2 2 1 2 1 2 1 2 1 2 1 1 1 1 1 1 1 1 1 1 1 1 1];
sufDir = {'Pretests'; 'Cond'; 'PostTests'; 'PostSleep'; 'Post24h'; 'Post48h'};
suf = {'pre'; 'Cond'; 'posttest'; 'postsleep'; 'post24h'; 'post48h'};
suf_db = {'TestPre'; 'TestPost'};

%Related to tests
t_posttest = 240;          % time (s) of each post-test trial
t_postsleep = 240;          % time (s) of each post-sleep trial
t_post24h = 240;          % time (s) of each post-24h trial


%% Load epochs

for imouse=1:length(indir)
    for itest=1:ntest
        %PostTest
        if itest<3
            ptest{itest} = load([indir{imouse} Day3{imouse} '/' elec{ielec(imouse)} '/' sufDir{3} '/' suf{3} num2str(itest) '/behavResources.mat'], 'ZoneEpoch', 'PosMat');
        end
        %PostSleep
        psleep{itest} = load([indir{imouse} Day3{imouse} '/' elec{ielec(imouse)} '/' sufDir{4} '/' suf{4} num2str(itest) '/behavResources.mat'], 'ZoneEpoch', 'PosMat');
        %Post24h
        p24h{itest} = load([indir{imouse} Day4{imouse} '/' elec{ielec(imouse)} '/' sufDir{5} '/' suf{5} num2str(itest) '/behavResources.mat'], 'ZoneEpoch', 'PosMat');
        % Post48
%         try 
%             c{itest} = load([indir{itest} Day4{itest} '/' elec{ielec(itest)} '/' sufDir{3} '/behavResources.mat'],'ZoneEpoch', 'Ytsd','Zone');
%         catch
%             try
%                 % post-test after 24h
%                 c{itest} = load([indir{itest} Day4{itest} '/' elec{ielec(itest)} '/Post24h/behavResources.mat'],'ZoneEpoch', 'Ytsd', 'Zone');
%             catch
%                 % Dima's post-test
%                 c{itest} = load([indir{itest} Day4{itest} '/' suf_db{2} '/behavResources.mat'],'ZoneEpoch', 'Ytsd', 'Zone');
%             end
%         end
    end
    

    
    
    %% Get epochs inside shockzone
    for itest=1:ntest
        % Post-tests
        if itest<3
            tfin_ptest = ptest{1,itest}.PosMat(end,1);
            if ~(isempty(ptest{1,itest}))
                epochs = [Start(ptest{1,itest}.ZoneEpoch{1},'s') End(ptest{1,itest}.ZoneEpoch{1},'s')];
                [sizepo q] = size(epochs);
                if sizepo>0
                    for iepoch=1:sizepo
                        timein = epochs(end,2)-epochs(end,1);
                        if timein>13
                            shocktest(imouse,itest) = epochs(end,1)+13;
                            break
                        elseif iepoch==sizepo
                            shocktest(imouse,itest) = tfin_ptest;
                        end
                    end
                else
                    shocktest(imouse,itest) = t_posttest;
                end
            else
                shocktest(imouse,itest) = t_posttest;
            end
        end
        
        
        %Post-Sleep
        tfin_psleep = psleep{1,itest}.PosMat(end,1);
        if ~(isempty(psleep{1,itest}))
            epochs = [Start(psleep{1,itest}.ZoneEpoch{1},'s') End(psleep{1,itest}.ZoneEpoch{1},'s')];
            [sizepo q] = size(epochs);
            if sizepo>0
                for iepoch=1:sizepo
                        timein = epochs(end,2)-epochs(end,1);
                    if timein>13
                        shocksleep(imouse,itest) = epochs(end,1)+13;
                        break
                    elseif iepoch==sizepo
                        shocksleep(imouse,itest) = tfin_psleep;
                    end
                end
            else
                shocksleep(imouse,itest) = t_postsleep;
            end
        else
            shocksleep(imouse,itest) = t_postsleep;
        end
        
        %Post-24h
        tfin_p24h = p24h{1,itest}.PosMat(end,1);
        if ~(isempty(p24h{1,itest}))
            try
                epochs = [Start(p24h{1,itest}.ZoneEpoch{1},'s') End(p24h{1,itest}.ZoneEpoch{1},'s')];
                [sizepo q] = size(epochs);
                if sizepo>0
                    for iepoch=1:sizepo
                            timein = epochs(end,2)-epochs(end,1);
                        if timein>13
                            shock24h(imouse,itest) = epochs(end,1)+13;
                            break
                        elseif iepoch==sizepo
                            shock24h(imouse,itest) = tfin_p24h;
                        end
                    end
                else
                    shock24h(imouse,itest) = t_post24h;
                end
            catch
                shock24h(imouse,itest) = t_post24h;
                disp(['Mouse ' indir{imouse} ' on ' sufDir{5} ' trial #' itest ' have a ZoneEpoch issue']);
            end
                
        else
            shock24h(imouse,itest) = t_post24h;
            disp(['Mouse ' indir{imouse} ' on ' sufDir{5} ' trial #' itest ' have a issue at if ~(isempty(p24h{1,itest}))']);
        end
    end
    

end

%% Calculate means and stats

LatencyArray = [squeeze(mean(shocktest,2))'; squeeze(mean(shocksleep,2))'; squeeze(mean(shock24h,2))']';
LatencyArray_std = [std(shocktest',1)./sqrt(length(shocktest)); std(shocksleep',1)./sqrt(length(shocksleep)); std(shock24h',1)./sqrt(length(shock24h))]';

%ielec = [1 2 1 2 2 1 1 2 0 0 0 0 0 0 0];

Lat_ant = [squeeze(mean(shocktest(ielec==1,:),2))'; squeeze(mean(shocksleep(ielec==1,:),2))'; squeeze(mean(shock24h(ielec==1,:),2))']';
Lat_ant_std = [(std(shocktest(ielec==1,:)'./sqrt(length(shocktest(ielec==1,:))'),1)); ...
               (std(shocksleep(ielec==1,:)'./sqrt(length(shocksleep(ielec==1,:))'),1)); ...
               (std(shock24h(ielec==1,:)'./sqrt(length(shock24h(ielec==1,:))'),1))]';
Lat_pos = [squeeze(mean(shocktest(ielec==2,:),2))'; squeeze(mean(shocksleep(ielec==2,:),2))'; squeeze(mean(shock24h(ielec==2,:),2))']';
Lat_pos_std = [(std(shocktest(ielec==2,:)'./sqrt(length(shocktest(ielec==2,:))'),1)); ...
               (std(shocksleep(ielec==2,:)'./sqrt(length(shocksleep(ielec==2,:))'),1)); ...
               (std(shock24h(ielec==2,:)'./sqrt(length(shock24h(ielec==2,:))'),1))]';


LatencyArrayMean = mean(LatencyArray, 1);
LatencyArrayMean_std = std(LatencyArray,1);
p12 = signrank(LatencyArray(1,1), LatencyArray(1,2));
p13 = signrank(LatencyArray(1,1), LatencyArray(1,3));
p23 = signrank(LatencyArray(1,2), LatencyArray(1,3));

Lat_antmean =  mean(Lat_ant,1);
Lat_posmean =  mean(Lat_pos,1);
Lat_antstd =  std(Lat_ant,1)./sqrt(length(Lat_ant));
Lat_posstd =  std(Lat_pos,1)./sqrt(length(Lat_pos));
p12ant = signrank(Lat_ant(1,1), Lat_ant(1,2));
p13ant = signrank(Lat_ant(1,1), Lat_ant(1,3));
p23ant = signrank(Lat_ant(1,2), Lat_ant(1,3));


%% Plots
% Individual mice

fh1 = figure('Color',[1 1 1], 'rend','painters','pos',[10 10 1920 1080]);

subplot(2,3,[1,3])
hb = bar(LatencyArray);
hold on
for ib = 1:numel(hb)
    %XData property is the tick labels/group centers; XOffset is the offset
    %of each distinct group
    xData = hb(ib).XData+hb(ib).XOffset;
    errorbar(xData,LatencyArray(:,ib),LatencyArray_std(:,ib),'k.')
end
hold on
set(gca,'Xtick',[1:8],'XtickLabel',{'M784ant', 'M784post', 'M789ant', 'M789post', 'M790post', 'M791ant', 'M792ant', '792post'});
set(gca,'Ytick',(0:40:240),'Ylim',[0 240])

lgd=legend('Post-Test', 'Post-Sleep', 'Post-24h');
lgd.Location = 'northwest';
ylabel('Time (s)');
box off
title ('Time to enter shockzone per mouse/stimulation electrode');



% Averaged

subplot(2,3,4)
PlotErrorBarN_KJ(LatencyArrayMean, 'barcolors', [0.3 0.266 0.613], 'newfig', 0, 'showPoints',0);
hold on
errorbar(LatencyArrayMean, LatencyArrayMean_std,'.', 'Color', 'k');
hold on
set(gca,'Xtick',[1:3],'XtickLabel',{'Post-Test', 'Post-Sleep', 'Post-24h'}, 'FontSize', 12);
set(gca,'Ytick',(0:40:240),'Ylim',[0 240])
ylabel('Time (s)', 'FontSize', 12);
%Stats sig
if p12 < 0.05
    H1 = sigstar({{'Post-Test', 'Post-Sleep'}}, p12);
end
if p13 < 0.05
    H2 = sigstar({{'Post-Test', 'Post-24h'}}, p13);
end
if p23 < 0.05
    H3 = sigstar({{'Post-Sleep', 'Post-24h'}}, p23);
end
box off
title('All mice','FontSize', 12);


subplot(2,3,5)
PlotErrorBarN_KJ(Lat_antmean, 'barcolors', [0.3 0.266 0.613], 'newfig', 0,'showPoints',0);
hold on
errorbar(Lat_antmean, Lat_antstd,'.', 'Color', 'k');
set(gca,'Xtick',[1:3],'XtickLabel',{'Post-Test', 'Post-Sleep', 'Post-24h'}, 'FontSize', 12);
set(gca,'Ytick',(0:40:240),'Ylim',[0 240]) 
ylabel('Time (s)', 'FontSize', 12);
%Stats sig
if p12ant < 0.05
    H1 = sigstar({{'Post-Test', 'Post-Sleep'}}, p12);
end
if p13ant < 0.05
    H2 = sigstar({{'Post-Test', 'Post-24h'}}, p13);
end
if p23ant < 0.05
    H3 = sigstar({{'Post-Sleep', 'Post-24h'}}, p23);
end
box off
title ('Anterior Electrode', 'FontSize', 12);

subplot(2,3,6)
PlotErrorBarN_KJ(Lat_posmean, 'barcolors', [0.3 0.266 0.613], 'newfig', 0, 'showPoints',0);
%PlotErrorSpreadN_KJ(Lat_pos,'newfig',0,'paired',1,'median',1,'errorbars',1,'y_lim',[0 250])
hold on
errorbar(Lat_posmean, Lat_posstd,'.', 'Color', 'k');
set(gca,'Xtick',[1:3],'XtickLabel',{'Post-Test', 'Post-Sleep', 'Post-24h'}, 'FontSize', 12);
set(gca,'Ytick',(0:40:240),'Ylim',[0 240])
ylabel('Time (s)', 'FontSize', 12);
%Stats sig
% if p12 < 0.05
%     H1 = sigstar({{'Post-Test', 'Post-Sleep'}}, p12);
% end
% if p13 < 0.05
%     H2 = sigstar({{'Post-Test', 'Post-24h'}}, p13);
% end
% if p23 < 0.05
%     H3 = sigstar({{'Post-Sleep', 'Post-24h'}}, p23);
% end
box off
title ('Posterior Electrode', 'FontSize', 12);

% Global figure details

% Super title
annotation('textbox', [0 0.9 1 0.1], ...
    'String', 'Time to enter the shockzone with timer running out (13s)', ...
    'EdgeColor', 'none', ...
    'HorizontalAlignment', 'center', ...
    'FontSize', 16, 'Fontweight', 'bold');

% Created with...
annotation('textbox',[.75 0 .2 .06], ...
    'String','Figure created with TimeToShockInPost.m', ...
    'FitBoxToText','on', 'EdgeColor', 'none', 'FontAngle','italic')

%save
fileName = [dirout 'TimeToShockzone_mean'];

print(fileName, '-dpng', '-r300');
saveas(fh1, [fileName '.fig']);
    
    
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    