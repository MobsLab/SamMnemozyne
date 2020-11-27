function check_stimquality(varargin)

%==========================================================================
% Details: Verify the latency between stimulation and detection
%
% INPUTS:
%       - 
%
% OPTIONAL inputs:
%       - dropbox_save: specify location where to save the data in
%         in /home/mobs/Dropbox/MOBS_workingON/
%
% OUTPUT:
%       - figures including:
%           - latency (boxplot)
%
% NOTES:
%       
%
%   Written by Samuel Laventure - 30-06-2019
%      
%==========================================================================



clear all
% load working variables
load('LFPData/DigInfo3.mat');
load('DetectionTSD.mat');


%set folders
[parentdir,~,~]=fileparts(pwd);
pathOut = [pwd '/Figures/'];
if ~exist(pathOut,'dir')
    mkdir(pathOut);
end

% var init
outliers = [];
dbox=0;

% Parse parameter list
for i = 1:2:length(varargin)
    if ~ischar(varargin{i})
        error(['Parameter ' num2str(i+2) ' is not a property.']);
    end
    switch(lower(varargin{i}))
        case 'dropbox_save'
            dropbox_save = varargin{i+1};
            if ~ischar(dropbox_save)
                error('dropbox_save should be string (name of folder where to save data)');
            else
                dbox=1;
                pathDBox = ['/home/mobs/Dropbox/MOBS_workingON/' dropbox_save];
                if ~exist(pathDBox,'dir')
                    mkdir(pathDBox);
                end
            end

        otherwise
            error(['Unknown property ''' num2str(varargin{i}) '''.']);
    end
end

%% MAIN
% get stim information
StimSent = thresholdIntervals(DigTSD,0.99,'Direction','Above');
nbStim = length(Start(StimSent));
tStim = Start(StimSent);

% get detections info
Detect = thresholdIntervals(DetectionTSD,0.99,'Direction','Above');
Detect_start = Start(Detect);

for istim=1:nbStim
   id(istim) = find(Detect_start<tStim(istim),1,'last');
end

% get lag durations
spikestim = Detect_start(id);
deltastim = (((tStim - spikestim)/1e4)-.0007)*1e3;

% detecting outliers
outliers = find(deltastim>100);
if outliers
    deltastim_out(outliers) = deltastim(outliers)';
    deltastim(outliers) = [];
end

%% FIGURES
% figures
f = figure;
    boxplot(deltastim, 'Notch','off', 'Whisker', 1)
    xlabel('All stimulations')
    ylabel('Latency to stim (ms)')
    title('Latency from detection to stimultion')
    set(gca,'XTick',[]);
    a = get(get(gca,'children'),'children');
    set(a, 'Color', 'k'); 
    hold on
    x=ones(length(deltastim));
    f1 = scatter(x(:,1),deltastim(:,1),'k','filled');
    f1.MarkerFaceAlpha = 0.5;
    
    %annotation
    dim = [.6 .6 .3 .3];
    str = sprintf(['Mean latency: ' num2str(round(mean(deltastim)),2) ' ms' ...
                    '\nStd dev: ' num2str(round(std(deltastim)),2) ' ms']);
    annotation('textbox',dim,'String',str,'FitBoxToText','on');
    
    % script name at bottom
%     AddScriptName
    
    %save figure
    print([pathOut 'StimLatency'], '-dpng', '-r300');
    close(f);
    
%save data
save('LatencyStim.mat','deltastim','deltastim_out','tStim','spikestim','outliers');
end