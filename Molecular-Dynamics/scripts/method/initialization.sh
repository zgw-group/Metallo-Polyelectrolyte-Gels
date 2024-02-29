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


# Add molecular simulation parameters in global folder
cp "${input_path}/parameters.in" parameters.in
cp "${input_path}/thermo.in" thermo.in

if [ "$GPUS" == "0" ]
then
    sed -i "s/package gpu/#package gpu/g" parameters.in
fi

sed -i "s/Temp/$TEMPERATURE/g" parameters.in
sed -i "s/e_r/$DIELECTRIC/g" parameters.in

# Make and enter the initial directory
# move to working directory
mkdir -p "${cwd}"
cd "${cwd}" || exit

# Initialize the system
echo "INFO: Generating initial system"
mkdir -p "${cwd}/0-initial_system"
cd "${cwd}/0-initial_system" || exit

{
if [ ! -f input.data ]
then
    
    # Initialise the box
    cp "${input_path}/initialize.py" initialize.py
    
    sed -i "s/rho/$DENSITY/g" initialize.py

    sed -i "s/Npoly/$NCHAIN/g" initialize.py
    sed -i "s/Nbb/$SPARSITY/g" initialize.py
    sed -i "s/Nmono/$NMONOMER/g" initialize.py

    sed -i "s/Nion/$NMETAL/g" initialize.py
    sed -i "s/Z_c/$METAL_CHARGE/g" initialize.py
    sed -i "s/r_i/$METAL_DIAMETER/g" initialize.py

    $PYTHON_BIN initialize.py

    rm initialize.py
fi
} > "${log_file}" 2>&1
echo "Critical: System initialized."
cd "${cwd}" || exit

echo "INFO: Minimizing initial system energy."
# Make and enter the initial directory
# move to working directory
mkdir -p "${cwd}/1-energy_minimisation"
cd "${cwd}/1-energy_minimisation" || exit

{
if [ ! -f initial.data ]
then
    # Perform energy minimisation
    cp "${input_path}/energy_minimize.in" energy_minimize.in

    if [ "${GPUS}" == "0" ]
    then
        if [ -z ${CPU_LIST+x} ]
        then
            $MPI_BIN -np $CPU_THREADS --use-hwthread-cpus --bind-to core --cpu-set $CPU_LIST $LAMMPS_BIN -in energy_minimize.in
        else
            $MPI_BIN -np $CPU_THREADS --use-hwthread-cpus $LAMMPS_BIN -in energy_minimize.in
        fi
    else
        if [ -z ${CPU_LIST+x} ]
        then
            $MPI_BIN -np $CPU_THREADS --use-hwthread-cpus --bind-to core --cpu-set $CPU_LIST $LAMMPS_BIN  -sf gpu -pk gpu $GPUS -in energy_minimize.in
        else
            $MPI_BIN -np $CPU_THREADS --use-hwthread-cpus $LAMMPS_BIN -sf gpu -pk gpu $GPUS -in energy_minimize.in
        fi
    fi  
fi

# Move the initial structure file to the main directory
mv initial.data "${cwd}/initial.data"

} > "${log_file}" 2>&1
cd "${cwd}" || exit

echo "Critical: Initial system energy minimized."
cd "${cwd_initialization}" || exit 1