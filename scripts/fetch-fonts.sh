#!/usr/bin/env sh
# Pulls the licensed webfonts from the private d-lawler/d-lawler-fonts repo
# into public/fonts before a build. The fonts are not in this repo.
# Only the files referenced in assets/scss/_typography.scss are copied.
set -e
DEST="public/fonts"
FONTS=$(grep -oE "/fonts/[A-Za-z0-9_-]+\.woff2" assets/scss/_typography.scss | sed 's#/fonts/##' | sort -u)

if [ -z "$FONTS_TOKEN" ]; then
  if ls "$DEST"/*.woff2 >/dev/null 2>&1; then
    echo "fetch-fonts: FONTS_TOKEN not set, using fonts already in $DEST"
  else
    echo "fetch-fonts: FONTS_TOKEN not set, building with fallback fonts"
  fi
  exit 0
fi

TMP="$(mktemp -d)"
git clone --quiet --depth 1 "https://x-access-token:${FONTS_TOKEN}@github.com/d-lawler/d-lawler-fonts.git" "$TMP"
mkdir -p "$DEST"
for f in $FONTS; do cp "$TMP/$f" "$DEST/"; done
rm -rf "$TMP"
echo "fetch-fonts: installed $(echo "$FONTS" | wc -l | tr -d ' ') fonts"
