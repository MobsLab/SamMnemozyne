%% DetectHR_PAGTest
clear all

% Init variables
ntest = 4;           % Nbr of trials
Dir = PathForExperimentsPAGTest_SL('PostSleep');


%% Get data from dirin
% Structure of dirin:
%   dirin{imouse} {1} {itest}
%       ...so first is mouse, second is a constant (1) and tird is the trial number 

try
   dirin;
catch
   dirin=Dir.path;
end


i=1;
while i<length(dirin)+1
    %-- Current folder
    cd(dirin{i}{1}{1}); 
    [parentFolder deepestFolder] = fileparts(pwd);
    cd(parentFolder)
    %     
    %     load ([dirin{i} '/ChannelsToAnalyse/EKG.mat']);
    if exist([parentFolder '/ChannelsToAnalyse/EKG.mat'], 'file')
        answer = questdlg(['Would you like process' parentFolder],'Hey Mark','Sure', 'Nay', 'Sure');
        % Handle response
        switch answer
            case 'Sure'
                        
                disp(['Starting file: ' parentFolder])

                load([parentFolder '/ChannelsToAnalyse/EKG.mat']);
                %% Check for noise
                [Epoch,TotalNoiseEpoch,SubNoiseEpoch,Info]=FindNoiseEpoch_SleepScoring(channel);

                load ([parentFolder '/LFPData/LFP' num2str(channel) '.mat']);
                A = Restrict(LFP, Epoch);
                plot(Range(A, 's'), Data(A))

                save('NoiseEpoch', 'Epoch', 'TotalNoiseEpoch','SubNoiseEpoch','Info');

                %% Make Heart Beat data
                Options.TemplateThreshStd=3;
                Options.BeatThreshStd=0.2;  %0.5
                load ([parentFolder '/ChannelsToAnalyse/EKG.mat'])
                EKG = load(['LFPData/LFP',num2str(channel),'.mat']);
                load('ExpeInfo.mat')
                load('behavResources.mat');
                SafeEpoch = intervalSet (Start(TTLInfo.StimEpoch)-5E2, Start(TTLInfo.StimEpoch)+3E3);
                [Times,Template,HeartRate,GoodEpoch]=DetectHeartBeats_EmbReact_SB(EKG.LFP,SafeEpoch,Options,1);
                
                answer = questdlg(['Are you satified with this Sire?'],'Hey Mark','Sure', 'Nay', 'Sure');
                
                % Handle response
                switch answer
                    case 'Sure'
                        EKG.HBTimes=ts(Times);
                        EKG.HBShape=Template;
                        EKG.DetectionOptions=Options;
                        EKG.HBRate=HeartRate;
                        EKG.GoodEpoch=GoodEpoch;
                        save('HeartBeatInfo.mat','EKG')
                        saveas(gcf,'EKGCheck.fig'),              
                        saveFigure(gcf,'EKGCheck', parentFolder);
                        disp([parentFolder ' DONE'])
                        i=i+1;
                    case 'Nay'
                        disp([parentFolder ' REDOING'])
                end
                
            case 'Nay'
                disp([parentFolder ' SKIPPED'])
                i=i+1;
        end
    else
        disp([parentFolder ' does not have EKG'])
        i=i+1;
    end
    
    
end