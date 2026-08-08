function rho = roms_rho_eos(temp,salt,z_r)
%ROMS_RHO_EOS ROMS nonlinear in-situ density anomaly (kg m^-3 - 1000).
%
% Implements the NONLIN_EOS branch in ROMS/Nonlinear/rho_eos.F. TEMP is
% potential temperature (degC), SALT is practical salinity (PSU), and Z_R
% is the ROMS rho-point elevation (m, negative below the free surface).
% The result has the same convention as the ROMS rho output variable.

    if ~isequal(size(temp),size(salt),size(z_r))
        error('ML_Budget:EOSSizeMismatch', ...
              'temp, salt, and z_r must have identical sizes.');
    end

    T = max(double(temp),-2.0);
    S = max(double(salt),0.0);
    Z = double(z_r);
    sqrtS = sqrt(S);

    % Density at one atmosphere.
    C0 = 9.99842594e2 + T.*(6.793952e-2 + T.*(-9.095290e-3 + ...
         T.*(1.001685e-4 + T.*(-1.120083e-6 + T.*6.536332e-9))));
    C1 = 8.24493e-1 + T.*(-4.08990e-3 + T.*(7.64380e-5 + ...
         T.*(-8.24670e-7 + T.*5.38750e-9)));
    C2 = -5.72466e-3 + T.*(1.02270e-4 - T.*1.65460e-6);
    den1 = C0 + S.*(C1 + sqrtS.*C2 + S.*4.8314e-4);

    % Secant bulk modulus. ROMS treats Z (m, negative) as pressure (dbar,
    % negative), including the 0.1*Z factor in the rational correction.
    C3 = 1.909256e4 + T.*(2.098925e2 + T.*(-3.041638 + ...
         T.*(-1.852732e-3 - T.*1.361629e-5)));
    C4 = 1.044077e2 + T.*(-6.500517 + T.*(1.553190e-1 + T.*2.326469e-4));
    C5 = -5.587545 + T.*(7.390729e-1 - T.*1.909078e-2);
    bulk0 = C3 + S.*(C4 + sqrtS.*C5);
    C6 = 4.721788e-1 + T.*(1.028859e-2 + T.*(-2.512549e-4 - ...
         T.*5.939910e-7));
    C7 = -1.571896e-2 + T.*(-2.598241e-4 + T.*7.267926e-6);
    bulk1 = C6 + S.*(C7 + sqrtS.*2.042967e-3);
    C8 = 1.045941e-5 + T.*(-5.782165e-10 + T.*1.296821e-7);
    C9 = -2.595994e-7 + T.*(-1.248266e-9 - T.*3.508914e-9);
    bulk2 = C8 + S.*C9;
    bulk = bulk0 - Z.*(bulk1 - Z.*bulk2);

    rho = den1.*bulk./(bulk + 0.1.*Z) - 1000.0;
end
