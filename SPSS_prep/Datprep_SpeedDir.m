
clear all

expe{1} = 'StimMFBWake'; 
expn{1} = 1;
expe{2} = 'UMazePAG';
expn{2} = 2;
mice_num{1} =  [882 941 1117 1161 1162 1168];  
% mice_num{1} =  [863 934 913 882 941 081 1117 1124 1161 1162 1168];  
mice_num{2} =  [798 828 861 882 905 906 911 912 977 994 1117 1124 1161 1162 1168];  

nbt=4;
nbtcond=4;
%--------------- GET DIRECTORIES-------------------
for iexp=1:2
    Dir{iexp} = PathForExperimentsERC(expe{iexp});
    Dir{iexp} = RestrictPathForExperiment(Dir{iexp},'nMice', mice_num{iexp});
end

% format: pre1...pre8;cond1...cond8;post1....post8
pos.pre_to = [1:nbt];
pos.cond_to = [pos.pre_to(end)+1:pos.pre_to(end)+nbtcond];
pos.post_to = [pos.cond_to(end)+1:pos.cond_to(end)+nbt];
pos.pre_aw  = [pos.post_to(end)+1:pos.post_to(end)+nbt];
pos.cond_aw = [pos.pre_aw(end)+1:pos.pre_aw(end)+nbt];
pos.post_aw = [pos.cond_aw(end)+1:pos.cond_aw(end)+nbt];


%% Get data
datspeed.data=[]; 
datspeed_all.data=[];
count=1; count_all=1;
for iexp=1:length(expe)
    for i = 1:length(Dir{iexp}.path)
        load([Dir{iexp}.path{i}{1} '/behavResources.mat'], 'SpeedDir');  
        if count_all
            datspeed_all.exp{1} = expn{iexp}; 
            datspeed_all.ID{1} = mice_num{iexp}(i); 
            datspeed_all.OK{1} = 1;
            count_all=0;
        else
            datspeed_all.exp{end+1,1} = expn{iexp}; 
            datspeed_all.ID{end+1,1} = mice_num{iexp}(i); 
            datspeed_all.OK{end+1,1} = 1;
        end
        sz = size(datspeed_all.data,1)+1;
        nt = size(SpeedDir.speed,2);
        if nt>nbt
            nt=nbt;
        end
        % all on one line
        datspeed_all.data(sz,pos.pre_to(1):pos.pre_to(1)+nt-1)   = SpeedDir.speed(1,1:nt,1);
        datspeed_all.data(sz,pos.cond_to(1):pos.cond_to(1)+nt-1) = SpeedDir.speed(2,1:nt,1);
        datspeed_all.data(sz,pos.post_to(1):pos.post_to(1)+nt-1) = SpeedDir.speed(3,1:nt,1);
        datspeed_all.data(sz,pos.pre_aw(1):pos.pre_aw(1)+nt-1)   = SpeedDir.speed(1,1:nt,2);
        datspeed_all.data(sz,pos.cond_aw(1):pos.cond_aw(1)+nt-1) = SpeedDir.speed(2,1:nt,2);
        datspeed_all.data(sz,pos.post_aw(1):pos.post_aw(1)+nt-1) = SpeedDir.speed(3,1:nt,2);
        datspeed_all.data(datspeed_all.data==0) = NaN;
        if iexp==2
            datspeed_all.data(sz,:)=datspeed_all.data(sz,:)*1.25;
        end
        for isess=1:3
            for idir=1:2
                if count==1
                    datspeed.exp{1} = expn{iexp}; 
                    datspeed.ID{1} = mice_num{iexp}(i); 
                    datspeed.OK{1} = 1;
                    datspeed.sess{1} = isess;
                    datspeed.dir{1} = idir;
                    count=0;
                else
                    datspeed.exp{end+1,1} = expn{iexp}; 
                    datspeed.ID{end+1,1} = mice_num{iexp}(i); 
                    datspeed.OK{end+1,1} = 1;
                    datspeed.sess{end+1,1} = isess;
                    datspeed.dir{end+1,1} = idir;
                end
                sz = size(datspeed.data,1)+1;
                nt = size(SpeedDir.speed,2);
                datspeed.data(sz,1:nt) = SpeedDir.speed(isess,1:nt,idir);
                if iexp==2
                    datspeed.data(sz,:)=datspeed.data(sz,:)*1.25;
                end
            end
        end
        clear SpeedDir
    end
        
end

%% saving
outPath = '/DataSL/StimMFBWake/DataSPSS/'; 
fullPath = [dropbox outPath];
save([fullPath 'Global_SpeedDir_' date '.mat'],'datspeed','datspeed_all');
% special case for Matlab on Linux using in root 
if isunix
    system(['sudo chown -R mobs ' fullPath]);
end
