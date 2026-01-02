#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
rdp_file="${repo_root}/docs/windows-host.rdp"
remmina_file="${repo_root}/docs/windows-host.remmina"

if [[ ! -f "${rdp_file}" ]]; then
  echo "Missing ${rdp_file}" >&2
  exit 1
fi

full_address=$(awk -F 'full address:s:' 'NF>1 { print $2; exit }' "${rdp_file}")
if [[ -z "${full_address}" ]]; then
  echo "Missing full address in ${rdp_file}" >&2
  exit 1
fi

cat <<EOF_REM > "${remmina_file}"
[remmina]
name=Windows Host
protocol=RDP
server=${full_address}
username=
password=
domain=
resolution_mode=2
scale=1
color_depth=32
sound=local
security=
authentication=
ignore-tls-errors=1
EOF_REM
