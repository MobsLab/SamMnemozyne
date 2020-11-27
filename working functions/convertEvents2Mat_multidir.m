
mainPath = pwd;
% find all exp folders
FileList = dir(fullfile(cd, '**', '*.oebin'));

for idir=1:length(FileList)
    cd(FileList(idir).folder)
    convertEvents2Mat;
end

cd(mainPath);
