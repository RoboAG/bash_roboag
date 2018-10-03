#!/bin/bash

#***************************[help]********************************************
# 2018 10 03

function robo_help_config_workspace() {

    echo ""
    echo "### Config RoboAG Workspace ###"
    echo ""
    echo "see also https://github.com/RoboAG/bash_roboag"
    echo ""


    echo "0. Open Terminal"
    echo "  <strg>+<alt>+<T>"
    echo -e "\n<enter>\n"; read dummy


    echo "1.a) Create working directory"
    echo "  Recommended is \"~/workspace/\", but any directory is possible!"
    echo "  $ mkdir -p ~/workspace"
    echo "  $ cd ~/workspace"
    echo -e "\n<enter>\n"; read dummy


    echo "1.b) Download scripts"
    file_part="https://raw.githubusercontent.com/RoboAG/bash_roboag"
    file="${file_part}/master/checkout.sh"
    echo "  $ wget -nv ${file}"
    echo "  $ bash ./checkout.sh"
    echo "    answer all question with \"y\" (yes)"
    echo -e "\n<enter>\n"; read dummy


    echo "2. Set Mode of Computer"
    echo "  a) Client within RoboAG (connection to RoboAG server)"
    echo "    nothing todo"
    echo ""
    echo "  b) Standalone client (no server avaiable)"
    echo "    $ touch  \${ROBO_PATH_CONFIG}standalone.txt"
    echo ""
    echo "  c) RoboAG server"
    echo "    $ touch  \${ROBO_PATH_CONFIG}is_server.txt"
    echo -e "\n<enter>\n"; read dummy


    echo "3) Download additional repositories"
    echo "  If not in server mode, download additional repositories as needed."
    echo "  $ git_clone_..."
    echo "  E.g. $ git_clone_robo_lib"
    echo ""
    echo "  For a overview and some hints see:"
    echo "  $ repo_help_overview"
    echo -e "\n<enter>\n"; read dummy


    echo "done :-)"
}
