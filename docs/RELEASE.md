# CharacterMarkdown - Release Process Guide

Complete guide for releasing new versions of CharacterMarkdown.

---

## Overview

The release process is **fully automated** after initial setup:

1. ✅ Update version and changelog (manual)
2. ✅ Create Git tag (manual)
3. ✅ Push tag to GitHub (manual)
4. 🤖 Build ZIP artifact (automated)
5. 🤖 Run tests and validation (automated)
6. 🤖 Create GitHub release (automated)
7. 🤖 Upload to ESOUI (automated)

---

## Release Checklist

### Pre-Release (Manual Steps)

- [ ] **Code Complete:** All features/fixes implemented
- [ ] **Testing:** Addon tested in ESO Live client
- [ ] **PTS Testing:** (For major releases) Test on PTS with upcoming patch
- [ ] **Version Bump:** Update version in `CharacterMarkdown.txt`
- [ ] **Changelog:** Update `CHANGELOG.md` with release notes
- [ ] **API Version:** Verify `## APIVersion` matches current ESO version
- [ ] **Dependencies:** Verify `## DependsOn` versions are current
- [ ] **Local Tests:** Run `task test` successfully
- [ ] **Commit Changes:** Commit version and changelog updates

### Post-Release (Automated)

- [ ] **Create Tag:** `git tag vX.X.X`
- [ ] **Push Tag:** `git push origin main --tags`
- [ ] **Monitor GitHub Actions:** Watch workflow completion
- [ ] **Verify GitHub Release:** Check release page
- [ ] **Verify ESOUI Upload:** Check ESOUI author dashboard
- [ ] **In-Game Testing:** Download and test published version

---

## Versioning Strategy

CharacterMarkdown follows [Semantic Versioning](https://semver.org):

### Version Format: `MAJOR.MINOR.PATCH`

```
2.1.0 → 2.1.1 → 2.2.0 → 3.0.0
```

### When to Bump Versions

**MAJOR version** (X.0.0) - Breaking changes
- Incompatible API changes
- Removed features
- Major architecture refactor
- Example: `2.1.0 → 3.0.0`

**MINOR version** (0.X.0) - New features
- New functionality added
- New sections or export formats
- Non-breaking changes
- Example: `2.1.0 → 2.2.0`

**PATCH version** (0.0.X) - Bug fixes
- Bug fixes only
- Performance improvements
- Documentation updates
- Example: `2.1.0 → 2.1.1`

### AddOnVersion (Numeric)

ESO uses a separate numeric version for sorting:

```lua
## AddOnVersion: 20250120  -- YYYYMMDD format (recommended)
## AddOnVersion: 2001001    -- Or incrementing integer
```

**Recommendation:** Use `YYYYMMDD` format (automatically set by CI/CD)

### API Version

Update when ESO patches release:

```lua
## APIVersion: 101043 101044  -- Support multiple versions

# Get current version in ESO:
/script d(GetAPIVersion())
```

**Update Schedule:**
- Major ESO updates (e.g., Gold Road, Update 46): Update within 48 hours
- Minor patches: Update within 1 week

---

## Step-by-Step Release Process

### Step 1: Prepare Code

Ensure all changes are committed:

```bash
git status

# Should show:
# On branch main
# nothing to commit, working tree clean
```

If you have uncommitted changes:

```bash
git add .
git commit -m "Prepare for release"
git push origin main
```

### Step 2: Update Version

Edit `CharacterMarkdown.txt`:

```lua
## Version: 2.1.1  # ← Update this line
## AddOnVersion: 20250120  # ← Will be auto-updated by CI/CD
```

### Step 3: Update CHANGELOG.md

Add new version section at top (below `## [Unreleased]`):

```markdown
## [Unreleased]

## [2.1.1] - 2025-01-20

### Added
- New feature X

### Fixed
- Bug fix Y

### Changed
- Improvement Z
```

**Changelog Format (Keep a Changelog):**
- **Added:** New features
- **Changed:** Changes in existing functionality
- **Deprecated:** Soon-to-be removed features
- **Removed:** Removed features
- **Fixed:** Bug fixes
- **Security:** Security fixes

### Step 4: Run Local Tests

```bash
task test

# Expected output:
# 🔍 Running Luacheck...
# ✅ Lint passed
# ✅ Validating manifest...
# ✅ Manifest valid
# ✅ All tests passed
```

If tests fail, fix issues before proceeding.

### Step 5: Commit Version Changes

```bash
git add CharacterMarkdown.txt CHANGELOG.md
git commit -m "Release v2.1.1"
git push origin main
```

### Step 6: Create and Push Git Tag

```bash
# Get version from manifest
VERSION=$(grep "^## Version:" CharacterMarkdown.txt | awk '{print $3}')
echo "Creating tag: v${VERSION}"

# Create annotated tag
git tag -a "v${VERSION}" -m "Release v${VERSION}"

# Push tag to GitHub (triggers CI/CD)
git push origin main --tags
```

**Or use the automated task:**

```bash
task release:tag

# Interactive prompts:
# - Confirm tag creation
# - Confirm push to GitHub
```

### Step 7: Monitor GitHub Actions

1. Go to: https://github.com/YOUR_USERNAME/CharacterMarkdown/actions
2. Click on the running "Release CharacterMarkdown" workflow
3. Watch the progress:
   - ✅ Checkout repository
   - ✅ Extract version
   - ✅ Run tests
   - ✅ Update manifest
   - ✅ Create ZIP
   - ✅ Validate ZIP structure
   - ✅ Create GitHub release
   - ✅ Upload to ESOUI

**Typical Duration:** 2-3 minutes

### Step 8: Verify Release

#### A) GitHub Release

1. Go to: https://github.com/YOUR_USERNAME/CharacterMarkdown/releases
2. Verify:
   - ✅ Release exists with correct version number
   - ✅ Changelog is displayed
   - ✅ ZIP artifact is attached
   - ✅ ZIP filename matches version

#### B) ESOUI Upload

1. Go to: https://www.esoui.com/downloads/author.php
2. Verify:
   - ✅ New version appears in your addon list
   - ✅ Version number matches
   - ✅ File size looks correct
   - ✅ Status is "Pending Approval" or "Approved"

**Approval Time:** Usually 24-48 hours for ESOUI staff review

#### C) In-Game Testing

After ESOUI approval:

1. Download addon from ESOUI
2. Install to ESO Live client
3. Launch ESO
4. Test basic functionality:
   ```
   /markdown
   # Verify window opens
   # Verify data generation
   # Verify copy-to-clipboard
   ```

---

## Automated Workflow Details

### What GitHub Actions Does

When you push a tag matching `v*` (e.g., `v2.1.1`):

1. **Checkout:** Clones repository
2. **Version Extraction:** Parses tag name
3. **Environment Setup:** Installs Lua 5.1, Luacheck
4. **Testing:**
   - Runs Luacheck on all Lua files
   - Validates manifest structure
5. **Version Update:**
   - Updates `## Version: X.X.X` in manifest
   - Updates `## AddOnVersion: YYYYMMDD` to current date
   - Creates `CharacterMarkdown.addon` copy
6. **Build:**
   - Creates temp directory structure
   - Copies files (excluding .build-ignore patterns)
   - Creates ZIP: `CharacterMarkdown-X.X.X.zip`
7. **Validation:**
   - Verifies ZIP has correct folder structure
   - Checks for required files
   - Warns about development files in ZIP
8. **Changelog Extraction:**
   - Parses `CHANGELOG.md`
   - Extracts section for current version
9. **GitHub Release:**
   - Creates release with version tag
   - Attaches ZIP artifact
   - Uses changelog as release notes
10. **ESOUI Upload:**
    - Uploads ZIP to ESOUI via API
    - Sets version, changelog, compatibility
    - Uses `ESOUI_API_KEY` secret

### Workflow Variables

Configured in `.github/workflows/release.yml`:

```yaml
# Line ~140
addon_id: '3425'  # Your ESOUI addon ID
compatibility: '11.0.0'  # Current ESO version
test: false  # Set to 'true' for dry-run
```

---

## Release Types

### Patch Release (Bug Fixes Only)

**Example:** `2.1.0 → 2.1.1`

```bash
# 1. Fix bugs
# 2. Update version
echo "## Version: 2.1.1" # In CharacterMarkdown.txt

# 3. Update changelog
cat >> CHANGELOG.md << 'EOF'

## [2.1.1] - 2025-01-20

### Fixed
- Fixed invisible text in output window
- Corrected skill maxed detection for rank 50 skills
EOF

# 4. Release
task test
git commit -am "Release v2.1.1"
git tag v2.1.1
git push origin main --tags
```

### Minor Release (New Features)

**Example:** `2.1.0 → 2.2.0`

```bash
# 1. Implement features
# 2. Update version
echo "## Version: 2.2.0"

# 3. Update changelog with Added/Changed sections
cat >> CHANGELOG.md << 'EOF'

## [2.2.0] - 2025-01-25

### Added
- New currency tracking section
- PvP campaign information
- Companion equipment display

### Changed
- Improved skill bar formatting
- Optimized markdown generation
EOF

# 4. Release
task test
git commit -am "Release v2.2.0"
git tag v2.2.0
git push origin main --tags
```

### Major Release (Breaking Changes)

**Example:** `2.1.0 → 3.0.0`

```bash
# 1. Implement breaking changes
# 2. Update version
echo "## Version: 3.0.0"

# 3. Update changelog with detailed migration notes
cat >> CHANGELOG.md << 'EOF'

## [3.0.0] - 2025-02-01

### BREAKING CHANGES
⚠️ This release contains breaking changes. See migration guide below.

### Removed
- Deprecated "quick" export format (use "discord" instead)
- Old settings format (auto-migrates on first load)

### Added
- New template engine with custom formatting
- Advanced filtering options

### Changed
- Settings panel redesigned
- Command syntax updated: `/markdown format` instead of `/markdown -f format`

### Migration Guide
1. Backup SavedVariables before updating
2. Update command usage in keybinds/macros
3. Review new settings panel options
EOF

# 4. Release
task test
git commit -am "Release v3.0.0 - BREAKING CHANGES"
git tag v3.0.0
git push origin main --tags
```

---

## Hotfix Process (Emergency Fixes)

For critical bugs that need immediate release:

### Fast-Track Release

```bash
# 1. Create hotfix branch (optional)
git checkout -b hotfix/2.1.1

# 2. Fix critical bug
# 3. Update version (patch bump)
echo "## Version: 2.1.1"

# 4. Quick changelog
cat >> CHANGELOG.md << 'EOF'

## [2.1.1] - 2025-01-20

### Fixed
- [HOTFIX] Critical error preventing addon load
EOF

# 5. Release immediately
git commit -am "Hotfix v2.1.1 - Critical error fix"
git tag v2.1.1
git push origin main --tags

# 6. Monitor CI/CD closely
# 7. Test immediately after ESOUI approval
```

### Hotfix Checklist

- [ ] Bug is critical (crashes, data loss, unusable)
- [ ] Fix is isolated (minimal code changes)
- [ ] Testing confirms fix works
- [ ] Changelog clearly marks as HOTFIX
- [ ] Fast-track approval requested on ESOUI

---

## ESO Patch Day Releases

When ESO releases a major update:

### Pre-Patch Preparation

**2 weeks before patch:**
- [ ] Install ESO PTS (Public Test Server)
- [ ] Copy addon to PTS AddOns folder
- [ ] Test addon on PTS
- [ ] Check for API changes in patch notes

**1 week before patch:**
- [ ] Update `## APIVersion` for new patch
- [ ] Fix any compatibility issues found on PTS
- [ ] Prepare changelog for patch compatibility

### Patch Day (Day 0)

**Morning of patch release:**

```bash
# 1. Verify current API version in ESO
# /script d(GetAPIVersion())
# Example output: 101046

# 2. Update manifest
echo "## APIVersion: 101045 101046"  # Support old and new

# 3. Quick changelog
cat >> CHANGELOG.md << 'EOF'

## [2.1.1] - 2025-01-20

### Changed
- Updated for ESO Update 46 (Gold Road)
- API version 101046 compatibility verified
EOF

# 4. Release immediately
task test
git commit -am "Update 46 compatibility"
git tag v2.1.1
git push origin main --tags
```

**Within 48 hours:**
- Monitor ESOUI comments for bug reports
- Test addon with multiple characters
- Fix any compatibility issues with hotfix

---

## Rollback Procedure

If a release has critical issues:

### Option 1: Quick Hotfix (Preferred)

```bash
# Fix the issue immediately
# Release new patch version (e.g., 2.1.2)
# See Hotfix Process above
```

### Option 2: Revert to Previous Version

```bash
# 1. Delete bad tag locally and remotely
git tag -d v2.1.1
git push --delete origin v2.1.1

# 2. Delete GitHub release
# Go to GitHub releases, delete the broken release

# 3. Revert commit
git revert HEAD
git push origin main

# 4. Re-release previous version (if needed)
git tag v2.1.0
git push origin main --tags
```

### Option 3: Manual ESOUI Update

If only ESOUI upload is affected:

1. Go to: https://www.esoui.com/downloads/filecpl.php
2. Select "Edit" for CharacterMarkdown
3. Upload corrected ZIP manually
4. Update version/changelog as needed

---

## Troubleshooting Releases

### Issue: GitHub Actions Fails

**Symptom:** Workflow shows red X

**Diagnosis:**
1. Click on failed workflow run
2. Expand failed step
3. Read error message

**Common Causes:**

**Luacheck Errors:**
```bash
# Fix locally first
task lint

# View specific errors
luacheck src/ --no-color
```

**Manifest Validation Failed:**
```bash
# Run validator
lua5.1 scripts/validate-manifest.lua CharacterMarkdown.txt

# Fix issues in manifest
```

**ZIP Structure Invalid:**
```bash
# Check .build-ignore
# Ensure no critical files excluded
```

### Issue: ESOUI Upload Fails

**Symptom:** Workflow succeeds but no ESOUI upload

**Check:**

1. **API Key Valid:**
   - Regenerate at: https://www.esoui.com/downloads/filecpl.php?action=apitokens
   - Update GitHub secret: `ESOUI_API_KEY`

2. **Addon ID Correct:**
   - Verify in workflow: `addon_id: 'XXXX'`
   - Check ESOUI URL for correct ID

3. **Workflow Logs:**
   ```
   - name: Upload to ESOUI
   # Check this step's output
   ```

### Issue: Version Mismatch

**Symptom:** GitHub release version doesn't match ESOUI

**Fix:**
```bash
# 1. Delete incorrect tag
git tag -d vX.X.X
git push --delete origin vX.X.X

# 2. Fix version in CharacterMarkdown.txt
# 3. Create correct tag
git tag vX.X.X
git push origin main --tags
```

### Issue: Changelog Not Extracted

**Symptom:** GitHub release shows "See CHANGELOG.md"

**Fix:**

Ensure CHANGELOG.md has correct format:

```markdown
## [2.1.1] - 2025-01-20
      ↑           ↑
   Must match   ISO date
   tag version
```

---

## Best Practices

### ✅ Do

- **Test locally** before releasing
- **Update changelog** before every release
- **Use semantic versioning** consistently
- **Monitor GitHub Actions** after tag push
- **Test in-game** after ESOUI approval
- **Keep API version current** with ESO patches
- **Respond to bug reports** quickly

### ❌ Don't

- **Rush releases** without testing
- **Skip changelog updates**
- **Release on ESO patch day** (wait 1-2 days)
- **Forget to update API version** after ESO updates
- **Ignore CI/CD failures** (always investigate)
- **Release breaking changes** as minor versions

---

## Release Schedule Recommendations

### Regular Releases

- **Monthly:** Feature releases (minor versions)
- **Weekly:** Bug fix releases (patches)
- **As-needed:** ESO patch compatibility

### ESO Patch Alignment

- **Major ESO Updates:** Within 48 hours
- **Minor ESO Patches:** Within 1 week
- **PTS Testing:** 2 weeks before major updates

---

## Quick Reference

### Release Commands

```bash
# Full release workflow
task release:prepare   # Validate and show checklist
task release:tag       # Create and push tag (interactive)

# Manual workflow
task test              # Run tests
git commit -am "Release vX.X.X"
git tag vX.X.X
git push origin main --tags

# Version check
task version           # Show current version

# Rollback
git tag -d vX.X.X
git push --delete origin vX.X.X
```

### Important Links

- **GitHub Actions:** https://github.com/YOUR_USERNAME/CharacterMarkdown/actions
- **GitHub Releases:** https://github.com/YOUR_USERNAME/CharacterMarkdown/releases
- **ESOUI Dashboard:** https://www.esoui.com/downloads/author.php
- **ESOUI API Tokens:** https://www.esoui.com/downloads/filecpl.php?action=apitokens

---

**Happy Releasing! 🚀**
