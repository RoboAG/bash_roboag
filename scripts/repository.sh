#***************************[needed external variables]***********************
# 2018 01 05

# ROBO_PATH_WORKSPACE



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

