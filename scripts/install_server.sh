#!/bin/bash

#***************************[apt-cacher-ng]***********************************
# 2019 11 20

function robo_config_aptcacher_server() {

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "sets the basic config of the apt-cacher-ng daemon (server only)."
    if [ $? -ne 0 ]; then return -1; fi

    # check current mode
    _robo_system_need_server "$FUNCNAME"
    if [ $? -ne 0 ]; then return -2; fi

    # Do the configuration
    FILENAME_CONFIG="/etc/apt-cacher-ng/acng.conf"

    AWK_STRING="
        # config apt-cacher
        \$0 ~ /BindAddress: / {
          print \"# roboag:\",\$0
          \$0 = \"BindAddress: localhost 192.168.2.20\";
        }
        \$0 ~ /^# Offlinemode/ {
          print \"# roboag:\",\$0
          \$0 = \"Offlinemode:1\";
        }

        { print \$0 }
    "

    _config_file_modify "$FILENAME_CONFIG" "$AWK_STRING" "backup-once"
}

function robo_config_aptcacher_server_restore() {

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "restores the old behaviour of the apt-cacher-ng daemon."
    if [ $? -ne 0 ]; then return -1; fi

    # Undo the configuration
    FILENAME_CONFIG="/etc/apt-cacher-ng/acng.conf"

    _config_file_restore "$FILENAME_CONFIG" "backup-once"
}
