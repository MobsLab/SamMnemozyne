function sam_hb_compare_groups(varargin)

%==========================================================================
% Details: compare hb during MFB and PAG calibrations (could be use to
%          compare any 2 session or group)
%
% INPUTS:
%           - session: name of the sessions in SessionEpoch you want to compare. Needs to
%           be in the same order as your mouse number.  
%               ex: sam_hb_MFBvPAG({'mfb14'},{'pag3'},'micenum',[941 747]))
%       Varargin:
%           - expname:  name of the experiment in PathForExperiment and
%           folder naming
%           - micenum: number of mouse to analyze in [### ### ###]
%           format. Example: 'Mice_to_analyze',[955 945 936 012]
%           - parent_dir_out: 
%       
%
% OUTPUT:
%
% NOTES: needs HeartBeatInfo.mat (from Dat2Mat_##.m [calling
%           DetectHeartBeats_EmbReact_SB.m])
%       
%     -> StimMFBWake exp: 882 has longer stim time so the rate figure show empty longer
%     after stim. 
%
%     -> Heart rate cannot change before another heart beat occurs. Hence
%     for one value, the heart rate stays the same for a number of timepoints 
%
%   Written by Samuel Laventure - 04-05-2020 (based on sam_hb_exp.m)
%      
%==========================================================================

%% Initiation
% Parse parameter list
for i = 1:2:length(varargin)
    if ~ischar(varargin{i})
        error(['Parameter ' num2str(i+2) ' is not a property.']);
    end
    switch(lower(varargin{i}))
        case 'expname'
            expname = varargin{i+1};
            if ~isstring(expname)
                error('Incorrect value for property ''expname''.');
            end
        case 'gr1'
            gr1 = varargin{i+1};
            if ~isint(gr1)
                error('Incorrect value for property ''gr1''.');
            end
        case 'gr2'
            gr2 = varargin{i+1};
            if ~isint(gr2)
                error('Incorrect value for property ''gr2''.');
            end
        case 'main_dir_out'
            main_dir_out = varargin{i+1};
            if ~isstring(main_dir_out)
                error('Incorrect value for property ''main_dir_out''.');
            end
            
        otherwise
            error(['Unknown property ''' num2str(varargin{i}) '''.']);
    end
end

%check if exist and assign default value if not
% which experiment 
if ~exist('expname','var')
    expname = 'StimMFBWake';
    disp(['...Processing default experiment: ' expname]);
end
if ~exist('gr1','var')
    gr1 = [941]; 
    disp(['...Processing default mice #' num2str(gr1)]);
end
if ~exist('gr2','var')
    gr2 = [797]; 
    disp(['...Processing default mice #' num2str(gr2)]);
end
if ~exist('parent_dir_out','var')
    main_dir_out = [dropbox '/DataSL/StimMFBWake/']; 
    disp(['...Output directory set to default: ' main_dir_out]);
end

%% Parameters

% date for dir_out folders
t = char(datetime('now','Format','y-MM-d'));

% Directory to save and name of the figure to save
dir_out = [main_dir_out '/HeartBeat/' t '/'];
if ~exist(dir_out,'dir')
    mkdir(dir_out);
end
sav = 1;
ntrial = 4;  %assuming that all pre, post and cond have the same number of trials 
% threshold for minimum heartbeat (get rid of outliers)
restricted = 0;  % is restrict or not
thresh = 8; % hb/s min
ttime = 3.5;  %time in sec before and after stim to calculate rate
stimdelay=1; %time in sec after stim onset
prebuff=500; %before stim in s1e4
postbuff=1501; %after stim
stimdur=1000;



% Get directories
sessN{1} = 'mfb14';
% sessN{2} = 'x20x2C5V';
% sessB{2} = '2,5V';   % Dima hasa diff name for SessionEpoch than SessionName... This is for the find_sessionid line
sessN{2} = 'x20x2C5V';
sessB{2} = '2,5V'; 
% %group1
% try 
    Dir_gr1 = PathForExperimentsERC_SL_home('CalibMFB');
% catch
%     Dir_gr1 = PathForExperimentsERC_SL('CalibMFB');
% end
Dir_gr1 = RestrictPathForExperiment(Dir_gr1,'nMice', gr1);
% set nbr of mice
nb_gr(1) = size(Dir_gr1.path,2);
%group2
% Dir{2} = PathForExperimentsERC_Dima('UMazePAG');
% Dir{2} = RestrictPathForExperiment(Dir, 'Group', 'ECG');
Dir_gr2.path{1}={'D:\DimaData\M797\Calib-2.5V/'};
% set nbr of mice
nb_gr(2) = size(Dir_gr2.path,2);

%%  Figures parameters
% smoothing interval
smoo =1; % does we smooth or not
sm = 500;

% set text format
set(0,'defaulttextinterpreter','latex');
set(0,'DefaultTextFontname', 'Arial')
set(0,'DefaultAxesFontName', 'Arial')
set(0,'defaultTextFontSize',12)
set(0,'defaultAxesFontSize',12)

%#####################################################################
%#
%#                           M A I N
%#
%#####################################################################
% GET DATA GROUP 1
%GROUP 1
for imouse=1:nb_gr(1)
    % Get behavResources data
    behav{1,imouse} = load([Dir_gr1.path{imouse}{1} '/behavResources.mat'], 'behavResources','SessionEpoch','StimEpoch');
    [idx stimes{1,imouse}] = RestrictSession(Dir_gr1,sessN{1});
%             stimes{igr,imouse} = struct2cell(behav{igr,imouse}.SessionEpoch);  %transform the object structure into cell to allow for navigation using id

    % get stim information
%     load([Dir_gr1.path{imouse}{1} 'LFPData/DigInfo3.mat']);
% %     StimSent{1,imouse} = thresholdIntervals(DigTSD,0.99,'Direction','Above');
%     StimSent{1,imouse} = Start(behav{1,imouse}.StimEpoch);

    % Get session id
    id{1,imouse} = find_sessionid(behav{1,imouse}, sessN{1});

    % load working variables
    ekg{1,imouse} = load([Dir_gr1.path{imouse}{1} '/HeartBeatInfo.mat'], 'EKG');
end
% GROUP 2
for imouse=1:nb_gr(2)
    % Get behavResources data
    behav{2,imouse} = load([Dir_gr2.path{imouse}{1} '/behavResources.mat'], 'behavResources','SessionEpoch','StimEpoch');
    [idx stimes{2,imouse}] = RestrictSession(Dir_gr2,sessN{2});
%     stimes{2,imouse} = behav{2,imouse}.SessionEpoch.x20x2C5V;

    % get stim information
%     load([Dir_gr2.path{imouse}{1} 'LFPData/DigInfo3.mat']);
% %     StimSent{2,imouse} = thresholdIntervals(DigTSD,0.99,'Direction','Above');
%     StimSent{2,imouse} = Start(behav{2,imouse}.StimEpoch);

    % Get session id
    id{2,imouse} = find_sessionid(behav{2,imouse}, sessB{2});
    
    % load working variables
    ekg{2,imouse} = load([Dir_gr2.path{imouse}{1} '/HeartBeatInfo.mat'], 'EKG');
end



for igr=1:2
    for imouse=1:nb_gr(igr)
        if ~restricted
            hb{igr,imouse} = Restrict(Restrict(ekg{igr,imouse}.EKG.HBRate,stimes{igr,imouse}{1}{1}),ekg{igr,imouse}.EKG.GoodEpoch);
        else
            hb{igr,imouse} = RestrictThreshold(Restrict(ekg{igr,imouse}.EKG.HBRate,stimes{igr,imouse}{1}{1}),thresh);
        end
        % calculate mean and sd
        hb_mean(igr,imouse) = nanmean(Data(hb{igr,imouse}));
        hb_std(igr,imouse) = nanstd(Data(hb{igr,imouse}));
        
        %get start time and end time (for figure)
        sstart(igr,imouse) = behav{igr,imouse}.behavResources(id{igr,imouse}{1}).PosMat(1,1);
        send(igr,imouse) = behav{igr,imouse}.behavResources(id{igr,imouse}{1}).PosMat(end,1);

        % stim react
        HBTimes{igr} = Data(ekg{igr,imouse}.EKG.HBTimes);
        tstim = Start(and(behav{igr,imouse}.StimEpoch, stimes{igr,imouse}{1}{1}));
        % verification that the stim are enough far appart
        iddel = find(diff(tstim)<45000);
        iddel = sort(unique([iddel; iddel+1]));
        tstim(iddel)=[];

        % var init
        rateprelfp = nan(size(tstim,1),ttime*1E4);
        ratepostlfp = nan(size(tstim,1),(stimdelay+ttime)*1E4);
        for istim=1:length(tstim)
            % ------ HB pre stim ------ 
            ratepre_id = find((HBTimes{igr}<tstim(istim)) ...
                & (HBTimes{igr}>tstim(istim)-ttime*1E4));
            ratepre{istim} = HBTimes{igr}(ratepre_id);
            hr_pre = 1./movmedian(diff(ratepre{istim}/1e4),[3 0]);
            delta_pre = diff(ratepre{istim}/1e4);

            % setting up rate on LFP points to allow for average between
            % stim
            fst = 1;
            for ihb=1:length(ratepre_id)
                if ihb>1
                    rateprelfp(istim,fst:single(ceil(ratepre{istim}(ihb)-ratepre{istim}(1)))) = hr_pre(ihb-1);
                    deltaprelfp(istim,fst:single(ceil(ratepre{istim}(ihb)-ratepre{istim}(1)))) = delta_pre(ihb-1);
                    fst = (ratepre{istim}(ihb)+1)-ratepre{istim}(1);
                end
            end

            %  ------ HB post stim ------ 
            ratepost_id = find((HBTimes{igr}>tstim(istim)) ...
                & (HBTimes{igr}<tstim(istim)+(stimdelay+ttime)*1E4));
            ratepost{istim} = HBTimes{igr}(ratepost_id);
            hr_post = 1./movmedian(diff(ratepost{istim}/1e4),[0 3]);
            delta_post = diff(ratepost{istim}/1e4);

            % setting up rate on LFP points to allow for average between
            % stim
            fst = (stimdelay+ttime)*1E4;
            tstart = tstim(istim);
            for ihb=length(ratepost_id):-1:1
                if ihb>1
                    if ratepost{istim}(ihb)-tstim(istim) > 1500
                        ratepostlfp(istim,floor(ratepost{istim}(ihb)-tstart):fst) = hr_post(ihb-1);
                        deltapostlfp(istim,floor(ratepost{istim}(ihb)-tstart):fst) = delta_post(ihb-1);
                        fst = floor(ratepost{istim}(ihb)-tstart)-1;
                    end
                end
            end
            
            clear ratepre_id ratepre hr_pre delta_pre ratepost_id ratepost hr_post delta_post 
        end
                
        % calculate mean per mouse
        nbstim(igr,imouse) = length(tstim);
        if nbstim(igr,imouse)
            ratepre_mean(igr,imouse,1:ttime*1E4) = squeeze(squeeze(nanmean(rateprelfp,1)));
            ratepre_std(igr,imouse,1:ttime*1E4) = squeeze(squeeze(nanstd(rateprelfp,1)));
            ratepost_mean(igr,imouse,1:(ttime+stimdelay)*1E4) = squeeze(squeeze(nanmean(ratepostlfp,1)));
            ratepost_std(igr,imouse,1:(ttime+stimdelay)*1E4) = squeeze(squeeze(nanstd(ratepostlfp,1)));
        else
            ratepre_mean(igr,imouse,1:ttime*1E4) = nan;
            ratepost_mean(igr,imouse,1:(ttime+stimdelay)*1E4) = nan;
        end
        ratepre_all{igr,imouse} = rateprelfp(:,1:ttime*1E4);
        ratepost_all{igr,imouse} = ratepostlfp(:,1:(ttime+stimdelay)*1E4);
        clear rateprelfp ratepostlfp tstim
    end    

    % Prepare data for figures
    % Overall means
    if nb_gr(igr) > 1
        ratepre_all_mean{igr} = squeeze(nanmean(nanmean(ratepre_mean(igr,:,:),2)));
        ratepre_all_std{igr} = squeeze(nanmean(nanstd(ratepre_mean(igr,:,:),2)));
        ratepost_all_mean{igr} = squeeze(nanmean(nanmean(ratepost_mean(igr,:,:),2)));
        ratepost_all_std{igr} = squeeze(nanmean(nanstd(ratepost_mean(igr,:,:),2)));
    else
        ratepre_all_mean{igr} = squeeze(ratepre_mean(igr,:,:));
        ratepre_all_std{igr} = squeeze(ratepre_std(igr,:,:));
        ratepost_all_mean{igr} = squeeze(ratepost_mean(igr,:,:));
        ratepost_all_std{igr} = squeeze(ratepost_std(igr,:,:));
    end
    hb_meanall{igr} = squeeze(mean(hb_mean(igr,:),2));
    ratepre_trial_mean{igr} = nanmean(nanmean(ratepre_mean(igr,:,ttime*1E4-19999:ttime*1E4),3),2);
    ratepost_trial_mean{igr} = nanmean(nanmean(ratepost_mean(igr,:,stimdur+1:stimdur+20000),3),2);
    
    % smooth data
    if smoo
        ratepre_all_mean{igr} = smooth(ratepre_all_mean{igr},sm);
        ratepre_all_std{igr} = smooth(ratepre_all_std{igr},sm);    
        ratepost_all_mean{igr} = smooth(ratepost_all_mean{igr},sm);
        ratepost_all_std{igr} = smooth(ratepost_all_std{igr},sm);
    end
    
    % standardize data
    std_ratepre_mean{igr} = (ratepre_all_mean{igr}-mean([ratepre_all_mean{igr}(1:5000,1);ratepost_all_mean{igr}(end-5000:end,1)])) ...
        ./std([ratepre_all_mean{igr}(1:5000,1);ratepost_all_mean{igr}(end-5000:end,1)]);
    std_ratepost_mean{igr} = (ratepost_all_mean{igr}-mean([ratepre_all_mean{igr}(1:5000,1);ratepost_all_mean{igr}(end-5000:end,1)])) ...
        ./std([ratepre_all_mean{igr}(1:5000,1);ratepost_all_mean{igr}(end-5000:end,1)]);
    

    
    nbstim_all(igr) = sum(sum(nbstim(igr,:))); 
end

% temporary stats / will have to be changes to
% between mice and not within
for ipt=1:size(ratepre_all{1,1}(1,:),2)
    [hpre(ipt),ppre(ipt)] = ttest2(ratepre_all{1,1}(:,ipt),ratepre_all{2,1}(:,ipt));
end
for ipt=1:size(ratepost_all{1,1}(1,:),2)
    [hpost(ipt),ppost(ipt)] = ttest2(ratepost_all{1,1}(:,ipt),ratepost_all{2,1}(:,ipt));
end
% statistical correction
alpha = .01;
% FDR
    ppre_corr = mafdr(ppre');
    ind_pre = find(ppre_corr<alpha);
    
    ppost_corr = mafdr(ppost');
    ind_post = find(ppost_corr<alpha);

%#####################################################################
%#
%#                        F I G U R E S
%#
%#####################################################################
%% HR with stim
% set default plot colors
clrs_default = get(gca,'colororder');
color_extra = [65	16	16; 
                87	72	53;	
                37	62	63;	
                50	100	0;
                82	41	12;	
                100	50	31;	
                39	58	93;	
                100	97	86;	
                86	8	24;	
                0	100	100;
                0	0	55;
                0	55	55;	
                72	53	4;
                66	66	66;	
                0 39 0]/100;
clrs_default = [clrs_default; color_extra];
clrs_letter = {'b','r'};
% set limits
maxy = max([max(max(ratepre_all_mean{1}+ratepre_all_std{1}))  max(max(ratepost_all_mean{1}+ratepost_all_std{1})) ...
            max(max(ratepre_all_mean{2}+ratepre_all_std{2}))  max(max(ratepost_all_mean{2}+ratepost_all_std{2}))])*1.05;
miny = min([min(min(ratepre_all_mean{1}-ratepre_all_std{1})) min(min(ratepost_all_mean{1}-ratepost_all_std{1})) ...
            min(min(ratepre_all_mean{2}-ratepre_all_std{2})) min(min(ratepost_all_mean{2}-ratepost_all_std{2}))])*0.95;
% var for sig
presig(1:length(ppre),1) = nan;
postsig(1:length(ppost),1) = nan;
presig(ind_pre) = 1;
postsig(ind_post) = 1;
presig2 = presig(1:length(ratepre_all_mean{1}(5001:end-prebuff)),1);
postsig2 = postsig(1:length(ratepost_all_mean{1}(postbuff:end-5000)),1);

%--------------------------------------------------------------------------
%----------------------PLOT HEART RATE AROUND STIM-------------------------
%--------------------------------------------------------------------------
supertit = 'Heart Rate locked to stim';
figure2(1,'Color',[1 1 1], 'rend','painters','pos',[1 1 1200 600],'Name', supertit, 'NumberTitle','off')
            rectangle('Position',[ttime*1E4-prebuff,5,prebuff+postbuff,10],'FaceColor',[.9 .9 .9],'EdgeColor','none',...
            'LineWidth',.01)
            hold on

            rectangle('Position',[ttime*1E4,5,stimdur,10],'FaceColor',[.6 .6 .6],'EdgeColor','none',...
            'LineWidth',.01)
            hold on
            for igr=1:2
%                     p(igr)=plot([5001:ttime*1E4-prebuff],smooth(squeeze(squeeze(ratepre_all_mean{igr}(5001:end-prebuff))),500),'Color',clrs_default(igr,:)); % starts 500 ms after because median is culculated on trailing data (inverse for post)
                shadedErrorBar([5001:ttime*1E4-prebuff],squeeze(squeeze(ratepre_all_mean{igr}(5001:end-prebuff))), ...
                    squeeze(squeeze(ratepre_all_std{igr}(5001:end-prebuff))),clrs_letter{igr},1);
                hold on 
%                     p(igr)=plot([ttime*1E4+postbuff:(ttime*2+stimdelay)*1e4-5000], smooth(squeeze(squeeze(ratepost_all_mean{igr}(postbuff:end-5000))),500),'Color',clrs_default(igr,:));
                h{igr}=shadedErrorBar([ttime*1E4+postbuff:(ttime*2+stimdelay)*1e4-5000], squeeze(squeeze(ratepost_all_mean{igr}(postbuff:end-5000))),...
                    squeeze(squeeze(ratepost_all_std{igr}(postbuff:end-5000))),clrs_letter{igr},1);
                hold on
            end
            % set statistical sig
            plot([5001:ttime*1E4-prebuff],presig2*maxy-.5,'m')
            hold on
            plot([ttime*1E4+postbuff:(ttime*2+stimdelay)*1e4-5000],postsig2*maxy-.5,'m')
            
            ylim([miny maxy])
            xlim([5000 (ttime*2+stimdelay)*1e4-5000])
            set(gca, 'Xtick', 5001:5000:((ttime*2+stimdelay)*1e4)-5000,...
                'Xticklabel', num2cell([-1*(ttime-.5):.5:(stimdelay+ttime-.5)]))
            ax = gca;
            ax.Layer = 'top';
            xlabel('time (s)')
            ylabel('Hz')    
            legend([h{1}.mainLine h{2}.mainLine],{['MFB - ' num2str(nbstim(1)) ' stims - n=' num2str(nb_gr(1))], ...
                ['PAG - ' num2str(nbstim(2)) ' stims - n=' num2str(nb_gr(2))]},'Location','SouthEast')
            title('Heart Rate locked to stim')

    hold off
    % Save figure
    if sav
        print([dir_out 'MFBvsPAG_heartrate_stimlock'], '-dpng', '-r600');
    end

%--------------------------------------------------------------------------
%-------------Z-Scored PLOT HEART RATE AROUND STIM-------------------------
%--------------------------------------------------------------------------
supertit = 'Standardized Heart Rate locked to stim';
figure2(1,'Color',[1 1 1], 'rend','painters','pos',[1 1 1200 600],'Name', supertit, 'NumberTitle','off')
            for igr=1:2
                    p(igr)=plot([5001:ttime*1E4-prebuff],squeeze(squeeze(std_ratepre_mean{igr}(5001:end-prebuff))),'Color',clrs_letter{igr}); % starts 500 ms after because median is culculated on trailing data (inverse for post)
%                 ([5001:ttime*1E4-prebuff],squeeze(squeeze(std_ratepre_mean{igr}(5001:end-prebuff))), ...
%                     squeeze(squeeze(std_ratepre_std{igr}(5001:end-prebuff))),clrs_letter{igr},1);
                hold on 
                    p(igr)=plot([ttime*1E4+postbuff:(ttime*2+stimdelay)*1e4-5000], squeeze(squeeze(std_ratepost_mean{igr}(postbuff:end-5000))),'Color',clrs_letter{igr});
%                 h{igr}=shadedErrorBar([ttime*1E4+postbuff:(ttime*2+stimdelay)*1e4-5000], squeeze(squeeze(std_ratepost_mean{igr}(postbuff:end-5000))),...
%                     squeeze(squeeze(std_ratepost_std{igr}(postbuff:end-5000))),clrs_letter{igr},1);
                hold on
            end
            rectangle('Position',[ttime*1E4-prebuff,-5,prebuff+postbuff,10],'FaceColor',[.9 .9 .9],'EdgeColor','none',...
            'LineWidth',.01)
            hold on
            rectangle('Position',[ttime*1E4,-5,stimdur,10],'FaceColor',[.6 .6 .6],'EdgeColor','none',...
            'LineWidth',.01)
             ylim([-5 5])
            xlim([5000 (ttime*2+stimdelay)*1e4-5000])
            set(gca, 'Xtick', 5001:5000:((ttime*2+stimdelay)*1e4)-5000,...
                'Xticklabel', num2cell([-1*(ttime-.5):.5:(stimdelay+ttime-.5)]))
            ax = gca;
            ax.Layer = 'top';
            xlabel('time (s)')
            ylabel('Hz Z-Score')    
            legend([p(1) p(2)],{['MFB - ' num2str(nbstim(1)) ' stims - n=' num2str(nb_gr(1))], ...
                ['PAG - ' num2str(nbstim(2)) ' stims - n=' num2str(nb_gr(2))]},'Location','SouthEast')
            title('Standardized Heart Rate locked to stim')
            
    hold off
    % Save figure
    if sav
        print([dir_out 'MFBvsPAG_heartrate_stimlock_zscore'], '-dpng', '-r600');
    end
    
    
void = [];    
supertit = 'Heart rate difference pre/post stim (+/-2s) ';
figure2(1,'Color',[1 1 1], 'rend','painters','pos',[1 1 400 400],'Name', supertit, 'NumberTitle','off')
    
        [p,h, her] = PlotErrorBarN_SL([ratepre_trial_mean nan ratepost_trial_mean],...
            'barwidth', 0.85, 'newfig', 0);
         ylim([0 15]);
        set(gca,'Xtick',[1:5],'XtickLabel',{'        Pre-stim','','','       Post-stim',''});
        set(gca, 'FontSize', 12);
        h.FaceColor = 'flat';
        h.CData(1,:) = [0 0 1];
        h.CData(2,:) = [1 0 0];        
        h.CData(4,:) = [0 0 1];
        h.CData(5,:) = [1 0 0];
        
        set(h, 'LineWidth', 2);
        set(her, 'LineWidth', 2);
        ylabel('Hz');
        title('Average HR difference pre/post stim', 'FontSize', 16);
        % creating legend with hidden-fake data (hugly but effective)
        b2=bar([-2],[ 1],'FaceColor','flat');
        b1=bar([-3],[ 1],'FaceColor','flat');
        b1.CData(1,:) = repmat([0 0 1],1);
        b2.CData(1,:) = repmat([1 0 0],1);
        legend([b1 b2],{'MFB','PAG'})%,'Location','EastOutside')
        
    % Save figure
    if sav
        print([dir_out 'MFBvsPAG_average_hr_diff_2sec'], '-dpng', '-r300');
    end    
    
% Overall
supertit = 'Heart Rate Dynamics locked to stim';
figure('Color',[1 1 1], 'rend','painters','pos',[1 1 600 400],'Name', supertit, 'NumberTitle','off')

        rectangle('Position',[ttime*1E4-prebuff,0,prebuff+postbuff,20],'FaceColor',[.9 .9 .9],'EdgeColor','none',...
        'LineWidth',.01)
        hold on
        
        rectangle('Position',[ttime*1E4,0,stimdur,20],'FaceColor',[.6 .6 .6],'EdgeColor','none',...
        'LineWidth',.01)
        hold on

        plot([5001:ttime*1E4-prebuff],ratepre_all_mean(5001:end-prebuff))
        hold on
        plot([ttime*1E4+postbuff:(ttime*2+stimdelay)*1e4-5000], ratepost_all_mean(postbuff:end-5000))

        ylim([11.5 13])
                xlim([5000 (ttime*2+stimdelay)*1e4-5000])
                set(gca, 'Xtick', 5001:5000:((ttime*2+stimdelay)*1e4)-5000,...
                    'Xticklabel', num2cell([-1*(ttime-.5):.5:(stimdelay+ttime-.5)]))
        ax = gca;
        ax.Layer = 'top';
        t=annotation('textbox',[.8 .7 .2 .1],'String',['n=' num2str(nbstim_all) ' stim'],'FitBoxToText','on');
        sz = t.FontSize;
        t.FontSize = 10;
        t.EdgeColor =  'none';
        hold off
        xlabel('time (s)')
        ylabel('Hz')    
        title('Heart Rate Dynamics locked to stim')
    % Save figure
    if sav
        print([dir_out 'heartrate_stim_all'], '-dpng', '-r300');
    end

% Overall - ALL data points
supertit = 'Heart Rate Dynamics locked to stim - no buffer';
figure('Color',[1 1 1], 'rend','painters','pos',[1 1 600 400],'Name', supertit, 'NumberTitle','off')
        rectangle('Position',[ttime*1E4,0,stimdur,20],'FaceColor',[.6 .6 .6],'EdgeColor','none',...
        'LineWidth',.01)
        hold on

        plot([5001:ttime*1E4],ratepre_all_mean(5001:end))
        hold on
        plot([ttime*1E4+1:(ttime*2+stimdelay)*1e4-5000], ratepost_all_mean(1:end-5000))
        hold on
        lx=(ttime+.075*2)*1e4+1200;
        plot([lx lx], [10 13]); 
        hold on
        lx=(ttime+.075)*1e4+1200;
        plot([lx lx], [10 13]); 
        ylim([10 13])
                xlim([5000 (ttime*2+stimdelay)*1e4-5000])
                set(gca, 'Xtick', 5001:5000:((ttime*2+stimdelay)*1e4)-5000,...
                    'Xticklabel', num2cell([-1*(ttime-.5):.5:(stimdelay+ttime-.5)]))
        ax = gca;
        ax.Layer = 'top';
        t=annotation('textbox',[.8 .7 .2 .1],'String',['n=' num2str(nbstim_all) ' stim'],'FitBoxToText','on');
        sz = t.FontSize;
        t.FontSize = 10;
        t.EdgeColor =  'none';
        hold off
        xlabel('time (s)')
        ylabel('Hz')    
        title('Heart Rate Dynamics locked to stim')
    % Save figure
    if sav
        print([dir_out 'heartrate_stim_all_nobuffer'], '-dpng', '-r300');
    end
    
    
supertit = 'Heart rate difference pre/post stim (+/-2s) ';
figure('Color',[1 1 1], 'rend','painters','pos',[1 1 400 400],'Name', supertit, 'NumberTitle','off')
    
        [p,h, her] = PlotErrorBarN_SL([ratepre_trial_mean ratepost_trial_mean],...
            'colorpoints',1,'barcolors', [.3 .3 .3], 'barwidth', 0.6, 'newfig', 0);
         ylim([10 13.5]);
        set(gca,'Xtick',[1:2],'XtickLabel',{'Pre-stim','Post-stim'});
        set(gca, 'FontSize', 12);
        h.FaceColor = 'flat';
        h.CData(1,:) = [.3 .3 .3];
        h.CData(2,:) = [.6 .6 .6];
        
        set(h, 'LineWidth', 2);
        set(her, 'LineWidth', 2);
        ylabel('Hz');
        title('Average HR difference pre/post stim', 'FontSize', 16);
        
    % Save figure
    if sav
        print([dir_out 'average_hr_diff_2sec'], '-dpng', '-r300');
    end

%% HB dynamics

ymax=max([Data(hbpre{imouse,itrial}); Data(hbcond{imouse,itrial}); Data(hbpost{imouse,itrial})]);
ymin=min([Data(hbpre{imouse,itrial}); Data(hbcond{imouse,itrial}); Data(hbpost{imouse,itrial})]);
supertit = 'Heart Rate Dynamics per trial - Pre-Tests';
figure('Color',[1 1 1], 'rend','painters','pos',[1 1 2100 400],'Name', supertit, 'NumberTitle','off')
    for imouse=1:length(Dir.path)
        for itrial=1:ntrial
            subplot(length(Dir.path),ntrial,itrial+((imouse-1)*ntrial))
                plot((Range(hbpre{imouse,itrial})./1E4)-prestart(imouse,itrial),Data(hbpre{imouse,itrial}))
                ylim([ymin-ymin*.15 ymax+ymax*.15])
                xlim([0 preend(imouse,itrial)-prestart(imouse,itrial)])
                set(gca, 'Xtick', 0:20:preend(imouse,itrial)-prestart(imouse,itrial),...
                    'Xticklabel', num2cell([0:20:preend(imouse,itrial)-prestart(imouse,itrial)])) 
                if itrial==1
                    xlabel('time')
                    ylabel('Hz')    
                    title(['MOUSE #' num2str(Mice_to_analyze(imouse))])
                end
        end
    end
    % Save figure
    if sav
        print([dir_out 'heartrate_dyna_pre'], '-dpng', '-r300');
    end

supertit = 'Heart Rate Dynamics per trial - Cond';
figure('Color',[1 1 1], 'rend','painters','pos',[1 1 2100 400],'Name', supertit, 'NumberTitle','off')
    for imouse=1:length(Dir.path)
        for itrial=1:ntrial
            subplot(length(Dir.path),ntrial,itrial+((imouse-1)*ntrial))
                plot((Range(hbcond{imouse,itrial})./1E4)-condstart(imouse,itrial),Data(hbcond{imouse,itrial}))
                hold on
                ylim([ymin-ymin*.15 ymax+ymax*.15])
                %plotting stim markers
                %   fucking long line that could be summarized as this:
                %   plot(PosMat(PosMat:,4)==1,1)-time_of_start,PosMat(PosMat:,4)==1,1)*0+a
                %   bit more than the max on the y axis);
                plot(behav{imouse}.behavResources(idcond{1,1}(itrial)).PosMat(behav{imouse}.behavResources(idcond{1,1}(itrial)).PosMat(:,4)==1,1)-condstart(imouse,itrial)...
                    ,behav{imouse}.behavResources(idcond{1,1}(itrial)).PosMat(behav{imouse}.behavResources(idcond{1,1}(itrial)).PosMat(:,4)==1,1)*0+max(ylim)*.95,...
                    'g*')
                xlim([0 condend(imouse,itrial)-condstart(imouse,itrial)])
                set(gca, 'Xtick', 0:80:condend(imouse,itrial)-condstart(imouse,itrial),...
                    'Xticklabel', num2cell([0:80:condend(imouse,itrial)-condstart(imouse,itrial)])) 
                hold off
                if itrial==1
                    xlabel('time')
                    ylabel('Hz')    
                    title(['MOUSE #' num2str(Mice_to_analyze(imouse))])
                end
        end
    end
    % Save figure
    if sav
        print([dir_out 'heartrate_dyna_cond'], '-dpng', '-r300');
    end
    
supertit = 'Heart Rate Dynamics per trial - Post-Tests';
figure('Color',[1 1 1], 'rend','painters','pos',[1 1 2100 400],'Name', supertit, 'NumberTitle','off')
    for imouse=1:length(Dir.path)
        for itrial=1:ntrial
            subplot(length(Dir.path),ntrial,itrial+((imouse-1)*ntrial))
                plot((Range(hbpost{imouse,itrial})./1E4)-poststart(imouse,itrial),Data(hbpost{imouse,itrial}))
                ylim([ymin-ymin*.15 ymax+ymax*.15])
                xlim([0 postend(imouse,itrial)-poststart(imouse,itrial)])
                set(gca, 'Xtick', 0:20:postend(imouse,itrial)-poststart(imouse,itrial),...
                    'Xticklabel', num2cell([0:20:postend(imouse,itrial)-poststart(imouse,itrial)])) 
                if itrial==1
                    xlabel('time')
                    ylabel('Hz')    
                    title(['MOUSE #' num2str(Mice_to_analyze(imouse))])
                end
        end
    end
    % Save figure
    if sav
        print([dir_out 'heartrate_dyna_post'], '-dpng', '-r300');
    end
    
%% HB dist
supertit = 'Heart Rate Histograms per trial - Pre-Tests';
figure('Color',[1 1 1], 'rend','painters','pos',[1 1 900 400],'Name', supertit, 'NumberTitle','off')
    for imouse=1:length(Dir.path)
        for itrial=1:ntrial
            subplot(length(Dir.path),ntrial,itrial+((imouse-1)*ntrial))
                hist(Data(hbpre{imouse,itrial}),length(Data(hbpre{imouse,itrial})))
                ylim([0 225])
                xlim([8 14.5])
                if itrial==1
                    xlabel('time')
                    ylabel('Hz')    
                    title(['MOUSE #' num2str(Mice_to_analyze(imouse))])
                end
        end
    end
    % Save figure
    if sav
        print([dir_out 'heartrate_hist_pre'], '-dpng', '-r300');
    end
    
supertit = 'Heart Rate Histograms per trial - Cond';
figure('Color',[1 1 1], 'rend','painters','pos',[1 1 900 400],'Name', supertit, 'NumberTitle','off')
    for imouse=1:length(Dir.path)
        for itrial=1:ntrial
            subplot(length(Dir.path),ntrial,itrial+((imouse-1)*ntrial))
                hist(Data(hbcond{imouse,itrial}),length(Data(hbcond{imouse,itrial})))
                ylim([0 225])
                xlim([8 14.5])
                if itrial==1
                    xlabel('Hz')
                    ylabel('Number')    
                    title(['MOUSE #' num2str(Mice_to_analyze(imouse))])
                end
        end
    end
    % Save figure
    if sav
        print([dir_out 'heartrate_hist_cond'], '-dpng', '-r300');
    end
    
supertit = 'Heart Rate Histograms per trial - Post-Tests';
figure('Color',[1 1 1], 'rend','painters','pos',[1 1 900 400],'Name', supertit, 'NumberTitle','off')
    for imouse=1:length(Dir.path)
        for itrial=1:ntrial
            subplot(length(Dir.path),ntrial,itrial+((imouse-1)*ntrial))
                hist(Data(hbpost{imouse,itrial}),length(Data(hbpost{imouse,itrial})))
                ylim([0 225])
                xlim([8 14.5])
                if itrial==1
                    xlabel('Hz')
                    ylabel('Number')    
                    title(['MOUSE #' num2str(Mice_to_analyze(imouse))])
                end
        end
    end
    % Save figure
    if sav
        print([dir_out 'heartrate_hist_post'], '-dpng', '-r300');
    end


%% averaged HB
maxy=14;
supertit = 'Heart Rate';
figure('Color',[1 1 1], 'rend','painters','pos',[1 1 900 400],'Name', supertit, 'NumberTitle','off')
    subplot(2,3,1:3)
        [p,h, her] = PlotErrorBarN_SL([hbpre_meanall hbcond_meanall hbpost_meanall],...
            'colorpoints',1,'barcolors', [.3 .3 .3], 'barwidth', 0.6, 'newfig', 0);
        ylim([8 maxy]);
        set(gca,'Xtick',[1:3],'XtickLabel',{'Pre', 'Cond', 'Post'});
        set(gca, 'FontSize', 12);
        h.FaceColor = 'flat';
        h.CData(1,:) = [.3 .3 .3];
        h.CData(2,:) = [.6 .6 .6];
        h.CData(3,:) = [1 1 1];
        set(h, 'LineWidth', 2);
        set(her, 'LineWidth', 2);
        ylabel('Beats/sec');
        title('Heart Rate across sessions', 'FontSize', 16);

    subplot(2,3,4)
        [p,h, her] = PlotErrorBarN_SL(hbpre_mean,...
            'colorpoints',1,'barcolors', [.3 .3 .3], 'barwidth', 0.6, 'newfig', 0);
        ylim([8 maxy]);
        set(gca,'Xtick',[1:4]);
        set(gca, 'FontSize', 12);
        set(h, 'LineWidth', 2);
        set(her, 'LineWidth', 2);
        ylabel('Beats/sec');
        xlabel('Trials');
        title('Pre', 'FontSize', 16);   
            
    subplot(2,3,5)
        [p,h, her] = PlotErrorBarN_SL(hbcond_mean,...
            'colorpoints',1,'barcolors', [.6 .6 .6], 'barwidth', 0.6, 'newfig', 0);
        ylim([8 maxy]);
        set(gca,'Xtick',[1:4]);
        set(gca, 'FontSize', 12);
        set(h, 'LineWidth', 2);
        set(her, 'LineWidth', 2);
        ylabel('Beats/sec');
        xlabel('Trials');
        title('Cond', 'FontSize', 16); 
        
    subplot(2,3,6)
        [p,h, her] = PlotErrorBarN_SL(hbpost_mean,...
            'colorpoints',1,'barcolors', [1 1 1], 'barwidth', 0.6, 'newfig', 0);
        ylim([8 maxy]);
        set(gca,'Xtick',[1:4]);
        set(gca, 'FontSize', 12);
        set(h, 'LineWidth', 2);
        set(her, 'LineWidth', 2);
        ylabel('Beats/sec');
        xlabel('Trials');
        title('Post', 'FontSize', 16);         

    %% Save figure
    if sav
        print([dir_out 'heartrate_sessions'], '-dpng', '-r300');
    end
