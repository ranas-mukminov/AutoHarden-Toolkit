# AutoHarden-Toolkit

> Automated server hardening based on CIS Benchmarks.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-linux-lightgrey)](https://www.kernel.org/)

**AutoHarden-Toolkit** is a lightweight, modular framework designed to automate the hardening of Linux servers according to CIS (Center for Internet Security) Benchmarks. It ensures your infrastructure meets industry-standard security baselines with minimal manual intervention.

## Features

- **CIS Compliance**: Automates checks and remediation for CIS Benchmarks.
- **Modular Design**: Enable or disable specific hardening modules.
- **Idempotent**: Safe to run multiple times; only applies necessary changes.
- **Audit Mode**: Dry-run capability to preview changes before applying them.

## Quick Start

### Prerequisites

- Linux Server (Ubuntu/Debian/CentOS)
- Root privileges

### Installation & Usage

1.  Clone the repository:
    ```bash
    git clone https://github.com/ranas-mukminov/AutoHarden-Toolkit.git
    cd AutoHarden-Toolkit
    ```

2.  Run the hardening script:
    ```bash
    sudo bash harden.sh
    ```

## Configuration

The toolkit is configured via environment variables or a config file (coming soon in v1.0). Currently, the demo script runs with default safe settings.

## Commercial Support

Need enterprise-grade hardening, custom CIS profiles, or ongoing security auditing?

I provide professional DevOps & Security services:
- Infrastructure Security Audit
- CIS/GDPR/HIPAA Compliance Implementation
- Automated Hardening Pipelines

👉 **[Visit run-as-daemon.ru](https://run-as-daemon.ru)** or check my **[GitHub Profile](https://github.com/ranas-mukminov)**.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
