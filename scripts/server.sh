#!/bin/bash

#***************************[dependencies]************************************
# 2021 01 19

# the following must be sourced BEFORE this script
#     config.sh
#
# the following must be sourced AFTER this script



#***************************[ssh]*********************************************

# 2022 02 11
alias robo_server_ssh_check="robo_server_ssh robo_system_wtf"

alias robo_server_ssh_update="_robo_server_ssh_update_repo; \
  _robo_server_ssh_update_system"
alias _robo_server_ssh_update_repo="robo_server_ssh \
  \"robo_repo_update\" tabs"
alias _robo_server_ssh_update_system="robo_server_ssh \
  \"robo_system_update\" tabs"

alias _robo_server_ssh_install="robo_server_ssh \
  \"robo_system_install\" tabs"

alias _robo_server_ssh_reboot="robo_server_ssh \
  \"sudo reboot\" tabs"
alias _robo_server_ssh_poweroff="robo_server_ssh \
  \"sudo poweroff\" tabs"

alias _robo_server_ssh_pololu="robo_server_ssh \
  \"pololu_repo_make\" tabs"
alias _robo_server_ssh_robolib="robo_server_ssh \
  \"robolib_repo_make\" tabs"


# 2023 01 13
function robo_server_ssh() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME [<script>] [<mode>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 0-1 parameters"
        echo "    [#1:]script to be executed on each computer"
        echo "    [#2:]mode (default \"\")"
        echo "         tabs     runs each ssh-session in a new terminal tab"
        echo "         windows  runs each ssh-session in a new terminal"
        echo "This function logs into each available computer."
        echo "If a bash script is passed, it will be executed."

        return
    fi

    # check parameter
    if [ $# -gt 2 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi
    param_script="$1"
    param_mode="$2"
    string_mode=""
    if [ "$param_mode" == "tabs" ]; then
        string_mode="--tabs"
    elif [ "$param_mode" == "windows" ]; then
        string_mode="--windows"
    elif [ "$param_mode" != "" ]; then
        echo "$FUNCNAME: Unknown <mode> \"$param_mode\"."
        return -2
    fi


    # check for server
    _robo_config_need_server "$FUNCNAME"

    # load list of current dhcp clients
    computers="$(robo_config_server_dhcp_show --none-verbose)"
    if [ $? -ne 0 ]; then return -2; fi

    # filter (raspi with open-roberta-lab)
    computers="$(echo "$computers" | grep -v orlab)"

    network_ssh --no-passwd --interactive $string_mode \
      "$computers" "$ROBO_USER_ADMIN" "$param_script"
}

# 2021 10 26
function robo_server_ssh_getconfigs() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs no parameters"
        echo "This function copies the current runtime files (e.g. modified"
        echo "config files) from each available computer."

        return
    fi

    # check parameter
    if [ $# -gt 0 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # check for server
    _robo_config_need_server "$FUNCNAME"
    if [ $? -ne 0 ]; then return -2; fi

    # load list of current dhcp clients
    computers="$(robo_config_server_dhcp_show --none-verbose)"
    if [ $? -ne 0 ]; then return -3; fi

    for computer in $computers; do
        echo "  copy from $computer"
        dest="${HOME}/config/${computer}"
        if [ ! -d "$dest" ]; then
            echo "    mkdir $dest"
            mkdir -p "$dest"
        fi
        chmod 755 --recursive "$dest"
        scp -r -p -q -o PasswordAuthentication=no \
          "guru@${computer}:/home/guru/config/${computer}" \
          "${HOME}/config/"
        chmod 755 --recursive "$dest"
    done

    echo "done :-)"
}



#***************************[client status]***********************************

# 2022 02 23
function robo_server_check_clients() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME [<flag>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 0-1 parameters"
        echo "    [#1:]flag for checking all clients (default \"\")"
        echo "         \"\"   checks only connected clients"
        echo "         all  checks all clients"
        echo "The last update date for system (apt), robo repos &"
        echo "installation will be checked."
        #echo "Before checking the clients, their config will be updated."

        return
    fi

    # check parameter
    if [ $# -gt 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi
    param_flag="$1"
    if [ "$param_flag" != "" ] && [ "$param_flag" != "all" ]; then
        echo "$FUNCNAME: Unknown <flag> \"$param_flag\"."
        return -2
    fi


    # check for server
    _robo_config_need_server "$FUNCNAME"
    if [ $? -ne 0 ]; then return -3; fi

    # load list of current dhcp clients
    if [ "$param_flag" == "" ]; then
        computers="$(robo_config_server_dhcp_show --none-verbose)"
        if [ $? -ne 0 ]; then return -4; fi
    else
        if [ ! -d "${HOME}/config/" ]; then return -5; fi
        computers="$(ls "${HOME}/config/")"
    fi

    # setup constants for comparing dates
    now_secs="$(date +"%s")"
    date_install_secs="$(_robo_system_convert_date_to_sec \
        "$ROBO_SYSTEM_INSTALL_DATE_CLIENT")"
    if [ $? -ne 0 ]; then return -6; fi
    date_uninstall_secs="$(_robo_system_convert_date_to_sec \
        "$ROBO_SYSTEM_UNINSTALL_DATE_CLIENT")"
    if [ $? -ne 0 ]; then return -7; fi

    (
        echo -e "*name* *install* *uninstall* *update* *repo*"
        for computer in $computers; do
            dest="${HOME}/config/${computer}/roboag/"
            if [ ! -d "$dest" ]; then continue; fi
            if [ -f "${dest}is_server.txt" ]; then continue; fi

            # name of client
            echo -n "$computer "

            # last install date
            temp="${dest}install.log"
            if [ ! -f "$temp" ]; then
                echo -n "--- "
            else
                date="$(cat "$temp" | grep " install client " | \
                tail -n 1 | awk "{print \$5}")"
                if [ $? -eq 0 ] && [ "$date" != "" ]; then
                    date_secs="$(_robo_system_convert_date_to_sec "$date")"
                    if [ $? -ne 0 ]; then date_secs=""; fi
                else
                    date_secs=""
                fi
                if [ "$date_secs" == "" ]; then
                    echo -n "err "
                else
                    if [ $date_install_secs -gt $date_secs ]; then
                        echo -n "$date "
                    else
                        echo -n "ok "
                    fi
                fi
            fi

            # last uninstall date
            temp="${dest}install.log"
            if [ ! -f "$temp" ]; then
                echo -n "--- "
            else
                date="$(cat "$temp" | grep " uninstall client " | \
                tail -n 1 | awk "{print \$5}")"
                if [ $? -eq 0 ] && [ "$date" != "" ]; then
                    date_secs="$(_robo_system_convert_date_to_sec "$date")"
                    if [ $? -ne 0 ]; then date_secs=""; fi
                else
                    date_secs=""
                fi
                if [ "$date_secs" == "" ]; then
                    echo -n "err "
                else
                    if [ $date_uninstall_secs -gt $date_secs ]; then
                        echo -n "$date "
                    else
                        echo -n "ok "
                    fi
                fi
            fi

            # last update date
            temp="${dest}update.log"
            if [ ! -f "$temp" ]; then
                echo -n "--- "
            else
                date="$(tail -n 1 "$temp" | awk "{print \$1}")"
                if [ $? -eq 0 ] && [ "$date" != "" ]; then
                    date_secs="$(_robo_system_convert_date_to_sec "$date")"
                    if [ $? -ne 0 ]; then date_secs=""; fi
                else
                    date_secs=""
                fi
                if [ "$date_secs" == "" ]; then
                    echo -n "err "
                else
                    diff_days="$(echo \
                      "($now_secs - $date_secs) / 60 / 60 / 24" | bc)"
                    if [ $diff_days -ge 6 ]; then
                        echo -n "$date "
                    else
                        echo -n "ok "
                    fi
                fi
            fi

            # last repo date
            temp="${dest}repo.log"
            if [ ! -f "$temp" ]; then
                echo -n "--- "
            else
                date="$(tail -n 1 "$temp" | awk "{print \$1}")"
                if [ $? -eq 0 ] && [ "$date" != "" ]; then
                    date_secs="$(_robo_system_convert_date_to_sec "$date")"
                    if [ $? -ne 0 ]; then date_secs=""; fi
                else
                    date_secs=""
                fi
                if [ "$date_secs" == "" ]; then
                    echo -n "err "
                else
                    diff_days="$(echo \
                      "($now_secs - $date_secs) / 60 / 60 / 24" | bc)"
                    if [ $diff_days -ge 6 ]; then
                        echo -n "$date "
                    else
                        echo -n "ok "
                    fi
                fi
            fi
            echo ""

        done
    ) | column -tx | sort

    echo ""
    echo "ssh commands:"
    echo "  $ _robo_server_ssh_update_repo"
    echo "  $ _robo_server_ssh_update_system"
    echo "  $ _robo_server_ssh_install"
    echo "  $ robo_server_ssh_getconfigs"
}



#***************************[user data]***************************************
# 2021 10 25
export ROBO_PATH_ROBOAG_USER="${ROBO_PATH_ROBOAG}/User/"

# 2021 11 07
function _robo_server_userdata_list() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs no parameters"
        echo "Lists all existing users on shared roboag data folder."
        echo "  ($ROBO_PATH_ROBOAG_USER)"

        return
    fi

    # check parameter
    if [ $# -gt 0 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # check if path exists
    if [ ! -d "$ROBO_PATH_ROBOAG_USER" ]; then
        echo "$FUNCNAME: folder for userdata does not exist"
        echo "  ($ROBO_PATH_ROBOAG_USER)"
        return -3
    fi

    # load list of users
    users="$(ls "$ROBO_PATH_ROBOAG_USER" | grep -v "^_")"

    # print list of users
    echo "$users"
}

# 2021 11 07
function robo_server_userdata_show() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME [<flag>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs no parameters"
        echo "Shows details of all existing users on shared data folder."
        echo "  ($ROBO_PATH_ROBOAG_USER)"

        return
    fi

    # check parameter
    if [ $# -gt 0 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # load list of users
    users="$(_robo_server_userdata_list)"
    if [ $? -ne 0 ]; then
        return -2;
    fi

    (
        echo -e "*name* *new* *count* *last*"
        for user in $users; do
            path="${ROBO_PATH_ROBOAG_USER}${user}/"
            if [ ! -d "$path" ]; then continue; fi

            # name of client
            echo -n "$user "

            # load top-level folders
            dirs="$(ls --file-type "$path" | grep "/")"

            # check new folder
            if echo "$dirs" | grep "^neu/$" > /dev/null 2>&1; then
                echo -n "ok "
            else
                echo -n "--- "
            fi

            # count folder
            count="$(echo "$dirs" | grep -v "^neu/$" | wc --lines)"
            echo -n "$count "

            # show latest folder
            last="$(echo "$dirs" | grep -E "^[0-9]{4}_" | sort | tail -n 1)"
            echo "$last"
        done
    ) | column -tx | sort

    echo ""
    echo "user data commands:"
    echo "  $ robo_server_userdata_show"
    echo "  $ robo_server_userdata_check"
    echo "  $ robo_server_userdata_fix"
    echo "  $ robo_server_userdata_add"
}

# 2021 11 01
function robo_server_userdata_add() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME <username>"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 1 parameters"
        echo "     #1: name of user to be added"
        echo "Adds the given user to the shared roboag data folder."
        echo "  ($ROBO_PATH_ROBOAG_USER)"

        return
    fi

    # check parameter
    if [ $# -ne 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    param_name="${1,,}"
    if [ "$param_name" == "" ]; then
        echo "$FUNCNAME: invalid username \"$param_name\""
        return -2
    fi

    # check for server
    _robo_config_need_server "$FUNCNAME"
    if [ $? -ne 0 ]; then return -3; fi

    # check if path exists
    if [ ! -d "$ROBO_PATH_ROBOAG_USER" ]; then
        echo "$FUNCNAME: folder for userdata does not exist"
        echo "  ($ROBO_PATH_ROBOAG_USER)"
        return -4
    fi

    # load list of users
    users="$(_robo_server_userdata_list)"
    if [ $? -ne 0 ]; then
        return -5;
    fi

    # check users
    if echo "${users,,}" | grep -E "^$param_name$" > /dev/null 2>&1; then
        echo "$FUNCNAME: user \"$param_name\" already exists"
        return -6
    fi

    echo "creating user \"$param_name\""
    echo "  (${ROBO_PATH_ROBOAG_USER}${param_name}/)"
    mkdir -p                "${ROBO_PATH_ROBOAG_USER}${param_name}/neu/"
    chmod 775               "${ROBO_PATH_ROBOAG_USER}${param_name}/neu/"
    sudo chown $USER:roboag "${ROBO_PATH_ROBOAG_USER}${param_name}/neu/"

    echo ""
    echo "done :-)"
}

# 2021 11 02
function robo_server_userdata_backup() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs no parameters"
        echo "Renames all \"new\" folders into current day."
        echo ""
        echo "  warning: function is work in progress"

        return
    fi

    # check parameter
    if [ $# -gt 0 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    echo "  warning: function is work in progress"
    echo ""

    # check for server
    _robo_config_need_server "$FUNCNAME"
    if [ $? -ne 0 ]; then return -2; fi

    # load list of users
    users="$(_robo_server_userdata_list)"
    if [ $? -ne 0 ]; then
        return -3;
    fi

    # get current day
    file_date="$(date +"%Y_%m_%d_")" # prepend "_" to mark folder

    # internal variable
    backup=0

    for user in $users; do
        path="${ROBO_PATH_ROBOAG_USER}${user}/"
        if [ ! -d "${path}neu/" ]; then continue; fi

        # check if there are any files
        result="$(find "${path}neu/" -type f)"
        if [ "$result" == "" ]; then continue; fi

        # inform
        echo "$user: update owner & permissions"

        # update owner of new folder and its subfolders and subfiles
        find "${path}neu/" -execdir sudo chown $USER: {} \;

        # update permissions of new folder and its subfolders and subfiles
        find "${path}neu/" -type d -execdir sudo chmod =775   {} \;
        find "${path}neu/" -type f -execdir sudo chmod u+rw,g+rw,o=r {} \;

        # check if backup already exists
        if [ -d "${path}${file_date}/" ]; then
            echo "$user: error backup already exists"
            return -4
        fi

        # move folder
        echo "$user: move new data"
        mv "${path}neu/" "${path}${file_date}/"

        # store succesfull backup
        backup=1
    done

    if [ $backup -eq 1 ]; then
        echo ""
        echo "running $ robo_server_userdata_fix"
        robo_server_userdata_fix
    fi

    echo ""
    echo "done :-)"
}

# 2021 11 07
function robo_server_userdata_fix() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs no parameters"
        echo "Adds the \"new\" folders, if necessary and sets the correct"
        echo "file/folder mode for each user."

        return
    fi

    # check parameter
    if [ $# -gt 0 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # check for server
    _robo_config_need_server "$FUNCNAME"
    if [ $? -ne 0 ]; then return -2; fi

    # load list of users
    users="$(_robo_server_userdata_list)"
    if [ $? -ne 0 ]; then
        return -3;
    fi

    for user in $users; do
        path="${ROBO_PATH_ROBOAG_USER}${user}/"
        if [ ! -d "$path" ]; then continue; fi

        # check if new folder exists
        if [ ! -d "${path}neu/" ]; then
            echo "$user: creating folder \"neu/\""
            mkdir -p "${path}neu/"
            if [ $? -ne 0 ]; then
                continue
            fi
            sudo chown $USER:roboag "${path}neu/"
            sudo chmod 775          "${path}neu/"
        fi

        # update owner of new folder
        current_user="$(stat -c "%U" "${path}neu/")"
        current_group="$(stat -c "%G" "${path}neu/")"
        if [ $? -ne 0 ] || [ "$current_user" != "$USER" ] || \
          [ "$current_group" != "roboag" ]; then
            echo "$user: update owner of \"neu/\""
            sudo chown $USER:roboag "${path}neu/"
        fi

        # update permissions of new folder
        current_mode="$(stat -c "%a" "${path}neu/")"
        if [ $? -ne 0 ] || [ "$current_mode" != "775" ]; then
            echo "$user: update permissions of \"neu/\""
            sudo chmod =775 "${path}neu/"
        fi

        # update owner of subfolders and subfiles
        result="$(find "${path}neu/" \! -user $USER -o \! -group roboag)"
        if [ "$result" != "" ]; then
            echo "$user: update owner of folders/files"
            find "${path}neu/" -execdir sudo chown $USER:roboag {} \;
        fi

        # update permissions of subfolders and subfiles
        result="$(find "${path}neu/" -type d \! -perm  775)"
        result+="$(find "${path}neu/" -type f \! -perm -664)"
        if [ "$result" != "" ]; then
            echo "$user: update permissions of folders/files"
            find "${path}neu/" -type d -execdir sudo chmod =775   {} \;
            find "${path}neu/" -type f -execdir sudo chmod u+rw,g+rw,o=r {} \;
        fi
    done
}

# 2021 11 01
function robo_server_userdata_check() {

    # init variables
    error_flag=0;

    # initial output
    echo -n "user data         ... "

    # load list of users
    users="$(_robo_server_userdata_list)"
    if [ $? -ne 0 ] || [ "$users" == "" ]; then
        users=""
        error_flag=1;
        echo ""
        echo "  no users exists"
        echo -n "    --> robo_server_userdata_add"
    fi

    for user in $users; do
        path="${ROBO_PATH_ROBOAG_USER}${user}/"
        if [ ! -d "$path" ]; then continue; fi

        # check if new folder exists
        if [ ! -d "${path}neu/" ]; then
            error_flag=2;
            echo ""
            echo -n "  $user: missing folder \"neu\""
            break
        fi

        # update owner of new folder
        current_user="$(stat -c "%U" "${path}neu/")"
        current_group="$(stat -c "%G" "${path}neu/")"
        if [ $? -ne 0 ] || [ "$current_user" != "$USER" ] || \
          [ "$current_group" != "roboag" ]; then
            error_flag=2;
            echo ""
            echo -n "  $user: wrong owner of \"neu\""
            break
        fi

        # update permissions of new folder
        current_mode="$(stat -c "%a" "${path}neu/")"
        if [ $? -ne 0 ] || [ "$current_mode" != "775" ]; then
            error_flag=2;
            echo ""
            echo -n "  $user: wrong permissions of \"neu\""
            break
        fi

        # update owner of subfolders and subfiles
        result="$(find "${path}neu/" \! -user $USER -o \! -group roboag)"
        if [ "$result" != "" ]; then
            error_flag=2;
            echo ""
            echo -n "  $user: wrong owner of folders/files"
            break
        fi

        # update permissions of subfolders and subfiles
        result="$(find "${path}neu/" -type d \! -perm  775)"
        result+="$(find "${path}neu/" -type f \! -perm -664)"
        if [ "$result" != "" ]; then
            error_flag=2;
            echo ""
            echo -n "  $user: wrong permissions of folders/files"
            break
        fi
    done
    if [ $error_flag -eq 2 ]; then
        echo ""
        echo -n "    --> robo_server_userdata_fix"
    fi

    # final result
    if [ $error_flag -eq 0 ]; then
        echo "ok"
    else
        echo ""
    fi
}

