function figH = sam_sleep_prevspost_bysess(expe, subj, numexpe, varargin)
%==========================================================================
% Details: Output details about sleep pre and post sessions
%
% INPUTS:
%       - expe              Name of the experiment in PathForExperiment
%       - subj              Mice number to analyze
%      
%   OPTIONS:
%       - stim              Default: 0; Put to 1 if you have stim during
%                           sleep
%
% OUTPUT:
%       - figure including:
%           - Pre vs Post sleep % per subject
%           - Pre and post hypnogram per subject
%           - Pre vs post sleep percentage and duration for all subject
%           (mean)
%
% NOTES:
%
%   Original written by Samuel Laventure - 02-07-2019
%   Modified on by SL - 29-11-2019, 2020-12
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
        otherwise
            error(['Unknown property ''' num2str(varargin{i}) '''.']);
    end
end

%check if exist and assign default value if not
%Is there stim in this session
if ~exist('stim','var')
    stim=0;
end


%% Parameters
% Get directories
Dir = PathForExperimentsERC(expe);
% if strcmp(expe,'StimMFBWake') || strcmp(expe,'Novel')
%     Dir = PathForExperimentsERC_SL(expe);
% elseif strcmp(expe,'UMazePAG') 
%     Dir = PathForExperimentsERC_Dima(expe);
% else    
%     warning('Exited. Verify experiment name');
%     return
% end
Dir = RestrictPathForExperiment(Dir,'nMice', unique(subj));

% get sessions id and timepoints

if strcmp(expe,'BaselineSleep')
    for isubj=1:length(numexpe)
        load([Dir.path{isubj,numexpe(isubj)}{1} 'behavResources.mat'],'SleepEpochs');
        tdatpre{isubj,numexpe(isubj)}{1} = SleepEpochs.pre;
        tdatpost{isubj,numexpe(isubj)}{1} = SleepEpochs.post;
    end
else
    try
        [id_pre tdatpre] = RestrictSession(Dir,'PreSleep');  %add variable for session to call
    catch
        [id_pre tdatpre] = RestrictSession(Dir,'BaselineSleep');
    end
    [id_post tdatpost] = RestrictSession(Dir,'PostSleep');
end
 
%#####################################################################
%#                           M A I N
%#####################################################################
% check if all mice have substages processed and load substaging
for isubj=1:length(numexpe)
    for iexp=1:length(Dir.path{isubj})
        cd(Dir.path{1,isubj}{iexp})
        try
            substg{isubj} = load([pwd '/SleepSubstages.mat'],'Epoch_sess');
            disp(['...loading substages for mouse ' num2str(isubj)])
            ss(isubj) = 1;
        catch
            ss(isubj) = 0;
        end
    end
end

for isubj=1:length(numexpe)
    for iexp=1:length(Dir.path{isubj})
        cd(Dir.path{1,isubj}{iexp})
        % load variables
        if ss(isubj)   
            ssnb=5;
            ssnames = {'N1','N2','N3','REM','W'};
            ssnames_now = {'N1','N2','N3','REM'};
        else
            ssnb=3;
            ssnames = {'NREM','REM','W'};
            ssnames_now = {'NREM','REM'};
            try 
                sscoring = load('SleepScoring_OBGamma.mat','REMEpoch','SWSEpoch','Wake');
                disp('...loading sleep variables from OBGamma')
            catch
                sscoring = load('SleepScoring_Accelero.mat','REMEpoch','SWSEpoch','Wake');
                disp('...loading sleep variables from Accelero')
            end
        end

        if stim
            stims = load('StimSent.mat');
            disp('...loading stimulations');
        end
        % load LFP to be able to create the sleepstage variable
        LFP = load('LFPData/LFP1.mat', 'LFP');

        %pre 
        if ss(isubj) 
            [pre_n1, pre_n2, pre_n3, pre_rem, pre_wake] = get_subscoring(substg{isubj}.Epoch_sess{1},tdatpre{isubj,numexpe(isubj)}{1});
            pre_Epochs = {pre_n1,pre_n2,pre_n3,pre_rem,pre_wake};
        else
            [pre_rem, pre_nrem, pre_wake] = get_sleepscoring(isubj,sscoring,tdatpre);
            pre_Epochs = {pre_nrem,pre_rem,pre_wake};
        end
        pre_SleepStages = CreateSleepStages_tsd(pre_Epochs);

        %post
        if ss(isubj) 
            [post_n1, post_n2, post_n3, post_rem, post_wake] = get_subscoring(substg{isubj}.Epoch_sess{2},tdatpost{isubj,numexpe(isubj)}{1});
            post_Epochs = {post_n1,post_n2,post_n3,post_rem,post_wake};
        else
            [post_rem, post_nrem, post_wake] = get_sleepscoring(isubj,sscoring,tdatpost);
            post_Epochs = {post_nrem,post_rem,post_wake};
        end
        post_SleepStages = CreateSleepStages_tsd(post_Epochs);

        % prep figure data - hypnograms
        pre_start = Start(tdatpre{isubj,numexpe(isubj)}{1})/1e4/3600;
        pre_end = End(tdatpre{isubj,numexpe(isubj)}{1})/1e4/3600;

        post_start = Start(tdatpost{isubj,numexpe(isubj)}{1})/1e4/3600;
        post_end = End(tdatpost{isubj,numexpe(isubj)}{1})/1e4/3600;

        if ss(isubj)
            colori = {[.2 .6 1], [.0 .4 1], [.0 .0 1], [.6 .0 1], [1 .4 .4]}; %substage color
        else
            colori = {[0 0 0], [.85 .85 .85], [.95 .95 .95]}; %substage color
        end

        %prep figure data - barplot
        predur(isubj) = sum(End(tdatpre{isubj,numexpe(isubj)}{1}) - Start(tdatpre{isubj,numexpe(isubj)}{1}));
        postdur(isubj) = sum(End(tdatpost{isubj,numexpe(isubj)}{1}) - Start(tdatpost{isubj,numexpe(isubj)}{1}));
        % same without wake
        if ss(isubj), wpos=5; else wpos=3; end
        predur_now(isubj) = predur(isubj)-(sum(End(pre_Epochs{wpos}) - Start(pre_Epochs{wpos})));
        postdur_now(isubj) = postdur(isubj)-(sum(End(post_Epochs{wpos}) - Start(post_Epochs{wpos})));

        %latency to sleep
        if ss(isubj)
            stsleep_pre = Start(or(or(pre_n1,pre_n2),pre_n3));
            stsleep_post = Start(or(or(post_n1,post_n2),post_n3));       
        else
            stsleep_pre = Start(pre_nrem);
            stsleep_post = Start(post_nrem); 
        end
        stsess{1}=Start(tdatpre{isubj,numexpe(isubj)}{1}); stsess{2}=Start(tdatpost{isubj,numexpe(isubj)}{1});
        lat(isubj,1) = (stsleep_pre(1)-stsess{1}(1))/60E4;
        lat(isubj,2) = (stsleep_post(1)-stsess{2}(1))/60E4;

        % stage durations
        for istages=1:ssnb
            stagdur(1,istages) = sum(End(pre_Epochs{istages})-Start(pre_Epochs{istages}));
            stagdur(2,istages) = sum(End(post_Epochs{istages})-Start(post_Epochs{istages}));
            stagperc(1,istages) = stagdur(1,istages)/predur(isubj)*100;
            stagperc(2,istages) = stagdur(2,istages)/postdur(isubj)*100;
            if istages < ssnb
                % without wake
                stagperc_now(1,istages) = stagdur(1,istages)/predur_now(isubj)*100;
                stagperc_now(2,istages) = stagdur(2,istages)/postdur_now(isubj)*100;
            end
        end

        % for all mice
        stagdur_part(isubj,:,:) = stagdur;
        stagperc_part(isubj,:,:) = stagperc;

        % get delta waveforms
        if ss(isubj)
            % load data
            load([pwd '/DeltaWaves.mat'],'deltas_pre','deltas_post', ...
                    'Msup_short_delta_pre','Msup_short_delta_pre', ...
                    'Msup_long_delta_pre','Msup_long_delta_pre', ....
                    'Mdeep_short_delta_pre','Mdeep_short_delta_pre', ...
                    'Mdeep_long_delta_pre','Mdeep_long_delta_pre', ...
                    'Msup_short_delta_post','Msup_short_delta_post', ...
                    'Msup_long_delta_post','Msup_long_delta_post', ....
                    'Mdeep_short_delta_post','Mdeep_short_delta_post', ...
                    'Mdeep_long_delta_post','Mdeep_long_delta_post');
            load([pwd '/ChannelsToAnalyse/PFCx_deltadeep.mat']);
            load([pwd '/LFPData/LFP' num2str(channel) '.mat']);
%             %pre
%             dsta = Start(deltas_pre);
%             dend = End(deltas_pre);
%             dmid = ((dend-dsta)/2 + dsta)/1e4;
%             % extract waveforms
%     %         [Mpre{isubj} Tpre{isubj}] = PlotRipRaw(Restrict(LFP,tdatpre{isubj}{1}),dmid,500,0,0,0);        
%             %post
%             dsta = Start(deltas_post);
%             dend = End(deltas_post);
%             dmid = ((dend-dsta)/2 + dsta)/1e4;
%             [Mpost{isubj} Tpost{isubj}] = PlotRipRaw(Restrict(LFP,tdatpost{isubj,numexpe(isubj)}{1}),dmid,500,0,0,0);
        end


        %%
        % #####################################################################
        % #             F I G U R E S    B Y   S E S S I O N S
        % #####################################################################
        % hypnogram
        supertit = ['Mouse ' num2str(subj(isubj))  ' - Hypnograms'];
        figH.SleepArch_single{isubj} = figure('Color',[1 1 1], 'rend','painters','pos', ...
            [10 10 1650 1200],'Name', supertit, 'NumberTitle','off');
            % set axes position
            preS = axes('position', [.05 .68 .6 .23]);
            preD = axes('position', [.725 .68 .25 .23]);
            postS = axes('position', [.05 .35 .6 .23]);
            postD = axes('position', [.725 .35 .25 .23]);
    %         bmin = axes('position', [.15 .08 .285 .18]);
    %         bperc = axes('position', [.565 .08 .285 .18]); 
            bmin = axes('position', [.15 .08 .125 .18]);
            bperc = axes('position', [.375 .08 .125 .18]); 
            bperc_nowake = axes('position', [.6 .08 .125 .18]);

            % plot hypnograms
            axes(preS)
                plot(Range(pre_SleepStages,'s')/3600,Data(pre_SleepStages),'k')
                hold on
                for ep=1:length(pre_Epochs)
                    plot(Range(Restrict(pre_SleepStages,pre_Epochs{ep}),'s')/3600 ,Data(Restrict(pre_SleepStages,pre_Epochs{ep})),'.','Color',colori{ep}), hold on,
                end
                xlim([pre_start pre_end]) 
                xlabel('Time (h)')
                set(gca,'TickLength',[0 0])
                ytick_substage = 1:ssnb; %ordinate in graph
                ylim([0.5 ssnb+0.5])
                ylabel_substage = ssnames;
                set(gca,'Ytick',ytick_substage,'YTickLabel',ylabel_substage)
                title('Pre-sleep','FontSize',14,'FontWeight','bold'); 

            axes(postS)
                plot(Range(post_SleepStages,'s')/3600,Data(post_SleepStages),'k') 
                hold on
                for ep=1:length(post_Epochs)
                    plot(Range(Restrict(post_SleepStages,post_Epochs{ep}),'s')/3600 ,Data(Restrict(post_SleepStages,post_Epochs{ep})),'.','Color',colori{ep}), hold on,
                end
                % stim markers
                if stim 
                    plot(Start(stims.StimSent)/1e4/3600,3.25,'g*')
                end
                xlim([post_start post_end]) 
                xlabel('Time (h)')      
                set(gca,'TickLength',[0 0])
                ytick_substage = 1:ssnb; %ordinate in graph
                ylim([0.5 ssnb+0.5])
                ylabel_substage = ssnames;
                set(gca,'Ytick',ytick_substage,'YTickLabel',ylabel_substage)
                title('Post-sleep','FontSize',14,'FontWeight','bold'); 

                if stim
                    %annotation
                    dim = [.8 .22 .3 .3];
                    str = sprintf(['Stimulations: * \nNumber of stim: ' num2str(stims.nbStim)]);
                    annotation('textbox',dim,'String',str,'Color','black','FitBoxToText','on');
                end

            if ss(isubj)
                maxy = max(max([Msup_long_delta_pre(:,2) Msup_long_delta_post(:,2) Mdeep_long_delta_pre(:,2) Mdeep_long_delta_post(:,2)]))*1.15;
                miny = min(min([Msup_long_delta_pre(:,2) Msup_long_delta_post(:,2) Mdeep_long_delta_pre(:,2) Mdeep_long_delta_post(:,2)]))*1.15;
                % plot deltas
                axes(preD)
                    plot(Mdeep_long_delta_pre(:,1),Mdeep_long_delta_pre(:,2),'-', 'color', 'r'), hold on
                    plot(Mdeep_short_delta_pre(:,1),Mdeep_short_delta_pre(:,2),'--', 'color', 'r'), hold on
                    plot(Msup_long_delta_pre(:,1),Msup_long_delta_pre(:,2), '-', 'color', 'b'), hold on
                    plot(Msup_short_delta_pre(:,1),Msup_short_delta_pre(:,2),'--', 'color', 'b'), hold on
    %                 shadedErrorBar([],Mpre{isubj}(:,2),Mpre{isubj}(:,3),'-b',1);
                    xlabel('Time (ms)')
                    ylabel('{\mu}V')   
                    title(['Pre-sleep deltas']);      
                    ylim([miny maxy])
                    legend({'Deepest long','Deepest short','Highest long','Highest short'}, ...
                        'location','NorthEast','FontSize',8);
                    makepretty_erc

                axes(postD)
                    plot(Mdeep_long_delta_post(:,1),Mdeep_long_delta_post(:,2),'-', 'color', 'r'), hold on 
                    plot(Mdeep_short_delta_post(:,1),Mdeep_short_delta_post(:,2),'--', 'color', 'r'), hold on  
                    plot(Msup_long_delta_post(:,1),Msup_long_delta_post(:,2), '-', 'color', 'b'), hold on  
                    plot(Msup_short_delta_post(:,1),Msup_short_delta_post(:,2),'--', 'color', 'b'), hold on       
    %                 shadedErrorBar([],Mpost{isubj}(:,2),Mpost{isubj}(:,3),'-b',1);
                    xlabel('Time (ms)')
                    ylabel('{\mu}V')   
                    title(['Post-sleep deltas']);      
                    ylim([miny maxy])
                    makepretty_erc
            end

            ymax= max(max(stagdur/(1E4*60)))*1.2;
            % plot sleep arch (bars)
            axes(bmin)
                b1 = bar(stagdur'/(1E4*60),1,'FaceColor','flat');
                b1(1,1).CData = [1 1 1];
                b1(1,2).CData = [0 0 0];
                xtips1 = b1(1).XData-.05;
                ytips1 = b1(1).YData;
                labels1 = string(round(b1(1).YData,1));
                xtips2 = b1(2).XData+.05;
                ytips2 = b1(2).YData;
                labels2 = string(round(b1(2).YData,1));
                text(xtips1,ytips1,labels1,'HorizontalAlignment','right',...
                    'VerticalAlignment','bottom','Color',[.6 .6 .6],'FontSize',8)
                text(xtips2,ytips2,labels2,'HorizontalAlignment','left',...
                    'VerticalAlignment','bottom','Color','black','FontSize',8)
                ylim([0 ymax])
                title('Minutes','FontSize',14)
                set(gca,'XTickLabel',ssnames)
                xlabel('Stages')
                ylabel('min')
                % creating legend with hidden-fake data
                hold on
                axP = get(gca,'Position');
                c1=bar(nan(2,5),'FaceColor','flat');
                c1(1,1).CData = [1 1 1];
                c1(1,2).CData = [0 0 0];
                legend(c1,{'Pre-sleep','Post-sleep'},'location','WestOutside');
                set(gca, 'Position', axP)
                makepretty_erc

            ymax= max(max(stagperc_now))*1.2;   
            axes(bperc)
                b2 = bar(stagperc',1,'FaceColor','flat');
                b2(1,1).CData = [1 1 1];
                b2(1,2).CData = [0 0 0];
                xtips1 = b2(1).XData-.05;
                ytips1 = b2(1).YData;
                labels1 = string(round(b2(1).YData,1));
                xtips2 = b2(2).XData+.05;
                ytips2 = b2(2).YData;
                labels2 = string(round(b2(2).YData,1));
                text(xtips1,ytips1,labels1,'HorizontalAlignment','right',...
                    'VerticalAlignment','bottom','Color',[.6 .6 .6],'FontSize',8)
                text(xtips2,ytips2,labels2,'HorizontalAlignment','left',...
                    'VerticalAlignment','bottom','Color','black','FontSize',8)
                ylim([0 ymax])
                title('%','FontSize',14)
                set(gca,'XTickLabel',ssnames)
                xlabel('Stages')
                ylabel('%')
                makepretty_erc


       % plot sleep arch (bars) WITHOUT WAKE  
            axes(bperc_nowake)
                b2 = bar(stagperc_now',1,'FaceColor','flat');
                b2(1,1).CData = [1 1 1];
                b2(1,2).CData = [0 0 0];
                xtips1 = b2(1).XData-.05;
                ytips1 = b2(1).YData;
                labels1 = string(round(b2(1).YData,1));
                xtips2 = b2(2).XData+.05;
                ytips2 = b2(2).YData;
                labels2 = string(round(b2(2).YData,1));
                text(xtips1,ytips1,labels1,'HorizontalAlignment','right',...
                    'VerticalAlignment','bottom','Color',[.6 .6 .6],'FontSize',8)
                text(xtips2,ytips2,labels2,'HorizontalAlignment','left',...
                    'VerticalAlignment','bottom','Color','black','FontSize',8)
                ylim([0 ymax])
                title('% (w/ wake)','FontSize',14)
                set(gca,'XTickLabel',ssnames_now)
                xlabel('Stages')
                ylabel('%')
                makepretty_erc

                %% Table number of sleep events
                tablepos = [.75 .15 .168 .087]; 
                tdetails{1,1} = 'Sess dur';   tdetails{1,2} = predur(isubj)/60e4;         tdetails{1,3} = postdur(isubj)/60e4;
                tdetails{2,1} = 'Sleep dur';     tdetails{2,2} = predur_now(isubj)/60e4;     tdetails{2,3} = postdur_now(isubj)/60e4;
                tdetails{3,1} = 'Latency';         tdetails{3,2} = lat(isubj,1);   tdetails{3,3} = lat(isubj,2);

                tableau1 = uitable(gcf, 'Data',tdetails, 'units','normalized', 'position',tablepos, 'ColumnWidth',{80 80 80});
                tableau1.ColumnName = {'in Minutes','Pre', 'Post'};
    end            
end  


end

