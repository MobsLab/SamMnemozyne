% SleepScoring_Accelero_OBgamma
% 01.12.2017 SB - corrected by Dima on 20.11.18: StimEpoch and smoothwindow
% added
%
% SleepScoring_Accelero_OBgamma('PlotFigure',1)
%
% Sleep Scoring Using Olfactory Bulb and Hippocampal LFP
% This function creates SleepScoring_OBGamma with sleep scoring variables
%
%
%INPUTS
% PlotFigure (optional) = overview figrue of sleep scoring if 1; default is 1
%
%
% SEE
%   SleepScoringAccelerometer SleepScoringOBGamma
%


function Correct_SleepScoring_Theta(varargin)

%% INITITATION
disp('Performing sleep scoring with OB gamma and with Accelerometer')

% Parse parameter list
for i = 1:2:length(varargin)
    if ~ischar(varargin{i})
        error(['Parameter ' num2str(i+2) ' is not a property.']);
    end
    switch(lower(varargin{i}))
        case 'plotfigure'
            PlotFigure = varargin{i+1};
            if PlotFigure~=0 && PlotFigure ~=1
                error('Incorrect value for property ''PlotFigure''.');
            end
        case 'recompute'
            recompute = varargin{i+1};
            if recompute~=0 && recompute ~=1
                error('Incorrect value for property ''recompute''.');
            end
        case 'smoothwindow'
            smootime = varargin{i+1};
            if smootime<=0
                error('Incorrect value for property ''smoothwindow''.');
            end
        case 'stimepoch'
            StimEpoch = varargin{i+1};
            if ~isobject(StimEpoch)
                error('Incorrect value for property ''stimepoch''.');
            end
        otherwise
            error(['Unknown property ''' num2str(varargin{i}) '''.']);
    end
end

%check if exist and assign default value if not
if ~exist('PlotFigure','var')
    PlotFigure=1;
end
%recompute?
if ~exist('recompute','var')
    recompute=0;
end

% params
minduration = 3;     % abs cut off duration for epochs (sec)

try
    smootime;
catch
    smootime = 3;
end

%% Load necessary channels

foldername=pwd;
if foldername(end)~=filesep
    foldername(end+1)=filesep;
end

% OB
if exist('ChannelsToAnalyse/Bulb_deep.mat','file')==2
    load('ChannelsToAnalyse/Bulb_deep.mat')
    channel_bulb=channel;
else
    dowiob=input('No OB channel, you want to do only accelerometer-based scoring? 1/0 ');
    if ~dowiob
        error('No OB channel, do not want ');
    end
end

% HPC
if exist('ChannelsToAnalyse/dHPC_deep.mat','file')==2
    load('ChannelsToAnalyse/dHPC_deep.mat')
    channel_hpc=channel;
elseif exist('ChannelsToAnalyse/dHPC_rip.mat','file')==2
    load('ChannelsToAnalyse/dHPC_rip.mat')
    channel_hpc=channel;
elseif exist('ChannelsToAnalyse/dHPC_sup.mat','file')==2
    load('ChannelsToAnalyse/dHPC_sup.mat')
    channel_hpc=channel;
else
    error('No HPC channel, cannot do sleep scoring');
end

%loading
% load('SleepScoring_OBGamma','Sleep','Epoch','Info','TotalNoiseEpoch','SmoothTheta');
if exist('SleepScoring_OBGamma.mat','file')
    ssob = matfile('SleepScoring_OBGamma.mat','Writable',true);
    SleepOB = ssob.Sleep;
    Epoch = ssob.Epoch;
    Info_OB = ssob.Info;
    TotalNoiseEpoch = ssob.TotalNoiseEpoch;
    SmoothTheta_OB = ssob.SmoothTheta;
end    
% load('SleepScoring_Accelero','ImmobilityEpoch','Epoch','Info','TotalNoiseEpoch','SmoothTheta');
if exist('SleepScoring_Accelero.mat','var')
    ssac = matfile('SleepScoring_Accelero.mat','Writable',true);
    is_accelero = true;
    ImmobilityEpoch =  ssac.ImmobilityEpoch;
    Epoch = ssob.Epoch;
    Info_accelero = ssac.Info;
    TotalNoiseEpoch = ssac.TotalNoiseEpoch;
    SmoothTheta_acc = ssac.SmoothTheta;
else
    is_accelero = false;
end    

%% Find Theta epoch
disp('Theta Epochs')

if exist('dowiob','var')
    if ~dowiob
        % restricted to sleep with OB gamma
        if ~exist('StimEpoch')
            [ThetaEpoch_OB, SmoothTheta, Info_temp] = ...
                FindThetaEpoch_SleepScoring_tmp(SmoothTheta_OB,Info_OB.theta_thresh,SleepOB, ...
                Epoch, channel_hpc, minduration, 'foldername', foldername,...
                'smoothwindow', smootime,'continuity',1);
        else
            [ThetaEpoch_OB, SmoothTheta, Info_temp] = FindThetaEpoch_SleepScoring_tmp(SmoothTheta_OB,Info_OB.theta_thresh,SleepOB, Epoch, channel_hpc, minduration, 'foldername', foldername,...
                'smoothwindow', smootime,'continuity',1, 'stimepoch', StimEpoch);
        end
        Info_OB=ConCatStruct(Info_OB,Info_temp);
        ssob.Info=Info_OB;
        ssob.ThetaEpoch = ThetaEpoch_OB;
        clear Info_temp ThetaEpoch;
%         ThetaEpoch = ThetaEpoch_OB;
%         save('SleepScoring_OBGamma','ThetaEpoch','SmoothTheta','-append');
%         
%         clear ThetaEpoch;
    end
else
    disp('Processing sleep with bulb gamma')
    % restricted to sleep with OB gamma
    if ~exist('StimEpoch')
        [ThetaEpoch_OB, SmoothTheta, Info_temp] = FindThetaEpoch_SleepScoring_tmp(SmoothTheta_OB,Info_OB.theta_thresh,SleepOB, Epoch, channel_hpc, minduration, 'foldername', foldername,...
            'smoothwindow', smootime,'continuity',1);
    else
        [ThetaEpoch_OB, SmoothTheta, Info_temp] = FindThetaEpoch_SleepScoring_tmp(SmoothTheta_OB,Info_OB.theta_thresh,SleepOB, Epoch, channel_hpc, minduration, 'foldername', foldername,...
            'smoothwindow', smootime,'continuity',1, 'stimepoch', StimEpoch);
    end
    disp('Saving ThetaEpoch to SleepScoring_OBGamma.mat')
    Info_OB=ConCatStruct(Info_OB,Info_temp); 
    ssob.Info=Info_OB;
    ssob.ThetaEpoch = ThetaEpoch_OB;
    disp('Saving done.')
    
%     clear Info_temp;
%     ThetaEpoch = ThetaEpoch_OB;
%     save('SleepScoring_OBGamma','ThetaEpoch','-append');
%     clear ThetaEpoch;
end

% restricted to immobility epoch
if is_accelero
    disp('Processing sleep with Accelero')
    if ~exist('StimEpoch')
        [ThetaEpoch_acc, SmoothTheta, Info_temp] = FindThetaEpoch_SleepScoring_tmp(SmoothTheta_acc,Info_accelero.theta_thresh,ImmobilityEpoch, Epoch, channel_hpc, minduration,...
            'foldername', foldername,'smoothwindow', smootime,'continuity',1);
    else
        [ThetaEpoch_acc, SmoothTheta, Info_temp] = FindThetaEpoch_SleepScoring_tmp(SmoothTheta_acc,Info_accelero.theta_thresh,ImmobilityEpoch, Epoch, channel_hpc, minduration,...
            'foldername', foldername,'smoothwindow', smootime, 'continuity',1,'stimepoch', StimEpoch);
    end
    
    disp('Saving ThetaEpoch to SleepScoring_Accelero.mat')
    Info_accelero = ConCatStruct(Info_accelero,Info_temp); 
    ssac.Info = Info_accelero;
    ssac.ThetaEpoch = ThetaEpoch_acc;
    disp('Saving done.')
    
%     clear Info_temp;
%     ThetaEpoch = ThetaEpoch_acc;
%     save('SleepScoring_Accelero','ThetaEpoch','-append');
%     clear ThetaEpoch;
end


%% Define behavioural epochs
if exist('dowiob','var')
    if ~dowiob
        disp('Updating sleep stages epochs to SleepScoring_OBGamma.mat')
        [ssob.REMEpoch,ssob.SWSEpoch,ssob.Wake,ssob.REMEpochWiNoise, ssob.SWSEpochWiNoise, ssob.WakeWiNoise] = ...
            ScoreEpochs_SleepScoring(TotalNoiseEpoch, Epoch, SleepOB, ThetaEpoch_OB, minduration);
        ssob.SleepWiNoise = or(REMEpochWiNoise,SWSEpochWiNoise);
        ssob.Sleep = or(REMEpoch,SWSEpoch);
%         save('SleepScoring_OBGamma','REMEpoch','SWSEpoch','Wake','REMEpochWiNoise', ...
%             'SWSEpochWiNoise', 'WakeWiNoise','Sleep','SleepWiNoise','-append','-v7.3');
        disp('Saving done.')
        
    end
else
    [ssob.REMEpoch,ssob.SWSEpoch,ssob.Wake,ssob.REMEpochWiNoise,ssob.SWSEpochWiNoise,ssob.WakeWiNoise] = ...
        ScoreEpochs_SleepScoring(TotalNoiseEpoch, Epoch, SleepOB, ThetaEpoch_OB, minduration);
    ssob.SleepWiNoise = or(REMEpochWiNoise,SWSEpochWiNoise);
    ssob.Sleep = or(REMEpoch,SWSEpoch);
%     save('SleepScoring_OBGamma','REMEpoch','SWSEpoch','Wake','REMEpochWiNoise', 'SWSEpochWiNoise', 'WakeWiNoise','Sleep','SleepWiNoise','-append');
end
    
if is_accelero
    [ssac.REMEpoch,ssac.SWSEpoch,ssac.Wake,ssac.REMEpochWiNoise,ssac.SWSEpochWiNoise,ssac.WakeWiNoise] = ScoreEpochs_SleepScoring(TotalNoiseEpoch, Epoch, ImmobilityEpoch, ThetaEpoch_acc, minduration);
    ssac.SleepWiNoise = or(REMEpochWiNoise,SWSEpochWiNoise);
    ssac.Sleep = or(REMEpoch,SWSEpoch);
%     save('SleepScoring_Accelero','REMEpoch','SWSEpoch','Wake','REMEpochWiNoise', 'SWSEpochWiNoise', 'WakeWiNoise','Sleep','SleepWiNoise','-append')
end

%% save Info
if exist('dowiob','var')
    if ~dowiob
        ssob.Info = Info_OB;
%         save('SleepScoring_OBGamma','Info','-append')
    end
else
    ssob.Info = Info_OB;
%     save('SleepScoring_OBGamma','Info','-append')
end

if is_accelero
    ssac.Info = Info_accelero;
%     save('SleepScoring_Accelero','Info','-append')
end


%% Make sleep scoring figure if PlotFigure is 1
if PlotFigure==1
    
    %OB
    % Calculate spectra if they don't alread exist
    if ~(exist('H_Low_Spectrum.mat', 'file') == 2)
        LowSpectrumSB(foldername,channel_hpc,'H');
    end
    if exist('dowiob','var')
        if ~dowiob
            if ~(exist('B_High_Spectrum.mat', 'file') == 2)
                HighSpectrum(foldername,channel_bulb,'B');
            end
        end
    else
        if ~(exist('B_High_Spectrum.mat', 'file') == 2)
            HighSpectrum(foldername,channel_bulb,'B');
        end
    end
    % Make figure
    if exist('dowiob','var')
        if ~dowiob
            Figure_SleepScoring_OBGamma(foldername)
        end
    else
        Figure_SleepScoring_OBGamma(foldername)
    end
    
%     %Accelerometer
%     % Make figure
%     if is_accelero
%         ratio_display_movement = (max(Data(ThetaRatioTSD))-min(Data(ThetaRatioTSD)))/(max(Data(tsdMovement))-min(Data(tsdMovement)));
%         Figure_SleepScoring_Accelero(ratio_display_movement, foldername)
%     end
%     
end


end


