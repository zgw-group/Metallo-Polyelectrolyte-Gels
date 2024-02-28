#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#
# Author     : Pierre Walker (GitHub: @pw0908)
# Date       : 2024-02-23
# Description: Script to set generic global variables pertaining to the system.
# Notes      : Script should only be called from the main run.sh script.

# find path to this script
script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
project_path="${script_path}/../.."

# ##############################################################################
# Set simulation identifiers ###################################################
# ##############################################################################

# Polymer tag
POLYMER_TAG="POL_${NCHAIN}-${SPARSITY}-${NMONOMER}"
export POLYMER_TAG

# Metal tag
METAL_TAG="MET_${NMETAL}-${METAL_CHARGE}_${METAL_DIAMETER}"

# system tag
SYSTEM_TAG="diel_${DIELECTRIC}_dens_${DENSITY}_temp_${TEMPERATURE}"

# Combine tags
export TAG="${TAG_JOBID}-${METAL_TAG}-${POLYMER_TAG}-${SYSTEM_TAG}"