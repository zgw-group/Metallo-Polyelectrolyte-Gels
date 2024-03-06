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

# Run the simulation
echo "INFO: Performing NVE simulation of system"
if [ ! -f production_nve.data ]
then
{
    if test -f "simulation.restart1"
    then
        cp "${input_path}/production_nve_restart.in" production_nve_restart.in

        if test -f "simulation.restart2"
        then
            if [ "simulation.restart1" -nt "simulation.restart2" ]
            then
                sed -i "s/restartn/restart1/g" production_nve_restart.in
            else
                sed -i "s/restartn/restart2/g" production_nve_restart.in
            fi
        else
            sed -i "s/restartn/restart1/g" production_nve_restart.in
        fi

        if [ "${GPUS}" == "0" ]
        then
            if [ -z ${CPU_LIST+x} ]
            then
                $MPI_BIN -np $CPU_THREADS --use-hwthread-cpus $CPU_LIST $LAMMPS_BIN -in production_nve_restart.in
            else
                $MPI_BIN -np $CPU_THREADS --use-hwthread-cpus --bind-to core --cpu-set $CPU_LIST $LAMMPS_BIN -in production_nve_restart.in
            fi
        else
            if [ -z ${CPU_LIST+x} ]
            then
                $MPI_BIN -np $CPU_THREADS --use-hwthread-cpus $LAMMPS_BIN -sf gpu -pk gpu $GPUS -in production_nve_restart.in
            else
                $MPI_BIN -np $CPU_THREADS --use-hwthread-cpus --bind-to core --cpu-set $CPU_LIST $LAMMPS_BIN -sf gpu -pk gpu $GPUS -in production_nve_restart.in
            fi
        fi
    else
        # Perform nvt run
        cp "${input_path}/production_nve.in" production_nve.in

        if [ "${GPUS}" == "0" ]
        then
            if [ -z ${CPU_LIST+x} ]
            then
                $MPI_BIN -np $CPU_THREADS --use-hwthread-cpus $CPU_LIST $LAMMPS_BIN -in production_nve.in
            else
                $MPI_BIN -np $CPU_THREADS --use-hwthread-cpus --bind-to core --cpu-set $CPU_LIST $LAMMPS_BIN -in production_nve.in
            fi
        else
            if [ -z ${CPU_LIST+x} ]
            then
                $MPI_BIN -np $CPU_THREADS --use-hwthread-cpus $LAMMPS_BIN -sf gpu -pk gpu $GPUS -in production_nve.in
            else
                $MPI_BIN -np $CPU_THREADS --use-hwthread-cpus --bind-to core --cpu-set $CPU_LIST $LAMMPS_BIN -sf gpu -pk gpu $GPUS -in production_nve.in
            fi
        fi
    fi
} > "${log_file}" 2>&1
fi

echo "Critical: NVE production simulation completed."
echo "Critical: Performing Cluster Analysis."
{
cp "${input_path}/analysis_nve.in" analysis_nve.in
if [ "${GPUS}" == "0" ]
then
    if [ -z ${CPU_LIST+x} ]
    then
        $MPI_BIN -np $CPU_THREADS --use-hwthread-cpus $CPU_LIST $LAMMPS_BIN $CPU_THREADS -in analysis_nve.in
    else
        $MPI_BIN -np $CPU_THREADS --use-hwthread-cpus --bind-to core --cpu-set $CPU_LIST $LAMMPS_BIN -in analysis_nve.in
    fi
else
    if [ -z ${CPU_LIST+x} ]
    then
        $MPI_BIN -np $CPU_THREADS --use-hwthread-cpus $LAMMPS_BIN -sf gpu -pk gpu $GPUS -in analysis_nve.in
    else
        $MPI_BIN -np $CPU_THREADS --use-hwthread-cpus --bind-to core --cpu-set $CPU_LIST $LAMMPS_BIN -sf gpu -pk gpu $GPUS -in analysis_nve.in
    fi
fi
} > "analysis_${log_file}" 2>&1
echo "Critical: Cluster Analysis Complete."
cd "${cwd}" || exit

cd "${cwd_production_nve}" || exit 1