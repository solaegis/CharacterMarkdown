#!/bin/bash
# CharacterMarkdown - ESOUI listing and release compliance checks
# See docs/ESOUI_BEST_PRACTICES.md and docs/ESOUI_COMPLIANCE.md

set -euo pipefail

MANIFEST="${1:-CharacterMarkdown.txt}"
LISTING="${2:-README_ESOUI.txt}"
CHANGELOG="${3:-CHANGELOG.md}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASSED=0
FAILED=0
WARNINGS=0

ok() { echo -e "${GREEN}OK${NC}: $1"; PASSED=$((PASSED + 1)); }
fail() { echo -e "${RED}FAIL${NC}: $1"; FAILED=$((FAILED + 1)); }
warn() { echo -e "${YELLOW}WARN${NC}: $1"; WARNINGS=$((WARNINGS + 1)); }

echo "ESOUI compliance checks"
echo "  Manifest: $MANIFEST"
echo "  Listing:  $LISTING"
echo ""

if [ ! -f "$MANIFEST" ]; then
    fail "Manifest not found: $MANIFEST"
    exit 1
fi
if [ ! -f "$LISTING" ]; then
    fail "Listing description not found: $LISTING"
    exit 1
fi

# AI disclosure near top of listing
head_block=$(head -n 5 "$LISTING")
if echo "$head_block" | grep -q '\[B\]AI disclosure:\[/B\]'; then
    ok "AI disclosure present in first 5 lines of listing"
else
    fail "AI disclosure missing from start of $LISTING"
fi

# Credits block
if grep -q '\[B\]Credits:\[/B\]' "$LISTING"; then
    ok "Credits block present"
else
    fail "Credits block missing in $LISTING"
fi

# PC-only note
if grep -qi 'PC only' "$LISTING"; then
    ok "PC-only platform note present"
else
    fail "PC-only note missing in $LISTING"
fi

# ASCII-only listing and changelog (ESOUI listing uploads mojibake UTF-8)
check_ascii() {
    local file="$1"
    if LC_ALL=C grep -n '[^[:print:][:space:]]' "$file" >/dev/null 2>&1; then
        fail "Non-ASCII characters in $file (listing uploads must be ASCII-only)"
        LC_ALL=C grep -n '[^[:print:][:space:]]' "$file" | head -5
    else
        ok "ASCII-only: $file"
    fi
}
check_ascii "$LISTING"
if [ -f "$CHANGELOG" ]; then
    check_ascii "$CHANGELOG"
else
    warn "CHANGELOG.md not found"
fi

# No .addon in repo root for PC-only (source of truth)
if [ -f "CharacterMarkdown.addon" ]; then
    fail "CharacterMarkdown.addon present; PC-only releases must use .txt only"
else
    ok "No CharacterMarkdown.addon (PC .txt only)"
fi

# OptionalDependsOn ↔ listing sync
opt_line=$(grep '^## OptionalDependsOn:' "$MANIFEST" || true)
if [ -n "$opt_line" ]; then
    deps=$(echo "$opt_line" | sed 's/^## OptionalDependsOn:[[:space:]]*//')
    missing=0
    for token in $deps; do
        name=$(echo "$token" | sed 's/[>=].*//')
        if ! grep -q "$name" "$LISTING"; then
            fail "Optional dependency '$name' not mentioned in $LISTING"
            missing=1
        fi
    done
    if [ "$missing" -eq 0 ]; then
        ok "All OptionalDependsOn libraries listed in $LISTING"
    fi
else
    ok "No OptionalDependsOn to sync"
fi

# Hard deps must appear in listing (also checked in validate-manifest.lua)
for field in DependsOn PCDependsOn ConsoleDependsOn; do
    hard=$(grep "^## ${field}:" "$MANIFEST" || true)
    if [ -n "$hard" ]; then
        deps=$(echo "$hard" | sed "s/^## ${field}:[[:space:]]*//")
        for token in $deps; do
            name=$(echo "$token" | sed 's/[>=].*//')
            if ! grep -q "$name" "$LISTING"; then
                fail "Hard dependency '$name' ($field) not listed in $LISTING"
            else
                ok "Hard dependency '$name' listed in $LISTING"
            fi
        done
    fi
done

# Changelog has version entries
if [ -f "$CHANGELOG" ]; then
    if grep -q '^## \[' "$CHANGELOG"; then
        ok "CHANGELOG.md has version entries"
        version=$(grep '^## Version:' "$MANIFEST" | awk '{print $3}')
        if [ "$version" != "@project-version@" ] && [ -n "$version" ]; then
            if grep -q "^## \[${version}\]" "$CHANGELOG"; then
                ok "CHANGELOG has entry for Version $version"
            else
                warn "No CHANGELOG entry matching manifest Version $version (ok if still @project-version@ at tag time)"
            fi
        fi
    else
        fail "CHANGELOG.md has no ## [version] entries"
    fi
fi

# Delegate wiki manifest rules
if command -v lua >/dev/null 2>&1; then
    if lua scripts/validate-manifest.lua "$MANIFEST"; then
        ok "Manifest wiki validation passed"
    else
        fail "Manifest wiki validation failed"
    fi
else
    warn "lua not found; skipped validate-manifest.lua"
fi

echo ""
echo "Passed: $PASSED  Failed: $FAILED  Warnings: $WARNINGS"
if [ "$FAILED" -gt 0 ]; then
    exit 1
fi
exit 0
