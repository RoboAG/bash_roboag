#!/bin/bash

#***************************[dependencies]************************************
# 2021 01 19

# the following must be sourced BEFORE this script
#     config.sh
#
# the following must be sourced AFTER this script



#***************************[apt-cacher-ng]***********************************
# 2023 11 18

function robo_setup_server_aptcacher_check() {
    server_config_aptcacher_check
}



#***************************[apt proxy]***************************************

# 2023 09 23
function robo_setup_server_aptproxy() {

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "adds the additional apt repos to the apt proxy (squid-deb-proxy)."
    if [ $? -ne 0 ]; then return -1; fi

    # check current mode
    _robo_config_need_server "$FUNCNAME"
    if [ $? -ne 0 ]; then return -2; fi

    # Do the configuration
    FILENAME_CONFIG="95-roboag"
    CONFIG_SRC="${ROBO_PATH_SCRIPT}system_config/squid-deb-proxy/"
    CONFIG_DST="/etc/squid-deb-proxy/mirror-dstdomain.acl.d/"
    FILE_SRC="${CONFIG_SRC}${FILENAME_CONFIG}"
    FILE_DST="${CONFIG_DST}${FILENAME_CONFIG}"

    # check if config path exists
    if [ ! -d "$CONFIG_DST" ]; then
        echo "Directory \"$CONFIG_DST\" does not exist."
        echo "Is squid-deb-proxy installed ?"
        return -3
    fi

    # check if config file exists
    if [ ! -f "$FILE_DST" ]; then
        echo "Adding config file for roboag."
        echo "  ($FILE_DST)"

        sudo cp "$FILE_SRC" "$FILE_DST"
    else
        # check if config file changed
        if ! diff --brief "$FILE_SRC" "$FILE_DST" > /dev/null; then
            echo "Updating config file for roboag."
            echo "  ($FILE_DST)"
            diff "$FILE_SRC" "$FILE_DST"

            sudo cp "$FILE_SRC" "$FILE_DST"
        else
            echo "Config file is up to date - nothing todo."
        fi
    fi

    echo "done :-)"
}

# 2023 09 23
function robo_setup_server_aptproxy_check() {
    # init variables
    error_flag=0;

    # initial output
    echo -n "apt proxy server  ... "

    # Do the configuration
    FILENAME_CONFIG="95-roboag"
    CONFIG_SRC="${ROBO_PATH_SCRIPT}system_config/squid-deb-proxy/"
    CONFIG_DST="/etc/squid-deb-proxy/mirror-dstdomain.acl.d/"
    FILE_SRC="${CONFIG_SRC}${FILENAME_CONFIG}"
    FILE_DST="${CONFIG_DST}${FILENAME_CONFIG}"

    # check if config file exists
    if [ ! -f "$FILE_DST" ]; then
        error_flag=1;
        echo ""
        echo -n "  missing config file"
    else
        # check if config file changed
        if ! diff --brief "$FILE_SRC" "$FILE_DST" > /dev/null; then
            error_flag=1;
            echo ""
            echo -n "  config file changed"
        fi
    fi

    # final result
    if [ $error_flag -eq 0 ]; then
        echo "ok"
    else
        echo ""
        echo "  --> robo_setup_server_aptproxy"
    fi
}

# 2023 09 23
function robo_setup_server_aptproxy_restore() {

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "removes the additional apt repos to the apt proxy (squid-deb-proxy)."
    if [ $? -ne 0 ]; then return -1; fi

    # check current mode
    _robo_config_need_server "$FUNCNAME"
    if [ $? -ne 0 ]; then return -2; fi

    # Do the configuration
    FILENAME_CONFIG="95-roboag"
    CONFIG_DST="/etc/squid-deb-proxy/mirror-dstdomain.acl.d/"
    FILE_DST="${CONFIG_DST}${FILENAME_CONFIG}"

    # check if config path exists
    if [ ! -d "$CONFIG_DST" ]; then
        echo "Directory \"$CONFIG_DST\" does not exist."
        echo "Is squid-deb-proxy installed ?"
        return -3
    fi

    # check if config file exists
    if [ ! -f "$FILE_DST" ]; then
        echo "Removing config file."
        echo "  ($FILE_DST)"

        sudo rm "$FILE_DST"
    else
        echo "Config file does not exist - nothing todo."
    fi

    echo "done :-)"
}



#***************************[network interfaces]******************************
# 2021 01 12

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
            # networkd is faster on startup, but dnsmasq will have problems ...
            # therefore, using NetworkManager as renderer!
            #print \"  renderer: networkd\"
            print \"  renderer: NetworkManager\"
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

    echo ""
    echo "After updating the settings, the server should be REBOOTED."
    echo "  $ sudo reboot"
    echo ""

    echo "done :-)"
}

# 2021 01 15
function robo_setup_server_interfaces_check() {

    # Check the configuration
    FILENAME_CONFIG="/etc/netplan/01-roboag-setup-interfaces.yaml"

    # init variables
    error_flag=0;

    # initial output
    echo -n "server interfaces ... "

    # check if eth_intern exists
    interfaces_intern="$(ip --brief link | grep "^eth_intern")"
    interfaces_carrier="$(ip link | grep -o "^[^ ]*" | grep NO-CARRIER)"
    if [ "$interfaces_intern" == "" ]; then
        error_flag=1;
        echo ""
        echo -n "  missing interface eth_intern"
    elif [ "$interfaces_carrier" != "" ]; then
        error_flag=1;
        echo ""
        echo -n "  missing carrier on eth_intern"
    fi

    # check config file
    if [ ! -e "${FILENAME_CONFIG}" ]; then
        error_flag=1
        echo ""
        echo -n "  missing config file ${FILENAME_CONFIG}"
    fi

    # final result
    if [ $error_flag -eq 0 ]; then
        echo "ok"
    else
        echo ""
    fi
}

# 2021 01 03
function robo_setup_server_interfaces_restore() {

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "restores the old behaviour of the network devices."
    if [ $? -ne 0 ]; then return -1; fi

    # Undo the configuration
    FILENAME_CONFIG="/etc/netplan/01-roboag-setup-interfaces.yaml"

    _config_file_restore "$FILENAME_CONFIG" "create-config"
    if [ $? -ne 0 ]; then return -2; fi

    echo ""
    echo "After updating the settings, the server should be REBOOTED."
    echo "  $ sudo reboot"
    echo ""

    echo "done :-)"
}



#***************************[dnsmasq]*****************************************
# 2021 01 23

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

    # check internal network interface
    echo -n "checking "
    robo_setup_server_interfaces_check
    if [ $? -ne 0 ]; then return -3; fi

    # check & install dnsmasq
    _config_install_list "dnsmasq resolvconf" quiet
    if [ $? -ne 0 ]; then return -4; fi

    # check if config path exists
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

    # restart & enable dnsmasq, if necessary
    if [ "$changed" != "" ] || \
      [ "$(systemctl is-active dnsmasq)" != "active" ]; then
        echo "(re)starting service dnsmasq"
        sudo systemctl restart dnsmasq
        if [ $? -ne 0 ]; then return -6; fi
    fi
    if [ "$(systemctl is-active dnsmasq)" == "active" ] && \
      [ "$(systemctl is-enabled dnsmasq)" == "disabled" ]; then
        echo "enabling service dnsmasq"
        sudo systemctl enable dnsmasq
        if [ $? -ne 0 ]; then return -7; fi
    fi

    # restart & enable systemd-resolved, if necessary
    if [ "$(systemctl is-active systemd-resolved)" != "active" ]; then
        echo "starting service systemd-resolved"
        sudo systemctl restart systemd-resolved
    fi
    if [ "$(systemctl is-active systemd-resolved)" == "active" ] && \
      [ "$(systemctl is-enabled systemd-resolved)" == "disabled" ]; then
        echo "enabling service systemd-resolved"
        sudo systemctl enable systemd-resolved
    fi

    echo "done :-)"
}

# 2021 01 15
function robo_setup_server_dnsmasq_check() {

    # Check the configuration
    PATH_CONFIG="/etc/dnsmasq.d/"
    PATH_LOCAL="${ROBO_PATH_SCRIPT}system_config/dnsmasq/"

    # init variables
    error_flag=0;

    # initial output
    echo -n "dnsmasq on server ... "

    # check status of service
    config_check_service dnsmasq "quiet" "enabled"
    if [ $? -ne 0 ]; then error_flag=2; fi
    config_check_service systemd-resolved "quiet" "enabled"
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
    elif [ $error_flag -eq 2 ]; then
        echo ""
        echo "  --> sudo systemctl restart dnsmasq"
    else
        echo ""
        echo "  --> robo_setup_server_dnsmasq"
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



#***************************[samba]*******************************************

# 2024 08 09
function robo_setup_server_samba() {

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "sets the config of samba-server on internal network (eth_intern)."
    if [ $? -ne 0 ]; then return -1; fi

    # check current mode
    _robo_config_need_server "$FUNCNAME"
    if [ $? -ne 0 ]; then return -2; fi

    # check if paths to shares are set correctly
    if [ "$ROBO_PATH_ROBOAG" == "" ]; then
        echo "Variable ROBO_PATH_ROBOAG is not set."
        return -3
    fi
    if [ "$ROBO_PATH_ROBOSAX" == "" ]; then
        echo "Variable ROBO_PATH_ROBOSAX is not set."
        return -3
    fi

    # create shared folders if necessary
    if [ ! -d "$ROBO_PATH_ROBOAG" ]; then
        echo "creating roboag data folder"
        echo "  ($ROBO_PATH_ROBOAG)"
        sudo mkdir -p "$ROBO_PATH_ROBOAG"
        sudo chown $USER:$USER "$ROBO_PATH_ROBOAG"
        if [ $? -ne 0 ]; then return -3; fi
    fi
    if [ ! -d "$ROBO_PATH_ROBOSAX" ]; then
        echo "creating robosax data folder"
        echo "  ($ROBO_PATH_ROBOSAX)"
        sudo mkdir -p "$ROBO_PATH_ROBOSAX"
        sudo chown $USER:$USER "$ROBO_PATH_ROBOSAX"
        if [ $? -ne 0 ]; then return -3; fi
    fi

    # check internal network interface
    echo -n "checking "
    robo_setup_server_interfaces_check
    if [ $? -ne 0 ]; then return -4; fi

    ## check & install samba server
    #_config_install_list "samba" quiet
    #if [ $? -ne 0 ]; then return -4; fi

    # Do the configuration
    FILENAME_CONFIG="/etc/samba/smb.conf"

    # check if config file exists
    if [ ! -e "$FILENAME_CONFIG" ]; then
        echo "File \"$FILENAME_CONFIG\" does not exist."
        echo "Is the samba server correctly installed ?"
        return -5
    fi

    # init awk string
    AWK_STRING="$(_robo_setup_server_samba_getawk)"
    if [ $? -ne 0 ]; then return -6; fi

    # apply awk string
    _config_file_modify_full "$FILENAME_CONFIG" "samba/server" "$AWK_STRING" "backup-once"
    if [ $? -ne 0 ]; then return -7; fi

    echo "(re)starting service smbd"
    sudo systemctl restart smbd

    # enabling smbd, if running
    if [ "$(systemctl is-active smbd)" == "active" ] && \
      [ "$(systemctl is-enabled smbd)" == "disabled" ]; then
        echo "enabling service smbd"
        sudo systemctl enable smbd
    fi

    echo ""
    echo "Details can be shown here:"
    echo "  $ testparm --suppress-prompt"
    echo ""

    echo "done :-)"
}

# 2024 08 08
function robo_setup_server_samba_check() {

    # init variables
    error_flag=0;

    # initial output
    echo -n "samba server      ... "

    # check status of service
    config_check_service smbd "quiet" "enabled"
    if [ $? -ne 0 ]; then error_flag=1; fi

    # check folders
    if [ ! -d "$ROBO_PATH_ROBOAG" ]; then
        error_flag=1
        echo ""
        echo -n "  missing roboag folder"
    fi
    if [ ! -d "$ROBO_PATH_ROBOSAX" ]; then
        error_flag=1
        echo ""
        echo -n "  missing robosax folder"
    fi

    # check for shares
    AWK_STRING="$(_robo_setup_server_samba_getawk)"
    if [ $? -ne 0 ]; then
        error_flag=1
        echo ""
        echo -n "  error from _robo_setup_server_samba_getawk"
    fi

    FILENAME_CONFIG="/etc/samba/smb.conf"
    content="$(cat "$FILENAME_CONFIG")"
    error_subflag=0;

    if [ "$(echo "$content" | grep "\[roboag\]")" == "" ]; then
        error_subflag=1;
        error_flag=1
        echo ""
        echo -n "  missing share [roboag]"
    fi
    if [ "$(echo "$content" | grep "\[robosax\]")" == "" ]; then
        error_subflag=1;
        error_flag=1
        echo ""
        echo -n "  missing share [robosax]"
    fi

    # check awk-script
    if [ $error_subflag -eq 0 ]; then
        result="$(echo "$content" | awk "$AWK_STRING")"
        if [ "$result" != "$content" ]; then
            error_flag=1
            echo ""
            echo -n "  missing config"
        fi
    fi

    # final result
    if [ $error_flag -eq 0 ]; then
        echo "ok"
    else
        echo ""
    fi
}

# 2024 08 09
function robo_setup_server_samba_restore() {

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "restores the old behaviour of the samba server."
    if [ $? -ne 0 ]; then return -1; fi

    # stop & disable samba deamon
    if [ "$(systemctl is-active smbd)" == "active" ]; then
        echo "stopping service smbd"
        sudo systemctl stop smbd
    fi
    if [ "$(systemctl is-enabled smbd)" == "enabled" ]; then
        echo "disabling service smbd"
        sudo systemctl disable smbd
    fi

    # Undo the configuration
    FILENAME_CONFIG="/etc/samba/smb.conf"


    _config_file_restore_full "$FILENAME_CONFIG" "samba/server" "backup-once"

    echo "done :-)"
}

# 2021 01 03
function _robo_setup_server_samba_getawk() {

    FILENAME_CONFIG="/etc/samba/smb.conf"

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs no parameters"
        echo "This function returns the awk-script needed to modify the"
        echo "samba config file $FILENAME_CONFIG."

        return
    fi

    # check parameter
    if [ $# -ne 0 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # check if config file exists
    if [ ! -e "$FILENAME_CONFIG" ]; then
        echo "$FUNCNAME: Error"
        echo "File \"$FILENAME_CONFIG\" does not exist."
        return -2
    fi

    # init awk string
    echo "
        # server name
        \$0 ~ /^[^;#]*server string = %h/ {
          print \"# [EDIT]: \",\$0
          \$0 = \"   server string = Samba-Share der RoboAG\"
        }

        # interface
        \$0 ~ /interfaces =/ && \$0 ~ /^;/ {
          print \"# [EDIT]: \",\$0
          \$0 = \"   interfaces = 127.0.0.0/8 eth_intern\"
        }
        \$0 ~ /bind interfaces only =/ && \$0 ~ /^;/ {
          print \"# [EDIT]: \",\$0
          \$0 = \"   bind interfaces only = yes\"
        }

        { print \$0 }
    "

    # check if share "roboag" and "robosax" exists
    content="$(cat "$FILENAME_CONFIG")"

    if [ "$(echo "$content" | grep "\[roboag\]")" == "" ]; then
        echo "
            # Add RoboAG-Share (internal)
            END {
                print \"\"
                print \"[roboag]\"
                print \"  path = $ROBO_PATH_ROBOAG\"
                print \"  comment = Interne Freigabe der RoboAG\"
                print \"  writeable = yes\"
                print \"\"
            }
        "
    fi
    if [ "$(echo "$content" | grep "\[robosax\]")" == "" ]; then
        echo "
            # Add RoboSAX-Share (public)
            END {
                print \"\"
                print \"[robosax]\"
                print \"  path = $ROBO_PATH_ROBOSAX\"
                print \"  comment = Freigabe des RoboSAX\"
                print \"  guest ok = yes\"
                print \"  writeable = no\"
                print \"\"
            }
        "
    fi
}



#***************************[samba user]**************************************
# 2021 01 16

function robo_setup_server_smbuser() {

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "adds $ROBO_USER_AG as samba user."
    if [ $? -ne 0 ]; then return -1; fi

    # check current mode
    _robo_config_need_server "$FUNCNAME"
    if [ $? -ne 0 ]; then return -2; fi

    # check if samba user already exists
    if [ "$(sudo pdbedit -L | grep $ROBO_USER_AG)" != "" ]; then
        echo "Error: samba user $ROBO_USER_AG already exists!"
        return -3
    fi

    # check if regular user exists
    groups="$(id $ROBO_USER_AG 2> /dev/null)"
    if [ $? -ne 0 ]; then
        echo "regular user $ROBO_USER_AG does not exist"
        return -4
    fi

    # create user
    sudo smbpasswd -a $ROBO_USER_AG

    echo "done :-)"
}

# 2021 01 15
function robo_setup_server_smbuser_check() {

    # init variables
    error_flag=0;

    # initial output
    echo -n "samba user        ... "

    # check if samba user already exists
    if [ "$(sudo pdbedit -L | grep $ROBO_USER_AG)" == "" ]; then
        error_flag=1;
        echo ""
        echo -n "  $ROBO_USER_AG does not exist"
    fi

    # final result
    if [ $error_flag -eq 0 ]; then
        echo "ok"
    else
        echo ""
        echo "  --> robo_setup_server_smbuser"
    fi
}

# 2021 01 24
function robo_setup_server_smbuser_restore() {

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "removes user $ROBO_USER_AG from samba server."
    if [ $? -ne 0 ]; then return -1; fi

    sudo smbpasswd -x $ROBO_USER_AG

    echo "done :-)"
}



#***************************[rebind repos]***********************************

# 2024 08 09
function robo_setup_server_rebind_repos() {

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "rebinds the repos to the samba share."
    if [ $? -ne 0 ]; then return -1; fi

    # check current mode
    _robo_config_need_server "$FUNCNAME"
    if [ $? -ne 0 ]; then return -2; fi

    # check if folders exist
    if [ ! -d "$ROBO_PATH_OPT_REPOS" ]; then
        echo "Folder \"$ROBO_PATH_OPT_REPOS\" does not exist."
        return -3
    fi
    if [ "$ROBO_PATH_ROBOAG" == "" ]; then
        echo "Variable ROBO_PATH_ROBOAG is not set."
        return -3
    fi

    # check/create data folder
    if [ ! -d "$ROBO_PATH_ROBOAG" ]; then
        echo "creating roboag data folder"
        echo "  ($ROBO_PATH_ROBOAG)"
        sudo mkdir -p "$ROBO_PATH_ROBOAG"
        sudo chown $USER:$USER "$ROBO_PATH_ROBOAG"
        if [ $? -ne 0 ]; then return -3; fi
    fi

    # create mount point
    REBIND_SRC="${ROBO_PATH_OPT_REPOS::-1}"
    REBIND_DST="${ROBO_PATH_ROBOAG}/Repos"

    if [ ! -d "$REBIND_DST" ]; then
        echo "creating mount point"
        echo "  ($REBIND_DST)"
        sudo mkdir "$REBIND_DST"
    fi

    # Do the configuration
    FILENAME_CONFIG="/etc/fstab"

    # check config file
    if [ ! -e "$FILENAME_CONFIG" ]; then
        echo "File \"$FILENAME_CONFIG\" does not exist."
        return -4
    fi

    content="$(cat "$FILENAME_CONFIG")"
    if echo "$content" | grep --quiet -E "^ *${REBIND_SRC}"; then
        echo "Source of repos is already part of fstab."
        echo "  $REBIND_SRC"
        return -4
    fi
    if echo "$content" | grep --quiet -E "^ *[^ ]* +${REBIND_DST}"; then
        echo "Destination of repos is already part of fstab."
        echo "  $REBIND_DST"
        return -4
    fi

    # add rebind to fstab
    echo "adding rebind of repos to $FILENAME_CONFIG"
    AWK_STRING="
        # keep file as it was
        { print \$0 }

        # add rebind at the end of file
        END {
            print \"\"
            print \"# rebind roboag repos\"
            print \"$REBIND_SRC   $REBIND_DST   none   bind   0   0\"
        }
    "

    _config_file_modify_full "$FILENAME_CONFIG" "fstab/rebind" "$AWK_STRING" "backup-once"
    if [ $? -ne 0 ]; then return -5; fi

    # mount rebind
    sudo mount "$REBIND_DST"

    echo "done :-)"
}

# 2024 08 08
function robo_setup_server_rebind_repos_check() {

    # init variables
    error_flag=0;

    # initial output
    echo -n "rebind repos      ... "

    # check folders
    if [ ! -d "$ROBO_PATH_OPT_REPOS" ]; then
        error_flag=1
        echo ""
        echo -n "  missing repos folder"
    fi
    if [ "$ROBO_PATH_ROBOAG" == "" ]; then
        error_flag=1
        echo ""
        echo -n "  \$ROBO_PATH_ROBOAG not set"
    else
        if [ ! -d "$ROBO_PATH_ROBOAG" ]; then
        error_flag=1
        echo ""
        echo -n "  missing roboag data folder"
        fi
    fi

    # check config file
    REBIND_SRC="${ROBO_PATH_OPT_REPOS::-1}"
    REBIND_DST="${ROBO_PATH_ROBOAG}/Repos"
    FILENAME_CONFIG="/etc/fstab"


    content="$(cat "$FILENAME_CONFIG")"
    if ! echo "$content" | grep --quiet -E "^ *${REBIND_SRC}"; then
        error_flag=1
        echo ""
        echo "  missing fstab entry"
        echo -n "  -> robo_setup_server_rebind_repos"
    elif ! echo "$content" | grep --quiet -E "^ *[^ ]* +${REBIND_DST}"; then
        error_flag=1
        echo ""
        echo "  missing fstab entry"
        echo -n "  -> robo_setup_server_rebind_repos"
    fi

    if [ $error_flag -eq 0 ]; then
        if ! mount | grep --quiet " $REBIND_DST "; then
            error_flag=1
            echo ""
            echo "  repos are not mounted"
            echo -n "  -> sudo mount -a"
        fi
    fi

    # final result
    if [ $error_flag -eq 0 ]; then
        echo "ok"
    else
        echo ""
    fi
}

# 2024 08 09
function robo_setup_server_rebind_repos_restore() {

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "removes the rebind of the roboag repos from fstab."
    if [ $? -ne 0 ]; then return -1; fi


    # unmount rebind
    if mount | grep --quiet " $REBIND_DST "; then
        error_flag=1
        echo "unmount repos"
        sudo umount "$REBIND_DST"
        if [ $? -ne 0 ]; then return -2; fi
    fi

    # Undo the configuration
    FILENAME_CONFIG="/etc/samba/smb.conf"

    _config_file_restore_full "$FILENAME_CONFIG" "fstab/rebind" "backup-once"
    if [ $? -ne 0 ]; then return -3; fi

    echo "remove mount point"
    sudo rmdir $REBIND_DST

    echo "done :-)"
}



#***************************[cron]*********************************************

# 2021 01 24
function _robo_setup_server_cron_text() {

    # Do the configuration
    FILE_LOCAL="${ROBO_PATH_SCRIPT}system_config/cron/root"

    # read config file
    content="$(cat "$FILE_LOCAL")"

    # extract services
    services="$(echo "$content" | grep "@reboot" | grep -E -o "restart[^&]+")"
    services="${services:8}"
    # check services
    for service in $services; do
        if ! systemctl is-enabled $service >> /dev/null 2>&1; then
            content="$(echo "$content" | sed "$ s/ $service / /")"
        fi
    done

    current_content="$(sudo crontab -u root -l 2> /dev/null)"
    if [ $? -eq 0 ] && [ "$content" == "$current_content" ]; then
        # nothing todo
        return
    fi

    echo "$content"
}

# 2021 01 24
function robo_setup_server_cron() {

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "adds a cronjob to restart server deamons."
    if [ $? -ne 0 ]; then return -1; fi

    # check current mode
    _robo_config_need_server "$FUNCNAME"
    if [ $? -ne 0 ]; then return -2; fi

    # get content
    content="$(_robo_setup_server_cron_text)"
    if [ $? -ne 0 ]; then return -3; fi
    if [ "$content" == "" ]; then
        echo "nothing todo ;-)"
        return
    fi

    # check if config file exists
    temp_filename="/tmp/root"
    old_content="$(sudo crontab -u root -l 2> /dev/null)"
    if [ "$old_content" != "" ]; then
        need_edit=0
        last_backup_file="$(_config_file_return_last "$temp_filename" \
          "${CONFIG_PATH_BACKUP}crontab/")"
        if [ "$last_backup_file" == "" ] || \
          [ ! -e "$last_backup_file" ]; then
            need_edit=1
        elif [ "$old_content" != "$(cat "$last_backup_file")" ]; then
            need_edit=1
        fi
        if [ $need_edit -eq 1 ]; then
            echo "crontab of root user already set ..."
            echo "  $ sudo crontab -u root -e"
            return -1
        fi

        echo "updating crontab of root user"
    else
        echo "creating crontab of root user"
    fi

    echo "$content" | tee "$temp_filename" | sudo crontab -u root -
    config_file_backup "$temp_filename" "crontab"
    rm "$temp_filename"

    echo "done :-)"
}

# 2021 01 24
function robo_setup_server_cron_check() {

    # init variables
    error_flag=0;

    # initial output
    echo -n "cronjob on server ... "

    # get content
    content="$(_robo_setup_server_cron_text)"
    if [ $? -ne 0 ]; then
        echo "error"
        return
    fi
    if [ "$content" == "" ]; then
        echo "ok"
        return
    fi

    # final result
    echo ""
    echo "  --> robo_setup_server_cron"
}

# 2021 01 24
function robo_setup_server_cron_restore() {

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "removes the cronjob restarting server deamons."
    if [ $? -ne 0 ]; then return -1; fi

    # check current mode
    _robo_config_need_server "$FUNCNAME"
    if [ $? -ne 0 ]; then return -2; fi

    # check if config file exists
    temp_filename="/tmp/root"
    old_content="$(sudo crontab -u root -l 2> /dev/null)"
    if [ "$old_content" == "" ]; then
        echo "nothing todo ;-)"
        return
    fi

    last_backup_file="$(_config_file_return_last "$temp_filename" \
      "${CONFIG_PATH_BACKUP}crontab/")"
    if [ "$last_backup_file" == "" ] || \
      [ ! -e "$last_backup_file" ]; then
        echo "no backup file of crontab of root ..."
        echo "  $ sudo crontab -u root -e"
        return -3
    fi

    if [ "$old_content" != "$(cat "$last_backup_file")" ]; then
        echo "last backup file differs from crontab of root ..."
        echo "  $ cat \"$last_backup_file\""
        echo "  $ sudo crontab -u root -e"
        return -4
    fi

    echo "removing crontab of root"
    sudo crontab -u root -r

    echo "done :-)"
}



#***************************[apache]******************************************

# 2021 02 06
export ROBO_SERVER_HTML_PATH="/var/www/html/"
export ROBO_SERVER_KEYS_LIST="packages.microsoft.gpg"


# 2023 01 20
function robo_setup_server_apache() {

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "sets up the apache2 server."
    if [ $? -ne 0 ]; then return -1; fi

    # check current mode
    _robo_config_need_server "$FUNCNAME"
    if [ $? -ne 0 ]; then return -2; fi

    # modify listener (only localhost & internal port)
    FILENAME_CONFIG="/etc/apache2/ports.conf"
    AWK_STRING="$(_robo_setup_server_apache_getawk)"
    if [ $? -ne 0 ]; then return -3; fi

    if [ "$AWK_STRING" != "" ]; then
        _config_file_modify_full "$FILENAME_CONFIG" "apache" "$AWK_STRING"
        if [ $? -ne 0 ]; then return -4; fi
    fi

    # check available sites
    FILENAME_SIMPLE="001-roboag.conf"
    tmp="/etc/apache2/"
    FILENAME_CONFIG="${tmp}sites-available/${FILENAME_SIMPLE}"
    FILENAME_CONFIG2="${tmp}sites-enabled/${FILENAME_SIMPLE}"
    FILE_LOCAL="${ROBO_PATH_SCRIPT}system_config/apache/${FILENAME_SIMPLE}"

    if [ ! -e "$FILENAME_CONFIG" ]; then
        echo "create virtual host for roboag"
        echo "  ($FILENAME_CONFIG)"
        sudo cp "$FILE_LOCAL" "$FILENAME_CONFIG"
    elif [ "$(cat "$FILE_LOCAL")" != "$(cat "$FILENAME_CONFIG")" ]; then
        echo "updating virtual host for roboag"
        echo "  ($FILENAME_CONFIG)"
        config_file_backup "$FILENAME_CONFIG" "apache"
        sudo cp "$FILE_LOCAL" "$FILENAME_CONFIG"
    fi
    if [ ! -e "$FILENAME_CONFIG2" ]; then
        echo "enable virtual host for roboag"
        echo "  ($FILENAME_CONFIG2)"
        sudo ln -s "$FILENAME_CONFIG" "$FILENAME_CONFIG2"
    fi

    # disable default site
    FILENAME_CONFIG="/etc/apache2/sites-enabled/000-default.conf"
    if [ -L "$FILENAME_CONFIG" ]; then
        echo "disable default virtual host"
        echo "  ($FILENAME_CONFIG)"
        sudo rm "$FILENAME_CONFIG"
    fi

    # create folder structure
    if [ -d "$ROBO_SERVER_HTML_PATH" ]; then
        # check for index.html
        if [ -f "${ROBO_SERVER_HTML_PATH}index.html" ]; then
            echo "moving index.html to folder default/"
            sudo mkdir -p "${ROBO_SERVER_HTML_PATH}default"
            sudo mv "${ROBO_SERVER_HTML_PATH}index.html" \
              "${ROBO_SERVER_HTML_PATH}default/index.html"
        fi
        # create main robo folder
        folders="roboag robosax doc keys orlab"
        for folder in $folders; do
            path="${ROBO_SERVER_HTML_PATH}${folder}/"
            if [ ! -d "${path}" ]; then
                echo "create folder $folder/"
                echo "  ($path)"
                sudo mkdir "$path"
                sudo chown $USER:$USER "$path"
            fi
        done
        # create subfolders
        tmp="${ROBO_SERVER_HTML_PATH}doc/robolib"
        if [ ! -L "$tmp" ]; then
            echo "linking doc/robolib"
            sudo ln -s "$REPO_ROBOAG_DOC_ROBOLIB" "$tmp"
        fi
        tmp="${ROBO_SERVER_HTML_PATH}doc/punkte"
        if [ ! -L "$tmp" ]; then
            echo "linking doc/punkte"
            sudo ln -s "$REPO_ROBOSAX_DOC_PUNKTE" "$tmp"
        fi
    fi

    # copy shared keys
    key_src="/usr/share/keyrings/";
    key_dest="${ROBO_SERVER_HTML_PATH}keys/";

    if [ -d "$key_dest" ]; then
        for key in $ROBO_SERVER_KEYS_LIST; do
            if [ ! -e "${key_src}${key}" ]; then continue; fi
            if [ ! -e "${key_dest}${key}" ]; then
                echo "  copy key \"$key\""
            else
                tmp="$(diff --brief "${key_src}${key}" "${key_dest}${key}")"
                if [ "$tmp" == "" ]; then
                    continue;
                fi
                echo "  update key \"$key\""
            fi
            sudo cp "${key_src}${key}" "${key_dest}${key}"
            sudo chmod 644 "${key_dest}${key}"
        done
    fi

    echo "restarting apache"
    sudo systemctl restart apache2

    echo "done :-)"
}

# 2021 02 06
function robo_setup_server_apache_check() {

    # init variables
    error_flag=0;

    # initial output
    echo -n "apache server     ... "

    # check status of service
    config_check_service apache2 "quiet" "enabled"
    if [ $? -ne 0 ]; then error_flag=1; fi

    # check for shares
    AWK_STRING="$(_robo_setup_server_apache_getawk)"
    if [ $? -ne 0 ]; then
        error_flag=1
        echo ""
        echo -n "  error from _robo_setup_server_apache_getawk"
    elif [ "$AWK_STRING" != "" ]; then
        error_flag=1
        echo ""
        echo -n "  ports.conf can be modified"
    fi

    # check available sites
    FILENAME_SIMPLE="001-roboag.conf"
    tmp="/etc/apache2/"
    FILENAME_CONFIG="${tmp}sites-available/${FILENAME_SIMPLE}"
    FILENAME_CONFIG2="${tmp}sites-enabled/${FILENAME_SIMPLE}"
    FILE_LOCAL="${ROBO_PATH_SCRIPT}system_config/apache/${FILENAME_SIMPLE}"

    if [ ! -e "$FILENAME_CONFIG" ]; then
        error_flag=1
        echo ""
        echo -n "  missing virtual host for roboag"
    elif [ "$(cat "$FILE_LOCAL")" != "$(cat "$FILENAME_CONFIG")" ]; then
        error_flag=1
        echo ""
        echo -n "  virtual host needs to be updated"
    elif [ ! -e "$FILENAME_CONFIG2" ]; then
        error_flag=1
        echo ""
        echo -n "  virtual host is disabled"
    fi

    # disable default site
    FILENAME_CONFIG="/etc/apache2/sites-enabled/000-default.conf"
    if [ -L "$FILENAME_CONFIG" ]; then
        error_flag=1
        echo ""
        echo -n "  default virtual host is still enabled"
    fi

    # check for shared keys
    key_src="/usr/share/keyrings/";
    key_dest="${ROBO_SERVER_HTML_PATH}keys/";

    if [ -d "$key_dest" ]; then
        for key in $ROBO_SERVER_KEYS_LIST; do
            if [ ! -e "${key_src}${key}" ]; then continue; fi
            if [ ! -e "${key_dest}${key}" ]; then
                error_flag=1
                echo ""
                echo -n "  key \"$key\" is not copied yet"
            else
                tmp="$(diff --brief "${key_src}${key}" "${key_dest}${key}")"
                if [ "$tmp" != "" ]; then
                    error_flag=1
                    echo ""
                    echo -n "  key \"$key\" has changed"
                fi
            fi
        done
    fi

    # final result
    if [ $error_flag -eq 0 ]; then
        echo "ok"
    else
        echo ""
        echo "  --> robo_setup_server_apache"
    fi
}

# 2023 02 14
function robo_setup_server_apache_restore() {

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "removes config of apache server."
    if [ $? -ne 0 ]; then return -1; fi

    # check available sites
    FILENAME_SIMPLE="001-roboag.conf"
    tmp="/etc/apache2/"
    FILENAME_CONFIG="${tmp}sites-available/${FILENAME_SIMPLE}"
    FILENAME_CONFIG2="${tmp}sites-enabled/${FILENAME_SIMPLE}"

    if [ -L "$FILENAME_CONFIG2" ]; then
        echo "disable virtual host for roboag"
        echo "  ($FILENAME_CONFIG2)"
        sudo rm "$FILENAME_CONFIG2"
    fi
    if [ -e "$FILENAME_CONFIG" ]; then
        echo "removing virtual host for roboag"
        echo "  ($FILENAME_CONFIG)"
        sudo rm "$FILENAME_CONFIG"
    fi

    # enable default site
    FILENAME_SIMPLE="000-default.conf"
    tmp="/etc/apache2/"
    FILENAME_CONFIG="${tmp}sites-available/${FILENAME_SIMPLE}"
    FILENAME_CONFIG2="${tmp}sites-enabled/${FILENAME_SIMPLE}"
    if [ ! -L "$FILENAME_CONFIG2" ]; then
        echo "enabling default virtual host"
        echo "  ($FILENAME_CONFIG)"
        sudo ln -s "$FILENAME_CONFIG" "$FILENAME_CONFIG2"
    fi

    # remove shared keys
    key_path="${ROBO_SERVER_HTML_PATH}keys/";

    if [ -d "$key_path" ]; then
        for key in $ROBO_SERVER_KEYS_LIST; do
            if [ ! -e "${key_path}${key}" ]; then continue; fi
            echo "  removing key \"$key\""
            sudo rm "${key_path}${key}"
        done
    fi

    # remove folder structure
    if [ -d "$ROBO_SERVER_HTML_PATH" ]; then
        # check for index.html
        if [ ! -f "${ROBO_SERVER_HTML_PATH}index.html" ] && \
          [ -f "${ROBO_SERVER_HTML_PATH}default/index.html" ]; then
            echo "moving index.html from folder default/"
            sudo mv "${ROBO_SERVER_HTML_PATH}default/index.html" \
              "${ROBO_SERVER_HTML_PATH}index.html"
        fi
        # remove subfolders
        tmp="${ROBO_SERVER_HTML_PATH}doc/robolib"
        if [ -L "$tmp" ]; then
            echo "removing doc/robolib"
            sudo rm "$tmp"
        fi
        tmp="${ROBO_SERVER_HTML_PATH}doc/punkte"
        if [ -L "$tmp" ]; then
            echo "removing doc/punkte"
            sudo rm "$tmp"
        fi
        # remove main robo folders if empty
        folders="roboag robosax doc keys orlab"
        for folder in $folders; do
            path="${ROBO_SERVER_HTML_PATH}${folder}/"
            if [ -d "${path}" ]; then
                sudo rmdir "$path" 2> /dev/null
                if [ $# -ne 0 ]; then
                    echo "folder $folder is not empty"
                else
                    echo "removing folder $folder"
                fi
                echo "  ($path)"
            fi
        done
    fi

    # restore config of ports
    FILENAME_CONFIG="/etc/apache2/ports.conf"
    _config_file_restore_full "$FILENAME_CONFIG" "apache"

    # restart apache
    echo "restarting apache"
    sudo systemctl restart apache2

    echo "done :-)"
}

# 2023 02 14
function _robo_setup_server_apache_getawk() {

    FILENAME_CONFIG="/etc/apache2/ports.conf"

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs no parameters"
        echo "This function returns the awk-script needed to modify the"
        echo "apache2 config file $FILENAME_CONFIG."

        return
    fi

    # check parameter
    if [ $# -ne 0 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # check if config file exists
    if [ ! -e "$FILENAME_CONFIG" ]; then
        echo "$FUNCNAME: Error"
        echo "File \"$FILENAME_CONFIG\" does not exist."
        return -2
    fi

    # return awk string
    AWK_STRING="
        # search for Listen directive
        \$0 ~ /^[^#]*(LISTEN|Listen) :?[0-9]+$/ {
          # print old content with preceeding '# [EDIT]: '
          print \"# [EDIT]: \",\$0
          # remove optional colon
          sub( /:/ , \"\")
          # change port 80 to 8080
          sub( /80/ , \"8080\")
          # store current modified line in buffer
          tmp = \$0
          # add localhost to buffer
          sub( /(LISTEN|Listen) / , \"&localhost:\", tmp )
          # print buffer
          print tmp
          # add server ip to current line
          sub( /(LISTEN|Listen) / , \"&$_ROBO_SERVER_IP:\")
        }

        # print current line
        { print \$0 }
    "

    content="$(cat $FILENAME_CONFIG)"
    if [ "$content" != "$(echo "$content" | awk "$AWK_STRING")" ]; then
        echo "$AWK_STRING"
    fi
}



#***************************[open roberta connector]**************************
# 2023 01 20

function robo_setup_server_orlab_connector () {

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "builds the connector for open-roberta-lab."
    if [ $? -ne 0 ]; then return -1; fi

    # check current mode
    _robo_config_need_server "$FUNCNAME"
    if [ $? -ne 0 ]; then return -2; fi

    # Do the configuration
    PATH_PATCH="${ROBO_PATH_SCRIPT}system_config/open_roberta/connector.patch"
    PATH_REPO="${REPO_ROBOAG_ROBERTA_CONNECTOR[0]}"
    PATH_TMP="/tmp/orlab/"
    PATH_ZIP="${PATH_TMP}zip/"
    PATH_HTML="${ROBO_SERVER_HTML_PATH}orlab/"

    SRC_JAR_="${PATH_TMP}target/${ROBO_ORLAB_CONNECTOR_NAME}"
    SRC_LIBS="${PATH_TMP}target/libs/"
    SRC_RSC="${PATH_TMP}resources/"
    RSC_SUBDIRS="linux megaavr"

    ZIP_JAR="${PATH_ZIP}${ROBO_ORLAB_CONNECTOR_NAME}.jar"
    ZIP_LIBS="${PATH_ZIP}libs/"
    ZIP_RSC="${PATH_ZIP}resources/"

    # check if repo exists
    if [ ! -d "$PATH_REPO" ]; then
        echo "clone repo of open-roberta-connector"
        git_clone_roboag_roberta_connector
        if [ $? -ne 0 ]; then return -3; fi
    fi

    # create temp folder
    echo "create temp folder"
    echo "  ($PATH_TMP)"
    if [ -d "$PATH_TMP" ]; then
        rm -rf "$PATH_TMP"
        if [ $? -ne 0 ]; then return -4; fi
    fi
    mkdir -p "$PATH_TMP"

    # copy git-repo
    echo "copy git-repo"
    echo "  ($PATH_REPO)"
    rsync --archive --exclude=".git" "$PATH_REPO" "$PATH_TMP"
    if [ $? -ne 0 ]; then return -5; fi

    # switch to folder & apply patch
    echo "apply patch"
    echo "  ($PATH_PATCH)"
    cd "$PATH_TMP"
    git apply "$PATH_PATCH"
    if [ $? -ne 0 ]; then return -6; fi

    # build java application
    echo "build connector"
    mvn clean install
    if [ $? -ne 0 ]; then return -7; fi
    if [ ! -e "${SRC_JAR_}"*.jar ]; then
        echo "cannot find jar file"
        echo "  (${SRC_JAR_}*.jar)"
        return -7
    fi

    # copy everything together
    echo "copy & zip files"
    echo "  ($PATH_ZIP)"
    mkdir -p "$PATH_ZIP"
    if [ $? -ne 0 ]; then return -8; fi
    echo "    1. *.jar"
    cp "${SRC_JAR_}"*.jar "$ZIP_JAR"
    if [ $? -ne 0 ]; then return -8; fi
    echo "    2. libs/"
    mkdir -p "$ZIP_LIBS"
    rsync --archive --delete "$SRC_LIBS" "$ZIP_LIBS"
    if [ $? -ne 0 ]; then return -8; fi
    echo "    3. resources/"
    for subdir in $RSC_SUBDIRS; do
        echo "        ${subdir}/"
        mkdir -p "${ZIP_RSC}${subdir}/"
        rsync --archive --delete \
          "${SRC_RSC}${subdir}/" "${ZIP_RSC}${subdir}/"
        if [ $? -ne 0 ]; then return -8; fi
    done
    echo "    4. zip everything"
    cd "$PATH_ZIP"
    zip -r "${ROBO_ORLAB_CONNECTOR_NAME}" *

    # copy zip to apache server
    if [ ! -d "$PATH_HTML" ]; then
        echo "create apache folder"
        echo "  ($PATH_HTML)"
        sudo mkdir "$PATH_HTML"
        if [ $? -ne 0 ]; then return -9; fi
        sudo chown $USER:$USER "$PATH_HTML"
        if [ $? -ne 0 ]; then return -9; fi
    fi
    echo "copy zip into apache folder"
    cp "${PATH_ZIP}${ROBO_ORLAB_CONNECTOR_NAME}.zip" "$PATH_HTML"
    if [ $? -ne 0 ]; then return -9; fi

    echo "remove temp folder"
    #rm -r "$PATH_TMP"
    if [ $? -ne 0 ]; then return -10; fi

    echo "done :-)"
}
