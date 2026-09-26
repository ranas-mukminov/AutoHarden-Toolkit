#!/usr/bin/env bash
# Sysctl hardening module

module_sysctl_run() {
  local mode="$1"
  report_section "Kernel / network sysctl"

  local drop_in="/etc/sysctl.d/99-autoharden-smb.conf"
  local lines=()
  local line key want current

  while IFS= read -r line; do
    [[ -z "$line" || "$line" =~ ^# ]] && continue
    # Accept "key = value" or "key=value"
    key=$(echo "$line" | sed -E 's/[[:space:]]*=[[:space:]]*/=/; s/=.*//' | xargs)
    want=$(echo "$line" | sed -E 's/[[:space:]]*=[[:space:]]*/=/; s/^[^=]+=//' | xargs)
    [[ -n "$key" && -n "$want" ]] || continue
    lines+=("${key} = ${want}")
    current=$(sysctl -n "$key" 2>/dev/null || echo "")
    if [[ -z "$current" ]]; then
      report_item planned "$key → $want (not readable on this host)"
    elif [[ "$current" == "$want" ]]; then
      report_item ok "$key already $want"
    else
      report_item planned "$key → $want (current: $current)"
    fi
  done <<< "${SYSCTL_RULES:-}"

  if [[ "$mode" == "apply" && ${#lines[@]} -gt 0 ]]; then
    {
      echo "# Managed by AutoHarden-Toolkit (${PROFILE_NAME:-unknown})"
      echo "# ${AH_BRAND} — do not edit by hand; re-run CLI to refresh"
      printf '%s\n' "${lines[@]}"
    } > "$drop_in"
    if sysctl --system >/dev/null 2>&1 || sysctl -p "$drop_in" >/dev/null 2>&1; then
      report_item applied "Wrote $drop_in and reloaded sysctl"
    else
      report_item applied "Wrote $drop_in (reload partially failed — check manually)"
    fi
  elif [[ "$mode" != "apply" && ${#lines[@]} -gt 0 ]]; then
    report_item info "Would write drop-in: $drop_in"
  fi
}
