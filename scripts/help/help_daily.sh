#!/bin/bash

#***************************[help]********************************************
# 2023 09 23

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
        echo "  $ sudo systemctl restart dnsmasq         # dns & dhcp"
        echo "  $ sudo systemctl restart smbd            # samba shares"
        echo "  $ sudo systemctl restart squid-deb-proxy # apt proxy"
        echo ""
    fi

    echo "help"
    echo "  $ robo_help                    # overview"
    echo "  $ robo_help_daily              # this script"
    echo "  $ robo_help_install            # install"
    echo "  $ robo_help_setup_workspace    # copy scripts"
    echo "  $ robo_help_setup              # setup"
    echo ""

    echo "system"
    echo "  $ robo_system_wtf              # check  system"
    echo "  $ robo_repo_update             # update repos"
    if [ "$ROBO_CONFIG_IS_CLIENT" == "1" ]; then
        echo "  $ robo_repo_clone_from_server  # clone repos"
    fi
    echo "  $ robo_system_update           # update system"
    echo ""

    if [ "$ROBO_CONFIG_IS_SERVER" == "1" ]; then
        echo "clients"
        echo "  $ robo_config_server_dhcp_show # list clients"
        echo ""
        echo "  $ robo_server_ssh_getconfigs   # store  their config files"
        echo "  $ robo_server_check_clients    # check client logs"
        echo ""
        echo "  $ robo_server_ssh              # ssh into each client"
        echo "  $ robo_server_ssh_update       # update their system & repos"
        echo "  $ robo_server_ssh_check        # check  their system"
        echo ""
        echo "server"
        echo "  $ robo_config_server_internet_on  # internet ON"
        echo "  $ robo_config_server_internet_off # internet OFF"
        echo ""
        echo "  $ robo_server_userdata_show       # list all users"
        echo "  $ robo_server_userdata_add        # add a new user"
        echo "  $ robo_server_userdata_backup     # backup current data"
        echo "  $ robo_server_userdata_fix        # create \"neu/\" folders"
        echo ""
    fi
}
