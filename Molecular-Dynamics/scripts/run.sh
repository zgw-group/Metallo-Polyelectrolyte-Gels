#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#
# Author     : Pierre Walker (GitHub: @pw0908)
# Date       : 2024-02-23
# Description: Script to set global variables and preferences for the simulation
#              and run the simulation.
# Usage      : ./run.sh [global_preferences] [simulation_preferences]

# built-in shell options
set -o errexit  # exit when a command fails. Add || true to commands allowed to fail
set -o nounset  # exit when script tries to use undeclared variables
set -o pipefail # exit when a command in a pipe fails

package="run.sh" # name of this script

# ##############################################################################
# Input parsing ################################################################
# ##############################################################################

# global preferences file
global_preferences="${1}"

# simulation method flags
flag_initialization=false
flag_equilibration=false
flag_production_nve=false
flag_deformation=false
flag_analysis_nve=false
flag_analysis_ip=false

# action flags
flag_archive=false

# remove global preferences from command line arguments (check that first argument is not a flag)
if [[ "${global_preferences}" != -* ]]; then
    shift
fi

# parse command line arguments
for arg in "$@"; do
    case "${arg}" in
    -i | --initialize)
        flag_initialization=true
        ;;
    -e | --equilibrate)
        flag_equilibration=true
        ;;
    -nve | --nve)
        flag_production_nve=true
        ;;
    -def | --deform)
        flag_deformation=true
        ;;
    -anve | --analysis_nve)
        flag_analysis_nve=true
        ;;
    -aip | --analysis_ip)
        flag_analysis_ip=true
        export IPRANGE="${2}"
        ;;
    -a | --all)
        flag_initialization=true
        flag_equilibration=true
        flag_production_nve=true
        flag_deformation=true
        ;;
    -h | --help)
        echo "Usage: ${package} [global_preferences] [simulation_preferences]"
        echo ""
        echo "[global_preferences] is an input shell script that sets global variables and parameters for the simulation."
        echo ""
        echo "[simulation_preferences] is a list of flags that specify which simulation methods to run."
        echo "If a production method is selected, the sampling method must also be selected."
        echo ""
        echo "Calculation methods:"
        echo "  -i, --initialize      Initialize the simulation."
        echo "  -e, --equilibrate     Perform equilibriation simulation."
        echo "  -nve, --nve           Perform production NVE simulation."
        echo "  -def, --deform        Perform deformation simulation."
        echo "  -anve, --analysis_nve Perform analysis of NVE simulation."
        echo "  -a, --all             Run all simulation methods."
        echo ""
        echo "Other:"
        echo "  -h, --help            Display this help message."
        echo ""
        exit 0
        ;;
    *)
        # echo "ERROR: Unrecognized argument: ${arg}"
        # echo "Usage: ${package} [global_preferences] [simulation_preferences] [sampling]"
        # exit 1
        # ;;
    esac
done

# input checking
if [[ $# -lt 1 ]]; then
    echo "ERROR: Too few arguments."
    echo "Arguments: ${*}"
    echo "Usage: ${package} [global_preferences] [simulation_preferences]"
    echo "Use '${package} --help' for more information."
    exit 1
fi

# check that at least one simulation method was selected
if [[ "${flag_initialization}" = false ]] && [[ "${flag_equilibration}" = false ]] && [[ "${flag_production_nve}" = false ]] && [[ "${flag_deformation}" = false ]] && [[ "${flag_analysis_nve}" = false ]] && [[ "${flag_analysis_ip}" = false ]]; then
    echo "ERROR: No simulation methods selected."
    echo "Usage: ${package} [global_preferences] [simulation_preferences]"
    echo "Use '${package} --help' for more information."
    exit 1
fi

# ##############################################################################
# Load input preferences #######################################################
# ##############################################################################

# find path to this script
script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
project_path="${script_path}/.."

# load global preferences
# shellcheck source=../submission/input/1-model-system/1.0_neatdimer_10nmbox.sh
source "${global_preferences}"
# shellcheck source=variable/system.sh
source "${project_path}/scripts/variable/system.sh"
# shellcheck source=variable/node.sh
source "${project_path}/scripts/variable/node.sh"

# create simulation directory and move into it
mkdir -p "${project_path}/data/${TAG}"
cd "${project_path}/data/${TAG}" || exit 1

# ##############################################################################
# Run simulation methods #######################################################
# ##############################################################################

# initialize simulation
if [[ "${flag_initialization}" = true ]]; then
    echo "Initializing simulation..."
    source "${project_path}/scripts/method/initialization.sh"
fi

# equilibrate simulation
if [[ "${flag_equilibration}" = true ]]; then
    echo "Equilibrating simulation..."
    source "${project_path}/scripts/method/equilibration.sh"
fi

# run production simulation
if [[ "${flag_production_nve}" = true ]]; then
    echo "Running production NVE simulation..."
    source "${project_path}/scripts/method/production_nve.sh"
fi

# run deformation simulation
if [[ "${flag_deformation}" = true ]]; then
    echo "Running deformation simulation..."
    source "${project_path}/scripts/method/production_deform.sh"
fi

# run analysis of NVE simulation
if [[ "${flag_analysis_nve}" = true ]]; then
    echo "Analyzing NVE simulation..."
    source "${project_path}/scripts/method/analysis_nve.sh"
fi

# run ion-pair analysis of NVE simulation
if [[ "${flag_analysis_ip}" = true ]]; then
    echo "Analyzing NVE simulation..."
    export IPRANGE="${2}"
    source "${project_path}/scripts/method/analysis_ion_pair.sh"
fi

# ##############################################################################
# End ##########################################################################
# ##############################################################################

echo "INFO: ${package} completed successfully."
