function fix_ripfreq(expe,mice_num)

% set freq band
frequency_band = [120 220];
frequency = 1250; 

% get directories from PathForExp
for i=1:length(expe)
    Dir{i} = PathForExperimentsERC(expe{i});
    Dir{i} = RestrictPathForExperiment(Dir{i}, 'nMice', unique(mice_num{i}));
end

disp('Getting data...')
nsuj=0;
for iexp=1:length(expe)
    disp('=========================')
    disp(['    ' expe{iexp}])
    disp('=========================')
    for isuj = 1:length(Dir{iexp}.path)
        for iisuj=1:length(Dir{iexp}.path{isuj})
            % write to screen
            disp(['   ' num2str(mice_num{iexp}(isuj))])
            % load ripples
            load([Dir{iexp}.path{isuj}{iisuj} 'SWR.mat'], 'ripples','RipplesEpoch'); 
            if ~exist('ripples','var')
                disp(['      No ripple file for mouse #' num2str(mice_num{iexp}(isuj)) ' in exp ' expe{iexp}])
            else
                %load rip channel LFP
                load([Dir{iexp}.path{isuj}{iisuj} 'ChannelsToAnalyse/dHPC_rip'],'channel');
                if isempty(channel)||isnan(channel), error('channel error'); end
                load([Dir{iexp}.path{isuj}{iisuj} 'LFPData/LFP' num2str(channel)]);
                % filter LFP
                FiltLFP = FilterLFP(LFP, frequency_band, 1024);

                % Detect instantaneous frequency
                st_ss = ripples(:,1)*1E4; %Start(RipplesEpoch);
                en_ss = ripples(:,3)*1E4; %Stop(RipplesEpoch);
                freq = zeros(length(st_ss),1);
                j=0;
                for i=1:length(st_ss)
                    if st_ss(i)~=en_ss(i)
                        % resample ripples data to be 30 times more detailed 
                        % find maxima rather than minima where spikes are
                        peakIx = LocalMaxima(resample(Data(Restrict(FiltLFP,intervalSet(st_ss(i),en_ss(i))))...
                            , 30 , 1) , 4 ,0); 
                    else
                        % set ID of event for deletion
                        j=j+1;
                        bad_rip_id(j) = i;
                        peakIx=[];
                    end
                    if ~isempty(peakIx)
                        freq(i) = frequency/(median(diff(peakIx))/30);
                    else
                        freq(i) = nan;
                    end
                end
        
                % save new freq
                ripples(:,5) = freq;

                % backup old file
                copyfile([Dir{iexp}.path{isuj}{iisuj} 'SWR.mat'],[Dir{iexp}.path{isuj}{iisuj} 'SWR_oldfreq.mat']);
                % save new freq
                try
                    save([Dir{iexp}.path{isuj}{iisuj} 'SWR.mat'],'ripples','bad_rip_id','-append');
                catch
                    save([Dir{iexp}.path{isuj}{iisuj} 'SWR.mat'],'ripples','-append');
                end
                
                % note if bad ripples
                if j
                    disp([num2str(length(bad_rip_id)) ' bad ripples (events with 0 duration) were detected.Check bad_rip_id in SWR.mat - it correspond to RipplesEpoch and not ripples.'])
                end
            end
            clear LFP FiltLFP st_ss en_ss freq peakIx channel ripples RipplesEpoch
        end
    end
end
disp('=========================')
disp('        COMPLETED')
disp('=========================')