function sleepcycles_ana_study(Dir, expe, mice_num, varargin)

%==========================================================================
% Details: main wrappper for wake study (in cycles) for ECR project
%
% INPUTS:
%       - Dir               includes all directories for each experiment
%                           Format:
%                           Dir{<exp1>,<exp2>}.path{<mouse1>},{<mouse2a>,<mouse2b>},{<mouse3>},
%                           ...}
%       - expe              Name of experiment in PathForExperiment
%                           Format:
%                               expe = {'ExpeName1','ExpeName2'};
%       - mice_num          ID # of all mice for the analyses
%                           Format:
%                               mice_num = {[mouse1 mouse2 mouse3],[mouse1 mouse2]};
% OPTIONAL:
%       - remparams         times for cycle definition.
%                           time 1: merge REM intervals (in seconds)
%                           time 2: drop REM intervals (in seconds)
%                           Format: [timeMERGE timeDROP]
%
% OUTPUT:
%       -figH               Figures handles (for saving)
%       -wake               Global strutures with all variables
%
% NOTES: none
%
%   Written by Samuel Laventure - 2022-03
%      
%==========================================================================

% parsing varargin
for i = 1:2:length(varargin)
    if ~ischar(varargin{i})
        error(['Parameter ' num2str(i+2) ' is not a property.']);
    end
    switch(lower(varargin{i}))
        case 'remparams'
            remparams = varargin{i+1};
            if ~(length(remparams)==2)
                error('remparams needs 2 parameters: [TimeMergeREM TimeDropREM].');
            end
        case 'plotfig'
            plotfig = varargin{i+1};
            if ~(plotfig==1) && ~(plotfig==0)
                error('plotfig should either be 0 or 1.');
            end
        otherwise
            error(['Unknown property ''' num2str(varargin{i}) '''.']);
    end
end

%check if exist and assign default value if not
% parameters to define cycles
if ~exist('remparams','var')
    remparams= [0 0];
end
% plot figures 
if ~exist('plotfig','var')
    plotfig=1;
end

% load data
load([dropbox '/DataSL/SleepCycles/sleepcycle_data.mat']);

exp = sleepcycle.info.exp;
mice_num = sleepcycle.info.mice_num;
sEpoch = sleepcycle.sEpoch;
sSession = sleepcycle.sSession;
cycleEpoch = sleepcycle.cycleEpoch;
remdur = sleepcycle.remdur;

% get experiment names
for iexp=1:length(expe)
    switch expe{iexp}
        case 'StimMFBWake'
            expname{iexp}='MFB';
        case 'Novel'
            expname{iexp}='Novel';
        case 'UMazePAG'
            expname{iexp}='PAG';
        case 'Known'
            expname{iexp}='Known';
        case 'BaselineSleep'
            expname{iexp}='BaselineSleep';
        otherwise
            expname{iexp}=expe{iexp};
    end
end

% var init
stageName = {'NREM','REM','Wake'};
sessName = {'Pre-test','Post-test'};
colori = {[0 0 .8], [.8 0 0], [0 0 0]}; % for hypnogram
clr = {[0 .8 0],[.9 0 0],[1 1 1],[0 0 0]};  %arbitrary order. can change or automate later
clr_letter = {'-g','-r','-k'};
clr_letter2 = {'g','r','k'};
numexp = 3; % number of experiment tested

%%
%#####################################################################
%#                           M  A  I  N
%#####################################################################
% get max number of subject
for iexp=1:numexp
    nsuj(iexp) = length(mice_num{iexp}); 
end
maxsuj = max(nsuj);
for ilen=1:size(params,2)
    for iexp=1:numexp %length(expe)
        % get number of session
        nsess(iexp) = size(sEpoch{iexp,1},1);
        %init vars
        for isess=1:nsess(iexp)
            remdur_dyn_tmp{isess} = nan(maxsuj,100);  
        end
        for isuj = 1:length(mice_num{iexp})
            for isess=1:nsess(iexp)
                nbCycles{ilen}{iexp,isess}(isuj) = size(cycleEpoch{iexp,isuj}{ilen}{isess},2);
                for icyc=1:nbCycles{iexp,isess}(isuj)
                    remdur_dyn_tmp{ilen}{isess}(isuj,icyc) = ...
                        remdur{iexp,isuj}{ilen}{isess,icyc};  
                end
            end
        end
        % number of wake dynamic
        dyn_remdur{iexp} = remdur_dyn_tmp;
        % get number of mouse per sleep cycle #
        for isess=1:nsess
            for icyc=1:100
                dyn_remdur_num{ilen}(iexp,isess,icyc) = length(find(dyn_remdur{iexp}{ilen}{isess}(:,icyc)>=0));  
            end
        end
    end
    % data prep for figures

    for iexp=1:numexp
        for isess=1:nsess(iexp)
            % rem length by cycle
            dat_dyn_remdur{ilen}{iexp,isess} = nanmean(dyn_remdur{iexp}{ilen}{isess});
            dat_dyn_remdur_std{ilen}{iexp,isess} = nanstd(dyn_remdur{iexp}{ilen}{isess})/ ...
                (sqrt(length(dyn_remdur{iexp}{ilen}{isess})));
        end
    end
  
% Median wake by cycle
% fig param        
ymax = max([dat_dyn_remdur{ilen}{:,:}])+max([dat_dyn_remdur{ilen}{:,:}])*.25;
for iexp=1:numexp
    for isess=1:nsess(iexp)
        [a b] = find(dat_dyn_remdur{ilen}{iexp,isess}(dat_dyn_remdur{ilen}{iexp,isess}>-1));
        cnt(iexp,isess) = max(b);
    end
end
xmax = max(max(cnt));

supertit = ['Merged-REM duration per cycle (' num2str(params(1,ilen)) ')'];
figH.remdur = figure('Color',[1 1 1], 'rend','painters','pos',[1 1 600 600], ...
    'Name', supertit, 'NumberTitle','off'); 
    % set axes
    if nsess(1)==1 
        ax_plot{1}= axes('position', [.15 .25 .8 .7]);
        ax_num{1} = axes('position', [.15 .05 .8 .15]);
    else
        ax_plot{1}= axes('position', [.15 .7 .8 .25]);
        ax_num{1} = axes('position', [.15 .57 .8 .10]);
        ax_plot{2}= axes('position', [.15 .20 .8 .25]);
        ax_num{2} = axes('position', [.15 .05 .8 .10]);
    end

    
    for isess=1:nsess(iexp)
        for iexp=1:numexp
            axes(ax_plot{isess})
                shadedErrorBar([],dat_dyn_remdur{ilen}{iexp,isess},...
                    dat_dyn_remdur_std{ilen}{iexp,isess},clr_letter{iexp},1)
                hold on
                ylim([0 ymax])
                xlim([1 xmax])
                ylabel({'Merged-REM','duration (sec)'})
                if isess==nsess(iexp)
                    xlabel('Cycle #')
                else
%                     legend(expname{1:numexp},'Location','NorthEast')
                end
                if nsess(iexp)==2
                    title(sessName{isess})
                end
                makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16) 
                
            axes(ax_num{isess})
                plot(squeeze(dyn_remdur_num(iexp,isess,:)),clr_letter2{iexp})
                hold on
                xlim([1 xmax])
                ylabel({'nb of','mice'})
                makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16) 
                
                if isess==nsess(iexp)
                    legend(expname{1:numexp},'Location','NorthEast','FontSize',6)
                end
        end
    end    
end

            
%             % -- cycle density --
%             nbCycles{iexp,isess}(isuj) = size(cycleEpoch{iexp,isuj}{isess},2);
%             % get total time per cycle
%             for icyc=1:nbCycles{iexp,isess}(isuj)
%                 timetot_byCyc{iexp,isess,isuj}(icyc) = ...
%                     sum(End(cycleEpoch{iexp,isuj}{isess}{icyc})- ...
%                     Start(cycleEpoch{iexp,isuj}{isess}{icyc}));
%             end
%             % total time covered by cycles
%             timetot_Cyc{iexp,isess}(isuj) = sum(timetot_byCyc{iexp,isess,isuj});
%             % number of cycle by hour (density)
%             den_cycle{iexp,isess}(isuj) = nbCycles{iexp,isess}(isuj)/(timetot_Cyc{iexp,isess}(isuj)/3600e4);
%             % percentage of wake during cycles
%             for icyc=1:nbCycles{iexp,isess}(isuj)
%                 wakeperc_byCyc(iexp,isess,isuj,icyc) = ...
%                     (waketotdur{iexp,isuj}{isess}(icyc)/(timetot_byCyc{iexp,isess,isuj}(icyc)/1e4))*100;
%             end
%             % -- first cycle --
%             firstcyc_len = ep_len{iexp,isuj}{isess}(1,:);
%             firstcyc_sum{iexp,isess}(isuj) = sum(firstcyc_len);
%             % -- first wake episode --
%             nrtw = 0; ncyc=0;
%             for icyc=2:nbCycles{iexp,isess}(isuj)
%                 st = Start(wakeCycles{iexp,isuj}{isess,icyc});
%                 if ~isempty(st)
%                     ncyc=ncyc+1;
%                     % rem-to-wake
%                     firstwake_tim{iexp,isess,isuj}(icyc) =  ...
%                         (st(1)-End(cycleEpoch{iexp,isuj}{isess}{icyc-1}))/1e4;
%                     if firstwake_tim{iexp,isess,isuj}(icyc)<15
%                         nrtw=nrtw+1; % add to rem to wake
%                     end
%                 else
%                     firstwake_tim{iexp,isess,isuj}(icyc) = nan;
%                     firstwake_len{iexp,isess,isuj}(icyc) = nan;
%                 end
%                 clear st
%             end
%             remtowake_rate{iexp,isess}(isuj) = nrtw/ncyc*100;
%             % -- length first wake after rem--
%             firstwake_len{iexp,isess,isuj} = ...
%                 ep_len{iexp,isuj}{isess}(2:size(ep_len{iexp,isuj}{isess},1),1);
%             firstwake_mean{iexp,isess}(isuj) = nanmean(firstwake_len{iexp,isess,isuj});
%             % -- fragmentation --
%             % frag index
%             xcyc = 1;
%             for icyc=2:nbCycles{iexp,isess}(isuj)
%                 if nbCycles{iexp,isess}(isuj)>2
%                     frag{iexp,isess,isuj}(xcyc) = nwake{iexp,isuj}{isess}(icyc)/wakeperc_byCyc(iexp,isess,isuj,icyc);   
%                     xcyc=xcyc+1;
%                 else
%                     frag{iexp,isess,isuj}(1) = nan;
%                 end
%             end
%             frag_mean{iexp,isess}(isuj) = nanmean(frag{iexp,isess,isuj}); 
%             % number of wake dynamic
%             dyn_wake_tmp{isess}(isuj,1:length(nwake{iexp,isuj}{isess})) = ...
%                 nwake{iexp,isuj}{isess};  
%             % average wake/total wake by cycle
%             ep_len_mean{iexp,isess}(isuj,1:size(ep_len{iexp,isuj}{isess},1)) = ...
%                 nanmean(ep_len{iexp,isuj}{isess},2);
%             ep_len_med{iexp,isess}(isuj,1:size(ep_len{iexp,isuj}{isess},1)) = ...
%                 nanmedian(ep_len{iexp,isuj}{isess},2);
%             
%             % check that data is filled for all sessions
%             if (isess==nsess(iexp)) && (nsess(iexp)>1)
%                 % init vars
%                 numvar = 5;
%                 for ivar=1:numvar
%                     ok{ivar} = zeros(1,nsess(iexp));
%                 end
%                 % number of cycle by hour (density)
%                 for isess=1:nsess(iexp)
%                     if ~isnan(den_cycle{iexp,isess}(isuj)),     ok{1}(isess)=1; end
%                     if ~isnan(firstcyc_sum{iexp,isess}(isuj)),  ok{2}(isess)=1; end
%                     if ~isnan(remtowake_rate{iexp,isess}(isuj)),ok{3}(isess)=1; end
%                     if ~isnan(firstwake_mean{iexp,isess}(isuj)),ok{4}(isess)=1; end
%                     if ~isnan(frag_mean{iexp,isess}(isuj)),     ok{5}(isess)=1; end
%                 end
%                 for ivar=1:numvar
%                     notok = find(ok{ivar}==0);
%                     if ~isempty(notok)
%                         okid = find(ok{ivar}==1);
%                         for i=1:length(okid)
%                             switch ivar
%                                 case 1
%                                     den_cycle{iexp,okid(i)}(isuj) = nan; 
%                                 case 2
%                                     firstcyc_sum{iexp,okid(i)}(isuj) = nan; 
%                                 case 3
%                                     remtowake_rate{iexp,okid(i)}(isuj) = nan; 
%                                 case 4
%                                     firstwake_mean{iexp,okid(i)}(isuj) = nan; 
%                                 case 5
%                                     frag_mean{iexp,okid(i)}(isuj) = nan; 
%                             end
%                         end
%                     end
%                     clear notok okid
%                 end
%             end
%             clear ok
%         end
%     end
%     % number of wake dynamic
%     dyn_wake{iexp} = dyn_wake_tmp;
%     % get number of mouse per sleep cycle #
%     for isess=1:nsess
%         for icyc=1:100
%             dyn_wakenum(iexp,isess,icyc) = length(find(dyn_wake{iexp}{isess}(:,icyc)>=0));  
%         end
%     end
% end
% 
% %% Prep data for figures
% 
% dat_den_cycle = nan(numexp*nsess(1,1)+(nsess(1,1)-1),maxsuj);
% dat_firstcyc = nan(numexp*nsess(1,1)+(nsess(1,1)-1),maxsuj);
% dat_remtowake = nan(numexp*nsess(1,1)+(nsess(1,1)-1),maxsuj);
% dat_firstwake = nan(numexp*nsess(1,1)+(nsess(1,1)-1),maxsuj);
% dat_frag = nan(numexp*nsess(1,1)+(nsess(1,1)-1),maxsuj);
% for iexp=1:numexp
%     for isess=1:nsess(iexp)
%         % number of cycle by hour (density)
%         dat_den_cycle((isess*(numexp+1))-(numexp+1)+iexp,1:length(den_cycle{iexp,isess})) = ...
%             den_cycle{iexp,isess};
%         % first cycle wake length
%         dat_firstcyc((isess*(numexp+1))-(numexp+1)+iexp,1:length(den_cycle{iexp,isess})) = ...
%             firstcyc_sum{iexp,isess};
%         % rem-to-wake ratio
%         dat_remtowake((isess*(numexp+1))-(numexp+1)+iexp,1:length(den_cycle{iexp,isess})) = ...
%             remtowake_rate{iexp,isess};
%         % first wake after rem
%         dat_firstwake((isess*(numexp+1))-(numexp+1)+iexp,1:length(den_cycle{iexp,isess})) = ...
%             firstwake_mean{iexp,isess};
%         % fragmentation
%         dat_frag((isess*(numexp+1))-(numexp+1)+iexp,1:length(den_cycle{iexp,isess})) = ...
%             frag_mean{iexp,isess};
%         % number of wake dynamic
%         dat_dyn_wake{iexp,isess} = nanmean(dyn_wake{iexp}{isess});
%         dat_dyn_wake_std{iexp,isess} = nanstd(dyn_wake{iexp}{isess})/(sqrt(length(dyn_wake{iexp}{isess})));
%         % average/median wake length by cycle
%         dat_eplen_mean{iexp,isess} = nanmean(ep_len_mean{iexp,isess});
%         dat_eplen_meanse{iexp,isess} = nanstd(ep_len_mean{iexp,isess})/(sqrt(length(ep_len_mean{iexp,isess})));
%         dat_eplen_med{iexp,isess} = nanmedian(ep_len_mean{iexp,isess});
%         dat_eplen_medse{iexp,isess} = nanstd(ep_len_med{iexp,isess})/(sqrt(length(ep_len_med{iexp,isess})));
%     end
% end
% 
% % differences
% dat_den_cycle_dif   = nan(numexp,maxsuj);
% dat_firstcyc_dif    = nan(numexp,maxsuj);
% dat_remtowake_dif   = nan(numexp,maxsuj);
% dat_firstwake_dif   = nan(numexp,maxsuj);
% dat_frag_dif        = nan(numexp,maxsuj);
% 
% for iexp=1:numexp
%     for isuj=1:length(mice_num{iexp})
%         % number of cycle by hour (density)
%         dat_den_cycle_dif(iexp,isuj) = ...
%             (den_cycle{iexp,2}(isuj)-den_cycle{iexp,1}(isuj))/den_cycle{iexp,1}(isuj)*100;
%         % first cycle wake length
%         if ~(firstcyc_sum{iexp,1}(isuj)==Inf) && (firstcyc_sum{iexp,1}(isuj)>600)
%             dat_firstcyc_dif(iexp,isuj) = ...
%                 (firstcyc_sum{iexp,isess}(isuj)-firstcyc_sum{iexp,1}(isuj))/firstcyc_sum{iexp,1}(isuj)*100;
%         else
%             dat_firstcyc_dif(iexp,isuj) = nan;
%         end
%         % rem-to-wake
%         dat_remtowake_dif(iexp,isuj) = ...
%             (remtowake_rate{iexp,isess}(isuj)-remtowake_rate{iexp,1}(isuj))/remtowake_rate{iexp,1}(isuj)*100;
%         % first wake after rem
%         dat_firstwake_dif(iexp,isuj) = ...
%             (firstwake_mean{iexp,isess}(isuj)-firstwake_mean{iexp,1}(isuj))/firstwake_mean{iexp,1}(isuj)*100;
%         % fragmentation
%         dat_frag_dif(iexp,isuj) = ...
%             (frag_mean{iexp,isess}(isuj)-frag_mean{iexp,1}(isuj))/frag_mean{iexp,1}(isuj)*100;
%         
%     end
% end
% 
% %%
% %#####################################################################
% %#                     P L O T T I N G
% %#####################################################################
% disp('Plotting...')
% 
% % number of cycle by hour (density)
% supertit = 'Cycle Density (cycle/hour)';
% figH.cycden = figure('Color',[1 1 1], 'rend','painters','pos',[1 1 950 350], ...
%     'Name', supertit, 'NumberTitle','off'); 
%     subplot(1,2,1)
%         [~,h,her] = PlotErrorBarN_SL(squeeze(dat_den_cycle(:,:))',...
%             'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3],...
%             'showsigstar','sig','showpoints',1,'paired',0);
%             h.FaceColor = 'flat';
%             h.FaceAlpha = .5;
%             for isess=1:nsess(1)
%                 for iexp=1:numexp
%                     h.CData(((isess*(numexp+1))-4+iexp),:) = clr{iexp};
%                 end
%             end
%             set(gca,'xticklabel',{[]})    
%             set(h, 'LineWidth', 1);
%             set(her, 'LineWidth', 1);
%             if nsess(1)==1
%                 xticks([2]);
%                 xticklabels('');
%             else
%                 xticks([ceil(numexp/2) ceil(numexp/2)*numexp]);
%                 xticklabels({'Pre-Sleep','Post-Sleep'});
%             end
%             title({'Cycle per hour','(including wake)'});
%             ylabel('cycle/hour')
%             makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16)  
%         
%     subplot(1,2,2)
%         [~,h,her] = PlotErrorBarN_SL(squeeze(dat_den_cycle_dif(:,:))',...
%             'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3],...
%             'showsigstar','sig','showpoints',1,'paired',0);
%             h.FaceColor = 'flat';
%             h.FaceAlpha = .5;
%             for iexp=1:numexp()
%                 h.CData(iexp,:) = clr{iexp};
%             end
%             set(gca,'xticklabel',{[]})    
%             set(h, 'LineWidth', 1);
%             set(her, 'LineWidth', 1);
%             title({'Post/Pre change (%)'});
%             ylabel('%')
%             makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16)  
%         
% % first cycle wake length
% supertit = 'First cycle - amount of wake';
% figH.firstcyc = figure('Color',[1 1 1], 'rend','painters','pos',[1 1 950 350], ...
%     'Name', supertit, 'NumberTitle','off');
%     subplot(1,2,1)
%         [~,h,her] = PlotErrorBarN_SL(squeeze(dat_firstcyc(:,:))',...
%                 'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3],...
%                 'showsigstar','sig','showpoints',1,'paired',0);
%             h.FaceColor = 'flat';
%             h.FaceAlpha = .5;
%             for isess=1:nsess(1)
%                 for iexp=1:numexp()
%                     h.CData(((isess*(numexp+1))-4+iexp),:) = clr{iexp};
%                 end
%             end
%             set(gca,'xticklabel',{[]})    
%             set(h, 'LineWidth', 1);
%             set(her, 'LineWidth', 1);
%             if nsess(1)==1
%                 xticks([2]);
%                 xticklabels('');
%             else
%                 xticks([ceil(numexp/2) ceil(numexp/2)*numexp]);
%                 xticklabels({'Pre-Sleep','Post-Sleep'});
%             end
%             title({'First cycle','amount of wake (s)'});
%             ylabel('duration (s)')
%             makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16)  
%         
%     subplot(1,2,2)
%         [~,h,her] = PlotErrorBarN_SL(squeeze(dat_firstcyc_dif(:,:))',...
%             'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3],...
%             'showsigstar','sig','showpoints',1,'paired',0);
%             h.FaceColor = 'flat';
%             h.FaceAlpha = .5;
%             for iexp=1:numexp()
%                 h.CData(iexp,:) = clr{iexp};
%             end
%             set(gca,'xticklabel',{[]})    
%             set(h, 'LineWidth', 1);
%             set(her, 'LineWidth', 1);
%             title({'Post/Pre change (%)'});
%             ylabel('%')
%             makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16)   
% 
% % rem-to-wake
% supertit = 'REM to Wake transition - ratio';
% figH.remtowake = figure('Color',[1 1 1], 'rend','painters','pos',[1 1 950 350], ...
%     'Name', supertit, 'NumberTitle','off');
%     subplot(1,2,1)
%         [~,h,her] = PlotErrorBarN_SL(squeeze(dat_remtowake(:,:))',...
%                 'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3],...
%                 'showsigstar','sig','showpoints',1,'paired',0);
%             h.FaceColor = 'flat';
%             h.FaceAlpha = .5;
%             for isess=1:nsess(1)
%                 for iexp=1:numexp()
%                     h.CData(((isess*(numexp+1))-4+iexp),:) = clr{iexp};
%                 end
%             end
%             set(gca,'xticklabel',{[]})    
%             set(h, 'LineWidth', 1);
%             set(her, 'LineWidth', 1);
%             if nsess(1)==1
%                 xticks([2]);
%                 xticklabels('');
%             else
%                 xticks([ceil(numexp/2) ceil(numexp/2)*numexp]);
%                 xticklabels({'Pre-Sleep','Post-Sleep'});
%             end
%             title({'Percentage of','REM-to-Wake transitions'});
%             ylabel('%')
%             makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16)   
%             
%     subplot(1,2,2)
%         [~,h,her] = PlotErrorBarN_SL(squeeze(dat_remtowake_dif(:,:))',...
%             'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3],...
%             'showsigstar','sig','showpoints',1,'paired',0);
%             h.FaceColor = 'flat';
%             h.FaceAlpha = .5;
%             for iexp=1:numexp()
%                 h.CData(iexp,:) = clr{iexp};
%             end
%             set(gca,'xticklabel',{[]})    
%             set(h, 'LineWidth', 1);
%             set(her, 'LineWidth', 1);
%             title({'Post/Pre change (%)'});
%             ylabel('%')
%             makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16) 
%             
% 
% % first wake
% supertit = 'Duration of first wake after REM';
% figH.firstwake = figure('Color',[1 1 1], 'rend','painters','pos',[1 1 950 350], ...
%     'Name', supertit, 'NumberTitle','off');
%     subplot(1,2,1)
%         [~,h,her] = PlotErrorBarN_SL(squeeze(dat_firstwake(:,:))',...
%                 'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3],...
%                 'showsigstar','sig','showpoints',1,'paired',0);
%             h.FaceColor = 'flat';
%             h.FaceAlpha = .5;
%             for isess=1:nsess(1)
%                 for iexp=1:numexp()
%                     h.CData(((isess*(numexp+1))-4+iexp),:) = clr{iexp};
%                 end
%             end
%             set(gca,'xticklabel',{[]})    
%             set(h, 'LineWidth', 1);
%             set(her, 'LineWidth', 1);
%             if nsess(1)==1
%                 xticks([2]);
%                 xticklabels('');
%             else
%                 xticks([ceil(numexp/2) ceil(numexp/2)*numexp]);
%                 xticklabels({'Pre-Sleep','Post-Sleep'});
%             end
%             title({'Duration of first wake','after REM episode'});
%             ylabel('duration (s)')
%     %         ylim([0 100])
%             makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16)   
%             
%     subplot(1,2,2)
%         [~,h,her] = PlotErrorBarN_SL(squeeze(dat_firstwake_dif(:,:))',...
%             'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3],...
%             'showsigstar','sig','showpoints',1,'paired',0);
%             h.FaceColor = 'flat';
%             h.FaceAlpha = .5;
%             for iexp=1:numexp()
%                 h.CData(iexp,:) = clr{iexp};
%             end
%             set(gca,'xticklabel',{[]})    
%             set(h, 'LineWidth', 1);
%             set(her, 'LineWidth', 1);
%             title({'Post/Pre change (%)'});
%             ylabel('%')
%             makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16) 
% 
% % fragmentation
% supertit = 'Sleep fragmentation';
% figH.frag = figure('Color',[1 1 1], 'rend','painters','pos',[1 1 950 350], ...
%     'Name', supertit, 'NumberTitle','off');
%     subplot(1,2,1)
%         [~,h,her] = PlotErrorBarN_SL(squeeze(dat_frag(:,:))',...
%                 'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3],...
%                 'showsigstar','sig','showpoints',1,'paired',0);
%             h.FaceColor = 'flat';
%             h.FaceAlpha = .5;
%             for isess=1:nsess(1)
%                 for iexp=1:numexp()
%                     h.CData(((isess*(numexp+1))-4+iexp),:) = clr{iexp};
%                 end
%             end
%             set(gca,'xticklabel',{[]})    
%             set(h, 'LineWidth', 1);
%             set(her, 'LineWidth', 1);
%             if nsess(1)==1
%                 xticks([2]);
%                 xticklabels('');
%             else
%                 xticks([ceil(numexp/2) ceil(numexp/2)*numexp]);
%                 xticklabels({'Pre-Sleep','Post-Sleep'});
%             end
%             title({'Sleep','fragmentation'});
%             ylabel('frag. indice')
%             makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16)  
%             
%     subplot(1,2,2)
%         [~,h,her] = PlotErrorBarN_SL(squeeze(dat_frag_dif(:,:))',...
%             'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3],...
%             'showsigstar','sig','showpoints',1,'paired',0);
%             h.FaceColor = 'flat';
%             h.FaceAlpha = .5;
%             for iexp=1:numexp()
%                 h.CData(iexp,:) = clr{iexp};
%             end
%             set(gca,'xticklabel',{[]})    
%             set(h, 'LineWidth', 1);
%             set(her, 'LineWidth', 1);
%             title({'Post/Pre change (%)'});
%             ylabel('%')
%             makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16) 
% 
% % fig param        
% ymax = max([dat_dyn_wake{:,:}])+max([dat_dyn_wake{:,:}])*.25;
% for iexp=1:numexp
%     for isess=1:nsess(iexp)
%         [a b] = find(dat_dyn_wake{iexp,isess}(dat_dyn_wake{iexp,isess}>-1));
%         cnt(iexp,isess) = max(b);
%     end
% end
% xmax = max(max(cnt));
% 
% % Number of wake episode by cycle
% supertit = 'Number of wake episode by cycle';
% figH.dynwake = figure('Color',[1 1 1], 'rend','painters','pos',[1 1 600 600], ...
%     'Name', supertit, 'NumberTitle','off'); 
%     % set axes
%     if nsess(1)==1 
%         ax_plot{1}= axes('position', [.15 .25 .8 .7]);
%         ax_num{1} = axes('position', [.15 .05 .8 .15]);
%     else
%         ax_plot{1}= axes('position', [.15 .7 .8 .25]);
%         ax_num{1} = axes('position', [.15 .57 .8 .10]);
%         ax_plot{2}= axes('position', [.15 .20 .8 .25]);
%         ax_num{2} = axes('position', [.15 .05 .8 .10]);
%     end
% 
%     
%     for isess=1:nsess(1)
%         for iexp=1:numexp
%             axes(ax_plot{isess})
%                 shadedErrorBar([],dat_dyn_wake{iexp,isess},dat_dyn_wake_std{iexp,isess},clr_letter{iexp},1)
%                 hold on
%                 ylim([0 ymax])
%                 xlim([1 xmax])
%                 ylabel({'nb of','wake episodes'})
%                 if isess==nsess(iexp)
%                     xlabel('Cycle #')
%                 else
% %                     legend(expname{1:numexp},'Location','NorthEast')
%                 end
%                 if nsess(iexp)==2
%                     title(sessName{isess})
%                 end
%                 makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16) 
%                 
%             axes(ax_num{isess})
%                 plot(squeeze(dyn_wakenum(iexp,isess,:)),clr_letter2{iexp})
%                 hold on
%                 xlim([1 xmax])
%                 ylabel({'nb of','mice'})
%                 makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16) 
%                 
%                 if isess==nsess(iexp)
%                     legend(expname{1:numexp},'Location','NorthEast','FontSize',6)
%                 end
%         end
%     end
%     
% % Average wake by cycle
% % fig param        
% ymax = max([dat_eplen_mean{:,:}])+max([dat_eplen_mean{:,:}])*.25;
% for iexp=1:numexp
%     for isess=1:nsess(iexp)
%         [a b] = find(dat_eplen_mean{iexp,isess}(dat_eplen_mean{iexp,isess}>-1));
%         cnt(iexp,isess) = max(b);
%     end
% end
% xmax = max(max(cnt));
% 
% supertit = 'Average wake length by cycle';
% figH.eplen_mean = figure('Color',[1 1 1], 'rend','painters','pos',[1 1 600 600], ...
%     'Name', supertit, 'NumberTitle','off'); 
%     % set axes
%     if nsess(1)==1 
%         ax_plot{1}= axes('position', [.15 .25 .8 .7]);
%         ax_num{1} = axes('position', [.15 .05 .8 .15]);
%     else
%         ax_plot{1}= axes('position', [.15 .7 .8 .25]);
%         ax_num{1} = axes('position', [.15 .57 .8 .10]);
%         ax_plot{2}= axes('position', [.15 .20 .8 .25]);
%         ax_num{2} = axes('position', [.15 .05 .8 .10]);
%     end
% 
%     
%     for isess=1:nsess(iexp)
%         for iexp=1:numexp
%             axes(ax_plot{isess})
%                 shadedErrorBar([],dat_eplen_mean{iexp,isess},dat_eplen_meanse{iexp,isess},clr_letter{iexp},1)
%                 hold on
%                 ylim([0 ymax])
%                 xlim([1 xmax])
%                 ylabel({'wake epoch','average (sec)'})
%                 if isess==nsess(iexp)
%                     xlabel('Cycle #')
%                 else
% %                     legend(expname{1:numexp},'Location','NorthEast')
%                 end
%                 if nsess(iexp)==2
%                     title(sessName{isess})
%                 end
%                 makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16) 
%                 
%             axes(ax_num{isess})
%                 plot(squeeze(dyn_wakenum(iexp,isess,:)),clr_letter2{iexp})
%                 hold on
%                 xlim([1 xmax])
%                 ylabel({'nb of','mice'})
%                 makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16) 
%                 
%                 if isess==nsess(iexp)
%                     legend(expname{1:numexp},'Location','NorthEast','FontSize',6)
%                 end
%         end
%     end
% 
% % Median wake by cycle
% % fig param        
% ymax = max([dat_eplen_med{:,:}])+max([dat_eplen_med{:,:}])*.25;
% for iexp=1:numexp
%     for isess=1:nsess(iexp)
%         [a b] = find(dat_eplen_med{iexp,isess}(dat_eplen_med{iexp,isess}>-1));
%         cnt(iexp,isess) = max(b);
%     end
% end
% xmax = max(max(cnt));
% 
% supertit = 'MEDIAN wake length by cycle';
% figH.eplen_median = figure('Color',[1 1 1], 'rend','painters','pos',[1 1 600 600], ...
%     'Name', supertit, 'NumberTitle','off'); 
%     % set axes
%     if nsess(1)==1 
%         ax_plot{1}= axes('position', [.15 .25 .8 .7]);
%         ax_num{1} = axes('position', [.15 .05 .8 .15]);
%     else
%         ax_plot{1}= axes('position', [.15 .7 .8 .25]);
%         ax_num{1} = axes('position', [.15 .57 .8 .10]);
%         ax_plot{2}= axes('position', [.15 .20 .8 .25]);
%         ax_num{2} = axes('position', [.15 .05 .8 .10]);
%     end
% 
%     
%     for isess=1:nsess(iexp)
%         for iexp=1:numexp
%             axes(ax_plot{isess})
%                 shadedErrorBar([],dat_eplen_med{iexp,isess},dat_eplen_medse{iexp,isess},clr_letter{iexp},1)
%                 hold on
%                 ylim([0 ymax])
%                 xlim([1 xmax])
%                 ylabel({'wake epoch','median (sec)'})
%                 if isess==nsess(iexp)
%                     xlabel('Cycle #')
%                 else
% %                     legend(expname{1:numexp},'Location','NorthEast')
%                 end
%                 if nsess(iexp)==2
%                     title(sessName{isess})
%                 end
%                 makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16) 
%                 
%             axes(ax_num{isess})
%                 plot(squeeze(dyn_wakenum(iexp,isess,:)),clr_letter2{iexp})
%                 hold on
%                 xlim([1 xmax])
%                 ylabel({'nb of','mice'})
%                 makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16) 
%                 
%                 if isess==nsess(iexp)
%                     legend(expname{1:numexp},'Location','NorthEast','FontSize',6)
%                 end
%         end
%     end    
% 
% %% Saving figures
% dirPath = [dropbox '/DataSL/SleepCycles/Params_Merge' num2str(remparams(1)) ...
%     '_Drop' num2str(remparams(2)) '/']; 
% 
% % number of cycle by hour (density)
% figName = 'CycleDensity';
% saveF(figH.cycden,figName,dirPath,'sformat',{'dpng'},'res',900,'savfig',0);
% % first cycle wake length
% figName = 'FirstCycle';
% saveF(figH.firstcyc,figName,dirPath,'sformat',{'dpng'},'res',900,'savfig',0);
% % rem-to-wake ratio
% figName = 'RemToWake';
% saveF(figH.remtowake,figName,dirPath,'sformat',{'dpng'},'res',900,'savfig',0);
% % first wake after rem
% figName = 'FirstWake';
% saveF(figH.firstwake,figName,dirPath,'sformat',{'dpng'},'res',900,'savfig',0);
% % fragmentation
% figName = 'SleepFragmentation';
% saveF(figH.frag,figName,dirPath,'sformat',{'dpng'},'res',900,'savfig',0);
% % number of wake dynamic
% figName = 'WakeDynamic';
% saveF(figH.dynwake,figName,dirPath,'sformat',{'dpng'},'res',900,'savfig',0);
% % average/median wake length by cycle  
% figName = 'WakeEpochAverage';
% saveF(figH.eplen_mean,figName,dirPath,'sformat',{'dpng'},'res',900,'savfig',0);  
% figName = 'WakeEpochMedian';
% saveF(figH.eplen_median,figName,dirPath,'sformat',{'dpng'},'res',900,'savfig',0);  
% 

disp(' ')
disp('Done')


    

