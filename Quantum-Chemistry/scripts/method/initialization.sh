#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#
# Author     : Pierre Walker (GitHub: @pw0908)
# Date       : 2024-02-23
# Description: Script to create initial system for QC calculations
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
cwd="$(pwd)/1-initiliazation"
log_file="system_initialization.log"

echo "INFO: Generating initial system"
# Make and enter the initial directory
# move to working directory
mkdir -p "${cwd}"
cd "${cwd}" || exit
echo $METAL
echo $LIGAND

{
if [ ! -f initial.xyz ] # Check if the initial.xyz file exists. If it does, then the run probably has already been performed.
then
    # Copy the input files for the initial guess to this repository
    cp ${input_path}/initial.inp initial.inp

    # Sum of the charges of the ligands
    NET_LIGAND_CHARGE="0"
    for i in "${!NUM_LIGAND[@]}"; do
        NET_LIGAND_CHARGE=$(($NET_LIGAND_CHARGE + $NUM_LIGAND[i] * $LIGAND_CHARGE[i]))
    done
    NET_CHARGE=$(($METAL_CHARGE + $NET_LIGAND_CHARGE))
    LIGANDS=""
    BINDINGS=""
    NUM_LIGANDS=""
    for i in "${!LIGAND[@]}"; do
        LIGANDS="${LIGANDS}${LIGAND[i]},"
        BINDINGS="${BINDINGS}${BINDING_SITES[i]}/"
        NUM_LIGANDS="${NUM_LIGANDS}${NUM_LIGAND[i]},"
    done
    # echo $NET_LIGAND_CHARGE
    LIGANDS=${LIGANDS::-1}
    BINDINGS=${BINDINGS::-1}
    NUM_LIGANDS=${NUM_LIGANDS::-1}

    # Replace the placeholders in the input file with the correct values
    sed -i'' -e "s/metal/$METAL/g" initial.inp
    sed -i'' -e "s/spinmultiplicity/$SPIN/g" initial.inp
    sed -i'' -e "s/netcharge/$NET_CHARGE/g" initial.inp
    sed -i'' -e "s/oxidationstate/$OX_STATE/g" initial.inp
    sed -i'' -e "s/ligandsmile/$LIGANDS/g" initial.inp
    sed -i'' -e "s/bindingsites/$BINDINGS/g" initial.inp
    sed -i'' -e "s/numligand/$NUM_LIGANDS/g" initial.inp

    # Obtain the initial guess for the structure from MolSimplify
    molsimplify -i initial.inp

    # Rename the output file to initial.xyz and remove all other files
    echo "INFO: Cleaning up"
    find . -name '*xyz' -exec mv {} initial.xyz \;
    rm -r Runs
fi
} > "${log_file}" 2>&1
# Exit the directory and return to the main folder
echo "Critical: Finished system initialization"
cd "${cwd_initialization}" || exit 1