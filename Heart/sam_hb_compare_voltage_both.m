function sam_hb_compare_voltage_figs(varargin)

%==========================================================================
% Details: run after sam_hb_compare_voltage_mfb and dual. Uses the output
% .mat files to create figures. originally for Heloise thesis. 
%
% INPUTS: calibmfb.mat and calibdual.mat
%       
%
% OUTPUT:
%
% NOTES: 
%
%   Written by Samuel Laventure - 04-06-2020 (based on sam_hb_exp.m)
%      
%==========================================================================
%% INPUT Directories and info
nmice = [941 016];

% Get directories
Dir = '/home/mobs/Dropbox/DataSL/Calib/HeartBeat/';

ntrial = 3; %assuming that all pre, post and cond have the same number of trials 

% Self-stim
selfstim = {'Low','Medium','High'};
%-----------------------------------------------------------------------------------------------------------------------

% set nbr of mice and trials
nbmice = 2
nbtrials = 3;

%% Parameters
% date for dir_out folders
t = char(datetime('now','Format','y-MM-d'));

% Directory to save and name of the figure to save
dir_out = [dropbox '/DataSL/Calib/HeartBeat/' t '/'];
if ~exist(dir_out,'dir')
    mkdir(dir_out);
end
sav = 1;

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
smoo =1; % do we smooth or not
sm = 500;
stp = 1;

% set text format
set(0,'defaulttextinterpreter','latex');
set(0,'DefaultTextFontname', 'Arial')
set(0,'DefaultAxesFontName', 'Arial')
set(0,'defaultTextFontSize',12)
set(0,'defaultAxesFontSize',12)

%% LOAD data
mfb = load([Dir 'calibmfb.mat']);
dual = load([Dir 'calibdual.mat']);


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
clrs_letter = {'b','r','g','y','c','m','k','b','r','g','y','c','m','k'};

% set legend text
idel=1;
for i=1:stp:mfb.nbtrials
    if mfb.nbstim(i)>0
        legtxt{idel} = [selfstim{i}];
        idel=idel+1;
    end
end

%--------------------------------------------------------------------------
%----------------------PLOT HEART RATE AROUND STIM-------------------------
%--------------------------------------------------------------------------
supertit = 'Heart Rate locked to stim';
figure2(1,'Color',[1 1 1], 'rend','painters','pos',[1 1 800 1800],'Name', supertit, 'NumberTitle','off')
    subplot(3,2,1:2)
        rectangle('Position',[ttime*1E4-prebuff,5,prebuff+postbuff,10],'FaceColor',[.9 .9 .9],'EdgeColor','none',...
        'LineWidth',.01)
        hold on
        rectangle('Position',[ttime*1E4,5,stimdur,10],'FaceColor',[.6 .6 .6],'EdgeColor','none',...
        'LineWidth',.01)
        hold on
        % MFB
        plot([5001:ttime*1E4-prebuff],squeeze(squeeze(mfb.ratepre_all_mean{1,1}(5001:end-prebuff))),...
             'Color',clrs_default(6,:),'LineWidth',2); % starts 500 ms after because median is culculated on trailing data (inverse for post)
        hold on
        p(1) = plot([ttime*1E4+postbuff:(ttime*2+stimdelay)*1e4-5000], squeeze(squeeze(mfb.ratepost_all_mean{1,1}(postbuff:end-5000))),... 
            'Color',clrs_default(6,:),'LineWidth',2);
        hold on
        % DUAL
        plot([5001:ttime*1E4-prebuff],squeeze(squeeze(dual.ratepre_all_mean{1,3}(5001:end-prebuff))),...
             'Color',clrs_default(7,:),'LineWidth',2); % starts 500 ms after because median is culculated on trailing data (inverse for post)
        hold on
        p(2) = plot([ttime*1E4+postbuff:(ttime*2+stimdelay)*1e4-5000], squeeze(squeeze(dual.ratepost_all_mean{1,3}(postbuff:end-5000))),... 
            'Color',clrs_default(7,:),'LineWidth',2);
        hold on
        
        ylim([9 14])
        xlim([5000 (ttime*2+stimdelay)*1e4-5000])
        set(gca, 'Xtick', 5001:5000:((ttime*2+stimdelay)*1e4)-5000,...
            'Xticklabel', num2cell([-1*(ttime-.5):.5:(stimdelay+ttime-.5)]))
        ax = gca;
        ax.Layer = 'top';
        xlabel('time (s)')
        ylabel('Hz')   
        title({'Self-Stimulation','LOW'},'FontSize',16, 'fontweight','bold')
        legend(p,{'MFB','Dual'},'Location','SouthEast')
        hold off
        
     % Medium
     subplot(3,2,3:4)
        rectangle('Position',[ttime*1E4-prebuff,5,prebuff+postbuff,10],'FaceColor',[.9 .9 .9],'EdgeColor','none',...
        'LineWidth',.01)
        hold on
        rectangle('Position',[ttime*1E4,5,stimdur,10],'FaceColor',[.6 .6 .6],'EdgeColor','none',...
        'LineWidth',.01)
        hold on
        % MFB
        plot([5001:ttime*1E4-prebuff],squeeze(squeeze(mfb.ratepre_all_mean{1,2}(5001:end-prebuff))),...
             'Color',clrs_default(6,:),'LineWidth',2); % starts 500 ms after because median is culculated on trailing data (inverse for post)
        hold on
        plot([ttime*1E4+postbuff:(ttime*2+stimdelay)*1e4-5000], squeeze(squeeze(mfb.ratepost_all_mean{1,2}(postbuff:end-5000))),... 
            'Color',clrs_default(6,:),'LineWidth',2);
        hold on
        % DUAL
        plot([5001:ttime*1E4-prebuff],squeeze(squeeze(dual.ratepre_all_mean{1,2}(5001:end-prebuff))),...
             'Color',clrs_default(7,:),'LineWidth',2); % starts 500 ms after because median is culculated on trailing data (inverse for post)
        hold on
        p(1)=plot([ttime*1E4+postbuff:(ttime*2+stimdelay)*1e4-5000], squeeze(squeeze(dual.ratepost_all_mean{1,2}(postbuff:end-5000))),... 
            'Color',clrs_default(7,:),'LineWidth',2);
        hold on
        
        ylim([9 14])
        xlim([5000 (ttime*2+stimdelay)*1e4-5000])
        set(gca, 'Xtick', 5001:5000:((ttime*2+stimdelay)*1e4)-5000,...
            'Xticklabel', num2cell([-1*(ttime-.5):.5:(stimdelay+ttime-.5)]))
        ax = gca;
        ax.Layer = 'top';
        xlabel('time (s)')
        ylabel('Hz')   
        title('MEDIUM','FontSize',16,'fontweight','bold')
        hold off
        
     % High
     subplot(3,2,5:6)
        rectangle('Position',[ttime*1E4-prebuff,5,prebuff+postbuff,10],'FaceColor',[.9 .9 .9],'EdgeColor','none',...
        'LineWidth',.01)
        hold on
        rectangle('Position',[ttime*1E4,5,stimdur,10],'FaceColor',[.6 .6 .6],'EdgeColor','none',...
        'LineWidth',.01)
        hold on
        % MFB
        plot([5001:ttime*1E4-prebuff],squeeze(squeeze(mfb.ratepre_all_mean{1,3}(5001:end-prebuff))),...
             'Color',clrs_default(6,:),'LineWidth',2); % starts 500 ms after because median is culculated on trailing data (inverse for post)
        hold on
        plot([ttime*1E4+postbuff:(ttime*2+stimdelay)*1e4-5000], squeeze(squeeze(mfb.ratepost_all_mean{1,3}(postbuff:end-5000))),... 
            'Color',clrs_default(6,:),'LineWidth',2);
        hold on
        % DUAL
        plot([5001:ttime*1E4-prebuff],squeeze(squeeze(dual.ratepre_all_mean{1,1}(5001:end-prebuff))),...
             'Color',clrs_default(7,:),'LineWidth',2); % starts 500 ms after because median is culculated on trailing data (inverse for post)
        hold on
        p(1)=plot([ttime*1E4+postbuff:(ttime*2+stimdelay)*1e4-5000], squeeze(squeeze(dual.ratepost_all_mean{1,1}(postbuff:end-5000))),... 
            'Color',clrs_default(7,:),'LineWidth',2);
        hold on
        
        ylim([9 14])
        xlim([5000 (ttime*2+stimdelay)*1e4-5000])
        set(gca, 'Xtick', 5001:5000:((ttime*2+stimdelay)*1e4)-5000,...
            'Xticklabel', num2cell([-1*(ttime-.5):.5:(stimdelay+ttime-.5)]))
        ax = gca;
        ax.Layer = 'top';
        xlabel('time (s)')
        ylabel('Hz')   
        title('HIGH','FontSize',16,'fontweight','bold')
        hold off
           
        
    % Save figure
    if sav
        print([dir_out 'MFBDualCalib_HR_stimlock_LowMedHI'], '-dpng', '-r600');
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
            legtxt{idel} = [volt{i} ' - ' num2str(tstim_all(imouse,i)) ' stim'];
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
