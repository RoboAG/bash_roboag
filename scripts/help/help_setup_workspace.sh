#!/bin/bash

#***************************[help]********************************************
# 2020 10 12

function robo_help_setup_workspace() {

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
    echo "  $ . checkout.sh"
    echo "    answer all question with \"y\" (yes)"
    echo -e "\n<enter>\n"; read dummy


    echo "2. Set Mode of Computer"
    echo "  a) Standalone client (no server available)"
    echo "    nothing todo"
    echo ""
    echo "  b) Client within RoboAG (connection to RoboAG server)"
    echo "    $ touch \${ROBO_PATH_CONFIG}is_client.txt"
    echo ""
    echo "  c) RoboAG server"
    echo "    $ touch \${ROBO_PATH_CONFIG}is_server.txt"
    echo -e "\n<enter>\n"; read dummy


    echo "3.a) Source workspace"
    echo "  If you accepted auto sourcing in step 1.b):"
    echo "    Just close terminal and reopen it."
    echo "  Otherwise, you need to source the downloaded scripts directly:"
    echo "    $ source ~/workspace/bash/master/roboag/bashrc.sh"
    echo -e "\n<enter>\n"; read dummy

    echo "3.b) Download additional repositories"
    echo "  Only if in standalone-mode, download additional repositories."
    echo "  Get all repos        : $ repo_clone_all"
    echo "  Select specific repos: $ repo_clone_bash"
    echo "                         $ git_clone_... (e.g. git_clone_robo_lib)"
    echo ""
    echo "  For an overview and some hints see:"
    echo "    $ robo_repo_overview"
    echo -e "\n<enter>\n"; read dummy


    echo "done :-)"
}
