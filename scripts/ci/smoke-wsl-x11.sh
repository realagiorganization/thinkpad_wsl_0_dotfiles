#!/usr/bin/env bash
set -euo pipefail

workdir=$(pwd)

if [[ ! -f "${workdir}/scripts/wsl-x11.sh" ]]; then
  echo "Missing scripts/wsl-x11.sh" >&2
  exit 1
fi

unset DISPLAY
unset LIBGL_ALWAYS_INDIRECT
export WSL_X11_FORCE=1

# Source the helper to populate DISPLAY.
source "${workdir}/scripts/wsl-x11.sh"

if [[ -z "${DISPLAY:-}" ]]; then
  echo "DISPLAY was not set by scripts/wsl-x11.sh" >&2
  exit 1
fi

if [[ "${LIBGL_ALWAYS_INDIRECT:-}" != "1" ]]; then
  echo "LIBGL_ALWAYS_INDIRECT not set to 1" >&2
  exit 1
fi

# Basic sanity check for DISPLAY format.
if ! [[ "${DISPLAY}" =~ :0$ ]]; then
  echo "DISPLAY does not end with :0 (${DISPLAY})" >&2
  exit 1
fi
