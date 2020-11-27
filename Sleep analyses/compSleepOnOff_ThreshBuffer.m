function compSleepOnOff_ThreshBuffer(Dir)
%==========================================================================
% Details: Detect and output ripples (figure and .mat file) of all sites on all spike groups
%
% INPUTS:
%       - Dir: working directory
%
% OUTPUT:
%
% NOTES:
%
%   Written by Samuel Laventure - 08-10-2020
%      
%==========================================================================
%% Set Directories and variables

% Mouse number for folder name + threshold info
mouseNum = 'M1117';
tgam = 40.97;
tthe = 5.1;

try
   Dir;
catch
   Dir =  [pwd '/'];
end
cd(Dir);

dir_out = [dropbox '/DataSL/Sleep/SleepScoringONOFFCompare/' mouseNum '/'];
if ~exist(dir_out,'dir')
    mkdir(dir_out);
end


% set recording software
oe    = 1;
intan = 0;

% Transition types:
% [2 3] NREM -> REM
% [2 4] NREM -> Wake
% [3 2] REM -> NREM
% [3 4] REM -> Wake
% [4 2] Wake -> NREM
% [4 3] Wake -> REM (should not happen)
transname = {'NREM->REM','NREM->Wake','REM->NREM','REM->Wake','Wake->NREM','Wake->REM'}; 
stagename = {'NREM','REM','Wake'};
%threshold buffer size
buffsize = [0,0,0,0,0; ... %.01*tgam, .05*tgam, .15*tgam, .25*tgam; ...
    0, .01*tthe, .05*tthe, .15*tthe, .25*tthe];
for ibuf=1:size(buffsize,2)
   threshgam(2,ibuf) = buffsize(1,ibuf)+tgam(1,1);
   threshgam(1,ibuf) = tgam(1,1)-buffsize(1,ibuf);
   threshthe(2,ibuf) = buffsize(2,ibuf)+tthe(1,1);
   threshthe(1,ibuf) = tthe(1,1)-buffsize(2,ibuf);
end
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
    load([SignalPath.folder '/' SignalPath.name],'text','metadata');
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

% +1 to compensate for NaN = 0 to create following table
on=on+1;
off=off+1;
durhalf=5; % number of sec before and after transition
trans{1}=[];trans{2}=[];trans{3}=[];
trans{4}=[];trans{5}=[];trans{6}=[];
trans_errors{1}=[];trans_errors{2}=[];trans_errors{3}=[];
trans_errors{4}=[];trans_errors{5}=[];trans_errors{6}=[];
trans_gamma{1}=[];trans_gamma{2}=[];trans_gamma{3}=[];
trans_gamma{4}=[];trans_gamma{5}=[];trans_gamma{6}=[];
trans_theta{1}=[];trans_theta{2}=[];trans_theta{3}=[];
trans_theta{4}=[];trans_theta{5}=[];trans_theta{6}=[];
trans_epoch = [];
for iss=1:length(off)
    % get info on transitions
    if (iss>4) && (iss<length(on)-4)
        if ~(on(iss)==on(iss-1))
            epoch_cmp = on(iss-durhalf:iss+durhalf-1);
            epoch_off = off(iss-durhalf:iss+durhalf-1);
            idx_diff = find(epoch_cmp~=epoch_off);
            errors = zeros(1,10);
            errors(idx_diff) = 1;
            transtype = epoch_cmp(4:5);
            epoch_gamma = metadata(iss-durhalf:iss+durhalf-1,1);
            epoch_gamma(setdiff(1:end,idx_diff))=NaN;
            epoch_theta = metadata(iss-durhalf:iss+durhalf-1,2);
            epoch_theta(setdiff(1:end,idx_diff))=NaN;
            % Transition types:
            % [2 3] NREM -> REM
            % [2 4] NREM -> Wake
            % [3 2] REM -> NREM
            % [3 4] REM -> Wake
            % [4 2] Wake -> NREM
            % [4 3] Wake -> REM (should not happen)
            switch num2str(transtype)
                case num2str([2 3])
                    trans{1}(end+1,1:durhalf*2)=epoch_cmp;
                    trans_errors{1}(end+1,1:durhalf*2)=errors;
                    trans_gamma{1}(end+1,1:durhalf*2)=epoch_gamma;
                    trans_theta{1}(end+1,1:durhalf*2)=epoch_theta;
                case num2str([2 4])
                    trans{2}(end+1,1:durhalf*2)=epoch_cmp;
                    trans_errors{2}(end+1,1:durhalf*2)=errors;
                    trans_gamma{2}(end+1,1:durhalf*2)=epoch_gamma;
                    trans_theta{2}(end+1,1:durhalf*2)=epoch_theta;
                case num2str([3 2])
                    trans{3}(end+1,1:durhalf*2)=epoch_cmp;
                    trans_errors{3}(end+1,1:durhalf*2)=errors;
                    trans_gamma{3}(end+1,1:durhalf*2)=epoch_gamma;
                    trans_theta{3}(end+1,1:durhalf*2)=epoch_theta;
                case num2str([3 4])
                    trans{4}(end+1,1:durhalf*2)=epoch_cmp;
                    trans_errors{4}(end+1,1:durhalf*2)=errors;
                    trans_gamma{4}(end+1,1:durhalf*2)=epoch_gamma;
                    trans_theta{4}(end+1,1:durhalf*2)=epoch_theta;
                case num2str([4 2])
                    trans{5}(end+1,1:durhalf*2)=epoch_cmp;
                    trans_errors{5}(end+1,1:durhalf*2)=errors;
                    trans_gamma{5}(end+1,1:durhalf*2)=epoch_gamma;
                    trans_theta{5}(end+1,1:durhalf*2)=epoch_theta;
                case num2str([4 3])
                    trans{6}(end+1,1:durhalf*2)=epoch_cmp;    
                    trans_errors{6}(end+1,1:durhalf*2)=errors;    
                    trans_gamma{6}(end+1,1:durhalf*2)=epoch_gamma;
                    trans_theta{6}(end+1,1:durhalf*2)=epoch_theta;        
            end
            % get timestamp of transition
            trans_epoch(end+1) = iss;
        end
    end
end

lastss=1;
for ibuf=1:size(buffsize,2)
    tbl_cmp{ibuf}= zeros(4,4);
    for iss=1:length(off)
        if (metadata(iss,1)>threshgam(1,ibuf)) && (metadata(iss,1)<threshgam(2,ibuf))
            on(iss) = lastss;                
        end
        if (metadata(iss,2)>threshthe(1,ibuf)) && (metadata(iss,2)<threshthe(2,ibuf))
            if on(iss)==2 || on(iss)==3
                on(iss) = lastss;                
            end
        end
        % create sleep scoring accuracy table
        tbl_cmp{ibuf}(off(iss),on(iss))=tbl_cmp{ibuf}(off(iss),on(iss))+1;
        if ~(on(iss)==off(iss))
            dif{ibuf}(iss) = 4.5;
        else
            dif{ibuf}(iss) = NaN;
        end
        lastss = on(iss);
        clear idx
    end
    ratio = sum(tbl_cmp{ibuf},2);
    tbl_ss{ibuf} = tbl_cmp{ibuf}./ratio;

    % add totals to table
    for iss=1:4
        tbl_cmp{ibuf}(iss,5) = sum(tbl_cmp{ibuf}(iss,:));
        tbl_cmp{ibuf}(5,iss) = sum(tbl_cmp{ibuf}(:,iss));
    end
    onbuff{ibuf}=on;
    offbuff{ibuf}=off;
    % get rid of unidentified epoch
    idx=find(off==1);
    offbuff{ibuf}(idx) = [];
    onbuff{ibuf}(idx) = [];
    dif{ibuf}(idx) = [];
    diff{ibuf} = offbuff{ibuf}-onbuff{ibuf};
    good{ibuf} = length(find(diff{ibuf}==0));
    good_perc{ibuf} = good{ibuf}/length(off)*100;
end

for istage=2:4
    accu{istage-1}=[];
    accudif{istage-1}=[];
    for ibuf=1:size(buffsize,2)
        accu{istage-1}(end+1)=tbl_ss{ibuf}(istage,istage);
    end
    accudif{istage-1}=accu{istage-1} - repmat(accu{istage-1}(1),1,size(buffsize,2));
end





% -------------------------------------------------------------------------
%                              F I G U R E S 
% -------------------------------------------------------------------------
for ibuf=1:size(buffsize,2)
    disp(['Buffer size (%/2): ' num2str(buffsize(1,ibuf)/tgam)])
    disp(['Percentage of equal online vs offline sleep scoring: ' num2str(good_perc{ibuf}) '%'])
    disp('How to read the table: Read each rows and columns seperately; you can find the total number of epoch scored in that stage at the end of the column/row. The table was filled looking at concordance between ONLINE and OFFLINE - e.g. if online and offline agreed it would put +1 in the cell for the same stage. If online = NREM while offline = REM it would put a +1 at row OffREM/colum OnNREM.  ')
    T = table(tbl_ss{ibuf},'RowName',{'Off Undef','Off NREM','Off REM','Off Wake'},'VariableName',{'Online'});
    supertit='Online (columns) percentage in each stage compared to offline (gold standard - row)';
    figure2(1,'pos',[1 1 710 110],'Name', supertit, 'NumberTitle','off')
        uitable('Data',T{:,:},'ColumnName',{'On Undef','On NREM','On REM','On Wake'},...
        'RowName',T.Properties.RowNames,'Units', 'Normalized', 'Position',[0, 0, 1, 1]);
        % save figure
        print([dir_out 'Table_ssONOFFcompareBUFF' num2str(buffsize(1,ibuf)/tgam)], '-dpng', '-r300');

    Traw = table(tbl_cmp{ibuf},'RowName',{'Off Undef','Off NREM','Off REM','Off Wake','ON TOTAL'},'VariableName',{'Online'});
    supertit='Online (columns) compared to offline (gold standard - row)';
    figure2(1,'pos',[1 1 710 150],'Name', supertit, 'NumberTitle','off')
        uitable('Data',Traw{:,:},'ColumnName',{'On Undef','On NREM','On REM','On Wake','OFF TOTAL'},...
        'RowName',Traw.Properties.RowNames,'Units', 'Normalized', 'Position',[0, 0, 1, 1]);
        % save figure
        print([dir_out 'Table_ssONOFFcompareBUFF_Perc' num2str(buffsize(1,ibuf)/tgam)], '-dpng', '-r300');
end

% Accuracy by stage by buffer size (threshold)    
supertit='Accuracy by gamma and theta buffer size threshold';
figure2(1,'pos',[1 1 1000 900],'Name', supertit, 'NumberTitle','off')
    for istage=1:3
        subplot(2,3,istage)
            bar(accu{istage});
            title(stagename{istage})
            ylim([.75 .95])
            xlabel('Buffer size (% of threshold value)')
            ylabel('Accuracy %')
            set(gca,'XTick',[1:size(buffsize,2)],'XTickLabel',num2cell(buffsize(2,:)/tthe))
    end
    for istage=4:6
        subplot(2,3,istage)
            bar(accudif{istage-3});
            title(stagename{istage-3})
            ylim([-.04 .04])
            xlabel('Buffer size (% of threshold value)')
            ylabel('Change in accuracy %')
            set(gca,'XTick',[1:size(buffsize,2)],'XTickLabel',num2cell(buffsize(2,:)/tthe))
        
    end
    % save figure
    print([dir_out 'BarAccuracyBuff'], '-dpng', '-r300');



% hypnogram comparing on and off 
supertit='Hypnogram: comparing Online and Offline scoring';
figure2(1,'pos',[1 1 2500 600],'Name', supertit, 'NumberTitle','off')
    plot(on(1,1:end))
    hold on
    plot(off(1,1:end))
    hold on
    plot(dif(1,1:end),'.','MarkerFaceColor','red')
    ylim([1.5 5])
    xlim([1 length(on)])
    set(gca,'YTick',[2,3,4,4.5], ...
        'YTickLabel',{'NREM','REM','Wake','Difference'})
    set(gca,'XTick',[1:900:length(on)],...
        'XTickLabel',num2cell(0:900/3600:length(on)/3600))
    % save figure
    print([dir_out 'HypnoONOFF_V1'], '-dpng', '-r300');
    
supertit='Hypnogram: comparing Online and Offline scoring';
figure2(1,'pos',[1 1 2500 900],'Name', supertit, 'NumberTitle','off')
    plot(on(1,1:end))
    hold on
    plot(off(1,1:end)+3)
    hold on
    plot(dif(1,1:end),'.','MarkerFaceColor','red')
    ylim([1.5 7.5])
    xlim([1 length(on)])
    set(gca,'YTick',[2,3,4,4.5,5,6,7], ...
        'YTickLabel',{'On NREM','Off REM','On Wake','Difference','Off NREM','Off REM','Off Wake'})
    set(gca,'XTick',[1:900:length(on)],...
        'XTickLabel',num2cell(0:900/3600:length(on)/3600))
    % save figure
    print([dir_out 'HypnoONOFF_V2'], '-dpng', '-r300');

% Errors distribution by type of online stage transition    
supertit='Errors distribution around stage transitions';
figure2(1,'pos',[1 1 1000 900],'Name', supertit, 'NumberTitle','off')
    for itrans=1:6
        sum_epoch = sum(trans_errors{itrans},1);
        subplot(3,2,itrans)
            bar(sum_epoch);
            title(transname{itrans})
            ylim([0 20])
            xlabel('seconds')
            if ~(rem(itrans, 2)==0)
                ylabel('number of errors')
            end
            set(gca,'XTick',[1:(2*durhalf)],'XTickLabel',num2cell(-(durhalf):durhalf))

    end
    % save figure
    print([dir_out 'StageTransErrors'], '-dpng', '-r300');

supertit='Gamma/Theta of ON/OFF errors';
figure2(1,'pos',[1 1 1000 900],'Name', supertit, 'NumberTitle','off')
    for itrans=1:6
        subplot(3,2,itrans)
            gamma_nonans=~isnan(trans_gamma{itrans});
            theta_nonans=~isnan(trans_theta{itrans});
            scatter(trans_gamma{itrans}(gamma_nonans), trans_theta{itrans}(theta_nonans), 50, 'filled')
            title(transname{itrans})
            xlabel('Gamma')
            ylabel('Theta')
            xlim([8 25])
            ylim([0 11])
            vline(15.09,'r','Gamma thresh')
            hline(3.6, 'g','Theta thresh')
    end
    % save figure
    print([dir_out 'GammaThetaONOFFerrors'], '-dpng', '-r300');






    
end
