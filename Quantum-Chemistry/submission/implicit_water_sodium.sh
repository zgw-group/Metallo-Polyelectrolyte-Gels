#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#
# Author     : Pierre Walker (GitHub: @pw0908)
# Date       : 2024-02-23
# Description: Script to set global variables and preferences for the calculation

# Hardware ####################################################################

export CPU_THREADS='20' # number of CPU threads to use (-1 = all available)
export CPU_PINS='0'     # offset for CPU thread pinning (-1 = no offset)

# System components ###########################################################
# tag for system
export TAG_JOBID="0.1.0" # tag to append to system name

# metal specification
export METAL="Na"         # Give the metal name
export OX_STATE="I"       # Give the oxidation state of the metal
export METAL_CHARGE="1"   # Give the charge of the metal
export SPIN="1"           # Give the spin of the metal complex (e.g. 5 for Fe(II), 4 for Fe(III))

# ligand specification
export LIGAND=("C(C(=O)[O-])") # Give the ligand name
export BINDING_SITES=("3,4")    # Give the binding sites for the ligand
export LIGAND_CHARGE=("-1")     # Give the charge of the ligand
export NUM_LIGAND=("1")         # Give the number of ligands in the complex

# complex specification
export COMPLEX_SPIN="1" # Give the spin of the complex

# Calculation #################################################################
# DFT specification
export FUNCTIONAL="B3LYP"                       # Give the DFT functional
export BASIS_SET="def2-TZVPP D3BJ CPCM(water)"  # Give the basis set
