% Dat2Mat_DB - Converting preprocessed files to matlab format
% 30.01.2019 DB

function Dat2Mat_SL(dirin)

%% Parameters
try
   dirin;
catch
    dirin =  {[pwd '/']};
end

%%% Do you have stimulations?
sleepstimulated = 0;
i=1;

%% Intan or Open Ephys
intan = 1;
oe    = 0;

%% To do
stim = 0;
ss = 1;
hb =  0;
rip = 1;

%#####################################################################
%#
%#                           M A I N
%#
%#####################################################################


%% Run
for i=1:length(dirin)
    Dir=dirin{i};
    
    cd(Dir);
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
    
    
    SetCurrentSession('same');
%% Make data

%     Get Stimulations if you have any
    if stim
        if intan
            GetStims_DB
            make_StimSent
        elseif oe
            GetStims_OE_SL
        end
    end
    
%     make Spike DataStim (NEED TO Cluster first!)
    if ExpeInfo.PreProcessingInfo.DoSpikes
       MakeData_Spikes('mua', 1,'recompute',1);
    end
    
%% Sleep scoring
% Note: if no sleep it will crash when creating theta epoch. But the
% SleepScoring_.mat will have been created.
    if ss
        defaultvalues={'yes', 'yes', 'yes'};
        Questions={'Sleep Scoring ? OBgamma', 'Sleep events?' 'Substages?'};
        ans = inputdlg(Questions, 'Inputs for makeData', 1, defaultvalues);

        doscoring = strcmp(ans{1},'yes');
        dosleepevents = strcmp(ans{2},'yes');
        dosubstages = strcmp(ans{3},'yes');

        if doscoring == 1
            if sleepstimulated
                StimEpoch = intervalSet(Start(TTLInfo.StimEpoch)-3E2, Start(TTLInfo.StimEpoch)+3E3);
                SleepScoring_Accelero_OBgamma('PlotFigure',1, 'smoothwindow', 1.2, 'StimEpoch', StimEpoch);
            else
                SleepScoring_Accelero_OBgamma('PlotFigure',1);
            end        
        end
        disp('Creating sleep scoring array');
        make_sleepscoringarray
    end
    
%% Heart
     if hb
        % Make Heart Beat data
        Options.TemplateThreshStd=3;  % était 3
        Options.BeatThreshStd=0.1;
        load ([Dir '/ChannelsToAnalyse/EKG.mat'])
        EKG = load(['LFPData/LFP',num2str(channel),'.mat']);
        load('ExpeInfo.mat')
        load('behavResources.mat');
    %     try
    %         load('SleepScoring_OBGamma.mat', 'TotalNoiseEpoch');
    %         disp('Loading Sleep Scoring from OB...');
    %     catch
    %         disp('No OB, trying accelero.');
    %         load('SleepScoring_Accelero.mat','TotalNoiseEpoch');
    %         disp('Loading Sleep Scoring from Accelero...');
    %     end

        if hbstim
            StimEpoch = intervalSet(Start(TTLInfo.StimEpoch), Start(TTLInfo.StimEpoch));
        else
            StimEpoch = intervalSet(Start(TTLInfo.StimEpoch)-3E2, Start(TTLInfo.StimEpoch)+5E3);
        end
        %StimEpoch = intervalSet(Start(TTLInfo.StimEpoch), Start(TTLInfo.StimEpoch));
        BadEpoch = StimEpoch; %or(TotalNoiseEpoch, StimEpoch);
        [Times,Template,HeartRate,GoodEpoch]=DetectHeartBeats_EmbReact_SB(EKG.LFP,BadEpoch,Options,1);  %WARNING: check for value of movmedian (ln #95)
        EKG.HBTimes=ts(Times);
        EKG.HBShape=Template;
        EKG.DetectionOptions=Options;
        EKG.HBRate=HeartRate;
        EKG.GoodEpoch=GoodEpoch;
        save('HeartBeatInfo.mat','EKG')
        saveas(gcf,'EKGCheck.fig'),              
        saveFigure(gcf,'EKGCheck', Dir);
    end
    
    
%% Ripples    
    if rip
        % Detect ripples events
        if exist('ChannelsToAnalyse/dHPC_rip.mat')==2
            rip_chan = load('ChannelsToAnalyse/dHPC_rip.mat');
            nonrip_chan = load('ChannelsToAnalyse/Bulb_sup.mat');
            [ripples,stdev] = FindRipples_DB (rip_chan.channel, nonrip_chan.channel, [1 2],'rmvnoise',0, 'clean',1); % [2 7],'rmvnoise',1, 'clean',1);
        end
    end
end
end