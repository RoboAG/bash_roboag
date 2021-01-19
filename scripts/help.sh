#!/bin/bash

#***************************[dependencies]************************************
# 2021 01 19

# the following must be sourced BEFORE this script
#     repo.sh
#     config.sh
#
# the following must be sourced AFTER this script



#***************************[all]*********************************************
# 2021 01 19

function robo_help_all() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 0 parameters"
        echo -n "Prints all available functions within master repository "
        echo "\"robo\"."

        return
    fi

    # check parameter
    if [ $# -gt 0 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # print overview of all repositories
    echo ""
    echo "### $FUNCNAME ###"
    echo ""
    echo "help"
    echo -n "  "; echo "robo_help  #no help"
    echo -n "  "; $FUNCNAME -h
    echo ""
    echo -n "  "; robo_help_install -h
    echo -n "  "; robo_help_setup_workspace -h
    echo -n "  "; robo_help_setup -h
    echo -n "  "; echo "robo_help_daily             #no help"
    echo ""
    if [ "$SOURCED_BASH_REPO" != "" ]; then
        echo -n "  "; echo "repo_help                   #no help"
    fi
    if [ "$SOURCED_BASH_MASTER_SERVER" != "" ]; then
        echo -n "  "; echo "server_help                 #no help"
    fi
    if [ "$SOURCED_BASH_CONFIG" != "" ]; then
        echo -n "  "; echo "config_help                 #no help"
    fi
    if [ "$SOURCED_BASH_FILE" != "" ]; then
        echo -n "  "; echo "file_help                   #no help"
    fi
    if [ "$SOURCED_BASH_MULTIMEDIA" != "" ]; then
        echo -n "  "; echo "multimedia_help             #no help"
    fi
    if [ "$SOURCED_BASH_NETWORK" != "" ]; then
        echo -n "  "; echo "network_help                #no help"
    fi
    echo ""
    echo "repository functions"
    echo -n "  "; echo "robo_repo_overview          #no help"
    echo -n "  "; echo "robo_repo_status            #no help"
    echo -n "  "; echo "robo_repo_update            #no help"
    echo ""
    echo "install functions"
    echo -n "  "; echo "robo_system_update          #no help"
    echo -n "  "; robo_system_install -h
    echo -n "  "; robo_system_wtf -h
    echo ""
    echo "server functions"
    echo -n "  "; robo_config_server_internet_on -h
    echo -n "  "; robo_config_server_internet_off -h
    echo -n "  "; robo_server_ssh -h
    echo -n "  "; echo "robo_server_ssh_check       #no help"
    echo -n "  "; echo "robo_server_ssh_update      #no help"
    echo -n "  "; robo_config_server_dhcp_list -h
    echo -n "  "; robo_config_server_dhcp_add -h
    echo -n "  "; robo_config_server_dhcp_edit -h
    echo ""
}



#***************************[help]********************************************
# 2021 01 19

function robo_help() {

    echo ""
    echo "### $FUNCNAME ###"
    echo ""
    echo "help functions"
    echo -n "  "; echo "$FUNCNAME                   #no help"
    echo -n "  "; robo_help_all -h
    echo -n "  "; robo_help_install -h
    echo -n "  "; robo_help_setup_workspace -h
    echo -n "  "; robo_help_setup -h
    echo -n "  "; echo "robo_help_daily             #no help"
    echo ""
    echo "repository functions"
    echo -n "  "; echo "robo_repo_overview          #no help"
    echo -n "  "; echo "robo_repo_status            #no help"
    echo -n "  "; echo "robo_repo_update            #no help"
    echo ""
    echo "install functions"
    echo -n "  "; echo "robo_system_update          #no help"
    echo -n "  "; robo_system_install -h
    echo -n "  "; robo_system_wtf -h
    echo ""

    if [ "$ROBO_CONFIG_IS_SERVER" == "1" ]; then
        echo "server functions"
        echo -n "  "; robo_config_server_internet_on -h
        echo -n "  "; robo_config_server_internet_off -h
        echo -n "  "; robo_server_ssh -h
        echo -n "  "; echo "robo_server_ssh_check       #no help"
        echo -n "  "; echo "robo_server_ssh_update      #no help"
        echo -n "  "; robo_config_server_dhcp_list -h
        echo -n "  "; robo_config_server_dhcp_add -h
        echo -n "  "; robo_config_server_dhcp_edit -h
        echo ""
    fi
}
