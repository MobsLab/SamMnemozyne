function spike_ripple(expe,subj,clu,session,varargin)
%==========================================================================
% Details: Compare frequency rate during sleep for 1 cluster for one mouse
%
% INPUTS:
%       - expe: experiment for the PathforExperiment.m
%       - subj: mice ID for the analysis (ex: [912 882 747])
%       - clu: neuron cluster # 
%       - session: session names in cell format {'session1','session2', ...}
%       - varargin:
%           . save_data: save variables and figures to dir_out (default: 0)
%
% OUTPUTS:
%       - 
%
% NOTES: 
%       - 
%       
% EXAMPLE: 
%
%
%   Original written by Samuel Laventure - 25-04-2020
%      
%  see also, 
%==========================================================================

% SELECT SECTIONS TO RUN
% Section 1
% Section 2
% Section 3
% Section 4

% Parse parameter list
for i = 1:2:length(varargin)
    if ~ischar(varargin{i})
        error(['Parameter ' num2str(i+2) ' is not a property.']);
    end
    switch(lower(varargin{i}))
        case 'save_data'
            save_data = varargin{i+1};
            if save_data~=0 && save_data ~=1
                error('Incorrect value for property ''save_data''.');
            end
        otherwise
            error(['Unknown property ''' num2str(varargin{i}) '''.']);
    end
end

%check if exist and assign default value if not
%save_data?
if ~exist('save_data','var')
    save_data=0;
end


%% ========================================================================
%                        P A R A M E T E R S
%  ========================================================================

% Directory to save and name of the figure to save
dir_out = [dropbox '\DataSL\StimMFBWake\Spikes/' date '/'];
%set folders
if ~exist(dir_out,'dir')
    mkdir(dir_out);
end

% Get data directories
Dir = PathForExperimentsERC_SL_home(expe);
Dir = RestrictPathForExperiment(Dir,'nMice', subj);

% get other parameters
nbsuj = length(Dir.path);

%##########################################################################
%#
%#                           M A I N
%#
%##########################################################################

%% Get data
load([Dir.path{1}{1} 'behavResources.mat'], 'SessionEpoch');
load([Dir.path{1}{1} 'Ripples.mat'], 'ripples');
load([Dir.path{1}{1}  'SpikeData.mat'], 'S');  % need to create this file from digIn3
try
    load([Dir.path{1}{1} 'SleepScoring_OBGamma.mat'],'SWSEpoch','REMEpoch','Wake');
catch
    warning('SleepScoringOBGamma not available. Loading SleepScoring_Accelero instead.');
    load([Dir.path{1}{1} 'SleepScoring_Accelero.mat']);
end

%% create inreval set of ripples
rip = intervalSet(ripples(:,1)*1e4,ripples(:,3)*1e4);

%% set pre and post var
for isess=1:length(session)
    se = extractfield(SessionEpoch,session{isess});
    % Intersect
    stage{isess,1} = and(and(SWSEpoch,se{1}),rip);
    stage{isess,2} = and(and(REMEpoch,se{1}),rip);
    stage{isess,3} = and(and(Wake,se{1}),rip); 
    for i=1:3
        fr_in(isess,i) = length(Restrict(S{clu},stage{isess,i}))/sum(End(stage{isess,i},'s')-Start(stage{isess,i},'s'));
    end
    clear stage
    % NOT in intersect
    stage{isess,1} = diff(and(SWSEpoch,se{1}),rip);
    stage{isess,2} = diff(and(REMEpoch,se{1}),rip);
    stage{isess,3} = diff(and(Wake,se{1}),rip);
    for i=1:3
        fr_out(isess,i) = length(Restrict(S{clu},stage{isess,i}))/sum(End(stage{isess,i},'s')-Start(stage{isess,i},'s'));
    end
    clear se stage
end

% prepare data for figures
nremfr_in = [];
remfr_in = [];
wakefr_in = [];
nremfr_out = [];
remfr_out = [];
wakefr_out = [];
for isess=1:length(session)
    nremfr_in = [nremfr_in fr_in(isess,1)];
    remfr_in = [remfr_in fr_in(isess,2)];
    wakefr_in = [wakefr_in fr_in(isess,3)];
    nremfr_out = [nremfr_out fr_out(isess,1)];
    remfr_out = [remfr_out fr_out(isess,2)];
    wakefr_out = [wakefr_out fr_out(isess,3)];
end
void = nan;

%% 
% ------------------------------------------------------------------------- 
%                              SECTION
%                   F I G U R E   R E G R E S S I O N
% -------------------------------------------------------------------------

% set figures text format
set(0,'defaulttextinterpreter','latex');
set(0,'DefaultTextFontname', 'Arial')
set(0,'DefaultAxesFontName', 'Arial')
set(0,'defaultTextFontSize',14)
set(0,'defaultAxesFontSize',14)

maxy = max(max([nremfr_in remfr_in wakefr_in nremfr_out remfr_out wakefr_out]))*1.25;

supertit = ['M' num2str(subj) 'Clu' num2str(clu) ' - Firing rate and ripples' ];
figure2(1,'Color',[1 1 1], 'rend','painters','pos',[10 10 1800 600],'Name', supertit, 'NumberTitle','off')
    subplot(1,2,1)
        [p_occ,h_occ, her_occ] = PlotErrorBarN_SL([nremfr_in void remfr_in void wakefr_in],...
            'barcolors', [0 0 0], 'barwidth', 1, 'newfig', 0, 'Colorpoints',0);
        h_occ.FaceColor = 'flat';
        h_occ.CData(2,:) = [1 1 1];
        h_occ.CData(5,:) = [1 1 1];
        h_occ.CData(8,:) = [1 1 1];
        set(gca,'Xtick',[1:8],'XtickLabel',{'            NREM','','','             REM','',''...
            '              Wake',''});   
        set(gca, 'LineWidth', 1);
        set(h_occ, 'LineWidth', 1);
        set(her_occ, 'LineWidth', 1);
        ylim([0 maxy])
        ylabel('Firing rate (Hz)');
        title(['M' num2str(subj) ' - Firing rate during ripples'],'FontSize',20)
        % creating legend with hidden-fake data (hugly but effective)
        b2=bar([-2],[ 1],'FaceColor','flat');
        b1=bar([-3],[ 1],'FaceColor','flat');
        b1.CData(1,:) = repmat([0 0 0],1);
        b2.CData(1,:) = repmat([1 1 1],1);
%         axP = get(gca,'Position');
        lg = legend([b1 b2],{'Pre-Sleep','Post-Sleep'},'Location','NorthWestOutside');
        title(lg,'Session')
%         set(gca, 'Position', axP)
    
    subplot(1,2,2)
        [p_occ,h_occ, her_occ] = PlotErrorBarN_SL([nremfr_out void remfr_out void wakefr_out],...
            'barcolors', [0 0 0], 'barwidth', 1, 'newfig', 0, 'Colorpoints',0);
        h_occ.FaceColor = 'flat';
        h_occ.CData(2,:) = [1 1 1];
        h_occ.CData(5,:) = [1 1 1];
        h_occ.CData(8,:) = [1 1 1];
        set(gca,'Xtick',[1:8],'XtickLabel',{'            NREM','','','             REM','',''...
            '              Wake',''});   
        set(gca, 'LineWidth', 1);
        set(h_occ, 'LineWidth', 1);
        set(her_occ, 'LineWidth', 1);
        ylim([0 maxy])
        ylabel('Firing rate (Hz)');
        title(['M' num2str(subj) ' - Firing rate outside ripples'],'FontSize',20)    
    %save figure
    print([dir_out 'M' num2str(subj) 'Clu' num2str(clu) '_FR_during_ripples'], '-dpng', '-r600');
    
    
    
    