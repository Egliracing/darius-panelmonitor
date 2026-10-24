import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore

PlasmoidItem {
    id: root
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: compactRepresentation
    toolTipMainText: "Darius Panelmonitor"
    toolTipSubText: sensorData.statusText
    switchWidth: 0
    switchHeight: 0
    MonitorData { id: sensorData; settings: Plasmoid.configuration }
    compactRepresentation: MonitorView {
        anchors.fill: parent
        verticalPanel: Plasmoid.formFactor === PlasmaCore.Types.Vertical
        settings: Plasmoid.configuration; readings: sensorData
        Layout.minimumWidth: verticalPanel ? 0 : Plasmoid.configuration.width
        Layout.preferredWidth: verticalPanel ? 32 : Plasmoid.configuration.width
        Layout.maximumWidth: verticalPanel ? Infinity : Plasmoid.configuration.width
        Layout.minimumHeight: verticalPanel ? Plasmoid.configuration.width : 0
        Layout.maximumHeight: verticalPanel ? Plasmoid.configuration.width : Infinity
        Layout.fillHeight: true
    }
    fullRepresentation: MonitorView {
        anchors.fill: parent
        verticalPanel: Plasmoid.formFactor === PlasmaCore.Types.Vertical
        settings: Plasmoid.configuration; readings: sensorData
        Layout.minimumWidth: Plasmoid.configuration.width
        Layout.minimumHeight: 24
    }
}

