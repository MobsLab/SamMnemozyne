
Chan = 'dHPC_deep';

load('C:\Users\samue\Documents\Mnemozyne\Spectral Analyses\StimPAGWake/params.mat');

expe='StimPAGWake';
subj=PAG_params.subj;
Dir = PathForExperimentsERC_SL_home(expe);
Dir = RestrictPathForExperiment(Dir,'nMice', subj);

for i=1:length(Dir.path)
    try
        load([Dir.path{1,i}{1} '/ChannelsToAnalyse/' Chan '.mat']);
        PAG_params.dHPC_deep(i) =  channel;
    catch
        PAG_params.dHPC_deep(i) =  nan;
    end
end

save('params.mat','PAG_params');

