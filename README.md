Keyboard
========

Master of keyboard is master of automation.

Minimum Karabiner-esque feature implementation in Swift 3.  
Goal is to port my onw custom settings in Karabiner and its [private.xml](https://github.com/creasty/dotfiles/blob/d8b54873c6de27f1244ea10c7e290d1f248ea8ff/app/karabiner/private.xml).


List of hacks
-------------

### Window/space navigations

`S` acts as a "super key" that doesn't require any modifier keys.

| Key | Description |
|---|---|
| `S+H` | Move to left space |
| `S+L` | Move to right space |
| `S+J` | Switch to next application |
| `S+K` | Switch to previous application |
| `S+N` | Switch to next window |
| `S+B` | Switch to previous window |

### Emacs mode

| Key | Description |
|---|---|
| `Ctrl-C` | Escape |
| `Ctrl-D` | Forward delete |
| `Ctrl-H` | Backspace |
| `Ctrl-J` | Enter |
| `Ctrl-P` | ↑ |
| `Ctrl-N` | ↓ |
| `Ctrl-B` | ← |
| `Ctrl-F` | → |
| `Ctrl-A` | Beginning of line (`Shift` allowed) |
| `Ctrl-E` | End of line (`Shift` allowed) |

### Application hotkeys

| Key | Application |
|---|---|
| `Cmd-'` | Finder |
| `Ctrl-Cmd-'` | Evernote |

### Fool-safe "Quit Application"

You need to press `Cmd-Q` twice to "Quit Application."

`Cmd-Q Cmd-Q`

### Switch to EISUU (an input source) with Escape key

For Vim, `Ctrl-C` and `Escape` now invoke `EISUU` with it.
