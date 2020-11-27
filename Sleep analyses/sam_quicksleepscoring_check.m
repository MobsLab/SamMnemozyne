
%% MUST BE CHANGED
pathOnline = [pwd '/ERC-M0936-SleepStimTest-rem2_190704_174620/'];
if ~exist(pathOnline,'dir')
    mkdir(pathOnline);
end
pathOut = [pwd '/Figures/'];
if ~exist(pathOut,'dir')
    mkdir(pathOut);
end
%% var init
sscore = [];

%% Get online data
filename = [pathOnline 'sleepScoring.txt'];
delimiterIn = ';';
headerlinesIn = 0;
Online = importdata(filename,delimiterIn,headerlinesIn);

sleep = [];
iund=1;
ss = Online.textdata(:,2);
for i = 1:length(ss)
    switch ss{i}
        case 'Wake'
            sleep(i)=0;
        case 'NREM'
            sleep(i)=1;
        case 'REM'
            sleep(i)=2;
        case 'Undefined'
            sleep(i)=3;
            bef(iund) = sleep(i-1);
            iund = iund+1;
    end
end


%% Figures
stage = {'','Wake','NREM','REM','Undefined',''};

figure, 
subplot (2,2,1:2)
plot(sleep) 
ylim([-1 4])
title('Online Sleep Scoring')
yticklabels(stage)
xlabel('time (sec)')
ylabel('sleep stages')

subplot (2,2,3)
hist(bef), 
xticklabels(stage(2:5))
title('Score before undefined')
xlabel('sleep stages')
ylabel('Nbr of occurence')


subplot (2,2,4)
hist(sleep), 
title('Nbr for each stage')
xticklabels(stage(2:5))
xlabel('sleep stages')
ylabel('total duration (sec)')

%% save data

sscore.wake = find(sleep==0);
sscore.nrem = find(sleep==1);
sscore.rem = find(sleep==2);
score.und = find(sleep==3);

save('quick_onlinesleepscoring.mat','ss');
print([pathOut 'Hypnogram_stims'], '-dpng', '-r300');