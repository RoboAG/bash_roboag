#!/bin/bash

#***************************[help]********************************************
# 2021 08 12

function robo_help_user() {

    echo "### ROBOAG ###"
    echo ""

    echo "  $ robolib_init_kepler # Legt die Konfig für das Keplerboard an"
    echo "  $ robolib_init_3pi    # Legt die Konfig für einen 3Pi an"
    echo ""
    echo "  $ robolib_all         # Kompiliert im aktuellen Ordner"
    echo "  $ robolib_clean       # Entfernt alle Kompilierartefakte"
    echo ""
    echo "  $ robolib_avrdude     # Avrdude zum Herunterladen (3Pi, ISP)"
    echo "  $ robolib_download    # Robolib-Downloader (RS232 & Bootloader)"
    echo ""
    echo "  $ robolib_data        # Einfacher Datanaustausch (RS232)"
    echo ""
}
