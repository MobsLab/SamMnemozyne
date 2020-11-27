function sam_hb_compare_voltage_dual(varargin)

%==========================================================================
% Details: compare hb during DUAL calibrations . Needs to input manually in the
% scripts the location of your concatenated files
%
% INPUTS:
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
%   Written by Samuel Laventure - 08-05-2020 (based on sam_hb_exp.m)
%      
%==========================================================================
%% INPUT Directories and info
nmice = [941 016];

% Get directories
Dir = PathForExperimentsERC_SL('CalibDual');
Dir = RestrictPathForExperiment(Dir,'nMice', nmice);

% ----------------------------------------------- %
%                MANUAL INPUT
%   |-------------------------------------------- %
%   |
%   |
%   |-------------------------------------------------------------------------------------------------------------------
% Get directories
% sessN = {'dual1';'dual2';'dual3';'dual4';'dual5';'dual6';'dual7';'dual8';'dual9';'dual10'};
% sessN = {'mfb14';'dual2';'dual4';'dual6';'dual8'}; % dual at 0V pag was not processed well. Using last MFB trial instead.
 
%941
sessN{1} = {'dual1';'dual2';'dual8'};    
%016
sessN{2} = {'mfb11','dual6','dual12'};%{'mfb11','dual6','dual12'};
% %936
% sessN{3} = {'dual1','dual3','dual5'};

ntrial = 3; %assuming that all pre, post and cond have the same number of trials 

% Voltage
% volt = {'0V','2V','3V','4V','5V','6V','7V','7.5V','8V','8.5V'};
% volt = {'0V','2V','4V','6V','7.5V'};
selfstim = {'High','Medium','Low'};
%-----------------------------------------------------------------------------------------------------------------------

% set nbr of mice and trials
nbmice = length(Dir.path);
nbtrials = length(selfstim);

%% Parameters
% date for dir_out folders
t = char(datetime('now','Format','y-MM-d'));

% Directory to save and name of the figure to save
dir_out = [dropbox '/DataSL/Calib/HeartBeat/' t '/'];
if ~exist(dir_out,'dir')
    mkdir(dir_out);
end
sav = 1;
% ntrial_per_mouse = 3;

% threshold for minimum heartbeat (get rid of outliers)
restricted = 0;  % is restrict or not
thresh = 8; % hb/s min
ttime = 3.5;  %time in sec before and after stim to calculate rate
stimdelay=1; %time in sec after stim onset
prebuff=500; %before stim in s1e4
postbuff=1501; %after stim
stimdur=1000;

%%  Figures parameters
% smoothing interval
smoo =0; % does we smooth or not
sm = 500;
stp = 1;

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
for imouse=1:nbmice
    % Get behavResources data
    behav{imouse} = load([Dir.path{imouse}{1} '/behavResources.mat'], 'behavResources','SessionEpoch','StimEpoch');
    for itrial=1:ntrial
%         [idx stimes{imouse,itrial}] = RestrictSession(Dir,sessN{imouse}{itrial});
        stimes{imouse,itrial} = extractfield(behav{imouse}.SessionEpoch,sessN{imouse}{itrial});
    end
    
    % load EKG
    ekg{imouse} = load([Dir.path{imouse}{1} '/HeartBeatInfo.mat'], 'EKG');
end

for imouse=1:nbmice
    for itrial=1:ntrial
        if ~restricted
            hb{imouse,itrial} = Restrict(Restrict(ekg{imouse}.EKG.HBRate,stimes{imouse,itrial}{1}),ekg{imouse}.EKG.GoodEpoch);
        else
            hb{imouse,itrial} = RestrictThreshold(Restrict(ekg{imouse}.EKG.HBRate,stimes{imouse}{1}),thresh);
        end
        % calculate mean and sd
        hb_mean(imouse,itrial) = nanmean(Data(hb{imouse,itrial}));
        hb_std(imouse,itrial) = nanstd(Data(hb{imouse,itrial}));
        
        % stim react
        HBTimes{imouse} = Data(ekg{imouse}.EKG.HBTimes);
        tstim = Start(and(behav{imouse}.StimEpoch, stimes{imouse,itrial}{1}));
        tstim_all(imouse,itrial) = length(tstim);
        % verification that the stim are enough far appart
        iddel = find(diff(tstim)<45000); % 45000
        iddel = sort(unique([iddel; iddel+1]));
        tstim(iddel)=[];
        
        if length(tstim)
            disp(['mouse #' num2str(imouse) ', trial #' num2str(itrial) ': ' num2str(length(tstim)) ' stims selected'])
            % var init
            rateprelfp = nan(size(tstim,1),ttime*1E4);
            ratepostlfp = nan(size(tstim,1),(stimdelay+ttime)*1E4);
            for istim=1:length(tstim)
                % ------ HB pre stim ------ 
                ratepre_id = find((HBTimes{imouse}<tstim(istim)) ...
                    & (HBTimes{imouse}>tstim(istim)-ttime*1E4));
                ratepre{istim} = HBTimes{imouse}(ratepre_id);
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
                ratepost_id = find((HBTimes{imouse}>tstim(istim)) ...
                    & (HBTimes{imouse}<tstim(istim)+(stimdelay+ttime)*1E4));
                ratepost{istim} = HBTimes{imouse}(ratepost_id);
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
            end
            clear ratepre_id ratepre hr_pre delta_pre ratepost_id ratepost hr_post delta_post 
  
            % calculate mean per trial
            nbstim(imouse,itrial) = length(tstim);
            if nbstim(imouse,itrial)
                ratepre_mean(imouse,itrial,1:ttime*1E4) = squeeze(squeeze(nanmean(rateprelfp,1)));
                ratepre_std(imouse,itrial,1:ttime*1E4) = squeeze(squeeze(nanstd(rateprelfp,1)));
                ratepost_mean(imouse,itrial,1:(ttime+stimdelay)*1E4) = squeeze(squeeze(nanmean(ratepostlfp,1)));
                ratepost_std(imouse,itrial,1:(ttime+stimdelay)*1E4) = squeeze(squeeze(nanstd(ratepostlfp,1)));
            else
                ratepre_mean(imouse,itrial,1:ttime*1E4) = nan;
                ratepost_mean(imouse,itrial,1:(ttime+stimdelay)*1E4) = nan;
            end
            ratepre_all{imouse,itrial} = rateprelfp(:,1:ttime*1E4);
            ratepost_all{imouse,itrial} = ratepostlfp(:,1:(ttime+stimdelay)*1E4);
            
%             % smooth data
%             if smoo
%                 ratepre_mean(imouse,itrial,:) = smooth(ratepre_mean(imouse,itrial,:),sm);
%                 ratepre_std(imouse,itrial,:) = smooth(ratepre_std(imouse,itrial,:),sm);    
%                 ratepost_mean(imouse,itrial,:) = smooth(ratepost_mean(imouse,itrial,:),sm);
%                 ratepost_std(imouse,itrial,:) = smooth(ratepost_std(imouse,itrial,:),sm);
%             end
            clear rateprelfp ratepostlfp tstim
        else
            warning(['Mouse ' num2str(nmice(imouse)) ' has no valid stim during ' selfstim{imouse,itrial} ' trial']);
            nbstim(imouse,itrial) = 0;
        end
              
    end    
 

%     hb_meanall{imouse} = squeeze(mean(hb_mean(imouse,:),2));
%     ratepre_trial_mean{imouse} = nanmean(nanmean(ratepre_mean(imouse,:,ttime*1E4-19999:ttime*1E4),3),2);
%     ratepost_trial_mean{imouse} = nanmean(nanmean(ratepost_mean(imouse,:,stimdur+1:stimdur+20000),3),2);
%     

%     
%     % standardize data
%     std_ratepre_mean{imouse} = (ratepre_all_mean{imouse}-mean([ratepre_all_mean{imouse}(1:5000,1);ratepost_all_mean{imouse}(end-5000:end,1)])) ...
%         ./std([ratepre_all_mean{imouse}(1:5000,1);ratepost_all_mean{imouse}(end-5000:end,1)]);
%     std_ratepost_mean{imouse} = (ratepost_all_mean{imouse}-mean([ratepre_all_mean{imouse}(1:5000,1);ratepost_all_mean{imouse}(end-5000:end,1)])) ...
%         ./std([ratepre_all_mean{imouse}(1:5000,1);ratepost_all_mean{imouse}(end-5000:end,1)]);
%     
%  
%     
%     nbstim_all(imouse) = sum(sum(nbstim(imouse,:))); 
end

% Prepare data for figures
% Overall means
for itrial=1:ntrial
    if nbmice > 1
        ratepre_all_mean{itrial} = squeeze(nanmean(ratepre_mean(:,itrial,:),1));
        ratepre_all_std{itrial} = squeeze(nanstd(ratepre_mean(:,itrial,:)));
        ratepost_all_mean{itrial} = squeeze(nanmean(ratepost_mean(:,itrial,:),1));
        ratepost_all_std{itrial} = squeeze(nanstd(ratepost_mean(:,itrial,:)));
    else
        ratepre_all_mean{itrial} = squeeze(ratepre_mean(:,itrial,:));
        ratepre_all_std{itrial} = squeeze(ratepre_std(:,itrial,:));
        ratepost_all_mean{itrial} = squeeze(ratepost_mean(:,itrial,:));
        ratepost_all_std{itrial} = squeeze(ratepost_std(:,itrial,:));
    end
    % smooth data
    if smoo
        ratepre_all_mean{itrial} = smooth(ratepre_all_mean{itrial},sm);
        ratepre_all_std{itrial} = smooth(ratepre_all_std{itrial},sm);    
        ratepost_all_mean{itrial} = smooth(ratepost_all_mean{itrial},sm);
        ratepost_all_std{itrial} = smooth(ratepost_all_std{itrial},sm);
    end
end

save([dir_out 'calibdual.mat'],'ratepre_all_mean','ratepre_all_std','ratepost_all_mean','ratepost_all_std',...
    'selfstim','nbtrials','nbstim');

% % temporary stats / will have to be changes to
% % between mice and not within
% for ipt=1:size(ratepre_all{1,1}(1,:),2)
%     [hpre(ipt),ppre(ipt)] = ttest2(ratepre_all{1,1}(:,ipt),ratepre_all{2,1}(:,ipt));
% end
% for ipt=1:size(ratepost_all{1,1}(1,:),2)
%     [hpost(ipt),ppost(ipt)] = ttest2(ratepost_all{1,1}(:,ipt),ratepost_all{2,1}(:,ipt));
% end
% % statistical correction
% alpha = .01;
% % FDR
%     ppre_corr = mafdr(ppre');
%     ind_pre = find(ppre_corr<alpha);
%     
%     ppost_corr = mafdr(ppost');
%     ind_post = find(ppost_corr<alpha);

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
clrs_letter = {'r','k','b','y','g','c','m','b','r','g','y','c','m','k'};


%         
% % var for sig
% presig(1:length(ppre),1) = nan;
% postsig(1:length(ppost),1) = nan;
% presig(ind_pre) = 1;
% postsig(ind_post) = 1;
% presig2 = presig(1:length(ratepre_mean{1}(5001:end-prebuff)),1);
% postsig2 = postsig(1:length(ratepost_mean{1}(postbuff:end-5000)),1);



%     % set limits
%     maxy = max([max(max(ratepre_mean(imouse,:,:)+ratepre_std(imouse,:,:)))  max(max(ratepost_mean(imouse,:,:)+ratepost_std(imouse,:,:)))])*1.01;
%     miny = min([min(min(ratepre_mean(imouse,:,:)-ratepre_std(imouse,:,:))) min(min(ratepost_mean(imouse,:,:)-ratepost_std(imouse,:,:)))])*0.99;
    
    % set legend text
    idel=1;
    for i=1:stp:nbtrials
        if nbstim(i)>0
            legtxt{idel} = [selfstim{i}];
            idel=idel+1;
        end
    end
    
    %--------------------------------------------------------------------------
    %----------------------PLOT HEART RATE AROUND STIM-------------------------
    %--------------------------------------------------------------------------
    supertit = 'Heart Rate locked to stim during dual calibration';
    figure2(1,'Color',[1 1 1], 'rend','painters','pos',[1 1 900 600],'Name', supertit, 'NumberTitle','off')
        rectangle('Position',[ttime*1E4-prebuff,5,prebuff+postbuff,10],'FaceColor',[.9 .9 .9],'EdgeColor','none',...
        'LineWidth',.01)
        hold on

        rectangle('Position',[ttime*1E4,5,stimdur,10],'FaceColor',[.6 .6 .6],'EdgeColor','none',...
        'LineWidth',.01)
        hold on
        it=3;  % inversement des couleurs
        for itrial=1:stp:ntrial
            if nbstim(itrial)>0
%                 plot([5001:ttime*1E4-prebuff],squeeze(squeeze(ratepre_all_mean{1,itrial}(5001:end-prebuff))),...
%                      'Color',clrs_default(it,:),'LineWidth',2); % starts 500 ms after because median is culculated on trailing data (inverse for post)
%                 hold on
%                 p(it)=plot([ttime*1E4+postbuff:(ttime*2+stimdelay)*1e4-5000], squeeze(squeeze(ratepost_all_mean{1,itrial}(postbuff:end-5000))),... 
%                     'Color',clrs_default(it,:),'LineWidth',2);
                hold on
                
                f=shadedErrorBar([5001:ttime*1E4-prebuff],squeeze(squeeze(ratepre_all_mean{1,itrial}(5001:end-prebuff))), ...
                    squeeze(squeeze(ratepre_all_std{1,itrial}(5001:end-prebuff))),clrs_letter{it},1);
                hold on 
                h(itrial)=shadedErrorBar([ttime*1E4+postbuff:(ttime*2+stimdelay)*1e4-5000], squeeze(squeeze(ratepost_all_mean{1,itrial}(postbuff:end-5000))),...
                    squeeze(squeeze(ratepost_all_std{1,itrial}(postbuff:end-5000))),clrs_letter{it},1);

                 f.mainLine.LineWidth = 2;
                 h(itrial).mainLine.LineWidth = 2;

                it=it-1; % inverse
            end
        end

        ylim([9 14])
        xlim([5000 (ttime*2+stimdelay)*1e4-5000])
        set(gca, 'Xtick', 5001:5000:((ttime*2+stimdelay)*1e4)-5000,...
            'Xticklabel', num2cell([-1*(ttime-.5):.5:(stimdelay+ttime-.5)]))
        ax = gca;
        ax.Layer = 'top';
        xlabel('time (s)')
        ylabel('Hz')    
        legend([h(1).mainLine h(2).mainLine h(3).mainLine],legtxt,'Location','NorthEast')
        title('Heart rate locked to stim during dual calibration')

        hold off
        % Save figure
        if sav
            if smoo
                print([dir_out 'DualCalib_HR_stimlock_LowMedHI_smooth'], '-dpng', '-r600');
            else
                print([dir_out 'DualCalib_HR_stimlock_LowMedHI'], '-dpng', '-r600');
            end
        end



    %--------------------------------------------------------------------------
    %----------------------PER MICE PLOT HEART RATE AROUND STIM-------------------------
    %--------------------------------------------------------------------------
 
for imouse=1:nbmice
    % set limits
    maxy = max([max(max(ratepre_mean(imouse,:,:)+ratepre_std(imouse,:,:)))  max(max(ratepost_mean(imouse,:,:)+ratepost_std(imouse,:,:)))])*1.01;
    miny = min([min(min(ratepre_mean(imouse,:,:)-ratepre_std(imouse,:,:))) min(min(ratepost_mean(imouse,:,:)-ratepost_std(imouse,:,:)))])*0.99;
    % set legend text
    idel=1;
    for i=1:stp:nbtrials
        if nbstim(i)>0
            legtxt{idel} = [selfstim{i} ' - ' num2str(tstim_all(imouse,i)) ' stim'];
            idel=idel+1;
        end
    end

    supertit = 'Heart Rate locked to stim during dual calibration';
    figure2(1,'Color',[1 1 1], 'rend','painters','pos',[1 1 1200 600],'Name', supertit, 'NumberTitle','off')
        rectangle('Position',[ttime*1E4-prebuff,5,prebuff+postbuff,10],'FaceColor',[.9 .9 .9],'EdgeColor','none',...
        'LineWidth',.01)
        hold on

        rectangle('Position',[ttime*1E4,5,stimdur,10],'FaceColor',[.6 .6 .6],'EdgeColor','none',...
        'LineWidth',.01)
        hold on
        it=1;
        for itrial=1:stp:ntrial
            if nbstim(itrial)>0
                plot([5001:ttime*1E4-prebuff],squeeze(squeeze(ratepre_mean(imouse,itrial,5001:end-prebuff))),'Color',clrs_default(it,:)); % starts 500 ms after because median is culculated on trailing data (inverse for post)
                hold on
                p(it)=plot([ttime*1E4+postbuff:(ttime*2+stimdelay)*1e4-5000], squeeze(squeeze(ratepost_mean(imouse,itrial,postbuff:end-5000))),'Color',clrs_default(it,:));
%                     shadedErrorBar([5001:ttime*1E4-prebuff],squeeze(squeeze(ratepre_mean(imouse,itrial,5001:end-prebuff))), ...
%                         squeeze(squeeze(ratepre_std(imouse,itrial,5001:end-prebuff))),clrs_letter{itrial},1);
%                     hold on 
%                     h{itrial}=shadedErrorBar([ttime*1E4+postbuff:(ttime*2+stimdelay)*1e4-5000], squeeze(squeeze(ratepost_mean(imouse,itrial,postbuff:end-5000))),...
%                         squeeze(squeeze(ratepost_std(imouse,itrial,postbuff:end-5000))),clrs_letter{itrial},1);
                hold on
                it=it+1;
            end
        end

        ylim([9.5 maxy])
        xlim([5000 (ttime*2+stimdelay)*1e4-5000])
        set(gca, 'Xtick', 5001:5000:((ttime*2+stimdelay)*1e4)-5000,...
            'Xticklabel', num2cell([-1*(ttime-.5):.5:(stimdelay+ttime-.5)]))
        ax = gca;
        ax.Layer = 'top';
        xlabel('time (s)')
        ylabel('Hz')    
        legend(p,legtxt,'Location','SouthEast')
        title('Heart Rate locked to stim')

        hold off
        % Save figure
        if sav
            if smoo
                print([dir_out 'DualCalib_HR_stimlock_smooth'], '-dpng', '-r600');
            else
                print([dir_out 'DualCalib_HR_stimlock'], '-dpng', '-r600');
            end
        end
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
        print([dir_out 'Dual_heartrate_stimlock_zscore'], '-dpng', '-r600');
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
        print([dir_out 'Dual_average_hr_diff_2sec'], '-dpng', '-r300');
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
