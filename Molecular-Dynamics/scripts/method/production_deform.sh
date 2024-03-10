#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#
# Author     : Pierre Walker (GitHub: @pw0908)
# Date       : 2024-02-23
# Description: Script to perform deformation MD on the system
# Usage      : ./production_deform.sh
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
cwd_deformation="$(pwd)"
cwd="$(pwd)/4-deformation"
log_file="deformation.log"

# Make and enter the initial directory
# move to working directory
mkdir -p "${cwd}"
cd "${cwd}" || exit

# Equilibrate the system
echo "INFO: Deforming the system"
{
if [ ! -f production_deform.data ]
then
    if test -f "simulation.restart1"
    then
        cp "${input_path}/production/production_deform_restart.in" production_deform_restart.in

        sed -i "s/MAX_STRAIN/${MAX_STRAIN}/g" production_deform_restart.in
        sed -i "s/STRAIN_RATE/${DEFORMATION}/g" production_deform_restart.in

        if test -f "simulation.restart2"
        then
            if [ "simulation.restart1" -nt "simulation.restart2" ]
            then
                sed -i "s/restartn/restart1/g" production_deform_restart.in
            else
                sed -i "s/restartn/restart2/g" production_deform_restart.in
            fi
        else
            sed -i "s/restartn/restart1/g" production_deform_restart.in
        fi

        mv --backup=t stress.txt stress.txt.bak

        if [ "${GPUS}" == "0" ]
        then
            if [ -z ${CPU_LIST+x} ]
            then
                $MPI_BIN -np $CPU_THREADS --use-hwthread-cpus $CPU_LIST $LAMMPS_BIN -in production_deform_restart.in
            else
                $MPI_BIN -np $CPU_THREADS --use-hwthread-cpus --bind-to core --cpu-set $CPU_LIST $LAMMPS_BIN -in production_deform_restart.in
            fi
        else
            if [ -z ${CPU_LIST+x} ]
            then
                $MPI_BIN -np $CPU_THREADS --use-hwthread-cpus $LAMMPS_BIN -sf gpu -pk gpu $GPUS -in production_deform_restart.in
            else
                $MPI_BIN -np $CPU_THREADS --use-hwthread-cpus --bind-to core --cpu-set $CPU_LIST $LAMMPS_BIN -sf gpu -pk gpu $GPUS -in production_deform_restart.in
            fi
        fi

    else
        # Perform nvt run
        cp "${input_path}/production/production_deform.in" production_deform.in

        sed -i "s/MAX_STRAIN/${MAX_STRAIN}/g" production_deform.in
        sed -i "s/STRAIN_RATE/${DEFORMATION}/g" production_deform.in

        if [ "${GPUS}" == "0" ]
        then
            if [ -z ${CPU_LIST+x} ]
            then
                $MPI_BIN -np $CPU_THREADS --use-hwthread-cpus $CPU_LIST $LAMMPS_BIN -in production_deform.in
            else
                $MPI_BIN -np $CPU_THREADS --use-hwthread-cpus --bind-to core --cpu-set $CPU_LIST $LAMMPS_BIN -in production_deform.in
            fi
        else
            if [ -z ${CPU_LIST+x} ]
            then
                $MPI_BIN -np $CPU_THREADS --use-hwthread-cpus $LAMMPS_BIN -sf gpu -pk gpu $GPUS -in production_deform.in
            else
                $MPI_BIN -np $CPU_THREADS --use-hwthread-cpus --bind-to core --cpu-set $CPU_LIST $LAMMPS_BIN -sf gpu -pk gpu $GPUS -in production_deform.in
            fi
        fi
    fi
fi
} > "${log_file}" 2>&1

tail -n +3 -q stress.txt.bak.* >> stress.txt

cd "${cwd}" || exit

echo "Critical: Deformation simulation completed."
cd "${cwd_deformation}" || exit 1