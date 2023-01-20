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
export ROBO_ORLAB_CONNECTOR_NAME="OpenRobertaConnector.jar"

# 2023 01 20
alias orlab_connect="robo_orlab_connect"

function robo_orlab_connect () {
    path="${ROBO_PATH_OPT_BIN}"
    file="${path}${ROBO_ORLAB_CONNECTOR_NAME}"
    if [ -e "$file" ]; then
        echo "using roboag version of connector"
    else
        path="${HOME}/Downloads/"
        file="${path}${ROBO_ORLAB_CONNECTOR_NAME}"
        if [ -e "$file" ]; then
            echo "using downloaded version of connector"
        else
            echo "cannot find connector :-("
            return -1
        fi
    fi
    echo "  ($file)"
    (
        cd "$ROBO_ORLAB_CONNECTOR_PATH"
        java -jar -Dfile.encoding=utf-8 "$ROBO_ORLAB_CONNECTOR"
    )
}
