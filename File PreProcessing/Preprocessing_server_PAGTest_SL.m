%Preprocessing_server_DB
% 11.04.2018 DB

function Preprocessing_PAGTest_SL(dirin)

try
   dirin;
catch
    dirin={
        '/media/mobs/DataMOBS85/PAG tests/M784/28092018/SleepStim/'
        %'/media/mobs/DataMOBS85/PAG tests/M784/18092018/CalibContextA';
%     '/media/mobs/DataMOBS85/PAG tests/M784/18092018/CalibContextB/Calib0.0V';
%     '/media/mobs/DataMOBS85/PAG tests/M784/18092018/CalibContextB/Calib0.5V';
%     '/media/mobs/DataMOBS85/PAG tests/M784/18092018/CalibContextB/Calib1.0V';
%     '/media/mobs/DataMOBS85/PAG tests/M784/18092018/CalibContextB/Calib1.5V';
%     '/media/mobs/DataMOBS85/PAG tests/M784/18092018/CalibContextB/Calib2.0V';
%     '/media/mobs/DataMOBS85/PAG tests/M784/18092018/CalibContextB/Calib2.5V';
%     '/media/mobs/DataMOBS85/PAG tests/M784/18092018/CalibContextB/Calib3.0V';
%     '/media/mobs/DataMOBS85/PAG tests/M784/18092018/CalibContextB/Calib3.5V';
%     '/media/mobs/DataMOBS85/PAG tests/M784/18092018/CalibContextB/Calib4.0V';
%     '/media/mobs/DataMOBS85/PAG tests/M784/18092018/CalibContextB/Calib4.5V';
%     '/media/mobs/DataMOBS85/PAG tests/M784/18092018/CalibContextC/Calib0.0V';
%     '/media/mobs/DataMOBS85/PAG tests/M784/18092018/CalibContextC/Calib0.5V';
%     '/media/mobs/DataMOBS85/PAG tests/M784/18092018/CalibContextC/Calib1.0V';
%     '/media/mobs/DataMOBS85/PAG tests/M784/18092018/CalibContextC/Calib1.5V';
%     '/media/mobs/DataMOBS85/PAG tests/M784/18092018/CalibContextC/Calib2.0V';
%     '/media/mobs/DataMOBS85/PAG tests/M784/18092018/CalibContextC/Calib2.5V';
%     '/media/mobs/DataMOBS85/PAG tests/M784/18092018/CalibContextC/Calib3.0V';
%     '/media/mobs/DataMOBS85/PAG tests/M784/18092018/CalibContextC/Calib3.5V';
%     '/media/mobs/DataMOBS85/PAG tests/M784/18092018/CalibContextC/Calib4.0V';
%     '/media/mobs/DataMOBS85/PAG tests/M784/18092018/CalibContextC/Calib4.5V';
%     '/media/mobs/DataMOBS85/PAG tests/M784/18092018/CalibContextC/Calib5.0V';
%     '/media/mobs/DataMOBS85/PAG tests/M784/18092018/CalibContextC/Calib5.5V';
%     '/media/mobs/DataMOBS85/PAG tests/M784/18092018/CalibContextC/Calib6.0V';
%     '/media/mobs/DataMOBS85/PAG tests/M784/19092018/AnteriorStim/PostCalib-ContextA';
%     '/media/mobs/DataMOBS85/PAG tests/M784/19092018/AnteriorStim/PostCalib-ContextB';
%     '/media/mobs/DataMOBS85/PAG tests/M784/19092018/PosteriorStim/Cond';
%     '/media/mobs/DataMOBS85/PAG tests/M784/19092018/PosteriorStim/Hab';
%     '/media/mobs/DataMOBS85/PAG tests/M784/19092018/PosteriorStim/PostCalib-ContextC';
%     '/media/mobs/DataMOBS85/PAG tests/M784/19092018/PosteriorStim/PostSleep';
%     '/media/mobs/DataMOBS85/PAG tests/M784/19092018/PosteriorStim/PostTests';
%     '/media/mobs/DataMOBS85/PAG tests/M784/19092018/PosteriorStim/Pretests';
%     '/media/mobs/DataMOBS85/PAG tests/M784/20092018/AnteriorStim/Cond';
%     '/media/mobs/DataMOBS85/PAG tests/M784/20092018/AnteriorStim/Hab';
%     '/media/mobs/DataMOBS85/PAG tests/M784/20092018/AnteriorStim/PostSleep';
%     '/media/mobs/DataMOBS85/PAG tests/M784/20092018/AnteriorStim/PostTests';
%     '/media/mobs/DataMOBS85/PAG tests/M784/20092018/AnteriorStim/Pretests';
%     '/media/mobs/DataMOBS85/PAG tests/M784/20092018/PosteriorStim/Post24h';
%     '/media/mobs/DataMOBS85/PAG tests/M784/21092018/AnteriorStim/Post24h';
%     '/media/mobs/DataMOBS85/PAG tests/M784/21092018/PosteriorStim/Post48h';
%     '/media/mobs/DataMOBS85/PAG tests/M784/22092018/AnteriorStim/Post48h';
%     '/media/mobs/DataMOBS85/PAG tests/M789/18092018/CalibContextA';
%     '/media/mobs/DataMOBS85/PAG tests/M789/18092018/CalibContextB/Calib0.0V';
%     '/media/mobs/DataMOBS85/PAG tests/M789/18092018/CalibContextB/Calib0.5V';
%     '/media/mobs/DataMOBS85/PAG tests/M789/18092018/CalibContextB/Calib1.0V';
%     '/media/mobs/DataMOBS85/PAG tests/M789/18092018/CalibContextB/Calib1.5V';
%     '/media/mobs/DataMOBS85/PAG tests/M789/18092018/CalibContextB/Calib2.0V';
%     '/media/mobs/DataMOBS85/PAG tests/M789/18092018/CalibContextC/Calib0.0V';
%     '/media/mobs/DataMOBS85/PAG tests/M789/18092018/CalibContextC/Calib1.0V';
%     '/media/mobs/DataMOBS85/PAG tests/M789/18092018/CalibContextC/Calib1.5V';
%     '/media/mobs/DataMOBS85/PAG tests/M789/18092018/CalibContextC/Calib2.0V';
%     '/media/mobs/DataMOBS85/PAG tests/M789/18092018/CalibContextC/Calib2.5V';
%     '/media/mobs/DataMOBS85/PAG tests/M789/18092018/CalibContextC/Calib3.5V';
%     '/media/mobs/DataMOBS85/PAG tests/M789/18092018/CalibContextC/Calib4.0V';
%     '/media/mobs/DataMOBS85/PAG tests/M789/18092018/CalibContextC/Calib4.5V';
%     '/media/mobs/DataMOBS85/PAG tests/M789/19092018/AnteriorStim/Cond';
%     '/media/mobs/DataMOBS85/PAG tests/M789/19092018/AnteriorStim/Hab';
%     '/media/mobs/DataMOBS85/PAG tests/M789/19092018/AnteriorStim/PostCalib-ContextA';
%     '/media/mobs/DataMOBS85/PAG tests/M789/19092018/AnteriorStim/PostCalib-ContextB';
%     '/media/mobs/DataMOBS85/PAG tests/M789/19092018/AnteriorStim/PostSleep';
%     '/media/mobs/DataMOBS85/PAG tests/M789/19092018/AnteriorStim/PostTests';
%     '/media/mobs/DataMOBS85/PAG tests/M789/19092018/AnteriorStim/Pretests';
%     '/media/mobs/DataMOBS85/PAG tests/M789/20092018/AnteriorStim/Post24h';
%     '/media/mobs/DataMOBS85/PAG tests/M789/20092018/PosteriorStim/Cond';
%     '/media/mobs/DataMOBS85/PAG tests/M789/20092018/PosteriorStim/Hab';
%     '/media/mobs/DataMOBS85/PAG tests/M789/20092018/PosteriorStim/PostSleep';
%     '/media/mobs/DataMOBS85/PAG tests/M789/20092018/PosteriorStim/PostTests';
%     '/media/mobs/DataMOBS85/PAG tests/M789/20092018/PosteriorStim/Pretests';
%     '/media/mobs/DataMOBS85/PAG tests/M789/21092018/AnteriorStim/Post48h';
%     '/media/mobs/DataMOBS85/PAG tests/M789/21092018/PosteriorStim/Post24h';
%     '/media/mobs/DataMOBS85/PAG tests/M790/18092018/CalibContextA';
%     '/media/mobs/DataMOBS85/PAG tests/M790/18092018/CalibContextB/Calib0.0V';
%     '/media/mobs/DataMOBS85/PAG tests/M790/18092018/CalibContextB/Calib1.0V';
%     '/media/mobs/DataMOBS85/PAG tests/M790/18092018/CalibContextB/Calib1.5V';
%     '/media/mobs/DataMOBS85/PAG tests/M790/18092018/CalibContextB/Calib2.5V';
%     '/media/mobs/DataMOBS85/PAG tests/M790/18092018/CalibContextB/Calib4.0V';
%     '/media/mobs/DataMOBS85/PAG tests/M790/18092018/CalibContextC/Calib0.0V';
%     '/media/mobs/DataMOBS85/PAG tests/M790/18092018/CalibContextC/Calib1.0V';
%     '/media/mobs/DataMOBS85/PAG tests/M790/18092018/CalibContextC/Calib1.5V';
%     '/media/mobs/DataMOBS85/PAG tests/M790/18092018/CalibContextC/Calib2.5V';
%     '/media/mobs/DataMOBS85/PAG tests/M790/18092018/CalibContextC/Calib3.0V';
%     '/media/mobs/DataMOBS85/PAG tests/M790/18092018/CalibContextC/Calib3.5V';
%     '/media/mobs/DataMOBS85/PAG tests/M790/18092018/CalibContextC/Calib4.0V';
%     '/media/mobs/DataMOBS85/PAG tests/M790/18092018/CalibContextC/Calib4.5V';
%     '/media/mobs/DataMOBS85/PAG tests/M790/19092018/AnteriorStim/PostCalib-ContextA';
%     '/media/mobs/DataMOBS85/PAG tests/M790/19092018/AnteriorStim/PostCalib-ContextB';
%     '/media/mobs/DataMOBS85/PAG tests/M790/19092018/PosteriorStim/Cond';
%     '/media/mobs/DataMOBS85/PAG tests/M790/19092018/PosteriorStim/Hab';
%     '/media/mobs/DataMOBS85/PAG tests/M790/19092018/PosteriorStim/PostCalib-ContextC';
%     '/media/mobs/DataMOBS85/PAG tests/M790/19092018/PosteriorStim/PostSleep';
%     '/media/mobs/DataMOBS85/PAG tests/M790/19092018/PosteriorStim/PostTests';
%     '/media/mobs/DataMOBS85/PAG tests/M790/19092018/PosteriorStim/PreTests';
%     '/media/mobs/DataMOBS85/PAG tests/M790/20092018/PosteriorStim/Post24h';
%     '/media/mobs/DataMOBS85/PAG tests/M790/21092018/PosteriorStim/Post48h';
%     '/media/mobs/DataMOBS85/PAG tests/M791/18092018/CalibContextA';
%     '/media/mobs/DataMOBS85/PAG tests/M791/18092018/CalibContextB/Calib0.0V';
%     '/media/mobs/DataMOBS85/PAG tests/M791/18092018/CalibContextB/Calib2.0V';
%     '/media/mobs/DataMOBS85/PAG tests/M791/18092018/CalibContextB/Calib2.5V';
%     '/media/mobs/DataMOBS85/PAG tests/M791/18092018/CalibContextC/Calib0.0V';
%     '/media/mobs/DataMOBS85/PAG tests/M791/18092018/CalibContextC/Calib1.0V';
%     '/media/mobs/DataMOBS85/PAG tests/M791/18092018/CalibContextC/Calib2.0V';
%     '/media/mobs/DataMOBS85/PAG tests/M791/18092018/CalibContextC/Calib3.5V';
%     '/media/mobs/DataMOBS85/PAG tests/M791/18092018/CalibContextC/Calib4.0V';
%     '/media/mobs/DataMOBS85/PAG tests/M791/18092018/CalibContextC/Calib5.0V';
%     '/media/mobs/DataMOBS85/PAG tests/M791/18092018/CalibContextC/Calib6.0V';
%     '/media/mobs/DataMOBS85/PAG tests/M791/18092018/CalibContextC/Calib7.0V';
%     '/media/mobs/DataMOBS85/PAG tests/M791/19092018/AnteriorStim/PostCalib-ContextA';
%     '/media/mobs/DataMOBS85/PAG tests/M791/19092018/AnteriorStim/PostCalib-ContextB';
%     '/media/mobs/DataMOBS85/PAG tests/M791/19092018/PosteriorStim/PostCalib-ContextC';
%     '/media/mobs/DataMOBS85/PAG tests/M791/20092018/AnteriorStim/Cond';
%     '/media/mobs/DataMOBS85/PAG tests/M791/20092018/AnteriorStim/Hab';
%     '/media/mobs/DataMOBS85/PAG tests/M791/20092018/AnteriorStim/PostSleep';
%     '/media/mobs/DataMOBS85/PAG tests/M791/20092018/AnteriorStim/PostTests';
%     '/media/mobs/DataMOBS85/PAG tests/M791/20092018/AnteriorStim/PreTests';
%     '/media/mobs/DataMOBS85/PAG tests/M791/21092018/AnteriorStim/Post24h';
%     '/media/mobs/DataMOBS85/PAG tests/M791/22092018/AnteriorStim/Post48h';
%     '/media/mobs/DataMOBS85/PAG tests/M792/18092018/CalibContextA';
%     '/media/mobs/DataMOBS85/PAG tests/M792/18092018/CalibContextB/Calib0.0V';
%     '/media/mobs/DataMOBS85/PAG tests/M792/18092018/CalibContextB/Calib1.0V';
%     '/media/mobs/DataMOBS85/PAG tests/M792/18092018/CalibContextB/Calib2.0V';
%     '/media/mobs/DataMOBS85/PAG tests/M792/18092018/CalibContextC/Calib0.0V';
%     '/media/mobs/DataMOBS85/PAG tests/M792/18092018/CalibContextC/Calib1.0V';
%     '/media/mobs/DataMOBS85/PAG tests/M792/18092018/CalibContextC/Calib3.0V';
%     '/media/mobs/DataMOBS85/PAG tests/M792/18092018/CalibContextC/Calib4.0V';
%     '/media/mobs/DataMOBS85/PAG tests/M792/18092018/CalibContextC/Calib5.0V';
%     '/media/mobs/DataMOBS85/PAG tests/M792/18092018/CalibContextC/Calib5.5V';
%     '/media/mobs/DataMOBS85/PAG tests/M792/18092018/CalibContextC/Calib6.5V';
%     '/media/mobs/DataMOBS85/PAG tests/M792/18092018/CalibContextC/Calib7.0V';
%     '/media/mobs/DataMOBS85/PAG tests/M792/19092018/AnteriorStim/PostCalib-ContextA';
%     '/media/mobs/DataMOBS85/PAG tests/M792/19092018/PosteriorStim/Cond';
%     '/media/mobs/DataMOBS85/PAG tests/M792/19092018/PosteriorStim/Hab';
%     '/media/mobs/DataMOBS85/PAG tests/M792/19092018/PosteriorStim/PostCalib-ContextC';
%     '/media/mobs/DataMOBS85/PAG tests/M792/19092018/PosteriorStim/PostSleep';
%     '/media/mobs/DataMOBS85/PAG tests/M792/19092018/PosteriorStim/PostTests';
%     '/media/mobs/DataMOBS85/PAG tests/M792/19092018/PosteriorStim/PreTests';
%     '/media/mobs/DataMOBS85/PAG tests/M792/20092018/AnteriorStim/Cond';
%     '/media/mobs/DataMOBS85/PAG tests/M792/20092018/AnteriorStim/Hab';
%     '/media/mobs/DataMOBS85/PAG tests/M792/20092018/AnteriorStim/PostSleep';
%     '/media/mobs/DataMOBS85/PAG tests/M792/20092018/AnteriorStim/PostTests';
%     '/media/mobs/DataMOBS85/PAG tests/M792/20092018/AnteriorStim/PreTests';
%     '/media/mobs/DataMOBS85/PAG tests/M792/20092018/PosteriorStim/Post24h';
%     '/media/mobs/DataMOBS85/PAG tests/M792/21092018/AnteriorStim/Post24h';
%     '/media/mobs/DataMOBS85/PAG tests/M792/21092018/PosteriorStim/Post48h';
%     '/media/mobs/DataMOBS85/PAG tests/M792/22092018/AnteriorStim/Post48h';
    };
end

for i=1:length(dirin)
    Dir=dirin{i};
    
    cd(Dir);
    prefix = 'PAG-';  % Experiment prefix
    load('ExpeInfo.mat');
    load('makedataBulbeInputs.mat');
    flnme = [prefix 'Mouse-' num2str(ExpeInfo.nmouse) '-' num2str(ExpeInfo.date) '-' ExpeInfo.phase];
    dir_rip = '';

    %% Make data

    %Set Session
    SetCurrentSession([flnme '.xml']);
    
    % make LFP
    MakeData_LFP
    
    % Make accelerometer Movtsd
    MakeData_Accelero(Dir);
    
    % Digital inputs
    if dodigitalin == 1
        MakeData_Digin
    end
    
    % Get Stimulations if you have any
    if dodigitalin == 1
        GetStims_DB
    end
    %DirJump{1}=Dir;
    %JumpCatcher_PAGTest_SL(DirJump,1,1);
    
end
end

%% After - get freezing, noise and heart