load('SleepScoring_OBGamma.mat');

gamma = log(Data(SmoothGamma));
theta = log(Data(SmoothTheta));

selgam_id = find(gamma>5.972 & gamma<6.515);
selthe_id = find(theta>1.193);
%find points in area
sel_id = ismember(selgam_id,selthe_id);
arr = zeros(size(gamma));
arr(selgam_id(sel_id))=1;

%% fonction to extract sleep scoring and put it in an array
%init var
sampling = 1250;

endpt = max(max(End(SleepWiNoise)),max(End(WakeWiNoise)));
sleep_all = nan(endpt,1);
%NREM
st_nrem=int32(Start(SWSEpoch));
en_nrem=int32(End(SWSEpoch));
for i=1:length(st_nrem)
    sleep_all(st_nrem(i)+1:en_nrem(i)+1) = 1;    
end
%REM
st_rem=int32(Start(REMEpoch));
en_rem=int32(End(REMEpoch));
for i=1:length(st_rem)
    sleep_all(st_rem(i)+1:en_rem(i)+1) = 2;    
end
%WAKE
st_w=int32(Start(Wake));
en_w=int32(End(Wake));
for i=1:length(st_w)
    sleep_all(st_w(i)+1:en_w(i)+1) = 3;    
end

%% Ripples
rip=zeros(length(sleep_all),1);
ripx = int32(ripples(:,2)*1E4);
rip(ripx)=1;

% Prepare data for regression
% fit data to longest (which is sleep (seconds x 1e4), while gamma is
% seconds * sampling rate (1250))
gamma_lg = repmat(gamma,8,1);
theta_lg = repmat(theta,8,1);
arr_lg = repmat(arr,8,1);
gamma_lg = gamma_lg(1:length(sleep_all));
theta_lg = theta_lg(1:length(sleep_all));
arr_lg = arr_lg(1:length(sleep_all));




%% REGRESSION

X = [ones(size(gamma_lg)) sleep_all rip sleep_all.*rip];
[b,bint,r,rint,stats] = regress(arr_lg,X);    % Removes NaN data

figure
scatter3(sleep_all,gamma_lg,arr_lg,'filled')
hold on
x1fit = min(sleep_all):1:max(sleep_all);
x2fit = min(gamma_lg):1:max(gamma_lg);
[X1FIT,X2FIT] = meshgrid(x1fit,x2fit);
YFIT = b(1) + b(2)*X1FIT + b(3)*X2FIT + b(4)*X1FIT.*X2FIT;
mesh(X1FIT,X2FIT,YFIT)
xlabel('Sleep')
ylabel('Ripples')
zlabel('Weird stuff')
view(50,10)
hold off


%% Correlation
[R P] = corrcoef(arr_lg, sleep_all, gamma_lg, theta_lg);