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
ORCA_BIN="${script_path}/../../software/orca/orca"
MFW_BIN="${script_path}/../../software/Multiwfn/Multiwfn"

export ORCA_BIN
export MFW_BIN

hostname=$(hostname -s)

if [[ "${hostname}" == "pierre-walker" ]]; then
    TOTAL_CPU=24
    CPU_LIST="$(python3 ${script_path}/../parameters/cpu_avail.py ${TOTAL_CPU} $CPU_THREADS)"
fi    