
Case_nam='WFPoff';
Data_dir=['/user/yang.yu/Clark/application/NESS/Result/TWOWAY/',Case_nam,'/ROMS'];

INT_dir=[pwd,'/PRE/INT/',Case_nam];
CUM_dir=[pwd,'/PRE/CUM/',Case_nam];
OUT_dir=[pwd,'/Result'];

Time_beg=[2023 6 1];
Time_end=[2023 9 1];
Time_ref=[2023 6 1];
Time_frq=1;

MLD_variable  ='rho';
MLD_method    = 1;   %1:deltT; 2:gradT
MLD_threshold = 0.03;
MLD_nanlimit  = 100;

IF_DIAGNOSTICS = 1;
ENTRAIN_OPTION = 1;
HCM_DIA_OUTPUT = 1;
IF_HCM_DIA_RHR = 1;
IF_HCM_DIA_SHR = 1;
IF_SALINITY    = 1;
IF_DENSITY     = 1;
