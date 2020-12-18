
function MAIN_PREPROCESS()

%==========================================================================
% Details: Step by step pre-processing
%
% INPUTS:
%       
% OUTPUT:
%
% NOTES: 
%       
%   Written by Samuel Laventure - 05-10-2020 
%      
%==========================================================================

%% VARIABLE INIT
% Mouse number & expe name
Mouse_id = '1124'; 
expe = 'StimMFBWake';

% set non-ripple channel
switch Mouse_id
    case '1117'
        if strcmp(expe,'StimMFBWake')
            nonrip_chan.channel = 5; % 1117 StimMFBWake
        end
    case '1124'
        if strcmp(expe,'StimMFBWake')
            nonrip_chan.channel = 61; % 1124 StimMFBWake
        end
end

% set main directory
workPath =  pwd;

% sessions to linearalize and morph (UMaze)
% sess = {'1-explo','3-hab',...
%         '4-pre-tests/pre1','4-pre-tests/pre2','4-pre-tests/pre3','4-pre-tests/pre4',...
%         '5-cond/cond1','5-cond/cond2','5-cond/cond3','5-cond/cond4',...
%         '5-cond/cond5','5-cond/cond6','5-cond/cond7','5-cond/cond8',...
%         '7-post-tests/post1','7-post-tests/post2','7-post-tests/post3','7-post-tests/post4',...
%         '8-extinct'};
sess = {'2-Hab',...
        '3-Pre-Tests/pre1','3-Pre-Tests/pre2','3-Pre-Tests/pre3','3-Pre-Tests/pre4',...
        '3-Pre-Tests/pre5','3-Pre-Tests/pre6','3-Pre-Tests/pre7','3-Pre-Tests/pre8',...
        '4-Cond/cond1','4-Cond/cond2','4-Cond/cond3','4-Cond/cond4',...
        '4-Cond/cond5','4-Cond/cond6','4-Cond/cond7','4-Cond/cond8',...
        '6-Post-Tests/post1','6-Post-Tests/post2','6-Post-Tests/post3','6-Post-Tests/post4',...
        '6-Post-Tests/post5','6-Post-Tests/post6','6-Post-Tests/post7','6-Post-Tests/post8',...
        '7-Extinct'};    
    
% Intan or Open Ephys
intan = 0;
oe    = 1;

% To do
stim = 1;       % set to 1 if you have stim
ss = 1;         % set to 1 to sleep scoring
hb =  0;        % set to 1 to process heart rate 
osc = 1;        % set to 1 to process ripples, spindles, delta waves and substages

%% MAIN

% MORPH and LINEARALIZE UMAZE
DoMorphLinearization_SL(sess);
cd(workPath);
%Do a re-run to make sure all folders are done.

% CONVERT PYTHON to MATLAB (open ephys only)
if oe
    convertEvents2Mat_multidir;
    cd(workPath);
end

% MAIN PRE-PROCESSING PIPELINE
% suite...
% GUI_StepTwo_RecordingInfo
% GUI_StepThree_FolderInfo

GUI_StepOne_ExperimentInfo;
% CHECK IN behavResources.mat in the behavResources var that X and Y
% aligned have data !!

% % PREPARE STIM (oe: if stim launched from the OE panel)
% if stim
%     if intan
%         GetStims_DB
%         make_StimSent
%     elseif oe
%         GetStims_OE_SL
%     end
% end

% SLEEP SCORING
if ss
    defaultvalues={'yes', 'yes', 'yes'};
    Questions={'Sleep Scoring ? OBgamma', 'Sleep events?' 'Substages?'};
    ans = inputdlg(Questions, 'Inputs for makeData', 1, defaultvalues);

    doscoring = strcmp(ans{1},'yes');
    dosleepevents = strcmp(ans{2},'yes');
    dosubstages = strcmp(ans{3},'yes');

    if doscoring == 1
        if stim
            load('behavResources.mat','TTLInfo');
            StimEpoch = intervalSet(Start(TTLInfo.StimEpoch)-3E2, Start(TTLInfo.StimEpoch)+3E3);
            SleepScoring_Accelero_OBgamma('PlotFigure',1, 'smoothwindow', 1.2, 'StimEpoch', StimEpoch);
        else
            SleepScoring_Accelero_OBgamma('PlotFigure',1);
        end        
    end
    disp('Creating sleep scoring array');
    % add a array of sleep scoring to OBgamma
    make_sleepscoringarray
    % create an event file for neuroscope
    make_sleepscoring_event
    % Note: if no sleep it will crash when creating theta epoch. But the
    % SleepScoring_.mat will have been created.
end

% HEART RATE
 if hb
    preprocess_hb(workPath);
end

%% DELTA, RIPPLES & SPINDLES    
if osc
    % set non-rippples HPC channel here
    channel = 2;
    save([pwd '/ChannelsToAnalyse/nonHPC.mat'],'channel')
    % detect events, substages, create .mat and event files, ID Figure
    sleep_details('recompute',1,'save_data',1,'stim',1,'down',1,'delta',1,'rip',1,'spindle',1)
end

% -------------------------
%   CLUSTER SPIKE GROUPS
% -------------------------

load('ExpeInfo.mat'); 
try
    flnme = ['M' num2str(ExpeInfo.nmouse) '_' num2str(ExpeInfo.date) '_' ExpeInfo.SessionType '_SpikeRef'];
    %Set Session
    SetCurrentSession([flnme '.xml']);
catch
    flnme = ['M' num2str(ExpeInfo.nmouse) '_' num2str(ExpeInfo.date) '_' ExpeInfo.SessionType];
    %Set Session
    SetCurrentSession([flnme '.xml']);
end

% if re-launched use:
SetCurrentSession('same');

% MAKE DATA SPIKES (NEED TO Cluster first!)
MakeData_Spikes('mua', 1,'recompute',1);

