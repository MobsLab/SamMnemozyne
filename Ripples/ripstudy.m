clear all
% MFB
expe{1} = 'StimMFBWake';
mice_num{1} = [882 941 1081 1117 1161 1162 1168 1182 1199 1199 1223 1228 1239 1239];  % mice ID #
numexpe{1} = [1 1 1 1 1 1 1 1 1 2 1 1 1 2];
% PAG 
expe{2} = 'UMazePAG';
mice_num{2} = [797 798 828 861 882 905 906 911 912 977 994 1117 1124 1161 1162 1168 1182 1186 1199];
numexpe{2} = [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
% Novel 
expe{3} = 'Novel';
mice_num{3} = [1016 1081 1083 1161 1182 1183 1185 1223 1228 1230];
numexpe{3} = [1 1 1 1 1 1 1 1 1 1];

% expe{1} = 'StimMFBWake';
% mice_num{1} = [1199 1199 1223 1228 1239 1239];  % mice ID #
% numexpe{1} = [1 2 1 1 1 2];
%% Parameters
partlen = 3300;   % in sec

frequency_band = [120 220];
frequency = 1250;

%% get data
disp('Getting data...')
for i=1:length(expe)
    Dir{i} = PathForExperimentsERC(expe{i});
    switch expe{i}
        case 'StimMFBWake'
            expname{i}='MFB';
        case 'Novel'
            expname{i}='Novel';
        case 'UMazePAG'
            expname{i}='PAG';
        case 'Known'
            expname{i}='Known';
    end
    Dir{i} = RestrictPathForExperiment(Dir{i}, 'nMice', unique(mice_num{i}));
end

%% PROCESSING
for iexp=1:length(expe)
    disp(['   Experiment: ' expname{iexp}])
    disp('Processing:')
    nsuj = 0;
    for isuj = 1:length(Dir{iexp}.path)
        for iisuj=1:length(Dir{iexp}.path{isuj})
            nsuj = nsuj+1;
            disp(['   M' num2str(mice_num{iexp}(nsuj))])
            load([Dir{iexp}.path{isuj}{iisuj} 'behavResources.mat'],'SessionEpoch');
            load([Dir{iexp}.path{isuj}{iisuj} 'SWR.mat'],'RipplesEpoch','ripples');
            try 
                load([Dir{iexp}.path{isuj}{iisuj} 'SleepScoring_OBGamma.mat'],'Sleep','SWSEpoch');
                disp('...loading sleep from OBGamma')
            catch
                load([Dir{iexp}.path{isuj}{iisuj} 'SleepScoring_Accelero.mat'],'Sleep','SWSEpoch');
                disp('...loading sleep from Accelero')
            end
            %set sessions
            try
                sess{1} = and(SessionEpoch.PreSleep,SWSEpoch);
            catch
                sess{1} = and(SessionEpoch.Baseline,SWSEpoch);
            end
            sess{2} = and(SessionEpoch.PostSleep,SWSEpoch);
            
            %set parts
            for isess=1:2
                nrem_ep = and(sess{isess},SWSEpoch);
                nrem_len=0;
                for iep=1:length(Start(nrem_ep))
                    nrem_add = End(subset(nrem_ep,iep))-Start(subset(nrem_ep,iep));
                    if (nrem_len+nrem_add)<partlen*1e4
                        if ~(iep==length(Start(nrem_ep)))
                            nrem_len = nrem_len + nrem_add;
                        else
                            nrem_end = Start(subset(nrem_ep,iep)) + (partlen*1e4) - nrem_len;
                        end
                    else
                        nrem_end = Start(subset(nrem_ep,iep)) + (partlen*1e4) - nrem_len;
                        break
                    end
                end
                part{isess} = intervalSet(Start(subset(nrem_ep,1)),nrem_end);
                clear nrem_end
            end            
            
            for j=1:2
                % set ripples per session
                rip{j} = and(RipplesEpoch,sess{j});
                st_ripsess = Start(rip{j});
                st_ripall = Start(RipplesEpoch);
                void=[]; ii=1;
                for irip=1:length(st_ripsess)
                    if ~isempty(find(st_ripsess(irip)==st_ripall))
                        rip_idx(irip) = find(st_ripsess(irip)==st_ripall);
                    else
                        void(ii) = irip;
                        ii=ii+1;
                    end
                end
                rip_idx(void) = [];
                clear sesssleep sleepdur st_ripall
                
                % set ripples per part
                rip_part{j} = and(RipplesEpoch,part{j});
                st_rippart = Start(rip_part{j});
                st_ripall = Start(RipplesEpoch);
                void=[]; ii=1;
                for irip=1:length(st_rippart)
                    if ~isempty(find(st_rippart(irip)==st_ripall))
                        rippart_idx(irip) = find(st_rippart(irip)==st_ripall);
                    else
                        void(ii) = irip;
                        ii=ii+1;
                    end
                end
                rippart_idx(void) = [];
                
                % all - session
                amp(j,1:length(rip_idx)) = ripples(rip_idx,6);
                amp_med(j) = mean(ripples(rip_idx,6));
                freq(j,1:length(rip_idx)) = ripples(rip_idx,5);
                freq_med(j) = mean(ripples(rip_idx,5));
                dur(j,1:length(rip_idx)) = ripples(rip_idx,4);
                dur_med(j) = mean(ripples(rip_idx,4));
%                 sesssleep = and(Sleep,sess{j});
                sleepdur = sum(End(sess{j})-Start(sess{j}))/1e4;
                den(j) = length(st_ripsess)/sleepdur;    

                % part (NREM) - first minutes of sessions
                amp_p(j,1:length(rippart_idx)) = ripples(rippart_idx,6);
                amp_p_med(j) = mean(ripples(rippart_idx,6));
                freq_p(j,1:length(rippart_idx)) = ripples(rippart_idx,5);
                freq_p_med(j) = mean(ripples(rippart_idx,5));
                dur_p(j,1:length(rippart_idx)) = ripples(rippart_idx,4);
                dur_p_med(j) = mean(ripples(rippart_idx,4));
                den_p(j) = length(st_rippart)/partlen;  
                
                clear st_rippart sesssleep st_ripall rip_idx rippart_idx nrem_ep void
            
                % sort by minute
                cumall=cumsum(End(sess{j})-Start(sess{j}));
                minlen = floor(cumall(end)/60e4);
                id_st = 1;
                for imin=1:minlen 
                    idmin = find(cumall>imin*60e4,1,'first');
                    if imin == 1
                        st_tmp = Start(subset(sess{j},id_st));
                    else
                        st_tmp = lastmin;
                    end
                    if idmin > 1
                        timerest = 60e4 - cumall(idmin-1); 
                    else
                        timerest = 60e4;
                    end
                    lastst = Start(subset(sess{j},idmin));
%                     disp([num2str(j) '; ' num2str(imin) ' min'])
                    lastmin = lastst+timerest;
                    ripmin = and(rip{j},intervalSet(st_tmp,lastmin));
                    
                    st_ripmin = Start(ripmin);
                    st_ripall = Start(RipplesEpoch);
                    void=[]; ii=1; ripmin_idx = [];
                    for irip=1:length(st_ripmin)
                        if ~isempty(find(st_ripmin(irip)==st_ripall))
                            ripmin_idx(irip) = find(st_ripmin(irip)==st_ripall);
                        else
                            void(ii) = irip;
                            ii=ii+1;
                        end
                    end
                    if exist('void','var') && ~isempty(void) && ~isempty(ripmin_idx)
                        ripmin_idx(void) = [];
                    end
                    if ~isempty(ripmin_idx)
                        ampmin(iexp,isuj,j,imin) = nanmean(ripples(ripmin_idx,6));
                        freqmin(iexp,isuj,j,imin) = nanmean(ripples(ripmin_idx,5));
                        durmin(iexp,isuj,j,imin) = nanmean(ripples(ripmin_idx,4));
                    else
                        ampmin(iexp,isuj,j,imin) = nan;
                        freqmin(iexp,isuj,j,imin) = nan;
                        durmin(iexp,isuj,j,imin) = nan;
                    end
                    clear ripmin_idx ripmin 
                end
            end
%             ampall{iexp,isuj,j}=amp;
%             freqall{iexp,isuj,j}=freq;
%             durall{iexp,isuj,j}=dur;

            % insert nans
            try
                amp(~amp) = nan ;
                freq(~freq) = nan ;
                dur(~dur) = nan;
            end
            try 
                amp_p(~amp_p) = nan ;
                freq_p(~freq_p) = nan ;
                dur_p(~dur_p) = nan;
            end   
%             try
%                 ampmin(~ampmin) = nan ;
%                 freqmin(~freqmin) = nan ;
%                 durmin(~durmin) = nan;
%             end
            % figures
            supertit = [expname{iexp} '_M' num2str(mice_num{iexp}(isuj)) ' - Change in ripples  - PreSleep(blue) vs PostSleep(red)'];
            figH = figure('Color',[1 1 1], 'rend','painters','pos', ...
                [10 10 1000 900],'Name', supertit, 'NumberTitle','off');
                subplot(3,2,1:2)
                    plot(runmean(amp',10));
                    title('Amplitude')
                    legend({'pre','post'})
                    xlim([0 size(amp,2)])
                    makepretty_erc
                subplot(3,2,3:4)
                    plot(runmean(freq',10));
                    title('Frequency')
                    makepretty_erc
                subplot(3,2,5:6)
                    plot(runmean(dur',10)); 
                    title('Duration') 
                    makepretty_erc
 
                    
%                 subplot(3,2,1:2)
%                     p1=plot(smooth(amp(1,1:sum(~isnan(amp(1,:)))),50)); hold on
%                     p2=plot(smooth(amp(2,1:sum(~isnan(amp(2,:)))),50)); 
%                     title('Amplitude')
%                     legend([p1 p2],{'pre','post'})
%                     makepretty_erc
%                 subplot(3,2,3:4)
%                     h1=plot(smooth(freq(1,1:sum(~isnan(freq(1,:)))),50)); hold on
%                     h2=plot(smooth(freq(2,1:sum(~isnan(freq(2,:)))),50)); 
%                     title('Frequency')
%             %         legend([h1 h2],{'pre','post'})
%                     makepretty_erc
%                 subplot(3,2,5:6)
%                     h1=plot(smooth(dur(1,1:sum(~isnan(dur(1,:)))),50)); hold on
%                     h2=plot(smooth(dur(2,1:sum(~isnan(dur(2,:)))),50)); 
%                     title('Duration')
%             %         legend([h1 h2],{'pre','post'})    
%                     makepretty_erc
                    
            annotation('textbox',[.48 .89 .3 .1], ...
                'String',['  M' num2str(mice_num{iexp}(nsuj))],'FontSize',24, ...
                'FitBoxToText','on')
            
            figName = ['RipplesChar_PrevsPost_' expname{iexp} '_' ...
                num2str(numexpe{iexp}(nsuj)) '_M'  num2str(mice_num{iexp}(nsuj))];
                    saveF(figH,figName,[dropbox '/DataSL/Ripples/'],'sformat',{'dpng'},'res',300,'savfig',0)
                
            yden  = max([den den_p]);
%             yamp  = max(max([amp amp_p]))*1.1;
%             yfreq = max(max([freq freq_p]))*1.1;
%             ydur  = max(max([dur dur_p]))*1.1; 

            supertit = [expname{iexp} '_M' num2str(mice_num{iexp}(nsuj)) ' - Change in ripples - ' ...
                num2str(partlen) ' first sec. - PreSleep(blue) vs PostSleep(red)'];
            figH = figure('Color',[1 1 1], 'rend','painters','pos', ...
                [10 10 2000 900],'Name', supertit, 'NumberTitle','off');
                subplot(241)
                    h1=histogram(amp(1,:)); hold on
                    h2=histogram(amp(2,:)); 
                    title('Amplitude - session')
                    legend([h1 h2],{'pre','post'},'AutoUpdate','off')
                    xline(amp_med(1),'LineWidth',1,'Color','b');
                    xline(amp_med(2),'LineWidth',1,'Color','r');
%                     ylim([0 yamp])
                    makepretty_erc
                    
                subplot(242)
                    h1=histogram(freq(1,:),10); hold on
                    h2=histogram(freq(2,:),10); 
                    title('Frequency - session')
                    xline(freq_med(1),'LineWidth',1,'Color','b');
                    xline(freq_med(2),'LineWidth',1,'Color','r');
%                     ylim([0 yfreq])
                    makepretty_erc
                subplot(245)
                    h1=histogram(dur(1,:),100); hold on
                    h2=histogram(dur(2,:),100); 
                    title('Duration - session')
                    xline(dur_med(1),'LineWidth',1,'Color','b');
                    xline(dur_med(2),'LineWidth',1,'Color','r');
%                     ylim([0 ydur])
                    makepretty_erc
                subplot(246)
                    b=bar(den','FaceColor','flat');
                    b.CData(1,:) = [0 0 1];
                    b.CData(2,:) = [1 0 0];
                    b.FaceAlpha = 0.5;
                    title('Density - session')
                    set(gca,'xticklabel',{'pre','post'})
                    ylabel('rip/sec')
                    ylim([0 yden])
                    makepretty_erc
                % first parts    
                subplot(243)
                    h1=histogram(amp_p(1,:)); hold on
                    h2=histogram(amp_p(2,:)); 
                    title('Amplitude - first part')
%                     legend([h1 h2],{'pre','post'})
                    xline(amp_p_med(1),'LineWidth',1,'Color','b');
                    xline(amp_p_med(2),'LineWidth',1,'Color','r');
%                     ylim([0 yamp])
                    makepretty_erc
                subplot(244)
                    h1=histogram(freq_p(1,:),10); hold on
                    h2=histogram(freq_p(2,:),10); 
                    title('Frequency - first part')
                    xline(freq_p_med(1),'LineWidth',1,'Color','b');
                    xline(freq_p_med(2),'LineWidth',1,'Color','r');
%                     ylim([0 yfreq])
                    makepretty_erc
                subplot(247)
                    h1=histogram(dur_p(1,:),100); hold on
                    h2=histogram(dur_p(2,:),100); 
                    title('Duration - first part')
                    xline(dur_p_med(1),'LineWidth',1,'Color','b');
                    xline(dur_p_med(2),'LineWidth',1,'Color','r');
%                     ylim([0 ydur])
                    makepretty_erc
                subplot(248)
                    b=bar(den_p','FaceColor','flat');
                    b.CData(1,:) = [0 0 1];
                    b.CData(2,:) = [1 0 0];
                    b.FaceAlpha = 0.5;
                    title('Density - first part')
                    set(gca,'xticklabel',{'pre','post'})
                    ylabel('rip/sec')
                    ylim([0 yden])
                    makepretty_erc
                    
            annotation('textbox',[.48 .89 .3 .1], ...
                'String',['  M' num2str(mice_num{iexp}(nsuj))],'FontSize',24, ...
                'FitBoxToText','on')
            
            figName = ['RipplesChar_First' num2str(partlen) 'sec_PrevsPost_' ...
                expname{iexp} '_' num2str(numexpe{iexp}(nsuj))  '_M'  num2str(mice_num{iexp}(nsuj))];
                    saveF(figH,figName,[dropbox '/DataSL/Ripples/'],'sformat',{'dpng'},'res',300,'savfig',0)        
                    
                    
                    
            clear RipplesEpoch ripples Sleep SessionEpoch rip amp freq dur rip_p amp_p freq_p dur_p
        end
    end
end


% for iexp=1:3
%     for isess=1:2
%         i=0;
%         for isuj = 1:length(Dir{iexp}.path)
%             for iisuj=1:length(Dir{iexp}.path{isuj})
%                 i=i+1;
%                 zamp = find(ampmin(iexp,i,isess,:)==0);
%                 zfreq = find(freqmin(iexp,i,isess,:)==0);
%                 zdur = find(durmin(iexp,i,isess,:)==0);
%                 try
%                     ampmin(iexp,i,isess,zamp) = nan;
%                 end
%                 try
%                     freqmin(iexp,i,isess,zfreq) = nan;
%                 end
%                 try
%                     durmin(iexp,i,isess,zdur) = nan;
%                 end
%             end
%         end
%     end
% end
% ampmin_mean = squeeze(nanmean(ampmin,2));
% freqmin_mean = squeeze(nanmean(freqmin,2));
% durmin_mean = squeeze(nanmean(durmin,2));
% 
% 
% supertit = ['Dynamic change in ripples (by minute) - PreSleep(blue) vs PostSleep(red)'];
% figH = figure('Color',[1 1 1], 'rend','painters','pos', ...
%     [10 10 2000 900],'Name', supertit, 'NumberTitle','off');
%     %MFB    
%     subplot(3,6,1:2)
%         p1=plot(squeeze(ampmin_mean(1,1,:))); hold on
%         p2=plot(squeeze(ampmin_mean(1,2,:)));
%         title({'MFB','Amplitude'})
%         makepretty_erc
%     subplot(3,6,7:8)
%         p1=plot(squeeze(freqmin_mean(1,1,:))); hold on
%         p2=plot(squeeze(freqmin_mean(1,2,:)));
%         title('Frequency')
%         makepretty_erc
%     subplot(3,6,13:14)
%         p1=plot(squeeze(durmin_mean(1,1,:))); hold on
%         p2=plot(squeeze(durmin_mean(1,2,:)));
%         title('Duration')
%         makepretty_erc
%     % PAG    
%     subplot(3,6,3:4)
%         p1=plot(squeeze(ampmin_mean(2,1,:))); hold on
%         p2=plot(squeeze(ampmin_mean(2,2,:)));
%         title({'PAG','Amplitude'})
%         makepretty_erc
%     subplot(3,6,9:10)
%         p1=plot(squeeze(freqmin_mean(2,1,:))); hold on
%         p2=plot(squeeze(freqmin_mean(2,2,:)));
%         title('Frequency')
%         makepretty_erc
%     subplot(3,6,15:16)
%         p1=plot(squeeze(durmin_mean(2,1,:))); hold on
%         p2=plot(squeeze(durmin_mean(2,2,:)));
%         title('Duration')
%         makepretty_erc
%     % NOVEL   
%     subplot(3,6,5:6)
%         p1=plot(squeeze(ampmin_mean(3,1,:))); hold on
%         p2=plot(squeeze(ampmin_mean(3,2,:)));
%         title({'NOVEL','Amplitude'})
%         legend([p1 p2],{'pre','post'})
%         makepretty_erc
%     subplot(3,6,11:12)
%         p1=plot(squeeze(freqmin_mean(3,1,:))); hold on
%         p2=plot(squeeze(freqmin_mean(3,2,:)));
%         title('Frequency')
%         makepretty_erc
%     subplot(3,6,17:18)
%         p1=plot(squeeze(durmin_mean(3,1,:))); hold on
%         p2=plot(squeeze(durmin_mean(3,2,:)));
%         title('Duration')
%         makepretty_erc


disp('Done.')
disp('-------------------')