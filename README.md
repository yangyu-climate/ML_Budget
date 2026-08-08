# ML_Budget

Mixed-layer heat and salt budget analysis toolbox for ROMS output.

This project reads daily ROMS average and diagnostic NetCDF files, diagnoses
mixed-layer properties, integrates budget terms through time, and writes a
time-averaged MATLAB result file for one configured case.

## Copyright

Copyright (c) 2026 Yang Yu. All rights reserved.

This repository includes third-party MATLAB toolboxes and support files under
`app/`. Those components retain their original copyrights and licenses.

## Contact

For questions, bug reports, or collaboration requests, contact:

- Maintainer: Yang Yu
- Email: yang.yu@whoi.edu
- Repository: https://github.com/yangatwhoi/ML_Budget.git

## Directory Layout

```text
ML_Budget/
|-- Run.m                  Main MATLAB entry point
|-- ml_parameter.m         Case paths, dates, mixed-layer options, switches
|-- code/
|   |-- ml_budget_daily.m       Daily mixed-layer variables and budget terms
|   |-- ml_budget_accumulate.m  Cumulative time integration
|   `-- ml_budget_Taverage.m    Final time average
|-- app/                   Local and third-party MATLAB toolboxes
|-- doc/                   Notes and reference documents
|-- Run.sh                 Linux background run helper
`-- PBS.sh                 HPC/Slurm-style job script template
```

Generated run artifacts are written under `PRE/` and `Result/`.

## Requirements

- MATLAB with NetCDF support (`ncread`)
- ROMS daily average files named like `avg_00001.nc`
- ROMS daily diagnostic files named like `dia_00001.nc` when
  `IF_DIAGNOSTICS = 1`
- A ROMS initial/restart file (`Init_file`, default `Ini.nc`) when
  `IF_DIAGNOSTICS = 1`

`Init_file` must use the same static ROMS grid and vertical-coordinate
configuration as the average files. It must contain `zeta`, the configured
`MLD_variable`, and `temp`; it must also contain `salt` when
`IF_SALINITY = 1`.

The `rho` field is required whenever `MLD_variable = 'rho'`,
`IF_DENSITY = 1`, or `IF_N2 = 1`. When `IF_N2 = 1`, each average file must
also contain scalar `rho0`.

The bundled `app/` directory contains supporting MATLAB utilities, including
NetCDF helper functions, M_Map, color maps, and mixed-layer helper routines.

## Quick Start

1. Open `ml_parameter.m`.
2. Set `Case_name`, `Data_dir`, and `Init_file`.
3. Confirm the configured ROMS average, diagnostic, and initial files exist.
4. Run in MATLAB from the project root:

   ```matlab
   Run
   ```

For Linux background execution:

```bash
./Run.sh
```

For an HPC job, adapt `PBS.sh` to the local queue, MATLAB module, and walltime
requirements before submitting it.

## Configuration

All normal run settings live in `ml_parameter.m`.

### Case And Paths

- `Case_name`: case name used for intermediate and final output folders.
- `Data_dir`: ROMS input directory.
- `Init_file`: ROMS initial/restart file used as the reference state for
  first-day budget closure. It must share the static grid and vertical
  coordinate configuration of the average files.
- `INT_dir`: daily mixed-layer output directory.
- `CUM_dir`: cumulative budget output directory.
- `OUT_dir`: final averaged result directory.

Default output paths are:

```text
PRE/INT/<Case_name>/YYYY-MM-DD.mat
PRE/CUM/<Case_name>/YYYY-MM-DD.mat
Result/<Case_name>.mat
```

### Time Range

- `Time_beg`: first analysis day, as `[yyyy mm dd]`.
- `Time_end`: final analysis day, as `[yyyy mm dd]`.
- `Time_ref`: ROMS file numbering reference date.
- `Time_frq`: time step in days.

The scripts map dates to ROMS file names using `Time_ref` and `Time_frq`. For
example, daily files are expected to follow the padded sequence
`avg_00001.nc`, `avg_00002.nc`, and so on.

### Mixed-Layer Depth

- `MLD_variable`: input 3D variable used for mixed-layer depth diagnosis,
  commonly `rho` or `temp`.
- `MLD_method = 1`: threshold method relative to the near-surface value.
- `MLD_method = 2`: vertical-gradient threshold method.
- `MLD_threshold`: threshold value for the selected method.
- `MLD_nanlimit`: maximum missing-value tolerance used by the mixed-layer
  helper routines.

### Diagnostics And Optional Terms

- `IF_DIAGNOSTICS`: total switch to read ROMS diagnostic terms and compute
  temperature and salinity budget components.
- `ENTRAIN_OPTION`: entrainment diagnosis option.
- `HCM_DIA_OUTPUT`: enable heat-content model diagnostic output terms.
- `IF_HCM_DIA_RHR`: include/remove shortwave radiative heating contribution.
- `IF_HCM_DIA_SHR`: include/remove surface heat flux contribution.
- `IF_SALINITY`: include mixed-layer salinity and, when `IF_DIAGNOSTICS = 1`,
  salinity budget variables.
- `IF_DENSITY`: include mixed-layer density output.
- `IF_N2`: calculate and save water-column `N2max` and `N2depth`.

When diagnostics are enabled, the daily script reads fields such as
`temp_rate`, `temp_hadv`, `temp_vadv`, `temp_hdiff`, and `temp_vdiff` from
`dia_*.nc`.

## Workflow

`Run.m` adds the support directories to the MATLAB path, starts the toolbox
environment, then runs these scripts in order:

1. `code/ml_budget_daily.m`
   - Reads ROMS daily files.
   - Diagnoses mixed-layer depth.
   - Computes mixed-layer averages and daily budget terms.
   - Saves daily files to `PRE/INT/<Case_name>/`.

2. `code/ml_budget_accumulate.m`
   - Reads daily mixed-layer files.
   - Integrates budget terms from the ROMS initial state through each day.
     The first day uses its daily diagnostic rate; later days use trapezoidal
     integration of physical rates.
   - Saves cumulative files to `PRE/CUM/<Case_name>/`.

3. `code/ml_budget_Taverage.m`
   - Reads cumulative files.
   - Computes time averages of cumulative budget contributions.
   - Saves the final file to `Result/<Case_name>.mat`.

## Output Variables

The exact saved variables depend on the switches in `ml_parameter.m`.
Common fields include:

- Grid and metadata: `Time`, `lon`, `lat`, `mask`, `h`, `zeta`
- Mixed-layer structure: `MLD`, `num_ml`
- Water-column stratification: `N2max` (maximum buoyancy frequency squared,
  s^-2) and `N2depth` (positive-downward depth of that maximum, m). These are
  calculated from adjacent ROMS density levels using
  `N2 = (g / rho0) * d(rho) / d(depth)`, where `rho0` is read with
  `ncread(fileA,'rho0')` from each ROMS average file. When `IF_N2 = 1`,
  `rho` and `rho0` are required even if
  `IF_DENSITY = 0`; the final output contains the time average of each daily
  field.
- Mixed-layer means: `temp_ml`, `salt_ml`, `rho_ml`
- Temperature budget terms:
  `temp_tend_ml`, `temp_rate_ml`, `temp_entr_ml`, `temp_hadv_ml`,
  `temp_vadv_ml`, `temp_hdiff_ml`, `temp_vdiff_ml`, `temp_nudge_ml`
- Salinity budget terms, when `IF_DIAGNOSTICS = 1` and `IF_SALINITY = 1`:
  `salt_tend_ml`, `salt_rate_ml`, `salt_entr_ml`, `salt_hadv_ml`,
  `salt_vadv_ml`, `salt_hdiff_ml`, `salt_vdiff_ml`, `salt_nudge_ml`

In `PRE/CUM/`, budget variables are cumulative contributions relative to the
state diagnosed from `Init_file`. In the final result, their time averages
therefore quantify each process's contribution to the mean mixed-layer
temperature or salinity change. `temp_residual_ml` and `salt_residual_ml`
are the corresponding closure residuals.

Daily diagnostic budget fields are rates in the units supplied by ROMS. The
corresponding `PRE/CUM/` and final budget fields are time-integrated
contributions, with temperature or salinity units rather than rate units.
`N2depth` in the final result is the time average of the daily depths at
which `N2max` occurs; it is not the depth of the maximum of a time-mean N2
profile.

For `ENTRAIN_OPTION = 2`, daily intermediate files may also include additional
entrainment diagnostics such as Kim et al. style estimates and residual
correction terms. The cumulative and final-average scripts propagate the
primary `*_entr_ml` fields.

## Pre-Run Check

The helper function `app/Tool_box/validate_ml_parameter.m` can be used to catch
common configuration problems before a long run:

```matlab
addpath(fullfile(pwd,'app'))
start
validate_ml_parameter
```

It checks required paths, date vectors, logical switches, mixed-layer options,
and MATLAB NetCDF support.

## Troubleshooting

- If MATLAB cannot find helper functions, run from the project root and use
  `Run.m` rather than starting scripts inside `code/` directly.
- If `Data_dir` is missing, update it in `ml_parameter.m`.
- If a ROMS file cannot be loaded, check that the date range and `Time_ref`
  produce the expected `avg_*.nc` and `dia_*.nc` sequence numbers.
- If diagnostics are unavailable, set `IF_DIAGNOSTICS = 0` or provide the
  matching `dia_*.nc` files.
- If salinity or density variables are absent from the ROMS output, set
  `IF_SALINITY = 0` or `IF_DENSITY = 0` as appropriate. If `rho` or scalar
  `rho0` is unavailable, also set `IF_N2 = 0`. If `rho` is unavailable and
  `MLD_variable = 'rho'`, set `MLD_variable = 'temp'` as well.

## Maintenance Notes

- Keep case-specific paths and switches in `ml_parameter.m`.
- Keep scientific formula changes localized in `code/ml_budget_*.m`.
- Treat `PRE/` and `Result/` as generated output rather than source files.
- Keep third-party toolbox updates isolated under `app/`.
