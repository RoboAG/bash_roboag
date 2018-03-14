#!/bin/sh

###############################################################################
#                                                                             #
# checkout.sh                                                                 #
# ===========                                                                 #
#                                                                             #
# Version: 1.0.0                                                              #
# Date   : 13.03.18                                                           #
# Author : Peter Weissig                                                      #
#                                                                             #
# For help or bug report please visit:                                        #
#   https://github.com/RoboAG/bash_roboag/                                    #
###############################################################################

PATH_THIS="bash/roboag"
PATH_ADD="bash/repo"

###############################################################################
NAME_GIT_THIS="bash_roboag"
NAME_GIT_ADD="bash_repo"

URL_GIT_THIS="https://github.com/RoboAG/${NAME_GIT_THIS}.git"
URL_GIT_ADD="https://github.com/peterweissig/${NAME_GIT_ADD}.git"

NAME_CHECKOUT_SCRIPT="checkout.sh"

###############################################################################
echo "The projects"
echo "  \"${PATH_THIS}\" and \"${PATH_ADD}\""
echo "will be checked out completely."
echo ""


# export paths
export ROBO_PATH_WORKSPACE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd )/"
export ROBO_PATH_SCRIPTS="${ROBO_PATH_WORKSPACE}${BASH_ROBOAG_PATH}"

export ROBO_HOME="$(cd && pwd )/"


# check paths
if [ "${ROBO_PATH_WORKSPACE}" != "${ROBO_PATH_HOME}workspace/" ]; then
    echo ""
    echo "This script must be placed at the top-level of the working"
    echo "directory - not in \"bash/\" or \"bash/roboag/\"!"
    echo ""

    echo "Do you want to continue ? (yes/No)"
    read answer
    if [ ! "$answer" == "yes" ]; then
        echo "  Stopped"
        return -1
        exit   -1
    fi
fi


echo ""
echo "### checking out the project"
if [ -d "${PATH_THIS}" ]; then
    echo "This project already exists!"
    return
fi
git clone "${URL_GIT_THIS}" "${PATH_THIS}"


echo ""
echo "### automatically sourcing this project"
./${PATH_THIS}setup_bashrc.sh


echo ""
echo "### checking out the additional repository"
if [ -d "${PATH_ADD}" ]; then
    echo "This project already exists!"
    return
fi
git clone "${URL_GIT_ADD}" "${PATH_ADD}"


if [ $? -ne 0 ]; then
    echo "### There have been errors! ###"
    return -1;
else
    echo ""
    echo "### deleting this script"
    rm "${NAME_CHECKOUT_SCRIPT}"

    echo "all done :-)"
fi
