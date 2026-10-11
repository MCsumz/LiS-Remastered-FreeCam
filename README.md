# Life is Strange Remastered — Free Camera

A free-camera hotkey mod for **Life is Strange Remastered (PC)**, powered by UE4SS.

Toggle Unreal Engine's native debug camera using your keyboard or Xbox controller, without opening the developer console.

## Features

- **Keyboard support:** Press `1` to toggle the free camera.
- **Xbox controller support:** Hold **L3 + R3** (both analog sticks pressed) for approximately **1.5 seconds** to toggle the camera.
- **Two-way toggling:** Enter and exit free-camera mode using either input method.
- **Controller-aware input handling:** Supports switching between the normal player controller and Unreal's debug camera controller.
- **Lightweight:** Standalone UE4SS Lua mod; no external hotkey application required.

## Requirements

**Game:** Life is Strange Remastered — Windows PC

**Dependencies:**

- [UE4SS — RE-UE4SS](https://github.com/UE4SS-RE/RE-UE4SS) — A compatible experimental build is recommended.
- [Life is Strange Remastered UE4SS compatibility patch](https://www.nexusmods.com/lifeisstrangeremastered/mods/54) by WoahItsJeebus.

**Important:** Life is Strange Remastered requires the game-specific `VTableLayout.ini` compatibility patch for the tested setup. UE4SS without the patch may cause startup crashes.

## Installation

**1. Install UE4SS**

Download a compatible experimental UE4SS build from the [UE4SS releases](https://github.com/UE4SS-RE/RE-UE4SS/releases) and follow its installation instructions.

The target game executable directory is:

`Steam\steamapps\common\LIS - Remastered\LIS\Binaries\Win64\`

**2. Install the compatibility patch**

Download the game-specific `VTableLayout.ini` from the Nexus Mods page linked above.

Place the file at:

`LIS\Binaries\Win64\ue4ss\VTableLayout.ini`

**3. Install FreeCamHotkey**

Copy the `FreeCamHotkey` folder from this repository into:

`LIS\Binaries\Win64\ue4ss\Mods\`

The script should be located at:

`LIS\Binaries\Win64\ue4ss\Mods\FreeCamHotkey\Scripts\main.lua`

**4. Enable the mod**

Open:

`LIS\Binaries\Win64\ue4ss\Mods\mods.txt`

Add or enable the following entry:

`FreeCamHotkey : 1`

**5. Launch the game**

Start Life is Strange Remastered through Steam and load into gameplay.

## Controls

| Input | Action |
|---|---|
| Keyboard `1` | Toggle free camera ON/OFF |
| Xbox L3 + R3 (hold ~1.5 seconds) | Toggle free camera ON/OFF |

Release both analog stick buttons between controller activations.

## Compatibility and limitations

Developed and tested with Life is Strange Remastered for Windows using an experimental UE4SS build and the game-specific compatibility patch.

Compatibility with every game version, controller model, or UE4SS release is not guaranteed.

This mod uses Unreal Engine's native debug-camera functionality. Camera behavior and movement controls are determined by the game engine.

## Development and credits

**Project creator and maintainer:** [MCsumz](https://github.com/MCsumz)

Concept, design direction, implementation requirements, integration, and in-game testing by MCsumz. Lua development assisted by **OpenAI Codex**.

**Dependencies and third-party acknowledgements:**

- [UE4SS-RE](https://github.com/UE4SS-RE/RE-UE4SS) — UE4SS framework.
- **WoahItsJeebus** — Life is Strange Remastered UE4SS compatibility patch.

These dependencies are separate projects and are not bundled with this mod.

## License

The original mod code in this repository is released under the **MIT License**, subject to any applicable third-party notices. See [LICENSE](LICENSE).

This is an unofficial fan-made modification and is not affiliated with or endorsed by Square Enix or the game's developers.
