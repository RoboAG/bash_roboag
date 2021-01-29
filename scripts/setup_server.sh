#!/bin/bash

#***************************[dependencies]************************************
# 2021 01 19

# the following must be sourced BEFORE this script
#     config.sh
#
# the following must be sourced AFTER this script



#***************************[apt-cacher-ng]***********************************
# 2021 01 03

alias robo_setup_server_aptcacher="server_config_aptcacher \
  ${_ROBO_SERVER_IP}"
alias robo_setup_server_aptcacher_check="server_config_aptcacher_check"
alias robo_setup_server_aptcacher_restore="server_config_aptcacher_restore"



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

# 2021 01 03
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
    if [ ! -d "$ROBO_PATH_ROBOAG" ]; then
        echo "Directory $ROBO_PATH_ROBOAG does not exist."
        return -3
    fi
    if [ "$ROBO_PATH_ROBOSAX" == "" ]; then
        echo "Variable ROBO_PATH_ROBOSAX is not set."
        return -3
    fi
    if [ ! -d "$ROBO_PATH_ROBOSAX" ]; then
        echo "Directory $ROBO_PATH_ROBOSAX does not exist."
        return -3
    fi

    # check internal network interface
    echo -n "checking "
    robo_setup_server_interfaces_check
    if [ $? -ne 0 ]; then return -3; fi

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
    _config_file_modify "$FILENAME_CONFIG" "$AWK_STRING" "backup-once"
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

# 2021 01 15
function robo_setup_server_samba_check() {

    # init variables
    error_flag=0;

    # initial output
    echo -n "samba server      ... "

    # check status of service
    config_check_service smbd "quiet" "enabled"
    if [ $? -ne 0 ]; then error_flag=1; fi

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

# 2021 01 03
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


    _config_file_restore "$FILENAME_CONFIG" "backup-once"

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
