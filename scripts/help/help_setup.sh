#!/bin/bash

#***************************[help]********************************************
# 2023 09 23

function robo_help_setup() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME [<system>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 0-1 parameters"
        echo "    [#1:]system for which setup instructions will be shown"
        echo "           \"standalone\" Standalone"
        echo "           \"client\"     Client of RoboAG"
        echo "           \"server\"     Server of RoboAG (and RoboSAX)"

        return
    fi

    # check parameter
    if [ $# -gt 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # check first parameter (system-flag)
    system_flag=""
    if [ $# -gt 0 ]; then
        #check for current versions
        if [ "$1" == "client" ]; then
            system_flag="client"
        elif [ "$1" == "server" ]; then
            system_flag="server"
        elif [ "$1" == "standalone" ]; then
            system_flag=""
        else
            echo "$FUNCNAME: Parameter Error."
            $FUNCNAME --help
            return -1
        fi
    else
        if [ "$ROBO_CONFIG_IS_SERVER" != "" ]; then
            system_flag="server"
        elif [ "$ROBO_CONFIG_IS_CLIENT" != "" ]; then
            system_flag="client"
        fi
    fi

    echo ""
    if [ "$system_flag" == "client" ]; then
        echo "### Setup CLIENT ###"
    elif [ "$system_flag" == "server" ]; then
        echo "### Setup SERVER ###"
    else
        echo "### Setup STANDALONE ###"
    fi
    echo ""
    echo "simple configurations"
    echo "    $ config_bash_search"
    if [ "$system_flag" == "server" ]; then
        echo "    $ config_bash_histsize"
    fi
    echo "    $ config_clear_home"
    echo -e "\n<enter>\n"; read dummy

    if [ "$system_flag" != "" ]; then
        echo ""
        echo "user & groups"
        echo "    $ config_password_disable_rejection"
        echo "    $ robo_config_user"
        echo -e "\n<enter>\n"; read dummy
    fi

    echo ""
    echo "update sources"
    #echo "    $ config_source_list_add_multiverse"
    if [ "$system_flag" == "client" ]; then
        echo "    $ robo_config_aptcacher"
    fi
    echo -e "\n<enter>\n"; read dummy

    echo ""
    echo "install packages (this may take a while)"
    echo "    $ robo_system_update"
    echo "    $ sudo reboot"
    if [ "$system_flag" != "server" ]; then
        echo "    $ robo_system_install"
    else
        echo "    $ robo_system_install server"
    fi
    echo -e "\n<enter>\n"; read dummy

    if [ "$system_flag" == "server" ]; then
        echo ""
        echo "setup network"
        echo "    $ robo_setup_server_interfaces"
        echo "    $ sudo reboot"
        echo -e "\n<enter>\n"; read dummy
        echo ""
        echo "setup apt proxy"
        echo "    ... ToDo ..."
        echo -e "\n<enter>\n"; read dummy
        echo ""
        echo "install client packages (this may take a while)"
        echo "    $ robo_system_install"
        echo -e "\n<enter>\n"; read dummy
        echo ""
        echo "setup dnsmasq (dhcp+dns)"
        echo "    $ robo_setup_server_dnsmasq"
        echo -e "\n<enter>\n"; read dummy
        echo ""
        echo "setup apache"
        echo "    $ robo_setup_server_apache"
        echo -e "\n<enter>\n"; read dummy
    fi

    if [ "$system_flag" == "client" ]; then
        echo ""
        echo "install vscode"
        echo "    $ robo_config_keys"
        echo "    $ config_install_vscode  # this will fail"
        echo "    $ robo_config_aptcacher"
        echo "    $ robo_system_update"
        echo "    $ robo_system_install"
        echo -e "\n<enter>\n"; read dummy
    fi

    echo ""
    if [ "$system_flag" == "" ]; then
        echo -n "optional: "
    fi
    echo "setup samba (file shares)"
    if [ "$system_flag" == "server" ]; then
        echo "    $ robo_setup_server_samba"
        echo "    $ robo_setup_server_smbuser"
    fi
    echo "    $ robo_config_samba"
    echo -e "\n<enter>\n"; read dummy

    if [ "$system_flag" == "server" ]; then
        echo "setup crontab (restart services on reboot)"
        echo "    $ robo_setup_server_cron"
    fi

    if [ "$system_flag" == "client" ]; then
        echo ""
        echo "update repos"
        echo "    $ robo_repo_update"
        echo "    $ robo_repo_clone_from_server"
        echo -e "\n<enter>\n"; read dummy
        echo ""
        echo "sudo without password"
        echo "    $ config_sudo_no_password"
        echo -e "\n<enter>\n"; read dummy
    fi

    echo ""
    echo "check system"
    echo "    $ robo_system_wtf"
    echo -e "\n<enter>\n"; read dummy

    if [ "$system_flag" == "" ]; then
        echo ""
        echo "optional install"
        echo "    $ config_install_nextcloud"
        echo -e "\n<enter>\n"; read dummy
    fi

    echo "done :-)"
}
