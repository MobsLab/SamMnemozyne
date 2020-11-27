FinalFolder = pwd;

for f = 1:length(ExpeInfo.PreProcessingInfo.FolderForConcatenation_Ephys)
    if ExpeInfo.PreProcessingInfo.IntanRecorded{f} == 0
        %% go to folder
        cd(ExpeInfo.PreProcessingInfo.FolderForConcatenation_Ephys{f})
        disp(ExpeInfo.PreProcessingInfo.FolderForConcatenation_Ephys{f})
%% Get the true time of the beginning and the end of the folders

        %Sanity check :  the foldername should finish with the time int TimeBeginRec
        out_ind = regexp(ExpeInfo.PreProcessingInfo.FolderForConcatenation_Ephys{f}, 'continuous');
        StartFile = dir([ExpeInfo.PreProcessingInfo.FolderForConcatenation_Ephys{f}(1:out_ind-1) '*.oebin']);
        if isempty(StartFile)
            error('structure.oebin was not found. It should be present at the same level as "continuous" folder');
        end
        ind_start=strfind(StartFile.date,':');
        TimeBeginRec_Allfiles(f,1:3)=[str2num(StartFile.date(ind_start(1)-2:ind_start(1)-1)),...
            str2num(StartFile.date(ind_start(1)+1:ind_start(2)-1)),str2num(StartFile.date(ind_start(2)+1:end))];

        StopFile=dir('*.dat');
        ind_stop=strfind(StopFile.date,':');
        TimeEndRec_Allfiles(f,1:3)=[str2num(StopFile.date(ind_stop(1)-2:ind_stop(1)-1)),...
            str2num(StopFile.date(ind_stop(1)+1:ind_stop(2)-1)),str2num(StopFile.date(ind_stop(2)+1:end))];

        disp(['File starts at ' num2str(TimeBeginRec_Allfiles(f,1:3)) ' and ends at ' num2str(TimeEndRec_Allfiles(f,1:3))])
    end
end
cd(FinalFolder)
%% save the times
TimeEndRec = TimeEndRec_Allfiles(end,:);
TimeBeginRec = TimeBeginRec_Allfiles(1,:);
save([FinalFolder filesep 'TimeRec.mat'],'TimeEndRec','TimeBeginRec','TimeEndRec_Allfiles','TimeBeginRec_Allfiles')
        

                