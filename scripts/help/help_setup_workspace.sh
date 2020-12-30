#!/bin/bash

#***************************[help]********************************************
# 2020 12 30

alias robo_help_setup_workspace_shared="robo_help_setup_workspace shared"
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
        echo "the path is \"/opt/roboag/repos/\". Therefore, all users have"
        echo "access to the repositories. For the setup the current user"
        echo "needs sudo rights."
        echo "This is the default setup for our CLIENTS and SERVERS."
        echo ""
        echo "See also: $ robo_help_setup_workspace shared"
        echo ""

        echo "In SIMPLE mode the repositories are stored in a user-defined"
        echo "place - typically at \"~/workspace/\". This is the simplest"
        echo "setup, but the repositories are only available to the current"
        echo "user. This is good for TESTING our scripts or in case you are"
        echo "having a SINGLE-USER-system working with our repositories."
        echo ""
        echo "See also: $ robo_help_setup_workspace simple"
        echo ""

        return
    fi


    # setup paths
    if [ "$mode_flag" == "simple" ]; then
        path_workspace=""
    else
        path_workspace="/opt/roboag/repos/"
    fi
    path_roboag="${path_workspace}bash/master/roboag/"


    # print header
    echo ""
    echo "### Config RoboAG Workspace ###"
    echo ""
    if [ "$mode_flag" == "simple" ]; then
        echo "SIMPLE-mode for testing and single-user-systems"
    else
        echo "SHARED mode for clients & server"
    fi
    echo "See also: $ robo_help_setup_workspace"
    echo ""
    echo -e "\n<enter>\n"; read dummy

    # steps ...
    echo "0. Open Terminal"
    echo "  <strg>+<alt>+<t>"
    echo -e "\n<enter>\n"; read dummy


    if [ "$mode_flag" == "simple" ]; then
        echo "1.a) Create working directory"
        echo "  Recommended is \"~/workspace/\", but any directory is possible!"
        echo "  $ mkdir -p ~/workspace"
        echo "  $ cd ~/workspace"
        echo -e "\n<enter>\n"; read dummy

        echo "1.b) Download scripts"
        filename="checkout.sh"
    else
        echo "1.a) Download scripts"
        filename="checkout_all_users.sh"
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

        echo "1.c) Config settings"
        echo "  Config files, e.g. changed by scripts or nano_config(),"
        echo "  will be copied into the shared repositories - this can be a"
        echo "  SECURITY ISSUE. For our clients this is a feature :-)"
        echo "  If you want to keep your config files local:"
        echo "    $ mkdir -p \"\${HOME}/config/\${HOSTNAME}/\""
        echo -e "\n<enter>\n"; read dummy
    fi


    echo "2. Source workspace"
    echo "  If you accepted auto sourcing in step 1:"
    echo "    Just close terminal and reopen it."
    echo "  Otherwise, you need to source the downloaded scripts directly:"
    echo "    $ source ${path_roboag}bashrc.sh"
    echo "  Or you can setup auto-sourcing later:"
    echo "    $ source ${path_roboag}setup_bashrc.sh"
    echo "    # remember to close and reopen terminal afterwards"
    echo -e "\n<enter>\n"; read dummy


    echo "3. Set Mode of Computer"
    echo "  a) Standalone client (no server available)"
    echo "    nothing todo"
    echo ""
    echo "  b) Client within RoboAG (connection to RoboAG server)"
    echo "    $ touch \${ROBO_PATH_CONFIG}is_client.txt"
    echo ""
    echo "  c) RoboAG server"
    echo "    $ touch \${ROBO_PATH_CONFIG}is_server.txt"
    echo ""
    if [ "$mode_flag" == "simple" ]; then
        echo "  You are following instructions for simple usage, most"
        echo "  likely a) is your choice."
    else
        echo "  You are following instructions for shared usage, most"
        echo "  likely b) or c) is your choice. Nevertheless, this files"
        echo "  might also be created later."
    fi
    echo "  If changing your mode of operation, you need to re-source:"
    echo "    close terminal and source workspace (see also step 2)"
    echo ""
    echo -e "\n<enter>\n"; read dummy

    echo "4. Download additional repositories"
    echo "  If in standalone-mode, download additional repositories."
    echo "  Get all repos        : $ repo_clone_all"
    echo "  Select specific repos: $ repo_clone_bash"
    echo "                         $ repo_clone_roboag"
    echo "                         $ repo_clone_robosax"
    echo "                         $ git_clone_... (e.g. git_clone_robo_lib)"
    echo ""
    echo "  For an overview and some hints see:"
    echo "    $ robo_repo_overview"
    echo -e "\n<enter>\n"; read dummy


    echo "done :-)"
}
