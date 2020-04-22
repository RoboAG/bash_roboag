#!/bin/bash


#***************************[update]******************************************
# 2019 09 10

alias robo_system_update="config_update_system"


#***************************[install]*****************************************
# 2020 04 22

function robo_system_install() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME [<flag>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 0-1 parameters"
        echo "    [#1:]flag for installed packages"
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

            _robo_system_need_server "$FUNCNAME"
            if [ $? -ne 0 ]; then return; fi
        elif [ "$1" != "" ]; then
            echo "$FUNCNAME: Parameter Error."
            $FUNCNAME --help
            return -1
        fi
    fi

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
            python

            librecad eagle inkscape dia

            zim doxygen

            libreoffice libreoffice-help-de
            okular gwenview

            vlc
            " "" --yes
        if [ $? -ne 0 ]; then return -2; fi

        # install vs code
        config_install_vscode
        if [ $? -ne 0 ]; then return -3; fi
    else
        _config_install_list "
            exfat-fuse exfat-utils

            apt-cacher-ng

            samba samba-common

            isc-dhcp-server

            apache2
            mariadb-server
            php php-mysql phpmyadmin
            " "" --yes
        if [ $? -ne 0 ]; then return -2; fi
    fi

    echo "done :-)"
}


#***************************[apt-cacher-ng]***********************************
# 2019 11 20

function robo_config_aptcacher() {

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "updates all source lists to use the apt-cacher-ng running on server."
    if [ $? -ne 0 ]; then return -1; fi

    config_source_list_aptcacher_set "$ROBO_SERVER_IP"
    if [ $? -ne 0 ]; then return -2; fi

    echo "done :-)"
}

alias robo_config_aptcacher_restore="config_source_list_aptcacher_unset"
alias robo_config_aptcacher_check="config_source_list_aptcacher_check"
