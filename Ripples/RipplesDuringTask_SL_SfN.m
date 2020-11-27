%% Parameters
sav=1;
old = 0;
ntrial = 4;  %nbr of pre, post and cond trials

% Directory to save and name of the figure to save
dir_out = '/home/mobs/Dropbox/MOBS_workingON/Sam/StimMFBWake/ripples/SfN/';

%set folders
if ~exist(dir_out,'dir')
    mkdir(dir_out);
end

Dir = PathForExperimentsERC_SL('StimMFBWake');
Dir = RestrictPathForExperiment(Dir, 'nMice', [936 941]);
set(0,'defaulttextinterpreter','none');
% set text format
% set(0,'defaulttextinterpreter','latex');
% set(0,'DefaultTextFontname', 'Arial')
% set(0,'DefaultAxesFontName', 'Arial')
% set(0,'defaultAxesFontSize',10)

%#####################################################################
%#
%#                           M A I N
%#
%#####################################################################

%% Get Data
for i = 1:length(Dir.path)
        Rip{i} = load([Dir.path{i}{1} 'Ripples.mat'], 'ripples');
        a{i} = load([Dir.path{i}{1} '/behavResources.mat'], 'behavResources', 'SessionEpoch', 'ZoneEpoch', 'FreezeAccEpoch');
end

%% Find indices of PreTests and PostTest session in the structure
id_Pre = cell(1,length(a));
id_Post = cell(1,length(a));
id_Cond = cell(1,length(a));

for i=1:length(a)
    id_Pre{i} = zeros(1,length(a{i}.behavResources));
    id_Cond{i} = zeros(1,length(a{i}.behavResources));
    id_Post{i} = zeros(1,length(a{i}.behavResources));
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
    id_Cond{i}=find(id_Cond{i});
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
    
    for k=1:length(id_Cond{i})
        for t=1:length(a{i}.behavResources(id_Cond{i}(k)).Zone)
            Cond_Occup(i,k,t)=size(a{i}.behavResources(id_Cond{i}(k)).ZoneIndices{t},1)./...
                size(Data(a{i}.behavResources(id_Cond{i}(k)).Xtsd),1);
        end
    end
end
Pre_Occup = squeeze(Pre_Occup(:,:,1));
Post_Occup = squeeze(Post_Occup(:,:,1));
Cond_Occup_Shock = squeeze(Cond_Occup(:,:,1));
Cond_Occup_Safe = squeeze(Cond_Occup(:,:,2));

Pre_Occup_mean = mean(Pre_Occup,2);
Pre_Occup_std = std(Pre_Occup,0,2);
Post_Occup_mean = mean(Post_Occup,2);
Post_Occup_std = std(Post_Occup,0,2);

Cond_Occup_Shock_mean = mean(Cond_Occup_Shock,2);
Cond_Occup_Safe_mean = mean(Cond_Occup_Safe,2);
% Wilcoxon signed rank task between Pre and PostTest
p_pre_post = signrank(Pre_Occup_mean, Post_Occup_mean);

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
            Pre_entnum_shock(i,k) = 0;
        else
            Pre_entnum_shock(i,k)=length(find(diff(a{i}.behavResources(id_Pre{i}(k)).ZoneIndices{1})>1))+1;
        end
    end
    
    for k=1:length(id_Post{i})   
        if isempty(a{i}.behavResources(id_Post{i}(k)).ZoneIndices{1})
            Post_entnum_shock(i,k) = 0;
        else
            Post_entnum_shock(i,k)=length(find(diff(a{i}.behavResources(id_Post{i}(k)).ZoneIndices{1})>1))+1;
        end
    end
    
    for k=1:length(id_Cond{i})   
        if isempty(a{i}.behavResources(id_Cond{i}(k)).ZoneIndices{1})
            Cond_entnum_shock(i,k) = 0;
        else
            Cond_entnum_shock(i,k)=length(find(diff(a{i}.behavResources(id_Post{i}(k)).ZoneIndices{1})>1))+1;
        end
    end
    
end
Pre_entnum_shock_mean = mean(Pre_entnum_shock,2);
Pre_entnum_shock_std = std(Pre_entnum_shock,0,2);
Post_entnum_shock_mean = mean(Post_entnum_shock,2);
Post_entnum_shock_std = std(Post_entnum_shock,0,2);
Cond_entnum_shock_mean = mean(Cond_entnum_shock,2);
Cond_entnum_shock_std = std(Cond_entnum_shock,0,2);
% Wilcoxon test
p_entnum_shock_pre_post = signrank(Pre_entnum_shock_mean, Post_entnum_shock_mean);

%% Calculate number of entries into the shock zone
% Check with smb if it's correct way to calculate (plus one entry even if one frame it was outside )
for i = 1:length(a)
    for k=1:length(id_Pre{i})
        if isempty(a{i}.behavResources(id_Pre{i}(k)).ZoneIndices{2})
            Pre_entnum_safe(i,k) = 0;
        else
            Pre_entnum_safe(i,k)=length(find(diff(a{i}.behavResources(id_Pre{i}(k)).ZoneIndices{1})>1))+1;
        end
    end
    
    for k=1:length(id_Post{i})   
        if isempty(a{i}.behavResources(id_Post{i}(k)).ZoneIndices{2})
            Post_entnum_safe(i,k) = 0;
        else
            Post_entnum_safe(i,k)=length(find(diff(a{i}.behavResources(id_Post{i}(k)).ZoneIndices{1})>1))+1;
        end
    end
    
    for k=1:length(id_Cond{i})   
        if isempty(a{i}.behavResources(id_Cond{i}(k)).ZoneIndices{2})
            Cond_entnum_safe(i,k) = 0;
        else
            Cond_entnum_safe(i,k)=length(find(diff(a{i}.behavResources(id_Cond{i}(k)).ZoneIndices{1})>1))+1;
        end
    end
end
Pre_entnum_safe_mean = mean(Pre_entnum_safe,2);
Pre_entnum_safe_std = std(Pre_entnum_safe,0,2);
Post_entnum_safe_mean = mean(Post_entnum_safe,2);
Post_entnum_safe_std = std(Post_entnum_safe,0,2);
Cond_entnum_safe_mean = mean(Cond_entnum_safe,2);
Cond_entnum_safe_std = std(Cond_entnum_safe,0,2);
% Wilcoxon test
p_entnum_safe_pre_post = signrank(Pre_entnum_safe_mean, Post_entnum_safe_mean);


%% Calculate speed in the safe zone and in the noshock + shock vs everything else
% I skip the last point in ZoneIndices because length(Xtsd)=length(Vtsd)+1
% - UPD 18/07/2018 - Could do length(Start(ZoneEpoch))
for i = 1:length(a)
    for k=1:length(id_Pre{i})
        % PreTest SafeZone speed
        if isempty(a{i}.behavResources(id_Pre{i}(k)).ZoneIndices{2})
            VZmean_pre(i,k) = 0;
        else
            if old
                Vtemp_pre{i}{k} = tsd(Range(a{i}.behavResources(id_Pre{i}(k)).Vtsd),...
                    (Data(a{i}.behavResources(id_Pre{i}(k)).Vtsd)./...
                    ([diff(a{i}.behavResources(id_Pre{i}(k)).PosMat(:,1));-1])));
            else
                Vtemp_pre{i}{k}=Data(a{i}.behavResources(id_Pre{i}(k)).Vtsd);
            end
            VZone_pre{i}{k}=Vtemp_pre{i}{k}(a{i}.behavResources(id_Pre{i}(k)).ZoneIndices{2}(1:end-1),1);
            VZmean_pre(i,k)=mean(VZone_pre{i}{k},1);
        end
    end
    
    % PostTest SafeZone speed
    for k=1:length(id_Post{i})
        % PreTest SafeZone speed
        if isempty(a{i}.behavResources(id_Post{i}(k)).ZoneIndices{2})
            VZmean_post(i,k) = 0;
        else
            if old
                Vtemp_post{i}{k} = tsd(Range(a{i}.behavResources(id_Post{i}(k)).Vtsd),...
                    (Data(a{i}.behavResources(id_Post{i}(k)).Vtsd)./...
                    ([diff(a{i}.behavResources(id_Post{i}(k)).PosMat(:,1));-1])));
            else
                Vtemp_post{i}{k}=Data(a{i}.behavResources(id_Post{i}(k)).Vtsd);
            end
            VZone_post{i}{k}=Vtemp_post{i}{k}(a{i}.behavResources(id_Post{i}(k)).ZoneIndices{2}(1:end-1),1);
            VZmean_post(i,k)=mean(VZone_post{i}{k},1);
        end
    end
    
    % Cond SafeZone speed
    for k=1:length(id_Cond{i})
        % Cond SafeZone speed
        if isempty(a{i}.behavResources(id_Cond{i}(k)).ZoneIndices{2})
            VZmean_cond(i,k) = 0;
        else
            if old
                Vtemp_cond{i}{k} = tsd(Range(a{i}.behavResources(id_Cond{i}(k)).Vtsd),...
                    (Data(a{i}.behavResources(id_Cond{i}(k)).Vtsd)./...
                    ([diff(a{i}.behavResources(id_Cond{i}(k)).PosMat(:,1));-1])));
            else
                Vtemp_cond{i}{k}=Data(a{i}.behavResources(id_Cond{i}(k)).Vtsd);
            end
            VZone_cond{i}{k}=Vtemp_cond{i}{k}(a{i}.behavResources(id_Cond{i}(k)).ZoneIndices{2}(1:end-1),1);
            VZmean_cond(i,k)=mean(VZone_cond{i}{k},1);
        end
    end
    
end

Pre_VZmean_mean = mean(VZmean_pre,2);
Pre_VZmean_std = std(VZmean_pre,0,2);
Post_VZmean_mean = mean(VZmean_post,2);
Post_VZmean_std = std(VZmean_post,0,2);
Cond_VZmean_mean = mean(VZmean_cond,2);
Cond_VZmean_std = std(VZmean_cond,0,2);
% Wilcoxon test
p_VZmean_pre_post = signrank(Pre_VZmean_mean, Post_VZmean_mean);

% %% Process freezing
% for i = 1:length(a)
%     for k=1:length(id_Cond{i})
%         eval(['FreezingCond{i}{k} = and(a{i}.FreezeAccEpoch,a{i}.SessionEpoch.Cond' num2str(k) ');']);
%         eval(['time = sum(End(a{i}.SessionEpoch.Cond' num2str(k) ')-Start(a{i}.SessionEpoch.Cond' num2str(k) '));']);
%         FreezingCondSafe{i}{k} = and(FreezingCond{i}{k},a{i}.ZoneEpoch.NoShock);
%         FreezingCondSafePerc(i,k) = sum(End(FreezingCondSafe{i}{k})-Start(FreezingCondSafe{i}{k}))/...
%             time*100;
%         
%         FreezingCondShock{i}{k} = and(FreezingCond{i}{k},a{i}.ZoneEpoch.Shock);
%         FreezingCondShockPerc(i,k) = sum(End(FreezingCondShock{i}{k})-Start(FreezingCondShock{i}{k}))/...
%             time*100;
%     end
% end
% 
% FreezingCondSafePercMean = mean(FreezingCondSafePerc,2);
% FreezingCondShockPercMean = mean(FreezingCondShockPerc,2);

%% Prepare intervalSets for ripples
for i=1:1:length(Dir.path)
    IS_TestPre{i} = or(a{i}.SessionEpoch.TestPre1,a{i}.SessionEpoch.TestPre2);
    IS_TestPre{i} = or(IS_TestPre{i},a{i}.SessionEpoch.TestPre3);
    IS_TestPre{i} = or(IS_TestPre{i},a{i}.SessionEpoch.TestPre4);

    IS_TestPost{i} = or(a{i}.SessionEpoch.TestPost1,a{i}.SessionEpoch.TestPost2);
    IS_TestPost{i} = or(IS_TestPost{i},a{i}.SessionEpoch.TestPost3);
    IS_TestPost{i} = or(IS_TestPost{i},a{i}.SessionEpoch.TestPost4);
    
    IS_Cond{i} = or(a{i}.SessionEpoch.Cond1,a{i}.SessionEpoch.Cond2);
    IS_Cond{i} = or(IS_Cond{i},a{i}.SessionEpoch.Cond3);
    IS_Cond{i} = or(IS_Cond{i},a{i}.SessionEpoch.Cond4);
end


%% Calculate ripples density in the shock zone

% Extract ripples for TestPre and -Post in the safe Zone
for i = 1:length(Dir.path)
    ripplesPeak{i}=ts(Rip{i}.ripples(:,2)*1e4);
    PreRipples{i}=Restrict(ripplesPeak{i},IS_TestPre{i});
    PostRipples{i}=Restrict(ripplesPeak{i},IS_TestPost{i});
    CondRipples{i}=Restrict(ripplesPeak{i},IS_Cond{i});
    
    for itrial=1:ntrial
        PreRipples_Safe{i,itrial}=Restrict(ripplesPeak{i},a{i}.behavResources(id_Pre{1}(itrial)).ZoneEpoch{2});
        PostRipples_Safe{i,itrial}=Restrict(ripplesPeak{i},a{i}.behavResources(id_Post{1}(itrial)).ZoneEpoch{2});

        PreRipples_Shock{i,itrial}=Restrict(ripplesPeak{i},a{i}.behavResources(id_Pre{1}(itrial)).ZoneEpoch{1});
        PostRipples_Shock{i,itrial}=Restrict(ripplesPeak{i},a{i}.behavResources(id_Post{1}(itrial)).ZoneEpoch{1});

        CondRipples_Shock{i,itrial}=Restrict(ripplesPeak{i},a{i}.behavResources(id_Cond{1}(itrial)).ZoneEpoch{1});
        CondRipples_Safe{i,itrial}=Restrict(ripplesPeak{i}, a{i}.behavResources(id_Cond{1}(itrial)).ZoneEpoch{2});
    end

end

for i=1:length(Dir.path)

    
    % WholeMaze
    Pre_N(i)=length(Range(PreRipples{i}));
    Post_N(i)=length(Range(PostRipples{i}));    

    % Normalize to the duration of sleep
    TimePre{i} = IS_TestPre{i};
    Pre_N_norm_all(i) = Pre_N(i)/((sum(End(TimePre{i})- Start(TimePre{i})))/1e4); 
    TimePost{i} = IS_TestPost{i};
    Post_N_norm_all(i) = Post_N(i)/((sum(End(TimePost{i})- Start(TimePost{i})))/1e4);
    
    
%     Cond_N_ShockFreeze(i)=length(Range(CondRipples_ShockFreeze{i}));
%     Cond_N_SafeFreeze(i)=length(Range(CondRipples_SafeFreeze{i}));
    
    for itrial=1:ntrial
        
        % Cond
    %     Cond_N_Freeze(i) = length(Range(CondRipplesFreeze{i}));
        Cond_N_Shock(i)=length(Range(CondRipples_Shock{i, itrial}));
        Cond_N_Safe(i)=length(Range(CondRipples_Safe{i, itrial}));
        
        % Normalize to the duration of sleep
        TimeShock{i,itrial} = a{i}.behavResources(id_Cond{1}(itrial)).ZoneEpoch{1};
        Cond_N_norm_Shock(i,itrial) = Cond_N_Shock(i)/((sum(End(TimeShock{i,itrial})- Start(TimeShock{i,itrial})))/1e4); 
        TimeSafe{i,itrial} = a{i}.behavResources(id_Cond{1}(itrial)).ZoneEpoch{2};
        Cond_N_norm_Safe(i,itrial) = Cond_N_Safe(i)/((sum(End(TimeSafe{i,itrial})- Start(TimeSafe{i,itrial})))/1e4);

    %     TimeShockFreeze{i} = and(and(IS_Cond{i}, a{i}.ZoneEpoch.Shock),a{i}.FreezeAccEpoch);
    %     Cond_N_norm_ShockFreeze(i) = Cond_N_ShockFreeze(i)/((sum(End(TimeShockFreeze{i})- Start(TimeShockFreeze{i})))/1e4); 
    %     TimeSafeFreeze{i} = and(and(IS_Cond{i}, a{i}.ZoneEpoch.NoShock),a{i}.FreezeAccEpoch);
    %     Cond_N_norm_SafeFreeze(i) = Cond_N_SafeFreeze(i)/((sum(End(TimeSafeFreeze{i})- Start(TimeSafeFreeze{i})))/1e4);

        % Shcok Zone
        Pre_N_Shock(i,itrial)=length(Range(PreRipples_Shock{i,itrial}));
        Post_N_Shock(i,itrial)=length(Range(PostRipples_Shock{i,itrial}));
        % Normalize to the duration of SWSSleep
        TimePre{i,itrial} = a{i}.behavResources(id_Pre{1}(itrial)).ZoneEpoch{1};
        Pre_N_norm_Shock(i,itrial) = Pre_N_Shock(i,itrial)/((sum(End(TimePre{i,itrial})- Start(TimePre{i,itrial})))/1e4); 
        TimePost{i,itrial} = a{i}.behavResources(id_Post{1}(itrial)).ZoneEpoch{1};
        Post_N_norm_Shock(i,itrial) = Post_N_Shock(i,itrial)/((sum(End(TimePost{i,itrial})- Start(TimePost{i,itrial})))/1e4);

        % Safe Zone
        Pre_N_Safe(i,itrial)=length(Range(PreRipples_Safe{i,itrial}));
        Post_N_Safe(i,itrial)=length(Range(PostRipples_Safe{i,itrial}));
        % Normalize to the duration of SWSSleep
        TimePre{i,itrial} = a{i}.behavResources(id_Pre{1}(itrial)).ZoneEpoch{2};
        Pre_N_norm_Safe(i,itrial) = Pre_N_Safe(i,itrial)/((sum(End(TimePre{i,itrial})- Start(TimePre{i,itrial})))/1e4); 
        TimePost{i,itrial} = a{i}.behavResources(id_Post{1}(itrial)).ZoneEpoch{2};
        Post_N_norm_Safe(i,itrial) = Post_N_Safe(i,itrial)/((sum(End(TimePost{i,itrial})- Start(TimePost{i,itrial})))/1e4);
    end
    
end

%% This part is too make sure that the animal went into the zone to calculate density.
%  So no go = NaN and not 0.
% taking care of nan 
Cond_N_norm_Shock(isnan(Cond_N_norm_Shock))=0;
Cond_N_norm_Safe(isnan(Cond_N_norm_Safe))=0;

Pre_N_norm_Shock(isnan(Pre_N_norm_Shock))=0;
Pre_N_norm_Safe(isnan(Pre_N_norm_Safe))=0;

Post_N_norm_Shock(isnan(Post_N_norm_Shock))=0;
Post_N_norm_Safe(isnan(Post_N_norm_Safe))=0;

% check if mouse went into zone 
%find ID
Pre_entnum_shock_id = find(Pre_entnum_shock==0);
Pre_entnum_safe_id = find(Pre_entnum_safe==0);
Pre_N_norm_Shock(Pre_entnum_shock_id) = nan;
Pre_N_norm_Safe(Pre_entnum_safe_id) = nan;

Post_entnum_shock_id = find(Post_entnum_shock==0);
Post_entnum_safe_id = find(Post_entnum_safe==0);
Post_N_norm_Shock(Post_entnum_shock_id) = nan;
Post_N_norm_Safe(Post_entnum_safe_id) = nan;

Cond_entnum_shock_id = find(Cond_entnum_shock==0);
Cond_entnum_safe_id = find(Cond_entnum_safe==0);
Cond_N_norm_Shock(Pre_entnum_shock_id) = nan;
Cond_N_norm_Safe(Pre_entnum_safe_id) = nan;


% calculating means per mice across trials
Cond_N_norm_Shock_mean = squeeze(nanmean(Cond_N_norm_Shock,2));
Cond_N_norm_Safe_mean = squeeze(nanmean(Cond_N_norm_Safe,2));

Pre_N_norm_Shock_mean = squeeze(nanmean(Pre_N_norm_Shock,2));
Pre_N_norm_Safe_mean = squeeze(nanmean(Pre_N_norm_Safe,2));

Post_N_norm_Shock_mean = squeeze(nanmean(Post_N_norm_Shock,2));
Post_N_norm_Safe_mean = squeeze(nanmean(Post_N_norm_Safe,2));

%% Plot

f1 = figure( 'rend','painters','pos',[1 1 600 500])
    
        [p_Con,h, her] = PlotErrorBarN_DB([Cond_N_norm_Shock_mean Cond_N_norm_Safe_mean], 'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'showpoints',0);
        ylim([0 .1]);
        set(gca,'Xtick',[1:2],'XtickLabel',{'Stim', 'NoStim'});
        set(gca, 'FontSize', 20, 'FontWeight',  'bold');
        set(gca, 'LineWidth', 3);
        set(h, 'LineWidth', 3);
        set(her, 'LineWidth', 3);
        h.FaceColor = 'flat';
        h.CData(1,:) = [.1 .1 .1];
        h.CData(2,:) = [.6 .6 .6];
        ylabel('Ripples/s');
        title('Ripples density', 'FontSize', 22);

    if sav
        print([dir_out 'RipplesStimNoStim_Cond'], '-dpng', '-r300');
    end




f1 = figure( 'rend','painters','pos',[1 1 1800 1000])
    % Absolute number
    subplot(121)
        [p_Con,h, her] = PlotErrorBarN_DB([Cond_N_norm_Shock_mean Cond_N_norm_Safe_mean], 'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'showpoints',0);
        % ylim([0 0.4]);
        ylim([0 .03]);
        set(gca,'Xtick',[1:2],'XtickLabel',{'Stim', 'NoStim'});
        set(gca, 'FontSize', 18);
        h.FaceColor = 'flat';
        h.CData(1,:) = [1 0 0];
        h.CData(2,:) = [0 0 1];
        set(h, 'LineWidth', 2);
        set(her, 'LineWidth', 2);
        ylabel('Ripples/s');
        title('Ripples density during conditioning', 'FontSize', 20);

        boxpost = [0.34 0.9 0.35 0.1];
        annotation(f1,'textbox',boxpost,'String','During Conditioning','LineStyle','none','HorizontalAlignment','center','FontWeight','bold',...
                'FitBoxToText','off', 'FontSize', 20);

    subplot(122)
        scatter(Cond_N_norm_Safe_mean,Cond_VZmean_mean, 'filled','MarkerFaceColor','k')
        hold on
        l = lsline;
        set(l,'Color','k','LineWidth',2)
        set(gca, 'FontSize', 14);
        ylabel('Speed in NoStim zone (cm/s)');
        xlabel('Density of ripples in NoStim zone (ripples/s)');
        title('Correlation: ripples density vs speed - NoStim zone', 'FontSize', 18);
        [CC,pv] = corrcoef(Cond_N_norm_Safe_mean,Cond_VZmean_mean);
        boxpost = [0.755 0.875 0.2 0.05];
        if CC < 1
            towrite = ['r=' num2str(round(CC(1,2),2)) ', p=' num2str(round(pv(1,2),2))];
            annotation(f1,'textbox',boxpost,'String',towrite,'LineStyle','none','HorizontalAlignment','center','FontWeight','bold',...
                'FitBoxToText','off', 'FontSize', 12);
        end
% 
% 
% 
%         boxpost1 = [0.36 0.43 0.3 0.1];
%         annotation(f1,'textbox',boxpost1,'String','PreTest vs PostTest','LineStyle','none','HorizontalAlignment','center','FontWeight','bold',...
%                 'FitBoxToText','off', 'FontSize', 20);
 %% Save it

    if sav
        print([dir_out 'RipplesStimNoStim'], '-dpng', '-r300');
    end
    
figure
    RipplesEffect = (Post_N_norm_Safe_mean) - (Pre_N_norm_Safe_mean);
    SpeedEffect = Post_VZmean_mean - Pre_VZmean_mean;
    scatter(RipplesEffect,SpeedEffect, 'filled','MarkerFaceColor','k')
    hold on
    l = lsline;
    set(l,'Color','k','LineWidth',2)
    set(gca, 'FontSize', 14);
    ylabel('Speed in NoStim Zone difference');
    xlabel('Density of ripples in NoStim Zone difference');
    title('NoStim Zone: Ripples density effect correlation with speed effect', 'FontSize', 14);

    %% Save it

    if sav
        print([dir_out 'RipplesDuringTask_without'], '-dpng', '-r300');
    end

%% Figure ripples Pre vs Post
supertit = 'Ripples distributions';
figure('Color',[1 1 1], 'rend','painters','pos',[1 1 1400 500],'Name', supertit, 'NumberTitle','off')
    subplot(1,3,1)
        [p,h, her] = PlotErrorBarN_SL([Pre_N_norm_Shock_mean Post_N_norm_Shock_mean],...
                        'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, ...
                        'colorpoints',1,'showpoints',1);
        set(gca,'Xtick',[1:2],'XtickLabel',{'PreTest', 'PostTest'});
        set(gca, 'FontSize', 14);
        ylim([0 0.06]);
        h.FaceColor = 'flat';
        h.CData(1,:) = [.3 .3 .3];
        h.CData(2,:) = [1 1 1];
        set(h, 'LineWidth', 2);
        set(her, 'LineWidth', 2);
        ylabel('Ripples/s');
        title('Ripples density in Stim Zone', 'FontSize', 18);
        
     subplot(1,3,2)
        [p_ppreppostsafe,h, her] = PlotErrorBarN_SL([Pre_N_norm_Safe_mean Post_N_norm_Safe_mean],...
                        'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, ...
                        'colorpoints',1,'showpoints',1);
        set(gca,'Xtick',[1:2],'XtickLabel',{'PreTest', 'PostTest'});
        set(gca, 'FontSize', 14);
        ylim([0 0.06]);
        h.FaceColor = 'flat';
        h.CData(1,:) = [.3 .3 .3];
        h.CData(2,:) = [1 1 1];
        set(h, 'LineWidth', 2);
        set(her, 'LineWidth', 2);
        ylabel('Ripples/s');
        title('Ripples density in NoStim Zone', 'FontSize', 18);
        
     subplot(1,3,3)
        [p_prepost,h, her] = PlotErrorBarN_SL([Pre_N_norm_all' Post_N_norm_all'],...
                        'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, ...
                        'colorpoints',1,'showpoints',1);
        set(gca,'Xtick',[1:2],'XtickLabel',{'PreTest', 'PostTest'});
        set(gca, 'FontSize', 14);
        ylim([0 0.06]);
        h.FaceColor = 'flat';
        h.CData(1,:) = [.3 .3 .3];
        h.CData(2,:) = [1 1 1];
        set(h, 'LineWidth', 2);
        set(her, 'LineWidth', 2);
        ylabel('Ripples/s');
        title('Ripples density in whole maze', 'FontSize', 18);
    
    if sav
        print([dir_out 'RipplesPrePost'], '-dpng', '-r300');
    end
    
    
%%
figure
    scatter(Post_N_norm_Safe_mean,Post_VZmean_mean, 'filled','MarkerFaceColor','k')
    hold on
    l = lsline;
    set(l,'Color','k','LineWidth',3)
    set(gca, 'FontSize', 14, 'FontWeight',  'bold');
    ylabel('Speed in NoStim zone (cm/s)');
    xlabel('Density of ripples in NoStim zone (ripples/s)');
    title('Correlation - PostTest: ripples density vs speed - NoStim zone', 'FontSize', 18);
    [CC,pv] = corrcoef(Post_N_norm_Safe_mean,Post_VZmean_mean);
    boxpost = [0.755 0.875 0.2 0.05];
    if CC < 1
        towrite = ['r=' num2str(round(CC(1,2),2)) ', p=' num2str(round(pv(1,2),2))];
        annotation(f1,'textbox',boxpost,'String',towrite,'LineStyle','none','HorizontalAlignment','center','FontWeight','bold',...
                'FitBoxToText','off', 'FontSize', 12);
    end

%% Figure Cond ocuupany

f4 = figure('units', 'normalized', 'outerposition', [0 0 0.8 0.6])

    subplot(121)
        [p_cond,h_cond, her_cond] = PlotErrorBarN_DB([Cond_Occup_Shock_mean*100 Cond_Occup_Safe_mean*100], 'barcolors', [0 0 0], 'barwidth', 0.8, 'newfig', 0, 'showpoints',0);
        set(gca,'Xtick',[1:2],'XtickLabel',{'Stim zone', 'NoStim zone'});
        set(gca, 'FontSize', 14);
        set(gca, 'LineWidth', 2);
        ax = gca;
        labels = string(ax.YAxis.TickLabels); % extract
        labels(2:2:end) = nan; % remove every other one
        ax.YAxis.TickLabels = labels; % set
        h_cond.FaceColor = 'flat';
        h_cond.CData(1,:) = [1 0 0];
        h_cond.CData(2,:) = [0 0 1];
        set(h_cond, 'LineWidth', 2);
        set(her_cond, 'LineWidth', 2);
        ylabel('% time');
        title('Conditioning: occupancy of Stim and NoStim zones', 'FontSize', 18);

    subplot(122)
        [p_Con,h, her] = PlotErrorBarN_DB([Cond_N_norm_Shock_mean Cond_N_norm_Safe_mean], 'barcolors', [0 0 0], 'barwidth', 0.8, 'newfig', 0, 'showpoints',0);
        % ylim([0 0.4]);
        ylim([0 0.1]);
        set(gca,'Xtick',[1:2],'XtickLabel',{'Stim zone', 'NoStim zone'});
        set(gca, 'FontSize', 14);
        set(gca, 'LineWidth', 2);
        ax = gca;
        labels = string(ax.YAxis.TickLabels); % extract
        labels(2:2:end) = nan; % remove every other one
        ax.YAxis.TickLabels = labels; % set
        h.FaceColor = 'flat';
        h.CData(1,:) = [1 0 0];
        h.CData(2,:) = [0 0 1];
        set(h, 'LineWidth',2);
        set(her, 'LineWidth', 2);
        ylabel('Ripples/s');
        title('Ripples density during conditioning', 'FontSize', 18);

    if sav
        print([dir_out 'OccupCondRippes_without'], '-dpng', '-r300');
    end

% %% Figure Cond freezing
% 
% f5 = figure('units', 'normalized', 'outerposition', [0 0 0.8 0.6])
% 
    % subplot(121)
        % [p_cond,h_cond, her_cond] = PlotErrorBarN_DB([FreezingCondShockPercMean FreezingCondSafePercMean], 'barcolors', [0 0 0], 'barwidth', 0.8, 'newfig', 0, 'showpoints',0);
        % ylim([0 20]);
        % set(gca,'Xtick',[1:2],'XtickLabel',{'ShockZone', 'SafeZone'});
        % set(gca, 'FontSize', 14, 'FontWeight',  'bold');
        % set(gca, 'LineWidth', 3);
        % ax = gca;
        % labels = string(ax.YAxis.TickLabels); % extract
        % labels(2:2:end) = nan; % remove every other one
        % ax.YAxis.TickLabels = labels; % set
        % h_cond.FaceColor = 'flat';
        % h_cond.CData(1,:) = [1 0 0];
        % h_cond.CData(2,:) = [0 0 1];
        % set(h_cond, 'LineWidth', 3);
        % set(her_cond, 'LineWidth', 3);
        % ylabel('% time');
        % title('Conditioning: freezing', 'FontSize', 14);
    % 
    % subplot(122)
        % Cond_N_norm_ShockFreeze(find(isnan(Cond_N_norm_ShockFreeze))) = 0;
        % Cond_N_norm_SafeFreeze(find(isnan(Cond_N_norm_SafeFreeze))) = 0;
        % [p_Con,h, her] = PlotErrorBarN_DB([Cond_N_norm_ShockFreeze' Cond_N_norm_SafeFreeze'], 'barcolors', [0 0 0], 'barwidth', 0.8, 'newfig', 0, 'showpoints',0);
        % % ylim([0 0.4]);
        % ylim([0 0.5]);
        % set(gca,'Xtick',[1:2],'XtickLabel',{'ShockZone', 'SafeZone'});
        % set(gca, 'FontSize', 14, 'FontWeight',  'bold');
        % set(gca, 'LineWidth', 3);
        % ax = gca;
        % labels = string(ax.YAxis.TickLabels); % extract
        % labels(2:2:end) = nan; % remove every other one
        % ax.YAxis.TickLabels = labels; % set
        % h.FaceColor = 'flat';
        % h.CData(1,:) = [1 0 0];
        % h.CData(2,:) = [0 0 1];
        % set(h, 'LineWidth', 3);
        % set(her, 'LineWidth', 3);
        % ylabel('Ripples/s');
        % title('Conditioning: ripples density during freezing', 'FontSize', 14);
    % 
    %     if sav
    %         print([dir_out 'FreezingCondRippes_without'], '-dpng', '-r300');
    %     end
