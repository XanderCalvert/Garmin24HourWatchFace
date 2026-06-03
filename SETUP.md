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

1. Open **Connect IQ Simulator** from SDK Manager or `%SDK%\bin\connectiq.exe`
2. Choose **Fenix 7X** or **Enduro 3** (when available)
3. Run:

```powershell
.\run-simulator.ps1 -Device fenix7x
```

Or use **Run Without Debugging** in the Monkey C extension.

### Sunrise/sunset border in the simulator

The coloured ring needs a location. In the simulator:

1. **Simulation → Set current position** (or **Activity Data**) and enter your latitude/longitude, then click **OK**
2. Reload the watch face (switch away and back, or restart the simulation)

You should see **blue / orange / yellow** segments around the ring at the correct clock times (not one solid colour).

## Enduro 3 deployment

```powershell
.\build.ps1 -Device enduro3
```

Copy `bin/24hourclockface.prg` to the watch `GARMIN/APPS` folder via USB.

## VS Code settings

`.vscode/settings.json` points the Monkey C extension at `developer_key.der`. The extension auto-detects the active SDK from `current-sdk.cfg`.
