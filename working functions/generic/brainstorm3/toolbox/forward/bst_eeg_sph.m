function G = bst_eeg_sph(Rq, Re, center, R, sigma)
% BST_EEG_SPH: Calculate the electric potential, spherical head, arbitrary orientation
%
% USAGE:  G = bst_eeg_sph(Rq, Channel, center, R, sigma);
%
% INPUT:
%    - Rq     : dipole location(in meters)    [nDipoles x 3]
%    - Re     : EEG sensors(in meters)        [nSensors x 3]  
%    - center : Sphere center                 [1 x 3]
%    - R      : radii(in meters) of sphere from INNERMOST to OUTERMOST  [nLayers x 1]
%    - sigma  : conductivity from INNERMOST to OUTERMOST                [nLayers x 1]
%
% OUTPUTS:
%    - G : EEG forward model gain matrix    [nSensors x (3*nDipoles)]
%
% DESCRIPTION:  EEG multilayer spherical forward model
%     This function computes the voltage potential forward gain matrix for an array of 
%     EEG electrodes on the outermost layer of a single/multilayer conductive sphere. 
%     Each region of the multilayer sphere is assumed to be concentric with 
%     isontropic conductivity.  EEG sensors are assumed to be located on the surface
%     of the outermost sphere. 
% 
%     Method: Series Approximiation of a Multilayer Sphere as three dipoles in a 
%             single shell using "Berg/Sherg" parameter approximation.
%     Ref:    Z. Zhang "A fast method to compute surface potentials generated by 
%             dipoles within multilayer anisotropic spheres" 
%             (Phys. Med. Biol. 40, pp335-349,1995)    
% 
%     Dipole generator(s) are assumed to be interior to the innermost "core" layer. For those 
%     dipoles external to the sphere, the dipole "image" is computed and used determine the 
%     gain function. The exception to this is the Legendre Method where all dipoles MUST be 
%     interior to the innermost "core" layer.

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
%
% Authors: Sylvain Baillet, John Mosher, John Ermer, Francois Tadel

% Checking inputs
if R(1)~= min(R)
    error('Head radii must be specified from innermost to outmost layer!!! ')
end
if size(Rq,2) ~= 3
    error('Dipole location must have three columns!!!')
end
NL = length(R);   % # of concentric sphere layers
P = size(Rq,1);
M = size(Re,1);

% Center all coordinates on the center of the sphere
Re = bst_bsxfun(@minus, Re, center(:)');
Rq = bst_bsxfun(@minus, Rq, center(:)');
% Compute Berg parameters
[mu_berg, lam_berg] = bst_berg(R, sigma);

% Projection of the EEG sensors on the sphere
[theta phi Re_sph] = cart2sph(Re(:,1),Re(:,2),Re(:,3));
Re_sph = R(end) * ones(size(Re_sph));
[Re(:,1) Re(:,2) Re(:,3)] = sph2cart(theta,phi,Re_sph);

% Pre-Allocate Gain Matrix
G = zeros(M,3*P);

Re_mag    = R(NL);
Rq_mag    = rownorm(Rq);  %(Px1)
Re_dot_Rq = Rq*Re';       %(PxM)

for k = 1:length(mu_berg)
    mu = mu_berg(k);
    % This part checks for the presence of Berg dipoles which are external to
    % the sphere. For those dipoles external to the sphere, the dipole parameters
    % are replaced with the electrical image (internal to sphere) of the dipole
    nx = find(mu .* Rq_mag > Re_mag);
    if ~isempty(nx)
        warning('Check results...');
        Rq(nx,:) = Re_mag.^2 * bst_bsxfun(@rdivide, Rq(nx,:), sum(Rq(nx,:).^2,2));
    end
    
    % Calculation of Forward Gain Matrix Contribution due to K-th Berg Dipole
    Rq1_mag_sq = repmat((mu * Rq_mag).^2,1,M);          %(PxM)
    const = 1 ./ (4.0 * pi * sigma(NL) / lam_berg(k) * mu.^2 * Rq_mag.^2);
    d_mag = reshape( rownorm(reshape(repmat(Re,1,P)',3,P*M)' - mu .* repmat(Rq,M,1)) ,P,M);        %(PxM)
    %
    F_scalar = d_mag .* (Re_mag.*d_mag + Re_mag.^2 - mu.*Re_dot_Rq); %(PxM)
    %
    c1 = bst_bsxfun(@times, (2*( (mu.*Re_dot_Rq - Rq1_mag_sq) ./ d_mag.^3) + 1./d_mag - 1./Re_mag), const);                 %(PxM)
    c2 = bst_bsxfun(@times, (2./d_mag.^3) + (d_mag+Re_mag) ./ (Re_mag.*F_scalar), const);
    %
    G = G + reshape(repmat((c1 - c2.*mu.*Re_dot_Rq)',3,1),M,3*P) .* mu .* repmat(reshape(Rq',1,3*P),M,1) ...
          + reshape(repmat((c2.*Rq1_mag_sq)',3,1),M,3*P) .* repmat(Re,1,P);
end

end



%% ===== FUNCTION: ROWNORM =====
% Calculate the Euclidean norm of each ROW in A
function nrm = rownorm(A)
    nrm = sqrt(sum(A.^2, 2));
end
