#!/bin/bash

#***************************[needed external variables]***********************
# 2020 09 27

# ROBO_PATH_WORKSPACE

# note: repo files must be sourced AFTER this script



#***************************[server]******************************************
# 2018 01 01

# note: this is already set in file bash/repo/list.sh
export REPO_ROOT_GITHUB_URL="https://github.com/peterweissig/"



#***************************[bash]********************************************
# 2020 10 11

# paths
# note: this is equivalent to setup in bash/repo/list.sh
export ROBO_BASH_PATH="${ROBO_PATH_WORKSPACE}bash/"

# repos
# note: this is equivalent to setup in bash/repo/list.sh
if [ "$REPO_BASH_REPO" == "" ]; then
    export REPO_BASH_REPO=("${ROBO_BASH_PATH}repo/" \
    "${REPO_ROOT_GITHUB_URL}bash_repo.git")

    alias git_clone_bash_repo="git clone ${REPO_BASH_REPO[1]} \
      ${REPO_BASH_REPO[0]}"
fi



#***************************[global update and stat]**************************
# 2018 01 05

alias robo_repo_update="repo_pull_all"
alias robo_repo_status="repo_status_all"



#***************************[change repo paths]*******************************
# 2020 10 11

export REPO_MODE="roboag"
alias robo_repo_overview="repo_help_overview_roboag"
