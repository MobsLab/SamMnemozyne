%quickly made script to verify the quality of sleep scoring (better use gui_verify_sleepscoring)


%%testSleepERC
clear 
foldername = pwd;
load SleepScoring_OBGamma Epoch Wake REMEpoch SWSEpoch TotalNoiseEpoch SmoothGamma SmoothTheta Info
InfoOB=Info;
WakeOB=Wake;
REMEpochOB=REMEpoch;
SWSEpochOB=SWSEpoch;

load SleepScoring_Accelero Wake REMEpoch SWSEpoch TotalNoiseEpoch ThetaRatioTSD tsdMovement SmoothTheta Info

infoacc = Info;

eval(['load ChannelsToAnalyse/PFCx_deep.mat'])
try
    eval(['load SpectrumDataL/Sp',num2str(channel)])
catch
    [Sp,tx,f]=LoadSpectrumML(channel,pwd,'newlow');
end

lowPowPFC=mean(Sp(:,find(f>0&f<15)),2);
lowPowPFCtsd=tsd(tx*1E4,lowPowPFC);

% spectro (from Figure_SleepScoring_OBGamma)
%% INITIATION

% Variables that indicate if specta exist
SpecOk.OB = 0;
SpecOk.HPC = 0;

% load OB spectrum
if exist([foldername,'/B_High_Spectrum.mat'])>0
    load([foldername,'/B_High_Spectrum.mat']);
    
    % smooth the spectrum for visualization
    datb = Spectro{1};
    for k = 1:size(datb,2)
        datbnew(:,k) = runmean(datb(:,k),100);
    end
    
    % make tsd
    sptsdB = tsd(Spectro{2}*1e4,datbnew);
    fB = Spectro{3};
    clear Spectro
    
    % get caxis lims
    CMax.OB = max(max(Data(Restrict(sptsdB,Epoch))))*1.05;
    CMin.OB = min(min(Data(Restrict(sptsdB,Epoch))))*0.95;
    
    SpecOk.OB = 1;
end

% load HPC spectrum
if exist([foldername,'/H_Low_Spectrum.mat'])>0
    load([foldername,'/H_Low_Spectrum.mat']);
    
    % make tsd
    sptsdH = tsd(Spectro{2}*1e4,Spectro{1});
    fH = Spectro{3};
    clear Spectro
    
    % get caxis lims
    CMax.HPC = max(max(Data(Restrict(sptsdH,Epoch))))*1.05;
    CMin.HPC = min(min(Data(Restrict(sptsdH,Epoch))))*0.95;
    
    SpecOk.HPC = 1;
end

% gamma and theta power : restrict to non-noisy epoch
SmoothGammaNew = Restrict(SmoothGamma,Epoch);
SmoothThetaNew = Restrict(SmoothTheta,Epoch);

% gamma and theta power : subsample to same bins
t = Range(SmoothThetaNew);
ti = t(5:1200:end);
SmoothGammaNew = (Restrict(SmoothGammaNew,ts(ti)));
SmoothThetaNew = (Restrict(SmoothThetaNew,ts(ti)));
mvt = tsdMovement;

% REM
SmoothThetaREM  =  Data(Restrict(Restrict(SmoothTheta,mvt),REMEpoch));
SmoothGammaREM  =  Data(Restrict(Restrict(SmoothGamma,mvt),REMEpoch));
mvtREM          =  Data(Restrict(mvt,REMEpoch));
% SWS
SmoothThetaSWS  =  Data(Restrict(Restrict(SmoothTheta,mvt),SWSEpoch));
SmoothGammaSWS  =  Data(Restrict(Restrict(SmoothGamma,mvt),SWSEpoch));
mvtSWS          =  Data(Restrict(mvt,SWSEpoch));
% Wake
SmoothThetaWake =  Data(Restrict(Restrict(SmoothTheta,mvt),Wake));
SmoothGammaWake =  Data(Restrict(Restrict(SmoothGamma,mvt),Wake));
mvtWake         =  Data(Restrict(mvt,Wake));

% fix theta and gamma size to mvt 
i=1;
for ij=1:375:length(SmoothThetaREM)
    try
        tetharem(i) =  mean(SmoothThetaREM(ij:ij+374));
        gammarem(i) =  mean(SmoothGammaREM(ij:ij+374));
    catch
        tetharem(i) =  mean(SmoothThetaREM(ij:end));
        gammarem(i) =  mean(SmoothGammaREM(ij:end));
    end
    i=i+1;
end
i=1;
for ij=1:375:length(SmoothThetaSWS)
    try
        tethasws(i) =  mean(SmoothThetaSWS(ij:ij+374));
        gammasws(i) =  mean(SmoothGammaSWS(ij:ij+374));
    catch
        tethasws(i) =  mean(SmoothThetaSWS(ij:end));
        gammasws(i) =  mean(SmoothGammaSWS(ij:end));
    end
    i=i+1;
end
i=1;
for ij=1:375:length(SmoothThetaWake)
    try
        tethawak(i) =  mean(SmoothThetaWake(ij:ij+374));
        gammawak(i) =  mean(SmoothGammaWake(ij:ij+374));
    catch
        tethawak(i) =  mean(SmoothThetaWake(ij:end));
        gammawak(i) =  mean(SmoothGammaWake(ij:end));
    end
    i=i+1;
end
% reduce number of points plotted
trem = tetharem(1:10:end);
grem = gammarem(1:10:end);
mrem = mvtREM(1:10:end);
tsws = tethasws(1:10:end);
gsws = gammasws(1:10:end);
msws = mvtSWS(1:10:end);
twak = tethawak(1:10:end);
gwak = gammawak(1:10:end);
mwak = mvtWake(1:10:end);

minsz = min([length(trem) length(grem) length(mrem)]);
trem=trem(1:minsz);
grem=grem(1:minsz);
mrem=mrem(1:minsz);
minsz = min([length(tsws) length(gsws) length(msws)]);
tsws=tsws(1:minsz);
gsws=gsws(1:minsz);
msws=msws(1:minsz);
minsz = min([length(twak) length(gwak) length(mwak)]);
twak=twak(1:minsz);
gwak=gwak(1:minsz);
mwak=mwak(1:minsz);

%%  F I G U R E S 
% scatter plots of theta, gamma and accelero 
figure,
    subplot(131)
        plot(10*log10(trem),10*log10(mrem),'.','color','g','MarkerSize',2), hold on
        plot(10*log10(tsws),10*log10(msws),'.','color','r','MarkerSize',2), hold on
        plot(10*log10(twak),10*log10(mwak),'.','color','b','MarkerSize',2)
        title('theta vs accelero')
        xlabel('theta'), ylabel('accelero')  
    subplot(132)
        plot(10*log10(trem),10*log10(grem),'.','color','g','MarkerSize',2), hold on
        plot(10*log10(tsws),10*log10(gsws),'.','color','r','MarkerSize',2), hold on
        plot(10*log10(twak),10*log10(gwak),'.','color','b','MarkerSize',2)
        title('theta vs gamma')
        xlabel('theta'), ylabel('gamma')    
    subplot(133)
        plot(10*log10(grem),10*log10(mrem),'.','color','g','MarkerSize',2), hold on
        plot(10*log10(gsws),10*log10(msws),'.','color','r','MarkerSize',2), hold on
        plot(10*log10(gwak),10*log10(mwak),'.','color','b','MarkerSize',2)
        title('gamma vs accelero')
        xlabel('gamma'), ylabel('accelero')         
        
figure, 
    subplot(1,2,1), 
        hist(10*log10(Data(Restrict(lowPowPFCtsd,SWSEpoch))),500)
    subplot(1,2,2), 
        hist(Data(Restrict(lowPowPFCtsd,SWSEpoch)),500)

figure, 
    % theta raw
    subplot(511),
        yyaxis left
        imagesc(Range(sptsdH,'s'),fH,10*log10(Data(sptsdH))'), axis xy, caxis(10*log10([CMin.HPC CMax.HPC]))
        xlabel('HPC spectro')
        hold on  
        yyaxis right
        plot(Range(ThetaRatioTSD,'s'), Data(ThetaRatioTSD),'color',[0.6 0.6 0.6]), ylabel('theta (raw)'), title(pwd)
        SleepStages=PlotSleepStage(Wake,SWSEpoch,REMEpoch,0,[10 2]);
    % theta
    subplot(512),
        yyaxis left
        imagesc(Range(sptsdH,'s'),fH,10*log10(Data(sptsdH))'), axis xy, caxis(10*log10([CMin.HPC CMax.HPC]))
        xlabel('HPC spectro')
        hold on  
        yyaxis right
        plot(Range(SmoothTheta,'s'), Data(SmoothTheta),'color',[0.6 0.6 0.6]), ylabel('theta')
        line(xlim,[Info.theta_thresh Info.theta_thresh],'color','r')
        SleepStages=PlotSleepStage(Wake,SWSEpoch,REMEpoch,0,[7 1]);
    % movement
    subplot(513), 
        yyaxis left
        imagesc(Range(sptsdB,'s'),fB,10*log10(Data(sptsdB))'), axis xy, caxis(10*log10([CMin.OB CMax.OB]))
        xlabel('Bulb spectro')
        hold on
        yyaxis right
        plot(Range(tsdMovement,'s'), Data(tsdMovement),'color',[0.6 0.6 0.6]), ylabel('Mvt')
        SleepStages=PlotSleepStage(Wake,SWSEpoch,REMEpoch,0,[2E8 5e7]);
        ylim([0 5E8])
        line(xlim,[infoacc.mov_threshold infoacc.mov_threshold],'color','r')
    % gamma
    subplot(514), 
        yyaxis left
        imagesc(Range(sptsdB,'s'),fB,10*log10(Data(sptsdB))'), axis xy, caxis(10*log10([CMin.OB CMax.OB]))
        xlabel('Bulb spectro')
        hold on
        yyaxis right
        plot(Range(SmoothGamma,'s'), Data(SmoothGamma),'color',[0.6 0.6 0.6]), ylabel('Gamma')
        line(xlim,[InfoOB.gamma_thresh InfoOB.gamma_thresh],'color','r')
        SleepStagesOB=PlotSleepStage(WakeOB,SWSEpochOB,REMEpochOB,0,[500 100]);
    % low PFC power
    subplot(515),
        yyaxis left
        imagesc(Range(sptsdB,'s'),fB,10*log10(Data(sptsdB))'), axis xy, caxis(10*log10([CMin.OB CMax.OB]))
        xlabel('Bulb spectro')
        hold on
        yyaxis right 
        plot(tx, 10*log10(lowPowPFC),'color',[0.6 0.6 0.6]), ylabel('low Pow PFC')
        SleepStagesOB=PlotSleepStage(WakeOB,SWSEpochOB,REMEpochOB,0,[60 2]);
        line(xlim,[43 43],'color','r')
%         
%         
% figure, 
%     % theta raw
%     subplot(511),
%         yyaxis left
%         imagesc(Range(sptsdH,'s'),fH,10*log10(Data(sptsdH))'), axis xy, caxis(10*log10([CMin.HPC CMax.HPC]))
%         xlabel('HPC spectro')
%         hold on  
%         yyaxis right
%         plot(Range(ThetaRatioTSD,'s'), Data(ThetaRatioTSD),'color',[0.6 0.6 0.6]), ylabel('theta (raw)'), title(pwd)
%         SleepStages=PlotSleepStage(Wake,SWSEpoch,REMEpoch,0,[10 2]);
%     % theta
%     subplot(512),
%         yyaxis left
%         imagesc(Range(sptsdH,'s'),fH,10*log10(Data(sptsdH))'), axis xy, caxis(10*log10([CMin.HPC CMax.HPC]))
%         xlabel('HPC spectro')
%         hold on  
%         yyaxis right
%         plot(Range(SmoothTheta,'s'), Data(SmoothTheta),'color',[0.6 0.6 0.6]), ylabel('theta')
%         line(xlim,[Info.theta_thresh Info.theta_thresh],'color','r')
%         SleepStages=PlotSleepStage(Wake,SWSEpoch,REMEpoch,0,[7 1]);
%     % movement
%     subplot(513), 
%         yyaxis left
%         imagesc(Range(sptsdB,'s'),fB,10*log10(Data(sptsdB))'), axis xy, caxis(10*log10([CMin.OB CMax.OB]))
%         xlabel('Bulb spectro')
%         hold on
%         yyaxis right
%         plot(Range(tsdMovement,'s'), Data(tsdMovement),'color',[0.6 0.6 0.6]), ylabel('Mvt')
%         SleepStages=PlotSleepStage(Wake,SWSEpoch,REMEpoch,0,[2E8 5e7]);
%         ylim([0 5E8])
%         line(xlim,[infoacc.mov_threshold infoacc.mov_threshold],'color','r')
%     % gamma
%     subplot(514), 
%         yyaxis left
%         imagesc(Range(sptsdB,'s'),fB,10*log10(Data(sptsdB))'), axis xy, caxis(10*log10([CMin.OB CMax.OB]))
%         xlabel('Bulb spectro')
%         hold on
%         yyaxis right
%         plot(Range(SmoothGamma,'s'), Data(SmoothGamma),'color',[0.6 0.6 0.6]), ylabel('Gamma')
%         line(xlim,[InfoOB.gamma_thresh InfoOB.gamma_thresh],'color','r')
%         SleepStagesOB=PlotSleepStage(WakeOB,SWSEpochOB,REMEpochOB,0,[500 100]);
%     % low PFC power
%     subplot(515),
%         yyaxis left
%         imagesc(Range(sptsdB,'s'),fB,10*log10(Data(sptsdB))'), axis xy, caxis(10*log10([CMin.OB CMax.OB]))
%         xlabel('Bulb spectro')
%         hold on
%         yyaxis right 
%         plot(tx, 10*log10(lowPowPFC),'color',[0.6 0.6 0.6]), ylabel('low Pow PFC')
%         SleepStagesOB=PlotSleepStage(WakeOB,SWSEpochOB,REMEpochOB,0,[60 2]);
%         line(xlim,[43 43],'color','r')

a=0;
a=a+500; subplot(511),xlim([a a+500]),subplot(512),xlim([a a+500]),subplot(513),xlim([a a+500]),subplot(514),xlim([a a+500]),subplot(515),xlim([a a+500])