function rip_allsites(Dir)
%==========================================================================
% Details: Detect and output ripples (figure and .mat file) of all sites on all spike groups
%
% INPUTS:
%       - Dir: working directory
%
% OUTPUT:
%
% NOTES:
%
%   Written by Samuel Laventure - 16-07-2020
%      
%==========================================================================
%% Set Directories and variables
try
   Dir;
catch
   Dir =  [pwd '/'];
end

dir_out = [pwd '/ripples/'];
if ~exist(dir_out,'dir')
    mkdir(dir_out);
end

%#####################################################################
%#
%#                           M A I N
%#
%#####################################################################
% set shank site order
shk{1} = [5 19 16 17 9 6 20 21 18 10 7 25 22 23 11];
shk{2} = [45 46 47 55 56 42 43 44 52 57 39 40 41 53];	
shk{3} = [37 38 50 61 60 34 35 48 51 62 63 33 30 32];	
shk{4} = [26 27 24 12 3 2 28 29 14 13 0 1 31 15 49];

%set site with good ripples
ripchan = load('ChannelsToAnalyse/dHPC_rip.mat');

% load directory and variables
cd(Dir);
load('ExpeInfo.mat');
sgr = ExpeInfo.SpikeGroupInfo.ChanNames;
sgr_nb = length(sgr);

%% detect ripples
for isgr=1:sgr_nb
    nsgr = str2num(sgr{isgr});
    for isite=1:length(nsgr)
        rip_chan = nsgr(isite);
        nonrip_chan = load('ChannelsToAnalyse/Bulb_sup.mat');
        [ripples{isgr,isite},stdev{isgr,isite}] = FindRipples_sites (rip_chan, isgr, isite, nonrip_chan.channel,...
            [2 7],'rmvnoise',0, 'clean',1); % [2 7],'rmvnoise',1, 'clean',1);
    end
end
disp('Completed');
end