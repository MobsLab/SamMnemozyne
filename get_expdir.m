function Dir = get_expdir(expe,mice_num)

%==========================================================================
% Details: get directories from PathForExperiment(s)
%
% INPUTS:
%       - expe              Name of experiment in PathForExperiment
%                           Format:
%                               expe = {'ExpeName1','ExpeName2'};
%       - mice_num          ID # of all mice for the analyses
%                           Format:
%                               mice_num = {[mouse1 mouse2 mouse3],[mouse1 mouse2]};
%
% OUTPUT:
%       - Dir               includes all directories for each experiment
%                           Format:
%                           Dir{<exp1>,<exp2>}.path{<mouse1>},{<mouse2a>,<mouse2b>},{<mouse3>},
%                           ...}
%
% NOTES:
%
%   Written by Samuel Laventure - 2022-03
%      
%==========================================================================

%% Parameters
for iexp=1:length(expe)
    switch expe{iexp}
        case 'StimMFBWake'
            erc=1;
        case 'Novel'
            erc=1;
        case 'UMazePAG'
            erc=1;
        case 'Known'
            erc=1;
        case 'BaselineSleep'
            erc=1;
        otherwise
            erc=0;
    end
    if erc
        Dir{iexp} = PathForExperimentsERC(expe{iexp});
    else
        Dir{iexp} = PathForExperiments_Opto_MC(expe{iexp});  % Mathilde's expe (temporary)
    end
    Dir{iexp} = RestrictPathForExperiment(Dir{iexp}, 'nMice', unique(mice_num{iexp}));
end
