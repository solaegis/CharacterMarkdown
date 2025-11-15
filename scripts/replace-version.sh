#!/bin/bash
# Replace @project-version@ placeholder with actual Git version
# Usage: ./scripts/replace-version.sh <target_path> <version>
#
# If target_path is a file: replaces @project-version@ in that file
# If target_path is a directory: replaces @project-version@ in all files recursively
#
# This provides a general-purpose version replacement system that works
# anywhere @project-version@ appears (manifest, source files, docs, etc.)

set -e

TARGET="$1"
VERSION="$2"

if [ -z "$TARGET" ] || [ -z "$VERSION" ]; then
  echo "Usage: $0 <target_path> <version>"
  echo ""
  echo "Examples:"
  echo "  $0 CharacterMarkdown.addon 2.1.7       # Replace in single file"
  echo "  $0 src/ 2.1.7                          # Replace in directory"
  echo "  $0 . 2.1.7                             # Replace in all files"
  exit 1
fi

# Function to replace version in a single file
replace_in_file() {
  local file="$1"
  local version="$2"
  
  # Check if file contains the placeholder
  if grep -q "@project-version@" "$file" 2>/dev/null; then
    echo "  Replacing @project-version@ in: $file"
    
    # Use different sed syntax for macOS vs Linux
    if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i '' "s/@project-version@/${version}/g" "$file"
    else
      sed -i "s/@project-version@/${version}/g" "$file"
    fi
  fi
}

# Handle file vs directory
if [ -f "$TARGET" ]; then
  # Single file
  echo "📝 Replacing @project-version@ with ${VERSION} in file..."
  replace_in_file "$TARGET" "$VERSION"
  echo "✅ Done"
  
elif [ -d "$TARGET" ]; then
  # Directory - find all relevant files
  echo "📝 Replacing @project-version@ with ${VERSION} in directory: $TARGET"
  
  # Find all text files that might contain the placeholder
  # Include: .lua, .md, .txt, .addon, .xml
  find "$TARGET" -type f \( \
    -name "*.lua" -o \
    -name "*.md" -o \
    -name "*.txt" -o \
    -name "*.addon" -o \
    -name "*.xml" \
  \) | while read -r file; do
    replace_in_file "$file" "$VERSION"
  done
  
  echo "✅ Done"
  
else
  echo "❌ Error: $TARGET is not a file or directory"
  exit 1
fi

