# Publishing Guide

## Initial Setup (One-Time)

### 1. Create ESOUI Account
1. Register at https://www.esoui.com/
2. Verify email
3. Apply for author status (User Control Panel → Permissions)
4. Wait for approval (24-48 hours)

### 2. First Manual Upload
```bash
# Build release
task build

# Output: dist/CharacterMarkdown-2.1.0.zip
```

Upload at: https://www.esoui.com/downloads/upload-update.php

**Form Fields:**
- **Name**: CharacterMarkdown
- **Category**: Character Advancement
- **Version**: 2.1.0
- **Game Version**: 11.0.0 (current ESO version)
- **Description**: Brief description with features
- **File**: Upload ZIP
- **Optional Libraries**: LibAddonMenu-2.0

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
git commit -m "Release v2.1.2"
git tag v2.1.2
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
# Edit CharacterMarkdown.addon:
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

### Checklist
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
git tag v2.1.2
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

ESO supports addons on Xbox/PlayStation (as of June 2025).

### Requirements
- Use `.addon` manifest extension (already done)
- Case-sensitive file paths on PlayStation
- Upload via Bethesda.net (separate from ESOUI)

### Upload Tool
Download: https://help.elderscrollsonline.com/app/answers/detail/a_id/69621

---

## Resources

- **ESOUI**: https://www.esoui.com/
- **Author Dashboard**: https://www.esoui.com/downloads/author.php
- **API Tokens**: https://www.esoui.com/downloads/filecpl.php?action=apitokens
- **GitHub Actions**: https://docs.github.com/en/actions

---

**Ready to publish!** 🚀
