#!/bin/bash

#***************************[dependencies]************************************
# 2021 01 19

# the following must be sourced BEFORE this script
#     config.sh
#     setup_server.sh
#
# the following must be sourced AFTER this script



#***************************[date]********************************************
# 2022 02 22

function _robo_system_convert_date_to_sec() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME dd.mm.yyyy"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 1 parameter"
        echo "     #1: date in german/european notation"
        echo "         e.g. 17.06.2021"
        echo "This function converts the given day into unix time."

        return
    fi

    # check parameter
    if [ $# -ne 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # init variables
    date="$1"

    # convert date into american style (e.g. 06/17/2021)
    date_en="$(echo "$date" | awk -F "." "{print \$2\"/\"\$1\"/\"\$3}")"
    if [ $? -ne 0 ]; then return -2; fi

    # convert date into unix time
    date_secs="$(date --date="$date_en" +"%s")"
    if [ $? -ne 0 ]; then return -3; fi

    echo "$date_secs"
}



#***************************[update]******************************************
# 2023 02 04

export ROBO_FILE_LOG_UPDATE="${ROBO_PATH_CONFIG}update.log"

function robo_system_update() {

    # call update function
    config_update_system
    if [ $? -ne 0 ]; then return -1; fi

    # add logging
    if [ ! -f "$ROBO_FILE_LOG_UPDATE" ]; then
        touch "$ROBO_FILE_LOG_UPDATE" 2>> /dev/null
        if [ $? -ne 0 ]; then return -2; fi
    fi
    if [ -f "$ROBO_FILE_LOG_UPDATE" ]; then
        str="$(date +"%d.%m.%Y %H:%M") update system"
        echo "$str" >> "$ROBO_FILE_LOG_UPDATE"
    fi
}

# 2023 02 04
function robo_system_check_update() {

    # init variables
    error_flag=0;

   # initial output
    echo -n "system update     ... "

    # check for logfile
    if [ ! -f "$ROBO_FILE_LOG_UPDATE" ]; then
        error_flag=1;
        echo ""
        echo -n "  no logfile"
    else
        # convert date to seconds
        date="$(tail -n 1 "$ROBO_FILE_LOG_UPDATE" | awk "{print \$1}")"
        if [ "$date" == "" ]; then
            error_flag=1;
            echo ""
            echo -n "  no valid log"
        else
            # convert given date & today in unix time
            date_secs="$(_robo_system_convert_date_to_sec "$date")"
            now_secs="$(date +"%s")"
            # calculate time diff in days
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
# 2024 09 09

export ROBO_FILE_LOG_INSTALL="${ROBO_PATH_CONFIG}install.log"
export ROBO_SYSTEM_INSTALL_DATE_COMMON="17.05.2025"
export ROBO_SYSTEM_INSTALL_DATE_SERVER="23.09.2023"
export ROBO_SYSTEM_UNINSTALL_DATE_COMMON="17.05.2025"
export ROBO_SYSTEM_UNINSTALL_DATE_SERVER="23.09.2023"

common_path="${ROBO_PATH_SCRIPT}system_config/install/"
export ROBO_FILE_INSTALL_COMMON="${common_path}/common.txt"
export ROBO_FILE_INSTALL_SERVER="${common_path}/server.txt"
export ROBO_FILE_UNINSTALL_COMMON="${common_path}/uninstall_common.txt"
export ROBO_FILE_UNINSTALL_SERVER="${common_path}/uninstall_server.txt"

# 2024 09 09
function robo_system_install() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME [<system>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 0-1 parameters"
        echo "    [#1:]system for installed packages"
        echo "         \"\"       common packages (default)"
        echo "         \"server\" additional packages for server"
        echo "This function installs all needed packages."

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
    UBUNTU_VERSION=$(lsb_release -rs | cut -d. -f1)

    # check python version
    if [ "$UBUNTU_VERSION" -lt "20" ]; then
        PYTHON="python"
    else
        PYTHON="python3"
    fi

    # select between common and only server
    if [ "$server_flag" -eq 0 ]; then
        # common install
        list="$(_robo_config_read_list "${ROBO_FILE_INSTALL_COMMON}")"
        if [ $? -ne 0 ]; then return -2; fi
        _config_install_list "$list" "" --yes
        if [ $? -ne 0 ]; then return -3; fi
        _config_install_list "$PYTHON $PYTHON-serial $PYTHON-opencv" "" --yes
        if [ $? -ne 0 ]; then return -3; fi

        # ubuntu-version dependend packages
        if [ "$PYTHON" == "python3" ]; then
            _config_install_list "python-is-python3"
            if [ $? -ne 0 ]; then return -3; fi
        fi

        # install vs code
        if apt show code 2>> /dev/null; then
            _config_install_list "code"
        else
            config_install_vscode
        fi
        if [ $? -ne 0 ]; then return -4; fi
    else
        # server install
        list="$(_robo_config_read_list "${ROBO_FILE_INSTALL_SERVER}")"
        if [ $? -ne 0 ]; then return -2; fi
        _config_install_list "$list" "" --yes
        if [ $? -ne 0 ]; then return -3; fi

        # handle older operating systems
        if [ "$UBUNTU_VERSION" -le "20" ]; then
	        _config_install_list "exfat-utils" "" --yes
            if [ $? -ne 0 ]; then return -4; fi
        fi
    fi

    # add logging
    if [ ! -f "$ROBO_FILE_LOG_INSTALL" ]; then
        touch "$ROBO_FILE_LOG_INSTALL" 2>> /dev/null
        if [ $? -ne 0 ]; then return -5; fi
    fi
    if [ -f "$ROBO_FILE_LOG_INSTALL" ]; then
        str="$(date +"%d.%m.%Y %H:%M") install"
        if [ "$server_flag" -eq 0 ]; then
            str="${str} common ${ROBO_SYSTEM_INSTALL_DATE_COMMON}"
        else
            str="${str} server ${ROBO_SYSTEM_INSTALL_DATE_SERVER}"
        fi
        echo "$str" >> "$ROBO_FILE_LOG_INSTALL"
    fi
    if [ $? -ne 0 ]; then return -5; fi

    echo "done :-)"
}

# 2024 09 09
function robo_system_uninstall() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME [<system>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 0-1 parameters"
        echo "    [#1:]system for uninstalling packages"
        echo "         \"\"       common packages (default)"
        echo "         \"server\" additional packages for server"
        echo "This function uninstalls packages, not needed anymore."

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

    # select between common and only server
    if [ "$server_flag" -eq 0 ]; then
        # common uninstall
        list="$(_robo_config_read_list "${ROBO_FILE_UNINSTALL_COMMON}")"
        if [ $? -ne 0 ]; then return -2; fi
        _config_uninstall_list "$list" "" --yes
        if [ $? -ne 0 ]; then return -3; fi
    else
        # server uninstall
        list="$(_robo_config_read_list "${ROBO_FILE_UNINSTALL_SERVER}")"
        if [ $? -ne 0 ]; then return -2; fi
        _config_uninstall_list "$list" "" --yes
        if [ $? -ne 0 ]; then return -3; fi
    fi

    # add logging
    if [ ! -f "$ROBO_FILE_LOG_INSTALL" ]; then
        touch "$ROBO_FILE_LOG_INSTALL" 2>> /dev/null
        if [ $? -ne 0 ]; then return -3; fi
    fi
    if [ -f "$ROBO_FILE_LOG_INSTALL" ]; then
        str="$(date +"%d.%m.%Y %H:%M") uninstall"
        if [ "$server_flag" -eq 0 ]; then
            str="${str} common ${ROBO_SYSTEM_UNINSTALL_DATE_COMMON}"
        else
            str="${str} server ${ROBO_SYSTEM_UNINSTALL_DATE_SERVER}"
        fi
        echo "$str" >> "$ROBO_FILE_LOG_INSTALL"
    fi
    if [ $? -ne 0 ]; then return -3; fi

    echo "done :-)"
}

# 2023 02 04
function robo_system_check_install() {

    # init variables
    error_flag=0;

   # initial output
    echo -n "system install    ... "

    # check for internet connection
    if [ ! -f "$ROBO_FILE_LOG_INSTALL" ]; then
        error_flag=1;
        echo ""
        echo "  no logfile"
        echo "  --> robo_system_install"
        echo -n "  --> robo_system_uninstall"
        if [ "$ROBO_CONFIG_IS_SERVER" == "1" ]; then
        echo ""
            echo "  --> robo_system_install server"
            echo -n "  --> robo_system_uninstall server"
        fi
    else
        # check for common install
        date="$(cat "$ROBO_FILE_LOG_INSTALL" | \
          grep -E " install (client|common) " | \
          tail -n 1 | awk '{print $5}')"
        if [ $? -ne 0 ] || [ "$date" == "" ]; then
            error_flag=1;
            echo ""
            echo "  no valid log for common installation"
            echo -n "  --> robo_system_install"
        else
            # convert last install date & latest timestamp into unix time
            date_secs="$(_robo_system_convert_date_to_sec "$date")"
            date_timestamp_secs="$(_robo_system_convert_date_to_sec \
              "$ROBO_SYSTEM_INSTALL_DATE_COMMON")"

            if [ $? -ne 0 ] || [ $date_timestamp_secs -gt $date_secs ]; then
                error_flag=1;
                echo ""
                echo "  new common install"
                echo -n "  --> robo_system_install"
            fi
        fi

        # check for common uninstall
        date="$(cat "$ROBO_FILE_LOG_INSTALL" | \
          grep -E " uninstall (client|common) " | \
          tail -n 1 | awk '{print $5}')"
        if [ $? -ne 0 ] || [ "$date" == "" ]; then
            error_flag=1;
            echo ""
            echo "  no valid log for common uninstallation"
            echo -n "  --> robo_system_uninstall"
        else
            # convert last install date & latest timestamp into unix time
            date_secs="$(_robo_system_convert_date_to_sec "$date")"
            date_timestamp_secs="$(_robo_system_convert_date_to_sec \
              "$ROBO_SYSTEM_UNINSTALL_DATE_COMMON")"

            if [ $? -ne 0 ] || [ $date_timestamp_secs -gt $date_secs ]; then
                error_flag=1;
                echo ""
                echo "  new client uninstall"
                echo -n "  --> robo_system_uninstall"
            fi
        fi

        # check for server mode
        if [ "$ROBO_CONFIG_IS_SERVER" == "1" ]; then
            # check for server install
            date="$(cat "$ROBO_FILE_LOG_INSTALL" | \
              grep " install server " | tail -n 1 | awk '{print $5}')"
            if [ $? -ne 0 ] || [ "$date" == "" ]; then
                error_flag=1;
                echo ""
                echo "  no valid log for server install"
                echo -n "  --> robo_system_install server"
            else
                # convert last install date & latest timestamp into unix time
                date_secs="$(_robo_system_convert_date_to_sec "$date")"
                date_timestamp_secs="$(_robo_system_convert_date_to_sec \
                "$ROBO_SYSTEM_INSTALL_DATE_SERVER")"

                if [ $? -ne 0 ] || \
                  [ $date_timestamp_secs -gt $date_secs ]; then
                    error_flag=1;
                    echo ""
                    echo "  new server install"
                    echo -n "  --> robo_system_install server"
                fi
            fi

            # check for server uninstall
            date="$(cat "$ROBO_FILE_LOG_INSTALL" | \
              grep " uninstall server " | tail -n 1 | awk '{print $5}')"
            if [ $? -ne 0 ] || [ "$date" == "" ]; then
                error_flag=1;
                echo ""
                echo "  no valid log for server uninstall"
                echo -n "  --> robo_system_uninstall server"
            else
                # convert last install date & latest timestamp into unix time
                date_secs="$(_robo_system_convert_date_to_sec "$date")"
                date_timestamp_secs="$(_robo_system_convert_date_to_sec \
                "$ROBO_SYSTEM_UNINSTALL_DATE_SERVER")"

                if [ $? -ne 0 ] || \
                  [ $date_timestamp_secs -gt $date_secs ]; then
                    error_flag=1;
                    echo ""
                    echo "  new server uninstall"
                    echo -n "  --> robo_system_uninstall server"
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
# 2024 08 08

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
        robo_setup_server_rebind_repos_check
        robo_setup_server_samba_check
    fi
    if [ "$ROBO_CONFIG_STANDALONE" != "1" ]; then
        robo_config_samba_check
    else
        echo ""
        echo "optional: $ robo_config_samba_check"
    fi
    if [ "$ROBO_CONFIG_IS_SERVER" == "1" ]; then
        robo_setup_server_aptcacher_check # checks for removal
        robo_setup_server_aptproxy_check
    fi
    robo_config_aptcacher_check # checks for removal
    robo_config_aptproxy_check
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
