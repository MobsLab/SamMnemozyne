function [wstats] = wilcox_bts_tmp(Sp,t,lsfreq,draws)
%==========================================================================
% Details: bootstrap data from pre and gr2 (could also be group 1 vs 2) selection and analyzes the
%          difference with a mann-whitney-wilcoxon analyzes. This analyses
%          is for 2 groups only. 
%          The order of the analysis is group 1 then group 2. Positive diff
%          would mean bigger diff for group 1 over group 2.
%
% INPUTS:
%       - Spt: Spectral matrices in 5D arrays (not cells)
%       (step1,trials,markers,time,frequency) from 2 groups (i.e. groups, sessions,
%       zones, etc)
%       - t: size of the time array
%       - lsfreq: list of frequencies 
%       - draws: number of draws for the bootstrap
%
% OUTPUTS:
%       - wstats: results from the wilcoxon analyses
%       - bts: structure containing the bootstrapped maps (pre & gr2)
%
% NOTES: For more groups comparison the script will
%          need adjustment and use the Kruskal-Wallis test.
%       
% see also: compare_spectrum.m,SpectrumParametersSL,mtspecgramc,RestrictSession 
%
% Original written by Samuel Laventure - 31-03-2020
%       
%==========================================================================

%% --- Variable initialization ---
f=length(lsfreq);
Sp1 = squeeze(Sp(1,:,:,:,:));
Sp2 = squeeze(Sp(2,:,:,:,:));

%% 
% ------------------------------------------------------------------------- 
%                        G R O U P   1  - B O O T S T R A P
% -------------------------------------------------------------------------

% normalize data
Sp1 = reshape(Sp1,size(Sp1,1)*size(Sp1,2),size(Sp1,3),size(Sp1,4));
basel = mean(Sp1(:,1:ceil(size(Sp1,2)*.2),:),2); % change this value to change the window for normalization
stdbase = std(Sp1(:,1:ceil(size(Sp1,2)*.2),:),0,2);  % here too
Sp1 = (Sp1 - reshape(repmat(basel,1,t),size(basel,1),t,f)) ...
                ./reshape(repmat(stdbase,1,t),size(stdbase,1),t,f);
% shape the matrix for bootstrap (pool instance of the map you want 
% to btstrap in the first field, then group the rest (the maps) all
% together with [].
gr1_tmp = reshape(Sp1,size(Sp1,1),[]);

% bootstrap function (you can change the draws number)
[bts_gr1_tmp btsam_gr1_tmp] = bootstrp(draws, @nanmean, gr1_tmp);
% reshape the matrix into a map format for vizualization (figures)
bts_gr1 = reshape(bts_gr1_tmp,draws,t,f);
bts_gr1(isnan(bts_gr1))=0;                

% ------------------------------------------------------------------------- 
%                       G R O U P  2 - B O O T S T R A P
%                           same as pre section
% -------------------------------------------------------------------------

Sp2 = reshape(Sp2,size(Sp2,1)*size(Sp2,2),size(Sp2,3),size(Sp2,4));
basel = mean(Sp2(:,1:ceil(size(Sp2,2)*.2),:),2);
stdbase = std(Sp2(:,1:ceil(size(Sp2,2)*.2),:),0,2);
Sp2 = (Sp2 - reshape(repmat(basel,1,t),size(basel,1),t,f)) ...
                ./reshape(repmat(stdbase,1,t),size(stdbase,1),t,f);
gr2_tmp = reshape(Sp2,size(Sp2,1),[]);
[bts_gr2_tmp btsam_gr2_tmp] = bootstrp(draws, @nanmean, gr2_tmp);
bts_gr2 = reshape(bts_gr2_tmp,draws,t,f);
bts_gr2(isnan(bts_gr2))=0;

% ------------------------------------------------------------------------- 
%                            W I L C O X O N
%                         need mwwtest.m function
% -------------------------------------------------------------------------

disp('...working on frequency ')
for ifreq=1:size(bts_gr1,3)
    disp([num2str(lsfreq(ifreq)) ' Hz']);
    for itime=1:size(bts_gr1,2)
        stats = [];
        stats = mwwtest(bts_gr1(:,itime,ifreq)',bts_gr2(:,itime,ifreq)');
        if stats.mr(1) < stats.mr(2)
            stats.Zsign = stats.Z*-1;
        else
            stats.Zsign = stats.Z;
        end
        wstats_map(itime,ifreq) = stats.Zsign;
    end
end
wstats = wstats_map(1:itime,1:ifreq);



