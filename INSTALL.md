# Install 24 Hour Watch Face (sideload)

Download the **`.prg` file that matches your watch** from [GitHub Releases](https://github.com/XanderCalvert/Garmin24HourWatchFace/releases). Do not use a build made for a different model.

## Pick your file

| Your watch (examples) | Download |
|----------------------|----------|
| Garmin Enduro 3 | `24hourclockface-enduro3.prg` |
| fēnix 7X / 7X Pro | `24hourclockface-fenix7x.prg` |
| fēnix 6X Pro / 6X Solar / tactix Delta | `24hourclockface-fenix6xpro.prg` |
| fēnix 5 (42 mm) | `24hourclockface-fenix5.prg` |
| fēnix 5 Plus / 5X / 5S Plus | `24hourclockface-fenix5plus.prg` (or ask if unsure) |
| Forerunner 255 | `24hourclockface-fr255.prg` |

Not listed? Check **Settings → System → About** on the watch and open an issue on GitHub with the exact model name.

## Install over USB

1. Connect the watch with a data cable.
2. Open the watch storage on your computer (appears as a removable drive).
3. Copy your `.prg` into **`GARMIN/APPS/`** (you may rename it to `24hourclockface.prg` on the watch).
4. Safely eject, then on the watch: **hold** to change watch face → pick **24hourclockface**.

## Settings on the watch

Sideloaded faces do not show settings in the Garmin Connect phone app. On the watch:

**Long-press UP** on the watch face → **Customize** (or similar) → **Display** menu.

You can toggle digital time, steps, battery %, date, sun ring, and 24-hour digital format. Use **Display → Battery %** off to enable the low-battery tick at the bottom instead of a percentage.

## Sun path ring

The coloured ring needs GPS/location. Wear the watch outside or sync with Garmin Connect so sunrise/sunset can be calculated.

## Uninstall

Delete the `.prg` from `GARMIN/APPS/` on the watch (USB), or remove the face from the watch face picker if your firmware allows it.
