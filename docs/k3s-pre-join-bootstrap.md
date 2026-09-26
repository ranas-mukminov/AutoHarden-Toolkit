# Optional: K3s pre-join node bootstrap (A4)

**Status:** Optional — does **not** block the base [Secure-K3s-GitOps-Template](https://github.com/ranas-mukminov/Secure-K3s-GitOps-Template) day-to-prod path.

**Brand:** Run_as_daemon · AutoHarden-Toolkit

---

## When to use

Before a node joins a K3s cluster, you may want a **host-level** harden pass (SSH, sysctl, optional UFW). This is useful for Starter / SMB clusters where nodes are exposed briefly during bootstrap.

Skip this doc if your template Ansible/Terraform already enforces equivalent controls.

---

## Recommended order

1. **Provision** VM / bare metal; ensure out-of-band console access.
2. **SSH keys** installed for the admin user (`~/.ssh/authorized_keys`).
3. *(Optional)* Narrow SSH helper: [ssh-harden](https://github.com/ranas-mukminov/ssh-harden) `--audit` then `--apply`.
4. **AutoHarden dry-run** with profile `smb-default`.
5. Review report + [Director Checklist](director-checklist.md); approve.
6. **AutoHarden `--apply`** on the node.
7. **Join K3s** per Secure-K3s-GitOps-Template (`bootstrap.sh` / Ansible).

```text
SSH keys → (optional ssh-harden) → autoharden dry-run → approve → autoharden --apply → k3s join
```

---

## Commands (AutoHarden)

```bash
git clone https://github.com/ranas-mukminov/AutoHarden-Toolkit.git
cd AutoHarden-Toolkit

# Dry-run (default — no host changes)
./bin/autoharden run --profile smb-default --report reports/prejoin-dry-run.md

# Apply only after review
sudo ./bin/autoharden run --profile smb-default --apply --report reports/prejoin-applied.md
```

Flags:

| Flag | Meaning |
|------|---------|
| *(none)* / `run` | Dry-run audit + Markdown report |
| `--profile smb-default` | Safe SMB / small-server baseline (default) |
| `--apply` | Explicit apply — required for changes |
| `--report PATH` | Write Markdown report for director sign-off |

---

## ssh-harden vs AutoHarden

| Tool | Role |
|------|------|
| [ssh-harden](https://github.com/ranas-mukminov/ssh-harden) | Narrow OpenSSH helper (subset) |
| [AutoHarden-Toolkit](https://github.com/ranas-mukminov/AutoHarden-Toolkit) | Profile CLI: SSH + sysctl + packages + optional UFW + director report |

Use ssh-harden when you only need `sshd_config`. Use AutoHarden for a broader pre-join baseline and PDF/MD director checklist.

---

## Links

- Template: https://github.com/ranas-mukminov/Secure-K3s-GitOps-Template
- AutoHarden CLI issue/epic: B1 (`run` / `report`, dry-run default)
- ssh-harden cross-link issue: https://github.com/ranas-mukminov/ssh-harden/issues/1

---

*Optional helper docs — Run_as_daemon Starter Hub*
