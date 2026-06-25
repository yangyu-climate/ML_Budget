function value = ml_depth_average(profile, weights)
%ML_DEPTH_AVERAGE Weighted vertical average over valid layer thicknesses.

    profile = squeeze(profile);
    profile = profile(:);
    weights = weights(:);
    valid = weights > 0 & ~isnan(profile);

    if any(valid)
        value = sum(profile(valid).*weights(valid))/sum(weights(valid));
    else
        value = NaN;
    end
end
