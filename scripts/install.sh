#!/bin/bash


#***************************[update]******************************************
# 2019 09 10

alias robo_system_update="config_update_system"


#***************************[install]*****************************************
# 2019 09 10

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

            if [ "$ROBO_CONFIG_IS_SERVER" == "" ]; then
                echo "$FUNCNAME: You are not in server-mode!"
                echo -n "  Do you want to continue ? (No/yes) "
                read answer

                if [ "$answer" != "y" ] && [ "$answer" != "Y" ] && \
                  [ "$answer" != "yes" ]; then
                    echo "$FUNCNAME: Aborted."
                    return
                fi
            fi
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
    fi

    if [ $? -ne 0 ]; then return -2; fi
    echo "done :-)"
}
