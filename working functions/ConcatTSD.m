function [concatdata] = ConcatTSD(tsddata)
%==========================================================================
% Details: Concatenate TSDs 
%
% INPUTS:
%       - tsddata: series of TSD in {'tsd1','tsd2',...} format
%
% OUTPUT:
%       - concatdata: TSD
%
% NOTES:  CHECK IF WORKING
%
%   Written by Samuel Laventure - 27-02-2020
%      
%==========================================================================

for i=1:length(tsddata) 
    TimeTemp{i} = Range(tsddata{i});
    DataTemp{i} = Data(tsddata{i});
end
for i=1:(length(tsddata)-1)
    TimeTemp{i+1} = TimeTemp{i+1};
end
for i = 1:length(tsddata)
    concatdata = tsd(TimeTemp{i}, DataTemp{i});
end

% % Concatenate Imdifftsd (type single tsd)
% for i=1:length(FilesList) % Tsd, with differences in pixels between mask and a frame in Data
%     ImdifftsdTimeTemp{i} = Range(a{i}.Imdifftsd);
%     ImdifftsdDataTemp{i} = Data(a{i}.Imdifftsd);
% end
% for i=1:(length(FilesList)-1)
%     ImdifftsdTimeTemp{i+1} = ImdifftsdTimeTemp{i+1};
% end
% for i = 1:length(FilesList)
%     behavResources(i).Imdifftsd = tsd(ImdifftsdTimeTemp{i}, ImdifftsdDataTemp{i});
% end
% clear ImdifftsdTimeTemp ImdifftsdDataTemp

end