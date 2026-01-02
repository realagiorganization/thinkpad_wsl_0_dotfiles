#!/usr/bin/env bash
set -euo pipefail

output_path=${1:-/tmp/gui-smoke.png}
repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
profile="${repo_root}/docs/windows-host.remmina"

if ! command -v xvfb-run >/dev/null 2>&1; then
  echo "xvfb-run not available; skipping GUI smoke test." >&2
  exit 0
fi

if ! command -v scrot >/dev/null 2>&1; then
  echo "scrot not available; skipping GUI smoke test." >&2
  exit 0
fi

if ! command -v xclock >/dev/null 2>&1; then
  echo "xclock not available; skipping GUI smoke test." >&2
  exit 0
fi

if ! command -v remmina >/dev/null 2>&1; then
  echo "remmina not available; skipping GUI smoke test." >&2
  exit 0
fi

if [[ ! -f "${profile}" ]]; then
  echo "Missing Remmina profile: ${profile}" >&2
  exit 1
fi

xvfb-run -a bash -c "set -euo pipefail
xclock &
XCLOCK_PID=\$!
remmina -c '${profile}' &
REMMINA_PID=\$!
sleep 3
scrot -z '${output_path}'
kill \${REMMINA_PID} \${XCLOCK_PID} 2>/dev/null || true
wait \${REMMINA_PID} 2>/dev/null || true
wait \${XCLOCK_PID} 2>/dev/null || true
"

if [[ ! -f "${output_path}" ]]; then
  echo "Screenshot not created at ${output_path}" >&2
  exit 1
fi
