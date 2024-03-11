#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#
# Author     : Pierre Walker (GitHub: @pw0908)
# Date       : 2024-02-23
# Description: Script to set generic global variables pertaining to the node
#              hardware and software.
# Notes      : Script assumes software has been installed in the software folder.

# ##############################################################################
# Set software and hardware ####################################################
# ##############################################################################

# set paths to executables
script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
export LAMMPS_BIN="${script_path}/../../software/lammps_new/build/lmp"
export VMD_BIN="${script_path}/../../software/vmd/plugins/LINUXAMD64/molfile/"
export MPI_BIN="/home/pjwalker/software/openmpi_4.1.5-gcc_11.4.0-cuda_11.6.124/bin/mpirun"

hostname=$(hostname -s)

if [[ "${hostname}" == "pierre-walker" ]]; then
    # If on Pierre's machine, get the list of CPUs you can pin to.
    TOTAL_CPU=24
    export CPU_LIST="$(python3 ${script_path}/../parameters/cpu_avail.py ${TOTAL_CPU} $CPU_THREADS)"
    echo "CPUs pinned: ${CPU_LIST}"
    export PYTHON_BIN="/home/pjwalker/anaconda3/bin/python3"
fi    