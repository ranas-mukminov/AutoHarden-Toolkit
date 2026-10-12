#!/usr/bin/env bash
# SSH hardening module (profile-driven)
# On Debian/Ubuntu, sshd_config usually starts with:
#   Include /etc/ssh/sshd_config.d/*.conf
# First obtained value wins, so editing the main file is a no-op when a
# cloud-init (or other) drop-in already set PasswordAuthentication.
# We write an early drop-in (00-autoharden.conf) so our settings win, and
# verify with sshd -T after apply.

module_ssh_run() {
  local mode="$1"
  local conf="/etc/ssh/sshd_config"
  local dropin_dir="/etc/ssh/sshd_config.d"
  # Lexicographically early so it wins under Include-at-top (Ubuntu/Debian).
  local dropin_file="${dropin_dir}/00-autoharden.conf"
  report_section "SSH (OpenSSH)"

  if [[ ! -r "$conf" ]]; then
    report_item skipped "Cannot read $conf (need read access; usually root)"
    return 0
  fi

  local use_dropin=0
  if grep -Eq '^[[:space:]]*Include[[:space:]]+.*/sshd_config\.d/\*' "$conf"; then
    use_dropin=1
  fi

  local key want current
  local -a keys=(PasswordAuthentication PermitRootLogin MaxAuthTries X11Forwarding AllowTcpForwarding)
  local -a planned_lines=()

  for key in "${keys[@]}"; do
    eval "want=\${SSH_${key}:-}"
    [[ -n "$want" ]] || continue
    # Prefer effective value via sshd -T when available
    current=""
    if command -v sshd >/dev/null 2>&1 || [[ -x /usr/sbin/sshd ]]; then
      local sshd_bin dump
      sshd_bin=$(command -v sshd || true)
      [[ -z "$sshd_bin" && -x /usr/sbin/sshd ]] && sshd_bin=/usr/sbin/sshd
      if dump=$("$sshd_bin" -T 2>/dev/null); then
        current=$(awk -v k="$(printf '%s' "$key" | tr '[:upper:]' '[:lower:]')" '
          BEGIN { IGNORECASE=1 }
          tolower($1) == k { print $2; exit }
        ' <<<"$dump")
      fi
    fi
    if [[ -z "$current" ]]; then
      # Fall back to first hit in main config (ignores drop-ins — audit only hint)
      current=$(awk -v k="$key" 'BEGIN{IGNORECASE=1} $0 ~ "^[[:space:]]*"k"[[:space:]]" {print $2; exit}' "$conf" || true)
    fi

    planned_lines+=("${key} ${want}")
    if [[ -z "$current" ]]; then
      report_item planned "$key → $want (effective value unknown / not present)"
    elif [[ "${current,,}" == "${want,,}" ]]; then
      report_item ok "$key already $want"
    else
      report_item planned "$key → $want (effective: $current)"
    fi
  done

  if [[ ${#planned_lines[@]} -eq 0 ]]; then
    report_item info "No SSH_* settings configured for this profile"
    return 0
  fi

  if [[ "$mode" != "apply" ]]; then
    if [[ "$use_dropin" -eq 1 ]]; then
      report_item info "Would write drop-in: $dropin_file (Include sshd_config.d detected)"
    else
      report_item info "Would edit $conf (no sshd_config.d Include found)"
    fi
    return 0
  fi

  local invoker="${SUDO_USER:-${USER:-}}"
  local home_dir keys_file
  if [[ -n "$invoker" && "$invoker" != "root" ]]; then
    home_dir=$(getent passwd "$invoker" | cut -d: -f6 || true)
  else
    home_dir="${HOME:-/root}"
  fi
  keys_file="${home_dir}/.ssh/authorized_keys"
  if [[ ! -s "$keys_file" ]]; then
    ah_die "Refusing SSH apply: no authorized_keys at $keys_file (lockout risk)"
  fi

  local sshd_bin
  sshd_bin=$(command -v sshd || true)
  [[ -z "$sshd_bin" && -x /usr/sbin/sshd ]] && sshd_bin=/usr/sbin/sshd
  [[ -n "$sshd_bin" ]] || ah_die "sshd not found; cannot validate"

  if [[ "$use_dropin" -eq 1 ]]; then
    mkdir -p "$dropin_dir"
    local bak=""
    if [[ -f "$dropin_file" ]]; then
      bak="${dropin_file}.autoharden-$(ah_filestamp)"
      cp -a "$dropin_file" "$bak"
    fi
    local umask_old
    umask_old=$(umask)
    umask 077
    {
      echo "# Managed by AutoHarden-Toolkit (${PROFILE_NAME:-unknown}) — do not edit by hand"
      echo "# Early drop-in so settings win under Include-at-top (first value wins)."
      printf '%s\n' "${planned_lines[@]}"
    } >"$dropin_file"
    umask "$umask_old"
    chmod 600 "$dropin_file"

    if ! "$sshd_bin" -t; then
      rm -f "$dropin_file"
      [[ -n "$bak" ]] && mv -f "$bak" "$dropin_file"
      ah_die "sshd -t failed after writing $dropin_file; rolled back"
    fi
    report_item applied "Wrote $dropin_file"
    [[ -n "$bak" ]] && report_item info "Backup: $bak"
  else
    # No Include — edit main sshd_config (legacy hosts)
    local workdir work
    if [[ $(id -u) -eq 0 ]]; then
      workdir=$(mktemp -d /root/.autoharden.XXXXXX)
    else
      workdir=$(mktemp -d "${TMPDIR:-/tmp}/autoharden.XXXXXX")
      chmod 700 "$workdir"
    fi
    work="$workdir/sshd_config"
    cp -a "$conf" "$work"
    chmod 600 "$work"

    for key in "${keys[@]}"; do
      eval "want=\${SSH_${key}:-}"
      [[ -n "$want" ]] || continue
      if grep -qE "^[[:space:]]*#?[[:space:]]*${key}\\b" "$work"; then
        sed -ri "0,/^[[:space:]]*#?[[:space:]]*${key}\\b/ s|^[[:space:]]*#?[[:space:]]*${key}.*|${key} ${want}|" "$work"
      else
        printf '%s %s\n' "$key" "$want" >>"$work"
      fi
    done

    local bak="/etc/ssh/sshd_config.autoharden-$(ah_filestamp)"
    cp -a "$conf" "$bak"
    if ! "$sshd_bin" -t -f "$work"; then
      rm -rf "$workdir"
      ah_die "sshd -t failed for proposed config; live file unchanged"
    fi
    local orig_mode
    orig_mode=$(stat -c '%a' "$conf" 2>/dev/null || echo 600)
    install -m "0${orig_mode}" "$work" "$conf"
    "$sshd_bin" -t -f "$conf" || ah_die "live sshd_config failed validation after install"
    report_item applied "Updated $conf"
    report_item info "Backup: $bak"
    rm -rf "$workdir"
  fi

  # Assert effective values
  local dump eff
  if dump=$("$sshd_bin" -T 2>/dev/null); then
    for key in "${keys[@]}"; do
      eval "want=\${SSH_${key}:-}"
      [[ -n "$want" ]] || continue
      eff=$(awk -v k="$(printf '%s' "$key" | tr '[:upper:]' '[:lower:]')" '
        BEGIN { IGNORECASE=1 }
        tolower($1) == k { print $2; exit }
      ' <<<"$dump")
      if [[ -n "$eff" && "${eff,,}" != "${want,,}" ]]; then
        report_item skipped "$key effective is '$eff' (expected $want) — Match/other drop-in may override"
      fi
    done
  fi

  if systemctl list-unit-files 2>/dev/null | grep -q '^sshd.service'; then
    systemctl reload sshd 2>/dev/null || systemctl restart sshd || true
  elif systemctl list-unit-files 2>/dev/null | grep -q '^ssh.service'; then
    systemctl reload ssh 2>/dev/null || systemctl restart ssh || true
  fi
}
