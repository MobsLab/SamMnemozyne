function spkrip_dist(Dir)
%==========================================================================
% Details: Detect and output ripples (figure and .mat file) of all sites on all spike groups
%
% INPUTS:
%       - Dir: working directory
%
% OUTPUT:
%
% NOTES:
%
%   Written by Samuel Laventure - 16-07-2020
%      
%==========================================================================

%% Set Directory
try
   Dir;
catch
   Dir =  [pwd '/'];
end


%%
%#####################################################################
%#
%#                           M A I N
%#
%#####################################################################

% set directory and variables
cd(Dir);
load('ExpeInfo.mat');
load('SpikeData.mat');
sgr = ExpeInfo.SpikeGroupInfo.ChanNames;
sgr_nb = length(sgr);

for isgr=1:sgr_nb
    nsgr = str2num(sgr{isgr});
    for isite=1:length(nsgr)
        ripFile = ['RipplesspkGr' num2str(isgr) '_' num2str(isite) '.mat'];
        load(ripFile,'ripples');
        dist{isgr,isite}=[];
        cluid = find(contains(cellnames,['TT' num2str(isgr)]));
        for irip=1:length(ripples)
            for iclu=1:length(cluid)
                spkpos = Range(S{cluid(iclu)});
                spkid = find((spkpos>(ripples(irip,2)-1)*1e4) & (spkpos<(ripples(irip,2)+1)*1e4));
                if spkid
                    for isp=1:length(spkid)
                        dist{isgr,isite}(end+1) = spkpos(spkid(isp))-(ripples(irip,2)*1e4);
                    end
                end
                clear spkpos spkid
            end
        end
        clear ripples
    end
end

%% 
%#####################################################################
%#
%#                        F IG U R E S
%#
%#####################################################################
for isgr=1:sgr_nb
    nsgr = str2num(sgr{isgr});
    supertit = ['Spikes distance from ripples for Spike Group #' num2str(isgr)];
    figure2(1,'Color',[1 1 1], 'rend','painters','pos',[1 1 500 1000],'Name', supertit, 'NumberTitle','off')
        for isite=1:length(nsgr)
            subplot(length(nsgr),1,isite)
                hist(dist{isgr,isite},1000)
                title(['Derivation #' num2str(isite)]) 
                if isite==length(nsgr)
                    xlabel('time centered on ripple (1e4)')             
                end
        end  
        % save figure
        print(['spkrip_distance_SpkGr' num2str(isgr)], '-dpng', '-r300');
end


disp('completed')