#!/bin/bash

#***************************[check mode of operation]*************************
# 2019 11 20

function _robo_check_user_roboag() {

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "checks if user RoboAG exists."
    if [ $? -ne 0 ]; then return -1; fi

    # check if user exists
    temp="$(cat /etc/passwd | grep -i roboag)"
    if [ "temp" != "" ]; then
        echo "user roboag already exists"
        read answer

        if [ "$answer" != "y" ] && [ "$answer" != "Y" ] && \
            [ "$answer" != "yes" ]; then
            echo "$1: Aborted."
            return -3
        fi
    fi
}

function robo_setup_user_roboag() {

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "creates user RoboAG."
    if [ $? -ne 0 ]; then return -1; fi

    # check if user exists
    temp="$(cat /etc/passwd | grep -i roboag)"
    if [ "$ROBO_CONFIG_IS_SERVER" == "" ]; then
        echo "$1: You are not in server-mode!"
        echo -n "  Do you want to continue ? (No/yes) "
        read answer

        if [ "$answer" != "y" ] && [ "$answer" != "Y" ] && \
            [ "$answer" != "yes" ]; then
            echo "$1: Aborted."
            return -3
        fi
    fi
}
