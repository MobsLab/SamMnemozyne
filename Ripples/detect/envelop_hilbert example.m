% Test example for hilbert envelop adaptive threshold
% you will need some EEG data in eeglab format

% setup
LP = 16;                                                                    % low-pass filter
HP = 11;                                                                    % high-pass filter
CH = 1;                                                                     % channel of interest index
F = 1;                                                                      % factor to multiply sampling frequency. smoother envelope > SamplingFrequency, less smooth < SamplingFrequency
eventType = 'Spindle';                                                      % name of event
filename = 'testfile';                                                      % output file name
filepath = pwd;                                                             % output file path
EEGfilt = pop_eegfiltnew(EEG, 'locutoff',HP,'hicutoff',LP);                 % filter to frequency range of interest
y = EEGfilt.data(CH)';                                                      % select channel of interest and transpose signal
SamplingFrequency = EEG.srate;                                              % EEG sampling rate
Smooth_window = round(F*SamplingFrequency);                                 % smoothing window size
threshold_style = 1;                                                        % type of threshold. 1 = auto
DURATION = round(F*SamplingFrequency);                                      % adaptive threshold duration parameter
gr = 1;                                                                     % output figure = 1
merge = 1;                                                                  % merge old events with new events = 1

% run event detection
alarm = envelop_hilbert(y,Smooth_window,threshold_style,DURATION,gr);

% create eeglab event structure
events = diff(alarm);
onsets = find(events==1);
offsets = find(events==-1);
for nevt = 1:length(onsets)
    event(nevt).type = eventType;
    event(nevt).latency = onsets(nevt);
    event(nevt).duration = offsets(nevt)-onsets(nevt)+1;
    event(nevt).urevent = nevt;
end

% merge events
if merge ==1
    EEG.event = [EEG.event event];
else
    EEG.event = event;
end

% check it and save it
EEG=eeg_checkset(EEG,'eventconsistency');
EEG=eeg_checkset(EEG);
pop_saveset(EEGtemp, 'filename', filename, 'filepath', filepath, 'savemode', 'onefile');