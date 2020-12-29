# bash_roboag
Scripts for setup, configuration und daily tasks within RoboAG.

All scripts are supposed to run on Linux (Ubuntu).

[![Build Status](https://travis-ci.org/RoboAG/bash_roboag.svg?branch=master)](https://travis-ci.org/RoboAG/bash_roboag)

## setup workspace
There are different modes of usage: Either standalone for one user or sharing
repos with all users.

In **standalone** mode the workspace directory can be freely choosen.
Nevertheless ''~/workspace/'' is recommended.

When setting up the scripts for **all users** they will be automatically
placed in ''/opt/roboag/repos/''.

### standalone
create workspace directory (e.g.)

    mkdir -p ~/workspace
    cd ~/workspace


download scripts

    wget -nv https://raw.githubusercontent.com/RoboAG/bash_roboag/master/checkout.sh
    source checkout.sh

### all users
download scripts

    wget -nv https://raw.githubusercontent.com/RoboAG/bash_roboag/master/checkout_all_users.sh
    source checkout_all_users.sh
    rm checkout_all_users.sh

### additional repositories
checkout additionals repositories (e.g. robolib)

    # reopen terminal before continuing
    repo_clone_bash
    repo_clone_roboag
    ...
    repo_help_overview #list of all referenced repositories

see also [help_setup_workspace.sh](scripts/help/help_setup_workspace.sh).


## Installation
install git client

    sudo apt install git


For install instructions see [doc_install repo](https://github.com/RoboAG/doc_install) (german).
