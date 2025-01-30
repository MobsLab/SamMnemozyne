function [sleepcycle] = sleepcycle_study(Dir, expe, mice_num, varargin)

%==========================================================================
% Details: sleep cycle study 
%
% INPUTS:
%       - Dir               includes all directories for each experiment
%                           Format:
%                           Dir{<exp1>,<exp2>}.path{<mouse1>},{<mouse2a>,<mouse2b>},{<mouse3>},
%                           ...}
%       - expe              Name of experiment in PathForExperiment
%                           Format:
%                               expe = {'ExpeName1','ExpeName2'};
%       - mice_num          ID # of all mice for the analyses
%                           Format:
%                               mice_num = {[mouse1 mouse2 mouse3],[mouse1 mouse2]};
% OPTIONAL:
%       - remparams         times for cycle definition.
%                           time 1: merge REM intervals (in seconds)
%                           time 2: drop REM intervals (in seconds)
%                           Format: [timeMERGE timeDROP]
%
% OUTPUT:
%       -figH               Figures handles (for saving)
%       -wake               Global strutures with all variables
%
% NOTES: none
%
%   Written by Samuel Laventure - 2022-03
%      
%==========================================================================

% parsing varargin
for i = 1:2:length(varargin)
    if ~ischar(varargin{i})
        error(['Parameter ' num2str(i+2) ' is not a property.']);
    end
    switch(lower(varargin{i}))
        case 'remparams'
            remparams = varargin{i+1};
            if ~(length(remparams)==2)
                error('remparams needs 2 parameters: [TimeMergeREM TimeDropREM].');
            end
        case 'plotfig'
            plotfig = varargin{i+1};
            if ~(plotfig==1) && ~(plotfig==0)
                error('plotfig argument should be either 0 or 1');
            end
        otherwise
            error(['Unknown property ''' num2str(varargin{i}) '''.']);
    end
end

%check if exist and assign default value if not
% parameters to define cycles
if ~exist('remparams','var')
    remparams = [0 0];
end
if ~exist('plotfig','var')
    plotfig = 1;
end

% get experiment names
for iexp=1:length(expe)
    switch expe{iexp}
        case 'StimMFBWake'
            expname{iexp}='MFB';
        case 'Novel'
            expname{iexp}='Novel';
        case 'UMazePAG'
            expname{iexp}='PAG';
        case 'Known'
            expname{iexp}='Known';
        case 'BaselineSleep'
            expname{iexp}='BaselineSleep';
        otherwise
            expname{iexp}=expe{iexp};
    end
end

% var init
stageName = {'NREM','REM','Wake'};
colori = {[0 0 .8], [.8 0 0], [0 0 0]}; % for hypnogram

%%
%#####################################################################
%#                           M  A  I  N
%#####################################################################

for iexp=1:length(expe)
    disp(['   Experiment: ' expname{iexp}])
    disp('     Getting data for:')
    nsuj=0;
    for isuj = 1:length(Dir{iexp}.path)
        for iisuj=1:length(Dir{iexp}.path{isuj})
            nsuj=nsuj+1;
            disp(['            M' num2str(mice_num{iexp}(nsuj))])
            
            % get sleep epoch by stage
            % from "get_SleepEpoch" but with noise
            try
                load([Dir{iexp}.path{isuj}{iisuj} 'SleepScoring_OBGamma.mat'], ...
                    'WakeWiNoise', 'SWSEpochWiNoise', 'REMEpochWiNoise','Epoch');
            catch
                load([Dir{iexp}.path{isuj}{iisuj} 'SleepScoring_Accelero.mat'], ...
                    'WakeWiNoise', 'SWSEpochWiNoise', 'REMEpochWiNoise','Epoch');
            end 
            tmpEpoch{1} = SWSEpochWiNoise;                   % nrem
            tmpEpoch{2} = REMEpochWiNoise;                   % rem
            tmpEpoch{3} = WakeWiNoise;                       % wake
            clear WakeWiNoise SWSEpochWiNoise REMEpochWiNoise

            % seperate session pre vs post if there are any
            try  % try, because some don't have behavResources. If not there it is considered that there is no pre/post session
                load([Dir{iexp}.path{isuj}{iisuj} 'behavResources.mat'], 'SessionEpoch'); 
            end
            if exist('SessionEpoch','var') % if doesnt exist then it is a Baseline session
                try
                    SleepEpochs.pre = SessionEpoch.PreSleep;
                catch
                    SleepEpochs.pre = SessionEpoch.Baseline;
                end
                SleepEpochs.post = SessionEpoch.PostSleep;

                % restrict to pre/post sessions
                for istage=1:3
                    sEpoch{1,istage} = and(tmpEpoch{istage},SleepEpochs.pre);     
                    sEpoch{2,istage} = and(tmpEpoch{istage},SleepEpochs.post);    
                end
                sSession{1} = SleepEpochs.pre;
                sSession{2} = SleepEpochs.post;
                nsess=2;
            else
                for istage=1:3
                    sEpoch{1,istage} = tmpEpoch{istage};
                end
                st = Start(Epoch); en = End(Epoch);
                sSession{1} = intervalSet(st(1),en(end));
                nsess=1;
            end   

            disp('Done.')
            disp('-------------------')
            disp('Prep data for figure')

            % get sleep cycles
            [cycleEpoch remepoch] = get_sleepcycles_study(sEpoch,sSession,remparams);
            
            % merged rem duration 
            for isess=1:nsess
                st = Start(remepoch{isess});
                en = End(remepoch{isess});
                for icyc=1:length(cycleEpoch{isess})
                    remdur{isess,icyc} = (en(icyc)-st(icyc))/1e4;
                end
                clear st en
            end

            % store data
            sleepcycle.cycleEpoch{iexp,nsuj} = cycleEpoch;   
            sleepcycle.remdur{iexp,nsuj} = remdur;     
            sleepcycle.sEpoch{iexp,nsuj} = sEpoch;
            sleepcycle.sSession{iexp,nsuj} = sSession;
            sleepcycle.info.exp = expe;
            sleepcycle.info.mice_num = mice_num;
            sleepcycle.info.remparams = remparams;
                
            
%             % Hypno data
%             for isess=1:nsess
%                 allepochs{isess} = {sEpoch{isess,1},sEpoch{isess,2},sEpoch{isess,3}};
%                 ep_tsd{isess} = CreateSleepStages_tsd(allepochs{isess});
%                 % set colors
%                 for icycle=1:length(cycleEpoch{isess})
%                     if ~(rem(icycle,2))
%                         colorCyc{isess,icycle} = [0 0 0];
%                     else
%                         colorCyc{isess,icycle} = [.5 .5 .5];
%                     end
%                 end
%             end
% 
%             % Measurments
%             for isess=1:nsess
%                 waketotdur{isess} = sum(ep_len{isess},2);
%                 for icycle=1:length(cycleEpoch{isess})
%                     nwake{isess}(icycle) = length(Start(wakeCycle{isess,icycle}));
%                 end
%             end
%             if nsess==2
%                 [a b] = waketotdur{:};
%                 [c d] = nwake{:};
%             else
%                 a = waketotdur{:}; b=[];
%                 c = nwake{:}; d=[];
%             end
%             xmax_totdur = max([a; b])+max([a; b])*.15;
%             xmax_nwake = max([c d])+max([c d])*.15;

            
            
%             wake.sEpoch{iexp,nsuj} = sEpoch;
%             wake.sSession{iexp,nsuj} = sSession;
%             wake.cycleEpoch{iexp,nsuj} = cycleEpoch;
%             wake.wakeCycles{iexp,nsuj} = wakeCycle;  
%             wake.waketotdur{iexp,nsuj} = waketotdur;
%             wake.nwake{iexp,nsuj} = nwake;
%             wake.ep_len{iexp,nsuj} = ep_len;
%             wake.info.exp = expe;
%             wake.info.mice_num = mice_num;
%             wake.info.remparams = remparams;

   
            clear cycleEpoch sEpoch sSession remdur remepoch
        end
    end
end

disp(' ')
disp('Done')


    

