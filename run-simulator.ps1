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

Write-Host "Launching simulator for $Device..."
& $monkeydo $prg $Device
