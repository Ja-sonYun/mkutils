#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$SCRIPT_DIR/src"
DIST_DIR="$SCRIPT_DIR/dist"

mkdir -p "$DIST_DIR"

echo "Building utils.mk..."

# Encode AWK scripts to base64
b64_semver_bump=$(base64 <"$SRC_DIR/awk/semver_bump.awk" | tr -d '\n')
b64_escape=$(base64 <"$SRC_DIR/awk/escape.awk" | tr -d '\n')
b64_version_cmp=$(base64 <"$SRC_DIR/awk/version_cmp.awk" | tr -d '\n')
b64_help=$(base64 <"$SRC_DIR/awk/help.awk" | tr -d '\n')

# Encode Python script to base64
b64_utils_py=$(base64 <"$SRC_DIR/py/input.py" | tr -d '\n')

output="$DIST_DIR/utils.mk"
tmp=$(mktemp "$DIST_DIR/.utils.mk.XXXXXX")
trap 'rm -f "$tmp"' EXIT
trap 'exit 1' HUP INT TERM
if [ -f "$output" ]; then
	cp -p "$output" "$tmp"
else
	chmod '=rw' "$tmp"
fi

# Concatenate all mk files in order and replace placeholders
for f in "$SRC_DIR"/mk/*.mk; do
	cat "$f" || exit 1
	echo ""
done |
	sed "s|__SEMVER_BUMP_AWK_B64__|$b64_semver_bump|g" |
	sed "s|__ESCAPE_AWK_B64__|$b64_escape|g" |
	sed "s|__VERSION_CMP_AWK_B64__|$b64_version_cmp|g" |
	sed "s|__HELP_AWK_B64__|$b64_help|g" |
	sed "s|__UTILS_PY_B64__|$b64_utils_py|g" \
		>"$tmp"
mv -f "$tmp" "$output"

echo "Done: $output"
