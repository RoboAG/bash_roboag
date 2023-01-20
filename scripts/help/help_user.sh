#!/bin/bash

#***************************[help]********************************************
# 2023 01 20

function robo_help_user() {

    echo    "### ROBOAG ###"
    echo    ""

    echo    "robolib"
    echo -n "  $ robolib_init_kepler        # Legt die Konfig für das"
    echo                                    " Keplerboard an"
    echo -n "  $ robolib_init_3pi           # Legt die Konfig für einen"
    echo                                    " 3Pi an"
    echo    ""
    echo    "  $ robolib_build [mcu]        # Kompiliert im aktuellen Ordner"
    echo -n "  $ robolib_clean              # Entfernt alle "
    echo                                    " Kompilierartefakte"
    echo    ""
    echo -n "  $ robolib_avrdude [comport]  # Avrdude zum Herunterladen"
    echo                                    " (3Pi, ISP)"
    echo -n "  $ robolib_download [comport] # Robolib-Downloader"
    echo                                    " (RS232 & Bootloader)"
    echo    ""
    echo -n "  $ robolib_data [comport]     # Einfacher Datanaustausch"
    echo                                    " (RS232)"
    echo    ""
    echo    ""

    echo    "Open-Roberta-Lab"
    echo    "  $ robo_orlab_connect         # Connector zum Herunterladen"
    echo    ""
}
