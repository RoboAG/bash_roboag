#!/bin/bash


#***************************[all]*********************************************
# 2019 09 26

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
    echo -n "  "; robo_help_install_server -h
    echo -n "  "; echo "robo_help_config_workspace  #no help"
    echo -n "  "; robo_help_setup -h
    echo ""
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
    if [ "$SOURCED_BASH_REPO" != "" ]; then
        echo -n "  "; echo "repo_help                   #no help"
    fi
    echo ""
    echo "repository functions"
    echo -n "  "; echo "robo_repo_status            #no help"
    echo -n "  "; echo "robo_repo_update            #no help"
    echo ""
    echo "install functions"
    echo -n "  "; echo "robo_system_update          #no help"
    echo -n "  "; robo_system_install -h
    echo ""
}

#***************************[help]********************************************
# 2019 11 20

function robo_help() {

    echo ""
    echo "### $FUNCNAME ###"
    echo ""
    echo "help functions"
    echo -n "  "; echo "$FUNCNAME                   #no help"
    echo -n "  "; robo_help_all -h
    echo -n "  "; robo_help_install_client -h
    echo -n "  "; robo_help_install_server -h
    echo -n "  "; echo "robo_help_config_workspace  #no help"
    echo -n "  "; robo_help_setup -h
    echo ""
    echo "repository functions"
    echo -n "  "; echo "robo_repo_status            #no help"
    echo -n "  "; echo "robo_repo_update            #no help"
    echo ""
    echo "install functions"
    echo -n "  "; echo "robo_system_update          #no help"
    echo -n "  "; robo_system_install -h
    echo ""
}
