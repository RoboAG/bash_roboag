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
# 2021 01 19

export _ROBO_SERVER_IP="192.168.2.20"
export _ROBO_SERVER_IP_MASK="255.255.255.0"
export _ROBO_SERVER_IP_MASK2="${_ROBO_SERVER_IP}/24"

# this definition is overwritten in server mode (see also config_server.sh)
export ROBO_SERVER_IP="$_ROBO_SERVER_IP"



#***************************[user]********************************************
# 2021 01 16

export ROBO_USER_ADMIN="guru"
export ROBO_USER_AG="roboag"



#***************************[shared paths]************************************
# 2021 01 16

export ROBO_PATH_SHARED="/opt/roboag/"
export ROBO_PATH_SHARED_REPOS="${ROBO_PATH_SHARED}repos/"
export ROBO_PATH_SHARED_DATA="${ROBO_PATH_SHARED}data/"
