#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#
# Author     : Pierre Walker (GitHub: @pw0908)
# Date       : 2024-02-23
# Description: Script to optimize the complex using ORCA.
# Usage      : ./optimization.sh
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
cwd_optimization="$(pwd)"
cwd="$(pwd)/2-optimization"
log_file="optimization.log"

echo "INFO: Optimizing complex structure"
# Make and enter the initial directory
# move to working directory
mkdir -p "${cwd}"
cd "${cwd}" || exit

{
if [ ! -f optimization.out ] # Check if the optimisation.xyz file exists. If it does, then the run probably has already been performed.
then
    # Copy the input files for the optimisation to this repository
    cp ${input_path}/optimisation.inp optimisation.inp

    # Replace the placeholders in the input file with the correct values
    sed -i'' -e "s/spin/$COMPLEX_SPIN/g" optimisation.inp
    sed -i'' -e "s/netcharge/$NET_CHARGE/g" optimisation.inp
    sed -i'' -e "s/ncpu/$CPU_THREADS/g" optimisation.inp
    sed -i'' -e "s/METHOD/$FUNCTIONAL/g" optimisation.inp
    sed -i'' -e "s/BASIS/$BASIS_SET/g" optimisation.inp

    # Run the optimisation using ORCA
    # if ncpu greater than 1, then use pinseting

    if [ $CPU_THREADS -gt 1 ]
    then
        # if CPU_LIST is not set, then use all available cores
        if [ -z ${CPU_LIST+x} ]
        then
            $ORCA_BIN optimisation.inp > optimization.out "-np $CPU_THREADS --use-hwthread-cpus"
        else
            $ORCA_BIN optimisation.inp > optimization.out "-np $CPU_THREADS --use-hwthread-cpus --bind-to core --cpu-set $CPU_LIST"
        fi
    else
        $ORCA_BIN optimisation.inp > optimization.out
    fi
else
    if grep -Fq "ORCA TERMINATED NORMALLY" optimization.out
    then
        echo "Optimization already performed"
    else
        if [ $TOTAL_CPU -gt 1 ]
        then
            # if CPU_LIST is not set, then use all available cores
            if [ -z ${CPU_LIST+x} ]
            then
                $ORCA_BIN optimisation.inp > optimization.out "-np $TOTAL_CPU --use-hwthread-cpus"
            else
                $ORCA_BIN optimisation.inp > optimization.out "-np $TOTAL_CPU --use-hwthread-cpus --bind-to core --cpu-set $CPU_LIST"
            fi
        else
            $ORCA_BIN optimisation.inp > optimization.out
        fi
    fi
fi
} > "${log_file}" 2>&1
# Exit the directory and return to the main folder
echo "Critical: Finished complex optimization"
cd "${cwd_optimization}" || exit 1