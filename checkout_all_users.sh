#!/bin/sh

###############################################################################
#                                                                             #
# checkout.sh                                                                 #
# ===========                                                                 #
#                                                                             #
# Version: 1.1.4                                                              #
# Date   : 30.12.20                                                           #
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

ROBO_PATH_WORKSPACE="/opt/roboag/repos/"
PATH_THIS="${ROBO_PATH_WORKSPACE}${PATH_THIS}"
PATH_ADD="${ROBO_PATH_WORKSPACE}${PATH_ADD}"

###############################################################################
echo "The projects"
echo "  \"${NAME_THIS}\" and \"${NAME_ADD}\""
echo "will be checked out completely."
echo ""
echo "The repositories will be available for all users!"
echo "  (workspace will be \"$ROBO_PATH_WORKSPACE\")"
echo ""

# ask user for confirmation
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

# check if git is installed
git_status="$(dpkg-query --show --showformat='${db:Status-Abbrev}' git)"
if [ "${git_status}" != "ii " ]; then
    echo ""
    echo "### git does not seem to be installed"
    echo "please run: $ apt install git"
    return -1
    exit   -1
fi

# create path
echo "mkdir -p \"$ROBO_PATH_WORKSPACE\""
sudo mkdir -p "$ROBO_PATH_WORKSPACE" && \
  sudo chown $USER "$ROBO_PATH_WORKSPACE"
chmod 755 "$ROBO_PATH_WORKSPACE"

# checking out this repo
echo ""
echo "### checking out the project"
if [ -d "${PATH_THIS}" ]; then
    echo "This project already exists!"
    return
    exit
fi
git clone "${URL_GIT_THIS}" "${PATH_THIS}"

echo ""
echo "### checking out the additional repository"
if [ -d "${PATH_ADD}" ]; then
    echo "This project already exists!"
    return
    exit
fi
git clone "${URL_GIT_ADD}" "${PATH_ADD}"


echo ""
echo "### automatically sourcing this project"
echo "If you want to automatically source this project, call"
echo "  \$ ${PATH_THIS}setup_bashrc.sh"


echo ""
echo "all done :-)"
