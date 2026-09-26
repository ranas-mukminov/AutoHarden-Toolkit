#!/usr/bin/env bash
# Build reproducible source tarball + SHA256 for GitHub Releases.
# Usage: ./scripts/package-release.sh [version]
# Example: ./scripts/package-release.sh 0.2.0
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

VERSION="${1:-}"
if [[ -z "$VERSION" ]]; then
  if [[ -f lib/common.sh ]]; then
    VERSION="$(grep -E '^AH_VERSION=' lib/common.sh | head -1 | cut -d= -f2 | tr -d '"')"
  fi
fi
VERSION="${VERSION:-0.2.0}"
NAME="AutoHarden-Toolkit-${VERSION}"
DIST="${ROOT}/dist"
TAR="${DIST}/${NAME}.tar.gz"
SUM="${TAR}.sha256"

rm -rf "$DIST"
mkdir -p "$DIST"

# Prefer git archive for clean tree
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git archive --format=tar.gz --prefix="${NAME}/" HEAD -o "$TAR"
else
  tar --exclude='.git' --exclude='dist' --exclude='reports/*.md' \
    -czf "$TAR" --transform "s,^,${NAME}/," \
    bin lib profiles docs scripts harden.sh LICENSE README.md README.ru.md .gitignore
fi

(
  cd "$DIST"
  sha256sum "$(basename "$TAR")" > "$(basename "$SUM")"
)

cat <<MSG
Release artifacts:
  $TAR
  $SUM

Verify download:
  sha256sum -c $(basename "$SUM")

Suggested GitHub release notes (paste):
---
## AutoHarden-Toolkit v${VERSION}

### Artifacts
- \`${NAME}.tar.gz\` — source tree
- \`${NAME}.tar.gz.sha256\` — SHA256 checksum

### Verify
\`\`\`bash
sha256sum -c ${NAME}.tar.gz.sha256
\`\`\`

### License & support
MIT open source. Paid support / commercial Starter onboarding: https://run-as-daemon.ru (Run_as_daemon).

### Highlights
- CLI: \`bin/autoharden run|report\` — dry-run default, \`--apply\` explicit
- Profile: \`smb-default\`
- Director checklist (MD/PDF): \`docs/director-checklist.md\`
- Optional K3s pre-join: \`docs/k3s-pre-join-bootstrap.md\`
---

Tag & publish (example):
  git tag -a v${VERSION} -m "v${VERSION}"
  git push origin v${VERSION}
  gh release create v${VERSION} "$TAR" "$SUM" --title "v${VERSION}" --notes-file - 
MSG
