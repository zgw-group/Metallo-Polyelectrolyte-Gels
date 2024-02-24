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
flag_optimisation=false
flag_binding=false
flag_ir_spectrum=false

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
    -opt | --optimise)
        flag_optimisation=true
        ;;
    -b | --binding)
        flag_binding=true
        ;;
    -ir | --ir_spectrum)
        flag_ir_spectrum=true
        ;;
    -a | --all)
        flag_initialization=true
        flag_optimisation=true
        flag_binding=true
        flag_ir_spectrum=true
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
        echo "  -i, --initialize    Initialize the calculation."
        echo "  -opt, --optimise    Optimise the initial structure."
        echo "  -b, --binding       Calculate the binding energy of the complex."
        echo "  -ir, --ir_spectrum  Calculate the IR spectrum of the complex."
        echo "  -a, --all           Run all simulation methods."
        echo ""
        echo "Other:"
        echo "  -h, --help          Display this help message."
        echo ""
        exit 0
        ;;
    *)
        echo "ERROR: Unrecognized argument: ${arg}"
        echo "Usage: ${package} [global_preferences] [simulation_preferences] [sampling]"
        exit 1
        ;;
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
if [[ "${flag_initialization}" = false ]] && [[ "${flag_equilibration}" = false ]] && [[ "${flag_production}" = false ]]; then
    echo "ERROR: No simulation methods selected."
    echo "Usage: ${package} [global_preferences] [simulation_preferences]"
    echo "Use '${package} --help' for more information."
    exit 1
fi

# check that if production was selected, at least one sampling method was selected
if [[ "${flag_production}" = true ]] && [[ "${flag_sampling_md}" = false ]] && [[ "${FLAG_SAMPLING_OPES_EXPLORE}" = false ]] && [[ "${flag_sampling_opes_one}" = false ]] && [[ "${flag_sampling_hremd}" = false ]] && [[ "${FLAG_SAMPLING_METAD}" = false ]]; then
    echo "ERROR: No production sampling methods selected."
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

# export simulation methods
export FLAG_SAMPLING_METAD
export FLAG_SAMPLING_OPES_EXPLORE

# create simulation directory and move into it
mkdir -p "${project_path}/data/${TAG}"
cd "${project_path}/data/${TAG}" || exit 1

# ##############################################################################
# Run simulation methods #######################################################
# ##############################################################################

# initialize simulation
if [[ "${flag_initialization}" = true ]]; then
    echo "Initializing simulation..."
    "${project_path}/scripts/method/initialization.sh"
fi

# equilibrate simulation
if [[ "${flag_equilibration}" = true ]]; then
    echo "Equilibrating simulation..."
    "${project_path}/scripts/method/equilibration.sh"
fi

# run production simulation
if [[ "${flag_production}" = true ]]; then
    echo "INFO: Archiving simulation boolean: ${flag_archive}"
    export FLAG_ARCHIVE="${flag_archive}"

    # find walltime remaining
    # shellcheck source=variable/slurm.sh
    source "${project_path}/scripts/variable/slurm.sh"
    echo "INFO: WALLTIME_HOURS: ${WALLTIME_HOURS}"

    if [[ "${flag_sampling_hremd}" = true ]]; then
        echo "Equilibrating HREMD..."
        "${project_path}/scripts/method/equilibration_hremd.sh"

        # recalculate walltime remaining
        # shellcheck source=variable/slurm.sh
        source "${project_path}/scripts/variable/slurm.sh"
        echo "INFO: WALLTIME_HOURS for HREMD production: ${WALLTIME_HOURS}"

        echo "Sampling HREMD..."
        "${project_path}/scripts/method/sampling_hremd.sh"

    elif [[ "${flag_sampling_md}" = true ]]; then
        echo "Sampling MD..."
        "${project_path}/scripts/method/sampling_md.sh"

    elif [[ "${FLAG_SAMPLING_METAD}" = true ]]; then
        echo "Sampling Metadynamics..."
        "${project_path}/scripts/method/sampling_metadynamics.sh"

    elif [[ "${FLAG_SAMPLING_OPES_EXPLORE}" = true ]]; then
        echo "Sampling OPES Explore..."
        "${project_path}/scripts/method/sampling_opes_explore.sh"

    elif [[ "${flag_sampling_opes_one}" = true ]]; then
        echo "Sampling OneOPES..."
        "${project_path}/scripts/method/sampling_opes_one.sh"
    fi

fi

# ##############################################################################
# End ##########################################################################
# ##############################################################################

echo "INFO: ${package} completed successfully."
