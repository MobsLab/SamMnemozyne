function [cycleEpoch remepoch] = get_sleepcycles_study(sEpoch,sSession,params)
%
%
% Input:
%           sEpoch      Intervalset of sleep stages (run get_SleepEpoch before)
%           sSession    Intervalset of start en end of whole session(s) (run get_SleepEpoch before)
%           tmerge      format: [x1 x2]
%                       x1 = time in seconds to merge rem
%                       x2 = time in seconds to drop short rem epochs
%
% Output:
%           cycleEpoch  intervalSet of defined cycles (end-of-rem to end-of-rem)
%                       This version keeps long wake period into cycles.
%
% See wakebycycle.m
%
% Written by S. Laventure - 2022-03

% get sleep cycle (rem end-to-end)
for ilen=1:size(params,2)
    for isess=1:size(sEpoch,1)
        % restrict to session
        rem = and(sEpoch{isess,2},sSession{isess});
        if params(1,ilen) && params(2,ilen)
            % merge rem
            remepoch_tmp = mergeCloseIntervals(rem,params(1,ilen)*1e4);
            % drop rem 
            remepoch{ilen}{isess} = dropShortIntervals(remepoch_tmp,params(2,ilen)*1e4);
        else
            remepoch{ilen}{isess} = rem;
        end
        endREM = End(remepoch{ilen}{isess});
        stSleep = Start(sSession{isess});
        for irem=1:length(endREM)
            if irem==1
                cycleEpoch{ilen}{isess}{irem} = intervalSet(stSleep(1),endREM(1)); 
            else
                cycleEpoch{ilen}{isess}{irem} = intervalSet(endREM(irem-1),endREM(irem)); 
            end
        end
        clear endREM stSleep
    end
end