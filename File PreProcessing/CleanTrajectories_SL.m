function [CleanPosMatInit, CleanPosMat, CleanXtsd, CleanYtsd, CleanVtsd, CleanMaskBounary] = CleanTrajectories_DB(dirin_traj)
%%% CleanTrajectories_DB - creates clean version of a given trajectory
%   The code gets rid of:
%
%   - Mistracking in the beginning (caused usually by sloppy hands of the experimenter)
%   - Non-tracking during the experiment
%   - Mis-tracking caused by reflections from the walls
%
%   Has video-support
%

%% Add parameters from old behavResources files  
% % Conditioning
% loading_cond = '/media/nas5/ProjetERC2/Mouse-905/20190404/PAGExp/Cond';
% saving_cond = '/media/nas5/ProjetERC2/Mouse-905/20190404/Retracking/Cond';
% icond = {'/Cond1', '/Cond2', '/Cond3', '/Cond4'};
% for i = 1:length(icond)
%     cond{i} = load([loading_cond icond{i} '/behavResources.mat'], 'GotFrame', 'Zone', 'th_immob', 'thtps_immob');
%     GotFrame = cond{1, i}.GotFrame;
%     Zone = cond{1, i}.Zone;
%     th_immob = cond{1, i}.th_immob;
%     thtps_immob = cond{1, i}.thtps_immob;
%     save([saving_cond icond{i} '/behavResources_Offline.mat'], 'GotFrame', 'Zone', 'th_immob', 'thtps_immob', '-append');
% end
% % ExploAfter
% loading_ExploAfter = '/media/nas5/ProjetERC2/Mouse-905/20190404/PAGExp/ExploAfter';
% saving_ExploAfter = '/media/nas5/ProjetERC2/Mouse-905/20190404/Retracking/ExploAfter';
% ExploAfter = load([loading_ExploAfter '/behavResources.mat'], 'GotFrame', 'Zone', 'th_immob', 'thtps_immob');
% GotFrame = ExploAfter.GotFrame;
% Zone = ExploAfter.Zone;
% th_immob = ExploAfter.th_immob;
% thtps_immob = ExploAfter.thtps_immob;
% save([saving_ExploAfter '/behavResources_Offline.mat'], 'GotFrame', 'Zone','th_immob', 'thtps_immob', '-append');
% % Hab
% loading_hab = '/media/nas5/ProjetERC2/Mouse-905/20190404/PAGExp/Hab';
% saving_hab = '/media/nas5/ProjetERC2/Mouse-905/20190404/Retracking/Hab';
% Hab = load([loading_hab '/behavResources.mat'], 'GotFrame', 'Zone', 'th_immob', 'thtps_immob');
% GotFrame = Hab.GotFrame;
% Zone = Hab.Zone;
% th_immob = Hab.th_immob;
% thtps_immob = Hab.thtps_immob;
% save([saving_hab '/behavResources_Offline.mat'], 'GotFrame', 'Zone','th_immob', 'thtps_immob', '-append');
% % TestPre
% loading_testpre = '/media/nas5/ProjetERC2/Mouse-905/20190404/PAGExp/TestPre';
% saving_testpre = '/media/nas5/ProjetERC2/Mouse-905/20190404/Retracking/TestPre';
% itestpre = {'/TestPre1', '/TestPre2', '/TestPre3', '/TestPre4'};
% for i = 1:length(itestpre)
%     testpre{i} = load([loading_testpre itestpre{i} '/behavResources.mat'], 'GotFrame', 'Zone', 'th_immob', 'thtps_immob');
%     GotFrame = testpre{1, i}.GotFrame;
%     Zone = testpre{1, i}.Zone;
%     th_immob = testpre{1, i}.th_immobdirin_traj;
%     thtps_immob = testpre{1, i}.thtps_immob;
%     save([saving_testpre itestpre{i} '/behavResources_Offline.mat'], 'GotFrame', 'Zone','th_immob', 'thtps_immob', '-append');
%%TestPost
% loading_testpost = '/media/nas5/ProjetERC2/Mouse-905/20190404/PAGExp/TestPost';
% saving_testpost = '/media/nas5/ProjetERC2/Mouse-905/20190404/Retracking/TestPost';
% % itestpost = {'/TestPost1', '/TestPost2', '/TestPost3', '/TestPost4'};
% itestpost = {'/TestPost1'};
% 
% for i = 1:length(itestpost)
%     testpost{i} = load([loading_testpost itestpost{i} '/behavResources.mat'], 'GotFrame', 'Zone', 'th_immob', 'thtps_immob');
%     GotFrame = testpost{1, i}.GotFrame;
%     Zone = testpost{1, i}.Zone;
%     th_immob = testpost{1, i}.th_immob;
%     thtps_immob = testpost{1, i}.thtps_immob;
%     save([saving_testpost itestpost{i} '/behavResources.mat'], 'GotFrame', 'Zone','th_immob', 'thtps_immob', '-append');
% end
% 
% clear all
%% Parameters
try
    dirin_traj;
catch
    dirin_traj = '/media/nas5/ProjetERC2/Mouse-905/20190404/Retracking/TestPost/TestPost1';
end

cd(dirin_traj)
% 
% path_video = dir('**/*.avi');
% 
% % The ration between New Mask and original mask areas
% FracArea = 0.85;

% Distance between two points that forbids interpolation
dist_thresh = 2;

%% Load the data
load([dirin_traj '/behavResources.mat']);

%% Do the housekeeping

% %Controls size and position of the figures
% x0=500;
% y0=300;
% width=1100;
% height=600;
% 
% StartTimeOK = 0;
% PauseDuration = 0.01;
% EndOfSample = 500;

% %Creates the new mask
% stats = regionprops(mask, 'Area');
% tempmask=mask;
% AimArea=stats.Area*FracArea;
% ActArea=stats.Area;
% while AimArea<ActArea
%     tempmask=imerode(tempmask,strel('disk',1));
%     stats = regionprops(tempmask, 'Area');
%     ActArea=stats.Area;
% end
% aux=bwboundaries(tempmask);
% new_mask=aux{1}./Ratio_IMAonREAL;
% 
% [xmin,xmax] = bounds(new_mask(:,2));
% [ymin,ymax] = bounds(new_mask(:,1));
% 
% vid = VideoReader([path_video.folder '/' path_video.name]);
% frames = read(vid);
% 
% %% Start of the trajectory
% 
% if isnan(PosMatInit(1,2)) && sum(isnan(PosMatInit(1:10,2))) > 7
%     %Gets the starting indice for the good tracking from the user
%     while StartTimeOK == 0
%         
%         % figure
%         traj = figure('units', 'normalized', 'outerposition', [0.1 0.3 0.8 0.6]);
%         hold on
%         xlim([xmin-10,xmax+10])
%         ylim([ymin-10,ymax+20])
%         a=[];
%         
%         tps=Range(Ytsd,'s');
%         tps = tps(GotFrame == 1);
%         
%         for i=100:EndOfSample
%             subplot(121)
%             if GotFrame(i) == 0
%                 cla reset
%             else
%                 plot(new_mask(:,2),new_mask(:,1),'k','LineWidth',2)
%                 text(xmin-2,ymax+5,'Trajectory','fontweight','bold','fontsize',12)
%                 hold on
%                 plot(PosMatInit(1:i,2),PosMatInit(1:i,3),'r')
%                 hold off
%                 a=text(xmax-2,ymax+5,[num2str(PosMatInit(i,1)) ' s'],'fontweight','bold','fontsize',12);
%             end
%             
%             subplot(122)
%             IM = squeeze(frames(:,:,:,i));
%             IM = IM(:,:,1);
%             IM = double(IM)/256;
%             imagesc(IM)
%             axis xy
%             hold on
%             title(num2str(tps(i)))
%             plot(PosMatInit(i,2)*Ratio_IMAonREAL,PosMatInit(i,3)*Ratio_IMAonREAL,'*r','MarkerSize',16);
%             hold off
%             pause(PauseDuration)
%         end
%         
%         
%         answer = questdlg('Can you see where good trackin starts?', ...
%             'Clean beginning of trajectories', ...
%             'No, slow down','Yes, choose starting point', 'Yes, choose starting point');
%         switch answer
%             case 'No, slow down'
%                 PauseDuration = PauseDuration*2;
%                 close(traj)
%             case 'Yes, choose starting point'
%                 [x_init,y_init] = ginput(1);
%                 close(traj)
%                 distances = sum((PosMatInit(1:EndOfSample,[2,3])-[[x_init y_init]]).^2,2);
%                 IndiceStartTracking = find(distances==min(distances));
%                 
%                 traj = figure;
%                 set(gcf,'position',[x0,y0,width,height])
%                 hold on
%                 xlim([xmin-10,xmax+10])
%                 ylim([ymin-10,ymax+20])
%                 a=[];
%                 
%                 plot(new_mask(:,2),new_mask(:,1),'k','LineWidth',2)
%                 
%                 for i=IndiceStartTracking:EndOfSample
%                     delete(a)
%                     plot(PosMatInit(IndiceStartTracking:i,2),PosMatInit(IndiceStartTracking:i,3),'r')
%                     a=text(xmax-5,ymax+10,[num2str(PosMatInit(i,1)) ' s'],'fontweight','bold','fontsize',12);
%                     pause(PauseDuration)
%                     
%                 end
%                 answer2 = questdlg('Are you satisfied?', ...
%                     'Clean beginning of trajectories', ...
%                     'Yes','No, restart','No, restart');
%                 switch answer2
%                     case 'Yes'
%                         close(traj)
%                         StartTimeOK = 1;
%                     case 'No, restart'
%                         close(traj)
%                 end
%         end
%         
%     end
% end


%Creates the clean version of behavResources.mat variables
if exist('IndiceStartTracking', 'var')
    CleanPosMatInit = PosMatInit;
    CleanPosMatInit(1:IndiceStartTracking-1,2:end) = NaN;
else
    CleanPosMatInit = PosMatInit;
end

%% Find big jumps in the file
% Find timestamps where the mouse was not tracked
idx_nan = isnan(CleanPosMatInit(:,2));
if exist('IndiceStartTracking', 'var')
    idx_nan = find(idx_nan(IndiceStartTracking:end));
    idx_nan = idx_nan+IndiceStartTracking-1;
else
    idx_nan = find(idx_nan);
end

if ~isempty(idx_nan)
    % Split in sequences
    firsttime = 1;
    DD = diff(idx_nan);
    id=[false (DD==1)' false];
    istart = strfind(id,[0 1]);
    iend = strfind(id,[1 0]);
    k = 0;
    for i=1:length(id)-1
        if id(i)==0 && id(i+1)==0
            seq{i} = idx_nan(i);
            firsttime = 1;
        elseif id(i)==0 && id(i+1) == 1
            if firsttime
                k=k+1;
                start = istart(k);
                stop = iend(k);
                seq{i}=[idx_nan(start):idx_nan(stop)];
                firsttime = 0;
            end
        elseif id(i)==1 && id(i+1)==0
            seq{i} = [];
            firsttime=1;
        end
    end
    seq = seq(~cellfun('isempty',seq));
    
    CleanPosMat = CleanPosMatInit;
    for i=1:length(seq)
        temp = seq{i};
        if temp(1) ~= 1 && temp(1) > 5
            if length(temp)<4 % 4 is arbitrary
                
                if temp(end)+5 < size(CleanPosMat,1) % 5 is arbitrary
                    
                    % Interpolate x
                    x = CleanPosMatInit(temp(1)-5:temp(end)+5,2);
                    nanx = isnan(x);
                    t = 1:numel(x);
                    x(nanx) = interp1(t(~nanx), x(~nanx), t(nanx));
                    % Interpolate x
                    y = CleanPosMatInit(temp(1)-5:temp(end)+5,3);
                    nany = isnan(y);
                    t = 1:numel(y);
                    y(nany) = interp1(t(~nany), y(~nany), t(nany));
                    
                    CleanPosMat(temp(1)-5:temp(end)+5,2:3) = [x y];
                    
                    clear x y nanx nany t
                    
                end
                
                
            else
                
                if temp(end)+5 < size(CleanPosMat,1)
                    
                    twopoints = CleanPosMatInit([temp(1)-1 temp(end)+1],2:3);
                    dist = pdist(twopoints, 'euclidean');
                    if dist<dist_thresh
                        
                        % Interpolate x
                        x = CleanPosMatInit(temp(1)-5:temp(end)+5,2);
                        nanx = isnan(x);
                        t = 1:numel(x);
                        x(nanx) = interp1(t(~nanx), x(~nanx), t(nanx));
                        % Interpolate x
                        y = CleanPosMatInit(temp(1)-5:temp(end)+5,3);
                        nany = isnan(y);
                        t = 1:numel(y);
                        y(nany) = interp1(t(~nany), y(~nany), t(nany));
                        
                        CleanPosMat(temp(1)-5:temp(end)+5,2:3) = [x y];
                        
                        clear x y nanx nany t
                        
                    end
                end
            end
        end
    end
else
    CleanPosMat = CleanPosMatInit;
end
%% Save the result
CleanXtsd = tsd(Range(Xtsd),CleanPosMat(:,2));
CleanYtsd = tsd(Range(Ytsd),CleanPosMat(:,3));
CleanVtsd=tsd(CleanPosMat(1:end-1,1)*1e4,(sqrt(diff(CleanPosMat(:,2)).^2+diff(CleanPosMat(:,3)).^2)./(diff(CleanPosMat(:,1)))));
CleanMaskBounary = new_mask;

%Saves the workspace to a new variable cleanBehavResources.mat
save([dirin_traj '/behavResources.mat'], 'CleanPosMatInit', 'CleanPosMat', 'CleanXtsd', 'CleanYtsd',...
    'CleanVtsd', 'CleanMaskBounary','-append');
% save([dirin_traj '/cleanBehavResources.mat'], 'CleanPosMatInit', 'CleanPosMat', 'CleanXtsd', 'CleanYtsd',...
%     'CleanVtsd', 'CleanMaskBounary','-append');

clear
end