#!/usr/bin/env bash
# CharacterMarkdown ZIP Structure Validator
# Ensures release ZIP has correct folder structure for ESO addon installation

set -euo pipefail

if [ $# -lt 1 ]; then
    echo "Usage: $0 <addon.zip>"
    exit 1
fi

ZIP_FILE="$1"

if [ ! -f "$ZIP_FILE" ]; then
    echo "❌ Error: ZIP file not found: $ZIP_FILE"
    exit 1
fi

echo "📦 Validating ZIP structure: $ZIP_FILE"
echo ""

# Get list of files in ZIP
CONTENTS=$(unzip -l "$ZIP_FILE" | awk 'NR>3 {print $4}' | grep -v '^$')

# Check for top-level folder
FIRST_ENTRY=$(echo "$CONTENTS" | head -1)
TOP_FOLDER=$(echo "$FIRST_ENTRY" | cut -d'/' -f1)

if [ "$TOP_FOLDER" != "CharacterMarkdown" ]; then
    echo "❌ Error: ZIP must contain a 'CharacterMarkdown/' folder at root"
    echo "   Found: $TOP_FOLDER"
    echo ""
    echo "ZIP structure should be:"
    echo "   CharacterMarkdown/"
    echo "   ├── CharacterMarkdown.txt (or .addon)"
    echo "   ├── CharacterMarkdown.lua"
    echo "   ├── CharacterMarkdown.xml"
    echo "   └── src/"
    exit 1
fi

echo "✅ Top-level folder: $TOP_FOLDER/"

# Check for required files
REQUIRED_FILES=(
    "CharacterMarkdown/CharacterMarkdown.txt"
    "CharacterMarkdown/CharacterMarkdown.xml"
    "CharacterMarkdown/src/Core.lua"
)

# Allow either .txt or .addon manifest
HAS_TXT=$(echo "$CONTENTS" | grep -c "^CharacterMarkdown/CharacterMarkdown.txt$" || true)
HAS_ADDON=$(echo "$CONTENTS" | grep -c "^CharacterMarkdown/CharacterMarkdown.addon$" || true)

if [ "$HAS_TXT" -eq 0 ] && [ "$HAS_ADDON" -eq 0 ]; then
    echo "❌ Error: Missing manifest file (CharacterMarkdown.txt or .addon)"
    exit 1
else
    if [ "$HAS_TXT" -gt 0 ]; then
        echo "✅ Manifest: CharacterMarkdown.txt"
    fi
    if [ "$HAS_ADDON" -gt 0 ]; then
        echo "✅ Manifest: CharacterMarkdown.addon"
    fi
fi

# Check for XML file
if echo "$CONTENTS" | grep -q "^CharacterMarkdown/CharacterMarkdown.xml$"; then
    echo "✅ UI Definition: CharacterMarkdown.xml"
else
    echo "❌ Error: Missing CharacterMarkdown.xml"
    exit 1
fi

# Check for source files
SRC_FILES=$(echo "$CONTENTS" | grep -c "^CharacterMarkdown/src/.*\.lua$" || true)
if [ "$SRC_FILES" -gt 0 ]; then
    echo "✅ Source files: $SRC_FILES Lua files in src/"
else
    echo "⚠️  Warning: No Lua files found in src/ directory"
fi

# Check for excluded development files (should NOT be in ZIP)
DEV_FILES=(
    ".git"
    ".github"
    "build/"
    "dist/"
    "docs/"
    ".DS_Store"
    ".gitignore"
    "Taskfile.yml"
    "README.md"
)

FOUND_DEV_FILES=()
for dev_file in "${DEV_FILES[@]}"; do
    if echo "$CONTENTS" | grep -q "CharacterMarkdown/$dev_file"; then
        FOUND_DEV_FILES+=("$dev_file")
    fi
done

if [ ${#FOUND_DEV_FILES[@]} -gt 0 ]; then
    echo ""
    echo "⚠️  Warning: Development files found in ZIP (should be excluded):"
    for dev_file in "${FOUND_DEV_FILES[@]}"; do
        echo "   - $dev_file"
    done
    echo ""
    echo "Consider updating .build-ignore to exclude these files."
fi

# Check file count
TOTAL_FILES=$(echo "$CONTENTS" | grep -c "^CharacterMarkdown/.*" || true)
echo ""
echo "📊 Total files in ZIP: $TOTAL_FILES"

# Check ZIP size
ZIP_SIZE=$(du -h "$ZIP_FILE" | cut -f1)
ZIP_SIZE_BYTES=$(stat -f%z "$ZIP_FILE" 2>/dev/null || stat -c%s "$ZIP_FILE" 2>/dev/null)
ZIP_SIZE_MB=$((ZIP_SIZE_BYTES / 1024 / 1024))

echo "📊 ZIP size: $ZIP_SIZE"

if [ "$ZIP_SIZE_MB" -gt 5 ]; then
    echo "⚠️  Warning: ZIP is larger than 5MB (ESO SavedVariables soft limit)"
    echo "   Consider reducing included assets or documentation."
fi

echo ""
echo "✅ ZIP structure validation passed!"
echo ""
echo "ZIP is ready for:"
echo "   - Manual upload to ESOUI.com"
echo "   - GitHub release attachment"
echo "   - Automated ESOUI upload via API"

exit 0
