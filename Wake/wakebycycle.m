function [figH wake] = wakebycycle(Dir, expe, mice_num, varargin)

%==========================================================================
% Details: main wrappper for wake study (in cycles) for ECR project
%
% INPUTS:
%       - Dir               includes all directories for each experiment
%                           Format:
%                           Dir{<exp1>,<exp2>}.path{<mouse1>},{<mouse2a>,<mouse2b>},{<mouse3>},
%                           ...}
%       - expe              Name of experiment in PathForExperiment
%                           Format:
%                               expe = {'ExpeName1','ExpeName2'};
%       - mice_num          ID # of all mice for the analyses
%                           Format:
%                               mice_num = {[mouse1 mouse2 mouse3],[mouse1 mouse2]};
% OPTIONAL:
%       - remparams         times for cycle definition.
%                           time 1: merge REM intervals (in seconds)
%                           time 2: drop REM intervals (in seconds)
%                           Format: [timeMERGE timeDROP]
%
% OUTPUT:
%       -figH               Figures handles (for saving)
%       -wake               Global strutures with all variables
%
% NOTES: none
%
%   Written by Samuel Laventure - 2022-03
%      
%==========================================================================

% parsing varargin
for i = 1:2:length(varargin)
    if ~ischar(varargin{i})
        error(['Parameter ' num2str(i+2) ' is not a property.']);
    end
    switch(lower(varargin{i}))
        case 'remparams'
            remparams = varargin{i+1};
            if ~(length(remparams)==2)
                error('remparams needs 2 parameters: [TimeMergeREM TimeDropREM].');
            end
        case 'plotfig'
            plotfig = varargin{i+1};
            if ~(plotfig==1) && ~(plotfig==0)
                error('plotfig argument should be either 0 or 1');
            end
        otherwise
            error(['Unknown property ''' num2str(varargin{i}) '''.']);
    end
end

%check if exist and assign default value if not
% parameters to define cycles
if ~exist('remparams','var')
    remparams = [0 0];
end
if ~exist('plotfig','var')
    plotfig = 1;
end

% get experiment names
for iexp=1:length(expe)
    switch expe{iexp}
        case 'StimMFBWake'
            expname{iexp}='MFB';
        case 'Novel'
            expname{iexp}='Novel';
        case 'UMazePAG'
            expname{iexp}='PAG';
        case 'Known'
            expname{iexp}='Known';
        case 'BaselineSleep'
            expname{iexp}='BaselineSleep';
        otherwise
            expname{iexp}=expe{iexp};
    end
end

% var init
stageName = {'NREM','REM','Wake'};
colori = {[0 0 .8], [.8 0 0], [0 0 0]}; % for hypnogram

%%
%#####################################################################
%#                           M  A  I  N
%#####################################################################

for iexp=1:length(expe)
    disp(['   Experiment: ' expname{iexp}])
    disp('     Getting data for:')
    nsuj=0;
    for isuj = 1:length(Dir{iexp}.path)
        for iisuj=1:length(Dir{iexp}.path{isuj})
            nsuj=nsuj+1;
            disp(['            M' num2str(mice_num{iexp}(nsuj))])
            
            % get sleep epoch by stage
            % from "get_SleepEpoch" but with noise
            try
                load([Dir{iexp}.path{isuj}{iisuj} 'SleepScoring_OBGamma.mat'], ...
                    'WakeWiNoise', 'SWSEpochWiNoise', 'REMEpochWiNoise','Epoch');
            catch
                load([Dir{iexp}.path{isuj}{iisuj} 'SleepScoring_Accelero.mat'], ...
                    'WakeWiNoise', 'SWSEpochWiNoise', 'REMEpochWiNoise','Epoch');
            end 
            tmpEpoch{1} = SWSEpochWiNoise;                   % nrem
            tmpEpoch{2} = REMEpochWiNoise;                   % rem
            tmpEpoch{3} = WakeWiNoise;                       % wake
            clear WakeWiNoise SWSEpochWiNoise REMEpochWiNoise

            % seperate session pre vs post if there are any
            try  % try, because some don't have behavResources. If not there it is considered that there is no pre/post session
                load([Dir{iexp}.path{isuj}{iisuj} 'behavResources.mat'], 'SessionEpoch'); 
            end
            if exist('SessionEpoch','var') % if doesnt exist then it is a Baseline session
                try
                    SleepEpochs.pre = SessionEpoch.PreSleep;
                catch
                    SleepEpochs.pre = SessionEpoch.Baseline;
                end
                SleepEpochs.post = SessionEpoch.PostSleep;

                % restrict to pre/post sessions
                for istage=1:3
                    sEpoch{1,istage} = and(tmpEpoch{istage},SleepEpochs.pre);     
                    sEpoch{2,istage} = and(tmpEpoch{istage},SleepEpochs.post);    
                end
                sSession{1} = SleepEpochs.pre;
                sSession{2} = SleepEpochs.post;
                nsess=2;
            else
                for istage=1:3
                    sEpoch{1,istage} = tmpEpoch{istage};
                end
                st = Start(Epoch); en = End(Epoch);
                sSession{1} = intervalSet(st(1),en(end));
                nsess=1;
            end   

            disp('Done.')
            disp('-------------------')
            disp('Prep data for figure')

            % get sleep cycles
            cycleEpoch = get_sleepcycles(sEpoch,sSession,remparams);
            % get wake episodes for each cycle
            for isess=1:nsess
                for icycle=1:size(cycleEpoch{isess},2)
                    if ~isempty(cycleEpoch{isess}{icycle})
                        eplen_tmp{isess}{icycle}(1)=0;
                        wakeCycle{isess,icycle} = and(cycleEpoch{isess}{icycle},sEpoch{isess,3});
                        st = Start(wakeCycle{isess,icycle});
                        en = End(wakeCycle{isess,icycle});
                        for iep=1:length(st)
                            eplen_tmp{isess}{icycle}(iep) = (en(iep)-st(iep))/1e4; 
                        end
                        clear st en
                    end
                end
                % create zeros matrix for wake episode length
                [~,d] = cellfun(@size,eplen_tmp{isess});
                maxsz = max(d);
                clear d
                ep_len{isess} = zeros(size(cycleEpoch{isess},1),maxsz);
                % fill matrix (if nothing = 0)
                for icycle=1:length(cycleEpoch{isess})
                    for iep=1:length(eplen_tmp{isess}{icycle})
                        ep_len{isess}(icycle,iep) = eplen_tmp{isess}{icycle}(iep);
                    end
                    ncyc(isess) = icycle;
                end
                maxtot(isess) = max(sum(ep_len{isess},2));
            end        

            % get total durations and wake density
            for isess=1:nsess
                totdur(isess) = (End(sSession{isess})-Start(sSession{isess}))/1e4;
                wakeden(isess) = sum(End(sEpoch{isess,3})-Start(sEpoch{isess,3}))/1e4 ...
                    / totdur(isess)*100; 
                numcyc{isess} = [1:ncyc(isess)]; % yticks
            end

            % Hypno data
            for isess=1:nsess
                allepochs{isess} = {sEpoch{isess,1},sEpoch{isess,2},sEpoch{isess,3}};
                ep_tsd{isess} = CreateSleepStages_tsd(allepochs{isess});
                % set colors
                for icycle=1:length(cycleEpoch{isess})
                    if ~(rem(icycle,2))
                        colorCyc{isess,icycle} = [0 0 0];
                    else
                        colorCyc{isess,icycle} = [.5 .5 .5];
                    end
                end
            end

            % Measurments
            for isess=1:nsess
                waketotdur{isess} = sum(ep_len{isess},2);
                for icycle=1:length(cycleEpoch{isess})
                    nwake{isess}(icycle) = length(Start(wakeCycle{isess,icycle}));
                end
            end
            if nsess==2
                [a b] = waketotdur{:};
                [c d] = nwake{:};
            else
                a = waketotdur{:}; b=[];
                c = nwake{:}; d=[];
            end
            xmax_totdur = max([a; b])+max([a; b])*.15;
            xmax_nwake = max([c d])+max([c d])*.15;

            % store data
            wake.sEpoch{iexp,nsuj} = sEpoch;
            wake.sSession{iexp,nsuj} = sSession;
            wake.cycleEpoch{iexp,nsuj} = cycleEpoch;
            wake.wakeCycles{iexp,nsuj} = wakeCycle;  
            wake.waketotdur{iexp,nsuj} = waketotdur;
            wake.nwake{iexp,nsuj} = nwake;
            wake.ep_len{iexp,nsuj} = ep_len;
            wake.info.exp = expe;
            wake.info.mice_num = mice_num;
            wake.info.remparams = remparams;

    %%
    %#####################################################################
    %#                     P L O T T I N G
    %#####################################################################
            if plotfig
                disp('Plotting...')

                % prep data for figures
                xmax = max(maxtot); % get max for the time axis
                if nsess==1, plotsize=800; else plotsize=1600; end


                supertit = [expname{iexp} ' - M' num2str(mice_num{iexp}(nsuj)) ' - Wake episodes by cycle'];
                figH{iexp,nsuj} = figure('Color',[1 1 1], 'rend','painters','pos',[1 1 plotsize 2000], ...
                    'Name', supertit, 'NumberTitle','off'); 
                    % set axes
                    if nsess==1 
                        ax_hypno{1}     = axes('position', [.1 .75 .8 .15]);
                        ax_wakecycle{1} = axes('position', [.1 .1 .65 .6]);
                        ax_vertplot{1}  = axes('position', [.8 .1 .1 .6]);
                        annpos(1) = .28;
                        maintit = .28;
                    else
                        ax_hypno{1}     = axes('position', [.05 .75 .4 .15]);
                        ax_wakecycle{1} = axes('position', [.05 .1 .25 .6]);
                        ax_vertplot{1}  = axes('position', [.35 .1 .1 .6]);
                        ax_hypno{2}     = axes('position', [.55 .75 .4 .15]);
                        ax_wakecycle{2} = axes('position', [.55 .1 .25 .6]);
                        ax_vertplot{2}  = axes('position', [.85 .1 .1 .6]);
                        annpos(1) = .1;
                        annpos(2) = .6 ;
                        maintit = .43;
                    end

                    for isess=1:nsess
                        % HYPNO
                        axes(ax_hypno{isess})
                            for icycle=1:length(cycleEpoch{isess})
                                plot([Start(cycleEpoch{isess}{icycle})/1e4/3600 End(cycleEpoch{isess}{icycle})/1e4/3600],...
                                    [3.5 3.5],'LineWidth',5,'Color',colorCyc{isess,icycle})
                                hold on
                            end
                            ylim([0.5 3+1])
                            plot(Range(ep_tsd{isess},'s')/3600,Data(ep_tsd{isess}),'k',...
                                'LineWidth',.25,'color',[.9 .9 .9])
                            hold on
                            for ep=1:length(allepochs{isess})
                                plot(Range(Restrict(ep_tsd{isess},allepochs{isess}{ep}),'s')/3600, ...
                                    Data(Restrict(ep_tsd{isess},allepochs{isess}{ep})), ...
                                    '.','Color',colori{ep}) 
                                hold on
                            end
                            xlim([Start(sSession{isess})/1e4/3600 End(sSession{isess})/1e4/3600]) 
                            xlabel('Time (h)')
                            set(gca,'TickLength',[0 0])
                            ytick_substage = 1:3; %ordinate in graph
                            ylabel_substage = stageName;
                            set(gca,'Ytick',ytick_substage,'YTickLabel',ylabel_substage)
                            if nsess>1, title({['Session ' num2str(isess)]},'FontSize',16); end

                        % WAKE BY CYCLE
                        axes(ax_wakecycle{isess})
                            if size(ep_len{isess},1)>1
                                barh(ep_len{isess},'stacked')
                            else
                                barh([1;nan],[ep_len{isess};nan(1,length(ep_len{isess}))],'stacked')
                            end
                                yticks(numcyc{isess}) 
                                ylabel({'Sleep','cycles'},'FontSize',16)
                                xlim([0 xmax+xmax*.1])
                                xlabel('time (s)','FontSize',16)
                                ax=gca;
                                set(ax, 'Ydir', 'reverse')

                        % MEASURMENTS (VERTICAL)
                        axes(ax_vertplot{isess})
                            p1=plot(waketotdur{isess},[1:length(cycleEpoch{isess})]);
                                p1.Color=[.85 .3250 .0980];
                                ylim([0 length(cycleEpoch{isess})+1]) 
                                yticks([1:length(cycleEpoch{isess})]) 
                                set(gca, 'Ydir', 'reverse') 
                                set(gca,'Xcolor',[.85 .3250 .0980])
                                xlabel('total wake (s)','FontSize',8)
                                xlim([0 xmax_totdur])
                                set(gca,'box','off')

                            hAx(1) = gca;
                            hAx(2) = axes('Position',hAx(1).Position,'XAxisLocation','top', ...
                                'YAxisLocation','right','color','none');
                            hold(hAx(2),'on')  

                            p2=plot(nwake{isess},[1:length(cycleEpoch{isess})]);
                                p2.Color = [0 .447 .741];
                                ylim([0 length(cycleEpoch{isess})+1])  
                                yticks([1:length(cycleEpoch{isess})])
                                set(gca, 'Ydir', 'reverse') 
                                set(gca,'Xcolor',[0 .447 .741])
                                xlabel('number wake episode','FontSize',8)
                                xlim([0 xmax_nwake])

                        % add annotation - session duration and desity of wake
                        dim = [annpos(isess) .04 0.01 0.01];
                        str = {['Session duration (sec): ' num2str(floor(totdur(isess)))], ...
                            ['Wake (%): ' num2str(floor(wakeden(isess)))]};
                        annotation('textbox',dim,'String',str,'FitBoxToText','on',...
                            'EdgeColor',[1 1 1],'BackgroundColor',[.9 .9 .9]);
                    end
                    % annotation mouse and exp
                    dim = [maintit .96 0.01 0.01];
                    str = [expname{iexp} ' - M' num2str(mice_num{iexp}(nsuj))];
                    annotation('textbox',dim,'String',str,'FitBoxToText','on',...
                        'EdgeColor',[1 1 1],'BackgroundColor',[1 1 1],...
                        'FontSize',20,'FontWeight','bold');
            else
                figH{iexp,nsuj} = nan;
            end
            clear cycleEpoch wakeCycle ep_len eplen_tmp sEpoch sSession nwake
        end
    end
end

disp(' ')
disp('Done')


    

