#!/usr/bin/env bash
# Optional UFW baseline (never enables without --apply)

module_firewall_run() {
  local mode="$1"
  report_section "Firewall (UFW optional)"

  if [[ "${FIREWALL_ENABLE_UFW:-no}" != "yes" ]]; then
    report_item skipped "FIREWALL_ENABLE_UFW!=yes"
    return 0
  fi

  if ! command -v ufw >/dev/null 2>&1; then
    report_item skipped "ufw not installed (optional for smb-default)"
    return 0
  fi

  local status
  status=$(ufw status 2>/dev/null | head -1 || true)

  if [[ "$mode" != "apply" ]]; then
    report_item planned "ufw default ${FIREWALL_DEFAULT_INCOMING:-deny} incoming"
    report_item planned "ufw default ${FIREWALL_DEFAULT_OUTGOING:-allow} outgoing"
    [[ "${FIREWALL_ALLOW_SSH:-yes}" == "yes" ]] && report_item planned "ufw allow OpenSSH/ssh"
    report_item planned "ufw --force enable (only with --apply)"
    report_item info "Current: ${status:-unknown}"
    return 0
  fi

  # ufw syntax is `ufw default <allow|deny|reject> <incoming|outgoing|routed>`;
  # the reversed order is rejected as "Invalid syntax" and aborts --apply under set -e.
  ufw default "${FIREWALL_DEFAULT_INCOMING:-deny}" incoming >/dev/null
  ufw default "${FIREWALL_DEFAULT_OUTGOING:-allow}" outgoing >/dev/null
  report_item applied "ufw defaults set (in=${FIREWALL_DEFAULT_INCOMING:-deny}, out=${FIREWALL_DEFAULT_OUTGOING:-allow})"
  if [[ "${FIREWALL_ALLOW_SSH:-yes}" == "yes" ]]; then
    ufw allow OpenSSH >/dev/null 2>&1 || ufw allow 22/tcp >/dev/null 2>&1 || true
    report_item applied "ufw allow SSH"
  fi
  ufw --force enable >/dev/null
  report_item applied "ufw enabled"
}
