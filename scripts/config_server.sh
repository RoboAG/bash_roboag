#!/bin/bash

#***************************[server config]***********************************
# 2019 11 20

export _ROBO_SERVER_IP="192.168.2.20"

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

