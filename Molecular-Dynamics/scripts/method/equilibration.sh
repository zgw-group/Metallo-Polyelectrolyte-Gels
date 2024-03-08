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

# NVT Equilibration ###################################################################
cwd_nvt="$(pwd)/1-nvt"
log_file="equilibration_nvt.log"

# Make and enter the initial directory
# move to working directory
mkdir -p "${cwd_nvt}"
cd "${cwd_nvt}" || exit

# Equilibrate the system
echo "INFO: Equilibrating system in NVT"


if [ ! -f equilibrated_nvt.data ]
then
    {
    if test -f "simulation.restart1"
    then
        cp "${input_path}/equilibration_nvt_restart.in" equilibration_nvt_restart.in

        if test -f "simulation.restart2"
        then
            if [ "simulation.restart1" -nt "simulation.restart2" ]
            then
                sed -i "s/restartn/restart1/g" equilibration_nvt_restart.in
            else
                sed -i "s/restartn/restart2/g" equilibration_nvt_restart.in
            fi
        else
            sed -i "s/restartn/restart1/g" equilibration_nvt_restart.in
        fi

        if [ "${GPUS}" == "0" ]
        then
            if [ -z ${CPU_LIST+x} ]
            then
                $MPI_BIN -np $CPU_THREADS --use-hwthread-cpus $CPU_LIST $LAMMPS_BIN -in equilibration_nvt_restart.in
            else
                $MPI_BIN -np $CPU_THREADS --use-hwthread-cpus --bind-to core --cpu-set $CPU_LIST $LAMMPS_BIN -in equilibration_nvt_restart.in
            fi
        else
            if [ -z ${CPU_LIST+x} ]
            then
                $MPI_BIN -np $CPU_THREADS --use-hwthread-cpus $LAMMPS_BIN -sf gpu -pk gpu $GPUS -in equilibration_nvt_restart.in
            else
                $MPI_BIN -np $CPU_THREADS --use-hwthread-cpus --bind-to core --cpu-set $CPU_LIST $LAMMPS_BIN -sf gpu -pk gpu $GPUS -in equilibration_nvt_restart.in
            fi
        fi
    else
        # Perform equilibration run
        cp "${input_path}/equilibration_nvt.in" equilibration_nvt.in

        if [ "${GPUS}" == "0" ]
        then
            if [ -z ${CPU_LIST+x} ]
            then
                $MPI_BIN -np $CPU_THREADS --use-hwthread-cpus $CPU_LIST $LAMMPS_BIN -in equilibration_nvt.in
            else
                $MPI_BIN -np $CPU_THREADS --use-hwthread-cpus --bind-to core --cpu-set $CPU_LIST $LAMMPS_BIN -in equilibration_nvt.in
            fi
        else
            if [ -z ${CPU_LIST+x} ]
            then
                $MPI_BIN -np $CPU_THREADS --use-hwthread-cpus $LAMMPS_BIN -sf gpu -pk gpu $GPUS -in equilibration_nvt.in
            else
                $MPI_BIN -np $CPU_THREADS --use-hwthread-cpus --bind-to core --cpu-set $CPU_LIST $LAMMPS_BIN -sf gpu -pk gpu $GPUS -in equilibration_nvt.in
            fi
        fi
    fi
    } > "${log_file}" 2>&1
fi
cd "${cwd}" || exit

echo "Critical: Equilibration NVT simulation completed."

# Output files
cwd_npt="$(pwd)/2-npt"
log_file="equilibration_npt.log"

# Make and enter the initial directory
# move to working directory
mkdir -p "${cwd_npt}"
cd "${cwd_npt}" || exit

# Equilibrate the system
echo "INFO: Equilibrating system in NPT"

if [ ! -f equilibrated_npt.data ]
then
    {
    if test -f "simulation.restart1"
    then
        cp "${input_path}/equilibration_restart.in" equilibration_npt_restart.in

        if test -f "simulation.restart2"
        then
            if [ "simulation.restart1" -nt "simulation.restart2" ]
            then
                sed -i "s/restartn/restart1/g" equilibration_npt_restart.in
            else
                sed -i "s/restartn/restart2/g" equilibration_npt_restart.in
            fi
        else
            sed -i "s/restartn/restart1/g" equilibration_npt_restart.in
        fi

        if [ "${GPUS}" == "0" ]
        then
            if [ -z ${CPU_LIST+x} ]
            then
                $MPI_BIN -np $CPU_THREADS --use-hwthread-cpus $CPU_LIST $LAMMPS_BIN -in equilibration_npt_restart.in
            else
                $MPI_BIN -np $CPU_THREADS --use-hwthread-cpus --bind-to core --cpu-set $CPU_LIST $LAMMPS_BIN -in equilibration_npt_restart.in
            fi
        else
            if [ -z ${CPU_LIST+x} ]
            then
                $MPI_BIN -np $CPU_THREADS --use-hwthread-cpus $LAMMPS_BIN -sf gpu -pk gpu $GPUS -in equilibration_npt_restart.in
            else
                $MPI_BIN -np $CPU_THREADS --use-hwthread-cpus --bind-to core --cpu-set $CPU_LIST $LAMMPS_BIN -sf gpu -pk gpu $GPUS -in equilibration_npt_restart.in
            fi
        fi
    else
        # Perform equilibration run
        cp "${input_path}/equilibration_npt.in" equilibration_npt.in

        if [ "${GPUS}" == "0" ]
        then
            if [ -z ${CPU_LIST+x} ]
            then
                $MPI_BIN -np $CPU_THREADS --use-hwthread-cpus $CPU_LIST $LAMMPS_BIN -in equilibration_npt.in
            else
                $MPI_BIN -np $CPU_THREADS --use-hwthread-cpus --bind-to core --cpu-set $CPU_LIST $LAMMPS_BIN -in equilibration_npt.in
            fi
        else
            if [ -z ${CPU_LIST+x} ]
            then
                $MPI_BIN -np $CPU_THREADS --use-hwthread-cpus $LAMMPS_BIN -sf gpu -pk gpu $GPUS -in equilibration_npt.in
            else
                $MPI_BIN -np $CPU_THREADS --use-hwthread-cpus --bind-to core --cpu-set $CPU_LIST $LAMMPS_BIN -sf gpu -pk gpu $GPUS -in equilibration_npt.in
            fi
        fi
    fi
    } > "${log_file}" 2>&1
fi

cd "${cwd}" || exit

echo "Critical: Equilibration NPT simulation completed."

cp "${cwd_npt}/equilibrated_npt.data" "${cwd}/equilibrated.data"

cd "${cwd_equilibration}" || exit 1