function [id_sess tdat dat] = RestrictSession(workpath,session,varargin)


%==========================================================================
% Details: find and output a called session ID in the behavResources structure
%
% INPUTS:
%       - workpath: directories list from PathForExperiment (cell,string)
%       - session: the session name (string)
%       - varargin:
%               - measure: variable of interest in behavResources in behavResources.mat (could be modify for other variables)
%               - ntrial:  number of trial with the same name (default 1; must be >= 1)
%
% OUTPUT:
%       - id_sess: position (order) of the session within behavResources variable (num) 
%       - tdat: Timepoints from this session in Interval Set (cell - 1 per directories). 
%       - dat: Actual data from behavResources IF asked by 'measure' (format: cell{mouse,trial})
%          
%
% NOTES: 
%
%   Written by Samuel Laventure - 10-11-2019
%      
%==========================================================================


% Parse parameter list
cmeasure = 0;  % checked if session
for i = 1:2:length(varargin)
    if ~ischar(varargin{i})
        error(['Parameter ' num2str(i+2) ' is not a property.']);
    end
    switch(lower(varargin{i}))
        case 'measure'
            measure = varargin{i+1};
            cmeasure = 1;
            if ~ischar(measure)
                error('Incorrect value for property ''measure''. Measure must be a string.');            
            end
         case 'ntrial'
            ntrial = varargin{i+1};
            if ~ntrial==1 || ~ntrial==0
                error('Incorrect value for property ''ntrial''.');            
            end
        otherwise
            error(['Unknown property ''' num2str(varargin{i}) '''.']);
    end
end


%#####################################################################
%#
%#                           M A I N
%#
%#####################################################################


%% Get behavResources and timepoints
for isuj = 1:length(workpath.path)
    disp(['Working on subject ' num2str(isuj)])
    disp('   .loading behavResources')
    behav{isuj} = load([workpath.path{isuj}{1} 'behavResources.mat'], 'behavResources','SessionEpoch');
    
    % Get timepoints (interval set)
    if isfield(behav{isuj}.SessionEpoch,session)
        disp('   .extracting timepoints')
        tdat{isuj} = extractfield(behav{isuj}.SessionEpoch,session);
    else
        error([session ' is not a valid session name for this expirement.']); 
    end
    
    % Get position of session
    id_sess{isuj} = find_sessionid(behav{isuj}, session);

    % Get behav data
    if cmeasure
        disp('   .extracting behavioral data')
        if isfield(behav{isuj}.behavResources(id_sess{isuj}{1}),measure)
            dat{isuj,1} = extractfield(behav{isuj}.behavResources(id_sess{isuj}{1}),measure);
        elseif isfield(behav{isuj}.behavResources(id_sess{isuj}),[measure num2str(ntrial)]) %check if the last increment of this session exist
            for itrial=1:ntrial
                if isfield(behav{isuj}.behavResources(id_sess{isuj}),[measure num2str(itrial)])
                    dat{isuj,itrial} = extractfield(behav{isuj}.behavResources(id_sess{isuj}),[measure num2str(itrial)]);
                else
                    error(['Incrementation not valid for this session.']);
                end
            end
        else
            error([measure ' is not a valid measure name (in behavResources var) for this expirement.']); 
        end
    end    
end
disp('Done! Carry on.')



