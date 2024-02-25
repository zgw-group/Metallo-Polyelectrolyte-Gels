#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#
# Author     : Pierre Walker (GitHub: @pw0908)
# Date       : 2024-02-23
# Description: Script to install ORCA

# Unpack the ORCA tarball
if [ -d "orca" ]; then
    echo "ORCA already installed"
else
    tar -xvf orca_5_0_3_linux_x86-64_shared_openmpi411.tar.xz
    mv orca_5_0_3_linux_x86-64_shared_openmpi411 orca
fi