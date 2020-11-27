%% Parameters
sav=1;
dur_parts=5; %duration of sleep parts in minutes
dur_small=1; %duration of small bins of sleep parts in minutes 


% Directory to save and name of the figure to save
dir_out = '/home/mobs/Dropbox/MOBS_workingON/Sam/StimMFBWake/ripples/temp/';
%create folders
if ~exist(dir_out,'dir')
    mkdir(dir_out);
end

Dir = PathForExperimentsERC_SL('StimMFBWake');
Dir = RestrictPathForExperiment(Dir, 'nMice', [882 941]);

% set text format
% set(0,'defaulttextinterpreter','latex');
% set(0,'DefaultTextFontname', 'Arial')
% set(0,'DefaultAxesFontName', 'Arial')
% set(0,'defaultTextFontSize',12)
% set(0,'defaultAxesFontSize',12)

% var init
PreRipAmp=[];
PostRipAmp=[];
PreRipDur=[];
PostRipDur=[];
PreRipples_all=[];
PostRipples_all=[];

%#####################################################################
%#
%#                           M A I N
%#
%#####################################################################

for i = 1:length(Dir.path)
    %% Get Data
    Rip{i} = load([Dir.path{i}{1} 'Ripples.mat'], 'ripples');
    try
        Sleep{i} = load([Dir.path{i}{1} 'SleepScoring_OBGamma.mat'], 'Sleep', 'SWSEpoch');
    catch
        Sleep{i} = load([Dir.path{i}{1} 'SleepScoring_Accelero.mat'], 'Sleep', 'SWSEpoch');
    end        
    Session{i} = load([Dir.path{i}{1} 'behavResources.mat'], 'SessionEpoch');
    load([Dir.path{i}{1} 'ExpeInfo.mat']);
    riplfp(i) = load([Dir.path{i}{1} 'LFPData/LFP' num2str(ExpeInfo.ChannelToAnalyse.dHPC_rip) '.mat']);

    %% Split sleep sessions in parts
    % whole session
    Session{i}.SessionEpoch.PreSleep = and(Session{i}.SessionEpoch.PreSleep, Sleep{i}.SWSEpoch);
    Session{i}.SessionEpoch.PostSleep = and(Session{i}.SessionEpoch.PostSleep, Sleep{i}.SWSEpoch);
    
    % Restrict sleeps to first 15 min
    Session{i}.SessionEpoch.PreSleep_first = RestrictToTime(and(Session{i}.SessionEpoch.PreSleep, Sleep{i}.SWSEpoch),...
        dur_parts*60*1e4);
    Session{i}.SessionEpoch.PostSleep_first = RestrictToTime(and(Session{i}.SessionEpoch.PostSleep, Sleep{i}.SWSEpoch),...
        dur_parts*60*1e4);
    
    % Restrict sleeps to last 15 min
    [Pre_split res] = SplitIntervals(and(Session{i}.SessionEpoch.PreSleep, Sleep{i}.SWSEpoch),dur_parts*60*1e4);
    [post_split res] = SplitIntervals(and(Session{i}.SessionEpoch.PostSleep, Sleep{i}.SWSEpoch),dur_parts*60*1e4);
    Session{i}.SessionEpoch.PreSleep_last = and(Pre_split{length(Pre_split)}, Sleep{i}.SWSEpoch);        
    Session{i}.SessionEpoch.PostSleep_last = and(post_split{length(post_split)}, Sleep{i}.SWSEpoch);
    
    % split sleep sessions in smalll bouts
    Session{i}.SessionEpoch.PreSleep_bin = SplitIntervals(and(Session{i}.SessionEpoch.PreSleep, Sleep{i}.SWSEpoch),dur_small*60*1e4);
    Session{i}.SessionEpoch.PostSleep_bin = SplitIntervals(and(Session{i}.SessionEpoch.PostSleep, Sleep{i}.SWSEpoch),dur_small*60*1e4);
   
     %% Calculate density, duration, amplitude
     
    ripplesPeak{i}=ts(Rip{i}.ripples(:,2)*1e4);
    
    %----------------- DENSITY -------------------
    %whole session
    PreRipples{i}=Restrict(ripplesPeak{i},Session{i}.SessionEpoch.PreSleep);
    PostRipples{i}=Restrict(ripplesPeak{i},Session{i}.SessionEpoch.PostSleep);
    %concat
    PreRipples_all{i} = Data(PreRipples{i});
    PostRipples_all{i} = Data(PreRipples{i});
    
    % Number during sleep
    Pre_N(i)=length(Range(PreRipples{i}));
    Post_N(i)=length(Range(PostRipples{i}));
    % Normalize to the duration of sleep
    TimePre{i} = and(Session{i}.SessionEpoch.PreSleep, Sleep{i}.SWSEpoch);
    Pre_N_norm_all(i) = Pre_N(i)/((sum(End(TimePre{i})- Start(TimePre{i})))/1e4); 
    TimePost{i} = and(Session{i}.SessionEpoch.PostSleep, Sleep{i}.SWSEpoch);
    Post_N_norm_all(i) = Post_N(i)/((sum(End(TimePost{i})- Start(TimePost{i})))/1e4);
    
    % First part of sessions
    PreRipples_first{i}=Restrict(ripplesPeak{i},Session{i}.SessionEpoch.PreSleep_first);
    PostRipples_first{i}=Restrict(ripplesPeak{i},Session{i}.SessionEpoch.PostSleep_first);    
    % Number during sleep
    Pre_N_first(i)=length(Range(PreRipples_first{i}));
    Post_N_first(i)=length(Range(PostRipples_first{i}));
    % Normalize to the duration of sleep
    TimePre_first{i} = Session{i}.SessionEpoch.PreSleep_first;
    Pre_N_norm_all_first(i) = Pre_N_first(i)/((sum(End(TimePre_first{i})- Start(TimePre_first{i})))/1e4); 
    TimePost_first{i} = Session{i}.SessionEpoch.PostSleep_first;
    Post_N_norm_all_first(i) = Post_N_first(i)/((sum(End(TimePost_first{i})- Start(TimePost_first{i})))/1e4);
    
    % Last part of sessions
    PreRipples_last{i}=Restrict(ripplesPeak{i},Session{i}.SessionEpoch.PreSleep_last);
    PostRipples_last{i}=Restrict(ripplesPeak{i},Session{i}.SessionEpoch.PostSleep_last);    
    % Number during sleep
    Pre_N_last(i)=length(Range(PreRipples_last{i}));
    Post_N_last(i)=length(Range(PostRipples_last{i}));
    % Normalize to the duration of sleep
    TimePre_last{i} = Session{i}.SessionEpoch.PreSleep_last;
    Pre_N_norm_all_last(i) = Pre_N_last(i)/((sum(End(TimePre_last{i})- Start(TimePre_last{i})))/1e4); 
    TimePost_last{i} = Session{i}.SessionEpoch.PostSleep_last;
    Post_N_norm_all_last(i) = Post_N_last(i)/((sum(End(TimePost_last{i})- Start(TimePost_last{i})))/1e4);
    
    % Ripples dynamics
    for ibin=1:length(Session{i}.SessionEpoch.PreSleep_bin)
        PreRipples_bin{i,ibin}=Restrict(ripplesPeak{i},Session{i}.SessionEpoch.PreSleep_bin{ibin});
        Pre_N_bin(i,ibin)=length(Range(PreRipples_bin{i,ibin}));
        Pre_N_norm_all_bin(i,ibin) = Pre_N_bin(i,ibin)/(dur_small*60);
    end
    for ibin=1:length(Session{i}.SessionEpoch.PostSleep_bin)
        PostRipples_bin{i,ibin}=Restrict(ripplesPeak{i},Session{i}.SessionEpoch.PostSleep_bin{ibin}); 
        Post_N_bin(i,ibin)=length(Range(PostRipples_bin{i,ibin}));
        Post_N_norm_all_bin(i,ibin) = Post_N_bin(i,ibin)/(dur_small*60);
    end
 
    
    
    %----------------- DURATION -------------------
    % start of ripples
    ripplesBeg{i}=tsd(Rip{i}.ripples(:,2)*1e4,Rip{i}.ripples(:,1)*1e4);
    PreRipplesBeg{i}=Restrict(ripplesBeg{i},and(Session{i}.SessionEpoch.PreSleep, Sleep{i}.SWSEpoch));
    PostRipplesBeg{i}=Restrict(ripplesBeg{i},and(Session{i}.SessionEpoch.PostSleep, Sleep{i}.SWSEpoch));
    %end of ripples
    ripplesEnd{i}=tsd(Rip{i}.ripples(:,2)*1e4,Rip{i}.ripples(:,3)*1e4);
    PreRipplesEnd{i}=Restrict(ripplesEnd{i},and(Session{i}.SessionEpoch.PreSleep, Sleep{i}.SWSEpoch));
    PostRipplesEnd{i}=Restrict(ripplesEnd{i},and(Session{i}.SessionEpoch.PostSleep, Sleep{i}.SWSEpoch));
    % Duration
    for k = 1:length(Range(PreRipplesBeg{i}))
        Pre_dur{i} = (Data(PreRipplesEnd{i})/1e4) - (Data(PreRipplesBeg{i})/1e4);
    end
    Pre_dur_mean(i) = mean(Pre_dur{i});
    for k = 1:length(Range(PostRipplesBeg{i}))
        Post_dur{i} = (Data(PostRipplesEnd{i})/1e4) - (Data(PostRipplesBeg{i})/1e4);
    end
    Post_dur_mean(i) = mean(Post_dur{i});
    %Dynamics
    for ibin=1:length(Session{i}.SessionEpoch.PreSleep_bin)
        PreRipplesBeg_bin{i,ibin}=Restrict(ripplesBeg{i},Session{i}.SessionEpoch.PreSleep_bin{ibin});
        PreRipplesEnd_bin{i,ibin}=Restrict(ripplesEnd{i},Session{i}.SessionEpoch.PreSleep_bin{ibin});
        Pre_dur_bin{i,ibin} = (Data(PreRipplesEnd_bin{i,ibin})/1e4) - (Data(PreRipplesBeg_bin{i,ibin})/1e4);
        Pre_dur_bin_mean(i,ibin) = squeeze(mean(Pre_dur_bin{i,ibin},1));
    end
    for ibin=1:length(Session{i}.SessionEpoch.PostSleep_bin)
        PostRipplesBeg_bin{i,ibin}=Restrict(ripplesBeg{i},Session{i}.SessionEpoch.PostSleep_bin{ibin});
        PostRipplesEnd_bin{i,ibin}=Restrict(ripplesEnd{i},Session{i}.SessionEpoch.PostSleep_bin{ibin});
        Post_dur_bin{i,ibin} = (Data(PostRipplesEnd_bin{i,ibin})/1e4) - (Data(PostRipplesBeg_bin{i,ibin})/1e4);
        Post_dur_bin_mean(i,ibin) = squeeze(mean(Post_dur_bin{i,ibin},1));
    end
    % all ripples (for dist)
    PreRipDur = cat(1,PreRipDur,Pre_dur{i});
    PostRipDur = cat(1,PostRipDur,Post_dur{i});     
    
    
    %----------------- AMPLITUDE -------------------
    %amplitude of ripples
    ripplesAmp{i}=tsd(Rip{i}.ripples(:,2)*1e4,Rip{i}.ripples(:,4));
    PreRipplesAmp{i}=Restrict(ripplesAmp{i},and(Session{i}.SessionEpoch.PreSleep, Sleep{i}.SWSEpoch));
    PostRipplesAmp{i}=Restrict(ripplesAmp{i},and(Session{i}.SessionEpoch.PostSleep, Sleep{i}.SWSEpoch));
    Pre_amp{i}=Data(PreRipplesAmp{i});
    Post_amp{i}=Data(PostRipplesAmp{i});
    % Amplitude
    Pre_Amp_mean(i) = mean(Data(PreRipplesAmp{i}));
    Post_Amp_mean(i) = mean(Data(PostRipplesAmp{i}));
    % Dynamics
    for ibin=1:length(Session{i}.SessionEpoch.PreSleep_bin)
        PreRipplesAmp_bin{i,ibin}=Restrict(ripplesAmp{i},Session{i}.SessionEpoch.PreSleep_bin{ibin});
        PreRipplesAmp_bin_mean(i,ibin)  = squeeze(mean(Data(PreRipplesAmp_bin{i,ibin}),1));
    end
    for ibin=1:length(Session{i}.SessionEpoch.PostSleep_bin)
        PostRipplesAmp_bin{i,ibin}=Restrict(ripplesAmp{i},Session{i}.SessionEpoch.PostSleep_bin{ibin});
        PostRipplesAmp_bin_mean(i,ibin)  = squeeze(mean(Data(PostRipplesAmp_bin{i,ibin}),1));
    end
    % all ripples (for dist)
    PreRipAmp = cat(1,PreRipAmp,Pre_amp{i});
    PostRipAmp = cat(1,PostRipAmp,Post_amp{i});    

% [preM{i} preT{i}]=PlotRipRaw(riplfp(i),Data(ts(PreRipples_all))/1e4,[-50 50],1,0,0);
% [postM{i} postT{i}]=PlotRipRaw(riplfp(i),Data(ts(PostRipples_all))/1e4,[-50 50],1,0,0);
end



% %% Plot
% supertit = 'Average ripple';
% figure('Color',[1 1 1], 'rend','painters','pos',[1 1 900 500],'Name', supertit, 'NumberTitle','off')
%     subplot(1,2,1:2) 
%         plot(preM(:,2))
%         hold on
%         plot(postM(:,2))
%         legend('Pre Sleep','Post Sleep')
%         title('Average ripples', 'FontSize', 18);
%         ylabel('amplitude')
%         xlabel('time (ms)')
%         xlim([0 125])
%         xticks(0:12.5:125)
%         set(gca,'Xticklabel',num2cell(-50:10:50))
%         grid on
%         
% 
% % FIGURE 1: 
% % set y axis limits
maxy = max([Pre_N_norm_all Post_N_norm_all]);
maxy_first = max([Pre_N_norm_all_first Post_N_norm_all_first]);
maxy_last = max([Pre_N_norm_all_last Post_N_norm_all_last]);

maxy_all=max([maxy maxy_first maxy_last]);
% 
% supertit = 'Ripples density';
% figure('Color',[1 1 1], 'rend','painters','pos',[1 1 1800 400],'Name', supertit, 'NumberTitle','off')
%     % Absolute number
%     subplot(131)
%         [p,h, her] = PlotErrorBarN_SL([Pre_N_norm_all' Post_N_norm_all'],...
%             'colorpoints',1,'barcolors', [.3 .3 .3], 'barwidth', 0.6, 'newfig', 0);
%         ylim([0 maxy_all+.15*maxy_all]);
%         set(gca,'Xtick',[1:2],'XtickLabel',{'PreSleep', 'PostSleep'});
%         set(gca, 'FontSize', 14);
%         h.FaceColor = 'flat';
%         h.CData(1,:) = [.3 .3 .3];
%         h.CData(2,:) = [1 1 1];
%         set(h, 'LineWidth', 2);
%         set(her, 'LineWidth', 2);
%         ylabel('Ripples/s');
%         title('Ripples density - complete sessions', 'FontSize', 18);
% 
%     subplot(132)
%         [p,h, her] = PlotErrorBarN_SL([Pre_N_norm_all_first' Post_N_norm_all_first'],...
%             'colorpoints',1,'barcolors', [.3 .3 .3], 'barwidth', 0.6, 'newfig', 0);
%         ylim([0 maxy_all+.15*maxy_all]);
%         set(gca,'Xtick',[1:2],'XtickLabel',{'PreSleep', 'PostSleep'});
%         set(gca, 'FontSize', 14);
%         h.FaceColor = 'flat';
%         h.CData(1,:) = [.3 .3 .3];
%         h.CData(2,:) = [1 1 1];
%         set(h, 'LineWidth', 2);
%         set(her, 'LineWidth', 2);
%         ylabel('Ripples/s');
%         title(['Ripples density in first ' num2str(dur_parts) ' min of sleep'], 'FontSize', 18);
%         
%     subplot(133)
%         [p,h, her] = PlotErrorBarN_SL([Pre_N_norm_all_last' Post_N_norm_all_last'],...
%             'colorpoints',1,'barcolors', [.3 .3 .3], 'barwidth', 0.6, 'newfig', 0);
%         ylim([0 maxy_all+.15*maxy_all]);
%         set(gca,'Xtick',[1:2],'XtickLabel',{'PreSleep', 'PostSleep'});
%         set(gca, 'FontSize', 14);
%         h.FaceColor = 'flat';
%         h.CData(1,:) = [.3 .3 .3];
%         h.CData(2,:) = [1 1 1];
%         set(h, 'LineWidth', 2);
%         set(her, 'LineWidth', 2);
%         ylabel('Ripples/s');
%         title(['Ripples density in last ' num2str(dur_parts) ' min of sleep'], 'FontSize', 18);
% 
%     %% Save figure
%     if sav
%         print([dir_out 'ripples_prepost_compare'], '-dpng', '-r300');
%     end


supertit = 'Ripples details';
figure('Color',[1 1 1], 'rend','painters','pos',[1 1 1300 400],'Name', supertit, 'NumberTitle','off')
     subplot(131)
        [p,h, her] = PlotErrorBarN_SL([Pre_N_norm_all' Post_N_norm_all'],...
            'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0,'colorpoints',0,...
            'showpoints',0);
        ylim([0 maxy_all+.15*maxy_all]);
        set(gca,'Xtick',[1:2],'XtickLabel',{'Pre', 'Post'});
        set(gca, 'FontSize', 16, 'FontWeight',  'bold');
        set(gca, 'LineWidth', 3);
        set(h, 'LineWidth', 3);
        set(her, 'LineWidth', 3);
        h.FaceColor = 'flat';
        h.CData(1,:) = [0 0 0];
        h.CData(2,:) = [1 1 1];
        set(h, 'LineWidth', 3);
        set(her, 'LineWidth', 3);
        ylabel('Ripples/sec');
        title('Mean ripples density', 'FontSize', 18);
    subplot(132)
        [p,h, her] = PlotErrorBarN_SL([(Pre_dur_mean*1e3)' (Post_dur_mean*1e3)'],...
            'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0,'colorpoints',0,...
            'showpoints',0);
        ylim([0 55]);
        set(gca,'Xtick',[1:2],'XtickLabel',{'Pre', 'Post'});
        set(gca, 'FontSize', 16, 'FontWeight',  'bold');
        set(gca, 'LineWidth', 3);
        set(h, 'LineWidth', 3);
        set(her, 'LineWidth', 3);
        h.FaceColor = 'flat';
        h.CData(1,:) = [0 0 0];
        h.CData(2,:) = [1 1 1];
        set(h, 'LineWidth', 3);
        set(her, 'LineWidth', 3);
        ylabel('Duration (ms)');
        title('Mean ripples duration', 'FontSize', 18);

    subplot(133)
        [p,h, her] = PlotErrorBarN_SL([Pre_Amp_mean' Post_Amp_mean'],...
            'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'colorpoints',0,...
            'showpoints',0);
        ylim([0 20]);
        set(gca,'Xtick',[1:2],'XtickLabel',{'Pre', 'Post'});
        set(gca, 'FontSize', 16, 'FontWeight',  'bold');
        set(gca, 'LineWidth', 3);
        set(h, 'LineWidth', 3);
        set(her, 'LineWidth', 3);
        h.FaceColor = 'flat';
        h.CData(1,:) = [0 0 0];
        h.CData(2,:) = [1 1 1];
        set(h, 'LineWidth', 2);
        set(her, 'LineWidth', 2);
        ylabel('uV')
        title('Mean ripples amplitude', 'FontSize', 18);
    
    %% Save figure
    if sav
        print([dir_out 'ripples_details'], '-dpng', '-r300');
    end
    
% FIGURE ripples dynamics across sleep session

supertit = 'Ripples Dynamics Across Sleep Sessions';

figure('Color',[1 1 1], 'rend','painters','pos',[1 1 2400 800],'Name', supertit, 'NumberTitle','off')
    Pre_N_norm_all_bin(Pre_N_norm_all_bin==0)=nan;
    Post_N_norm_all_bin(Post_N_norm_all_bin==0)=nan;
    Pre_dur_bin_mean(Pre_dur_bin_mean==0)=nan;
    Post_dur_bin_mean(Post_dur_bin_mean==0)=nan;
    PreRipplesAmp_bin_mean(PreRipplesAmp_bin_mean==0)=nan;
    PostRipplesAmp_bin_mean(PostRipplesAmp_bin_mean==0)=nan;
    
    Pre_N_norm_all_bin=nanmean(Pre_N_norm_all_bin);
    Post_N_norm_all_bin=nanmean(Post_N_norm_all_bin);
    Pre_dur_bin_mean=nanmean(Pre_dur_bin_mean);
    Post_dur_bin_mean=nanmean(Post_dur_bin_mean);
    PreRipplesAmp_bin_mean=nanmean(PreRipplesAmp_bin_mean);
    PostRipplesAmp_bin_mean=nanmean(PostRipplesAmp_bin_mean);
    
    %set limits
    ylimmax_den = max(max([Pre_N_norm_all_bin Post_N_norm_all_bin]));
    ylimmax_dur = max(max([Pre_dur_bin_mean Post_dur_bin_mean]))*1000;
    ylimmax_amp = max(max([PreRipplesAmp_bin_mean PostRipplesAmp_bin_mean]));
    
    subplot(2,6,1:2)
        plot(Pre_N_norm_all_bin)
            t_str = {'DENSITY';'PreSleep'}; 
            title(t_str, 'FontSize', 13, 'interpreter','latex',...
                'HorizontalAlignment', 'center');
            ylabel('ripples/sec')
            ylim([0 ylimmax_den+ylimmax_den*.15])
            xlabel(['Time in seconds'])
            xtickangle(45)
            xlim([1 length(Pre_N_norm_all_bin)])
            set(gca, 'Xtick', 0:5:length(Pre_N_norm_all_bin),...
                'Xticklabel', num2cell([0:5:length(Pre_N_norm_all_bin)]*dur_small*60))
       
    subplot(2,6,7:8)      
        plot(Post_N_norm_all_bin)
            t_str = {'PostSleep'}; 
            title(t_str, 'FontSize', 13, 'interpreter','latex',...
                'HorizontalAlignment', 'center');
            ylabel('ripples/sec')
            ylim([0 ylimmax_den+ylimmax_den*.15])
            xlabel(['Time in seconds'])
            xtickangle(45)
            xlim([1 length(Post_N_norm_all_bin)])
            set(gca, 'Xtick', 0:5:length(Post_N_norm_all_bin),...
                'Xticklabel', num2cell([0:5:length(Post_N_norm_all_bin)]*dur_small*60))
        
     subplot(2,6,3:4)
        plot(Pre_dur_bin_mean*1000)
            t_str = {'DURATION';'PreSleep'}; 
            title(t_str, 'FontSize', 13, 'interpreter','latex',...
                'HorizontalAlignment', 'center');
            ylabel('msec')
            ylim([0 ylimmax_dur+ylimmax_dur*.15])
            xlabel(['Time in seconds'])
            xtickangle(45)
            xlim([1 length(Pre_N_norm_all_bin)])
            set(gca, 'Xtick', 0:5:length(Pre_N_norm_all_bin),...
                'Xticklabel', num2cell([0:5:length(Pre_N_norm_all_bin)]*dur_small*60))   
        
     subplot(2,6,9:10)
        plot(Post_dur_bin_mean*1000)
            t_str = {'Post-Sleep'}; 
            title(t_str, 'FontSize', 13, 'interpreter','latex',...
                'HorizontalAlignment', 'center');
            ylabel('msec')
            ylim([0 ylimmax_dur+ylimmax_dur*.15])
            xlabel(['Time in seconds'])
            xtickangle(45)
            xlim([1 length(Post_N_norm_all_bin)])
            set(gca, 'Xtick', 0:5:length(Post_N_norm_all_bin),...
                'Xticklabel', num2cell([0:5:length(Post_N_norm_all_bin)]*dur_small*60))   

     subplot(2,6,5:6)
        plot(PreRipplesAmp_bin_mean)
            t_str = {'AMPLITUDE';'PreSleep'}; 
            title(t_str, 'FontSize', 13, 'interpreter','latex',...
                'HorizontalAlignment', 'center');
            ylabel('$${\mu}$$V')
            ylim([0 ylimmax_amp+ylimmax_amp*.15])
            xlabel(['Time in seconds'])
            xtickangle(45)
            xlim([1 length(Pre_N_norm_all_bin)])
            set(gca, 'Xtick', 0:5:length(Pre_N_norm_all_bin),...
                'Xticklabel', num2cell([0:5:length(Pre_N_norm_all_bin)]*dur_small*60))   
        
     subplot(2,6,11:12)
        plot(PostRipplesAmp_bin_mean)
            t_str = {'PostSleep'}; 
            title(t_str, 'FontSize', 13, 'interpreter','latex',...
                'HorizontalAlignment', 'center');
            ylabel('$${\mu}$$V')
            ylim([0 ylimmax_amp+ylimmax_amp*.15])
            xlabel(['Time in seconds'])
            xtickangle(45)
            xlim([1 length(Post_N_norm_all_bin)])
            set(gca, 'Xtick', 0:5:length(Post_N_norm_all_bin),...
                'Xticklabel', num2cell([0:5:length(Post_N_norm_all_bin)]*dur_small*60))  
       if sav
            print([dir_out 'ripples_dynamics'], '-dpng', '-r300');
       end

       


% % Figure Distribtions
% 
% xlimdur_max = max(max(PreRipDur*1000),max(PostRipDur*1000));
% xlimdur_min = min(min(PreRipDur*1000),min(PostRipDur*1000));
% xlimamp_max = max(max(PreRipAmp),max(PostRipAmp));
% xlimamp_min = min(min(PreRipAmp),min(PostRipAmp));
% 
% set(0,'defaultAxesFontSize',12)
% supertit = 'Ripples distributions';
% figure('Color',[1 1 1], 'rend','painters','pos',[1 1 1400 800],'Name', supertit, 'NumberTitle','off')
%     subplot(2,4,1:2) 
%         hist(PreRipDur*1000,100)
%         t_str = {'DURATION';'PreSleep'}; 
%         title(t_str, 'FontSize', 18, 'interpreter','latex',...
%                 'HorizontalAlignment', 'center');
%         xlabel('ms')
%         ylabel('Number')    
%         xlim([xlimdur_min xlimdur_max])
%     
%     subplot(2,4,5:6) 
%         hist(PostRipDur*1000,100)
%         t_str = {'PostSleep'}; 
%         title(t_str, 'FontSize', 18, 'interpreter','latex',...
%                 'HorizontalAlignment', 'center');
%         xlabel('ms')
%         ylabel('Number') 
%         xlim([xlimdur_min xlimdur_max])
%         
%     subplot(2,4,3:4) 
%         hist(PreRipAmp,250)
%         t_str = {'AMPLITUDE';'PreSleep'}; 
%         title(t_str, 'FontSize', 18, 'interpreter','latex',...
%                 'HorizontalAlignment', 'center');
%         xlabel('$${\mu}$$V')
%         ylabel('Number')
%         xlim([xlimamp_min xlimamp_max])
%         
%     subplot(2,4,7:8) 
%         hist(PostRipAmp,250)
%         t_str = {'PostSleep'}; 
%         title(t_str, 'FontSize', 18, 'interpreter','latex',...
%                 'HorizontalAlignment', 'center');
%         xlabel('$${\mu}$$V')
%         ylabel('Number')
%         xlim([xlimamp_min xlimamp_max])
%         
%         if sav
%             print([dir_out 'ripples_dist'], '-dpng', '-r300');
%        end
% 
% f2 = figure('units', 'normalized', 'outerposition', [0 0 0.8 0.6])
% 
%     Effect = (Post_N_norm_all)' - (Pre_N_norm_all');
%     AmpEffect = [mean([Pre_Amp_mean' Post_Amp_mean'],2) Effect];
%     AmpEffectCorr = corrcoef([mean([Pre_Amp_mean' Post_Amp_mean'],2) Effect]);
%     DurEffect = [mean([(Pre_dur_mean*1e3)' (Post_dur_mean*1e3)'],2) Effect];
%     DurEffectCorr = corrcoef([mean([(Pre_dur_mean*1e3)' (Post_dur_mean*1e3)'],2) Effect]);
% 
%     subplot(121)
%         scatter(DurEffect(:,1),DurEffect(:,2), 'filled','MarkerFaceColor','k')
%         hold on
%         l = lsline;
%         set(l,'Color','k','LineWidth',3)
%         set(gca, 'FontSize', 14, 'FontWeight',  'bold');
%         ylabel('Difference between before and after');
%         xlabel('Duration of ripples');
%         title('Ripples density effect correlation with ripples duration', 'FontSize', 14);
% 
%     subplot(122)
%         scatter(AmpEffect(:,1),AmpEffect(:,2), 'filled','MarkerFaceColor','k')
%         hold on
%         l = lsline;
%         set(l,'Color','k','LineWidth',3)
%         set(gca, 'FontSize', 14, 'FontWeight',  'bold');
%         ylabel('Difference between before and after');
%         xlabel('Amplitude of ripples');
%         title('Ripples density effect correlation with ripples amplitude', 'FontSize', 14);
% 
%     if sav
%         saveas(gcf, [dir_out 'Correlation.fig']);
%         saveFigure(gcf,'Correlation',dir_out);
%     end