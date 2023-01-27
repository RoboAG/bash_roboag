#!/bin/bash

#***************************[help]********************************************
# 2023 01 27

function robo_help_install() {

    # Hilfe anzeigen
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME [<system>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME benötigt 0-1 parameter"
        echo "    [#1:]System für welches die Installationsanleitung angezeigt werden soll."
        echo "         Standardwert des optionalen Parameters ist \"pc\"."
        echo "           \"pc\"         Standard-PC(client)"
        echo "           \"raspi\"      RaspberryPi(client)"
        echo "           \"server\"     Server der Roboag"
        echo "           \"togo\"       Server ToGo"
        echo ""
        echo "Hinweis: Ältere Anleitungen können weiterhin eingesehen werden:"
        echo "    $ robo_help_install_client2004"

        return
    fi

    # Parameter prüfen
    if [ $# -gt 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # ersten Parameter prüfen (system-flag)
    system_flag="client"
    server_flag=""
    if [ $# -gt 0 ]; then
        if [ "$1" == "client" ]; then
            # nothing to do :-)
            dummy=1
        elif [ "$1" == "raspi" ]; then
            system_flag="raspi"
            echo "$FUNCNAME: RaspberryPis sind noch nicht dokumentiert."
            return
        elif [ "$1" == "server" ]; then
            system_flag="server"
            server_flag="roboag"
        elif [ "$1" == "togo" ]; then
            system_flag="server"
            server_flag="togo"
        else
            echo "$FUNCNAME: Parameter Error."
            $FUNCNAME --help
            return -1
        fi
    fi

    # Hilfsmarker für Server & Client anlegen
    S=" "
    C="x"
    if [ "$server" != "" ]; then
        S="x"
        C=" "
    fi

    # Anleitung
    echo ""
    echo "### Allgemeine Installationsanleitung ###"
    echo ""
    echo "Betriebssystem: Ubuntu 20.04.1 LTS"
    echo "Quelle        : https://releases.ubuntu.com/22.04/"
    temp="${REPO_ROBOAG_DOC_INSTALL[1]}"
    if [ "$temp" != "" ]; then
        echo "  (siehe auch ${REPO_ROBOAG_DOC_INSTALL[1]})"
    fi

    echo -e "\n<Enter drücken>\n"; read dummy

    echo "Sprachauswahl"
    echo "  [...             ]"
    echo "  [Dansk           ]"
    echo " *[Deutsch         ]*   [Ubuntu ausprobieren]   *[Ubuntu installieren]* "
    echo "  [Eesti           ]"
    echo "  [English         ]"
    echo "  [...             ]"
    echo -e "\n<Enter drücken>\n"; read dummy

    echo "Tastaturbelegeung"
    echo "  [...             ]   *[German               ]*"
    echo "  [Georgian        ]    [German - German (...)]"
    echo " *[German          ]*   [German - German (...)]"
    echo "  [German (Austria)]    [German - German (...)]"
    echo "  [Greek           ]    [German - German (...)]"
    echo "  [...             ]    [...                  ]"
    echo ""
    echo "                        [Beenden]  [Zurück]   *[Weiter]*"
    echo -e "\n<Enter drücken>\n"; read dummy

    echo "Aktualisierung und andere Software"
    echo "  Welche Anwendungen möchten Sie am Anfang installieren?"
    echo "  [ ] Normale Installation"
    echo "  [x] Minimale Installation"
    echo ""
    echo "  Weitere Optionen"
    echo "  [$S] Während Ubuntu installiert wird Aktualisierungen herunterladen"
    echo "  [x] Installieren Sie Software von Drittanbietern ..."
    echo ""
    echo "                        [Beenden]  [Zurück]   *[Weiter]*"
    echo -e "\n<Enter drücken>\n"; read dummy


    echo "Installationsart"
    echo "  [$C] Festplatte löschen und Ubuntu installieren"
    echo "  [$S] Etwas Anderes"
    echo ""
    echo "                        [Beenden]  [Zurück]   *[Jetzt installieren]*"
    echo -e "\n<Enter drücken>\n"; read dummy

    if [ "$server_flag" != "" ]; then
        echo "TODO details server ..."
    fi

    echo "Änderungen auf die Festplatte schreiben"
    echo "                        [Zurück]   *[Weiter]*"
    echo -e "\n<Enter drücken>\n"; read dummy

    echo "Wo befinden Sie sich?"
    echo "  [Berlin                                  ]"
    echo "                        [Zurück]   *[Weiter]*"
    echo -e "\n<Enter drücken>\n"; read dummy


    echo "Wer sind Sie?"
    echo "                       Ihr Name: [Guru der RoboAG                 ]"
    echo "            Name Ihres Rechners: [<siehe externe Liste>           ]"
    echo "  Bitte Benutzernamen auswählen: [guru                            ]"
    echo "         Ein Passwort auswählen: [<geheim ;-)>                    ]"
    echo "           Passwort wiederholen: [<Passwort wiederholen>          ]"
    echo "                                 ( ) Automatisch anmelden"
    echo "                                 (x) Passwort zum Anmelden abfragen"
    echo "                                 [ ] Active Directory verwenden"
    echo ""
    echo "                        [Zurück]   *[Weiter]*"
    echo -e "\n<Enter drücken>\n"; read dummy

    echo ""
    echo "  ... sehr lange warten ..."
    echo -e "\n<Enter drücken>\n"; read dummy

    echo "Installation abgeschlossen"
    echo "      [Jetzt  neu starten]"
    echo -e "\n<Enter>"; read dummy

    echo "  bei Aufforderung Installationsmedium entfernen"
    echo -e "\n<Enter>"; read dummy

    echo "Fertig :-)"
    echo ""
    echo "Nächste Anleitung für die globale Konfiguration einsehen:"
    echo "    $ robo_help_setup_workspace"
}




#***************************[20.04]*******************************************
# 2023 01 27

function robo_help_install_client2004() {

    _config_simple_parameter_check "$FUNCNAME" "" \
      "shows install instructions for clients on Lubuntu 20.04."
    if [ $? -ne 0 ]; then return -1; fi

    echo ""
    echo "### Install Client - deprecated ###"
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
    echo "    [$ROBO_USER_ADMIN]"
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
    echo "    $ robo_help_setup_workspace"
}
