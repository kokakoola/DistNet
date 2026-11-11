#!/usr/bin/env bash
# Render the thesis (HTML + docx), push main to GitHub, publish the thesis
# HTML to GitHub Pages (gh-pages branch) and copy the docx to the synced
# SharePoint Review folder as a new version. Does not commit: commit first.
# Usage (from anywhere): ./publish.sh
set -euo pipefail

repo="$(cd "$(dirname "$0")" && pwd)"
thesis="$repo/report/thesis"
cd "$repo"

# Uncommitted thesis changes would be published but not pushed -- warn
if [ -n "$(git status --porcelain -- report/thesis)" ]; then
  echo "WARNING: uncommitted changes in report/thesis:"
  git status --short -- report/thesis
  read -r -p "Continue anyway? [y/N] " answer
  [ "$answer" = "y" ] || exit 1
fi

echo "== Rendering thesis (HTML + docx)"
(cd "$thesis" && quarto render)
echo "docx: $thesis/_book/DistNet_thesis.docx"

echo "== Pushing main to GitHub"
git push origin main

echo "== Publishing thesis HTML to GitHub Pages"
(cd "$thesis" && quarto publish gh-pages --no-render --no-prompt)

echo "== Uploading docx to SharePoint Docs/Review (new version)"
Rscript -e 'source(here::here("R/helpers/review_sync.R")); cat(upload_review(), "\n")'

echo "Done."
