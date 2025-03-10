function test_all(test_dir)
% @=============================================================================
% This function is part of the Brainstorm software:
% http://neuroimage.usc.edu/brainstorm
% 
% Copyright (c)2000-2018 University of Southern California & McGill University
% This software is distributed under the terms of the GNU General Public License
% as published by the Free Software Foundation. Further details on the GPLv3
% license can be found at http://www.gnu.org/copyleft/gpl.html.
% 
% FOR RESEARCH PURPOSES ONLY. THE SOFTWARE IS PROVIDED "AS IS," AND THE
% UNIVERSITY OF SOUTHERN CALIFORNIA AND ITS COLLABORATORS DO NOT MAKE ANY
% WARRANTY, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO WARRANTIES OF
% MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, NOR DO THEY ASSUME ANY
% LIABILITY OR RESPONSIBILITY FOR THE USE OF THIS SOFTWARE.
%
% For more information type "brainstorm license" at command prompt.
% =============================================================================@

%% ===== START =====
% Check inputs
if (nargin < 1) || isempty(test_dir)
    error('You must specify an empty directory in input.');
end
% Create test folder
if ~isdir(test_dir)
    if ~mkdir(test_dir)
        error(['Could not create folder: ' test_dir]);
    end
end
% Start profiling
% profile on
% Reset brainstorm
bst_reset();
% Prepare test folders
BrainstormHomeDir = fileparts(fileparts(fileparts(which(mfilename))));
BrainstormDbDir = fullfile(test_dir, 'brainstorm_db');
if isdir(BrainstormDbDir)
    error(['You should delete the test database folder first: ' BrainstormDbDir]);
end
mkdir(BrainstormDbDir);
% Start Brainstorm with GUI
bst_startup(BrainstormHomeDir, 0, BrainstormDbDir);

% Initialize random generator
rng('default');

% The protocol name has to be a valid folder name (no spaces, no weird characters...)
ProtocolName = 'ProtocolTest';
% Delete existing protocol
gui_brainstorm('DeleteProtocol', ProtocolName);
% Create new protocol
gui_brainstorm('CreateProtocol', ProtocolName, 0, 0, BrainstormDbDir);
% Start a new report
bst_report('Start');


%% ===== CREATE SUBJECT =====
% Create subject
SubjectName = 'Subject01';
[sSubject, iSubject] = db_add_subject(SubjectName);
% Set anatomy
sTemplates = bst_get('AnatomyDefaults');
iTemplate = find(strcmpi('ICBM152_2016c', {sTemplates.Name}));
db_set_template(iSubject, sTemplates(iTemplate), 0);
% Re-compute the MNI transformation
bst_process('CallProcess', 'process_mni_affine', [], [], ...
    'subjectname', SubjectName);
% Create downsampled cortex
CortexFile = 'Subject01\tess_cortex_pial_low.mat';
CortexLowFile = tess_downsize(CortexFile, 500, 'reducepatch');
% Create a folder
ConditionName = 'simulate';
iStudySim = db_add_condition(SubjectName, ConditionName);


%% ===== DISPLAY ANATOMY =====
% Get the updated subject structure
sSubject = bst_get('Subject', SubjectName);
% Get MRI file and surface files
MriFile    = sSubject.Anatomy(sSubject.iAnatomy).FileName;
CortexFile = sSubject.Surface(sSubject.iCortex).FileName;
HeadFile   = sSubject.Surface(sSubject.iScalp).FileName;
% Display MRI
hFigMri1 = view_mri(MriFile);
hFigMri2 = view_mri_3d(MriFile, [], [], 'NewFigure');
hFigMri3 = view_mri_slices(MriFile, 'x', 20);
% Close figures
bst_report('Snapshot', hFigMri1, [], 'view_mri');
bst_report('Snapshot', hFigMri2, [], 'view_mri_3d');
bst_report('Snapshot', hFigMri3, [], 'view_mri_slices');
close([hFigMri1 hFigMri2 hFigMri3]);
% Display scalp and cortex
hFigSurf = view_surface(HeadFile);
hFigSurf = view_surface(CortexFile, [], [], hFigSurf);
hFigMriSurf = view_mri(MriFile, CortexFile);
% Figure configuration
iTess = 2;
panel_surface('SetShowSulci',     hFigSurf, iTess, 1);
panel_surface('SetSurfaceColor',  hFigSurf, iTess, [1 0 0]);
panel_surface('SetSurfaceSmooth', hFigSurf, iTess, 0.5, 0);
panel_surface('SetSurfaceTransparency', hFigSurf, iTess, 0.8);
figure_3d('SetStandardView', hFigSurf, 'left');
pause(0.5);
% Close figures
bst_report('Snapshot', hFigSurf, [], 'view_surface');
bst_report('Snapshot', hFigMriSurf, [], 'view_mri + surface');
close([hFigSurf hFigMriSurf]);


%% ===== DATA SIMULATION =====
% Process: Simulate generic signals
nfiles = 10;
sfreq = 1000;
sSimScout = bst_process('CallProcess', 'process_simulate_matrix', [], [], ...
    'subjectname', SubjectName, ...
    'condition',   ConditionName, ...
    'samples',     nfiles * sfreq, ...
    'srate',       sfreq, ...
    'matlab',      ['ferp = 1; fnoise = 60;' 10 ...
                    'Data(1,:) = sin(pi + ferp*2*pi*t);' 10 ...
                    'Data(Data < 0) = 0;' 10 ...
                    'Data(1,:) = Data(1,:) + sin(fnoise*2*pi*t + pi*rand(1)) + 4 * (0.5 - rand(1,length(t)));' ...
                    'Data(2,:) =             sin(fnoise*2*pi*t + pi*rand(1)) + 4 * (0.5 - rand(1,length(t)));']);
% Process: Set channel file
bst_process('CallProcess', 'process_import_channel', sSimScout, [], ...
    'usedefault',   3);  % Colin27: 10-20 19
% Process: Compute head model
bst_process('CallProcess', 'process_headmodel', sSimScout, [], ...
    'sourcespace', 1, ...  % Cortex surface
    'eeg',         3, ...  % OpenMEEG BEM
    'openmeeg',    struct(...
         'BemSelect',    [0, 0, 1], ...
         'BemCond',      [1, 0.0125, 1], ...
         'BemNames',     {{'Scalp', 'Skull', 'Brain'}}, ...
         'BemFiles',     {{}}, ...
         'isAdjoint',    0, ...
         'isAdaptative', 1, ...
         'isSplit',      0, ...
         'SplitLength',  4000));
% Process: Simulate recordings from scouts
sSimData = bst_process('CallProcess', 'process_simulate_recordings', sSimScout, [], ...
    'scouts',      {'Mindboggle', {'lateraloccipital L', 'medialorbitofrontal R'}}, ...
    'savesources', 0);
% Add time markers
DataMat.Events = db_template('event');
DataMat.Events.label   = 'sin+';
DataMat.Events.color   = [0 1 0];
DataMat.Events.samples = round((.5:1:nfiles) * sfreq);
DataMat.Events.times   = DataMat.Events.samples ./ sfreq;
DataMat.Events.epochs  = ones(size(DataMat.Events.samples));
bst_save(file_fullpath(sSimData.FileName), DataMat, 'v6', 1);
% Save as an EGI raw file
RawFile = bst_fullfile(test_dir, 'run01.raw');
export_data(sSimData.FileName, [], RawFile, 'EEG-EGI-RAW');


%% ===== DISPLAY SENSORS =====
% View sensors
hFig = view_surface(HeadFile);
hFig = view_channels(sSimData.ChannelFile, 'EEG', 1, 1, hFig);
% Hide sensors
hFig = view_channels(sSimData.ChannelFile, 'EEG', 0, 0, hFig);
% Edit good/bad channel for current file
gui_edit_channel(sSimData.ChannelFile);
% Unload everything
bst_memory('UnloadAll', 'Forced');


%% ===== ACCESS THE RECORDINGS =====
% Process: Create link to raw file
sFilesRaw = bst_process('CallProcess', 'process_import_data_raw', [], [], ...
    'subjectname',    SubjectName, ...
    'datafile',       {RawFile, 'EEG-EGI-RAW'}, ...
    'channelreplace', 0, ...
    'channelalign',   0, ...
    'evtmode',        'value');
% Process: Set channel file
bst_process('CallProcess', 'process_import_channel', sFilesRaw, [], ...
    'usedefault',   3);  % Colin27: 10-20 19
% Process: Refine registration
bst_process('CallProcess', 'process_headpoints_refine', sFilesRaw, []);
% Process: Project electrodes on scalp
bst_process('CallProcess', 'process_channel_project', sFilesRaw, []);
% Process: Snapshot: Sensors/MRI registration
bst_process('CallProcess', 'process_snapshot', sFilesRaw, [], ...
    'target',   1, ...  % Sensors/MRI registration
    'modality', 4, ...  % EEG
    'orient',   1, ...  % left
    'comment',  'MEG/MRI Registration');


%% ===== PRE-PROCESSING =====
% Process: Power spectrum density (Welch)
sFilesPsdBefore = bst_process('CallProcess', 'process_psd', sFilesRaw, [], ...
    'timewindow',  [], ...
    'win_length',  1, ...
    'win_overlap', 50, ...
    'sensortypes', 'EEG', ...
    'edit', struct(...
         'Comment',         'Power', ...
         'TimeBands',       [], ...
         'Freqs',           [], ...
         'ClusterFuncTime', 'none', ...
         'Measure',         'power', ...
         'Output',          'all', ...
         'SaveKernel',      0));
% Process: Sinusoid removal: 60Hz 120Hz 180Hz 300Hz
sFilesClean = bst_process('CallProcess', 'process_notch', sFilesRaw, [], ...
    'freqlist',    60, ...
    'sensortypes', 'EEG', ...
    'read_all',    0);
% Process: Band-pass:0.5-40Hz
sFilesClean = bst_process('CallProcess', 'process_bandpass', sFilesClean, [], ...
    'sensortypes', 'EEG', ...
    'highpass',    0.5, ...
    'lowpass',     80, ...
    'attenuation', 'strict', ...  % 60dB
    'mirror',      0);

% Process: Set bad channels
bst_process('CallProcess', 'process_channel_setbad', sFilesClean, [], ...
    'sensortypes', 'Fp2');
% Process: Re-reference EEG
bst_process('CallProcess', 'process_eegref', sFilesClean, [], ...
    'eegref',      'AVERAGE', ...
    'sensortypes', 'EEG');

% Process: Power spectrum density (Welch)
sFilesPsdAfter = bst_process('CallProcess', 'process_psd', sFilesClean, [], ...
    'timewindow',  [], ...
    'win_length',  1, ...
    'win_overlap', 50, ...
    'sensortypes', 'EEG', ...
    'edit', struct(...
         'Comment',         'Power', ...
         'TimeBands',       [], ...
         'Freqs',           [], ...
         'ClusterFuncTime', 'none', ...
         'Measure',         'power', ...
         'Output',          'all', ...
         'SaveKernel',      0));
% Process: Snapshot: Frequency spectrum
bst_process('CallProcess', 'process_snapshot', [sFilesPsdBefore, sFilesPsdAfter], [], ...
    'target',   10, ...  % Frequency spectrum
    'comment',  'Power spectrum density');


%% ===== ARTIFACT CLEANING =====
% TODO: SSP, ICA, bad segments, other detections, add ECG/EOG to signal


%% ===== IMPORT RECORDINGS =====
% Process: Import MEG/EEG: Events
sFilesEpochs = bst_process('CallProcess', 'process_import_data_event', sFilesClean, [], ...
    'subjectname', SubjectName, ...
    'condition',   '', ...
    'eventname',   'sin+', ...
    'timewindow',  [], ...
    'epochtime',   [-0.100, 0.500], ...
    'createcond',  0, ...
    'ignoreshort', 1, ...
    'usectfcomp',  1, ...
    'usessp',      1, ...
    'freq',        [], ...
    'baseline',    [-0.1, -0.0017]);
% Display raster plot
hFigRaster = view_erpimage({sFilesEpochs.FileName}, 'erpimage', 'EEG');
bst_report('Snapshot', hFigRaster, sFilesEpochs(1).FileName, 'ERP image');
close(hFigRaster);


%% ===== AVERAGE =====
% Process: Average: By trial group (folder average)
sFilesAvg = bst_process('CallProcess', 'process_average', sFilesEpochs, [], ...
    'avgtype',    5, ...  % By trial groups (folder average)
    'avg_func',   7, ...  % Arithmetic average + Standard error
    'weighted',   0, ...
    'keepevents', 1);
% Process: Snapshot: Recordings time series
bst_process('CallProcess', 'process_snapshot', sFilesAvg, [], ...
    'target',     5, ...  % Recordings time series
    'modality',   4, ...  % EEG
    'Comment',    'Evoked response');
% Process: Snapshot: Recordings topography (contact sheet)
bst_process('CallProcess', 'process_snapshot', sFilesAvg, [], ...
    'target',         7, ...  % Recordings topography (contact sheet)
    'modality',       4, ...  % EEG
    'contact_time',   [0, 0.500], ...
    'contact_nimage', 15, ...
    'Comment',        'Evoked response');


%% ===== DISPLAY ERP =====
% View averages
hFigEeg = view_timeseries(sFilesAvg.FileName, 'EEG');
hFigTp1 = view_topography(sFilesAvg.FileName, 'EEG', '2DSensorCap');
hFigTp2 = view_topography(sFilesAvg.FileName, 'EEG', '3DSensorCap');
hFigTp3 = view_topography(sFilesAvg.FileName, 'EEG', '2DDisc');
hFigTp4 = view_topography(sFilesAvg.FileName, 'EEG', '2DLayout');
hFigTp5 = view_topography(sFilesAvg.FileName, 'EEG', '3DElectrodes');
figure_3d('SetStandardView', hFigTp5, 'left');
% Set time: 90ms
panel_time('SetCurrentTime', 0.250);
% Set filters: 40Hz low-pass, no high-pass
panel_filter('SetFilters', 1, 40, 0, [], 0, [], 0, 0);
% View selected sensors
SelectedChannels = {'O1', 'T5'};
bst_figures('SetSelectedRows', SelectedChannels);
hFigSel = view_timeseries(sFilesAvg.FileName, [], SelectedChannels);
% Select time window
figure_timeseries('SetTimeSelectionManual', hFigSel, [0.070, 0.130]);
% Show sensors on 2DSensorCap topography
figure_3d('ViewSensors', hFigTp1, 1, 1);
% Display time contact sheet for a figure
hContactFig = view_contactsheet( hFigTp2, 'time', 'fig', [], 12, [0 0.120] );
% Screen captures
bst_report('Snapshot', hFigSel, sFilesEpochs(1).FileName, 'Selected channels');
bst_report('Snapshot', hFigTp1, sFilesEpochs(1).FileName, '2DSensorCap');
bst_report('Snapshot', hFigTp2, sFilesEpochs(1).FileName, '3DSensorCap');
bst_report('Snapshot', hFigTp3, sFilesEpochs(1).FileName, '2DDisc');
bst_report('Snapshot', hFigTp4, sFilesEpochs(1).FileName, '2DLayout');
bst_report('Snapshot', hFigTp5, sFilesEpochs(1).FileName, '3DElectrodes');
bst_report('Snapshot', hContactFig, sFilesEpochs(1).FileName, 'Contact sheet');
% Colormap tests
bst_colormaps('SetColormapName', 'eeg', 'jet');
bst_colormaps('SetColormapName', 'eeg', 'cmap_rbw');
bst_colormaps('SetColormapAbsolute', 'eeg', 1);
bst_colormaps('SetMaxMode', 'eeg', 'local');
bst_colormaps('SetDisplayColorbar', 'eeg', 0);
bst_colormaps('RestoreDefaults', 'eeg');
gui_edit_channelflag(sFilesAvg.FileName);
bst_memory('UnloadAll', 'Forced');
close(hContactFig);


%% ===== SOURCE ANALYSIS =====
% Copy headmodel from simulation folder to data folder
sHeadmodel = bst_get('HeadModelForStudy', iStudySim);
db_add(sFilesAvg.iStudy, sHeadmodel.FileName);
% No noise model
bst_process('CallProcess', 'process_noisecov', sFilesAvg, [], ...
    'sensortypes',    'EEG', ...
    'target',         1, ...  % Noise covariance
    'identity',       1);     % Identity matrix
% Process: Compute sources [2018]
sAvgSrc = bst_process('CallProcess', 'process_inverse_2018', sFilesAvg, [], ...
    'output',  1, ...  % Kernel only: shared
    'inverse', struct(...
         'Comment',        'sLORETA: EEG', ...
         'InverseMethod',  'minnorm', ...
         'InverseMeasure', 'sloreta', ...
         'SourceOrient',   {{'free'}}, ...
         'Loose',          0.2, ...
         'UseDepth',       0, ...
         'WeightExp',      0.5, ...
         'WeightLimit',    10, ...
         'NoiseMethod',    'reg', ...
         'NoiseReg',       0.1, ...
         'SnrMethod',      'fixed', ...
         'SnrRms',         1e-06, ...
         'SnrFixed',       3, ...
         'ComputeKernel',  1, ...
         'DataTypes',      {{'EEG'}}));
% Process: Snapshot: Sources (one time)
bst_process('CallProcess', 'process_snapshot', sAvgSrc, [], ...
    'target',    8, ...  % Sources (one time)
    'modality',  4, ...  % EEG
    'orient',    3, ...  % top
    'time',      0.230, ...
    'threshold', 60, ...
    'comment',   'Average sources');


%% ===== SCOUTS =====
% Process: Scouts time series: V1 L
sScout = bst_process('CallProcess', 'process_extract_scout', sAvgSrc, [], ...
    'timewindow',     [], ...
    'scouts',         {'Brodmann', {'V1 L', 'V1 R'}}, ...
    'scoutfunc',      1, ...  % Mean
    'isflip',         1, ...
    'isnorm',         1, ...
    'concatenate',    1, ...
    'save',           1, ...
    'addrowcomment',  1, ...
    'addfilecomment', 1);
% Process: Snapshot: Recordings time series
bst_process('CallProcess', 'process_snapshot', sScout, [], ...
    'target',     5, ...  % Recordings time series
    'modality',   4, ...  % EEG
    'Comment',    'Scouts');


% ===== SOURCE ANALYSIS: VOLUME =====
% Process: Compute head model
bst_process('CallProcess', 'process_headmodel', sFilesAvg, [], ...
    'sourcespace', 2, ...  % MRI volume
    'volumegrid',  struct(...
         'Method',        'adaptive', ...
         'nLayers',       17, ...
         'Reduction',     3, ...
         'nVerticesInit', 4000, ...
         'Resolution',    0.005, ...
         'FileName',      []), ...
    'eeg',         2);     % 3-shell sphere
% Process: Compute sources [2018]
sAvgSrcVol = bst_process('CallProcess', 'process_inverse_2018', sFilesAvg, [], ...
    'output',  1, ...  % Kernel only: shared
    'inverse', struct(...
         'Comment',        'Dipoles: EEG', ...
         'InverseMethod',  'gls', ...
         'InverseMeasure', 'performance', ...
         'SourceOrient',   {{'free'}}, ...
         'Loose',          0.2, ...
         'UseDepth',       1, ...
         'WeightExp',      0.5, ...
         'WeightLimit',    10, ...
         'NoiseMethod',    'reg', ...
         'NoiseReg',       0.1, ...
         'SnrMethod',      'rms', ...
         'SnrRms',         1e-06, ...
         'SnrFixed',       3, ...
         'ComputeKernel',  1, ...
         'DataTypes',      {{'EEG'}}));
% Process: Snapshot: Sources (one time)
bst_process('CallProcess', 'process_snapshot', sAvgSrcVol, [], ...
    'target',    8, ...  % Sources (one time)
    'modality',  1, ...  % MEG (All)
    'orient',    3, ...  % top
    'time',      0, ...
    'threshold', 0, ...
    'comment',   'Dipole modeling');
% Process: Dipole scanning
sDipScan = bst_process('CallProcess', 'process_dipole_scanning', sAvgSrcVol, [], ...
    'timewindow', [-0.040, 0.100], ...
    'scouts',     {});
% Process: Snapshot: Dipoles
bst_process('CallProcess', 'process_snapshot', sDipScan, [], ...
    'target',    13, ...  % Dipoles
    'orient',    3, ...   % top
    'threshold', 90, ...
    'Comment',   'Dipole scanning');
% Process: Snapshot: Dipoles
bst_process('CallProcess', 'process_snapshot', sDipScan, [], ...
    'target',    13, ...  % Dipoles
    'orient',    1, ...   % left
    'threshold', 90, ...
    'Comment',   'Dipole scanning');


%% ===== TIME-FREQUENCY =====
% Process: Time-frequency (Morlet wavelets)
sFilesTf = bst_process('CallProcess', 'process_timefreq', sFilesEpochs, [], ...
    'sensortypes', 'EEG', ...
    'edit',        struct(...
         'Comment',         'Avg,Power,1-80Hz', ...
         'TimeBands',       [], ...
         'Freqs',           [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80], ...
         'MorletFc',        1, ...
         'MorletFwhmTc',    3, ...
         'ClusterFuncTime', 'none', ...
         'Measure',         'power', ...
         'Output',          'average', ...
         'RemoveEvoked',    0, ...
         'SaveKernel',      0), ...
    'normalize',   'none');  % None: Save non-standardized time-frequency maps
% Process: Event-related perturbation (ERS/ERD): [-100ms,-1ms]
sFilesTfNorm = bst_process('CallProcess', 'process_baseline_norm', sFilesTf, [], ...
    'baseline',  [-0.1, -0.001], ...
    'method',    'ersd', ...  % Event-related perturbation (ERS/ERD):    x_std = (x - &mu;) / &mu; * 100
    'overwrite', 0);
% Process: Snapshot: Time-frequency maps
bst_process('CallProcess', 'process_snapshot', sFilesTfNorm, [], ...
    'target',   14, ...  % Time-frequency maps
    'Comment',  'Not normalized');


%% ===== STOP AND REPORTING =====
ReportFile = bst_report('Save', []);
HtmlFile = bst_report('Export', ReportFile, test_dir);
web(HtmlFile);


% Start Brainstorm with no GUI
% brainstorm nogui
% brainstorm stop

% Stop profiling
% profile viewer
% profiview
% coveragerpt



