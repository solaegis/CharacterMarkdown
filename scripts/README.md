# Scripts

Utility scripts for CharacterMarkdown development and maintenance.

## trim.py

**Purpose**: Intelligently trim unnecessary newlines from markdown files without breaking markdown syntax.

**Features**:
- Reduces excessive consecutive blank lines (3+ → 2)
- Removes trailing whitespace on lines
- Ensures file ends with single newline
- Removes chunk markers from CharacterMarkdown output (`<!-- Chunk N ... -->`)
- Removes excessive padding (550+ trailing newlines added by chunking algorithm)
- Preserves code blocks, HTML blocks, and tables

**Usage**:
```bash
# Trim all example files
task examples:trim

# Preview changes without modifying files
task examples:trim:dry-run

# Direct usage
python3 scripts/trim.py file1.md file2.md

# With dry-run
python3 scripts/trim.py --dry-run file1.md file2.md
```

**What it removes**:
- Chunk markers like `<!-- Chunk 1 (20414 bytes before padding) -->`
- Excessive trailing newlines (550+ blank lines used for paste safety)
- Multiple consecutive blank lines (reduces to max 2)
- Trailing whitespace on lines

**What it preserves**:
- All actual markdown content
- Code block formatting (between `````)
- HTML block structure (`<div>`, etc.)
- Table spacing
- Heading, list, and blockquote formatting

**Background**: CharacterMarkdown's chunking system adds chunk markers and excessive padding (550+ newlines) to protect against paste truncation. This is intentional for the in-game display but unnecessary for saved example files. This script cleans up saved examples while preserving all actual content.

## Other Scripts

### pre-release-check.sh
Comprehensive pre-release validation script. Checks:
- Lua syntax validation
- Manifest validation
- File structure
- CHANGELOG entries
- README badges
- Git status

Run via: `task release:check`

### replace-version.sh
Replaces `@project-version@` placeholders with actual version during build.
Used automatically by `task build:release`.

### update-api-version.sh
Updates ESO API version in manifest file.

Usage: `task version:api -- <API_VERSION>`

### validate-manifest.lua
Validates CharacterMarkdown.addon manifest file structure.
Used by build and validation tasks.

### validate-zip.sh
Validates release ZIP package meets ESOUI requirements.
Used automatically by `task build:release`.

## Git Hooks

### pre-push
Optional pre-push hook for validation before pushing tags.

Install: `task git:hooks:install`

Runs validation checks before allowing tag pushes to prevent broken releases.

