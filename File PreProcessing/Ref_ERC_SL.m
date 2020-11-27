% Ref_ERC_DB

if ExpeInfo.nmouse == 714
    RefSubtraction_multi([flnme '.dat'], length(ExpeInfo.RecordElecs.channel), 1, num2str(ExpeInfo.nmouse), [0:21 24:31], 22, [22:23 32:35]);
    movefile([flnme '_' num2str(ExpeInfo.nmouse) '.dat'], [flnme '.dat']);
    RefSubtraction_multi_AverageChans([flnme '_original' '.dat'], length(ExpeInfo.RecordElecs.channel)...
        , 1, 'SpikeRef', [4:11], [4:7], [0:3 12:35]);
    movefile([flnme '_original_SpikeRef.dat'], [flnme '_SpikeRef' '.dat']);
elseif ExpeInfo.nmouse == 711
    RefSubtraction_multi([flnme '.dat'], length(ExpeInfo.RecordElecs.channel), 1, num2str(ExpeInfo.nmouse), [0:5 8:31], 6, [6:7 32:35]);
    movefile([flnme '_' num2str(ExpeInfo.nmouse) '.dat'], [flnme '.dat']);
    RefSubtraction_multi_AverageChans([flnme '_original' '.dat'], length(ExpeInfo.RecordElecs.channel)...
        , 1, 'SpikeRef', [0:3 12:21 23:31], [0:3 16:21 23 28:31], [4:11 22 32:35]); % all channels - good ripples
%     RefSubtraction_multi_AverageChans([flnme '_original' '.dat'], length(ExpeInfo.RecordElecs.channel)...
%         , 1, 'SpikeRef', [16:27 29 31], [16:27 29 31], [0:15 28 30 32:35]); % all channels - good ripples
    movefile([flnme '_original_SpikeRef.dat'], [flnme '_SpikeRef' '.dat']);
elseif ExpeInfo.nmouse == 621
    RefSubtraction_multi([flnme '.dat'], length(ExpeInfo.RecordElecs.channel), 1, num2str(ExpeInfo.nmouse), [0:21 23:28], 22, [22 29:31]);
    movefile([flnme '_' num2str(ExpeInfo.nmouse) '.dat'], [flnme '.dat']);
elseif ExpeInfo.nmouse == 743
    RefSubtraction_multi([flnme '.dat'], length(ExpeInfo.RecordElecs.channel), 1, num2str(ExpeInfo.nmouse), [0:25 28:63], 26, [26:27 64:70]);
    movefile([flnme '_' num2str(ExpeInfo.nmouse) '.dat'], [flnme '.dat']);
    RefSubtraction_multi_AverageChans([flnme '_original' '.dat'], length(ExpeInfo.RecordElecs.channel)...
        , 1, 'SpikeRef', [0:15 32:63], [0:15 32:39 43:63], [16:31 64:70]); % averaged probe(L) and tetrodes(R)
    movefile([flnme '_original_SpikeRef.dat'], [flnme '_SpikeRef' '.dat']);
elseif ExpeInfo.nmouse == 712
    RefSubtraction_multi([flnme '.dat'], length(ExpeInfo.RecordElecs.channel), 1, num2str(ExpeInfo.nmouse), [0:21 24:31], 23, [22:23 32:35]);
    movefile([flnme '_' num2str(ExpeInfo.nmouse) '.dat'], [flnme '.dat']);
elseif ExpeInfo.nmouse == 741
%     RefSubtraction_multi([flnme '.dat'], length(ExpeInfo.RecordElecs.channel), 1, num2str(ExpeInfo.nmouse), [0:7 10:31], 8, [8:9 32:35]);
    RefSubtraction_multi([flnme '.dat'], length(ExpeInfo.RecordElecs.channel), 1, num2str(ExpeInfo.nmouse), [0:23 26:31], 24, [24:25 32:35]);
    movefile([flnme '_' num2str(ExpeInfo.nmouse) '.dat'], [flnme '.dat']);
    RefSubtraction_multi_AverageChans([flnme '_original' '.dat'], length(ExpeInfo.RecordElecs.channel)...
        , 1, 'SpikeRef', [12:15], [12:15], [0:11 16:35]);
    movefile([flnme '_original_SpikeRef.dat'], [flnme '_SpikeRef' '.dat']);
elseif ExpeInfo.nmouse == 742
    RefSubtraction_multi([flnme '.dat'], length(ExpeInfo.RecordElecs.channel), 1, num2str(ExpeInfo.nmouse), [0:7 10:31], 8, [8:9 32:35]);
    movefile([flnme '_' num2str(ExpeInfo.nmouse) '.dat'], [flnme '.dat']);
%     RefSubtraction_multi_AverageChans([flnme '_original' '.dat'], length(ExpeInfo.RecordElecs.channel)...
%         , 1, 'SpikeRef', [8:15], [8:15], [0:7 16:35]); 
%     movefile([flnme '_original_SpikeRef.dat'], [flnme '_SpikeRef' '.dat']);
elseif ExpeInfo.nmouse == 753
    RefSubtraction_multi([flnme '.dat'], length(ExpeInfo.RecordElecs.channel), 1, num2str(ExpeInfo.nmouse), [0:7 10:31], 9, [8:9 32:35]);
    movefile([flnme '_' num2str(ExpeInfo.nmouse) '.dat'], [flnme '.dat']);
    RefSubtraction_multi_AverageChans([flnme '_original' '.dat'], length(ExpeInfo.RecordElecs.channel)...
        , 1, 'SpikeRef', [28:31], [28:31], [0:27 32:35]);
    movefile([flnme '_original_SpikeRef.dat'], [flnme '_SpikeRef' '.dat']);
elseif ExpeInfo.nmouse == 788
    RefSubtraction_multi([flnme '.dat'], length(ExpeInfo.RecordElecs.channel), 1, num2str(ExpeInfo.nmouse), [0 1 2], 2, [3:6]);
    movefile([flnme '_' num2str(ExpeInfo.nmouse) '.dat'], [flnme '.dat']);
elseif ExpeInfo.nmouse == 785
    RefSubtraction_multi([flnme '.dat'], length(ExpeInfo.RecordElecs.channel), 1, num2str(ExpeInfo.nmouse), [0 1 2], 2, [3:7]);
    movefile([flnme '_' num2str(ExpeInfo.nmouse) '.dat'], [flnme '.dat']);
elseif ExpeInfo.nmouse == 786
    RefSubtraction_multi([flnme '.dat'], length(ExpeInfo.RecordElecs.channel), 1, num2str(ExpeInfo.nmouse), [0 1 2], 2, [3:7]);
    movefile([flnme '_' num2str(ExpeInfo.nmouse) '.dat'], [flnme '.dat']);
% elseif ExpeInfo.nmouse == 787
%     RefSubtraction_multi([flnme '.dat'], length(ExpeInfo.RecordElecs.channel), 1, num2str(ExpeInfo.nmouse), [0 1 3], 3, [2 4:7]);
%     movefile([flnme '_' num2str(ExpeInfo.nmouse) '.dat'], [flnme '.dat']);
end