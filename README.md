Keyboard
========

[![Build Status](https://travis-ci.com/creasty/Keyboard.svg?branch=master)](https://travis-ci.com/creasty/Keyboard)
[![GitHub release](https://img.shields.io/github/release/creasty/Keyboard.svg)](https://github.com/creasty/Keyboard/releases)
[![License](https://img.shields.io/github/license/creasty/Keyboard.svg)](./LICENSE)

Master of keyboard is master of automation.


Installation
------------

```
$ brew cask install creasty/tools/keyboard
```


List of actions
---------------

`+` denotes a key sequence of the 'super key' mode which is activated by the first letter with no modifier keys pressed.

### Window/space navigation

| Key | Description |
|:---|:---|
| <kbd>S+H</kbd> | Move to left space |
| <kbd>S+L</kbd> | Move to right space |
| <kbd>S+J</kbd> | Switch to next application |
| <kbd>S+K</kbd> | Switch to previous application |
| <kbd>S+N</kbd> | Switch to next window |
| <kbd>S+B</kbd> | Switch to previous window |
| <kbd>S+M</kbd> | Mission control |

<details><summary>Requirements</summary>

Open "System Preferences" and set the following shortcuts.

- `Mission Control` > `Move left a space` <kbd>Ctrl-LeftArrow</kbd>
- `Mission Control` > `Move right a space` <kbd>Ctrl-RightArrow</kbd>
- `Keyboard` > `Move focus to next window` <kbd>Cmd-F1</kbd>

| 1 | 2 |
|---|---|
| ![](https://user-images.githubusercontent.com/1695538/50548207-12b02800-0c8c-11e9-8dd9-527d4aed2b69.png) | ![](https://user-images.githubusercontent.com/1695538/50548209-1643af00-0c8c-11e9-9bf8-1e86ca13f4fb.png) |

</details>

### Window resizing/positioning

| Key | Description |
|:---|:---|
| <kbd>S+D+F</kbd> | Full screen |
| <kbd>S+D+H</kbd> | Left half |
| <kbd>S+D+J</kbd> | Bottom half |
| <kbd>S+D+K</kbd> | Top half |
| <kbd>S+D+L</kbd> | Right half |

### Emacs mode

| Key | Description | Shift allowed |
|:---|:---|:---|
| <kbd>Ctrl-C</kbd> | Escape | NO |
| <kbd>Ctrl-D</kbd> | Forward delete | NO |
| <kbd>Ctrl-H</kbd> | Backspace | NO |
| <kbd>Ctrl-J</kbd> | Enter | NO |
| <kbd>Ctrl-P</kbd> | ↑ | YES |
| <kbd>Ctrl-N</kbd> | ↓ | YES |
| <kbd>Ctrl-B</kbd> | ← | YES |
| <kbd>Ctrl-F</kbd> | → | YES |
| <kbd>Ctrl-A</kbd> | Beginning of line | YES |
| <kbd>Ctrl-E</kbd> | End of line | YES |

### Word motions

| Key | Description |
|:---|:---|
| <kbd>A+D</kbd> | Delete word after cursor |
| <kbd>A+H</kbd> | Delete word before cursor |
| <kbd>A+B</kbd> | Move cursor backward by word |
| <kbd>A+F</kbd> | Move cursor forward by word |

### Switch input source

| Key | Description |
|:---|:---|
| <kbd>Ctrl-;</kbd> | Selects next source in the input menu |

### Switch input source with Escape key

Change the input source to English as you leave 'insert mode' in Vim with <kbd>Escape</kbd> key so it can prevent IME from capturing key strokes in 'normal mode'.

| Key | Description |
|:---|:---|
| <kbd>Ctrl-C</kbd> | Invokes <kbd>EISUU, Escape</kbd> |
| <kbd>Escape</kbd> | Invokes <kbd>EISUU, Escape</kbd> |

### Switch between apps

| Key | App | Bundle ID | URL |
|:---|:---|:---|:---|
| <kbd>;+F</kbd> | Finder | `com.apple.finder` | N/A |
| <kbd>;+M</kbd> | Alacritty | `io.alacritty` | https://github.com/jwilm/alacritty |
| <kbd>;+T</kbd> | Things | `com.culturedcode.ThingsMac` | https://culturedcode.com/things |
| <kbd>;+B</kbd> | Bear | `net.shinyfrog.bear` | https://bear.app |
| <kbd>;+N</kbd> | Notion | `notion.id` | https://www.notion.so |

### Fool-safe "Quit Application"

Prevents <kbd>Cmd-Q</kbd> from quiting applications.

| Key | Description |
|:---|:---|
| <kbd>Cmd-Q</kbd> | Noop |
| <kbd>Cmd-Q, Cmd-Q</kbd> | Invokes </kbd>Cmd-Q</kbd>. Quits application |
