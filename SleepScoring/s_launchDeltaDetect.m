function s_launchDeltaDetect(expe,subj,ss,thresh)


% Get directories
% if strcmp(expe,'StimMFBWake') || strcmp(expe,'Novel')
%     Dir = PathForExperimentsERC_SL(expe);
% elseif strcmp(expe,'UMazePAG') 
%     Dir = PathForExperimentsERC_Dima(expe);
% else    
%     warning('Exited. Verify experiment name');
%     return
% end
Dir = PathForExperimentsERC(expe);
% Dir = PathForExperimentsERC_SL(expe);
Dir = RestrictPathForExperiment(Dir,'nMice', subj);

% get sessions id and timepoints
if strcmp(expe,'BaselineSleep')
    load([Dir.path{1}{1} 'TimeRec.mat'], 'TimeBeginRec','TimeEndRec');
    % create pre-sleep segment (first 2hrs)
    tdatpre{1}{1} = intervalSet(1,9000*1e4);
    % create post-sleep segment (2hrs)
    t1={[num2str(TimeBeginRec(1)) ':' num2str(TimeBeginRec(2)) ':' num2str(TimeBeginRec(3))]};
    t2={'15:30:00'};
    poststart = seconds(diff(datetime([t1;t2])))*1e4;
    postend = poststart+(9000*1e4);
    tdatpost{1}{1} = intervalSet(poststart,postend);   
    %check length
    clear t2
    t2={[num2str(TimeEndRec(1)) ':' num2str(TimeEndRec(2)) ':' num2str(TimeEndRec(3))]};
    totdur = seconds(diff(datetime([t1;t2])))*1e4;
    if totdur<postend
        disp('PostSleep session end happens after the end of the session.' );
        disp('Check your times and/or change the start of the post sleep session in the script');
        return
    else
        SleepEpochs.pre = tdatpre{1}{1};
        SleepEpochs.post = tdatpost{1}{1};
        save([Dir.path{1}{1} 'behavResources.mat'],'SleepEpochs','-append');
        disp('behavResources updated');
    end
else
    try
        [id_pre, tdatpre] = RestrictSession(Dir,'PreSleep');  %add variable for session to call
    catch
        [id_pre, tdatpre] = RestrictSession(Dir,'BaselineSleep');
    end
    [id_post, tdatpost] = RestrictSession(Dir,'PostSleep');
end
%% detect deltas
[deltas_pre alldeltas_pre deltas_Info_pre] = CreateDeltaWavesSleep_epoch('recompute',1, ...
    'scoring',ss,'epoch',tdatpre{1}{1},'thresh',thresh);
[deltas_post alldeltas_post deltas_Info_post] = CreateDeltaWavesSleep_epoch('recompute',1, ...
    'scoring',ss,'epoch',tdatpost{1}{1},'thresh',thresh);

%% save
if exist('DeltaWaves.mat', 'file') == 2
    save('DeltaWaves.mat','deltas_pre','alldeltas_pre','deltas_Info_pre', ...
        'deltas_post','alldeltas_post','deltas_Info_post','-append')
else
    save('DeltaWaves.mat','deltas_pre','alldeltas_pre','deltas_Info_pre', ...
        'deltas_post','alldeltas_post','deltas_Info_post')
end

%extension evt
extens{1} = 'pre'; extens{2} = 'pos';
% evt pre
evt{1}.time = (Start(deltas_pre) + End(deltas_pre)) / 2E4;
for i=1:length(evt{1}.time)
    evt{1}.description{i} = ['deltawaves_pre'];
end
% evt post
evt{2}.time = (Start(deltas_post) + End(deltas_post)) / 2E4;
for i=1:length(evt{2}.time)
    evt{2}.description{i}= ['deltawaves_post'];
end
for i=1:2
    %create
    delete(['deltawaves.evt.' extens{i}]);
    CreateEvent(evt{i},'deltawaves',extens{i});
end

%% set NREM features
[featuresNREM_sess{1}, Namesfeatures_sess{1}, EpochSleep_sess{1}, NoiseEpoch_sess{1}, scoring_sess{1}] = ...
    FindNREMfeatures_epoch('scoring',ss,'sess','pre','epoch',tdatpre{1}{1});
[featuresNREM_sess{2}, Namesfeatures_sess{2}, EpochSleep_sess{2}, NoiseEpoch_sess{2}, scoring_sess{2}] = ...
    FindNREMfeatures_epoch('scoring',ss,'sess','post','epoch',tdatpost{1}{1});
save('FeaturesScoring.mat', 'featuresNREM_sess', 'Namesfeatures_sess', 'EpochSleep_sess', 'NoiseEpoch_sess', 'scoring_sess','-append')

[Epoch_sess{1}, NameEpoch_sess{1}] = SubstagesScoring(featuresNREM_sess{1}, NoiseEpoch_sess{1},'burstis3',1,'removesi',1,'newburstthresh',0);
[Epoch_sess{2}, NameEpoch_sess{2}] = SubstagesScoring(featuresNREM_sess{2}, NoiseEpoch_sess{2},'burstis3',1,'removesi',1,'newburstthresh',0);
save('SleepSubstages.mat', 'Epoch_sess', 'NameEpoch_sess','-append');

%% Creating deep/sup
disp('Delta waves analysis (deep & sup)')
%pre 
load('IdFigureData','Msup_short_delta');
if ~exist('Msup_short_delta_pre','var')
%     [meancurve, ~] = MakeIDfunc_Deltas('mua', []);
    [meancurve_pre, meancurve_post, ~, ~] = MakeIDfunc_Deltas_bysess('mua', []);
    %pre
    if ~isempty(meancurve_pre.short.sup)
        Msup_short_delta_pre = meancurve_pre.short.sup; 
        Msup_long_delta_pre = meancurve_pre.long.sup;  
    end
    Mdeep_short_delta_pre  = meancurve_pre.short.deep;
    Mdeep_long_delta_pre  = meancurve_pre.long.deep;
    Mmua_short_delta_pre  = meancurve_pre.short.mua; 
    Mmua_long_delta_pre  = meancurve_pre.long.mua;
    
    %post
    if ~isempty(meancurve_post.short.sup)
        Msup_short_delta_post = meancurve_post.short.sup; 
        Msup_long_delta_post = meancurve_post.long.sup;  
    end
    Mdeep_short_delta_post  = meancurve_post.short.deep;
    Mdeep_long_delta_post  = meancurve_post.long.deep;
    Mmua_short_delta_post  = meancurve_post.short.mua; 
    Mmua_long_delta_post  = meancurve_post.long.mua;
    
    if ~isempty(meancurve_pre.short.sup)
        save DeltaWaves -append Msup_short_delta_pre Mdeep_short_delta_pre Msup_long_delta_pre Mdeep_long_delta_pre ...
                                Msup_short_delta_post Mdeep_short_delta_post Msup_long_delta_post Mdeep_long_delta_post
    else
        save DeltaWaves -append Mdeep_short_delta_pre Mdeep_long_delta_pre ...
                                Mdeep_short_delta_post Mdeep_long_delta_post
    end
    
else
    disp('already done')
end

disp('ALL DONE')