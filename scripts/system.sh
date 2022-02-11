#!/bin/bash

#***************************[dependencies]************************************
# 2021 01 19

# the following must be sourced BEFORE this script
#     config.sh
#     setup_server.sh
#
# the following must be sourced AFTER this script



#***************************[update]******************************************
# 2021 08 12

export ROBO_PATH_LOG_UPDATE="${ROBO_PATH_CONFIG}update.log"

function robo_system_update() {

    # call update function
    config_update_system
    if [ $? -ne 0 ]; then return -1; fi

    # add logging
    temp="${ROBO_PATH_CONFIG}update.log"
    if [ ! -f "$ROBO_PATH_LOG_UPDATE" ]; then
        touch "$ROBO_PATH_LOG_UPDATE" 2>> /dev/null
        if [ $? -ne 0 ]; then return -2; fi
    fi
    if [ -f "$ROBO_PATH_LOG_UPDATE" ]; then
        str="$(date +"%d.%m.%Y %H:%M") update system"
        echo "$str" >> "$ROBO_PATH_LOG_UPDATE"
    fi
}

# 2021 09 19
function robo_system_check_update() {

    # init variables
    error_flag=0;

   # initial output
    echo -n "system update     ... "

    # check for logfile
    if [ ! -f "$ROBO_PATH_LOG_UPDATE" ]; then
        error_flag=1;
        echo ""
        echo -n "  no logfile"
    else
        # convert date to seconds
        date="$(tail -n 1 "$ROBO_PATH_LOG_UPDATE" | awk "{print \$1}")"
        if [ "$date" == "" ]; then
            error_flag=1;
            echo ""
            echo -n "  no valid log"
        else
            date_en="$(echo "$date" | \
              awk -F "." "{print \$2\"/\"\$1\"/\"\$3}")"
            date_secs="$(date --date="$date_en" +"%s")"

            # calculate time diff in days
            now_secs="$(date +"%s")"
            diff_days="$(echo "($now_secs - $date_secs) / 60 / 60 / 24" | \
              bc)"

            if [ $diff_days -ge 6 ]; then
                error_flag=1;
                echo ""
                echo -n "  $diff_days days ago"
            fi
        fi
    fi

    # final result
    if [ $error_flag -eq 0 ]; then
        echo "ok"
    else
        echo ""
        echo "  --> robo_system_update"
    fi
}



#***************************[install]*****************************************
# 2022 02 11

export ROBO_PATH_LOG_INSTALL="${ROBO_PATH_CONFIG}install.log"
export ROBO_SYSTEM_INSTALL_DATE_CLIENT="11/02/2022"
export ROBO_SYSTEM_INSTALL_DATE_SERVER="11/02/2022"

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

    # check python version
    if [ "$VER" -lt "20" ]; then
        PYTHON="python"
    else
        PYTHON="python3"
    fi

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

            git meld

            vim kate bless
            exuberant-ctags

            binutils gcc avr-libc avrdude
            g++ cmake

            $PYTHON $PYTHON-serial $PYTHON-opencv

            librecad inkscape dia

            zim doxygen

            libreoffice libreoffice-help-de
            okular gwenview

            vlc
            " "" --yes
        if [ $? -ne 0 ]; then return -2; fi

        # ubuntu-version dependend packages
        if [ "$PYTHON" == "python3" ]; then
            _config_install_list "python-is-python3"
        fi

        # install vs code
        if apt show code 2>> /dev/null; then
            _config_install_list "code"
        else
            config_install_vscode
        fi
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

    # add logging
    if [ ! -f "$ROBO_PATH_LOG_INSTALL" ]; then
        touch "$ROBO_PATH_LOG_INSTALL" 2>> /dev/null
        if [ $? -ne 0 ]; then return -3; fi
    fi
    if [ -f "$ROBO_PATH_LOG_INSTALL" ]; then
        str="$(date +"%d.%m.%Y %H:%M") install"
        if [ "$server_flag" -ne 0 ]; then
            str="${str} server"
        fi
        echo "$str" >> "$ROBO_PATH_LOG_INSTALL"
    fi
    if [ $? -ne 0 ]; then return -3; fi

    echo "done :-)"
}


# 2021 08 12
function robo_system_check_install() {

    # init variables
    error_flag=0;

   # initial output
    echo -n "system install    ... "

    # check for internet connection
    if [ ! -f "$ROBO_PATH_LOG_INSTALL" ]; then
        error_flag=1;
        echo ""
        echo "  no logfile"
        echo -n "  --> robo_system_install"
        if [ "$ROBO_CONFIG_IS_SERVER" == "1" ]; then
            echo ""
            echo -n "  --> robo_system_install server"
        fi
    else
        # check for client install
        date="$(cat "$ROBO_PATH_LOG_INSTALL" | grep -v server | \
          tail -n 1 | awk "{print \$1}")"
        if [ "$date" == "" ]; then
            error_flag=1;
            echo ""
            echo "  no valid log"
            echo -n "  --> robo_system_install"
        else
            date_en="$(echo "$date" | \
              awk -F "." "{print \$2\"/\"\$1\"/\"\$3}")"
            date_secs="$(date --date="$date_en" +"%s")"

            # calculate time diff in days
            date_update_client="$(date \
              --date="$ROBO_SYSTEM_INSTALL_DATE_CLIENT" +"%s")"

            if [ $date_update_client -ge $date_secs ]; then
                error_flag=1;
                echo ""
                echo "  new client installs"
                echo -n "  --> robo_system_install"
            fi
        fi

        # check for server install
        if [ "$ROBO_CONFIG_IS_SERVER" == "1" ]; then
            date="$(cat "$ROBO_PATH_LOG_INSTALL" | grep server | \
            tail -n 1 | awk "{print \$1}")"
            if [ "$date" == "" ]; then
                error_flag=1;
                echo ""
                echo "  no valid log for server"
                echo -n "  --> robo_system_install server"
            else
                date_en="$(echo "$date" | \
                awk -F "." "{print \$2\"/\"\$1\"/\"\$3}")"
                date_secs="$(date --date="$date_en" +"%s")"

                # calculate time diff in days
                date_update_server="$(date \
                --date="$ROBO_SYSTEM_INSTALL_DATE_SERVER" +"%s")"

                if [ $date_update_server -ge $date_secs ]; then
                    error_flag=1;
                    echo ""
                    echo "  new server installs"
                    echo -n "  --> robo_system_install server"
                fi
            fi
        fi
    fi

    # final result
    if [ $error_flag -eq 0 ]; then
        echo "ok"
    else
        echo ""
    fi
}



#***************************[check]******************************************
# 2021 11 02

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
        echo "### check SERVER ###"
    elif [ "$ROBO_CONFIG_IS_CLIENT" == "1" ]; then
        echo "### check CLIENT ###"
    elif [ "$ROBO_CONFIG_STANDALONE" == "1" ]; then
        echo "### check STANDALONE ###"
    else
        echo "### who are you ? ###"
    fi

    # user & groups
    if [ "$ROBO_CONFIG_STANDALONE" != "1" ]; then
        robo_config_user_check
    fi

    # paths
    robo_config_paths_check

    # network
    if [ "$ROBO_CONFIG_IS_SERVER" == "1" ]; then
        robo_setup_server_interfaces_check
    fi
    if [ "$ROBO_CONFIG_STANDALONE" != "1" ]; then
        robo_system_check_server
    fi
    robo_system_check_internet

    # services/deamons
    if [ "$ROBO_CONFIG_IS_SERVER" == "1" ]; then
        robo_setup_server_dnsmasq_check
        robo_config_server_dhcp_check
        robo_setup_server_apache_check

        robo_setup_server_samba_check
    fi
    if [ "$ROBO_CONFIG_STANDALONE" != "1" ]; then
        robo_config_samba_check
    else
        echo ""
        echo "optional: $ robo_config_samba_check"
    fi
    if [ "$ROBO_CONFIG_IS_SERVER" == "1" ]; then
        robo_setup_server_aptcacher_check
    fi
    if [ "$ROBO_CONFIG_STANDALONE" != "1" ]; then
        robo_config_aptcacher_check
    fi
    if [ "$ROBO_CONFIG_IS_SERVER" == "1" ]; then
        robo_config_server_intranet_check
        robo_server_userdata_check
    fi

    if [ "$ROBO_CONFIG_IS_CLIENT" == "1" ]; then
        robo_config_keys_check
    fi

    if [ "$ROBO_CONFIG_STANDALONE" != "1" ]; then
        robo_system_check_install
        robo_system_check_update
        robo_repo_check
    fi

    # checks which need sudo rights
    if [ "$ROBO_CONFIG_IS_SERVER" == "1" ]; then
        if sudo -n true 2> /dev/null; then
            robo_setup_server_cron_check
            robo_setup_server_smbuser_check
            robo_config_server_internet_check
        else
            echo ""
            echo "not executing the following checks:"
            echo "  $ robo_setup_server_cron_check"
            echo "  $ robo_setup_server_smbuser_check"
            echo "  $ robo_config_server_internet_check"
        fi
    fi
}

# 2021 01 16
function robo_system_check_internet() {

    # init variables
    error_flag=0;

   # initial output
    echo -n "internet          ... "

    # check for internet connection
    if ! network_ping 8.8.8.8 &> /dev/null; then
        error_flag=1;
        #echo ""
        #echo -n "  no internet connection"
    fi;

    # final result
    if [ $error_flag -eq 0 ]; then
        echo "ok"
    else
        echo ":-("
    fi
}

# 2021 01 15
function robo_system_check_server() {

    # init variables
    error_flag=0;

   # initial output
    echo -n "roboag server     ... "

    # check for internet connection
    if ! network_ping "${_ROBO_SERVER_IP}" &> /dev/null; then
        error_flag=1;
        echo ""
        echo -n "  no ping"
    fi;

    # final result
    if [ $error_flag -eq 0 ]; then
        echo "ok"
    else
        echo ""
    fi
}
