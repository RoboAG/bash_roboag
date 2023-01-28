#!/bin/bash

#***************************[dependencies]************************************
# 2021 01 19

# the following must be sourced BEFORE this script
#     repo files
#     config_user.sh
#
# the following must be sourced AFTER this script
#



#***************************[open roberta connector]**************************
# 2023 01 20
export ROBO_ORLAB_CONNECTOR_NAME="OpenRobertaConnector"
export _ROBO_ORLAB_CONNECTOR_PATH1="${ROBO_PATH_OPT_BIN}${ROBO_ORLAB_CONNECTOR_NAME}/"
export _ROBO_ORLAB_CONNECTOR_PATH2="${HOME}/Downloads/${ROBO_ORLAB_CONNECTOR_NAME}/"

# 2023 01 20
alias orlab_connect="robo_orlab_connect"

function robo_orlab_connect () {
    path="$_ROBO_ORLAB_CONNECTOR_PATH1"
    if [ -d "$path" ]; then
        echo "using roboag version of connector"        
    else
        path="$_ROBO_ORLAB_CONNECTOR_PATH2"
        if [ -d "$path" ]; then
            echo "using downloaded version of connector"
        else
            echo "cannot find connector :-("
            return -1
        fi
    fi
    file="${path}${ROBO_ORLAB_CONNECTOR_NAME}.jar"
    echo "  ($file)"
    (
        cd "$path"
        java -jar -Dfile.encoding=utf-8 "$file"
    )
}
