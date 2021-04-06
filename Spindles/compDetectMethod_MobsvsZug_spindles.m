function [figH] = compDetectMethod_MobsvsZug_spindles(recompute)


%recompute?
if ~exist('recompute','var')
    recompute=1;
end

%% load data
load('Spindles_full.mat','spindles_Info');
spi_chan = spindles_Info.channel;

load('spindles_abs.mat','spindles_abs');
spim = spindles_abs*1E4;
spim_epoch = intervalSet(spim(:,1),spim(:,3));
% wf_spim_all = M;
clear spindles Spindlesepoch M LFP

load('spindles_sqrt.mat','spindles_sqrt');
spiz = spindles_sqrt*1E4;
spiz_epoch = intervalSet(spiz(:,1),spiz(:,3));
% spiz_chan = dHPC_spi;
clear spindles

% sleep
load('SleepScoring_OBGamma.mat','SWSEpoch','Wake');

% data (to create tsd)
load([pwd '/LFPData/LFP' num2str(spi_chan) '.mat']);


if ~exist('Spi_comp.mat','file') || recompute
    %% Prep data
    % all
    spim_epoch_all = and(spim_epoch,or(SWSEpoch,Wake));
    spim_all = [Start(spim_epoch_all),End(spim_epoch_all)];
    st = Start(spim_epoch_all);
    for i=1:length(Start(spim_epoch_all))
        idx = find(st(i)==Start(spim_epoch));
        if idx
            peak.m.all(i) = spim(idx);
            idx=[];
        else
            peak.m.all(i) = nan;
            disp('peak mobs all: no spiple')
        end
    end
    spiz_epoch_all = spiz_epoch; %and(spiz_epoch,or(SWSEpoch,Wake));
    spiz_all = [Start(spiz_epoch_all),End(spiz_epoch_all)];
    st = Start(spiz_epoch_all);
    for i=1:length(Start(spiz_epoch_all))
        idx = find(Start(spiz_epoch)==st(i));
        if idx
            peak.z.all(i) = spiz(idx);
            idx=[];
        else
            peak.z.all(i) = nan;
            disp('peak zug all: no spiple')
        end
    end

    % nrem
    spim_epoch_nrem = and(spim_epoch,SWSEpoch);
    spim_nrem = [Start(spim_epoch_nrem),End(spim_epoch_nrem)];
    st = Start(spim_epoch_nrem);
    for i=1:length(Start(spim_epoch_nrem))
        idx = find(Start(spim_epoch)==st(i));
        if idx
            peak.m.nrem(i) = spim(idx);
            idx=[];
        else
            peak.m.nrem(i) = nan;
            disp('peak zug nrem: no spiple')
        end
    end
    spiz_epoch_nrem = and(spiz_epoch,SWSEpoch);
    spiz_nrem = [Start(spiz_epoch_nrem),End(spiz_epoch_nrem)];
    st = Start(spiz_epoch_nrem);
    for i=1:length(Start(spiz_epoch_nrem))
        idx = find(Start(spiz_epoch)==st(i));
        if idx
            peak.z.nrem(i) = spiz(idx);
            idx=[];
        else
            peak.z.nrem(i) = nan;
            disp('peak zug nrem: no spiple')
        end
    end

    %wake
    spim_epoch_wake = and(spim_epoch,Wake);
    spim_wake = [Start(spim_epoch_wake),End(spim_epoch_wake)];
    st = Start(spim_epoch_wake);
    for i=1:length(Start(spim_epoch_wake))
        idx = find(Start(spim_epoch)==st(i));
        if idx
            peak.m.wake(i) = spim(idx);
            idx=[];
        else
            peak.m.wake(i) = nan;
            disp('peak mobs wake: no spiple')
        end
    end
    spiz_epoch_wake = and(spiz_epoch,Wake);
    spiz_wake = [Start(spiz_epoch_wake),End(spiz_epoch_wake)];
    st = Start(spiz_epoch_wake);
    for i=1:length(Start(spiz_epoch_wake))
        idx = find(Start(spiz_epoch)==st(i));
        if idx
            peak.z.wake(i) = spiz(idx);
            idx=[];
        else
            peak.z.wake(i) = nan;
            disp('peak zug wake: no spiple')
        end
    end


    %% calculations
    disp('')
    disp('...Sorting spindles')
    % init var
    info.GroupOrder = {'Common','Zug. only','MOBs only','All'};
    info.StageOrder = {'All','NREM','Wake'};
    y_all=0;n_all=0;
    y_nrem=0;n_nrem=0;
    y_wake=0;n_wake=0;
    id.all{1}=[];id.all{2}=[];id.all{3}=[];    % spindles detected by both will have zugaro indices 
    id.nrem{1}=[];id.nrem{2}=[];id.nrem{3}=[];
    id.wake{1}=[];id.wake{2}=[];id.wake{3}=[];

    % All stages
    all_lfp = Restrict(LFP,or(SWSEpoch,Wake));
    all_spim = Restrict(all_lfp,spim_epoch);
    for i=1:size(spiz_all,1)
        spiz_all_ts = intervalSet(spiz_all(i,1),spiz_all(i,2));
        in = inInterval(spiz_all_ts,all_spim);
        if sum(Data(in))
            y_all=y_all+1;
            id.all{1}(end+1)=i;
        else
            n_all=n_all+1;
            id.all{2}(end+1)=i;
        end
    end
    % get indices from mobs (we do the same as above but looking at the
    % other group)
    all_spiz = Restrict(all_lfp,spiz_epoch);
    for i=1:size(spim_all,1)
        spim_all_ts = intervalSet(spim_all(i,1),spim_all(i,2));
        in = inInterval(spim_all_ts,all_spiz);
        if ~sum(Data(in))
            id.all{3}(end+1)=i;
        end
    end
    matspi.all(1) = y_all;
    matspi.all(2) = n_all;
    matspi.all(3) = length(id.all{3});

    % nrem
    % restrict to stage and create interval set
    nrem_lfp = Restrict(LFP,SWSEpoch);
    nrem_spim = Restrict(nrem_lfp,spim_epoch);

    for i=1:size(spiz_nrem,1)
        spiz_nrem_ts = intervalSet(spiz_nrem(i,1),spiz_nrem(i,2));
        in = inInterval(spiz_nrem_ts,nrem_spim);
        if sum(Data(in))
            y_nrem=y_nrem+1;
            id.nrem{1}(end+1)=i;
        else
            n_nrem=n_nrem+1;
            id.nrem{2}(end+1)=i;
        end
    end
    % get indices from mobs (we do the same as above but looking at the
    % other group)
    nrem_spiz = Restrict(nrem_lfp,spiz_epoch);
    for i=1:size(spim_nrem,1)
        spim_nrem_ts = intervalSet(spim_nrem(i,1),spim_nrem(i,2));
        in = inInterval(spim_nrem_ts,nrem_spiz);
        if ~sum(Data(in))
            id.nrem{3}(end+1)=i;
        end
    end
    matspi.nrem(1) = y_nrem;
    matspi.nrem(2) = n_nrem;
    matspi.nrem(3) = length(id.nrem{3});
    matspi.nrem(4) = y_nrem + n_nrem + length(id.nrem{3});

    % Wake
    % restrict to stage and create interval set
    wake_lfp = Restrict(LFP,Wake);
    wake_spim = Restrict(wake_lfp,spim_epoch);

    for i=1:size(spiz_wake,1)
        spiz_wake_ts = intervalSet(spiz_wake(i,1),spiz_wake(i,2));
        in = inInterval(spiz_wake_ts,wake_spim);
        if sum(Data(in))
            y_wake=y_wake+1;
            id.wake{1}(end+1)=i;
        else
            n_wake=n_wake+1;
            id.wake{2}(end+1)=i;
        end
    end
    % get indices from mobs (we do the same as above but looking at the
    % other group)
    wake_spiz = Restrict(wake_lfp,spiz_epoch);
    for i=1:size(spim_wake,1)
        spim_wake_ts = intervalSet(spim_wake(i,1),spim_wake(i,2));
        in = inInterval(spim_wake_ts,wake_spiz);
        if ~sum(Data(in))
            id.wake{3}(end+1)=i;
        end
    end
    matspi.wake(1) = y_wake;
    matspi.wake(2) = n_wake;
    matspi.wake(3) = length(id.wake{3});
    
    %% prep data for waveforms
    % all
    spi.all.both = spiz(id.all{1},1:3)/1E4;
    spi.all.zug = spiz(id.all{2},1:3)/1E4;
    spi.all.mobs = spim(id.all{3},1:3)/1E4;
    % nrem
    spi.nrem.both = spiz(id.nrem{1},1:3)/1E4;
    spi.nrem.zug = spiz(id.nrem{2},1:3)/1E4;
    spi.nrem.mobs = spim(id.nrem{3},1:3)/1E4;
    % rem
    spi.wake.both = spiz(id.wake{1},1:3)/1E4;
    spi.wake.zug = spiz(id.wake{2},1:3)/1E4;
    spi.wake.mobs = spim(id.wake{3},1:3)/1E4;

    %% Waveforms
    disp('')
    disp('...processing waveforms')
    % All
    %   - both
    [wf.all.both, t.all.both]=PlotRipRaw(LFP, spi.all.both, [-1000 1000],'PlotFigure',0);
    %   - zugaro only
    [wf.all.zug, t.all.zug]=PlotRipRaw(LFP, spi.all.zug, [-1000 1000],'PlotFigure',0);
    %   - mobs only
    [wf.all.mobs, t.all.mobs]=PlotRipRaw(LFP, spi.all.mobs, [-1000 1000],'PlotFigure',0);


    % nrem
    %   - both
    [wf.nrem.both, t.nrem.both]=PlotRipRaw(LFP, spi.nrem.both, [-1000 1000],'PlotFigure',0);
    %   - zugaro only
    [wf.nrem.zug, t.nrem.zug]=PlotRipRaw(LFP, spi.nrem.zug, [-1000 1000],'PlotFigure',0);
    %   - mobs only
    [wf.nrem.mobs, t.nrem.mobs]=PlotRipRaw(LFP, spi.nrem.mobs, [-1000 1000],'PlotFigure',0);

    % wake
    %   - both
    [wf.wake.both, t.wake.both]=PlotRipRaw(LFP, spi.wake.both, [-1000 1000],'PlotFigure',0);
    %   - zugaro only
    [wf.wake.zug, t.wake.zug]=PlotRipRaw(LFP, spi.wake.zug, [-1000 1000],'PlotFigure',0);
    %   - mobs only
    [wf.wake.mobs, t.wake.mobs]=PlotRipRaw(LFP, spi.wake.mobs, [-1000 1000],'PlotFigure',0);  
    
    %save
    save('Spi_comp.mat','info','matspi','id','spi','wf','peak');

else
    load('Spi_comp.mat');
end

%% set data
% confusion matrix
confmatx = [matspi.nrem'];


%% plot waveforms
supertit = 'Comparisons between spiple detection methods';
figH = figure('Color',[1 1 1], 'rend','painters','pos',[1 1 800 400],'Name', supertit, 'NumberTitle','off');

    
subplot(2,4,1:3)
    plot(wf.nrem.both(:,2),'-k','LineWidth',1.5)
    hold on
    plot(wf.nrem.zug(:,2),'-b','LineWidth',1.5)
    hold on
    plot(wf.nrem.mobs(:,2),'-g','LineWidth',1.5)
%     title(info.StageOrder{2})
    ylabel('amplitude')
    xlim([0 2500])
    legend({[info.GroupOrder{1} ' - ' num2str(size(spi.nrem.both,1)) ' spi'],...
        [info.GroupOrder{2} ' - ' num2str(size(spi.nrem.zug,1)) ' spi'],...
        [info.GroupOrder{3} ' - ' num2str(size(spi.nrem.mobs,1)) ' spi']},...
        'location','OutsideSouth','FontSize',10);

 
% crosscorr
nbbin=51;
durbin=50;

%  - nrem
subplot(2,4,4)
    [C, B] = CrossCorr(peak.z.nrem, peak.m.nrem, durbin, nbbin);
        b2 = bar(C(1:nbbin));  
        set(gca,'Xtick',[1 nbbin],'XtickLabel',cellstr(num2str(B([1 nbbin])/10)));
%         title('NREM')
        ylabel('')
        ylim([0 max(C)*1.15])
       

T = table(confmatx,'RowNames',info.GroupOrder);
t = uitable('Data',T{:,:},'ColumnName',info.StageOrder{2},...
'RowName',T.Properties.RowNames,'Units', 'Normalized', 'Position',[0, 0, 1, 1]);        
        
subplot(2,4,6:7)
    % -------------------
    % create fake plot to get position and insert table
    plot(3)
    pos = get(subplot(2,4,6:7),'position');
    delete(subplot(2,4,6:7))
    % -------------------
    set(t,'units','normalized')
    set(t,'position',pos)
     
end