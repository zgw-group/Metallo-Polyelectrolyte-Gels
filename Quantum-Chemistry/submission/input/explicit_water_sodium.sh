#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#
# Author     : Pierre Walker (GitHub: @pw0908)
# Date       : 2024-02-23
# Description: Script to set global variables and preferences for the calculation

# Hardware ####################################################################

export CPU_THREADS='4' # number of CPU threads to use (-1 = all available)

# System components ###########################################################
# tag for system
export TAG_JOBID="0.1.0" # tag to append to system name

# metal specification
export METAL="Na"         # Give the metal name
export OX_STATE="I"       # Give the oxidation state of the metal
export METAL_CHARGE="1"   # Give the charge of the metal
export SPIN="1"           # Give the spin of the metal complex (e.g. 5 for Fe(II), 4 for Fe(III))

# ligand specification
LIGAND=("C(C(=O)[O-])","water") # Give the ligand name
export LIGAND
BINDING_SITES=("3,4","")    # Give the binding sites for the ligand
export BINDING_SITES
LIGAND_CHARGE=("-1","0")     # Give the charge of the ligand
export LIGAND_CHARGE
NUM_LIGAND=("1","4")         # Give the number of ligands in the complex
export NUM_LIGAND
export TOTAL_LIGAND_SPIN="1"

# complex specification
export COMPLEX_SPIN="1" # Give the spin of the complex
export COORD="6"        # Give the coordination number of the metal

# Calculation #################################################################
# DFT specification
export FUNCTIONAL="B3LYP"                       # Give the DFT functional
export BASIS_SET="def2-TZVPP D3BJ CPCM(water)"  # Give the basis set