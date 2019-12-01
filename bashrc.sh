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
# 2018 12 11

export ROBO_PATH_SCRIPT="$(cd "$(dirname "${BASH_SOURCE}")" && pwd )/"
parent_path="$(basename "$(dirname "$ROBO_PATH_SCRIPT")")"
if [ "$parent_path" == "master" ]; then
    export ROBO_PATH_WORKSPACE="$( \
      cd "${ROBO_PATH_SCRIPT}../../../" && pwd )/"
else
    if [ "$parent_path" != "bash" ]; then
        echo "roboag scripts: unknown file structure!"
    fi
    export ROBO_PATH_WORKSPACE="$( \
      cd "${ROBO_PATH_SCRIPT}../../" && pwd )/"
fi


#***************************[help]********************************************
# 2019 11 20

. ${ROBO_PATH_SCRIPT}scripts/help.sh
. ${ROBO_PATH_SCRIPT}scripts/help/bashrc.sh


#***************************[repository]**************************************
# 2018 11 30

. ${ROBO_PATH_SCRIPT}scripts/config.sh
. ${ROBO_PATH_SCRIPT}scripts/repository.sh

if [ -d "${REPO_BASH_REPO[0]}" ]; then
    export REPO_PATH_WORKSPACE="${ROBO_PATH_WORKSPACE}"
    . ${REPO_BASH_REPO[0]}bashrc.sh
fi


#***************************[install]*****************************************
# 2019 11 20

. ${ROBO_PATH_SCRIPT}scripts/install.sh
. ${ROBO_PATH_SCRIPT}scripts/install_server.sh


#***************************[other master scripts]***************************
# 2019 12 01

if [ -d "${REPO_BASH_MASTER_SERVER[0]}" ]; then
    . ${REPO_BASH_MASTER_SERVER[0]}bashrc.sh
fi

if [ -d "${REPO_BASH_MASTER_BASHONLY[0]}" ]; then
    . ${REPO_BASH_MASTER_BASHONLY[0]}bashrc.sh
fi


#***************************[robolib]*****************************************
# 2018 01 11

if [ "${REPO_ROBO_LIB[0]}" != "" ] && \
  [ -d "${REPO_ROBO_LIB[0]}" ]; then
    . ${REPO_ROBO_LIB[0]}scripts/bashrc.sh
fi
