function [ripples,stdev] = FindRipples_sites (dHPC_rip,spkgr,pos,nonrip, thresh, varargin)
%A small customization of FindRipples - Dima, 09.04.2018
% modified by Samuel Laventure 2020-07
%
%Prepare filtered for FindRipples, find ripples and save events and plots
% Works in the current folder
%
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
    end
end

%check if exist and assign default value if not
if ~exist('dHPC_rip','var')
    dHPC_rip = 9; % Number of ripples channel
end
if ~exist('nonrip','var')
   nonrip = 13; % Number of hippocampal channel without ripples
end
if ~exist('thresh','var')
   thresh = [2 5]; % Thresholds for FindRipples
end
if ~exist('rmvnoise','var')
   rmvnoise = 1; % Remove or not from noisy channel
end
if ~exist('clean','var')
   clean = 0; % Do we need to calculate noise on a noiseless epochs?
end



% Parameters to change manually
siteN=['spkGr' num2str(spkgr) '_' num2str(pos)];
filename = ['ripples_spkGr' siteN '.evt.rip'];
noise_thr = 13E3;
%%%%----------------------------------%%%
freq = [120 220]; % frequency range of ripples
dur = [15 20 200]; % Durations for FindRipples
sd = [];
%%%%----------------------------------%%%



%% Load data
res = pwd;
cd(res);
LFP_rip = load([ res '/LFPData/LFP' num2str(dHPC_rip) '.mat']);
LFPf=FilterLFP(LFP_rip.LFP,freq,1048);
LFPr=LFP_rip.LFP;
if rmvnoise == 1
    LFP_noise = load([ res '/LFPData/LFP' num2str(nonrip) '.mat']);
    LFPfn=FilterLFP(LFP_noise.LFP,freq,1048);
    LFPn=LFP_noise.LFP;
    NoiseTime=Range(LFPfn, 's');
    NoiseData=Data(LFPfn);
end
GoodTime=Range(LFPf, 's');
GoodData=Data(LFPf);
clear LFP_rip LFP_noise

%% Calculate standard deviation without noise
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


%% Find Ripples
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
save (['Ripples' siteN], 'ripples', 'stdev', 'dHPC_rip', 'nonrip', 'thresh', 'dur', 'freq', 'rmvnoise');


% %% Plot stats
% [maps,data,stats] = RippleStats([Range(LFPf,'s') Data(LFPf)],ripples);
% PlotRippleStats(ripples,maps,data,stats, 'saveplot', 1);


%% Plot Raw stuff
PlotRipRaw(LFPr, ripples, [-60 60]);
saveas(gcf, [res '/Rippleraw' siteN '.fig']);
saveFigure(gcf,['RippleRaw' siteN],res);
close(gcf);



end




