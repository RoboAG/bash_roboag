#!/bin/bash

#***************************[update]******************************************
# 2019 09 10

alias robo_system_update="config_update_system"



#***************************[install]*****************************************
# 2021 01 01

function robo_system_install() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME [<system>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 0-1 parameters"
        echo "    [#1:]system for installed packages"
        echo "         \"\" regular packages (default)"
        echo "         \"server\" additional packages for server"
        echo "This function installs all packages needed."

        return
    fi

    # check parameter
    if [ $# -gt 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # init variables
    server_flag="0"

    if [ $# -gt 0 ]; then
        if [ "$1" == "server" ]; then
            server_flag="1"

            _robo_config_need_server "$FUNCNAME"
            if [ $? -ne 0 ]; then return; fi
        elif [ "$1" != "" ]; then
            echo "$FUNCNAME: Parameter Error."
            $FUNCNAME --help
            return -1
        fi
    fi

    # check ubuntu version
    VER=$(lsb_release -r | cut -f2 | cut -d. -f1)

    # select between server and client
    if [ "$server_flag" -eq 0 ]; then
        # basic install
        _config_install_list "
            openssh-server

            synaptic
            cifs-utils
            net-tools
            ntp

            regexxer pwgen

            subversion git meld

            vim kate bless
            exuberant-ctags konsole

            binutils gcc avr-libc avrdude
            g++ cmake

            librecad inkscape dia

            zim doxygen

            libreoffice libreoffice-help-de
            okular gwenview

            vlc
            " "" --yes
        if [ $? -ne 0 ]; then return -2; fi

        # ubuntu-version dependend packages
        if [ "$VER" -lt "20" ]; then
            _config_install_list "python"
        else
            _config_install_list "python3 python-is-python3"
        fi

        # check for eagle
        if apt show eagle 2>> /dev/null; then
            _config_install_list "eagle"
        else
            echo "eagle is not available"
        fi

        # install vs code
        config_install_vscode
        if [ $? -ne 0 ]; then return -3; fi
    else
        _config_install_list "
            exfat-fuse exfat-utils

            apt-cacher-ng

            samba samba-common

            apache2
            mariadb-server
            php php-mysql phpmyadmin
            " "" --yes
        if [ $? -ne 0 ]; then return -2; fi
    fi

    echo "done :-)"
}

#***************************[check]******************************************
# 2021 01 01

function robo_system_wtf() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 0 parameters"
        echo "This function checks several aspects of the configuration."

        return
    fi

    # check parameter
    if [ $# -ne 0 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    if [ "$ROBO_CONFIG_IS_SERVER" == "1" ]; then

        robo_setup_server_interfaces_check
        robo_setup_server_dnsmasq_check

    else
        echo "... no client-specific checks yet"
    fi

    robo_system_check_internet
}

# 2021 01 01
function robo_system_check_internet() {

    # init variables
    error_flag=0;

   # initial output
    echo -n "internet ... "

    # check for internet connection
    ping -q -c 1 -w 2 8.8.8.8 > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        error_flag=1;
        echo ""
        echo -n "  no internet connection"
    fi;

    # final result
    if [ $error_flag -eq 0 ]; then
        echo "ok"
    else
        echo ""
    fi
}
