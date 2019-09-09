# bash_roboag
Scripts for setup, configuration und daily tasks within RoboAG.

## Setup for linux (Ubuntu)
create workspace directory

    mkdir -p ~/workspace
    cd ~/workspace


download scripts

    wget -nv https://raw.githubusercontent.com/RoboAG/bash_roboag/master/checkout.sh
    . checkout.sh


checkout additionals repositories (e.g. robolib)

    repo_clone_bash
    git_clone_robo_lib
    git_clone_robo_pololu
    ...
    repo_help #list of all referenced repositories

see also [help_config_workspace.sh](scripts/help_config_workspace.sh).

[![Build Status](https://travis-ci.org/RoboAG/bash_roboag.svg?branch=master)](https://travis-ci.org/RoboAG/bash_roboag)

## Installation
For install instructions see [doc/install](doc/install.md).
