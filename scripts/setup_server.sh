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
            print \"      addresses: [${_ROBO_SERVER_IP_MASK2}]\"
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

# 2021 01 02
function robo_setup_server_interfaces_check() {

    # Check the configuration
    FILENAME_CONFIG="/etc/netplan/01-roboag-setup-interfaces.yaml"

    # init variables
    error_flag=0;

    # initial output
    echo -n "interfaces ... "

    # check if eth_intern exists
    interfaces="$(ip link | grep -o "^[^ ]*")"
    interface_intern="$(echo "$interfaces" | grep "^eth_intern")"
    if [ "$interface_intern" == "" ]; then
        error_flag=1;
        echo ""
        echo -n "  missing interface eth_intern"
    elif [ "$(echo "$interface_intern" | grep NO-CARRIER)" == "" ]; then
        error_flag=1;
        echo ""
        echo -n "  missing carrier on eth_intern"
    fi

    # check config file
    if [ ! -e "${FILENAME_CONFIG}" ]; then
        error_flag=1
        echo ""
        echo -n "  missing config file ${PATH_CONFIG}"
    fi

    # final result
    if [ $error_flag -eq 0 ]; then
        echo "ok"
    else
        echo ""
    fi
}

# 2021 01 01
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



#***************************[dnsmasq]*****************************************
# 2021 01 01

function robo_setup_server_dnsmasq() {

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "sets the config of the internal network (eth_intern). \
Additionally installs dnsmasq."
    if [ $? -ne 0 ]; then return -1; fi

    # check current mode
    _robo_config_need_server "$FUNCNAME"
    if [ $? -ne 0 ]; then return -2; fi

    # Do the configuration
    PATH_CONFIG="/etc/dnsmasq.d/"
    PATH_LOCAL="${ROBO_PATH_SCRIPT}system_config/dnsmasq/"

    # check for network interfaces
    interfaces="$(ip --brief link | grep -o "^[^ ]*")"
    if [ "$(echo "$interfaces" | grep eth_intern)" == "" ]; then
        echo "Missing interface eth_intern."
        echo "Did you call robo_setup_server_interfaces ?"
        return -3
    fi

    # check & install dnsmasq
    _config_install_list "dnsmasq" quiet
    if [ $? -ne 0 ]; then return -4; fi

    # check for previous configurations
    if [ ! -d "$PATH_CONFIG" ]; then
        echo "Directory \"$PATH_CONFIG\" does not exist."
        echo "Is dnsmasq correctly installed ?"
        return -5
    fi

    # iterate over all config_files
    changed=""
    files="$(ls "$PATH_LOCAL")"
    for file in $files; do
        echo "checking ${PATH_CONFIG}${file}"
        if [ ! -e "${PATH_CONFIG}${file}" ]; then
            echo "    copy from ${PATH_LOCAL}$file"
            sudo cp "${PATH_LOCAL}$file" "${PATH_CONFIG}${file}"
            changed=1
        fi
    done

    # restart if necessary
    if [ "$changed" != "" ]; then
        echo "(re)starting service dnsmasq"
        sudo systemctl restart dnsmasq
    fi

    # enabling dnsmasq, if running
    if [ "$(systemctl is-active dnsmasq)" == "active" ] && \
      [ "$(systemctl is-enabled dnsmasq)" == "disabled" ]; then
        echo "enabling service dnsmasq"
        sudo systemctl enable dnsmasq
    fi

    echo "done :-)"
}

# 2021 01 01
function robo_setup_server_dnsmasq_check() {

    # Check the configuration
    PATH_CONFIG="/etc/dnsmasq.d/"
    PATH_LOCAL="${ROBO_PATH_SCRIPT}system_config/dnsmasq/"

    # init variables
    error_flag=0;

    # initial output
    echo -n "dnsmasq ... "

    # check status of service
    config_check_service dnsmasq "quiet" "enabled"
    if [ $? -ne 0 ]; then error_flag=1; fi

    # iterate over all config_files
    files="$(ls "$PATH_LOCAL")"
    for file in $files; do
        if [ ! -e "${PATH_CONFIG}${file}" ]; then
            error_flag=1
            echo ""
            echo -n "  missing file ${PATH_CONFIG}${file}"
        else
            temp="$(diff --brief "${PATH_LOCAL}$file" \
              "${PATH_CONFIG}${file}")"
            if [ "$temp" != "" ]; then
                error_flag=1
                echo ""
                echo -n "  modified file ${PATH_CONFIG}${file}"
            elif [ -L "${PATH_CONFIG}${file}" ]; then
                error_flag=1
                echo ""
                echo -n "  file ${PATH_CONFIG}${file} is a symlink"
            fi
        fi
    done

    # final result
    if [ $error_flag -eq 0 ]; then
        echo "ok"
    else
        echo ""
    fi
}

# 2021 01 01
function robo_setup_server_dnsmasq_restore() {

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "restores the old behaviour of the internal network. \
Additionally uninstalls dnsmasq."
    if [ $? -ne 0 ]; then return -1; fi

    # Undo the configuration
    PATH_CONFIG="/etc/dnsmasq.d/"
    PATH_LOCAL="${ROBO_PATH_SCRIPT}system_config/dnsmasq/"

    # stop & disable dnsmasq
    if [ "$(systemctl is-active dnsmasq)" == "active" ]; then
        echo "stopping service dnsmasq"
        sudo systemctl stop dnsmasq
    fi
    if [ "$(systemctl is-enabled dnsmasq)" == "enabled" ]; then
        echo "disabling service dnsmasq"
        sudo systemctl disable dnsmasq
    fi

    # remove files
    # iterate over all config_files
    changed=""
    files="$(ls "$PATH_LOCAL")"
    for file in $files; do
        echo "removing ${PATH_CONFIG}${file}"
        if [ ! -e "${PATH_CONFIG}${file}" ]; then
            echo "    ... already missing"
        elif [ -L "${PATH_CONFIG}${file}" ]; then
            sudo rm "${PATH_CONFIG}${file}"
        else
            temp="$(diff --brief "${PATH_LOCAL}$file" \
              "${PATH_CONFIG}${file}")"
            if [ "$temp" == "" ]; then
                sudo rm "${PATH_CONFIG}${file}"
            else
                echo "    ... modified file"
            fi
        fi
    done

    # uninstall dnsmasq
    echo "uninstall dnsmasq"
    sudo apt remove dnsmasq

    echo "done :-)"
}
