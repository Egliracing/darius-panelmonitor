# Darius Panelmonitor — CPU, RAM & Network

**Keep an eye on your system without leaving your panel.**

Darius Panelmonitor brings CPU usage, memory usage, and live download/upload rates
together in one compact KDE Plasma 6 widget. Clear numbers, subtle usage bars, and
three customizable colors make your system activity easy to read at a glance.

## Small panel? It fits.

The layout adapts to the space your panel actually provides. In a small panel,
readings sit neatly on one row. Give it more height and it switches to a two-row
layout with separate headings. Text scales to fit, with a configurable maximum
font size. You can also force the horizontal single-row layout at any height.
Vertical panels use a centered, stacked layout. The length control follows the
panel direction: width for horizontal panels, height for vertical ones.

Make it compact, give it breathing room, or match it to your desktop colors.
The widget follows the panel thickness while keeping its readings centered.
For a many-core CPU or unusually long values, increase the widget length for more
readable numbers; extremely small panels cannot display unlimited detail.

## Choose the readings that matter to you

**CPU:** switch between overall usage and separate live bars for every logical
CPU, including SMT threads. With enough space, each bar shows its percentage;
hover for the CPU number and reading.

**Memory:** choose a percentage, used memory, or a **used / total** display such as
“6.0 / 32.0 GiB”. Select binary GiB or decimal GB according to your preference.
That example is illustrative; actual capacity comes from KDE's memory sensors.

**Network:** choose **Mbit/s, kbit/s, MB/s, KiB/s**, or automatic byte units. Both
download and upload follow your selection. The **NET** label remains visible.

The screenshots show these options in action: compact and two-row layouts,
individual CPU bars, used/total RAM, different network units, a vertical panel,
and an alternative color palette and font-size setting. The settings screenshot
shows where users can choose their own combination.

## Your panel, your preferences

- Show or hide CPU, RAM, and network independently.
- Customize the three colors, length along the panel, maximum font size, and update limit.
- Choose the CPU, memory and network display modes independently.
- Turn the CPU/RAM usage bars on or off.
- Keep fixed network units or let byte units scale automatically.
- Keep the **NET** heading visible, even in the compact layout.

## Ready for different connections

Automatic mode picks a connected Ethernet interface, or Wi-Fi when no Ethernet is
connected. It monitors one connection rather than adding Docker bridges to your
physical interface's traffic. Prefer a particular interface? Enter its name in the
settings. Automatic mode prefers Ethernet; it is not a default-route detector.

## Native KDE data

Readings come from KDE's shared system-monitor sensors. There are no shell
commands running every second, no extra custom background service, and no
telemetry. Missing sensors display a dash instead of a misleading zero.

**Requirements:** KDE Plasma 6, KDE system-monitor sensor QML modules, Kirigami,
QtQuick Controls/Dialogs, and Plasma's NetworkManager QML module. The shared
`ksystemstats` service must be available. English UI with a German translation.

**Tested on:** Kubuntu 26.04.1, Plasma 6.6.6, Qt 6.10.2. Horizontal and vertical layouts are included. Plasma 5 is not supported.

**Please note:** Network rates include local LAN traffic. This widget is not an
Internet speed test. In a fixed-unit mode, the unit applies to both download and upload. Automatic
byte mode shows each direction’s unit separately. Selecting
`all` manually may double-count traffic through virtual interfaces.

After installation, open **Edit Mode → Add Widgets**, find **Darius Panelmonitor**,
and drag it into your panel. Right-click it to configure.

**Free for personal non-commercial use · Source available under custom terms · Version 1.2.1**

Screenshots show the actual widget and configuration components rendered with
live KDE sensor data in a controlled preview. Panel backgrounds and headings are
presentation elements; sensor numbers are not fabricated.

License: personal non-commercial use and private modification are permitted.
Commercial use, sales and distribution of modified versions require the author's
separate written permission. Copyright notices must be retained. Read LICENSE
for the full terms. This is source-available software, not OSI Open Source.
