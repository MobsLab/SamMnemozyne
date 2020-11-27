function [id] = find_sessionid(behav, sName)


%==========================================================================
% Details: find and output a called session ID in the behavResources structure
%
% INPUTS:
%       - behav: the behaResources variable
%       - sName: the session name
%
% OUTPUT:
%       - id: the session name position
%          
%
% NOTES: 
%
%   Written by Samuel Laventure - 12-10-2019
%      
%==========================================================================


%% Find indices session in the behavResources structure
id = cell(1,length(behav));

for i=1:length(behav)
    try
        id{i} = zeros(1,length(behav{1,1}.behavResources)); %2020-02-26 added {1,1}. If later it gives error implement a try/catch
    catch
        id{i} = zeros(1,length(behav.behavResources));
    end
    for k=1:length(behav.behavResources)
        if ~isempty(strfind(behav.behavResources(k).SessionName,sName))
            id{i}(k) = 1;
        end
    end
    id{i}=find(id{i});
end