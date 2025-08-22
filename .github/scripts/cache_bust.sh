#!/usr/bin/env bash
set -euo pipefail
DIR="${1:-preview-seed}"
BUILD_ID="$(date -u +%Y%m%d%H%M%S)"

# Inject no-cache meta tags and append ?v=BUILD_ID to assets in all HTML files
find "$DIR" -type f -name "*.html" | while read -r f; do
  # Add/replace cache-control meta group inside <head>
  # If <head> exists, inject after the first <head>; otherwise, skip
  if grep -qi "<head" "$f"; then
    # remove old injected markers if any
    sed -i '/<!-- cache-bust-start -->/,/<!-- cache-bust-end -->/d' "$f"
    
    # inject no-cache meta tags after <head>
    sed -i '/<head[^>]*>/i\
<!-- cache-bust-start -->\
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />\
    <meta http-equiv="Pragma" content="no-cache" />\
    <meta http-equiv="Expires" content="0" />\
<!-- cache-bust-end -->' "$f"
    
    # append ?v=BUILD_ID to CSS and JS assets
    sed -i "s/\(href=[\"'][^\"']*\.css\)\([\"']\)/\1?v=$BUILD_ID\2/g" "$f"
    sed -i "s/\(src=[\"'][^\"']*\.js\)\([\"']\)/\1?v=$BUILD_ID\2/g" "$f"
    
    echo "Cache-busted: $f (build: $BUILD_ID)"
  fi
done

echo "Cache-busting complete for $DIR with build ID: $BUILD_ID"