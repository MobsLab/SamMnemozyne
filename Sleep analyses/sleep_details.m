function sleep_details(varargin)
%==========================================================================
% Details: Output details about sleep session.
%            - figure including (handle is not outputed):
%               - Neurons
%               - Sleep scoring plot, curves, stage duration
%               - Hypnogram
%               - mean lfp on delta waves
%               - mean ripples
%               - mean spindles
%
% INPUTS:
%       VARARGINs:
%       - stim          If stimulations are to be taken off the signal (0 or 1)
%       - recompute     Recompute events (0 or 1)
%       - down          Detect down states (default: 0). Need PFC neurons. 
%       - delta         Detect delta waves (default: 1). Need PFC channel. 
%       - rip           Detect ripples (default: 1). Need HPC rip channel.
%       - spindle       Detect spindles (default: 1). Need PFC spindle channel.
%       - ripthresh     Ripple thresholds (default: [4 6;2 5])
%                               1st: thresh for absolute detection   [4 6]
%                               2nd: thresh for rootsquare detection [2 5]
%       - substages     Compute substaging (N1,N2,N3). Proper signal on PFC
%                       (presence of delta and spindles) is necessary.
%       - idfig         output ID figures
% 
% OUTPUT:
%
% NOTES:
%
%   Written by Samuel Laventure - 02-07-2019
%   Updated 2020-11 SL 
%   Updated 2021-01 SL - added conditions, fixed ripples pipeline
%      
%  see also, FindNREMfeatures, SubstagesScoring, MakeIDSleepData,PlotIDSleepData
%==========================================================================

% Parse parameter list
for i = 1:2:length(varargin)
    if ~ischar(varargin{i})
        error(['Parameter ' num2str(i+2) ' is not a property.']);
    end
    switch(lower(varargin{i}))
        case 'stim'
            stim = varargin{i+1};
            if stim~=0 && stim ~=1
                error('Incorrect value for property ''stim''.');
            end
        case 'recompute'
            recompute = varargin{i+1};
            if recompute~=0 && recompute ~=1
                error('Incorrect value for property ''recompute''.');
            end
        case 'down'
            down = varargin{i+1};
            if down~=0 && down ~=1
                error('Incorrect value for property ''down''.');
            end
        case 'delta'
            delta = varargin{i+1};
            if delta~=0 && delta ~=1
                error('Incorrect value for property ''delta''.');
            end
        case 'rip'
            rip = varargin{i+1};
            if rip~=0 && rip ~=1
                error('Incorrect value for property ''rip''.');
            end
        case 'spindle'
            spindle = varargin{i+1};
            if spindle~=0 && spindle ~=1
                error('Incorrect value for property ''spindle''.');
            end
        case 'ripthresh'
            ripthresh = varargin{i+1};
            if ~isnumeric(ripthresh)
                error('Incorrect value for property ''ripthresh''.');
            end
        case 'delthresh'
            delthresh = varargin{i+1};
            if ~isnumeric(delthresh)
                error('Incorrect value for property ''delthresh''.');
            end
        case 'spithresh'
            spithresh = varargin{i+1};
            if ~isnumeric(spithresh)
                error('Incorrect value for property ''spithresh''.');
            end
        case 'substages'
            substages = varargin{i+1};
            if substages~=0 && substages ~=1
                error('Incorrect value for property ''substages''.');
            end
        case 'idfig'
            idfig = varargin{i+1};
            if idfig~=0 && idfig ~=1
                error('Incorrect value for property ''idfig''.');
            end
        case 'scoring'
            scoring = varargin{i+1};
            if ~strcmp(scoring,'ob') && ~strcmp(scoring,'accelero')
                error('Incorrect value for property ''scoring''.');
            end
        case 'restrict'
            restrict = varargin{i+1};
            if restrict~=0 && restrict ~=1
                error('Incorrect value for property ''restrict''.');
            end
        otherwise
            error(['Unknown property ''' num2str(varargin{i}) '''.']);
    end
end

%check if exist and assign default value if not
%Is there stim in this session
if ~exist('stim','var')
    stim=0;
end
%recompute?
if ~exist('recompute','var')
    recompute=1;
end
if ~exist('down','var')
    down=0;
end
if ~exist('delta','var')
    delta=1;
end
if ~exist('rip','var')
    rip=1;
end
if ~exist('spindle','var')
    spindle=1;
end
if ~exist('ripthresh','var')
    % [absolute detection; rootsquare det.]
    ripthresh=[4 6; 2 5]; 
end
if ~exist('delthresh','var')
    delthresh=[2 1]; 
end
if ~exist('spithresh','var')
    % [absolute detection; rootsquare det.]
    spithresh=[2 3; 3 5];
end
if ~exist('substages','var')
    substages=1;
end
if ~exist('idfig','var')
    idfig=1;
end
if ~exist('scoring','var')
    scoring='ob';
end
if ~exist('restrict','var')
    restrict=0;
end


%load stim
if stim
    try 
        load('behavResources.mat','StimEpoch');
    catch
        warning('No var StimEpoch in behavResources')
        return
    end
end

%% Sleep event
disp('Detecting sleep events')
disp(' ')
CreateSleepSignals('recompute',recompute,'scoring',scoring,'stim',stim,'restrict',restrict, ...
    'down',down,'delta',delta,'rip',rip,'spindle',spindle, ...
    'ripthresh',ripthresh,'delthresh',delthresh,'spithresh',spithresh);

%% Substages
if substages
    disp('getting sleep stages')
    [featuresNREM, Namesfeatures, EpochSleep, NoiseEpoch, scoring] = FindNREMfeatures('scoring',scoring);
    save('FeaturesScoring', 'featuresNREM', 'Namesfeatures', 'EpochSleep', 'NoiseEpoch', 'scoring')
    [Epoch, NameEpoch] = SubstagesScoring(featuresNREM, NoiseEpoch,'burstis3',1,'removesi',1,'newburstthresh',0);
    save('SleepSubstages', 'Epoch', 'NameEpoch')
end

%% GLOBAL FIGURES
if idfig
    %set folders
    [parentdir,~,~]=fileparts(pwd);
    pathOut = [pwd '/Figures/' date '/'];
    if ~exist(pathOut,'dir')
        mkdir(pathOut);
    end
    % Id figure 1
    disp('making ID fig1')
    MakeIDSleepData('recompute',recompute)
    PlotIDSleepData('scoring',scoring)
    print([pathOut 'SleepGlobalDetails'], '-dpng', '-r300');
% 
%     % Id figure 2
%     MakeIDSleepData2('scoring',scoring,'recompute',1)
%     PlotIDSleepData2
%     print([pathOut 'DeltaGlobalDetails'], '-dpng', '-r300');
end
end

