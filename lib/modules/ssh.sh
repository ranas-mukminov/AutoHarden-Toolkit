#!/usr/bin/env bash
# SSH hardening module (profile-driven)

module_ssh_run() {
  local mode="$1"
  local conf="/etc/ssh/sshd_config"
  report_section "SSH (OpenSSH)"

  if [[ ! -r "$conf" ]]; then
    report_item skipped "Cannot read $conf (need read access; usually root)"
    return 0
  fi

  local work
  work=$(mktemp /tmp/autoharden-sshd.XXXXXX)
  cp -a "$conf" "$work"

  local key want current
  for key in PasswordAuthentication PermitRootLogin MaxAuthTries X11Forwarding AllowTcpForwarding; do
    eval "want=\${SSH_${key}:-}"
    [[ -n "$want" ]] || continue
    current=$(awk -v k="$key" 'BEGIN{IGNORECASE=1} $0 ~ "^[[:space:]]*"k"[[:space:]]" {print $2; exit}' "$work" || true)
    if [[ -z "$current" ]]; then
      if [[ "$mode" == "apply" ]]; then
        printf '%s %s\n' "$key" "$want" >> "$work"
        report_item applied "$key → $want (was missing)"
      else
        report_item planned "$key → $want (not present)"
      fi
    elif [[ "$current" != "$want" ]]; then
      if [[ "$mode" == "apply" ]]; then
        sed -ri "0,/^[[:space:]]*#?[[:space:]]*${key}\\b/ s|^[[:space:]]*#?[[:space:]]*${key}.*|${key} ${want}|" "$work"
        report_item applied "$key → $want (was: $current)"
      else
        report_item planned "$key → $want (current: $current)"
      fi
    else
      report_item ok "$key already $want"
    fi
  done

  if [[ "$mode" == "apply" ]]; then
    local invoker="${SUDO_USER:-${USER:-}}"
    local home_dir keys_file
    if [[ -n "$invoker" && "$invoker" != "root" ]]; then
      home_dir=$(getent passwd "$invoker" | cut -d: -f6 || true)
    else
      home_dir="${HOME:-/root}"
    fi
    keys_file="${home_dir}/.ssh/authorized_keys"
    if [[ ! -s "$keys_file" ]]; then
      rm -f "$work"
      ah_die "Refusing SSH apply: no authorized_keys at $keys_file (lockout risk)"
    fi

    local sshd_bin
    sshd_bin=$(command -v sshd || true)
    [[ -z "$sshd_bin" && -x /usr/sbin/sshd ]] && sshd_bin=/usr/sbin/sshd
    [[ -n "$sshd_bin" ]] || { rm -f "$work"; ah_die "sshd not found; cannot validate"; }

    local bak="/etc/ssh/sshd_config.autoharden-$(ah_filestamp)"
    cp -a "$conf" "$bak"
    if ! "$sshd_bin" -t -f "$work"; then
      rm -f "$work"
      ah_die "sshd -t failed for proposed config; live file unchanged"
    fi
    install -m 0644 "$work" "$conf"
    "$sshd_bin" -t -f "$conf" || ah_die "live sshd_config failed validation after install"
    report_item info "Backup: $bak"
    if systemctl list-unit-files 2>/dev/null | grep -q '^sshd.service'; then
      systemctl reload sshd 2>/dev/null || systemctl restart sshd || true
    elif systemctl list-unit-files 2>/dev/null | grep -q '^ssh.service'; then
      systemctl reload ssh 2>/dev/null || systemctl restart ssh || true
    fi
  fi

  rm -f "$work"
}
