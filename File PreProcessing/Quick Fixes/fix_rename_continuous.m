
workDir = pwd;
Sfile = 'continuous_original';
SPath = dir(fullfile(pwd, '**', [Sfile '*.dat']));
    
for i=1:length(SPath)
    cd(SPath(i).folder)
    movefile('continuous_original.dat','continuous.dat')
end

cd(workDir)