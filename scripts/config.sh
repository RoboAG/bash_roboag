#***************************[needed external variables]***********************
# 2018 03 01

# ROBO_PATH_WORKSPACE


#***************************[path]********************************************
# 2018 03 01

export ROBO_PATH_CONFIG="${ROBO_PATH_SCRIPTS}config/"



#***************************[check mode of operation]*************************
# 2018 03 01

# unset all possible config states
unset ROBO_CONFIG_IS_SERVER
unset ROBO_CONFIG_IS_CLIENT
unset ROBO_CONFIG_STANDALONE

# Is in server-mode ?
if [ "$(ls $ROBO_PATH_CONFIG  | grep -i is_server | wc -w)" -gt 0 ]; then
    export ROBO_CONFIG_IS_SERVER="1"
else

    # Standalone-Mode ?
    if [ "$(ls $ROBO_PATH_CONFIG  | grep -i standalone | wc -w)" -gt 0 ]; then
        export ROBO_CONFIG_STANDALONE="1"
    else

        # Is in client-mode!
        export ROBO_CONFIG_IS_CLIENT="1"
    fi
fi



#***************************[server config]***********************************
# 2018 04 01

# setup server paths
export _ROBO_SERVER_PATH_DATA="/mnt/data/"
export _ROBO_SERVER_PATH_ROBOAG="${_ROBO_SERVER_PATH_DATA}roboag/"
export _ROBO_SERVER_PATH_ROBOSAX="${_ROBO_SERVER_PATH_DATA}robosax/"


if [ "$ROBO_CONFIG_IS_SERVER" != "" ]; then

    # setup hard-drives
    export ROBO_PATH_ROBOAG="${_ROBO_SERVER_PATH_ROBOAG}"
    export ROBO_PATH_ROBOSAX="${_ROBO_SERVER_PATH_ROBOSAX}"

    # override standard-directories
    export REPO_ROBO_PATH="${ROBO_PATH_ROBOAG}WinAVR/"
        # robolib
        # pololu

        export REPO_ROBOSAX_AVR_PATH="${REPO_ROBO_PATH}RoboSAX/"
            # licht robosax


    temp="${ROBO_PATH_ROBOAG}Eagle/"
        export REPO_ROBO_EAGLE_PATH="${temp}RoboAG/"
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

    export REPO_ROBOAG_PATH="${ROBO_PATH_ROBOAG}Projekte/"
        # display
        # gluecksrad
        # 3pi

        export REPO_ROBOSAX_PROJECT_PATH="${REPO_ROBOAG_PATH}RoboSAX/"
            # ledbox

        export REPO_HARDWARE_PATH="${REPO_ROBOAG_PATH}Peter/"
            # home-audio
            # opa
            # dimmer

    export REPO_CPP_PATH="${ROBO_PATH_ROBOAG}C++/Peter/"
            # avr_downloader and xbee_tool

    export REPO_ROS_PATH="${ROBO_PATH_ROBOAG}ROS/"
        # ProAut
            # parameter
            # pcdfilter
            # octomap
            # nearfield_map

    temp="${ROBO_PATH_ROBOAG}PHP/"
    export REPO_ROBOAG_PHP_PATH="${temp}"
        # filebrowser

    export REPO_ROBOSAX_PHP_PATH="${temp}"
        # Punkte RoboSAX

fi
