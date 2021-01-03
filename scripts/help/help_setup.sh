#!/bin/bash

#***************************[help]********************************************
# 2021 01 03

function robo_help_setup() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME [<system>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 0-1 parameters"
        echo "    [#1:]system for which setup instructions will be shown"
        echo "         Leave option empty to run for \"client\"."
        echo "           \"client\"     Client of RoboAG"
        echo "           \"server\"     Server of RoboAG (and RoboSAX)"

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
        elif [ "$1" == "server" ]; then
            system_flag="server"
        else
            echo "$FUNCNAME: Parameter Error."
            $FUNCNAME --help
            return -1
        fi
    fi

    echo ""
    if [ "$system_flag" != "server" ]; then
        echo "### Setup CLIENT ###"
    else
        echo "### Setup SERVER ###"
    fi
    echo ""
    echo "simple configurations"
    echo "    $ config_bash_search"
    if [ "$system_flag" == "server" ]; then
        echo "    $ config_bash_histsize"
    fi
    echo "    $ config_clear_home"
    echo -e "\n<enter>\n"; read dummy

    echo ""
    echo "update sources (this may take a while)"
    echo "    $ config_source_list_add_multiverse"
    if [ "$system_flag" != "server" ]; then
        echo "    $ robo_config_aptcacher   (if not in standalone-mode)"
    fi
    echo -e "\n<enter>\n"; read dummy

    echo ""
    echo "install packages (this may take a while)"
    echo "    $ robo_system_update"
    echo "    $ sudo reboot"
    if [ "$system_flag" == "client" ]; then
        echo "    $ robo_system_install"
    else
        echo "    $ robo_system_install server"
    fi
    echo -e "\n<enter>\n"; read dummy

    if [ "$system_flag" == "server" ]; then
        echo ""
        echo "setup network"
        echo "    $ robo_setup_server_interfaces"
        echo "    $ sudo reboot"
        echo -e "\n<enter>\n"; read dummy
        echo ""
        echo "setup apt-cacher-ng"
        echo "    $ robo_setup_server_aptcacher"
        echo "    $ robo_config_aptcacher"
        echo "    $ robo_system_update"
        echo -e "\n<enter>\n"; read dummy
        echo ""
        echo "install client packages (this may take a while)"
        echo "    $ robo_system_install"
        echo -e "\n<enter>\n"; read dummy
        echo ""
        echo "setup dnsmasq (dhcp+dns)"
        echo "    $ robo_setup_server_dnsmasq"
        echo -e "\n<enter>\n"; read dummy
    fi

    echo ""
    echo "... ToDo ..."
    echo -e "\n<enter>\n"; read dummy

    echo ""
    echo "check system"
    echo "    $ robo_system_wtf"
    echo -e "\n<enter>\n"; read dummy

    echo "done :-)"
}
