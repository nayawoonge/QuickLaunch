<p align="center">
  <img src="Support/AppIcon.png" width="128" alt="QuickLaunch icon">
</p>

<h1 align="center">QuickLaunch</h1>

<p align="center">Launch any app instantly with global hotkeys on macOS.</p>

<p align="center">
  <b>English</b> | <a href="README.ko.md">한국어</a>
</p>

---

- 🔑 Assign a hotkey to any app (e.g. `⌥⌘T` → Terminal) — basic launching needs no Accessibility permission (Carbon HotKey API)
- 🪟 Bring running apps forward, with optional minimized-window restoration
- 🌐 Supports installed browser web apps such as YouTube and YouTube Music
- 🚀 Optional launch at login
- 👻 Optionally hide the menu bar icon
- 🫥 Optionally hide the Dock icon
- 🌐 English / Korean (follows system language)

## Screenshots

<p align="center">
  <img src="docs/screenshot-main.png" width="540" alt="Main window">
</p>
<p align="center">
  <img src="docs/screenshot-add.png" width="440" alt="Add shortcut">
</p>



## Install

### Download (recommended)

1. Download [**QuickLaunch.dmg**](https://github.com/nayawoonge/QuickLaunch/releases/latest/download/QuickLaunch.dmg) (or browse [Releases](../../releases))
2. Open the DMG and drag **QuickLaunch** into the **Applications** folder
3. First launch: the app is not notarized, so **right-click → Open**, or run:
   ```bash
   xattr -dr com.apple.quarantine /Applications/QuickLaunch.app
   ```

### Build from source

Requires macOS 14+, Xcode or Command Line Tools (Swift 5.9+).

```bash
git clone https://github.com/nayawoonge/QuickLaunch.git
cd QuickLaunch
make install   # builds and copies to /Applications
# or:
make dmg       # builds build/QuickLaunch.dmg
```

If Command Line Tools reports a missing `SwiftUIMacros` plugin with the macOS 27 SDK, use a full Xcode installation or an installed macOS 26.5 SDK:

```bash
make app SWIFT_BUILD_FLAGS="--build-system native --sdk /Library/Developer/CommandLineTools/SDKs/MacOSX26.5.sdk"
```

The XCTest suite (`swift test`) requires a toolchain that includes XCTest, such as full Xcode.

## Usage

1. Open QuickLaunch → click **Add (+)**
2. Pick an app, click **Click to Record**, and press a key combo (e.g. `⌥⌘T`)
3. Save — the hotkey now launches/activates that app from anywhere

### Options

| Option | Description |
|---|---|
| Launch at login | Start QuickLaunch automatically at login (`SMAppService`) |
| Show icon in menu bar | Turn off to remove the icon from the top menu bar |
| Hide Dock icon | Turn on to hide the app from the Dock and `⌘⇥` app switcher |
| Restore minimized windows | Bring an existing window forward; restore one if all windows are minimized. Off by default; requires Accessibility permission. |

> **If both icons are hidden**: launch QuickLaunch again (Spotlight → QuickLaunch) — the settings window of the running instance will reopen.

### When an app opens without a visible window

- **Minimized windows:** enable **Restore minimized windows** in QuickLaunch, then click **Allow Accessibility…** and allow QuickLaunch under **System Settings → Privacy & Security → Accessibility**. Return to QuickLaunch and try the hotkey again. It prefers an unminimized window; if all windows are minimized, it restores one. Apps that do not expose their windows through macOS Accessibility may not support restoration. Basic launching still works if access is denied or revoked.
- **Another desktop (Space) or full-screen window:** in **System Settings → Desktop & Dock → Mission Control**, enable **“When switching to an application, switch to a Space with open windows for the application.”** QuickLaunch requests activation of the existing app; macOS controls the Space transition. It does not move windows to the current desktop or monitor. See [Apple's Spaces guide](https://support.apple.com/guide/mac-help/mh14112/mac).
- **No open windows:** QuickLaunch sends the normal app open request; the target app decides whether to create a new window.

### Notes

- A shortcut needs at least one modifier key (⌘⌥⌃⇧). F1–F20 can be used alone.
- Shortcuts already reserved by the system or another app cannot be registered and are marked with ⚠️ in the list.
- If enabling launch-at-login fails, move the app to `/Applications` and try again.

## License

[MIT](LICENSE)
