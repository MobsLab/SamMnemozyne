function [figH_ind figH] = BehaviorERC_SL_8trials(expe,Mice_to_analyze)
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

rmpath([dropbox '\DataSL\Matlab_scripts\working functions\generic\eeglab\sccn-eeglab-e35d7ab\functions\miscfunc\']);

%% Parameters

%-------------- RUNNNING PARAMETERS -----------
old = 0;
sav = 1;
ntrial_prepost = 4;   % number of trial to show in figures whether it is classic # or more. 
fixtrial = 0;  % change number of trial to process see var ntrial_prepost

%-------------- CHOOSE FIGURE TO OUTPUT ----------
% per mouse
trajdyn = 1; % Trajectories + barplot + zone dynamics 
firstentry = 1; % 1st entry barplot per mouse
trajoccup = 1; % trajectories and mean occupancy

globalstats = 0; % global statistiques (not complete)
heatmaps = 0; % heatmaps all mice
traj_all = 0; %trajectories all mice
finalfig = 0;
heatstat = 0;

%--------------- GET DIRECTORIES-------------------
% Dir = PathForExperimentsERC_SL('StimMFBWake');
% Dir = PathForExperimentsERC_SL('Reversal');
Dir = PathForExperimentsERC_SL(expe);
Dir = RestrictPathForExperiment(Dir,'nMice', Mice_to_analyze);

%-------------- MAP PARAMETERS -----------
freqVideo=15;       %frame rate
smo=2;            %smoothing factor
sizeMap=50;         %Map size

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
tt = 0;   
          %ttest2
%Map parameter
freqVideo=15;       %frame rate
smo=4;            %smoothing factor
sizeMap=50;         %Map size
sizeMapx=240;         %Map size
sizeMapy=320;         %Map size
%Map reduction function
fun = @(block_struct) mean2(block_struct.data);

% #####################################################################
% #
% #                           M A I N
% #
% #####################################################################


%% Get data
for i = 1:length(Dir.path)
    a{i} = load([Dir.path{i}{1} '/behavResources.mat'], 'behavResources');
end

%% Set sessions
switch expe
    case 'StimMFBWake'
        cond = 1;  % set to 1 if there are conditionning trial in UMaze
    case 'StimMFBSleep'
        cond = 0;
    case 'Reversal'
        cond = 1;     
    case 'FirstExploNew'
        cond = 1;
end

%% Find indices of PreTests and PostTest and Cond session in the structure
id_Pre = cell(1,length(a));
id_Post = cell(1,length(a));
if cond
    id_Cond = cell(1,length(a));
end

for i=1:length(a)
    id_Pre{i} = zeros(1,length(a{i}.behavResources));
    id_Post{i} = zeros(1,length(a{i}.behavResources));
    if cond
        id_Cond{i} = zeros(1,length(a{i}.behavResources));
    end
    for k=1:length(a{i}.behavResources)
        if ~isempty(strfind(a{i}.behavResources(k).SessionName,'TestPre'))
            id_Pre{i}(k) = 1;
        end
        if ~isempty(strfind(a{i}.behavResources(k).SessionName,'TestPost'))
            id_Post{i}(k) = 1;
        end
        if cond
            if ~isempty(strfind(a{i}.behavResources(k).SessionName,'Cond'))
                id_Cond{i}(k) = 1;
            end
        end
    end
    id_Pre{i}=find(id_Pre{i});
    id_Post{i}=find(id_Post{i});
    if cond
        id_Cond{i}=find(id_Cond{i});
        % get nbr of cond trial
        nbcond{i} = length(id_Cond{i});
    end
    if fixtrial
        id_Pre{i} = id_Pre{i}(1:ntrial_prepost);
        id_Post{i} = id_Post{i}(1:ntrial_prepost);
        nbprepost(i) = ntrial_prepost;
    else
        % get nbr of cond trial
        nbprepost(i) = length(id_Pre{i});
    end
    
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
    if cond
        for k=1:length(id_Cond{i})
            for t=1:length(a{i}.behavResources(id_Cond{i}(k)).Zone)
                Cond_Occup(i,k,t)=size(a{i}.behavResources(id_Cond{i}(k)).ZoneIndices{t},1)./...
                    size(Data(a{i}.behavResources(id_Cond{i}(k)).Xtsd),1);
            end
        end
    end
end

Pre_Occup_stim = squeeze(Pre_Occup(:,:,1));
Pre_Occup_nostim = squeeze(Pre_Occup(:,:,2));
Post_Occup_stim = squeeze(Post_Occup(:,:,1));
Post_Occup_nostim = squeeze(Post_Occup(:,:,2));
if cond
    Cond_Occup_stim = squeeze(Cond_Occup(:,:,1));
    Cond_Occup_nostim = squeeze(Cond_Occup(:,:,2));
end

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

%----  Cond
if cond
    % Shock
    Cond_Occup_stim_mean = mean(Cond_Occup_stim,2);
    % nostim
    Cond_Occup_nostim_mean = mean(Cond_Occup_nostim,2);
end

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
p_FirstTime_pre_post = signrank(Pre_FirstTime_mean,Post_FirstTime_mean); % not used for now

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
p_entnum_pre_post = signrank(Pre_entnum_mean, Post_entnum_mean); % not used for now

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
p_VZmean_pre_post = signrank(Pre_VZmean_mean, Post_VZmean_mean); % not used for now

%% GET OCCUPANCY DATA


for i=1:length(a)
    %Pre-tests
    for k=1:length(id_Pre{i})
        % if problem with hist2 it is because of eeglab hist2 function
        % place it in an another path temprorarly or reload PrgMatlab path)
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
    if cond
        for k=1:length(id_Cond{i})
            [occH_Cond, x1, x2] = hist2(Data(a{i}.behavResources(id_Cond{i}(k)).AlignedXtsd),...
                Data(a{i}.behavResources(id_Cond{i}(k)).AlignedYtsd), 240, 320);
            occHS_Cond(i,k,1:320,1:240) = SmoothDec(occH_Cond/freqVideo,[smo,smo]); 
            x_Cond(i,k,1:240)=x1;
            y_Cond(i,k,1:320)=x2;
        end % loop nb sess    
    end
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


% for i=1:length(a)
%     %Pre-tests
%     for k=1:length(id_Pre{i})
%         % occupation map
%         [OccupMap_temp,xx,yy] = hist2d(Data(a{i}.behavResources(id_Pre{i}(k)).AlignedXtsd),...
%             Data(a{i}.behavResources(id_Pre{i}(k)).AlignedYtsd),[0:0.01:1],[0:0.01:1]);
%         OccupMap_temp = OccupMap_temp/sum(OccupMap_temp(:));
% %         OccupMap_pre(i,k,1:101,1:101) = OccupMap_pre(i,k,:,:) + OccupMap_temp;
%         OccupMap_pre(1:101,1:101) = OccupMap_pre(:,:) + OccupMap_temp;
%     end % loop nb sess 
%     %Post-tests
%     for k=1:length(id_Post{i})
%                 % occupation map
%         [OccupMap_temp,xx,yy] = hist2d(Data(a{i}.behavResources(id_Post{i}(k)).AlignedXtsd),...
%             Data(a{i}.behavResources(id_Post{i}(k)).AlignedYtsd),[0:0.01:1],[0:0.01:1]);
%         OccupMap_temp = OccupMap_temp/sum(OccupMap_temp(:));
% %         OccupMap_post(i,k,1:101,1:101) = OccupMap_post(i,k,:,:) + OccupMap_temp;
%         OccupMap_post(1:101,1:101) = OccupMap_post(:,:) + OccupMap_temp;
%     end
% end

%% Get data by zones

%var init
trajzone_pre{length(a),8}=nan;
trajzone_post{length(a),8}=nan;

for i=1:length(a)
    for itrial=1:nbprepost(i)
        nzones = size(a{i}.behavResources(id_Pre{i}(itrial)).ZoneIndices,2)-2;
        for izone=1:nzones
            if izone<6
                trajzone_pre{i,itrial}(a{i}.behavResources(id_Pre{i}(itrial)).ZoneIndices{izone}) = izone;
                trajzone_post{i,itrial}(a{i}.behavResources(id_Post{i}(itrial)).ZoneIndices{izone}) = izone;
            else
                trajzone_pre{i,itrial}(a{i}.behavResources(id_Pre{i}(itrial)).ZoneIndices{izone+2}) = izone;
                trajzone_post{i,itrial}(a{i}.behavResources(id_Post{i}(itrial)).ZoneIndices{izone+2}) = izone;
            end   
            trajzone_pre_temp_id{i,itrial,izone} = find(trajzone_pre{i,itrial}(:)==izone);
            trajzone_pre_temp{i,itrial}(izone,trajzone_pre_temp_id{i,itrial,izone}) = 1;   
            trajzone_post_temp_id{i,itrial,izone} = find(trajzone_post{i,itrial}(:)==izone);
            trajzone_post_temp{i,itrial}(izone,trajzone_post_temp_id{i,itrial,izone}) = 1; 
        end
        trajzone_cumul_pre = cumsum(trajzone_pre_temp{i,itrial}');
        trajzone_pre_ratio{i,itrial} = trajzone_cumul_pre ./ sum(trajzone_cumul_pre,2);
        trajzone_cumul_post = cumsum(trajzone_post_temp{i,itrial}');
        trajzone_post_ratio{i,itrial} = trajzone_cumul_post ./ sum(trajzone_cumul_post,2);
        
        % re-order in a linear pattern for visualization
        if nzones == 7
            trajzone_pre_ratio{i,itrial} = trajzone_pre_ratio{i,itrial}(:,[1 4 6 3 7 5 2]);
            trajzone_post_ratio{i,itrial} = trajzone_post_ratio{i,itrial}(:,[1 4 6 3 7 5 2]);
        elseif nzones == 5
            trajzone_pre_ratio{i,itrial} = trajzone_pre_ratio{i,itrial}(:,[1 4 3 5 2]);
            trajzone_post_ratio{i,itrial} = trajzone_post_ratio{i,itrial}(:,[1 4 3 5 2]);
        end 
    end
    if cond
        for itrial=1:nbcond{i}
            nzones = size(a{i}.behavResources(id_Cond{i}(itrial)).ZoneIndices,2)-2; %there are two zones in position 6 and 7 that are not used. *sigh*
            for izone=1:nzones
                if izone<6
                    trajzone_cond{i,itrial}(a{i}.behavResources(id_Cond{i}(itrial)).ZoneIndices{izone}) = izone;
                else
                    trajzone_cond{i,itrial}(a{i}.behavResources(id_Cond{i}(itrial)).ZoneIndices{izone+2}) = izone;
                end
                trajzone_cond_temp_id{i,itrial,izone} = find(trajzone_cond{i,itrial}(:)==izone);
                trajzone_cond_temp{i,itrial}(izone,trajzone_cond_temp_id{i,itrial,izone}) = 1;  
            end
            trajzone_cumul_cond = cumsum(trajzone_cond_temp{i,itrial}');
            trajzone_cond_ratio{i,itrial} = trajzone_cumul_cond ./ sum(trajzone_cumul_cond,2);
            if nzones == 7
                trajzone_cond_ratio{i,itrial} = trajzone_cond_ratio{i,itrial}(:,[1 4 6 3 7 5 2]);
            elseif nzones == 5
                trajzone_cond_ratio{i,itrial} = trajzone_cond_ratio{i,itrial}(:,[1 4 3 5 2]);
            end
        end
    end
end

%% 
%==========================================================================
%
%                               F I G U R E S 
%
%==========================================================================

%--------------------------------------------------------------------------
%---------------- Trajectories + barplot + zone dynamics ------------------
%--------------------------------------------------------------------------
for i=1:length(a)
    if trajdyn
        supertit = ['Mouse ' num2str(Mice_to_analyze(i))  ' - trial dynamics'];
        figH_ind.trajdyn{i} = figure('Color',[1 1 1], 'rend','painters','pos',[10 10 2000 1400],'Name', supertit, 'NumberTitle','off')
        % prepare data visualization (stim, nostim for each trial in the same vector)   
    %         datpre = nan(8);
    %         datcond = nan(8);
    %         datpost = nan(8);
            itrial=1;
            for ii=1:3:ntrial_prepost
                datpre(ii) = squeeze(Pre_Occup(i,itrial,1));
                datpre(ii+1) = squeeze(Pre_Occup(i,itrial,2));
                datpre(ii+2) = nan;
                datpost(ii) = squeeze(Post_Occup(i,itrial,1));
                datpost(ii+1) = squeeze(Post_Occup(i,itrial,2));
                datpost(ii+2) = nan;
                itrial=itrial+1;
            end
            if cond
                itrial=1;
                for ii=1:3:nbcond{i}*3-2
                    datcond(ii) = squeeze(Cond_Occup(i,itrial,1));
                    datcond(ii+1) = squeeze(Cond_Occup(i,itrial,2));
                    datcond(ii+2) = nan;
                    itrial=itrial+1;
                end
            end
        % occupancy bar plot
            if cond
                subplot(5,12,1:4)
            else
                subplot(5,4,1:2)
            end
                [p_occ,h_occ, her_occ] = PlotErrorBarN_DB(datpre*100,...
                    'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'showpoints',0);
                h_occ.FaceColor = 'flat';
                h_occ.CData([2:3:23],:) = repmat([1 1 1],8,1);
                set(gca,'Xtick',[1:24],'XtickLabel',{'','t1','','','t2','','',...
                        't3','','','t4','','','t5','','','t6','','',...
                        't7','','','t8',''});
                set(gca, 'FontSize', 14);
                set(gca, 'LineWidth', 1);
                set(h_occ, 'LineWidth', 1);
                set(her_occ, 'LineWidth', 1);
                line(xlim,[21.5 21.5],'Color','k','LineStyle','--','LineWidth',1);
                ylabel('% time');
                ylim([0 100])
                title('Pre-tests')
            
            if cond
                subplot(5,12,5:8)          
                    [p_occ,h_occ, her_occ] = PlotErrorBarN_DB(datcond*100,...
                        'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'showpoints',0);
                    h_occ.FaceColor = 'flat';
                    if nbcond{i}==8
                        h_occ.CData([2:3:23],:) = repmat([1 1 1],8,1);
                        set(gca,'Xtick',[1:24],'XtickLabel',{'','t1','','','t2','','',...
                        't3','','','t4','','','t5','','','t6','','',...
                        't7','','','t8',''});
                    else
                        h_occ.CData([2 5 8 11],:) = repmat([1 1 1],4,1);
                        set(gca,'Xtick',[1:12],'XtickLabel',{'','trial 1','','','trial 2','','',...
                            'trial 3','','','trial 4',''});            
                    end 
                    set(gca, 'FontSize', 14);
                    set(gca, 'LineWidth', 1);
                    set(h_occ, 'LineWidth', 1);
                    set(her_occ, 'LineWidth', 1);
                    line(xlim,[21.5 21.5],'Color','k','LineStyle','--','LineWidth',1);
                    ylabel('% time');
                    ylim([0 100])
                    title('Cond')
            end
            
            if cond
                subplot(5,12,9:12)        
            else
                subplot(5,4,3:4)
            end
                [p_occ,h_occ, her_occ] = PlotErrorBarN_DB(datpost*100,...
                    'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'showpoints',0);
                h_occ.FaceColor = 'flat';
                h_occ.CData([2:3:23],:) = repmat([1 1 1],8,1);
                set(gca,'Xtick',[1:24],'XtickLabel',{'','t1','','','t2','','',...
                        't3','','','t4','','','t5','','','t6','','',...
                        't7','','','t8',''});
                set(gca, 'FontSize', 14);
                set(gca, 'LineWidth', 1);
                set(h_occ, 'LineWidth', 1);
                set(her_occ, 'LineWidth', 1);
                line(xlim,[21.5 21.5],'Color','k','LineStyle','--','LineWidth',1);
                ylabel('% time');
                ylim([0 100])   
                title('Post-tests')
        % Cumul occupancy
            for itrial=1:4
         % Pre
                if cond
                    subplot(5,12,itrial+12)   
                else
                    subplot(5,4,itrial+4)
                end
                    area(trajzone_pre_ratio{i,itrial}*100)
                    ylim([0 100])
                    xlim([1 size(trajzone_pre_ratio{i,itrial},1)])
                    title(['Trial #' num2str(itrial)])
                    if itrial==1
                        xlabel('time')
                        ylabel('% of occupancy')
                        axP = get(gca,'Position');
                        if nzones == 7 
                            legend({'Stim','Stim-Near','Stim-Far',...
                                'Center','NoStim-Far','NoStim-Near','NoStim'},'Location','WestOutside')
                        elseif nzones == 5
                            legend({'Stim','Stim-Far',...
                                'Center','NoStim-Far','NoStim'},'Location','WestOutside')  
                        end
                        set(gca, 'Position', axP)
                    end
                
                if cond
                    if nbcond{i}==8
                        subplot(5,12,itrial+24)   
                    else
                        subplot(5,6,itrial+12)  
                    end  
                else
                    subplot(5,4,itrial+8)
                end
                    area(trajzone_pre_ratio{i,itrial+4}*100)
                    ylabel('% of occupancy')
                    ylim([0 100])
                    xlim([1 size(trajzone_pre_ratio{i,itrial+4},1)])
                    title(['Trial #' num2str(itrial+4)])
                    if itrial==1
                        xlabel('time')
                        ylabel('% of occupancy')
                    end               
            end
            
            if cond
                % Cond
                for itrial=1:nbcond{i}/2    %allow for cond with 4 and 8 trials
                    subplot(5,12,itrial+16)
                        area(trajzone_cond_ratio{i,itrial}*100)
                        ylim([0 100])
                        xlim([1 size(trajzone_cond_ratio{i,itrial},1)])
                        title(['Trial #' num2str(itrial)])

                        if nbcond{i}==8
                            subplot(5,12,itrial+28)   
                        else
                            subplot(5,6,itrial+14)  
                        end 
                        area(trajzone_cond_ratio{i,itrial+nbcond{i}/2}*100)
                        ylim([0 100])
                        xlim([1 size(trajzone_cond_ratio{i,itrial+nbcond{i}/2},1)])
                        title(['Trial #' num2str(itrial+nbcond{i}/2)])
                end
            end
            
            
            for itrial=1:4
            % post    
                if cond
                    subplot(5,12,itrial+20) 
                else
                    subplot(5,4,itrial+6) 
                end
                    area(trajzone_post_ratio{i,itrial}*100)
                    ylim([0 100])
                    xlim([1 size(trajzone_post_ratio{i,itrial},1)])
                    title(['Trial #' num2str(itrial)])

                    if cond    
                        subplot(5,12,itrial+32) 
                    else
                        subplot(5,4,itrial+10)
                    end
                    area(trajzone_post_ratio{i,itrial+4}*100)
                    ylim([0 100])
                    xlim([1 size(trajzone_post_ratio{i,itrial+4},1)])
                    title(['Trial #' num2str(itrial+4)])

                % -------- Distance to reward zone ---------
                % Pre
                if cond
                    subplot(5,12,itrial+36)   
                else
                    subplot(5,4,itrial+12)
                end
                    p = plot(Data(a{i}.behavResources(id_Pre{i}(itrial)).LinearDist), 'Color','k');
                    hold on
                    f_draw_zones(Data(a{i}.behavResources(id_Pre{i}(itrial)).LinearDist),nzones)
                    uistack(p,'top')
                    xlim([1 length(Data(a{i}.behavResources(id_Pre{i}(itrial)).LinearDist))])
                    title(['Trial #' num2str(itrial)])
                    if itrial==1
                        if nzones == 7
                            set(gca,'Ytick',[0 .1 .28 .4 .5 .6 .72 .9 1],'YtickLabel',{'','Stim','Stim-Near',...
                                'Stim-Far','Center','NoStim-Far','NoStim-Near','NoStim',''});
                        elseif nzones == 5
                            set(gca,'Ytick',[0 .1 .3 .5 .7 .9 1],'YtickLabel',{'','Stim',...
                                'Stim-Far','Center','NoStim-Far','NoStim',''});
                        end

                        xlabel('Time')
                    else
                        set(gca,'YTickLabel',[]);
                    end
                
                if cond    
                    subplot(5,12,itrial+48) 
                else
                    subplot(5,4,itrial+16)
                end
                    p=plot(Data(a{i}.behavResources(id_Pre{i}(itrial+4)).LinearDist),'Color','k');
                    hold on
                    f_draw_zones(Data(a{i}.behavResources(id_Pre{i}(itrial+4)).LinearDist),nzones)
                    uistack(p,'top')
                    xlim([1 length(Data(a{i}.behavResources(id_Pre{i}(itrial+4)).LinearDist))])
                    title(['Trial #' num2str(itrial+4)])
                    if itrial==1
                        if nzones == 7
                            set(gca,'Ytick',[0 .1 .28 .4 .5 .6 .72 .9 1],'YtickLabel',{'','Stim','Stim-Near',...
                                'Stim-Far','Center','NoStim-Far','NoStim-Near','NoStim',''});
                        elseif nzones == 5
                            set(gca,'Ytick',[0 .1 .3 .5 .7 .9 1],'YtickLabel',{'','Stim',...
                                'Stim-Far','Center','NoStim-Far','NoStim',''});
                        end  
                        xlabel('Time')
                    else
                        set(gca,'YTickLabel',[]);
                    end
            end
            
            
            % cond
            if cond
                for itrial=1:nbcond{i}/2 
                    subplot(5,12,itrial+40)
                        p=plot(Data(a{i}.behavResources(id_Cond{i}(itrial)).LinearDist),'Color','k');
                        hold on
                        f_draw_zones(Data(a{i}.behavResources(id_Cond{i}(itrial)).LinearDist),nzones)
                        uistack(p,'top')
                        xlim([1 length(Data(a{i}.behavResources(id_Cond{i}(itrial)).LinearDist))])
                        title(['Trial #' num2str(itrial)])
                        set(gca,'YTickLabel',[]);

                    subplot(5,12,itrial+52)  
                        p=plot(Data(a{i}.behavResources(id_Cond{i}(itrial+nbcond{i}/2)).LinearDist),'Color','k');
                        hold on
                        f_draw_zones(Data(a{i}.behavResources(id_Cond{i}(itrial+nbcond{i}/2)).LinearDist),nzones)
                        uistack(p,'top')
                        xlim([1 length(Data(a{i}.behavResources(id_Cond{i}(itrial+nbcond{i}/2)).LinearDist))])
                        title(['Trial #' num2str(itrial+nbcond{i}/2)])
                        set(gca,'YTickLabel',[]);
                end
            end
            
            % Post
            for itrial=1:4
                if cond
                    subplot(5,12,itrial+44)   
                else
                    subplot(5,4,itrial+14)
                end
                    p=plot(Data(a{i}.behavResources(id_Post{i}(itrial)).LinearDist),'Color','k');
                    hold on
                    f_draw_zones(Data(a{i}.behavResources(id_Post{i}(itrial)).LinearDist),nzones)
                    uistack(p,'top')
                    xlim([1 length(Data(a{i}.behavResources(id_Post{i}(itrial)).LinearDist))])
                    title(['Trial #' num2str(itrial)])
                    set(gca,'YTickLabel',[]);

                if cond
                    subplot(5,12,itrial+56)  
                else
                    subplot(5,4,itrial+56)
                end
                    p =plot(Data(a{i}.behavResources(id_Post{i}(itrial+4)).LinearDist),'Color','k');
                    hold on
                    f_draw_zones(Data(a{i}.behavResources(id_Post{i}(itrial+4)).LinearDist),nzones)
                    uistack(p,'top')
                    xlim([1 length(Data(a{i}.behavResources(id_Post{i}(itrial+4)).LinearDist))])
                    title(['Trial #' num2str(itrial+4)])
                    set(gca,'YTickLabel',[]);

            end
              % Supertitle
            mtit(supertit, 'fontsize',14, 'xoff', 0, 'yoff', 0.05);
    end
    
    %----------------------------------------------------------------------
    %--------------------FIGURE FIRST ENTRY BY MOUSE-----------------------
    %----------------------------------------------------------------------
    if firstentry 
        supertit = ['Mouse ' num2str(Mice_to_analyze(i))  ' - Latency to first entry'];
        figH_ind.firstentry{i} = figure('Color',[1 1 1], 'rend','painters','pos',[10 10 1300 600],'Name', supertit, 'NumberTitle','off')
            pre_max=Pre_FirstTime;
            post_max=Post_FirstTime;
            pre_max(pre_max==240)=0;
            post_max(post_max==240)=0;
            
            max_y = max(max([post_max post_max]));
            max_y=max_y+max_y*.15; 
            %pre
            subplot(1,2,1)
                [p_occ,h_occ, her_occ] = PlotErrorBarN_SL(Pre_FirstTime(i,1:ntrial_prepost),...
                    'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'showPoints',0);
                    ylim([0 max_y])
                    if ntrial_prepost == 4
                        set(gca,'Xtick',[1:4],'XtickLabel',{'trial 1','trial 2',...
                            'trial 3','trial 4'});
                    else
                        set(gca,'Xtick',[1:8],'XtickLabel',{'','t1','','','t2','','',...
                        't3','','','t4','','','t5','','','t6','','',...
                        't7','','','t8',''});
                    end                        
                    set(gca, 'FontSize', 14);
                    set(gca, 'LineWidth', 1);
                    set(h_occ, 'LineWidth', 1);
                    set(her_occ, 'LineWidth', 1);
                    ylabel('time (s)');
                    title('Pre-Tests latency')
                    
            %post        
            subplot(1,2,2)
                [p_occ,h_occ, her_occ] = PlotErrorBarN_SL(Post_FirstTime(i,1:ntrial_prepost),...
                    'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'showPoints',0);
                    ylim([0 max_y])
                    if ntrial_prepost == 4
                        set(gca,'Xtick',[1:4],'XtickLabel',{'trial 1','trial 2',...
                            'trial 3','trial 4'});
                    else
                        set(gca,'Xtick',[1:8],'XtickLabel',{'','t1','','','t2','','',...
                        't3','','','t4','','','t5','','','t6','','',...
                        't7','','','t8',''});
                    end     
                    set(gca, 'FontSize', 14);
                    set(gca, 'LineWidth', 1);
                    set(h_occ, 'LineWidth', 1);
                    set(her_occ, 'LineWidth', 1);
                    ylabel('time (s)');
                    title('Post-Tests latency')
                      % Supertitle
            mtit(['M' num2str(Mice_to_analyze(i))], 'fontsize',14, 'xoff', -.6, 'yoff', 0,'color',	[0, 0.4470, 0.7410]);        
      
    end


    % Trajectories, barplot (stim/no-stim) per mouse   
    if trajoccup    
            supertit = ['Mouse ' num2str(Mice_to_analyze(i))  ' - Trajectories'];
            figH_ind.trajoccup{i} = figure('Color',[1 1 1], 'rend','painters','pos',[1 1 2000 1200],'Name', supertit, 'NumberTitle','off')

                subplot(3,3,1) 
                    for k=1:nbprepost(i)    
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
                    xlim([-0.05 1.05])    
                    ylim([-0.05 1.05])
                    title('Pre-tests')
                    % constructing the u maze
                    f_draw_umaze
                    %legend
                    axP = get(gca,'Position');
                    %lg = legend(p1([nbcond{i}]),num2cell(1:nbcond{i}),'Location','WestOutside');
                    lg = legend(p1([1:8]),sprintfc('%d',1:8),'Location','WestOutside');
                    title(lg,'Trial #')
                    set(gca, 'Position', axP)
                if cond
                    subplot(3,3,2) 

                        for k=1:nbcond{i}   
                            % -- trajectories    
                            p2(k) = plot(Data(a{i}.behavResources(id_Cond{i}(k)).AlignedXtsd),...
                                Data(a{i}.behavResources(id_Cond{i}(k)).AlignedYtsd),...
                                     'linewidth',.5);  
                            hold on
                            tempX = Data(a{i}.behavResources(id_Cond{i}(k)).AlignedXtsd);
                            tempY = Data(a{i}.behavResources(id_Cond{i}(k)).AlignedYtsd);
                            plot(tempX(a{i}.behavResources(id_Cond{i}(k)).PosMat(:,4)==1),tempY(a{i}.behavResources(id_Cond{i}(k)).PosMat(:,4)==1),...
                                'p','Color','k','MarkerFaceColor','g','MarkerSize',16);
                            clear tempX tempY
                        end
                        axis off
                        xlim([-0.05 1.05])    
                        ylim([-0.05 1.05])
                        title('Cond')   
                        % constructing the u maze
                        f_draw_umaze   
                end

                subplot(3,3,3) 
                    for k=1:nbprepost(i) 
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
                    xlim([-0.05 1.05])    
                    ylim([-0.05 1.05])
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
                if cond
                    subplot(3,3,5)
                        [p_occ,h_occ, her_occ] = PlotErrorBarN_DB([squeeze(Cond_Occup(i,1:nbcond{i},1))'*100 squeeze(Cond_Occup(i,1:nbcond{i},2))'*100],...
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
                end

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
                if cond
                    itrial=1;
                    for ii=1:3:nbcond{i}*3-2
                        datcond(ii) = squeeze(Cond_Occup(i,itrial,1));
                        datcond(ii+1) = squeeze(Cond_Occup(i,itrial,2));
                        datcond(ii+2) = nan;
                        itrial=itrial+1;
                    end
                end

                subplot(3,3,7)
                    [p_occ,h_occ, her_occ] = PlotErrorBarN_DB(datpre*100,...
                        'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'showpoints',0);
                    h_occ.FaceColor = 'flat';
                    h_occ.CData([2:3:23],:) = repmat([1 1 1],8,1);
                    set(gca,'Xtick',[1:24],'XtickLabel',{'','t1','','','t2','','',...
                        't3','','','t4','','','t5','','','t6','','',...
                        't7','','','t8',''});
                    set(gca, 'FontSize', 14);
                    set(gca, 'LineWidth', 1);
                    set(h_occ, 'LineWidth', 1);
                    set(her_occ, 'LineWidth', 1);
                    line(xlim,[21.5 21.5],'Color','k','LineStyle','--','LineWidth',1);
                    ylabel('% time');
                    ylim([0 100])
                
                if cond
                    subplot(3,3,8)
                        [p_occ,h_occ, her_occ] = PlotErrorBarN_DB(datcond*100,...
                            'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'showpoints',0);
                        h_occ.FaceColor = 'flat';
                        if nbcond{i}==8
                            h_occ.CData([2:3:23],:) = repmat([1 1 1],8,1);
                            set(gca,'Xtick',[1:24],'XtickLabel',{'','t1','','','t2','','',...
                        't3','','','t4','','','t5','','','t6','','',...
                        't7','','','t8',''});
                        else
                            h_occ.CData([2 5 8 11],:) = repmat([1 1 1],4,1);
                            set(gca,'Xtick',[1:12],'XtickLabel',{'','trial 1','','','trial 2','','',...
                                'trial 3','','','trial 4',''});            
                        end 
                        set(gca, 'FontSize', 14);
                        set(gca, 'LineWidth', 1);
                        set(h_occ, 'LineWidth', 1);
                        set(her_occ, 'LineWidth', 1);
                        line(xlim,[21.5 21.5],'Color','k','LineStyle','--','LineWidth',1);
                        ylabel('% time');
                        ylim([0 100])
                end

                subplot(3,3,9)
                    [p_occ,h_occ, her_occ] = PlotErrorBarN_DB(datpost*100,...
                        'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'showpoints',0);
                    h_occ.FaceColor = 'flat';
                    h_occ.CData([2:3:23],:) = repmat([1 1 1],8,1);
                    set(gca,'Xtick',[1:24],'XtickLabel',{'','t1','','','t2','','',...
                        't3','','','t4','','','t5','','','t6','','',...
                        't7','','','t8',''});
                    set(gca, 'FontSize', 14);
                    set(gca, 'LineWidth', 1);
                    set(h_occ, 'LineWidth', 1);
                    set(her_occ, 'LineWidth', 1);
                    line(xlim,[21.5 21.5],'Color','k','LineStyle','--','LineWidth',1);
                    ylabel('% time');
                    ylim([0 100])   
                    hold on


                % Supertitle
                mtit(supertit, 'fontsize',14, 'xoff', 0, 'yoff', 0.05);


                clear datpre datpost 
                if cond
                    clear datcond
                end
    end 
end


%% Plot all mice
%--------------------------------------------------------------------------
%----------------------GENERAL BASIC STATS---------------------------------
%--------------------------------------------------------------------------

if globalstats
    figH.globalstats = figure('units', 'normalized', 'outerposition', [0 0 0.65 0.65]);
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
        text(2.3,23.2,'Random Occupancy','FontSize',8);
        ylabel('% time');
        title('Occupancy in rewarded zone', 'FontSize', 14);
        ylim([0 max(max([Pre_Occup_stim_mean*100 Post_Occup_stim_mean*100]))*1.2])
        makepretty_erc
        
        axes(NumEntr_Axes);
        % set y max
        ymax = max(max([Pre_entnum_mean Post_entnum_mean]))+(max(max([Pre_entnum_mean Post_entnum_mean]))*.15);
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
        title('Nbr of entries to the rewarded zone', 'FontSize', 14);
        ylim([0 ymax])
        makepretty_erc
        
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
        ylim([0 max(max([Pre_FirstTime_mean Post_FirstTime_mean]))*1.2])
        makepretty_erc
        
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
        ylim([0 max(max([Pre_VZmean_mean Post_VZmean_mean]))*1.2])
        makepretty_erc
end


%--------------------------------------------------------------------------
%---------------------------HEATMAPS - PRE VS POST-------------------------
%--------------------------------------------------------------------------
if heatmaps
    % calculate occupancy means
    x_pre_mean = squeeze(mean(mean(x_pre,1)));
    y_pre_mean = squeeze(mean(mean(y_pre,1)));
    occHS_pre_mean = squeeze(mean(mean(occHS_pre,1)));
    x_post_mean = squeeze(mean(mean(x_post,1)));
    y_post_mean = squeeze(mean(mean(y_post,1)));
    occHS_post_mean = squeeze(mean(mean(occHS_post,1)));
    if cond
        x_cond_mean = squeeze(mean(mean(x_Cond,1)));
        y_cond_mean = squeeze(mean(mean(y_Cond,1)));
        occHS_cond_mean = squeeze(mean(mean(occHS_Cond,1)));
    end

    figH.heatmaps = figure('Color',[1 1 1], 'render','painters','position',[10 10 1600 375])
        % occupancy
        subplot(1,3,1)
            imagesc([1:320],[1:240],flip(squeeze(occHS_pre_mean))) 
            caxis([0 .008]) % control color intensity here
            colormap(hot)
            axis off
            set(gca, 'XTickLabel', []);
            set(gca, 'YTickLabel', []);
            t_str = {'PRE-TESTS'};
            title(t_str, 'FontSize', 14, 'interpreter','latex',...
             'HorizontalAlignment', 'center');
            %add visuals
            rectangle('Position',[115 48 90 193], 'FaceColor',[1 1 1]) % center
            rectangle('Position',[1 160 114 80], 'EdgeColor',[0 1 0],'LineWidth',1.5) % stim zone

        if cond
            subplot(1,3,2)
                imagesc([1:320],[1:240],flip(squeeze(occHS_cond_mean))) 
                caxis([0 .008]) % control color intensity here
                colormap(hot)
                axis off
                set(gca, 'XTickLabel', []);
                set(gca, 'YTickLabel', []);
                t_str = {'COND'};
                title(t_str, 'FontSize', 14, 'interpreter','latex',...
                 'HorizontalAlignment', 'center');  
                %add visuals
                rectangle('Position',[115 48 90 193], 'FaceColor',[1 1 1]) % center
                rectangle('Position',[1 160 114 80], 'EdgeColor',[0 1 0],'LineWidth',1.5) % stim zone
        end

        subplot(1,3,3)
            imagesc([1:320],[1:240],flip(squeeze(occHS_post_mean))) 
            caxis([0 .008]) % control color intensity here
            colormap(hot)
            axis off
            set(gca, 'XTickLabel', []);
            set(gca, 'YTickLabel', []);
            t_str = {'POST-TESTS'};
            title(t_str, 'FontSize', 14, 'interpreter','latex',...
             'HorizontalAlignment', 'center'); 
            %add visuals
            rectangle('Position',[115 48 90 193], 'FaceColor',[1 1 1]) % center
            rectangle('Position',[1 160 114 80], 'EdgeColor',[0 1 0],'LineWidth',1.5) % stim zone

end

%--------------------------------------------------------------------------
%-------------------------TRAJECTORIES ALL MICE----------------------------
%--------------------------------------------------------------------------      
    
if traj_all
    supertit = 'Post-test trajectories per trial';
    figH.traj_all = figure('Color',[1 1 1], 'rend','painters','pos',[1 1 2100 600],'Name', supertit, 'NumberTitle','off');
        for itrial=1:8
            subplot(2,8,itrial) 
                for i=1:length(a)
                    if itrial<=nbprepost(i)
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

                        xlim([-.05 1.05])
                        ylim([-.05 1.05])
                        title(['Trial #' num2str(itrial)])
                        % constructing the u maze
                        f_draw_umaze 
                        if itrial == 1 && i== length(a)
                            axP = get(gca,'Position');
                            mice_str = cellstr(string(Mice_to_analyze)); 
                            lg = legend(p1([1:length(Mice_to_analyze)]),mice_str,'Location','WestOutside');
                            title(lg,'Mice')
                            set(gca, 'Position', axP)
                        end
                    end
                end


            subplot(2,8,itrial+8)
%                 if length(Mice_to_analyze)>1
%                     [p_occ,h_occ, her_occ] = PlotErrorBarN_SL([Post_Occup_stim(:,itrial)*100 Post_Occup_nostim(:,itrial)*100],...
%                     'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'colorpoints',1,'optiontest','ttest','norm',0);
%                 else
                    [p_occ,h_occ, her_occ] = PlotErrorBarN_SL([Post_Occup_stim(:,itrial)*100 Post_Occup_nostim(:,itrial)*100],...
                    'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'paired',0, 'colorpoints',1);
%                 end
                h_occ.FaceColor = 'flat';
                h_occ.CData(2,:) = [1 1 1];
                set(gca,'Xtick',[1:2],'XtickLabel',{'Stim', 'No-stim'});
                xtickangle(45)
                set(gca, 'FontSize', 12);
                set(gca, 'LineWidth', 1.5);
                set(h_occ, 'LineWidth', 1.5);
                set(her_occ, 'LineWidth', 1.5);
                ylabel('% time');
                ylim([0 100])    
                makepretty
        end

end   

% figure('Color',[1 1 1], 'render','painters','position',[10 10 1700 1000])
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
%     
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
%     subplot(2,3,2) 
%         for k=1:4   
%             % -- trajectories    
%             p2 = plot(Data(a{2}.behavResources(id_Cond{2}(k)).AlignedXtsd),...
%                 Data(a{2}.behavResources(id_Cond{2}(k)).AlignedYtsd),...
%                     'linewidth',1.5);  
%             box off
%             hold on 
%         end
%         axis off
%         xlim([0 1])    
%         ylim([0 1])
%         t_str = {'CONDITIONING (4x8 min)'};
%         title(t_str, 'FontSize', 15, 'interpreter','latex',...
%             'HorizontalAlignment', 'center'); 
%         f_draw_umaze 
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
%         lg = legend(p3([length(Mice_to_analyze)]),'1','2','3','4','Location','EastOutside');
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
%     subplot(2,3,5)
%         [p_occ,h_occ, her_occ] = PlotErrorBarN_DB([Cond_Occup_stim_mean*100 Cond_Occup_nostim_mean*100],...
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
    
%--------------------------------------------------------------------------
%---------------------------HEATMAPS - PRE VS POST-------------------------
%--------------------------------------------------------------------------
% set figures text format
% set(0,'defaulttextinterpreter','latex');
% set(0,'DefaultTextFontname', 'Arial')
% set(0,'DefaultAxesFontName', 'Arial')
% set(0,'defaultTextFontSize',14)
% set(0,'defaultAxesFontSize',14)
if finalfig
    % calculate occupancy means
    x_pre_mean = squeeze(mean(mean(x_pre,1)));
    y_pre_mean = squeeze(mean(mean(y_pre,1)));
    occHS_pre_mean = squeeze(mean(mean(occHS_pre,1)));
    x_post_mean = squeeze(mean(mean(x_post,1)));
    y_post_mean = squeeze(mean(mean(y_post,1)));
    occHS_post_mean = squeeze(mean(mean(occHS_post,1)));
    if cond
        x_cond_mean = squeeze(mean(mean(x_Cond,1)));
        y_cond_mean = squeeze(mean(mean(y_Cond,1)));
        occHS_cond_mean = squeeze(mean(mean(occHS_Cond,1)));
    end

    figH.finalfig = figure('Color',[1 1 1], 'render','painters','position',[10 10 1900 375])
        % occupancy
        subplot(1,4,1)
            imagesc([1:320],[1:240],flip(squeeze(occHS_pre_mean))) 
            caxis([0 .008]) % control color intensity here
            colormap(hot)
            axis off
            set(gca, 'XTickLabel', []);
            set(gca, 'YTickLabel', []);
            t_str = {'Pre-tests'};
            title(t_str, 'FontSize', 14, 'interpreter','latex',...
             'HorizontalAlignment', 'center');
            %add visuals
            rectangle('Position',[115 48 90 193], 'FaceColor',[1 1 1]) % center
            rectangle('Position',[1 160 114 80], 'EdgeColor',[0 1 0],'LineWidth',1.5) % stim zone

        if cond
            subplot(1,4,2)
                imagesc([1:320],[1:240],flip(squeeze(occHS_cond_mean))) 
                caxis([0 .008]) % control color intensity here
                colormap(hot)
                axis off
                set(gca, 'XTickLabel', []);
                set(gca, 'YTickLabel', []);
                t_str = {'Cond'};
                title(t_str, 'FontSize', 14, 'interpreter','latex',...
                 'HorizontalAlignment', 'center');  
                %add visuals
                rectangle('Position',[115 48 90 193], 'FaceColor',[1 1 1]) % center
                rectangle('Position',[1 160 114 80], 'EdgeColor',[0 1 0],'LineWidth',1.5) % stim zone
        end

        subplot(1,4,3)
            imagesc([1:320],[1:240],flip(squeeze(occHS_post_mean))) 
            caxis([0 .008]) % control color intensity here
            colormap(hot)
            axis off
            set(gca, 'XTickLabel', []);
            set(gca, 'YTickLabel', []);
            t_str = {'Post-tests'};
            title(t_str, 'FontSize', 14, 'interpreter','latex',...
             'HorizontalAlignment', 'center'); 
            %add visuals
            rectangle('Position',[115 48 90 193], 'FaceColor',[1 1 1]) % center
            rectangle('Position',[1 160 114 80], 'EdgeColor',[0 1 0],'LineWidth',1.5) % stim zone
        
        voidtmp = nan(length(Dir.path),1);    
        subplot(1,4,4)
%             [p_occ,h_occ, her_occ] = PlotErrorBarN_DB([Pre_Occup_stim_mean*100 Pre_Occup_nostim_mean*100 voidtmp  Cond_Occup_stim_mean*100 Cond_Occup_nostim_mean*100 voidtmp Post_Occup_stim_mean*100 Post_Occup_nostim_mean*100],...
%                 'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'showpoints',0);
%             set(gca,'Xtick',[1:8],'XtickLabel',{'        Pre', '','',...
%                 '        Cond', '','', ...
%                 '        Post', ''});
            [p_occ,h_occ, her_occ] = PlotErrorBarN_DB([Pre_Occup_stim_mean*100  Cond_Occup_stim_mean*100 Post_Occup_stim_mean*100],...
                'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'showpoints',0);
            set(gca,'Xtick',[1:3],'XtickLabel',{'Pre','Cond','Post',});
%             h_occ.FaceColor = 'flat';
%             h_occ.CData(2,:) = [1 1 1];
%             h_occ.CData(5,:) = [1 1 1];
%             h_occ.CData(8,:) = [1 1 1];
            set(gca, 'FontSize', 12);
            set(gca, 'LineWidth', 1);
            set(h_occ, 'LineWidth', 1);
            set(her_occ, 'LineWidth', 1);
            ylabel('% time');
            ylim([0 85])
            t_str = {'Time spent in stim zone by session'};
            title(t_str, 'FontSize', 14, 'interpreter','latex',...
             'HorizontalAlignment', 'center'); 
%             % creating legend with hidden-fake data (hugly but effective)
%                 b2=bar([-2],[ 1],'FaceColor','flat');
%                 b1=bar([-3],[ 1],'FaceColor','flat');
%                 b1.CData(1,:) = repmat([0 0 0],1);
%                 b2.CData(1,:) = repmat([1 1 1],1);
%                 legend([b1 b2],{'Stim','No-stim'})%,'Location','EastOutside')
            

end          
            
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

            subplot(2,6,1:2), imagesc(occup_pre_glob), axis xy
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
                %add visuals
                f_draw_umaze2(sizeMapx,sizeMapy)

            subplot(2,6,3:4), imagesc(occup_cond_glob), axis xy
                caxis([0 .08]);
                t_str = 'Conditioning'; 
                title(t_str, 'FontSize', 13, 'interpreter','latex',...
                        'HorizontalAlignment', 'center');
                colormap(gca,'hot')
                set(gca,'xtick',[])
                set(gca,'ytick',[])  
                hold on
                %add visuals
                f_draw_umaze2(sizeMapx,sizeMapy)

            subplot(2,6,5:6), imagesc(occup_post_glob), axis xy
                caxis([0 .08]);
                t_str = 'Post-tests'; 
                title(t_str, 'FontSize', 13, 'interpreter','latex',...
                        'HorizontalAlignment', 'center');
                colormap(gca,'hot')
                set(gca,'xtick',[])
                set(gca,'ytick',[])  
                hold on
                %add visuals
                f_draw_umaze2(sizeMapx,sizeMapy)


            subplot(2,6,8:9), imagesc(squeeze(tsig)), axis xy
                caxis([-1*max(max(squeeze(tsig))) max(max(squeeze(tsig)))]);
                t_str = {'Significant changes'; 'in occupancy post- vs pre-tests'}; 
                title(t_str, 'FontSize', 13, 'interpreter','latex',...
                        'HorizontalAlignment', 'center');

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
            subplot(2,6,10:11)
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
                ylim([0 85])
                t_str = {'Time spent in zones by session'};
                title(t_str, 'FontSize', 14, 'interpreter','latex',...
                 'HorizontalAlignment', 'center'); 
                % creating legend with hidden-fake data (hugly but effective)
                    b2=bar([-2],[ 1],'FaceColor','flat');
                    b1=bar([-3],[ 1],'FaceColor','flat');
                    b1.CData(1,:) = repmat([0 0 0],1);
                    b2.CData(1,:) = repmat([1 1 1],1);
                    legend([b1 b2],{'Stim','No-stim'})

    end
end
    
    

%% 
%==========================================================================
%                               FUNCTIONS
%==========================================================================

% DRAWING UMAZE SHAPE
function f_draw_umaze
    % constructing the u maze
    line([-.05 -.05],[-.05 1.05],'Color','black','LineWidth',2) % left outside arm
    line([1.05 1.05],[-.05 1.05],'Color','black','LineWidth',2) % right outside arm
    line([-.05 .4],[-.05 -.05],'Color','black','LineWidth',2) % bottom left outside
    line([.6 1.05],[-.05 -.05],'Color','black','LineWidth',2) % bottom right outside
    line([.4 .4],[-.05 .7],'Color','black','LineWidth',2) % left inside arm
    line([.6 .6],[-.05 .7],'Color','black','LineWidth',2) % right inside arm
    line([.4 .6],[.7 .7],'Color','black','LineWidth',2) % center inside arm
    line([-.05 1.05],[1.05 1.05],'Color','black','LineWidth',2) % up outside
    % stim zone
    line([-0.051 -.051],[-.05 .35],'Color','green','LineWidth',1.5) % left stim
    line([.3995 .3995],[-.05 .35],'Color','green','LineWidth',1.5) % right stim
    line([-0.051 .3995],[-.05 -.05],'Color','green','LineWidth',1.5) % top stim
    line([-0.051 .3995],[.35 .35],'Color','green','LineWidth',1.5) % bottom stim    
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