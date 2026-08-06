# Release Checklist

**Use this checklist before every release to ensure production readiness.**

This checklist covers all aspects of preparing CharacterMarkdown for release: code quality, documentation, build validation, testing, and deployment.

---

## 🤖 Quick Start: Automated Pre-Release Validation

**For Cursor AI or manual execution:**

```bash
# Run comprehensive pre-release validation (RECOMMENDED)
task release:check

# Or use individual commands
task test              # Lint + validate
task build             # Build and validate ZIP
task validate          # All validations (files, manifest, syntax, changelog)

# View interactive checklist
task release:checklist

# Guided release workflow (interactive)
task release           # or: task release:workflow
```

**📖 See [docs/RELEASE_TASKS_REFERENCE.md](docs/RELEASE_TASKS_REFERENCE.md) for complete task command reference**

**Cursor AI can automatically run these checks:**
- ✅ Code linting (`task lint`)
- ✅ All validations (`task validate`)
- ✅ Syntax validation (`task validate:syntax`)
- ✅ Manifest validation (`task validate:manifest`)
- ✅ README.md badges (`task validate:readme`)
- ✅ Build validation (`task build`)
- ✅ Comprehensive pre-release check (`task release:check`)

---

## 📋 Pre-Release Validation Checklist

### 1. Code Quality & Validation

#### Automated Checks (Cursor AI can run these)

- [ ] **Lint Check**
  ```bash
  task lint
  ```
  - ✅ No Luacheck errors or warnings
  - ✅ All Lua files pass linting
  - ⚠️ Fix any warnings before proceeding

- [ ] **Syntax Validation**
  ```bash
  task validate:syntax
  ```
  - ✅ All Lua files have valid syntax
  - ✅ No LuaJIT compilation errors
  - ⚠️ Fix syntax errors immediately

- [ ] **Manifest Validation**
  ```bash
  task validate:manifest
  # Or: lua scripts/validate-manifest.lua CharacterMarkdown.txt
  ```
  - ✅ Manifest file exists and is valid
  - ✅ Required fields present: Title, Author, Version, APIVersion
  - ✅ All referenced files exist
  - ✅ File load order is correct

- [ ] **File Structure Validation**
  ```bash
  task validate:files
  ```
  - ✅ All required files present (manifest, XML, README, LICENSE)
  - ✅ Source directory structure correct
  - ✅ No missing dependencies

#### Manual Checks

- [ ] **Code Review**
  - [ ] All code follows patterns and conventions in `.cursorrules`
  - [ ] Lua 5.1 compatibility (no `goto` statements, etc.)
  - [ ] Error handling, namespace conventions, and logging patterns followed
  - [ ] Tested in ESO environment

---

### 2. Documentation Review

#### Automated Checks

- [ ] **Documentation Audit**
  ```bash
  task docs:audit       # Comprehensive documentation health check
  task docs:links       # Check for broken links
  ```
  - ✅ No orphaned files (or acceptable orphans documented)
  - ✅ No broken internal links
  - ✅ No stale files (or reviewed and accepted)
  - ✅ No duplicate content
  - ✅ Documentation health score > 90
  - See [docs/DOCUMENTATION_AUDIT_GUIDE.md](docs/DOCUMENTATION_AUDIT_GUIDE.md) for details
  - **Cursor AI**: Use [`@docs/prompts/documentation_consolidation_prompt.md`](docs/prompts/documentation_consolidation_prompt.md) for automated cleanup

- [ ] **Example Files Cleanup**
  ```bash
  task examples:trim:dry-run   # Preview changes
  task examples:trim           # Trim unnecessary newlines
  ```
  - ✅ Remove chunk markers from example files
  - ✅ Remove excessive padding (550+ trailing newlines)
  - ✅ Reduce consecutive blank lines (3+ → 2)
  - ✅ All markdown structure preserved
  - ℹ️  Example files in `assets/examples/` should be clean for distribution

- [ ] **CHANGELOG.md Updated**
  ```bash
  # Check CHANGELOG has entry for current version
  grep -q "## \[.*\]" CHANGELOG.md || echo "⚠️ CHANGELOG needs version entry"
  ```
  - ✅ CHANGELOG.md has entry for release version
  - ✅ Entry follows [Keep a Changelog](https://keepachangelog.com/) format
  - ✅ All changes documented (Added/Changed/Fixed/Removed)
  - ✅ Date is correct (YYYY-MM-DD format)
  - **Cursor AI**: Use [`@docs/prompts/changelog_entry_prompt.md`](docs/prompts/changelog_entry_prompt.md) to generate properly formatted entries
    ```
    @docs/prompts/changelog_entry_prompt.md
    Generate CHANGELOG entry for v@project-version@ from recent changes
    ```

- [ ] **README.md Badges**
  ```bash
  task validate:readme
  ```
  - ✅ API version badge matches manifest
  - ℹ️  Version badge (updated after Git tag)

#### Manual Checks

- [ ] **README.md Content**
  - [ ] Features list accurate
  - [ ] Installation instructions correct
  - [ ] Usage examples work

- [ ] **README_ESOUI.txt** (if exists)
  - [ ] Content is up-to-date
  - [ ] Formatting is correct for ESOUI display
  - [ ] No markdown syntax (plain text only)

- [ ] **Documentation Files**
  - [ ] `docs/PUBLISHING.md` - Release process documented
  - [ ] `docs/DEVELOPMENT.md` - Development guide current
  - [ ] `docs/ARCHITECTURE.md` - Architecture accurate
  - [ ] All doc links work

- [ ] **Code Comments**
  - [ ] Complex logic has explanatory comments
  - [ ] API usage documented where needed
  - [ ] TODO comments addressed or removed

---

### 3. Version Management

#### Automated Checks

- [ ] **Version Consistency**
  ```bash
  # Check manifest version placeholder
  grep -q "@project-version@" CharacterMarkdown.txt || echo "⚠️ Version should use @project-version@"
  
  # Check CHANGELOG has version entry
  task version  # Shows current version info
  ```
  - ✅ Manifest uses `@project-version@` placeholder (Git-based versioning)
  - ✅ CHANGELOG.md has entry matching release version
  - ✅ Version follows semantic versioning (MAJOR.MINOR.PATCH)

#### Manual Checks

- [ ] **Version Bump**
  - [ ] Version bumped appropriately (patch/minor/major)
  - [ ] Breaking changes → major version bump
  - [ ] New features → minor version bump
  - [ ] Bug fixes → patch version bump

- [ ] **API Version**
  ```bash
  # Get current ESO API version in-game: /script d(GetAPIVersion())
  # Then update manifest:
  task version:api -- <API_VERSION>
  
  # Example:
  task version:api -- 101049
  ```
  - ✅ APIVersion in manifest matches current ESO version
  - ✅ Tested with current ESO API version

- [ ] **Git Tags**
  - [ ] Tag will be created: `v<version>` (e.g., `v2.1.12`)
  - [ ] Tag message includes version number
  - [ ] No duplicate tags exist

---

### 4. Build & Packaging

#### Automated Checks (Cursor AI can run these)

- [ ] **Build Package**
  ```bash
  task build
  ```
  - ✅ Build completes without errors
  - ✅ ZIP file created in `dist/` directory
  - ✅ Version placeholder replaced in built manifest
  - ✅ All files included (no missing dependencies)

- [ ] **ZIP Validation**
  ```bash
  scripts/validate-zip.sh dist/CharacterMarkdown-*.zip
  ```
  - ✅ ZIP structure correct (addon folder at root)
  - ✅ Manifest file present (`.txt` format, PC-only)
  - ✅ XML file present
  - ✅ Source directory included
  - ✅ Critical files present (Core.lua, Init.lua, Commands.lua, Events.lua)
  - ✅ No unwanted files (.git, .DS_Store, build artifacts, `__MACOSX`)
  - ✅ Package size < 10MB (ESOUI recommendation)
  - ✅ PC-only (uses `.txt` not `.addon`)

- [ ] **Manifest Content in ZIP**
  - ✅ All required fields present in built manifest
  - ✅ Version correctly replaced (not `@project-version@`)
  - ✅ APIVersion is current
  - ✅ File references are correct

#### Manual Checks

- [ ] **Build Artifacts**
  - [ ] `dist/` directory contains ZIP file
  - [ ] ZIP filename format: `CharacterMarkdown-<version>.zip`
  - [ ] ZIP can be extracted without errors
  - [ ] Extracted structure matches ESO addon requirements

- [ ] **Excluded Files**
  - [ ] No development files in ZIP (.git, .task, docs, scripts)
  - [ ] No test files included
  - [ ] No backup files included
  - [ ] `.build-ignore` rules working correctly

---

### 5. In-Game Testing

#### Manual Checks (Must be done in ESO)

- [ ] **Basic Functionality**
  ```lua
  -- In-game commands:
  /markdown test        # Run validation tests
  /markdown settings    # Open settings panel
  ```
  - ✅ Addon loads without errors
  - ✅ No errors in chat on load
  - ✅ `/markdown` command works
  - ✅ Window displays correctly
  - ✅ Copy to clipboard works
  - ✅ Settings panel accessible

- [ ] **Validation Tests**
  ```lua
  /markdown test
  ```
  - ✅ All validation tests pass
  - ✅ Settings diagnostic passes
  - ✅ Data collection works
  - ✅ Markdown generation succeeds
  - ✅ No broken syntax in output

- [ ] **Settings Persistence**
  - ✅ Settings save correctly
  - ✅ Settings persist after `/reloadui`
  - ✅ Settings persist after game restart
  - ✅ Default settings work correctly

- [ ] **Format Testing**
  - ✅ All formats copy correctly

- [ ] **Feature Testing**
  - ✅ UESP links work correctly
  - ✅ All sections generate (when enabled)
  - ✅ Progress bars render correctly
  - ✅ Tables format properly
  - ✅ Emojis display correctly
  - ✅ Chunking works for large outputs

- [ ] **Edge Cases**
  - ✅ Works with multiple characters
  - ✅ Works with low-level characters
  - ✅ Works with max-level characters
  - ✅ Handles missing data gracefully
  - ✅ No crashes on edge cases

---

### 6. Git State & Tagging

#### Automated Checks

- [ ] **Git Status**
  ```bash
  git status
  ```
  - ✅ Working directory is clean (or only expected changes)
  - ✅ All changes committed
  - ✅ No untracked files (except build artifacts)

- [ ] **Branch State**
  ```bash
  git log --oneline -5
  git branch
  ```
  - ✅ On correct branch (usually `main`)
  - ✅ Up to date with remote (or ready to push)
  - ✅ Recent commits are correct

#### Manual Checks

- [ ] **Commit Messages**
  - ✅ Commits follow conventional format (if using)
  - ✅ Release commit message: `Release v<version>`
  - ✅ All related changes committed together

- [ ] **Tag Creation**
  ```bash
  # Interactive with specific version (recommended):
  task release:tag -- @project-version@       # Prompts before push
  
  # Or use default version from Taskfile:
  task release:tag
  
  # Or manual:
  task git:tag                    # Creates tag
  git push origin main --tags     # Push tag
  
  # Verify tag:
  git tag -l "v*"
  ```
  - ✅ Tag name: `v<version>` (e.g., `v@project-version@`)
  - ✅ Version in semantic format (X.Y.Z)
  - ✅ Tag message includes version
  - ✅ Tag points to correct commit
  - ✅ No duplicate tags

- [ ] **Pre-Push Validation** (if using git hook)
  ```bash
  # Git hook will run automatically on:
  git push origin main --tags
  ```
  - ✅ Pre-push hook installed (optional)
  - ✅ Hook runs validation before push
  - ✅ Hook prevents push if validation fails

---

### 7. Pre-Release Final Checks

#### Manual Review

- [ ] **Release Notes**
  - [ ] CHANGELOG.md entry is complete
  - [ ] All user-facing changes documented
  - [ ] Breaking changes clearly marked
  - [ ] Migration notes included (if needed)

- [ ] **Breaking Changes** (if any)
  - [ ] Breaking changes clearly documented
  - [ ] Migration guide provided (if needed)
  - [ ] Version bump is major (if breaking)

- [ ] **Dependencies**
  - [ ] Optional dependencies listed correctly
  - [ ] LibAddonMenu-2.0 version requirement correct
  - [ ] LibDebugLogger version requirement correct (if used)
  - [ ] LibSets version requirement correct (if used)
  - [ ] LibSlashCommander / LibChatMessage / LibAsync / LibCustomIcons listed when used

- [ ] **License & Legal**
  - [ ] LICENSE file present and correct
  - [ ] Copyright year updated (if needed)
  - [ ] ESO disclaimer present in manifest

---

### 8. Release Execution

#### Automated (GitHub Actions)

Once tag is pushed, GitHub Actions will:
- ✅ Run Luacheck validation
- ✅ Validate manifest
- ✅ Update version in manifest
- ✅ Create release ZIP
- ✅ Validate ZIP structure
- ✅ Create GitHub release
- ✅ Upload to ESOUI (if configured)

#### Manual Steps

- [ ] **Create and Push Tag**
  ```bash
  # Recommended (interactive with confirmation):
  task release:tag
  
  # Or step-by-step:
  task git:tag                    # Creates tag locally
  git push origin main --tags     # Push to GitHub (triggers Actions)
  ```

- [ ] **Monitor GitHub Actions**
  - [ ] Check Actions tab for workflow run
  - [ ] Verify all steps pass
  - [ ] Check for any errors or warnings

- [ ] **Verify Release**
  - [ ] GitHub release created
  - [ ] Release ZIP downloadable
  - [ ] ESOUI upload successful (if automated)
  - [ ] Version number correct on ESOUI

---

### 9. Post-Release Verification

#### Automated Checks

- [ ] **Download and Test**
  ```bash
  # Download release ZIP from GitHub
  # Extract and test
  ```
  - ✅ Release ZIP downloads correctly
  - ✅ ZIP extracts without errors
  - ✅ Extracted addon structure is correct

#### Manual Checks

- [ ] **ESOUI Verification**
  - [ ] Addon page shows correct version
  - [ ] Description is accurate
  - [ ] Download link works
  - [ ] Changelog displayed correctly

- [ ] **User Testing**
  - [ ] Test fresh installation from ESOUI
  - [ ] Verify no installation issues
  - [ ] Check user feedback/comments
  - [ ] Monitor for bug reports

- [ ] **Documentation**
  - [ ] Update any version-specific docs
  - [ ] Update API version if changed
  - [ ] Archive old release notes (if needed)

---

## 🚀 Quick Release Workflow

**Option 1: Guided Interactive Workflow (Recommended)**

```bash
# Run guided release workflow - walks you through all steps
task release
```

**Option 2: Manual Step-by-Step Workflow**

```bash
# 1. Run automated validation
task release:check

# 2. Bump version (if needed)
task version:bump -- patch   # or minor/major

# 3. Update CHANGELOG.md manually
# Add release notes for new version

# 4. Final validation
task test
task build

# 5. Commit and tag
git add .
task git:commit -- "Release v<version>"
task release:tag -- @project-version@     # Interactive with version (prompts before push)

# 6. Monitor GitHub Actions
# Check Actions tab for automated release
```

**Option 3: Use Helper Commands**

```bash
# Display checklist
task release:checklist

# View release help
task help:release

# Install git hooks for automatic validation before pushing tags
task git:hooks:install
```

---

## 🔧 Git Hooks Setup (Optional)

### Install Pre-Push Hook

**Option 1: Using Task (Recommended)**

```bash
# Install pre-push hook
task git:hooks:install

# Test the hook
task git:hooks:test

# Uninstall if needed
task git:hooks:uninstall
```

**Option 2: Manual Installation**

```bash
# Copy hook template
cp scripts/git-hooks/pre-push .git/hooks/pre-push
chmod +x .git/hooks/pre-push
```

The pre-push hook will:
- ✅ Run validation before pushing tags
- ✅ Prevent push if validation fails
- ✅ Skip validation for non-tag pushes (optional)

To bypass the hook if needed:
```bash
git push --no-verify
```

### Manual Pre-Release Check

```bash
# Run comprehensive pre-release validation (recommended)
task release:check

# Or run the script directly
./scripts/pre-release-check.sh
```

These run all automated checks from the checklist.

---

## 📝 Notes

- **Automated checks** can be run by Cursor AI or manually
- **Manual checks** require human judgment and in-game testing
- **Git hooks** are optional but recommended for automated validation
- **Always test in-game** before releasing
- **Monitor GitHub Actions** after pushing tags

---

## 🔗 Related Documentation

- [Publishing Guide](docs/PUBLISHING.md) - Detailed release process
- [Development Guide](docs/DEVELOPMENT.md) - Development workflow
- [Testing Guide](docs/TESTING_COMMAND.md) - In-game testing procedures
- [Architecture](docs/ARCHITECTURE.md) - Code structure

---

**Last Updated:** 2025-01-21  
**Version:** CharacterMarkdown Release Checklist v1.0

