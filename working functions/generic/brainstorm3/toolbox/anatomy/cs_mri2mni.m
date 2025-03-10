function [outputVar1, outputVar2] = cs_mri2mni(MRI, mriCoord)
% CS_MRI2MNI: Compute the transform to move from the MRI coordinate system (in mm) to the MNI coordinate system
%
% USAGE:            [transfMNI] = cs_mri2mni(MRI);
%         [mniCoord, transfMNI] = cs_mri2mni(MRI, mriCoord);
%
% DEPRECATED: Replace with cs_convert()

% @=============================================================================
% This function is part of the Brainstorm software:
% http://neuroimage.usc.edu/brainstorm
% 
% Copyright (c)2000-2018 University of Southern California & McGill University
% This software is distributed under the terms of the GNU General Public License
% as published by the Free Software Foundation. Further details on the GPLv3
% license can be found at http://www.gnu.org/copyleft/gpl.html.
% 
% FOR RESEARCH PURPOSES ONLY. THE SOFTWARE IS PROVIDED "AS IS," AND THE
% UNIVERSITY OF SOUTHERN CALIFORNIA AND ITS COLLABORATORS DO NOT MAKE ANY
% WARRANTY, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO WARRANTIES OF
% MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, NOR DO THEY ASSUME ANY
% LIABILITY OR RESPONSIBILITY FOR THE USE OF THIS SOFTWARE.
%
% For more information type "brainstorm license" at command prompt.
% =============================================================================@

disp('BST> WARNING: Deprecated function cs_mri2mni(), use cs_convert() instead.');

if (nargin == 1)
    outputVar1 = cs_compute(MRI, 'mni');
    outputVar2 = [];
else
    outputVar1 = cs_convert(MRI, 'mri', 'mni', mriCoord' / 1000)' * 1000;
    outputVar2 = MRI.NCS;
end

    