#!/bin/sh

###############################################################################
#                                                                             #
# checkout.sh                                                                 #
# ===========                                                                 #
#                                                                             #
# Version: 1.0.4                                                              #
# Date   : 17.11.18                                                           #
# Author : Peter Weissig                                                      #
#                                                                             #
# For help or bug report please visit:                                        #
#   https://github.com/RoboAG/bash_roboag/                                    #
###############################################################################

NAME_THIS="roboag"
NAME_ADD="repo"

###############################################################################
PATH_THIS="bash/${NAME_THIS}/"
PATH_ADD="bash/${NAME_ADD}/"
NAME_GIT_THIS="bash_${NAME_THIS}"
NAME_GIT_ADD="bash_${NAME_ADD}"

URL_GIT_THIS="https://github.com/RoboAG/${NAME_GIT_THIS}.git"
URL_GIT_ADD="https://github.com/peterweissig/${NAME_GIT_ADD}.git"

NAME_CHECKOUT_SCRIPT="checkout.sh"

###############################################################################
echo "The projects"
echo "  \"${NAME_THIS}\" and \"${NAME_ADD}\""
echo "will be checked out completely."
echo ""


# export paths
export ROBO_PATH_WORKSPACE="$(cd "$(dirname "${BASH_SOURCE}")" && pwd )/"
export ROBO_PATH_SCRIPTS="${ROBO_PATH_WORKSPACE}${BASH_ROBOAG_PATH}"

export ROBO_PATH_HOME="$(cd && pwd )/"


# check paths
if [ "${ROBO_PATH_WORKSPACE}" != "${ROBO_PATH_HOME}workspace/" ]; then
    echo ""
    echo "This script must be placed at the top-level of the working"
    echo -n "directory - usually \"~/workspace/\" - not in "
    echo "\"bash/\" or \"bash/roboag/\"!"
    echo ""

    echo "Do you wish to continue ? (No/yes)"
    if [ "$1" != "-y" ] && [ "$1" != "--yes" ]; then
        read answer
    else
        echo "<auto answer \"yes\">"
        answer="yes"
    fi
    if [ "$answer" != "y" ] && [ "$answer" != "Y" ] && \
      [ "$answer" != "yes" ]; then

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
    exit
fi
git clone "${URL_GIT_THIS}" "${PATH_THIS}"


echo ""
echo "### automatically sourcing this project"
./${PATH_THIS}setup_bashrc.sh $1


echo ""
echo "### checking out the additional repository"
if [ -d "${PATH_ADD}" ]; then
    echo "This project already exists!"
    return
    exit
fi
git clone "${URL_GIT_ADD}" "${PATH_ADD}"


if [ $? -ne 0 ]; then
    echo "### There have been errors! ###"
    return -1
    exit   -1
else
    echo ""
    echo "### deleting this script"
    rm "${NAME_CHECKOUT_SCRIPT}"

    echo "all done :-)"
fi
