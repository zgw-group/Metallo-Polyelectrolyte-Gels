#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#
# Author     : Pierre Walker (GitHub: @pw0908)
# Date       : 2024-02-23
# Description: Script to install mdhelper

# Install mdhelper
# If mdhelper is already installed, then do nothing
if test -d mdhelper; then
    echo "INFO: mdhelper already installed"
else
    git clone https://github.com/bbye98/mdhelper.git
    cd mdhelper
    pip install -e .[dev]
    cd ..
fi