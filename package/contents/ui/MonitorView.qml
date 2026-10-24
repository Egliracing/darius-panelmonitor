import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

Item {
    id: view
    required property var settings
    required property var readings
    property bool verticalPanel: false
    implicitWidth: verticalPanel ? 32 : settings.width
    implicitHeight: verticalPanel ? settings.width : 32
    // The panel owns our height; compact panels automatically use a single row.
    readonly property bool singleRow: !verticalPanel && (settings.oneLine || height < 40)
    readonly property real verticalPadding: (verticalPanel ? width : height) < 40 ? 1 : 3
    readonly property real barSpace: settings.showBars ? 4 : 0
    readonly property int valuePixels: Math.max(6, Math.min(
        Math.round(settings.fontSize * 96 / 72),
        Math.floor(verticalPanel ? (width - 8) / 2.8 : (height - 2 * verticalPadding - barSpace) / (singleRow ? 1.3 : 2.4))))
    readonly property int titlePixels: Math.max(6, Math.floor(valuePixels * 0.78))
    readonly property bool anyVisible: settings.showCpu || settings.showRam || settings.showNetwork

    component Metric: Item {
        id: metric
        required property string title
        required property string valueText
        required property color accent
        property real percent: -1
        property bool network: false
        readonly property int fittedPixels: view.verticalPanel
            ? Math.max(5, Math.min(view.valuePixels, Math.floor(width / 4.3), Math.floor((height - view.titlePixels - 6) / (network ? 5 : (view.settings.ramMode === 1 ? 4 : 2))))) : view.valuePixels
        readonly property string displayText: view.verticalPanel
            ? (network ? valueText.replace("   ↑ ", "\n↑ ").replace(/ (Mbit\/s|kbit\/s|MB\/s|KiB\/s|B\/s|MiB\/s|GiB\/s|TiB\/s)/g, "\n$1") : valueText.replace(" / ", "\n/\n").replace(/ (GB|GiB)$/, "\n$1")) : valueText
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredWidth: network ? 220 : 80
        Layout.preferredHeight: view.verticalPanel ? (network ? 160 : 100) : -1
        clip: true
        Accessible.role: Accessible.StaticText
        Accessible.name: title + " " + valueText
        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -view.barSpace / 2
            width: parent.width
            spacing: 1
            visible: !view.singleRow
            QQC2.Label {
                text: metric.title; color: metric.accent
                font.pixelSize: view.titlePixels
                font.weight: Font.DemiBold; width: parent.width
                horizontalAlignment: Text.AlignHCenter
            }
            QQC2.Label {
                text: metric.displayText; color: Kirigami.Theme.textColor; font.pixelSize: metric.fittedPixels
                font.weight: Font.DemiBold; width: parent.width
                horizontalAlignment: Text.AlignHCenter
                elide: view.verticalPanel ? Text.ElideNone : Text.ElideRight
                wrapMode: view.verticalPanel ? Text.Wrap : Text.NoWrap
            }
        }
        QQC2.Label {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -view.barSpace / 2
            width: parent.width
            visible: view.singleRow
            text: metric.title + " " + metric.valueText
            color: metric.accent; font.pixelSize: view.valuePixels
            horizontalAlignment: Text.AlignHCenter; elide: Text.ElideRight
            fontSizeMode: Text.HorizontalFit; minimumPixelSize: 6
        }
        Rectangle {
            visible: view.settings.showBars && metric.percent >= 0
            anchors { bottom: parent.bottom; left: parent.left; right: parent.right; leftMargin: 5; rightMargin: 5; bottomMargin: 1 }
            height: 2; radius: 1; color: Qt.rgba(metric.accent.r, metric.accent.g, metric.accent.b, 0.18)
            Rectangle {
                width: parent.width * Math.max(0, Math.min(100, metric.percent)) / 100
                height: parent.height; radius: 1; color: metric.accent
                Behavior on width { NumberAnimation { duration: 180 } }
            }
        }
    }
    GridLayout {
        columns: view.verticalPanel ? 1 : 3
        anchors.fill: parent
        anchors.leftMargin: 4
        anchors.rightMargin: 4
        anchors.topMargin: view.verticalPadding
        anchors.bottomMargin: view.verticalPadding
        columnSpacing: view.verticalPanel ? 0 : 12
        rowSpacing: view.verticalPanel ? 8 : 0
        Metric {
            visible: view.settings.showCpu && (view.settings.cpuMode || 0) === 0; title: "CPU"
            valueText: view.readings.cpuText; percent: view.readings.cpuPercent
            accent: view.settings.cpuColor
        }
        Item {
            id: coreGroup
            visible: view.settings.showCpu && view.settings.cpuMode === 1
            Layout.fillWidth: true; Layout.fillHeight: true
            Layout.preferredWidth: Math.min(400, Math.max(100, view.readings.coreValues.length * 36))
            Layout.preferredHeight: view.verticalPanel ? Math.max(80, view.readings.coreValues.length * 20) : -1
            Accessible.role: Accessible.StaticText
            Accessible.name: "CPU " + view.readings.coreText
            QQC2.Label {
                id: coreHeading
                anchors.left: parent.left
                anchors.verticalCenter: view.verticalPanel ? undefined : parent.verticalCenter
                anchors.top: view.verticalPanel ? parent.top : undefined
                width: view.verticalPanel ? parent.width : implicitWidth
                horizontalAlignment: Text.AlignHCenter
                text: "CPU"; color: view.settings.cpuColor; font.pixelSize: view.titlePixels
            }
            Grid {
                id: coreGrid
                columns: view.verticalPanel ? Math.max(1, Math.floor(width / 23)) : Math.max(1, view.readings.coreValues.length)
                anchors { left: view.verticalPanel ? parent.left : coreHeading.right; leftMargin: view.verticalPanel ? 0 : 5; right: parent.right; top: view.verticalPanel ? coreHeading.bottom : parent.top; bottom: parent.bottom }
                spacing: 2
                Repeater {
                    model: view.readings.coreValues
                    delegate: Item {
                        id: core
                        required property int index
                        required property real modelData
                        width: Math.max(1, (parent.width - (coreGrid.columns - 1) * 2) / coreGrid.columns)
                        height: view.verticalPanel ? Math.max(1, (parent.height - (Math.ceil(view.readings.coreValues.length / coreGrid.columns) - 1) * 2) / Math.max(1, Math.ceil(view.readings.coreValues.length / coreGrid.columns))) : parent.height
                        Accessible.role: Accessible.StaticText
                        Accessible.name: "CPU " + (index + 1) + ": " + (modelData >= 0 ? Math.round(modelData) + " %" : "—")
                        Rectangle {
                            anchors.fill: parent; radius: 2
                            color: view.settings.cpuColor; opacity: 0.15
                        }
                        Rectangle {
                            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                            height: parent.height * Math.max(0, core.modelData) / 100
                            radius: 2; color: view.settings.cpuColor; opacity: 0.5
                        }
                        QQC2.Label {
                            anchors.top: parent.top; anchors.horizontalCenter: parent.horizontalCenter
                            visible: !view.verticalPanel && !view.singleRow && core.width >= 16
                            text: "C" + (core.index + 1)
                            font.pixelSize: view.titlePixels
                            color: Kirigami.Theme.textColor
                        }
                        QQC2.Label {
                            anchors.centerIn: parent
                            visible: core.width >= 23
                            text: core.modelData >= 0 ? Math.round(core.modelData) + "%" : "—"
                            font.pixelSize: Math.min(view.valuePixels, core.width / 2.3, core.height / 1.4)
                            color: Kirigami.Theme.textColor
                        }
                        HoverHandler { id: coreHover }
                        QQC2.ToolTip.visible: coreHover.hovered
                        QQC2.ToolTip.text: core.Accessible.name
                    }
                }
            }
        }
        Metric {
            visible: view.settings.showRam; title: "RAM"
            valueText: view.readings.ramText; percent: view.readings.ramPercent
            accent: view.settings.ramColor
        }
        Metric {
            visible: view.settings.showNetwork; title: i18n("NET"); network: true
            valueText: view.readings.networkText
            accent: view.settings.netColor
        }
        QQC2.Label {
            visible: !view.anyVisible; text: i18n("Panelmonitor · configure the display")
            Layout.fillWidth: true; horizontalAlignment: Text.AlignHCenter
            color: Kirigami.Theme.disabledTextColor
        }
    }
}

