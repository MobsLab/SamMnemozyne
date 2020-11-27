function make_StimSent()
%%
%  Description: make stim data .mat from raw data (intan and Open Ephys)


% load working variables
try
    load('LFPData/DigInfo3.mat');
    % get stim information
    StimEpoch = thresholdIntervals(DigTSD,0.99,'Direction','Above');
    
catch
    load('events/Spk_Srt_+_Stim-106.0_TTL_1.mat','timestamps');
    StimEpoch = intervalSet(timestamps(1:2:end),timestamps(2:2:end));
end
    
nbStim = length(Start(StimEpoch));
tStim = Start(StimEpoch);
TTLInfo.StimEpoch=StimEpoch;

%save
save('StimEpoch.mat','StimEpoch','nbStim','tStim');
save('behavResources.mat', 'StimEpoch', '-append');
save('behavResources.mat', 'TTLInfo', '-append');

%save for brainstorm
tStim = tStim/1E4;
save('stimarray','tStim');

end