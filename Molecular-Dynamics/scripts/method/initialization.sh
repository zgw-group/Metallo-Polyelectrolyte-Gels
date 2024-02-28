#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#
# Author     : Pierre Walker (GitHub: @pw0908)
# Date       : 2024-02-23
# Description: Script to create initial system for MD simulations
# Usage      : ./system_initialization.sh
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
cwd_initialization="$(pwd)"
cwd="$(pwd)/1-initialization"
log_file="initialization.log"

echo "INFO: Generating initial system"
# Make and enter the initial directory
# move to working directory
mkdir -p "${cwd}"
cd "${cwd}" || exit

{
if [ ! -f input.data ]
then
    
    # Initialise the box
    cp "${input_path}/init_ionomer.py" init_ionomer.py
    
    sed -i "s/rho/$DENSITY/g" init_ionomer.py

    sed -i "s/Npoly/$NCHAIN/g" init_ionomer.py
    sed -i "s/Nbb/$SPARSITY/g" init_ionomer.py
    sed -i "s/Nmono/$NMONOMER/g" init_ionomer.py

    sed -i "s/Nion/$NMETAL/g" init_ionomer.py
    sed -i "s/Z_c/$METAL_CHARGE/g" init_ionomer.py
    sed -i "s/r_i/$METAL_DIAMETER/g" init_ionomer.py

    $PYTHON_BIN init_ionomer.py
    
    # Set the conditions in the box
    cp "${input_path}/parameters.in" parameters.in
    cp "${input_path}/thermo.in" thermo.in

    if [ "$GPUS" == "0" ]
    then
        sed -i "s/package gpu/#package gpu/g" parameters.in
    fi

    sed -i "s/Temp/$TEMPERATURE/g" parameters.in
    sed -i "s/e_r/$DIELECTRIC/g" parameters.in
fi
} > "${log_file}" 2>&1