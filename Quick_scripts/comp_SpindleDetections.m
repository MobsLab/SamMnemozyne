recompute=1;
save=1;
mice_num=[1117];
thresh = [2 3.5;2.5 3.5];
dirPath = [dropbox 'DataSL/Spindles/'];

Dir = PathForExperimentsERC(expe);
Dir = RestrictPathForExperiment(Dir,'nMice', mice_num);

for i=1:length(Dir.path)
    cd(Dir.path{i})
    CreateSpindlesSleep_v2('thresh',thresh,'scoring','ob');

    H = compDetectMethod_MobvsZug_spindles(recompute);
        figName = ['M' num2str(mice_num) '_SpindleComp_ZugvsMOBs'];
        saveF(H,figName,dirPath,'sformat',{'dpng'},'res',300,'savfig',0);
end