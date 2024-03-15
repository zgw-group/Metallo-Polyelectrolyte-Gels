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
    echo "INFO: Starting Ion-pair analysis."

    cp "${input_path}/analysis/analysis_ion_pair.py" analysis_ion_pair.py

    $PYTHON_BIN analysis_ion_pair.py $CPU_THREADS $IPRANGE

    rm analysis_ion_pair.py

    cp "${input_path}/analysis/analysis_crosslinking.py" analysis_crosslinking.py

    $PYTHON_BIN analysis_crosslinking.py $NMONOMERS

    rm analysis_crosslinking.py

    echo "INFO: Ion-pair analysis complete."

} > "analysis_ip_${log_file}" 2>&1
echo "Critical: Analysis of NVE simulations complete."
cd "${cwd}" || exit

cd "${cwd_production_nve}" || exit 1