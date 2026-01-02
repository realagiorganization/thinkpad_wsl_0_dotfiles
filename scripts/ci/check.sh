#!/usr/bin/env bash
set -euo pipefail

required_files=(
  "AGENTS.md"
  "ADVERTISING.md"
  "README.md"
  "docs/wsl-x11.md"
  "docs/windows-host.rdp"
  "scripts/wsl-x11.sh"
  "scripts/ci/smoke-wsl-x11.sh"
)

for file in "${required_files[@]}"; do
  if [[ ! -f "${file}" ]]; then
    echo "Missing required file: ${file}" >&2
    exit 1
  fi
done

bash -n scripts/wsl-x11.sh

if ! rg -q '^full address:s:' docs/windows-host.rdp; then
  echo "docs/windows-host.rdp missing full address" >&2
  exit 1
fi

scripts/ci/smoke-wsl-x11.sh
