#!/usr/bin/env bash
set -euo pipefail

if [[ "${WSL_X11_FORCE:-}" != "1" ]]; then
  if ! grep -qi microsoft /proc/version; then
    exit 0
  fi
fi

if [[ -z "${DISPLAY:-}" ]]; then
  if [[ -n "${WSL_X11_HOST:-}" ]]; then
    export DISPLAY="${WSL_X11_HOST}:0"
  else
    config_host=""
    if [[ -f "${HOME}/.config/wsl-x11-host" ]]; then
      config_host=$(head -n 1 "${HOME}/.config/wsl-x11-host" | tr -d '\r\n')
    fi
    if [[ -n "${config_host}" ]]; then
      export DISPLAY="${config_host}:0"
    else
      windows_ip=""
      gateway_ip=""
      powershell_cmd=""

      if command -v powershell.exe >/dev/null 2>&1; then
        powershell_cmd="powershell.exe"
      elif [[ -x /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe ]]; then
        powershell_cmd="/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"
      fi

      if [[ -n "${powershell_cmd}" ]]; then
        windows_ip=$(${powershell_cmd} -NoProfile -Command "(Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias 'Wi-Fi' | Select-Object -First 1 -ExpandProperty IPAddress)" 2>/dev/null | tr -d '\r' || true)
        if [[ -z "${windows_ip}" ]]; then
          windows_ip=$(${powershell_cmd} -NoProfile -Command "(Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike 'vEthernet (WSL)*' -and $_.IPAddress -notlike '169.254*' -and $_.IPAddress -notlike '127.*' } | Select-Object -First 1 -ExpandProperty IPAddress)" 2>/dev/null | tr -d '\r' || true)
        fi
      fi

      if [[ -n "${windows_ip}" ]]; then
        export DISPLAY="${windows_ip}:0"
      else
        if command -v ip >/dev/null 2>&1; then
          gateway_ip=$(ip route | awk '/default/ { print $3; exit }')
        elif command -v route >/dev/null 2>&1; then
          gateway_ip=$(route -n | awk '$1 == "0.0.0.0" { print $2; exit }')
        fi

        if [[ -n "${gateway_ip}" ]]; then
          export DISPLAY="${gateway_ip}:0"
        else
          wsl_host_ip=$(awk '/nameserver/ { print $2; exit }' /etc/resolv.conf)
          if [[ -n "${wsl_host_ip}" ]]; then
            export DISPLAY="${wsl_host_ip}:0"
          fi
        fi
      fi
    fi
  fi
fi

if [[ -z "${LIBGL_ALWAYS_INDIRECT:-}" ]]; then
  export LIBGL_ALWAYS_INDIRECT=1
fi
