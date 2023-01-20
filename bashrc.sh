#!/bin/bash

#***************************[check if already sourced]************************
# 2019 12 01

if [ "$SOURCED_BASH_MASTER_ROBOAG" != "" ]; then

    return
    exit
fi

if [ "$SOURCED_BASH_LAST" == "" ]; then
    export SOURCED_BASH_LAST=1
else
    export SOURCED_BASH_LAST="$(expr "$SOURCED_BASH_LAST" + 1)"
fi

export SOURCED_BASH_MASTER_ROBOAG="$SOURCED_BASH_LAST"



#***************************[paths and files]*********************************
# 2020 12 27

export ROBO_PATH_SCRIPT="$(realpath "$(dirname "${BASH_SOURCE}")" )/"
parent_path="$(basename "$(dirname "$ROBO_PATH_SCRIPT")")"
if [ "$parent_path" == "master" ]; then
    export ROBO_PATH_WORKSPACE="$( \
      realpath "${ROBO_PATH_SCRIPT}../../.." )/"
else
    if [ "$parent_path" != "bash" ]; then
        echo "roboag scripts: unknown file structure!"
    fi
    export ROBO_PATH_WORKSPACE="$( \
      realpath "${ROBO_PATH_SCRIPT}../.." )/"
fi



#***************************[repository]**************************************
# 2021 07 25

if [ "$ROBO_CONFIG_IS_USER" == "1" ]; then
    tmp="${HOME}/Downloads/"
    if [ ! -d "${tmp}" ]; then
        tmp="${HOME}/"
    fi
    export REPO_PATH_CONFIG="${tmp}"
    export CONFIG_PATH_BACKUP="${tmp}"
    export NETWORK_PATH_LOG="${tmp}"
fi

source "${ROBO_PATH_SCRIPT}scripts/repository.sh"

if [ -d "${REPO_BASH_REPO[0]}" ]; then
    export REPO_PATH_WORKSPACE="${ROBO_PATH_WORKSPACE}"
    source "${REPO_BASH_REPO[0]}bashrc.sh"
fi



#***************************[internal scripts]********************************
# 2023 01 20

source "${ROBO_PATH_SCRIPT}scripts/config_user.sh"

if [ "$ROBO_CONFIG_IS_USER" != "1" ]; then
    # config.sh sets _robo_config_need_... and ROBO_CONFIG_IS_...
    source "${ROBO_PATH_SCRIPT}scripts/config.sh"
    source "${ROBO_PATH_SCRIPT}scripts/config_server.sh"

    source "${ROBO_PATH_SCRIPT}scripts/help.sh"
    source "${ROBO_PATH_SCRIPT}scripts/help/bashrc.sh"

    source "${ROBO_PATH_SCRIPT}scripts/server.sh"

    #source "${ROBO_PATH_SCRIPT}scripts/setup.sh"
    source "${ROBO_PATH_SCRIPT}scripts/setup_server.sh"

    # system.sh depends on most aliases
    source "${ROBO_PATH_SCRIPT}scripts/system.sh"

else
    source "${ROBO_PATH_SCRIPT}scripts/help/help_user.sh"
fi



#***************************[other master scripts]****************************
# 2021 07 25

if [ -d "${REPO_BASH_MASTER_SERVER[0]}" ] && \
  [ "$ROBO_CONFIG_IS_USER" != "1" ]; then

    source "${REPO_BASH_MASTER_SERVER[0]}bashrc.sh"
fi

if [ -d "${REPO_BASH_MASTER_BASHONLY[0]}" ]; then
    source "${REPO_BASH_MASTER_BASHONLY[0]}bashrc.sh"
fi



#***************************[robolib]*****************************************
# 2021 03 24

if [ "${REPO_ROBOAG_LIB[0]}" != "" ] && \
  [ -d "${REPO_ROBOAG_LIB[0]}" ]; then
    source "${REPO_ROBOAG_LIB[0]}scripts/bashrc.sh"
fi
