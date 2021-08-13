#!/bin/bash

#***************************[dependencies]************************************
# 2021 01 19

# the following must be sourced BEFORE this script
#     config.sh
#
# the following must be sourced AFTER this script



#***************************[ssh]*********************************************

# 2021 08 13
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

# 2021 08 13 - only temp
alias _robo_server_ssh_mount="robo_server_ssh \
  \"sudo mount /media/roboag/ \&\& ls /media/roboag/\" tabs"

# 2021 01 28
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

    network_ssh --no-passwd --interactive $string_mode \
      "$computers" "$ROBO_USER_ADMIN" "$param_script"
}

# 2021 02 06
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

    # load list of current dhcp clients
    computers="$(robo_config_server_dhcp_show --none-verbose)"
    if [ $? -ne 0 ]; then return -2; fi

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

# 2021 08 12
function robo_server_check_clients() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME [<flag>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 0-1 parameters"
        echo "    [#1:]flag for checking all clients (default \"\")"
        echo "         \"\" checks only connected clients"
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

    # load list of current dhcp clients
    if [ "$param_flag" == "" ]; then
        computers="$(robo_config_server_dhcp_show --none-verbose)"
        if [ $? -ne 0 ]; then return -2; fi
    else
        if [ ! -d "${HOME}/config/" ]; then return -2; fi
        computers="$(ls "${HOME}/config/")"
    fi


    now_secs="$(date +"%s")"
    date_update_client="$(date \
      --date="$ROBO_SYSTEM_INSTALL_DATE_CLIENT" +"%s")"

    (
        echo -e "*name* *install* *update* *repo*"
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
                date="$(cat "$temp" | grep -v server | tail -n 1 | \
                  awk "{print \$1}")"
                date_en="$(echo "$date" | \
                  awk -F "." "{print \$2\"/\"\$1\"/\"\$3}")"
                if [ "$date" == "" ] || [ "$date_en" == "//" ]; then
                    echo -n "err "
                else
                    date_secs="$(date --date="$date_en" +"%s")"
                    if [ $date_update_client -ge $date_secs ]; then
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
                date_en="$(echo "$date" | \
                  awk -F "." "{print \$2\"/\"\$1\"/\"\$3}")"
                if [ "$date" == "" ] || [ "$date_en" == "//" ]; then
                    echo -n "err "
                else
                    date_secs="$(date --date="$date_en" +"%s")"
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
                date_en="$(echo "$date" | \
                  awk -F "." "{print \$2\"/\"\$1\"/\"\$3}")"
                if [ "$date" == "" ] || [ "$date_en" == "//" ]; then
                    echo -n "err "
                else
                    date_secs="$(date --date="$date_en" +"%s")"
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
