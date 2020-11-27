function [wstats,bts_pre,bts_post] = wilcox_bts_old(Sp_pre,Sp_post,t,lsfreq,draws)
%==========================================================================
% Details: bootstrap data from pre and post (could also be group 1 vs 2) selection and analyzes the
%          difference with a mann-whitney-wilcoxon analyzes
%
% INPUTS:
%       - Sp_pre & Sp_post: Spectral matrices in 4D arrays (not cells)
%       (session,markers,time,frequency) from 2 groups (groups, sessions,
%       zones, etc)
%       - t: size of the time array
%       - lsfreq: list of frequencies 
%       - draws: number of draws for the bootstrap
%
% OUTPUTS:
%       - wstats: results from the wilcoxon analyses
%       - bts: structure containing the bootstrapped maps (pre & post)
%
% NOTES: 
%       
% see also: compare_spectrum.m,SpectrumParametersSL,mtspecgramc,RestrictSession 
%
% Original written by Samuel Laventure - 31-03-2020
%       
%==========================================================================

%% --- Variable initialization ---
f=length(lsfreq);

%% 
% ------------------------------------------------------------------------- 
%                        P R E  - B O O T S T R A P
% -------------------------------------------------------------------------

% normalize data
Sp_pre = reshape(Sp_pre,size(Sp_pre,1)*size(Sp_pre,2),size(Sp_pre,3),size(Sp_pre,4));
basel = mean(Sp_pre(:,1:ceil(size(Sp_pre,2)*.2),:),2); % change this value to change the window for normalization
stdbase = std(Sp_pre(:,1:ceil(size(Sp_pre,2)*.2),:),0,2);  % here too
Sp_pre = (Sp_pre - reshape(repmat(basel,1,t),size(basel,1),t,f)) ...
                ./reshape(repmat(stdbase,1,t),size(stdbase,1),t,f);
% shape the matrix for bootstrap (pool instance of the map you want 
% to btstrap in the first field, then group the rest (the maps) all
% together with [].
pre_tmp = reshape(Sp_pre,size(Sp_pre,1),[]);

% bootstrap function (you can change the draws number)
[bts_pre_tmp btsam_pre_tmp] = bootstrp(draws, @nanmean, pre_tmp);
% reshape the matrix into a map format for vizualization (figures)
bts_pre = reshape(bts_pre_tmp,draws,t,f);
bts_pre(isnan(bts_pre))=0;                

% ------------------------------------------------------------------------- 
%                       P O S T  - B O O T S T R A P
%                           same as pre section
% -------------------------------------------------------------------------

Sp_post = reshape(Sp_post,size(Sp_post,1)*size(Sp_post,2),size(Sp_post,3),size(Sp_post,4));
basel = mean(Sp_post(:,1:ceil(size(Sp_post,2)*.2),:),2);
stdbase = std(Sp_post(:,1:ceil(size(Sp_post,2)*.2),:),0,2); 
Sp_post = (Sp_post - reshape(repmat(basel,1,t),size(basel,1),t,f)) ...
                ./reshape(repmat(stdbase,1,t),size(stdbase,1),t,f);
post_tmp = reshape(Sp_post,size(Sp_post,1),[]);
[bts_post_tmp btsam_post_tmp] = bootstrp(draws, @nanmean, post_tmp);
bts_post = reshape(bts_post_tmp,draws,t,f);
bts_post(isnan(bts_post))=0;

% ------------------------------------------------------------------------- 
%                            W I L C O X O N
%                         need mwwtest.m function
% -------------------------------------------------------------------------

disp('...working on frequency ')
for ifreq=1:size(bts_pre,3)
    disp([num2str(lsfreq(ifreq)) ' Hz']);
    for itime=1:size(bts_pre,2)
        stats = [];
        stats = mwwtest(bts_post(:,itime,ifreq)',bts_pre(:,itime,ifreq)');
        if stats.mr(1) < stats.mr(2)
            stats.Zsign = stats.Z*-1;
        else
            stats.Zsign = stats.Z;
        end
        wstats_map(itime,ifreq) = stats.Zsign;
    end
end
wstats = wstats_map(1:itime,1:ifreq);

bts.pre = bts_pre;
bts.post = bts_post;


