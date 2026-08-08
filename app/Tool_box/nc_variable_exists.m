function tf = nc_variable_exists(file_name,var_name)
%NC_VARIABLE_EXISTS True when a NetCDF file contains a named variable.

    ncid = netcdf.open(file_name,'NOWRITE');
    cleanup = onCleanup(@() netcdf.close(ncid)); %#ok<NASGU>
    try
        netcdf.inqVarID(ncid,var_name);
        tf = true;
    catch
        % netcdf.inqVarID reports a missing variable with NC_ENOTVAR, but
        % MATLAB releases do not expose that condition with one stable ID.
        tf = false;
    end
end
