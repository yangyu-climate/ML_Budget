function depth = find_MLD_deltT(T,D,threshold)
    Z = abs(D(:));
    T = T(:);
    valid = ~isnan(Z) & ~isnan(T);

    if ~any(valid)
        depth = NaN;
        return
    end

    Z = Z(valid);
    T = T(valid);
    [Z,idx] = sort(Z,'ascend');
    T = T(idx);

    Tsurf = T(1);
    DIF = abs(T-Tsurf);
    loc = find(DIF>=threshold,1,'first');

    if isempty(loc)
        depth = NaN;
    elseif loc==1
        depth = Z(1);
    else
        z1 = Z(loc-1);
        z2 = Z(loc);
        d1 = DIF(loc-1);
        d2 = DIF(loc);
        if d2==d1
            depth = z2;
        else
            depth = z1 + (threshold-d1)*(z2-z1)/(d2-d1);
        end
    end
