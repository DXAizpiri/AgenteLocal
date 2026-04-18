#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if command -v cygpath >/dev/null 2>&1; then
  ps_script="$(cygpath -w "$script_dir/agente.ps1")"
else
  ps_script="$script_dir/agente.ps1"
fi

exec powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$ps_script" "$@"
