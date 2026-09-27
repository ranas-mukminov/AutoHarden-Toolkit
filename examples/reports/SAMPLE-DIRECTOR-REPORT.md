# SAMPLE — Director Report (fake SMB)

> **SAMPLE ONLY — fictional data.** Not a live audit. Generated for portfolio / demo purposes.
> Brand: **Run_as_daemon** · Product: AutoHarden-Toolkit v0.2.0  
> Live dry-run: `./bin/autoharden run --profile smb-default`

| Field | Value |
|-------|-------|
| Company (fake) | ООО «Северный Склад» (SMB, 28 employees) |
| Host | `smb-web-01.example.local` (Ubuntu 22.04) |
| Profile | `smb-default` |
| Mode | DRY-RUN (no changes applied) |
| Operator | infra@example.local |
| Report date | 2026-09-26 |
| Toolkit | [AutoHarden-Toolkit v0.2.0](https://github.com/ranas-mukminov/AutoHarden-Toolkit/releases/tag/v0.2.0) |

---

## Executive summary (for director)

| Status | Count |
|--------|------:|
| Already OK | 4 |
| Planned / would change | 6 |
| Blocked / needs decision | 1 |
| Applied | 0 |

**Recommendation:** Approve SSH password-auth disable and UFW baseline after confirming console/KVM access. Defer optional fail2ban until monitoring is ready.

---

## Checklist sign-off (sample)

| # | Control area | Finding | Director decision |
|---|--------------|---------|-------------------|
| 1 | SSH PasswordAuthentication | Would set `no` (currently yes) | ☐ Approve |
| 2 | SSH PermitRootLogin | Already `no` | N/A — OK |
| 3 | SSH MaxAuthTries | Would set `4` | ☐ Approve |
| 4 | sysctl net.ipv4.conf.all.rp_filter | Would enable | ☐ Approve |
| 5 | Unattended upgrades | Would enable security updates | ☐ Approve |
| 6 | UFW default deny incoming | Planned (SSH allow exception) | ☐ Approve / ☐ Defer |
| 7 | fail2ban | Skipped — optional module | ☐ Defer |

---

## Next steps (sample narrative)

1. Operator attaches this dry-run + [director checklist](../../docs/director-checklist.md).
2. Director authorizes `--apply` only after out-of-band console is verified.
3. Re-run `./bin/autoharden report --profile smb-default --report reports/post-apply.md` after apply.

```bash
# Reproduce a live dry-run (not this SAMPLE file)
./bin/autoharden run --profile smb-default --report reports/director-dry-run.md
# After approval only:
# sudo ./bin/autoharden run --profile smb-default --apply --report reports/applied.md
```

---

*SAMPLE artifact · AutoHarden-Toolkit · Run_as_daemon · [run-as-daemon.ru](https://run-as-daemon.ru)*
