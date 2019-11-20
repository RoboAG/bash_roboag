#!/bin/bash

#***************************[help]********************************************
# 2019 09 26

function robo_help_setup() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME [<system>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 0-1 parameters"
        echo "    [#1:]system for which install instructions will be shown"
        echo "         Leave option empty to run for \"client\"."
        echo "           \"client\"     Client of RoboAG"
        echo "           \"server\"     Server of RoboAG (and RoboSAX)"
        echo "           \"laptop\"     Peters Laptop (same as client)"
        echo "           \"togo\"       Peters ToGo-Server"
        echo "           \"peter\"      Peters Home-Server"

        return
    fi

    # check parameter
    if [ $# -gt 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # check first parameter (system-flag)
    system_flag="client"
    if [ $# -gt 0 ]; then
        #check for current versions
        if [ "$1" == "client" ]; then
            # nothing to do :-)
            dummy=1
        elif [ "$1" == "roboag" ]; then
            system_flag="roboag"
        elif [ "$1" == "laptop" ]; then
            system_flag="client"
        elif [ "$1" == "peter" ]; then
            system_flag="peter"
        elif [ "$1" == "togo" ]; then
            system_flag="togo"
        else
            echo "$FUNCNAME: Parameter Error."
            $FUNCNAME --help
            return -1
        fi
    fi

    echo ""
    echo "### Configure computer ###"
    echo ""
    echo "1. simple configurations"
    echo "    $ config_bash_search"
    echo "    $ config_clear_home"
    echo -e "\n<enter>\n"; read dummy

    echo ""
    echo "2. updated sources (this may take a while)"
    echo "    $ config_source_list_to_multiverse"
    echo "    $ config_update_system"
    echo "    $ sudo reboot"
    if [ "$system_flag" == "client" ]; then
        echo "    $ robo_system_install"
    else
        echo "    $ robo_system_install server"
    fi
    echo -e "\n<enter>\n"; read dummy

    echo "... ToDo ..."
    echo -e "\n<enter>\n"; read dummy

    echo "done :-)"
}
