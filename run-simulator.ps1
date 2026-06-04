param(
    [string]$Device = "fenix7x"
)

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
& (Join-Path $projectRoot "build.ps1") -Device $Device
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$sdk = (Get-Content (Join-Path $env:APPDATA "Garmin\ConnectIQ\current-sdk.cfg")).Trim()
$monkeydo = Join-Path $sdk "bin\monkeydo.bat"
$prg = Join-Path $projectRoot "bin\24hourclockface.prg"

$connectIq = Join-Path $sdk "bin\connectiq.bat"
Write-Host "Launching simulator for $Device..."
$output = & $monkeydo $prg $Device 2>&1 | Out-String
if ($LASTEXITCODE -ne 0 -or $output -match "Unable to connect") {
    Write-Host $output.Trim()
    Write-Host ""
    Write-Host "Start the Connect IQ Simulator first, then run this script again:"
    Write-Host "  & `"$connectIq`""
    Write-Host "Pick $Device in the simulator window, wait until the watch is ready, then re-run:"
    Write-Host "  .\run-simulator.ps1 -Device $Device"
    exit 1
}
Write-Host $output.Trim()
