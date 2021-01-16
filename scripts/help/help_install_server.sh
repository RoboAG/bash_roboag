#!/bin/bash

#***************************[help]********************************************
# 2021 01 16

function robo_help_install_server() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME [<system>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 0-1 parameters"
        echo "    [#1:]system for which install instructions will be shown"
        echo "         Leave option empty to run for \"roboag\"."
        echo "           \"roboag\"     Server of RoboAG (and RoboSAX)"
        echo "           \"togo\"       ToGo-Server"
        echo "         Deprecated versions for Ubuntu 18.04:"
        echo "           \"roboag1804\" Server of RoboAG"
        echo "           \"togo1804\"   ToGo-Server"
        echo "         Deprecated versions for Ubuntu 16.04:"
        echo "           \"roboag1604\" Server of RoboAG"
        echo "           \"togo1604\"   ToGo-Server"

        return
    fi

    # check parameter
    if [ $# -gt 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # check first parameter (system-flag)
    system_flag="roboag"
    if [ $# -gt 0 ]; then
        # check for deprecated versions
        if [ "$1" == "roboag1804" ]; then
            robo_help_install_server1804 roboag
            return
        fi
        if [ "$1" == "togo1804" ]; then
            robo_help_install_server1804 togo
            return
        fi
        if [ "$1" == "roboag1604" ]; then
            robo_help_install_server1604 roboag
            return
        fi
        if [ "$1" == "togo1604" ]; then
            robo_help_install_server1604 togo
            return
        fi

        #check for current versions
        if [ "$1" == "roboag" ]; then
            # nothing to do :-)
            dummy=1
        elif [ "$1" == "togo" ]; then
            system_flag="togo"
        else
            echo "$FUNCNAME: Parameter Error."
            $FUNCNAME --help
            return -1
        fi
    fi

    echo ""
    echo "### Install Server ###"
    echo ""
    echo "Operating System: Ubuntu Server 20.04.1 LTS"
    echo ""

    echo "0. Source"
    echo "  Internet:"
    echo "    https://releases.ubuntu.com/20.04/"
    echo -e "\n<enter>\n"; read dummy


    echo "1. Willkommen! Bienvenue! Welcome! ..."
    echo "   ..."
    echo "   [Català   ]"
    echo "  *[Deutsch  ]*"
    echo "   [English  ]"
    echo "   ..."
    echo -e "\n<enter>\n"; read dummy


    echo "2. Installer-Aktualisierung verfügbar"
    echo "  ..."
    echo "   [Aktualisieren auf neuen Installer]"
    echo "  *[Ohne Aktualisierung fortfahren   ]*"
    echo "   [Zurück                           ]"
    echo -e "\n<enter>\n"; read dummy

    echo "3. Tastatur-Konfiguration"
    echo "  Bitte wählen Sie unten Ihr Tastaturlayout aus ..."
    echo "  Belegung:  [Deutsch]"
    echo "  Variante:  [Deutsch]"
    echo -e "\n<enter>\n"; read dummy


    echo "4. Netzwerkverbindungen"
    echo "  Konfigurieren Sie mindestens eine Schnittstelle ..."
    echo "  ..."
    echo "  <nichts zu tun - die Seite listet nur alle Schnittstellen auf>"
    echo -e "\n<enter>\n"; read dummy

    echo "5. Proxy konfigurieren"
    echo "  Wenn dieses System einen Proxy erfordert ..."
    echo "  Proxy address: [  ]"
    echo "  <nichts zu tun - Proxyadresse leer lassen>"
    echo -e "\n<enter>\n"; read dummy

    echo "6. Konfiguriere Ubuntu-Archive-Mirror"
    echo "  Wenn Sie einen ... Spiegelserver für Ubuntu verwenden ..."
    echo "  Mirror-Adresse: [http://de.archive.ubuntu.com/ubuntu]"
    echo "  <nichts zu tun - Mirror-Adresse nicht verändern>"
    echo -e "\n<enter>\n"; read dummy


    echo "7. Begleitete Speicherplatzkonfiguration"
    echo "  Configure a guided storage layout, or create a custom one:"
    echo "  [ ] Eine ganze Festplatte verwenden"
    echo "      ..."
    echo "  [x] Custom storage layout"
    echo -e "\n<enter>\n"; read dummy

    echo "7.a) Speicherplatzkonfiguration"
    if [ "$system_flag" == "roboag" ]; then
        echo "  240GB SSD:"
        echo "    a) System"
        echo "       Size (max. 222G)   : 50G"
        echo "       Format             : ext4"
        echo "       Mount              : /"
        echo "    b) Swap"
        echo "       Size (max. 172G)   : 10G"
        echo "       Format             : swap"
        echo "       Mount              : SWAP"
        echo "    c) Home"
        echo "       Size (max. 162G)   : 20G"
        echo "       Format             : ext4"
        echo "       Mount              : /home"
        echo "    d) Data"
        echo "       Size (max. 142G)   : 30G"
        echo "       Format             : ext4"
        echo "       Mount              : /mnt/data"
        echo "    e) Backup"
        echo "       Size (max. 112G)   :                 <leer lassen>"
        echo "       Format             : ext4"
        echo "       Mount              : /mnt/backup"
        echo -e "\n<enter>\n"; read dummy

        echo "FILE SYSTEM SUMMARY"
        echo "  /               50G  ext4   ..."
        echo "  /boot/efi      512M  fat32  ..."
        echo "  /home           20G  ext4   ..."
        echo "  /mnt/data       30G  ext4   ..."
        echo "  /mnt/backup    112G  ext4   ..."
        echo "  SWAP            10G  swap   ..."
    else
        echo "  120GB SSD:"
        echo "    a) System"
        echo "       Size (max. 111G)   : 50G"
        echo "       Format             : ext4"
        echo "       Mount              : /"
        echo "    b) Swap"
        echo "       Size (max.  72G)   : 10G"
        echo "       Format             : swap"
        echo "       Mount              : SWAP"
        echo "    c) Home"
        echo "       Size (max.  62G)   :             <leer lassen>"
        echo "       Format             : ext4"
        echo "       Mount              : /home"
        echo -e "\n<enter>\n"; read dummy

        echo "  1TB HDD:"
        echo "    a) Data"
        echo "       Size (max. 931G)   : 750G        <ca. 75%>"
        echo "       Format             : ext4"
        echo "       Mount              : /media/data"
        echo "    b) Share"
        echo "       Size (max. 181G)   : 100G        <ca. 10%>"
        echo "       Format             : ext4"
        echo "       Mount              : /media/share"
        echo "    c) Internal"
        echo "       Size (max.  81G)   :             <leer lassen>"
        echo "       Format             : ext4"
        echo "       Mount              : /mnt/internal"
        echo -e "\n<enter>\n"; read dummy

        echo "FILE SYSTEM SUMMARY"
        echo "  /               50G  ext4   ..."
        echo "  /boot/efi      512M  fat32  ..."
        echo "  /home           51G  ext4   ..."
        echo "  /media/data    750G  ext4   ..."
        echo "  /media/share   100G  ext4   ..."
        echo "  /mnt/internal   81G  ext4   ..."
        echo "  SWAP            10G  swap   ..."
    fi
    echo ""
    echo "AVAILABLE DEVICES"
    echo ""
    echo "USED DEVICES"
    echo "  ... <ähnlich zu file system summary>"

    echo -e "\n<enter>\n"; read dummy

    echo "7.b) Bestätigung der destruktiven Aktionen"
    echo "  Selecting Continue below will begin the Installation ..."
    echo "  You will not be able to return ..."
    echo "  Are you sure you want to continue ?"
    echo "    [Nein      ]"
    echo "   *[Fortfahren]*"
    echo -e "\n<enter>\n"; read dummy


    echo "8. Profileinrichtung"
    echo "  Geben Sie den Benutzernamen und das Passwort ein ..."
    if [ "$system_flag" == "roboag" ]; then
        echo "  Ihr Name               : Guru der RoboAG"
        echo "  Name Ihres Servers     : server"
        echo "  Benutzernamen auswählen: guru"
    else
        echo "  Your name             : Peter       <beliebig>"
        echo "  Your server's name    : blackbox    <beliebig>"
        echo "  Pick a username       : peter       <beliebig>"
    fi
    echo "  Passwort auswählen    : xxx"
    echo "  Passwort bestätigen   : xxx"
    echo -e "\n<enter>\n"; read dummy

    echo "9. SSH-Einrichtung"
    echo "  Sie können auswählen das OpenSSH-Server-Paket zu installieren..."
    echo "    [x] OpenSSH-Server installieren"
    echo "    SSH-Identität importieren: [Nein]"
    echo -e "\n<enter>\n"; read dummy

    echo "10. Unterstützte Server-Snaps"
    echo "  Dies sind beliebte Snaps in Serverumgebungen ..."
    if [ "$system_flag" == "roboag" ]; then
        echo "  [ ] ..."
        echo "  <alle Optionen leer lassen>"
    else
        echo "  [ ] ..."
        echo "  [x] minidlna-escoand"
    fi
    echo -e "\n<enter>\n"; read dummy


    echo "11. Installation des Grundsystems"
    echo "  ..."
    echo "  final system configuration"
    echo "    ..."
    echo "  downloading and installing security updates"
    echo "    ..."
    echo "  [Neustart]"
    echo -e "\n<enter>\n"; read dummy


    echo "12. Reboot"
    echo "  <etwas warten>"
    echo "  Please remove the installation medium, then press ENTER:"
    echo "  <Installationsmedium entfernen und enter drücken>"
    echo -e "\n<enter>\n"; read dummy


    echo "13. Update"
    echo "  <wegen laufender Nachinstallationen eine Weile warten>"
    echo "  <in den Server einloggen>"
    echo "  $ sudo apt update"
    echo "  $ sudo apt upgrade --yes && sudo apt dist-upgrade --yes"
    echo "  <es kann eine Weile dauern bis die Updates durch sind>"
    echo "  $ sudo apt install ubuntu-desktop"
    echo "  <die Installation dauert meist sehr lange>"
    echo "  $ sudo reboot"
    echo -e "\n<enter>\n"; read dummy

    echo "14. Weiteres"
    echo "  Für die weitere Einrichtung des Rechners sollten die folgenden"
    echo "  Skripte auf den neuen Rechner genutzt werden:"
    echo "    $ robo_help_setup_workspace_shared"
    echo "    $ robo_help_setup server"

    echo "done :-)"
}

#***************************[18.04]*******************************************
# 2021 01 16

function robo_help_install_server1804() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME [<system>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 0-1 parameters"
        echo "    [#1:]system for which install instructions will be shown"
        echo "         Leave option empty to run for \"roboag\"."
        echo "           \"roboag\"  Server of RoboAG (and RoboSAX)"
        echo "           \"togo\"    ToGo-Server"

        return
    fi

    # check parameter
    if [ $# -gt 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # check first parameter (system-flag)
    system_flag="roboag"
    if [ $# -gt 0 ]; then
        #check for current versions
        if [ "$1" == "roboag" ]; then
            # nothing to do :-)
            dummy=1
        elif [ "$1" == "togo" ]; then
            system_flag="togo"
        else
            echo "$FUNCNAME: Parameter Error."
            $FUNCNAME --help
            return -1
        fi
    fi

    echo ""
    echo "### Install Server ###"
    echo ""
    echo "Operating System: Ubuntu Server 18.04.1 LTS"
    echo ""

    echo "0. Source"
    echo "  Internet:"
    echo "    https://releases.ubuntu.com/18.04/"
    echo -e "\n<enter>\n"; read dummy


    echo "1. GNU GRUB"
    echo "  [x] Install Ubuntu Server"
    echo "  [ ] OEM install (for manufacturers)"
    echo "  [ ] Check disk for defects"
    echo -e "\n<enter>\n"; read dummy


    echo "2. Select language (1/11)"
    echo "  Please choose your preferred language."
    echo "    [Deutsch]"
    echo -e "\n<enter>\n"; read dummy

    echo "3. Keyboard configuration (2/11)"
    echo "  Please select your keyboard layout below, ..."
    echo "  Layout   [Deutsch]"
    echo "  Variant  [Deutsch]"
    echo -e "\n<enter>\n"; read dummy


    echo "4. Ubuntu 18.04 (3/11)"
    echo "  Welcome to Ubuntu! The world's favourite platform for ..."
    echo "    [Install Ubuntu]"
    echo -e "\n<enter>\n"; read dummy


    echo "5. Network connections (4/11)"
    echo "  Configure at least one interface this server can use ..."
    if [ "$system_flag" == "roboag" ]; then
        echo "    enp63s0"
    else
        echo "    enp1s0"
        echo "    enp4s0"
    fi
    echo -n "  <nothing todo - this page just lists all available ethernet "
    echo "connections>"
    echo -e "\n<enter>\n"; read dummy

    echo "6. Configure proxy (5/11)"
    echo "  If this system requires a proxy to connect to the internet, ..."
    echo "  Proxy address: [  ]"
    echo "  <nothing todo - leave proxy address empty>"
    echo -e "\n<enter>\n"; read dummy

    echo "7. Configure Ubuntu archive mirror (6/11)"
    echo "  If you use an alternative mirror for Ubuntu, ..."
    echo "  Mirror address: [http://archive.ubuntu.com/ubuntu]"
    echo "  <nothing todo - leave mirror address as it is>"
    echo -e "\n<enter>\n"; read dummy


    echo "8. Dateisystem einrichten (7/11)"
    echo "  The installer can guide you though partitioning ..."
    echo "  [Manual]"
    echo -e "\n<enter>\n"; read dummy

    echo "8.a) Dateisystem einrichten (7/11)"
    echo "  SSD:"
    echo "    a) System"
    echo "       Size (max. 111G)   : 50G         <ca. 45%>"
    echo "       Format             : ext4"
    echo "       Mount              : /"
    echo "    b) Swap"
    echo "       Size (max.  61G)   : 10G"
    echo "       Format             : swap"
    echo "       Mount              : SWAP"
    echo "    c) Home"
    echo "       Size (max.  51G)   :             <leave empty>"
    echo "       Format             : ext4"
    echo "       Mount              : /home"
    echo -e "\n<enter>\n"; read dummy

    if [ "$system_flag" == "roboag" ]; then
        echo "  HDD:"
        echo "    a) Data"
        echo "       Size (max. 232G)   : 50G"
        echo "       Format             : ext4"
        echo "       Mount              : /media/data"
        echo "    b) Backup"
        echo "       Size (max. 182G)   :             <leave empty>"
        echo "       Format             : ext4"
        echo "       Mount              : /media/backup"
        echo -e "\n<enter>\n"; read dummy

        echo "FILE SYSTEM SUMMARY"
        echo "  /               50G  ext4   ..."
        echo "  /boot/efi      512M  fat32  ..."
        echo "  /home           51G  ext4   ..."
        echo "  /media/data     50G  ext4   ..."
        echo "  /media/backup  182G  ext4   ..."
        echo "  SWAP            10G  swap   ..."
    else
        echo "  HDD:"
        echo "    a) Data"
        echo "       Size (max. 931G)   : 750G        <ca. 75%>"
        echo "       Format             : ext4"
        echo "       Mount              : /media/data"
        echo "    b) Share"
        echo "       Size (max. 181G)   : 100G        <ca. 10%>"
        echo "       Format             : ext4"
        echo "       Mount              : /media/share"
        echo "    c) Internal"
        echo "       Size (max.  81G)   :             <leave empty>"
        echo "       Format             : ext4"
        echo "       Mount              : /mnt/internal"
        echo -e "\n<enter>\n"; read dummy

        echo "FILE SYSTEM SUMMARY"
        echo "  /               50G  ext4   ..."
        echo "  /boot/efi      512M  fat32  ..."
        echo "  /home           51G  ext4   ..."
        echo "  /media/data    750G  ext4   ..."
        echo "  /media/share   100G  ext4   ..."
        echo "  /mnt/internal   81G  ext4   ..."
        echo "  SWAP            10G  swap   ..."
    fi
    echo ""
    echo "AVAILABLE DEVICES"
    echo ""
    echo "USED DEVICES"
    echo "  ... <similar to file system summary>"

    echo -e "\n<enter>\n"; read dummy

    echo "8.b) Confirm destructive action"
    echo "  Selecting Continue below will begin the Installation ..."
    echo "  You will not be able to return ..."
    echo "  Are you sure you want to continue ?"
    echo "    [Continue]"
    echo -e "\n<enter>\n"; read dummy


    echo "9. Profil setup (9/11)"
    echo "  Enter the username and password ..."
    if [ "$system_flag" == "roboag" ]; then
        echo "  Your name             : Guru der RoboAG"
        echo "  Your server's name    : server"
        echo "  Pick a username       : guru"
    else
        echo "  Your name             : Peter     <beliebig>"
        echo "  Your server's name    : blackbox"
        echo "  Pick a username       : peter     <beliebig>"
    fi
    echo "  Choose a password     : xxx"
    echo "  Confirm your password : xxx"
    echo "  Import SSH identity   : [No]"
    echo -e "\n<enter>\n"; read dummy

    echo "10. Featured Server Snaps (9/11)"
    echo "  These are popular snaps in server environments. ..."
    if [ "$system_flag" == "roboag" ]; then
        echo "  [ ] ..."
        echo "  <leave all options unchecked>"
    else
        echo "  [ ] ..."
        echo "  [x] minidlna-escoand"
    fi
    echo -e "\n<enter>\n"; read dummy


    echo "11. Install complete (11/11)"
    echo "  --Finished install!--"
    echo "  ..."
    echo "  <nothing todo - this page just lists every step done>"
    echo "  [Reboot Now]"
    echo -e "\n<enter>\n"; read dummy


    echo "12. Reboot"
    echo "  <wait some time>"
    echo "  Please remove the installation medium, then press ENTER:"
    echo "  <do as written ;-)>"
    echo -e "\n<enter>\n"; read dummy


    echo "13. Update"
    echo "  <wait some time for final installations>"
    echo "  log into server"
    echo "  $ sudo apt update"
    echo "  $ sudo apt upgrade && sudo apt dist-upgrade"
    echo "  <wait some time for the updates to be done>"
    echo "  $ sudo apt install ubuntu-desktop"
    echo "  <wait some time for the installation to be done>"
    echo "  $ sudo reboot"
    echo -e "\n<enter>\n"; read dummy

    echo "14. Config"
    echo "  for further configuration and setup see"
    echo "  $ robo_help_setup_workspace_shared"
    echo "  $ robo_help_setup server"

    echo "done :-)"
}



#***************************[16.04]*******************************************
# 2020 12 30

function robo_help_install_server1604() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME [<system>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 0-1 parameters"
        echo "    [#1:]system for which install instructions will be shown"
        echo "         Leave option empty to run for \"roboag\"."
        echo "           \"roboag\"  Server of RoboAG (and RoboSAX)"
        echo "           \"togo\"    ToGo-Server"

        return
    fi

    # check parameter
    if [ $# -gt 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # check first parameter (system-flag)
    system_flag="roboag"
    if [ $# -gt 0 ]; then
        if [ "$1" == "roboag" ]; then
            # nothing to do :-)
            dummy=1
        elif [ "$1" == "togo" ]; then
            system_flag="togo"
        else
            echo "$FUNCNAME: Parameter Error."
            $FUNCNAME --help
            return -1
        fi
    fi

    echo ""
    echo "### Install Server ###"
    echo ""
    echo "Operating System: Ubuntu Server 16.04.3 LTS"
    echo ""

    echo "0. Source"
    echo "  Internet:"
    echo "    https://releases.ubuntu.com/16.04/"
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
    echo "  [server]"
    echo -e "\n<enter>\n"; read dummy


    echo "7.a) Benutzer und Passwörter einrichten"
    echo "  Vollständiger Name des Benutzers:"
    if [ "$system_flag" == "roboag" ]; then
        echo "  [Guru]"
    else
        echo "  [Peter]    <beliebig>"
    fi
    echo -e "\n<enter>\n"; read dummy

    echo "7.b) Benutzer und Passwörter einrichten"
    echo "  Benutzername für ihr Konto:"
    if [ "$system_flag" == "roboag" ]; then
        echo "  [guru]"
    else
        echo "  [peter]    <beliebig>"
    fi
    echo -e "\n<enter>\n"; read dummy

    echo "7.c) Benutzer und Passwörter einrichten"
    echo "  Wählen Sie ein Passwort für den neuen Benutzer:"
    echo "  [xxx]    <geheim>"
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
        echo "    ~ToDo~"
        echo -e "\n<enter>\n"; read dummy
    else
        echo "  SSD:"
        echo "    a) System"
        echo "       Neue Größe der Partition    : <50%>"
        echo "       Typ der neuen Partition     : <Primär>"
        echo "       Position der neuen Partition: <Anfang>"
        echo "       Benutzen als       : Ext4-Journaling-Dateisystem"
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
        echo "       Benutzen als       : Ext4-Journaling-Dateisystem"
        echo "       Einbindungspunkt   : /home"
        echo "       Einbindungsoptionen: defaults"
        echo "       Name               : Home"
        echo "       Boot-Flag          : Aus"
        echo -e "\n<enter>\n"; read dummy

        echo "  HDD:"
        echo "    a) Data"
        echo "       Neue Größe der Partition    : <75%>"
        echo "       Typ der neuen Partition     : <Logisch>"
        echo "       Position der neuen Partition: <Anfang>"
        echo "       Benutzen als       : Ext4-Journaling-Dateisystem"
        echo "       Einbindungspunkt   : /media/data"
        echo "       Einbindungsoptionen: defaults"
        echo "       Name               : Data"
        echo "       Boot-Flag          : Aus"
        echo "    b) Share"
        echo "       Neue Größe der Partition    : <40%>"
        echo "       Typ der neuen Partition     : <Logisch>"
        echo "       Position der neuen Partition: <Anfang>"
        echo "       Benutzen als       : Ext4-Journaling-Dateisystem"
        echo "       Einbindungspunkt   : /media/share"
        echo "       Einbindungsoptionen: defaults"
        echo "       Name               : Share"
        echo "       Boot-Flag          : Aus"
        echo "    c) Internal"
        echo "       Neue Größe der Partition    : <unverändert>"
        echo "       Typ der neuen Partition     : <Logisch>"
        echo "       Position der neuen Partition: <Anfang>"
        echo "       Benutzen als       : Ext4-Journaling-Dateisystem"
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
    echo "  $ sudo apt update"
    echo "  $ sudo apt install ubuntu-desktop"
    echo -e "\n<enter>\n"; read dummy

    echo "done :-)"
}

