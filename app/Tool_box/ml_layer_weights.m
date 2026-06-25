function weights = ml_layer_weights(z_w, depth_limit)
%ML_LAYER_WEIGHTS Thickness of each vertical layer inside a depth interval.
%
% z_w is the w-level depth vector in positive meters. depth_limit is the
% lower bound of the interval [0, depth_limit], also in positive meters.

    z_w = abs(z_w(:));
    layer_top = min(z_w(1:end-1), z_w(2:end));
    layer_bot = max(z_w(1:end-1), z_w(2:end));
    weights = max(0, min(layer_bot, depth_limit) - layer_top);
end
