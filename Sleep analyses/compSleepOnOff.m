function compSleepOnOff(Dir)
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
%   Written by Samuel Laventure - 16-07-2020
%      
%==========================================================================
%% Set Directories and variables

% Mouse number for folder name
mouseNum = 'M1117';
gthresh = 40.97;
tthresh = 5.1;


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
tbl_cmp= zeros(4,4);
durhalf=5; % number of sec before and after transition
trans{1}=[];trans{2}=[];trans{3}=[];
trans{4}=[];trans{5}=[];trans{6}=[];
trans_errors{1}=[];trans_errors{2}=[];trans_errors{3}=[];
trans_errors{4}=[];trans_errors{5}=[];trans_errors{6}=[];
trans_gamma{1}=[];trans_gamma{2}=[];trans_gamma{3}=[];
trans_gamma{4}=[];trans_gamma{5}=[];trans_gamma{6}=[];
trans_theta{1}=[];trans_theta{2}=[];trans_theta{3}=[];
trans_theta{4}=[];trans_theta{5}=[];trans_theta{6}=[];

for iss=1:length(off)
    tbl_cmp(off(iss),on(iss))=tbl_cmp(off(iss),on(iss))+1;
    if ~(on(iss)==off(iss))
        dif(iss) = 4.5;
    else
        dif(iss) = NaN;
    end
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
        end
    end
end




ratio = sum(tbl_cmp,2);
tbl_ss = tbl_cmp./ratio;

% add totals to table
for iss=1:4
    tbl_cmp(iss,5) = sum(tbl_cmp(iss,:));
    tbl_cmp(5,iss) = sum(tbl_cmp(:,iss));
end

% get rid of unidentified epoch
idx=find(off==1);
off(idx) = [];
on(idx) = [];
dif(idx) = [];

diff = off-on;
good = length(find(diff==0));
good_perc = good/length(off)*100;

% -------------------------------------------------------------------------
%                              F I G U R E S 
% -------------------------------------------------------------------------

disp(['Percentage of equal online vs offline sleep scoring: ' num2str(good_perc) '%'])
disp('')
disp('How to read the table: Read each rows and columns seperately; you can find the total number of epoch scored in that stage at the end of the column/row. The table was filled looking at concordance between ONLINE and OFFLINE - e.g. if online and offline agreed it would put +1 in the cell for the same stage. If online = NREM while offline = REM it would put a +1 at row OffREM/colum OnNREM.  ')
T = table(tbl_ss,'RowName',{'Off Undef','Off NREM','Off REM','Off Wake'},'VariableName',{'Online'});
supertit='Online (columns) percentage in each stage compared to offline (gold standard - row)';
figure2(1,'pos',[1 1 710 110],'Name', supertit, 'NumberTitle','off')
    uitable('Data',T{:,:},'ColumnName',{'On Undef','On NREM','On REM','On Wake'},...
    'RowName',T.Properties.RowNames,'Units', 'Normalized', 'Position',[0, 0, 1, 1]);
    % save figure
    print([dir_out 'Table_ssONOFFcompare'], '-dpng', '-r300');

Traw = table(tbl_cmp,'RowName',{'Off Undef','Off NREM','Off REM','Off Wake','ON TOTAL'},'VariableName',{'Online'});
supertit='Online (columns) compared to offline (gold standard - row)';
figure2(1,'pos',[1 1 710 150],'Name', supertit, 'NumberTitle','off')
    uitable('Data',Traw{:,:},'ColumnName',{'On Undef','On NREM','On REM','On Wake','OFF TOTAL'},...
    'RowName',Traw.Properties.RowNames,'Units', 'Normalized', 'Position',[0, 0, 1, 1]);
    % save figure
    print([dir_out 'Table_ssONOFFcompare_Perc'], '-dpng', '-r300');

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
            xlim([gthresh-25 gthresh+25])
            ylim([0 tthresh+10])
            vline(gthresh,'r','Gamma thresh')
            hline(tthresh, 'g','Theta thresh')
    end
    % save figure
    print([dir_out 'GammaThetaONOFFerrors'], '-dpng', '-r300');






    
end
