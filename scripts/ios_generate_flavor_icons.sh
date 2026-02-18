#!/usr/bin/env bash
# Generate iOS app icon sizes from assets/logo for dev and staging flavors.
# Run from project root: ./scripts/ios_generate_flavor_icons.sh
# Requires: sips (macOS) or ImageMagick (convert).

set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ASSETS="$ROOT/assets/logo"
DEV_SRC="$ASSETS/app_icon_dev.png"
UAT_SRC="$ASSETS/app_icon_uat.png"
XCASSETS="$ROOT/ios/Runner/Assets.xcassets"

# size_px: physical pixel size (e.g. 40 for 20x20@2x)
gen_icon() {
  local src="$1"
  local out="$2"
  local size_px="$3"
  if [[ ! -f "$src" ]]; then echo "Skip (missing): $src"; return; fi
  if command -v sips &>/dev/null; then
    sips -z "$size_px" "$size_px" "$src" --out "$out" 2>/dev/null || true
  elif command -v convert &>/dev/null; then
    convert "$src" -resize "${size_px}x${size_px}!" "$out" 2>/dev/null || true
  else
    echo "Need sips (macOS) or ImageMagick (convert). Copying 1024 only."
    if [[ "$size_px" -eq 1024 ]]; then cp "$src" "$out"; fi
    return
  fi
}

# Generate all sizes from Contents.json into output dir
# Usage: generate_set <source_png> <appiconset_dir>
generate_set() {
  local src="$1"
  local dir="$2"
  mkdir -p "$dir"
  # Format: filename:size
  local entries=(
    "Icon-App-20x20@2x.png:40"
    "Icon-App-20x20@3x.png:60"
    "Icon-App-29x29@1x.png:29"
    "Icon-App-29x29@2x.png:58"
    "Icon-App-29x29@3x.png:87"
    "Icon-App-40x40@2x.png:80"
    "Icon-App-40x40@3x.png:120"
    "Icon-App-57x57@1x.png:57"
    "Icon-App-57x57@2x.png:114"
    "Icon-App-60x60@2x.png:120"
    "Icon-App-60x60@3x.png:180"
    "Icon-App-20x20@1x.png:20"
    "Icon-App-40x40@1x.png:40"
    "Icon-App-50x50@1x.png:50"
    "Icon-App-50x50@2x.png:100"
    "Icon-App-72x72@1x.png:72"
    "Icon-App-72x72@2x.png:144"
    "Icon-App-76x76@1x.png:76"
    "Icon-App-76x76@2x.png:152"
    "Icon-App-83.5x83.5@2x.png:167"
    "Icon-App-1024x1024@1x.png:1024"
  )
  for entry in "${entries[@]}"; do
    local filename="${entry%%:*}"
    local size="${entry##*:}"
    gen_icon "$src" "$dir/$filename" "$size"
  done
  echo "Generated icons in $dir"
}

echo "Generating AppIcon-Dev from $DEV_SRC"
generate_set "$DEV_SRC" "$XCASSETS/AppIcon-Dev.appiconset"

echo "Generating AppIcon-Staging from $UAT_SRC"
generate_set "$UAT_SRC" "$XCASSETS/AppIcon-Staging.appiconset"

echo "Done. Build dev/staging in Xcode to use the new icons."
