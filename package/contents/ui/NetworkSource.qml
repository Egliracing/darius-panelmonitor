// SPDX-FileCopyrightText: 2026 Darius Jakpor
// SPDX-License-Identifier: GPL-3.0-only

import QtQml
import org.kde.plasma.networkmanagement as PlasmaNM

QtObject {
    id: source
    property string requestedInterface: ""
    property string automaticInterface: ""
    property var availableInterfaces: []
    readonly property string selectedInterface: requestedInterface.trim() || automaticInterface
    property PlasmaNM.NetworkModel networkModel: PlasmaNM.NetworkModel {}
    // NetworkManagerQt ConnectionSettings: Wired=13, Wireless=14;
    // ActiveConnection::Activated=2. Select one physical connection, never a sum.
    function chooseInterface(rows) {
        const candidates = rows.filter(row => row.state === 2 && row.name
            && (row.type === 13 || row.type === 14));
        candidates.sort((a, b) => a.type - b.type || a.name.localeCompare(b.name));
        return candidates.length ? candidates[0].name : "";
    }
    function refresh() {
        let rows = [];
        for (let i = 0; i < networkModel.rowCount(); ++i) {
            const index = networkModel.index(i, 0);
            rows.push({ name: String(networkModel.data(index, PlasmaNM.NetworkModel.DeviceName) || ""),
                state: Number(networkModel.data(index, PlasmaNM.NetworkModel.ConnectionStateRole)),
                type: Number(networkModel.data(index, PlasmaNM.NetworkModel.TypeRole)) });
        }
        availableInterfaces = [...new Set(rows.filter(row => row.name).map(row => row.name))].sort();
        automaticInterface = chooseInterface(rows);
    }
    property Connections modelSignals: Connections {
        target: source.networkModel
        function onDataChanged() { source.refresh(); }
        function onRowsInserted() { source.refresh(); }
        function onRowsRemoved() { source.refresh(); }
        function onModelReset() { source.refresh(); }
    }
    Component.onCompleted: refresh()
}
