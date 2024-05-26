#!/bin/bash

#***************************[needed external variables]***********************
# 2020 09 27

# ROBO_PATH_WORKSPACE



#***************************[dependencies]************************************
# 2021 01 19

# the following must be sourced BEFORE this script
#
# the following must be sourced AFTER this script
#     repo files
#     config.sh



#***************************[server]******************************************
# 2018 01 01

# note: this is already set in file bash/repo/list.sh
export REPO_ROOT_GITHUB_URL="https://github.com/peterweissig/"



#***************************[bash]********************************************
# 2023 11 18

# paths
# note: this is equivalent to setup in bash/repo/list.sh
export ROBO_BASH_PATH="${ROBO_PATH_WORKSPACE}bash/"

# repos
# note: this is equivalent to setup in bash/repo/list.sh
if [ "$REPO_BASH_REPO" == "" ]; then
    export REPO_BASH_REPO=("${ROBO_BASH_PATH}repo/" \
    "${REPO_ROOT_GITHUB_URL}bash_repo.git")

    function git_clone_bash_repo() {
        git clone "${REPO_BASH_REPO[1]}" "${REPO_BASH_REPO[0]}"
    }
fi



#***************************[change repo paths]*******************************
# 2023 11 18

export REPO_MODE="roboag"
function robo_repo_overview() { repo_help_overview_roboag; }

if [ "$ROBO_CONFIG_IS_USER" == "1" ]; then
    return
    exit
fi


#***************************[global update and stat]**************************
# 2023 11 18

function robo_repo_status() { repo_status_all; }
function robo_repo_update_from_web() { repo_pull_all; }

# 2021 01 09
function robo_repo_update_from_server() {

    _robo_config_need_client "$FUNCNAME"
    if [ $? -ne 0 ]; then return -2; fi

    # find all repos
    readarray -t repos <<< "$(file_search --only-dirs \
      .git "$ROBO_PATH_WORKSPACE")"
    if [ $? -ne 0 ]; then return -3; fi

    length_ws="${#ROBO_PATH_WORKSPACE}"
    error=0

    # iterate over repos
    for i in ${!repos[@]}; do
        repo="${repos[$i]}"
        if [ "$repo" == "" ]; then continue; fi

        repo="$(dirname "${repo}")/"
        if [ "${repo:0:$length_ws}" != "$ROBO_PATH_WORKSPACE" ]; then
            continue
        fi
        repo_name="$(basename "$repo")"
        repo_short="${repo:$length_ws}"
        repo_path="${ROBO_SHARE_ROBOAG}Repos/${repo_short}"
        if [ ! -d "$repo_path" ]; then
            echo "unknown repository ${repo}"
            error=1;
            continue
        fi

        echo "###g ${repo_name}@server ###"
        (cd "$repo" && git pull --tags "file://${repo_path}")
        if [ $? -ne 0 ]; then error=2; fi
    done

    # check result
    if [ $error -eq 0 ]; then
        echo "done :-)"
    else
        return $error
    fi
}

# 2023 02 04
# moved logfile path to config.sh, since path is not set yet ...
#export ROBO_FILE_LOG_REPO="${ROBO_PATH_CONFIG}repo.log"

function robo_repo_update() {

    if [ "$ROBO_CONFIG_IS_CLIENT" == "1" ]; then
        robo_repo_update_from_server | _repo_filter_git_grep
    else
        robo_repo_update_from_web
    fi
    if [ $? -ne 0 ]; then return -1; fi

    # add logging
    if [ ! -f "$ROBO_FILE_LOG_REPO" ]; then
        touch "$ROBO_FILE_LOG_REPO" 2>> /dev/null
        if [ $? -ne 0 ]; then return -2; fi
    fi
    if [ -f "$ROBO_FILE_LOG_REPO" ]; then
        str="$(date +"%d.%m.%Y %H:%M") repo";
        if [ "$ROBO_CONFIG_IS_CLIENT" == "1" ]; then
            str="${str} server"
        else
            str="${str} web"
        fi

        echo "$str" >> "$ROBO_FILE_LOG_REPO"
    fi
}

# 2023 02 04
function robo_repo_check() {

    # init variables
    error_flag=0;

   # initial output
    echo -n "repos             ... "

    # check for logfile
    if [ ! -f "$ROBO_FILE_LOG_REPO" ]; then
        error_flag=1;
        echo ""
        echo -n "  no logfile"
    else
        # convert date to seconds
        date="$(tail -n 1 "$ROBO_FILE_LOG_REPO" | awk "{print \$1}")"
        if [ "$date" == "" ]; then
            error_flag=1;
            echo ""
            echo -n "  no valid log"
        else
            date_en="$(echo "$date" | \
              awk -F "." "{print \$2\"/\"\$1\"/\"\$3}")"
            date_secs="$(date --date="$date_en" +"%s")"

            # calculate time diff in days
            now_secs="$(date +"%s")"
            diff_days="$(echo "($now_secs - $date_secs) / 60 / 60 / 24" | \
              bc)"

            if [ $diff_days -ge 6 ]; then
                error_flag=1;
                echo ""
                echo -n "  $diff_days days ago"
            fi
        fi
    fi

    # final result
    if [ $error_flag -eq 0 ]; then
        echo "ok"
    else
        echo ""
        echo "  --> robo_repo_update"
    fi
}

# 2021 01 23
function robo_repo_clone_from_server() {

    _robo_config_need_client "$FUNCNAME"
    if [ $? -ne 0 ]; then return -2; fi

    path_workspace="${ROBO_SHARE_ROBOAG}Repos/"

    # find all repos
    echo "reading repo list ..."
    readarray -t repos <<< "$(file_search --only-dirs \
      .git "${path_workspace}")"
    if [ $? -ne 0 ]; then return -3; fi

    length_ws="${#path_workspace}"

    # iterate over repos
    for i in ${!repos[@]}; do
        repo="${repos[$i]}"
        if [ "$repo" == "" ]; then continue; fi

        repo="$(dirname "${repo}")/"
        if [ "${repo:0:$length_ws}" != "$path_workspace" ]; then
            continue
        fi
        repo_name="$(basename "$repo")"
        repo_short="${repo:$length_ws}"
        repo_path="${ROBO_PATH_WORKSPACE}${repo_short}"
        if [ -d "${repo_path}.git" ]; then
            continue
        fi
        echo "###g ${repo_name}@server ###"
        if [ -d "${repo_path}" ]; then
            echo "  remove old files"
            rm -rf "$repo_path"
        fi

        repo_parent="$(dirname "$repo_path")"
        if [ ! -d "$repo_parent" ]; then
            echo "  mkdir $repo_parent"
            mkdir -p "$repo_parent"
        fi
        (
            echo "  copy $repo_short"
            cp -a "$repo" "$repo_path" && \
            cd "$repo_path" && \
            echo "  git checkout" && \
            git checkout --quiet .
        )
    done

    echo "done :-)"
}
