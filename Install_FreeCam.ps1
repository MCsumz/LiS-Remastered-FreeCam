# Installs both UE4SS Lua mods into Life is Strange Remastered.
param([string]$Win64)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($Win64)) {
    $Win64 = Read-Host 'Enter the full LIS\Binaries\Win64 path'
}
$Win64 = $Win64.Trim().Trim('"')
if (-not (Test-Path -LiteralPath $Win64 -PathType Container)) {
    throw "Game Win64 directory not found: $Win64"
}
if (Get-Process -Name 'LiS-Win64-Shipping' -ErrorAction SilentlyContinue) {
    throw 'Close Life is Strange Remastered before installing the mods.'
}

$mods = Join-Path $Win64 'ue4ss\Mods'
if (-not (Test-Path -LiteralPath $mods -PathType Container)) {
    throw "UE4SS Mods directory not found: $mods"
}

$modNames = @('FreeCamHotkey', 'FreeCamVerticalTriggers')
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
foreach ($modName in $modNames) {
    $source = Join-Path $PSScriptRoot "$modName\Scripts\main.lua"
    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
        throw "Package is missing: $source"
    }
    $targetDir = Join-Path $mods "$modName\Scripts"
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    $target = Join-Path $targetDir 'main.lua'
    if (Test-Path -LiteralPath $target -PathType Leaf) {
        Copy-Item -LiteralPath $target -Destination "$target.backup-$stamp" -Force
    }
    Copy-Item -LiteralPath $source -Destination $target -Force
    Write-Host "Installed $modName"
}

$modsTxt = Join-Path $mods 'mods.txt'
$lines = New-Object 'System.Collections.Generic.List[string]'
if (Test-Path -LiteralPath $modsTxt -PathType Leaf) {
    Copy-Item -LiteralPath $modsTxt -Destination "$modsTxt.backup-$stamp" -Force
    foreach ($line in [System.IO.File]::ReadAllLines($modsTxt)) {
        $lines.Add($line)
    }
} else {
    $lines.Add('Keybinds : 1')
}

# Keep the FreeCam entries together at the end of the regular mod list.
# Remove any previous entries first so reinstalling also fixes their position.
for ($i = $lines.Count - 1; $i -ge 0; $i--) {
    if ($lines[$i] -match '^\s*(?:FreeCamHotkey|FreeCamVerticalTriggers)\s*:') {
        $lines.RemoveAt($i)
    }
}

$insertAt = $lines.Count
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match '^\s*;\s*Built-in keybinds\b' -or
        $lines[$i] -match '^\s*Keybinds\s*:') {
        $insertAt = $i
        break
    }
}
# Preserve the blank separator above the built-in keybinds section.
while ($insertAt -gt 0 -and [string]::IsNullOrWhiteSpace($lines[$insertAt - 1])) {
    $insertAt--
}
foreach ($modName in $modNames) {
    $lines.Insert($insertAt, "$modName : 1")
    $insertAt++
}

[System.IO.File]::WriteAllLines($modsTxt, $lines, (New-Object System.Text.UTF8Encoding($false)))
Write-Host 'Done. Restart the game to load both mods.'
