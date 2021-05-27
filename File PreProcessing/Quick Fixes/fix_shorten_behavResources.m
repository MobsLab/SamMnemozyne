
function fix_shorten_behavResources(dur)

% Script correcting behavRessources to match a desired length (SHORTHEN IT)
% makes a copy of your original behavResources adding "_old" as suffixe.
% This script is useful if your ephys recording crashed before the end but
% the .dat is intact. 
%
%       dur         time in SECONDS when the recording should stop
%
% written by SL - 2020

disp('Backing up old behavResources.mat')
copyfile('behavResources.mat','behavResources_old.mat');

load('behavResources.mat')

% recording duration
durts = intervalSet(1,dur*1e4);

% find end position
end_id = find(PosMat(:,1)<dur,1,'last');

PosMat = PosMat(1:end_id,:);
CleanPosMat = CleanPosMat(1:end_id,:);
CleanVtsd = Restrict(CleanVtsd,durts);
CleanXtsd = Restrict(CleanXtsd,durts);
CleanYtsd = Restrict(CleanYtsd,durts);
GotFrame = GotFrame(1,1:end_id);

im_diff = im_diff(1:end_id,:);
im_diffInit = im_diffInit(1:end_id,:);
Imdifftsd = Restrict(Imdifftsd,durts);
MouseTemp = MouseTemp(1:end_id,:);
PosMatInit = PosMatInit(1:end_id,:);
Vtsd = Restrict(Vtsd,durts);
Xtsd = Restrict(Xtsd,durts);
Ytsd = Restrict(Ytsd,durts);

FreezeEpoch = and(FreezeEpoch,durts);
for i=length(ZoneEpoch)
    ZoneEpoch{1,i} = and(ZoneEpoch{1,i},durts);
end

clear dur durts end_id

save('behavResources.mat')
