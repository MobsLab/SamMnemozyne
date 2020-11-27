function CheckSleepStim(Dir)
%==========================================================================
% Details: Make analysis on sleep scoring around stim during sleep
%           - Gamma from bulbe
%           - Accelerometer
%           - Sleep scoring
%
% INPUTS:
%       - Dir: working directory
%
% OUTPUT:
%
% NOTES: - The folder name must be the voltage used (example:
%               /blabla/3,00V'/)
%
%   Written by Samuel Laventure - 29-10-2020
%      
%==========================================================================
%% Set Directories and variables

[parentDir currDir] = fileparts(pwd);
 
% Mouse number for folder name
load('ExpeInfo.mat');
mouseNum = num2str(ExpeInfo.nmouse);
volt = currDir;


try
   Dir;
catch   
   Dir =  [pwd '/'];
end
cd(Dir);

dir_out = [dropbox '/DataSL/Sleep/SleepStimTest/' mouseNum '/'];
if ~exist(dir_out, 'dir')
    mkdir(dir_out);
    if ismac
        disp('Creating folder (mac version)');
    elseif isunix
        disp('Creating folder (linux version)');
        system(['sudo chown mobs' dir_out]);
    else
        disp('Creating folder (pc version)');
    end
end

% Sleep stages
stagename = {'NREM','REM','Wake'};
% duration around stim in second
stimdur = .1; 
predur = 5;
postdur = 10 + stimdur; 

%#####################################################################
%#                          M  A  I  N
%#####################################################################
%% load variables
make_sleepscoringarray;
load('SleepScoring_OBGamma.mat','sleep_array');

off_all = sleep_array;
load('behavResources.mat','StimEpoch');
bulb = load('B_High_Spectrum.mat','Spectro');
hpc = load('H_Low_Spectrum.mat','Spectro');

% accelero data
load(['LFPData/InfoLFP.mat']);
id_acc = find(strcmp(InfoLFP.structure,'Accelero'));
for iacc=1:3
    load([Dir 'LFPData/LFP' num2str(id_acc(iacc)-1) '.mat']);
    acc(iacc,:) = LFP;
end
% sum 3 accelero data and zscore
acctot = zscore(abs(Data(acc(1))) + abs(Data(acc(2))) + abs(Data(acc(3))));

% stims time
stim = Start(StimEpoch);

for istim=1:length(stim)
    StimPeriod(istim) = intervalSet(stim(istim)-predur*1e4,stim(istim)+postdur*1e4); 
end

% reduce number of offline scoring input to 1 per second
off=[];
off_all(isnan(off_all))=0;
ii=1;
for iss=1:10020:length(off_all)
    if length(off_all)<iss+10020
        en = iss+(length(off_all)-iss);
    else
        en = iss+10020;
    end
    x = off_all(iss:en); 
    if unique(x)==0
        off(ii) = 0;
    else
        [a,b]=hist(x,unique(x));
        [M,id] = max(a);
        off(ii) = b(id);
    end
    clear a b id
    ii=ii+1;
end

% make matrix
for istim=1:length(stim)
    ss(istim,:) = sleep_array(stim(istim)-predur*1e4:stim(istim)+postdur*1e4);
    % get spectral data
    st = find(bulb.Spectro{1,2}>stim(istim)/1e4-predur,1,'first');
    en = find(bulb.Spectro{1,2}<stim(istim)/1e4+postdur,1,'last');
    hi(istim,1:size(bulb.Spectro{1,1},2),1:size(bulb.Spectro{1,1}(st:en,1),1)) = bulb.Spectro{1,1}(st:en,:)';
    clear en st
    st = find(hpc.Spectro{1,2}>stim(istim)/1e4-predur,1,'first');
    en = find(hpc.Spectro{1,2}<stim(istim)/1e4+postdur,1,'last');
    lo(istim,1:size(hpc.Spectro{1,1},2),1:size(hpc.Spectro{1,1}(st:en,1),1)) = hpc.Spectro{1,1}(st:en,:)';
    clear st en
    % get accelero data
    st = find(Range(LFP)>Start(StimPeriod(istim)),1,'first');
    en = find(Range(LFP)<End(StimPeriod(istim)),1,'last');
    accdata{istim} = acctot(st:en); 
    clear st en
end

% average spectrum
hi_mean = squeeze(mean(hi));
lo_mean = squeeze(mean(lo));
hi_timeinter = (predur+postdur)*1e4/size(hi_mean,2);
lo_timeinter = (predur+postdur)*1e4/size(lo_mean,2);

% make real wake spectrum
% find real sleep to wake
towake_id = strfind(sleep_array',[1 1 1 1 3 3 3 3 3])
id = 1; % manually change this number to use other sleep-wake transitions
if ~isempty(towake_id)
    % get spectral data
    st = find(bulb.Spectro{1,2}>towake_id(id)/1e4-predur,1,'first');
    en = find(bulb.Spectro{1,2}<towake_id(id)/1e4+postdur,1,'last');
    hi_wake = bulb.Spectro{1,1}(st:en,:)';
    clear st en
    % get accelero data
    st = find(Range(LFP)>towake_id(id)-predur*1e4,1,'first');
    en = find(Range(LFP)<towake_id(id)+postdur*1e4,1,'last');
    accdata_wake = acctot(st:en); 
    clear st en
else
    warning('There is no non-stim sleep-to-wake occurence in this session. Check in other recordings.');
end

%%
% -------------------------------------------------------------------------
%                              F I G U R E S 
% -------------------------------------------------------------------------

% set text format
set(0,'defaulttextinterpreter','latex');
set(0,'DefaultTextFontname', 'Arial')
set(0,'DefaultAxesFontName', 'Arial')
set(0,'defaultTextFontSize',12)
set(0,'defaultAxesFontSize',12)

supertit=[mouseNum ': Sleep Scoring around stim (' volt ')'];
figure2(1,'pos',[1 1 600 400],'Name', supertit, 'NumberTitle','off')
    imagesc(ss);
        title([mouseNum ': Sleep Scoring around stim (' volt ')'])
        ylabel('Stims #')
        xlabel('time (s)')
        vline(5*1e4)
        colorbar
        caxis([0 3])
        set(gca,'XTick',[1:1e4:(predur+postdur)*1e4],'XTickLabel',num2cell(-predur:1:postdur))
        colorbar('Ticks',[0,1,2,3],'TickLabels',{'Undefined','NREM','REM','Wake'})
    % save figure
    print([dir_out mouseNum '_ss_' volt], '-dpng', '-r300');    

    
% set text format
set(0,'defaulttextinterpreter','latex');
set(0,'DefaultTextFontname', 'Arial')
set(0,'DefaultAxesFontName', 'Arial')
set(0,'defaultTextFontSize',8)
set(0,'defaultAxesFontSize',8)

% Gamma + Accelero for each stim
subpos=5;
supertit=[mouseNum ': Spectral power around stims (' volt ')'];
figure2(2,'pos',[1 1 600 2500],'Name', supertit, 'NumberTitle','off')
    sgtitle([mouseNum ': Spectral power around stims (' volt ')'])
    if ~isempty(towake_id)
        subplot(((length(stim)+1)*3)+1,1,1)
            plot(accdata_wake)
            ylim([-2.5 2.5])
            xlim([1 length(accdata_wake)])
            axis off
            ylabel('Z accelero')
            title('Normal sleep-wake transition')

        subplot(((length(stim)+1)*3)+1,1,2:3)
            imagesc(hi_wake)
            axis xy
            caxis([0 1*1e4])
            set(gca,'XTickLabel',[]);
    end
    for istim=1:length(stim)
        subplot(((length(stim)+1)*3)+1,1,subpos)    
            plot(accdata{istim},'k','LineWidth',0.01)
            axis off
            ylabel('Z accelero')
            xlim([1 length(accdata{istim})])
            ylim([-2.5 2.5])
            if istim==1
                title('Stim transitions')
            end
            
        subplot(((length(stim)+1)*3)+1,1,subpos+1:subpos+2)
            imagesc(squeeze(hi(istim,:,:))), axis xy
            caxis([0 1*1e4])
            ylabel(['Stim #' num2str(istim)])
            if istim==length(stim)
                xlabel('time (s)')
                set(gca,'XTick',[1:1e4/hi_timeinter:size(hi,3)],'XTickLabel',num2cell(-predur:1:postdur))
            elseif istim==1
                set(gca,'XTick',[1:1e4/hi_timeinter:size(hi,3)],'XTickLabel',num2cell(-predur:1:postdur))
                set(gca,'xaxisLocation','top')
            else
                set(gca,'XTickLabel',[]);
            end
            set(gca,'YTick',[1:10:length(bulb.Spectro{1,3})],'YTickLabel',num2cell(ceil(bulb.Spectro{1,3}(1:10:end))))
        subpos=subpos+3;    
    end  
    % save figure
    print([dir_out mouseNum '_obgamma_accelero_' volt], '-dpng', '-r600');   
    
% % gamma and theta spectrum
% for istim=1:length(stim)
%     supertit=['Spectral power around stims -  Stim #' num2str(istim)];
%     figure2(1,'pos',[1 1 2200 800],'Name', supertit, 'NumberTitle','off')
%         subplot(2,1,1)
%             imagesc(squeeze(hi(istim,:,:))), axis xy
%                 title('Bulb - high freq')
%                 ylabel('Frequency')
%                 xlabel('time (s)')
% %                 vline(5*1e4)
%                 colorbar
%                 caxis([0 1*1e4])
%                 set(gca,'XTick',[1:hi_timeinter:size(hi,3)],'XTickLabel',num2cell(-predur:1:postdur))
%                 set(gca,'YTick',[1:4:length(bulb.Spectro{1,3})],'YTickLabel',num2cell(ceil(bulb.Spectro{1,3}(1:4:end))))
%         
%         subplot(2,1,2)
%             imagesc(squeeze(lo(istim,:,:))), axis xy
%                 title('HPC - low-freq')
%                 ylabel('Frequency')
%                 xlabel('time (s)')
% %                 vline(5*1e4)
%                 colorbar
%                 caxis([0 8*1e4])
%                 set(gca,'XTick',[1:1e4/lo_timeinter:size(lo,3)],'XTickLabel',num2cell(-predur:1:postdur))
%                 set(gca,'YTick',[1:20:length(hpc.Spectro{1,3})],'YTickLabel',num2cell(ceil(hpc.Spectro{1,3}(1:20:end))))
% 
% end






