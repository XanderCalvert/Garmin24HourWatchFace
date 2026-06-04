param(
    [Parameter(Mandatory = $true)]
    [string]$Version,
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

& (Join-Path $projectRoot "build-all.ps1") -Devices $Devices
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

$releaseDir = Join-Path $projectRoot "release"
$stagingDir = Join-Path $releaseDir "24hourclockface-$Version"
$zipPath = Join-Path $releaseDir "24hourclockface-$Version.zip"

if (Test-Path $stagingDir) {
    Remove-Item -Recurse -Force $stagingDir
}
New-Item -ItemType Directory -Force -Path $stagingDir | Out-Null

Copy-Item (Join-Path $projectRoot "INSTALL.md") $stagingDir

foreach ($device in $Devices) {
    $prg = Join-Path $projectRoot "bin\24hourclockface-$device.prg"
    if (-not (Test-Path $prg)) {
        Write-Error "Missing build output: $prg"
    }
    Copy-Item $prg $stagingDir
}

if (Test-Path $zipPath) {
    Remove-Item -Force $zipPath
}
New-Item -ItemType Directory -Force -Path $releaseDir | Out-Null
Compress-Archive -Path (Join-Path $stagingDir "*") -DestinationPath $zipPath -Force

Write-Host ""
Write-Host "Release package: $zipPath" -ForegroundColor Green
Write-Host "Upload this zip (or individual .prg files in bin\) to GitHub Releases." -ForegroundColor Green
