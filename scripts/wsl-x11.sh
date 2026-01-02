#!/usr/bin/env bash
set -euo pipefail

if ! grep -qi microsoft /proc/version; then
  exit 0
fi

if [[ -z "${DISPLAY:-}" ]]; then
  wsl_host_ip=$(awk '/nameserver/ { print $2; exit }' /etc/resolv.conf)
  if [[ -n "${wsl_host_ip}" ]]; then
    export DISPLAY="${wsl_host_ip}:0"
  fi
fi

if [[ -z "${LIBGL_ALWAYS_INDIRECT:-}" ]]; then
  export LIBGL_ALWAYS_INDIRECT=1
fi
