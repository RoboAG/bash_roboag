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



#***************************[server ip]***************************************
# 2021 01 19

export _ROBO_SERVER_IP="192.168.2.20"
export _ROBO_SERVER_IP_MASK="255.255.255.0"
export _ROBO_SERVER_IP_MASK2="${_ROBO_SERVER_IP}/24"

# this definition is overwritten in server mode
export ROBO_SERVER_IP="$_ROBO_SERVER_IP"



#***************************[user]********************************************
# 2021 01 16

export ROBO_USER_ADMIN="guru"
export ROBO_USER_AG="roboag"



#***************************[shared paths]************************************
# 2021 01 16

export ROBO_PATH_SHARED="/opt/roboag/"
export ROBO_PATH_SHARED_REPOS="${ROBO_PATH_SHARED}repos/"
export ROBO_PATH_SHARED_DATA="${ROBO_PATH_SHARED}data/"



#***************************[samba paths]*************************************
# 2021 01 16

export _ROBO_SHARE_ROBOAG="/media/roboag/"
export _ROBO_SHARE_ROBOAG2="/media/roboag_smb/"
#export _ROBO_SHARE_ROBOAG3="${ROBO_PATH_SHARED_DATA}roboag_smb/"
export _ROBO_SHARE_ROBOSAX="/media/robosax/"
export _ROBO_SHARE_ROBOSAX2="/media/robosax_smb/"
#export _ROBO_SHARE_ROBOSAX3="{ROBO_PATH_SHARED_DATA}robosax_smb/"

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

# 2021 01 12
function _robo_config_mode_get() {

    # unset all possible config states
    unset ROBO_CONFIG_IS_SERVER
    unset ROBO_CONFIG_IS_CLIENT
    unset ROBO_CONFIG_STANDALONE

    # Is in server-mode ?
    temp=
    if [ "$(ls "$ROBO_PATH_CONFIG"  | grep -i is_server)" != "" ]; then
        export ROBO_CONFIG_IS_SERVER="1"
    else

        # Is in client-mode ?
        if [ "$(ls "$ROBO_PATH_CONFIG"  | grep -i is_client)" != "" ]; then
            export ROBO_CONFIG_IS_CLIENT="1"
        else

            # Standalone-Mode!
            export ROBO_CONFIG_STANDALONE="1"
        fi
    fi
}

# 2021 01 12
function robo_config_mode_get() {

    _robo_config_mode_get

    echo -n "current mode: "
    if [ "$ROBO_CONFIG_IS_SERVER" == "1" ]; then
        echo "server"
    elif [ "$ROBO_CONFIG_IS_CLIENT" == "1" ]; then
        echo "client"
    elif [ "$ROBO_CONFIG_STANDALONE" == "1" ]; then
        echo "standalone"
    else
        echo "?"
    fi
}

# 2021 01 12
function robo_config_mode_set() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME <mode>"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 1 parameter"
        echo "     #1: new mode of computer"
        echo "           \"client\"  client     mode"
        echo "           \"server\"  server     mode"
        echo "           \"\"        standalone mode"
        echo "Switching mode of current system."

        return
    fi

    # check parameter
    if [ $# -ne 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # check first parameter (mode)
    mode_flag=""
    if [ $# -gt 0 ]; then
        if [ "$1" == "client" ]; then
            mode_flag="client"
        elif [ "$1" == "server" ]; then
            mode_flag="server"
        elif [ "$1" == "" ]; then
            mode_flag="standalone"
        else
            echo "$FUNCNAME: Unknown parameter \"$1\"."
            $FUNCNAME --help
            return -1
        fi
    fi

    # check first parameter (mode)
    current_flag=""
    if [ $# -gt 0 ]; then
        if [ "$ROBO_CONFIG_IS_SERVER" == "1" ]; then
            current_flag="server"
        elif [ "$ROBO_CONFIG_IS_CLIENT" == "1" ]; then
            current_flag="client"
        elif [ "$ROBO_CONFIG_STANDALONE" == "1" ]; then
            current_flag="standalone"
        else
            current_flag="unknown"
        fi
    fi

    _config_simple_parameter_check "$FUNCNAME" "" \
      "Switching mode of system from $current_flag to ${mode_flag^^}."
    if [ $? -ne 0 ]; then return -2; fi

    # create config files
    if [ "$mode_flag" == "client" ] && \
      [ "$(ls "$ROBO_PATH_CONFIG"  | grep -i is_client)" == "" ]; then
        echo "creating ${ROBO_PATH_CONFIG}is_client.txt"
        touch "${ROBO_PATH_CONFIG}is_client.txt"
    elif [ "$mode_flag" == "server" ] && \
      [ "$(ls "$ROBO_PATH_CONFIG"  | grep -i is_server)" == "" ]; then
        echo "creating ${ROBO_PATH_CONFIG}is_server.txt"
        touch "${ROBO_PATH_CONFIG}is_server.txt"
    fi

    # remove old config files
    if [ "$mode_flag" != "client" ]; then
        files="$(ls "$ROBO_PATH_CONFIG"  | grep -i is_client)"
        if [ "$files" != "" ]; then
            for file in $files; do
                if [ -e "${ROBO_PATH_CONFIG}${file}" ]; then
                    echo "rm ${ROBO_PATH_CONFIG}${file}"
                    rm "${ROBO_PATH_CONFIG}${file}"
                fi
            done
        fi
    fi
    if [ "$mode_flag" != "server" ]; then
        files="$(ls "$ROBO_PATH_CONFIG"  | grep -i is_server)"
        if [ "$files" != "" ]; then
            for file in $files; do
                if [ -e "${ROBO_PATH_CONFIG}${file}" ]; then
                    echo "rm ${ROBO_PATH_CONFIG}${file}"
                    rm "${ROBO_PATH_CONFIG}${file}"
                fi
            done
        fi
    fi

    # get current mode
    _robo_config_mode_get

    echo "done :-)"
}

_robo_config_mode_get



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

# 2021 01 16
function robo_config_user() {

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "add user $ROBO_USER_AG and add users to groups."
    if [ $? -ne 0 ]; then return -1; fi

    # init variables
    user_roboag=""
    groups_guru="sudo plugdev dialout $ROBO_USER_AG"
    groups_roboag="plugdev dialout"

    # check user roboag
    getent_roboag="$(getent passwd $ROBO_USER_AG)"
    if [ "$getent_roboag" == "" ]; then
        # create user roboag
        if [ "$ROBO_CONFIG_IS_SERVER" != "" ]; then
            sudo adduser --no-create-home \
            --disabled-password --disabled-login \
            --gecos "RoboAG" --uid 2000  $ROBO_USER_AG
        else
            sudo adduser --gecos "RoboAG" --uid 2000  $ROBO_USER_AG
        fi
        if [ $? -ne 0 ]; then return -1; fi
    fi

    # add roboag to groups
    groups="$(cat /etc/group | grep ":.*$ROBO_USER_AG" | grep -o "^[^:]*")"
    for group in $groups_roboag; do
        if [ "$(echo $groups | grep "$group")" == "" ]; then
            sudo addgroup $ROBO_USER_AG "$group"
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

# 2021 01 16
function robo_config_user_check() {

    # init variables
    error_flag=0;
    user_roboag=""
    groups_guru="sudo plugdev dialout"
    groups_roboag="plugdev dialout"

    # initial output
    echo -n "users & groups    ... "

    # check user roboag
    getent_roboag="$(getent passwd $ROBO_USER_AG)"
    if [ "$getent_roboag" != "" ]; then
        user_roboag="1"
        groups_guru="${groups_guru} $ROBO_USER_AG"
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
        echo -n "  $ROBO_USER_AG does not exist"
    else
        groups="$(cat /etc/group | grep ":.*$ROBO_USER_AG" | grep -o "^[^:]*")"
        for group in $groups_roboag; do
            if [ "$(echo "$groups" | grep "$group")" == "" ]; then
                error_flag=1
                echo ""
                echo -n "  $ROBO_USER_AG is not in $group"
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

# 2021 01 16
function robo_config_user_restore() {

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "removes user/group $ROBO_USER_AG."
    if [ $? -ne 0 ]; then return -1; fi

    # init variables
    user_roboag=""

    # check user roboag
    if [ "$(getent passwd $ROBO_USER_AG)" == "" ]; then
        echo "user $ROBO_USER_AG does not exist"
    else
        # check samba db
        if [ "$(sudo pdbedit -L | grep $ROBO_USER_AG)" != "" ]; then
            echo "Error: samba user $ROBO_USER_AG still exists!"
            echo "  --> robo_setup_server_smbuser_restore"
            return -1
        fi

        # remove user
        sudo deluser --remove-home $ROBO_USER_AG
    fi

    # check group roboag
    if [ "$(getent group $ROBO_USER_AG)" == "" ]; then
        # remove user
        sudo delgroup $ROBO_USER_AG
    else
        echo "group $ROBO_USER_AG does not exist (anymore)"
    fi

    echo "done :-)"
}



#***************************[samba]*******************************************

# 2021 01 16
function robo_config_samba() {

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "add samba shares from roboag-server (roboag & robosax)."
    if [ $? -ne 0 ]; then return -1; fi

    # check mount points
    if [ ! -d "$ROBO_SHARE_ROBOAG" ]; then
        echo "creating mointpoint for roboag"
        echo "  mkdir $ROBO_SHARE_ROBOAG"
        sudo mkdir -p "$ROBO_SHARE_ROBOAG"
    fi
    if [ ! -d "$ROBO_SHARE_ROBOSAX" ]; then
        echo "creating mointpoint for robosax"
        echo "  mkdir $ROBO_SHARE_ROBOSAX"
        sudo mkdir -p "$ROBO_SHARE_ROBOSAX"
    fi

    # check credential file
    if [ -d "$ROBO_PATH_SHARED" ]; then
        smb_path="$ROBO_PATH_SHARED_DATA"
    else
        smb_path="$HOME"
    fi
    smb_file="${smb_path}.smbcredentials"
    if [ ! -f "$smb_file" ]; then
        echo "creating credential file for roboag"
        if [ ! -d "${smb_path}" ]; then
            echo "  mkdir ${smb_path}"
            sudo mkdir -p "${smb_path}"
        fi
        while true; do
            echo -n "  please type password: (not shown)"
            read -s password
            echo ""
            if [ "$password" == "" ]; then
                echo "    password should not be empty"
                continue;
            fi
            temp="$(_file_name_clean_string "$password")"
            if [ $? -ne 0 ] || [ "$password" != "$temp" ]; then
                echo "    password should not contain whitespaces or äüöß"
                echo "    only allow are (a-z, A-Z, 0-9, _.,;*+=#~())"
                unset temp password
                continue
            fi
            unset temp
            break
        done
        (
            echo "username=$ROBO_USER_AG"
            echo "password=$password"
        ) | sudo tee "$smb_file" > /dev/null
        sudo chmod 600 "$smb_file"
        unset password
    fi

    if [ "$(stat -c "%U" "$smb_file")" != "root" ]; then
        echo "changing owner of credential file to root"
        sudo chown root:root "$smb_file"
    fi
    if [ "$(stat -c "%a" "$smb_file")" != "600" ]; then
        echo "changing mode of credential file to 600"
        sudo chmod 600 "$smb_file"
    fi

    # check fstab
    FILENAME_CONFIG="/etc/fstab"
    AWK_STRING="
        # do not change current content of file
        { print \$0 }

        # Add RoboAG-Shares to $FILENAME_CONFIG
        END {
            print \"\"
            print \"# roboag shares on server\"
    "
    need_roboag=0
    temp="$(cat "$FILENAME_CONFIG" | grep "${ROBO_SHARE_ROBOAG:0: -1}")"
    if [ "$temp" == "" ]; then
        need_roboag=1
        temp="            "
        temp+="print \"//${ROBO_SERVER_IP}/roboag    "
        temp+="${ROBO_SHARE_ROBOAG:0: -1}    "
        temp+="cifs   "
        temp+="user,rw,credentials=$smb_file   "
        temp+=$'0   0"\n'
        AWK_STRING+="$temp"
    fi
    need_robosax=0
    temp="$(cat "$FILENAME_CONFIG" | grep "${ROBO_SHARE_ROBOSAX:0: -1}")"
    if [ "$temp" == "" ]; then
        need_robosax=1
        temp="            "
        temp+="print \"//${ROBO_SERVER_IP}/robosax   "
        temp+="${ROBO_SHARE_ROBOSAX:0: -1}   "
        temp+="cifs   "
        temp+="users,guest   "
        temp+=$'0   0"\n'
        AWK_STRING+="$temp"
    fi
    AWK_STRING+="
        }
    "

    if [ $need_roboag -eq 1 ] || [ $need_robosax -eq 1 ]; then
        echo "modifying $FILENAME_CONFIG"

        # apply awk string
        _config_file_modify "$FILENAME_CONFIG" "$AWK_STRING" "backup-once"
        if [ $? -ne 0 ]; then return -2; fi

        echo "running $ mount -a"
        sudo mount -a
    fi

    echo "done :-)"
}

# 2021 01 16
function robo_config_samba_check() {

    # init variables
    FILENAME_CONFIG="/etc/fstab"
    error_flag=0;

    # initial output
    echo -n "samba share       ... "

    # check mount points
    if [ ! -d "$ROBO_SHARE_ROBOAG" ]; then
        error_flag=1
        echo ""
        echo -n "  mountpoint roboag does not exist"
    else
        if [ -d "$ROBO_PATH_SHARED" ]; then
            smb_path="$ROBO_PATH_SHARED_DATA"
        else
            smb_path="$HOME"
        fi
        smb_file="${smb_path}.smbcredentials"

        if [ ! -f "$smb_file" ]; then
            error_flag=1
            echo ""
            echo -n "  $ROBO_USER_AG's credential file does not exist"
        else
            if [ "$(stat -c "%U" "$smb_file")" != "root" ]; then
                error_flag=1
                echo ""
                echo -n "  $ROBO_USER_AG's credential file not owned by root"
            fi
            if [ "$(stat -c "%a" "$smb_file")" != "600" ]; then
                error_flag=1
                echo ""
                echo -n "  $ROBO_USER_AG's credential file's mode is not 600"
            fi
        fi
        temp="$(cat "$FILENAME_CONFIG" | grep "${ROBO_SHARE_ROBOAG:0: -1}")"
        if [ "$temp" == "" ]; then
            error_flag=1
            echo ""
            echo -n "  roboag not defined in fstab"
        elif ! findmnt --noheadings "$ROBO_SHARE_ROBOAG" > /dev/null; then
            if [ $error_flag -eq 0 ]; then
                error_flag=2
            fi
            echo ""
            echo -n "  roboag not mounted"
        fi
    fi
    if [ ! -d "$ROBO_SHARE_ROBOSAX" ]; then
        error_flag=1
        echo ""
        echo -n "  mountpoint robosax does not exist"
    else
        temp="$(cat "$FILENAME_CONFIG" | grep "${ROBO_SHARE_ROBOSAX:0: -1}")"
        if [ "$temp" == "" ]; then
            error_flag=1
            echo ""
            echo -n "  robosax not defined in fstab"
        elif ! findmnt --noheadings "$ROBO_SHARE_ROBOSAX" > /dev/null; then
            if [ $error_flag -eq 0 ]; then
                error_flag=2
            fi
            echo ""
            echo -n "  robosax not mounted"
        fi
    fi

    if [ $error_flag -eq 0 ]; then
        echo "ok"
    elif [ $error_flag -eq 2 ]; then
        echo ""
        echo "  --> sudo mount -a"
    else
        echo ""
        echo "  --> robo_config_samba"
    fi
}

# 2021 01 16
function robo_config_samba_restore() {

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "removes the samba shares from server and restores fstab."
    if [ $? -ne 0 ]; then return -1; fi


    FILENAME_CONFIG="/etc/fstab"

    # removing share roboag
    if [ -d "$ROBO_SHARE_ROBOAG" ]; then
        if findmnt --noheadings "$ROBO_SHARE_ROBOAG" > /dev/null; then
            echo "unmount roboag"
            sudo umount "$ROBO_SHARE_ROBOAG"
        fi
        echo "removing mountpoint roboag"
        sudo rmdir "$ROBO_SHARE_ROBOAG"
    fi

    # removing credential file
    if [ -d "$ROBO_PATH_SHARED" ]; then
        smb_path="$ROBO_PATH_SHARED_DATA"
    else
        smb_path="$HOME"
    fi
    smb_file="${smb_path}.smbcredentials"
    if [ -f "$smb_file" ]; then
        error_flag=1
        echo "removing roboag's credential file "
        sudo rm "$smb_file"
    fi

    # removing share robosax
    if [ -d "$ROBO_SHARE_ROBOSAX" ]; then
        if findmnt --noheadings "$ROBO_SHARE_ROBOSAX" > /dev/null; then
            echo "unmount robosax"
            sudo umount "$ROBO_SHARE_ROBOSAX"
        fi
        echo "removing mountpoint robosax"
        sudo rmdir "$ROBO_SHARE_ROBOSAX"
    fi

    # check fstab
    FILENAME_CONFIG="/etc/fstab"
    has_roboag=0
    temp="$(cat "$FILENAME_CONFIG" | grep "${ROBO_SHARE_ROBOAG:0: -1}")"
    if [ "$temp" != "" ]; then has_roboag=1; fi

    has_robosax=0
    temp="$(cat "$FILENAME_CONFIG" | grep "${ROBO_SHARE_ROBOSAX:0: -1}")"
    if [ "$temp" != "" ]; then has_robosax=1; fi

    if [ $has_roboag -eq 1 ] || [ $has_robosax -eq 1 ]; then
        _config_file_restore "$FILENAME_CONFIG" "backup-once"
        if [ $? -ne 0 ]; then return -2; fi
        sudo mount -a
    fi

    echo "done :-)"
}
