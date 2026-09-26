#!/usr/bin/env bash
# Generate PDF from docs/director-checklist.md (pandoc or wkhtmltopdf).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="${ROOT}/docs/director-checklist.md"
OUT="${ROOT}/docs/director-checklist.pdf"

if [[ ! -f "$SRC" ]]; then
  echo "Missing $SRC" >&2
  exit 1
fi

if command -v pandoc >/dev/null 2>&1; then
  pandoc "$SRC" -o "$OUT" --metadata title="AutoHarden Director Checklist — Run_as_daemon"
  echo "Wrote $OUT (pandoc)"
  exit 0
fi

if command -v wkhtmltopdf >/dev/null 2>&1; then
  tmp="$(mktemp -t ah-director.XXXXXX.html)"
  if command -v pandoc >/dev/null 2>&1; then
    pandoc "$SRC" -o "$tmp"
  else
    # Minimal MD→HTML fallback
    {
      echo '<html><head><meta charset="utf-8"><title>AutoHarden Director Checklist — Run_as_daemon</title>'
      echo '<style>body{font-family:DejaVu Sans,Arial,sans-serif;max-width:800px;margin:2rem auto;line-height:1.45} table{border-collapse:collapse;width:100%} td,th{border:1px solid #ccc;padding:.4rem} h1{color:#111}</style></head><body>'
      # very small converter: escape and wrap pre for fidelity
      echo '<pre style="white-space:pre-wrap;font-family:inherit">'
      sed 's/&/\&amp;/g;s/</\&lt;/g;s/>/\&gt;/g' "$SRC"
      echo '</pre></body></html>'
    } > "$tmp"
  fi
  wkhtmltopdf "$tmp" "$OUT"
  rm -f "$tmp"
  echo "Wrote $OUT (wkhtmltopdf)"
  exit 0
fi

cat <<MSG
No PDF engine found. Install one of:
  - pandoc (+ pdflatex or weasyprint/wkhtmltopdf as needed)
  - wkhtmltopdf

Then re-run: ./scripts/generate-director-pdf.sh

Markdown source of truth remains: docs/director-checklist.md
MSG
exit 2
