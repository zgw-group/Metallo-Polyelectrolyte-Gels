#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#
# Author     : Pierre Walker (GitHub: @pw0908)
# Date       : 2024-02-23
# Description: Script to set global variables and preferences for the MD Simulation

# Hardware ####################################################################
export CPU_THREADS='1'                     # number of CPU threads to use (-1 = all available)
export CPU_PINS='1'                         # offset for CPU thread pinning (-1 = no offset)
export GPUS='1'                             # number of GPUs to use (-1 = all available)
export GPU_ID='0'                           # GPU ID to use (-1 = no GPU)

# System components ###########################################################
# tag for system
export TAG_JOBID="0.2.0" # tag to append to system name

# metal specification
export NMETAL="600"                         # Give the number of metal atoms
export METAL_DIAMETER="0.5"                 # Give the radius of the metal
export METAL_CHARGE="2"                     # Give the charge of the metal

# polymer specification
export NCHAIN="50"                          # Give the number of polymers
export SPARSITY="41"                        # Give the charge sparsity of the polymer
export NMONOMER="8"                         # Give the number of monomers in the polymer
export BEAD_DIAMETER="1"                    # Give the radius of the polymer

# co-ion specification
export COION_DIAMETER="1.5"                 # Give the radius of the co-ion

# Simulation #################################################################
# Initialisation
export DENSITY="0.05"                       # Give the initial density
export TEMPERATURE="1"                      # Give the temperature
export DIELECTRIC="0.15"                    # Give the dielectric constant

# Production - NVE
export TIME_STEP="0.005"                    # Give the time step
export NUM_STEPS="35000000"                 # Give the number of steps

# Production - Deformation
export DEFORMATION="0.652e-2"               # Give the deformation rate
export DEFORMATION_STEPS="300000"           # Give the number of steps
