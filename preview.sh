#!/usr/bin/env bash
# quarto preview for the thesis + re-render when an include file (_*.qmd) changes.
# quarto preview only watches the chapter files, so the watcher touches every
# file that includes the changed _*.qmd (also nested includes).
# Usage (repo root): ./preview.sh   -- stop with Ctrl+C
set -euo pipefail

thesis="$(cd "$(dirname "$0")/report/thesis" && pwd)"

python3 - "$thesis" <<'EOF' &
import os, re, sys, time
from pathlib import Path

root = Path(sys.argv[1])
inc = re.compile(r"\{\{<\s*include\s+([^\s>]+)\s*>\}\}")

def mtimes():
    return {p: p.stat().st_mtime for p in root.glob("*.qmd")}

def parents(name):
    # files that include `name`
    return [p for p in root.glob("*.qmd") if name in inc.findall(p.read_text(encoding="utf-8"))]

seen = mtimes()
while True:
    time.sleep(1)
    now = mtimes()
    changed = [p for p, t in now.items() if p.name.startswith("_") and t > seen.get(p, 0)]
    touched = set()
    queue = [p.name for p in changed]
    while queue:
        for parent in parents(queue.pop()):
            if parent not in touched:
                touched.add(parent)
                parent.touch()
                if parent.name.startswith("_"):
                    queue.append(parent.name)
    for p in touched:
        print(f"[watch] include changed -> re-render {p.name}", flush=True)
    seen = mtimes()
EOF
watcher=$!
trap 'kill $watcher 2>/dev/null' EXIT

cd "$thesis"
quarto preview
