#!/bin/bash

#***************************[needed external variables]***********************
# 2018 04 01

# ROBO_PATH_SCRIPTS

# note: repo files must be sourced after this script



#***************************[path]********************************************
# 2018 03 01

export ROBO_PATH_CONFIG="${ROBO_PATH_SCRIPT}config/"



#***************************[check mode of operation]*************************
# 2019 09 10

# unset all possible config states
unset ROBO_CONFIG_IS_SERVER
unset ROBO_CONFIG_IS_CLIENT
unset ROBO_CONFIG_STANDALONE

# Is in server-mode ?
if [ "$(ls $ROBO_PATH_CONFIG  | grep -i is_server | wc -w)" -gt 0 ]; then
    export ROBO_CONFIG_IS_SERVER="1"
else

    # Is in client-mode ?
    if [ "$(ls $ROBO_PATH_CONFIG  | grep -i is_client | wc -w)" -gt 0 ]; then
        export ROBO_CONFIG_IS_CLIENT="1"
    else

        # Standalone-Mode!
        export ROBO_CONFIG_STANDALONE="1"
    fi
fi



#***************************[server config]***********************************
# 2019 01 05

# setup server paths
export _ROBO_SERVER_PATH_DATA="/mnt/data/"
export _ROBO_SERVER_PATH_ROBOAG="${_ROBO_SERVER_PATH_DATA}roboag/"
export _ROBO_SERVER_PATH_ROBOSAX="${_ROBO_SERVER_PATH_DATA}robosax/"


if [ "$ROBO_CONFIG_IS_SERVER" != "" ]; then

    # setup hard-drives
    export ROBO_PATH_ROBOAG="${_ROBO_SERVER_PATH_ROBOAG}"
    export ROBO_PATH_ROBOSAX="${_ROBO_SERVER_PATH_ROBOSAX}"

    # setup repo directory
    export ROBO_PATH_REPOS="${ROBO_PATH_ROBOAG}Repos/"

    # override standard-directories
    export REPO_ROBO_PATH="${ROBO_PATH_REPOS}WinAVR/"
        # robolib
        # pololu

        export REPO_ROBOSAX_AVR_PATH="${REPO_ROBO_PATH}RoboSAX/"
            # licht robosax


    temp="${ROBO_PATH_REPOS}Eagle/"
        export REPO_ROBO_EAGLE_PATH="${temp}"
            # config
            # keplerboard
            # xbee
            # logic
            # vtgMon

        export REPO_ROBOSAX_EAGLE_PATH="${temp}RoboSAX/"
            # licht tht
            # anzeige tht

        export REPO_PROJECTS_EAGLE_PATH="${temp}Peter/"
            # dmx_driver

    export REPO_ROBOAG_PATH="${ROBO_PATH_REPOS}Projekte/"
        # display
        # gluecksrad
        # 3pi

        export REPO_ROBOSAX_PROJECT_PATH="${REPO_ROBOAG_PATH}RoboSAX/"
            # ledbox

        export REPO_HARDWARE_PATH="${REPO_ROBOAG_PATH}Peter/"
            # home-audio
            # opa
            # dimmer

    export REPO_CPP_PATH="${ROBO_PATH_REPOS}C++/Peter/"
            # avr_downloader and xbee_tool

    export REPO_ROS_PATH="${ROBO_PATH_REPOS}ROS/"
        # ros-tools-pa
            # parameter
            # pcdfilter
            # octomap
            # nearfield_map
            # odometry
        # ros-sensors-pa
            # radar

    temp="${ROBO_PATH_REPOS}PHP/"
    export REPO_ROBOAG_PHP_PATH="${temp}"
        # filebrowser

    export REPO_ROBOSAX_PHP_PATH="${temp}"
        # Punkte RoboSAX

    export REPO_DOC_PATH="${ROBO_PATH_REPOS}doc/"
            # documentation of servers
fi

#***************************[mode check]**************************************
# 2019 11 20

function _robo_system_need_server() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME <function-name>"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 1 parameter"
        echo "     #1: name of calling function"
        echo "This function checks if server-mode is active."
        echo "Elsewhile the user will be asked, before continueing."

        return
    fi

    # check parameter
    if [ $# -ne 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi
    # check parameter
    if [ "$1" == "" ]; then
        echo -n "$FUNCNAME: Parameter Error - "
        echo "name of calling function must be set."
        return -2
    fi

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

function _robo_system_need_client() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME <function-name>"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 1 parameter"
        echo "     #1: name of calling function"
        echo "This function checks if client-mode is active."
        echo "Elsewhile the user will be asked, before continueing."

        return
    fi

    # check parameter
    if [ $# -ne 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi
    # check parameter
    if [ "$1" == "" ]; then
        echo -n "$FUNCNAME: Parameter Error - "
        echo "name of calling function must be set."
        return -2
    fi

    if [ "$ROBO_CONFIG_IS_CLIENT" == "" ]; then
        echo "$1: You are not in client-mode!"
        echo -n "  Do you want to continue ? (No/yes) "
        read answer

        if [ "$answer" != "y" ] && [ "$answer" != "Y" ] && \
            [ "$answer" != "yes" ]; then
            echo "$1: Aborted."
            return -3
        fi
    fi
}
