function [figH wake] = wakebycycle_erc(expe,mice_num)

%==========================================================================
% Details: main wrappper for wake study (in cycles) for ECR project
%
% INPUTS:
%       - expe              Name of experiment in PathForExperiment
%       - mice_num          ID # of all mice for the analyses
%
% OUTPUT:
%       -figH               Figures handles (for saving)
%       -wake              Global strutures with all variables
% NOTES:
%
%   Written by Samuel Laventure - 2022-03
%      
%==========================================================================

%% Parameters
for iexp=1:length(expe)
    switch expe{iexp}
        case 'StimMFBWake'
            expname{iexp}='MFB';
            erc=1;
        case 'Novel'
            expname{iexp}='Novel';
            erc=1;
        case 'UMazePAG'
            expname{iexp}='PAG';
            erc=1;
        case 'Known'
            expname{iexp}='Known';
            erc=1;
        case 'BaselineSleep'
            expname{iexp}='BaselineSleep';
            erc=1;
        otherwise
            expname{iexp}=expe{iexp};
            erc=0;
    end
    if erc
        Dir{iexp} = PathForExperimentsERC(expe{iexp});
    else
        Dir{iexp} = PathForExperiments_Opto_MC(expe{iexp});
    end
    Dir{iexp} = RestrictPathForExperiment(Dir{iexp}, 'nMice', unique(mice_num{iexp}));
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
            try
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
        end

        disp('Done.')
        disp('-------------------')
        disp('Prep data for figure')
        
        % get sleep cycles
        cycleEpoch = get_sleepcycles(sEpoch,sSession,120);
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
        wake.sEpoch{iexp,isuj} = sEpoch;
        wake.sSession{iexp,isuj} = sSession;
        wake.cycleEpoch{iexp,isuj} = cycleEpoch;
        wake.cycles{iexp,isuj} = wakeCycle;  
        wake.waketotdur{iexp,isuj} = waketotdur;
        wake.nwake{iexp,isuj} = nwake;
        wake.ep_len{iexp,isuj} = ep_len;
        
%%
%#####################################################################
%#                     P L O T T I N G
%#####################################################################
        disp('Plotting...')
        
        % prep data for figures
        xmax = max(maxtot); % get max for the time axis
        if nsess==1, plotsize=800; else plotsize=1600; end
        
        
        supertit = [expname{iexp} ' - M' num2str(mice_num{iexp}(isuj)) ' - Wake episodes by cycle'];
        figH{iexp,isuj} = figure('Color',[1 1 1], 'rend','painters','pos',[1 1 plotsize 2000], ...
            'Name', supertit, 'NumberTitle','off'); 
            % set axes
            if nsess==1 
                ax_hypno{1}     = axes('position', [.1 .75 .8 .15]);
                ax_wakecycle{1} = axes('position', [.1 .1 .65 .6]);
                ax_vertplot{1}  = axes('position', [.8 .1 .1 .6]);
                annpos(1) = .35;
            else
                ax_hypno{1}     = axes('position', [.05 .75 .4 .15]);
                ax_wakecycle{1} = axes('position', [.05 .1 .25 .6]);
                ax_vertplot{1}  = axes('position', [.35 .1 .1 .6]);
                ax_hypno{2}     = axes('position', [.55 .75 .4 .15]);
                ax_wakecycle{2} = axes('position', [.55 .1 .25 .6]);
                ax_vertplot{2}  = axes('position', [.85 .1 .1 .6]);
                annpos(1) = .1;
                annpos(2) = .6 ;
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
                    title({['Session ' num2str(isess)]},'FontSize',16) 
                
                % WAKE BY CYCLE
                axes(ax_wakecycle{isess})
                    barh(ep_len{isess},'stacked')
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
            dim = [.43 .96 0.01 0.01];
            str = [expname{iexp} ' - M' num2str(mice_num{iexp}(isuj))];
            annotation('textbox',dim,'String',str,'FitBoxToText','on',...
                'EdgeColor',[1 1 1],'BackgroundColor',[1 1 1],...
                'FontSize',20,'FontWeight','bold');
        clear cycleEpoch wakeCycle ep_len eplen_tmp sEpoch sSession nwake
    end
end

disp(' ')
disp('Done')


    

