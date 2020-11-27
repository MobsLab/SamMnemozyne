function SaveEvents_SL(filename,event,channelID,evName,varargin)

%SaveEvents_SL - 
%
%  USAGE
%
%    SaveEvents(filename,events,channelID,evName,options)
%    Call example: SaveEvents_SL('detection_events.evt.det',DetectedArray'/1e4,33,'Detect','overwrite','on')
%
%    filename       file to save to
%    event        event in seconds
%    channelID      channel ID (appended to the event description)
%    evName         Name of the events
%    <options>      optional list of property-value pairs (see table below)
%
%    =========================================================================
%     Properties    Values
%    -------------------------------------------------------------------------
%     'overwrite'   overwrite file if it exists (default = 'off')
%    =========================================================================
%
%  SEE
%
%    See also Findevents, eventstats, Ploteventstats, SaveEvents.

% Copyright (C) 2004-2015 by Michaël Zugaro
% Modified by S. laventure 07-2020
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.

% Default values
overwrite = 'off';

if nargin < 3,
  error('Incorrect number of parameters (type ''help <a href="matlab:help SaveRippleEvents">SaveRippleEvents</a>'' for details).');
end

for i = 1:2:length(varargin),
	if ~ischar(varargin{i}),
		error(['Parameter ' num2str(i+2) ' is not a property (type ''help <a href="matlab:help SaveRippleEvents">SaveRippleEvents</a>'' for details).']);
	end
	switch(lower(varargin{i})),
		case 'overwrite',
			overwrite = varargin{i+1};
			if ~isastring(overwrite,'on','off'),
				error('Incorrect value for property ''overwrite'' (type ''help <a href="matlab:help SaveRippleEvents">SaveRippleEvents</a>'' for details).');
			end
		otherwise,
			error(['Unknown property ''' num2str(varargin{i}) ''' (type ''help <a href="matlab:help SaveRippleEvents">SaveRippleEvents</a>'' for details).']);
	end
end

n = size(event,1);
r = event(:,1)';
events.time = r;
for i = 1:3*n,
	events.description{i,1} = [evName ' ' int2str(channelID)];
end

if strcmp('overwrite','on'),
    SaveEvents(filename,events,'overwrite','on');
else
    SaveEvents(filename,events);
end
