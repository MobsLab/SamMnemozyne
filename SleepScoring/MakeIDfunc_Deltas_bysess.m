% MakeIDfunc_Deltas
% 06.12.2017 KJ
%
%%INPUT
%
%
%%OUTPUT
%
%
% SEE
%   MakeIDSleepData MakeIDfunc_Neuron MakeIDfunc_Ripples MakeIDfunc_Spindles
%
%


function [meancurve_pre, meancurve_post, nb_delta_pre, nb_delta_post] = MakeIDfunc_Deltas(varargin)


% Parse parameter list
for i = 1:2:length(varargin)
    if ~ischar(varargin{i})
        error(['Parameter ' num2str(i+2) ' is not a property.']);
    end
    switch(lower(varargin{i}))
        case 'binsize'
            binsize = lower(varargin{i+1});
            if binsize<=0
                error('Incorrect value for property ''binsize''.');
            end
        case 'foldername'
            foldername = lower(varargin{i+1});
        case 'mua'
            MUA = varargin{i+1};
        case 'lfp_sup'
            LFPsup = varargin{i+1};
        case 'lfp_deep'
            LFPdeep = varargin{i+1};
        case 'recompute'
            recompute = varargin{i+1};
            if recompute~=0 && recompute ~=1
                error('Incorrect value for property ''recompute''.');
            end
        otherwise
            error(['Unknown property ''' num2str(varargin{i}) '''.']);
    end
end

%check if exist and assign default value if not
if ~exist('foldername','var')
    foldername = pwd;
end
if ~exist('binsize','var')
    binsize = 10;
end
if ~exist('recompute','var')
    recompute=0;
end
if ~exist('MUA','var')
    %MUA
    load SpikeData
    if exist('SpikesToAnalyse/PFCx_down.mat','file')==2
        load SpikesToAnalyse/PFCx_down
    elseif exist('SpikesToAnalyse/PFCx_Neurons.mat','file')
        load SpikesToAnalyse/PFCx_Neurons
    elseif exist('SpikesToAnalyse/PFCx_MUA.mat','file')
        load SpikesToAnalyse/PFCx_MUA
    else
        number=[];
    end
    NumNeurons=number;
    T=PoolNeurons(S,NumNeurons);
    clear ST
    ST{1}=T;
    try
        ST=tsdArray(ST);
    end
    MUA=MakeQfromS(ST,binsize*10);
    clear ST T
end

%%  pre

if ~exist('LFPsup','var')
    %LFP sup
    load('DeltaWaves.mat', 'deltas_Info_pre')
    if ~isnan(deltas_Info_pre.channel_sup)
        load(['LFPData/LFP' num2str(deltas_Info_pre.channel_sup)],'LFP')
        LFPsup=LFP;
        clear LFP channel
    else
        LFPsup=[];
    end
end

if ~exist('LFPdeep','var')
    load('DeltaWaves.mat', 'deltas_Info_post')
    load(['LFPData/LFP' num2str(deltas_Info_post.channel_deep)],'LFP')
    LFPdeep=LFP;
    clear LFP channel
end

%% data
load('DeltaWaves.mat', 'deltas_pre')
%delta data
deltas_tmp = (Start(deltas_pre) + End(deltas_pre)) / 2e4;
delta_duration = End(deltas_pre) - Start(deltas_pre);
nb_deltas = length(deltas_tmp);
%shortest and largest
[~, idx_delta_sorted] = sort(delta_duration,'ascend');
halfsize = min(floor(nb_deltas/2), 500);
short_deltas = deltas_tmp(idx_delta_sorted(1:halfsize));
long_deltas = deltas_tmp(idx_delta_sorted(end-halfsize+1:end));


%% Mean curves
% short deltas
if ~isempty(LFPsup)
    meancurve_pre.short.sup = PlotRipRaw(LFPsup, sort(short_deltas), 500, 0, 0); close
else
    meancurve_pre.short.sup = [];
end    
if not(isempty(MUA))
    meancurve_pre.short.mua = PlotRipRaw(MUA, sort(short_deltas), 500, 0, 0); close
else
    meancurve_pre.short.mua = [];
end
meancurve_pre.short.deep = PlotRipRaw(LFPdeep, sort(short_deltas), 500, 0, 0); close

% long deltas
if ~isempty(LFPsup)
    meancurve_pre.long.sup = PlotRipRaw(LFPsup, sort(long_deltas), 500, 0, 0); close
else
    meancurve_pre.long.sup = [];
end
if not(isempty(MUA))
    meancurve_pre.long.mua = PlotRipRaw(MUA, sort(long_deltas), 500, 0, 0); close
else
    meancurve_pre.long.mua = [];
end
meancurve_pre.long.deep = PlotRipRaw(LFPdeep, sort(long_deltas), 500, 0, 0); close

nb_delta_pre.short = length(short_deltas);
nb_delta_pre.long = length(long_deltas);
nb_delta_pre.all = nb_deltas;

%%  post

if ~exist('LFPsup','var')
    %LFP sup
    load('DeltaWaves.mat', 'deltas_Info_post')
    if ~isnan(deltas_Info_post.channel_sup)
        load(['LFPData/LFP' num2str(deltas_Info_post.channel_sup)],'LFP')
        LFPsup=LFP;
        clear LFP channel
    else
        LFPsup=[];
    end
end

if ~exist('LFPdeep','var')
    load('DeltaWaves.mat', 'deltas_Info_post')
    load(['LFPData/LFP' num2str(deltas_Info_post.channel_deep)],'LFP')
    LFPdeep=LFP;
    clear LFP channel
end

%% data
load('DeltaWaves.mat', 'deltas_post')
%delta data
deltas_tmp = (Start(deltas_post) + End(deltas_post)) / 2e4;
delta_duration = End(deltas_post) - Start(deltas_post);
nb_deltas = length(deltas_tmp);
%shortest and largest
[~, idx_delta_sorted] = sort(delta_duration,'ascend');
halfsize = min(floor(nb_deltas/2), 500);
short_deltas = deltas_tmp(idx_delta_sorted(1:halfsize));
long_deltas = deltas_tmp(idx_delta_sorted(end-halfsize+1:end));


%% Mean curves
% short deltas
if ~isempty(LFPsup)
    meancurve_post.short.sup = PlotRipRaw(LFPsup, sort(short_deltas), 500, 0, 0); close
else
    meancurve_post.short.sup = [];
end    
if not(isempty(MUA))
    meancurve_post.short.mua = PlotRipRaw(MUA, sort(short_deltas), 500, 0, 0); close
else
    meancurve_post.short.mua = [];
end
meancurve_post.short.deep = PlotRipRaw(LFPdeep, sort(short_deltas), 500, 0, 0); close

% long deltas
if ~isempty(LFPsup)
    meancurve_post.long.sup = PlotRipRaw(LFPsup, sort(long_deltas), 500, 0, 0); close
else
    meancurve_post.long.sup = [];
end
if not(isempty(MUA))
    meancurve_post.long.mua = PlotRipRaw(MUA, sort(long_deltas), 500, 0, 0); close
else
    meancurve_post.long.mua = [];
end
meancurve_post.long.deep = PlotRipRaw(LFPdeep, sort(long_deltas), 500, 0, 0); close

nb_delta_post.short = length(short_deltas);
nb_delta_post.long = length(long_deltas);
nb_delta_post.all = nb_deltas;
end












