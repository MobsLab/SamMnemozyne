%% Script to fix timestemp are nto aligned (due to intan rec not stopped correctly at one point).
%Quick setup from LastStepDoProecssing
%% File by file preparation for concatenation
clear all
load('ExpeInfo.mat')
BaseFileName = ['M' num2str(ExpeInfo.nmouse) '_' ExpeInfo.date '_' ExpeInfo.SessionType];
FinalFolder = cd;

SetCurrentSession([BaseFileName '.xml'])

tpsCatEvt = MakeData_CatEvents(FinalFolder);

switch ExpeInfo.PreProcessingInfo.IsThereBehav
    case 'Yes'
        
        if ~strcmpi(ExpeInfo.CameraType, 'None')
            if  length(ExpeInfo.PreProcessingInfo.FolderForConcatenation_Behav)==1
                copyfile([ExpeInfo.PreProcessingInfo.FolderForConcatenation_Behav{1} filesep 'behavResources.mat'],...
                    [FinalFolder filesep 'behavResources-temp.mat']);
                TempVar = load([FinalFolder filesep 'behavResources-temp.mat']);
                save([FinalFolder filesep 'behavResources.mat'],'-struct','TempVar','-append')
                delete([FinalFolder filesep 'behavResources-temp.mat'])
                
            else
                for f = 1:length(ExpeInfo.PreProcessingInfo.FolderForConcatenation_Behav)
                    
%                     copyfile([ExpeInfo.PreProcessingInfo.FolderForConcatenation_Behav{f} filesep 'behavResources.mat'],...
%                         [FinalFolder filesep 'behavResources-' sprintf('%02d',f) '.mat']);
                    filelist{f} = [FinalFolder filesep 'behavResources-' sprintf('%02d',f) '.mat'];
                    
                end
                BehavResourcesConcatenation(filelist, ExpeInfo.PreProcessingInfo.FolderSessionName, tpsCatEvt, FinalFolder)
            end
        end
        
    case 'No'
end

disp('All done, you''re good! Jesus loves you. And your momma too')
disp('All hail the Holy Octopus')


%% FIX





%Then use this script changing the correct session in
%BehavResourcesConcatenation.m
%

st = cell2mat(tpsCatEvt);
% the following loop fix automatically the errors in time by adding time at the end of session to match behavior to intan recordings. 
idif=1;
for i=1:size(ImdifftsdTimeTemp,2)-1
    endtime(i) = ImdifftsdTimeTemp{1,i}(end);
    sttime(i) = ImdifftsdTimeTemp{1,i+1}(1);
    difftime(i) = endtime(i)-sttime(i);
    if difftime(i) > 0
        id_diff(idif)=i;
        idif=idif+1;
        st(i*2:end)=st(i*2:end)+((difftime(i)+1000)/1E4); 
    end
end

%st(38:end)=st(38:end)+500;    %change 1) the session number found in ImdifftsdTime and 2) the amount to add (time/1e4)
ff=st;
st = st(1:2:end);
en =ff;
en = en(2:2:end);

for i=1:length(st)
    duration(i) = en(i)-st(i);
    lasttime(i) = en(i);
end    

%% Check for time inconsistencies
for i=1:length(FilesList)
    ImdifftsdTimeTemp{i} = Range(a{i}.Imdifftsd);
end
for i=1:(length(FilesList)-1)
    ImdifftsdTimeTemp{i+1} = ImdifftsdTimeTemp{i+1}+sum(duration(1:i))*1e4;
end
ImdifftsdTime = ImdifftsdTimeTemp{1};
for i = 2:length(FilesList)
    ImdifftsdTime = [ImdifftsdTime; ImdifftsdTimeTemp{i}];
    figure,plot(ImdifftsdTime)
end

% Find bad session by plotting IMDiff then find the problematic session
% using ImDifftsdTime
figure,plot(ImdifftsdTime)
adif =  diff(ImdifftsdTime);
disp('This should be empty');
find(adif<0) 

%% Run this when completed
clear ImdifftsdTimeTemp ImdifftsdTime
%Then press the "continue" button on top
