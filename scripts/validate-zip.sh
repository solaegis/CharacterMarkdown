#!/bin/bash

# CharacterMarkdown - ZIP Package Validation Script
# Validates ZIP structure meets ESOUI requirements before upload
# Author: solaegis

set -e

# =============================================================================
# CONFIGURATION
# =============================================================================

ADDON_NAME="CharacterMarkdown"
DIST_DIR="dist"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# =============================================================================
# VALIDATION FUNCTIONS
# =============================================================================

print_header() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo " CharacterMarkdown - ZIP Package Validator"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

validate_zip_exists() {
    if [ ! -f "$1" ]; then
        print_error "ZIP file not found: $1"
        echo ""
        echo "Run: task build"
        exit 1
    fi
    print_success "ZIP file found: $1"
}

validate_zip_structure() {
    local zip_file="$1"
    
    echo ""
    echo "Validating ZIP structure..."
    echo ""
    
    # Get list of files in ZIP
    local zip_contents=$(unzip -l "$zip_file")
    
    # Check for required folder structure
    if ! echo "$zip_contents" | grep -q "${ADDON_NAME}/"; then
        print_error "ZIP must contain '${ADDON_NAME}/' folder at root"
        echo ""
        echo "Current structure:"
        unzip -l "$zip_file" | head -20
        return 1
    fi
    print_success "Root folder structure correct: ${ADDON_NAME}/"
    
    # Check for manifest file (.addon)
    if ! echo "$zip_contents" | grep -q "${ADDON_NAME}/${ADDON_NAME}.addon"; then
        print_error "Missing manifest file: ${ADDON_NAME}.addon"
        return 1
    fi
    print_success "Manifest file present: ${ADDON_NAME}.addon"
    
    # Check for XML file
    if ! echo "$zip_contents" | grep -q "${ADDON_NAME}/${ADDON_NAME}.xml"; then
        print_error "Missing XML file: ${ADDON_NAME}.xml"
        return 1
    fi
    print_success "XML file present: ${ADDON_NAME}.xml"
    
    # Check for source directory
    if ! echo "$zip_contents" | grep -q "${ADDON_NAME}/src/"; then
        print_error "Missing source directory: src/"
        return 1
    fi
    print_success "Source directory present: src/"
    
    # Check for critical Lua files
    local critical_files=(
        "src/Core.lua"
        "src/Init.lua"
        "src/Commands.lua"
        "src/Events.lua"
    )
    
    for file in "${critical_files[@]}"; do
        if ! echo "$zip_contents" | grep -q "${ADDON_NAME}/${file}"; then
            print_warning "Missing critical file: ${file}"
        fi
    done
    
    # Check for unwanted files
    local unwanted_patterns=(
        ".DS_Store"
        ".git/"
        ".github/"
        ".task/"
        "node_modules/"
        "test/"
        "*.backup"
        "Taskfile.yaml"
    )
    
    local has_unwanted=0
    for pattern in "${unwanted_patterns[@]}"; do
        if echo "$zip_contents" | grep -q "$pattern"; then
            print_warning "ZIP contains unwanted files: $pattern"
            has_unwanted=1
        fi
    done
    
    if [ $has_unwanted -eq 0 ]; then
        print_success "No unwanted files detected"
    fi
    
    echo ""
    return 0
}

validate_manifest_content() {
    local zip_file="$1"
    
    echo "Validating manifest content..."
    echo ""
    
    # Extract manifest to temp location
    local temp_dir=$(mktemp -d)
    unzip -q "$zip_file" "${ADDON_NAME}/${ADDON_NAME}.addon" -d "$temp_dir"
    local manifest_file="$temp_dir/${ADDON_NAME}/${ADDON_NAME}.addon"
    
    if [ ! -f "$manifest_file" ]; then
        print_error "Failed to extract manifest from ZIP"
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Check required fields
    local required_fields=(
        "Title"
        "Author"
        "Version"
        "AddOnVersion"
        "APIVersion"
        "SavedVariables"
    )
    
    for field in "${required_fields[@]}"; do
        if ! grep -q "^## ${field}:" "$manifest_file"; then
            print_error "Missing required manifest field: ## ${field}:"
            rm -rf "$temp_dir"
            return 1
        fi
    done
    print_success "All required manifest fields present"
    
    # Extract and display version info
    local version=$(grep "^## Version:" "$manifest_file" | awk '{print $3}')
    local api_version=$(grep "^## APIVersion:" "$manifest_file" | awk '{print $3}')
    local addon_version=$(grep "^## AddOnVersion:" "$manifest_file" | awk '{print $3}')
    
    echo ""
    echo "Version Information:"
    echo "  Version:       $version"
    echo "  API Version:   $api_version"
    echo "  AddOn Version: $addon_version"
    echo ""
    
    # Check for console compatibility (no .txt file should exist)
    if unzip -l "$zip_file" | grep -q "${ADDON_NAME}.txt"; then
        print_warning "ZIP contains old .txt manifest (should only have .addon for console compat)"
    else
        print_success "Console-compatible: Using .addon manifest"
    fi
    
    rm -rf "$temp_dir"
    return 0
}

validate_size() {
    local zip_file="$1"
    
    echo "Validating file size..."
    echo ""
    
    # Get file size
    local size_bytes=$(stat -f%z "$zip_file" 2>/dev/null || stat -c%s "$zip_file" 2>/dev/null)
    local size_mb=$((size_bytes / 1024 / 1024))
    local size_kb=$((size_bytes / 1024))
    
    echo "Package size: ${size_kb} KB (${size_mb} MB)"
    
    # ESOUI recommends < 10MB
    if [ $size_mb -gt 10 ]; then
        print_warning "Package size exceeds 10MB"
        print_warning "Consider optimizing assets or reducing file count"
    else
        print_success "Package size within recommended limits (< 10MB)"
    fi
    
    # Warn if very small (might be missing files)
    if [ $size_kb -lt 50 ]; then
        print_warning "Package is very small (< 50KB) - verify all files included"
    fi
    
    echo ""
    return 0
}

validate_file_count() {
    local zip_file="$1"
    
    echo "Analyzing file count..."
    echo ""
    
    local file_count=$(unzip -l "$zip_file" | grep -c "${ADDON_NAME}/")
    local lua_count=$(unzip -l "$zip_file" | grep -c "\.lua$")
    
    echo "Total files: $file_count"
    echo "Lua files:   $lua_count"
    
    if [ $lua_count -lt 5 ]; then
        print_warning "Very few Lua files detected (${lua_count}) - verify source files included"
    else
        print_success "Lua file count looks reasonable (${lua_count})"
    fi
    
    echo ""
    return 0
}

# =============================================================================
# MAIN VALIDATION
# =============================================================================

main() {
    print_header
    
    # Find most recent ZIP in dist directory
    if [ -z "$1" ]; then
        # Auto-detect latest ZIP
        ZIP_FILE=$(ls -t "${DIST_DIR}/${ADDON_NAME}"-*.zip 2>/dev/null | head -1)
        if [ -z "$ZIP_FILE" ]; then
            print_error "No ZIP files found in ${DIST_DIR}/"
            echo ""
            echo "Run: task build"
            exit 1
        fi
    else
        ZIP_FILE="$1"
    fi
    
    echo "Validating: $ZIP_FILE"
    echo ""
    
    # Run all validations
    validate_zip_exists "$ZIP_FILE" || exit 1
    validate_zip_structure "$ZIP_FILE" || exit 1
    validate_manifest_content "$ZIP_FILE" || exit 1
    validate_size "$ZIP_FILE" || exit 1
    validate_file_count "$ZIP_FILE" || exit 1
    
    # Final summary
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_success "All validations passed!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Package is ready for ESOUI upload:"
    echo "  $ZIP_FILE"
    echo ""
}

# Run validation
main "$@"
