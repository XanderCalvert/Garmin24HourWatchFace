# 24hourclockface

A Garmin Connect IQ watch face where **one hand completes a full rotation per day** — not per hour. Midnight at the bottom, midday at the top. The hand moves once per minute based on minutes since midnight, giving a calm, approximate sense of where you are in the day.

Built with **Monkey C / Connect IQ** for the **Garmin Enduro 3** (280×280 round MIP).

## Concept

Traditional watch hands sweep the dial twice a day. This face sweeps **once**. The analog hand is intentionally slow — it tells you roughly where you are in the day, not the exact minute. A small digital readout (time, date, battery) keeps it practical.

```
        12
   09        15

06      •      18

   03        21
        00
```

## How the hand angle works

```monkeyc
var minutes = clockTime.hour * 60 + clockTime.min;
var angleDeg = (minutes / 1440.0) * 360.0 + 90.0;
```

- **1440** = minutes in a day
- **+90°** offset places **00:00 at the bottom** and **12:00 at the top**
- Seconds are ignored; the face updates **once per minute** via the normal watch face lifecycle

## Features

| Feature | Details |
|---------|---------|
| 24-hour dial | Labels at 00, 03, 06, 09, 12, 15, 18, 21 |
| Single slow hand | One rotation per day |
| Digital time | 24h or 12h (display only; dial stays 24h) |
| Date | Short format below centre |
| Battery | Optional percentage; when hidden, low battery thickens/red bottom tick |
| Settings | Dark, light, or follow-device theme; toggle digital time, steps, battery, date, and sun border |

Settings are configured in the **Garmin Connect IQ** app on your phone (or Garmin Express).

## Garmin constraints

- **MIP display** (64 colours) — solid fills, no gradients
- **Minute-level updates** — no seconds hand or sub-minute movement
- **Screen-derived layout** — dial, sun ring, hand hub, and centre text positions scale from the display’s smaller dimension (reference 280×280); Enduro 3 (`enduro3`) and `fenix7x` (simulator/dev) both use 280×280 today
- **Install from [GitHub Releases](https://github.com/XanderCalvert/Garmin24HourWatchFace/releases)** — sideload the `.prg` for your device ([INSTALL.md](INSTALL.md))

## Project structure

```
source/
  TwentyFourClockFaceApp.mc      App entry
  TwentyFourClockFaceView.mc     Dial, hand, digital overlays
  DialGeometry.mc                Screen-derived radii for dial, ticks, sun ring
  TwentyFourClockFaceDelegate.mc Watch face delegate
  Theme.mc                       Colours and settings helpers
resources/
  strings/  settings/  drawables/  properties.xml
manifest.xml
monkey.jungle
```

## Build and run

See [SETUP.md](SETUP.md) for SDK installation and developer key setup.

```powershell
# Dev build (fenix7x device files installed by default in SDK Manager)
.\build.ps1 -Device fenix7x

# Enduro 3 build (download enduro3 device in SDK Manager first)
.\build.ps1 -Device enduro3

# Friend devices (fenix 6X Pro, fenix 5, FR 255, …) — see SETUP.md
.\build-all.ps1

# Simulator (start Connect IQ Simulator first, pick matching device)
.\run-simulator.ps1 -Device fenix7x
```

Output: `bin/24hourclockface.prg`

## Install (friends) or sideload (developers)

**Friends:** see [INSTALL.md](INSTALL.md) and download the matching `.prg` from [Releases](https://github.com/XanderCalvert/Garmin24HourWatchFace/releases).

**Developers:** build with `.\build.ps1 -Device enduro3`, copy `bin/24hourclockface.prg` to `GARMIN/APPS/`, select the face on the watch.

**Publish a release:** [RELEASE.md](RELEASE.md) — `.\package-release.ps1 -Version "1.1.0"`, then attach the zip on GitHub.

## Screenshots

After launching in the Connect IQ Simulator (Enduro 3 or Fenix 7X profile):

- **Dark theme** — black background, light ticks/hand, bright sun ring colours
- **Light theme** — white background, dark ticks/hand, deeper sun ring colours for contrast
- **Follow device** — matches the watch’s day/night display mode when supported

Capture from the simulator window for portfolio use.

## Why this exists

> I built a Garmin watch face where the hand rotates once per day instead of twice. It is intentionally slow, calm, and designed to make the day feel more visible.

## Licence

Personal project. Garmin Connect IQ SDK subject to [Garmin SDK licence](https://developer.garmin.com/connect-iq/sdk/).
