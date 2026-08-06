# Publishing Guide

## Initial Setup (One-Time)

### 1. Create ESOUI Account
1. Register at https://www.esoui.com/
2. Verify email
3. Apply for author status (User Control Panel → Permissions)
4. Wait for approval (24-48 hours)

### Packaging notes (PC-only on ESOUI)
- Manifest: `CharacterMarkdown.txt` (not `.addon`)
- ZIP root folder must be `CharacterMarkdown/` matching the manifest basename
- Exclude hidden/dev paths (`__MACOSX`, `.github`, `scripts/`, dotfiles)
- Local and CI builds both use `scripts/build-copy.sh` whitelist copy

### 2. First Manual Upload
```bash
# Build release
task build

# Output: dist/CharacterMarkdown-@project-version@.zip
```

Upload at: https://www.esoui.com/downloads/upload-update.php

**Form Fields:**
- **Name**: CharacterMarkdown
- **Category**: Character Advancement
- **Version**: @project-version@
- **Game Version**: 12.0.0 (current ESO client; Season Zero Pt.2)
- **Description**: Brief description with features
- **File**: Upload ZIP
- **Optional Libraries**: LibAddonMenu-2.0, LibDebugLogger, LibSets, LibSlashCommander, LibChatMessage, LibAsync, LibCustomIcons

### 3. Get Addon ID
After upload approval, note the ID from URL:
```
https://www.esoui.com/downloads/info4279-CharacterMarkdown.html
                                    ^^^^
                                 Addon ID
```

### 4. Generate API Token
1. Navigate to: https://www.esoui.com/downloads/filecpl.php?action=apitokens
2. Click "Generate New Token"
3. Copy token (shown only once)

### 5. Configure GitHub

#### Add Secret
1. Go to repository on GitHub
2. Settings → Secrets and variables → Actions
3. New repository secret:
   - Name: `ESOUI_API_KEY`
   - Value: [Your API token]

#### Update Workflow
Edit `.github/workflows/release.yaml`:
```yaml
addon_id: '4279'  # Replace with your addon ID
```

---

## Automated Releases

### Release Process
```bash
# 1. Update version
task version:bump -- patch

# 2. Update CHANGELOG.md
# Add release notes for new version

# 3. Test
task test
task install:live
# Test in-game

# 4. Commit and tag
git add .
git commit -m "Release v@project-version@"
git tag v@project-version@
git push origin main --tags
```

### What Happens Automatically
GitHub Actions workflow:
1. ✓ Runs Luacheck validation
2. ✓ Validates manifest
3. ✓ Updates version in manifest
4. ✓ Creates release ZIP
5. ✓ Validates ZIP structure
6. ✓ Creates GitHub release
7. ✓ Uploads to ESOUI

**Time**: ~3-5 minutes

---

## Manual Publishing (If Needed)

### Build Package
```bash
task build
# Output: dist/CharacterMarkdown-X.X.X.zip
```

### Validate Package
```bash
task minion:verify
# Checks ZIP structure and size
```

### Upload to ESOUI
1. Go to: https://www.esoui.com/downloads/author.php
2. Find your addon
3. Click "Update"
4. Upload new ZIP
5. Update changelog
6. Submit

---

## Version Management

### Semantic Versioning
```
MAJOR.MINOR.PATCH
2.1.0 → 2.1.1 (patch - bug fixes)
2.1.0 → 2.2.0 (minor - new features)
2.0.0 → 3.0.0 (major - breaking changes)
```

### Update Version
```bash
# Automated (updates manifest + CHANGELOG template)
task version:bump -- patch   # 2.1.0 → 2.1.1
task version:bump -- minor   # 2.1.0 → 2.2.0
task version:bump -- major   # 2.1.0 → 3.0.0

# Manual
# Edit CharacterMarkdown.txt:
## Version: 2.1.1
## AddOnVersion: 20250121  # YYYYMMDD format
```

### Update API Version
Get current version in ESO:
```
/script d(GetAPIVersion())
```

Update manifest:
```bash
task version:api -- 101048
# Or manually edit:
## APIVersion: 101048
```

---

## Changelog Maintenance

### Format (Keep a Changelog)
```markdown
## [2.1.1] - 2025-01-21

### Added
- New feature descriptions

### Changed
- Modified behavior descriptions

### Fixed
- Bug fix descriptions

### Removed
- Removed feature descriptions
```

### Example
```markdown
## [2.1.1] - 2025-01-21

### Fixed
- Settings now persist correctly across sessions
- Fixed clipboard truncation for large exports

### Added
- LibDebugLogger integration for clean debug output
- ZIP validation script for build process
```

---

## Testing Before Release

**📋 For a comprehensive pre-release checklist, see [RELEASE_CHECKLIST.md](../RELEASE_CHECKLIST.md)**

### Quick Checklist
- [ ] All formats generate correctly
- [ ] Settings persist after /reloadui
- [ ] Settings persist after game restart
- [ ] No errors in chat on load
- [ ] Window displays correctly
- [ ] Copy to clipboard works
- [ ] All UESP links functional
- [ ] Tested with 2+ different characters
- [ ] Version numbers updated
- [ ] CHANGELOG.md updated

### Automated Pre-Release Validation
```bash
# Run comprehensive validation
./scripts/pre-release-check.sh

# Or use Taskfile
task test    # Lint + validate
task build   # Build and validate ZIP
```

---

## Post-Release

### Verify
1. Check GitHub release created
2. Verify ESOUI upload successful
3. Download ZIP from GitHub and test
4. Monitor ESOUI comments for feedback

### If Issues Found
```bash
# Quick hotfix
task version:bump -- patch
# Fix issue
git commit -am "fix: critical bug description"
git tag v@project-version@
git push origin main --tags
```

---

## Troubleshooting

### GitHub Actions Failed

**Check logs**: Actions tab → Failed workflow → Expand failed step

**Common issues**:
- Missing ESOUI_API_KEY secret
- Incorrect addon ID
- Luacheck errors
- Manifest validation failed

### ESOUI Upload Failed

**Invalid API key**: Regenerate token and update secret  
**Addon not found**: Verify addon ID in workflow  
**ZIP structure wrong**: Run `task build` (not manual ZIP)

### Version Conflicts

**Tag already exists**:
```bash
git tag -d v2.1.1        # Delete local
git push origin :v2.1.1  # Delete remote
```

---

## Console Publishing (Optional)

ESO supports addons on Xbox/PlayStation (as of June 2025). CharacterMarkdown on ESOUI is **PC-only** and ships `CharacterMarkdown.txt`.

### Requirements (if targeting console separately)
- Console uploads use `.addon` manifest extension (separate from ESOUI PC zip)
- Case-sensitive file paths on PlayStation
- Upload via Bethesda.net (separate from ESOUI)

### Upload Tool
Download: https://help.elderscrollsonline.com/app/answers/detail/a_id/69621

---

## SavedVariables (server-scoped)

Account-wide settings use `ZO_SavedVars:NewAccountWide` with `GetWorldName()` as the namespace so NA, EU, and PTS toggles do not overwrite each other. Per-character fields (`customNotes`, `customTitle`, `playStyle`) remain under `perCharacterData[characterId]` inside the current server's account table (character IDs are already unique across megaservers).

Runtime code reads and writes `CM.settings` (the current megaserver `$AccountWide` table), not the SavedVariables root.

---

## Discontinuing or transferring maintenance

Follow [ESOUI Best Practices §§5–6](ESOUI_BEST_PRACTICES.md) if you stop shipping CharacterMarkdown:

1. Prefer finding a maintainer over deletion if the addon is widely used. Post in the appropriate ESOUI forum.
2. Update the ESOUI listing name, description, and changelog to state it is no longer to be used; link alternatives if known.
3. Optionally update addon comments (many users read comments first).
4. **Do not** rely on forum threads or addon comments alone for moderator action — comments are not monitored.
5. To mark discontinued: PM an esoui.com moderator (Dolby, Cairenn, Baertram) with the addon link, asking for category **"Discontinued & Outdated"** (keeps Minion from finding it).
6. To delete entirely: PM a moderator requesting deletion. Deletion removes description, changelog, files, and comments permanently.

Forks, patches, and takeovers: see [CONTRIBUTING.md](../CONTRIBUTING.md). Repo compliance status: [ESOUI_COMPLIANCE.md](ESOUI_COMPLIANCE.md).

---

## Related Documentation

- **[ESOUI Best Practices](ESOUI_BEST_PRACTICES.md)** - Forum + wiki rules
- **[ESOUI Compliance](ESOUI_COMPLIANCE.md)** - CharacterMarkdown status matrix
- **[Development Guide](DEVELOPMENT.md)** - Setup and workflow
- **[Architecture](ARCHITECTURE.md)** - Code structure
- **[Testing Guide](TESTING_COMMAND.md)** - Pre-release validation

## Resources

- **ESOUI**: https://www.esoui.com/
- **Author Dashboard**: https://www.esoui.com/downloads/author.php
- **API Tokens**: https://www.esoui.com/downloads/filecpl.php?action=apitokens
- **GitHub Actions**: https://docs.github.com/en/actions

---

**Ready to publish!** 🚀
