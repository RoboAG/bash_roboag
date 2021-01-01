#!/bin/bash

#***************************[apt-cacher-ng]***********************************
# 2020 10 12

alias robo_setup_server_aptcacher="server_config_aptcacher \
  ${_ROBO_SERVER_IP}"

alias robo_setup_server_aptcacher_restore="server_config_aptcacher_restore"



#***************************[network interfaces]******************************
# 2021 01 01

function robo_setup_server_interfaces() {

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "sets the network devices using netplan (server only)."
    if [ $? -ne 0 ]; then return -1; fi

    # check current mode
    _robo_config_need_server "$FUNCNAME"
    if [ $? -ne 0 ]; then return -2; fi

    # Do the configuration
    PATH_CONFIG="/etc/netplan/"
    FILENAME_CONFIG="${PATH_CONFIG}01-roboag-setup-interfaces.yaml"
    REGEX_MAC='^((([0-9a-fA-F]{2}):){5})([0-9a-fA-F]{2})$'

    # check for previous configurations
    if [ ! -d "$PATH_CONFIG" ]; then
        echo "Directory \"$PATH_CONFIG\" does not exist."
        echo "Is netplan installed ?"
        return -3
    fi
    temp="$(ls "$PATH_CONFIG" | grep -i "roboag")"
    if [ "$(echo "$temp" | wc -w)" -gt 0 ]; then
        echo "File \"$temp\" exist"
        echo "Is netplan already configured ?"
        return -4
    fi

    # display network devices
    echo "List of currently installed network devices:"
    ip -color -brief link show | grep --invert-match --ignore-case loopback

    # setup internal network
    while true; do
        echo ""
        echo "Setup INTERNAL network (will become eth_intern)"
        echo -n "Enter mac-address: "
        read mac

        if [[ "$mac" =~ $REGEX_MAC ]]; then
            break;
        fi
        echo "mac-address \"$mac\" is invalid."
    done
    mac_intern="$mac"

    # setup external network
    while true; do
        echo ""
        echo -n "Setup EXTERNAL network "
        echo "(skipped if empty; otherwise become eth_extern)"
        echo -n "Enter mac-address: "
        read mac

        if [ "$mac" == "" ] || [[ "$mac" =~ $REGEX_MAC ]]; then
            break;
        fi
        echo "mac-address \"$mac\" is invalid."
    done
    mac_extern="$mac"

    AWK_STRING="
        # setup eth_intern
        END {
            print \"network:\"
            print \"  version: 2\"
            print \"  renderer: networkd\"
            print \"  ethernets:\"
            print \"    eth_intern:\"
            print \"      dhcp4: no\"
            print \"      dhcp6: no\"
            print \"      optional: true\"
            print \"      addresses: [${_ROBO_SERVER_IP}/24]\"
            print \"      match:\"
            print \"        macaddress: ${mac_intern}\"
            print \"      set-name: eth_intern\"
        }
    "

    if [ "$mac_extern" != "" ]; then
        AWK_STRING+="
            # setup eth_extern
            END {
                print \"    eth_extern:\"
                print \"      dhcp4: yes\"
                print \"      optional: true\"
                print \"      match:\"
                print \"        macaddress: ${mac_extern}\"
                print \"      set-name: eth_extern\"
            }
        "
    fi

    _config_file_modify "$FILENAME_CONFIG" "$AWK_STRING" "create-config"
    if [ $? -ne 0 ]; then return -5; fi

    echo "After updating the settings, the server should be REBOOTED."
    echo "  $ sudo reboot"

    echo "done :-)"
}

function robo_setup_server_interfaces_restore() {

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "restores the old behaviour of the network devices."
    if [ $? -ne 0 ]; then return -1; fi

    # Undo the configuration
    FILENAME_CONFIG="/etc/netplan/01-roboag-setup-interfaces.yaml"

    _config_file_restore "$FILENAME_CONFIG" "create-config"
    if [ $? -ne 0 ]; then return -2; fi

    echo "After updating the settings, the server should be REBOOTED."
    echo "  $ sudo reboot"

    echo "done :-)"
}
