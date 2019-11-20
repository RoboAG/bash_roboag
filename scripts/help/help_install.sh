#!/bin/bash

#***************************[help]********************************************
# 2019 11 20

function robo_help_install() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME [<system>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 0-1 parameters"
        echo "    [#1:]system for which install instructions will be shown"
        echo "         Leave option empty to run for \"pc\"."
        echo "           \"pc\"         common computers (client)"
        echo "           \"raspi\"      raspberry pi     (client)"
        echo "           \"server\"     server"

        return
    fi

    # check parameter
    if [ $# -gt 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # check first parameter (system-flag)
    system_flag="pc"
    if [ $# -gt 0 ]; then
        if [ "$1" == "pc" ]; then
            # nothing to do :-)
            dummy=1
        elif [ "$1" == "raspi" ]; then
            system_flag="raspi"
        elif [ "$1" == "server" ]; then
            robo_help_install_server
            return $?
        else
            echo "$FUNCNAME: Parameter Error."
            $FUNCNAME --help
            return -1
        fi
    fi

    echo ""
    echo "### Install Client ###"
    echo ""
    echo "Operating System: Xubuntu 18.04.3 LTS"
    echo ""

    echo "0. Source"
    echo "  Internet:"
    echo "    http://cdimage.ubuntu.com/xubuntu/releases/18.04/release/"
    echo -e "\n<enter>\n"; read dummy

    #ToDo

}

