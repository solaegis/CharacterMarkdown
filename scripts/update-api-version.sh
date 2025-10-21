#!/bin/bash
# Update ESO API Version Script
# Usage: ./scripts/update-api-version.sh [API_VERSION]
# Example: ./scripts/update-api-version.sh 101047

set -e

ADDON_NAME="CharacterMarkdown"
MANIFEST_FILE="${ADDON_NAME}.addon"

# Check if API version was provided as argument
if [ $# -eq 1 ]; then
    NEW_API_VERSION="$1"
    echo "📝 Updating API version to: $NEW_API_VERSION"
else
    echo "❌ Error: API version required"
    echo ""
    echo "Usage: $0 [API_VERSION]"
    echo ""
    echo "To get current API version:"
    echo "  1. Launch ESO"
    echo "  2. Type in chat: /script d(GetAPIVersion())"
    echo "  3. Run: $0 [VERSION_NUMBER]"
    echo ""
    echo "Example:"
    echo "  $0 101047"
    exit 1
fi

# Validate API version format (should be 6 digits)
if ! [[ "$NEW_API_VERSION" =~ ^[0-9]{6}$ ]]; then
    echo "❌ Error: API version must be 6 digits (e.g., 101047)"
    exit 1
fi

# Check if manifest file exists
if [ ! -f "$MANIFEST_FILE" ]; then
    echo "❌ Error: Manifest file '$MANIFEST_FILE' not found"
    exit 1
fi

# Get current API version
CURRENT_API_VERSION=$(grep "^## APIVersion:" "$MANIFEST_FILE" | awk '{print $3}')
echo "📋 Current API version: $CURRENT_API_VERSION"

# Update the manifest
echo "🔄 Updating manifest..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/^## APIVersion: .*/## APIVersion: $NEW_API_VERSION/g" "$MANIFEST_FILE"
else
    # Linux
    sed -i "s/^## APIVersion: .*/## APIVersion: $NEW_API_VERSION/g" "$MANIFEST_FILE"
fi

# Verify the update
UPDATED_API_VERSION=$(grep "^## APIVersion:" "$MANIFEST_FILE" | awk '{print $3}')
if [ "$UPDATED_API_VERSION" = "$NEW_API_VERSION" ]; then
    echo "✅ Successfully updated API version: $CURRENT_API_VERSION → $NEW_API_VERSION"
    
    # Show the updated line
    echo "📄 Updated line:"
    grep "^## APIVersion:" "$MANIFEST_FILE"
    
    echo ""
    echo "📝 Next steps:"
    echo "  1. Test the addon in ESO to ensure compatibility"
    echo "  2. Commit the changes: git add $MANIFEST_FILE"
    echo "  3. Commit: git commit -m 'Update API version to $NEW_API_VERSION'"
    echo "  4. Push: git push origin main"
    echo "  5. Create release tag: git tag vX.X.X"
    echo "  6. Push tag: git push origin main --tags"
else
    echo "❌ Error: Failed to update API version"
    exit 1
fi
