# WSL X11 setup

This repository ships a helper script that sets `DISPLAY` for WSL and enables indirect GL when needed.

## Requirements
- Windows X server if WSLg is not available (VcXsrv or Xming work).
- Allow inbound connections for the X server on the Windows firewall.

## Use
1. Start your Windows X server.
2. In WSL, run:
   - `source /home/standard/scripts/wsl-x11.sh`
3. Launch an X11 app (example: `xclock`).

## Optional: auto-load for every shell
Append this line to `~/.bashrc`:
- `source /home/standard/scripts/wsl-x11.sh`
