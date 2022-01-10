
function saveF(H,figName,dirPath,varargin)

%==========================================================================
% Details:  Saves figure from handle in different formats (can be save 
%           simultaneously in multiple formats). Can also save to
%           the Matlab .fig format if option savfig is set to 1 
%           (default: 0). 
%
% INPUTS:
%   
%       - H             Handle of figure
%       - figName       Figure name (string)
%       - dirPath       Directory where to save figure
%       
%   Options:
%       - sformat       Format in which to save figure. Several can be
%                       called at the same time. Must be in cell array.
%                       ex: {'djpeg','dpdf','deps','dpng'} 
%                       see Matlab print fonction for all possible formats  
%                           -default: dpng
%       - res           Resolution of saved file                            -default: 300
%       - savfig        Saving in .fig format                               -default: 0
%
% NOTES:
%   Written by S. Laventure 2020-12
%      
%==========================================================================
% Parse parameter list
for i = 1:2:length(varargin)
	if ~ischar(varargin{i})
		error(['Parameter ' num2str(i+2) ' is not a property (type ''help <a href="matlab:help malepretty_erc">makepretty_erc</a>'' for details).']);
	end
	switch(lower(varargin{i}))
        case 'sformat'
            sformat =  varargin{i+1};
            if ~ischar(sformat{1})
				error('Incorrect value for property ''sformat''');
            end
        case 'res'
            res =  varargin{i+1};
            if ~isnumeric(res)
				error('Incorrect value for property ''res''');
            end 
        case 'savfig'
            savfig =  varargin{i+1};
            if ~savfig==0 && ~savfig==1
				error('Incorrect value for property ''savfig''');
            end 
    end    
end
%Default values 
if ~exist('sformat','var')
    sformat = {'dpng'};
end
if ~exist('res','var')
    res = 300;
end
if ~exist('savfig','var')
    savfig = 0;
end

% create directory if doesn't exist and set permissions
if ~exist(dirPath, 'dir')
    mkdir(dirPath);
%     if ismac
%         disp('Creating folder (mac version)');
%     elseif isunix
%         disp('Creating folder (linux version)');
%         system(['sudo chown mobs /' dirPath]);
%     else
%         disp('Creating folder (pc version)');
%     end
end

% saving
set(H,'paperPositionMode','auto')
for i=1:length(sformat)
    print(H,[dirPath figName], ['-' sformat{i}], ['-r' num2str(res)]);
end
% saving in .fig format 
if savfig
    saveas(H,[dirPath figName],'fig');
end

% special case for Matlab on Linux using in root 
if isunix
    system(['sudo chown -R hobbes /' dirPath]);
end
end

