%==========================================================================
% Details: Output behavioral data from the ExploExp experiment.
%
% INPUTS:
%       - None
%
% OUTPUT:
%       - figure including:
%           - Trajectories
%           - Heatmaps
%
% NOTES:
%
%   Written by Samuel Laventure - 26-11-2018
%==========================================================================

clear all

%#####################################################################
%#
%#                   P A R A M E T E R S
%#
%#####################################################################

% ---------- HARDCODED -----------
% bootsrapping options
    bts=1;      %bootstrap: 1 = yes; 0 = no
    draws=50;   %nbr of draws for the bts
    rnd=0;      %test against a random sampling of pre-post maps

% stats correction 
    alpha=.001; % p-value seeked for significance
        % only one must be chosen
        %----------
        fdr_corr=0;
        bonfholm=0;
        bonf=1;
        %----------
    corr = {'uncorr','fdr','bonfholm','bonf'};

%----------- SAVING PARAMETERS ----------
% Outputs
    dirout = '/home/mobs/Dropbox/MOBS_workingON/Sam/ExploExp/';
    if ~exist(dirout, 'dir')
        mkdir(dirout);
    end    sav=1;      % Do you want to save a figure? Y=1; N=0

%     %-- Current folder
%     [parentFolder deepestFolder] = fileparts(pwd);
% 
%     %-- Folder with data
%     dataPath = [parentFolder '/eeglab_files/' datype '/'];

indir = {'/media/mobs/DataMOBS85/ExploExp/ERC-Mouse-754-21112018-Hab_00/', ...
    '/media/mobs/DataMOBS85/ExploExp/ERC-Mouse-754-22112018-Hab_02/', ...
    '/media/mobs/DataMOBS85/ExploExp/ERC-Mouse-754-22112018-Hab_03/', ... 
    '/media/mobs/DataMOBS85/ExploExp/ERC-Mouse-754-23112018-Hab_00/', ... 
    '/media/mobs/DataMOBS85/ExploExp/ERC-Mouse-754-23112018-Hab_01/', ...
    '/media/mobs/DataMOBS85/ExploExp/ERC-Mouse-754-23112018-Hab_02/';
    '/media/mobs/DataMOBS85/ExploExp/ERC-Mouse-818-21112018-Hab_00/', ...
    '/media/mobs/DataMOBS85/ExploExp/ERC-Mouse-818-22112018-Hab_00/', ...
    '/media/mobs/DataMOBS85/ExploExp/ERC-Mouse-818-22112018-Hab_01/', ...
    '/media/mobs/DataMOBS85/ExploExp/ERC-Mouse-818-23112018-Hab_00/', ...
    '/media/mobs/DataMOBS85/ExploExp/ERC-Mouse-818-23112018-Hab_01/', ...
    '/media/mobs/DataMOBS85/ExploExp/ERC-Mouse-818-23112018-Hab_02/';
    '/media/mobs/DataMOBS85/ExploExp/ERC-Mouse-821-21112018-Hab_00/', ...
    '/media/mobs/DataMOBS85/ExploExp/ERC-Mouse-821-22112018-Hab_00/', ...
    '/media/mobs/DataMOBS85/ExploExp/ERC-Mouse-821-22112018-Hab_01/', ...
    '/media/mobs/DataMOBS85/ExploExp/ERC-Mouse-821-23112018-Hab_00/', ...
    '/media/mobs/DataMOBS85/ExploExp/ERC-Mouse-821-23112018-Hab_01/', ...
    '/media/mobs/DataMOBS85/ExploExp/ERC-Mouse-821-23112018-Hab_02/'
        };


% Directories details
umaze = [1 1 1 1 1 1;
         1 1 1 1 1 1;
         1 1 1 1 1 1];

nmice = 3; % Nbr of mouse
ntest = 1; % Nbr of trials per test
nsess = 6; % Nbr of sesion

%-------------- MAP PARAMETERS -----------
freqVideo=15;       %frame rate
smo=1.5;            %smoothing factor
sizeMap=50;         %Map size

%------------- FIGURE PARAMETERS -------------
clrs = {'ko', 'bo', 'ro','go'; 'k','b', 'r', 'g'; 'kp', 'bp', 'rp', 'gp'};


%#####################################################################
%#
%#                           M A I N
%#
%#####################################################################
% Get trajectories

for imice=1:nmice
    for isess=1:nsess 
         dat{imice,isess} = load([indir{imice,isess} 'behavResources.mat'], 'Xtsd', 'Ytsd', 'Zone','PosMat', 'Ratio_IMAonREAL');
    end % loop nb sess (6)
end % loop nb mice