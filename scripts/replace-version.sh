#!/bin/bash
# Replace @project-version@ placeholder with actual Git version
# Usage: ./scripts/replace-version.sh <manifest_file> <version>

set -e

MANIFEST_FILE="$1"
VERSION="$2"

if [ -z "$MANIFEST_FILE" ] || [ -z "$VERSION" ]; then
  echo "Usage: $0 <manifest_file> <version>"
  exit 1
fi

# Replace @project-version@ with actual version
sed "s/@project-version@/${VERSION}/g" "$MANIFEST_FILE" > "${MANIFEST_FILE}.tmp"
mv "${MANIFEST_FILE}.tmp" "$MANIFEST_FILE"

