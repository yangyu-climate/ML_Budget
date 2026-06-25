clear
clc
Run_dir = fullfile(pwd,'app');
code_dir= fullfile(pwd,'code');
addpath(Run_dir)
start
%--------------------------------------------------------------------------
addpath(code_dir)

ml_budget_daily
ml_budget_accumulate
ml_budget_Taverage
