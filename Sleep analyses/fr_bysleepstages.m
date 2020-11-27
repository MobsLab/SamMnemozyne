function ssfr = fr_bysleepstages(Dir,clunb,epoch,showfig)

%==========================================================================
% Details: get firing rates per sleep stages
%
% INPUTS:
%       - Dir: directory where spiking info is located
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

% Parameters
% load working variables
load([Dir 'SpikeData.mat']);  % need to create this file from digIn3

%set folders
[parentdir,~,~]=fileparts(pwd);
pathOut = [pwd '/Figures/'];
if ~exist(pathOut,'dir')
    mkdir(pathOut);
end

for i=1:length(epoch)
    ssfr(i) = length(Restrict(S{clunb},epoch{i}))/sum(End(epoch{i},'s')-Start(epoch{i},'s'));
end

if showfig
    ss_real = {'NREM','REM','WAKE'};
    % stages %
    s = length(Start(epoch{1})); 
    r = length(Start(epoch{2}));
    w = length(Start(epoch{3}));
    all = w+s+r;
    wp = w/all*100;
    sp = s/all*100;
    rp = r/all*100;

    % figures
    f = figure2(1,'Position', [0 0 1000 400]);
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

%         %save figure
%         print([pathOut 'FR-by-sleepstage'], '-dpng', '-r300');
%         close(f);
% 
%     %save data
%     save('FR_sleepstage','ss','ssfr');
end