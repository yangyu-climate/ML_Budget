clear
clc
Run_dir = fullfile(pwd,'app');
code_dir= fullfile(pwd,'code');
addpath(Run_dir)
start
%--------------------------------------------------------------------------
addpath(code_dir)

% Fail before producing any intermediate output when the run configuration
% is incomplete or internally inconsistent.
validate_ml_parameter

ml_budget_daily
ml_budget_accumulate
ml_budget_Taverage
