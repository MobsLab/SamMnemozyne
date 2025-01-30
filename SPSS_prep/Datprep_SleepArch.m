load('SubStage_Results_50min.mat')

% MFB
expe{1} = 'StimMFBWake';
mice_num{1} = [882 941 1081 1117 1161 1162 1168 1182 1199 1199 1223 1228 1239 1239];  % mice ID #
numexpe{1} = [1 1 1 1 1 1 1 1 1 2 1 1 1 2];
% PAG 
expe{2} = 'UMazePAG';
mice_num{2} = [797 798 828 861 882 905 906 911 912 977 994 1117 1124 1161 1162 1168 1182 1186 1199];
numexpe{2} = [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
% Novel 
expe{3} = 'Novel';
mice_num{3} = [1016 1081 1083 1116 1161 1182 1183 1185 1223 1228 1230];
numexpe{3} = [1 1 1 1 1 1 1 1 1 1 1];
% BaselineSleep
expe{4} = 'BaselineSleep';
mice_num{4} = [1162 1162 1168 1168 1168 1185 1199 1230];
numexpe{4} = [1 2 1 2 3 1 1 1];
% Known
expe{5} = 'Known';
mice_num{5} = [1230 1239];
numexpe{5} = [1 1];

%% SPSS DATA PREP
clear mat

% percentage
len = length(sstage.per_nowake.nrem);
stg{1} = sstage.per_nowake.nrem;
stg{2} = sstage.per_nowake.rem;
stg{3} = sstage.per_nowake.n1;
stg{4} = sstage.per_nowake.n2;
stg{5} = sstage.per_nowake.n3;
id = sstage.miceID;
mat=nan(length(expe)*length(stg{1}),2*5);
for istg=1:5
    k=1;
    for iexp=1:length(expe)
        for isuj=1:len
            for isess=1:2
                mat(k,isess+(istg*2)-2) = stg{istg}(iexp,isess,isuj); 
                gr(k,1) = iexp;
            end
            mID(k,1) = id(isuj,iexp);
            k=k+1;
        end
    end
end

% difference
clear stg
len = length(sstage.diff_per_nowake.nrem);
stg{1} = sstage.diff_per_nowake.nrem;
stg{2} = sstage.diff_per_nowake.rem;
stg{3} = sstage.diff_per_nowake.n1;
stg{4} = sstage.diff_per_nowake.n2;
stg{5} = sstage.diff_per_nowake.n3;
matdiff=nan(length(expe)*length(stg{1}),1);
for istg=1:5
    k=1;
    for iexp=1:length(expe)
        for isuj=1:len
            matdiff(k,istg) = stg{istg}(iexp,isuj); 
            gr(k,1) = iexp;
            k=k+1;
        end
    end
end

% percentage
clear stg
len = length(sstage.dur.nrem);
stg{1} = sstage.dur.nrem;
stg{2} = sstage.dur.rem;
stg{3} = sstage.dur.n1;
stg{4} = sstage.dur.n2;
stg{5} = sstage.dur.n3;
matdur=nan(length(expe)*length(stg{1}),2*5);
for istg=1:5
    k=1;
    for iexp=1:length(expe)
        for isuj=1:len
            for isess=1:2
                matdur(k,isess+(istg*2)-2) = stg{istg}(iexp,isess,isuj); 
                gr(k,1) = iexp;
            end
            mID(k,1) = id(isuj,iexp);
            k=k+1;
        end
    end
end


%% Manually transfer to generic matrix (mat)
