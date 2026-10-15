function depth = find_MLD_deltT(T,D,threshold,difference_mode,reference_depth)
    if nargin < 4 || isempty(difference_mode)
        difference_mode = 'absolute';
    end
    if nargin < 5 || isempty(reference_depth)
        reference_depth = 0;
    end

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

    iref = find(Z >= reference_depth,1,'first');
    if isempty(iref)
        % The water column is shallower than the requested reference depth.
        iref = 1;
    end
    Tsurf = T(iref);
    if strcmpi(difference_mode,'signed')
        % For density MLD, only an increase in density below the surface
        % should define the mixed-layer base.  An inversion should not
        % create an artificially shallow MLD.
        DIF = T-Tsurf;
    else
        % Temperature MLD convention: use the magnitude of the change.
        DIF = abs(T-Tsurf);
    end
    loc = find((1:numel(Z))' >= iref & DIF>=threshold,1,'first');

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
