# bash_roboag
Scripts for setup, configuration und daily tasks within RoboAG.

## Setup for linux (Ubuntu)
create workspace directory

    mkdir -p ~/workspace
    cd ~/workspace


download scripts

    wget -nv https://raw.githubusercontent.com/RoboAG/bash_roboag/master/checkout.sh
    source checkout.sh


checkout additionals repositories (e.g. robolib)

    # reopen terminal before continuing
    repo_clone_bash
    repo_clone_roboag
    ...
    repo_help_overview #list of all referenced repositories

see also [help_config_workspace.sh](scripts/help/help_config_workspace.sh).

[![Build Status](https://travis-ci.org/RoboAG/bash_roboag.svg?branch=master)](https://travis-ci.org/RoboAG/bash_roboag)

## Installation
For install instructions see [doc_install repo](https://github.com/RoboAG/doc_install) (german).
