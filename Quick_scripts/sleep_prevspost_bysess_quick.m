%%   MAIN ANALYSES
clear all
expe = 'StimMFBWake'; 
expe = 'UMazePAG'; 

mice_num = [1124];

ss = 'accelero';
ss = 'ob';

thresh = [1 .8];

% path
dirPath_sMFBW_sleep = [dropbox 'DataSL/' expe '/Sleep/' date '/'];  % folder where to save

% detect deltas by session
s_launchDeltaDetect(expe,mice_num,ss,thresh)

% Need to run s_launchDeltaDetect first
Hsleep = sam_sleep_prevspost_bysess(expe,mice_num,'stim',0); % plot using delta detection restricted to sleep sessions
    for i=1:length(mice_num)
        figName = ['M' num2str(mice_num(i)) '_sleeparch_prepost'];
        saveF(Hsleep.SleepArch_single{i},figName,dirPath_sMFBW_sleep,'sformat',{'dpng'},'res',300,'savfig',0)
        disp(['M' num2str(mice_num(i)) ' saved']);
    end