#!/bin/bash

#***************************[help]********************************************
# 2020 09 27

function robo_help_install() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME [<system>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 0-1 parameters"
        echo "    [#1:]system for which install instructions will be shown"
        echo "         Leave option empty to run for \"client\"."
        echo "           \"client\"     common computers (client)"
        echo "           \"raspi\"      raspberry pi     (client)"
        echo "           \"server\"     server"

        return
    fi

    # check parameter
    if [ $# -gt 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # check first parameter (system-flag)
    system_flag="client"
    if [ $# -gt 0 ]; then
        if [ "$1" == "client" ]; then
            # nothing to do :-)
            dummy=1
        elif [ "$1" == "raspi" ]; then
            system_flag="raspi"
            echo "$FUNCNAME: raspberry pis are not documented yet"
            return
        elif [ "$1" == "server" ]; then
            robo_help_install_server
            return $?
        else
            echo "$FUNCNAME: Parameter Error."
            $FUNCNAME --help
            return -1
        fi
    fi

    echo ""
    echo "### Install Client ###"
    echo ""
    echo "Operating System: Lubuntu 20.04.1 LTS"
    temp="${REPO_ROBOAG_DOC_INSTALL[1]}"
    if [ "$temp" != "" ]; then
        echo "  (see also ${REPO_ROBOAG_DOC_INSTALL[1]})"
    fi

    echo "0. Source"
    echo "  Internet:"
    echo "    https://cdimage.ubuntu.com/lubuntu/releases/20.04/release/"
    echo -e "\n<enter>\n"; read dummy

    echo "1. Select language"
    echo "    [Deutsch]"
    echo -e "\n<enter>\n"; read dummy

    echo "2. Start LiveCD"
    echo "  [x] Start Lubuntu"
    echo "  [ ] Start Lubuntu (safe graphics)"
    echo "  [ ] Arbeitsspeicher testen"
    echo "  [ ] Von der ersten Festplatte starten"
    echo -e "\n<enter>"; read dummy
    echo "  wait some time ..."
    echo -e "\n<enter>\n"; read dummy


    echo "3. Start install programm"
    echo "  on Desktop click on \"Lubuntu 20.04 LTS installieren\""
    echo -e "\n<enter>\n"; read dummy

    echo "4. Willkommen im Lubuntu Installationsprogramm."
    echo "  [Deutsch]"
    echo -e "\n<enter>\n"; read dummy

    echo "5. Standort"
    echo "  Region: [Europa]      Zeitzone: [Berlin]"
    echo -e "\n<enter>\n"; read dummy

    echo "6. Tastatur"
    echo "  Tastaturmodell: [Generic 105-key PC (intl.) - ... ]"
    echo "  [German]              [Standard]"
    echo -e "\n<enter>\n"; read dummy

    echo "7. Partitionen"
    echo "  [ ] Parallel dazu Installieren"
    echo "  [ ] Ersetze eine Partition"
    echo "  [ ] Festplatte Löschen"
    echo "  [x] Manuelle Partitionierung"
    echo -e "\n<enter>\n"; read dummy

    echo "7.a Clear harddrive"
    echo "  [Neue Partitionstabelle]"
    echo ""
    echo "  on Popup:"
    echo "      ..."
    echo "      Welchen Partitionstabellen-Typ möchten Sie erstellen ?"
    echo "      [x] Master Boot record (MBR)"
    echo "      [ ] GUID Partitions-Tabelle (GPT)"
    echo -e "\n<enter>\n"; read dummy

    echo "7.b Create Partitions"
    echo "  select free Memory (Freier Speicher)"
    echo "  click on [Erstellen]"
    echo ""
    echo "  on Popup:"
    echo "      setup size (Größe), filesystem (Dateisystem) &"
    echo "      mount point (Einhängepunkt) accordingly"
    echo ""
    echo "  repeat for all partitions"
    echo "    a) Root"
    echo "       Size (30-50G)      : 50000MiB"
    echo "       Format             : ext4"
    echo "       Mount              : /"
    echo "    b) Swap (might be skipped)"
    echo "       Size (5-10GB)      : 10000MiB"
    echo "       Format             : Linux-Swap"
    echo "    c) Home"
    echo "       Size (10-20GB)     : 20000MiB"
    echo "       Format             : ext4"
    echo "       Mount              : /home"
    echo "    d) Backup"
    echo "       Size (remaining)   :             <leave unchanged>"
    echo "       Format             : ext4"
    echo "       Mount              : /mnt/backup"
    echo -e "\n<enter>\n"; read dummy

    echo "8. Benutzer"
    echo "  Wie ist ihr Vor- und Nachname ?"
    echo "    [Guru der RoboAG]"
    echo "  Welchen Namen möchten Sie zum Anmelden benutzen ?"
    echo "    [guru]"
    echo "  Wie ist der Name dieses Computers ?"
    echo "    [Olaf]       <set name according to official list>"
    echo "  Wählen sie ein Passwort um ihr Konto zu sichern."
    echo "    [*****]             [*****]"
    echo "  [ ] Automatisches Einloggen ohne Passwortabfrage."
    echo -e "\n<enter>\n"; read dummy

    echo "9. Zusammenfassung"
    echo "  <double check settings>"
    echo ""
    echo "  on Popup:"
    echo "      ..."
    echo "      Diese Änderungen können nicht rückgängig gemacht werden."
    echo "      [Jetzt installieren]"
    echo -e "\n<enter>"; read dummy
    echo "  wait some time ..."
    echo -e "\n<enter>\n"; read dummy

    echo "10. Beenden"
    echo "  Alles erledigt."
    echo "  ..."
    echo "  [x] Jetzt Neustarten"
    echo -e "\n<enter>\n"; read dummy

    echo "11. Reboot"
    echo "  Please remove the installation medium, then press ENTER:"
    echo -e "\n<enter>\n"; read dummy

    echo "done :-)"
    echo ""
    echo "call next script for help regarding setup:"
    echo "    $ robo_help_setup"
}

