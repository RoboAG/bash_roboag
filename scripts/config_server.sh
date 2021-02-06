#!/bin/bash

#***************************[dependencies]************************************
# 2021 01 19

# the following must be sourced BEFORE this script
#     config.sh
#
# the following must be sourced AFTER this script



#***************************[server ip]***************************************
# 2021 01 19

# overwritting default ip from config.sh
if [ "$ROBO_CONFIG_IS_SERVER" != "" ]; then
    export ROBO_SERVER_IP="localhost"
fi



#***************************[server paths]************************************
# 2021 01 01

# setup server paths
export _ROBO_SERVER_PATH_DATA="/mnt/data/"
export _ROBO_SERVER_PATH_DATA2="/media/share/"


if [ "$ROBO_CONFIG_IS_SERVER" != "" ]; then

    # check if data-folder exists
    if [ -d "$_ROBO_SERVER_PATH_DATA" ]; then
        export ROBO_PATH_ROBOAG="${_ROBO_SERVER_PATH_DATA}roboag"
        export ROBO_PATH_ROBOSAX="${_ROBO_SERVER_PATH_DATA}robosax"
    elif [ -d "$_ROBO_SERVER_PATH_DATA2" ]; then
        export ROBO_PATH_ROBOAG="${_ROBO_SERVER_PATH_DATA2}roboag"
        export ROBO_PATH_ROBOSAX="${_ROBO_SERVER_PATH_DATA2}robosax"
    #else
        # echo "missing main data path"
    fi
fi



#***************************[internet sharing]*******************************

# 2021 01 01
function robo_config_server_internet_on() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME [<interface>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 0-1 parameters"
        echo "    [#1:]external interface for the connection"
        echo "         (defaults to eth_extern)"
        echo "This function enables the internet for the clients."

        return
    fi

    # check parameter
    if [ $# -gt 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    param_interface="eth_extern"
    if [ $# -gt 0 ]; then
        param_interface="$1"
    fi

    # check for server
    _robo_config_need_server "$FUNCNAME"

    # check interface
    result="$(ip -brief link show | grep --word-regexp "$param_interface")"
    if [ "$result" == "" ]; then
        echo "$FUNCNAME: Unknown interface \"$param_interface\""
        return -2
    fi

    # do the magic based on
    #   https://wiki.ubuntuusers.de/Router/ and
    #   https://help.ubuntu.com/community/Internet/ConnectionSharing

    sudo iptables -A FORWARD -o "$param_interface" -i eth_intern \
      -s "${_ROBO_SERVER_IP_MASK2}" -m conntrack --ctstate NEW -j ACCEPT
    sudo iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED \
      -j ACCEPT
    sudo iptables -t nat -F POSTROUTING
    sudo iptables -t nat -A POSTROUTING -o "$param_interface" -j MASQUERADE
    sudo sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"

    echo "done :-)"
}

# 2021 01 15
function robo_config_server_internet_check() {

    # Check the configuration
    FILENAME_CONFIG="/proc/sys/net/ipv4/ip_forward"

    # init variables
    error_flag=0;

    # initial output
    echo -n "internet sharing  ... "

    # check ipv4-forwarding
    content="$(cat "$FILENAME_CONFIG")"
    if [ "$content" == "1" ]; then
        echo "ON"
    elif [ "$content" == "0" ]; then
        echo "OFF"
    else
        error_flag=1
        echo ""
        echo "unknown status"
    fi

    # check iptables
    rules="$(sudo iptables --list-rules | grep -v "^-P ")"
    if [ "$rules" == "" ]; then
        if [ "$content" == "1" ]; then
            echo "  missing rules in iptable"
        fi
    else
        if [ "$content" == "0" ]; then
            echo "  having rules in iptables"
        else
            temp="$(echo "$rules" | grep "^-A" | grep "eth_intern")"
            if [ temp == "" ]; then
                echo "  missing rule for eth_intern"
            fi
        fi
    fi
}

# 2021 01 01
function robo_config_server_internet_off() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 0 parameters"
        echo "This function disables the internet for the clients."

        return
    fi

    # check parameter
    if [ $# -ne 0 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # check for server
    _robo_config_need_server "$FUNCNAME"

    # undo all ip forwarding
    sudo iptables --flush
    sudo sh -c "echo 0 > /proc/sys/net/ipv4/ip_forward"

    echo "done :-)"
}



#***************************[dhcp]*******************************************
# 2021 01 16

function robo_config_server_dhcp_check() {

    # Check the configuration
    FILENAME_LEASES="/var/lib/misc/dnsmasq.leases"
    FILENAME_DHCP="/etc/dnsmasq.d/dhcp_hosts.conf"

    # init variables
    error_flag=0;
    leases=""
    dhcp=""
    macs=""

    # initial output
    echo -n "dhcp server       ... "

    # check status of service
    config_check_service dnsmasq "quiet" "enabled"
    if [ $? -ne 0 ]; then error_flag=2; fi

    # check if lease file is there
    if [ ! -e "$FILENAME_LEASES" ]; then
        error_flag=1
        echo ""
        echo "  missing file of leases"
        echo -n "    (${FILENAME_LEASES})"
    else
        leases="$(cat "$FILENAME_LEASES")"
        macs="$(echo $leases | awk '{print $2}')"
    fi

    # check if dhcp file is there
    if [ ! -e "$FILENAME_DHCP" ]; then
        error_flag=1
        echo ""
        echo "  missing file of dhcp definitions"
        echo -n "    (${FILENAME_DHCP})"
    else
        dhcp="$(robo_config_server_dhcp_list verbose)"
    fi

    # iterate over all macs
    for mac in $macs; do
        if echo "$dhcp" | grep --quiet "$mac"; then
            continue;
        fi

        host="$(echo "$leases" | grep "$mac" | awk '{print $2 " " $3 " " $4}')"
        error_flag=1;
        echo ""
        echo -n "  $host"
    done

    # final result
    if [ $error_flag -eq 0 ]; then
        echo "ok"
    elif [ $error_flag -eq 2 ]; then
        echo ""
        echo "  --> sudo systemctl restart dnsmasq"
    else
        echo ""
    fi
}

# 2021 01 16
function robo_config_server_dhcp_show() {

    # Check the configuration
    FILENAME_LEASES="/var/lib/misc/dnsmasq.leases"

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME [<quiet>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 0-1 parameters"
        echo "    [#1:]flag for less verbose output"
        echo "         if not empty only hostnames or IPs will be printed"
        echo "This function shows all lately connected dhcp-clients."

        return
    fi

    # check parameter
    if [ $# -gt 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # check for verbose output
    if [ "$1" != "" ]; then
        AWK_STRING='{
            if ( $4 != "")
                { print $4 }
            else if ($3 != "")
                { print $3}
            else
                { printf "\n"}
        }';
    else
        AWK_STRING='{ print "  " $2 " " $3 " " $4}';
    fi

    # check for server
    _robo_config_need_server "$FUNCNAME"

    # check the file
    if [ ! -e $FILENAME_LEASES ]; then
        if [ "$1" == "" ]; then
            echo "error: file $FILENAME_LEASES does not exist"
        fi
        return -2
    fi

    # do the job
    cat "$FILENAME_LEASES" | awk "$AWK_STRING"
}


# 2021 01 01
function robo_config_server_dhcp_list() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME [<verbose>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 0-1 parameters"
        echo "    [#1:]flag for verbose output"
        echo "         if not empty, mac-addresses will also be printed"
        echo "This function lists all registered dhcp-clients."

        return
    fi

    # check parameter
    if [ $# -gt 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # check for verbose output
    if [ "$1" != "" ]; then
        AWK_STRING='{ print "  " $1 " " $3 " " $2}';
    else
        AWK_STRING='{ print "  " $3 " " $2}';
    fi

    # check for server
    _robo_config_need_server "$FUNCNAME"

    # Check the configuration
    PATH_CONFIG="/etc/dnsmasq.d/"

    # iterate over all config_files
    changed=""
    files="$(ls "$PATH_CONFIG")"
    for file in $files; do
        result="$(cat ${PATH_CONFIG}${file} \
          | grep "^[^#]*dhcp-host" \
          | sed 's/dhcp-host=//g' \
          | awk --field-separator=, "$AWK_STRING")"

        if [ "$result" != "" ]; then
            echo "${PATH_CONFIG}${file}"
            echo "$result"
        fi
    done
}

# 2021 01 16
function robo_config_server_dhcp_add() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME <mac> <ip> [<name>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 2-3 parameters"
        echo "     #1: mac adress"
        echo "     #2: ip adress"
        echo "    [#3:]hostname"
        echo "This function registers the given client at the dhcp server."

        return
    fi

    # check parameter
    if [ $# -lt 2 ] || [ $# -gt 3 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    param_mac="${1,,}"
    param_ip="$2"
    param_name="${3,,}"

    REGEX_MAC='^((([0-9a-fA-F]{2}):){5})([0-9a-fA-F]{2})$'
    if [[ ! "$param_mac" =~ $REGEX_MAC ]]; then
        echo "mac-address \"$param_mac\" is invalid"
        return -2
    fi
    REGEX_IP='^((([0-9]{1,3})\.){3})([0-9]{1,3})$'
    if [[ ! "$param_ip" =~ $REGEX_IP ]]; then
        echo "ip-address \"$param_ip\" is invalid"
        return -2
    fi

    # check for server
    _robo_config_need_server "$FUNCNAME"

    # Check the configuration
    PATH_CONFIG="/etc/dnsmasq.d/"
    FILENAME_CONFIG="${PATH_CONFIG}dhcp_hosts.conf"

    # check if mac or ip exist
    dhcp="$(robo_config_server_dhcp_list verbose)"
    if echo "$dhcp" | grep --quiet "$param_mac"; then
        echo "$FUNCNAME: mac $param_mac already exists."
        return -3
    fi
    if echo "$dhcp" | grep --quiet "$param_ip"; then
        echo "$FUNCNAME: ip $param_ip already exists."
        return -3
    fi

    # check if config-file needs to be created
    _robo_config_server_dhcp_create_hostfile
    if [ $? -ne 0 ]; then return -4; fi

    # create entry for config file
    if [ "$param_name" != "" ]; then
        entry="dhcp-host=${param_mac},${param_name},${param_ip},12h"
    else
        entry="dhcp-host=${param_mac},${param_ip},12h"
    fi

    echo "$entry" | sudo tee -a "$FILENAME_CONFIG" > /dev/null

    # store backup
    config_file_backup "$FILENAME_CONFIG" "dhcp"

    echo "done :-)"
}

# 2021 01 03
function robo_config_server_dhcp_edit() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs no parameters"
        echo "This function edits host list of the dhcp server."

        return
    fi

    # check parameter
    if [ $# -ne 0 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # check for server
    _robo_config_need_server "$FUNCNAME"

    # Check the configuration
    PATH_CONFIG="/etc/dnsmasq.d/"
    FILENAME_CONFIG="${PATH_CONFIG}dhcp_hosts.conf"

    # check if config-file needs to be created
    _robo_config_server_dhcp_create_hostfile
    if [ $? -ne 0 ]; then return -2; fi

    # edit file (and store backups)
    _config_file_modify_full "$FILENAME_CONFIG" "dhcp" "" "normal" ""
}

# 2021 01 03
function _robo_config_server_dhcp_create_hostfile() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs no parameters"
        echo "This function creates the host list of the dhcp server,"
        echo "if necessary"

        return
    fi

    # check parameter
    if [ $# -ne 0 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    PATH_CONFIG="/etc/dnsmasq.d/"
    FILENAME_CONFIG="${PATH_CONFIG}dhcp_hosts.conf"

    # check if config-file needs to be created
    if [ ! -d "$PATH_CONFIG" ]; then
        echo "$FUNCNAME: Error"
        echo "Directory \"PATH_CONFIG\" does not exist."
        echo "Is dnsmasq installed ?"
        return -2
    fi

    if [ ! -f "$FILENAME_CONFIG" ]; then
        echo "creating $FILENAME_CONFIG"
        (
            echo "# Setting up dhcp-adresses of local machines"
            echo "#"
            echo "# This file is modified by config-scripts."
            echo "#   https://github.com/RoboAG/bash_roboag"
            echo "#"
            echo "# robo_config_server_dhcp_add"
            echo "# robo_config_server_dhcp_list"
            echo "# robo_config_server_dhcp_edit"
            echo ""
        ) | sudo tee "$FILENAME_CONFIG" > /dev/null
    fi
}



#***************************[intranet]****************************************
# 2021 01 29

function robo_config_server_intranet_check() {

    # initial output
    echo -n "intranet on server ... "

    # init variables
    error_flag=0;

    # load current ports used in intranet
    port_list="$(netstat -tnl | grep -E -o "${_ROBO_SERVER_IP}:[0-9]+")"

    # check dhcp
    if config_check_service dnsmasq > /dev/null; then
        if ! echo "$port_list" | grep ":53"   > /dev/null; then
            error_flag=1
            echo ""
            echo "  no dns-server --> sudo systemctl restart dnsmasq"
        fi
    fi

    # check apache
    if config_check_service apache2 > /dev/null; then
        if ! echo "$port_list" | grep ":80"   > /dev/null; then
            error_flag=1
            echo ""
            echo "  no apache2 --> sudo systemctl restart apache2"
        fi
    fi

    # check apt-cacher
    if config_check_service apt-cacher-ng > /dev/null; then
        if ! echo "$port_list" | grep ":3142" > /dev/null; then
            error_flag=1
            echo ""
            echo "  no apt-cacher --> sudo systemctl restart apt-cacher-ng"
        fi
    fi

    # check apt-cacher
    if config_check_service smbd > /dev/null; then
        if ! echo "$port_list" | grep ":445"  > /dev/null; then
            error_flag=1
            echo ""
            echo "  no samba      --> sudo systemctl restart smbd"
        fi
    fi

    # final result
    if [ $error_flag -eq 0 ]; then
        echo "ok"
    else
        echo ""
    fi
}
