# AutoHarden-Toolkit

> Автоматическое усиление серверов с CIS-ориентированными профилями, dry-run по умолчанию и отчётами для директора.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-linux-lightgrey)](https://www.kernel.org/)
[![Brand](https://img.shields.io/badge/Run__as__daemon-hardening-blue)](https://run-as-daemon.pro)

**AutoHarden-Toolkit** (Starter Hub) — CLI для hardening Linux. По умолчанию **dry-run**; реальные изменения только с явным `--apply`.

**English:** [README.md](README.md)

## Быстрый старт

```bash
git clone https://github.com/ranas-mukminov/AutoHarden-Toolkit.git
cd AutoHarden-Toolkit

./bin/autoharden run --profile smb-default
sudo ./bin/autoharden run --profile smb-default --apply --report reports/applied.md
```

> Без `--apply` система не меняется. Перед apply проверьте SSH-ключи.

## Профиль `smb-default`

Безопасный набор для SMB / небольших серверов: SSH, sysctl, пакеты, опционально UFW.

## Документы

- Чеклист директора: [`docs/director-checklist.md`](docs/director-checklist.md) (+ PDF через `./scripts/generate-director-pdf.sh`)
- Опциональный pre-join для K3s: [`docs/k3s-pre-join-bootstrap.md`](docs/k3s-pre-join-bootstrap.md)
- Упаковка релиза: `./scripts/package-release.sh 0.2.0`

## Лицензия и платная поддержка

MIT — см. [LICENSE](LICENSE). Платная поддержка / commercial Starter: **Run_as_daemon** — [Telegram](https://t.me/en_run_as_daemon_dev) · [HQ](https://run-as-daemon.pro).
