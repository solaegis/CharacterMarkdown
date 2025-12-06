#!/bin/bash

# CharacterMarkdown - Pre-Build Validation Script
# Checks for disallowed files BEFORE building to fail fast (shift left)

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ESOUI-allowed file extensions (whitelist)
ALLOWED_EXTENSIONS=("lua" "xml" "txt" "addon" "md")

# Directories to check (only check what would be included in build)
# Exclude directories that are already in .build-ignore
CHECK_DIRS=("src")

# Files at root that should be checked (manifest, README_ESOUI.txt)
ROOT_FILES=("CharacterMarkdown.addon" "README_ESOUI.txt")

echo "🔍 Pre-Build Validation: Checking for disallowed file types..."
echo ""

# Find all files with disallowed extensions
DISALLOWED_FOUND=0

# Check for common disallowed file types ONLY in directories that would be included
DISALLOWED_PATTERNS=(
    "*.h"
    "*.hpp"
    "*.c"
    "*.cpp"
    "*.py"
    "*.sh"
    "*.yaml"
    "*.yml"
    "*.toml"
    "*.json"
    "*.js"
    "*.css"
    "*.html"
    "*.htm"
    "*.rockspec"
)

for pattern in "${DISALLOWED_PATTERNS[@]}"; do
    # Find files matching pattern ONLY in directories that would be included in build
    found=$(find "${CHECK_DIRS[@]}" -type f -name "$pattern" \
        ! -path "*/build/*" \
        ! -path "*/dist/*" \
        ! -path "*/.git/*" \
        ! -path "*/.task/*" \
        ! -path "*/node_modules/*" \
        ! -path "*/venv/*" \
        ! -path "*/.venv/*" \
        ! -path "*/.luarocks/*" \
        ! -path "*/docs/*" \
        ! -path "*/book/*" \
        ! -path "*/scripts/*" \
        ! -path "*/examples/*" \
        ! -path "*/assets/*" \
        ! -path "*/tests/*" \
        ! -path "*/test/*" \
        2>/dev/null | head -10)
    
    if [ -n "$found" ]; then
        echo -e "${RED}❌ Found disallowed files: $pattern${NC}"
        echo "$found" | sed 's/^/   /'
        DISALLOWED_FOUND=1
    fi
done

# Check for .luarocks directory in src/ (would be included)
if [ -d "src/.luarocks" ]; then
    echo -e "${RED}❌ Found .luarocks directory in src/${NC}"
    echo "   src/.luarocks/ (contains documentation files not allowed by ESOUI)"
    DISALLOWED_FOUND=1
fi

# Check for any files in src/ that don't match allowed extensions
if [ -d "src" ]; then
    # Find all files in src/
    all_files=$(find src -type f ! -path "*/.*" 2>/dev/null)
    
    while IFS= read -r file; do
        if [ -z "$file" ]; then
            continue
        fi
        
        ext="${file##*.}"
        ext_lower=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
        
        # Check if extension is in allowed list
        allowed=0
        for allowed_ext in "${ALLOWED_EXTENSIONS[@]}"; do
            if [ "$ext_lower" = "$allowed_ext" ]; then
                allowed=1
                break
            fi
        done
        
        if [ $allowed -eq 0 ]; then
            echo -e "${RED}❌ Disallowed file in src/: $file${NC}"
            echo "   Extension '.$ext' is not allowed (only: ${ALLOWED_EXTENSIONS[*]})"
            DISALLOWED_FOUND=1
        fi
    done <<< "$all_files"
fi

echo ""

if [ $DISALLOWED_FOUND -eq 1 ]; then
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${RED}❌ PRE-BUILD VALIDATION FAILED${NC}"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "ESOUI only allows these file types:"
    echo "  ${ALLOWED_EXTENSIONS[*]}"
    echo ""
    echo "Please remove or exclude disallowed files before building."
    echo "Update .build-ignore or remove files from repository."
    exit 1
else
    echo -e "${GREEN}✅ Pre-build validation passed${NC}"
    echo "   No disallowed file types found in source directories"
    echo "   Allowed extensions: ${ALLOWED_EXTENSIONS[*]}"
    exit 0
fi

