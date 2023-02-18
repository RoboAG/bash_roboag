#!/bin/bash

#***************************[dependencies]************************************
# 2021 01 19

# the following must be sourced BEFORE this script
#     repo files
#
# the following must be sourced AFTER this script
#     config.sh        - depends exported definitions
#     config_server.sh - overwritting ROBO_SERVER_IP
#     almost all files - using _robo_config_need_... or ROBO_CONFIG_IS_...



#***************************[server ip]***************************************
# 2023 02 14

export _ROBO_SERVER_IP="192.168.2.20"
export _ROBO_SERVER_IP_MASK="255.255.255.0"
export _ROBO_SERVER_IP_MASK2="${_ROBO_SERVER_IP}/24"

export ROBO_SERVER_PORT="8080"

# these definitions are overwritten in server mode (see also config_server.sh)
export ROBO_SERVER_IP="$_ROBO_SERVER_IP"
export ROBO_SERVER_URL="${ROBO_SERVER_IP}:${ROBO_SERVER_PORT}"



#***************************[user]********************************************
# 2021 01 16

export ROBO_USER_ADMIN="guru"
export ROBO_USER_AG="roboag"



#***************************[shared paths]************************************
# 2023 01 20

export ROBO_PATH_OPT="/opt/roboag/"
export ROBO_PATH_OPT_REPOS="${ROBO_PATH_OPT}repos/"
export ROBO_PATH_OPT_DATA="${ROBO_PATH_OPT}data/"
export ROBO_PATH_OPT_BIN="${ROBO_PATH_OPT}bin/"
