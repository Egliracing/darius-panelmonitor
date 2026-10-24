# Release test report — Darius Panelmonitor 1.2.0

Date: 24 October 2026. Status: local checks passed; **not yet published to KDE Store**.

## Environment

- Kubuntu 26.04.1, KDE Plasma 6.6.6, Qt 6.10.2.
- Eight logical CPUs; real KDE CPU, memory and physical-network sensors.
- Native Qt Quick software rendering at 2× device scale for the screenshots.
- Tests use PyQt6; the installed widget does not require Python.

## Passed checks

- **PASS** — Live KDE sensors.
- **PASS** — All five network unit conversions (decimal bits/bytes and binary bytes).
- **PASS** — Decimal Mbit/s conversion: zero, positive, negative.
- **PASS** — Automatic Ethernet/Wi-Fi choice, disconnected interfaces and virtual connections.
- **PASS** — Text bounds and NET label at 22/24/32/40/48/64 logical pixels.
- **PASS** — Missing manual interface reports unavailable instead of zero.
- **PASS** — CPU subscription toggle and forced one-row mode.
- **PASS** — Used-memory display receives live memory sensor.
- **PASS** — All logical CPU sensors live.
- **PASS** — Used/total GB memory mode and raw byte units verified against /proc/meminfo.
- **PASS** — English configuration page and configuration property aliases.
- **PASS** — Packaged German gettext catalog.
- **PASS** — Horizontal font maxima 8/11/24 pt and lengths 240/400/720 at heights 24/48/64, centered within panel bounds.
- **PASS** — Vertical alignment at widths 32/48/64 and lengths 240/400/600, two memory modes.
- **PASS** — Alternative colors, maximum font size and memory/network modes rendered with live data.
- **PASS** — actual Plasma applet loaded in `plasmawindowed` offscreen without QML
  TypeError, ReferenceError or binding-loop errors. The four-second test is stopped
  intentionally by timeout; offscreen window-shadow warnings are expected.
- **PASS** — screenshot visual review: small and large layouts, eight CPU gauges,
  RAM used/total, fixed and alternate network units, vertical layout and colors.

- **PASS** — packaged source ZIP extracted into a separate directory and its
  portable release test rerun successfully.

## What the tests establish

The live per-CPU sensor count matches the operating system's eight logical CPUs;
readings are in 0–100%. Physical-memory totals are checked against /proc/meminfo.
Unit conversion is checked with a known byte rate in all five network modes.
Unavailable interfaces produce a dash. Automatic network selection is exercised
against real NetworkManager data, with synthetic cases for Wi-Fi fallback and
virtual-interface exclusion. Tests do not disconnect the user's network.

Horizontal text bounds are checked at 22/24/32/40/48/64 logical pixels. Additional
font maxima (8/11/24 pt) and lengths (240/400/720 pixels) are tested at 24/48/64 pixels.
Vertical layouts are checked at 32/48/64-pixel widths and 240/400/600-pixel lengths,
with percentage and used/total memory modes. Screenshots use actual widget and
configuration components in a controlled presentation canvas with live data.

## Limits

This is one hardware/OS test environment, not a compatibility certification for
all Plasma versions or every monitor scaling factor. The vertical layout has been
rendered and checked locally; it has not been installed in a user's vertical
panel on a second system. Very narrow panels or many logical CPUs can require
more length or smaller text. Individual CPU percentages appear when their bars
are wide enough; hovering exposes the core number and value.

German gettext content is validated, but no second-language desktop session is
created. Interactive color-picker acceptance and all application-level persistence
paths are not automatically driven by these tests. Configuration bindings are
created and exercised; KConfig handles persistence in the Plasma host.

The KDE Store account, current upload form and post-upload installation flow have
not been tested because browser access to the Store was denied. The prepared
package must still be uploaded and its Store-provided installation checked.
