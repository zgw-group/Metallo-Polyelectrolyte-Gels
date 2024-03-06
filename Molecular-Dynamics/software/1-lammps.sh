#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#
# Author     : Pierre Walker (GitHub: @pw0908)
# Date       : 2024-02-23
# Description: Script to install LAMMPS

# Specify LAMMPS version
LAMMPS_VERSION="2Aug2023"

# Specify CUDA architecture
GPU="on"
CUDA_ARCH="sm_86" # For CUDA 11.1 and higher, sm_80 for lower versions

# Download LAMMPS
if test -d lammps; then # Check if LAMMPS is already downloaded
    echo "INFO: LAMMPS already downloaded"
elif test -f lammps-$LAMMPS_VERSION.tar.gz; then # Check if LAMMPS tarball is already downloaded
    tar -xvf lammps-$LAMMPS_VERSION.tar.gz
    mv lammps-$LAMMPS_VERSION lammps
    rm lammps-$LAMMPS_VERSION.tar.gz
else
    echo "INFO: Downloading latest version of LAMMPS..."
    wget https://download.lammps.org/tars/lammps-$LAMMPS_VERSION.tar.gz
    tar -xvf lammps-$LAMMPS_VERSION.tar.gz
    mv lammps-$LAMMPS_VERSION lammps
    rm lammps-$LAMMPS_VERSION.tar.gz
fi

# Enter LAMMPS directory
cd lammps

# Build LAMMPS
mkdir -p build
cd build

# Adding modules
cmake ../cmake -D PKG_MOLECULE=yes -D PKG_KSPACE=yes -D PKG_MANYBODY=yes -D PKG_OPENMP=yes                

# Add GPU support if requested
if [ "$GPU" = "on" ]; then
    cmake ../cmake -D PKG_GPU=yes -D GPU_API=cuda -D GPU_ARCH=$CUDA_ARCH      
fi 

# Compile LAMMPS
echo "INFO: Building LAMMPS..."
cmake --build .
cd ../..