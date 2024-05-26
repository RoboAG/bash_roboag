#!/bin/bash

echo ""
echo "setup_bashrc.sh script was called."
echo "The following project will be sourced within your bashrc."
if [ "$SOURCED_BASH_MASTER_ROBOAG" == "" ]; then
    echo "    roboag bash scripts"
else
    echo "    roboag bash scripts for USERS"
fi
echo "Do you wish to continue ? (No/yes)"
if [ "$1" != "-y" ] && [ "$1" != "--yes" ]; then
    read answer
else
    echo "<auto answer \"yes\">"
    answer="yes"
fi
if [ "$answer" != "y" ] && [ "$answer" != "Y" ] && \
  [ "$answer" != "yes" ]; then

    echo "Your ~./bashrc was NOT changed."
else

    # get local directory
    SCRIPTDIR="$(realpath "$(dirname "${BASH_SOURCE}")" )/"

    BASHRC_SOURCE="source ${SCRIPTDIR}bashrc.sh"
    if grep -Fq "${BASHRC_SOURCE}" ~/.bashrc; then

        echo "roboag already sourced within bashrc. This is good!"
    else

        echo "Adding roboag to your bashrc."

        echo ""                                        >> ~/.bashrc
        echo "# $(date +"%Y %m %d") sourcing roboag:"  >> ~/.bashrc
        if [ "$ROBO_CONFIG_IS_USER" == "1" ]; then
            echo "export ROBO_CONFIG_IS_USER=1"        >> ~/.bashrc
        fi
        echo "$BASHRC_SOURCE"                          >> ~/.bashrc
        if [ "$ROBO_CONFIG_IS_USER" == "1" ]; then
            echo "robo_help_user"                      >> ~/.bashrc
        else
            echo "robo_help_daily"                     >> ~/.bashrc
        fi
    fi

    # source scripts now, if not sourced before
    if [ "$SOURCED_BASH_MASTER_ROBOAG" == "" ]; then
        echo "Sourcing roboag scripts now."
        source "${SCRIPTDIR}bashrc.sh"
    fi
fi
