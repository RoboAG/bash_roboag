#!/bin/sh

###############################################################################
#                                                                             #
# checkout.sh                                                                 #
# ===========                                                                 #
#                                                                             #
# Version: 1.1.1                                                              #
# Date   : 21.04.20                                                           #
# Author : Peter Weissig                                                      #
#                                                                             #
# For help or bug report please visit:                                        #
#   https://github.com/RoboAG/bash_roboag/                                    #
###############################################################################

NAME_THIS="roboag"
NAME_ADD="repo"

###############################################################################
PATH_THIS="bash/master/${NAME_THIS}/"
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
export ROBO_PATH_WORKSPACE="$(realpath "$(dirname "${BASH_SOURCE}")" )/"
export ROBO_PATH_HOME="$(cd && realpath . )/"


# check paths
if [ "${ROBO_PATH_WORKSPACE}" != "${ROBO_PATH_HOME}workspace/" ]; then
    echo ""
    echo "This script must be placed at the top-level of the working "
    echo -n "directory - usually \"~/workspace/\" - not in "
    echo "\"bash/\" or \"bash/master/roboag/\"!"
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

# check if git is installed
git_status="$(dpkg-query --show --showformat='${db:Status-Abbrev}' git)"
if [ "${git_status}" != "ii " ]; then
    echo ""
    echo "### git does not seem to be installed"
    echo "please call: $ apt get install git"
    return -1
    exit   -1
fi


# checking out this repo
echo ""
echo "### checking out the project"
if [ -d "${PATH_THIS}" ]; then
    echo "This project already exists!"
    return
    exit
fi
git clone "${URL_GIT_THIS}" "${PATH_THIS}"

if [ $? -ne 0 ]; then
    echo "### There have been errors! ###"
    return -1
    exit   -1
fi


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
fi

echo ""
echo "### deleting this script"
rm "${NAME_CHECKOUT_SCRIPT}"

echo "all done :-)"
