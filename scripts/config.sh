#!/bin/bash

#***************************[needed external variables]***********************
# 2018 04 01

# ROBO_PATH_SCRIPTS

# note: repo files must be sourced after this script



#***************************[path]********************************************
# 2018 03 01

export ROBO_PATH_CONFIG="${ROBO_PATH_SCRIPT}config/"



#***************************[set mode of operation]***************************
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



#***************************[check mode of operation]*************************
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



#***************************[server config]***********************************
# 2019 11 20

export _ROBO_SERVER_IP="192.168.2.20"

if [ "$ROBO_CONFIG_IS_SERVER" == "" ]; then
    export ROBO_SERVER_IP="$_ROBO_SERVER_IP"
else
    export ROBO_SERVER_IP="localhost"
fi

#***************************[change repo paths]*******************************
# 2020 09 24

# avr
if [ "$REPO_ROBOAG_PATH" == "" ]; then
    export REPO_ROBOAG_PATH="${ROBO_PATH_WORKSPACE}WinAVR/"
        # robolib
        # pololu

    if [ "$REPO_ROBOSAX_AVR_PATH" == "" ]; then
        export REPO_ROBOSAX_AVR_PATH="${REPO_ROBOAG_PATH}RoboSAX/"
            # spielfeld
            # omnibot
    fi
fi

# eagle
if [ "$REPO_ROBOAG_EAGLE_PATH" == "" ]; then
    temp="${ROBO_PATH_WORKSPACE}Eagle/"
    export REPO_ROBOAG_EAGLE_PATH="${temp}"
        # config
        # keplerboard
        # xbee
        # logic
        # vtgMon

    if [ "$REPO_ROBOSAX_EAGLE_PATH" == "" ]; then
        export REPO_ROBOSAX_EAGLE_PATH="${temp}RoboSAX/"
            # spielfeld
            # licht
            # anzeige
    fi

    if [ "$REPO_PROJECTS_EAGLE_PATH" == "" ]; then
        export REPO_PROJECTS_EAGLE_PATH="${temp}Peter/"
            # dmx_driver
    fi
fi

# projects
if [ "$REPO_ROBOAG_PROJECTS_PATH" == "" ]; then
    export REPO_ROBOAG_PROJECTS_PATH="${ROBO_PATH_WORKSPACE}Projekte/"
        # display
        # gluecksrad
        # 3pi
        # roboter

    if [ "$REPO_ROBOSAX_PROJECT_PATH" == "" ]; then
        export REPO_ROBOSAX_PROJECT_PATH="${REPO_ROBOAG_PROJECTS_PATH}RoboSAX/"
            # spielfeld
            # ledbox
    fi

    if [ "$REPO_HARDWARE_PATH" == "" ]; then
        export REPO_HARDWARE_PATH="${REPO_ROBOAG_PROJECTS_PATH}Peter/"
            # anhaenger
            # home-audio
            # opa
            # dimmer
    fi
fi


# c++
if [ "$REPO_CPP_PATH" == "" ]; then
    export REPO_CPP_PATH="${ROBO_PATH_WORKSPACE}C++/Peter/"
        # avr_downloader and xbee_tool
fi

# ros
if [ "$REPO_ROS_PATH" == "" ]; then
    export REPO_ROS_PATH="${ROBO_PATH_WORKSPACE}ROS/"
        # ros-tools-pa
            # parameter
            # pcdfilter
            # octomap
            # nearfield_map
        # ros-sensors-pa
            # radar
fi

# php
if [ "$REPO_ROBOAG_PHP_PATH" == "" ]; then
    temp="${ROBO_PATH_WORKSPACE}PHP/"
    export REPO_ROBOAG_PHP_PATH="${temp}"
        # filebrowser

    if [ "$REPO_ROBOSAX_PHP_PATH" == "" ]; then
        export REPO_ROBOSAX_PHP_PATH="${temp}"
            # Punkte RoboSAX
            # Punkte RoboSAX (old version)
    fi
fi

# doc
if [ "$REPO_DOC_PATH" == "" ]; then
    export REPO_DOC_PATH="${ROBO_PATH_WORKSPACE}Dokumentation/"
        # online server
        # local server
        # robolib
        # punkte
fi

#***************************[server paths]************************************
# 2020 09 24

# setup server paths
export _ROBO_SERVER_PATH_DATA="/mnt/data/"
export _ROBO_SERVER_PATH_ROBOAG="${_ROBO_SERVER_PATH_DATA}roboag/"
export _ROBO_SERVER_PATH_ROBOSAX="${_ROBO_SERVER_PATH_DATA}robosax/"


if [ "$ROBO_CONFIG_IS_SERVER" != "" ]; then

    # setup hard-drives
    export ROBO_PATH_ROBOAG="${_ROBO_SERVER_PATH_ROBOAG}"
    export ROBO_PATH_ROBOSAX="${_ROBO_SERVER_PATH_ROBOSAX}"
fi
