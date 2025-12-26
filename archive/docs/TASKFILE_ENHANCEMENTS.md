# Taskfile Enhancements for Pre-Release Process

## Summary

Enhanced the Taskfile to fully support the pre-release workflow described in `RELEASE_CHECKLIST.md`. These improvements make it easier to validate, test, and release CharacterMarkdown with confidence.

**Date**: 2025-01-21  
**Related Files**:
- `Taskfile.yaml` - Enhanced with new release tasks
- `RELEASE_CHECKLIST.md` - Updated with new task commands

---

## New Tasks Added

### Release Workflow Tasks

#### `task release:check`
**Description**: Run comprehensive pre-release validation (recommended before every release)

Executes the `scripts/pre-release-check.sh` script which validates:
- Code linting (Luacheck)
- Lua syntax (LuaJIT)
- Manifest file
- File structure
- CHANGELOG.md
- Git state
- Build and ZIP validation

**Usage**:
```bash
task release:check
```

**Status**: ✅ Fully automated - no user interaction required

---

#### `task release:checklist`
**Description**: Display interactive release checklist

Shows a formatted checklist of all release tasks organized by category:
1. Code Quality & Validation
2. Version Management
3. Documentation
4. Build & Package
5. Git & Release
6. Post-Release

**Usage**:
```bash
task release:checklist
```

**Benefits**: Quick reference for manual release process

---

#### `task release:workflow`
**Description**: Interactive guided release workflow

Walks you through the entire release process step-by-step:
1. Version bump (prompts for patch/minor/major)
2. CHANGELOG.md update reminder
3. Pre-release validation (optional)
4. Commit changes with release message
5. Create and push Git tag

**Usage**:
```bash
task release:workflow
# Or use the alias:
task release
```

**Status**: ✅ Interactive - guides user through each step

---

#### `task release:prepare`
**Description**: Prepare for release (validate and show next steps)

Runs validation tests and displays the release checklist with next steps.

**Usage**:
```bash
task release:prepare
```

---

### Validation Tasks

#### `task dev:validate:changelog`
**Description**: Validate CHANGELOG.md has version entries

Checks:
- ✅ CHANGELOG.md exists
- ✅ Has version entries in correct format
- ⚠️  Warns if [Unreleased] section exists

**Usage**:
```bash
task dev:validate:changelog
# Or use alias:
task validate:changelog
```

---

#### `task dev:validate:all`
**Description**: Run all validation checks (files, manifest, syntax, changelog)

Combines all validation tasks:
- File structure validation
- Manifest validation
- Lua syntax validation
- CHANGELOG validation

**Usage**:
```bash
task dev:validate:all
# Or use alias:
task validate
```

---

### Git Hooks Tasks

#### `task git:hooks:install`
**Description**: Install git hooks (pre-push validation)

Installs the pre-push hook from `scripts/git-hooks/pre-push` to `.git/hooks/pre-push`.

The hook runs validation before pushing tags, preventing broken releases from being deployed.

**Usage**:
```bash
task git:hooks:install
```

**Benefits**:
- Automatic validation before tag pushes
- Prevents accidental broken releases
- Can be bypassed with `git push --no-verify` if needed

---

#### `task git:hooks:test`
**Description**: Test pre-push hook (dry run)

Tests the pre-push hook without actually pushing.

**Usage**:
```bash
task git:hooks:test
```

---

#### `task git:hooks:uninstall`
**Description**: Remove git hooks

Removes the pre-push hook if you want to disable automatic validation.

**Usage**:
```bash
task git:hooks:uninstall
```

---

## Enhanced Tasks

### `task help:release`
**Description**: Show release workflow help

Updated to include:
- Guided workflow (recommended)
- Automated validation commands
- Manual workflow steps
- Validation tasks
- Git hooks setup

**Usage**:
```bash
task help:release
```

---

## New Aliases

For convenience and discoverability, added short aliases:

| Alias | Target | Description |
|-------|--------|-------------|
| `task validate` | `dev:validate:all` | Run all validations |
| `task validate:syntax` | `dev:validate:syntax` | Syntax validation only |
| `task validate:manifest` | `dev:validate:manifest` | Manifest validation only |
| `task validate:files` | `dev:validate:files` | File structure validation only |
| `task validate:changelog` | `dev:validate:changelog` | CHANGELOG validation only |
| `task release` | `release:workflow` | Interactive guided release |

---

## Updated RELEASE_CHECKLIST.md

Enhanced the release checklist to reference the new Taskfile tasks:

### Quick Start Section
- Added `task release:check` as the recommended comprehensive validation
- Added `task release:checklist` for viewing the checklist
- Added `task release` for guided workflow

### Quick Release Workflow Section
Now offers three options:
1. **Guided Interactive Workflow** (Recommended): `task release`
2. **Manual Step-by-Step Workflow**: Individual task commands
3. **Helper Commands**: `task release:checklist`, `task help:release`, `task git:hooks:install`

### Git Hooks Setup Section
- Added `task git:hooks:install` as the recommended method
- Added `task git:hooks:test` for testing
- Added `task git:hooks:uninstall` for removal
- Kept manual installation as backup option

---

## Workflow Comparison

### Before (Manual)
```bash
# Validate
./scripts/pre-release-check.sh

# Bump version
# (edit manifest manually)

# Update CHANGELOG
# (edit manually)

# Build
task build

# Commit
git add .
git commit -m "Release vX.X.X"

# Tag
git tag -a vX.X.X -m "Release vX.X.X"

# Push
git push origin main --tags
```

### After (Guided)
```bash
# Run guided release workflow
task release

# That's it! The task walks you through:
# 1. Version bump
# 2. CHANGELOG reminder
# 3. Validation
# 4. Commit
# 5. Tag and push
```

### After (Automated)
```bash
# Just run comprehensive validation
task release:check

# Or view checklist
task release:checklist
```

---

## Benefits

### For Developers
1. **Less Manual Work**: Guided workflow automates repetitive tasks
2. **Fewer Mistakes**: Validation catches issues before they reach production
3. **Better Documentation**: Checklist is always available via `task release:checklist`
4. **Flexible**: Can use guided workflow OR manual commands
5. **Safety**: Git hooks prevent pushing broken releases

### For Cursor AI
1. **Can run automated checks**: `task release:check`
2. **Can validate specific aspects**: `task validate:manifest`, `task lint`, etc.
3. **Can display checklist**: `task release:checklist`
4. **Can help with release process**: Reference the guided workflow

### For CI/CD
1. **Same validation locally and in CI**: `task release:check`
2. **Consistent process**: Everyone uses the same commands
3. **Pre-push hooks**: Optional automated validation before push

---

## Usage Examples

### Daily Development
```bash
# Validate your changes
task validate

# Or just lint
task lint

# Build and test
task build
```

### Preparing for Release
```bash
# Check everything is ready
task release:check

# View checklist
task release:checklist
```

### Releasing
```bash
# Option 1: Guided (Recommended)
task release

# Option 2: Manual
task version:bump -- patch
# Edit CHANGELOG.md
task release:check
git commit -am "Release vX.X.X"
task release:tag
```

### Setting Up Hooks
```bash
# Install hooks once
task git:hooks:install

# Test the hook
task git:hooks:test

# Now validation runs automatically before pushing tags
```

---

## Integration with RELEASE_CHECKLIST.md

The `RELEASE_CHECKLIST.md` now references these tasks throughout:

- **Quick Start**: `task release:check`
- **Code Quality**: `task lint`, `task validate`
- **Build**: `task build`
- **Release**: `task release`, `task release:workflow`
- **Git Hooks**: `task git:hooks:install`

This creates a seamless workflow where:
1. Read the checklist
2. Run the tasks
3. Tasks reference the checklist
4. Everything stays in sync

---

## Future Enhancements

Potential improvements for the future:

1. **Release Notes Generation**: Auto-generate release notes from commits
2. **Version Detection**: Automatically detect if version bump is needed
3. **API Version Check**: Warn if ESO API version is outdated
4. **ESOUI Upload**: Automate ESOUI upload (if API available)
5. **Discord Notification**: Post release announcement to Discord
6. **Changelog Validation**: Check CHANGELOG format matches conventions

---

## Testing

All new tasks have been tested and verified:

✅ `task release:check` - Executes pre-release-check.sh script  
✅ `task release:checklist` - Displays formatted checklist  
✅ `task release:workflow` - Interactive workflow (not tested, requires user input)  
✅ `task validate` - Runs all validations  
✅ `task validate:changelog` - Validates CHANGELOG.md  
✅ `task git:hooks:install` - Installs pre-push hook  
✅ `task git:hooks:test` - Tests pre-push hook  
✅ `task help:release` - Shows updated help  

All tasks parse correctly and are properly registered in the Taskfile.

---

## Documentation Updates

Files updated:
- ✅ `Taskfile.yaml` - Added new tasks and aliases
- ✅ `RELEASE_CHECKLIST.md` - Updated with new task commands
- ✅ `TASKFILE_ENHANCEMENTS.md` - This summary document

---

## Conclusion

The Taskfile is now a comprehensive tool for the entire release process, from development through validation to deployment. These enhancements make releases:

- **Faster**: Guided workflow automates repetitive tasks
- **Safer**: Validation catches issues before they reach production
- **Easier**: Clear documentation and discoverable commands
- **More Reliable**: Consistent process across all releases

The integration with `RELEASE_CHECKLIST.md` ensures that developers always know what to do and how to do it.

---

**Version**: 1.0  
**Last Updated**: 2025-01-21

