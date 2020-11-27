function sam_hb_exp(varargin)

%==========================================================================
% Details: get hb details during pre, post and cond trials
%
% INPUTS:
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
%
%   Written by Samuel Laventure - 29-10-2019
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
        case 'micenum'
            micenum = varargin{i+1};
            if ~isstring(micenum)
                error('Incorrect value for property ''micenum''.');
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
if ~exist('Mice_to_analyze','var')
    Mice_to_analyze = [936 941]; 
    disp(['...Processing default mice #' num2str(Mice_to_analyze)]);
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
try 
    Dir = PathForExperimentsERC_SL_home(expname);
catch
    Dir = PathForExperimentsERC_SL(expname);
end
Dir = RestrictPathForExperiment(Dir,'nMice', Mice_to_analyze);

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

for imouse=1:length(Dir.path)
    % Get behavResources data
    behav{imouse} = load([Dir.path{imouse}{1} '/behavResources.mat'], 'behavResources','SessionEpoch');
    stimes = struct2cell(behav{imouse}.SessionEpoch);  %transform the object structure into cell to allow for navigation using id
    
    % get stim information
    load([Dir.path{imouse}{1} 'LFPData/DigInfo3.mat']);
    StimSent = thresholdIntervals(DigTSD,0.99,'Direction','Above');
    %tstim{imouse} = Start(StimSent);
    
    % Get session id
    idpre = find_sessionid(behav{imouse}, 'TestPre');
    idpost = find_sessionid(behav{imouse}, 'TestPost');
    idcond = find_sessionid(behav{imouse}, 'Cond');
        
    % load working variables
    load([Dir.path{imouse}{1} '/HeartBeatInfo.mat'], 'EKG');
    
    % get hb per trials
    for itrial=1:ntrial
        if ~restricted
            hbpre{imouse,itrial} = Restrict(Restrict(EKG.HBRate,stimes{idpre{1,1}(itrial),1}),EKG.GoodEpoch) ;
            hbpost{imouse,itrial} = Restrict(Restrict(EKG.HBRate,stimes{idpost{1,1}(itrial),1}),EKG.GoodEpoch);
            hbcond{imouse,itrial} = Restrict(EKG.HBRate,stimes{idcond{1,1}(itrial),1});
        else
            hbpre{imouse,itrial} = RestrictThreshold(Restrict(EKG.HBRate,stimes{idpre{1,1}(itrial),1}),thresh);
            hbpost{imouse,itrial} = RestrictThreshold(Restrict(EKG.HBRate,stimes{idpost{1,1}(itrial),1}),thresh);
            hbcond{imouse,itrial} = RestrictThreshold(Restrict(EKG.HBRate,stimes{idcond{1,1}(itrial),1}),thresh);
        end
        % calculate mean and sd
        hbpre_mean(imouse,itrial) = mean(Data(hbpre{imouse,itrial}));
        hbpost_mean(imouse,itrial) = mean(Data(hbpost{imouse,itrial}));
        hbcond_mean(imouse,itrial) = mean(Data(hbcond{imouse,itrial}));
        hbpre_std(imouse,itrial) = nanstd(Data(hbpre{imouse,itrial}));
        hbpost_std(imouse,itrial) = nanstd(Data(hbpost{imouse,itrial}));
        hbcond_std(imouse,itrial) = nanstd(Data(hbcond{imouse,itrial}));
        %get start time
        prestart(imouse,itrial) = behav{imouse}.behavResources(idpre{1,1}(itrial)).PosMat(1,1);
        condstart(imouse,itrial) = behav{imouse}.behavResources(idcond{1,1}(itrial)).PosMat(1,1);
        poststart(imouse,itrial) = behav{imouse}.behavResources(idpost{1,1}(itrial)).PosMat(1,1);
        preend(imouse,itrial) = behav{imouse}.behavResources(idpre{1,1}(itrial)).PosMat(end,1);
        condend(imouse,itrial) = behav{imouse}.behavResources(idcond{1,1}(itrial)).PosMat(end,1);
        postend(imouse,itrial) = behav{imouse}.behavResources(idpost{1,1}(itrial)).PosMat(end,1);
        
        
        % stim react
        HBTimes = Data(EKG.HBTimes);
        tstim{imouse,itrial} = Start(and(StimSent, stimes{idcond{1,1}(itrial),1}));
        % var init
        rateprelfp = nan(length(tstim{imouse,itrial}), ttime*1E4);
        ratepostlfp = nan(length(tstim{imouse,itrial}), (stimdelay+ttime)*1E4);
        for istim=1:length(tstim{imouse,itrial})
            % HB pre stim
            ratepre_id = find((HBTimes<tstim{imouse,itrial}(istim)) ...
                & (HBTimes>tstim{imouse,itrial}(istim)-ttime*1E4));
            ratepre{istim} = HBTimes(ratepre_id);
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
            
            % HB post stim
            ratepost_id = find((HBTimes>tstim{imouse,itrial}(istim)) ...
                & (HBTimes<tstim{imouse,itrial}(istim)+(stimdelay+ttime)*1E4));
            ratepost{istim} = HBTimes(ratepost_id);
            hr_post = 1./movmedian(diff(ratepost{istim}/1e4),[0 3]);
            delta_post = diff(ratepost{istim}/1e4);
            
            % setting up rate on LFP points to allow for average between
            % stim
            fst = (stimdelay+ttime)*1E4;
            tstart = tstim{imouse,itrial}(istim);
            for ihb=length(ratepost_id):-1:1
                if ihb>1
                    if ratepost{istim}(ihb)-tstim{imouse,itrial}(istim) > 1500
                        ratepostlfp(istim,floor(ratepost{istim}(ihb)-tstart):fst) = hr_post(ihb-1);
                        deltapostlfp(istim,floor(ratepost{istim}(ihb)-tstart):fst) = delta_post(ihb-1);
                        fst = floor(ratepost{istim}(ihb)-tstart)-1;
                    end
                end
            end
        end

        % calculate mean per trial
        nbstim(imouse,itrial) = length(tstim{imouse,itrial});
        if nbstim(imouse,itrial)
            ratepre_mean(imouse,itrial,1:ttime*1E4) = squeeze(nanmean(rateprelfp,1));
            ratepost_mean(imouse,itrial,1:(ttime+stimdelay)*1E4) = squeeze(nanmean(ratepostlfp,1));
            if itrial==1
                ratepre1_mean(imouse,1:ttime*1E4) = rateprelfp(1,:);
                ratepost1_mean(imouse,1:(ttime+stimdelay)*1E4) = ratepostlfp(1,:);
            end
        else
            ratepre_mean(imouse,itrial,1:ttime*1E4) = nan;
            ratepost_mean(imouse,itrial,1:(ttime+stimdelay)*1E4) = nan;
            if itrial==1
                ratepre1_mean(imouse,1:ttime*1E4) = rateprelfp(1,:);
                ratepost1_mean(imouse,1:(ttime+stimdelay)*1E4) = ratepostlfp(1,:);
            end
        end
            
    end
end

% Prepare data for figures
% Overall means
if length(Dir.path) > 1
    ratepre_all_mean = squeeze(nanmean(nanmean(ratepre_mean,2)));
    ratepost_all_mean = squeeze(nanmean(nanmean(ratepost_mean,2)));
    ratepre1_all_mean = squeeze(nanmean(ratepre1_mean));
    ratepost1_all_mean = squeeze(nanmean(ratepost1_mean));
    ratepre_all_std = squeeze(nanstd(nanstd(ratepre_mean,[],2)));
    ratepost_all_std = squeeze(nanstd(nanstd(ratepost_mean,[],2)));
    ratepre1_all_std = squeeze(nanstd(ratepre1_mean,[]));
    ratepost1_all_std = squeeze(nanstd(ratepost1_mean,[]));
else
    ratepre_all_mean = squeeze(nanmean(ratepre_mean,2));
    ratepost_all_mean = squeeze(nanmean(ratepost_mean,2));
    ratepre1_all_mean = ratepre1_mean;
    ratepost1_all_mean = ratepost1_mean;
    ratepre_all_std = squeeze(nanstd(ratepre_mean,[],2));
    ratepost_all_std = squeeze(nanstd(ratepost_mean,[],2));
    ratepre1_all_std = ratepre1_mean;
    ratepost1_all_std = ratepost1_mean;
end
hbpre_meanall = squeeze(mean(hbpre_mean,2));
hbpost_meanall = squeeze(mean(hbpost_mean,2));
hbcond_meanall = squeeze(mean(hbcond_mean,2));
ratepre_trial_mean = nanmean(nanmean(ratepre_mean(:,:,ttime*1E4-19999:ttime*1E4),3),2);
ratepost_trial_mean = nanmean(nanmean(ratepost_mean(:,:,stimdur+1:stimdur+20000),3),2);

nbstim_all = sum(sum(nbstim)); 

% smooth data
ratepre1_all_mean  = smooth(ratepre1_all_mean,1000);
ratepost1_all_mean  = smooth(ratepost1_all_mean,1000);

% calculate difference first stim vs all
diffpre = ratepre1_all_mean(5001:end-prebuff)'-squeeze(squeeze(ratepre_all_mean(5001:end-prebuff)));
diffpost = ratepost1_all_mean(postbuff:end-5000)'-squeeze(squeeze(ratepost_all_mean(postbuff:end-5000)));

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
% delta beat hotmaps
figure, imagesc(sort(deltaprelfp,1,'descend'))
    title('Pre-stim')
    ylabel('stims')  
    xlabel('time (s)')
    
figure, imagesc(sort(deltapostlfp,1,'ascend'))
    title('Post-stim')
    ylabel('stims')  
    xlabel('time (s)')

% set limits

maxy = max([max(max(max(ratepre_mean)))  max(max(max(ratepost_mean)))])*1.15;
miny = min([min(min(min(ratepre_mean))) min(min(min(ratepost_mean)))])*0.85;
    
% per trial per mouse
supertit = ['Mouse #' num2str(Mice_to_analyze(imouse)) ': Heart Rate Dynamics locked to stim'];
figure('Color',[1 1 1], 'rend','painters','pos',[1 1 2100 400],'Name', supertit, 'NumberTitle','off')
    for imouse=1:length(Dir.path)
        for itrial=1:ntrial
            subplot(length(Dir.path),ntrial,itrial+((imouse-1)*ntrial))
                rectangle('Position',[ttime*1E4-prebuff,0,prebuff+postbuff,20],'FaceColor',[.9 .9 .9],'EdgeColor','none',...
                'LineWidth',.01)
                hold on

                rectangle('Position',[ttime*1E4,0,stimdur,20],'FaceColor',[.6 .6 .6],'EdgeColor','none',...
                'LineWidth',.01)

                hold on
                plot([5001:ttime*1E4-prebuff],squeeze(squeeze(ratepre_mean(imouse,itrial,5001:end-prebuff)))) % starts 500 ms after because median is culculated on trailing data (inverse for post)
                hold on
                plot([ttime*1E4+postbuff:(ttime*2+stimdelay)*1e4-5000], squeeze(squeeze(ratepost_mean(imouse,itrial,postbuff:end-5000))))
                                
                ylim([miny maxy])
                xlim([5000 (ttime*2+stimdelay)*1e4-5000])
                set(gca, 'Xtick', 5001:5000:((ttime*2+stimdelay)*1e4)-5000,...
                    'Xticklabel', num2cell([-1*(ttime-.5):.5:(stimdelay+ttime-.5)]))
                ax = gca;
                ax.Layer = 'top';
                title(['Trial #' num2str(itrial)])

                hold off
                if itrial==1
                    xlabel('time (s)')
                    ylabel('Hz')    
                end
        end
    end
    % Save figure
    if sav
        print([dir_out 'heartrate_stim'], '-dpng', '-r300');
    end

    
% FIRST STIM vs ALL    
% Overall
supertit = 'Heart rate during conditioning';
figure('pos',[1 1 900 600],'Name', supertit, 'NumberTitle','off')
%     subplot(2,3,1:3)
        rectangle('Position',[ttime*1E4-prebuff,0,prebuff+postbuff,20],'FaceColor',[.9 .9 .9],'EdgeColor','none',...
        'LineWidth',.01)
        hold on
        
        rectangle('Position',[ttime*1E4,0,stimdur,20],'FaceColor',[.6 .6 .6],'EdgeColor','none',...
        'LineWidth',.01)
        hold on
%         plot([5001:ttime*1E4-prebuff],ratepre1_all_mean(5001:end-prebuff),'color',clrs_default(2,:))
%         hold on
%         h1=plot([ttime*1E4+postbuff:(ttime*2+stimdelay)*1e4-5000], ratepost1_all_mean(postbuff:end-5000),'color',clrs_default(2,:))
%         hold on
        h1=shadedErrorBar([5001:ttime*1E4-prebuff],squeeze(squeeze(ratepre_all_mean(5001:end-prebuff))), ...
            squeeze(squeeze(ratepre_all_std(5001:end-prebuff))),'k',1);
        hold on 
        h2=shadedErrorBar([ttime*1E4+postbuff:(ttime*2+stimdelay)*1e4-5000], squeeze(squeeze(ratepost_all_mean(postbuff:end-5000))),...
            squeeze(squeeze(ratepost_all_std(postbuff:end-5000))),'k',1);
        hold on
        h1.mainLine.LineWidth = 2;
        h2.mainLine.LineWidth = 2;
        ylim([9 14])
        xlim([5000 (ttime*2+stimdelay)*1e4-5000])
        set(gca, 'Xtick', 5001:5000:((ttime*2+stimdelay)*1e4)-5000,...
                    'Xticklabel', num2cell([-1*(ttime-.5):.5:(stimdelay+ttime-.5)]))
        ax = gca;
        ax.Layer = 'top';
%         t=annotation('textbox',[.75 .8 .1 .1],'String',['n=' num2str(nbstim_all) ' stims'],'FitBoxToText','on');
%         sz = t.FontSize;
%         t.FontSize = 10;
        %t.EdgeColor =  'none';
        hold off
        xlabel('time (s)')
        ylabel('Hz')    
        title('Heart Rate Dynamics locked to stim')
        
%     subplot(2,3,4:6)
%         rectangle('Position',[ttime*1E4-prebuff,-3,prebuff+postbuff,20],'FaceColor',[.9 .9 .9],'EdgeColor','none',...
%         'LineWidth',.01)
%         hold on
%         rectangle('Position',[ttime*1E4,-3,stimdur,20],'FaceColor',[.6 .6 .6],'EdgeColor','none',...
%         'LineWidth',.01)
%         hold on
%         plot([5001:ttime*1E4-prebuff],diffpre,'color',clrs_default(3,:))
%         hold on
%         plot([ttime*1E4+postbuff:(ttime*2+stimdelay)*1e4-5000],diffpost,'color',clrs_default(3,:))
%         hold on
%         ylim([-1 3])
%         xlim([5000 (ttime*2+stimdelay)*1e4-5000])
%         set(gca, 'Xtick', 5001:5000:((ttime*2+stimdelay)*1e4)-5000,...
%                     'Xticklabel', num2cell([-1*(ttime-.5):.5:(stimdelay+ttime-.5)]))
%         ax = gca;
%         ax.Layer = 'top';
%         hold off
%         xlabel('time (s)')
%         ylabel('Hz')    
%         title('Difference in heart rate (Hz) between 1st stim and all stims')
        
    % Save figure
    if sav
        print([dir_out 'HR_AllStims'], '-dpng', '-r600');
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

    

