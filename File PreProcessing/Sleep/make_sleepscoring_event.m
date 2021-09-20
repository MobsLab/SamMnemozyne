function make_sleepscoring_event 
try
    load('SleepScoring_OBGamma.mat','sleep_array');
catch
    load('SleepScoring_Accelero.mat','sleep_array');
end
    
if ~exist('sleep_array','var')
    make_sleepscoringarray
end

% reduce number of offline scoring input to 1 per second
ss=[];
sleep_array(isnan(sleep_array))=0;
ii=1;
for iss=1:10020:length(sleep_array)
    if length(sleep_array)<iss+10020
        en = iss+(length(sleep_array)-iss);
    else
        en = iss+10020;
    end
    x = sleep_array(iss:en); 
    if unique(x)==0
        ss(ii) = 0;
    else
        [a,b]=hist(x,unique(x));
        [M,id] = max(a);
        ss(ii) = b(id);
    end
    clear a b id
    ii=ii+1;
end

% prepare data for event file
for i=1:length(ss)
    switch ss(i)
        case 1
            evt.description{i} = 'NREM';
        case 2
            evt.description{i} = 'REM';
        case 3
            evt.description{i} = 'Wake';
        case 0
            evt.description{i} = 'Undefined';
    end
    evt.time(i) = i-1;
end

%evt classic
extens = 'ssc';
% delete([Info.EventFileName '.evt.' extens]);
CreateEvent(evt, 'SleepScoring', extens);
end