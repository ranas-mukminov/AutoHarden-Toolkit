#!/usr/bin/env bash
# harden-ssh.sh
# Clean, safe and reusable SSH hardening module
# Usage: ./harden-ssh.sh --audit | --apply

set -u

LOGFILE="/var/log/autoharden-ssh.log"
SSHD_CONF="/etc/ssh/sshd_config"
TIMESTAMP() { date +"%Y%m%d-%H%M%S"; }
DATESTAMP() { date +"%Y-%m-%d %H:%M:%S"; }

# Desired settings (key|value)
declare -A SETTINGS=(
  [PasswordAuthentication]=no
  [PermitRootLogin]=no
  [MaxAuthTries]=3
  [X11Forwarding]=no
  [AllowTcpForwarding]=no
)

log(){
  local msg="$1"
  echo "[$(DATESTAMP)] $msg" | tee -a "$LOGFILE"
}

usage(){
  echo "Usage: $0 --audit | --apply"
  exit 2
}

require_root(){
  if [[ $(id -u) -ne 0 ]]; then
    echo "This script must be run as root." >&2
    exit 1
  fi
}

backup_conf(){
  local ts
  ts=$(TIMESTAMP)
  local dest="${SSHD_CONF}.autoharden-${ts}"
  cp -a "$SSHD_CONF" "$dest"
  log "BACKUP: $SSHD_CONF -> $dest"
}

set_option_in_file(){
  # args: key value file
  local key="$1" value="$2" file="$3"

  # Escape characters for sed replacement
  local escaped_value
  escaped_value=$(printf "%s" "$value" | sed -e 's/[&/\\]/\\&/g')

  # If key exists (commented or not) replace the line; otherwise append
  if grep -qE "^\s*#?\s*${key}\b" "$file"; then
    # Use sed to replace only the first occurrence of option
    sed -ri "0,/^\s*#?\s*${key}\b/ s|^\s*#?\s*${key}.*|${key} ${escaped_value}|" "$file"
  else
    echo "${key} ${value}" >> "$file"
  fi
}

audit_or_apply_change(){
  # args: key value mode file
  local key="$1" value="$2" mode="$3" file="$4"

  # Find current effective value (not commented)
  local current
  current=$(awk -v k="$key" '
    BEGIN{IGNORECASE=1}
    $0 ~ "^\\s*"k"\\b"{print $2; exit}
  ' "$file" || true)

  if [[ -z "$current" ]]; then
    echo "Would set $key $value (not present)"
    [[ "$mode" == "apply" ]] && set_option_in_file "$key" "$value" "$file" && log "SET: $key $value"
  elif [[ "$current" != "$value" ]]; then
    echo "Would set $key $value (current: $current)"
    [[ "$mode" == "apply" ]] && set_option_in_file "$key" "$value" "$file" && log "SET: $key $value (was: $current)"
  else
    echo "$key already set to $value"
  fi
}

restart_ssh(){
  # Try the common service names in order
  local services=("sshd" "ssh")
  local restarted=1
  for svc in "${services[@]}"; do
    if systemctl list-unit-files | grep -q "^${svc}.service"; then
      systemctl restart "$svc" && {
        log "RESTART: systemctl restart $svc -> OK"
        if systemctl is-active --quiet "$svc"; then
          echo "SSH service ($svc) restarted successfully."
          return 0
        else
          echo "SSH service ($svc) restart attempted but service is not active." >&2
          log "RESTART: $svc restarted but not active"
          return 2
        fi
      } || {
        echo "Failed to restart $svc with systemctl." >&2
        log "RESTART FAILED: systemctl restart $svc"
        return 3
      }
    fi
  done

  # Fallback: try service command
  if command -v service >/dev/null 2>&1; then
    for svc in "${services[@]}"; do
      if service "$svc" status >/dev/null 2>&1; then
        service "$svc" restart && {
          log "RESTART: service $svc restart -> OK"
          echo "SSH service ($svc) restarted (sysv)."
          return 0
        } || {
          log "RESTART FAILED: service $svc restart"
          echo "Failed to restart $svc with service command." >&2
          return 4
        }
      fi
    done
  fi

  echo "No recognizable SSH service found to restart." >&2
  log "RESTART FAILED: no ssh service found"
  return 5
}

# ---------------------
# Main
# ---------------------
if [[ $# -ne 1 ]]; then
  usage
fi

MODE=""
case "$1" in
  --audit) MODE="audit" ;; 
  --apply) MODE="apply" ;; 
  *) usage ;; 
esac

if [[ "$MODE" == "apply" ]]; then
  require_root
  # Ensure logfile exists and is writeable
  mkdir -p "$(dirname "$LOGFILE")"
  touch "$LOGFILE" || { echo "Cannot write to $LOGFILE" >&2; exit 1; }
  backup_conf
fi

# Work on a temp copy for audit to avoid touching live file
WORKFILE="$SSHD_CONF"
if [[ "$MODE" == "audit" ]]; then
  WORKFILE=$(mktemp /tmp/sshd_config.autoharden.XXXXXX) || exit 1
  cp -a "$SSHD_CONF" "$WORKFILE"
fi

# Enforce settings
for key in "${!SETTINGS[@]}"; do
  value="${SETTINGS[$key]}"
  audit_or_apply_change "$key" "$value" "$MODE" "$WORKFILE"
done

if [[ "$MODE" == "apply" ]]; then
  # All changes were made directly to /etc/ssh/sshd_config by set_option_in_file
  echo
  echo "Applying changes and attempting to restart SSH service..."
  restart_ssh
  ret=$?
  if [[ $ret -eq 0 ]]; then
    echo "All done. Changes logged to $LOGFILE"
    exit 0
  else
    echo "Restart failed (code $ret). Check $LOGFILE and the service status." >&2
    exit $ret
  fi
else
  # Clean up temp
  rm -f "$WORKFILE"
  echo
  echo "Audit complete. No files were modified. Run with --apply to make changes (requires root)."
  exit 0
fi

