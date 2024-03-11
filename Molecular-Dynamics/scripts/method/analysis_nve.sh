#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#
# Author     : Pierre Walker (GitHub: @pw0908)
# Date       : 2024-02-23
# Description: Script to perform NVE production MD on the system
# Usage      : ./system_equilibration.sh
# Notes      : Script assumes that global variables have been set in a
#             submission/input/*.sh script. Script should only be called from
#             the main run.sh script.

# built-in shell options
set -o errexit  # exit when a command fails. Add || true to commands allowed to fail
set -o nounset  # exit when script tries to use undeclared variables
set -o pipefail # exit when a command in a pipe fails

# Default Preferences ###################################################################
echo "INFO: Setting default preferences"

# find path to this script
script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
project_path="${script_path}/../.."
input_path="${script_path}/../parameters"

# Output files
cwd_production_nve="$(pwd)"
cwd="$(pwd)/3-production_nve"
log_file="production_nve.log"

# Make and enter the initial directory
# move to working directory
mkdir -p "${cwd}"
cd "${cwd}" || exit

echo "Critical: Performing analysis of NVE simulations."
{
    echo "INFO: Starting End-to-End vector analysis."

    cp "${input_path}/analysis/analysis_e2e.py" analysis_e2e.py

    $PYTHON_BIN analysis_e2e.py $NCHAIN $NMONOMER $SPARSITY

    rm analysis_e2e.py

    echo "INFO: End-to-End vector analysis complete."

    echo "INFO: Starting cluster analysis."

    cp "${input_path}/analysis/analysis_nve.in" analysis_nve.in
    # SPECIFY VMD LOCATION
    sed -i "s+VMD_BIN+$VMD_BIN+g" analysis_nve.in

    if [ -z ${CPU_LIST+x} ]
    then
        $MPI_BIN -np $CPU_THREADS --use-hwthread-cpus $CPU_LIST $LAMMPS_BIN $CPU_THREADS -in analysis_nve.in
    else
        $MPI_BIN -np $CPU_THREADS --use-hwthread-cpus --bind-to core --cpu-set $CPU_LIST $LAMMPS_BIN -in analysis_nve.in
    fi

    echo "INFO: Cluster analysis complete."
} > "analysis_${log_file}" 2>&1
echo "Critical: Analysis of NVE simulations complete."
cd "${cwd}" || exit

cd "${cwd_production_nve}" || exit 1