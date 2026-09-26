#!/usr/bin/env bash
# Package presence module

module_packages_run() {
  local mode="$1"
  report_section "Packages"

  local pkg
  for pkg in ${PACKAGES_ENSURE:-}; do
    if command -v dpkg >/dev/null 2>&1; then
      if dpkg -s "$pkg" >/dev/null 2>&1; then
        report_item ok "package $pkg installed"
      else
        if [[ "$mode" == "apply" ]]; then
          if command -v apt-get >/dev/null 2>&1; then
            if DEBIAN_FRONTEND=noninteractive apt-get install -y "$pkg" >/dev/null 2>&1; then
              report_item applied "installed $pkg"
            else
              report_item skipped "failed to install $pkg"
            fi
          else
            report_item skipped "apt-get missing; cannot install $pkg"
          fi
        else
          report_item planned "install package $pkg"
        fi
      fi
    elif command -v rpm >/dev/null 2>&1; then
      if rpm -q "$pkg" >/dev/null 2>&1; then
        report_item ok "package $pkg installed"
      else
        if [[ "$mode" == "apply" ]]; then
          if command -v dnf >/dev/null 2>&1; then
            if dnf install -y "$pkg" >/dev/null 2>&1; then
              report_item applied "installed $pkg"
            else
              report_item skipped "failed to install $pkg"
            fi
          elif command -v yum >/dev/null 2>&1; then
            if yum install -y "$pkg" >/dev/null 2>&1; then
              report_item applied "installed $pkg"
            else
              report_item skipped "failed to install $pkg"
            fi
          else
            report_item skipped "no dnf/yum; cannot install $pkg"
          fi
        else
          report_item planned "install package $pkg"
        fi
      fi
    else
      report_item skipped "unknown package manager; cannot check $pkg"
    fi
  done
}
