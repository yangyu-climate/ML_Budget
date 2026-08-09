function [N2max,N2depth] = n2max_water_column(rho,depth,rho0)
% N2MAX_WATER_COLUMN Maximum buoyancy frequency squared in one water column.
%   rho is density (or density anomaly) at rho points and depth is positive
%   downward at those points. N2depth is the positive-downward depth of the
%   midpoint between the two rho points defining N2max.
%   This evaluates N2 = (g/rho0) * d(rho)/d(depth), equivalent to
%   N2 = -(g/rho0) * d(rho)/d(z) for ROMS z positive upward.

g = 9.81;   % m s^-2

if ~isnumeric(rho0) || ~isscalar(rho0) || ~isfinite(rho0) || rho0 <= 0
    error('ML_Budget:InvalidRho0','rho0 must be one finite positive scalar.');
end

rho = rho(:);
depth = depth(:);

N2max   = NaN;
N2depth = NaN;
if numel(rho) < 2 || numel(depth) < 2
    return
end

dz  = diff(depth);
valid_pair = isfinite(rho(1:end-1)) & isfinite(rho(2:end)) & ...
             isfinite(depth(1:end-1)) & isfinite(depth(2:end)) & dz ~= 0;
if ~any(valid_pair)
    return
end

N2 = g/rho0 * diff(rho)./dz;
% The strongest stratification is the largest *stable* buoyancy frequency.
% A water column with no N2>0 has no stable pycnocline to locate.
pair_index = find(valid_pair & N2 > 0);
if isempty(pair_index)
    return
end
[N2max,local_index] = max(N2(pair_index));
index = pair_index(local_index);
N2depth = 0.5*(depth(index)+depth(index+1));
end
