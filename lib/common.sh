#!/usr/bin/env bash
# Shared helpers for AutoHarden-Toolkit CLI

set -euo pipefail

AH_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AH_VERSION="0.2.0"
AH_BRAND="Run_as_daemon"
AH_SITE="https://run-as-daemon.ru"
AH_SITE_EN="https://run-as-daemon.dev"

ah_timestamp() { date +"%Y-%m-%d %H:%M:%S"; }
ah_filestamp() { date +"%Y%m%d-%H%M%S"; }

ah_log() {
  echo "[$(ah_timestamp)] $*" >&2
}

ah_die() {
  echo "ERROR: $*" >&2
  exit 1
}

ah_require_root() {
  if [[ "$(id -u)" -ne 0 ]]; then
    ah_die "Root privileges required for --apply. Re-run with sudo, or omit --apply for dry-run."
  fi
}

ah_load_profile() {
  local name="$1"
  local path="${AH_ROOT}/profiles/${name}.conf"
  [[ -f "$path" ]] || ah_die "Profile not found: $name (expected $path)"
  # shellcheck disable=SC1090
  source "$path"
  PROFILE_FILE="$path"
}

ah_list_profiles() {
  local f
  for f in "${AH_ROOT}"/profiles/*.conf; do
    [[ -e "$f" ]] || continue
    # shellcheck disable=SC1090
    ( source "$f"; printf '%s\t%s\n' "$(basename "$f" .conf)" "${PROFILE_DESCRIPTION:-}" )
  done
}
