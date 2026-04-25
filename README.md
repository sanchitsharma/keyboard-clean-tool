# KeyboardClean

A tiny macOS utility that disables all keyboard input so you can wipe your keyboard without triggering anything. A small floating panel appears in the top-right corner — click it to re-enable the keyboard and exit.

Blocks regular keys, modifiers, function keys, and media keys (volume, brightness, play/pause).

## Requirements

- macOS (Apple Silicon or Intel)
- Xcode command line tools (`xcode-select --install`) for `swiftc` and `codesign`
- Accessibility permission (granted on first run)

## Quick start

```sh
# One-time: create a stable self-signed code-signing identity in your login keychain.
# Without this, every rebuild gets a new ad-hoc signature and macOS will revoke
# the Accessibility permission, forcing you to re-grant it each time.
./setup-signing.sh

# Build the .app bundle.
./build.sh

# Launch.
open KeyboardClean.app
```

On first launch, macOS will prompt for Accessibility permission. Grant it via:

**System Settings → Privacy & Security → Accessibility** → toggle **KeyboardClean** on.

Then relaunch the app.

## Usage

Once the floating "Keyboard disabled" panel appears, all keyboard input is swallowed system-wide. **Click the panel** to exit and restore normal input.

## Notes

- A handful of keys are handled in firmware below the user-space event-tap layer and cannot be blocked — notably the Touch ID / power button on Apple Silicon Macs.
- The setup script creates a self-signed cert named `KeyboardClean Dev` in your login keychain. To remove it later: open Keychain Access, find the cert under "login", and delete it.
- The first time `build.sh` signs the binary, the keychain may prompt for permission to use the private key. Click **Always Allow** so subsequent builds are silent.

## License

MIT — see [LICENSE](LICENSE).
