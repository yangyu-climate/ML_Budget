function [ML,weights,depth] = ml_diagnose_weights(profile,z_w,h,method,threshold,nanlimit)
%ML_DIAGNOSE_WEIGHTS Diagnose MLD and layer weights for one water column.
%   z_w uses ROMS positive-upward coordinates. depth and ML are returned as
%   positive-downward meters. weights is the thickness inside [0,ML].

depth = -0.5*(z_w(1:end-1)+z_w(2:end));

if method==1
    ML = find_MLD_deltT(profile,depth,threshold);
elseif method==2
    ML = find_MLD_gradT(profile,depth,threshold);
else
    error('ML_Budget:InvalidMLDMethod', ...
          'method must be 1 (deltT) or 2 (gradT).');
end

if isnan(ML) && h<=nanlimit
    ML = max(depth);
end

if isnan(ML)
    weights = NaN(size(depth));
else
    weights = ml_layer_weights(z_w,ML);
end
end
