param(
    [string[]]$Devices = @(
        "enduro3",
        "fenix7x",
        "fenix6xpro",
        "fenix5",
        "fenix5plus",
        "fr255"
    )
)

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $projectRoot

New-Item -ItemType Directory -Force -Path (Join-Path $projectRoot "bin") | Out-Null

$built = @()
$failed = @()

foreach ($device in $Devices) {
    Write-Host ""
    Write-Host "=== $device ===" -ForegroundColor Cyan
    & (Join-Path $projectRoot "build.ps1") -Device $device
    if ($LASTEXITCODE -ne 0) {
        $failed += $device
        continue
    }

    $src = Join-Path $projectRoot "bin\24hourclockface.prg"
    $dest = Join-Path $projectRoot "bin\24hourclockface-$device.prg"
    Copy-Item -Force $src $dest
    $built += $dest
    Write-Host "Copied: $dest" -ForegroundColor Green
}

Write-Host ""
if ($built.Count -gt 0) {
    Write-Host "Built for $($built.Count) device(s). Give each friend the matching file:" -ForegroundColor Green
    foreach ($path in $built) {
        Write-Host "  $path"
    }
}

if ($failed.Count -gt 0) {
    Write-Host "Failed: $($failed -join ', ')" -ForegroundColor Red
    Write-Host "Download missing devices in Connect IQ SDK Manager, then run again."
    exit 1
}
