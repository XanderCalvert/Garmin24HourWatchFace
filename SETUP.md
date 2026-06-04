# Connect IQ SDK setup

## Prerequisites

1. **Connect IQ SDK Manager** — [Download from Garmin](https://developer.garmin.com/connect-iq/sdk/)
2. **Monkey C extension** for VS Code / Cursor (`garmin.monkey-c`)
3. **OpenSSL** (optional) — Git for Windows includes it at `C:\Program Files\Git\usr\bin\openssl.exe`

SDK installs to `%APPDATA%\Garmin\ConnectIQ\` (typically `%APPDATA%\Roaming\Garmin\ConnectIQ\` on Windows).

## SDK Manager steps

1. Install and open **Connect IQ SDK Manager**
2. Download the latest **Connect IQ SDK**
3. Download devices: 
   - **enduro3** — required for your Enduro 3
   - **fenix7x** — optional; same 280×280 layout, useful for simulator/dev builds
4. Set the active SDK when prompted

## Developer key

Generate once and save as `developer_key.der` in the project root:

```powershell
& "C:\Program Files\Git\usr\bin\openssl.exe" genrsa -out developer_key.pem 4096
& "C:\Program Files\Git\usr\bin\openssl.exe" pkcs8 -topk8 -inform PEM -outform DER -in developer_key.pem -out developer_key.der -nocrypt
Remove-Item developer_key.pem
```

Or use **SDK Manager → Generate Developer Key**.

## Build

```powershell
.\build.ps1 -Device fenix7x    # dev / simulator (device files usually pre-installed)
.\build.ps1 -Device enduro3    # deploy to Enduro 3
```

If `enduro3` fails with *Invalid device id*, download the **enduro3** device in SDK Manager.

## Simulator

`run-simulator.ps1` only **loads** the built `.prg` into an already-running simulator. It does not start the emulator.

1. Start **Connect IQ Simulator** first (SDK Manager → Start Simulator, or run `connectiq.bat` from your SDK `bin` folder — see `current-sdk.cfg` for the path).
2. In the simulator window, choose **Fenix 7X** or **Enduro 3** and wait until the virtual watch is up.
3. Build and load:

```powershell
.\run-simulator.ps1 -Device fenix7x
```

If you see **Unable to connect to simulator**, the emulator is not running or not ready — restart it and try again.

Or use **Run Without Debugging** in the Monkey C extension (often starts the simulator for you).

### Step count in the simulator

The simulator often reports **0** steps until you set activity data: **Simulation → Activity Data** (or similar), set steps, then reload the watch face.

### Sunrise/sunset border in the simulator

The coloured ring needs a location. In the simulator:

1. **Simulation → Set current position** (or **Activity Data**) and enter your latitude/longitude, then click **OK**
2. Reload the watch face (switch away and back, or restart the simulation)

You should see **blue / orange / yellow** segments around the ring at the correct clock times (not one solid colour).

### Watch face settings (hide battery, steps, date, etc.)

The **Simulation** menu does **not** include these options (it is for fake activity data, time simulation, notifications, and so on). **Set Battery Status** only changes the simulated charge level, not whether `%` is drawn on the face.

Use **one** of the methods below.

#### Option A — On-watch menu (simulator or Enduro 3) — easiest

1. Load the face (`.\run-simulator.ps1 -Device fenix7x`).
2. **Simulator:** menu **Settings → Trigger App Settings View** (with the face active).  
   **Physical watch:** long-press **UP** on the watch face → **Customize** (or similar) → open this face’s settings.
3. Open **Display** and toggle **Battery %** off (and any other fields you want hidden).

Changes apply immediately when you back out to the face.

#### Option B — Application properties editor (full list incl. theme)

1. Face loaded in the simulator.
2. **File → Edit Persistent Storage → Edit Application.Properties Data** (shortcut **Ctrl+P**).
3. Uncheck **Show battery**, set **Theme**, etc., then save.

If the editor is empty or says “No settings file found”: **File → Reset All App Data**, rebuild (`.\build.ps1`), reload the `.prg`, try **Ctrl+P** again.

#### Option C — Phone (store / beta install only)

Garmin Connect → watch → Connect IQ → **24hourclockface** → **Settings** appears only for apps installed from the Connect IQ store (or a private beta), **not** for a `.prg` copied over USB alone.

### Low-battery tick indicator (simulator)

With **Battery %** off (Option A or B):

1. **Settings → Set Battery Status** → **15%** (thicker bottom tick) or **8%** (thick red bottom tick).
2. Return to the watch face; reload if needed.

## Testing on other watches (before sharing)

Connect IQ builds are **per device**. A `.prg` built for `fenix7x` will not run on a Fenix 6X Pro or Fenix 5. Your layout scales from screen size, but you still need one build per watch model.

### 1. Download device definitions (once)

**Connect IQ SDK Manager** → download the device pack for each model you want to simulate or build for, for example:

| Watch (typical) | Device ID | Screen |
|-----------------|-----------|--------|
| Enduro 3 | `enduro3` | 280×280 |
| fēnix 7X (dev/sim) | `fenix7x` | 280×280 |
| fēnix 6X Pro | `fenix6xpro` | 280×280 |
| fēnix 5 (42 mm) | `fenix5` | 240×240 |
| fēnix 5 Plus / 5X / 5S variants | `fenix5plus`, `fenix5xplus`, `fenix5splus`, etc. | 240×240 |
| Forerunner 255 | `fr255` | 260×260 |

There is no `fr225` in current SDKs — if a friend said “225”, they likely mean **Forerunner 255** (`fr255`). Forerunner 235 is `fr235` (older; limited CIQ support).

**fēnix 5 vs 5 Plus:** they use different device IDs. Check **Settings → System → About** on the watch, then pick the matching ID in SDK Manager (folder name under `ConnectIQ\Devices\`).

The project `minSdkVersion` is **3.1.0** so the original fēnix 5 (`fenix5`, API 3.1) can be included alongside newer watches.

Confirm the exact model on the watch: **Settings → System → About**. Match that to a name in SDK Manager (same IDs as the folder names under `%APPDATA%\Garmin\ConnectIQ\Devices\`).

### 2. Build per device

Single device:

```powershell
.\build.ps1 -Device fenix6xpro
.\build.ps1 -Device fenix5
.\build.ps1 -Device fr255
```

All common targets (copies separate files so nothing gets overwritten):

```powershell
.\build-all.ps1
```

Outputs:

- `bin\24hourclockface-fenix6xpro.prg`
- `bin\24hourclockface-fenix5.prg`
- `bin\24hourclockface-fr255.prg`
- …plus your usual `enduro3` / `fenix7x` builds

Custom list:

```powershell
.\build-all.ps1 -Devices fenix6xpro,fenix5plus,fr255
```

If build fails with *Invalid device id*, install that device in SDK Manager first.

### 3. Simulator

The simulator emulates **one** device at a time.

1. Start **Connect IQ Simulator**.
2. Pick the device in the simulator UI (e.g. **fēnix 6X Pro**), not Fenix 7X.
3. Build and load for that same ID:

```powershell
.\run-simulator.ps1 -Device fenix6xpro
```

To try another size, **restart the simulator** (or switch device before the watch boots), then run `run-simulator.ps1` with the next `-Device`.

Check layout on smaller screens (`fenix5` 240×240, `fr255` 260×260): ticks, sun ring, and centre text should scale; fonts stay device-native.

### 4. Give friends the correct file

USB sideload (same as Enduro 3):

1. Build for **their** device ID.
2. Copy **only** that file, e.g. `24hourclockface-fenix6xpro.prg`, to `GARMIN/APPS/` on their watch (rename to `24hourclockface.prg` on the watch if you like).
3. Select the face on the watch.

They use **Display** settings on the watch (long-press **UP** → Customize) or you preconfigure in the simulator before copying.

Store / Connect IQ app install is a separate path; sideloaded `.prg` files do not show phone settings unless you publish to the store (or beta).

## Enduro 3 deployment

```powershell
.\build.ps1 -Device enduro3
```

Copy `bin/24hourclockface.prg` to the watch `GARMIN/APPS` folder via USB.

## VS Code settings

`.vscode/settings.json` points the Monkey C extension at `developer_key.der`. The extension auto-detects the active SDK from `current-sdk.cfg`.
