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
$PYTHON_BIN ${input_path}/plotting_iterations.py > plotting.out &
pid=$!
{
if [ ! -f optimization.out ] # Check if the optimization.xyz file exists. If it does, then the run probably has already been performed.
then
    # Copy the input files for the optimization to this repository
    cp ${input_path}/optimization.inp optimization.inp

    # Replace the placeholders in the input file with the correct values
    sed -i'' -e "s/spin/$COMPLEX_SPIN/g" optimization.inp
    sed -i'' -e "s/netcharge/$NET_CHARGE/g" optimization.inp
    sed -i'' -e "s/ncpu/$CPU_THREADS/g" optimization.inp
    sed -i'' -e "s/METHOD/$FUNCTIONAL/g" optimization.inp
    sed -i'' -e "s/BASIS/$BASIS_SET/g" optimization.inp

    # Run the optimization using ORCA
    # if ncpu greater than 1, then use pinseting
    if [ $CPU_THREADS -gt 1 ]
    then
        # if CPU_LIST is not set, then use all available cores
        if [ -z ${CPU_LIST+x} ]
        then
            $ORCA_BIN optimization.inp > optimization.out "-np $CPU_THREADS --use-hwthread-cpus"
        else
            $ORCA_BIN optimization.inp > optimization.out "-np $CPU_THREADS --use-hwthread-cpus --bind-to core --cpu-set $CPU_LIST"
        fi
    else
        $ORCA_BIN optimization.inp > optimization.out
    fi
else
    if grep -Fq "ORCA TERMINATED NORMALLY" optimization.out
    then
        echo "Optimization already performed"
    else
        if [ $CPU_THREADS -gt 1 ]
        then
            # if CPU_LIST is not set, then use all available cores
            if [ -z ${CPU_LIST+x} ]
            then
                $ORCA_BIN optimization.inp > optimization.out "-np $CPU_THREADS --use-hwthread-cpus"
            else
                $ORCA_BIN optimization.inp > optimization.out "-np $CPU_THREADS --use-hwthread-cpus --bind-to core --cpu-set $CPU_LIST"
            fi
        else
            $ORCA_BIN optimization.inp > optimization.out
        fi
    fi
fi
} > "${log_file}" 2>&1

if grep -Fq "ORCA TERMINATED NORMALLY" optimization.out
then
    echo "INFO: Optimization successful"
else
    echo "INFO: Optimization failed"
    exit 1
fi

kill -SIGKILL $pid
# Exit the directory and return to the main folder
echo "Critical: Finished complex optimization"
cd "${cwd_optimization}" || exit 1