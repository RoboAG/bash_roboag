#!/bin/bash

# get local directory
SCRIPTDIR="$(realpath "$(dirname "${BASH_SOURCE}")" )/"

# enable usage for USER (not client, server nor standalone)
export ROBO_CONFIG_IS_USER=1

# source setup_bashrc.sh
source ${SCRIPTDIR}setup_bashrc.sh
