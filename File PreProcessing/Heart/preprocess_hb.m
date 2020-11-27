function preprocess_hb(workPath)

% Make Heart Beat data
Options.TemplateThreshStd=3;  % était 3
Options.BeatThreshStd=0.1;
load ([workPath '/ChannelsToAnalyse/EKG.mat'])
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
saveFigure(gcf,'EKGCheck', workPath);
end