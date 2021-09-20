function figH = findthreshold_spi(varargin)
% =========================================================================
%                            findthreshold_spi
% =========================================================================
% DESCRIPTION:  Output interactive figures of average spindles for each
%               type of detection method (MOBs and Zugaro).
%               Run inside working directory. 
%                            
% =========================================================================
% INPUTS: 
%    __________________________________________________________________
%       Properties          Description                     Default
%    __________________________________________________________________
%
%       <varargin>
%
%       sizestep            Size of steps for each threshold 
%                           default: [.3 .4;.4 .7]
%       scoring             Either 'ob' or 'accelero'
%       rmvnoise            Clean artefactual noises
%       stim                Stim or not during sleep
%
% =========================================================================
% OUTPUT:
%    __________________________________________________________________
%       Properties          Description                   
%    __________________________________________________________________
%
%       figH                Handle of figures (for saving)
%
% =========================================================================
% VERSIONS
%   19.04.2021 Samuel Laventure
% =========================================================================
% SEE CreateSpindlesSleep FindSpindlesSB_SL FindSpindles_sqrt
% =========================================================================
%% 
% ------------------------------------------------------------------------- 
%                              SECTION
%                     I N I T I A L I Z A T I O N 
% -------------------------------------------------------------------------
% Parse parameter list
for i = 1:2:length(varargin)
    if ~ischar(varargin{i})
        error(['Parameter ' num2str(i+2) ' is not a property.']);
    end
    switch(lower(varargin{i}))
        case 'scoring'
            scoring = lower(varargin{i+1});
            if ~isstring_FMAToolbox(scoring, 'accelero' , 'ob')
                error('Incorrect value for property ''scoring''.');
            end
        case 'step'
            thresh = varargin{i+1};
            if ~isnumeric(sizestep)
                error('Incorrect value for property ''step''.');
            end
        case 'stim'
            stim = varargin{i+1};
            if stim~=0 && stim ~=1
                error('Incorrect value for property ''stim''.');
            end
        case 'rmvnoise'
            rmvnoise = varargin{i+1};
            if rmvnoise~=0 && rmvnoise ~=1
                error('Incorrect value for property ''rmvnoise''.');
            end
        otherwise
            error(['Unknown property ''' num2str(varargin{i}) '''.']);
    end
end

%check if exist and assign default value if not
%type of sleep scoring
if ~exist('scoring','var')
    scoring='ob';
end
% thresh base
if ~exist('step','var')
    sizestep=[.3 .4;.4 .7]; % 1st: thresh for absolute detection; 2nd: thresh for rootsquare det. 
end
%stim
if ~exist('stim','var')
    stim=0;
end
%rmvnoise (non-rip)
if ~exist('rmvnoise','var')
    rmvnoise=1;
end

% scoring = 'ob';
% rmvnoise = 1;
% stim = 0;
structure = 'PFCx';

nstep = 10;
% step = [.3 .4;.4 .7];
thresh_base = [0.5 1;1 1.5];

% params
Info.scoring = scoring;
Info.frequency_band = [9 18];
Info.durations = [100 300 3000];

% set folders
[parentdir,~,~]=fileparts(pwd);
pathOut = [pwd '/spindles/' date '/'];
if ~exist(pathOut,'dir')
    mkdir(pathOut);
end

% colors
clrs_default = get(gca,'colororder');
color_extra = [65	16	16; 
                87	72	53;	
                37	62	63;	
                50	100	0;
                82	41	12;	
                100	50	31;	
                39	58	93;	
                100	97	86;	
                86	8	24;	
                0	100	100;
                0	0	55;
                0	55	55;	
                72	53	4;
                66	66	66;	
                0 39 0]/100;
clrs = [clrs_default; color_extra];

%% 
% ------------------------------------------------------------------------- 
%                              SECTION
%                         L O A D    D A T A 
% -------------------------------------------------------------------------
try
    load('sSpindles.mat','M_thr','T_thr');
catch
    warning('No sSpindles.mat file. Proceeding with creation.')
end
if ~exist('M_thr','var')
    if strcmpi(scoring,'accelero')
        try
            load SleepScoring_Accelero Epoch TotalNoiseEpoch SWSEpoch
        catch
            try
                load StateEpoch Epoch TotalNoiseEpoch SWSEpoch
            catch
                warning('Please, run sleep scoring before extracting spindles!');
                return
            end
        end
    elseif strcmpi(scoring,'ob')
        try
            load SleepScoring_OBGamma Epoch TotalNoiseEpoch SWSEpoch
        catch
            try
                load StateEpochSB Epoch TotalNoiseEpoch SWSEpoch
            catch
                warning('Please, run sleep scoring before extracting spindles!');
                return
            end
        end

    end

    %load channel
    prefixe = ['ChannelsToAnalyse/' structure '_' ];
    channel=[];
    load([prefixe 'spindle']);
    

    %LFP tsd
    LFP=[];
    eval(['load LFPData/LFP',num2str(channel)])

    LFP_spindles = LFP;
    clear LFP channel

    %% 
    % ------------------------------------------------------------------------- 
    %                              SECTION
    %                       F I N D    S P I N D L E S  
    % -------------------------------------------------------------------------

    Info.Epoch= Epoch-TotalNoiseEpoch;
    Info.SWSEpoch= SWSEpoch-TotalNoiseEpoch;

    for istep=1:nstep
        % set threshold
        thr(istep,1:2,1:2) = thresh_base + (sizestep*istep);
        disp(['PROCESSING THRESHOLDS: ' num2str(squeeze(thr(istep,1,:))') ' and ' num2str(squeeze(thr(istep,2,:))')])  

        % Step 1: detect using LFP's absolute value
        disp('----------------------------------------')
        disp(' ') 
        disp('Detecting spindles using absolute value of the LFP')
        disp(' ')
        [spindles_abs, meanVal, stdVal] = FindSpindlesSB_SL(LFP_spindles, Info.SWSEpoch, 'frequency_band',Info.frequency_band, ...
            'durations',Info.durations,'threshold',squeeze(thr(istep,1,:))','stim',1,'clean',1);

        % Step 2: detect using LFP's square root 
        disp('----------------------------------------')
        disp(' ')
        disp('Detecting using root-square value of the LFP')
        disp(' ')
        [spindles_sqrt, stdev] = FindSpindles_sqrt(LFP_spindles, Info.SWSEpoch, squeeze(thr(istep,2,:))','clean',1);

        % Step 3: merge results
        disp('----------------------------------------')
        disp(' ')
        disp('Merging events')
        disp(' ')
        % get common spindles and sqrt-detected only 
        id{1}=[];id{2}=[];id{3}=[];
        ripabs = intervalSet(spindles_abs(:,1)*1E4, spindles_abs(:,3)*1E4);
        ripabs_tsd = Restrict(LFP_spindles,ripabs);
        for i=1:size(spindles_sqrt,1)
            ripsqrt_ts = intervalSet(spindles_sqrt(i,1)*1E4,spindles_sqrt(i,3)*1E4);
            in = inInterval(ripsqrt_ts,ripabs_tsd);
            if sum(Data(in))
                id{1}(end+1)=i;
            else
                id{2}(end+1)=i;
            end
            clear in
        end
        % get abs-detected only 
        ripsqrt = intervalSet(spindles_sqrt(:,1)*1E4, spindles_sqrt(:,3)*1E4);
        ripsqrt_tsd = Restrict(LFP_spindles,ripsqrt);
        for i=1:size(spindles_abs,1)
            ripabs_ts = intervalSet(spindles_abs(i,1)*1E4,spindles_abs(i,3)*1E4);
            in = inInterval(ripabs_ts,ripsqrt_tsd);
            if ~sum(Data(in))
                id{3}(end+1)=i;
            end
        end

        spindles_tmp = [spindles_sqrt([id{1}'; id{2}'],:); spindles_abs(id{3}',:)];
        % sorting events by start time
        [~,idx] = sort(spindles_tmp(:,1)); % sort just the first column
        Spindles = spindles_tmp(idx,:);   % sort the whole matrix using the sort indices

        % display final results
        disp('----------------------------------------')
        disp(['SquareRoot spindles only: ' num2str(length(id{2}))])
        disp(['Absosulte spindles only : ' num2str(length(id{3}))])
        disp(['Common spindles count   : ' num2str(length(id{1}))])
        disp('----------------------------------------')
        disp(['Spindles FINAL TOTAL    : ' num2str(size(Spindles,1))])
        disp('')


        disp('----------------------------------------')
        disp(' ')
        disp('Calculating averages')
        disp(' ')
        % Plot Raw stuff
        [Mabs{istep},Tabs{istep}]=PlotRipRaw(LFP_spindles, spindles_abs(:,1:3),[-1000 1000],'PlotFigure',0);
        [Msqt{istep},Tsqt{istep}]=PlotRipRaw(LFP_spindles, spindles_sqrt(:,1:3),[-1000 1000],'PlotFigure',0);

        clear Spindles id spindles_abs spindles_sqrt idx
        disp('========================================')
    end
    %% saving    
    M_thr.Mabs = Mabs;
    M_thr.Msqt = Msqt;
    T_thr.Tabs = Tabs;
    T_thr.Tsqt = Tsqt;

    if exist('sSpindles.mat','file')==2
        save('sSpindles.mat','M_thr','T_thr','-append');
    else
        save('sSpindles.mat','M_thr','T_thr');
    end
else
    Mabs = M_thr.Mabs;
    Msqt = M_thr.Msqt;
    Tabs = T_thr.Tabs;
    Tsqt = T_thr.Tsqt;
end
%% 
% ------------------------------------------------------------------------- 
%                              SECTION
%                            F I G U R E  
% -------------------------------------------------------------------------
supertit = ['Average spindle - MOBs'];
figure('Color',[1 1 1], 'rend','painters','pos',[10 10 2100 1200],'Name', supertit, 'NumberTitle','off')  
    for istep=1:nstep
        p1(istep) = plot(Mabs{istep}(:,2),'Color', clrs(istep,1:3));
        hold on
    end
    xlabel('Time (ms)')
    ylabel('$${\mu}$$V')   
    title(['Average spindle - MOBs']);      
    xlim([1 size(Mabs{istep},1)])
    for istep=1:nstep
        thr(1:2,1:2) = thresh_base + (sizestep*istep);
        thr_str_abs{istep} = string([strjoin(thr(:,1)) '; ' num2str(size(Tabs{istep},1)) ' spdl']);
        % create a button to calculate the difference between 2 points
        h = uicontrol('Position',[20 1000-(istep*80) 150 30],'String',['Line ' num2str(istep)],...
              'Callback', {@fChangeLine, p1, istep});
    end
    legend(p1([1:nstep]),thr_str_abs,'Location','WestOutside');

    
    %- save picture
    output_plot = ['spindle_abs_thresh.png'];
    fulloutput = [pathOut output_plot];
    print('-dpng',fulloutput,'-r300');

supertit = ['Average spindle - Zugaro'];
figure('Color',[1 1 1], 'rend','painters','pos',[10 10 2100 1200],'Name', supertit, 'NumberTitle','off')  
    for istep=1:nstep
        p2(istep) = plot(Mabs{istep}(:,2),'Color', clrs(istep,1:3));
        hold on
    end
    xlabel('Time (ms)')
    ylabel('$${\mu}$$V')   
    title(['Average spindle - ZUGARO']);      
    xlim([1 size(Mabs{istep},1)])
    for istep=1:nstep
        thr(1:2,1:2) = thresh_base + (sizestep*istep);
        thr_str_sqt{istep} = string([strjoin(thr(:,2)) '; ' num2str(size(Tsqt{istep},1)) ' spdl']);
        % create a button to calculate the difference between 2 points
        h = uicontrol('Position',[20 1000-(istep*80) 150 30],'String',['Line ' num2str(istep)],...
              'Callback', {@fChangeLine, p2, istep});
    end
    legend(p2([1:nstep]),thr_str_sqt,'Location','WestOutside');
    
    %- save picture
    output_plot = ['spindle_sqt_thresh.png'];
    fulloutput = [pathOut output_plot];
    print('-dpng',fulloutput,'-r300');
    
disp('----------------------------------------')
disp(' ')
disp(' DONE ')



function fChangeLine(ButtonH, EventData, p, istep )
    for ii=1:10
        p(ii).LineWidth = 1;
    end
    p(istep).LineWidth = 3;
    uistack(p(istep),'top');
end
end