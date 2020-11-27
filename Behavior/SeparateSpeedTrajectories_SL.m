%%% SeparateSpeedTrajectories_DB

%% Parameters
% Directory to save and name of the figure to save
dir_out = '/home/mobsrick/Dropbox/MOBS_workingON/Sam/StimMFBWake/';
fig_post = 'SpeedSeparation_SL';
% Before Vtsd correction == 1
old = 0;
sav = 0;

% Numbers of mice to run analysis on
Mice_to_analyze = [936 941 934 935 863 913]; % MFBStimWake

% Get directories
Dir = PathForExperimentsERC_SL('StimMFBWake');
Dir = RestrictPathForExperiment(Dir,'nMice', Mice_to_analyze);

clrs = {'ko', 'ro', 'go','co'; 'k','r', 'g', 'c'};

% % Axes
% fh = figure('units', 'normalized', 'outerposition', [0 0 0.65 0.65]);
% Occupancy_Axes = axes('position', [0.07 0.55 0.41 0.41]);
% NumEntr_Axes = axes('position', [0.55 0.55 0.41 0.41]);
% First_Axes = axes('position', [0.07 0.05 0.41 0.41]);
% Speed_Axes = axes('position', [0.55 0.05 0.41 0.41]);

%% Get data

for i = 1:length(Dir.path)
    a{i} = load([Dir.path{i}{1} '/behavResources.mat'], 'behavResources', 'AlignedXtsd','AlignedYtsd',...
        'Vtsd', 'SessionEpoch');
end

%% Process data
TowardsShockPre = cell(1,length(Dir.path));
AwayFromShockPre = cell(1,length(Dir.path));
TowardsShockPost = cell(1,length(Dir.path));
AwayFromShockPost = cell(1,length(Dir.path));
VtsdPre = cell(1,length(Dir.path));
VtsdPost = cell(1,length(Dir.path));

for i = 1:length(Dir.path)
    % Get PreTestEpoch
    PreEpoch = or(a{i}.SessionEpoch.TestPre1,a{i}.SessionEpoch.TestPre2);
    PreEpoch = or(PreEpoch,a{i}.SessionEpoch.TestPre3);
    PreEpoch = or(PreEpoch,a{i}.SessionEpoch.TestPre4);
    
    HabXPre = Restrict(a{i}.AlignedXtsd,PreEpoch);
    HabYPre = Restrict(a{i}.AlignedYtsd,PreEpoch);
    VtsdPre{i} = Restrict(a{i}.Vtsd,PreEpoch);
    TrajPre = [Data(HabXPre) Data(HabYPre)];
    [TowardsShockPre{i},AwayFromShockPre{i}] = SeparateTrajectoriesTowardsShock(TrajPre);
    
    % Get PostTestEpoch
    PostEpoch = or(a{i}.SessionEpoch.TestPost1,a{i}.SessionEpoch.TestPost2);
    PostEpoch = or(PostEpoch,a{i}.SessionEpoch.TestPost3);
    PostEpoch = or(PostEpoch,a{i}.SessionEpoch.TestPost4);
    
    HabXPost = Restrict(a{i}.AlignedXtsd,PostEpoch);
    HabYPost = Restrict(a{i}.AlignedYtsd,PostEpoch);
    VtsdPost{i} = Restrict(a{i}.Vtsd,PostEpoch);
    TrajPost = [Data(HabXPost) Data(HabYPost)];
    [TowardsShockPost{i},AwayFromShockPost{i}] = SeparateTrajectoriesTowardsShock(TrajPost);
    
end

%% Process average
TowardsShockPreAll = TowardsShockPre{1};
AwayFromShockPreAll = AwayFromShockPre{1};
TowardsShockPostAll = TowardsShockPost{1};
AwayFromShockPostAll = AwayFromShockPost{1};
VtsdPreAll = Data(VtsdPre{1});
VtsdPostAll = Data(VtsdPost{1});

for i = 2:length(Dir.path)
    TowardsShockPreAll = [TowardsShockPreAll; TowardsShockPre{i}];
    AwayFromShockPreAll = [AwayFromShockPreAll; AwayFromShockPre{i}];
    TowardsShockPostAll = [TowardsShockPostAll; TowardsShockPost{i}];
    AwayFromShockPostAll = [AwayFromShockPostAll; AwayFromShockPost{i}];
    
    VtsdPreAll = [VtsdPreAll; Data(VtsdPre{i})];
    VtsdPostAll = [VtsdPostAll; Data(VtsdPost{i})];
    
end


%% Plot mouse by mouse
for i = 1:length(Dir.path)
    
    figure('units', 'normalized', 'outerposition', [0.1 0.2 0.8 0.8]);
    
        % Pre - Towards
        subplot(2,2,1)
        hold on

        x = TowardsShockPre{i}(:,1);  % X data
        y = TowardsShockPre{i}(:,2);  % Y data
        z = Data(VtsdPre{i});

        % Plot data:
        surf([x(:) x(:)], [y(:) y(:)], [z(:) z(:)], ...  % Reshape and replicate data
            'FaceColor', 'none', ...    % Don't bother filling faces with color
            'EdgeColor', 'interp', ...  % Use interpolated color for edges
            'LineWidth', 2);            % Make a thicker line


        set(gca,'FontWeight','bold');
        set(gca,'LineWidth',1.2);
        xlabel('Position X (cm)')
        ylabel('Position Y (cm)')
           
        title('Speed towards reward zone during Pre-tests')

        hcb = colorbar;
        colormap(jet)
        set(get(hcb,'label'),'string','Speed (cm/s)');

        caxis([0 18])
    %     xlim([5 55])
    %     ylim([0 40])
    %     

        % Pre - Away
        subplot(2,2,2)
        hold on

        x = AwayFromShockPre{i}(:,1);  % X data
        y = AwayFromShockPre{i}(:,2);  % Y data
        z = Data(VtsdPre{i});

        % Plot data:
        surf([x(:) x(:)], [y(:) y(:)], [z(:) z(:)], ...  % Reshape and replicate data
            'FaceColor', 'none', ...    % Don't bother filling faces with color
            'EdgeColor', 'interp', ...  % Use interpolated color for edges
            'LineWidth', 2);            % Make a thicker line


        set(gca,'FontWeight','bold');
        set(gca,'LineWidth',1.2);
        xlabel('Position X (cm)')
        ylabel('Position Y (cm)')
        title('Speed away from reward zone during Pre-tests')

        hcb = colorbar;
        set(get(hcb,'label'),'string','Speed (cm/s)');

        caxis([0 18])
    %     xlim([5 55])
    %     ylim([0 40])
    %     
        % Post - Towards
        subplot(2,2,3)
        hold on

        x = TowardsShockPost{i}(:,1);  % X data
        y = TowardsShockPost{i}(:,2);  % Y data
        z = Data(VtsdPost{i});

        % Plot data:
        surf([x(:) x(:)], [y(:) y(:)], [z(:) z(:)], ...  % Reshape and replicate data
            'FaceColor', 'none', ...    % Don't bother filling faces with color
            'EdgeColor', 'interp', ...  % Use interpolated color for edges
            'LineWidth', 2);            % Make a thicker line


        set(gca,'FontWeight','bold');
        set(gca,'LineWidth',1.2);
        xlabel('Position X (cm)')
        ylabel('Position Y (cm)')
        title('Speed towards reward zone during Post-tests')

        hcb = colorbar;
        set(get(hcb,'label'),'string','Speed (cm/s)');

        caxis([0 18])
    %     xlim([5 55])
    %     ylim([0 40])

        % Post - Away
        subplot(2,2,4)
        hold on

        x = AwayFromShockPost{i}(:,1);  % X data
        y = AwayFromShockPost{i}(:,2);  % Y data
        z = Data(VtsdPost{i});

        % Plot data:
        surf([x(:) x(:)], [y(:) y(:)], [z(:) z(:)], ...  % Reshape and replicate data
            'FaceColor', 'none', ...    % Don't bother filling faces with color
            'EdgeColor', 'interp', ...  % Use interpolated color for edges
            'LineWidth', 2);            % Make a thicker line


        set(gca,'FontWeight','bold');
        set(gca,'LineWidth',1.2);
        xlabel('Position X (cm)')
        ylabel('Position Y (cm)')
        title('Speed away from reward zone during Post-tests')

        hcb = colorbar;
        set(get(hcb,'label'),'string','Speed (cm/s)');

        caxis([0 18])
    %     xlim([5 55])
    %     ylim([0 40])

        % Global title 
        supertit = ['Mouse ' num2str(Mice_to_analyze(i))  ' - Speed-Direction Trajectories'];
        mtit(supertit, 'fontsize',14, 'xoff', 0, 'yoff', 0.05);

        if sav
            print([dir_out 'SpeedTrajectories_' Mice_to_analyze{i}], '-dpng', '-r300');
        end
end

%% Plot Average

figure('units', 'normalized', 'outerposition', [0.1 0.2 0.8 0.8]);

    % Pre - Towards
    subplot(2,2,1)
    hold on

    x = TowardsShockPreAll(:,1);  % X data
    y = TowardsShockPreAll(:,2);  % Y data
    z = VtsdPreAll;

    % Plot data:
    surf([x(:) x(:)], [y(:) y(:)], [z(:) z(:)], ...  % Reshape and replicate data
        'FaceColor', 'none', ...    % Don't bother filling faces with color
        'EdgeColor', 'interp', ...  % Use interpolated color for edges
        'LineWidth', 2);            % Make a thicker line


    set(gca,'FontWeight','bold');
    set(gca,'LineWidth',1.2);
    xlabel('Position X (cm)')
    ylabel('Position Y (cm)')
    title('Speed towards reward zone during Pre-tests')

    hcb = colorbar;
    set(get(hcb,'label'),'string','Speed (cm/s)');

    caxis([0 18])
    xlim([-0.1 1.1])
    ylim([-0.1 1.1])


    % Pre - Away
    subplot(2,2,2)
    hold on

    x = AwayFromShockPreAll(:,1);  % X data
    y = AwayFromShockPreAll(:,2);  % Y data
    z = VtsdPreAll;

    % Plot data:
    surf([x(:) x(:)], [y(:) y(:)], [z(:) z(:)], ...  % Reshape and replicate data
        'FaceColor', 'none', ...    % Don't bother filling faces with color
        'EdgeColor', 'interp', ...  % Use interpolated color for edges
        'LineWidth', 2);            % Make a thicker line


    set(gca,'FontWeight','bold');
    set(gca,'LineWidth',1.2);
    xlabel('Position X (cm)')
    ylabel('Position Y (cm)')
    title('Speed away from reward zone during Pre-tests')

    hcb = colorbar;
    set(get(hcb,'label'),'string','Speed (cm/s)');

    caxis([0 18])
    xlim([-0.1 1.1])
    ylim([-0.1 1.1])

    % Post - Towards
    subplot(2,2,3)
    hold on

    x = TowardsShockPostAll(:,1);  % X data
    y = TowardsShockPostAll(:,2);  % Y data
    z = VtsdPostAll;

    % Plot data:
    surf([x(:) x(:)], [y(:) y(:)], [z(:) z(:)], ...  % Reshape and replicate data
        'FaceColor', 'none', ...    % Don't bother filling faces with color
        'EdgeColor', 'interp', ...  % Use interpolated color for edges
        'LineWidth', 2);            % Make a thicker line


    set(gca,'FontWeight','bold');
    set(gca,'LineWidth',1.2);
    xlabel('Position X (cm)')
    ylabel('Position Y (cm)')
    title('Speed towards reward zone during Post-tests')

    hcb = colorbar;
    set(get(hcb,'label'),'string','Speed (cm/s)');

    caxis([0 18])
    xlim([-0.1 1.1])
    ylim([-0.1 1.1])

    % Post - Away
    subplot(2,2,4)
    hold on

    x = AwayFromShockPostAll(:,1);  % X data
    y = AwayFromShockPostAll(:,2);  % Y data
    z = VtsdPostAll;

    % Plot data:
    surf([x(:) x(:)], [y(:) y(:)], [z(:) z(:)], ...  % Reshape and replicate data
        'FaceColor', 'none', ...    % Don't bother filling faces with color
        'EdgeColor', 'interp', ...  % Use interpolated color for edges
        'LineWidth', 2);            % Make a thicker line


    set(gca,'FontWeight','bold');
    set(gca,'LineWidth',1.2);
    xlabel('Position X (cm)')
    ylabel('Position Y (cm)')
    title('Speed away from reward zone during Post-tests')

    hcb = colorbar;
    set(get(hcb,'label'),'string','Speed (cm/s)');

    caxis([0 18])
    xlim([-0.1 1.1])
    ylim([-0.1 1.1])
    
    % Global title 
    supertit = ['Global Speed-Direction Trajectories'];
    mtit(supertit, 'fontsize',14, 'xoff', 0, 'yoff', 0.05);
    
    if sav
        print([dir_out 'SpeedTrajectories_averaged'], '-dpng', '-r300');
    end