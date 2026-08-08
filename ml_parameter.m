
Case_name='WFPoff';
Data_dir =['/user/yang.yu/Clark/application/NESS/Result/TWOWAY/',Case_name,'/ROMS'];
Init_file=[Data_dir,'/Ini.nc'];  % ROMS initial/restart file for first-day closure

INT_dir=[pwd,'/PRE/INT/',Case_name];
CUM_dir=[pwd,'/PRE/CUM/',Case_name];
OUT_dir=[pwd,'/Result'];

Time_beg=[2023 6 1];
Time_end=[2023 9 1];
Time_ref=[2023 6 1];
Time_frq=1;

MLD_variable  ='rho';
MLD_method    = 1;   %1:deltT; 2:gradT
MLD_threshold = 0.03;
MLD_nanlimit  = 100;

% Budget diagnostics (total switch for temperature and salinity budgets)
IF_DIAGNOSTICS = 1;  % Read and calculate ROMS budget terms
ENTRAIN_OPTION = 1;  % 1: residual; 2: Kim et al. (2005) estimate

% Heat-content model diagnostics (requires IF_DIAGNOSTICS = 1)
HCM_DIA_OUTPUT = 1;
IF_HCM_DIA_RHR = 1;  % Radiative heating term
IF_HCM_DIA_SHR = 1;  % Surface heat-flux term

% Salinity budget and mixed-layer salinity output
IF_SALINITY    = 1;  % Budget terms also require IF_DIAGNOSTICS = 1

% Mixed-layer density output
IF_DENSITY     = 1;

% Water-column stratification diagnostics
IF_N2          = 1;  % Calculate water-column N2max and N2depth
