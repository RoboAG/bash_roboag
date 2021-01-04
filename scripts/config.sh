#!/bin/bash

#***************************[needed external variables]***********************
# 2020 10 11

# ROBO_PATH_SCRIPTS

# note: repo files must be sourced BEFORE this script



#***************************[paths and files]*********************************
# 2020 10 11

if [ "$ROBO_PATH_CONFIG" == "" ]; then
    # check if an alternative path exists
    if [ "$REPO_BASH_DATA_PATH" != "" ] && \
      [ -d "$REPO_BASH_DATA_PATH" ]; then
        export ROBO_PATH_CONFIG="${REPO_BASH_DATA_PATH}roboag/"
    else
        export ROBO_PATH_CONFIG="${ROBO_PATH_SCRIPT}config/"
    fi

    # check if config folder exists
    if [ ! -d "$ROBO_PATH_CONFIG" ]; then
        echo "creating config folder for \"roboag\""
        echo "    ($ROBO_PATH_CONFIG)"
        mkdir -p "$ROBO_PATH_CONFIG"
    fi
fi



#***************************[mode of operation]*******************************
# 2019 09 10

# unset all possible config states
unset ROBO_CONFIG_IS_SERVER
unset ROBO_CONFIG_IS_CLIENT
unset ROBO_CONFIG_STANDALONE

# Is in server-mode ?
if [ "$(ls $ROBO_PATH_CONFIG  | grep -i is_server | wc -w)" -gt 0 ]; then
    export ROBO_CONFIG_IS_SERVER="1"
else

    # Is in client-mode ?
    if [ "$(ls $ROBO_PATH_CONFIG  | grep -i is_client | wc -w)" -gt 0 ]; then
        export ROBO_CONFIG_IS_CLIENT="1"
    else

        # Standalone-Mode!
        export ROBO_CONFIG_STANDALONE="1"
    fi
fi



#***************************[check mode of operation]*************************

# 2020 10 12
function _robo_config_need_server() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME <function-name>"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 1 parameter"
        echo "     #1: name of calling function"
        echo "This function checks if server-mode is active."
        echo "Elsewhile the user will be asked, before continueing."

        return
    fi

    # check parameter
    if [ $# -ne 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi
    # check parameter
    if [ "$1" == "" ]; then
        echo -n "$FUNCNAME: Parameter Error - "
        echo "name of calling function must be set."
        return -2
    fi

    if [ "$ROBO_CONFIG_IS_SERVER" == "" ]; then
        echo "$1: You are not in server-mode!"
        echo -n "  Do you want to continue ? (No/yes) "
        read answer

        if [ "$answer" != "y" ] && [ "$answer" != "Y" ] && \
            [ "$answer" != "yes" ]; then
            echo "$1: Aborted."
            return -3
        fi
    fi
}

# 2020 10 12
function _robo_config_need_client() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME <function-name>"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 1 parameter"
        echo "     #1: name of calling function"
        echo "This function checks if client-mode is active."
        echo "Elsewhile the user will be asked, before continueing."

        return
    fi

    # check parameter
    if [ $# -ne 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi
    # check parameter
    if [ "$1" == "" ]; then
        echo -n "$FUNCNAME: Parameter Error - "
        echo "name of calling function must be set."
        return -2
    fi

    if [ "$ROBO_CONFIG_IS_CLIENT" == "" ]; then
        echo "$1: You are not in client-mode!"
        echo -n "  Do you want to continue ? (No/yes) "
        read answer

        if [ "$answer" != "y" ] && [ "$answer" != "Y" ] && \
            [ "$answer" != "yes" ]; then
            echo "$1: Aborted."
            return -3
        fi
    fi
}



#***************************[apt-cacher-ng]***********************************

# 2020 12 31
function robo_config_aptcacher() {

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "updates all source lists to use the apt-cacher-ng running on server."
    if [ $? -ne 0 ]; then return -1; fi

    config_source_list_aptcacher_set --https2http "$ROBO_SERVER_IP"
    if [ $? -ne 0 ]; then return -2; fi

    echo "done :-)"
}

# 2021 01 03
function robo_config_aptcacher_check() {

    echo -n "apt-cacher sources ... "
    config_source_list_aptcacher_check "quiet"
    if [ $? -eq 0 ]; then
        echo "ok"
    else
        echo ""
        echo "  --> robo_config_aptcacher"
    fi
}

# 2020 12 31
alias robo_config_aptcacher_restore="config_source_list_aptcacher_unset"



#***************************[user]********************************************

# 2021 01 03
function robo_config_user() {

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "add user roboag and add users to groups."

    # init variables
    user_roboag=""
    groups_guru="sudo plugdev dialout"
    groups_roboag="plugdev dialout"


    # check user roboag
    groups="$(id roboag 2> /dev/null)"
    if [ $? -eq 0 ]; then
        user_roboag="1"
        groups_guru="$groups_guru roboag"
    else
        # create user roboag
        if [ "$ROBO_CONFIG_IS_SERVER" != "" ]; then
            sudo adduser --no-create-home \
            --disabled-password --disabled-login \
            --gecos "RoboAG" --uid 2000  roboag
        else
            sudo adduser --gecos "RoboAG" --uid 2000  roboag
        fi
        if [ $? -ne 0 ]; then return -1; fi
    fi

    # add roboag to groups
    groups="$(id roboag 2> /dev/null)"
    for group in $groups_roboag; do
        if [ "$(echo $groups | grep "$group")" == "" ]; then
            sudo addgroup roboag "$group"
        fi
    done

    # add current user to groups
    groups="$(id 2> /dev/null)"
    for group in $groups_guru; do
        if [ "$(echo $groups | grep "$group")" == "" ]; then
            sudo addgroup "$USER" "$group"
        fi
    done

    echo "done :-)"
}

# 2021 01 03
function robo_config_user_check() {

    # init variables
    error_flag=0;
    user_roboag=""
    groups_guru="sudo plugdev dialout"
    groups_roboag="plugdev dialout"

    # initial output
    echo -n "users & groups ... "

    # check user roboag
    id roboag > /dev/null 2> /dev/null
    if [ $? -eq 0 ]; then
        user_roboag="1"
        groups_guru="$groups_guru roboag"
    fi

    # check groups of current user
    groups="$(id)"
    for group in $groups_guru; do
        if [ "$(echo $groups | grep "$group")" == "" ]; then
            error_flag=1
            echo ""
            echo -n "  $USER is not in $group"
        fi
    done

    # check user roboag and it's groups

    if [ "$user_roboag" == "" ]; then
        error_flag=1
        echo ""
        echo -n "  roboag does not exist"
    else
        groups="$(id roboag 2> /dev/null)"
        for group in $groups_roboag; do
            if [ "$(echo $groups | grep "$group")" == "" ]; then
                error_flag=1
                echo ""
                echo -n "  roboag is not in $group"
            fi
        done
    fi

    if [ $error_flag -eq 0 ]; then
        echo "ok"
    else
        echo ""
        echo "  --> robo_config_user"
    fi
}
