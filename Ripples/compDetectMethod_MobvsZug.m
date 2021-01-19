function [figH] = compDetectMethod_MobsvsZug()

%% load data

load('Ripples.mat','ripples','RipplesEpoch','M','ripples_Info');
ripm = ripples*1E4;
ripm_epoch = RipplesEpoch;
wf_ripm_all = M;
ripm_chan = ripples_Info.channel;
clear ripples Ripplesepoch M LFP

load('Ripples_zug.mat','ripples','dHPC_rip');
ripz = ripples*1E4;
ripz_epoch = intervalSet(ripz(:,1),ripz(:,3));
ripz_chan = dHPC_rip;
clear ripples

% sleep
load('SleepScoring_OBGamma.mat','SWSEpoch','Wake');

% data (to create tsd)
load([pwd '/LFPData/LFP' num2str(ripm_chan) '.mat']);


if ~exist('Rip_comp.mat','file')
    %% Prep data
    % all
    ripm_epoch_all = and(ripm_epoch,or(SWSEpoch,Wake));
    ripm_all = [Start(ripm_epoch_all),End(ripm_epoch_all)];
    st = Start(ripm_epoch_all);
    for i=1:length(Start(ripm_epoch_all))
        idx = find(st(i)==Start(ripm_epoch));
        if idx
            peak.m.all(i) = ripm(idx);
            idx=[];
        else
            peak.m.all(i) = nan;
            disp('peak mobs all: no ripple')
        end
    end
    ripz_epoch_all = and(ripz_epoch,or(SWSEpoch,Wake));
    ripz_all = [Start(ripz_epoch_all),End(ripz_epoch_all)];
    st = Start(ripz_epoch_all);
    for i=1:length(Start(ripz_epoch_all))
        idx = find(Start(ripz_epoch)==st(i));
        if idx
            peak.z.all(i) = ripz(idx);
            idx=[];
        else
            peak.z.all(i) = nan;
            disp('peak zug all: no ripple')
        end
    end

    % nrem
    ripm_epoch_nrem = and(ripm_epoch,SWSEpoch);
    ripm_nrem = [Start(ripm_epoch_nrem),End(ripm_epoch_nrem)];
    st = Start(ripm_epoch_nrem);
    for i=1:length(Start(ripm_epoch_nrem))
        idx = find(Start(ripm_epoch)==st(i));
        if idx
            peak.m.nrem(i) = ripm(idx);
            idx=[];
        else
            peak.m.nrem(i) = nan;
            disp('peak zug nrem: no ripple')
        end
    end
    ripz_epoch_nrem = and(ripz_epoch,SWSEpoch);
    ripz_nrem = [Start(ripz_epoch_nrem),End(ripz_epoch_nrem)];
    st = Start(ripz_epoch_nrem);
    for i=1:length(Start(ripz_epoch_nrem))
        idx = find(Start(ripz_epoch)==st(i));
        if idx
            peak.z.nrem(i) = ripz(idx);
            idx=[];
        else
            peak.z.nrem(i) = nan;
            disp('peak zug nrem: no ripple')
        end
    end

    %wake
    ripm_epoch_wake = and(ripm_epoch,Wake);
    ripm_wake = [Start(ripm_epoch_wake),End(ripm_epoch_wake)];
    st = Start(ripm_epoch_wake);
    for i=1:length(Start(ripm_epoch_wake))
        idx = find(Start(ripm_epoch)==st(i));
        if idx
            peak.m.wake(i) = ripm(idx);
            idx=[];
        else
            peak.m.wake(i) = nan;
            disp('peak mobs wake: no ripple')
        end
    end
    ripz_epoch_wake = and(ripz_epoch,Wake);
    ripz_wake = [Start(ripz_epoch_wake),End(ripz_epoch_wake)];
    st = Start(ripz_epoch_wake);
    for i=1:length(Start(ripz_epoch_wake))
        idx = find(Start(ripz_epoch)==st(i));
        if idx
            peak.z.wake(i) = ripz(idx);
            idx=[];
        else
            peak.z.wake(i) = nan;
            disp('peak zug wake: no ripple')
        end
    end


    %% calculations
    disp('')
    disp('...Sorting ripples')
    % init var
    info.GroupOrder = {'Common','Zug. only','MOBs only'};
    info.StageOrder = {'All','NREM','Wake'};
    y_all=0;n_all=0;
    y_nrem=0;n_nrem=0;
    y_wake=0;n_wake=0;
    id.all{1}=[];id.all{2}=[];id.all{3}=[];    % ripples detected by both will have zugaro indices 
    id.nrem{1}=[];id.nrem{2}=[];id.nrem{3}=[];
    id.wake{1}=[];id.wake{2}=[];id.wake{3}=[];

    % All stages
    all_lfp = Restrict(LFP,or(SWSEpoch,Wake));
    all_ripm = Restrict(all_lfp,ripm_epoch);
    for i=1:size(ripz_all,1)
        ripz_all_ts = intervalSet(ripz_all(i,1),ripz_all(i,2));
        in = inInterval(ripz_all_ts,all_ripm);
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
    all_ripz = Restrict(all_lfp,ripz_epoch);
    for i=1:size(ripm_all,1)
        ripm_all_ts = intervalSet(ripm_all(i,1),ripm_all(i,2));
        in = inInterval(ripm_all_ts,all_ripz);
        if ~sum(Data(in))
            id.all{3}(end+1)=i;
        end
    end
    matrip.all(1) = y_all;
    matrip.all(2) = n_all;
    matrip.all(3) = length(id.all{3});

    % nrem
    % restrict to stage and create interval set
    nrem_lfp = Restrict(LFP,SWSEpoch);
    nrem_ripm = Restrict(nrem_lfp,ripm_epoch);

    for i=1:size(ripz_nrem,1)
        ripz_nrem_ts = intervalSet(ripz_nrem(i,1),ripz_nrem(i,2));
        in = inInterval(ripz_nrem_ts,nrem_ripm);
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
    nrem_ripz = Restrict(nrem_lfp,ripz_epoch);
    for i=1:size(ripm_nrem,1)
        ripm_nrem_ts = intervalSet(ripm_nrem(i,1),ripm_nrem(i,2));
        in = inInterval(ripm_nrem_ts,nrem_ripz);
        if ~sum(Data(in))
            id.nrem{3}(end+1)=i;
        end
    end
    matrip.nrem(1) = y_nrem;
    matrip.nrem(2) = n_nrem;
    matrip.nrem(3) = length(id.nrem{3});

    % Wake
    % restrict to stage and create interval set
    wake_lfp = Restrict(LFP,Wake);
    wake_ripm = Restrict(wake_lfp,ripm_epoch);

    for i=1:size(ripz_wake,1)
        ripz_wake_ts = intervalSet(ripz_wake(i,1),ripz_wake(i,2));
        in = inInterval(ripz_wake_ts,wake_ripm);
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
    wake_ripz = Restrict(wake_lfp,ripz_epoch);
    for i=1:size(ripm_wake,1)
        ripm_wake_ts = intervalSet(ripm_wake(i,1),ripm_wake(i,2));
        in = inInterval(ripm_wake_ts,wake_ripz);
        if ~sum(Data(in))
            id.wake{3}(end+1)=i;
        end
    end
    matrip.wake(1) = y_wake;
    matrip.wake(2) = n_wake;
    matrip.wake(3) = length(id.wake{3});
    
    %% prep data for waveforms
    % all
    rip.all.both = ripz(id.all{1},1:3)/1E4;
    rip.all.zug = ripz(id.all{2},1:3)/1E4;
    rip.all.mobs = ripm(id.all{3},1:3)/1E4;
    % nrem
    rip.nrem.both = ripz(id.nrem{1},1:3)/1E4;
    rip.nrem.zug = ripz(id.nrem{2},1:3)/1E4;
    rip.nrem.mobs = ripm(id.nrem{3},1:3)/1E4;
    % rem
    rip.wake.both = ripz(id.wake{1},1:3)/1E4;
    rip.wake.zug = ripz(id.wake{2},1:3)/1E4;
    rip.wake.mobs = ripm(id.wake{3},1:3)/1E4;

    %% Waveforms
    disp('')
    disp('...processing waveforms')
    % All
    %   - both
    [wf.all.both, t.all.both]=PlotRipRaw(LFP, rip.all.both, [-60 60],'PlotFigure',0);
    %   - zugaro only
    [wf.all.zug, t.all.zug]=PlotRipRaw(LFP, rip.all.zug, [-60 60],'PlotFigure',0);
    %   - mobs only
    [wf.all.mobs, t.all.mobs]=PlotRipRaw(LFP, rip.all.mobs, [-60 60],'PlotFigure',0);


    % nrem
    %   - both
    [wf.nrem.both, t.nrem.both]=PlotRipRaw(LFP, rip.nrem.both, [-60 60],'PlotFigure',0);
    %   - zugaro only
    [wf.nrem.zug, t.nrem.zug]=PlotRipRaw(LFP, rip.nrem.zug, [-60 60],'PlotFigure',0);
    %   - mobs only
    [wf.nrem.mobs, t.nrem.mobs]=PlotRipRaw(LFP, rip.nrem.mobs, [-60 60],'PlotFigure',0);

    % wake
    %   - both
    [wf.wake.both, t.wake.both]=PlotRipRaw(LFP, rip.wake.both, [-60 60],'PlotFigure',0);
    %   - zugaro only
    [wf.wake.zug, t.wake.zug]=PlotRipRaw(LFP, rip.wake.zug, [-60 60],'PlotFigure',0);
    %   - mobs only
    [wf.wake.mobs, t.wake.mobs]=PlotRipRaw(LFP, rip.wake.mobs, [-60 60],'PlotFigure',0);  
    
    %save
    save('Rip_comp.mat','info','matrip','id','rip','wf','peak');

else
    load('Rip_comp.mat');
end

%% set data
% confusion matrix
confmatx = [matrip.all' matrip.nrem' matrip.wake'];


%% plot waveforms
supertit = 'Comparisons between ripple detection methods';
figH = figure('Color',[1 1 1], 'rend','painters','pos',[1 1 1100 800],'Name', supertit, 'NumberTitle','off');
    
subplot(4,11,1:7)
    plot(wf.all.both(:,2),'-k','LineWidth',1)
    hold on
    plot(wf.all.zug(:,2),'-b','LineWidth',1)
    hold on
    plot(wf.all.mobs(:,2),'-g','LineWidth',1)
    title(info.StageOrder{1})
    ylabel('amplitude')
    legend({[info.GroupOrder{1} ' - ' num2str(size(rip.all.both,1)) ' rip'],...
        [info.GroupOrder{2} ' - ' num2str(size(rip.all.zug,1)) ' rip'],...
        [info.GroupOrder{3} ' - ' num2str(size(rip.all.mobs,1)) ' rip']},...
        'location','SouthWest','FontSize',8);
    
subplot(4,11,12:18)
    plot(wf.nrem.both(:,2),'-k','LineWidth',1)
    hold on
    plot(wf.nrem.zug(:,2),'-b','LineWidth',1)
    hold on
    plot(wf.nrem.mobs(:,2),'-g','LineWidth',1)
    title(info.StageOrder{2})
    ylabel('amplitude')
    legend({[info.GroupOrder{1} ' - ' num2str(size(rip.nrem.both,1)) ' rip'],...
        [info.GroupOrder{2} ' - ' num2str(size(rip.nrem.zug,1)) ' rip'],...
        [info.GroupOrder{3} ' - ' num2str(size(rip.nrem.mobs,1)) ' rip']},...
        'location','SouthWest','FontSize',8);
    
subplot(4,11,23:29)
    plot(wf.wake.both(:,2),'-k','LineWidth',1)
    hold on
    plot(wf.wake.zug(:,2),'-b','LineWidth',1)
    hold on
    plot(wf.wake.mobs(:,2),'-g','LineWidth',1)
    title(info.StageOrder{3})
    xlabel('time')
    ylabel('amplitude')
    legend({[info.GroupOrder{1} ' - ' num2str(size(rip.wake.both,1)) ' rip'],...
        [info.GroupOrder{2} ' - ' num2str(size(rip.wake.zug,1)) ' rip'],...
        [info.GroupOrder{3} ' - ' num2str(size(rip.wake.mobs,1)) ' rip']},...
        'location','SouthWest','FontSize',8);
 
% crosscorr
nbbin=51;
durbin=50;

%  - all
subplot(4,11,9:11)    
    [C, B] = CrossCorr(peak.m.all, peak.z.all, durbin, nbbin);
        b1 = bar(C(1:nbbin));  
        set(gca,'Xtick',[1 nbbin],'XtickLabel',cellstr(num2str(B([1 nbbin])/10)));
        title('All')
        ylabel('')
        ylim([0 max(C)*1.15])
    
%  - nrem
subplot(4,11,20:22)
    [C, B] = CrossCorr(peak.z.nrem, peak.m.nrem, durbin, nbbin);
        b2 = bar(C(1:nbbin));  
        set(gca,'Xtick',[1 nbbin],'XtickLabel',cellstr(num2str(B([1 nbbin])/10)));
        title('NREM')
        ylabel('')
        ylim([0 max(C)*1.15])
    
%  - wake
subplot(4,11,31:33)
    [C, B] = CrossCorr(peak.m.wake, peak.z.wake, durbin, nbbin);
        b1 = bar(C(1:nbbin)); 
        set(gca,'Xtick',[1 nbbin],'XtickLabel',cellstr(num2str(B([1 nbbin])/10)));
        title('Wake')
        xlabel('time(ms)')
        ylabel('')
        ylim([0 max(C)*1.15])
       

T = table(confmatx,'RowNames',info.GroupOrder);
t = uitable('Data',T{:,:},'ColumnName',info.StageOrder,...
'RowName',T.Properties.RowNames,'Units', 'Normalized', 'Position',[0, 0, 1, 1]);        
        
subplot(4,11,37:41)
    % -------------------
    % create fake plot to get position and insert table
    plot(3)
    pos = get(subplot(4,11,37:41),'position');
    delete(subplot(4,11,37:41))
    % -------------------
    set(t,'units','normalized')
    set(t,'position',pos)
     
end