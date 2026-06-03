param(
    [string]$Device = "fenix7x"
)

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $projectRoot

$sdkCfg = Join-Path $env:APPDATA "Garmin\ConnectIQ\current-sdk.cfg"
if (-not (Test-Path $sdkCfg)) {
    Write-Error "Connect IQ SDK not found. Install via SDK Manager (see SETUP.md)."
}

$sdk = (Get-Content $sdkCfg).Trim()
$monkeyc = Join-Path $sdk "bin\monkeyc.bat"
$key = Join-Path $projectRoot "developer_key.der"

if (-not (Test-Path $key)) {
    Write-Error "developer_key.der missing. See SETUP.md to generate one."
}

New-Item -ItemType Directory -Force -Path (Join-Path $projectRoot "bin") | Out-Null
$output = Join-Path $projectRoot "bin\24hourclockface.prg"

Write-Host "Building for $Device..."
& $monkeyc -d $Device -f monkey.jungle -o $output -y $key -w -O 2
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

Write-Host "Built: $output"
