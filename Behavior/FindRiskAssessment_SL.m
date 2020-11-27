%% Parameters
clear all
Options.DownSample=1;
Options.RemoveMask=1;
Options.Visualization=0;

Mice_to_analyze = [797 798 828 861 882 905 906 911 912];

Lim=0.55;
MakePlot=1;

%% Hab
%%% Hab %%%
DirHab = PathForExperimentsERC_Dima('Hab');
DirHab = RestrictPathForExperiment(DirHab,'nMice', Mice_to_analyze);
for i=1:length(DirHab.path)
    for j = 1:length(DirHab.path{i})
        disp(DirHab.path{i}{j})
        cd(DirHab.path{i}{j})
        load('behavResources.mat')
        if ~exist('RAUser','var')
            tps=Range(LinearDist);
            x=Data(CleanXtsd);
            y=Data(CleanYtsd);
            
            rmpath([dropbox '/Kteam/PrgMatlab/chronux2/spectral_analysis/continuous'])
            [YMax,XMax]=findpeaks(-runmean(Data(LinearDist),5),'MaxPeakWidth',300,'MinPeakHeight',...
                -Lim,'MinPeakDistance',100,'MinPeakProminence',0.1);
            YMax=-YMax;
            XMax(YMax<0.15)=[];
            YMax(YMax<0.15)=[];
            addpath([dropbox '/Kteam/PrgMatlab/chronux2/spectral_analysis/continuous'])
            RAEpoch=intervalSet(tps(XMax)-2*1e4,tps(XMax)+2*1e4);
            if exist('TTLInfo','var')
                if not(isempty(TTLInfo))
                    if not(isempty(TTLInfo.StimEpoch))
                        StimEpoch=intervalSet(Start(TTLInfo.StimEpoch)-2*1e4,Stop(TTLInfo.StimEpoch)+2*1e4);
                    else
                        StimEpoch=intervalSet(0,0.1);
                    end
                else
                    StimEpoch=intervalSet(0,0.1);
                end
            else
                StimEpoch=intervalSet(0,0.1);
                
            end
            RAEpochTemp=RAEpoch-StimEpoch;
            DurEp=Stop(RAEpochTemp,'s')-Start(RAEpochTemp,'s');
            ToKeep=find(DurEp>3.5);
            RAEpoch=subset(RAEpoch,ToKeep);
            RAEpoch=intervalSet(Start(RAEpoch)+1.5*1e4,Start(RAEpoch)+2.5*1e4);
            RAEp.ToShock=RAEpoch;
            size(Start(RAEpoch))
            
            clear RAEpoch
            rmpath([dropbox '/Kteam/PrgMatlab/chronux2/spectral_analysis/continuous'])
            [YMax,XMax]=findpeaks(runmean(Data(LinearDist),5),'MaxPeakWidth',300,'MinPeakHeight',Lim,...
                'MinPeakDistance',100,'MinPeakProminence',0.1);
            XMax(YMax>0.85)=[];
            YMax(YMax>0.85)=[];
            addpath([dropbox '/Kteam/PrgMatlab/chronux2/spectral_analysis/continuous'])
            RAEpoch=intervalSet(tps(XMax)-2*1e4,tps(XMax)+2*1e4);
            RAEpochTemp=RAEpoch-StimEpoch;
            DurEp=Stop(RAEpochTemp,'s')-Start(RAEpochTemp,'s');
            ToKeep=find(DurEp>3.5);
            RAEpoch=subset(RAEpochTemp,ToKeep);
            RAEpoch=intervalSet(Start(RAEpoch)+1.5*1e4,Start(RAEpoch)+2.5*1e4);
            RAEp.ToSafe=RAEpoch;
            size(Start(RAEpoch))
            
            
            RAUser.ToSafe=[];
            RAUser.ToShock=[];
            RAEpoch=RAEp;
            
            fh = figure('units', 'normalized', 'outerposition', [0.1 0.1 0.8 0.6]);
            plot(Range(LinearDist,'s'),Data(LinearDist))
            hold on
            plot(Range(Restrict(LinearDist,RAEpoch.ToShock),'s'),Data(Restrict(LinearDist,RAEpoch.ToShock)),'r*')
            try,
                plot(Start(TTLInfo.StimEpoch,'s'),0.9,'k.','MarkerSize',40)
                plot(Start(TTLInfo.StimEpoch,'s'),0.9,'y.','MarkerSize',30), end
            line(xlim,[1 1]*0.5,'linewidth',3,'color','b')
            line(xlim,[1 1]*0.15,'linewidth',2,'color','k')
            line(xlim,[1 1]*0.85,'linewidth',2,'color','k')
            plot(Range(Restrict(LinearDist,RAEpoch.ToSafe),'s'),Data(Restrict(LinearDist,RAEpoch.ToSafe)),'g*')
            hold off
            pause(7)
            close(fh)
            
            
            if MakePlot & or(not(isempty(Start(RAEp.ToSafe))),not(isempty(Start(RAEp.ToShock))))
                VideoName = dir('**/*.avi');
                a = VideoReader([VideoName.folder '/' VideoName.name]);
                frames = read(a);
                
                tps=Range(Ytsd,'s');
                tps = tps(find(GotFrame));
                ListOfTimes=Start(RAEp.ToShock,'s');
                
                if ~isempty(ListOfTimes)
                    for o = 1:length(ListOfTimes)
                        SSS(o) = find(tps>ListOfTimes(o),1);
                    end
                    
                    for z = 1:length(ListOfTimes)
                        fh = figure('units', 'normalized', 'outerposition', [-1 0.3 0.8 0.6]);
                        clf
                        plot(Range(LinearDist,'s'),Data(LinearDist))
                        hold on
                        plot(Range(Restrict(LinearDist,subset(RAEpoch.ToShock,z)),'s'),...
                            Data(Restrict(LinearDist,subset(RAEpoch.ToShock,z))),'r*')
                        try
                            plot(Start(TTLInfo.StimEpoch,'s'),0.9,'k.','MarkerSize',40)
                            plot(Start(TTLInfo.StimEpoch,'s'),0.9,'y.','MarkerSize',30)
                        end
                        line(xlim,[1 1]*0.5,'linewidth',3,'color','b')
                        line(xlim,[1 1]*0.15,'linewidth',2,'color','k')
                        line(xlim,[1 1]*0.85,'linewidth',2,'color','k')
                        hold off
                        fi = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
                        clf
                        for p=SSS(z)-70:SSS(z)+70 % Around 5 sec before and after the event
                            if p>1
                                figure(fi)
                                IM = squeeze(frames(:,:,:,p));
                                IM = IM(:,:,1);
                                IM = double(IM)/256;
                                imagesc(IM)
                                axis xy
                                title('Shock RA')
                                hold on
                                plot(x(p)*Ratio_IMAonREAL,y(p)*Ratio_IMAonREAL,'*r','MarkerSize',16);
                                hold off
                                pause(0.1)
                            else
                                pause(0.05);
                            end
                            
                        end
                        % What to do with that
                        answer = questdlg('0 is no RA and 2 is perfect RA?', ...
                            'Rate risk assessment events please', ...
                            '0','1', '2', '1');
                        switch answer
                            case '0'
                                answer2 = questdlg('Is the mouse in the maze?', ...
                                    'Where is the mouse', ...
                                    'Yes','No', 'Yes');
                                switch answer2
                                    case 'Yes'
                                        RAUser.ToShock.Time(z)=tps(SSS(z));
                                        RAUser.ToShock.idx(z)=SSS(z);
                                        RAUser.ToShock.grade(z)=0;
                                    case 'No'
                                        RAUser.ToShock.Time(z)=tps(SSS(z));
                                        RAUser.ToShock.idx(z)=SSS(z);
                                        RAUser.ToShock.grade(z)=NaN;
                                end
                            case '1'
                                RAUser.ToShock.Time(z)=tps(SSS(z));
                                RAUser.ToShock.idx(z)=SSS(z);
                                RAUser.ToShock.grade(z)=1;
                            case '2'
                                RAUser.ToShock.Time(z)=tps(SSS(z));
                                RAUser.ToShock.idx(z)=SSS(z);
                                RAUser.ToShock.grade(z)=2;
                        end
                        close(fh)
                        close(fi)
                        close all
                    end
                else
                    RAUser.ToShock.Time=[];
                    RAUser.ToShock.idx=[];
                    RAUser.ToShock.grade=[];
                end
                
                ListOfTimes=Start(RAEp.ToSafe,'s');
                
                if ~isempty(ListOfTimes)
                    for o = 1:length(ListOfTimes)
                        FFF(o) = find(tps>ListOfTimes(o),1);
                    end
                    for z = 1:length(ListOfTimes)
                        fh = figure('units', 'normalized', 'outerposition', [-1 0.3 0.8 0.6]);
                        clf
                        plot(Range(LinearDist,'s'),Data(LinearDist))
                        hold on
                        plot(Range(Restrict(LinearDist,subset(RAEpoch.ToSafe,z)),'s'),...
                            Data(Restrict(LinearDist,subset(RAEpoch.ToSafe,z))),'g*')
                        try
                            plot(Start(TTLInfo.StimEpoch,'s'),0.9,'k.','MarkerSize',40)
                            plot(Start(TTLInfo.StimEpoch,'s'),0.9,'y.','MarkerSize',30)
                        end
                        line(xlim,[1 1]*0.5,'linewidth',3,'color','b')
                        line(xlim,[1 1]*0.15,'linewidth',2,'color','k')
                        line(xlim,[1 1]*0.85,'linewidth',2,'color','k')
                        hold off
                        fi = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
                        clf
                        for p=FFF(z)-70:FFF(z)+70 % Around 5 sec before and after the event
                            if p>1
                                figure(fi)
                                IM = squeeze(frames(:,:,:,p));
                                IM = IM(:,:,1);
                                IM = double(IM)/256;
                                imagesc(IM)
                                axis xy
                                title('Safe RA')
                                hold on
                                plot(x(p)*Ratio_IMAonREAL,y(p)*Ratio_IMAonREAL,'*r','MarkerSize',16);
                                hold off
                                pause(0.1)
                            else
                                pause(0.05);
                            end
                        end
                        % What to do with that
                        answer = questdlg('0 is no RA and 2 is perfect RA?', ...
                            'Rate risk assessment events please', ...
                            '0','1', '2', '1');
                        switch answer
                            case '0'
                                answer2 = questdlg('Is the mouse in the maze?', ...
                                    'Where is the mouse', ...
                                    'Yes','No', 'Yes');
                                switch answer2
                                    case 'Yes'
                                        RAUser.ToSafe.Time(z)=tps(FFF(z));
                                        RAUser.ToSafe.idx(z)=FFF(z);
                                        RAUser.ToSafe.grade(z)=0;
                                    case 'No'
                                        RAUser.ToSafe.Time(z)=tps(FFF(z));
                                        RAUser.ToSafe.idx(z)=FFF(z);
                                        RAUser.ToSafe.grade(z)=NaN;
                                end
                            case '1'
                                RAUser.ToSafe.Time(z)=tps(FFF(z));
                                RAUser.ToSafe.idx(z)=FFF(z);
                                RAUser.ToSafe.grade(z)=1;
                            case '2'
                                RAUser.ToSafe.Time(z)=tps(FFF(z));
                                RAUser.ToSafe.idx(z)=FFF(z);
                                RAUser.ToSafe.grade(z)=2;
                        end
                    end
                    close(fh)
                    close(fi)
                    close all
                else
                    RAUser.ToSafe.Time=[];
                    RAUser.ToSafe.idx=[];
                    RAUser.ToSafe.grade=[];
                end
                
                
                disp(['SAFE: Epochs ',num2str(sum(~isnan(RAUser.ToSafe.grade))),...
                    ' PerfectOnes ',num2str(length(find(RAUser.ToSafe.grade==2)))])
                disp(['SHOCK: Epochs ',num2str(sum(~isnan(RAUser.ToShock.grade))),...
                    ' PerfectOnes ',num2str(length(find(RAUser.ToShock.grade==2)))])
                disp(['Saving in ' pwd])
                save('behavResources.mat','RAUser', 'RAEpoch', '-append');
                clearvars -except Options Mice_to_analyze Lim MakePlot DirHab i j
            elseif MakePlot
                save('behavResources.mat','RAUser', 'RAEpoch', '-append');
                clearvars -except Options Mice_to_analyze Lim MakePlot DirHab i j
            end
        else
            clearvars -except Options Mice_to_analyze Lim MakePlot DirHab i j
        end
    end
end


%% PreTests
%%% PreTests %%%
DirPre = PathForExperimentsERC_Dima('TestPre');
DirPre = RestrictPathForExperiment(DirPre,'nMice', Mice_to_analyze);
for i=1:length(DirPre.path)
    for j = 1:length(DirPre.path{i})
        disp(DirPre.path{i}{j})
        cd(DirPre.path{i}{j})
        load('behavResources.mat')
        if ~exist('RAUser','var')
            tps=Range(LinearDist);
            x=Data(CleanXtsd);
            y=Data(CleanYtsd);
            
            rmpath([dropbox '/Kteam/PrgMatlab/chronux2/spectral_analysis/continuous'])
            [YMax,XMax]=findpeaks(-runmean(Data(LinearDist),5),'MaxPeakWidth',300,'MinPeakHeight',...
                -Lim,'MinPeakDistance',100,'MinPeakProminence',0.1);
            YMax=-YMax;
            XMax(YMax<0.15)=[];
            YMax(YMax<0.15)=[];
            addpath([dropbox '/Kteam/PrgMatlab/chronux2/spectral_analysis/continuous'])
            RAEpoch=intervalSet(tps(XMax)-2*1e4,tps(XMax)+2*1e4);
            if exist('TTLInfo','var')
                if not(isempty(TTLInfo))
                    if not(isempty(TTLInfo.StimEpoch))
                        StimEpoch=intervalSet(Start(TTLInfo.StimEpoch)-2*1e4,Stop(TTLInfo.StimEpoch)+2*1e4);
                    else
                        StimEpoch=intervalSet(0,0.1);
                    end
                else
                    StimEpoch=intervalSet(0,0.1);
                end
            else
                StimEpoch=intervalSet(0,0.1);
                
            end
            RAEpochTemp=RAEpoch-StimEpoch;
            DurEp=Stop(RAEpochTemp,'s')-Start(RAEpochTemp,'s');
            ToKeep=find(DurEp>3.5);
            RAEpoch=subset(RAEpoch,ToKeep);
            RAEpoch=intervalSet(Start(RAEpoch)+1.5*1e4,Start(RAEpoch)+2.5*1e4);
            RAEp.ToShock=RAEpoch;
            size(Start(RAEpoch))
            
            clear RAEpoch
            rmpath([dropbox '/Kteam/PrgMatlab/chronux2/spectral_analysis/continuous'])
            [YMax,XMax]=findpeaks(runmean(Data(LinearDist),5),'MaxPeakWidth',300,'MinPeakHeight',Lim,...
                'MinPeakDistance',100,'MinPeakProminence',0.1);
            XMax(YMax>0.85)=[];
            YMax(YMax>0.85)=[];
            addpath([dropbox '/Kteam/PrgMatlab/chronux2/spectral_analysis/continuous'])
            RAEpoch=intervalSet(tps(XMax)-2*1e4,tps(XMax)+2*1e4);
            RAEpochTemp=RAEpoch-StimEpoch;
            DurEp=Stop(RAEpochTemp,'s')-Start(RAEpochTemp,'s');
            ToKeep=find(DurEp>3.5);
            RAEpoch=subset(RAEpochTemp,ToKeep);
            RAEpoch=intervalSet(Start(RAEpoch)+1.5*1e4,Start(RAEpoch)+2.5*1e4);
            RAEp.ToSafe=RAEpoch;
            size(Start(RAEpoch))
            
            
            RAUser.ToSafe=[];
            RAUser.ToShock=[];
            RAEpoch=RAEp;
            
            fh = figure('units', 'normalized', 'outerposition', [0.1 0.1 0.8 0.6]);
            plot(Range(LinearDist,'s'),Data(LinearDist))
            hold on
            plot(Range(Restrict(LinearDist,RAEpoch.ToShock),'s'),Data(Restrict(LinearDist,RAEpoch.ToShock)),'r*')
            try,
                plot(Start(TTLInfo.StimEpoch,'s'),0.9,'k.','MarkerSize',40)
                plot(Start(TTLInfo.StimEpoch,'s'),0.9,'y.','MarkerSize',30), end
            line(xlim,[1 1]*0.5,'linewidth',3,'color','b')
            line(xlim,[1 1]*0.15,'linewidth',2,'color','k')
            line(xlim,[1 1]*0.85,'linewidth',2,'color','k')
            plot(Range(Restrict(LinearDist,RAEpoch.ToSafe),'s'),Data(Restrict(LinearDist,RAEpoch.ToSafe)),'g*')
            hold off
            pause(7)
            close(fh)
            
            
            if MakePlot & or(not(isempty(Start(RAEp.ToSafe))),not(isempty(Start(RAEp.ToShock))))
                VideoName = dir('**/*.avi');
                a = VideoReader([VideoName.folder '/' VideoName.name]);
                frames = read(a);
                
                tps=Range(Ytsd,'s');
                tps = tps(find(GotFrame));
                ListOfTimes=Start(RAEp.ToShock,'s');
                
                if ~isempty(ListOfTimes)
                    for o = 1:length(ListOfTimes)
                        SSS(o) = find(tps>ListOfTimes(o),1);
                    end
                    
                    for z = 1:length(ListOfTimes)
                        fh = figure('units', 'normalized', 'outerposition', [-1 0.3 0.8 0.6]);
                        clf
                        plot(Range(LinearDist,'s'),Data(LinearDist))
                        hold on
                        plot(Range(Restrict(LinearDist,subset(RAEpoch.ToShock,z)),'s'),...
                            Data(Restrict(LinearDist,subset(RAEpoch.ToShock,z))),'r*')
                        try
                            plot(Start(TTLInfo.StimEpoch,'s'),0.9,'k.','MarkerSize',40)
                            plot(Start(TTLInfo.StimEpoch,'s'),0.9,'y.','MarkerSize',30)
                        end
                        line(xlim,[1 1]*0.5,'linewidth',3,'color','b')
                        line(xlim,[1 1]*0.15,'linewidth',2,'color','k')
                        line(xlim,[1 1]*0.85,'linewidth',2,'color','k')
                        hold off
                        fi = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
                        clf
                        for p=SSS(z)-70:SSS(z)+70 % Around 5 sec before and after the event
                            if p>1
                                figure(fi)
                                IM = squeeze(frames(:,:,:,p));
                                IM = IM(:,:,1);
                                IM = double(IM)/256;
                                imagesc(IM)
                                axis xy
                                title('Shock RA')
                                hold on
                                plot(x(p)*Ratio_IMAonREAL,y(p)*Ratio_IMAonREAL,'*r','MarkerSize',16);
                                hold off
                                pause(0.1)
                            else
                                pause(0.05);
                            end
                            
                        end
                        % What to do with that
                        answer = questdlg('0 is no RA and 2 is perfect RA?', ...
                            'Rate risk assessment events please', ...
                            '0','1', '2', '1');
                        switch answer
                            case '0'
                                answer2 = questdlg('Is the mouse in the maze?', ...
                                    'Where is the mouse', ...
                                    'Yes','No', 'Yes');
                                switch answer2
                                    case 'Yes'
                                        RAUser.ToShock.Time(z)=tps(SSS(z));
                                        RAUser.ToShock.idx(z)=SSS(z);
                                        RAUser.ToShock.grade(z)=0;
                                    case 'No'
                                        RAUser.ToShock.Time(z)=tps(SSS(z));
                                        RAUser.ToShock.idx(z)=SSS(z);
                                        RAUser.ToShock.grade(z)=NaN;
                                end
                            case '1'
                                RAUser.ToShock.Time(z)=tps(SSS(z));
                                RAUser.ToShock.idx(z)=SSS(z);
                                RAUser.ToShock.grade(z)=1;
                            case '2'
                                RAUser.ToShock.Time(z)=tps(SSS(z));
                                RAUser.ToShock.idx(z)=SSS(z);
                                RAUser.ToShock.grade(z)=2;
                        end
                        close(fh)
                        close(fi)
                        close all
                    end
                else
                    RAUser.ToShock.Time=[];
                    RAUser.ToShock.idx=[];
                    RAUser.ToShock.grade=[];
                end
                
                ListOfTimes=Start(RAEp.ToSafe,'s');
                
                if ~isempty(ListOfTimes)
                    for o = 1:length(ListOfTimes)
                        FFF(o) = find(tps>ListOfTimes(o),1);
                    end
                    for z = 1:length(ListOfTimes)
                        fh = figure('units', 'normalized', 'outerposition', [-1 0.3 0.8 0.6]);
                        clf
                        plot(Range(LinearDist,'s'),Data(LinearDist))
                        hold on
                        plot(Range(Restrict(LinearDist,subset(RAEpoch.ToSafe,z)),'s'),...
                            Data(Restrict(LinearDist,subset(RAEpoch.ToSafe,z))),'g*')
                        try
                            plot(Start(TTLInfo.StimEpoch,'s'),0.9,'k.','MarkerSize',40)
                            plot(Start(TTLInfo.StimEpoch,'s'),0.9,'y.','MarkerSize',30)
                        end
                        line(xlim,[1 1]*0.5,'linewidth',3,'color','b')
                        line(xlim,[1 1]*0.15,'linewidth',2,'color','k')
                        line(xlim,[1 1]*0.85,'linewidth',2,'color','k')
                        hold off
                        fi = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
                        clf
                        for p=FFF(z)-70:FFF(z)+70 % Around 5 sec before and after the event
                            if p>1
                                figure(fi)
                                IM = squeeze(frames(:,:,:,p));
                                IM = IM(:,:,1);
                                IM = double(IM)/256;
                                imagesc(IM)
                                axis xy
                                title('Safe RA')
                                hold on
                                plot(x(p)*Ratio_IMAonREAL,y(p)*Ratio_IMAonREAL,'*r','MarkerSize',16);
                                hold off
                                pause(0.1)
                            else
                                pause(0.05);
                            end
                        end
                        % What to do with that
                        answer = questdlg('0 is no RA and 2 is perfect RA?', ...
                            'Rate risk assessment events please', ...
                            '0','1', '2', '1');
                        switch answer
                            case '0'
                                answer2 = questdlg('Is the mouse in the maze?', ...
                                    'Where is the mouse', ...
                                    'Yes','No', 'Yes');
                                switch answer2
                                    case 'Yes'
                                        RAUser.ToSafe.Time(z)=tps(FFF(z));
                                        RAUser.ToSafe.idx(z)=FFF(z);
                                        RAUser.ToSafe.grade(z)=0;
                                    case 'No'
                                        RAUser.ToSafe.Time(z)=tps(FFF(z));
                                        RAUser.ToSafe.idx(z)=FFF(z);
                                        RAUser.ToSafe.grade(z)=NaN;
                                end
                            case '1'
                                RAUser.ToSafe.Time(z)=tps(FFF(z));
                                RAUser.ToSafe.idx(z)=FFF(z);
                                RAUser.ToSafe.grade(z)=1;
                            case '2'
                                RAUser.ToSafe.Time(z)=tps(FFF(z));
                                RAUser.ToSafe.idx(z)=FFF(z);
                                RAUser.ToSafe.grade(z)=2;
                        end
                    end
                    close(fh)
                    close(fi)
                    close all
                else
                    RAUser.ToSafe.Time=[];
                    RAUser.ToSafe.idx=[];
                    RAUser.ToSafe.grade=[];
                end
                
                
                disp(['SAFE: Epochs ',num2str(sum(~isnan(RAUser.ToSafe.grade))),...
                    ' PerfectOnes ',num2str(length(find(RAUser.ToSafe.grade==2)))])
                disp(['SHOCK: Epochs ',num2str(sum(~isnan(RAUser.ToShock.grade))),...
                    ' PerfectOnes ',num2str(length(find(RAUser.ToShock.grade==2)))])
                disp(['Saving in ' pwd])
                save('behavResources.mat','RAUser', 'RAEpoch', '-append');
                clearvars -except Options Mice_to_analyze Lim MakePlot DirPre i j
            elseif MakePlot
                save('behavResources.mat','RAUser', 'RAEpoch', '-append');
                clearvars -except Options Mice_to_analyze Lim MakePlot DirPre i j
            end
        else
            clearvars -except Options Mice_to_analyze Lim MakePlot DirPre i j
        end
    end
end



%% Cond
%%% Conditioning %%%
DirCond = PathForExperimentsERC_Dima('Cond');
DirCond = RestrictPathForExperiment(DirCond,'nMice', Mice_to_analyze);
for i=1:length(DirCond.path)
    for j = 1:length(DirCond.path{i})
        disp(DirCond.path{i}{j})
        cd(DirCond.path{i}{j})
        load('behavResources.mat')
        if ~exist('RAUser','var')
            tps=Range(LinearDist);
            x=Data(CleanXtsd);
            y=Data(CleanYtsd);
            
            rmpath([dropbox '/Kteam/PrgMatlab/chronux2/spectral_analysis/continuous'])
            [YMax,XMax]=findpeaks(-runmean(Data(LinearDist),5),'MaxPeakWidth',300,'MinPeakHeight',...
                -Lim,'MinPeakDistance',100,'MinPeakProminence',0.1);
            YMax=-YMax;
            XMax(YMax<0.15)=[];
            YMax(YMax<0.15)=[];
            addpath([dropbox '/Kteam/PrgMatlab/chronux2/spectral_analysis/continuous'])
            RAEpoch=intervalSet(tps(XMax)-2*1e4,tps(XMax)+2*1e4);
            if exist('TTLInfo','var')
                if not(isempty(TTLInfo))
                    if not(isempty(TTLInfo.StimEpoch))
                        StimEpoch=intervalSet(Start(TTLInfo.StimEpoch)-2*1e4,Stop(TTLInfo.StimEpoch)+2*1e4);
                    else
                        StimEpoch=intervalSet(0,0.1);
                    end
                else
                    StimEpoch=intervalSet(0,0.1);
                end
            else
                StimEpoch=intervalSet(0,0.1);
                
            end
            RAEpochTemp=RAEpoch-StimEpoch;
            DurEp=Stop(RAEpochTemp,'s')-Start(RAEpochTemp,'s');
            ToKeep=find(DurEp>3.5);
            RAEpoch=subset(RAEpoch,ToKeep);
            RAEpoch=intervalSet(Start(RAEpoch)+1.5*1e4,Start(RAEpoch)+2.5*1e4);
            RAEp.ToShock=RAEpoch;
            size(Start(RAEpoch))
            
            clear RAEpoch
            rmpath([dropbox '/Kteam/PrgMatlab/chronux2/spectral_analysis/continuous'])
            [YMax,XMax]=findpeaks(runmean(Data(LinearDist),5),'MaxPeakWidth',300,'MinPeakHeight',Lim,...
                'MinPeakDistance',100,'MinPeakProminence',0.1);
            XMax(YMax>0.85)=[];
            YMax(YMax>0.85)=[];
            addpath([dropbox '/Kteam/PrgMatlab/chronux2/spectral_analysis/continuous'])
            RAEpoch=intervalSet(tps(XMax)-2*1e4,tps(XMax)+2*1e4);
            RAEpochTemp=RAEpoch-StimEpoch;
            DurEp=Stop(RAEpochTemp,'s')-Start(RAEpochTemp,'s');
            ToKeep=find(DurEp>3.5);
            RAEpoch=subset(RAEpochTemp,ToKeep);
            RAEpoch=intervalSet(Start(RAEpoch)+1.5*1e4,Start(RAEpoch)+2.5*1e4);
            RAEp.ToSafe=RAEpoch;
            size(Start(RAEpoch))
            
            
            RAUser.ToSafe=[];
            RAUser.ToShock=[];
            RAEpoch=RAEp;
            
            fh = figure('units', 'normalized', 'outerposition', [0.1 0.1 0.8 0.6]);
            plot(Range(LinearDist,'s'),Data(LinearDist))
            hold on
            plot(Range(Restrict(LinearDist,RAEpoch.ToShock),'s'),Data(Restrict(LinearDist,RAEpoch.ToShock)),'r*')
            try,
                plot(Start(TTLInfo.StimEpoch,'s'),0.9,'k.','MarkerSize',40)
                plot(Start(TTLInfo.StimEpoch,'s'),0.9,'y.','MarkerSize',30), end
            line(xlim,[1 1]*0.5,'linewidth',3,'color','b')
            line(xlim,[1 1]*0.2,'linewidth',2,'color','k')
            line(xlim,[1 1]*0.8,'linewidth',2,'color','k')
            plot(Range(Restrict(LinearDist,RAEpoch.ToSafe),'s'),Data(Restrict(LinearDist,RAEpoch.ToSafe)),'g*')
            hold off
            pause(7)
            close(fh)
            
            if MakePlot & or(not(isempty(Start(RAEp.ToSafe))),not(isempty(Start(RAEp.ToShock))))
                VideoName = dir('**/*.avi');
                a = VideoReader([VideoName.folder '/' VideoName.name]);
                frames = read(a);
                
                tps=Range(Ytsd,'s');
                tps = tps(find(GotFrame));
                ListOfTimes=Start(RAEp.ToShock,'s');
                
                if ~isempty(ListOfTimes)
                    for o = 1:length(ListOfTimes)
                        SSS(o) = find(tps>ListOfTimes(o),1);
                    end
                    
                    for z = 1:length(ListOfTimes)
                        fh = figure('units', 'normalized', 'outerposition', [-1 0.3 0.8 0.6]);
                        clf
                        plot(Range(LinearDist,'s'),Data(LinearDist))
                        hold on
                        plot(Range(Restrict(LinearDist,subset(RAEpoch.ToShock,z)),'s'),...
                            Data(Restrict(LinearDist,subset(RAEpoch.ToShock,z))),'r*')
                        try
                            plot(Start(TTLInfo.StimEpoch,'s'),0.9,'k.','MarkerSize',40)
                            plot(Start(TTLInfo.StimEpoch,'s'),0.9,'y.','MarkerSize',30)
                        end
                        line(xlim,[1 1]*0.5,'linewidth',3,'color','b')
                        line(xlim,[1 1]*0.15,'linewidth',2,'color','k')
                        line(xlim,[1 1]*0.85,'linewidth',2,'color','k')
                        hold off
                        fi = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
                        clf
                        for p=SSS(z)-70:SSS(z)+70 % Around 5 sec before and after the event
                           if p>1
                                figure(fi)
                                IM = squeeze(frames(:,:,:,p));
                                IM = IM(:,:,1);
                                IM = double(IM)/256;
                                imagesc(IM)
                                axis xy
                                title('Shock RA')
                                hold on
                                plot(x(p)*Ratio_IMAonREAL,y(p)*Ratio_IMAonREAL,'*r','MarkerSize',16);
                                hold off
                                pause(0.1)
                            else
                                pause(0.05);
                            end
                        end
                        % What to do with that
                        answer = questdlg('0 is no RA and 2 is perfect RA?', ...
                            'Rate risk assessment events please', ...
                            '0','1', '2', '1');
                        switch answer
                            case '0'
                                answer2 = questdlg('Is the mouse in the maze?', ...
                                    'Where is the mouse', ...
                                    'Yes','No', 'Yes');
                                switch answer2
                                    case 'Yes'
                                        RAUser.ToShock.Time(z)=tps(SSS(z));
                                        RAUser.ToShock.idx(z)=SSS(z);
                                        RAUser.ToShock.grade(z)=0;
                                    case 'No'
                                        RAUser.ToShock.Time(z)=tps(SSS(z));
                                        RAUser.ToShock.idx(z)=SSS(z);
                                        RAUser.ToShock.grade(z)=NaN;
                                end
                            case '1'
                                RAUser.ToShock.Time(z)=tps(SSS(z));
                                RAUser.ToShock.idx(z)=SSS(z);
                                RAUser.ToShock.grade(z)=1;
                            case '2'
                                RAUser.ToShock.Time(z)=tps(SSS(z));
                                RAUser.ToShock.idx(z)=SSS(z);
                                RAUser.ToShock.grade(z)=2;
                        end
                        close(fh)
                        close(fi)
                        close all
                    end
                else
                    RAUser.ToShock.Time=[];
                    RAUser.ToShock.idx=[];
                    RAUser.ToShock.grade=[];
                end
                
                ListOfTimes=Start(RAEp.ToSafe,'s');
                
                if ~isempty(ListOfTimes)
                    for o = 1:length(ListOfTimes)
                        FFF(o) = find(tps>ListOfTimes(o),1);
                    end
                    for z = 1:length(ListOfTimes)
                        fh = figure('units', 'normalized', 'outerposition', [-1 0.3 0.8 0.6]);
                        clf
                        plot(Range(LinearDist,'s'),Data(LinearDist))
                        hold on
                        plot(Range(Restrict(LinearDist,subset(RAEpoch.ToSafe,z)),'s'),...
                            Data(Restrict(LinearDist,subset(RAEpoch.ToSafe,z))),'g*')
                        try
                            plot(Start(TTLInfo.StimEpoch,'s'),0.9,'k.','MarkerSize',40)
                            plot(Start(TTLInfo.StimEpoch,'s'),0.9,'y.','MarkerSize',30)
                        end
                        line(xlim,[1 1]*0.5,'linewidth',3,'color','b')
                        line(xlim,[1 1]*0.15,'linewidth',2,'color','k')
                        line(xlim,[1 1]*0.85,'linewidth',2,'color','k')
                        hold off
                        fi = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
                        clf
                        for p=FFF(z)-70:FFF(z)+70 % Around 5 sec before and after the event
                            if p>1
                                figure(fi)
                                IM = squeeze(frames(:,:,:,p));
                                IM = IM(:,:,1);
                                IM = double(IM)/256;
                                imagesc(IM)
                                axis xy
                                title('Safe RA')
                                hold on
                                plot(x(p)*Ratio_IMAonREAL,y(p)*Ratio_IMAonREAL,'*r','MarkerSize',16);
                                hold off
                                pause(0.1)
                            else
                                pause(0.05);
                            end
                        end
                        % What to do with that
                        answer = questdlg('0 is no RA and 2 is perfect RA?', ...
                            'Rate risk assessment events please', ...
                            '0','1', '2', '1');
                        switch answer
                            case '0'
                                answer2 = questdlg('Is the mouse in the maze?', ...
                                    'Where is the mouse', ...
                                    'Yes','No', 'Yes');
                                switch answer2
                                    case 'Yes'
                                        RAUser.ToSafe.Time(z)=tps(FFF(z));
                                        RAUser.ToSafe.idx(z)=FFF(z);
                                        RAUser.ToSafe.grade(z)=0;
                                    case 'No'
                                        RAUser.ToSafe.Time(z)=tps(FFF(z));
                                        RAUser.ToSafe.idx(z)=FFF(z);
                                        RAUser.ToSafe.grade(z)=NaN;
                                end
                            case '1'
                                RAUser.ToSafe.Time(z)=tps(FFF(z));
                                RAUser.ToSafe.idx(z)=FFF(z);
                                RAUser.ToSafe.grade(z)=1;
                            case '2'
                                RAUser.ToSafe.Time(z)=tps(FFF(z));
                                RAUser.ToSafe.idx(z)=FFF(z);
                                RAUser.ToSafe.grade(z)=2;
                        end
                    end
                    close(fh)
                    close(fi)
                    close all
                else
                    RAUser.ToSafe.Time=[];
                    RAUser.ToSafe.idx=[];
                    RAUser.ToSafe.grade=[];
                end
                
                
                disp(['SAFE: Epochs ',num2str(sum(~isnan(RAUser.ToSafe.grade))),...
                    ' PerfectOnes ',num2str(length(find(RAUser.ToSafe.grade==2)))])
                disp(['SHOCK: Epochs ',num2str(sum(~isnan(RAUser.ToShock.grade))),...
                    ' PerfectOnes ',num2str(length(find(RAUser.ToShock.grade==2)))])
                save('behavResources.mat','RAUser', 'RAEpoch', '-append');
                clearvars -except Options Mice_to_analyze Lim MakePlot DirCond i j
            elseif MakePlot
                save('behavResources.mat','RAUser', 'RAEpoch', '-append');
                clearvars -except Options Mice_to_analyze Lim MakePlot DirCond i j
            end
        else
            clearvars -except Options Mice_to_analyze Lim MakePlot DirCond i j
        end
    end
end

%% PostTests
%%% PostTests %%%
DirPost = PathForExperimentsERC_Dima('TestPost');
DirPost = RestrictPathForExperiment(DirPost,'nMice', Mice_to_analyze);
for i=1:length(DirPost.path)
    for j = 1:length(DirPost.path{i})
        disp(DirPost.path{i}{j})
        cd(DirPost.path{i}{j})
        load('behavResources.mat')
        if ~exist('RAUser','var')
            tps=Range(LinearDist);
            x=Data(CleanXtsd);
            y=Data(CleanYtsd);
            
            rmpath([dropbox '/Kteam/PrgMatlab/chronux2/spectral_analysis/continuous'])
            [YMax,XMax]=findpeaks(-runmean(Data(LinearDist),5),'MaxPeakWidth',300,'MinPeakHeight',...
                -Lim,'MinPeakDistance',100,'MinPeakProminence',0.1);
            YMax=-YMax;
            XMax(YMax<0.15)=[];
            YMax(YMax<0.15)=[];
            addpath([dropbox '/Kteam/PrgMatlab/chronux2/spectral_analysis/continuous'])
            RAEpoch=intervalSet(tps(XMax)-2*1e4,tps(XMax)+2*1e4);
            if exist('TTLInfo','var')
                if not(isempty(TTLInfo))
                    if not(isempty(TTLInfo.StimEpoch))
                        StimEpoch=intervalSet(Start(TTLInfo.StimEpoch)-2*1e4,Stop(TTLInfo.StimEpoch)+2*1e4);
                    else
                        StimEpoch=intervalSet(0,0.1);
                    end
                else
                    StimEpoch=intervalSet(0,0.1);
                end
            else
                StimEpoch=intervalSet(0,0.1);
                
            end
            RAEpochTemp=RAEpoch-StimEpoch;
            DurEp=Stop(RAEpochTemp,'s')-Start(RAEpochTemp,'s');
            ToKeep=find(DurEp>3.5);
            RAEpoch=subset(RAEpoch,ToKeep);
            RAEpoch=intervalSet(Start(RAEpoch)+1.5*1e4,Start(RAEpoch)+2.5*1e4);
            RAEp.ToShock=RAEpoch;
            size(Start(RAEpoch))
            
            clear RAEpoch
            rmpath([dropbox '/Kteam/PrgMatlab/chronux2/spectral_analysis/continuous'])
            [YMax,XMax]=findpeaks(runmean(Data(LinearDist),5),'MaxPeakWidth',300,'MinPeakHeight',Lim,...
                'MinPeakDistance',100,'MinPeakProminence',0.1);
            XMax(YMax>0.85)=[];
            YMax(YMax>0.85)=[];
            addpath([dropbox '/Kteam/PrgMatlab/chronux2/spectral_analysis/continuous'])
            RAEpoch=intervalSet(tps(XMax)-2*1e4,tps(XMax)+2*1e4);
            RAEpochTemp=RAEpoch-StimEpoch;
            DurEp=Stop(RAEpochTemp,'s')-Start(RAEpochTemp,'s');
            ToKeep=find(DurEp>3.5);
            RAEpoch=subset(RAEpochTemp,ToKeep);
            RAEpoch=intervalSet(Start(RAEpoch)+1.5*1e4,Start(RAEpoch)+2.5*1e4);
            RAEp.ToSafe=RAEpoch;
            size(Start(RAEpoch))
            
            
            RAUser.ToSafe=[];
            RAUser.ToShock=[];
            RAEpoch=RAEp;
            
            fh = figure('units', 'normalized', 'outerposition', [0.1 0.1 0.8 0.6]);
            plot(Range(LinearDist,'s'),Data(LinearDist))
            hold on
            plot(Range(Restrict(LinearDist,RAEpoch.ToShock),'s'),Data(Restrict(LinearDist,RAEpoch.ToShock)),'r*')
            try,
                plot(Start(TTLInfo.StimEpoch,'s'),0.9,'k.','MarkerSize',40)
                plot(Start(TTLInfo.StimEpoch,'s'),0.9,'y.','MarkerSize',30), end
            line(xlim,[1 1]*0.5,'linewidth',3,'color','b')
            line(xlim,[1 1]*0.15,'linewidth',2,'color','k')
            line(xlim,[1 1]*0.85,'linewidth',2,'color','k')
            plot(Range(Restrict(LinearDist,RAEpoch.ToSafe),'s'),Data(Restrict(LinearDist,RAEpoch.ToSafe)),'g*')
            hold off
            pause(7)
            close(fh)
            
            if MakePlot & or(not(isempty(Start(RAEp.ToSafe))),not(isempty(Start(RAEp.ToShock))))
                VideoName = dir('**/*.avi');
                a = VideoReader([VideoName.folder '/' VideoName.name]);
                frames = read(a);
                
                tps=Range(Ytsd,'s');
                tps = tps(find(GotFrame));
                ListOfTimes=Start(RAEp.ToShock,'s');
                
                if ~isempty(ListOfTimes)
                    for o = 1:length(ListOfTimes)
                        SSS(o) = find(tps>ListOfTimes(o),1);
                    end
                    
                    for z = 1:length(ListOfTimes)
                        fh = figure('units', 'normalized', 'outerposition', [-1 0.3 0.8 0.6]);
                        clf
                        plot(Range(LinearDist,'s'),Data(LinearDist))
                        hold on
                        plot(Range(Restrict(LinearDist,subset(RAEpoch.ToShock,z)),'s'),...
                            Data(Restrict(LinearDist,subset(RAEpoch.ToShock,z))),'r*')
                        try
                            plot(Start(TTLInfo.StimEpoch,'s'),0.9,'k.','MarkerSize',40)
                            plot(Start(TTLInfo.StimEpoch,'s'),0.9,'y.','MarkerSize',30)
                        end
                        line(xlim,[1 1]*0.5,'linewidth',3,'color','b')
                        line(xlim,[1 1]*0.2,'linewidth',2,'color','k')
                        line(xlim,[1 1]*0.8,'linewidth',2,'color','k')
                        hold off
                        fi = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
                        clf
                        for p=SSS(z)-70:SSS(z)+70 % Around 5 sec before and after the event
                            if p>1
                                figure(fi)
                                IM = squeeze(frames(:,:,:,p));
                                IM = IM(:,:,1);
                                IM = double(IM)/256;
                                imagesc(IM)
                                axis xy
                                title('Shock RA')
                                hold on
                                plot(x(p)*Ratio_IMAonREAL,y(p)*Ratio_IMAonREAL,'*r','MarkerSize',16);
                                hold off
                                pause(0.1)
                            else
                                pause(0.05);
                            end
                        end
                        % What to do with that
                        answer = questdlg('0 is no RA and 2 is perfect RA?', ...
                            'Rate risk assessment events please', ...
                            '0','1', '2', '1');
                        switch answer
                            case '0'
                                answer2 = questdlg('Is the mouse in the maze?', ...
                                    'Where is the mouse', ...
                                    'Yes','No', 'Yes');
                                switch answer2
                                    case 'Yes'
                                        RAUser.ToShock.Time(z)=tps(SSS(z));
                                        RAUser.ToShock.idx(z)=SSS(z);
                                        RAUser.ToShock.grade(z)=0;
                                    case 'No'
                                        RAUser.ToShock.Time(z)=tps(SSS(z));
                                        RAUser.ToShock.idx(z)=SSS(z);
                                        RAUser.ToShock.grade(z)=NaN;
                                end
                            case '1'
                                RAUser.ToShock.Time(z)=tps(SSS(z));
                                RAUser.ToShock.idx(z)=SSS(z);
                                RAUser.ToShock.grade(z)=1;
                            case '2'
                                RAUser.ToShock.Time(z)=tps(SSS(z));
                                RAUser.ToShock.idx(z)=SSS(z);
                                RAUser.ToShock.grade(z)=2;
                        end
                        close(fh)
                        close(fi)
                        close all
                    end
                else
                    RAUser.ToShock.Time=[];
                    RAUser.ToShock.idx=[];
                    RAUser.ToShock.grade=[];
                end
                
                ListOfTimes=Start(RAEp.ToSafe,'s');
                
                if ~isempty(ListOfTimes)
                    for o = 1:length(ListOfTimes)
                        FFF(o) = find(tps>ListOfTimes(o),1);
                    end
                    for z = 1:length(ListOfTimes)
                        fh = figure('units', 'normalized', 'outerposition', [-1 0.3 0.8 0.6]);
                        clf
                        plot(Range(LinearDist,'s'),Data(LinearDist))
                        hold on
                        plot(Range(Restrict(LinearDist,subset(RAEpoch.ToSafe,z)),'s'),...
                            Data(Restrict(LinearDist,subset(RAEpoch.ToSafe,z))),'g*')
                        try
                            plot(Start(TTLInfo.StimEpoch,'s'),0.9,'k.','MarkerSize',40)
                            plot(Start(TTLInfo.StimEpoch,'s'),0.9,'y.','MarkerSize',30)
                        end
                        line(xlim,[1 1]*0.5,'linewidth',3,'color','b')
                        line(xlim,[1 1]*0.15,'linewidth',2,'color','k')
                        line(xlim,[1 1]*0.85,'linewidth',2,'color','k')
                        hold off
                        fi = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
                        clf
                        for p=FFF(z)-70:FFF(z)+70 % Around 5 sec before and after the event
                            if p>1
                                figure(fi)
                                IM = squeeze(frames(:,:,:,p));
                                IM = IM(:,:,1);
                                IM = double(IM)/256;
                                imagesc(IM)
                                axis xy
                                title('Safe RA')
                                hold on
                                plot(x(p)*Ratio_IMAonREAL,y(p)*Ratio_IMAonREAL,'*r','MarkerSize',16);
                                hold off
                                pause(0.1)
                            else
                                pause(0.05);
                            end
                        end
                        % What to do with that
                        answer = questdlg('0 is no RA and 2 is perfect RA?', ...
                            'Rate risk assessment events please', ...
                            '0','1', '2', '1');
                        switch answer
                            case '0'
                                answer2 = questdlg('Is the mouse in the maze?', ...
                                    'Where is the mouse', ...
                                    'Yes','No', 'Yes');
                                switch answer2
                                    case 'Yes'
                                        RAUser.ToSafe.Time(z)=tps(FFF(z));
                                        RAUser.ToSafe.idx(z)=FFF(z);
                                        RAUser.ToSafe.grade(z)=0;
                                    case 'No'
                                        RAUser.ToSafe.Time(z)=tps(FFF(z));
                                        RAUser.ToSafe.idx(z)=FFF(z);
                                        RAUser.ToSafe.grade(z)=NaN;
                                end
                            case '1'
                                RAUser.ToSafe.Time(z)=tps(FFF(z));
                                RAUser.ToSafe.idx(z)=FFF(z);
                                RAUser.ToSafe.grade(z)=1;
                            case '2'
                                RAUser.ToSafe.Time(z)=tps(FFF(z));
                                RAUser.ToSafe.idx(z)=FFF(z);
                                RAUser.ToSafe.grade(z)=2;
                        end
                    end
                    close(fh)
                    close(fi)
                    close all
                else
                    RAUser.ToSafe.Time=[];
                    RAUser.ToSafe.idx=[];
                    RAUser.ToSafe.grade=[];
                end
                
                
                disp(['SAFE: Epochs ',num2str(sum(~isnan(RAUser.ToSafe.grade))),...
                    ' PerfectOnes ',num2str(length(find(RAUser.ToSafe.grade==2)))])
                disp(['SHOCK: Epochs ',num2str(sum(~isnan(RAUser.ToShock.grade))),...
                    ' PerfectOnes ',num2str(length(find(RAUser.ToShock.grade==2)))])
                save('behavResources.mat','RAUser', 'RAEpoch', '-append');
                clearvars -except Options Mice_to_analyze Lim MakePlot DirPost i j
                elseif MakePlot
                save('behavResources.mat','RAUser', 'RAEpoch', '-append');
                clearvars -except Options Mice_to_analyze Lim MakePlot DirPost i j
            end
        else
            clearvars -except Options Mice_to_analyze Lim MakePlot DirPost i j
        end
    end
end
