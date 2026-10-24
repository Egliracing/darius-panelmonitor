import QtQml
import org.kde.ksysguard.sensors as Sensors

QtObject {
    id: data
    required property var settings
    readonly property int cpuMode: settings.cpuMode || 0
    readonly property int ramMode: settings.ramMode || (settings.ramInGiB ? 2 : 0)
    readonly property int ramUnit: settings.ramUnit || 0
    readonly property int netUnit: settings.netUnit || 0
    property var coreValues: []
    property Sensors.Sensor cpuCount: Sensors.Sensor {
        sensorId: "cpu/all/coreCount"; enabled: data.settings.showCpu && data.cpuMode === 1
    }
    property Instantiator coreSensors: Instantiator {
        model: data.settings.showCpu && data.cpuMode === 1 && data.valid(data.cpuCount)
            ? Math.max(0, Number(data.cpuCount.value)) : 0
        delegate: Sensors.Sensor {
            required property int index
            sensorId: "cpu/cpu" + index + "/usage"
            enabled: true; updateRateLimit: data.settings.updateMs
            onValueChanged: data.refreshCores()
            onStatusChanged: data.refreshCores()
        }
        onObjectAdded: data.refreshCores()
        onObjectRemoved: data.refreshCores()
    }
    function refreshCores() {
        let values = [];
        for (let i = 0; i < coreSensors.count; ++i) {
            const sensor = coreSensors.objectAt(i);
            values.push(sensor ? percent(sensor) : -1);
        }
        coreValues = values;
    }
    property NetworkSource network: NetworkSource { requestedInterface: data.settings.interfaceName }
    readonly property string networkPrefix: network.selectedInterface ? "network/" + network.selectedInterface + "/" : ""
    readonly property string selectedInterface: network.selectedInterface
    property Sensors.Sensor cpu: Sensors.Sensor {
        sensorId: "cpu/all/usage"; enabled: data.settings.showCpu
        updateRateLimit: data.settings.updateMs
    }
    property Sensors.Sensor ram: Sensors.Sensor {
        sensorId: "memory/physical/usedPercent"; enabled: data.settings.showRam
        updateRateLimit: data.settings.updateMs
    }
    property Sensors.Sensor ramUsed: Sensors.Sensor {
        sensorId: "memory/physical/used"; enabled: data.settings.showRam && data.ramMode !== 0
        updateRateLimit: data.settings.updateMs
    }
    property Sensors.Sensor ramTotal: Sensors.Sensor {
        sensorId: "memory/physical/total"; enabled: data.settings.showRam && data.ramMode !== 0
        updateRateLimit: data.settings.updateMs
    }
    property Sensors.Sensor download: Sensors.Sensor {
        sensorId: data.networkPrefix ? data.networkPrefix + "download" : ""
        enabled: data.settings.showNetwork && data.networkPrefix !== ""; updateRateLimit: data.settings.updateMs
    }
    property Sensors.Sensor upload: Sensors.Sensor {
        sensorId: data.networkPrefix ? data.networkPrefix + "upload" : ""
        enabled: data.settings.showNetwork && data.networkPrefix !== ""; updateRateLimit: data.settings.updateMs
    }
    function valid(sensor) {
        return sensor.status === Sensors.Sensor.Ready && sensor.value !== undefined && sensor.value !== null && isFinite(Number(sensor.value));
    }
    function percent(sensor) {
        return valid(sensor) ? Math.max(0, Math.min(100, Number(sensor.value))) : -1;
    }
    readonly property real cpuPercent: percent(cpu)
    readonly property real ramPercent: percent(ram)
    readonly property string cpuText: valid(cpu) ? Math.round(cpuPercent) + " %" : "—"
    function number(value, decimals) {
        return Number(value).toLocaleString(Qt.locale(), "f", decimals);
    }
    function memory(value) {
        return number(Math.max(0, Number(value)) / (ramUnit === 1 ? 1e9 : 1073741824), 1);
    }
    readonly property string ramText: ramMode === 0
        ? (valid(ram) ? Math.round(ramPercent) + " %" : "—")
        : (valid(ramUsed) && (ramMode !== 1 || valid(ramTotal))
            ? memory(ramUsed.value) + (ramMode === 1 ? " / " + memory(ramTotal.value) : "")
                + (ramUnit === 1 ? " GB" : " GiB") : "—")
    function rate(bytesPerSecond, unit) {
        const value = Math.max(0, Number(bytesPerSecond));
        if (unit === 0) return number(value * 8 / 1e6, 2) + " Mbit/s";
        if (unit === 1) return number(value * 8 / 1e3, 1) + " kbit/s";
        if (unit === 2) return number(value / 1e6, 2) + " MB/s";
        if (unit === 3) return number(value / 1024, 1) + " KiB/s";
        const units = ["B/s", "KiB/s", "MiB/s", "GiB/s", "TiB/s"];
        const power = value > 0 ? Math.min(units.length - 1, Math.floor(Math.log(value) / Math.log(1024))) : 0;
        return number(value / Math.pow(1024, Math.max(0, power)), power > 0 ? 2 : 0) + " " + units[Math.max(0, power)];
    }
    function megabits(value) { return rate(value, 0); }
    readonly property string downloadText: valid(download) ? rate(download.value, netUnit) : "—"
    readonly property string uploadText: valid(upload) ? rate(upload.value, netUnit) : "—"
    readonly property string networkText: {
        // Fixed units share a suffix; automatic units may differ by direction.
        const down = netUnit < 4 ? downloadText.replace(/ [^ ]+$/, "") : downloadText;
        return "↓ " + down + "   ↑ " + uploadText;
    }
    readonly property string coreText: coreValues.map((value, i) => "CPU " + (i + 1) + ": "
        + (value >= 0 ? Math.round(value) + " %" : "—")).join(" · ")
    readonly property string statusText: "CPU: " + cpuText + " · RAM: " + ramText
        + (cpuMode === 1 ? "\n" + coreText : "")
        + "\n" + i18n("Network:") + " " + (selectedInterface || i18n("No active Ethernet or Wi-Fi connection"))
        + "\n" + i18n("Download:") + " " + downloadText + " · " + i18n("Upload:") + " " + uploadText
        + "\n" + i18n("— means that a sensor is not available yet.")
}
