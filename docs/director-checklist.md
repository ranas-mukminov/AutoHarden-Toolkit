# Director Checklist — AutoHarden

**Brand:** Run_as_daemon  
**Product:** AutoHarden-Toolkit (Starter Hub)  
**Sites:** [run-as-daemon.ru](https://run-as-daemon.ru) · [run-as-daemon.dev](https://run-as-daemon.dev)

---

## Why this checklist exists

Owners and directors need a short, sign-off-ready view of host hardening — without reading every CIS control. Use this document together with a CLI Markdown report from profile `smb-default`.

1. Operator runs a **dry-run** and attaches the report.
2. Director reviews the checklist below against that report.
3. Only then authorize `--apply` on the target host (or fleet).

> Default CLI mode is **dry-run**. Real changes require explicit `--apply`.

---

## How to produce the CLI report

```bash
git clone https://github.com/ranas-mukminov/AutoHarden-Toolkit.git
cd AutoHarden-Toolkit
./bin/autoharden run --profile smb-default --report reports/director-dry-run.md
```

Optional apply (after approval):

```bash
sudo ./bin/autoharden run --profile smb-default --apply --report reports/director-applied.md
```

PDF export of **this** checklist:

```bash
./scripts/generate-director-pdf.sh
# → docs/director-checklist.pdf
```

---

## Sign-off checklist

| # | Item | Owner check | Notes |
|---|------|-------------|-------|
| 1 | Dry-run report attached (Markdown) for host / fleet | ☐ | File: `reports/…` |
| 2 | Profile used is `smb-default` (or approved custom) | ☐ | |
| 3 | SSH: password auth planned/disabled; root login denied | ☐ | Match report SSH section |
| 4 | SSH: working key-based access verified **before** apply | ☐ | Avoid lockout |
| 5 | Sysctl baseline reviewed (rp_filter, syncookies, redirects) | ☐ | |
| 6 | Firewall plan reviewed (UFW optional; SSH allowed) | ☐ | Skip if other FW |
| 7 | Maintenance window / rollback path agreed | ☐ | sshd backup path in report |
| 8 | `--apply` authorized for listed hosts only | ☐ | |
| 9 | Post-apply report filed; spot-check SSH + services | ☐ | |
| 10 | Residual risk accepted (not a full CIS certification) | ☐ | |

**Director / owner signature:** ______________________  **Date:** __________

---

## Scope notes (honest limits)

- AutoHarden Starter profiles are **CIS-oriented examples**, not a certification.
- `smb-default` targets small / SMB standalone Linux servers.
- Narrow SSH-only helper: [ssh-harden](https://github.com/ranas-mukminov/ssh-harden).
- K3s node pre-join (optional): [k3s-pre-join-bootstrap.md](k3s-pre-join-bootstrap.md).

---

## Commercial / paid support

MIT-licensed OSS. Paid onboarding, custom profiles, and fleet audits: **Run_as_daemon** — [run-as-daemon.ru](https://run-as-daemon.ru).

---

*© Run_as_daemon / Ranas Mukminov — AutoHarden-Toolkit*
