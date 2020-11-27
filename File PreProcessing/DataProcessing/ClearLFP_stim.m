
function ClearLFP_stim()
%==========================================================================
% Details: take out (replace by NaN) stim data from LFP in the LFPData
% folder. Makes a copy of all the original files into LFP_bachup folder.
%
% INPUTS:
%       - 
%
% OUTPUT:
%
% NOTES:
%
%   Written by Samuel Laventure - 24-11-2020
%      
%==========================================================================

tic
load('behavResources.mat','StimEpoch')
st = Start(StimEpoch);
en = End(StimEpoch);

cd([pwd '/LFPData/'])
%create backup folder
buPath = [pwd '/LFP_backup/'];
mkdir(buPath);

% load info lfp
load('InfoLFP.mat');


for ilfp=1:length(InfoLFP.channel)
    disp(['...Processing LFP ' num2str(ilfp-1)]);
    % create backup
    copyfile([pwd '/LFP' num2str(ilfp-1) '.mat'], buPath);
    % load lfp
    load([pwd '/LFP' num2str(InfoLFP.channel(ilfp)) '.mat']);
    dat =  Data(LFP);
    time = Range(LFP);
    %get stim position in lfp
    for istim=1:length(st)
        st_id = find(time>st(istim),1,'first');
        en_id = find(time<st(istim)+1001,1,'last');
        dat(st_id:en_id) = NaN;
    end
    % create new LFP tsd
    LFP = tsd(time,dat);
    % save lfp.mat
    save(['LFP' num2str(ilfp-1) '.mat'],'LFP');
    
    clear LFP
end
disp('Done')
disp('Move on')
toc