#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#
# Author     : Pierre Walker (GitHub: @pw0908)
# Date       : 2024-02-23
# Description: Script to perform equilibration MD on the system
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
cwd_equilibration="$(pwd)"
cwd="$(pwd)/2-equilibration"
log_file="equilibration.log"

# Make and enter the initial directory
# move to working directory
mkdir -p "${cwd}"
cd "${cwd}" || exit

# Equilibrate the system
echo "INFO: Equilibrating system"

{
if [ ! -f equilibrated.data ]
then
    if test -f "simulation.restart1"
    then
        cp "${input_path}/equilibration_restart.in" equilibration_restart.in

        if test -f "simulation.restart2"
        then
            if [ "simulation.restart1" -nt "simulation.restart2" ]
            then
                sed -i "s/restartn/restart1/g" equilibration_restart.in
            else
                sed -i "s/restartn/restart2/g" equilibration_restart.in
            fi
        else
            sed -i "s/restartn/restart1/g" equilibration_restart.in
        fi

        if [ "${GPUS}" == "0" ]
        then
            if [ -z ${CPU_LIST+x} ]
            then
                $MPI_BIN -np $CPU_THREADS --use-hwthread-cpus $CPU_LIST $LAMMPS_BIN -in equilibration_restart.in
            else
                $MPI_BIN -np $CPU_THREADS --use-hwthread-cpus --bind-to core --cpu-set $CPU_LIST $LAMMPS_BIN -in equilibration_restart.in
            fi
        else
            if [ -z ${CPU_LIST+x} ]
            then
                $MPI_BIN -np $CPU_THREADS --use-hwthread-cpus $LAMMPS_BIN -sf gpu -pk gpu $GPUS -in equilibration_restart.in
            else
                $MPI_BIN -np $CPU_THREADS --use-hwthread-cpus --bind-to core --cpu-set $CPU_LIST $LAMMPS_BIN -sf gpu -pk gpu $GPUS -in equilibration_restart.in
            fi
        fi
    else
        # Perform equilibration run
        cp "${input_path}/equilibration.in" equilibration.in

        if [ "${GPUS}" == "0" ]
        then
            if [ -z ${CPU_LIST+x} ]
            then
                $MPI_BIN -np $CPU_THREADS --use-hwthread-cpus $CPU_LIST $LAMMPS_BIN -in equilibration.in
            else
                $MPI_BIN -np $CPU_THREADS --use-hwthread-cpus --bind-to core --cpu-set $CPU_LIST $LAMMPS_BIN -in equilibration.in
            fi
        else
            if [ -z ${CPU_LIST+x} ]
            then
                $MPI_BIN -np $CPU_THREADS --use-hwthread-cpus $LAMMPS_BIN -sf gpu -pk gpu $GPUS -in equilibration.in
            else
                $MPI_BIN -np $CPU_THREADS --use-hwthread-cpus --bind-to core --cpu-set $CPU_LIST $LAMMPS_BIN -sf gpu -pk gpu $GPUS -in equilibration.in
            fi
        fi
    fi
fi
} > "${log_file}" 2>&1
cd "${cwd}" || exit

echo "Critical: Equilibration simulation completed."
cd "${cwd_equilibration}" || exit 1