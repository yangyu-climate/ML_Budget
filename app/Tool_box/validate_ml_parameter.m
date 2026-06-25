function validate_ml_parameter()
%VALIDATE_ML_PARAMETER Validate the mixed-layer budget run configuration.
%
% The main budget scripts are intentionally script-based so they can share
% variables from ml_parameter.m. This function keeps configuration checks in
% one place and fails early before a long ROMS processing run starts.

    ml_parameter

    requiredText = {'Case_nam','Data_dir','INT_dir','CUM_dir','OUT_dir', ...
                    'MLD_variable'};
    for ii = 1:numel(requiredText)
        name = requiredText{ii};
        if ~exist(name,'var') || ~(ischar(eval(name)) || isstring(eval(name))) ...
                || strlength(string(eval(name))) == 0
            error('ML_Budget:InvalidParameter', ...
                  '%s must be a non-empty character vector or string.', name);
        end
    end

    validateDateVector(Time_beg,'Time_beg');
    validateDateVector(Time_end,'Time_end');
    validateDateVector(Time_ref,'Time_ref');

    if datenum(Time_end) < datenum(Time_beg)
        error('ML_Budget:InvalidDateRange', ...
              'Time_end must be later than or equal to Time_beg.');
    end

    if ~isnumeric(Time_frq) || ~isscalar(Time_frq) || Time_frq <= 0
        error('ML_Budget:InvalidTimeFrequency', ...
              'Time_frq must be a positive scalar in days.');
    end

    if ~ismember(MLD_method,[1 2])
        error('ML_Budget:InvalidMLDMethod', ...
              'MLD_method must be 1 (deltT) or 2 (gradT).');
    end

    if ~isnumeric(MLD_threshold) || ~isscalar(MLD_threshold) || MLD_threshold <= 0
        error('ML_Budget:InvalidMLDThreshold', ...
              'MLD_threshold must be a positive scalar.');
    end

    if ~isnumeric(MLD_nanlimit) || ~isscalar(MLD_nanlimit) || MLD_nanlimit < 0
        error('ML_Budget:InvalidMLDNanLimit', ...
              'MLD_nanlimit must be a non-negative scalar.');
    end

    validateFlag(IF_DIAGNOSTICS,'IF_DIAGNOSTICS');
    validateFlag(HCM_DIA_OUTPUT,'HCM_DIA_OUTPUT');
    validateFlag(IF_HCM_DIA_RHR,'IF_HCM_DIA_RHR');
    validateFlag(IF_HCM_DIA_SHR,'IF_HCM_DIA_SHR');
    validateFlag(IF_SALINITY,'IF_SALINITY');
    validateFlag(IF_DENSITY,'IF_DENSITY');

    if ~isnumeric(ENTRAIN_OPTION) || ~isscalar(ENTRAIN_OPTION) ...
            || ~ismember(ENTRAIN_OPTION,[1 2])
        error('ML_Budget:InvalidEntrainOption', ...
              'ENTRAIN_OPTION must be 1 or 2.');
    end

    if ~exist(Data_dir,'dir')
        error('ML_Budget:MissingInputDirectory', ...
              'Data_dir does not exist: %s', Data_dir);
    end

    if exist('ncread','file') ~= 2
        error('ML_Budget:MissingNetCDFSupport', ...
              'MATLAB ncread is unavailable. NetCDF support is required.');
    end
end

function validateDateVector(value,name)
    if ~isnumeric(value) || numel(value) ~= 3
        error('ML_Budget:InvalidDateVector', ...
              '%s must be [year month day].', name);
    end
    try
        datenum(value);
    catch err
        error('ML_Budget:InvalidDateVector', ...
              '%s is not a valid date: %s', name, err.message);
    end
end

function validateFlag(value,name)
    if ~(isnumeric(value) || islogical(value)) || ~isscalar(value) ...
            || ~ismember(double(value),[0 1])
        error('ML_Budget:InvalidFlag', '%s must be 0 or 1.', name);
    end
end
