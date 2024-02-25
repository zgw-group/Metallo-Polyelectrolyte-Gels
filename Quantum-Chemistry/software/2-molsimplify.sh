#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#
# Author     : Pierre Walker (GitHub: @pw0908)
# Date       : 2024-02-23
# Description: Script to install MolSimplify from GitHub

# Install molsimplify
if [ -d "molSimplify" ]; then
    echo "molSimplify already installed"
else
    git clone https://github.com/hjkgrp/molSimplify.git
    cd molSimplify
    pip install -e .[dev]
    cd ..
fi