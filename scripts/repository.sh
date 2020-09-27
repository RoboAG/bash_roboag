#!/bin/bash

#***************************[needed external variables]***********************
# 2020 09 27

# ROBO_PATH_WORKSPACE

# note: repo files must be sourced after this script



#***************************[server]******************************************
# 2018 01 01

# note: this is already set in file bash/repo/list.sh
export REPO_ROOT_GITHUB_URL="https://github.com/peterweissig/"



#***************************[bash]********************************************
# 2018 01 08

# paths
# note: this is already set in file bash/repo/list.sh
export REPO_BASH_PATH="${ROBO_PATH_WORKSPACE}bash/"

# repos
# note: this is already set in file bash/repo/list.sh
export REPO_BASH_REPO=("${REPO_BASH_PATH}repo/" \
  "${REPO_ROOT_GITHUB_URL}bash_repo.git")



#***************************[global update and stat]**************************
# 2018 01 05

alias robo_repo_update="repo_pull_all"
alias robo_repo_status="repo_status_all"



#***************************[change repo paths]*******************************
# 2020 09 27

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
        # server
            # online server
            # local server
        # robosax
            # punkte
    export REPO_ROBOAG_DOC_PATH="${REPO_DOC_PATH}"
        # robolib
        # install

fi
