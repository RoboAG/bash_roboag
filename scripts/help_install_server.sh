#!/bin/bash

#***************************[help]********************************************
# 2018 02 18

function robo_help_install_server() {

    if [ $# -lt 0 ] || [ $# -gt 1 ]; then
        echo "Error - robo_help_install_server needs 0-1 parameters"
        echo "       [#1]: system which will be installed"
        echo "             if used this parameter must be set to"
        echo "               \"roboag\" (default value) or \"peter\""

        return -1
    fi

    # check first parameter (system-flag)
    system_flag="roboag"
    if [ $# -gt 0 ]; then
        if [ "$1" == "roboag" ]; then
            # nothing to do :-)
            dummy=1
        elif [ "$1" == "peter" ]; then
            system_flag="peter"
        else
            echo "Error - robo_help_install_server"
            echo "       [#1]: must be \"roboag\" or \"peter\""
            return -2
        fi
    else
        echo "Warning - robo_help_install_server expects 1 parameter"
        echo "       [#1]: system which will be installed"
        echo "             (defaults to \"roboag\")"
    fi


    echo ""
    echo "### Install Server ###"
    echo ""
    echo "Operating System: Ubuntu Server 16.04.3 LTS"
    echo ""

    echo "0. Source"
    echo "  Internet:"
    echo "    https://www.ubuntu.com/download/server"
    echo -e "\n<enter>\n"; read dummy


    echo "1. GNU GRUB"
    echo "  [x] Install Ubuntu Server"
    echo "  [ ] OEM install (for manufacturers)"
    echo "  [ ] Install MAAS Region Controller"
    echo "  [ ] Install MAAS Rack Controller"
    echo "  [ ] Check disk for defects"
    echo "  [ ] Rescue a broken system"
    echo "  [ ] Boot and Install with the HWE kernel"
    echo -e "\n<enter>\n"; read dummy


    echo "2.a) Select a language"
    echo "  Language: [German - Deutsch]"
    echo -e "\n<enter>\n"; read dummy

    echo "2.b) Fortsetzen"
    echo "  Installation in der gewählten Sprache fortsetzen?"
    echo "  <Ja>"
    echo -e "\n<enter>\n"; read dummy


    echo "3. Auswählen des Standorts"
    echo "  Land oder Gebiet:"
    echo "  <Deutschland>"
    echo -e "\n<enter>\n"; read dummy


    echo "4.a) Tastatur konfigurieren"
    echo "  Tastaturmodell erkennen?"
    echo "  <Nein>"
    echo -e "\n<enter>\n"; read dummy

    echo "4.b) Tastatur konfigurieren"
    echo "  Herkunftsland der Tastatur?"
    echo "  <German>"
    echo -e "\n<enter>\n"; read dummy

    echo "4.c) Tastatur konfigurieren"
    echo "  Tastaturbelegung:"
    echo "  <German>"
    echo -e "\n<enter>\n"; read dummy


    echo "5. Zusätzliche Komponanten laden"
    echo "  ... kurz Warten"
    echo -e "\n<enter>\n"; read dummy


    echo "6. Netzwerk einrichten"
    echo "  Rechnername:"
    echo "  [?]"
    echo "    <vergeben   : Server   (RoboAG),"
    echo "                  blackbox (peter) ,"
    echo "                  flunder  (peter) >"
    #echo "    <noch offen : ?                >"
    echo -e "\n<enter>\n"; read dummy


    echo "7.a) Benutzer und Passwörter einrichten"
    echo "  Vollständiger Name des Benutzers:"
    if [ "$system_flag" == "roboag" ]; then
        echo "  [Guru]"
    else
        echo "  [Peter]"
    fi
    echo -e "\n<enter>\n"; read dummy

    echo "7.b) Benutzer und Passwörter einrichten"
    echo "  Benutzername für ihr Konto:"
    if [ "$system_flag" == "roboag" ]; then
        echo "  [guru]"
    else
        echo "  [peter]"
    fi
    echo -e "\n<enter>\n"; read dummy

    echo "7.c) Benutzer und Passwörter einrichten"
    echo "  Wählen Sie ein Passwort für den neuen Benutzer:"
    echo "  [xxx] (geheim)"
    echo -e "\n<enter>\n"; read dummy


    echo "8. Privaten Ordner verschlüsseln"
    echo "  <Nein>"
    echo -e "\n<enter>\n"; read dummy


    echo "9. Uhr einstellen"
    echo "  ... Europe/Berlin ..."
    echo "  Is this time zone correct?"
    echo "  <Ja>"
    echo -e "\n<enter>\n"; read dummy


    echo "10.0) Festplatten partitionieren"
    echo "  Aktive Partition aushängen?"
    echo "  <Ja>"
    echo -e "\n<enter>\n"; read dummy

    echo "10.a) Festplatten partitionieren"
    echo "  Partitionierungsmethode?"
    echo "  <Manuell>"
    echo -e "\n<enter>\n"; read dummy

    echo "10.b) Festplatten partitionieren"
    if [ "$system_flag" == "roboag" ]; then
        echo "  TODO"
        echo -e "\n<enter>\n"; read dummy
    else
        echo "  SSD:"
        echo "    a) System"
        echo "       Neue Größe der Partition    : <50%>"
        echo "       Typ der neuen Partition     : <Primär>"
        echo "       Position der neuen Partition: <Anfang>"
        echo "       Benutzen als       : Ext4-Journaling-Daeisystem"
        echo "       Einbindungspunkt   : /"
        echo "       Einbindungsoptionen: defaults"
        echo "       Name               : Root"
        echo "       Boot-Flag          : Ein"
        echo "    b) Swap"
        echo "       Neue Größe der Partition    : <8GB>"
        echo "       Typ der neuen Partition     : <Logisch>"
        echo "       Position der neuen Partition: <Ende>"
        echo "       Benutzen als       : Auslagerungsspeicher (Swap)"
        echo "       Boot-Flag          : Aus"
        echo "    c) Home"
        echo "       Neue Größe der Partition    : <unverändert>"
        echo "       Typ der neuen Partition     : <Logisch>"
        echo "       Position der neuen Partition: <Anfang>"
        echo "       Benutzen als       : Ext4-Journaling-Daeisystem"
        echo "       Einbindungspunkt   : /home"
        echo "       Einbindungsoptionen: defaults"
        echo "       Name               : Home"
        echo "       Boot-Flag          : Aus"
        echo -e "\n<enter>\n"; read dummy

        echo "  HD:"
        echo "    a) Data"
        echo "       Neue Größe der Partition    : <75%>"
        echo "       Typ der neuen Partition     : <Logisch>"
        echo "       Position der neuen Partition: <Anfang>"
        echo "       Benutzen als       : Ext4-Journaling-Daeisystem"
        echo "       Einbindungspunkt   : /media/data"
        echo "       Einbindungsoptionen: defaults"
        echo "       Name               : Data"
        echo "       Boot-Flag          : Aus"
        echo "    b) Share"
        echo "       Neue Größe der Partition    : <40%>"
        echo "       Typ der neuen Partition     : <Logisch>"
        echo "       Position der neuen Partition: <Anfang>"
        echo "       Benutzen als       : Ext4-Journaling-Daeisystem"
        echo "       Einbindungspunkt   : /media/share"
        echo "       Einbindungsoptionen: defaults"
        echo "       Name               : Share"
        echo "       Boot-Flag          : Aus"
        echo "    c) Internal"
        echo "       Neue Größe der Partition    : <unverändert>"
        echo "       Typ der neuen Partition     : <Logisch>"
        echo "       Position der neuen Partition: <Anfang>"
        echo "       Benutzen als       : Ext4-Journaling-Daeisystem"
        echo "       Einbindungspunkt   : /mnt/internal"
        echo "       Einbindungsoptionen: defaults"
        echo "       Name               : Internal"
        echo "       Boot-Flag          : Aus"
        echo -e "\n<enter>\n"; read dummy

        echo "10.c) Festplatten partitionieren"
        echo "  Änderungen auf die Festplatten schreiben?"
        echo "  <Ja>"
        echo -e "\n<enter>\n"; read dummy
    fi

    echo "  ... kurz Warten"
    echo -e "\n<enter>\n"; read dummy


    echo "11. Paketmanager konfigurieren"
    echo "  HTTP-Proxy-Daten (leer lassen für keinen Proxy):"
    echo "  <>"
    echo -e "\n<enter>\n"; read dummy

    echo "  ... kurz Warten"
    echo -e "\n<enter>\n"; read dummy


    echo "12. Konfiguriere tasksel"
    echo "  Wie möchten Sie Aktualisierungen auf diesem System verwalten?"
    if [ "$system_flag" == "roboag" ]; then
        echo "  <Keine automatischen Aktualisierungen>"
    else
        echo "  <Sicherheitsaktualisierungen automatisch installieren>"
    fi
    echo -e "\n<enter>\n"; read dummy

    echo "  ... kurz Warten"
    echo -e "\n<enter>\n"; read dummy


    echo "13. Softwareauswahl"
    echo "  Welche Software soll installiert werden?"
    if [ "$system_flag" == "roboag" ]; then
        echo "  [ ] Manual package selection"
        echo "  [ ] DNS server"
        echo "  [*] LAMP server"
        echo "  [ ] Mail server"
        echo "  [ ] PostgreSQL database"
        echo "  [*] Samba file server"
        echo "  [*] standard system utilities"
        echo "  [ ] Virtual Mashine host"
        echo "  [*] OpenSSH server"
    else
        echo "  [ ] Manual package selection"
        echo "  [ ] DNS server"
        echo "  [ ] LAMP server"
        echo "  [ ] Mail server"
        echo "  [ ] PostgreSQL database"
        echo "  [*] Samba file server"
        echo "  [*] standard system utilities"
        echo "  [ ] Virtual Mashine host"
        echo "  [*] OpenSSH server"
    fi
    echo -e "\n<enter>\n"; read dummy


    echo "14.a) GRUB-Bootloader auf einer Festplatte installieren"
    echo "  Den GRUB-Bootloader in den Master Boot Record installieren?"
    echo "  <Ja>"
    echo -e "\n<enter>\n"; read dummy

    echo "14.b) GRUB-Bootloader auf einer Festplatte installieren"
    echo "  Gerät für die Bootloader Installation:"
    echo "  <SSD>"
    echo -e "\n<enter>\n"; read dummy

    echo "  ... kurz Warten"
    echo -e "\n<enter>\n"; read dummy

    echo "15. Installation abschließen"
    echo "  ..."
    echo "  <Weiter>"
    echo -e "\n<enter>\n"; read dummy

    echo "Reboot"
    echo "  log into server"
    echo "  $ sudo apt-get update"
    echo "  $ sudo apt-get install ubuntu-desktop"
    echo -e "\n<enter>\n"; read dummy

    echo "done :-)"
}

