Dir.path = '/media/DataMOBsRAIDN/ProjectEmbReact/Mouse508/20170126/ProjectEmbReact_M508_20170126_BaselineSleep';

load('behavResources.mat')
load('HeartBeatInfo.mat')
load('SleepScoring_OBGamma.mat')
try
    load('SleepSubstages.mat');
    allss=1;
catch
    allss=0;
end


Epochs = {SWSEpoch,REMEpoch,Wake};
Epochs_all = {Epoch{1,1},Epoch{1,2},Epoch{1,3},Epoch{1,4},Epoch{1,5}};
SleepStages = CreateSleepStages_tsd(Epochs);
allstages = CreateSleepStages_tsd(Epochs_all);

if allss
    colori = {[0.5 0.3 1], [1 0.5 1], [0.8 0 0.7], [0.1 0.7 0], [0.5 0.2 0.1]}; %substage color
else
    colori = {[0.5 0.3 1], [0.1 0.7 0], [0.5 0.2 0.1]}; %substage color
end
temptime = Range(allstages);
sessend = temptime(end)/1e4/3600;

supertit = ['EKG and Hypnograms'];
figure('Color',[1 1 1], 'rend','painters','pos',[10 10 1500 800],'Name', supertit, 'NumberTitle','off') 
%     subplot(2,2,1:2)
%         plot(smoothdata(Data(EKG.HBRate),1))
%     
%     subplot(2,2,3:4)
%         plot(Range(SleepStages,'s')/3600,Data(SleepStages),'k') 
%         hold on
%         for ep=1:length(Epochs)
%             plot(Range(Restrict(SleepStages,Epochs{ep}),'s')/3600 ,Data(Restrict(SleepStages,Epochs{ep})),'.','Color',colori{ep}), hold on,
%         end
%         xlabel('Time (h)')
%         set(gca,'TickLength',[0 0])
%         ylim([0.5 3.5])
%         ylabel_substage = {'NREM','REM','WAKE'};
%         ytick_substage = [1 2 3]; %ordinate in graph
%         set(gca,'Ytick',ytick_substage,'YTickLabel',ylabel_substage)
    

    hold on    
    yyaxis left
%     plot(Range(SleepStages,'s')/3600,Data(SleepStages),'color',[.7 .7 .7]) 
%         hold on
%         for ep=1:length(Epochs)
%             plot(Range(Restrict(SleepStages,Epochs{ep}),'s')/3600 ,Data(Restrict(SleepStages,Epochs{ep})),'.','Color',colori{ep}), hold on,
%         end
    
        addaxis(Range(allstages,'s')/3600,Data(allstages))%,'color',[.7 .7 .7]) 
        hold on
        for ep=1:length(Epochs_all)
            plot(Range(Restrict(allstages,Epochs_all{ep}),'s')/3600 ,Data(Restrict(allstages,Epochs_all{ep})),'.','Color',colori{ep}), hold on,
        end
        xlabel('Time (h)')
        set(gca,'TickLength',[0 0])
        if allss
            ylim([0.5 5.5])
            ylabel_substage = {'N1','N2','N3','REM','WAKE'};
            ytick_substage = [1 2 3 4 5]; %ordinate in graph
        else 
            ylim([0.5 3.5])
            ylabel_substage = {'NREM','REM','WAKE'};
            ytick_substage = [1 2 3]; %ordinate in graph
        end
        
        set(gca,'Ytick',ytick_substage,'YTickLabel',ylabel_substage)


yyaxis right
    addaxis(Range(EKG.HBRate,'s')/3600,runmean(Data(EKG.HBRate),3))
    hold on
    addaxis(Range(EKG.HBRate,'s')/3600,movstd(Data(EKG.HBRate),10))
        xlim([0 sessend])
    
hold off
