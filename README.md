# AutoHarden-Toolkit

> Automated server hardening with CIS-oriented profiles, dry-run by default, and director-ready reports.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-linux-lightgrey)](https://www.kernel.org/)
[![Release](https://img.shields.io/github/v/release/ranas-mukminov/AutoHarden-Toolkit?display_name=tag)](https://github.com/ranas-mukminov/AutoHarden-Toolkit/releases/tag/v0.2.0)
[![Brand](https://img.shields.io/badge/Run__as__daemon-hardening-blue)](https://run-as-daemon.pro)

**AutoHarden-Toolkit** (Starter Hub) is a lightweight CLI for hardening Linux servers. Default mode is **dry-run**; real changes require explicit `--apply`.

**Русский:** [README.ru.md](README.ru.md)

## Features

- **CLI** — `run` + `report` with Markdown output
- **Profile `smb-default`** — safe baseline for SMB / small servers (SSH, sysctl, packages, optional UFW)
- **Dry-run default** — no host changes unless `--apply`
- **Director checklist** — MD + PDF-ready branding for Run_as_daemon
- **Release packaging** — tarball + SHA256 script
- **Optional K3s pre-join** docs for Secure-K3s Starter


## Latest release

**[v0.2.0 — Starter Hub](https://github.com/ranas-mukminov/AutoHarden-Toolkit/releases/tag/v0.2.0)** — download the release tarball / notes, or clone `main` and use the CLI below.

**CLI (dry-run + report):** `./bin/autoharden run --profile smb-default` (default dry-run) · `./bin/autoharden report --profile smb-default --report reports/audit.md`

**Sample director-report artifact (fake SMB, labeled SAMPLE):** [`examples/reports/SAMPLE-DIRECTOR-REPORT.md`](examples/reports/SAMPLE-DIRECTOR-REPORT.md) · also [`examples/reports/SAMPLE-smb-default-dry-run.md`](examples/reports/SAMPLE-smb-default-dry-run.md)

## Quick start

```bash
git clone https://github.com/ranas-mukminov/AutoHarden-Toolkit.git
cd AutoHarden-Toolkit
chmod +x bin/autoharden harden.sh scripts/*.sh

# Dry-run (default) — prints and writes a Markdown report
./bin/autoharden run --profile smb-default

# Or write a specific report path
./bin/autoharden report --profile smb-default --report reports/audit.md

# Apply ONLY after review (requires root + working SSH keys for SSH module)
sudo ./bin/autoharden run --profile smb-default --apply --report reports/applied.md
```

> **Warning:** Never pass `--apply` without reviewing the dry-run report and confirming key-based SSH access.

### Legacy SSH script

`harden.sh` remains available as a standalone SSH audit/apply helper (`--audit` / `--apply`). Prefer the CLI for profiles and director reports. Narrow extract: [ssh-harden](https://github.com/ranas-mukminov/ssh-harden).

## Profiles

| Profile | Description |
|---------|-------------|
| `smb-default` | Safe CIS-oriented baseline for SMB / small standalone Linux servers |

List profiles:

```bash
./bin/autoharden profiles
```

## Director checklist (B2)

- Source of truth: [`docs/director-checklist.md`](docs/director-checklist.md)
- **Sample filled report (fake SMB):** [`examples/reports/SAMPLE-DIRECTOR-REPORT.md`](examples/reports/SAMPLE-DIRECTOR-REPORT.md)
- Generate PDF (requires `pandoc` and/or `wkhtmltopdf`):

```bash
./scripts/generate-director-pdf.sh
```

## K3s pre-join (optional, A4)

See [`docs/k3s-pre-join-bootstrap.md`](docs/k3s-pre-join-bootstrap.md) — optional harden before joining [Secure-K3s-GitOps-Template](https://github.com/ranas-mukminov/Secure-K3s-GitOps-Template). Does not block the base template path.

## Release packaging (B3)

Published release: **[v0.2.0](https://github.com/ranas-mukminov/AutoHarden-Toolkit/releases/tag/v0.2.0)**.

```bash
./scripts/package-release.sh 0.2.0
# → dist/AutoHarden-Toolkit-0.2.0.tar.gz
# → dist/AutoHarden-Toolkit-0.2.0.tar.gz.sha256
```

Verify a download:

```bash
sha256sum -c AutoHarden-Toolkit-0.2.0.tar.gz.sha256
```

## License & paid support

This project is **MIT** open source — see [LICENSE](LICENSE).

**Paid support / commercial Starter** (custom profiles, fleet rollout, onboarding) is offered by **Run_as_daemon**:

- **Primary CTA:** [Telegram @en_run_as_daemon_dev](https://t.me/en_run_as_daemon_dev)
- HQ: https://run-as-daemon.pro
- Gateway: https://run-as-daemon.dev

The MIT grant does **not** include SLA, managed hardening, or commercial redistribution rights beyond the license text.

## Related

- [ssh-harden](https://github.com/ranas-mukminov/ssh-harden) — narrow SSH helper
- [Secure-K3s-GitOps-Template](https://github.com/ranas-mukminov/Secure-K3s-GitOps-Template) — K3s GitOps Starter
- [k8s-fintech-baseline](https://github.com/ranas-mukminov/k8s-fintech-baseline)

## Disclaimer

CIS-oriented **examples**, not a compliance certification. Review before production use. Keep an out-of-band console when changing SSH.
