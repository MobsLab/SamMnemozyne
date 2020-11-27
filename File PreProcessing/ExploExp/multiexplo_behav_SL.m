%==========================================================================
% Details: Output behavioral data from the ExploExp experiment.
%
% INPUTS:
%       - None. However, folders, files and other variables must be initialized 
%           before starting the script in the Prameters section. 
%
% OUTPUT:
%       - figures including:
%           - Trajectories
%           - Heatmaps
%           - Speed per sections
%
% NOTES:
%
%   Written by Samuel Laventure - 26-11-2018
%       edited SL - 20-11-2019
%==========================================================================

clear all

%#####################################################################
%#
%#                   P A R A M E T E R S
%#
%#####################################################################

% ---------- HARDCODED -----------
% bootsrapping options
    bts=1;      %bootstrap: 1 = yes; 0 = no
    draws=50;   %nbr of draws for the bts
    rnd=0;      %test against a random sampling of pre-post maps

% stats correction 
    alpha=.001; % p-value seeked for significance
        % only one must be chosen
        %----------
        fdr_corr=0;
        bonfholm=0;
        bonf=1;
        %----------
    corr = {'uncorr','fdr','bonfholm','bonf'};

%----------- SAVING PARAMETERS ----------
% Outputs
    dirout = '/home/mobs/Dropbox/MOBS_workingON/Sam/ExploExp/';
    if ~exist(dirout, 'dir')
        mkdir(dirout);
    end
    sav=1;      % Do you want to save a figure? Y=1; N=0

%     %-- Current folder
%     [parentFolder deepestFolder] = fileparts(pwd);
% 
%     %-- Folder with data
%     dataPath = [parentFolder '/eeglab_files/' datype '/'];

mice = {'754','818','821','802','809'};

% Individual files Note that each mice is seperated by ";"
indir = {'/media/mobs/DataMOBsRAIDN/MultiExploBehav/ERC-Mouse-754-21112018-Hab_00/', ...
    '/media/mobs/DataMOBsRAIDN/MultiExploBehav/ERC-Mouse-754-22112018-Hab_02/', ...
    '/media/mobs/DataMOBsRAIDN/MultiExploBehav/ERC-Mouse-754-22112018-Hab_03/', ... 
    '/media/mobs/DataMOBsRAIDN/MultiExploBehav/ERC-Mouse-754-23112018-Hab_00/', ... 
    '/media/mobs/DataMOBsRAIDN/MultiExploBehav/ERC-Mouse-754-23112018-Hab_01/', ...
    '/media/mobs/DataMOBsRAIDN/MultiExploBehav/ERC-Mouse-754-23112018-Hab_02/';
    '/media/mobs/DataMOBsRAIDN/MultiExploBehav/ERC-Mouse-818-21112018-Hab_00/', ...
    '/media/mobs/DataMOBsRAIDN/MultiExploBehav/ERC-Mouse-818-22112018-Hab_00/', ...
    '/media/mobs/DataMOBsRAIDN/MultiExploBehav/ERC-Mouse-818-22112018-Hab_01/', ...
    '/media/mobs/DataMOBsRAIDN/MultiExploBehav/ERC-Mouse-818-23112018-Hab_00/', ...
    '/media/mobs/DataMOBsRAIDN/MultiExploBehav/ERC-Mouse-818-23112018-Hab_01/', ...
    '/media/mobs/DataMOBsRAIDN/MultiExploBehav/ERC-Mouse-818-23112018-Hab_02/';
    '/media/mobs/DataMOBsRAIDN/MultiExploBehav/ERC-Mouse-821-21112018-Hab_00/', ...
    '/media/mobs/DataMOBsRAIDN/MultiExploBehav/ERC-Mouse-821-22112018-Hab_00/', ...
    '/media/mobs/DataMOBsRAIDN/MultiExploBehav/ERC-Mouse-821-22112018-Hab_01/', ...
    '/media/mobs/DataMOBsRAIDN/MultiExploBehav/ERC-Mouse-821-23112018-Hab_00/', ...
    '/media/mobs/DataMOBsRAIDN/MultiExploBehav/ERC-Mouse-821-23112018-Hab_01/', ...
    '/media/mobs/DataMOBsRAIDN/MultiExploBehav/ERC-Mouse-821-23112018-Hab_02/';
    '/media/mobs/DataMOBsRAIDN/MultiExploBehav/ERC-Mouse-802-26112018-Hab_00/', ...
    '/media/mobs/DataMOBsRAIDN/MultiExploBehav/ERC-Mouse-802-27112018-Hab_00/', ...
    '/media/mobs/DataMOBsRAIDN/MultiExploBehav/ERC-Mouse-802-27112018-Hab_01/', ...
    '/media/mobs/DataMOBsRAIDN/MultiExploBehav/ERC-Mouse-802-28112018-Hab_00/', ...
    '/media/mobs/DataMOBsRAIDN/MultiExploBehav/ERC-Mouse-802-28112018-Hab_01/', ...
    '/media/mobs/DataMOBsRAIDN/MultiExploBehav/ERC-Mouse-802-28112018-Hab_02/';
    '/media/mobs/DataMOBsRAIDN/MultiExploBehav/ERC-Mouse-809-26112018-Hab_00/', ...
    '/media/mobs/DataMOBsRAIDN/MultiExploBehav/ERC-Mouse-809-27112018-Hab_00/', ...
    '/media/mobs/DataMOBsRAIDN/MultiExploBehav/ERC-Mouse-809-28112018-Hab_00/', ...
    '/media/mobs/DataMOBsRAIDN/MultiExploBehav/ERC-Mouse-809-28112018-Hab_01/', ...
    '/media/mobs/DataMOBsRAIDN/MultiExploBehav/ERC-Mouse-809-28112018-Hab_02/', ...
    '/media/mobs/DataMOBsRAIDN/MultiExploBehav/ERC-Mouse-809-28112018-Hab_03/'
        };


% Directories details
umaze = [1 1 1 1 1 1;
         1 1 1 1 1 1;
         1 1 1 1 1 1];

nmice = 5; % Nbr of mouse
ntest = 1; % Nbr of trials per test
nsess = 6; % Nbr of sesion
sect_order = [4,3,5,1,0,2];  %order of U-mze section creation
sect_name = {'Left corner', 'Center middle', 'Right corner', 'Left arm', '', 'Right arm'};

%-------------- MAP PARAMETERS -----------
freqVideo=15;       %frame rate
smo=2;            %smoothing factor
sizeMap=50;         %Map size

%------------- FIGURE PARAMETERS -------------
clrs = {'ko', 'bo', 'ro','go', 'co', 'mo'; 'w','y', 'r', 'g', 'c', 'm'; 'kp', 'bp', 'rp', 'gp', 'cp', 'mp'};


%#####################################################################
%#
%#                           M A I N
%#
%#####################################################################

%GET DATA
for imice=1:nmice
    for isess=1:nsess 
        dat{imice,isess} = load([indir{imice,isess} 'behavResources.mat'], ...
            'Occup', 'Xtsd', 'Ytsd', 'Vtsd', 'ZoneIndices', 'Zone','PosMat', 'Ratio_IMAonREAL');
        
        % GET OCCUPANCY
        [occH, x1, x2] = hist2(Data(dat{imice,isess}.Xtsd), Data(dat{imice,isess}.Ytsd), 240, 320);
        occHS(imice,isess,1:320,1:240) = SmoothDec(occH/freqVideo,[smo,smo]); 
        x(imice,isess,1:240)=x1;
        y(imice,isess,1:320)=x2;
        for isect=1:5
            occup(imice,isess,isect) = dat{imice,isess}.Occup(1,isect);
            
            % Get speed
            tmpV = Data(dat{imice,isess}.Vtsd);
            Speedz = tmpV(dat{imice,isess}.ZoneIndices{isect}(1:end-1));
            SpeedZm(imice,isess,isect) = squeeze(mean(Speedz));
        end %loop u-mze sections
    end % loop nb sess 
    
    
    %% INDIVIDUAL FIGURES    
        
    % FIGURE 1 - Trajectories and heatmap per mouse
    supertit = ['Mouse ' mice{imice} ' - Trajectories and occupancy heatmaps'];
    figure('Color',[1 1 1], 'rend','painters','pos',[1 1 1400 700],'Name', supertit, 'NumberTitle','off')
        
        for l=1:nsess
            % Trajectories superposed on heatmaps
            subplot(2,3,l), 
            
            box off
            
            % -- heatmap
            % --- set x and y vector data for image
            xx=squeeze(x(imice,l,:));
            yi=permute(y,[3,1,2]);
            yy=yi(:,imice,l);
            % --- image
            imagesc(xx,yy,squeeze(occHS(imice,l,:,:))) 
            caxis([0 .1]) % control color intensity here
            colormap(hot)
            hold on
            % -- trajectories    
            p1 = plot((dat{imice,l}.PosMat(:,3)),(dat{imice,l}.PosMat(:,2)),...
                    'w', 'linewidth',.25);  
            p1.Color(4) = .3;    %control line color intensity here
            hold on 
            set(gca, 'XTickLabel', []);
            set(gca, 'YTickLabel', []);
            title(['Session ' num2str(l)])
        end
        
        % Supertitle
        mtit(supertit, 'fontsize',14, 'xoff', 0, 'yoff', 0.03);
        
        % script name at bottom
        AddScriptName

        if sav
            print([dirout 'Behav_Trajectories' mice{imice}], '-dpng', '-r300');
        end
        
    % FIGURE 2 - Occupancy % per section and mouse
    supertit = ['Mouse ' mice{imice} ' - Percentage of occupancy by section of U-Maze'];
    figure('Color',[1 1 1], 'rend','painters','pos',[10 10 1400 700],'Name',supertit, 'NumberTitle','off')
        for s=1:6
            if ~(s==5)
                subplot(2,3,s)
                PlotErrorBarN_KJ(occup(imice,1:6,sect_order(s)), 'barcolors', [0.3 0.266 0.613], 'newfig', 0);
                ylim([0 0.35])
                set(gca,'Xtick',[1:1:6]);
                xlabel('Sessions number');
                ylabel('% time spent in zone');
                title(sect_name{s})
            end
        end
        
        % Supertitle
        mtit(supertit, 'fontsize',14, 'xoff', 0, 'yoff', 0.03);
        
        % script name at bottom
        AddScriptName
        
        %save
        if sav
            print([dirout 'Behav_Occup' mice{imice}], '-dpng', '-r300');
        end    
        
        
    % FIGURE 3 - Speed per section and mouse
    supertit = ['Mouse ' mice{imice} ' - Average speed by section of U-Maze'];
    figure('Color',[1 1 1], 'rend','painters','pos',[10 10 1400 700],'Name',supertit, 'NumberTitle','off')
        for s=1:6
            if ~(s==5)
                subplot(2,3,s)
                PlotErrorBarN_KJ(SpeedZm(imice,1:6,sect_order(s)), 'barcolors', [0.3 0.266 0.613], 'newfig', 0);
                ylim([0 12])
                set(gca,'Xtick',[1:1:6]);
                xlabel('Sessions number');
                ylabel('cm/sec');
                title(sect_name{s})
            end
        end
        
        % Supertitle
        mtit(supertit, 'fontsize',14, 'xoff', 0, 'yoff', 0.03);
        
        % script name at bottom
        AddScriptName
        
        %save
        if sav
            print([dirout 'Behav_Speed' mice{imice}], '-dpng', '-r300');
        end    
        
end % loop nb mice

%% GROUP STATISTICS AND FIGURES

occHm = squeeze(mean(occHS(:,:,:,:)));
mocc=squeeze(mean(occup(:,:,:)));
Speedavg = squeeze(nanmean(SpeedZm(:,:,:)));


% FIGURE 4 - Trajectories and heatmap per mouse
supertit = 'Averaged occupancy heatmaps';
figure('Color',[1 1 1], 'rend','painters','pos',[10 10 1400 700],'Name', supertit, 'NumberTitle','off')

    for l=1:nsess
        % Trajectories superposed on heatmaps
        subplot(2,3,l), 
        box off

        %heatmap
        imagesc(x1,x2,squeeze(occHm(l,:,:))) 
        caxis([0 .1]);
        colormap(hot)

        hold on 
        set(gca, 'XTickLabel', []);
        set(gca, 'YTickLabel', []);

        title(['Session ' num2str(l)])
    end

    % Supertitle
    mtit(supertit, 'fontsize',14, 'xoff', 0, 'yoff', 0.03);

    % script name at bottom
    AddScriptName

    if sav
        print([dirout 'Behav_Heatmaps_all'], '-dpng', '-r300');
    end


% FIGURE 5 - Occupancy % per section - AVERAGE
supertit = 'Percentage of occupancy by section of U-Maze';
figure('Color',[1 1 1], 'rend','painters','pos',[10 10 1400 700],'Name',supertit, 'NumberTitle','off')
    si = 0;
    for s=1:6
        if ~(s==5)
            subplot(2,3,s)
            PlotErrorBarN_KJ(mocc(1:6,sect_order(s))', 'barcolors', [0.3 0.266 0.613], 'newfig', 0);
            ylim([0 0.35])
            set(gca,'Xtick',[1:1:6]);
            xlabel('Sessions number');
            ylabel('% time spent in zone');
            title(sect_name{s})
        end
    end

    % Supertitle
    mtit(supertit, 'fontsize',14, 'xoff', 0, 'yoff', 0.03);

    % script name at bottom
    AddScriptName

    %save
    if sav
        print([dirout 'Behav_Occup_all'], '-dpng', '-r300');
    end   
    
% FIGURE 6 - Speed per section
supertit = ['Average speed by section of U-Maze'];
figure('Color',[1 1 1], 'rend','painters','pos',[10 10 1400 700],'Name',supertit, 'NumberTitle','off')
    for s=1:6
        if ~(s==5)
            subplot(2,3,s)
            PlotErrorBarN_KJ(Speedavg(1:6,sect_order(s))', 'barcolors', [0.3 0.266 0.613], 'newfig', 0);
            ylim([0 12])
            set(gca,'Xtick',[1:1:6]);
            xlabel('Sessions number');
            ylabel('cm/sec');
            title(sect_name{s})
        end
    end

    % Supertitle
    mtit(supertit, 'fontsize',14, 'xoff', 0, 'yoff', 0.03);

    % script name at bottom
    AddScriptName

    %save
    if sav
        print([dirout 'Behav_Speed_all'], '-dpng', '-r300');
    end    















































