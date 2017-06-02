Keyboard
========

Master of keyboard is master of automation.

Minimum Karabiner-esque feature implementation in Swift 3.  
It aims at porting my own custom settings in Karabiner and its [private.xml](https://github.com/creasty/dotfiles/blob/d8b54873c6de27f1244ea10c7e290d1f248ea8ff/app/karabiner/private.xml).


List of hacks
-------------

### Window/space navigations

> Karabiner: `__KeyOverlaidModifier__` and `__BlockUntilKeyUp__`

`S` acts as "super key" that doesn't require any modifier keys.

<details>

<summary>Requirements</summary>

Open "System Preferences" and set the following shortcuts:

- Mission Control
  - "Move left a space" `Ctrl-LeftArrow`
  - "Move right a space" `Ctrl-RightArrow`
- Keyboard
  - "Move focus to next window" `Cmd-Backtick`

Don't mind to create new entry if missing.

| 1 | 2 |
|---|---|
| ![](https://cloud.githubusercontent.com/assets/1695538/26527997/3df11bf8-43db-11e7-975b-6f14aeb2e4a2.png) | ![](https://cloud.githubusercontent.com/assets/1695538/26527998/3e289ec0-43db-11e7-991b-a107a7f16231.png) |

</details>
<br>

| Key | Description |
|---|---|
| `S+H` | Move to left space |
| `S+L` | Move to right space |
| `S+J` | Switch to next application |
| `S+K` | Switch to previous application |
| `S+N` | Switch to next window |
| `S+B` | Switch to previous window |

### Emacs mode

> Karabiner: `option.emacsmode_*`

| Key | Description | Shift allowed |
|---|---|---|
| `Ctrl-C` | Escape | NO |
| `Ctrl-D` | Forward delete | NO |
| `Ctrl-H` | Backspace | NO |
| `Ctrl-J` | Enter | NO |
| `Ctrl-P` | ↑ | YES |
| `Ctrl-N` | ↓ | YES |
| `Ctrl-B` | ← | YES |
| `Ctrl-F` | → | YES |
| `Ctrl-A` | Beginning of line | YES |
| `Ctrl-E` | End of line | YES |

### Application hotkeys

> Karabiner: ` <vkopenurldef>` and `__KeyToKey__`

| Key | Application |
|---|---|
| `Cmd-'` | Finder |

### Fool-safe "Quit Application"

> Karabiner: `remap.doublepresscommandQ`

Press `Cmd-Q` twice to quit application.

`Cmd-Q Cmd-Q`

### Switch to EISUU (an input source) with Escape key

> Karabiner: `__KeyToKey__`

For Vim, `Ctrl-C` and `Escape` now invoke `EISUU` with it.
