# Purpose: Sync eyemine-client.toml with EyeMine's PointsSource setting before each launch.
#          Reads the EyeMine user.config to determine if mouse emulation is active,
#          then patches usingMouseEmulation in config/eyemine-client.toml accordingly.
# Usage:   Called from launch-prep.bat as part of the Prism pre-launch command.
# Date created: 2026-05-22

$ErrorActionPreference = 'Stop'

# --- Find EyeMine user.config (newest version wins if multiple installs/versions exist) ---
$candidates = Get-ChildItem `
    "$env:APPDATA\SpecialEffect\EyeMineV2*\*\user.config" `
    -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending

if (-not $candidates) {
    Write-Host "[eyemine-sync] EyeMine user.config not found under $env:APPDATA\SpecialEffect - skipping sync."
    exit 0
}

$configFile = $candidates[0].FullName
Write-Host "[eyemine-sync] Reading: $configFile"

# --- Parse XML and extract PointsSource ---
[xml]$xml = Get-Content $configFile -Encoding UTF8
$settings = $xml.configuration.userSettings.'JuliusSweetland.OptiKey.EyeMine.Properties.Settings'.setting
$pointsSource = ($settings | Where-Object { $_.name -eq 'PointsSource' }).value

if (-not $pointsSource) {
    Write-Host "[eyemine-sync] PointsSource setting not found in user.config - skipping sync."
    exit 0
}

Write-Host "[eyemine-sync] PointsSource = $pointsSource"

# Only Tobii* sources have direct eye tracker integration; everything else
# (MousePosition, GazeTracker, IrisbondDuo/Hiru, TheEyeTribe, etc.) uses mouse emulation
$useMouseEmulation = $pointsSource -notlike 'Tobii*'
$newValue = if ($useMouseEmulation) { 'true' } else { 'false' }

# --- Patch eyemine-client.toml ---
$tomlPath = Join-Path $env:INST_MC_DIR "config\eyemine-client.toml"

if (-not (Test-Path $tomlPath)) {
    Write-Host "[eyemine-sync] WARNING: $tomlPath not found - skipping patch (will apply on next launch after first run)."
    exit 0
}

$content = Get-Content $tomlPath -Raw -Encoding UTF8
$updated = $content -replace '(?m)^(\s*usingMouseEmulation\s*=\s*)(true|false)', "`${1}$newValue"

if ($content -eq $updated) {
    if ($content -notmatch '(?m)^\s*usingMouseEmulation\s*=') {
        Write-Host "[eyemine-sync] WARNING: usingMouseEmulation key not found in $tomlPath - no patch applied."
    } else {
        Write-Host "[eyemine-sync] usingMouseEmulation already $newValue - no change needed."
    }
} else {
    [System.IO.File]::WriteAllText($tomlPath, $updated, (New-Object System.Text.UTF8Encoding $false))
    Write-Host "[eyemine-sync] Patched usingMouseEmulation = $newValue"
}
