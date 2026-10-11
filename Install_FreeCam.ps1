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

foreach ($modName in $modNames) {
    $found = $false
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match ('^\s*' + [regex]::Escape($modName) + '\s*:')) {
            $lines[$i] = "$modName : 1"
            $found = $true
        }
    }
    if (-not $found) {
        $insertAt = $lines.Count
        for ($i = 0; $i -lt $lines.Count; $i++) {
            if ($lines[$i] -match '^\s*Keybinds\s*:') {
                $insertAt = $i
                break
            }
        }
        $lines.Insert($insertAt, "$modName : 1")
    }
}

[System.IO.File]::WriteAllLines($modsTxt, $lines, (New-Object System.Text.UTF8Encoding($false)))
Write-Host 'Done. Restart the game to load both mods.'
