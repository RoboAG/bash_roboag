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



#***************************[samba paths]*************************************
# 2019 11 20

export _ROBO_SHARE_ROBOAG="/media/roboag/"
export _ROBO_SHARE_ROBOAG2="/media/roboag_smb/"
#export _ROBO_SHARE_ROBOAG3="/opt/roboag/data/roboag_smb/"
export _ROBO_SHARE_ROBOSAX="/media/robosax/"
export _ROBO_SHARE_ROBOSAX2="/media/robosax_smb/"
#export _ROBO_SHARE_ROBOSAX3="/opt/roboag/data/robosax_smb/"

if [ "$ROBO_SHARE_ROBOAG" == "" ]; then
    if [ -d "_ROBO_SHARE_ROBOAG2" ]; then
        export ROBO_SHARE_ROBOAG="$_ROBO_SHARE_ROBOAG2"
    else
        export ROBO_SHARE_ROBOAG="$_ROBO_SHARE_ROBOAG"
    fi
fi
if [ "$ROBO_SHARE_ROBOSAX" == "" ]; then
    if [ -d "_ROBO_SHARE_ROBOSAX2" ]; then
        export ROBO_SHARE_ROBOSAX="$_ROBO_SHARE_ROBOSAX2"
    else
        export ROBO_SHARE_ROBOSAX="$_ROBO_SHARE_ROBOSAX"
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

# 2021 01 04
function robo_config_user() {

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "add user roboag and add users to groups."

    # init variables
    user_roboag=""
    groups_guru="sudo plugdev dialout roboag"
    groups_roboag="plugdev dialout"


    # check user roboag
    getent_roboag="$(getent passwd roboag)"
    if [ "$getent_roboag" == "" ]; then
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
    groups="$(cat /etc/group | grep ":.*roboag" | grep -o "^[^:]*")"
    for group in $groups_roboag; do
        if [ "$(echo $groups | grep "$group")" == "" ]; then
            sudo addgroup roboag "$group"
        fi
    done

    # add current user to groups
    groups="$(cat /etc/group | grep ":.*$USER" | grep -o "^[^:]*")"
    for group in $groups_guru; do
        if [ "$(echo $groups | grep "$group")" == "" ]; then
            sudo addgroup "$USER" "$group"
        fi
    done

    # update permissions of users home
    current_mode="$(stat -c "%a" "$HOME")"
    if [ $? -ne 0 ] || [ "$current_mode" != "700" ]; then
        echo "changing permissions for $HOME"
        echo "  (from $current_mode to 700)"
        chmod 700 "$HOME"
    fi

    # update permissions of roboags home
    if [ "$getent_roboag" != "" ]; then
        home_roboag="$(echo "$getent_roboag" | \
        awk --field-separator=: "{print \$6 }")"
        if [ -d "$home_roboag" ]; then
            current_mode="$(stat -c "%a" "$home_roboag")"
            if [ $? -ne 0 ] || [ "$current_mode" != "770" ]; then
                echo "changing permissions for $home_roboag"
                echo "  (from $current_mode to 770)"
                sudo chmod 770 "$home_roboag"
            fi
        fi
    fi

    echo "done :-)"
}

# 2021 01 04
function robo_config_user_check() {

    # init variables
    error_flag=0;
    user_roboag=""
    groups_guru="sudo plugdev dialout"
    groups_roboag="plugdev dialout"

    # initial output
    echo -n "users & groups ... "

    # check user roboag
    getent_roboag="$(getent passwd roboag)"
    if [ "$getent_roboag" != "" ]; then
        user_roboag="1"
        groups_guru="${groups_guru} roboag"
    fi

    # check groups of current user
    groups="$(cat /etc/group | grep ":.*$USER" | grep -o "^[^:]*")"
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
        groups="$(cat /etc/group | grep ":.*roboag" | grep -o "^[^:]*")"
        for group in $groups_roboag; do
            if [ "$(echo "$groups" | grep "$group")" == "" ]; then
                error_flag=1
                echo ""
                echo -n "  roboag is not in $group"
            fi
        done
    fi

    # update permissions of users home
    current_mode="$(stat -c "%a" "$HOME")"
    if [ $? -ne 0 ] || [ "$current_mode" != "700" ]; then
        error_flag=1
        echo ""
        echo -n "  mode of $HOME is not 700"
    fi

    # update permissions of roboags home
    if [ "$getent_roboag" != "" ]; then
        home_roboag="$(echo "$getent_roboag" | \
        awk --field-separator=: "{print \$6 }")"
        if [ -d "$home_roboag" ]; then
            current_mode="$(stat -c "%a" "$home_roboag")"
            if [ $? -ne 0 ] || [ "$current_mode" != "770" ]; then
                error_flag=1
                echo ""
                echo -n "  mode of $home_roboag is not 770"
            fi
        fi
    fi

    if [ $error_flag -eq 0 ]; then
        echo "ok"
    else
        echo ""
        echo "  --> robo_config_user"
    fi
}

# 2021 01 04
function robo_config_user_restore() {

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "removes user/group roboag."

    # init variables
    user_roboag=""

    # check user roboag
    if [ "$(getent passwd roboag)" == "" ]; then
        echo "user roboag does not exist"
    else
        # check samba db
        if [ "$(sudo pdbedit -L | grep roboag)" != "" ]; then
            echo "Error: samba user roboag still exists!"
            echo "  --> robo_setup_server_smbuser_restore"
            return -1
        fi

        # remove user
        sudo deluser --remove-home roboag
    fi

    # check group roboag
    if [ "$(getent group roboag)" == "" ]; then
        # remove user
        sudo delgroup roboag
    else
        echo "group roboag does not exist (anymore)"
    fi

    echo "done :-)"
}



#***************************[samba]*******************************************

# 2021 01 05
function robo_config_samba_check() {

    # init variables
    error_flag=0;

    # initial output
    echo -n "samba share ... "

    # check mount points
    if [ ! -d "$ROBO_SHARE_ROBOAG" ]; then
        error_flag=1
        echo ""
        echo -n "  mountpoint roboag does not exist"
    else
        if [ -d "/opt/roboag/" ]; then
            smb_path="/opt/roboag/data/"
        else
            smb_path="$HOME"
        fi
        smb_file="${smb_path}.smbcredentials"

        if [ ! -f "$smb_file" ]; then
            error_flag=1
            echo ""
            echo -n "  roboag's credential file does not exist"
        else
            if [ "$(stat -c "%U" "$smb_file")" != "root" ]; then
                error_flag=1
                echo ""
                echo -n "  roboag's credential file not owned by root"
            fi
            if [ "$(stat -c "%a" "$smb_file")" != "600" ]; then
                error_flag=1
                echo ""
                echo -n "  roboag's credential file's mode is not 600"
            fi
        fi
        if [ "(cat /etc/fstab | grep "$ROBO_SHARE_ROBOAG")" == "" ]; then
            error_flag=1
            echo ""
            echo -n "  roboag not defined in fstab"
        elif ! findmnt --noheadings "$ROBO_SHARE_ROBOAG" > /dev/null; then
            error_flag=1
            echo ""
            echo -n "  roboag not mounted"
        fi
    fi
    if [ ! -d "$ROBO_SHARE_ROBOSAX" ]; then
        error_flag=1
        echo ""
        echo -n "  mountpoint robosax does not exist"
    else
        if [ "(cat /etc/fstab | grep "$ROBO_SHARE_ROBOSAX")" == "" ]; then
            error_flag=1
            echo ""
            echo -n "  robosax not defined in fstab"
        elif ! findmnt --noheadings "$ROBO_SHARE_ROBOSAX" > /dev/null; then
            error_flag=1
            echo ""
            echo -n "  robosax not mounted"
        fi
    fi

    if [ $error_flag -eq 0 ]; then
        echo "ok"
    else
        echo ""
        echo "  --> ToDo robo_config_samba"
    fi
}
