function zdata = getZ(obj)
% Returns physical z-coordinate of voxels.
%
%   ZDATA = getZ(IMG)
%
%   Example
%   getZ
%
%   See also
%     getX, getY
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2010-07-13,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

siz = size(obj);
zdata = (0:siz(3)-1)'*1 + 1;
zdata = reshape(zdata, [1 1 siz(3)]);
zdata = zdata(ones(siz(2), 1), ones(siz(1),1), :);
