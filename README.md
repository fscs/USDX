# UltraStar Deluxe

## UltraQueue and player counts

This branch integrates UltraQueue with current UltraStar Deluxe. It supports arbitrary positive player counts without a fixed compiled player limit.
Available microphone channels, memory, and display space determine the practical limit. Party modes retain their existing team rules.

Set the player range in `config.ini`, then restart the game:

```ini
[Game]
MaxPlayers=32
Players=18
```

The player screen offers every count from one through `MaxPlayers`, with a minimum range of 24.
If `Players` exceeds `MaxPlayers`, the game expands the range to include that count.
Both themes use shared player templates. Singing and score layouts adapt to odd counts and split players across one or two screens.

In **Options > Record**, assign a separate capture channel to each player. Assigning one input twice does not create independent microphones.
For an XR18, USB capture channels 1 through 18 can map directly to players 1 through 18.
If a microphone is quiet, use the recording boost and threshold controls.

Configure the queue server separately:

```ini
[UltraQueue]
URL=http://localhost:8080
```

An empty `URL` disables queue requests. The default URL retains the FSCS server address.
The game fetches `/nextsong` when song selection opens. It reports the title and artist to `/startedplaying` and `/songfinished`.
Requests use JSON escaping, connection and read timeouts, and a 64 KiB response limit.
If the server is unavailable, the game logs the error and continues.

Typing a letter or digit opens song search. Hold **Left Alt** for letter shortcuts, such as **Left Alt + R** for a random song.

To run the focused checks, install Free Pascal with its FCL and network units, then run:

```sh
python3 test/check_players.py
```

These checks cover uneven screen splits, player indices above 255, grid bounds, palette reuse, and the queue protocol.
They do not require a display, mixer, or external queue server.

[![Build Status](https://github.com/UltraStar-Deluxe/USDX/actions/workflows/main.yml/badge.svg)](https://github.com/UltraStar-Deluxe/USDX/actions/workflows/main.yml)
[![License](https://img.shields.io/badge/license-GPLv2-blue.svg)](LICENSE)

Official Project Website: https://usdx.eu/

![UltraStar Deluxe Logo](https://github.com/UltraStar-Deluxe/USDX/blob/master/icons/ultrastardx-icon_256.png)


### 1. About
UltraStar Deluxe (USDX) is a free and open source karaoke game. Players sing along with music using microphones to score points for pitch and rhythm.
UltraStar Deluxe is a fork of the original UltraStar (developed by corvus5).
Many features have been added like party mode, theme support and support for more audio and video formats.
The improved stability and code quality of USDX enabled ports to Linux and macOS.

### 2. Installation
Currently, the following installation channels are offered:
- installer (or portable version) for [the latest release](https://github.com/UltraStar-Deluxe/USDX/releases/latest)
- flatpak from [flathub](https://flathub.org/apps/eu.usdx.UltraStarDeluxe)
- Arch Linux [AUR](https://aur.archlinux.org/packages/ultrastardx-git)

### 3. Configuration
- To set additional song directories change your config.ini like this:
```ini
  [Directories]
  SongDir1=C:\Users\My\Music\MyUSDXSongs
  SongDir2=F:\EvenMoreUSDXSongs
  SongDir...=... (some more directories)
```
- To enable joypad support change config.ini `Joypad=Off` to `Joypad=On`
- To enable 2 or 3 player each on 2 screens, disable the full screen mode, extend your desktop horizontally and set the resolution to fill one screen. Then, in the config.ini set `Screens=2` and restart the game.
- The primary folder for songs on macOS is `$HOME/Music/UltraStar Deluxe`, which is created when UltraStar Deluxe is run for the first time.
- On macOS, by default the `config.ini` file is created in `$HOME/Library/Application Support/UltraStarDeluxe` when UltraStar Deluxe is run for the first time.
- When running in borderless fullscreen mode, the monitor it runs on can be configured by setting `Graphics.PositionX/Y` to an offset in pixels.
- If installed via the flatpak package, the primary song folder is `~/.var/app/eu.usdx.UltraStarDeluxe/.ultrastardx/songs/` and the config.ini is located in `~/.var/app/eu.usdx.UltraStarDeluxe/.ultrastardx/` by default. To configure additional song directories, they first need to be made accessible to the flatpak app using the command: `flatpak override eu.usdx.UltraStarDeluxe --filesystem=/your/new/songfolder` - Afterwards, the directory can be added to the config.ini file as usual.

### 4. Further documentation
The [documentation](https://usdx.eu/docs/) contains more information on:
* [Command-line parameters](https://usdx.eu/docs/command-line-parameters/)
* [Controls](https://usdx.eu/docs/controls/)
* [Customization](https://usdx.eu/docs/customization/)

### 5. Compiling
The game has an Autotools-based buildsystem and can be compiled by running `./autogen.sh && ./configure [--enable-debug] && make`. The executable will be `game/ultrastardx[.exe]`.

For extended information, dependencies, OS-specific notes and configure flags, see [COMPILING.md](COMPILING.md).

### 6. Making a release
See [RELEASING.md](RELEASING.md)

Other useful documents for maintainers: [pipeline info](PIPELINE.md).
