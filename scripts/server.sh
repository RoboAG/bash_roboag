#!/bin/bash

#***************************[dependencies]************************************
# 2021 01 19

# the following must be sourced BEFORE this script
#     config.sh
#
# the following must be sourced AFTER this script



#***************************[ssh]*********************************************

# 2021 01 19
alias robo_server_ssh_check="robo_server_ssh robo_system_wtf"
alias robo_server_ssh_update="robo_server_ssh \
  \"config_update_system; robo_repo_update\""

# 2021 01 19
function robo_server_ssh() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME [<script>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 0-1 parameters"
        echo "    [#1:]script to be executed on each computer"
        echo "This function logs into each available computer."
        echo "If a bash script is passed, it will be executed."

        return
    fi

    # check parameter
    if [ $# -gt 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # check for server
    _robo_config_need_server "$FUNCNAME"

    # load list of current dhcp clients
    computers="$(robo_config_server_dhcp_show --none-verbose)"
    if [ $? -ne 0 ]; then return -2; fi

    network_ssh --no-passwd --interactive \
      "$computers" "$ROBO_USER_ADMIN" "$@"
}