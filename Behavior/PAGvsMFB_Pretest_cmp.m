%% Parameters
expe = {'StimMFBWake','UMazePAG'};
% Directory to save and name of the figure to save
% dir_out = '/home/mobs/Dropbox/DataSL/StimMFBREM/Behavior/';
% dir_out = '/home/mobs/Dropbox/DataSL/Reversal/Behavior/';
%dir_out = ['/home/mobs/Dropbox/DataSL/' expe '/Behavior/' date '/'];
dir_out = [dropbox '/DataSL/Behavior/' date '/'];

%set folders
if ~exist(dir_out,'dir')
    mkdir(dir_out);
end


%-------------- RUNNNING PARAMETERS -----------
sav = 1;
ntrial_prepost = 4;   % number of trial to show in figures whether it is classic # or more. 
trialdur = 2; % in min
dur_ts = intervalSet(1,trialdur*60*1e4);

%-------------- CHOOSE FIGURE TO OUTPUT ----------
% per mouse
trajdyn = 1; % Trajectories + barplot + zone dynamics 
firstentry = 1; % 1st entry barplot per mouse
trajoccup = 1; % trajectories and mean occupancy

globalstats = 1; % global statistiques (not complete)
heatmaps = 1; % heatmaps all mice
traj_all = 1; %trajectories all mice
finalfig = 1;

%--------------- MICE TO ANALYZE ----------------
% % good learners
Mice_to_analyze_MFB = [882 941 934 863 913]; 
Mice_to_analyze_PAG = [797 798 828 861 882 905 906 911 912 977 994]; 

%--------------- GET DIRECTORIES-------------------
Dir_MFB = PathForExperimentsERC_SL(expe{1});
Dir_MFB = RestrictPathForExperiment(Dir_MFB,'nMice', Mice_to_analyze_MFB);
Dir_PAG = PathForExperimentsERC_Dima(expe{2});
Dir_PAG = RestrictPathForExperiment(Dir_PAG,'nMice', Mice_to_analyze_PAG);

%------------- FIGURE PARAMETERS -------------
clrs = {'ko', 'bo', 'ro','go', 'co', 'mo'; 'k','r','b','m','g','c'; 'kp', 'bp', 'rp', 'gp', 'cp', 'mp'};

%Map parameter
freqVideo=15;       %frame rate
smo=4;            %smoothing factor
sizeMap=50;         %Map size
sizeMapx=240;         %Map size
sizeMapy=320;         %Map size
%Map reduction function
fun = @(block_struct) mean2(block_struct.data);

% MAZE LENGTH FACTOR
% Dimas measurement are too small
% the factor to match speed is Dimas Xtsd or Ytsd * 1.25
DimasFactor = 1.25;


% #####################################################################
% #
% #                           M A I N
% #
% #####################################################################

%% Get data
for i = 1:length(Dir_MFB.path)
    MFB{i} = load([Dir_MFB.path{i}{1} '/behavResources.mat'], 'behavResources');
end
for i = 1:length(Dir_PAG.path)
    PAG{i} = load([Dir_PAG.path{i}{1} '/behavResources.mat'], 'behavResources');
end

% Find indices of PreTests and PostTest and Cond session in the structure
% MFB
id_MFB = cell(1,length(MFB));
for i=1:length(MFB)
    id_MFB{i} = zeros(1,length(MFB{i}.behavResources));
    for k=1:length(MFB{i}.behavResources)
        if ~isempty(strfind(MFB{i}.behavResources(k).SessionName,'TestPre'))
            id_MFB{i}(k) = 1;
        end
    end
    id_MFB{i}=find(id_MFB{i});
end
% PAG
id_PAG = cell(1,length(PAG));
for i=1:length(PAG)
    id_PAG{i} = zeros(1,length(PAG{i}.behavResources));
    for k=1:length(PAG{i}.behavResources)
        if ~isempty(strfind(PAG{i}.behavResources(k).SessionName,'TestPre'))
            id_PAG{i}(k) = 1;
        end
    end
    id_PAG{i}=find(id_PAG{i});
end


%% GET OCCUPANCY DATA

for i=1:length(MFB)
    %MFB-tests
    for k=1:4
        % if problem with hist2 it is because of eeglab hist2 function
        % place it in an another path temprorarly or reload PrgMatlab path)
        [occH_MFB, x1, x2] = hist2d(Data(MFB{i}.behavResources(id_MFB{i}(k)).AlignedXtsd),...
            Data(MFB{i}.behavResources(id_MFB{i}(k)).AlignedYtsd), 240, 320);
        occHS_MFB(i,k,1:240,1:320) = SmoothDec(occH_MFB/freqVideo,[smo,smo]); 
%         x_MFB(i,k,1:240)=x1;
%         y_MFB(i,k,1:320)=x2;
        LocomotionEpoch = thresholdIntervals(MFB{i}.behavResources(id_MFB{i}(k)).Vtsd,5,'Direction', 'Above');
        vMFB(i,k) = mean(Data(Restrict(MFB{i}.behavResources(id_MFB{i}(k)).Vtsd,LocomotionEpoch))); 
    end % loop nb sess 
    %for each mouse, keep 1 average map for MFB and post tests
    occup_MFB{i}=squeeze(mean(occHS_MFB(i,:,:,:)));
end % loop mice
occup_MFB_glob = sum(cat(3,occup_MFB{:}),3);
occup_MFB_glob(occup_MFB_glob==0) = nan;

for i=1:length(PAG)
    %PAG-tests
    for k=1:4
        st = Range(PAG{i}.behavResources(id_PAG{i}(k)).CleanAlignedXtsd);
        dur_ts = intervalSet(st(1),st(1)+(trialdur*60*1e4));
        x = Data(Restrict(PAG{i}.behavResources(id_PAG{i}(k)).CleanAlignedXtsd,dur_ts));
        y = Data(Restrict(PAG{i}.behavResources(id_PAG{i}(k)).CleanAlignedYtsd,dur_ts));
        % if problem with hist2 it is because of eeglab hist2 function
        % place it in an another path temprorarly or reload PrgMatlab path)
        [occH_PAG, x1, x2] = hist2d(x,y, 240, 320);
        occHS_PAG(i,k,1:240,1:320) = SmoothDec(occH_PAG/freqVideo,[smo,smo]); 
%         x_PAG(i,k,1:240)=x1;
%         y_PAG(i,k,1:320)=x2;
        LocomotionEpoch = thresholdIntervals(PAG{i}.behavResources(id_PAG{i}(k)).Vtsd,5,'Direction', 'Above');
        vPAG(i,k) = mean(Data(Restrict(Restrict(PAG{i}.behavResources(id_PAG{i}(k)).Vtsd, dur_ts),LocomotionEpoch)));
    end % loop nb sess 
    %for each mouse, keep 1 average map for PAG and post tests
    occup_PAG{i}=squeeze(mean(occHS_PAG(i,:,:,:)));
end % loop mice
occup_PAG_glob = sum(cat(3,occup_PAG{:}),3);
occup_PAG_glob(occup_PAG_glob==0) = nan;

for itrial=1:4
    occup_MFB_trial(itrial,1:240,1:320) = squeeze(mean(occHS_MFB(:,itrial,:,:)));
    occup_PAG_trial(itrial,1:240,1:320) = squeeze(mean(occHS_PAG(:,itrial,:,:)));
    vMFBmean(itrial) = squeeze(mean(vMFB(:,itrial)));
    vMFBstd(itrial) = squeeze(std(vMFB(:,itrial))/sqrt(length(vMFB(:,itrial))));
    vPAGmean(itrial) = squeeze(mean(vPAG(:,itrial)));
    vPAGstd(itrial) = squeeze(std(vPAG(:,itrial))/sqrt(length(vPAG(:,itrial))));
end

% prepare data speed
for itrial=1:4
    vData(itrial,1) =  vMFBmean(itrial);
    vData(itrial,2) =  vPAGmean(itrial)*DimasFactor;
    vSTD(itrial,1) =  vMFBstd(itrial);
    vSTD(itrial,2) =  (vPAGstd(itrial))*DimasFactor;
end


%% Activity figure
supertit = '2 first minutes comparison between MFB and PAG Pre-Tests'; %['Occupancy by session: ' num2str(sizered) 'x' num2str(sizered) ' bins'];
figure('Color',[1 1 1], 'rend','painters','pos',[10 10 1550 800],'Name',supertit)
    for itrial=1:4
        subplot(2,4,itrial)
            imagesc(squeeze(occup_MFB_trial(itrial,:,:))'), axis xy
            caxis([0 .005]); 
            t_str = ['MFB #' num2str(itrial)];
            title(t_str, 'FontSize', 13, 'interpreter','latex',...
                    'HorizontalAlignment', 'center');
            colormap(gca,'hot')
            set(gca,'xtick',[])
            set(gca,'ytick',[])
            hold on
           
            % add visuals        
            f_draw_umaze2(sizeMapx,sizeMapy)
    end
    
    for itrial=5:8
        subplot(2,4,itrial)
            imagesc(squeeze(occup_PAG_trial(itrial-4,:,:))'), axis xy
            caxis([0 .005]);
            t_str = ['PAG #' num2str(itrial-4)];
            title(t_str, 'FontSize', 13, 'interpreter','latex',...
                    'HorizontalAlignment', 'center');
            colormap(gca,'hot')
            set(gca,'xtick',[])
            set(gca,'ytick',[])
            hold on
            %add visuals
            f_draw_umaze2(sizeMapx,sizeMapy)
    end
    print([dir_out 'OccComparePAGvsMFB_Pre'], '-dpng', '-r300');

% trajectories    
supertit = 'Trajectories: 2 first minutes comparison between MFB and PAG Pre-Tests'; %['Occupancy by session: ' num2str(sizered) 'x' num2str(sizered) ' bins'];
figure('Color',[1 1 1], 'rend','painters','pos',[10 10 1550 800],'Name',supertit)
    for itrial=1:4
        subplot(2,4,itrial)   
            %add trajectories
            for i=1:length(MFB)
               plot(Data(MFB{i}.behavResources(id_MFB{i}(itrial)).AlignedXtsd),...
                    Data(MFB{i}.behavResources(id_MFB{i}(itrial)).AlignedYtsd),...
                         'linewidth',.25,'Color','k');  
               hold on
            end
            t_str = ['MFB #' num2str(itrial)];
            title(t_str, 'FontSize', 13, 'interpreter','latex',...
                    'HorizontalAlignment', 'center');
            hold on
            set(gca,'xtick',[])
            set(gca,'ytick',[])
            xlim([-.05 1.05])
            ylim([-.05 1.05])
            %add visuals
            f_draw_umaze
    end
    for itrial=5:8
        subplot(2,4,itrial)
            %add trajectories
            for i=1:length(PAG)
               plot(Data(PAG{i}.behavResources(id_PAG{i}(itrial-4)).CleanAlignedXtsd),...
                    Data(PAG{i}.behavResources(id_PAG{i}(itrial-4)).CleanAlignedYtsd),...
                         'linewidth',.25,'Color','k');  
               hold on
            end
            t_str = ['PAG #' num2str(itrial-4)];
            title(t_str, 'FontSize', 13, 'interpreter','latex',...
                    'HorizontalAlignment', 'center');
            set(gca,'xtick',[])
            set(gca,'ytick',[])
            xlim([-.05 1.05])
            ylim([-.05 1.05])
            %add visuals
            f_draw_umaze
    end
    %save
    print([dir_out 'TrajComparePAGvsMFB_Pre'], '-dpng', '-r300');
    
    
% speed    

supertit = 'SPEED: 2 first minutes comparison between MFB and PAG Pre-Tests'; %['Occupancy by session: ' num2str(sizered) 'x' num2str(sizered) ' bins'];
figure('Color',[1 1 1], 'rend','painters','pos',[10 10 600 400],'Name',supertit)
    bar(vData,'grouped')
    %%For MATLAB R2019a or earlier releases
    hold on
    % Find the number of groups and the number of bars in each group
    ngroups = size(vData, 1);
    nbars = size(vData, 2);
    % Calculate the width for each bar group
    groupwidth = min(0.8, nbars/(nbars + 1.5));
    % Set the position of each error bar in the centre of the main bar
    for i = 1:nbars
        % Calculate center of each bar
        x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
        errorbar(x, vData(:,i), vSTD(:,i), 'k', 'linestyle', 'none');
    end
    hold offfor iacc=1:3
    load([Dir 'LFPData/LFP' num2str(id_acc(iacc)-1) '.mat']);
    acc(iacc,:) = LFP;
    clear LFP
end
    legend({'MFB','PAG'})
    ylim([0 7])
    ylabel('cm/s')
    xlabel('Pre-test trials')
    title('Overall speed: MFB vs PAG Pre-Tests')
    %save
    print([dir_out 'SpeedComparePAGvsMFB_Pre'], '-dpng', '-r300');
    

        
function f_draw_umaze2(sizeMapx,sizeMapy)

    % the following code adapt the maze boundaries to a 320 x 240 map or
    % similar x/y ratio
    
    rectangle('Position',[sizeMapx*((1/sizeMapx)*ceil(.32*sizeMapx))+.5 0 ...
        sizeMapx*((1/sizeMapx)*floor(.342*sizeMapx)) sizeMapy*((1/sizeMapy)*ceil(.7*sizeMapy))+.5], 'Linewidth', 1, 'FaceColor','w')
    rectangle('Position',[0 0 sizeMapx*((1/sizeMapx)*ceil(.32*sizeMapx))+.5 sizeMapy*((1/sizeMapy)*ceil(.35*sizeMapy))+.5], 'Linewidth', 1, 'EdgeColor','g') 
end    


% DRAWING UMAZE SHAPE
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
