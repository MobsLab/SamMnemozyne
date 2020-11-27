% NDM_shit_SL
function NDM_SL_pre_post(Dir, indir, indir_beh, postorpre)

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
    disp('you are gonna be asked about the experiment...');
    
    load('LFPData/InfoLFP.mat');
    % Info about the experiment
    Response = inputdlg({'Mouse Number','Stim Type (PAG,Eyeshock,MFB)','Date', 'Phase',...
    'Ripples','DeltaPF [sup (delta down) deep (delta up)]','SpindlePF', 'StimInt', 'StimDur'},'Inputs for ERC experiment',1);
    % Mouse and date info
    ExpeInfo.nmouse=eval(Response{1});
    ExpeInfo.date=eval(Response{3});
    ExpeInfo.phase=eval(Response{4});
    ExpeInfo.StimInt=eval(Response{8});
    ExpeInfo.StimDur=eval(Response{9});

    % Ephys info
    ExpeInfo.StimElecs=Response{2}; % PAG or MFB or Eyeshock
    ExpeInfo.Ripples=eval(Response{5}); % give channel
    ExpeInfo.DeltaPF=eval(Response{6}); % give sup (delta down) the deep (delta up)
    ExpeInfo.SpindlePF=eval(Response{7}); % give channel

    % Implantation info
    ExpeInfo.RecordElecs=InfoLFP;


    % Mouse characteristics
    ExpeInfo.VirusInjected={};
    ExpeInfo.OptoStimulation=0;
    ExpeInfo.MouseStrain='C57Bl6';
end

save('ExpeInfo.mat', 'ExpeInfo');

%% Move files
flnme = [prefix 'Mouse-' num2str(ExpeInfo.nmouse) '-' ExpeInfo.date '-' ExpeInfo.phase];

load('makedataBulbeInputs.mat');

%%% Loop: in each folder you should have xml file with numbered Phase name
%%% (f.e. _TestPre1.xml)

for i = 1:length(indir)
    cd([Dir postorpre num2str(i)]);
    % Move file with behavioral data
    if exist([Dir 'behavResources.mat'])==2
        disp('behavResources.mat copied already');
    else
        copyfile([Dir postorpre num2str(i) '/' indir_beh{i} 'behavResources.mat'], [Dir postorpre num2str(i)]);
    end

    % Move and rename files with electrophys data
    if exist([Dir 'amplifier.dat'])==2
        disp('amplifier.dat copied already');
    else
        copyfile([Dir postorpre num2str(i) '/' indir{i} 'amplifier.dat'], [Dir postorpre num2str(i)]);
        movefile([Dir postorpre num2str(i) '/'  'amplifier.dat'], [prefix 'Mouse-' num2str(ExpeInfo.nmouse) '-' ExpeInfo.date '-'...
            ExpeInfo.phase num2str(i) postfix.amp]);
    end

    % Move and rename files with accelerometer data
    if doaccelero == 1
        if exist([Dir 'auxiliary.dat'])==2
            disp('auxiliary.dat copied already');
        else
            copyfile([Dir postorpre num2str(i) '/' indir{i} 'auxiliary.dat'], [Dir postorpre num2str(i)]);
            movefile([Dir postorpre num2str(i) '/'  'auxiliary.dat'], [prefix 'Mouse-' num2str(ExpeInfo.nmouse) '-' ExpeInfo.date '-'...
            ExpeInfo.phase num2str(i) postfix.acc]);
        end
    end

    % Move and rename files with digital input
    if dodigitalin == 1
        if exist([Dir 'digitalin.dat'])==2
            disp('digitalin.dat copied already');
        else
            copyfile([Dir postorpre num2str(i) '/' indir{i} 'digitalin.dat'], [Dir postorpre num2str(i)]);
            movefile([Dir postorpre num2str(i) '/' 'digitalin.dat'], [prefix 'Mouse-' num2str(ExpeInfo.nmouse) '-' ExpeInfo.date '-'...
            ExpeInfo.phase num2str(i) postfix.din]);
        end
    end

    % Merge files (usually 36 channels: 32Elec+3Acc+1Digin)
    system(['ndm_mergedat ' flnme num2str(i) '.xml']);

    % Move it to the level up
    cd(Dir);
    copyfile([Dir postorpre num2str(i) '/' flnme num2str(i) '.dat'], Dir);
    movefile([Dir flnme num2str(i) '.dat'], [flnme '-0' num2str(i) postfix.amp]);

end

%% Do ndm shit

% Concatenate 4 sessions
system(['ndm_concatenate ' flnme '.xml']);

% Re-reference files (create 2 references: local for spikes and global for everything else)
Ref_ERC_SL

% Create LFP file
system(['ndm_lfp ' flnme '.xml']);

if spk == 1
    
    % Create spikes file
    system(['ndm_hipass ' flnme '_SpikeRef.xml']);
    system(['ndm_extractspikes ' flnme '_SpikeRef.xml']);
    system(['ndm_pca ' flnme '_SpikeRef.xml']);
end

%% End
disp('LFPs are ready! Go to KlustaKwik and spike-sort, mate')

end