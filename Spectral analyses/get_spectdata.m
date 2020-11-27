function [dataspec, t_spec, f_spec, tfmean, t_size] = get_spectdata(freqband, LFP, markers, noiseEpoch, windur)
%==========================================================================
% Details: get spectral data from specified LFP
%
% INPUTS:
%       - freqband: frequency band to extract (now, only 2 options: 'low'
%                   -> 0.1-20 Hz; 'high' -> 20-200Hz)
%       - LFP: TSD object containing LFP signal of one derivation
%       - markers: interval set of targeted timepoints (to extract)
%       - noiseEpoch: interval Set of noise epochs. If no noise leave empty
%                    (i.e. noiseepoch = [])
%       - windur: duration of half a window around marker point 
%                 (i.e. for a window of 5s total, windur = 2.5s) 
%
% OUTPUTS:
%       - dataspec: spectral info of markers
%       - tspec: spectral timepoints 
%       - fspec: frequencies extracted
%
% NOTES: 
%       - Don't forget to set your parameters within this section
%       - For now only gives freq for 'low' (0.1-20) and high (20-200)
%       
% see also: compare_spectrum.m,SpectrumParametersSL,mtspecgramc,RestrictSession 
%
% Original written by Samuel Laventure - 29-03-2020
%       
%==========================================================================
%var init
mrktime=[]; tf_temp=[]; noisefree=0; 

mrk = Start(markers);

% set spectral parameters
[params,movingwin,suffix]=SpectrumParametersSL(freqband); % low or high
dataspec=[]; t_spec=[]; f_spec=[]; tfmean=[]; t_size=[];

if ~isempty(mrk)   % check if there is actual markers to extract
    for imrk=1:length(mrk)
        % var init
        tf_temp = [];
        %get array of timepoints around marker
        mrktime = intervalSet(mrk(imrk)-windur, mrk(imrk)+windur); 
        if ~isempty(noiseEpoch)
            noisee = intersect(noiseEpoch,mrktime);
            if isempty(Start(noisee))
                noisefree = noisefree+1;
                % extract spectral information
                [dataspec{noisefree},t_spec{noisefree},f_spec]= ...
                        mtspecgramc(Data(Restrict(LFP, mrktime)),movingwin,params); 
                % get extracted matrix size    
                [t_size f_size] = size(dataspec{noisefree});
                tf_temp(noisefree,1:t_size,1:f_size) = dataspec{noisefree};                
            end
        else
            % extract spectral information
            [dataspec{imrk},t_spec{imrk},f_spec]= ...
                    mtspecgramc(Data(Restrict(LFP, mrktime)),movingwin,params); 
            [t_size f_size] = size(dataspec{imrk});
            tf_temp(imrk,1:t_size,1:f_size) = dataspec{imrk};  
        end
    end    
    
    % calculating means 
    if ~isempty(noiseEpoch)
        if noisefree > 1 
            tfmean(1:t_size,1:f_size) = squeeze(mean(tf_temp(:,:,:)));
        elseif noisefree == 1
            tfmean(1:t_size,1:f_size) = squeeze(tf_temp(:,:,:));
        end
    else
        if imrk > 1 
            tfmean(1:t_size,1:f_size) = squeeze(mean(tf_temp(:,:,:)));
        elseif imrk == 1
            tfmean(1:t_size,1:f_size) = squeeze(tf_temp(:,:,:));
        end
    end
else
    disp('No markers for this session/segment')
end 


