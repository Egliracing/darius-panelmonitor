#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
if ! command -v kpackagetool6 >/dev/null 2>&1; then
    echo 'kpackagetool6 fehlt. Dieses Miniprogramm benötigt KDE Plasma 6.' >&2
    exit 1
fi
if kpackagetool6 --type Plasma/Applet --show de.darius.panelmonitor >/dev/null 2>&1; then
    kpackagetool6 --type Plasma/Applet --upgrade "$PWD/package"
else
    kpackagetool6 --type Plasma/Applet --install "$PWD/package"
fi
printf '\nInstalliert. Kontrollleiste rechtsklicken → Bearbeitungsmodus → Miniprogramme hinzufügen.\nSuche: Darius Panelmonitor. Rechts neben den Infobereich ziehen.\nRechtsklick auf das Miniprogramm → Einrichten für Farben, Breite und Netzwerk.\n'
