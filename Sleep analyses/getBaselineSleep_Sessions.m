function SleepEpochs = getBaselineSleep_Sessions(dir,len)

%==========================================================================
% Details: get sleep sessions pre and post of full day recording based on 
%           duration given
%
% INPUTS:
%       - dir               mouse directory (string)
%       - len               duration of sessions in sec
%
% OUTPUT:
%       - SleepEpochs       IntervalSet of pre and post sessions
%
% NOTES:
%
%   Written by Samuel Laventure - 2020-12
%      
%==========================================================================
% load real rec time
load([dir 'TimeRec.mat'], 'TimeBeginRec','TimeEndRec');
% create pre-sleep segment
starttime = 1e4;
tdatpre{1}{1} = intervalSet(starttime,starttime+len*1e4);
% create post-sleep segment 
t1={[num2str(TimeBeginRec(1)) ':' num2str(TimeBeginRec(2)) ':' num2str(TimeBeginRec(3))]};
t2={'15:00:00'};
poststart = seconds(diff(datetime([t1;t2])))*1e4;
postend = poststart+(len*1e4);
tdatpost{1}{1} = intervalSet(poststart,postend);   
%check length
clear t2
t2={[num2str(TimeEndRec(1)) ':' num2str(TimeEndRec(2)) ':' num2str(TimeEndRec(3))]};
totdur = seconds(diff(datetime([t1;t2])))*1e4;
if totdur<postend
    disp('PostSleep session end happens after the end of the session.' );
    disp('Check your times and/or change the start of the post sleep session in the script');
    return
else
    SleepEpochs.pre = tdatpre{1}{1};
    SleepEpochs.post = tdatpost{1}{1};
end


