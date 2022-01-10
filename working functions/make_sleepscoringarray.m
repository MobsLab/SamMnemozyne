
%% fonction to extract sleep scoring and put it in an array
try
    disp('Processing OBGamma')
    load('SleepScoring_OBGamma.mat');

    endpt = int32(max(max(End(SleepWiNoise)),max(End(WakeWiNoise))));
    sleep_all = nan(endpt,1);
    %NREM
    st=int32(Start(SWSEpoch));
    en=int32(End(SWSEpoch));
    for i=1:length(st)
        sleep_all(st(i)+1:en(i)+1) = 1;    
    end
    %REM
    st=int32(Start(REMEpoch));
    en=int32(End(REMEpoch));
    for i=1:length(st)
        sleep_all(st(i)+1:en(i)+1) = 2;    
    end
    %WAKE
    st=int32(Start(Wake));
    en=int32(End(Wake));
    for i=1:length(st)
        sleep_all(st(i)+1:en(i)+1) = 3;    
    end

    sleep_array = sleep_all;
    % save it in SleepScoring .mat file
    save('SleepScoring_OBGamma.mat','sleep_array','-append','-v7.3')
    disp('OBGamma done.')
catch
    disp('No OBGamma available. Skipping...')
end
try
    disp('Processing Accelero')
    load('SleepScoring_Accelero.mat');

    endpt = int32(max(max(End(SleepWiNoise)),max(End(WakeWiNoise))));
    sleep_all = nan(endpt,1);
    %NREM
    st=int32(Start(SWSEpoch));
    en=int32(End(SWSEpoch));
    for i=1:length(st)
        sleep_all(st(i)+1:en(i)+1) = 1;    
    end
    %REM
    st=int32(Start(REMEpoch));
    en=int32(End(REMEpoch));
    for i=1:length(st)
        sleep_all(st(i)+1:en(i)+1) = 2;    
    end
    %WAKE
    st=int32(Start(Wake));
    en=int32(End(Wake));
    for i=1:length(st)
        sleep_all(st(i)+1:en(i)+1) = 3;    
    end

    sleep_array = sleep_all;
    % save it in SleepScoring .mat file
    save('SleepScoring_Accelero.mat','sleep_array','-append','-v7.3')
    disp('Accelero done.')
catch
    disp('No Accelero available. Skipping...')
end
disp('Sleep array completed.')