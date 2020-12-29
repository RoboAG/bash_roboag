# bash_roboag
Scripts for setup, configuration und daily tasks within RoboAG.

All scripts are supposed to run on Linux (Ubuntu).

[![Build Status](https://travis-ci.org/RoboAG/bash_roboag.svg?branch=master)](https://travis-ci.org/RoboAG/bash_roboag)

## setup workspace
There are two different modes of usage: Either simple mode for a
single-user-system or sharing repos with all users.

When setting up the scripts for **all users** they will be automatically
placed in ''/opt/roboag/repos/''. This is the default behaviour for our
clients and servers.

In **single** mode the workspace directory can be freely choosen.
Nevertheless, ''~/workspace/'' is recommended. This is recommended for
testing and single-user-systems.


For more infos see [help_setup_workspace.sh](scripts/help/help_setup_workspace.sh)
or just execute:

    robo_help_setup_workspace

### shared repos
download scripts

    wget -nv https://raw.githubusercontent.com/RoboAG/bash_roboag/master/checkout_all_users.sh
    source checkout_all_users.sh
    rm checkout_all_users.sh

### simple
create workspace directory (e.g.)

    mkdir -p ~/workspace
    cd ~/workspace


download scripts

    wget -nv https://raw.githubusercontent.com/RoboAG/bash_roboag/master/checkout.sh
    source checkout.sh

### additional repositories
checkout additionals repositories (e.g. robolib)

    # reopen terminal before continuing
    repo_clone_bash
    repo_clone_roboag
    ...
    repo_help_overview #list of all referenced repositories


## Installation
For install instructions see [doc_install repo](https://github.com/RoboAG/doc_install) (german).
