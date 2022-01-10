function stgperc = cumulSleepScoring(Dir,binlen,varargin)
%==========================================================================
% Details: output cumulative percentage in specified time bins of sleep scoring 
%
% INPUTS:
%       - Dir       Working directory
%       - binlen    Bin size in Seconds 
%   OPTIONS
%       - epoch     intervalSet of Epoch to extract
%
% NOTES:
%
%   Written by Samuel Laventure - 2021/12
%      
%==========================================================================
% Parse parameter list
for i = 1:2:length(varargin)
    if ~ischar(varargin{i})
        error(['Parameter ' num2str(i+2) ' is not a property.']);
    end
    switch(lower(varargin{i}))
        case 'epoch'
            epoch = varargin{i+1};
    end
end
%check if exist and assign default value if not
if ~exist('epoch','var')
    epoch=[];
end

% param
binlen = binlen*1e4; %transform from seconds to 1E4 format

cd(Dir)

% load sleep array
try 
    load('SleepScoring_OBGamma.mat','sleep_array');
catch
    load('SleepScoring_Accelero.mat','sleep_array');
end
if ~exist('sleep_array','var')
    disp('creating sleep_array')
    make_sleepscoringarray
end

% set epoch 
if ~isempty(epoch)
    st = Start(epoch);
    en = End(epoch);
else
    st = 1;
    en = length(sleep_array);
end
work_array = sleep_array(st:en);

cum = zeros(2,1);
stgperc = nan(2,ceil(length(work_array)/binlen));

for itime=1:floor((en-st)/binlen)
    if itime*binlen+binlen<(en-st)
        val=mode(work_array(itime*binlen:itime*binlen+binlen));
    else
        val=mode(work_array(itime*binlen:end));
    end
    if ~isnan(val) && val~=3
        cum(val) = cum(val)+1;
    end
    stgperc(:,itime) = 100*bsxfun(@rdivide,cum,sum(cum,1));
%     if ~rem(itime,1000)
%         disp([num2str(itime) ' done.'])
%     end
end
clear sleep_array
