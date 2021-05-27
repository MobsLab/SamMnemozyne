clear all
ac = load('SleepScoring_Accelero.mat','sleep_array');
ob = load('SleepScoring_OBGamma.mat','sleep_array');

confmatac = zeros(3,3);
for i=1:length(ac.sleep_array)
    if ~isnan(ac.sleep_array(i)) && ~isnan(ob.sleep_array(i))
        confmatac(ac.sleep_array(i),ob.sleep_array(i)) = confmatac(ac.sleep_array(i),ob.sleep_array(i)) + 1;
    end
end
confmatob = zeros(3,3);
for i=1:length(ob.sleep_array)
    if ~isnan(ob.sleep_array(i)) && ~isnan(ac.sleep_array(i))
        confmatob(ob.sleep_array(i),ac.sleep_array(i)) = confmatob(ob.sleep_array(i),ac.sleep_array(i)) + 1;
    end
end

%calculate totals
vertsumac = sum(confmatac);
horsumac  = sum(confmatac');

vertsumob = sum(confmatob);
horsumob  = sum(confmatob');

confmat_perc_ac = round(confmatac./length(ac.sleep_array)*100,1);
% confmat_perc_ac = round(confmat./horsum*100,1);
confmat_perc_ob = round(confmatob./length(ob.sleep_array)*100,1);
% confmat_perc_ob = round(confmat./horsum*100,1);

% sleep scoring percentages
for i=1:3
    co(i,1) = length(find(ac.sleep_array==i));
    co(i,2) = length(find(ob.sleep_array==i));
end
ymax = max(max([co./sum(co)*100 co./sum(co)*100]))*1.2;

%% figure
supertit = 'Comparisons of sleep scoring methods (Accelero VS OB Gamma)';
figH = figure('Color',[1 1 1], 'rend','painters','pos',[1 1 900 600],'Name', supertit, 'NumberTitle','off');
    subplot(3,4,[5:6 9:10])
        b=bar(co./sum(co)*100);
        b(1,1).FaceColor = 'flat';
        b(1,2).FaceColor = 'flat';
        b(1,1).CData(1,:) = [0 0 0];b(1,2).CData(1,:) = [1 1 1];
        b(1,1).CData(2,:) = [0 0 0];b(1,2).CData(2,:) = [1 1 1];
        b(1,1).CData(3,:) = [0 0 0];b(1,2).CData(3,:) = [1 1 1];
        title('Scoring architecture')
        set(gca, 'XTickLabel', {'NREM','REM','Wake'},'FontSize',8)
        xtickangle(45)
        ylim([0 ymax])
        ylabel('%')
        legend({'Accelero','OBGamma'})
    subplot(3,4,3)
        b=bar(confmatac(1,:)/horsumac(1)*100);
        b.FaceColor = 'flat';
        b.CData(1,:) = [0 0 1];
        b.CData(2,:) = [0 1 0]; 
        b.CData(3,:) = [1 0 0];
        title('Acc NREM -> OB...')
        set(gca, 'XTickLabel', {'NREM','REM','Wake'},'FontSize',8)
        xtickangle(45)
        ylabel('%')
    subplot(3,4,7)
        b=bar((confmatac(2,:)/horsumac(2)*100)');
        b.FaceColor = 'flat';
        b.CData(1,:) = [0 0 1];
        b.CData(2,:) = [0 1 0]; 
        b.CData(3,:) = [1 0 0];
        title('Acc REM -> OB...')
        set(gca, 'XTickLabel', {'NREM','REM','Wake'},'FontSize',8)
        xtickangle(45)
        ylabel('%')
    subplot(3,4,11)
        b=bar(confmatac(3,:)/horsumac(3)*100);
        b.FaceColor = 'flat';
        b.CData(1,:) = [0 0 1];
        b.CData(2,:) = [0 1 0]; 
        b.CData(3,:) = [1 0 0];
        title('Acc Wake -> OB...')
        set(gca, 'XTickLabel', {'NREM','REM','Wake'},'FontSize',8)
        xtickangle(45)
        ylabel('%')
    subplot(3,4,4)
        b=bar(confmatob(1,:)/vertsumob(1)*100);
        b.FaceColor = 'flat';
        b.CData(1,:) = [0 0 1];
        b.CData(2,:) = [0 1 0]; 
        b.CData(3,:) = [1 0 0];
        title('Ob NREM -> OB...')
        set(gca, 'XTickLabel', {'NREM','REM','Wake'},'FontSize',8)
        xtickangle(45)
        ylabel('%')
    subplot(3,4,8)
        b=bar(confmatob(2,:)/vertsumob(2)*100);
        b.FaceColor = 'flat';
        b.CData(1,:) = [0 0 1];
        b.CData(2,:) = [0 1 0]; 
        b.CData(3,:) = [1 0 0];
        title('Ob REM -> OB...')
        set(gca, 'XTickLabel', {'NREM','REM','Wake'},'FontSize',8)
        xtickangle(45)
        ylabel('%')
    subplot(3,4,12)
        b=bar(confmatob(3,:)/vertsumob(3)*100);
        b.FaceColor = 'flat';
        b.CData(1,:) = [0 0 1];
        b.CData(2,:) = [0 1 0]; 
        b.CData(3,:) = [1 0 0];
        title('Ob Wake -> OB...')
        set(gca, 'XTickLabel', {'NREM','REM','Wake'},'FontSize',8)
        xtickangle(45)
        ylabel('%')
        
        T = table(confmat_perc_ac,'RowNames',{'acNREM','acREM','acWake'});
        t = uitable('Data',T{:,:},'ColumnName',{'obNREM','obREM','obWake'},...
        'RowName',T.Properties.RowNames,'Units', 'Normalized', 'Position',[0, 0, 1, 1]);    
    
    subplot(3,4,1:2)
        % -------------------
        % create fake plot to get position and insert table
        plot(3)
        pos = get(subplot(3,4,1:2),'position');
    %     pos = get(gca,'position')
        delete(subplot(3,4,1:2))
        % -------------------
        set(t,'units','normalized')
        set(t,'position',pos)
