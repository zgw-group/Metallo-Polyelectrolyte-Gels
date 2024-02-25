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

# Metal tag
METAL_TAG="${METAL}-${OX_STATE}-${SPIN}"
export METAL_TAG

# ligand tags
for i in "${!LIGAND[@]}"; do
    LIGAND_TAG="${LIGAND_TAG}-${LIGAND[i]}-${BINDING_SITES[i]}-${NUM_LIGAND[i]}"
done
export LIGAND_TAG

# complex tag
COMPLEX_TAG="${COMPLEX_SPIN}"

# method tag
METHOD_TAG="${FUNCTIONAL}-${BASIS_SET}"

# Combine tags
export TAG="${TAG_JOBID}-${METAL_TAG}-${LIGAND_TAG}-${COMPLEX_SPIN}-${METHOD_TAG}"
