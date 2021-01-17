#!/bin/bash

#***************************[help]********************************************
# 2021 01 16

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

    if [ "$ROBO_CONFIG_IS_SERVER" == "1" ]; then
        echo "server deamons"
        echo "  $ robo_system_wtf"
        echo "  $ service --status-all"
        echo ""
        echo "  $ sudo systemctl restart dnsmasq       # dns & dhcp"
        echo "  $ sudo systemctl restart apt-cacher-ng # apt-cacher"
        echo "  $ sudo systemctl restart smbd          # samba shares"
        echo ""
    fi

    echo "help"
    echo "  $ robo_help           # overview"
    echo "  $ robo_help_daily     # this script"
    echo "  $ robo_help_install   # install"
    echo "  $ robo_help_setup     # setup"
    echo ""

    echo "system"
    echo "  $ robo_system_wtf     # check  system"
    echo "  $ robo_repo_update    # update repos"
    if [ "$ROBO_CONFIG_IS_CLIENT" == "1" ]; then
        echo "  $ robo_repo_clone_from_server # clone repos"
    fi
    echo "  $ robo_system_update  # update system"
    if [ "$ROBO_CONFIG_IS_SERVER" == "1" ]; then
        echo "  $ robo_system_ssh     # ssh into each client"
    fi
    echo ""

    if [ "$ROBO_CONFIG_IS_SERVER" == "1" ]; then
        echo "server"
        echo "  $ robo_config_server_internet_on  # internet ON"
        echo "  $ robo_config_server_internet_off # internet OFF"
        echo ""
    fi
}
