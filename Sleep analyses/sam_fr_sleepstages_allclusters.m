function sam_fr_sleepstages_allclusters(clunb,pc,npc,varargin)

%==========================================================================
% Details: get firing rates per sleep stages
%
% INPUTS:
%       - clunb: targeted cluster #
%       - pc: vector with PC # (ex: [2,3,6,7,8,14]
%       - npc: vector with nonPC # (ex: [2,3,6,7,8,14]
%
% OPTIONAL inputs:
%       - dropbox_save: specify location where to save the data
%         in /home/mobs/Dropbox/MOBS_workingON/
%
% OUTPUT:
%       - figures including:
%           - Firing Rate (FR) per sleep stages for each cluster
%           - FR per sleep stages with ss proportions
%           - FR for PC only
%           - FR for nPC only
%
% NOTES: needs SleepScoring_OBGamma.mat and SpikeData.mat
%            
%
%           - For M0936 [6 7 8 9 10 11],[2 3 4 5 12 13 14 15]
%
%
%       see: GetFiringrate.m
%
%
%   Written by Samuel Laventure - 08-07-2019
%      
%==========================================================================


% load working variables
load('SpikeData.mat');  % need to create this file from makeData_Spikes.m
load('SleepScoring_OBGamma.mat','Wake','SWSEpoch','REMEpoch','Sleep');

%set folders
[parentdir,~,~]=fileparts(pwd);
pathOut = [pwd '/Figures/'];
if ~exist(pathOut,'dir')
    mkdir(pathOut);
end

%% init var

ss_real = {'NREM','REM','SLEEP','WAKE'};

nclus = length(cellnames);
vclus = nan(nclus,1);
vclus(pc) = 1;
vclus(npc) = 0;
vclus(1,:)=[];

dbox=0;

% Parse parameter list
for i = 1:2:length(varargin)
    if ~ischar(varargin{i})
        error(['Parameter ' num2str(i+2) ' is not a property.']);
    end
    switch(lower(varargin{i}))
        case 'dropbox_save'
            dropbox_save = varargin{i+1};
            if ~ischar(dropbox_save)
                error('dropbox_save should be string (name of folder where to save data)');
            else
                dbox=1;
                pathDBox = ['/home/mobs/Dropbox/MOBS_workingON/' dropbox_save];
                if ~exist(pathDBox,'dir')
                    mkdir(pathDBox);
                end
            end

        otherwise
            error(['Unknown property ''' num2str(varargin{i}) '''.']);
    end
end


%% MAIN

for iclu=2:nclus
    ssfr(iclu-1,1) = length(Restrict(S{iclu},SWSEpoch))/sum(End(SWSEpoch)-Start(SWSEpoch))*1e4;
    ssfr(iclu-1,2) = length(Restrict(S{iclu},REMEpoch))/sum(End(REMEpoch)-Start(REMEpoch))*1e4;
    ssfr(iclu-1,3) = length(Restrict(S{iclu},Sleep))/sum(End(Sleep)-Start(Sleep))*1e4;
    ssfr(iclu-1,4) = length(Restrict(S{iclu},Wake))/sum(End(Wake)-Start(Wake))*1e4;
    for iss=1:4
        if ssfr(iclu-1,iss)==inf
            ssfr(iclu-1,iss)=0;
        end 
    end
end


% calculates pc vs npc 


% stages %
w = length(Start(Wake)); 
s = length(Start(SWSEpoch));
r = length(Start(REMEpoch));
all = w+s+r;
wp = w/all*100;
sp = s/all*100;
rp = r/all*100;

% calculates fr by stages for pc and non-pc 
ssfr_pc = ssfr(vclus==1,1:4);
ssfr_pc_mean = mean(ssfr(vclus==1,1:4));
ssfr_pc_stdv = std(ssfr(vclus==1,1:4)) / sqrt(length(pc));
ssfr_npc = ssfr(vclus==0,1:4);
ssfr_npc_mean = mean(ssfr(vclus==0,1:4));
ssfr_npc_stdv = std(ssfr(vclus==0,1:4)) / sqrt(length(npc));

%% FIGURES

% Sleep Stages proportion and FR
f1 = figure('Position', [0 0 1000 400]);
    subplot(1,2,1)
    bar([sp rp wp],'k')
    ylabel('Proportion (%)')
    xlabel('Sleep stages')
    title('Sleep stages proportion')
    xticklabels({'NREM','REM','WAKE'})
    
    subplot(1,2,2)
    bar(ssfr(clunb-1,:),'k')
    ylabel('Firing rate (Hz)')
    xlabel('Sleep stages')
    title('Firing rate of targeted cluster')
    xticklabels(ss_real)
    
    %save figure
    print([pathOut 'FR_SleepStagesProp'], '-dpng', '-r300');
    if dbox
        print([pathDBox 'FR_SleepStagesProp'], '-dpng', '-r300');
    end
close(f1)

% all clusters firing rate
f2 = figure('Position', [0 0 1000 400]);
    bar(ssfr')
    ylabel('Firing rate (Hz)')
    xlabel('Clusters')
    title('Firing rate by sleep stages')
    xticklabels(ss_real)
    for ilgd=2:nclus
        strclu{ilgd}=num2str(ilgd);
    end
    lgd = legend(strclu{2:16},'Location', 'eastoutside');
    title(lgd,'Cluster #')
    
    % note the targeted cluster
    dim = [0.45 0.6 0.2 0.3];
    str = ['Targeted Cluster: ' num2str(clunb)];
    annotation('textbox',dim,'String',str,'FitBoxToText','on');
    
    %save figure
    print([pathOut 'FRbySleepStages'], '-dpng', '-r300');
    if dbox
        print([pathDBox 'FRbySleepStages'], '-dpng', '-r300');
    end
close(f2)
    
% PC firing rate
f3 = figure('Position', [0 0 1000 400]);
    boxplot(ssfr_pc,'Notch','off','Labels',{'NREM','REM','Sleep','Wake'},'Whisker',1);
    ylabel('Firing rate (Hz)')
    xlabel('Stages')
    title('Place cells firing rate by sleep stages')
    a = get(get(gca,'children'),'children');
    set(a, 'Color', 'k') 
    

    ylim([0 max(max(ssfr_pc))+.5])
    hold on
    xCenter = 1:size(ssfr_pc,2); 
    spread = 0; % 0=no spread; 0.5=random spread within box bounds (can be any value)
    for i = 1:size(ssfr_pc,2)
        f1 = scatter(rand(size(ssfr_pc(:,i)))*spread -(spread/2) + xCenter(i), ssfr_pc(:,i), 'k','filled');
        f1.MarkerFaceAlpha = 0.5;
        hold on
    end
    
    %save figure
    print([pathOut 'PC_FRbySleepStages'], '-dpng', '-r300');
    if dbox
        print([pathDBox 'PC_FRbySleepStages'], '-dpng', '-r300');
    end
close(f3)
    
    
% nPC firing rate
f4 = figure('Position', [0 0 1000 400]);
    boxplot(ssfr_npc,'Notch','off','Labels',{'NREM','REM','Sleep','Wake'},'Whisker',1);
    ylabel('Firing rate (Hz)')
    xlabel('Stages')
    title('Non-place cells firing rate by sleep stages')
    a = get(get(gca,'children'),'children');
    set(a, 'Color', 'k') 
    
    hold on
    xCenter = 1:size(ssfr_npc,2); 
    spread = 0; % 0=no spread; 0.5=random spread within box bounds (can be any value)
    for i = 1:size(ssfr_npc,2)
        f1 = scatter(rand(size(ssfr_npc(:,i)))*spread -(spread/2) + xCenter(i), ssfr_npc(:,i), 'k','filled');
        f1.MarkerFaceAlpha = 0.5;
        hold on
    end
    
    %save figure
    print([pathOut 'nPC_FRbySleepStages'], '-dpng', '-r300');
    if dbox
        print([pathDBox 'nPC_FRbySleepStages'], '-dpng', '-r300');
    end
 close(f4)   
 
 
disp('Done');