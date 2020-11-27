function compSleepOnOff(Dir)
%==========================================================================
% Details: Verify the effect of delay on stimulation specificity for sleep stages
%           Detect and output ripples (figure and .mat file) of all sites on all spike groups
%
% INPUTS:
%       - Dir: working directory
%
% OUTPUT:
%
% NOTES:
%
%   Written by Samuel Laventure - 16-07-2020
%      
%==========================================================================
%% Set Directories and variables
try
   Dir;
catch
   Dir =  [pwd '/'];
end
cd(Dir);

dir_out = [dropbox '/DataSL/Sleep/CheckDelay/'];
if ~exist(dir_out,'dir')
    mkdir(dir_out);
end

% set recording software
oe    = 1;
intan = 0;


%#####################################################################
%#                          M  A  I  N
%#####################################################################

%% load variables
% get offline sleep scoring
try
    load('SleepScoring_OBGamma.mat','sleep_array');
catch
    make_sleepscoringarray;
    load('SleepScoring_OBGamma.mat','sleep_array');    
end
off_all = sleep_array;
% note: offline data are in 10k sampling rate
%get online sleep scoring
if oe
    fileSignal = 'Sleep_Scorer';
    SignalPath = dir(fullfile(pwd, '**', [fileSignal '*.mat']));
    load([SignalPath.folder '/' SignalPath.name],'text');
    ontxt = text;
    % note: online timestamps from Open ephys are in 20k sampling rate but @ 1 sleep scoring per sec. 
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

% transform online ss from text to numbers
for iss=1:size(ontxt,1)
    stage = ontxt(iss,1:4);
    switch stage
        case 'NREM'
            on(iss) = 1;
        case 'REM '
            on(iss) = 2;
        case 'Wake'
            on(iss) = 3;
    end
end

if length(on)>length(off)
    on=on(1:length(off));
%     on=on(length(on)-length(off)+1:end);
    warning('Online detection has more input then offline. Please check data.')
elseif length(off)>length(on)
    off=off(1:length(on));
%     off=off(length(off)-length(on)+1:end);
    warning('Offline detection has more input then online. Please check data.')
end

% make fake stims
delay = [0 1 2 3 4 5];
nremstim(1:length(delay),1)=0;
remstim(1:length(delay),1)=0;
wakestim(1:length(delay),1)=0;
for idel=1:length(delay)
    state=9;
    timecount=0;
    startstate=0;
    first=1;
    for ion=1:length(on)
        if on(ion)
            newstate = on(ion);
            if ~(state==newstate)
                startstate=1;
            else
                startstate=startstate+1;
            end
            
            if startstate>delay(idel)
                if first
                    timecount=1;
                    switch on(ion)
                        case 1
                            nremstim(idel)=nremstim(idel)+1;
                        case 2
                            remstim(idel) = remstim(idel)+1;
                        case 3
                            wakestim(idel) = wakestim(idel)+1;
                    end
                    first=0;
                else
                    if timecount>3
                        switch on(ion)
                            case 1
                                nremstim(idel)=nremstim(idel)+1;
                            case 2
                                remstim(idel) = remstim(idel)+1;
                            case 3
                                wakestim(idel) = wakestim(idel)+1;
                        end
                        timecount=1;
                    else
                        timecount=timecount+1;
                    end
                end
            end
            state=newstate;
        end      
    end
end

%% Make tables with different delays
% +1 to compensate for NaN = 0 to create following table
on=on+1;
off=off+1;    
idx=find(off==1);
off(idx) = [];
on(idx) = [];

for idel=1:length(delay)
    % init var
    tbl_cmp= zeros(4,4);
    state = 9;
    for iss=1:length(off)
        newstate = on(iss);
        if ~(state==newstate)
            startstate=1;
        else
            startstate=startstate+1;
        end
        
        if startstate>delay(idel)
            tbl_cmp(off(iss),on(iss))=tbl_cmp(off(iss),on(iss))+1;
            if ~(on(iss)==off(iss))
                dif{idel}(iss) = 4.5;
            else
                dif{idel}(iss) = NaN;
            end
        end
        state=newstate;
    end 
    ratio = sum(tbl_cmp,2);
    tbl_ss{idel} = tbl_cmp./ratio;
    % add totals to table
    for iss=1:4
        tbl_cmp(iss,5) = sum(tbl_cmp(iss,:));
        tbl_cmp(5,iss) = sum(tbl_cmp(:,iss));
    end
    tbl_nb{idel} = tbl_cmp;
    
    % get rid of unidentified epoch
    dif{idel}(idx) = [];

    diffo{idel} = off-on;
    good{idel} = length(find(diffo{idel}==0));
    good_perc{idel} = good{idel}/length(off)*100;

    for iss=2:4
        ssrate{iss-1}(idel) = tbl_ss{idel}(iss,iss)*100; 
    end
end

stimloss{1} = nremstim';
stimloss{2} = remstim';
stimloss{3} = wakestim';

%% Calculate loss of stim by delays
diffnrem = stimloss;
diffrem =  abs(diff(remstim));
diffwake =  abs(diff(wakestim));
% cumnrem = cumsum(diffnrem);
% cumrem = cumsum(diffrem);
% cumwake = cumsum(diffwake);

for iss=1:3    
    diffrate{iss} = diff(ssrate{iss});
    diffratep{iss} = diffrate{iss}./ssrate{iss}(1:5);
    cumrate{iss} = cumsum(diffrate{iss});
    
    stimloss_cum{iss} = stimloss{iss}/stimloss{iss}(1);
    rategain_cum{iss} = ssrate{iss}/ssrate{iss}(1);
    gains{iss} = stimloss_cum{iss}./rategain_cum{iss};
    gainssimp{iss} = stimloss_cum{iss}./ssrate{iss};
    stimlossz{iss} =(stimloss_cum{iss}-mean(stimloss_cum{iss}))./std(stimloss_cum{iss});
    gainsz{iss} = rategain_cum{iss}./ ...
        (stimlossz{iss}+abs(min(stimlossz{iss})));
end

% -------------------------------------------------------------------------
%                              F I G U R E S 
% -------------------------------------------------------------------------

supertit='Impact of delays on stimulations';
figure2(1,'pos',[1 1 1200 500],'Name', supertit, 'NumberTitle','off')
    subplot(1,3,1)
        bar(nremstim)
        title('NREM')
        xlabel('Delays (s)')
        ylabel('Maximum number of possible stim')
        set(gca,'XTickLabel',num2cell(delay(1):delay(end)))
    subplot(1,3,2)
        bar(remstim)        
        title('REM')
        xlabel('Delays (s)')
        set(gca,'XTickLabel',num2cell(delay(1):delay(end)))
    subplot(1,3,3)
        bar(wakestim)        
        title('Wake')
        xlabel('Delays (s)')
        set(gca,'XTickLabel',num2cell(delay(1):delay(end)))
    % save figure
    print([dir_out 'Delays_nbStim'], '-dpng', '-r300');

supertit='Quality of Sleep Scoring';
figure2(1,'pos',[1 1 1200 500],'Name', supertit, 'NumberTitle','off')
    subplot(1,3,1)
        bar(ssrate{1})
        title('NREM')
        xlabel('Delays (s)')
        ylabel('online vs offline %')
        ylim([80 100])
        set(gca,'XTickLabel',num2cell(delay(1):delay(end)))
    subplot(1,3,2)
        bar(ssrate{2})        
        title('REM')
        xlabel('Delays (s)')
        ylim([80 100])
        set(gca,'XTickLabel',num2cell(delay(1):delay(end)))
    subplot(1,3,3)
        bar(ssrate{3})        
        title('Wake')
        xlabel('Delays (s)')
        ylim([80 100])
        set(gca,'XTickLabel',num2cell(delay(1):delay(end)))
    % save figure
    print([dir_out 'Delays_ssQuality'], '-dpng', '-r300');
    
supertit='Gains by delay (accuracy/stim loss)';
figure2(1,'pos',[1 1 1200 500],'Name', supertit, 'NumberTitle','off')    
    subplot(1,3,1)
        bar(gains{1})
        title('NREM')
        xlabel('Delays (s)')
        ylabel('gain score')
        set(gca,'XTickLabel',num2cell(delay(2):delay(end)))
    subplot(1,3,2)
        bar(gains{2})        
        title('REM')
        xlabel('Delays (s)')
        set(gca,'XTickLabel',num2cell(delay(2):delay(end)))
    subplot(1,3,3)
        bar(gains{3})        
        title('Wake')
        xlabel('Delays (s)')
        set(gca,'XTickLabel',num2cell(delay(2):delay(end)))
    % save figure
    print([dir_out 'Delays_Gains'], '-dpng', '-r300');   
    
supertit='Gains by delay (accuracy/stim loss)';
figure2(1,'pos',[1 1 1200 500],'Name', supertit, 'NumberTitle','off')    
    subplot(1,3,1)
        bar(gainsz{1})
        title('NREM')
        xlabel('Delays (s)')
        ylabel('gain score')
        set(gca,'XTickLabel',num2cell(delay(2):delay(end)))
    subplot(1,3,2)
        bar(gainsz{2})        
        title('REM')
        xlabel('Delays (s)')
        set(gca,'XTickLabel',num2cell(delay(2):delay(end)))
    subplot(1,3,3)
        bar(gainsz{3})        
        title('Wake')
        xlabel('Delays (s)')
        set(gca,'XTickLabel',num2cell(delay(2):delay(end)))
    % save figure
    print([dir_out 'Delays_Gainsz'], '-dpng', '-r300');       
    
disp('Completed');
        
    
   
% for idel=1:length(delay)      
%     T = table(tbl_ss{idel},'RowName',{'Off Undef','Off NREM','Off REM','Off Wake'},'VariableName',{'Online'});
%     disp(['Delay: ' num2str(delay(idel)) 's'])
%     disp(['Percentage of equal online vs offline sleep scoring: ' num2str(good_perc{idel}) '%'])
%     disp('')
%     disp('How to read the table: Read each rows and columns seperately; you can find the total number of epoch scored in that stage at the end of the column/row. The table was filled looking at concordance between ONLINE and OFFLINE - e.g. if online and offline agreed it would put +1 in the cell for the same stage. If online = NREM while offline = REM it would put a +1 at row OffREM/colum OnNREM.  ')
%     disp('')
%     disp('--------------')
%     
%     supertit=['Delay: ' num2str(delay(idel)) 's; Online (columns) percentage in each stage compared to offline (gold standard - row)'];
%     figure2(1,'pos',[1 1 710 110],'Name', supertit, 'NumberTitle','off')
%         uitable('Data',T{:,:},'ColumnName',{'On Undef','On NREM','On REM','On Wake'},...
%         'RowName',T.Properties.RowNames,'Units', 'Normalized', 'Position',[0, 0, 1, 1]);
% 
%     Traw = table(tbl_nb{idel},'RowName',{'Off Undef','Off NREM','Off REM','Off Wake','ON TOTAL'},'VariableName',{'Online'});
%     supertit=['Delay: ' num2str(delay(idel)) 's; Online (columns) compared to offline (gold standard - row)'];
%     figure2(1,'pos',[1 1 710 150],'Name', supertit, 'NumberTitle','off')
%         uitable('Data',Traw{:,:},'ColumnName',{'On Undef','On NREM','On REM','On Wake','OFF TOTAL'},...
%         'RowName',Traw.Properties.RowNames,'Units', 'Normalized', 'Position',[0, 0, 1, 1]);
% end
    