#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#
# Author     : Alec Glisman (GitHub: @alec-glisman)
# Date       : 2023-08-30
# Description: Script to set generic global variables pertaining to the node
#              hardware and software.
# Notes      : Script should only be called from the main run.sh script.

# ##############################################################################
# Set software and hardware ####################################################
# ##############################################################################

# set paths to executables
hostname="$(hostname -s)"
if [[ "${hostname}" == "zeal" || "${hostname}" == "node"* ]]; then
    module_root="/nfs/zeal_nas/home_mount/modules"
    compilers="gcc_12.3.0-cuda_12.2.128"
    mpi_root="${module_root}/openmpi_4.1.5-${compilers}"
    plumed_root="${module_root}/plumed_mpi_2.9.0-${compilers}"
    gmx_root="${module_root}/gromacs_mpi_2023-plumed_mpi_2.9.0-${compilers}"

    MPI_BIN="${mpi_root}/bin/mpiexec"
    PLUMED_BIN="${plumed_root}/bin/plumed"
    PLUMED_KERNEL="${plumed_root}/lib/libplumedKernel.so"
    GMX_BIN="${gmx_root}/bin/gmx_mpi"

    PATH="${plumed_root}/bin:${gmx_root}/bin:${mpi_root}/bin:${PATH}"
    LD_LIBRARY_PATH="${plumed_root}/lib:${gmx_root}/lib:${LD_LIBRARY_PATH}"
    # shellcheck disable=SC2139
    alias plumed="${PLUMED_BIN}/bin/plumed"

elif [[ "${hostname}" == "desktop" ]]; then
    module_root="/home/aglisman/software"
    compilers="gcc_12.3.0-cuda_12.0.140"
    mpi_root="/usr"
    plumed_root="${module_root}/plumed_mpi_2.9.0-${compilers}"
    gmx_root="${module_root}/gromacs_mpi_2023-plumed_mpi_2.9.0-${compilers}"

    MPI_BIN="${mpi_root}/bin/mpiexec"
    PLUMED_BIN="${plumed_root}/bin/plumed"
    PLUMED_KERNEL="${plumed_root}/lib/libplumedKernel.so"
    GMX_BIN="${gmx_root}/bin/gmx_mpi"

    PATH="${plumed_root}/bin:${gmx_root}/bin:${mpi_root}/bin:${PATH}"
    LD_LIBRARY_PATH="${plumed_root}/lib:${gmx_root}/lib:${LD_LIBRARY_PATH}"
    # shellcheck disable=SC2139
    alias plumed="${PLUMED_BIN}/bin/plumed"

else
    MPI_BIN="mpiexec"
    ORCA_BIN="gmx_mpi"
    PLUMED_BIN="plumed"
fi

export MPI_BIN
export PLUMED_BIN
export PLUMED_KERNEL
export GMX_BIN
export PATH

# slurm defaults supersedes hardware input parameters
if [[ -n "${SLURM_NTASKS+x}" ]] && [[ "${CPU_THREADS}" == "-1" ]]; then
    export CPU_THREADS="${SLURM_NTASKS}"
fi

if [[ -n ${SLURM_GPUS+x} ]]; then
    if [[ "${SLURM_GPUS}" == "1" ]] && [[ "${GPU_IDS}" == "-1" ]]; then
        export GPU_IDS="${SLURM_GPUS}"
    fi
fi

# define number of computational nodes
# shellcheck disable=SC2236
if [[ ! -n "${SLURM_JOB_NUM_NODES+x}" ]]; then
    export SLURM_JOB_NUM_NODES='1'
fi
