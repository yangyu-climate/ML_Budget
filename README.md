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

The bundled `app/` directory contains supporting MATLAB utilities, including
NetCDF helper functions, M_Map, color maps, and mixed-layer helper routines.

## Quick Start

1. Open `ml_parameter.m`.
2. Set `Case_nam` and `Data_dir`.
3. Confirm the ROMS files exist in `Data_dir`.
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

- `Case_nam`: case name used for intermediate and final output folders.
- `Data_dir`: ROMS input directory.
- `INT_dir`: daily mixed-layer output directory.
- `CUM_dir`: cumulative budget output directory.
- `OUT_dir`: final averaged result directory.

Default output paths are:

```text
PRE/INT/<Case_nam>/YYYY-MM-DD.mat
PRE/CUM/<Case_nam>/YYYY-MM-DD.mat
Result/<Case_nam>.mat
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

- `IF_DIAGNOSTICS`: read ROMS diagnostic terms and compute budget components.
- `ENTRAIN_OPTION`: entrainment diagnosis option.
- `HCM_DIA_OUTPUT`: enable heat-content model diagnostic output terms.
- `IF_HCM_DIA_RHR`: include/remove shortwave radiative heating contribution.
- `IF_HCM_DIA_SHR`: include/remove surface heat flux contribution.
- `IF_SALINITY`: include salinity budget variables.
- `IF_DENSITY`: include mixed-layer density output.

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
   - Saves daily files to `PRE/INT/<Case_nam>/`.

2. `code/ml_budget_accumulate.m`
   - Reads daily mixed-layer files.
   - Integrates budget terms from `Time_beg` through each day.
   - Saves cumulative files to `PRE/CUM/<Case_nam>/`.

3. `code/ml_budget_Taverage.m`
   - Reads cumulative files.
   - Computes time-averaged fields.
   - Saves the final file to `Result/<Case_nam>.mat`.

## Output Variables

The exact saved variables depend on the switches in `ml_parameter.m`.
Common fields include:

- Grid and metadata: `Time`, `lon`, `lat`, `mask`, `h`, `zeta`
- Mixed-layer structure: `MLD`, `num_ml`
- Mixed-layer means: `temp_ml`, `salt_ml`, `rho_ml`
- Temperature budget terms:
  `temp_tend_ml`, `temp_rate_ml`, `temp_entr_ml`, `temp_hadv_ml`,
  `temp_vadv_ml`, `temp_hdiff_ml`, `temp_vdiff_ml`, `temp_nudge_ml`
- Salinity budget terms, when `IF_SALINITY = 1`:
  `salt_tend_ml`, `salt_rate_ml`, `salt_entr_ml`, `salt_hadv_ml`,
  `salt_vadv_ml`, `salt_hdiff_ml`, `salt_vdiff_ml`, `salt_nudge_ml`

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
  `IF_SALINITY = 0` or `IF_DENSITY = 0` as appropriate.

## Maintenance Notes

- Keep case-specific paths and switches in `ml_parameter.m`.
- Keep scientific formula changes localized in `code/ml_budget_*.m`.
- Treat `PRE/` and `Result/` as generated output rather than source files.
- Keep third-party toolbox updates isolated under `app/`.
