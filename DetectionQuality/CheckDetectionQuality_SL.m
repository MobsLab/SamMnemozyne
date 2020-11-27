% 
%   
%==========================================================================
% Details: Launch inside the target directory
%
% INPUTS:
%       
%
% OUTPUT:
%
% NOTES: 
%
%   From  CheckDetectionQuality_DB written by Dima. 
%                            copied on 5 June 2020
%   Changed made by Samuel Laventure - 07-06-2020 
%
%
% NEED TO DO:
%       - test and correct for intan recordings
%       - add comparison with all other clusters from .clu group   
%==========================================================================
clear all

%% Parameters
% date for dir_out folders
t = char(datetime('now','Format','y-MM-d'));

% Working dir
Dir = [pwd '/']; %'/media/mobs/DataMOBS127/M1059/200529/OE_NREMstim/recording1/';
cd(Dir);

% ----------------------------------------------- %
%                MANUAL INPUT
%   |-------------------------------------------- %
%   |
%   |
%   |----------------------------------------------------------------------
% Directory to save and name of the figure to save
dir_out= [dropbox 'DataSL/QualityValidation/' t '/'];
if ~exist(dir_out,'dir')
    mkdir(dir_out);
end

% Set target CLUSTER
cluname = 'TT1c4'; % from cellnames
numclust = 4;
nelec = 1;  %position of the electrode in the spike group
electnum = 34; % physical number of the electrode
cluother_id = [1:3,5:12]; % position in cellnames variable of all other cluster 

% Set target sleep stage 
% ---> 'All' or 'Wake' or 'NREM' or 'REM' or 'Sleep'
stage = 'NREM';

% Set recording system / only one can be set to 1;
oe=1;    % open ephys
intan=0; % intan

% --- SET BOXES POSITIONS ---
box.nb = 3;
% threshold
box.thresh = [-273 -273 -273];
% channel as set in OpenEphys spike detector plugin
box.ch = [33 33 33]; 
% is this a stim (1) or non-stim (0) electrode
box.stim = [1 1 1];   
% boxes position
box.recx = [397 513 691];
box.recy = [104 -230 53];
box.recw = [171 210 187];
box.rech = [246 274 195];

%--------------------------------------------------------------------------
%%
%#####################################################################
%#
%#                           M A I N
%#
%#####################################################################
%% Set data path
if oe
    fileSignal = 'Rhythm_FPGA-100.0_TTL_1.mat';
    SignalPath = dir(fullfile(pwd, '**', fileSignal));

    fileDetect = 'Spk_Srt_+_Stim-106.0_TTL_1.mat';
    DetectPath = dir(fullfile(pwd, '**', fileDetect));
    
    fileStart = 'sync_messages.txt';
    StartPath = dir(fullfile(pwd, '**', fileStart));
end

%% Loading variables
% load raw signal
if ~exist(['raw' num2str(electnum) '.mat'])
    disp('Making raw signal file...')
    MakeData_Detection(pwd,electnum);
end
load(['raw' num2str(electnum) '.mat']);

% load detection
if oe        
    fid = fopen([StartPath.folder '/' fileStart],'rt');
    C = textscan(fid,'%*s%s%s%f%s%f%[^\n]', 'Delimiter',',= ', 'MultipleDelimsAsOne',true);
    fclose(fid);
    tmp = strfind(C{1,2}{1},'@');
    timeStart=str2double(C{1,2}{1}(1:tmp-1));
    
    load([SignalPath.folder '/' fileSignal],'timestamps'); %detection file    
    RecStart = (double(timestamps(1))+timeStart)/2; % Openephys sampling rate 20KHz
    clear timestamps
    
    load([DetectPath.folder '/' fileDetect]); %detection file    
    tstamps = (double(timestamps)/2)-(timeStart/2); % Openephys sampling rate 20KHz
elseif intan
    load('DetectionTSD.mat');
end

% load spikes and waveforms
load('SpikeData.mat');
load(['Waveforms/Waveforms' cellnames{numclust} '.mat']);

%load sleep scoring
try
    load('SleepScoring_OBGamma.mat','Epoch','Wake','SWSEpoch','REMEpoch','Sleep');
catch
    load('SleepScoring_Accelero.mat','Epoch','Wake','SWSEpoch','REMEpoch','Sleep');
end

% load stims
load('behavResources.mat','StimEpoch')

%% Create event file of detection if doesn't already exist
if ~exist('detection_events.evt.det')
    SaveEvents_SL('detection_events.evt.det',DetectedArray/1e4,electnum,'Detect','overwrite','on')
end

%% Set working variables
% set cluster info
numclust = find(contains(cellnames,cluname));

% sleep/wake stage
switch stage
    case 'All'
        ss = Epoch;
    case 'Wake'
        ss = Wake;
    case 'NREM'
        ss = SWSEpoch;
    case 'REM'
        ss = REMEpoch;
    case 'Sleep'
        ss = Sleep;        
end

% online detection
if oe
    % clean detection (take out detection of artefact)
%     diff_time = diff(tstamps(1:2:end));
%     id_short = find(diff_time<1000);   % set ISI in 1e4
    st_tmp = tstamps(1:2:end);
    ed_tmp = tstamps(2:2:end);
    tim_stim = Start(StimEpoch);
%     st_tmp(id_short+1) = [];
%     ed_tmp(id_short+1) = [];
    detout=[];stimout=[];
    for idet=1:length(st_tmp)
        idx = find(tim_stim>st_tmp(idet),1,'first');
        if tim_stim(idx)-st_tmp(idet) > 1000
            detout(end+1) =  idet;
        end
    end
    for istm=1:length(tim_stim)
        idx = find(st_tmp<tim_stim(istm),1,'last');
        if tim_stim(istm)-st_tmp(idx) > 1000
            stimout(end+1) =  istm;
        end
    end
    % take out thrash
    st_clean = st_tmp;
    ed_clean = ed_tmp;
    st_clean(detout) = [];
    ed_clean(detout) = [];
    stim_clean = tim_stim;
    stim_clean(stimout) = [];
    % create clean detection array   
    Detected = intervalSet(st_clean,ed_clean); 
    DetectedArray = st_clean; 
elseif intan
    Detected = thresholdIntervals(DetectionTSD,0.99,'Direction','Above');
    DetectedArray = Start(Detected);
end
st_p = Start(Detected);
Detect_tsd =tsd(Start(Detected),Start(Detected));
Detectpre_tsd =tsd(st_p-30000,st_p-30000);
NumStimDetected = length(Start(Detected));
NumSpikesClustered = length(S{numclust});

SpikesTimes = S{numclust};
%SpikesTimes = Restrict(S{numclust},ss);
if isempty(Data(SpikesTimes))
    warning(['No spike found during epoch ' stage]);
    return
end

% Restrict W from S data
sp = Range(SpikesTimes);
ii=1;
% find indices
for i=1:length(sp)
    id_sp(ii)=find(Range(S{numclust})==sp(i));
    ii=ii+1;
end
% Use indices to rectrict W
Wr = W(id_sp,:,:);


%% Physical stim timing with online detection
[C, B] = CrossCorr(DetectedArray, stim_clean, 10, 100);
figure, 
    b1 = bar(C(46:56));   % from -50 to 50 ms
    set(gca,'Xtick',[1:11],'XtickLabel',cellstr(num2str(B(46:56))));
    title('Lag from detection to stimulation')
    xlabel('time(ms)')
    ylabel('% of detection')
    xline(6,'-r')
    dim = [.15 .6 .3 .3];
    annotation('textbox', dim, ...
        'String', [num2str(length(stim_clean)/length(DetectedArray)*100) '% followed by stim'], ...
        'FitBoxToText','on');
    % save
    print([dir_out 'DetectStimLag'], '-dpng', '-r300');
    if ismac
        disp('Saving to mac');
    elseif isunix
        cd(dir_out)
        system(['sudo chown mobs DetectStimLag.png']);
        cd(Dir)
    end

%% Sleep scoring check
% stage duration
N = length(Start(SWSEpoch));
R = length(Start(REMEpoch));
W = length(Start(Wake));
A = N+R+W;
Np = N/A*100;
Rp = R/A*100;
Wp = W/A*100;
%number of detection per stage
sNREM = length(Data(Restrict(Detectpre_tsd,SWSEpoch)));
sREM =  length(Data(Restrict(Detect_tsd,REMEpoch)));
sWake =  length(Data(Restrict(Detect_tsd,Wake)));
%proportion
pNREM = sNREM/length(DetectedArray)*100;
pREM = sREM/length(DetectedArray)*100;
pWake = sWake/length(DetectedArray)*100;

switch stage
    case 'NREM'
        ss_spk = sNREM;
    case 'REM'
        ss_spk = sREM;
    case 'Wake'
        ss_spk = sWake;
    case 'Sleep'
        ss_spk = sNREM+SREM;
    case 'All'
        ss_spk = sNREM+SREM+Wake;
end

% set pie chart colors
t1col = [1 0 0];   %red        
t2col = [0 1 0];   %green
t3col = [0 0 1];   %blue
tilecolor = [t1col; t2col; t3col];
clrs = get(gca,'colororder');

supertit = 'Online detection by sleep stage';
figure2(1,'Color',[1 1 1], 'rend','painters','pos',[1 1 400 900],'Name', supertit, 'NumberTitle','off')
    subplot(2,1,1)
        pie_modified([Np Rp Wp],clrs(1:3,1:3))
        legend({'NREM','REM','Wake'},'Location','northwest')
        title({'Proportion of sleep stage',['Targeted stage: ' stage]})
    subplot(2,1,2)
        pie_modified([pNREM pREM pWake],clrs(1:3,1:3))
        legend({'NREM','REM','Wake'},'Location','northwest')
        title({'Proportion of online detected spikes by stage'})
    
print([dir_out 'SleepStage_detect'], '-dpng', '-r300');
if ismac
    disp('Saving to mac');
elseif isunix
    cd(dir_out)
    system(['sudo chown mobs SleepStage_detect.png']);
    cd(Dir)
end


%% DEBUGGING/Verification zone
% COMMENT IF NOT NEEDED
% Display each detection in a large window 
dat=Data(raw);
tim=Range(raw);

hitim = 1000;
lotim = 1200;
rndspk=randi(length(DetectedArray),1);
idspk = find(tim<DetectedArray(rndspk),1,'last');
datcor = dat(idspk-hitim:idspk+lotim);
delstim = stim_clean(rndspk)-DetectedArray(rndspk);
stimpos = (hitim+delstim*2);
    
supertit = 'Random detection sample';
figure2(1,'Color',[1 1 1], 'rend','painters','pos',[1 1 1400 400],'Name', supertit, 'NumberTitle','off')
    plot(datcor','k')
    vl = vline(hitim,'r','Detection');
    vline(stimpos,'g','Stim')
    rectangle('Position', [hitim-800 -5000 800 10000], 'FaceColor', [0 0 1 0.5])
    xlim([1 hitim+lotim])
    ylim([-4000 4000])
    title({'RAW LFP timelocked to detection timestamps'})
    ylabel('uV')
    xlabel('Time (msec)')
    set(gca,'Xtick',[1:100:(hitim+lotim)],'XTickLabel',num2cell(-hitim/2:50:lotim/2))
    
    % small line to run to clear plot for debugging
    % if you're not planning on using it, comment it.
    % delete(p), delete(vl);
    
    print([dir_out 'RawDetectONOFF'], '-dpng', '-r300');
    if ismac
        disp('Saving to mac');
    elseif isunix
        cd(dir_out)
        system(['sudo chown mobs RawDetectONOFF.png']);
        cd(Dir)
    end
    
% quick check for quality of detection (check ondetect number)/ set lag
% time after the for command
ms = [100:50:400];
begin = DetectedArray;
sptostim_id=[];
for ims=1:length(ms)
    ondetect_id{ims} = [];
    offdetect{ims} = [];
    offdetect_id{ims} = [];
    gotspike=0;
    for ispike=1:length(begin)
        gotspike = find((sp < begin(ispike) & sp > begin(ispike)-ms(ims)));%find((sp < begin(ispike) & sp > begin(ispike)-ms(ims))); %,1,'last'); %& (sp > begin(ispike)-ms(ims))      
        if gotspike
            ondetect_id{ims}(end+1) = ispike;
%             lns = length(offdetect{ims})+length(gotspike);
%             offdetect{ims}(end+1:lns) = sp(gotspike);
%             offdetect_id{ims}(end+1:lns) = gotspike;
            offdetect{ims}(end+1) = sp(gotspike(end));
            offdetect_id{ims}(end+1) = gotspike(end);
            % for dist spike to stim
            if ims==7
                sptostim_id(end+1) = find(stim_clean>sp(gotspike(end)),1,'first');
            end
            gotspike=[];
        end    
    end
end
for i=1:length(ms)
    szdet(1,i) = size(ondetect_id{i},2);
    szdet_off(1,i) = size(offdetect_id{i},2);
end
% make barplot of results
supertit = 'Proportion of co-occuring detection: online/offline';
figure2(1,'Color',[1 1 1], 'rend','painters','pos',[1 1 600 900],'Name', supertit, 'NumberTitle','off')
    subplot(2,2,1:2)
        bar(szdet/length(DetectedArray)*100)
            title({'% ONLINE spikes with offline spikes before detection timepoint', ...
                ['by size of pre-window [total of ' num2str(length(DetectedArray)) ' online spikes]']})
            set(gca,'Xtick',[1:length(ms)],'XTickLabel',num2cell(ms/10))
            xlabel('msec before online detection')
            ylabel('% spikes found')
            ylim([0 max(szdet/length(DetectedArray)*100)*1.15])
%             print([dir_out 'barOnlineFound_' stage], '-dpng', '-r300');
    subplot(2,2,3:4)
        bar(szdet_off/length(sp)*100)
            title({'% OFFLINE spikes detected before online detection timepoint', ...
                ['by size of pre-window [total of ' num2str(length(sp)) ' offline spikes]']})
            set(gca,'Xtick',[1:length(ms)],'XTickLabel',num2cell(ms/10))
            xlabel('msec before online detection')
            ylabel('% spikes found')
            ylim([0 max(szdet_off/length(sp)*100)*1.15])
    
    print([dir_out 'barOn-OfflineFound_' stage], '-dpng', '-r300');   
    if ismac
        disp('Saving to mac');
    elseif isunix
        cd(dir_out)
        system(['sudo chown mobs barOn-OfflineFound_' stage '.png']);
        cd(Dir)
    end

% distance from spike to stimulation
id_tmp = sptostim_id(:);
id_tmp(id_tmp==0) = nan;
for i=1:length(id_tmp)
    if ~isnan(id_tmp(i))
        tim_stimspk(i) = stim_clean(id_tmp(i));
        dist(i) = tim_stimspk(i) - sp(offdetect_id{end}(i));
    else
        dist(i) = nan;
    end
end

[n,x] = hist(dist);

figure, 
    hist(dist,20) 
    xlim([0 900])
    ylim([0 max(n)*1.05])
    set(gca,'Xtick',[0:50:900],'XTickLabel',num2cell([0:50:900]/10))
    xlabel('Delay spike-stim (ms)')
    ylabel('Number of spike')
    title('Delay between spike detected and stimulation (ms)')
    
    print([dir_out 'DelaySpikeStim_' stage], '-dpng', '-r300');   
    if ismac
        disp('Saving to mac');
    elseif isunix
        cd(dir_out)
        system(['sudo chown mobs DelaySpikeStim_' stage '.png']);
        cd(Dir)
    end
    
    
% shape of these detected spikes
% for ims=1:length(ms)
%     Wall{ims} = [];
%     for is=1:length(offdetect_id{ims})
%         Wall{ims}(end+1,1:32) = Wr(offdetect_id{ims}(is),nelec,:);
%     end
%     Wmean{ims} = squeeze(mean(Wall{ims},1));
%     Wstd{ims} = squeeze(std(Wall{ims}));
%     figure, 
%         shplot = shadedErrorBar(1:32,Wmean{ims},Wstd{ims},'k');
%         title({'Average spike detected online spike in', ['window of ' num2str(ms(ims)/10) 'msec before']})
%         xlabel('timepoints')
%         ylabel('uV')
%         xlim([1 32])
%         print([dir_out 'AverageSpkOfft_' num2str(ms(ims)) 'bef_' stage], '-dpng', '-r300');
%         if ismac
%             disp('Saving to mac');
%         elseif isunix
%             cd(dir_out)
%             system(['sudo chown mobs AverageSpkOfft_' num2str(ms(ims)) 'bef_' stage '.png']);
%             cd(Dir)
%         end
% end

        
% quick check for lag (check lag)
% begin = Start(Detected);
% sp = Data(SpikesTimes);
% gotspike = 0;
% offdetect = 0;
% ondetect_id = 0;
% gotspk=0;
% for ispike=1:length(begin)
%     try
%         lag_id(ispike)=find(sp < begin(ispike),1,'last');
%         gotspk=1;
%     catch
%         warning('Exited because no spikes are available (check for lag section)')
%         break
%     end
% end
% if gotspk
%     lag = begin-sp(lag_id);
%     maxy = max(lag);
%     figure, hist(lag,500);
%         ylim([0 50])
% %          set(gca,'XTickLabel',num2cell(10:10:100))
%          xlabel('time in 1E4 from online detection')
%          ylabel('Number of online spikes found')
%         title('Lag from online to last offline spike');
%         
%         print([dir_out 'LagAll_' stage], '-dpng', '-r300');
%         if ismac
%             disp('Saving to mac');
%         elseif isunix
%             cd(dir_out)
%             system(['sudo chown mobs LagAll_' stage '.png']);
%             cd(Dir)
%         end
%      
%      figure, hist(lag,10000);
%         ylim([0 20])
%         xlim([1 10000])
% %         set(gca,'XTickLabel',num2cell(10:10:100))
%          xlabel('msec(?) from online detection')
%          ylabel('Number of online spikes found')
%         title('Lag from online to last offline spike');
%         
%         print([dir_out 'Lag1000ms_' stage], '-dpng', '-r300');
%         if ismac
%             disp('Saving to mac');
%         elseif isunix
%             cd(dir_out)
%             system(['sudo chown mobs Lag1000ms_' stage '.png']);
%             cd(Dir)
%         end
% end

%% Saving quality variables
save('QualityValidation.mat','stim_clean','DetectedArray','stimout','detout','Detect_tsd')


%% Offline detection with boxes - prep
%set var
box.x=[];box.y=[];box.w=[];box.h=[];
% Set position
for ibox=1:length(box.recx)
    % OpenEphys detection window width is 1300 microsec for 32 data points 
    % (15 pre, 17 post): 40 px/points). 
    %----------------------------------
    % set x and width (time)
    box.x(ibox)=ceil(box.recx(ibox)/40);
    box.w(ibox)=ceil(box.recw(ibox)/40);
    box.x2(ibox)=box.x(ibox)+box.w(ibox);
    %set y and amplitude (uV)
    box.y(ibox)=box.recy(ibox);
    box.h(ibox)=box.rech(ibox);
    box.y2(ibox)=box.y(ibox)-box.h(ibox);
end

%Verification sample
figure, plot(squeeze(Wr(randi(size(Wr,1),1),3,:))')
    for ibox=1:length(box.recx)
        rectangle('Position',[box.x(ibox) box.y(ibox)-box.h(ibox) box.w(ibox) box.h(ibox)]);
    end
    yline(box.thresh(ibox),'r');
    ylim([-2000 1000])
    title('Boxes verification sample')
        
%% Offline detection with boxes - process
% --- Process detection ---
f=40; % interpolation factor
inB = zeros(1,size(Wr,1));
inP = zeros(1,size(Wr,1));
for isp=1:size(Wr,1)
    inb = zeros(1,length(box.x));
    inpath = zeros(1,length(box.x));
    wav = Wr(isp,nelec,:);
    wavint = interp(wav,f);
    % threshold data        
    for ibox=1:box.nb
        % checking only for datapoint location
        if wav(14)<box.thresh(ibox) % will not work well if multiple windows or set of boxes
            inID = find((wav(box.x(ibox):box.x2(ibox)) < box.y(ibox)) & ...
                (wav(box.x(ibox):box.x2(ibox)) > box.y2));
            if inID
                inb(ibox) = 1;
            end
            clear inID
        end
        
        %checking for complete path
        if find(wavint((14*f)-f:(14*f)-1)<box.thresh(ibox)) % will not work well if multiple windows or set of boxes
            % checking only for datapoint location
            inID = find((wavint(box.x(ibox)*f:box.x2(ibox)*f) < box.y(ibox)) & ...
                (wavint(box.x(ibox)*f:box.x2(ibox)*f) > box.y2(ibox)));
            if inID
                inpath(ibox) = 1;
            end
            clear inID
        end
    end
    % by datapoints
    if isempty(inb(inb==0))
        inB(isp) = 1;
    end
    % by interpolated path
    if isempty(inpath(inpath==0))
        inP(isp) = 1;
    end
end
% Number of spike detected offline with boxes
nbInBox = sum(inB);
nbInPath = sum(inP);



%% Figure
%--------------------------------------------------------------------------
%--------------------Plot mean offline detection spike---------------------
%--------------------------------------------------------------------------
Bspk = find(inB);
Pspk = find(inP);
supertit = 'Averaged spike detected offline with boxes';
figure2(1,'Color',[1 1 1], 'rend','painters','pos',[1 1 1000 850],'Name', supertit, 'NumberTitle','off')
    subplot(2,2,1:2)
        for isp=1:100
            plot(squeeze(Wr(Bspk(randi(length(Bspk),1)),nelec,:))','k')
            hold on
        end
        for ibox=1:length(box.recx)
            rectangle('Position',[box.x(ibox) box.y(ibox)-box.h(ibox) box.w(ibox) box.h(ibox)],...
                'EdgeColor','r','LineWidth',2);
        end
        yline(box.thresh(ibox),'r','Threshold','LineWidth',2);
        ylim([-350 350]) 
        xlim([1 32])
        ylabel('Frequency')
        xlabel('Data-points')
        title('Detection with points IN boxes only')
        
    subplot(2,2,3:4)
        for isp=1:100
            plot(squeeze(Wr(Pspk(randi(length(Pspk),1)),nelec,:))','k')
            hold on
        end
        for ibox=1:length(box.recx)
            rectangle('Position',[box.x(ibox) box.y(ibox)-box.h(ibox) box.w(ibox) box.h(ibox)],...
                'EdgeColor','r','LineWidth',2);
        end
        yline(box.thresh(ibox),'r','Threshold','LineWidth',2);
        ylim([-350 350]) 
        xlim([1 32])
        ylabel('Frequency')
        xlabel('Data-points')
        title('Detection with paths crossing boxes')    
        
    print([dir_out 'OffBoxAverageSpikes_' stage], '-dpng', '-r300');
    if ismac
        disp('Saving to mac');
    elseif isunix
        cd(dir_out)
        system(['sudo chown mobs OffBoxAverageSpikes_' stage '.png']);
        cd(Dir)
    end







        
% SpikesDetectedCorrectly = Restrict(Restrict(SpikesTimes,ss),Detected);
% NumSpikesDetectedCorr = length(Data(SpikesDetectedCorrectly));
% 
% 
% SpikesDetectedCorrArray = Data(SpikesDetectedCorrectly);
% AllSpikesArray = Data(S{numclust});
% 
% AllSpikesArraySamples = round(AllSpikesArray/1e4*2e4);
% DetectedArraySamples = round(DetectedArray/1e4*2e4);
% SpikesDetectedCorrArraySamples = round(SpikesDetectedCorrArray/1e4*2E4);
% 
% id_found = zeros(1,length(DetectedArraySamples));
% for i = 1:length(SpikesDetectedCorrArraySamples)
%     [m(i),id] = min(abs((DetectedArraySamples+14)-SpikesDetectedCorrArraySamples(i)));
%     if m(i)<4
%         id_found(i) = id;
%     end
% end
% id_found = nonzeros(id_found);
% 
% DetectionWOSpikesIDX = setdiff([1:length(DetectedArraySamples)],id_found);
% [D,SpikesDetectedCorrIDX] = intersect(AllSpikesArray,SpikesDetectedCorrArray);
% [D,SpikesWODetectionIDX] = setdiff(AllSpikesArray,SpikesDetectedCorrArray);
% 
% clear D
% %
% % Spikes that were detected but did not appear after Kustakwik
% 
% disp('Initializing GPU')
% gpudev = gpuDevice(1); % initialize GPU (will erase any existing GPU arrays)
% 
% NchanTOT = 73;
% NT=32832;
% ntbuff=64;
% Nchan = 5;
% nt0=32;
% fbinary = [Dir 'M979_20190917_Decoding_Threshold_Clu6.fil'];
% d = dir(fbinary);
% ForceMaxRAMforDat   = 10000000000;
% memallocated = ForceMaxRAMforDat;
% nint16s      = memallocated/2;
% 
% ExtractArray = round(DetectedArray(DetectionWOSpikesIDX)/1e4*20000);
% 
% 
% NTbuff      = NT + ntbuff;
% Nbatch      = ceil(d.bytes/2/NchanTOT /(NT-ntbuff));
% Nbatch_buff = floor(4/5 * nint16s/Nchan /(NT-ntbuff)); % factor of 4/5 for storing PCs of spikes
% Nbatch_buff = min(Nbatch_buff, Nbatch);
% 
% DATA =zeros(NT, NchanTOT,Nbatch_buff,'int16');
% fid = fopen(fbinary, 'r');
% indicesTokeep = [64 51 53 54 55]';
% 
% waveforms_all = zeros(length(indicesTokeep),nt0,size(ExtractArray,1));
% 
% fprintf('Extraction of waveforms begun \n')
% for ibatch = 1:Nbatch
%     if mod(ibatch,10)==0
%         if ibatch~=10
%             fprintf(repmat('\b',[1 length([num2str(round(100*(ibatch-10)/Nbatch)), ' percent complete'])]))
%         end
%         fprintf('%d percent complete', round(100*ibatch/Nbatch));
%     end
%     
%     offset = max(0, 2*NchanTOT*((NT - ntbuff) * (ibatch-1) - 2*ntbuff));
%     if ibatch==1
%         ioffset = 0;
%     else
%         ioffset = ntbuff;
%     end
%     fseek(fid, offset, 'bof');
%     buff = fread(fid, [NchanTOT NTbuff], '*int16');
%     
%     nsampcurr = size(buff,2);
%     if nsampcurr<NTbuff
%         buff(:, nsampcurr+1:NTbuff) = repmat(buff(:,nsampcurr), 1, NTbuff-nsampcurr);
%     end
%         dataRAW = gpuArray(buff);
%         
%         dataRAW = dataRAW';
%         dataRAW = dataRAW(:, indicesTokeep);
%         DATA = gather_try(int16( dataRAW(ioffset + (1:NT),:)));
%         dat_offset = offset/NchanTOT/2+ioffset;
%         
%         for i = 1:length(indicesTokeep)
%             temp = find(ismember(ExtractArray, [nt0/2+1:size(DATA,1)-nt0/2] + dat_offset));
%             temp2 = ExtractArray(temp)-dat_offset;
%             
%             startIndicies = temp2;
%             stopIndicies = startIndicies+31;
%             X = cumsum(accumarray(cumsum([1;stopIndicies(:)-startIndicies(:)+1]),[startIndicies(:);0]-[0;stopIndicies(:)]-1)+1);
%             X = X(1:end-1);
%             waveforms_all(:,:,temp) = reshape(DATA(X,1:length(indicesTokeep))',size(indicesTokeep,1),nt0,[]);
%         end
%         
% end
% 
% SpikesNotFoundbyClustering = permute(waveforms_all,[3 1 2]);
% 
% %% Plot
% 
% % Detected spikes that match
% step = 20;
% f = figure('units', 'normalized', 'outerposition', [0 0 0.65 1]);
% for elec = 1:size(W,2)
%     subplot(13,15,[((elec-1)*30)+1:((elec-1)*30)+5 ((elec-1)*30)+16:((elec-1)*30)+20])
%     dat1 = W(SpikesDetectedCorrIDX,elec,:);
%     dat1 = dat1(1:step:end,:);
%     dat2 = W(SpikesWODetectionIDX,elec,:);
%     dat2 = dat2(1:step:end,:);
%     add1 = plot(dat1','color',[0.6 0.6 0.6]);
%     hold on
%     add2 = plot(dat2','color',[1 0.714 0.757]);
%     for i=1:length(add2)
%         add2(i).Color(4) = 0.1;
%     end
%     hold on
%     main1 = plot(nanmean(dat1),'color','k','linewidth',2);
%     ylim([-3000 1000])
%     xlim([0 35])
%     hold on
%     main2 = plot(nanmean(dat2),'color','r','linewidth',2);
%     main2.Color(4) = 0.4;
%     ylim([-3000 1000])
%     xlim([0 35])
%     set(gca,'FontWeight','bold','FontSize',14,'LineWidth',3);
%     if elec == 1
%         line(xlim,[-1041 -1041],'Color','r');
%         title(['Algorithm detected correctly ' num2str(round(length(SpikesDetectedCorrIDX)/length(AllSpikesArray)*100))...
%             '% of spikes']);
%         set(gca, 'YTickLabel',[],'XTickLabel',[]);
%     elseif elec == 4
%         xlabel('Time in samples')
%         legend([main1 main2], {'Detected','Not detected'},'FontSize',10, 'Location','SouthEast')
%     else
%         set(gca, 'YTickLabel',[],'XTickLabel',[]);
%     end
% end
% 
% step = 10;
% for elec = 1:size(W,2)
%     subplot(13,15,[((elec-1)*30)+11:((elec-1)*30)+15 ((elec-1)*30)+26:((elec-1)*30)+30])
%     dat = SpikesNotFoundbyClustering(:,elec,:);
%     dat = dat(1:step:end,:);
%     plot(dat','color',[0.6 0.6 0.6]), hold on
%     plot(nanmean(dat),'color','k','linewidth',2)
%     ylim([-3000 1000])
%     xlim([0 35])
%     set(gca,'FontWeight','bold','FontSize',14,'LineWidth',3);
%     if elec == 1
%         line(xlim,[-1041 -1041],'Color','r');
%         title([num2str(round(length(DetectionWOSpikesIDX)/length(DetectedArray)*100))...
%             '% of detected spikes were not found offline']);
%         set(gca, 'YTickLabel',[],'XTickLabel',[]);
%     elseif elec == 4
%         xlabel('Time in samples')
%     else
%         set(gca, 'YTickLabel',[],'XTickLabel',[]);
%     end
% end
% 
% subplot(13,15,[151:155 166:170])
% [C,B]=CrossCorr(AllSpikesArray,AllSpikesArray,1,50);C(B==0)=0;
% bar(B,C,'FaceColor','k','EdgeColor','k')
% set(gca,'FontWeight','bold','FontSize',14,'LineWidth',3);
% xlabel('time (ms)')
% ylim([0 20])
% title('Autocorrelogram of offline detected cluster')
% 
% string = [num2str(NumSpikesClustered) ' spikes found offline' newline num2str(NumStimDetected) ' spikes found offline'];
% annotation(f,'textbox',[0.41 0.03 0.2 0.1],'String',string, 'LineWidth',3,...
%         'HorizontalAlignment','center', 'FontSize', 14, 'FontWeight','bold',...
%         'FitBoxToText','on');
% 
% subplot(13,15,[161:165 176:180])
% [C,B]=CrossCorr(DetectedArray(DetectionWOSpikesIDX),DetectedArray(DetectionWOSpikesIDX),1,50);C(B==0)=0;
% bar(B,C,'FaceColor','k','EdgeColor','k')
% set(gca,'FontWeight','bold','FontSize',14,'LineWidth',3);
% xlabel('time (ms)')
% ylim([0 20])
% title('Autocorrelogram of over-detected spikes')
% 
% % Saving
% saveas(f, [dir_out 'Clu7_M979_SpikeShapes.fig']);
% saveFigure(f,'Clu7_M979_SpikeShapes',dir_out);
% 
% %% Cross correlograms
% f2 = figure('units', 'normalized', 'outerposition', [0 0 0.65 0.65]);
% for i=2:length(S)
%     [C,B]=CrossCorr((Start(Detected)+6),Range(S{i}),10,50);
%     subplot(5,2,i-1)
%     bar(B/1E3,C,1,'k')
%     ylim([0 100])
%     line([0 0], ylim,'color','r')
%     set(gca,'FontWeight','bold','FontSize',14,'LineWidth',3);
%     title(['Detected vs Cl#' num2str(i)])
%     if i<10
%         set(gca,'XTickLabel',[]);
%     else
%         xlabel('Time (ms)');
%     end
% end
% mtit(f2, 'Correctly detected spikes vs each cluster detected offline', 'zoff', 0.03, 'yoff', 0.01,...
%     'fontsize',16,'fontweight','bold');
% 
% % Saving
% saveas(f2, [dir_out 'Clu7_M979_CrossCorrect.fig']);
% saveFigure(f2,'Clu7_M979_CrossCorrect',dir_out);
% 
% f3 = figure('units', 'normalized', 'outerposition', [0 0 0.65 0.65]);
% for i=2:length(S)
%     [C,B]=CrossCorr((DetectedArray(DetectionWOSpikesIDX)+6),Range(S{i}),10,50);
%     subplot(5,2,i-1)
%     bar(B/1E3,C,1,'k')
%     ylim([0 100])
%     line([0 0], ylim,'color','r')
%     set(gca,'FontWeight','bold','FontSize',14,'LineWidth',3);
%     title(['Over-detected vs Cl#' num2str(i)])
%     if i<10
%         set(gca,'XTickLabel',[]);
%     else
%         xlabel('Time (ms)');
%     end
% end
% mtit(f3, 'Spikes not found in correct cluster vs each cluster detected offline', 'zoff', 0.03, 'yoff', 0.01,...
%     'fontsize',16,'fontweight','bold');
% 
% 
% % Saving
% saveas(f3, [dir_out 'Clu7_M979_CrossNotFound.fig']);
% saveFigure(f3,'Clu7_M979_CrossNotFound',dir_out);
% 
% %%
% %% Plot
% 
% % Detected spikes that match
% step = 20;
% f = figure('units', 'normalized', 'outerposition', [0 0 0.65 1]);
% for elec = 1:size(W,2)
%     subplot(13,15,[((elec-1)*30)+1:((elec-1)*30)+5 ((elec-1)*30)+16:((elec-1)*30)+20])
%     dat1 = W(SpikesDetectedCorrIDX,elec,:);
%     dat1 = dat1(1:step:end,:);
%     add1 = plot(dat1','color',[0.6 0.6 0.6]);
%     hold on
%     main1 = plot(nanmean(dat1),'color','k','linewidth',2);
%     ylim([-3000 1000])
%     xlim([0 35])
%     hold on
%     set(gca,'FontWeight','bold','FontSize',14,'LineWidth',3);
%     if elec == 1
%         line(xlim,[-1041 -1041],'Color','r');
%         title(['Spikes detected offline']);
%         set(gca, 'YTickLabel',[],'XTickLabel',[]);
%     elseif elec == 4
%         xlabel('Time in samples')
%     else
%         set(gca, 'YTickLabel',[],'XTickLabel',[]);
%     end
% end
% 
% step = 20;
% dat2 = W(SpikesDetectedCorrIDX,:,:);
% SpikesOnline = cat(1, dat2, SpikesNotFoundbyClustering);
% for elec = 1:size(W,2)
%     subplot(13,15,[((elec-1)*30)+11:((elec-1)*30)+15 ((elec-1)*30)+26:((elec-1)*30)+30])
%     dat = SpikesOnline(:,elec,:);
%     dat = dat(1:step:end,:);
%     plot(dat','color',[0.6 0.6 0.6]), hold on
%     plot(nanmean(dat),'color','k','linewidth',2)
%     ylim([-3000 1000])
%     xlim([0 35])
%     set(gca,'FontWeight','bold','FontSize',14,'LineWidth',3);
%     if elec == 1
%         line(xlim,[-1041 -1041],'Color','r');
%         title(['Spikes detected online']);
%         set(gca, 'YTickLabel',[],'XTickLabel',[]);
%     elseif elec == 4
%         xlabel('Time in samples')
%     else
%         set(gca, 'YTickLabel',[],'XTickLabel',[]);
%     end
% end
% 
% subplot(13,15,[151:155 166:170])
% [C,B]=CrossCorr(AllSpikesArray,AllSpikesArray,1,50);C(B==0)=0;
% bar(B,C,'FaceColor','k','EdgeColor','k')
% set(gca,'FontWeight','bold','FontSize',14,'LineWidth',3);
% xlabel('time (ms)')
% ylim([0 20])
% title('Autocorrelogram of offline detected cluster')
% 
% string = [num2str(NumSpikesClustered) ' spikes found offline' newline num2str(NumStimDetected) ' spikes found online'];
% annotation(f,'textbox',[0.41 0.03 0.2 0.1],'String',string, 'LineWidth',3,...
%         'HorizontalAlignment','center', 'FontSize', 14, 'FontWeight','bold',...
%         'FitBoxToText','on');
% 
% subplot(13,15,[161:165 176:180])
% [C,B]=CrossCorr(DetectedArray,DetectedArray,1,50);C(B==0)=0;
% bar(B,C,'FaceColor','k','EdgeColor','k')
% set(gca,'FontWeight','bold','FontSize',14,'LineWidth',3);
% xlabel('time (ms)')
% ylim([0 20])
% title('Autocorrelogram of online detected spikes')
% 
% % Saving
% saveas(f, [dir_out 'Clu7_M979_SpikeShapesOriginal.fig']);
% saveFigure(f,'Clu7_M979_SpikeShapes_Original',dir_out);
% 
% %% Plot from Karim
% 
% f = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
% binSize=80E4;
% 
% Q=MakeQfromS(S,binSize);
% Qs=full(Data(Q));
% Qtsd=tsd(Range(Q),Qs(:,10));
% 
% stim=tsdArray(tsd(Start(Detected),Start(Detected)));
% Qstim=MakeQfromS(stim,binSize);
% Qs2=full(Data(Qstim));
% Qstimtsd=tsd(Range(Qstim),Qs2(:,1));
% 
% [X,lag]=xcorr(Data(Qtsd),Data(Qstimtsd),100);
% 
% [C,B]=CrossCorr(Range(S{10}),Start(Detected),1,100);
% 
% subplot(3,3,1:3), plot(Range(Qtsd,'s'),Data(Qtsd),'LineWidth',3)
% hold on, plot(Range(Qstimtsd,'s'),Data(Qstimtsd),'r','LineWidth',3)
% set(gca,'FontWeight','bold','FontSize',14,'LineWidth',3);
% xlabel('Time (s)')
% ylabel('Count')
% title('FR across recording')
% legend('All Spikes','Detected Spikes')
% subplot(3,3,4:6), imagesc(zscore(Qs)')
% set(gca,'FontWeight','bold','FontSize',14,'LineWidth',3);
% axis xy
% title('FR across recording')
% ylabel('#Cluster')
% xlabel('#Bin')
% subplot(3,3,7), bar(B/10,C,1,'k'), line([0 0],ylim,'color','r','LineWidth',3)
% set(gca,'FontWeight','bold','FontSize',14,'LineWidth',3);
% ylabel('Count')
% xlabel('Time (ms)')
% ylim([0 10])
% title('Cross-correlation offline vs online')
% subplot(3,3,8), plot(lag,X,'k','Linewidth',3)
% hold on
% line([0 0],ylim,'color','r','LineWidth',3)
% xlabel('Lag')
% ylabel('Cross-correlation')
% title('Cross-correlation offline vs online')
% set(gca,'FontWeight','bold','FontSize',14,'LineWidth',3);
% subplot(3,3,9), plot(Data(Qtsd),Data(Restrict(Qstimtsd,Qtsd)),'ko','markerfacecolor','k', 'Linewidth', 3)
% hold on
% h1 = plot(Data(Qtsd),Data(Qtsd)*0.3,'r.');
% h2 = plot(Data(Qtsd),Data(Qtsd)*0.5,'b.');
% set(gca,'FontWeight','bold','FontSize',14,'LineWidth',3);
% xlabel('FR of all spikes')
% ylabel('FR of detected spikes')
% title('FR of all spikes vs detected spikes')
% legend([h1 h2], '1/3 of offline spikes', '1/2 of offline spikes')
% 
% saveas(f, [dir_out 'Clu7_M979_Karim.fig']);
% saveFigure(f,'Clu7_M979_Karim',dir_out);