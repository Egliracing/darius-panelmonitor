import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: page
    property alias cfg_showCpu: cpu.checked
    property alias cfg_showRam: ram.checked
    property alias cfg_showNetwork: net.checked
    property alias cfg_showBars: bars.checked
    property alias cfg_oneLine: single.checked
    property alias cfg_fontSize: fontSize.value
    property alias cfg_width: panelWidth.value
    property alias cfg_updateMs: interval.value
    property alias cfg_interfaceName: iface.text
    property alias cfg_cpuMode: cpuMode.currentIndex
    property alias cfg_ramMode: ramMode.currentIndex
    property alias cfg_ramUnit: ramUnit.currentIndex
    property alias cfg_netUnit: netUnit.currentIndex
    property alias cfg_cpuColor: cpuColor.colorValue
    property alias cfg_ramColor: ramColor.colorValue
    property alias cfg_netColor: netColor.colorValue

    QQC2.CheckBox { id: cpu; Kirigami.FormData.label: i18n("Show:"); text: i18n("CPU usage") }
    QQC2.CheckBox { id: ram; text: i18n("RAM usage") }
    QQC2.CheckBox { id: net; text: i18n("Download and upload") }
    QQC2.CheckBox { id: bars; Kirigami.FormData.label: i18n("Appearance:"); text: i18n("Usage bars for CPU and RAM") }
    QQC2.CheckBox { id: single; text: i18n("Always use one row (automatic in small panels)") }
    QQC2.ComboBox {
        implicitContentWidthPolicy: QQC2.ComboBox.WidestText
        id: cpuMode; Kirigami.FormData.label: i18n("CPU mode:")
        model: [i18n("Total usage (%)"), i18n("All logical CPUs (per-core bars)")]
    }
    QQC2.ComboBox {
        implicitContentWidthPolicy: QQC2.ComboBox.WidestText
        id: ramMode; Kirigami.FormData.label: i18n("Memory mode:")
        model: [i18n("Percentage"), i18n("Used / total"), i18n("Used memory only")]
    }
    QQC2.ComboBox {
        implicitContentWidthPolicy: QQC2.ComboBox.WidestText
        id: ramUnit; Kirigami.FormData.label: i18n("Memory unit:")
        model: ["GiB (1024³ bytes)", "GB (1000³ bytes)"]; enabled: ramMode.currentIndex !== 0
    }
    QQC2.ComboBox {
        implicitContentWidthPolicy: QQC2.ComboBox.WidestText
        id: netUnit; Kirigami.FormData.label: i18n("Network unit:")
        model: ["Mbit/s", "kbit/s", "MB/s", "KiB/s", i18n("Automatic (B/s, KiB/s, MiB/s…)")]
    }
    QQC2.SpinBox { id: fontSize; Kirigami.FormData.label: i18n("Maximum font size (pt):"); from: 8; to: 24 }
    QQC2.SpinBox { id: panelWidth; Kirigami.FormData.label: i18n("Length along the panel (pixels):"); from: 240; to: 900; stepSize: 10 }
    QQC2.SpinBox { id: interval; Kirigami.FormData.label: i18n("Update limit (ms):"); from: 1000; to: 10000; stepSize: 1000 }
    QQC2.TextField {
        id: iface; Kirigami.FormData.label: i18n("Network interface:")
        placeholderText: i18n("Automatic — leave empty")
        validator: RegularExpressionValidator { regularExpression: /[a-zA-Z0-9_.:-]*/ }
    }
    QQC2.Label {
        Layout.maximumWidth: 390; wrapMode: Text.WordWrap
        text: i18n("Leave empty to select a connected Ethernet interface, or Wi-Fi if no Ethernet is connected. Enter an interface name to override; enter all to sum every interface (may count container traffic more than once).")
    }

    QQC2.Label {
        Layout.maximumWidth: 390; wrapMode: Text.WordWrap
        text: i18n("Rates include local network traffic. This is not an Internet speed test. Missing sensors are shown as —.")
    }
    ColorField { id: cpuColor; Kirigami.FormData.label: i18n("CPU color:") }
    ColorField { id: ramColor; Kirigami.FormData.label: i18n("RAM color:") }
    ColorField { id: netColor; Kirigami.FormData.label: i18n("Network color:") }
}

