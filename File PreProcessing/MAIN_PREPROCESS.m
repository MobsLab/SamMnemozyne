
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
clear all
% Mouse number & expe name
mouse_num = 1336;
% expe = 'UMazePAG';
% expe = 'Reversal';
expe = 'Novel';
expe = 'StimMFBWake';
expe = 'UMazePAG';
expe = 'BaselineSleep';
expe = 'Known';

% set main directory
workPath =  pwd;

% sessions to linearalize and morph (UMaze)
sess = {'2-hab',...
        '3-pre-tests/pre1','3-pre-tests/pre2','3-pre-tests/pre3','3-pre-tests/pre4',...
        '4-cond/cond1','4-cond/cond2','4-cond/cond3','4-cond/cond4',...
        '4-cond/cond5','4-cond/cond6','4-cond/cond7','4-cond/cond8',...
        '6-post-tests/post1','6-post-tests/post2','6-post-tests/post3','6-post-tests/post4'}; %,...
        %'8-extinct'};
sess = {'3-hab',...
        '4-pre-tests/pre1','4-pre-tests/pre2','4-pre-tests/pre3','4-pre-tests/pre4',...
        '5-cond/cond1','5-cond/cond2','5-cond/cond3','5-cond/cond4',...
        '5-cond/cond5','5-cond/cond6','5-cond/cond7','5-cond/cond8',...
        '7-post-tests/post1','7-post-tests/post2','7-post-tests/post3','7-post-tests/post4'};       
        
sess = {'2-Hab',...
        '3-Pre-Tests/pre1','3-Pre-Tests/pre2','3-Pre-Tests/pre3','3-Pre-Tests/pre4',...
        '3-Pre-Tests/pre5','3-Pre-Tests/pre6','3-Pre-Tests/pre7','3-Pre-Tests/pre8',...
        '4-Cond/cond1','4-Cond/cond2','4-Cond/cond3','4-Cond/cond4',...
        '4-Cond/cond5','4-Cond/cond6','4-Cond/cond7','4-Cond/cond8',...
        '6-Post-Tests/post1','6-Post-Tests/post2','6-Post-Tests/post3','6-Post-Tests/post4',...
        '6-Post-Tests/post5','6-Post-Tests/post6','6-Post-Tests/post7','6-Post-Tests/post8',...
        '7-Extinct'};   
    
% NOVEL    
sess = {'2-Hab',...
        '3-Pre-Tests/pre1','3-Pre-Tests/pre2','3-Pre-Tests/pre3','3-Pre-Tests/pre4',...
        '4-Cond/cond1','4-Cond/cond2','4-Cond/cond3','4-Cond/cond4',...
        '6-Post-Tests/post1','6-Post-Tests/post2','6-Post-Tests/post3','6-Post-Tests/post4'};  
    %         '4-Cond/cond5','4-Cond/cond6','4-Cond/cond7','4-Cond/cond8',...
    
sess = {'2-Hab',...
        '3-Pre-Tests/pre1','3-Pre-Tests/pre2','3-Pre-Tests/pre3','3-Pre-Tests/pre4',...
        '3-Pre-Tests/pre5','3-Pre-Tests/pre6','3-Pre-Tests/pre7','3-Pre-Tests/pre8',...
        '4-Cond/cond1','4-Cond/cond2','4-Cond/cond3','4-Cond/cond4',...
        '4-Cond/cond5','4-Cond/cond6','4-Cond/cond7','4-Cond/cond8',...
        '6-Post-Tests/post1','6-Post-Tests/post2','6-Post-Tests/post3','6-Post-Tests/post4',...
        '6-Post-Tests/post5','6-Post-Tests/post6','6-Post-Tests/post7','6-Post-Tests/post8'};      
% % Reversal
% sess = {'1-Hab/hab1','1-Hab/hab2',...
%         '3-Pre-Tests/pre1','3-Pre-Tests/pre2','3-Pre-Tests/pre3','3-Pre-Tests/pre4',...
%         '3-Pre-Tests/pre5','3-Pre-Tests/pre6','3-Pre-Tests/pre7','3-Pre-Tests/pre8',...
%         '4-Cond/cond1','4-Cond/cond2','4-Cond/cond3','4-Cond/cond4',...
%         '6-Post-Tests/post1','6-Post-Tests/post2','6-Post-Tests/post3','6-Post-Tests/post4',...
%         '6-Post-Tests/post5','6-Post-Tests/post6','6-Post-Tests/post7','6-Post-Tests/post8',...
%         '7-Extinct'};       
% Intan or Open Ephys
intan = 1;
oe    = 1;

% SLEEP PARAMETERS
% sleep scoring method (isob = scored with OBGamma; else it will be with accelero)
isob = 1;
if isob
    scoring = 'ob';
else
    scoring = 'accelero';
end
ripthresh = [4 6; 2 5];     % [4 6; 2 5]; 
delthresh = [2 1];      % [2 1];
spithresh = [1.5 2; 3 5]; % [2 3; 3 5];

ripthresh = [4 6; 2.2 5.3];     % [4 6; 2 5]; 
delthresh = [2.5 1.5];       % [2 1];
spithresh = [2 3; 3 5]; % [2 3; 3 5];

ripthresh = [3.8 5.6; 1.8 4.7];     % [4 6; 2 5]; 
delthresh = [1.1 2.25];       % [2 1];
spithresh = [2 3; 3 5]; % [2 3; 3 5];

% To do
stim = 1;       % set to 1 if you have stim
ss = 1;         % set to 1 to sleep scoring
hb =  0;        % set to 1 to process heart rate 
osc = 1;        % set to 1 to process ripples, spindles, delta waves and substages

%% MAIN

% MORPH and LINEARALIZE UMAZE
workPath = pwd;
DoMorphLinearization_SL_v2(sess);
cd(workPath);
%Do a re-run to make sure all folders are done.

% CONVERT PYTHON to MATLAB (open ephys only)
%
% or use your terminali=i+1;plot(Data(Restrict(tsdMovement,intervalSet(st(i)-5000,en(i)+5000)))); yline(mov_threshold)
%   -> ~/Dropbox/Kteam/PrgMatlab/OnlinePlaceDecoding/matlab/convertEvents2Mat -p /path/to/events
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
%     if intan % not necessary anymore (included in the gui pipeline)
%         GetStims_DB
%         make_StimSent
%     elseif oe
%         GetStims_OE_SL
%     end
% end


% Create Direction data
create_DirLinear(expe,mouse_num)  % check PathForExp

% SLEEP SCORING
if ss
    if stim
        load('behavResources.mat','TTLInfo');
        StimEpoch = intervalSet(Start(TTLInfo.StimEpoch)-3E2, Start(TTLInfo.StimEpoch)+3E3);
%         Correct_SleepScoring_Theta('PlotFigure',1, 'smoothwindow', 1.2, 'StimEpoch', StimEpoch,'recompute',1);
        SleepScoring_Accelero_OBgamma('PlotFigure',1, 'smoothwindow', 2.5, ...
            'StimEpoch', StimEpoch,'recompute',1,'continuity',1);
        gui_sleepscoring_verif
    else
        SleepScoring_Accelero_OBgamma('PlotFigure',1, 'smoothwindow', 2.5, ...
            'recompute',1,'continuity',1);
        gui_sleepscoring_verif
    end   
    disp('Creating sleep scoring array');
    % add a array of sleep scoring to OBgamma
    make_sleepscoringarray
    % create an event file for neuroscope
    make_sleepscoring_event
    % Note: if no sleep it will crash when creating theta epoch. But the
    % SleepScoring_.mat will have been created.
end

%% DELTA, RIPPLES & SPINDLES    
if osc
    % plot spindle averages with different thresholds (for threshold
    % selection)
    findthreshold_spi('scoring',scoring)
    % detect nrem events and substages
    sleep_details('recompute',1,'stim',1,'restrict',0,'down',0,'delta',1, ...
        'rip',1,'spindle',1, 'substages',1,'idfig',1,'scoring',scoring, ...
        'spithresh',spithresh,'delthresh',delthresh,'ripthresh',ripthresh)
    % detect substages (it uses deltas and spindles to identify substages)
    % Make sure they are already well detected in the first place. 
    % The analysis will re-detect deltas during pre and post sleep sessions
    % IMportant: needs to be added to PathForExp
    s_launchDeltaDetect(expe,mouse_num,scoring,delthresh)
end

% HEART RATE
 if hb
    preprocess_hb(workPath);
 end

% -------------------------
%   CLUSTER SPIKE GROUPS
% -------------------------
% NEED TO CLUSTER FIRST

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

% PREPARING NEURONS FILES
CalcBasicNeuronInfo(workPath,1)

RippleGroups = [1 2 3 4]; % set correct ripple groups (spike groups with ripples)
RippleGroups = [1 2 3];
save([pwd '/SpikeData.mat'],'RippleGroups','-append')
% FindAllPlacefields 
FindAllPlaceFields(pwd,expe)

% MAPPING THE PLACE FIELDS
% If only one session -> unique = 1
% If multi sessions:
%           - pooled = 1 -> will pool togother the demanded sessions
%           - pooled = 0 -> will not pool

FiguresPlaceCellMap_session({'TestPre1','TestPre2','TestPre3','TestPre4',...
    'TestPre5','TestPre6','TestPre7','TestPre8'}, ...
    'pooled',1,'recompute',1,'plotfig',1,'unique',1)
FiguresPlaceCellMap_session({'Hab'}, ...
    'pooled',0,'recompute',0,'plotfig',1,'unique',0)

