%% DESCRIPTION
%
%   This is only a wrapper to output .mat and figures 
%   following cumulSleepScoring_rem.m script
%
%   Written by SL 2021-12

% saving
save([dropbox '/DataSL/SleepScoring/Cumulative/REM_precentage_reached.mat'],'level','level_slp','stgperc','onset')

%% GROUPS AND MICE #
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
mice_num{3} = [1016 1081 1083 1116 1161 1182 1183 1185 1223 1228 1230];
numexpe{3} = [1 1 1 1 1 1 1 1 1 1 1];

%%  CREATE ANALYSIS VARIABLES
clear sleeponset_pre 
for iexp=1:3
    sleeponset_pre(1:size(onset.sleep,2),iexp)=squeeze(onset.sleep(iexp,:,1))';
    sleeponset_post(1:size(onset.sleep,2),iexp)=squeeze(onset.sleep(iexp,:,2))';
    remonset_slp_pre(1:size(onset.sleep,2),iexp)=squeeze(onset.remsleep(iexp,:,1))';
    remonset_slp_post(1:size(onset.sleep,2),iexp)=squeeze(onset.remsleep(iexp,:,2))';
    remonset_sess_pre(1:size(onset.sleep,2),iexp)=squeeze(onset.remsess(iexp,:,1))';
    remonset_sess_post(1:size(onset.sleep,2),iexp)=squeeze(onset.remsess(iexp,:,2))';
end


for i=1:3 
    for j=1:2 
        for k=1:10
            remReach(i,j,k) = nanmean(level(i,:,j,k));
            numok(i,j,k) = sum(~isnan(level(i,:,j,k)));
            
        end
    end
end

expename = {'MFB','PAG','NOVEL'};
%% FIGURE TIME TO REACH %
figure,
for i=1:3
    subplot(3,2,i*2-1)
        bar(squeeze(squeeze(remReach(i,1,:))))
        text(1:10,ones(1,10)*300,num2str(squeeze(numok(i,1,:))), ...
            'vert','bottom','horiz','center','FontSize',14); 
        box off
        title([expename{i} ' - PreTests'])
        if i==3
            xlabel('REM %')
        elseif i == 2
            ylabel('time to reach REM% in sec.')
        end
        ylim([0 9000])
        makepretty_erc
        
    subplot(3,2,i*2)
        bar(squeeze(squeeze(remReach(i,2,:))))
        text(1:10,ones(1,10)*300,num2str(squeeze(numok(i,2,:))), ...
            'vert','bottom','horiz','center','FontSize',14); 
        box off
        title([expename{i} ' - PostTests'])
        if i==3
            xlabel('REM %')
        end
        ylim([0 9000])
        makepretty_erc
end
% with points
figure,
for i=1:3
    subplot(3,2,i*2-1)
        [p,h, her] = PlotErrorBarN_SL(squeeze(squeeze(level(i,:,1,:))),...
                'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, ...
                'colorpoints',0,'showpoints',1,'showsigstar','none');
%             set(gca,'Xtick',[2:4:7],'XtickLabel',{'Stim zone', 'Rest of U-Maze'});
            set(gca, 'FontSize', 14);
%             h.FaceColor = 'flat';
%             h.CData(1:4:7,:) = repmat([.3 .3 .3],2,1);
%             h.CData(2:4:7,:) = repmat([0 0 0],2,1);
%             h.CData(3:4:7,:) = repmat([1 1 1],2,1);
            set(h, 'LineWidth', 2);
            set(her, 'LineWidth', 2);
            title([expename{i} ' - PreTests'])
            if i==3
                xlabel('REM %')
            elseif i == 2
                ylabel('time to reach REM% in sec.')
            end
            ylim([0 9000])
            makepretty_erc
           
    subplot(3,2,i*2)
        [p,h, her] = PlotErrorBarN_SL(squeeze(squeeze(level(i,:,2,:))),...
                'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, ...
                'colorpoints',0,'showpoints',1,'showsigstar','none');
%             set(gca,'Xtick',[2:4:7],'XtickLabel',{'Stim zone', 'Rest of U-Maze'});
            set(gca, 'FontSize', 14);
%             h.FaceColor = 'flat';
%             h.CData(1:4:7,:) = repmat([.3 .3 .3],2,1);
%             h.CData(2:4:7,:) = repmat([0 0 0],2,1);
%             h.CData(3:4:7,:) = repmat([1 1 1],2,1);
            set(h, 'LineWidth', 2);
            set(her, 'LineWidth', 2);
        title([expename{i} ' - PostTests'])
        if i==3
            xlabel('REM %')
        end
        ylim([0 9000])
        makepretty_erc
end

%% FIGURE MEAN CURVE

tim = 9*60*6;
curvs=nan(3,2,19,tim);

for i=1:3
    for j=1:2
        for k=1:length(mice_num{i})
            nanid = ~isnan(stgperc{i,k,j}(2,:));
            curvid = find(nanid==1);
            curvs(i,j,k,1:length(curvid)) = stgperc{i,k,j}(2,curvid);
        end
    end
end
for i=1:3
    for j=1:2
        for x=1:tim
            curvmean(i,j,x) = nanmean(curvs(i,j,:,x));
            curvstd(i,j,x) = nanstd(curvs(i,j,:,x));
        end
    end
end

supertit = ['Cumulative % of REM across session'];
figure('Color',[1 1 1], 'rend','painters','pos',[10 10 1400 700],'Name', supertit, 'NumberTitle','off')  
    for i=1:3
        subplot(3,2,i*2-1)
            shadedErrorBar([],squeeze(curvmean(i,1,:)),squeeze(curvstd(i,1,:)),'-r',1);
            if i==1
                title({'PRE-SLEEP',expename{i}})   
            else
                title({expename{i}})   
            end
            if i==2
                ylabel('Cumul. Perc(%) of REM')   
            elseif i==3
                xlabel('Time (sec)')
            end
            ylim([0 20])
            xlim([1 720])
            xticks([100:100:720]);
            xticklabels({[1000:1000:7200]})
            yline(5,'--k')
            makepretty_erc
            
        subplot(3,2,i*2)
            shadedErrorBar([],squeeze(curvmean(i,2,:)),squeeze(curvstd(i,2,:)),'-r',1);
            if i==1
                title({'POST-SLEEP',expename{i}})   
            else
                title({expename{i}})   
            end
            if i==3
                xlabel('Time (sec)')
            end
            ylim([0 20])  
            xlim([1 720])
            xticks([100:100:720]);
            xticklabels({[1000:1000:7200]})
            yline(5,'--k')
            makepretty_erc 
    end

