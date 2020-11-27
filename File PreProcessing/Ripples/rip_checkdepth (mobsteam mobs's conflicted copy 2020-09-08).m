function rip_checkdepth(Dir)
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
%% Set Directories and variables
try
   Dir;
catch
   Dir =  [pwd '/'];
end
cd(Dir);

dir_out = [pwd '/ripples/'];
if ~exist(dir_out,'dir')
    mkdir(dir_out);
end

% load variables
load('ExpeInfo.mat');

% set shank channel order
gr{1} = [5 19 16 17 9 6 20 21 18 10 7 25 22 23 11];
gr{2} = [59 45 46 47 55 56 42 44 52 57 39 40 41 53];	
gr{3} = [37 38 50 61 60 34 35 48 51 62 63 33 30 32];	
gr{4} = [26 27 24 12 3 2 28 29 14 13 0 1 31 15 49];

% set best ripple channel per shank
rip_chan = [20 57 48 2];
rip_best = 2;

% Table des matière
ripdet = 1;   % if need to do basic ripple detection on main channel

%#####################################################################
%#
%#                           M A I N
%#
%#####################################################################

% set channel with good ripples
nonrip_chan = load('ChannelsToAnalyse/PFCx_deep.mat');

if ripdet
    for igr=1:length(rip_chan)
        % detect ripples
        [ripples{igr},stdev] = FindRipples_DB(rip_best,nonrip_chan.channel,...
                    [2 7],'rmvnoise',0, 'clean',1); % [2 7],'rmvnoise',1, 'clean',1);
    end
    save('Ripples_SpkGrp.mat','ripples')
else
    load('Ripples.mat')
end

% get average signal on all other channels
for igr=1:length(gr)
    disp(['Processing spike group #' num2str(igr)])
    for ichan=1:length(gr{igr})
        disp(['....processing channel #' num2str(ichan)])
        load([pwd '/LFPData/LFP' num2str(gr{igr}(ichan)) '.mat']);
        for irip=1:length(ripples{igr})
            ripwin = intervalSet(ripples{igr}(irip,2)*1e4-500,ripples{igr}(irip,2)*1e4+1300);
            riptsd = Restrict(LFP,ripwin);
            riptmp(irip,1:length(Data(riptsd))) = Data(riptsd);
        end
        clear LFP
        ripmean(igr,ichan,1:size(riptmp,2)) = squeeze(mean(riptmp));
    end
end

ripmean = permute(ripmean,[3,1,2]);

% set main ripples chan
for igr=1:length(gr)
    main(igr) = find(gr{igr}==rip_chan(igr));
end
% save data
save('ripmean.mat','ripmean');

%#####################################################################
%#                      F I G U R E S
%#####################################################################
colorbase = [0 0 0];
supertit = ['Averaged ripples'];
figure2(1,'Color',[1 1 1], 'rend','painters','pos',[1 1 700 1000],'Name', supertit, 'NumberTitle','off')
    for igr=1:length(gr)
        subplot(length(gr),1,igr)
            for ichan=1:length(gr{igr})
                plot(ripmean(:,igr,ichan),'color',(colorbase + (ichan*4/100)))
                ylim([-6000 6000])
                xlim([1 size(ripmean,1)])
                set(gca,'Xtick',[1:25:size(ripmean,1)],'XTickLabel',num2cell(0:20:180))
                title(['Shank #' num2str(igr)]);
                hold on
            end
            plot(ripmean(:,igr,main(igr)),'r')
            if igr==length(gr)
                xlabel('Time (ms)')
            end
            hold off
    end
    % save figure
    print([dir_out 'spkrip_averaged_AllShanks'], '-dpng', '-r300');
    
disp('Completed');
end