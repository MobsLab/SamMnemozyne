%%% LatencyTest_PAGTest

clear all
%% Parameters

% General
sav=1; % Do you want to save a figure?
dir_out = '/home/mobs/Dropbox/MOBS_workingON/Sam/PAGTests/'; % Where?

 % input folder
indir = {
    '/media/DataMOBsRAIDN/ProjetPAGTest/M784/'; %ant
    '/media/DataMOBsRAIDN/ProjetPAGTest/M784/'; %post
    '/media/DataMOBsRAIDN/ProjetPAGTest/M789/'; %ant
    '/media/DataMOBsRAIDN/ProjetPAGTest/M789/'; %post
    '/media/DataMOBsRAIDN/ProjetPAGTest/M790/'; %post
    '/media/DataMOBsRAIDN/ProjetPAGTest/M791/'; %ant
    '/media/DataMOBsRAIDN/ProjetPAGTest/M792/'; %ant
    '/media/DataMOBsRAIDN/ProjetPAGTest/M792/'  %post
};
ntest = 4;
Day3 = {
    '20092018'; %ant
    '19092018'; %post
    '19092018'; %ant
    '20092018'; %post
    '19092018'; %post
    '20092018'; %ant
    '20092018'; %ant
    '19092018'  %post
    };

Day4 = {
    '21092018';
    '20092018';
    '20092018';
    '21092018';
    '20092018';
    '21092018';
    '21092018';
    '20092018'
    };

elec = {'AnteriorStim','PosteriorStim'};
ielec = [1 2 1 2 2 1 1 2];

supertit = 'All locations - PAGTest';

sufDir = {'Pretests'; 'Cond'; 'PostTests';'PostSleep'; 'Post24h'};
suf = {'pre'; 'Cond'; 'posttest';'postsleep'; 'post24h'};

clrs = {'ko', 'bo', 'ro','go'; 'k','b', 'r', 'g'; 'kp', 'bp', 'rp', 'gp'};

%% Get the data Avoidance
for j=1:length(indir)
    for i = 1:1:ntest
        % PreTests
        a{j} = load([indir{j} Day3{j} '/' elec{ielec(j)} '/' sufDir{1} '/' suf{1} num2str(i) '/behavResources.mat'], 'PosMat', 'ZoneIndices');
        PreTest_PosMat{j}{i} = a{j}.PosMat;
        PreTest_ZoneIndices{j}{i} = a{j}.ZoneIndices;
        % Cond
        if (~(j==6) || i<4)
            b{j} = load([indir{j} Day3{j} '/' elec{ielec(j)} '/' sufDir{2} '/' suf{2} num2str(i) '/behavResources.mat'], 'PosMat', 'ZoneIndices');
            Cond_PosMat{j}{i} = b{j}.PosMat;
            Cond_ZoneIndices{j}{i} = b{j}.ZoneIndices; 
        end
        if i<3
            % PostTests
            c{j} = load([indir{j} Day3{j} '/' elec{ielec(j)} '/' sufDir{3} '/' suf{3} num2str(i) '/behavResources.mat'], 'PosMat', 'ZoneIndices');
            PostTest_PosMat{j}{i} = c{j}.PosMat;
            PostTest_ZoneIndices{j}{i} = c{j}.ZoneIndices;
        end
        % PostSleep
        d{j} = load([indir{j} Day3{j} '/' elec{ielec(j)} '/' sufDir{4} '/' suf{4} num2str(i) '/behavResources.mat'], 'PosMat', 'ZoneIndices');
        PostSleep_PosMat{j}{i} = d{j}.PosMat;
        PostSleep_ZoneIndices{j}{i} = d{j}.ZoneIndices;
    
        % Post24h
        if (~(j==5) || ~(i==1))
            e{j} = load([indir{j} Day4{j} '/' elec{ielec(j)} '/' sufDir{5} '/' suf{5} num2str(i) '/behavResources.mat'], 'PosMat', 'ZoneIndices');
            Post24h_PosMat{j}{i} = e{j}.PosMat;
            Post24h_ZoneIndices{j}{i} = e{j}.ZoneIndices;
        end
    end
    
end

%% Prepare the 'first enter to shock zone' and 'entered and stayed' array
for j=1:length(indir)
    for u = 1:ntest
        if isempty(PreTest_ZoneIndices{j}{u}{1})
            Pre_FirstTime{j}(u) = 240;
            Pre_LastTime{j}(u) = 240;
        else
            Pre_FirstZoneIndices{j}(u) = PreTest_ZoneIndices{j}{u}{1}(1);
            Pre_FirstTime{j}(u) = PreTest_PosMat{j}{u}(Pre_FirstZoneIndices{j}(u),1);
            Pre_lastZoneIndices{j}(u) = PreTest_ZoneIndices{j}{u}{1}(end);
            Pre_LastTime{j}(u) = PreTest_PosMat{j}{u}(Pre_lastZoneIndices{j}(u),1);
        end
        if u<3
            if isempty(PostTest_ZoneIndices{j}{u}{1})
                Post_FirstTime{j}(u) = 240;
                Post_LastTime{j}(u) = 240;
            else
                Post_FirstZoneIndices{j}(u) = PostTest_ZoneIndices{j}{u}{1}(1);
                Post_FirstTime{j}(u) = PostTest_PosMat{j}{u}(Post_FirstZoneIndices{j}(u),1);
                Post_lastZoneIndices{j}(u) = PostTest_ZoneIndices{j}{u}{1}(end);
                Post_LastTime{j}(u) = PostTest_PosMat{j}{u}(Post_lastZoneIndices{j}(u),1);
            end
        end
        if isempty(PostSleep_ZoneIndices{j}{u}{1})
            PostSleep_FirstTime{j}(u) = 240;
            PostSleep_LastTime{j}(u) = 240;
        else
            PostSleep_FirstZoneIndices{j}(u) = PostSleep_ZoneIndices{j}{u}{1}(1);
            PostSleep_FirstTime{j}(u) = PostSleep_PosMat{j}{u}(PostSleep_FirstZoneIndices{j}(u),1);
            PostSleep_lastZoneIndices{j}(u) = PostSleep_ZoneIndices{j}{u}{1}(end);
            PostSleep_LastTime{j}(u) = PostSleep_PosMat{j}{u}(PostSleep_lastZoneIndices{j}(u),1);
        end
        if (~(j==5) || ~(u==1))
            if isempty(Post24h_ZoneIndices{j}{u}{1})
                Post24h_FirstTime{j}(u) = 240;                
                Post24h_LastTime{j}(u) = 240;
            else
                Post24h_FirstZoneIndices{j}(u) = Post24h_ZoneIndices{j}{u}{1}(1);
                Post24h_FirstTime{j}(u) = Post24h_PosMat{j}{u}(Post24h_FirstZoneIndices{j}(u),1);
                Post24h_lastZoneIndices{j}(u) = Post24h_ZoneIndices{j}{u}{1}(end);
                Post24h_LastTime{j}(u) = Post24h_PosMat{j}{u}(Post24h_lastZoneIndices{j}(u),1);
                
                disp(['folder #' num2str(j) ', test #' num2str(u) ' Data:' num2str(Post24h_FirstTime{j}(u))]);
            end
        end
    end
end

%% Prepare arrays for plotting

for j=1:length(indir)
    % Pre
    if Pre_FirstTime{j}(1)==240
        FirstPre(j) = Pre_FirstTime{j}(1)+Pre_FirstTime{j}(2);
        if FirstPre(j)==480
            FirstPre(j) = FirstPre(j)+Pre_FirstTime{j}(3);
            if FirstPre(j)==720
                FirstPre(j) = FirstPre{j}+Pre_FirstTime{j}(4);
            end
        end
    else
        FirstPre(j) = Pre_FirstTime{j}(1);
    end

    if Pre_LastTime{j}(1)==240
        LastPre(j) = Pre_LastTime{j}(1)+Pre_LastTime{j}(2);
        if LastPre(j)==480
            LastPre(j) = LastPre(j)+Pre_LastTime{j}(3);
            if LastPre(j)==720
                LastPre(j) = LastPre{j}+Pre_LastTime{j}(4);
            end
        end
    else
        LastPre(j) = Pre_LastTime{j}(1);
    end
    
   % Before Sleep
    if Post_FirstTime{j}(1)==240
        FirstPost(j) = Post_FirstTime{j}(1)+Post_FirstTime{j}(2);
    else
        FirstPost(j) = Post_FirstTime{j}(1);
    end
    
    if Post_LastTime{j}(1)==240
        LastPost(j) = Post_LastTime{j}(1)+Post_LastTime{j}(2);
    else
        LastPost(j) = Post_LastTime{j}(1);
    end
    
    % PostSleep
    if PostSleep_FirstTime{j}(1)==240
        FirstPostSleep(j) = PostSleep_FirstTime{j}(1)+PostSleep_FirstTime{j}(2);
        if FirstPostSleep(j)==480
            FirstPostSleep(j) = FirstPostSleep(j)+PostSleep_FirstTime{j}(3);
            if FirstPostSleep(j)==720
                FirstPostSleep(j) = FirstPostSleep(j)+PostSleep_FirstTime{j}(4);
            end
        end
    else
        FirstPostSleep(j) = PostSleep_FirstTime{j}(1);
    end
    if PostSleep_LastTime{j}(1)==240
        LastPostSleep(j) = PostSleep_LastTime{j}(1)+PostSleep_LastTime{j}(2);
        if LastPostSleep(j)==480
            LastPostSleep(j) = LastPostSleep(j)+PostSleep_LastTime{j}(3);
            if LastPostSleep(j)==720
                LastPostSleep(j) = LastPostSleep(j)+PostSleep_LastTime{j}(4);
            end
        end
    else
        LastPostSleep(j) = PostSleep_LastTime{j}(1);
    end
    
    % PostSleep
    if Post24h_FirstTime{j}(1)==240
        FirstPost24h(j) = Post24h_FirstTime{j}(1)+Post24h_FirstTime{j}(2);
        if FirstPost24h(j)==480
            FirstPost24h(j) = FirstPost24h(j)+Post24h_FirstTime{j}(3);
            if FirstPost24h(j)==720
                FirstPost24h(j) = FirstPost24h(j)+Post24h_FirstTime{j}(4);
            end
        end
    else
        FirstPost24h(j) = Post24h_FirstTime{j}(1);
    end
    
    if Post24h_LastTime{j}(1)==240
        LastPost24h(j) = Post24h_LastTime{j}(1)+Post24h_LastTime{j}(2);
        if LastPost24h(j)==480
            LastPost24h(j) = LastPost24h(j)+Post24h_LastTime{j}(3);
            if LastPost24h(j)==720
                LastPost24h(j) = LastPost24h(j)+Post24h_LastTime{j}(4);
            end
        end
    else
        LastPost24h(j) = Post24h_LastTime{j}(1);
    end

end
            
   
LatencyArrayFirst = [FirstPre; FirstPost; FirstPostSleep; FirstPost24h]';
LatencyArrayFirstMean = mean(LatencyArrayFirst, 1);

LatencyArrayLast = [LastPre; LastPost; LastPostSleep; LastPost24h]';
LatencyArrayLastMean = mean(LatencyArrayLast, 1);


%% Plot
%First time in shock zone
% All mice
fh1 = figure('units', 'normalized', 'outerposition', [0 0 1 0.4]);
bar(LatencyArrayFirst);
set(gca,'Xtick',[1:8],'XtickLabel',{'M784ant', 'M784post', 'M789ant', 'M789post', 'M790post', 'M791ant', 'M792ant', '792post'});
legend('Pre-Test', 'Post-Test', 'Post-Sleep', 'Post-24h');
ylabel('Time (s)');
title ('First time to enter the shockzone');

saveas(fh1, [dir_out 'TimeToShockzone.fig']);
saveFigure(fh1,'TimeToShockzone',dir_out);

% Averaged
fh2 = figure('units', 'normalized', 'outerposition', [0.1 0.1 0.7 0.7]);
PlotErrorBarN_KJ(LatencyArrayFirstMean, 'barcolors', [0.3 0.266 0.613], 'newfig', 0);
set(gca,'Xtick',[1:4],'XtickLabel',{'Pre-Test', 'Post-Test', 'Post-Sleep', 'Post-24h'}, 'FontSize', 16);
ylabel('Time (s)', 'FontSize', 16);
title ('First time to enter the shockzone', 'FontSize', 16);

saveas(fh2, [dir_out 'TimeToShockzone_mean.fig']);
saveFigure(fh2,'TimeToShockzone_mean',dir_out);

%%
%% Not good because it shows last time the animal went into the zone, wether it stayed or left before threshold time. 

% % Last time in shock zone
% % All mice
% fh1 = figure('units', 'normalized', 'outerposition', [0 0 1 0.4]);
% bar(LatencyArrayLast);
% set(gca,'Xtick',[1:8],'XtickLabel',{'M784ant', 'M784post', 'M789ant', 'M789post', 'M790post', 'M791ant', 'M792ant', '792post'});
% legend('Pre-Test', 'Post-Test', 'Post-Sleep', 'Post-24h');
% ylabel('Time (s)');
% title ('Time to enter the shockzone (with shock timer)');
% 
% saveas(fh1, [dir_out 'TimeToShockzoneEnd.fig']);
% saveFigure(fh1,'TimeToShockzoneEnd',dir_out);
% 
% % Averaged
% fh2 = figure('units', 'normalized', 'outerposition', [0.1 0.1 0.7 0.7]);
% PlotErrorBarN_KJ(LatencyArrayLastMean, 'barcolors', [0.3 0.266 0.613], 'newfig', 0);
% set(gca,'Xtick',[1:4],'XtickLabel',{'Pre-Test', 'Post-Test', 'Post-Sleep', 'Post-24h'}, 'FontSize', 16);
% ylabel('Time (s)', 'FontSize', 16);
% title ('Avereaged time to enter the shockzone (with shock timer)', 'FontSize', 16);
% 
% saveas(fh2, [dir_out 'TimeToShockzoneEnd_mean.fig']);
% saveFigure(fh2,'TimeToShockzoneEnd_mean',dir_out);
   
    
    
    
    
    
    
    