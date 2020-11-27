function sam_fr_sleepstages(clunb)

%==========================================================================
% Details: get firing rates per sleep stages
%
% INPUTS:
%       - clunb: targeted cluster #
%
% OUTPUT:
%       - figures including:
%           - firing rate per sleep stages
%
% NOTES: needs SleepSubstages.mat and SpikeData.mat
%       
%       see: GetFiringrate.m
%
%
%   Written by Samuel Laventure - 08-07-2019
%      
%==========================================================================


% load working variables
load('SleepSubstages.mat');
load('SpikeData.mat');  % need to create this file from digIn3
load('SleepScoring_OBGamma.mat','Wake','SWSEpoch','REMEpoch');


%set folders
[parentdir,~,~]=fileparts(pwd);
pathOut = [pwd '/Figures/'];
if ~exist(pathOut,'dir')
    mkdir(pathOut);
end

ss = {'SWS','REM','WAKE'};
ss_real = {'NREM','REM','WAKE'};

ssl = length(ss);
for iss=1:ssl
    sst = find(strcmp(NameEpoch,ss{iss}));
    ssfr(iss) = GetFiringRate(S(clunb),'epoch',Epoch{sst});
end

% stages %
w = length(Start(Wake)); 
s = length(Start(SWSEpoch));
r = length(Start(REMEpoch));
all = w+s+r;
wp = w/all*100;
sp = s/all*100;
rp = r/all*100;

% figures
f = figure('Position', [0 0 1000 400]);
    subplot(1,2,1)
    bar([sp rp wp],'k')
    ylabel('Proportion (%)')
    xlabel('Sleep stages')
    title('Sleep stages proportion')
    xticklabels(ss_real)
    
    subplot(1,2,2)
    bar(ssfr,'k')
    ylabel('Firing rate (Hz)')
    xlabel('Sleep stages')
    title('Firing rate by sleep stages')
    xticklabels(ss_real)
    
%     % script name at bottom
%     AddScriptName
    
    %save figure
    print([pathOut 'FR-by-sleepstage'], '-dpng', '-r300');
%     close(f);
    
%save data
save('FR_sleepstage','ss','ssfr');