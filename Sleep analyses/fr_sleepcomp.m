function fr_sleepcomp(expe,subj,clu,varargin)
%==========================================================================
% Details: Compare frequency rate during sleep for 1 cluster for one mouse
%
% INPUTS:
%       - expe: experiment for the PathforExperiment.m
%       - subj: mice ID for the analysis (ex: [912 882 747])
%       - clu: neuron cluster # 
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
dir_out = [dropbox '\DataSL\StimMFBWake\Firing Rate/' date '/'];
%set folders
if ~exist(dir_out,'dir')
    mkdir(dir_out);
end

% Set session names to be compared (for simplicity they will marked 
% as pre and post)
sesspre = 'PreSleep'; 
sesspost = 'PostSleep';

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
try
    load([Dir.path{1}{1} 'SleepScoring_OBGamma.mat'],'SWSEpoch','REMEpoch','Wake');
catch
    warning('SleepScoringOBGamma not available. Loading SleepScoring_Accelero instead.');
    load([Dir.path{1}{1} 'SleepScoring_Accelero.mat']);
end

%% set pre and post var
pre{1} = and(SWSEpoch,SessionEpoch.PreSleep);
pre{2} = and(REMEpoch,SessionEpoch.PreSleep);
pre{3} = and(Wake,SessionEpoch.PreSleep);

post{1} = and(SWSEpoch,SessionEpoch.PostSleep);
post{2} = and(REMEpoch,SessionEpoch.PostSleep);
post{3} = and(Wake,SessionEpoch.PostSleep);

% get spiking info
frpre = fr_bysleepstages(Dir.path{1}{1},clu,pre,1); 
frpost = fr_bysleepstages(Dir.path{1}{1},clu,post,1);

% prepare data for figures
nremfr = [frpre(1) frpost(1)];
remfr = [frpre(2) frpost(2)];
wakefr = [frpre(3) frpost(3)];
void = nan;

% stages %
%pre
npre = length(Start(pre{1})); 
rpre = length(Start(pre{2}));
wpre = length(Start(pre{3}));
allpre = wpre+npre+rpre;
wppre = wpre/allpre*100;
nppre = npre/allpre*100;
rppre = rpre/allpre*100;

%post
npost = length(Start(post{1})); 
rpost = length(Start(post{2}));
wpost = length(Start(post{3}));
allpost = wpost+npost+rpost;
wppost = wpost/allpost*100;
nppost = npost/allpost*100;
rppost = rpost/allpost*100;

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

maxy = max(max([nremfr remfr wakefr]))*1.25;
maxy_arch = max(max([nppre nppost void rppre rppost void wppre wppost]))*1.25;

supertit = ['M' num2str(subj) 'Clu' num2str(clu) ' - Pre vs post-sleep firing rate' ];
figure2(1,'Color',[1 1 1], 'rend','painters','pos',[10 10 1800 600],'Name', supertit, 'NumberTitle','off')
    subplot(1,2,1)
        [p_occ,h_occ, her_occ] = PlotErrorBarN_SL([nremfr void remfr void wakefr],...
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
        title(['M' num2str(subj) ' - Firing rate by stage and session'],'FontSize',20)
        % creating legend with hidden-fake data (hugly but effective)
        b2=bar([-2],[ 1],'FaceColor','flat');
        b1=bar([-3],[ 1],'FaceColor','flat');
        b1.CData(1,:) = repmat([0 0 0],1);
        b2.CData(1,:) = repmat([1 1 1],1);
        axP = get(gca,'Position');
        lg = legend([b1 b2],{'Pre-Sleep','Post-Sleep'},'Location','NorthWestOutside');
        title(lg,'Session')
        set(gca, 'Position', axP)
            
    subplot(1,2,2)
        [p_occ,h_occ, her_occ] = PlotErrorBarN_SL([nppre nppost void rppre rppost void wppre wppost],...
            'barcolors', [0 0 0], 'barwidth', 1, 'newfig', 0, 'Colorpoints',0);
         h_occ.FaceColor = 'flat';
        h_occ.CData(2,:) = [1 1 1];
        h_occ.CData(5,:) = [1 1 1];
        h_occ.CData(8,:) = [1 1 1];     
        set(gca,'Xtick',[1:8],'XtickLabel',{'            NREM','','','             REM','',''...
            '              Wake',''}); 
        ylabel('Proportion (%)')   
        ylim([0 maxy_arch])
        title('Sleep stages proportion','FontSize',20)
%         % creating legend with hidden-fake data (hugly but effective)
%         b2=bar([-2],[ 1],'FaceColor','flat');
%         b1=bar([-3],[ 1],'FaceColor','flat');
%         b1.CData(1,:) = repmat([0 0 0],1);
%         b2.CData(1,:) = repmat([1 1 1],1);
%         legend([b1 b2],{'Pre-Sleep','Post-Sleep'})%,'Location','EastOutside')

    %save figure
    print([dir_out 'M' num2str(subj) 'Clu' num2str(clu) '_FR-by-sleepstage'], '-dpng', '-r600');
   




