# setup repositories
BASH_ROBOAG_PATH="bash/roboag/"
BASH_REPO_PATH="bash/repo/"
GIT_SERVER_ROBOAG="https://github.com/peterweissig/bash_roboag.git"
GIT_SERVER_REPO="https://github.com/peterweissig/bash_repo.git"

# export paths
export ROBO_PATH_WORKSPACE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd )/"
export ROBO_PATH_SCRIPTS="${ROBO_PATH_WORKSPACE}${BASH_ROBOAG_PATH}bashrc.sh"

export ROBO_HOME="$(cd && pwd )/"

##
## inform user
##

echo
echo "This script checks out \"bash/roboag\" and \"bash/repo\" to the local"
echo "working directory. It must be manually placed at the top-level"
echo "of the working directory - not in \"bash/\" or \"bash/roboag/\"!"
echo

echo "Run this script ? (yes/No)"
read answer
if [ ! "$answer" == "yes" ]; then
  echo "  Stopped"
  exit -1
fi

##
## check out roboag
##

echo "mkdir -p ${BASH_ROBOAG_PATH}"
mkdir -p "${BASH_ROBOAG_PATH}"

echo "git clone \"$GIT_SERVER_ROBOAG\" \"$BASH_ROBOAG_PATH\""
git clone "$GIT_SERVER_ROBOAG" "$BASH_ROBOAG_PATH"

##
## update .bashrc
##

LINE_BASHRC=". ${ROBO_PATH_SCRIPTS}bashrc.sh"
FOUND="$(cat "${ROBO_HOME}.bashrc" | grep "${LINE_BASHRC}")"

if [ "$FOUND" == "" ]; then
    echo "Add entry to \"~/.bashrc\""
    echo ""                                   >> "${ROBO_HOME}.bashrc"
    echo "# helper script for roboag :-)"     >> "${ROBO_HOME}.bashrc"
    echo "${LINE_BASHRC}"                     >> "${ROBO_HOME}.bashrc"
fi

##
## clone bash_repo repository
##

echo "git clone \"$GIT_SERVER_REPO\" \"$BASH_REPO_PATH\""
git clone "$GIT_SERVER_REPO" "$BASH_REPO_PATH"


##
## source bashrc.sh
##

. ${ROBO_PATH_SCRIPTS}bashrc.sh

##
## remove this file
##

rm checkout.sh
