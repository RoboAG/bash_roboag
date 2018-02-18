#***************************[paths and files]*********************************
# 2018 01 11

export ROBO_PATH_SCRIPTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd )/"
export ROBO_PATH_WORKSPACE="$(cd "${ROBO_PATH_SCRIPTS}../../" && pwd )/"

#***************************[help]********************************************
# 2018 02 15

. ${ROBO_PATH_SCRIPTS}scripts/help_install_server.sh


#***************************[repository]**************************************
# 2018 01 30

. ${ROBO_PATH_SCRIPTS}scripts/repository.sh

if [ -d "${REPO_BASH_REPO[0]}" ]; then
    export REPO_PATH_WORKSPACE="${ROBO_PATH_WORKSPACE}"
    . ${REPO_BASH_REPO[0]}list.sh
    . ${REPO_BASH_REPO[0]}functions.sh
    . ${REPO_BASH_REPO[0]}alias.sh
    . ${REPO_BASH_REPO[0]}help.sh
fi


#***************************[network]*****************************************
# 2018 01 11
if [ "${REPO_BASH_NETWORK[0]}" != "" ] && \
  [ -d "${REPO_BASH_NETWORK[0]}" ]; then
    . ${REPO_BASH_NETWORK[0]}functions.sh
fi


#***************************[multimedia]**************************************
# 2018 01 11
if [ "${REPO_BASH_MULTIMEDIA[0]}" != "" ] && \
  [ -d "${REPO_BASH_MULTIMEDIA[0]}" ]; then
    . ${REPO_BASH_MULTIMEDIA[0]}functions.sh
fi


#***************************[robolib]*****************************************
# 2018 01 11
if [ "${REPO_ROBO_LIB[0]}" != "" ] && \
  [ -d "${REPO_ROBO_LIB[0]}" ]; then
    . ${REPO_ROBO_LIB[0]}scripts/bashrc.sh
fi

