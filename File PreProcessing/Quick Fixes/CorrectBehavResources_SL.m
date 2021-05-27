%% Load data
mice = [882];
Dir = PathForExperimentsERC_SL('StimMFBWake');
Dir = RestrictPathForExperiment(Dir, 'nMice', mice);

for imouse = 1:length(Dir.path)
    
    cd(Dir.path{imouse}{1});
    try
        load('behavResources.mat');
    catch
        load([pwd '/Old_behavResources/behavResources.mat']);
    end
    mkdir('Old_behavResources');
    if ~exist([pwd '/Old_behavResources/behavResources.mat'],'file')
        copyfile('behavResources.mat', [pwd '/Old_behavResources']);
    else
        disp('behavResources already backed up. Skipping copyfile. ')
    end
    
    %% Create info
    Info.Align = true;
    Info.Clean = true;
    
    %% Create a backup old variables
    Old.Xtsd = Xtsd;
    Old.Ytsd = Ytsd;
    Old.Vtsd = Vtsd;
    Old.CleanXtsd = CleanXtsd;
    Old.CleanYtsd = CleanYtsd;
    Old.CleanVtsd = CleanVtsd;
    Old.PosMat = PosMat;
    Old.CleanPosMat = CleanPosMat;
    Old.CleanPosMatInit = CleanPosMatInit;
    Old.AlignedXtsd = AlignedXtsd;
    Old.AlignedYtsd = AlignedYtsd;
    try
        Old.CleanAlignedXtsd = CleanAlignedXtsd;
        Old.CleanAlignedYtsd = CleanAlignedYtsd;
        try
            Old.CleanZoneEpochAligned = CleanZoneEpochAligned;
        end
    end
    Old.CleanZoneEpoch = CleanZoneEpoch;
    Old.CleanZoneIndices = CleanZoneIndices;
    try
        Old.ZoneEpoch = ZoneEpoch;
    end
    Old.ZoneEpochAligned = ZoneEpochAligned;
    Old.ZoneIndices = ZoneIndices;
    
    Old.LinearDist = LinearDist;
    try
        Old.CleanLinearDist = CleanLinearDist;
    end
    
    Old.behavResources = behavResources;
    
    try
        Old.SpeedDir = SpeedDir;
    end
    
    %% Remove all unneccessary vars
    clear Xtsd Ytsd Vtsd CleanXtsd CleanYtsd CleanVtsd PosMat CleanPosMat CleanPosMatInit
    clear AlignedXtsd AlignedYtsd CleanAlignedXtsd CleanAlignedYtsd CleanZoneEpoch
    clear CleanZoneEpochAligned ZoneEpoch ZoneEpochAligned ZoneIndices
    clear LinearDist CleanLinearDist CleanZoneIndices
    clear behavResources
    clear SpeedDir
    
    %% Substitute stand-alone variables
    Xtsd = Old.CleanXtsd;
    Ytsd = Old.CleanYtsd;
%     AlignedXtsd = Old.CleanAlignedXtsd;
%     AlignedYtsd = Old.CleanAlignedYtsd;
    AlignedXtsd = Old.AlignedXtsd; % for Sam
    AlignedYtsd = Old.AlignedYtsd;  % for Sam
    Vtsd = Old.CleanVtsd;
    
    PosMat = Old.CleanPosMat;
    ZoneIndices = Old.CleanZoneIndices;
    ZoneEpoch = Old.CleanZoneEpoch;
%     LinearDist = Old.CleanLinearDist;
    LinearDist = Old.LinearDist;
    try
        SpeedDir = Old.SpeedDir;
    end
    
    %% behavResources
    behavResources = struct('SessionName', {Old.behavResources.SessionName});
    for ifield = 1:length(behavResources)
        behavResources(ifield).ref = Old.behavResources(ifield).ref;
        behavResources(ifield).mask = Old.behavResources(ifield).mask;
        behavResources(ifield).Ratio_IMAonREAL = Old.behavResources(ifield).Ratio_IMAonREAL;
        behavResources(ifield).BW_threshold = Old.behavResources(ifield).BW_threshold;
        behavResources(ifield).smaller_object_size = Old.behavResources(ifield).smaller_object_size;
        behavResources(ifield).sm_fact = Old.behavResources(ifield).sm_fact;
        behavResources(ifield).strsz = Old.behavResources(ifield).strsz;
        behavResources(ifield).SrdZone = Old.behavResources(ifield).SrdZone;
        behavResources(ifield).th_immob = Old.behavResources(ifield).th_immob;
        behavResources(ifield).thtps_immob = Old.behavResources(ifield).thtps_immob;
        behavResources(ifield).frame_limits = Old.behavResources(ifield).frame_limits;
        behavResources(ifield).Zone = Old.behavResources(ifield).Zone;
        behavResources(ifield).ZoneLabels = Old.behavResources(ifield).ZoneLabels;
        behavResources(ifield).delStim = Old.behavResources(ifield).delStim;
        behavResources(ifield).delStimreturn = Old.behavResources(ifield).delStimreturn;
        behavResources(ifield).DiodMask = Old.behavResources(ifield).DiodMask;
        behavResources(ifield).DiodThresh = Old.behavResources(ifield).DiodThresh;
        
        behavResources(ifield).PosMat = Old.behavResources(ifield).PosMat;
%         behavResources(ifield).PosMat = Old.behavResources(ifield).CleanPosMat;
        behavResources(ifield).PosMatInit = Old.behavResources(ifield).PosMatInit;
        behavResources(ifield).im_diff = Old.behavResources(ifield).im_diff;
        behavResources(ifield).im_diffInit = Old.behavResources(ifield).im_diffInit;
        behavResources(ifield).Imdifftsd = Old.behavResources(ifield).Imdifftsd;
        behavResources(ifield).Xtsd = Old.behavResources(ifield).CleanXtsd;
        behavResources(ifield).Ytsd = Old.behavResources(ifield).CleanYtsd;
%         behavResources(ifield).AlignedXtsd = Old.behavResources(ifield).CleanAlignedXtsd;
%         behavResources(ifield).AlignedYtsd = Old.behavResources(ifield).CleanAlignedYtsd;
        behavResources(ifield).AlignedXtsd = Old.behavResources(ifield).AlignedXtsd;
        behavResources(ifield).AlignedYtsd = Old.behavResources(ifield).AlignedYtsd;
        behavResources(ifield).Vtsd = Old.behavResources(ifield).Vtsd;
        behavResources(ifield).GotFrame = Old.behavResources(ifield).GotFrame;
        behavResources(ifield).ZoneIndices = Old.behavResources(ifield).ZoneIndices;
%         behavResources(ifield).ZoneIndices = Old.behavResources(ifield).CleanZoneIndices;
        behavResources(ifield).MouseTemp = Old.behavResources(ifield).MouseTemp;
        behavResources(ifield).FreezeEpoch = Old.behavResources(ifield).FreezeEpoch;
        behavResources(ifield).ZoneEpoch = Old.behavResources(ifield).ZoneEpoch;
%         behavResources(ifield).ZoneEpoch = Old.behavResources(ifield).CleanZoneEpoch;
        behavResources(ifield).LinearDist = Old.behavResources(ifield).LinearDist;
%         behavResources(ifield).LinearDist = Old.behavResources(ifield).CleanLinearDist;
        try
            behavResources(ifield).DirLinear = Old.behavResources(ifield).DirLinear;
            behavResources(ifield).DirEpoch = Old.behavResources(ifield).DirEpoch;
        end
            
    end
    clear ifield
    
    %% Save
    save('behavResources.mat', '-regexp', '^(?!(Dir|mice|imouse|Old)$).');
    
    clearvars -except Dir mice imouse
end