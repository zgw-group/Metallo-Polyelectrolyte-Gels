#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#
# Author     : Pierre Walker (GitHub: @pw0908)
# Date       : 2024-02-23
# Description: Script to obtain binding energy of the complex using ORCA.
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
cwd_binding="$(pwd)"
cwd="$(pwd)/3-binding"
log_file="binding.log"

# Make and enter the initial directory
# move to working directory
mkdir -p "${cwd}"
cd "${cwd}" || exit

# Obtain SPE of Metal
echo "INFO: Obtain SPE of Metal"
mkdir -p "${cwd}/metal"
cd "${cwd}/metal" || exit
{
if [ ! -f "${cwd}/metal/metal.out" ] # Check if the optimization.xyz file exists. If it does, then the run probably has already been performed.
then
        # Copy the input files for the metal to this repository
        cp ${input_path}/binding_metal.inp metal.inp

        # Replace the placeholders in the input file with the correct values
        sed -i'' -e "s/Metal/$METAL/g" metal.inp
        sed -i'' -e "s/spin/$SPIN/g" metal.inp
        sed -i'' -e "s/charge/$METAL_CHARGE/g" metal.inp
        sed -i'' -e "s/ncpu/$CPU_THREADS/g" metal.inp
        sed -i'' -e "s/METHOD/$FUNCTIONAL/g" metal.inp
        sed -i'' -e "s/BASIS/$BASIS_SET/g" metal.inp

        # Run the metal calculations using ORCA
        $ORCA_BIN metal.inp > metal.out
else
    if grep -Fq "ORCA TERMINATED NORMALLY" "${cwd}/metal/metal.out"
    then
        echo "Metal calculation already performed"
    else
        # Copy the input files for the metal to this repository
        cp ${input_path}/binding_metal.inp metal.inp

        # Replace the placeholders in the input file with the correct values
        sed -i'' -e "s/Metal/$METAL/g" metal.inp
        sed -i'' -e "s/spin/$SPIN/g" metal.inp
        sed -i'' -e "s/charge/$METAL_CHARGE/g" metal.inp
        sed -i'' -e "s/ncpu/$CPU_THREADS/g" metal.inp
        sed -i'' -e "s/METHOD/$FUNCTIONAL/g" metal.inp
        sed -i'' -e "s/BASIS/$BASIS_SET/g" metal.inp

        # Run the metal calculations using ORCA
        $ORCA_BIN metal.inp > metal.out
    fi 
fi
} > "${log_file}" 2>&1
echo "Critical: Obtained SPE of Metal"
cd "${cwd}" || exit

# Obtain optimised SPE of Ligand
echo "INFO: Obtain optimised SPE of Ligand"
mkdir -p "${cwd}/ligand"
cd "${cwd}/ligand" || exit

{
if [ ! -f "${cwd}/ligand/ligand.out" ] # Check if the optimization.xyz file exists. If it does, then the run probably has already been performed.
then

        # Copy the input files for the ligand to this repository
        cp ${input_path}/binding_ligand.inp ligand.inp

        # Replace the placeholders in the input file with the correct values
        cp "${cwd}/../2-optimization/optimization.xyz" initial_ligand.xyz
        sed -i '3d' initial_ligand.xyz
        natoms=$(head -n 1 initial_ligand.xyz)
        natoms=$((natoms-1))
        sed -i "1s/.*/$natoms/" initial_ligand.xyz

        sed -i'' -e "s/spin/$TOTAL_LIGAND_SPIN/g" ligand.inp
        sed -i'' -e "s/netcharge/$NET_LIGAND_CHARGE/g" ligand.inp
        sed -i'' -e "s/ncpu/$CPU_THREADS/g" ligand.inp
        sed -i'' -e "s/METHOD/$FUNCTIONAL/g" ligand.inp
        sed -i'' -e "s/BASIS/$BASIS_SET/g" ligand.inp

        # Run the ligand calculations using ORCA
        if [ $CPU_THREADS -gt 1 ]
        then
            # if CPU_LIST is not set, then use all available cores
            if [ -z ${CPU_LIST+x} ]
            then
                $ORCA_BIN ligand.inp > ligand.out "-np $CPU_THREADS --use-hwthread-cpus"
            else
                $ORCA_BIN ligand.inp > ligand.out "-np $CPU_THREADS --use-hwthread-cpus --bind-to core --cpu-set $CPU_LIST"
            fi
        else
            $ORCA_BIN ligand.inp > ligand.out
        fi
else
    if grep -Fq "ORCA TERMINATED NORMALLY" "${cwd}/ligand/ligand.out"
    then
        echo "Ligand calculation already performed"
    else
        # Copy the input files for the ligand to this repository
        cp ${input_path}/binding_ligand.inp ligand.inp

        # Replace the placeholders in the input file with the correct values
        cp "${cwd}/../2-optimization/optimization.xyz" initial_ligand.xyz
        sed -i '3d' initial_ligand.xyz
        natoms=$(head -n 1 initial_ligand.xyz)
        natoms=$((natoms-1))
        sed -i "1s/.*/$natoms/" initial_ligand.xyz

        sed -i'' -e "s/spin/$TOTAL_LIGAND_SPIN/g" ligand.inp
        sed -i'' -e "s/netcharge/$NET_LIGAND_CHARGE/g" ligand.inp
        sed -i'' -e "s/ncpu/$CPU_THREADS/g" ligand.inp
        sed -i'' -e "s/METHOD/$FUNCTIONAL/g" ligand.inp
        sed -i'' -e "s/BASIS/$BASIS_SET/g" ligand.inp

        # Run the ligand calculations using ORCA
        if [ $CPU_THREADS -gt 1 ]
        then
            if [ -z ${CPU_LIST+x} ]
            then
                $ORCA_BIN ligand.inp > ligand.out "-np $CPU_THREADS --use-hwthread-cpus"
            else
                $ORCA_BIN ligand.inp > ligand.out "-np $CPU_THREADS --use-hwthread-cpus --bind-to core --cpu-set $CPU_LIST"
            fi
        else
            $ORCA_BIN ligand.inp > ligand.out
        fi
    fi
fi
} > "${log_file}" 2>&1

if grep -Fq "ORCA TERMINATED NORMALLY" ligand.out
then
    echo "INFO: Ligand optimization successful"
else
    echo "INFO: Ligand optimization failed"
    exit 1
fi

echo "Critical: Obtained optimised SPE of Ligand"
cd "${cwd}" || exit

python ${input_path}/binding_energy_calc.py > binding.out
# Exit the directory and return to the main folder
echo "Critical: Finished binding energy calculation"
cd "${cwd_binding}" || exit 1