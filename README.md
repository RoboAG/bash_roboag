# bash_roboag
Scripts for setup, configuration und daily tasks within RoboAG.

## Setup for linux (Ubuntu)
create workspace directory

    mkdir -p ~/workspace
    cd ~/workspace


download scripts

    wget -nv https://raw.githubusercontent.com/RoboAG/bash_roboag/master/checkout.sh
    bash ./checkout.sh


checkout additionals repositories (e.g. robolib)

    git_clone_robo_lib
    git_clone_robo_pololu
    ...
    repo_help #list of all referenced repositories

see also [help_config_workspace.sh](scripts/help_config_workspace.sh).

## Installation
For install instructions see [doc/install](doc/install.md).
