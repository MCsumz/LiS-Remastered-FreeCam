Life is Strange Remastered - UE4SS free camera controls
=======================================================

Two Lua mods add keyboard and Xbox One controller controls to Unreal's
ToggleDebugCamera mode. These controls were tested in Life is Strange
Remastered with UE4SS and an Xbox One wireless controller.

Controls
--------
Keyboard 1: toggle the debug camera on or off.
Hold L3 + R3 for 1.5 seconds: toggle the debug camera on or off.
Release both stick buttons before using that shortcut again.
RT: move the debug camera up.
LT: move the debug camera down.

The game's existing camera controls remain available. Holding L3 + R3 may
move the camera vertically before the toggle occurs.

Requirements
------------
Install UE4SS in LIS\Binaries\Win64 before using this package:
https://github.com/UE4SS-RE/RE-UE4SS/releases

This game's UE4SS setup also uses a compatible VTableLayout.ini:
https://www.nexusmods.com/lifeisstrangeremastered/mods/54

UE4SS and the compatibility file are not included here.

Install
-------
Close the game. Run Install_FreeCam.ps1 in PowerShell with the path to the
game's Win64 directory, for example:

  powershell -NoProfile -ExecutionPolicy Bypass -File .\Install_FreeCam.ps1 -Win64 "C:\Program Files (x86)\Steam\steamapps\common\LIS - Remastered\LIS\Binaries\Win64"

The installer copies FreeCamHotkey and FreeCamVerticalTriggers into
Win64\ue4ss\Mods and enables both in mods.txt. Existing main.lua files and
mods.txt are backed up with timestamps before replacement. Restart the game.

Manual installation: copy both mod folders to Win64\ue4ss\Mods and add
these lines above Keybinds : 1 in Win64\ue4ss\Mods\mods.txt:

  FreeCamHotkey : 1
  FreeCamVerticalTriggers : 1

The old Input.ini RT/LT mappings are not needed. Trigger movement is
implemented by FreeCamVerticalTriggers, independently of the toggle mod.

Troubleshooting
---------------
Check Win64\ue4ss\UE4SS.log for [LiS FreeCamHotkey v7] and
[LiS FreeCamVerticalTriggers]. The trigger mod logs its first detected
RT/LT input, or an error if its movement loop stops.

To disable only trigger movement, set FreeCamVerticalTriggers : 0 in
mods.txt. To disable the whole package, set both mod entries to 0.
