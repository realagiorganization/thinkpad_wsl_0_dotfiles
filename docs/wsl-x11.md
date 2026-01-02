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
4. If it fails, confirm the target:
   - `echo "$DISPLAY"`

## Host override
If WSL DNS does not point at the Windows host, set the host IP directly:
- `export WSL_X11_HOST=192.168.0.105`
- `source /home/standard/scripts/wsl-x11.sh`

## Host detection
By default, the script attempts to read the Windows IPv4 address via Windows PowerShell
(`powershell.exe` or `/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe`)
and falls back to `/etc/resolv.conf` if PowerShell is unavailable.

## Persistent host config
You can also store the Windows host IP in `~/.config/wsl-x11-host`:
- `echo 192.168.0.105 > ~/.config/wsl-x11-host`
- `source /home/standard/scripts/wsl-x11.sh`

## Optional: auto-load for every shell
Append this line to `~/.bashrc`:
- `source /home/standard/scripts/wsl-x11.sh`

## Testing override
CI uses `WSL_X11_FORCE=1` to exercise the script outside WSL. Keep this override
available for smoke tests.
