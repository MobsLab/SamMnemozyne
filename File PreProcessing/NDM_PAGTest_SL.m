% NDM_shit_sl
function NDM_PAGTest_SL(Dir, indir, indir_beh,v,V,j)

%% Parameters
cd(Dir);
prefix = 'PAG-';  % Experiment prefix
postfix.amp = '-wideband.dat'; % Eletrophys data
postfix.acc = '-accelero.dat'; % Accelerometer data
postfix.din = '-digin.dat'; % Digital input data

%% Generate ExpeInfo

%check if ExpeInfo already exists 
try
    load('ExpeInfo.mat')
    disp('ExpeInfo already exists');
catch
    
    load('LFPData/InfoLFP.mat');
    % Info about the experiment
    % Mouse and date info
    ExpeInfo.nmouse=792;
    ExpeInfo.date='18092018';
    ExpeInfo.phase=['Calib-' num2str(v(j)) 'V'];
    ExpeInfo.StimInt=V{j};
    ExpeInfo.StimDur=0.1;

    % Ephys info
    ExpeInfo.StimElecs='PAG'; % PAG or MFB or Eyeshock
    ExpeInfo.Ripples=[]; % give channel
    ExpeInfo.DeltaPF=[]; % give sup (delta down) the deep (delta up)
    ExpeInfo.SpindlePF=[]; % give channel

    % Implantation info
    ExpeInfo.RecordElecs=InfoLFP;


    % Mouse characteristics
    ExpeInfo.VirusInjected={};
    ExpeInfo.OptoStimulation=0;
    ExpeInfo.MouseStrain='C57Bl6jRj';
end

%% Move files
flnme = [prefix 'Mouse-' num2str(ExpeInfo.nmouse) '-' ExpeInfo.date '-' ExpeInfo.phase];

load('makedataBulbeInputs.mat');

% Move file with behavioral data
if exist([Dir 'behavResources.mat'])==2
    disp('behavResources.mat copied already');
else
    copyfile([Dir indir_beh 'behavResources.mat'], Dir);
end

% Move and rename file with electrophys data
if exist([Dir 'amplifier.dat'])==2
    disp('amplifier.dat copied already');
else
copyfile([Dir indir 'amplifier.dat'], Dir);
    movefile([Dir 'amplifier.dat'], [prefix 'Mouse-' num2str(ExpeInfo.nmouse) '-' ExpeInfo.date '-' ExpeInfo.phase postfix.amp]);
end

% Move and rename file with accelerometer data
if doaccelero == 1
    if exist([Dir 'auxiliary.dat'])==2
        disp('auxiliary.dat copied already');
    else
        copyfile([Dir indir 'auxiliary.dat'], Dir);
        movefile([Dir 'auxiliary.dat'], [prefix 'Mouse-' num2str(ExpeInfo.nmouse) '-' ExpeInfo.date '-' ExpeInfo.phase postfix.acc]);
    end
end

% Move and rename file with digital input
if dodigitalin == 1
    if exist([Dir 'digitalin.dat'])==2
        disp('digitalin.dat copied already');
    else
        copyfile([Dir indir 'digitalin.dat'], Dir);
        movefile([Dir 'digitalin.dat'], [prefix 'Mouse-' num2str(ExpeInfo.nmouse) '-' ExpeInfo.date '-' ExpeInfo.phase postfix.din]);
    end
end

% Create folder raw ans move your files there
% mkdir ('raw');
% movefile ([Dir 'raw/' [prefix 'Mouse-' num2str(ExpeInfo.nmouse) '-' ExpeInfo.date '-' ExpeInfo.phase '.xml']]...
%    , Dir);
% movefile ([Dir indir_beh], [Dir 'raw']);

%% Do ndm shit

% Merge files (usually 36 channels: 32Elec+3Acc+1Digin)
system(['ndm_mergedat ' flnme '.xml']);

% Re-reference files (create 2 references: local for spikes and global for everything else)
Ref_ERC_DB

% Create LFP file
system(['ndm_lfp ' flnme '.xml']);

if spk == 1
    
    % Create spikes file
    system(['ndm_hipass ' flnme '_SpikeRef.xml']);
    system(['ndm_extractspikes ' flnme '_SpikeRef.xml']);
    system(['ndm_pca ' flnme '_SpikeRef.xml']);
end

%% End
save('ExpeInfo.mat', 'ExpeInfo');
disp('LFPs are ready! Go to KlustaKwik and spike-sort, mate')

end