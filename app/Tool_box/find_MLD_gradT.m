function depth = find_MLD_gradT(T,D,threshold)
    D = abs(D(:));
    T = T(:);
    valid = ~isnan(D) & ~isnan(T);

    if nnz(valid) < 2
        depth = NaN;
        return
    end

    D = D(valid);
    T = T(valid);
    [D,idx] = sort(D,'ascend');
    T = T(idx);

    D_C =     (D(1:end-1)+D(2:end))/2;
    D_L = abs((D(1:end-1)-D(2:end)));
    D_V = abs((T(1:end-1)-T(2:end)));
    DIF = D_V./D_L;

    loc = find(DIF>=threshold,1,'first');

    if isempty(loc)
        depth = NaN;
    elseif loc==1
        depth = D_C(1);
    else
        z1 = D_C(loc-1);
        z2 = D_C(loc);
        d1 = DIF(loc-1);
        d2 = DIF(loc);
        if d2==d1
            depth = z2;
        else
            depth = z1 + (threshold-d1)*(z2-z1)/(d2-d1);
        end
    end
