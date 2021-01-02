#!/bin/bash

#***************************[server config]***********************************
# 2019 11 20

export _ROBO_SERVER_IP="192.168.2.20"
export _ROBO_SERVER_IP_MASK="255.255.255.0"
export _ROBO_SERVER_IP_MASK2="${_ROBO_SERVER_IP}/24"

if [ "$ROBO_CONFIG_IS_SERVER" == "" ]; then
    export ROBO_SERVER_IP="$_ROBO_SERVER_IP"
else
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

function robo_config_server_internet_check() {

    # Check the configuration
    FILENAME_CONFIG="/proc/sys/net/ipv4/ip_forward"

    # init variables
    error_flag=0;

    # initial output
    echo -n "internet sharing ... "

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
# 2021 01 02

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
    echo -n "dhcp ... "

    # check status of service
    config_check_service dnsmasq "quiet" "enabled"
    if [ $? -ne 0 ]; then error_flag=1; fi

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
        if echo "$dhcp" | grep "$mac" > /dev/null; then
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
    else
        echo ""
    fi
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
