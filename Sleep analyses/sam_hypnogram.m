function sam_hypnogram()

%==========================================================================
% Details: make hypnogram with stimulations
%
% INPUTS:
%       - 
%
% OUTPUT:
%       - figures including:
%           - hypnogram with stims
%
% NOTES: needs Idfiguredata.mat
%       
%       see: sleep_details.m, FindNREMfeatures, SubstagesScoring, MakeIDSleepData,PlotIDSleepData
%
%
%   Written by Samuel Laventure - 30-06-2019
%      
%==========================================================================



clear all
% load working variables
load('IdFigureData.mat');
load('StimSent.mat');  % need to create this file from digIn3


%set folders
[parentdir,~,~]=fileparts(pwd);
pathOut = [pwd '/Figures/'];
if ~exist(pathOut,'dir')
    mkdir(pathOut);
end

figure('Color',[1 1 1],'units','normalized', 'position', [0 0 .8 .3]); %'outerposition',[0 0 1 1]);
    
    ylabel_substage = {'N3','N2','N1','REM','WAKE'};
    ytick_substage = [1 1.5 2 3 4]; %ordinate in graph
    colori = {[0.5 0.3 1], [1 0.5 1], [0.8 0 0.7], [0.1 0.7 0], [0.5 0.2 0.1]}; %substage color
    plot(Range(SleepStages,'s')/3600,Data(SleepStages),'k'), hold on,
    for ep=1:length(Epochs)
        plot(Range(Restrict(SleepStages,Epochs{ep}),'s')/3600 ,Data(Restrict(SleepStages,Epochs{ep})),'.','Color',colori{ep}), hold on,
    end
    % stim markers
    plot(Start(StimSent)/1e4/3600,3,'r*')
 
    xlim([0 max(Range(SleepStages,'s')/3600)]) 
    ylim([0.5 5])
    set(gca,'Ytick',ytick_substage,'YTickLabel',ylabel_substage)
    hold on,
    
    title('Hypnogram'); xlabel('Time (h)')
    
    %annotation
    dim = [.8 .6 .3 .3];
    str = sprintf('Stimulations: *');
    annotation('textbox',dim,'String',str,'Color','red','FitBoxToText','on');
    
    print([pathOut 'Hypnogram_stims'], '-dpng', '-r300');
    
    close all
 