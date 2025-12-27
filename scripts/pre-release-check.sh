#!/bin/bash

# CharacterMarkdown - Pre-Release Validation Script
# Runs comprehensive validation checks before release
# Usage: ./scripts/pre-release-check.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
PASSED=0
FAILED=0
WARNINGS=0

# Print functions
print_header() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo " CharacterMarkdown - Pre-Release Validation"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
    ((PASSED++))
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
    ((FAILED++))
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    ((WARNINGS++))
}

print_section() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if task command is available
check_task() {
    if ! command_exists task; then
        print_error "Task command not found. Install with: brew install go-task/tap/go-task"
        return 1
    fi
    return 0
}

# Validation functions
validate_lint() {
    print_section "1. Code Linting (Luacheck)"
    
    if ! check_task; then
        return 1
    fi
    
    if task lint > /dev/null 2>&1; then
        print_success "Lint check passed"
        return 0
    else
        print_error "Lint check failed - run 'task lint' for details"
        return 1
    fi
}

validate_syntax() {
    print_section "2. Lua Syntax Validation"
    
    if ! check_task; then
        return 1
    fi
    
    if task dev:validate:syntax > /dev/null 2>&1; then
        print_success "Syntax validation passed"
        return 0
    else
        print_error "Syntax validation failed - run 'task dev:validate:syntax' for details"
        return 1
    fi
}

validate_manifest() {
    print_section "3. Manifest Validation"
    
    MANIFEST_FILE="CharacterMarkdown.addon"
    
    if [ ! -f "$MANIFEST_FILE" ]; then
        print_error "Manifest file not found: $MANIFEST_FILE"
        return 1
    fi
    
    # Check required fields
    local required_fields=("Title" "Author" "Version" "APIVersion")
    local missing_fields=()
    
    for field in "${required_fields[@]}"; do
        if ! grep -q "^## ${field}:" "$MANIFEST_FILE"; then
            missing_fields+=("$field")
        fi
    done
    
    if [ ${#missing_fields[@]} -gt 0 ]; then
        print_error "Missing required manifest fields: ${missing_fields[*]}"
        return 1
    fi
    
    # Check version placeholder
    if ! grep -q "@project-version@" "$MANIFEST_FILE"; then
        print_warning "Manifest doesn't use @project-version@ placeholder (may be using fixed version)"
    fi
    
    # Validate with script if available
    if [ -f "scripts/validate-manifest.lua" ]; then
        if command_exists lua; then
            if lua scripts/validate-manifest.lua "$MANIFEST_FILE" > /dev/null 2>&1; then
                print_success "Manifest validation passed"
                return 0
            else
                print_error "Manifest validation failed - run 'lua scripts/validate-manifest.lua $MANIFEST_FILE' for details"
                return 1
            fi
        fi
    fi
    
    print_success "Manifest basic validation passed"
    return 0
}

validate_files() {
    print_section "4. File Structure Validation"
    
    if ! check_task; then
        return 1
    fi
    
    if task dev:validate:files > /dev/null 2>&1; then
        print_success "File structure validation passed"
        return 0
    else
        print_error "File structure validation failed - run 'task dev:validate:files' for details"
        return 1
    fi
}

validate_changelog() {
    print_section "5. CHANGELOG Validation"
    
    CHANGELOG_FILE="CHANGELOG.md"
    
    if [ ! -f "$CHANGELOG_FILE" ]; then
        print_error "CHANGELOG.md not found"
        return 1
    fi
    
    # Check for version entry
    if grep -q "^## \[.*\]" "$CHANGELOG_FILE"; then
        print_success "CHANGELOG.md has version entries"
        
        # Check for Unreleased section
        if grep -q "^## \[Unreleased\]" "$CHANGELOG_FILE"; then
            print_warning "CHANGELOG.md has [Unreleased] section - ensure it's updated for release"
        fi
    else
        print_error "CHANGELOG.md has no version entries"
        return 1
    fi
    
    return 0
}

validate_readme() {
    print_section "6. README.md Validation"
    
    README_FILE="README.md"
    MANIFEST_FILE="CharacterMarkdown.addon"
    
    if [ ! -f "$README_FILE" ]; then
        print_error "README.md not found"
        return 1
    fi
    
    # Get API version from manifest
    if [ -f "$MANIFEST_FILE" ]; then
        MANIFEST_API=$(grep "^## APIVersion:" "$MANIFEST_FILE" | awk '{print $3}')
        
        # Check if README has matching API badge
        if grep -q "badge/ESO_API-${MANIFEST_API}-" "$README_FILE"; then
            print_success "API version badge matches manifest ($MANIFEST_API)"
        else
            print_warning "API version badge may not match manifest (expected: $MANIFEST_API)"
        fi
    fi
    
    # Note about version badge
    if grep -q "@project-version@" "$MANIFEST_FILE"; then
        print_success "Version badge uses Git-based versioning"
    fi
    
    return 0
}

validate_git_state() {
    print_section "7. Git State Validation"
    
    if ! command_exists git; then
        print_warning "Git not found - skipping git validation"
        return 0
    fi
    
    # Check if in git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_warning "Not in a git repository - skipping git validation"
        return 0
    fi
    
    # Check for uncommitted changes
    if [ -n "$(git status --porcelain)" ]; then
        print_warning "Uncommitted changes detected - ensure all changes are committed before release"
        git status --short
    else
        print_success "Working directory is clean"
    fi
    
    # Check current branch
    CURRENT_BRANCH=$(git branch --show-current)
    if [ "$CURRENT_BRANCH" = "main" ] || [ "$CURRENT_BRANCH" = "master" ]; then
        print_success "On release branch: $CURRENT_BRANCH"
    else
        print_warning "Not on main/master branch: $CURRENT_BRANCH"
    fi
    
    return 0
}

validate_build() {
    print_section "8. Build Validation"
    
    if ! check_task; then
        return 1
    fi
    
    # Clean previous builds
    if [ -d "dist" ]; then
        rm -rf dist/*.zip 2>/dev/null || true
    fi
    
    # Run build
    if task build > /dev/null 2>&1; then
        print_success "Build completed successfully"
        
        # Check for ZIP file
        ZIP_FILE=$(ls -t dist/CharacterMarkdown-*.zip 2>/dev/null | head -1)
        if [ -n "$ZIP_FILE" ] && [ -f "$ZIP_FILE" ]; then
            print_success "Release ZIP created: $(basename "$ZIP_FILE")"
            
            # Validate ZIP if script exists
            if [ -f "scripts/validate-zip.sh" ]; then
                chmod +x scripts/validate-zip.sh 2>/dev/null || true
                if scripts/validate-zip.sh "$ZIP_FILE" > /dev/null 2>&1; then
                    print_success "ZIP validation passed"
                else
                    print_warning "ZIP validation had warnings - run 'scripts/validate-zip.sh $ZIP_FILE' for details"
                fi
            fi
        else
            print_error "Release ZIP not found after build"
            return 1
        fi
    else
        print_error "Build failed - run 'task build' for details"
        return 1
    fi
    
    return 0
}

# Main validation
main() {
    print_header
    
    local validation_failed=0
    
    # Run all validations
    validate_lint || validation_failed=1
    validate_syntax || validation_failed=1
    validate_manifest || validation_failed=1
    validate_files || validation_failed=1
    validate_changelog || validation_failed=1
    validate_readme || true  # Don't fail on README warnings
    validate_git_state || true  # Don't fail on git checks
    validate_build || validation_failed=1
    
    # Summary
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo " Validation Summary"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo -e "${GREEN}✅ Passed: $PASSED${NC}"
    echo -e "${RED}❌ Failed: $FAILED${NC}"
    echo -e "${YELLOW}⚠️  Warnings: $WARNINGS${NC}"
    echo ""
    
    if [ $validation_failed -eq 0 ]; then
        echo -e "${GREEN}✅ All critical validations passed!${NC}"
        echo ""
        echo "Next steps:"
        echo "  1. Review CHANGELOG.md and update if needed"
        echo "  2. Test in-game: /markdown test"
        echo "  3. Create git tag: git tag -a v<version> -m 'Release v<version>'"
        echo "  4. Push tag: git push origin main --tags"
        echo ""
        exit 0
    else
        echo -e "${RED}❌ Some validations failed. Please fix errors before releasing.${NC}"
        echo ""
        exit 1
    fi
}

# Run main validation
main "$@"

