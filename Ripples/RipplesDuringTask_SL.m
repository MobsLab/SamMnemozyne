function RipplesDuringTask_SL(expe, subj, numexpe)

%==========================================================================
% Details: Output details (density, amplitude, duration) of ripples during
% sleep
%
% INPUTS:
%       - mice number to analyses (format: [117 124]) 
%
% OUTPUT:
%       - figure including:
%           - 
%
% NOTES:
%       - Problem with the figure DYNAMICS
%
%   Written by Dima and Samuel Laventure - 2019
%      
%==========================================================================

%% Parameters
sav=1;
old = 0;
% subj = [117 124];
movonly=1;  % only ripples during movements
mvtthr = 2;
thrdir='Below'; % 'Above' or 'Below'
% ntrial = 4;  %nbr of pre, post and cond trials

% Directory to save and name of the figure to save
dir_out = [dropbox 'DataSL/StimMFBWake/ripples/' date '/'];

%set folders
if ~exist(dir_out,'dir')
    mkdir(dir_out);
end

Dir = PathForExperimentsERC(expe);
Dir = RestrictPathForExperiment(Dir, 'nMice', unique(subj));


% Set session names to be compared (for simplicity they will marked 
% as pre and post)
sessName = {'Pre-tests','Post-tests'};
sesspre = {'TestPre1','TestPre2','TestPre3','TestPre4','TestPre5','TestPre6','TestPre7','TestPre8'};    
sesspost = {'TestPost1','TestPost2','TestPost3','TestPost4','TestPost5','TestPost6','TestPost7','TestPost8'};
sesscond = {'Cond1','Cond2','Cond3','Cond4','Cond5','Cond6','Cond7','Cond8'};


% #####################################################################
% #
% #                           M A I N
% #
% #####################################################################
warning off
%% Get Data
i=0;
for ii = 1:length(Dir.path)
    for iexp=1:length(Dir.path{ii})
        i=i+1;
        load([Dir.path{ii}{iexp} 'SWR.mat'], 'ripples','dHPC_rip');
        if exist('ripples','var')
            if exist('dHPC_rip','var') 
                Rip{i} = load([Dir.path{ii}{iexp} 'SWR.mat'], 'ripples','dHPC_rip');
            else
                load([Dir.path{ii}{iexp} 'SWR.mat'], 'ripples','ripples_Info');
                Rip{i}.ripples = ripples;
                Rip{i}.dHPC_rip = ripples_Info.channel;
            end
        else
            load([Dir.path{ii}{iexp} 'SWR.mat'], 'Ripples','ripples_Info');
            Rip{i}.ripples = Ripples;
            Rip{i}.dHPC_rip = ripples_Info.channel;
        end
        a{i} = load([Dir.path{ii}{iexp} '/behavResources.mat'], 'behavResources', 'SessionEpoch', 'ZoneEpoch','FreezeAccEpoch','Vtsd');
    end
end
num = i;

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

% set max number of trials
for i=1:length(a)
    lnpre(i) = length(id_Pre{i});  %assuming that pre and post have the same number of trials
    lncond(i) = length(id_Cond{i});
end
ntrial_premax = max(lnpre);
ntrial_condmax = max(lncond);

% Get speed 
for i=1:length(a)
    for k=1:lnpre(i)
        if ~isempty(a{i}.behavResources(id_Pre{i}(k)).Vtsd)
            mvtpre{i,k} = a{i}.behavResources(id_Pre{i}(k)).Vtsd;  
        else
            mvtpre{i,k} = a{i}.behavResources(id_Pre{i}(k)).Vtsd;
        end
        if ~isempty(a{i}.behavResources(id_Post{i}(k)).Vtsd)
            mvtpost{i,k} = a{i}.behavResources(id_Post{i}(k)).Vtsd;    
        else
            mvtpost{i,k} = a{i}.behavResources(id_Post{i}(k)).Vtsd;
        end
    end
end
for i=1:length(a)
    for k=1:lncond(i)
        if ~isempty(a{i}.behavResources(id_Cond{i}(k)).Vtsd)
            mvtcond{i,k} = a{i}.behavResources(id_Cond{i}(k)).Vtsd;    
        else
            mvtcond{i,k} = a{i}.behavResources(id_Cond{i}(k)).Vtsd;
        end
    end
end


%% Calculate average occupancy
% Calculate occupancy de novo
for i=1:length(a)
    for k=1:length(id_Pre{i})
        for t=1:length(a{i}.behavResources(id_Pre{i}(k)).Zone)
            Pre_Occup(i,k,t)=size(a{i}.behavResources(id_Pre{i}(k)).ZoneIndices{t},1)./...
                size(Data(a{i}.behavResources(id_Pre{i}(k)).AlignedXtsd),1);
        end
    end
    for k=1:length(id_Post{i})
        for t=1:length(a{i}.behavResources(id_Post{i}(k)).Zone)
            Post_Occup(i,k,t)=size(a{i}.behavResources(id_Post{i}(k)).ZoneIndices{t},1)./...
                size(Data(a{i}.behavResources(id_Post{i}(k)).AlignedXtsd),1);
        end
    end
    
    for k=1:length(id_Cond{i})
        for t=1:length(a{i}.behavResources(id_Cond{i}(k)).Zone)
            Cond_Occup(i,k,t)=size(a{i}.behavResources(id_Cond{i}(k)).ZoneIndices{t},1)./...
                size(Data(a{i}.behavResources(id_Cond{i}(k)).AlignedXtsd),1);
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
% 
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
            Cond_entnum_shock(i,k)=length(find(diff(a{i}.behavResources(id_Cond{i}(k)).ZoneIndices{1})>1))+1;
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

%% Calculate number of entries into the no-stim zone
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
% I skip the last point in ZoneIndices because length(AlignedXtsd)=length(Vtsd)+1
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
% p_VZmean_pre_post = signrank(Pre_VZmean_mean, Post_VZmean_mean);

%% Prepare intervalSets for ripples
for isuj=1:num
    % Locomotion threshold
    LocomotionEpoch = thresholdIntervals(tsd(Range(a{isuj}.Vtsd),movmedian(Data(a{isuj}.Vtsd),5)) ...
        ,mvtthr,'Direction',thrdir);
    
    for itrial=1:lnpre(isuj)
        if isfield(a{isuj}.SessionEpoch,sesspre{itrial})
            pre_epoch{isuj,itrial} = extractfield(a{isuj}.SessionEpoch,sesspre{itrial});            
        end
        if isfield(a{isuj}.SessionEpoch,sesspost{itrial})
            post_epoch{isuj,itrial} = extractfield(a{isuj}.SessionEpoch,sesspost{itrial});            
        end        
    end
    for itrial=1:lncond
        if isfield(a{isuj}.SessionEpoch,sesscond{itrial})
            cond_epoch{isuj,itrial} = extractfield(a{isuj}.SessionEpoch,sesscond{itrial});            
        end   
    end
    
    % get first trial
    IS_TestPre{isuj} = pre_epoch{isuj,1}{1};
    IS_TestPost{isuj} = post_epoch{isuj,1}{1};
    IS_Cond{isuj} = cond_epoch{isuj,1}{1};
    
    % get all trials
    for itrial=2:lnpre(isuj)
        try
            IS_TestPre{isuj} = or(IS_TestPre{isuj},pre_epoch{isuj,itrial}{1});
        catch
            warning([num2str(subj(isuj)) ': Exited concat TestPre at #' num2str(itrial)])
            break
        end
        try
            IS_TestPost{isuj} = or(IS_TestPost{isuj},post_epoch{isuj,itrial}{1});
        catch
            warning([num2str(subj(isuj)) ': Exited concat TestPost at #' num2str(itrial)])
            break
        end
    end
    for itrial=2:lncond(isuj)
        try
            IS_Cond{isuj} = or(IS_Cond{isuj},cond_epoch{isuj,itrial}{1});
        catch
            warning([num2str(subj(isuj)) ': Exited concat Cond at #' num2str(itrial)])
            break
        end
    end
    if movonly
        IS_TestPre{isuj} = and(IS_TestPre{isuj}, LocomotionEpoch); 
        IS_TestPost{isuj} = and(IS_TestPost{isuj}, LocomotionEpoch); 
        IS_Cond{isuj} = and(IS_Cond{isuj}, LocomotionEpoch);   
    end
end

% 
% for isuj=1:num
%     for itrial=1:lnpre(isuj)
%         if isfield(a{isuj}.SessionEpoch,sesspre{itrial})
%             pre_epoch{isuj,itrial} = extractfield(a{isuj}.SessionEpoch,sesspre{itrial});            
%         end
%         if isfield(a{isuj}.SessionEpoch,sesspost{itrial})
%             post_epoch{isuj,itrial} = extractfield(a{isuj}.SessionEpoch,sesspost{itrial});            
%         end        
%     end
%     for itrial=1:lncond
%         if isfield(a{isuj}.SessionEpoch,sesscond{itrial})
%             cond_epoch{isuj,itrial} = extractfield(a{isuj}.SessionEpoch,sesscond{itrial});            
%         end   
%     end
%     
%     % get first trial
%     IS_TestPre{isuj} = pre_epoch{isuj,1}{1};
%     IS_TestPost{isuj} = post_epoch{isuj,1}{1};
%     IS_Cond{isuj} = cond_epoch{isuj,1}{1};
%     if movonly 
%         % Locomotion threshold - pre
%         LocomotionEpoch_pre = thresholdIntervals(tsd(Range(mvtpre{isuj,1})...
%             ,movmedian(Data(mvtpre{isuj,1}),5)),3,'Direction','Above');
%         IS_TestPre{isuj} = and(IS_TestPre{isuj}, LocomotionEpoch_pre);
%         % Locomotion threshold - post
%         LocomotionEpoch_post = thresholdIntervals(tsd(Range(mvtpost{isuj,1})...
%             ,movmedian(Data(mvtpost{isuj,1}),5)),3,'Direction','Above');
%         IS_TestPost{isuj} = and(IS_TestPost{isuj}, LocomotionEpoch_post);
%         % Locomotion threshold - cond
%         LocomotionEpoch_cond = thresholdIntervals(tsd(Range(mvtcond{isuj,1})...
%             ,movmedian(Data(mvtcond{isuj,1}),5)),3,'Direction','Above');
%         IS_Cond{isuj} = and(IS_Cond{isuj}, LocomotionEpoch_cond);
%     end
%     
%     % get all trials
%     for itrial=2:lnpre(isuj)
%         try
%             IS_TestPre{isuj} = or(IS_TestPre{isuj},pre_epoch{isuj,itrial}{1});
%             % restrict to movements
%             if movonly 
%                 % Locomotion threshold
%                 LocomotionEpoch = thresholdIntervals(tsd(Range(mvtpre{isuj,itrial})...
%                     ,movmedian(Data(mvtpre{isuj,itrial}),5)),mvtthr,'Direction',thrdir);
%                 IS_TestPre{isuj} = and(IS_TestPre{isuj}, LocomotionEpoch);
%                 clear LocomotionEpoch
%             end
%         catch
%             warning([num2str(subj(isuj)) ': Exited concat TestPre at #' num2str(itrial)])
%             break
%         end
%         try
%             IS_TestPost{isuj} = or(IS_TestPost{isuj},post_epoch{isuj,itrial}{1});
%             % restrict to movements
%             if movonly 
%                 % Locomotion threshold
%                 LocomotionEpoch = thresholdIntervals(tsd(Range(mvtpost{isuj,itrial})...
%                     ,movmedian(Data(mvtpost{isuj,itrial}),5)),mvtthr,'Direction',thrdir);
%                 IS_TestPost{isuj} = and(IS_TestPost{isuj}, LocomotionEpoch);
%                 clear LocomotionEpoch
%             end
%         catch
%             warning([num2str(subj(isuj)) ': Exited concat TestPost at #' num2str(itrial)])
%             break
%         end
%     end
%     
%     for itrial=2:lncond(isuj)
%         try
%             IS_Cond{isuj} = or(IS_Cond{isuj},cond_epoch{isuj,itrial}{1});
%             % restrict to movements
%             if movonly 
%                 % Locomotion threshold
%                 LocomotionEpoch = thresholdIntervals(tsd(Range(mvtcond{isuj,itrial})...
%                     ,movmedian(Data(mvtcond{isuj,itrial}),5)),mvtthr,'Direction',thrdir);
%                 IS_Cond{isuj} = and(IS_Cond{isuj}, LocomotionEpoch);
%                 clear LocomotionEpoch
%             end
%         catch
%             warning([num2str(subj(isuj)) ': Exited concat Cond at #' num2str(itrial)])
%             break
%         end
%     end
% end


%% Calculate ripples density in the shock zone
%Init var
PreRipples_Safe = cell(num,ntrial_premax);
PreRipples_Safe(1:num,1:ntrial_premax) = {nan};
PostRipples_Safe = cell(num,ntrial_premax);
PostRipples_Safe(1:num,1:ntrial_premax) = {nan};
CondRipples_Safe = cell(num,ntrial_condmax);
CondRipples_Safe(1:num,1:ntrial_condmax) = {nan};

PreRipples_Shock = cell(num,ntrial_premax);
PreRipples_Shock(1:num,1:ntrial_premax) = {nan};
PostRipples_Shock = cell(num,ntrial_premax);
PostRipples_Shock(1:num,1:ntrial_premax) = {nan};
CondRipples_Shock = cell(num,ntrial_condmax);
CondRipples_Safe(1:num,1:ntrial_condmax) = {nan};

% Extract ripples for TestPre, Cond and -Post in the safe Zone
for i = 1:num
    ripplesPeak{i}=ts(Rip{i}.ripples(:,2)*1e4);
%     PreRipples{i}=Restrict(ripplesPeak{i},IS_TestPre{i});
%     PostRipples{i}=Restrict(ripplesPeak{i},IS_TestPost{i});
%     CondRipples{i}=Restrict(ripplesPeak{i},IS_Cond{i});

    for itrial=1:lnpre(i)
        if movonly 
            % Locomotion threshold
            LocomotionEpochPre = thresholdIntervals(tsd(Range(mvtpre{i,itrial})...
                ,movmedian(Data(mvtpre{i,itrial}),5)),mvtthr,'Direction',thrdir);
            LocomotionEpochPost = thresholdIntervals(tsd(Range(mvtpost{i,itrial})...
                ,movmedian(Data(mvtpost{i,itrial}),5)),mvtthr,'Direction',thrdir);
            % set movement restrictions
            PreRipples_Safe{i,itrial}=Restrict(ripplesPeak{i},and(a{i}.behavResources(id_Pre{i}(itrial)).ZoneEpoch{2},LocomotionEpochPre));
            PostRipples_Safe{i,itrial}=Restrict(ripplesPeak{i},and(a{i}.behavResources(id_Post{i}(itrial)).ZoneEpoch{2},LocomotionEpochPost));

            PreRipples_Shock{i,itrial}=Restrict(ripplesPeak{i},and(a{i}.behavResources(id_Pre{i}(itrial)).ZoneEpoch{1},LocomotionEpochPre));
            PostRipples_Shock{i,itrial}=Restrict(ripplesPeak{i},and(a{i}.behavResources(id_Post{i}(itrial)).ZoneEpoch{1},LocomotionEpochPost));

            PreRipples_all{i,itrial}=Restrict(ripplesPeak{i},and(pre_epoch{i,itrial}{1},LocomotionEpochPre));
            PostRipples_all{i,itrial}=Restrict(ripplesPeak{i},and(post_epoch{i,itrial}{1},LocomotionEpochPost));
         
            clear LocomotionEpochPre LocomotionEpochPost
        else
            PreRipples_Safe{i,itrial}=Restrict(ripplesPeak{i},a{i}.behavResources(id_Pre{i}(itrial)).ZoneEpoch{2});
            PostRipples_Safe{i,itrial}=Restrict(ripplesPeak{i},a{i}.behavResources(id_Post{i}(itrial)).ZoneEpoch{2});

            PreRipples_Shock{i,itrial}=Restrict(ripplesPeak{i},a{i}.behavResources(id_Pre{i}(itrial)).ZoneEpoch{1});
            PostRipples_Shock{i,itrial}=Restrict(ripplesPeak{i},a{i}.behavResources(id_Post{i}(itrial)).ZoneEpoch{1});

            PreRipples_all{i,itrial}=Restrict(ripplesPeak{i},pre_epoch{i,itrial}{1});
            PostRipples_all{i,itrial}=Restrict(ripplesPeak{i},post_epoch{i,itrial}{1});
        end
        
    end
    for itrial=1:lncond(i)
        if movonly 
            % Locomotion threshold
            LocomotionEpochCond = thresholdIntervals(tsd(Range(mvtcond{i,itrial})...
                ,movmedian(Data(mvtcond{i,itrial}),5)),mvtthr,'Direction',thrdir);
            CondRipples_Shock{i,itrial}=Restrict(ripplesPeak{i},and(a{i}.behavResources(id_Cond{i}(itrial)).ZoneEpoch{1},LocomotionEpochCond));
            CondRipples_Safe{i,itrial}=Restrict(ripplesPeak{i},and(a{i}.behavResources(id_Cond{i}(itrial)).ZoneEpoch{2},LocomotionEpochCond));
            CondRipples_all{i,itrial}=Restrict(ripplesPeak{i},and(cond_epoch{i,itrial}{1},LocomotionEpochCond));   
            clear LocomotionEpochCond         
        else
            CondRipples_Shock{i,itrial}=Restrict(ripplesPeak{i},a{i}.behavResources(id_Cond{i}(itrial)).ZoneEpoch{1});
            CondRipples_Safe{i,itrial}=Restrict(ripplesPeak{i},a{i}.behavResources(id_Cond{i}(itrial)).ZoneEpoch{2});
            CondRipples_all{i,itrial}=Restrict(ripplesPeak{i},cond_epoch{i,itrial}{1});
        end
    end
end

%% Density calculation
%var init
Cond_N_norm_Shock = nan(num,ntrial_condmax);
Cond_N_norm_Safe = nan(num,ntrial_condmax);
Cond_N_norm_Rest = nan(num,ntrial_condmax);
Pre_N_norm_Safe = nan(num,ntrial_premax);
Pre_N_norm_Shock = nan(num,ntrial_premax);
Pre_N_norm_Rest = nan(num,ntrial_premax);
Post_N_norm_Safe = nan(num,ntrial_premax);
Post_N_norm_Shock = nan(num,ntrial_premax);
Post_N_norm_Rest = nan(num,ntrial_premax);

for i=1:num
    for itrial=1:lnpre(i)
    % WholeMaze
        Pre_N(i,itrial)=length(Range(PreRipples_all{i,itrial}));
        Post_N(i,itrial)=length(Range(PostRipples_all{i,itrial}));  
        if ~isempty(CondRipples_all{i,itrial})
            try
                Cond_N(i,itrial)=length(Range(CondRipples_all{i,itrial})); 
            catch
                if isnan(CondRipples_all{i,itrial})
                    Cond_N(i,itrial)=0;
                end
            end
        else
            Cond_N(i,itrial)=0;            
        end
        % Normalize to the duration of trial
        if movonly
            % Pre
            LocomotionEpochPre = thresholdIntervals(tsd(Range(mvtpre{i,itrial})...
                ,movmedian(Data(mvtpre{i,itrial}),5)),mvtthr,'Direction',thrdir);
            TimePre = and(pre_epoch{i,itrial}{1},LocomotionEpochPre);
            % Post
            LocomotionEpochPost = thresholdIntervals(tsd(Range(mvtpost{i,itrial})...
                ,movmedian(Data(mvtpost{i,itrial}),5)),mvtthr,'Direction',thrdir);
            TimePost = and(post_epoch{i,itrial}{1},LocomotionEpochPost);
            % Cond
            LocomotionEpochCond = thresholdIntervals(tsd(Range(mvtcond{i,itrial})...
                ,movmedian(Data(mvtcond{i,itrial}),5)),mvtthr,'Direction',thrdir);
            TimeCond = and(cond_epoch{i,itrial}{1},LocomotionEpochCond);
            
        else 
            TimePre = pre_epoch{i,itrial}{1};
            TimePost = post_epoch{i,itrial}{1};
            TimeCond = cond_epoch{i,itrial}{1};
        end
        % Calculate density
        Pre_N_norm_all(i,itrial) = Pre_N(i,itrial)/((sum(End(TimePre)- Start(TimePre)))/1e4); 
        Post_N_norm_all(i,itrial) = Post_N(i,itrial)/((sum(End(TimePost)- Start(TimePost)))/1e4);
        Cond_N_norm_all(i,itrial) = Cond_N(i,itrial)/((sum(End(TimeCond)- Start(TimeCond)))/1e4);
        % Clear var
        clear TimePre TimPost TimeCond
        
    % Stim Zone
        Pre_N_Shock(i,itrial)=length(Range(PreRipples_Shock{i,itrial}));
        Post_N_Shock(i,itrial)=length(Range(PostRipples_Shock{i,itrial}));
        if ~isempty(CondRipples_Shock{i,itrial})
            try
                Cond_N_Shock(i,itrial)=length(Range(CondRipples_Shock{i,itrial}));
            catch
                if isnan(CondRipples_Shock{i,itrial})
                    Cond_N_Shock(i,itrial)=0;
                end
            end
        else
            Cond_N_Shock(i,itrial)=0;
        end
        % Normalize to the duration of time spent in stim zone
        if movonly
            TimePre = and(a{i}.behavResources(id_Pre{i}(itrial)).ZoneEpoch{1},LocomotionEpochPre);
            TimePost = and(a{i}.behavResources(id_Post{i}(itrial)).ZoneEpoch{1},LocomotionEpochPost);
            TimeCond = and(a{i}.behavResources(id_Cond{i}(itrial)).ZoneEpoch{1},LocomotionEpochCond);                       
        else
            TimePre = a{i}.behavResources(id_Pre{i}(itrial)).ZoneEpoch{1};
            TimePost = a{i}.behavResources(id_Post{i}(itrial)).ZoneEpoch{1};
            TimeCond = a{i}.behavResources(id_Cond{i}(itrial)).ZoneEpoch{1};
        end
        Pre_N_norm_Shock(i,itrial) = Pre_N_Shock(i,itrial)/((sum(End(TimePre)- Start(TimePre)))/1e4); 
        Post_N_norm_Shock(i,itrial) = Post_N_Shock(i,itrial)/((sum(End(TimePost)- Start(TimePost)))/1e4);
        Cond_N_norm_Shock(i,itrial) = Cond_N_Shock(i,itrial)/((sum(End(TimeCond) - Start(TimeCond)))/1e4);
        
        clear TimePre TimPost TimeCond

     % No-Stim Zone
        Pre_N_Safe(i,itrial)=length(Range(PreRipples_Safe{i,itrial}));
        Post_N_Safe(i,itrial)=length(Range(PostRipples_Safe{i,itrial}));
        if ~isempty(CondRipples_Safe{i,itrial})
            try
                Cond_N_Safe(i,itrial)=length(Range(CondRipples_Safe{i, itrial}));
            catch
                if isnan(CondRipples_Safe{i,itrial})
                    Cond_N_Safe(i,itrial)=0;
                end
            end
        else
            Cond_N_Safe(i,itrial)=0;
        end
        % Normalize to the duration of time spent in no-stim zone
        if movonly
            TimePre = and(a{i}.behavResources(id_Pre{i}(itrial)).ZoneEpoch{2},LocomotionEpochPre);
            TimePost = and(a{i}.behavResources(id_Post{i}(itrial)).ZoneEpoch{2},LocomotionEpochPost);
            TimeCond = and(a{i}.behavResources(id_Cond{1}(itrial)).ZoneEpoch{2},LocomotionEpochCond);
        else
            TimePre = a{i}.behavResources(id_Pre{i}(itrial)).ZoneEpoch{2};
            TimePost = a{i}.behavResources(id_Post{i}(itrial)).ZoneEpoch{2};
            TimeCond = a{i}.behavResources(id_Cond{1}(itrial)).ZoneEpoch{2};
        end
        
        Pre_N_norm_Safe(i,itrial) = Pre_N_Safe(i,itrial)/((sum(End(TimePre)- Start(TimePre)))/1e4); 
        Post_N_norm_Safe(i,itrial) = Post_N_Safe(i,itrial)/((sum(End(TimePost)- Start(TimePost)))/1e4);
        Cond_N_norm_Safe(i,itrial) = Cond_N_Safe(i,itrial)/((sum(End(TimeCond)- Start(TimeCond)))/1e4);
        
        clear TimePre TimPost TimeCond
        
     % Rest of the maze (all except stim zone)
        Pre_N_Rest(i,itrial) = Pre_N(i,itrial)-Pre_N_Shock(i,itrial);
        Post_N_Rest(i,itrial) = Post_N(i,itrial)-Post_N_Shock(i,itrial);
        Cond_N_Rest(i,itrial) = Cond_N(i,itrial)-Cond_N_Shock(i,itrial);

        % Normalize to the duration of time spent in stim zone
        if movonly
            TimePre = sum((End(and(pre_epoch{i,itrial}{1},LocomotionEpochPre)) - Start(and(pre_epoch{i,itrial}{1},LocomotionEpochPre)))/1E4) - ...
                ((sum(End(and(a{i}.behavResources(id_Pre{i}(itrial)).ZoneEpoch{1},LocomotionEpochPre)) - Start(and(a{i}.behavResources(id_Pre{i}(itrial)).ZoneEpoch{1},LocomotionEpochPre))))/1e4);
            TimePost = sum((End(and(post_epoch{i,itrial}{1},LocomotionEpochPost)) - Start(and(post_epoch{i,itrial}{1},LocomotionEpochPost)))/1E4) -...
                ((sum(End(and(a{i}.behavResources(id_Post{i}(itrial)).ZoneEpoch{1},LocomotionEpochPost)) - Start(and(a{i}.behavResources(id_Post{i}(itrial)).ZoneEpoch{1},LocomotionEpochPost))))/1e4);
            TimeCond = sum((End(and(cond_epoch{i,itrial}{1},LocomotionEpochCond)) - Start(and(cond_epoch{i,itrial}{1},LocomotionEpochCond)))/1E4) - ...
                ((sum(End(and(a{i}.behavResources(id_Cond{i}(itrial)).ZoneEpoch{1},LocomotionEpochCond)) - Start(and(a{i}.behavResources(id_Cond{i}(itrial)).ZoneEpoch{1},LocomotionEpochCond))))/1e4);
        else
            TimePre = sum((End(pre_epoch{i,itrial}{1}) - Start(pre_epoch{i,itrial}{1}))/1E4) - ...
                ((sum(End(a{i}.behavResources(id_Pre{i}(itrial)).ZoneEpoch{1})- Start(a{i}.behavResources(id_Pre{i}(itrial)).ZoneEpoch{1})))/1e4);
            TimePost = sum((End(post_epoch{i,itrial}{1}) - Start(post_epoch{i,itrial}{1}))/1E4) -...
                ((sum(End(a{i}.behavResources(id_Post{i}(itrial)).ZoneEpoch{1})- Start(a{i}.behavResources(id_Post{i}(itrial)).ZoneEpoch{1})))/1e4);
            TimeCond = sum((End(cond_epoch{i,itrial}{1}) - Start(cond_epoch{i,itrial}{1}))/1E4) - ...
                ((sum(End(a{i}.behavResources(id_Cond{i}(itrial)).ZoneEpoch{1})- Start(a{i}.behavResources(id_Cond{i}(itrial)).ZoneEpoch{1})))/1e4);
        end
        
        Pre_N_norm_Rest(i,itrial) = Pre_N_Rest(i,itrial)/TimePre; 
        Post_N_norm_Rest(i,itrial) = Post_N_Rest(i,itrial)/TimePost; 
        Cond_N_norm_Rest(i,itrial) = Cond_N_Rest(i,itrial)/TimeCond; 
        
        clear TimePre TimPost TimeCond LocomotionEpochPre LocomotionEpochPost LocomotionEpochCond
    end 
end

%% This part is too make sure that the animal went into the zone to calculate density.
%  So no go = NaN and not 0.
% % taking care of nan 
% Pre_N_norm_Shock(isnan(Pre_N_norm_Shock))=0;
% Pre_N_norm_Safe(isnan(Pre_N_norm_Safe))=0;
% Pre_N_norm_Rest(isnan(Pre_N_norm_Rest))=0;
% 
% Post_N_norm_Shock(isnan(Post_N_norm_Shock))=0;
% Post_N_norm_Safe(isnan(Post_N_norm_Safe))=0;
% Post_N_norm_Rest(isnan(Post_N_norm_Rest))=0;
% 
% Cond_N_norm_Shock(isnan(Cond_N_norm_Shock))=0;
% Cond_N_norm_Safe(isnan(Cond_N_norm_Safe))=0;
% Cond_N_norm_Rest(isnan(Cond_N_norm_Rest))=0;

% check if mouse went into zone 
%find ID
Pre_N_norm_Shock(Pre_N_norm_Shock==0) = nan;
Pre_N_norm_Safe(Pre_N_norm_Safe==0) = nan;
Post_N_norm_Shock(Post_N_norm_Shock==0) = nan;
Post_N_norm_Safe(Post_N_norm_Safe==0) = nan;
Cond_N_norm_Shock(Cond_N_norm_Shock==0) = nan;
Cond_N_norm_Safe(Cond_N_norm_Safe==0) = nan;


% calculating means per mice across trials
Cond_N_norm_Shock_mean = squeeze(nanmean(Cond_N_norm_Shock,2));
Cond_N_norm_Safe_mean = squeeze(nanmean(Cond_N_norm_Safe,2));
Cond_N_norm_Rest_mean = squeeze(nanmean(Cond_N_norm_Rest,2)); 
Cond_N_norm_all_mean = squeeze(nanmean(Cond_N_norm_all,2));

Pre_N_norm_Shock_mean = squeeze(nanmean(Pre_N_norm_Shock,2));
Pre_N_norm_Safe_mean = squeeze(nanmean(Pre_N_norm_Safe,2));
Pre_N_norm_Rest_mean = squeeze(nanmean(Pre_N_norm_Rest,2));
Pre_N_norm_all_mean = squeeze(nanmean(Pre_N_norm_all,2));

Post_N_norm_Shock_mean = squeeze(nanmean(Post_N_norm_Shock,2));
Post_N_norm_Safe_mean = squeeze(nanmean(Post_N_norm_Safe,2));
Post_N_norm_Rest_mean = squeeze(nanmean(Post_N_norm_Rest,2));
Post_N_norm_all_mean = squeeze(nanmean(Post_N_norm_all,2));

%% 
%==========================================================================
%
%                               F I G U R E S 
%
%==========================================================================

% set text format
set(0,'defaulttextinterpreter','latex');
set(0,'DefaultTextFontname', 'Arial')
set(0,'DefaultAxesFontName', 'Arial')
set(0,'defaultAxesFontSize',14)



%--------------------------------------------------------------------------
%                 ripples u-maze location  
%--------------------------------------------------------------------------
% set plot colors
clrs_default = get(gca,'colororder');
clrs_default(end+1,1:3) = [0 0 0];
% colororder(clrs_default);

for i=1:num
    
    % ripple number
    nrip(i,1) = length(Restrict(ripplesPeak{i},IS_TestPre{i}));  
    nrip(i,2) = length(Restrict(ripplesPeak{i},IS_TestPost{i})); 
    nrip(i,3) = length(Restrict(ripplesPeak{i},IS_Cond{i}));   
    supertit = ['Mouse ' num2str(subj(i))  ' - Ripple '];
    figure('Color',[1 1 1], 'rend','painters','pos',[1 1 1800 500],'Name', supertit, 'NumberTitle','off')
        
        subplot(1,3,1) 
            for k=1:lnpre(i)    
                % -- trajectories    
                p1(k) = plot(Data(a{i}.behavResources(id_Pre{i}(k)).AlignedXtsd),...
                    Data(a{i}.behavResources(id_Pre{i}(k)).AlignedYtsd),...
                         'linewidth',.5,'Color',[.3 .3 .3]);  
                hold on
                tempX = Data(a{i}.behavResources(id_Pre{i}(k)).AlignedXtsd);
                tempY = Data(a{i}.behavResources(id_Pre{i}(k)).AlignedYtsd);
                riptime = Data(PreRipples_all{i,k})/1e4;
                for irip=1:length(riptime)
                    ripid = find(a{i}.behavResources(id_Pre{i}(k)).PosMat(:,1)>riptime(irip),1,'first');
                    plot(tempX(ripid),tempY(ripid),...
                        'o','Color','b','MarkerSize',10,'LineWidth',2);
                    hold on
                end
                clear tempX tempY
            end
            axis off
            xlim([-0.05 1.05])    
            ylim([-0.05 1.05])
            title(['Pre-tests (N=' num2str(nrip(i,1)) ')']) 
            % constructing the u maze
            f_draw_umaze
%             %legend (make legend outside of plot and subplot!)
%             axP = get(gca,'Position');
%             lg = legend(p1([1:lnpre(i)]),sprintfc('%d',1:lnpre),'Location','WestOutside');
%             title(lg,'Trial #')
%             set(gca, 'Position', axP)
        
        subplot(1,3,2) 
            for k=1:lncond(i)   
                % -- trajectories    
                p2(k) = plot(Data(a{i}.behavResources(id_Cond{i}(k)).AlignedXtsd),...
                    Data(a{i}.behavResources(id_Cond{i}(k)).AlignedYtsd),...
                         'linewidth',.5,'Color',[.3 .3 .3]);  
                hold on
                tempX = Data(a{i}.behavResources(id_Cond{i}(k)).AlignedXtsd);
                tempY = Data(a{i}.behavResources(id_Cond{i}(k)).AlignedYtsd);
                riptime = Data(CondRipples_all{i,k})/1e4;
                for irip=1:length(riptime)
                    ripid = find(a{i}.behavResources(id_Cond{i}(k)).PosMat(:,1)>riptime(irip),1,'first');
                    plot(tempX(ripid),tempY(ripid),...
                        'o','Color','b','MarkerSize',10,'LineWidth',2);
                    hold on
                end
                clear tempX tempY
            end
            axis off
            xlim([-0.05 1.05])    
            ylim([-0.05 1.05])
            title(['Cond (N=' num2str(nrip(i,3)) ')']) 
            % constructing the u maze
            f_draw_umaze  
        

        subplot(1,3,3) 
            for k=1:lnpre(i)
                % -- trajectories    
                p3(k) = plot(Data(a{i}.behavResources(id_Post{i}(k)).AlignedXtsd),...
                    Data(a{i}.behavResources(id_Post{i}(k)).AlignedYtsd),...
                         'linewidth',.5,'Color',[.3 .3 .3]);  
                hold on
                tempX = Data(a{i}.behavResources(id_Post{i}(k)).AlignedXtsd);
                tempY = Data(a{i}.behavResources(id_Post{i}(k)).AlignedYtsd);
                riptime = Data(PostRipples_all{i,k})/1e4;
                for irip=1:length(riptime)
                    ripid = find(a{i}.behavResources(id_Post{i}(k)).PosMat(:,1)>riptime(irip),1,'first');
                    plot(tempX(ripid),tempY(ripid),...
                        'o','Color','b','MarkerSize',10,'LineWidth',2);
                    hold on
                end
                clear tempX tempY
            end
            axis off
            xlim([-0.05 1.05])    
            ylim([-0.05 1.05])
            title(['Post-tests (N=' num2str(nrip(i,2)) ')'])  
            % constructing the u maze
            f_draw_umaze
            
       print([dir_out 'Ripples_Locations' num2str(subj(i))], '-dpng', '-r600');
end

%--------------------------------------------------------------------------
%---------------- ripples / speed effect  ------------------
%--------------------------------------------------------------------------


RipplesEffect = (Post_N_norm_Safe_mean) - (Pre_N_norm_Safe_mean);
SpeedEffect = Post_VZmean_mean - Pre_VZmean_mean;
figure
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


%--------------------------------------------------------------------------
%---------------- Figure ripples Pre vs Post ------------------
%--------------------------------------------------------------------------
% 
maxy = max(max([Pre_N_norm_Shock_mean Cond_N_norm_Shock_mean Post_N_norm_Shock_mean ...
                Pre_N_norm_Rest_mean Cond_N_norm_Rest_mean Post_N_norm_Rest_mean]))*1.15;

supertit = 'Ripples density during pre- and post-tests';
figure('Color',[1 1 1], 'rend','painters','pos',[1 1 1400 500],'Name', supertit, 'NumberTitle','off')
    subplot(1,3,1)
        [p,h, her] = PlotErrorBarN_SL([Pre_N_norm_Shock_mean Post_N_norm_Shock_mean],...
                        'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, ...
                        'colorpoints',1,'showpoints',1);
        set(gca,'Xtick',[1:2],'XtickLabel',{'PreTest', 'PostTest'});
        set(gca, 'FontSize', 14);
        ylim([0 maxy]);
        h.FaceColor = 'flat';
        h.CData(1,:) = [.3 .3 .3];
        h.CData(2,:) = [1 1 1];
        set(h, 'LineWidth', 2);
        set(her, 'LineWidth', 2);
        ylabel('Ripples/s');
        title('Ripples density in Stim Zone', 'FontSize', 18);
        
     subplot(1,3,2)
        [p_preppostsafe,h, her] = PlotErrorBarN_SL([Pre_N_norm_Safe_mean Post_N_norm_Safe_mean],...
                        'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, ...
                        'colorpoints',1,'showpoints',1);
        set(gca,'Xtick',[1:2],'XtickLabel',{'PreTest', 'PostTest'});
        set(gca, 'FontSize', 14);
        ylim([0 maxy]);
        h.FaceColor = 'flat';
        h.CData(1,:) = [.3 .3 .3];
        h.CData(2,:) = [1 1 1];
        set(h, 'LineWidth', 2);
        set(her, 'LineWidth', 2);
        ylabel('Ripples/s');
        title('Ripples density in NoStim Zone', 'FontSize', 18);
        
     subplot(1,3,3)
        [p_prepost,h, her] = PlotErrorBarN_SL([Pre_N_norm_all_mean Post_N_norm_all_mean],...
                        'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, ...
                        'colorpoints',1,'showpoints',1);
        set(gca,'Xtick',[1:2],'XtickLabel',{'PreTest', 'PostTest'});
        set(gca, 'FontSize', 14);
        ylim([0 maxy]);
        h.FaceColor = 'flat';
        h.CData(1,:) = [.3 .3 .3];
        h.CData(2,:) = [1 1 1];
        set(h, 'LineWidth', 2);
        set(her, 'LineWidth', 2);
        ylabel('Ripples/s');
        title('Ripples density in whole maze', 'FontSize', 18);
    
    if sav
        print([dir_out 'RipplesPrePost'], '-dpng', '-r600');
    end


%--------------------------------------------------------------------------
%---------------- Figure ripples Pre/Cond/Post ------------------
%--------------------------------------------------------------------------
voidtmp = nan(length(a),1); 
maxy = max(max([Pre_N_norm_Shock_mean Cond_N_norm_Shock_mean Post_N_norm_Shock_mean voidtmp ...
                Pre_N_norm_Rest_mean Cond_N_norm_Rest_mean Post_N_norm_Rest_mean]))*1.15;

supertit = 'Ripples density during cond/pre-/post-tests';% set plot colors
clrs_default = get(gca,'colororder');
clrs_default(end+1,1:3) = [0 0 0];
% colororder(clrs_default);
figure('Color',[1 1 1], 'rend','painters','pos',[1 1 1000 400],'Name', supertit, 'NumberTitle','off')
        [p,h, her] = PlotErrorBarN_SL([Pre_N_norm_Shock_mean Cond_N_norm_Shock_mean Post_N_norm_Shock_mean voidtmp ...
                                       Pre_N_norm_Rest_mean Cond_N_norm_Rest_mean Post_N_norm_Rest_mean],...
                        'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, ...
                        'colorpoints',1,'showpoints',0);
        set(gca,'Xtick',[2:4:7],'XtickLabel',{'Stim zone', 'Rest of U-Maze'});
        set(gca, 'FontSize', 14);
        ylim([0 maxy]);
        h.FaceColor = 'flat';
        h.CData(1:4:7,:) = repmat([.3 .3 .3],2,1);
        h.CData(2:4:7,:) = repmat([0 0 0],2,1);
        h.CData(3:4:7,:) = repmat([1 1 1],2,1);
        set(h, 'LineWidth', 2);
        set(her, 'LineWidth', 2);
        ylabel('ripples/s');
        title('Ripples density in Stim Zone', 'FontSize', 18);
        
        % creating legend with hidden-fake data (hugly but effective)
            b1=bar([-3],[ 1],'FaceColor','flat');
            b2=bar([-2],[ 1],'FaceColor','flat');
            b3=bar([-1],[ 1],'FaceColor','flat');
            b1.CData(1,:) = repmat([.3 .3 .3],1);
            b2.CData(1,:) = repmat([0 0 0],1);
            b3.CData(1,:) = repmat([1 1 1],1);
            legend([b1 b2 b3],{'Pre','Cond','Post'})%,'Location','EastOutside')          
    if sav
        print([dir_out 'RipplesPreCondPost'], '-dpng', '-r600');
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
    
%--------------------------------------------------------------------------
%                    A V E R A G E    R I P P L E 	
%--------------------------------------------------------------------------
i=0;
for ii=1:length(Dir.path)
    for iexp=1:length(Dir.path{ii})
        i=i+1;
        disp('--- processing LFP for average ripple---')
        % get data
        LFP_rip = load([Dir.path{ii}{iexp} '/LFPData/LFP' num2str(Rip{i}.dHPC_rip) '.mat']);
        LFPf=FilterLFP(LFP_rip.LFP,[120 220],1048);
        LFPr=LFP_rip.LFP;
        rmvt = Restrict(ripplesPeak{i},or(or(IS_TestPre{i},IS_Cond{i}),IS_TestPost{i}));
        
        if ~isempty(Data(rmvt))
            % Plot Raw stuff
            [M,T]=PlotRipRaw(LFPr,Data(rmvt)/1E4, [-60 60],'PlotFigure',0);
            M_task = M; T_task=T;
            %SAVING ripraw variables to ripples.mat for later use
            save([Dir.path{ii}{iexp} 'SWR.mat'],'M_task','T_task','-append');

%             % plot average ripple
%             supertit = ['Average ripple - M' num2str(subj(i))];
%             figure('Color',[1 1 1], 'rend','painters','pos',[10 10 1000 600],'Name', supertit, 'NumberTitle','off')  
%                 shadedErrorBar([],M(:,2),M(:,3),'-b',1);
%                 xlabel('Time (ms)')
%                 ylabel('$${\mu}$$V')   
%                 title(['M' num2str(subj(i)) ' - Average ripple (N=' num2str(length(rmvt)) ')']);        
%                 xlim([1 size(M,1)])
%                 set(gca, 'Xtick', 1:25:size(M,1),...
%                             'Xticklabel', num2cell([floor(M(1,1)*1000):20:ceil(M(end,1)*1000)]))   
% 
%                 %- save picture
%                 if sav
%                     print([dir_out 'M' num2str(subj(i)) '_task_average_ripple.png'], '-dpng', '-r600');
%                 end  
        
    %--------------------------------------------------------------------------
    %                    Global figure	
    %--------------------------------------------------------------------------

            supertit = ['GLOBAL FIGURE: Mouse ' num2str(subj(i))  ' - Ripple '];
            figure('Color',[1 1 1], 'rend','painters','pos',[1 1 1200 700],'Name', supertit, 'NumberTitle','off')
                subplot(2,3,1:2)
                    shadedErrorBar([],M(:,2),M(:,3),'-b',1);
                    xlabel('Time (ms)')
                    ylabel('$${\mu}$$V')   
                    title(['M' num2str(subj(i)) ' - Average ripple (N=' num2str(sum(nrip(i,:))) ')']);      
                    xlim([1 size(M,1)])
                    set(gca, 'Xtick', 1:25:size(M,1),...
                                'Xticklabel', num2cell([floor(M(1,1)*1000):20:ceil(M(end,1)*1000)]))

                subplot(2,3,4) 
                    for k=1:lnpre(i)    
                        % -- trajectories    
                        p1(k) = plot(Data(a{i}.behavResources(id_Pre{i}(k)).AlignedXtsd),...
                            Data(a{i}.behavResources(id_Pre{i}(k)).AlignedYtsd),...
                                 'linewidth',.5,'Color',[.3 .3 .3]);  
                        hold on
                        tempX = Data(a{i}.behavResources(id_Pre{i}(k)).AlignedXtsd);
                        tempY = Data(a{i}.behavResources(id_Pre{i}(k)).AlignedYtsd);
                        riptime = Data(PreRipples_all{i,k})/1e4;
                        for irip=1:length(riptime)
                            ripid = find(a{i}.behavResources(id_Pre{i}(k)).PosMat(:,1)>riptime(irip),1,'first');
                            plot(tempX(ripid),tempY(ripid),...
                                'o','Color','b','MarkerSize',10,'LineWidth',2);
                            hold on
                        end
                        clear tempX tempY
                    end
                    axis off
                    xlim([-0.05 1.05])    
                    ylim([-0.05 1.05])
                    title(['Pre-tests (N=' num2str(nrip(i,1)) ')'])
                    % constructing the u maze
                    f_draw_umaze
        %             %legend (make legend outside of plot and subplot!)
        %             axP = get(gca,'Position');
        %             lg = legend(p1([1:lnpre(i)]),sprintfc('%d',1:lnpre),'Location','WestOutside');
        %             title(lg,'Trial #')
        %             set(gca, 'Position', axP)

                subplot(2,3,5) 
                    for k=1:lncond(i)   
                        % -- trajectories    
                        p2(k) = plot(Data(a{i}.behavResources(id_Cond{i}(k)).AlignedXtsd),...
                            Data(a{i}.behavResources(id_Cond{i}(k)).AlignedYtsd),...
                                 'linewidth',.5,'Color',[.3 .3 .3]);  
                        hold on
                        tempX = Data(a{i}.behavResources(id_Cond{i}(k)).AlignedXtsd);
                        tempY = Data(a{i}.behavResources(id_Cond{i}(k)).AlignedYtsd);
                        riptime = Data(CondRipples_all{i,k})/1e4;
                        for irip=1:length(riptime)
                            ripid = find(a{i}.behavResources(id_Cond{i}(k)).PosMat(:,1)>riptime(irip),1,'first');
                            plot(tempX(ripid),tempY(ripid),...
                                'o','Color','b','MarkerSize',10,'LineWidth',2);
                            hold on
                        end
                        clear tempX tempY
                    end
                    axis off
                    xlim([-0.05 1.05])    
                    ylim([-0.05 1.05])
                    title(['Cond (N=' num2str(nrip(i,3)) ')'])   
                    % constructing the u maze
                    f_draw_umaze  


                subplot(2,3,6) 
                    for k=1:lnpre(i)
                        % -- trajectories    
                        p3(k) = plot(Data(a{i}.behavResources(id_Post{i}(k)).AlignedXtsd),...
                            Data(a{i}.behavResources(id_Post{i}(k)).AlignedYtsd),...
                                 'linewidth',.5,'Color',[.3 .3 .3]);  
                        hold on
                        tempX = Data(a{i}.behavResources(id_Post{i}(k)).AlignedXtsd);
                        tempY = Data(a{i}.behavResources(id_Post{i}(k)).AlignedYtsd);
                        riptime = Data(PostRipples_all{i,k})/1e4;
                        for irip=1:length(riptime)
                            ripid = find(a{i}.behavResources(id_Post{i}(k)).PosMat(:,1)>riptime(irip),1,'first');
                            plot(tempX(ripid),tempY(ripid),...
                                'o','Color','b','MarkerSize',10,'LineWidth',2);
                            hold on
                        end
                        clear tempX tempY
                    end
                    axis off
                    xlim([-0.05 1.05])    
                    ylim([-0.05 1.05])
                    title(['Post-tests (N=' num2str(nrip(i,2)) ')'])   
                    % constructing the u maze
                    f_draw_umaze

               print([dir_out 'ID_Global_Ripples' num2str(subj(i))], '-dpng', '-r600');
        end
    end
end


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

end