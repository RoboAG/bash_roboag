#!/bin/bash

#***************************[help]********************************************
# 2021 01 03

function robo_help_daily() {

    if [ "$ROBO_CONFIG_IS_SERVER" == "1" ]; then
        echo "### SERVER ###"
    elif [ "$ROBO_CONFIG_IS_CLIENT" == "1" ]; then
        echo "### CLIENT ###"
    elif [ "$ROBO_CONFIG_STANDALONE" == "1" ]; then
        echo "### STANDALONE ###"
    else
        echo "### who are you ? ###"
    fi
    echo ""

    echo "help"
    echo "  $ robo_help           # overview"
    echo "  $ robo_help_daily     # this script"
    echo "  $ robo_help_install   # install"
    echo "  $ robo_help_setup     # setup"
    echo ""

    echo "system"
    echo "  $ robo_system_wtf     # check  system"
    echo "  $ robo_repo_update    # update repos"
    echo "  $ robo_system_update  # update system"
    echo ""

    if [ "$ROBO_CONFIG_IS_SERVER" == "1" ]; then
        echo "server"
        echo "  $ robo_config_server_internet_on  # internet ON"
        echo "  $ robo_config_server_internet_off # internet OFF"
        echo ""
    fi
}
