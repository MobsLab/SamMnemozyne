clear all
load('behavResources.mat')
%% Xtsd
time = Range(Xtsd);
dataX = Data(Xtsd);
newdataX = dataX;

nanx = isnan(dataX);
t    = 1:numel(dataX);
newdataX(nanx) = interp1(t(~nanx), dataX(~nanx), t(nanx));
newdataX(isnan(newdataX))=0;
Xtsd = tsd(time, newdataX);

%% Ytsd
time = Range(Ytsd);
dataY = Data(Ytsd);
newdataY = dataY;

nany = isnan(dataY);
t    = 1:numel(dataY);
newdataY(nany) = interp1(t(~nany), dataY(~nany), t(nany));
newdataY(isnan(newdataY))=0;

Ytsd = tsd(time, newdataY);

%% Vtsd
time = Range(Vtsd);
dataV = Data(Vtsd);
newdataV = dataV;

nanv = isnan(dataV);
t    = 1:numel(dataV);
newdataV(nanv) = interp1(t(~nanv), dataV(~nanv), t(nanv));
newdataV(isnan(newdataV))=0;

Vtsd = tsd(time, newdataV);

save('behavResources_Neuroencoder.mat')