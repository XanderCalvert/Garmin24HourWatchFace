# 24hourclockface

A Garmin Connect IQ watch face where **one hand completes a full rotation per day** — not per hour. Midnight at the top, midday at the bottom. The hand moves once per minute based on minutes since midnight, giving a calm, approximate sense of where you are in the day.

Built with **Monkey C / Connect IQ** for the **Garmin Enduro 3** (280×280 round MIP).

## Concept

Traditional watch hands sweep the dial twice a day. This face sweeps **once**. The analog hand is intentionally slow — it tells you roughly where you are in the day, not the exact minute. A small digital readout (time, date, battery) keeps it practical.

```
        00
   21        03

18      •      06

   15        09
        12
```

## How the hand angle works

```monkeyc
var minutes = clockTime.hour * 60 + clockTime.min;
var angleDeg = (minutes / 1440.0) * 360.0 - 90.0;
```

- **1440** = minutes in a day
- **−90°** offset places **00:00 at the top** and **12:00 at the bottom**
- Seconds are ignored; the face updates **once per minute** via the normal watch face lifecycle

## Features

| Feature | Details |
|---------|---------|
| 24-hour dial | Labels at 00, 03, 06, 09, 12, 15, 18, 21 |
| Single slow hand | One rotation per day |
| Digital time | 24h or 12h (display only; dial stays 24h) |
| Date | Short format below centre |
| Battery | Small percentage at bottom |
| Settings | Light/dark theme, toggle digital time and battery |

Settings are configured in the **Garmin Connect IQ** app on your phone (or Garmin Express).

## Garmin constraints

- **MIP display** (64 colours) — solid fills, no gradients
- **Minute-level updates** — no seconds hand or sub-minute movement
- **Single-device MVP** — tuned for Enduro 3 (`enduro3`); `fenix7x` included for simulator/dev (same 280×280 layout)
- **No store publish yet** — sideload for personal use

## Project structure

```
source/
  TwentyFourClockFaceApp.mc      App entry
  TwentyFourClockFaceView.mc     Dial, hand, digital overlays
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

# Simulator (start Connect IQ Simulator first, pick matching device)
.\run-simulator.ps1 -Device fenix7x
```

Output: `bin/24hourclockface.prg`

## Sideload to Enduro 3

1. Build with `-Device enduro3`
2. Connect watch via USB
3. Copy `bin/24hourclockface.prg` to `GARMIN/APPS/` on the watch
4. Select the face on the watch

## Screenshots

After launching in the Connect IQ Simulator (Enduro 3 or Fenix 7X profile):

- **Dark theme** — black background, light dial ring, white hand
- **Light theme** — switch in Connect IQ app settings

Capture from the simulator window for portfolio use.

## Why this exists

> I built a Garmin watch face where the hand rotates once per day instead of twice. It is intentionally slow, calm, and designed to make the day feel more visible.

## Licence

Personal project. Garmin Connect IQ SDK subject to [Garmin SDK licence](https://developer.garmin.com/connect-iq/sdk/).
