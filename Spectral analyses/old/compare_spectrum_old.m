function compare_spectrum_old(expe, subj, numLFP, windur, varargin)
%==========================================================================
% Details: Compare time/frequency spectrums from a specific experiment. For
% the moment, compare the spectrum at the time of entering a zone.
%
% INPUTS:
%       - expe: experiment for the PathforExperiment.m
%       - subj: mice ID for the analysis (ex: [912 882 747])
%       - numLFP: LFP # to analyze for EACH SUBJ ID  (ex: [10 29 2]
%       - windur: time in second needed before (and after) the entrance
%       - varargin:
%           . freq: define frequency bad to analyze. For now, only low
%                   (0.1-20 Hz) and high (20-200 Hz). (default: high)
%           . clean: take out noise from segments using Noise epochs from
%             sleep scoring file (SleepScoring_OBGamma/accelero.mat)
%           . weight: creates weights for regression
%           . save_data: save variables and figures to dir_out (default: 0)
%
% OUTPUTS:
%       - Spectral results in SpectralData.mat
%       - Bootstrap and Wilcoxon results in wilcoxon_bstrp_results.mat
%       - Regression results in regression_stats.mat
%       - Figures regression and per mice/pooled tf contrast maps
%
% NOTES: 
%       - Don't forget to set your parameters within this section
%       - For now only gives freq for 'low' (0.1-20) and high (20-200)
%       - SECTIONs can be commented to save time if you already computed 
%         and saved the variables. Don't forget to keep the
%         loading variable uncommented.
%       
% EXAMPLE: 
%       StimMFBWake: compare_spectrum('StimMFBWake',[941 936],[7 29],3,'freq','high','clean',0,'weight',1,'save_data',1) 
%       StimPAGWake: compare_spectrum('StimPAGWake',PAG_params.subj,PAG_params.ripchan,3,'freq','high','clean',0,'weight',1,'save_data',1)
%
%
%   Original written by Samuel Laventure - 23-03-2020
%      
%  see also, LoadSpectrumML.m, glmfit, wwstats, RestrictSession,
%  wilcox_bts, tfregression
%==========================================================================

% SELECT SECTIONS TO RUN
% Section 1
extract_spec = 0;  % spectral information ectration
% Section 2
prep_data = 1;
% Section 3
bts_wilcox = 1;     
% Section 4
regression = 1;

% Parse parameter list
for i = 1:2:length(varargin)
    if ~ischar(varargin{i})
        error(['Parameter ' num2str(i+2) ' is not a property.']);
    end
    switch(lower(varargin{i}))
        case 'freq'
            freqband = varargin{i+1};
            if ~strcmp(freqband,'high') && ~strcmp(freqband,'low')
                error('Incorrect value for property ''freq''.');
            end    
        case 'clean'
            clean = varargin{i+1};
            if clean~=0 && clean ~=1
                error('Incorrect value for property ''clean''.');
            end
        case 'weight'
            w = varargin{i+1};
            if w~=0 && w~=1
                error('Incorrect value for property ''weight''.');
            end
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
% frequency band to analyze
if ~exist('freqband','var')
    freqband='high';
end
% clean data
if ~exist('clean','var')
    clean=0;
end
% use weight for regression
if ~exist('w','var')
    w=0;
end
%save_data?
if ~exist('save_data','var')
    save_data=0;
end




%% ========================================================================
%                        P A R A M E T E R S
%  ========================================================================

% Directory to save and name of the figure to save
% dir_out = 'C:\Users\samue\Dropbox\DataSL\StimMFBWake/Spectral Analyses/';
dir_out = ['C:\Users\samue\Documents\Mnemozyne/Spectral Analyses/' expe '/'];
%set folders
if ~exist(dir_out,'dir')
    mkdir(dir_out);
end

% Set session names to be compared (for simplicity they will marked 
% as pre and post)
sesspre = {'TestPre1','TestPre2','TestPre3','TestPre4'};    
sesspost = {'TestPost1','TestPost2','TestPost3','TestPost4'};
    
% Bootsrapping parameters 
draws=200;   %nbr of draws for the bts
    
% regression options
alpha = .05;
    
% Get prep data
windur = windur * 1e4;
gr_tested = [1 2]; %here, # of the zone tested that define the groups


% Get data directories
Dir = PathForExperimentsERC_SL_home(expe);
Dir = RestrictPathForExperiment(Dir,'nMice', subj);

% set spectral parameters
[params,movingwin,suffix]=SpectrumParametersML(freqband); % low or high

% get other parameters



%##########################################################################
%#
%#                           M A I N
%#
%##########################################################################

%% 
% ------------------------------------------------------------------------- 
%                           P R E P  D A T A 
% -------------------------------------------------------------------------
% Get behavioral data
for isubj=1:length(Dir.path)
    disp(['. Sujet: ' num2str(isubj)]);
    cd(Dir.path{1,isubj}{1})
    % load behavior
    behav{isubj} = load([Dir.path{isubj}{1} '/behavResources.mat'], 'behavResources','ZoneNames'); % ---> currently set to zone, will have to modify
end

% Get sessions id and timepoints (concatenated recordings)
for isess=1:length(sesspre)
    [id_pre{isess} tdatpre{isess}] = RestrictSession(Dir,sesspre{isess});  %add variable for session to call
end
for isess=1:length(sesspost)
    [id_post{isess} tdatpost{isess}] = RestrictSession(Dir,sesspost{isess});
end

%% 
% ------------------------------------------------------------------------- 
%           SECTION: EXTRACT SPECTRAL INFORMATION (TIME/FREQUENCY) 
% -------------------------------------------------------------------------
if extract_spec
    for isubj=1:length(Dir.path)    
        % load LFP
        load([Dir.path{isubj}{1} 'LFPData/LFP' num2str(numLFP(isubj)) '.mat'], 'LFP');

        %load sleep scoring for noise epoch
        if clean 
            try
                load([Dir.path{isubj}{1} 'SleepScoring_OBGamma.mat'],'TotalNoiseEpoch');
            catch
                try
                    load([Dir.path{isubj}{1} 'SleepScoring_Accelero.mat'],'TotalNoiseEpoch');
                catch
                    TotalNoiseEpoch = [];
                    clean = 0; 
                end
            end
        else
            TotalNoiseEpoch = [];
        end
        
        
        % PRE
        disp('----------PRE-----------');
        for isess=1:length(id_pre)
            disp(['.. Session: ' num2str(isess)]);
            disp('----------Extrating from LFP-----------');
            disp('... Zone:');
            for ievent=1:2%length(behav{isubj}.ZoneNames) % ---> currently set to zone, will have to modify
                fprintf(['.......' num2str(ievent)]);
                % get zone epoch
                markers = behav{1,isubj}.behavResources(id_pre{1,isess}{1,isubj}{1}).ZoneEpoch{1,ievent}; % may want to include a checkup here. Was it really in another zone or it was a NAN before... Also might be interesting to know where it was coming from. 
                % function extracting spectral information from LFP
                if ~isempty(markers)
                    [dataspec_pre{isubj,isess,ievent}, t_spec_pre{isubj,isess,ievent}, f_spec, tfmean_pre{isubj,isess,ievent},t_size]...
                        = get_spectdata(freqband, LFP, markers, TotalNoiseEpoch, windur);
                end
            end % loop zones
            disp('||')
        end % loop session   
        clear markers

        % POST
        disp('----------POST-----------');
        for isess=1:length(id_post)
            disp(['.. Session: ' num2str(isess)]);
            disp('----------Extrating from LFP-----------');
            disp('... Zone:');
            for ievent=1:2%length(behav{isubj}.ZoneNames)
                fprintf(['.......' num2str(ievent)]);
                % get zone epoch
                markers = behav{1,isubj}.behavResources(id_post{1,isess}{1,isubj}{1}).ZoneEpoch{1,ievent}; % may want to include a checkup here. Was it really in another zone or it was a NAN before... Also might be interesting to know where it was coming from. 
                % function extracting spectral information from LFP
                if ~isempty(markers)
                    [dataspec_post{isubj,isess,ievent}, t_spec_post{isubj,isess,ievent}, f_spec, tfmean_post{isubj,isess,ievent},t_size]...
                    = get_spectdata(freqband, LFP, markers, TotalNoiseEpoch, windur);
                end        
            end % loop zones
            disp('||')
        end % loop session  
    end % loop subjects
    
    clear LFP
    % saving SPECTRAL data
    if save_data
        save([dir_out 'SpectralData_' freqband '.mat'],'dataspec_post','t_spec_post','tfmean_post',...
            'dataspec_pre','t_spec_pre','tfmean_pre','f_spec','t_size','-v7.3');
    end
end
%% 
% -------------------------------------------------------------------------
% LOADING...
load([dir_out 'SpectralData_' freqband '.mat']);
% ------------------------------------------------------------------------- 
%                P R E P  D A T A  F O R  F I G U R E  
%                       A N D   A N A L Y S E S
% -------------------------------------------------------------------------
% set data params
lsfreq = f_spec;
f_size = length(lsfreq);
t_size = length(t_spec_pre{1,1,1}{1});

if prep_data
    %initialize a verification var (making sure that there are data)
    subj_ok(1:length(subj),1:length(behav{isubj}.ZoneNames)) = 1;

    % pre
    for isubj=1:length(Dir.path)
        for ievent=1:2 %length(behav{isubj}.ZoneNames)
            nmrk_pre = length(horzcat(dataspec_pre{isubj,:,ievent}));
            nmrk_post = length(horzcat(dataspec_post{isubj,:,ievent}));
            % check for empty arrays or nan
            if ~(nmrk_pre) || ~(nmrk_post)
                subj_ok(isubj,ievent) = 0;
            end
            %pre
            tfmean_tmp = [];
            tfmean_sess = [];
            for isess=1:length(sesspre)
                if ~isempty(tfmean_pre{isubj,isess,ievent})
                    tfmean_tmp(isess,:,:) = tfmean_pre{isubj,isess,ievent};
                end
            end
            if size(tfmean_tmp,1)>1
                Sp_mean_pre{isubj,ievent} = squeeze(mean(tfmean_tmp));
            else
                Sp_mean_pre{isubj,ievent} = squeeze(tfmean_tmp);
            end
            nmrk_tot_pre{isubj,ievent} = length(horzcat(dataspec_pre{isubj,:,ievent}));   

            % post
            tfmean_tmp = [];
            tfmean_sess = [];
            for isess=1:length(sesspost)
                if ~isempty(tfmean_post{isubj,isess,ievent})
                    tfmean_tmp(isess,:,:) = tfmean_post{isubj,isess,ievent};
                end
            end
            if size(tfmean_tmp,1)>1
                Sp_mean_post{isubj,ievent} = squeeze(mean(tfmean_tmp));
            else
                Sp_mean_post{isubj,ievent} = squeeze(tfmean_tmp);
            end
            nmrk_tot_post{isubj,ievent} = length(horzcat(dataspec_post{isubj,:,ievent}));

            if subj_ok(isubj,ievent)
                for isess=1:length(id_post)
                    nmrk_pre = size(dataspec_pre{isubj,isess,ievent},2);
                    if nmrk_pre
                        for imrk=1:nmrk_pre
                            try
                                tf_all_pre(isubj,isess,ievent,imrk,1:t_size,1:f_size) = dataspec_pre{isubj,isess,ievent}{imrk};
                            catch
                                warning(['Error at subject ' num2str(subj(isubj)) '; Event ' num2str(ievent) ...
                                    '; Session: ' num2str(isess) ' with matrix size of ' num2str(size(dataspec_pre{isubj,isess,ievent}{imrk}))])
                            end
                        end
                    end
                    nmrk_post = size(dataspec_post{isubj,isess,ievent},2);
                    if nmrk_post
                        for imrk=1:nmrk_post
                            try
                                tf_all_post(isubj,isess,ievent,imrk,1:t_size,1:f_size) = dataspec_post{isubj,isess,ievent}{imrk};
                            catch
                                warning(['Error at subject ' num2str(subj(isubj)) '; Event ' num2str(ievent) ...
                                    '; Session: ' num2str(isess) ' with matrix size of ' num2str(size(dataspec_post{isubj,isess,ievent}{imrk}))])
                            end
                        end
                    end
                end
            end
        end 
    end % loop subjects
    %save data 
    if save_data
        %beware, these are huge .mat files (long to make, but also big to save)
        save([dir_out 'prep_data_' freqband '.mat'],'tf_all_pre','tf_all_post',...
            'subj_ok','Sp_mean_pre','Sp_mean_post','nmrk_tot_pre','nmrk_tot_post', '-v7.3');
    end   
end

%% 
load([dir_out 'prep_data_' freqband '.mat']);
% ------------------------------------------------------------------------- 
%                              SECTION 
%                 BOOTSTRAP AND MANN-WHITNEY-WILCOXON
% -------------------------------------------------------------------------
if bts_wilcox
    disp('Bootstrapping and analyzing')
    for isubj=1:length(Dir.path)
        disp(['----- Sujet ' num2str(subj(isubj)) ' ------']);
        for ievent=1:2%length(behav{isubj}.ZoneNames)
            if subj_ok(isubj,ievent)
                disp(['--- Zone ' num2str(ievent) ' ---']); % ---> zones...
                % permute to place all single in front (subject and zones/events);original order->[isubj,isess,ievent,ichange,1:t_size,1:f_size]
                tf_prem_pre = permute(tf_all_pre,[1 3 2 4 5 6]);          
                tf_prem_post = permute(tf_all_post,[1 3 2 4 5 6]);
                % get rid of the singles 
                % the resulting variable should be 4D(session,markers,time,frequency)
                Sp_pre(:,:,:,:) = squeeze(tf_prem_pre(isubj,ievent,:,:,:,:));
                Sp_post(:,:,:,:) = squeeze(tf_prem_post(isubj,ievent,:,:,:,:));
                % call function to bootstrap the data and analyze (wilcoxon [could be changed to kolmogorov or ttest])
                if ~isempty(Sp_pre) || ~isempty(Sp_post) 
                    [wstats{isubj,ievent},bts_pre{isubj,ievent},bts_post{isubj,ievent}] = wilcox_bts(Sp_pre,Sp_post,t_size,lsfreq,draws);
                end
            end
        end
    end

    %save data from bts and wilcoxon
    if save_data
        %beware, these are huge .mat files (long to make, but also big to save)
        save([dir_out 'wilcoxon_bstrp_results_' freqband '.mat'],'bts_pre','bts_post','wstats', '-v7.3');
    end
end

%% 
% -------------------------------------------------------------------------
% LOADING...
load([dir_out 'wilcoxon_bstrp_results_' freqband '.mat']);
% ------------------------------------------------------------------------- 
%                               SECTION
%                   L O G I S T I C  R E G R E S S I O N
% -------------------------------------------------------------------------
nbsubj = length(Dir.path);
if regression
    % init var
    nbsubj = length(Dir.path);
    gains = 0; % for future second regressor (can be any measure each subject has)
    wnb=0; %for weigths regression

    % calculate weights 
    if w
        ii=0;
        for isubj=1:nbsubj   
            for igr=1:length(gr_tested)
                if subj_ok(isubj,igr)
                    if ~isempty(wstats{isubj,1}) && ~isempty(wstats{isubj,2}) %get rid of subject with no markers
                        ii=ii+1;
                        nbpre = length(find(tf_all_pre(isubj,:,igr,:,1,1)>0));
                        nbpost = length(find(tf_all_post(isubj,:,igr,:,1,1)>0));
                        sumwnb(1,ii) = (nbpre + nbpost);
                        ratiownb(1,ii) = 100-(abs(nbpre-nbpost)/(nbpre+nbpost))*100;
                    end
                end
            end
        end
        percwnb = (sumwnb./sum(sumwnb(1,:),2)).*100;
        ratiownb = ratiownb./sum(ratiownb(1,:),2).*100;
        wnb = percwnb + ratiownb;
    end

    % data for second regressor (empty for now) -> could be gains, performance
    % measure, temperature, HB, etc.
    datx2=[]; 

    % call linear regresssion function (glmfit)
    [Bintercept,Bgroup,pvalintercept,pvalgroup] = tfregression(nbsubj,wstats,datx2,wnb,t_size,f_size);

    % save regression outputs
    if save_data
        if w
            save([dir_out 'Regression_stats_' freqband '_weight.mat'],'Bintercept','Bgroup','pvalintercept','pvalgroup',...
                'windur','lsfreq','t_size','f_size');
        else
            save([dir_out 'Regression_stats_' freqband '_unweight.mat'],'Bintercept','Bgroup','pvalintercept','pvalgroup',...
                'windur','lsfreq','t_size','f_size');
        end
    end
end

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

%% FIGURE REGRESSION
    % loading datafor regression figure
    if w
        load([dir_out 'Regression_stats_' freqband '_weight.mat']);
    else
        load([dir_out 'Regression_stats_' freqband '_unweight.mat']);
    end
    
    %-- set variables for figures --
    try
        pvalue = alpha;
    catch 
        pvalue = .05;
    end
    if strcmp(freqband,'high')
%         B = Bgroup(512:718,1:34);
%         p = pvalgroup(512:718,1:34);%(410:820,1:34);
        B = Bgroup(:,:);
        p = pvalgroup(:,:);        
    else
        B = Bgroup(:,:);
        p = pvalgroup(:,:);
    end
    %-- correction FDR (requires function fdr_bh.m) --
    [p_masked p_fdr] = fdr_bh(p, pvalue);  
    %-- threshold/set direction of p --       
    B = B.*p_masked;
    
    %-- reformat window size --
    % can be used to constraint displayed window to a smaller size
    % to be done
    
    %% -----------DISPLAY--------------
    %-- init var
    params.freq = roundn(f_spec(1,:),-2);
    params.time = [-(windur/10):(windur/10*2)/(t_size-1):windur/10];
    
    %set caxes limits
    Bgroup_max = max(max(Bgroup))+max(max(Bgroup))*.05;
    Bgroup_min = min(min(Bgroup))-min(min(Bgroup))*.05;
    pvalgroup_max = max(max(pvalgroup))+max(max(pvalgroup))*.05;
    pvalgroup_min = min(min(pvalgroup))-min(min(pvalgroup))*.05;
    B_max = max(max(B))+max(max(B))*.05;
    B_min = min(min(B))-min(min(B))*.05;
    
    
    
    supertit = ['Contrast maps regression'];
    figure('Color',[1 1 1], 'rend','painters','pos',[10 10 2000 1000],'Name', supertit, 'NumberTitle','off')
    
        ax(1) = subplot(3,4,1:4);
            if strcmp(freqband,'high')
                 tftopo(Bgroup,params.time,params.freq,'limits',[-1*windur/10 windur/10 .1 200 Bgroup_min Bgroup_max]);%
%                 tftopo(Bgroup(512:718,:),params.time(512:718),params.freq,'limits',[-1*windur/10 windur/10 .1 200 Bgroup_min Bgroup_max]);%,'logfreq','on');
%                 tftopo(Bgroup(512:718,1:34),params.time(512:718),params.freq(1:34),'limits',[-1*windur/10 windur/10 .1 200 Bgroup_min Bgroup_max]);%,'logfreq','on');
            else
                tftopo(Bgroup,params.time,params.freq,'limits',[-1*windur/10 windur/10 .1 200 Bgroup_min Bgroup_max]);%,'logfreq','on');
            end             
            hold on
            colorbar;
            colormap(ax(1),bluewhitered)
            hold on
            xlabel('time (ms)')
            ylabel('frequency (Hz)')
            set(gca, 'FontSize',12)
            set(gca, 'YDir', 'normal')
            title('Un-corrected contrast regression map')
    
        ax(2) = subplot(3,4,5:8);
            if strcmp(freqband,'high')
                 tftopo(pvalgroup,params.time,params.freq(:),'limits',[-1*windur/10 windur/10 .1 200 pvalgroup_min pvalgroup_max]);
%                  tftopo(pvalgroup(512:718,:),params.time(512:718),params.freq(:),'limits',[-1*windur/10 windur/10 .1 200 pvalgroup_min pvalgroup_max]);%,'logfreq','on');
%                 tftopo(pvalgroup(512:718,1:34),params.time(512:718),params.freq(1:34),'limits',[-1*windur/10 windur/10 .1 200 pvalgroup_min pvalgroup_max]);%,'logfreq','on');
            else
                tftopo(pvalgroup(:,:),params.time(:),params.freq(:),'limits',[-1*windur/10 windur/10 .1 200 pvalgroup_min pvalgroup_max]);%,'logfreq','on');
            end
            hold on
            colorbar;
            colormap(ax(2),bluewhitered)
            hold on
            xlabel('time (ms)')
            ylabel('frequency (Hz)')
            set(gca, 'FontSize',12)
            set(gca, 'YDir', 'normal')
            title('Un-corrected regression p-values')
            
        ax(3) = subplot(3,4,9:12);
            if strcmp(freqband,'high')
                 tftopo(B,params.time,params.freq,'limits',[-1*windur/10 windur/10 .1 200 -1 1],'logfreq','on');  %needd to add for restriction of the window (time and freq)
%               tftopo(B(512:718,:),params.time(512:718),params.freq,'limits',[-1*windur/10 windur/10 .1 200 -1 1],'logfreq','on');  %needd to add for restriction of the window (time and freq)
%                 tftopo(B,params.time(512:718),params.freq(1:34),'limits',[-500 500 20 200 B_min B_max]);%,'logfreq','on');  %needd to add for restriction of the window (time and freq)
            else    
                tftopo(B,params.time,params.freq,'limits',[-1*windur/10 windur/10 4 20 B_min B_max]);%,'logfreq','on'); 
            end        
            hold on
            colorbar;
            colormap(ax(2),bluewhitered)
            hold on
            xlabel('time (ms)')
            ylabel('frequency (Hz)')
            set(gca, 'FontSize',12)
            set(gca, 'YDir', 'normal')
            title('Significant changes only (FDR)')
            
            
            %- save picture
            if w
                output_plot = ['linear_weigthed_bt_' freqband '_' num2str(pvalue) '.png'];
            else
                output_plot = ['linear_unweigthed_bt_' freqband '_' num2str(pvalue) '.png'];
            end
            fulloutput = [dir_out output_plot];
            print('-dpng',fulloutput,'-r600');
            
          
    
%% FIGURE REGRESSION - Beta change power between pre and post entry 
% ------   +/- 500 ms ----------
    winsz_t = .5;  % time in s
    winsz = floor((winsz_t*t_size)/((windur/1e4)*2)); % 100 msec
    mid = floor(t_size/2);
    if strcmp(freqband,'high')
        pwr_pre = Bgroup(mid-winsz:mid,:);
        pwr_post = Bgroup(mid:mid+winsz,:);
        f_size_tmp = f_size;
%         pwr_pre = Bgroup(mid-winsz:mid,1:34);
%         pwr_post = Bgroup(mid:mid+winsz,1:34);
%         f_size_tmp = 34;
    else
        pwr_pre = Bgroup(mid-winsz:mid,:);
        pwr_post = Bgroup(mid:mid+winsz,:);
        f_size_tmp= f_size;
    end
    % set axes limits
    ymax = max(max([std(pwr_pre) std(pwr_post)]))+max(max([mean(pwr_pre) mean(pwr_post)]));
    ymin = min(min([mean(pwr_pre) mean(pwr_post)]))-max(max([std(pwr_pre) std(pwr_post)]));
    
    % set number of x-axis ticks
    step=6;
    
    supertit = ['Contrast B-power by frequency from regression'];
    figure('Color',[1 1 1], 'rend','painters','pos',[10 10 800 600],'Name', supertit, 'NumberTitle','off')  

            hpre=shadedErrorBar([],pwr_pre,{@mean, @std},'-b',1);
            hold on 
            hpost=shadedErrorBar([],pwr_post,{@mean, @std},'-r',1);
            xlim([1 f_size_tmp]) 
            % long ass-multiline to set the ticks for the x-axis (play with
            % step above (number of ticks))
            set(gca,'Xtick',[1:floor(f_size_tmp/step):f_size_tmp],'XTickLabel', ...
                strsplit(num2str(floor([floor(f_spec(1)): ...
                (floor(f_spec(f_size_tmp))-floor(f_spec(1)))/(f_size_tmp/floor(f_size_tmp/step)):floor(f_spec(f_size_tmp))]))))
            xlabel('Frequency')
            ylim([ymin ymax])
            ylabel('B-power')
            legend([hpre.mainLine hpost.mainLine],{'pre-entry','post-entry'})
            title('B-power from regression by frequency (pre/post entry +/- 500ms)');      
        
        %- save picture
        if w
            output_plot = ['linear_weigthed_bt_Bpower_500ms_' freqband '_' num2str(pvalue) '.png'];
        else
            output_plot = ['linear_unweigthed_bt_Bpower_500ms_' freqband '_' num2str(pvalue) '.png'];
        end
        fulloutput = [dir_out output_plot];
        print('-dpng',fulloutput,'-r600');
        
% ------   +/- what you wish ms ----------
    winsz_t = .1;  % time in s
    gap = .1;  % time in second between the middle point and the window
    winsz = floor((winsz_t*t_size)/((windur/1e4)*2)); % 100 msec
    mid = floor(t_size/2);
    if strcmp(freqband,'high')
        pwr_pre = Bgroup(mid-winsz-gap:mid-gap,:);
        pwr_post = Bgroup(mid+gap:mid+gap+winsz,:);
        f_size_tmp= f_size;
        %f_size_tmp = 34;
    else
        pwr_pre = Bgroup(mid-winsz*2:mid-winsz,:);
        pwr_post = Bgroup(mid+winsz:mid+2*winsz,:);
        f_size_tmp= f_size;
    end
    % set axes limits
    ymax = max(max([std(pwr_pre) std(pwr_post)]))+max(max([mean(pwr_pre) mean(pwr_post)]));
    ymin = min(min([mean(pwr_pre) mean(pwr_post)]))-max(max([std(pwr_pre) std(pwr_post)]));
    
    step=6;
    
    supertit = ['Contrast B-power by frequency from regression'];
    figure('Color',[1 1 1], 'rend','painters','pos',[10 10 1250 1000],'Name', supertit, 'NumberTitle','off')  

        hpre=shadedErrorBar([],pwr_pre,{@mean, @std},'-b',1);
        hold on 
        hpost=shadedErrorBar([],pwr_post,{@mean, @std},'-r',1);
        xlim([1 f_size_tmp]) 
        % long ass-multiline to set the ticks for the x-axis (play with
        % step above (number of ticks))
        set(gca,'Xtick',[1:floor(f_size_tmp/step):f_size_tmp],'XTickLabel', ...
            strsplit(num2str(floor([floor(f_spec(1)): ...
            (floor(f_spec(f_size_tmp))-floor(f_spec(1)))/(f_size_tmp/floor(f_size_tmp/step)):floor(f_spec(f_size_tmp))]))))
        xlabel('Frequency')
        ylim([ymin ymax])
        ylabel('B-power')
        legend([hpre.mainLine hpost.mainLine],{'pre-entry','post-entry'})
        title(['B-power from regression by frequency (pre/post entry +/- ' num2str(gap*1000) ' to ' num2str(winsz_t*1000) 'ms)']);      

        %- save picture
        if w
            output_plot = ['linear_weigthed_bt_Bpower_100-200ms_' freqband '_' num2str(pvalue) '.png'];
        else
            output_plot = ['linear_unweigthed_bt_Bpower_100-200ms_' freqband '_' num2str(pvalue) '.png'];
        end
        fulloutput = [dir_out output_plot];
        print('-dpng',fulloutput,'-r600');
        
        
%% FIGURE ALL CONTRASTS

%------------------ complete time ----------------------

% set data
for igr=1:length(gr_tested)
    for isubj=1:nbsubj   
        if ~isempty(wstats{isubj,1}) && ~isempty(wstats{isubj,2}) %will not work well if more than 2 groups
            datset(igr,isubj,1:t_size,1:f_size)=wstats{isubj,igr};
        end
    end
    datset_mean(igr,1:t_size,1:f_size) = mean(datset(igr,:,:,:));    
end
% if strcmp(freqband,'high')
%    datset_mean = datset_mean(:,512:718,1:34);
% end
% set caxes limits
cmax = max(max(max(datset_mean)))+max(max(max(datset_mean)))*.05;
cmin = min(min(min(datset_mean)))-min(min(min(datset_mean)))*.05;

supertit = ['Stim zone Pre vs Post'];
figure('Color',[1 1 1], 'rend','painters','pos',[10 10 2000 1000],'Name', supertit, 'NumberTitle','off')

    ax(1) = subplot(3,4,1:4);
        if strcmp(freqband,'high')
%             tftopo(Bgroup(512:718,1:34),params.time(512:718),params.freq(1:34),'limits',[-1*windur/10 windur/10 .1 200 Bgroup_min Bgroup_max]);%,'logfreq','on');
            tftopo(Bgroup,params.time,params.freq,'limits',[-1*windur/10 windur/10 .1 200 Bgroup_min Bgroup_max],'smooth',2.5);%,'logfreq','on');
        else
            tftopo(Bgroup,params.time,params.freq,'limits',[-1*windur/10 windur/10 .1 200 Bgroup_min Bgroup_max],'smooth',2.5);%,'logfreq','on');
        end
        hold on
        colorbar;
        hold on
        xlabel('time (ms)')
        ylabel('frequency (Hz)')
        set(gca, 'FontSize',12)
        set(gca, 'YDir', 'normal')
        title('Un-corrected contrast regression map')
    
    ax(2) = subplot(3,4,5:8);
        if strcmp(freqband,'high')
%             tftopo(squeeze(datset_mean(1,:,:)),params.time(512:718),params.freq(1:34),'limits',[-1*windur/10 windur/10 .1 200 -25 25]); %,'logfreq','on');
            tftopo(squeeze(datset_mean(1,:,:)),params.time(:),params.freq(:),'limits',[-1*windur/10 windur/10 .1 200 cmin cmax]);%,'logfreq','on');
        else
            tftopo(squeeze(datset_mean(1,:,:)),params.time(:),params.freq(:),'limits',[-1*windur/10 windur/10 .1 200 cmin cmax]);%,'logfreq','on');
        end
        hold on
        colorbar;
        hold on
        xlabel('time (ms)')
        ylabel('frequency (Hz)')
        set(gca, 'FontSize',14)
        set(gca, 'YDir', 'normal')
        title('STIM zone entry')

    ax(3) = subplot(3,4,9:12);
        if strcmp(freqband,'high')
%             tftopo(squeeze(datset_mean(2,:,:)),params.time(512:718),params.freq(1:34),'limits',[-1*windur/10 windur/10 .1 200 -25 25]); %,'logfreq','on');
            tftopo(squeeze(datset_mean(2,:,:)),params.time,params.freq,'limits',[-1*windur/10 windur/10 .1 200 cmin cmax]); %,'logfreq','on');
        else
            tftopo(squeeze(datset_mean(2,:,:)),params.time,params.freq,'limits',[-1*windur/10 windur/10 .1 200 cmin cmax]); %,'logfreq','on');
        end
        hold on
        colorbar;
        colormap(bluewhitered)
        hold on
        xlabel('time (ms)')
        ylabel('frequency (Hz)')
        set(gca, 'FontSize',14)
        set(gca, 'YDir', 'normal')
        title('NO-STIM zone entry')

        %- save picture
        if w
            output_plot = ['AllContrasts_bt_' freqband '_' num2str(pvalue) '.png'];
        else
            output_plot = ['AllContrasts_bt_' freqband '_' num2str(pvalue) '.png'];
        end
        fulloutput = [dir_out output_plot];
        print('-dpng',fulloutput,'-r600');

%------------------ 500ms time ----------------------        
Bgroup_max = max(max(Bgroup))-max(max(Bgroup))*.05;
Bgroup_min = min(min(Bgroup))+min(min(Bgroup))*.05;
cmax = max(max(max(datset_mean)))-max(max(max(datset_mean)))*.05;
cmin = min(min(min(datset_mean)))+min(min(min(datset_mean)))*.05;

supertit = ['Stim zone Pre vs Post (+/-500ms)'];
figure('Color',[1 1 1], 'rend','painters','pos',[10 10 2000 1000],'Name', supertit, 'NumberTitle','off')

    ax(1) = subplot(3,4,1:4);
        if strcmp(freqband,'high')
%             tftopo(Bgroup(512:718,1:34),params.time(512:718),params.freq(1:34),'limits',[-1*windur/10 windur/10 .1 200 Bgroup_min Bgroup_max]);%,'logfreq','on');
            tftopo(Bgroup(512:718,:),params.time(512:718),params.freq,'limits',[-1*windur/10 windur/10 .1 200 Bgroup_min Bgroup_max],'smooth',2.5);%,'logfreq','on');
        else
            tftopo(Bgroup,params.time,params.freq,'limits',[-1*windur/10 windur/10 .1 200 Bgroup_min Bgroup_max],'smooth',2.5);%,'logfreq','on');
        end
        hold on
        colorbar;
        hold on
        xlabel('time (ms)')
        ylabel('frequency (Hz)')
        set(gca, 'FontSize',12)
        set(gca, 'YDir', 'normal')
        title('Un-corrected contrast regression map')
    
    ax(2) = subplot(3,4,5:8);
        if strcmp(freqband,'high')
%             tftopo(squeeze(datset_mean(1,:,:)),params.time(512:718),params.freq(1:34),'limits',[-1*windur/10 windur/10 .1 200 -25 25]); %,'logfreq','on');
            tftopo(squeeze(datset_mean(1,512:718,:)),params.time(512:718),params.freq(:),'limits',[-1*windur/10 windur/10 .1 200 cmin cmax]);%,'logfreq','on');
        else
            tftopo(squeeze(datset_mean(1,:,:)),params.time(:),params.freq(:),'limits',[-1*windur/10 windur/10 .1 200 cmin cmax]);%,'logfreq','on');
        end
        hold on
        colorbar;
        hold on
        xlabel('time (ms)')
        ylabel('frequency (Hz)')
        set(gca, 'FontSize',14)
        set(gca, 'YDir', 'normal')
        title('STIM zone entry')

    ax(3) = subplot(3,4,9:12);
        if strcmp(freqband,'high')
%             tftopo(squeeze(datset_mean(2,:,:)),params.time(512:718),params.freq(1:34),'limits',[-1*windur/10 windur/10 .1 200 -25 25]); %,'logfreq','on');
            tftopo(squeeze(datset_mean(2,512:718,:)),params.time(512:718),params.freq,'limits',[-1*windur/10 windur/10 .1 200 cmin cmax]); %,'logfreq','on');
        else
            tftopo(squeeze(datset_mean(2,:,:)),params.time,params.freq,'limits',[-1*windur/10 windur/10 .1 200 cmin cmax]); %,'logfreq','on');
        end
        hold on
        colorbar;
        colormap(bluewhitered)
        hold on
        xlabel('time (ms)')
        ylabel('frequency (Hz)')
        set(gca, 'FontSize',14)
        set(gca, 'YDir', 'normal')
        title('NO-STIM zone entry')

        %- save picture
        if w
            output_plot = ['AllContrasts_bt_1s_' freqband '_' num2str(pvalue) '.png'];
        else
            output_plot = ['AllContrasts_bt_1s_' freqband '_' num2str(pvalue) '.png'];
        end
        fulloutput = [dir_out output_plot];
        print('-dpng',fulloutput,'-r600');

     
%per mouse
% PRE
for isubj=1:length(Dir.path)
    supertit = ['Mouse ' num2str(subj(isubj))  ' - Pre-tests'];
    figure('Color',[1 1 1], 'rend','painters','pos',[10 10 800 1200],'Name', supertit, 'NumberTitle','off')
    for ievent=1:2%length(behav{isubj}.ZoneNames)-2
        if subj_ok(isubj,ievent) && ~isnan(sum(sum(Sp_mean_pre{isubj,ievent})))
            if sum(sum(Sp_mean_pre{isubj,ievent}))
                % get caxis lims
                CMax = max(max(Sp_mean_pre{isubj,ievent}))*1.00;
                CMin = min(min(Sp_mean_pre{isubj,ievent}))*0.98;
                
                subplot(2,2,2*ievent-1:2*ievent)
%                 subplot(length(behav{isubj}.ZoneNames)-2,2,2*ievent-1:2*ievent)
                    imagesc(Sp_mean_pre{isubj,ievent}'),axis xy, caxis([CMin CMax])
%                     set(gca,'Ytick',[1:40:f_size],'YtickLabel',num2cell(f_spec(1:40:f_size)));
                    set(gca,'Ytick',[1:floor(f_size_tmp/step):f_size_tmp],'YTickLabel', ...
                        strsplit(num2str(floor([floor(f_spec(1)): ...
                        (floor(f_spec(f_size_tmp))-floor(f_spec(1)))/(f_size_tmp/floor(f_size_tmp/step)):floor(f_spec(f_size_tmp))]))))
                    set(gca,'xtick',[])
                    prepX = num2cell([-1*(windur/1e4)*1000:1000:(windur/1e4)*1000]);
                    set(gca,'XTick',[0:t_size/(length(prepX)-1):t_size],'XtickLabel',prepX)
                    xline(t_size/2,'--r');
                    title(['Zone ' num2str(ievent) ' - n=' num2str(nmrk_tot_pre{isubj,ievent})])    
            else
                subplot(2,2,2*ievent-1:2*ievent)
%                 subplot(length(behav{isubj}.ZoneNames)-2,2,2*ievent-1:2*ievent)
                    % creating fake hidden plot(hugly but effective)
                    b2=bar([-2],[ 1],'FaceColor','flat');
                    title('No maps for this instance (without noise)')
            end
        end
    end
    
    % save figure
    if save_data
       print([dir_out 'pretests_' freqband '_' num2str(subj(isubj))], '-dpng', '-r300');
    end 
end % loop subjects

% POST
for isubj=1:length(Dir.path)
    supertit = ['Mouse ' num2str(subj(isubj))  ' - Post-tests'];
    figure('Color',[1 1 1], 'rend','painters','pos',[10 10 800 1200],'Name', supertit, 'NumberTitle','off')
    for ievent=1:2%length(behav{isubj}.ZoneNames)-2
        if subj_ok(isubj,ievent) &&  ~isnan(sum(sum(Sp_mean_pre{isubj,ievent})))
            if sum(sum(Sp_mean_post{isubj,ievent}))
                % get caxis lims
                CMax = max(max(Sp_mean_post{isubj,ievent}))*1.00;
                CMin = min(min(Sp_mean_post{isubj,ievent}))*0.98;
                
                subplot(2,2,2*ievent-1:2*ievent)
%                 subplot(length(behav{isubj}.ZoneNames)-2,2,2*ievent-1:2*ievent)
                    imagesc(Sp_mean_post{isubj,ievent}'),axis xy, caxis([CMin CMax])
                    hold on
%                     set(gca,'Ytick',[1:40:f_size],'YtickLabel',num2cell(f_spec(1:40:f_size)));
                    set(gca,'Ytick',[1:floor(f_size_tmp/step):f_size_tmp],'YTickLabel', ...
                        strsplit(num2str(floor([floor(f_spec(1)): ...
                        (floor(f_spec(f_size_tmp))-floor(f_spec(1)))/(f_size_tmp/floor(f_size_tmp/step)):floor(f_spec(f_size_tmp))]))))
                    prepX = num2cell([-1*(windur/1e4)*1000:1000:(windur/1e4)*1000]);
                    set(gca,'XTick',[0:t_size/(length(prepX)-1):t_size],'XtickLabel',prepX)
                    xline(t_size/2,'--r');
                    title(['Zone ' num2str(ievent) ' - n=' num2str(nmrk_tot_post{isubj,ievent})])             
            else
                subplot(2,2,2*ievent-1:2*ievent)
%                 subplot(length(behav{isubj}.ZoneNames)-2,2,2*ievent-1:2*ievent)
                    % creating fake hidden plot(hugly but effective)
                    b2=bar([-2],[ 1],'FaceColor','flat');
                    title('No maps for this instance (without noise)')
            end
        end
    end 

    % save figure
    if save_data
       print([dir_out 'posttests_' freqband '_' num2str(subj(isubj))], '-dpng', '-r300');
    end 
end % loop subjects
end
