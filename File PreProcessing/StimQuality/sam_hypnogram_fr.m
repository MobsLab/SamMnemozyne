

clear all

% Parameters
Dir = '/media/mobs/DataMOBS94/M0936/SleepStimTest/test4_04-07-2019/4-sleepstimrem2/';

% var init
numclust = 3; %targeted cluster
nbclust = 4; %total nbr of clusters on this tetrode
sessiondur = 3600; %session duration in sec

% load working variables
load('DetectionTSD.mat');
load('SpikeData.mat');
load([Dir 'Waveforms/Waveforms' cellnames{numclust} '.mat']);
load('SleepSubstages.mat');
load('StimSent.mat');  % need to create this file from digIn3

% Directories
dir_out = [pwd '/Figures/'];
if ~exist(dir_out,'dir')
    mkdir(dir_out);
end

% Do
StimSent = thresholdIntervals(DetectionTSD,0.001,'Direction','Above');

%% FIGURES

colori = {[0.5 0.3 1], [1 0.5 1], [0.8 0 0.7], [0.1 0.7 0], [0.5 0.2 0.1]}; %substage color
binSize=15E4;

f = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
    
    %Fire Rate
    Q=MakeQfromS(S,binSize);
    Qs=full(Data(Q));
    Qtsd=tsd(Range(Q),Qs(:,numclust));

    stim=tsdArray(tsd(Start(StimSent),Start(StimSent)));
    Qstim=MakeQfromS(stim,binSize);
    Qs2=full(Data(Qstim));
    Qstimtsd=tsd(Range(Qstim),Qs2(:,1));

    [X,lag]=xcorr(Data(Qtsd),Data(Qstimtsd),100);

    [C,B]=CrossCorr(Range(S{numclust}),Start(StimSent),1,100);
    
    plot(Range(Qtsd,'s'),Data(Qtsd))
    ar1 = area(Range(Qtsd,'s'),Data(Qtsd), 'EdgeColor', 'none', 'FaceColor', [.7 .7 .7]);
    hold on 
    plot(Range(Qstimtsd,'s'),Data(Qstimtsd))
    ar2 = area(Range(Qstimtsd,'s'),Data(Qstimtsd), 'EdgeColor', 'none', 'FaceColor', [0 0 0]);
    
    lgd = legend([ar1 ar2], {'All Spikes','Detected Spikes'},'FontSize',10);
    lgd = legend('Location','northwest');
          
    
    hold on   
    ylabel('Count')
    
    ylim([-40 125])
    set(gca,'xtick',[])
    set(gca,'box','off','color','none')
    xticklabels('')
    xlim([0 sessiondur])
    set(gca,'FontWeight','bold','FontSize',14,'LineWidth',3);
    
    % Hypnogram
    hAx(1)=gca;
    ylabel_substage = {'Wake','REM','NREM','SI'};
    ytick_substage = [-3.6 -2.9 -1.5 -.1]; %ordinate in graph
    
    hAx(2)=axes('Position',hAx(1).Position,'YAxisLocation','right','color','none');
    hold(hAx(2),'on')
    ylim([-5 20])
    SleepStages=PlotSleepStage(Epoch{5},Epoch{7},Epoch{4},0,[-.8 -.7]);

    xlim([0 sessiondur])
    set(hAx(2),'Ytick',ytick_substage,'YTickLabel',ylabel_substage)
    hold on

    set(gca,'FontWeight','bold','FontSize',14,'LineWidth',3);
    xlabel('Time (s)')
    title('Fire rate and sleep stages across session')


saveas(f, [dir_out 'Hypnogram_FR.fig']);
saveFigure(f,'Hypnogram_FR',dir_out);