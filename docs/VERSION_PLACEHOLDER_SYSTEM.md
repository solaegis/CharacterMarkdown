# Version Placeholder System

## Overview

CharacterMarkdown uses a **general-purpose version placeholder system** that works consistently across all files and build environments.

**Key Principle**: Use `@project-version@` placeholder anywhere you need the version, and it will be automatically replaced during build.

---

## How It Works

### 1. Use `@project-version@` Anywhere

The placeholder can appear in:
- ✅ **Manifest files** (`CharacterMarkdown.addon`)
- ✅ **Source code** (`src/Core.lua`)
- ✅ **Documentation** (`*.md` files)
- ✅ **Text files** (`*.txt`)
- ✅ **XML files** (`*.xml`)

**Example usage:**

```lua
-- src/Core.lua
CM.version = "@project-version@" -- Replaced during build

-- CharacterMarkdown.addon
## Version: @project-version@

-- README.md
Current version: @project-version@
```

### 2. Build Process Replaces It

**Local builds** (`task build`):
```bash
# Replaces @project-version@ in entire build directory
./scripts/replace-version.sh build/CharacterMarkdown/ "2.1.8"
```

**GitHub Actions** (on tag push):
```bash
# Replaces @project-version@ in all files
./scripts/replace-version.sh . "2.1.8"
```

### 3. Version Comes from Git Tags

**When tagged**: Uses tag version (e.g., `v2.1.8` → `2.1.8`)  
**When not tagged**: Uses commit SHA (e.g., `abc123d`)

---

## Benefits

### ✅ Consistency
- Same approach everywhere (no hardcoded versions)
- Works in local builds and GitHub Actions
- No version mismatch between files

### ✅ Flexibility
- Add `@project-version@` anywhere it's needed
- Automatically replaced during build
- No special-case handling required

### ✅ Maintainability
- Single source of truth (Git tags)
- No manual version updates in multiple files
- Less error-prone

### ✅ Developer-Friendly
- Clear placeholder syntax
- Easy to spot unreplaced versions
- Works in development mode too

---

## Files Using `@project-version@`

### Currently Implemented

1. **CharacterMarkdown.addon**
   ```
   ## Version: @project-version@
   ```

2. **src/Core.lua**
   ```lua
   -- CharacterMarkdown v@project-version@ - Core Namespace
   CM.version = "@project-version@" -- Fallback version
   ```

### Can Be Added To

Any file where version should appear:
- Documentation files (README.md, etc.)
- Help text
- Copyright notices
- Debug messages
- Any text file

---

## The replace-version.sh Script

### Enhanced Version (New)

**Location**: `scripts/replace-version.sh`

**Usage**:
```bash
# Single file
./scripts/replace-version.sh CharacterMarkdown.addon 2.1.8

# Entire directory (recursively processes all .lua, .md, .txt, .addon, .xml files)
./scripts/replace-version.sh src/ 2.1.8

# Current directory and all subdirectories
./scripts/replace-version.sh . 2.1.8
```

**Features**:
- ✅ Works on single file or directory
- ✅ Recursively processes all relevant files
- ✅ Cross-platform (macOS and Linux)
- ✅ Only replaces files that contain the placeholder
- ✅ Reports what it's doing

**Supported file types**:
- `.lua` - Lua source files
- `.md` - Markdown documentation
- `.txt` - Text files
- `.addon` - ESO addon manifests
- `.xml` - XML configuration

---

## Build Process Integration

### Local Builds (Taskfile)

**Command**: `task build`

**Process**:
1. Copies files to `build/CharacterMarkdown/`
2. Gets version from Git tag or commit SHA
3. **Runs**: `./scripts/replace-version.sh build/CharacterMarkdown/ $VERSION`
4. Creates ZIP from build directory

**Result**: All `@project-version@` placeholders replaced with actual version

---

### GitHub Actions

**Trigger**: Push Git tag (e.g., `v2.1.8`)

**Process**:
1. Checks out repository
2. Extracts version from tag
3. **Runs**: `./scripts/replace-version.sh . $VERSION`
4. Updates AddOnVersion in manifest
5. Creates release ZIP

**Result**: All `@project-version@` placeholders replaced in all files

---

## Development Workflow

### During Development

In your working directory, files contain `@project-version@`:

```lua
// src/Core.lua (unbuilt)
CM.version = "@project-version@"
```

**This is intentional!** The placeholder helps you identify:
- Which files need build processing
- Whether you're running built or source code

### Testing Locally

```bash
# Install source (with placeholders) for rapid development
task install:live

# ESO will use fallback version or GetAddOnMetadata()
# Placeholder visible in debug mode
```

### Building for Release

```bash
# Build (replaces placeholders)
task build

# Install built version (no placeholders)
task install:built
```

---

## Version Resolution at Runtime

### How ESO Gets the Version

1. **Try GetAddOnMetadata()** - Reads from manifest
2. **If that fails** - Use fallback `CM.version`
3. **If placeholder detected** - Warns in debug mode

```lua
-- src/Core.lua (excerpt)
CM.version = "@project-version@" -- Fallback version

function CM.InitializeVersion()
    local version = GetAddOnMetadata(CM.name, "Version")
    
    if version == "@project-version@" then
        -- Placeholder detected - using fallback
        CM.DebugPrint("CORE", "Placeholder not replaced - run 'task build'")
    else
        -- Valid version from manifest
        CM.version = version
    end
end
```

---

## Examples

### Example 1: Adding Version to Debug Output

**Before**:
```lua
CM.Info("CharacterMarkdown v2.1.7 initialized")
```

**After**:
```lua
CM.Info("CharacterMarkdown v@project-version@ initialized")
```

**Result after build**:
```lua
CM.Info("CharacterMarkdown v2.1.8 initialized")
```

---

### Example 2: Adding Version to Documentation

**Before** (`README.md`):
```markdown
## CharacterMarkdown v2.1.7
```

**After**:
```markdown
## CharacterMarkdown v@project-version@
```

**Result after build**:
```markdown
## CharacterMarkdown v2.1.8
```

---

### Example 3: Building with Custom Version

```bash
# Override version for testing
./scripts/replace-version.sh build/CharacterMarkdown/ "2.2.0-beta"
```

---

## Comparison: Old vs New

### Old System (Specific/Fragile)

**GitHub Actions**:
```yaml
# Only replaced specific lines
sed -i "s/^## Version: .*/## Version: $VERSION/g" manifest
```

**Problems**:
- ❌ Only works in manifest
- ❌ Hardcoded line matching
- ❌ Different from local builds
- ❌ Can't add version elsewhere
- ❌ Inconsistent behavior

---

### New System (General/Robust)

**Both environments**:
```bash
# Works everywhere, consistently
./scripts/replace-version.sh <path> $VERSION
```

**Benefits**:
- ✅ Works in any file
- ✅ General-purpose placeholder
- ✅ Same in local & CI builds
- ✅ Easy to add version anywhere
- ✅ Consistent behavior

---

## Testing the System

### Test Placeholder Detection

```bash
# Find all files with placeholders
grep -r "@project-version@" --include="*.lua" --include="*.md" --include="*.addon" .
```

**Expected output** (in working directory):
```
./src/Core.lua:-- CharacterMarkdown v@project-version@ - Core Namespace
./src/Core.lua:CM.version = "@project-version@"
./CharacterMarkdown.addon:## Version: @project-version@
```

---

### Test Script on Single File

```bash
# Create test file
echo 'Version: @project-version@' > test.txt

# Run replacement
./scripts/replace-version.sh test.txt "2.1.8"

# Check result
cat test.txt
# Output: Version: 2.1.8
```

---

### Test Script on Directory

```bash
# Build and check
task build

# Verify no placeholders in build
grep -r "@project-version@" build/CharacterMarkdown/
# Should return nothing (or only comments)
```

---

## Migration Guide

### For New Files

Just use `@project-version@` anywhere you need the version:

```lua
-- New file: src/NewFeature.lua
-- NewFeature v@project-version@
CM.NewFeature.version = "@project-version@"
```

No other changes needed - build system handles it automatically.

---

### For Existing Files

Replace hardcoded versions with placeholder:

**Before**:
```lua
CM.version = "2.1.7"
```

**After**:
```lua
CM.version = "@project-version@"
```

---

## Troubleshooting

### Issue: Placeholder Not Replaced in Built Addon

**Symptom**: See `@project-version@` in built files

**Cause**: Script not run or file type not supported

**Solution**:
```bash
# Check if script ran
task build | grep "Replacing @project-version@"

# Manually run on file
./scripts/replace-version.sh build/CharacterMarkdown/path/to/file.ext $VERSION
```

---

### Issue: Version Shows Placeholder in ESO

**Symptom**: `/markdown` shows version as "@project-version@"

**Cause**: Installed source files instead of built files

**Solution**:
```bash
# Install built version
task install:built
```

Or: Build always replaces it, so manifest should have real version.

---

### Issue: Script Fails on macOS

**Symptom**: `sed: invalid command code`

**Cause**: macOS sed syntax different from Linux

**Solution**: Script already handles this! Uses `$OSTYPE` detection.

If still failing:
```bash
# Check OSTYPE
echo $OSTYPE
# Should be "darwin" on macOS

# Test script
./scripts/replace-version.sh test.txt "1.0.0"
```

---

## Best Practices

### ✅ DO

- Use `@project-version@` for any version reference
- Let build system handle replacement
- Use Git tags for version management
- Test with `task install:built` before release

### ❌ DON'T

- Hardcode version numbers in source
- Manually update versions in multiple places
- Skip build step when testing releases
- Use different version formats in different files

---

## Summary

The `@project-version@` placeholder system provides:

1. **Single Source of Truth**: Git tags determine version
2. **Automatic Replacement**: Build process handles all files
3. **Consistent Behavior**: Works same in local builds and CI
4. **Easy to Use**: Just add placeholder anywhere
5. **Maintainable**: No manual version updates

**One placeholder to rule them all!** 🎯

---

**Version**: 1.0  
**Last Updated**: 2025-01-21  
**Status**: ✅ Implemented and tested

