#!/bin/bash

#***************************[help]********************************************
# 2021 02 06

alias robo_help_setup_workspace_shared="robo_help_setup_workspace shared"
alias robo_help_setup_workspace_client="robo_help_setup_workspace client"
alias robo_help_setup_workspace_simple="robo_help_setup_workspace simple"

function robo_help_setup_workspace() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME [<mode>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 0-1 parameter"
        echo "    [#1:]mode of the repositories (default: show infos)"
        echo "           \"shared\"  share workspace with all users"
        echo "           \"client\"  like \"shared\", but relying on server"
        echo "           \"simple\"  setup regular workspace"

        return
    fi

    # check parameter
    if [ $# -gt 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # check first parameter (mode)
    mode_flag=""
    if [ $# -gt 0 ]; then
        if [ "$1" == "shared" ]; then
            mode_flag="shared"
        elif [ "$1" == "client" ]; then
            mode_flag="client"
        elif [ "$1" == "simple" ]; then
            mode_flag="simple"
        else
            echo "$FUNCNAME: Parameter Error."
            $FUNCNAME --help
            return -1
        fi
    fi

    # show general infos
    if [ "$mode_flag" == "" ]; then
        echo ""
        echo "### Config RoboAG Workspace ###"
        echo ""
        echo "There are two ways to use our repositories:"
        echo "  - shared"
        echo "  - simple"
        echo ""

        echo "In SHARED mode the repositories are stored globally - for now"
        echo -n "the path is \"${ROBO_PATH_SHARED_REPOS}\". "
        echo    "Therefore, all users have"
        echo "access to the repositories. For the setup the current user"
        echo "needs sudo rights."
        echo "This is the default setup for our CLIENTS and SERVERS."
        echo ""
        echo "See also: $ robo_help_setup_workspace_shared"
        echo ""

        echo "CLIENT mode is very similar to shared mode. This mode works"
        echo "without direct access to internet. However, the server needs"
        echo "to be running. Therefore, this should be the first choice,"
        echo "if a client is setup within RoboAG."
        echo ""
        echo "See also: $ robo_help_setup_workspace_client"
        echo ""

        echo "In SIMPLE mode the repositories are stored in a user-defined"
        echo "place - typically at \"~/workspace/\". This is the simplest"
        echo "setup, but the repositories are only available to the current"
        echo "user. This is good for TESTING our scripts or in case you are"
        echo "having a SINGLE-USER-system working with our repositories."
        echo ""
        echo "See also: $ robo_help_setup_workspace_simple"
        echo ""

        return
    fi


    # setup paths
    if [ "$mode_flag" == "simple" ]; then
        path_workspace=""
    else
        path_workspace="$ROBO_PATH_SHARED_REPOS"
    fi
    path_roboag="${path_workspace}bash/master/roboag/"


    # print header
    echo ""
    echo "### Config RoboAG Workspace ###"
    echo ""
    if [ "$mode_flag" == "shared" ]; then
        echo "SHARED mode for clients & server"
    elif [ "$mode_flag" == "client" ]; then
        echo "CLIENT mode based on running server"
    else
        echo "SIMPLE-mode for testing and single-user-systems"
    fi
    echo "See also: $ robo_help_setup_workspace"
    echo ""
    echo -e "\n<enter>\n"; read dummy

    # steps ...
    echo "0. Open Terminal"
    echo "  <strg>+<alt>+<t>"
    echo -e "\n<enter>\n"; read dummy


    if [ "$mode_flag" != "client" ]; then
        if [ "$mode_flag" == "shared" ]; then
            echo "1.a) Download scripts"
            filename="checkout_all_users.sh"
        else
            echo "1.a) Create working directory"
            echo -n "  Recommended is \"~/workspace/\", "
            echo    "but any directory is possible!"
            echo "  $ mkdir -p ~/workspace"
            echo "  $ cd ~/workspace"
            echo -e "\n<enter>\n"; read dummy

            echo "1.b) Download scripts"
            filename="checkout.sh"
        fi
        url_part1="https://raw.githubusercontent.com/RoboAG/"
        url_part2="bash_roboag/master/"
        echo "  $ wget -nv \"${url_part1}${url_part2}${filename}\""
        echo "  $ source ${filename}"
        if [ "$mode_flag" == "simple" ]; then
            echo "    answer all questions with \"yes\""
        else
            echo "    answer question with \"yes\""
        fi
        echo -e "\n<enter>\n"; read dummy
        if [ "$mode_flag" != "simple" ]; then
            echo "1.b) Remove checkout script"
            echo "  $ rm \"${filename}\""
            echo -e "\n<enter>\n"; read dummy
        fi
    else # client mode
        echo "1.a) Create shared folder"
        echo "  $ sudo mkdir -p \"$ROBO_PATH_SHARED_REPOS\""
        echo "  $ sudo chown \$USER \"$ROBO_PATH_SHARED_REPOS\""
        echo -e "\n<enter>\n"; read dummy

        echo "1.b) Copy scripts from server"
        echo "  $ cd \"$ROBO_PATH_SHARED_REPOS\""
        temp="${ROBO_PATH_SHARED_REPOS}bash/"
        echo "  $ scp -r \"${USER}@${_ROBO_SERVER_IP}:${temp}\" ."
        echo -e "\n<enter>\n"; read dummy
    fi
    if [ "$mode_flag" != "simple" ]; then
        echo "1.c) Config settings"
        echo "  Config files, e.g. changed by scripts or nano_config(),"
        echo "  will be copied into the shared repositories - this can"
        echo "  be a SECURITY ISSUE."
        echo "  You should keep your config files local:"
        echo "    $ mkdir -p \"\${HOME}/config/\${HOSTNAME}/\""
        echo -e "\n<enter>\n"; read dummy
    fi


    echo "2. Source workspace"
    if [ "$mode_flag" != "client" ]; then
        echo "  If you did not accept auto sourcing in step 1:"
        echo "  You need to source the downloaded scripts directly:"
        echo "    $ source ${path_roboag}bashrc.sh"
        echo "  Or you can setup auto-sourcing later:"
    fi
    echo "    $ source ${path_roboag}setup_bashrc.sh"
    echo "    # remember to answer question with \"yes\""
    echo -e "\n<enter>\n"; read dummy


    echo "3. Set Mode of Computer"
    if [ "$mode_flag" != "client" ]; then
        echo "  a) Standalone client (no server available)"
        echo "    nothing todo"
        echo ""
        echo "  b) Client within RoboAG (connection to RoboAG server)"
    fi
    echo "    $ robo_config_mode_set client"
    if [ "$mode_flag" != "client" ]; then
        echo ""
        echo "  c) RoboAG server"
        echo "    $ robo_config_mode_set server"
        echo ""
        if [ "$mode_flag" == "simple" ]; then
            echo "  You are following instructions for simple usage, most"
            echo "  likely a) is your choice."
        else
            echo "  You are following instructions for shared usage, most"
            echo "  likely b) or c) is your choice. Nevertheless, this files"
            echo "  might also be created later."
        fi
    fi
    echo ""
    echo -e "\n<enter>\n"; read dummy

    if [ "$mode_flag" != "client" ]; then
        echo "4. Download additional repositories"
        echo "  Get all repos        : $ repo_clone_all"
        echo "  Select specific repos: $ repo_clone_bash"
        echo "                         $ repo_clone_roboag"
        echo "                         $ repo_clone_robosax"
        echo -n "                         $ git_clone_... "
        echo    "(e.g. git_clone_robo_lib)"
        echo ""
        echo "  For an overview and some hints see:"
        echo "    $ robo_repo_overview"
        echo -e "\n<enter>\n"; read dummy
    fi


    echo "Further setup instructions can be found here:"
    echo "  $ robo_help_setup"
    echo ""

    echo "done :-)"
}
