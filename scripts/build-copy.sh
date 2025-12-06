#!/bin/bash

# CharacterMarkdown - Whitelist-Based Build Copy Script
# CRITICAL: Only copies ESOUI-allowed file types: *.lua, *.xml, *.txt, *.addon, *.md
# This prevents ANY disallowed files from being included in the build

set -e

SOURCE_DIR="$1"
DEST_DIR="$2"

if [ -z "$SOURCE_DIR" ] || [ -z "$DEST_DIR" ]; then
    echo "Usage: $0 <source_dir> <dest_dir>"
    exit 1
fi

# ESOUI-allowed file extensions (whitelist)
ALLOWED_EXTENSIONS=("lua" "xml" "txt" "addon" "md")

# Create destination directory
mkdir -p "$DEST_DIR"

# Copy manifest file (required)
if [ -f "$SOURCE_DIR/CharacterMarkdown.addon" ]; then
    cp "$SOURCE_DIR/CharacterMarkdown.addon" "$DEST_DIR/"
    echo "  ✓ Copied manifest: CharacterMarkdown.addon"
fi

# Copy README_ESOUI.txt if it exists
if [ -f "$SOURCE_DIR/README_ESOUI.txt" ]; then
    cp "$SOURCE_DIR/README_ESOUI.txt" "$DEST_DIR/"
    echo "  ✓ Copied README_ESOUI.txt"
fi

# Copy src/ directory with whitelist filtering
if [ -d "$SOURCE_DIR/src" ]; then
    mkdir -p "$DEST_DIR/src"
    
    # Find and copy only allowed file types recursively
    # EXCLUDE test files and test directories
    # CRITICAL: Use -name patterns (not -path) for filename matching across all directories
    for ext in "${ALLOWED_EXTENSIONS[@]}"; do
        find "$SOURCE_DIR/src" -type f -name "*.${ext}" \
            ! -path "*/test/*" \
            ! -path "*/tests/*" \
            ! -name "*Tests.lua" \
            ! -name "test_*.lua" \
            ! -name "*_test.lua" \
            ! -name "verify_*.lua" \
            ! -name "debug_*.lua" \
            ! -name "reproduce_*.lua" \
            ! -path "*/.luarocks/*" \
            | while read -r file; do
            # Get relative path from src/
            rel_path="${file#$SOURCE_DIR/src/}"
            dest_file="$DEST_DIR/src/$rel_path"
            dest_dir=$(dirname "$dest_file")
            
            # Create directory structure
            mkdir -p "$dest_dir"
            
            # Copy file
            cp "$file" "$dest_file"
        done
    done
    
    echo "  ✓ Copied src/ directory (whitelist: ${ALLOWED_EXTENSIONS[*]})"
fi

echo "✅ Whitelist-based copy complete"
echo "   Only ESOUI-allowed file types included: ${ALLOWED_EXTENSIONS[*]}"
