#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#
# Author     : Pierre Walker (GitHub: @pw0908)
# Date       : 2024-02-23
# Description: Script to obtain IR spectrum of the complex using ORCA and Multiwfn.
# Usage      : ./ir_spectrum.sh
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
cwd_ir_spectrum="$(pwd)"
cwd="$(pwd)/4-ir-spectrum"
log_file="ir-spectrum.log"

echo "INFO: Obtaining IR spectrum of complex"
# Make and enter the initial directory
# move to working directory
mkdir -p "${cwd}"
cd "${cwd}" || exit

{
if [ ! -f complex_IR.out ]
then
    # Copy the input files to this repository
    cp ${input_path}/complex_IR.inp complex_IR.inp

    sed -i "s/ncpu/$CPU_THREADS/g" complex_IR.inp
    sed -i "s/spin/$COMPLEX_SPIN/g" complex_IR.inp
    sed -i "s/netcharge/$NET_CHARGE/g" complex_IR.inp
    sed -i'' -e "s/METHOD/$FUNCTIONAL/g" complex_IR.inp
    sed -i'' -e "s/BASIS/$BASIS_SET/g" complex_IR.inp

    # Run the ligand calculations using ORCA
    if [ $CPU_THREADS -gt 1 ]
    then
        # if CPU_LIST is not set, then use all available cores
        if [ -z ${CPU_LIST+x} ]
        then
            $ORCA_BIN complex_IR.inp > complex_IR.out "-np $CPU_THREADS --use-hwthread-cpus"
        else
            $ORCA_BIN complex_IR.inp > complex_IR.out "-np $CPU_THREADS --use-hwthread-cpus --bind-to core --cpu-set $CPU_LIST"
        fi
    else
        $ORCA_BIN complex_IR.inp > complex_IR.out
    fi
else
    if grep -Fq "ORCA TERMINATED NORMALLY" "${cwd}/complex_IR.out"
    then
        echo "IR calculation already performed"
    else
        # Copy the input files to this repository
        cp ${input_path}/complex_IR.inp complex_IR.inp

        sed -i "s/ncpu/$CPU_THREADS/g" complex_IR.inp
        sed -i "s/spin/$COMPLEX_SPIN/g" complex_IR.inp
        sed -i "s/netcharge/$NET_CHARGE/g" complex_IR.inp
        sed -i'' -e "s/METHOD/$FUNCTIONAL/g" complex_IR.inp
        sed -i'' -e "s/BASIS/$BASIS_SET/g" complex_IR.inp

        # Run the ligand calculations using ORCA
        if [ $CPU_THREADS -gt 1 ]
        then
            # if CPU_LIST is not set, then use all available cores
            if [ -z ${CPU_LIST+x} ]
            then
                $ORCA_BIN complex_IR.inp > complex_IR.out "-np $CPU_THREADS --use-hwthread-cpus"
            else
                $ORCA_BIN complex_IR.inp > complex_IR.out "-np $CPU_THREADS --use-hwthread-cpus --bind-to core --cpu-set $CPU_LIST"
            fi
        else
            $ORCA_BIN complex_IR.inp > complex_IR.out
        fi
    fi
fi
} > "${log_file}" 2>&1

if grep -Fq "ORCA TERMINATED NORMALLY" complex_IR.out
then
    echo "INFO: Calculation successful"
else
    echo "INFO: Calculation failed"
    exit 1
fi

# Obtain spectrum using Multiwfn
{
$MFW_BIN complex_IR.out << EOF
11
1
14

0.9614
2
1
-3
q
EOF
} > "${log_file}" 2>&1
# Exit the directory and return to the main folder
echo "Critical: Finished IR spectrum calculation"
cd "${cwd_ir_spectrum}" || exit 1