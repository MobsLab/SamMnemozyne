function [Bintercept,Bgroup,pvalintercept,pvalgroup] = tfregression(nbsubj,wstats,datx2,wnb,t_size,f_size)
%==========================================================================
% Details:  linear regression (one regressor for now) for time-frequency
%           maps after bootstrap. Uses glmfit function
%
% INPUTS:
%       - Sp: Spectral matrices in 4D (session,markers,time,frequency)
%       - t: size of the time array
%       - lsfreq: list of frequencies 
%       - draws: number of draws for the bootstrap
%
% OUTPUTS:
%       - wstats: results from the wilcoxon analyses
%       - bts: structure containing the bootstrapped maps (pre & post)
%
% NOTES: 
%       - for data not btstrapped, do not use weights
%          
%       
% see also: glmfit,wilcox_bts,compare_spectrum.m,SpectrumParametersSL,mtspecgramc 
%
% Original written by Samuel Laventure - 31-03-2020
%       
%==========================================================================

%% --- Variable initialization ---


disp('')
disp('Processing Linear Regression')

%% 
% ------------------------------------------------------------------------- 
%                       P R E P  D A T A 
% -------------------------------------------------------------------------

ii=0;
for isubj=1:nbsubj   
    if ~isempty(wstats{isubj,1}) && ~isempty(wstats{isubj,2})
        %-- place data of all in one array
        ii=ii+1;
        dat(ii,1:t_size,1:f_size) = wstats{isubj,1};   % data group 1 || 
        ii=ii+1;
        dat(ii,1:t_size,1:f_size) = wstats{isubj,2}; % data group 2 || 

        if datx2 
            % get subject gains                
            %pgains(isubj) = gains(isubj);
        end

        %-- set CATEGORIAL VAR: group    
        xgroup(ii-1) = 0;
        xgroup(ii) = 1;
    end
end

%--- Linear Regression ---
for itime=1:t_size
    for ifreq=1:f_size
        % prepare data                 
        pdat = squeeze(dat(:,itime,ifreq));

        % if you have a second regressor
        %pinter = ygroup' .* pgains';
        %x = [ygroup' pgains' pinter];
        
        x = xgroup';

        % LINEAR Regression
        if wnb
            [B,dev,stats] = glmfit(x,pdat,'normal','link','identity','estdisp','off','weights',wnb);
        else
            [B,dev,stats] = glmfit(x,pdat,'normal','link','identity','estdisp','off');
        end
        Bintercept(itime,ifreq)=B(1);
        Bgroup(itime,ifreq)=B(2);

        pvalintercept(itime,ifreq)=stats.p(1);
        pvalgroup(itime,ifreq)=stats.p(2);         
    end
end
disp('Done.')


