function sam_sleeparch_comp(expe,idMice)

%==========================================================================
% Details: 
%
% INPUTS:
%       - 
%
% OUTPUT:
%       - figures including:
%          
%
% NOTES: 
%       
%      
%
%
%   Written by Samuel Laventure - 12-10-2019
%      
%==========================================================================

%% Parameters
% Directory to save and name of the figure to save
% dir_out = '/home/mobs/Dropbox/DataSL/StimMFBWake/sleep_architecture/';
dir_out = [dropbox '/DataSL/StimMFBWake/sleep_architecture/' date '/'];

% Numbers of mice to run analysis on
% idMice = [882 941]; % MFBStimWake
% idMice = [117]; % FirstExploNew


% Get directories
Dir = PathForExperimentsERC(expe);
% Dir = PathForExperimentsERC_SL('Reversal');
Dir = RestrictPathForExperiment(Dir,'nMice', idMice);

%set folders
% [parentdir,~,~]=fileparts(pwd);
% dir_out = [pwd '/Figures/'];
if ~exist(dir_out,'dir')
    mkdir(dir_out);
end

ss = {'SWS','REM','WAKE'};
ss_real = {'NREM','REM','WAKE'};
sav = 1;
% set text format
set(0,'defaulttextinterpreter','latex');
set(0,'DefaultTextFontname', 'Arial')
set(0,'DefaultAxesFontName', 'Arial')
set(0,'defaultTextFontSize',12)
set(0,'defaultAxesFontSize',12)


%#####################################################################
%#
%#                           M A I N
%#
%#####################################################################

for i = 1:length(Dir.path)
    disp(['--- Processing mouse #' num2str(idMice(i)) '...']);
    %% Get Data
    % load working variables
    Session{i} = load([Dir.path{i}{1} 'behavResources.mat'], 'SessionEpoch');
    try
        Sleep{i} = load([Dir.path{i}{1} 'SleepScoring_OBGamma.mat'],'Wake','SWSEpoch','REMEpoch');
        disp('Loading OBGamma...');
    catch
        disp('No OBGamma, loading Accelero...');
        Sleep{i} = load([Dir.path{i}{1} 'SleepScoring_Accelero.mat'],'Wake','SWSEpoch','REMEpoch');
    end
    
    %% Find indices of PreTests and PostTest session in the structure
    
%     id_pre = find_sessionid(Session{i}, 'BaselineSleep');
%     id_post = find_sessionid(Session{i}, 'PostSleep');
    try
        presleep = Session{i}.SessionEpoch.BaselineSleep;
    catch
        presleep = Session{i}.SessionEpoch.PreSleep;
    end
    
    pre_wake{i} = and(presleep, Sleep{i}.Wake);
    post_wake{i} = and(Session{i}.SessionEpoch.PostSleep, Sleep{i}.Wake);
    pre_nrem{i} = and(presleep, Sleep{i}.SWSEpoch);
    post_nrem{i} = and(Session{i}.SessionEpoch.PostSleep, Sleep{i}.SWSEpoch);
    pre_rem{i} = and(presleep, Sleep{i}.REMEpoch);
    post_rem{i} = and(Session{i}.SessionEpoch.PostSleep, Sleep{i}.REMEpoch);
    
    % stages duration%
    pre_wake_tot(i) = sum(End(pre_wake{i})-Start(pre_wake{i}));
    post_wake_tot(i) = sum(End(post_wake{i})-Start(post_wake{i}));
    pre_nrem_tot(i) = sum(End(pre_nrem{i})-Start(pre_nrem{i}));
    post_nrem_tot(i) = sum(End(post_nrem{i})-Start(post_nrem{i}));
    pre_rem_tot(i) = sum(End(pre_rem{i})-Start(pre_rem{i}));
    post_rem_tot(i) = sum(End(post_rem{i})-Start(post_rem{i}));
    
    
    % calculate total duration
    pre_tot(i) = End(presleep)-Start(presleep);
    post_tot(i) = End(Session{i}.SessionEpoch.PostSleep)-Start(Session{i}.SessionEpoch.PostSleep);
    
    %stage percentage
    pre_wake_perc(i) = pre_wake_tot(i)/pre_tot(i)*100;
    post_wake_perc(i) = post_wake_tot(i)/post_tot(i)*100;
    pre_nrem_perc(i) = pre_nrem_tot(i)/pre_tot(i)*100;
    post_nrem_perc(i) = post_nrem_tot(i)/post_tot(i)*100;
    pre_rem_perc(i) = pre_rem_tot(i)/pre_tot(i)*100;
    post_rem_perc(i) = post_rem_tot(i)/post_tot(i)*100;
    
    
end %loop mouse

supertit = 'Sleep stages percentage during sessions';
figure('Color',[1 1 1], 'rend','painters','pos',[1 1 1600 400],'Name', supertit, 'NumberTitle','off')
    sgt = sgtitle(['Mouse ' num2str(idMice(i))],'FontSize', 24);   
    subplot(1,3,1)
        [~,h,her] = PlotErrorBarN_SL([pre_wake_perc' post_wake_perc'],...
                         'barwidth', 0.6, 'newfig', 0,...
                        'colorpoints',1,'barcolors',[.3 .3 .3]);
            h.FaceColor = 'flat';
            h.CData(1,:) = [0 0 0]; h.CData(2,:) = [1 1 1];
        %ylim([0 maxy_all+.15*maxy_all]);
        set(gca,'Xtick',[1:2],'XtickLabel',{'PreSleep', 'PostSleep'});
        set(gca, 'FontSize', 14);
        h.FaceColor = 'flat';
        set(h, 'LineWidth', 2);
        set(her, 'LineWidth', 2);
        ylabel('%');
        title('WAKE', 'FontSize', 18);

    subplot(1,3,2)
        [~,h, her] = PlotErrorBarN_SL([pre_nrem_perc' post_nrem_perc'],...
                        'barwidth', 0.6, 'newfig', 0,...
                        'colorpoints',1,'barcolors',[.3 .3 .3]);
            h.FaceColor = 'flat';
            h.CData(1,:) = [0 0 0]; h.CData(2,:) = [1 1 1];
        %ylim([0 maxy_all+.15*maxy_all]);
        set(gca,'Xtick',[1:2],'XtickLabel',{'PreSleep', 'PostSleep'});
        set(gca, 'FontSize', 14);
        h.FaceColor = 'flat';
        set(h, 'LineWidth', 2);
        set(her, 'LineWidth', 2);
        ylabel('%');
        title('NREM', 'FontSize', 18);
        
    subplot(1,3,3)
        [~,h, her] = PlotErrorBarN_SL([pre_rem_perc' post_rem_perc'],...
                        'barwidth', 0.6, 'newfig', 0,...
                        'colorpoints',1,'barcolors',[.3 .3 .3]);
            h.FaceColor = 'flat';
            h.CData(1,:) = [0 0 0]; h.CData(2,:) = [1 1 1];
        %ylim([0 maxy_all+.15*maxy_all]);
        set(gca,'Xtick',[1:2],'XtickLabel',{'PreSleep', 'PostSleep'});
        set(gca, 'FontSize', 14);
        h.FaceColor = 'flat';
        set(h, 'LineWidth', 2);
        set(her, 'LineWidth', 2);
        ylabel('%');
        title('REM', 'FontSize', 18);
        
        %save figure
        print([dir_out 'sleeparch_comp'], '-dpng', '-r300');
    %     close(f);

    %save data
    save([dir_out 'sleeparch_comp'],'pre_wake_perc','post_wake_perc', ...
        'pre_nrem_perc','post_nrem_perc','pre_rem_perc','post_rem_perc');

    