#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#
# Author     : Pierre Walker (GitHub: @pw0908)
# Date       : 2024-02-23
# Description: Script to install OpenMPI

# Specify OpenMPI version
OPENMPI_VERSION="4.1.5"

# Download OpenMPI
if test -d openmpi; then # Check if OpenMPI is already downloaded
    echo "INFO: OpenMPI already downloaded"
elif test -f openmpi-$OPENMPI_VERSION.tar.gz; then # Check if OpenMPI tarball is already downloaded
    tar -xvf openmpi-$OPENMPI_VERSION.tar.gz
    mv openmpi-$OPENMPI_VERSION openmpi
    rm openmpi-$OPENMPI_VERSION.tar.gz
else
    echo "INFO: Downloading version of OpenMPI..."
    wget "https://download.open-mpi.org/release/open-mpi/v${OPENMPI_VERSION::-2}/openmpi-${OPENMPI_VERSION}.tar.gz"
    tar -xvf openmpi-$OPENMPI_VERSION.tar.gz
    mv openmpi-$OPENMPI_VERSION openmpi
    rm openmpi-$OPENMPI_VERSION.tar.gz
fi

# # Enter OpenMPI directory
cd openmpi

# Build OpenMPI
script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
./configure --prefix=${script_path}/../openmpi-$OPENMPI_VERSION
sudo make -j32 all install

cd ../..