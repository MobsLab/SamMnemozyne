function [ripples,stdev] = FindRipples_SL (dHPC_rip,nonrip, thresh, varargin)
%A small customization of FindRipples - Dima, 09.04.2018
%
%Prepare filtered for FindRipples, find ripples and save events and plots
% Works in the current folder
%
% Example: FindRipples_SL ('991',2,6,[1 1.8], 'rmvnoise',1,'clean',1);
%
% See FindRipples SaveRippleEvents

%% Parameters

% Parse parameter list
for i = 1:2:length(varargin)
    if ~ischar(varargin{i})
		error(['Parameter ' num2str(i+2) ' is not a property (type ''help <a href="matlab:help FindRipples">FindRipples</a>'' for details).']);
    end
    switch(lower(varargin{i}))
		case 'stdev'
			sd = varargin{i+1};
			if isdscalar(sd,'<0')
				error('Incorrect value for property ''stdev'' (type ''help <a href="matlab:help FindRipples">FindRipples</a>'' for details).');
            end
		case 'frequency'
			freq = varargin{i+1};
			if isdvector(freq,'#1')
				error('Incorrect value for property ''frequency'' (type ''help <a href="matlab:help FindRipples">FindRipples</a>'' for details).');
            end
        case 'durations'
			dur = varargin{i+1};
			if isdvector(dur,'#1')
				error('Incorrect value for property ''durations'' (type ''help <a href="matlab:help FindRipples">FindRipples</a>'' for details).');
            end
        case 'rmvnoise'
			rmvnoise = varargin{i+1};
			if isdscalar(rmvnoise,'==0','==1')
				error('Incorrect value for property ''rmvnoise'' (type ''help <a href="matlab:help FindRipples">FindRipples</a>'' for details).');
            end
        case 'clean'
			clean = varargin{i+1};
			if isdscalar(clean,'==0','==1')
				error('Incorrect value for property ''clean'' (type ''help <a href="matlab:help FindRipples">FindRipples</a>'' for details).');
            end
        case 'immmobile'
			immobile = varargin{i+1};
    end
end

%check if exist and assign default value if not
if ~exist('dHPC_rip','var')
    dHPC_rip = 17; % Number of ripples channel
end
if ~exist('nonrip','var')
   nonrip = 7; % Number of hippocampal channel without ripples
endspindle
if ~exist('thresh','var')
   thresh = [2 5]; % Thresholds for FindRipples
end
if ~exist('rmvnoise','var')
   rmvnoise = 1; % Remove or not from noisy channel
end
if ~exist('clean','var')
   clean = 0; % Do we need to calculate noise on a noiseless epochs?
end
if ~exist('immobile','var')
   immobile = 0; % Only epoch with non-moving mouse = 1
end

% Parameters to change manually
filename = 'ripples.evt.rip';
noise_thr = 13E3;
%%%%----------------------------------%%%
freq = [120 220]; % frequency range of ripples
dur = [15 20 200]; % Durations for FindRipples (min inter-ripple; min dur rip; max dur rip)
sd = [];
%%%%----------------------------------%%%
%set folders
[parentdir,~,~]=fileparts(pwd);
pathOut = [pwd '/Ripples/' date '/'];
if ~exist(pathOut,'dir')
    mkdir(pathOut);
end


%% 
% ------------------------------------------------------------------------- 
%                              SECTION
%                         L O A D    D A T A 
% -------------------------------------------------------------------------
% load sleep scoring
res = pwd;
cd(res);
LFP_rip = load([ res '/LFPData/LFP' num2str(dHPC_rip) '.mat']);
if immobile
    immoEpoch = thresholdIntervals(LFP_rip.LFP,5,'Direction', 'Below');
    LFP = Restrict(LFP_rip.LFP,immoEpoch);
else
    LFP = LFP_rip.LFP;
end
LFPf=FilterLFP(LFP,freq,1048);
LFPr=LFP;
if rmvnoise == 1
    LFP_noise = load([ res '/LFPData/LFP' num2str(nonrip) '.mat']);
    if immobile
        LFPnoise = Restrict(LFP_noise.LFP,immoEpoch);
    else
        LFPnoise = LFP_noise.LFP;
    end
    LFPfn=FilterLFP(LFPnoise.LFP,freq,1048);
    LFPn=LFPnoise;
    NoiseTime=Range(LFPfn, 's');
    NoiseData=Data(LFPfn);
end
GoodTime=Range(LFPf, 's');
GoodData=Data(LFPf);
clear LFP_rip LFP_noise

%% 
% ------------------------------------------------------------------------- 
%                              SECTION
%              Calculate standard deviation without noise 
% -------------------------------------------------------------------------
if clean == 1
    load('behavResources.mat');
    AboveEpoch=thresholdIntervals(LFPr,noise_thr,'Direction','Above'); % Threshold on non-filtered data!!!
    NoiseEpoch=thresholdIntervals(LFPr,-noise_thr,'Direction','Below'); % Threshold on non-filtered data!!!
    CleanEpoch=or(AboveEpoch,NoiseEpoch);
    CleanEpoch=intervalSet(Start(CleanEpoch)-3E3,End(CleanEpoch)+5E3);
    if exist('TTLInfo')
        StimEpoch = intervalSet(Start(TTLInfo.StimEpoch)-1E3, End(TTLInfo.StimEpoch)+3E3);
        GoEpoch = or(CleanEpoch,StimEpoch);
    else
        GoEpoch=CleanEpoch;
    end
    rg=Range(LFPr);
    TotalEpoch=intervalSet(rg(1),rg(end));
    SCleanEpoch=mergeCloseIntervals(GoEpoch,1);
    GoodTime=Range(Restrict(LFPf,TotalEpoch-SCleanEpoch), 's');
    GoodData=Data(Restrict(LFPf,TotalEpoch-SCleanEpoch));
    if rmvnoise == 1
        NoiseTime=Range(Restrict(LFPfn,TotalEpoch-SCleanEpoch), 's');
        NoiseData=Data(Restrict(LFPfn,TotalEpoch-SCleanEpoch));
    end
end


%% 
% ------------------------------------------------------------------------- 
%                              SECTION
%                       F I N D    R I P P L E S  
% -------------------------------------------------------------------------
if rmvnoise == 1
    if ~isempty(sd)
        [ripples, stdev,~] = FindRipples([GoodTime GoodData], 'thresholds',thresh,'durations',dur,...
        'stdev', sd, 'noise',[NoiseTime NoiseData]);
    else
        [ripples, stdev,~] = FindRipples([GoodTime GoodData], 'thresholds',thresh,'durations',dur,...
        'noise',[NoiseTime NoiseData]);
    end
else
    if ~isempty(sd)
        [ripples,stdev] = FindRipples([GoodTime GoodData], 'thresholds',thresh,'durations',dur, 'stdev', sd);
    else
        [ripples,stdev] = FindRipples([GoodTime GoodData], 'thresholds',thresh,'durations',dur);
    end
end


%% Save events
SaveRippleEvents(filename,ripples,dHPC_rip, 'overwrite', 'on');
save('Ripples.mat', 'ripples', 'stdev', 'dHPC_rip', 'nonrip', 'thresh', 'dur', 'freq', 'rmvnoise');

%% 
% ------------------------------------------------------------------------- 
%                              SECTION
%                            F I G U R E  
% -------------------------------------------------------------------------

set(0,'defaulttextinterpreter','latex');
set(0,'DefaultTextFontname', 'Arial')
set(0,'DefaultAxesFontName', 'Arial')
set(0,'defaultTextFontSize',12)
set(0,'defaultAxesFontSize',12)

% Plot stats
[maps,data,stats] = RippleStats([Range(LFPf,'s') Data(LFPf)],ripples);
PlotRippleStats(ripples,maps,data,stats, 'saveplot', 1);


% Plot Raw stuff
[M,T]=PlotRipRaw(LFPr, ripples, [-60 60]);
saveas(gcf, [pathOut '/Rippleraw.fig']);
print('-dpng','Rippleraw','-r300');
close(gcf);
save('Ripples.mat','M','T','-append');

% plot average ripple
supertit = ['Average ripple'];
figure('Color',[1 1 1], 'rend','painters','pos',[10 10 1000 600],'Name', supertit, 'NumberTitle','off')  
    shadedErrorBar([],M(:,2),M(:,3),'-b',1);
    xlabel('Time (ms)')
    ylabel('$${\mu}$$V')   
    title(['Average ripple']);      
    xlim([1 size(M,1)])
    set(gca, 'Xtick', 1:25:size(M,1),...
                'Xticklabel', num2cell([floor(M(1,1)*1000):20:ceil(M(end,1)*1000)]))   

    %- save picture
    output_plot = ['average_ripple.png'];
    fulloutput = [pathOut output_plot];
    print('-dpng',fulloutput,'-r300');

end




