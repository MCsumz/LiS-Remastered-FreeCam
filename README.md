# Life is Strange Remastered — Free Camera

UE4SS Lua mods for controlling Unreal Engine's debug camera in **Life is Strange Remastered (Windows PC)**. The keyboard and Xbox One wireless controller controls below have been tested in-game.

## Controls

| Input | Action |
| --- | --- |
| Keyboard `1` | Toggle debug camera on or off |
| Hold Xbox L3 + R3 for about 1.5 seconds | Toggle debug camera on or off |
| Xbox RT | Move debug camera up |
| Xbox LT | Move debug camera down |

Release both stick buttons before using the L3 + R3 shortcut again. The game's existing camera controls remain available. Holding L3 + R3 may move the camera vertically before the toggle occurs.

`FreeCamHotkey` handles both toggle shortcuts. `FreeCamVerticalTriggers` handles RT/LT movement independently and only while the debug camera is active. No `Input.ini` trigger mappings or separate PowerShell helper need to run during gameplay.

## Requirements

- [UE4SS](https://github.com/UE4SS-RE/RE-UE4SS) installed in the game's `LIS\Binaries\Win64` directory. This setup was tested with a compatible experimental build.
- The game-specific [`VTableLayout.ini` compatibility patch](https://www.nexusmods.com/lifeisstrangeremastered/mods/54) by WoahItsJeebus, placed at `LIS\Binaries\Win64\ue4ss\VTableLayout.ini`. UE4SS without the patch may crash at startup.

These dependencies are separate projects and are not included in this repository.

## Installation

Close the game, then run the included installer from PowerShell, passing the game's `Win64` directory:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\Install_FreeCam.ps1 -Win64 "C:\Program Files (x86)\Steam\steamapps\common\LIS - Remastered\LIS\Binaries\Win64"
```

The installer copies both mod folders to `Win64\ue4ss\Mods`, enables them in `mods.txt`, and backs up existing scripts and `mods.txt` with timestamps before replacing them. Restart the game afterward.

For a manual install, copy `FreeCamHotkey` and `FreeCamVerticalTriggers` to `Win64\ue4ss\Mods`, then add or enable these entries in `Win64\ue4ss\Mods\mods.txt`:

```text
FreeCamHotkey : 1
FreeCamVerticalTriggers : 1
```

Place both FreeCam entries after the other mod entries, before the blank lines and built-in keybinds comment above `Keybinds : 1`. The Lua scripts should be at `ue4ss\Mods\FreeCamHotkey\Scripts\main.lua` and `ue4ss\Mods\FreeCamVerticalTriggers\Scripts\main.lua`.

## Troubleshooting

Check `Win64\ue4ss\UE4SS.log` for `[LiS FreeCamHotkey v7]` and `[LiS FreeCamVerticalTriggers]`. The trigger mod logs its first detected RT/LT input or an error if its movement loop stops.

To disable trigger movement alone, set `FreeCamVerticalTriggers : 0` in `mods.txt`. To disable the entire package, set both mod entries to `0`.

Compatibility with every game version, controller model, or UE4SS release is not guaranteed.

## Development and credits

**Project creator and maintainer:** [MCsumz](https://github.com/MCsumz)

Concept, design direction, implementation requirements, integration, and in-game testing by MCsumz. Lua development assisted by **OpenAI Codex**.

**Dependencies and third-party acknowledgements:** [UE4SS-RE](https://github.com/UE4SS-RE/RE-UE4SS) provides UE4SS; WoahItsJeebus created the Life is Strange Remastered UE4SS compatibility patch.

## License

The original mod code in this repository is released under the **MIT License**, subject to any applicable third-party notices. See [LICENSE](LICENSE).

This is an unofficial fan-made modification and is not affiliated with or endorsed by Square Enix or the game's developers.
