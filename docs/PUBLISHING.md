# Publishing CharacterMarkdown

> **Complete guide for publishing the addon to ESOUI.com**

---

## Table of Contents

- [Overview](#overview)
- [First-Time Setup](#first-time-setup)
- [Automated Releases](#automated-releases)
- [Manual Publishing](#manual-publishing)
- [Console Publishing](#console-publishing)
- [Troubleshooting](#troubleshooting)

---

## Overview

### Publishing Model

1. **First-time upload:** MUST be manual (to get addon ID)
2. **All updates:** Can be fully automated via GitHub Actions
3. **Platform:** ESOUI.com (primary), with optional console support

### Publishing Options

| Method | Use Case | Setup Time | Update Time |
|--------|----------|------------|-------------|
| **GitHub Actions** | Best for regular releases | 30 min | 1 min |
| **Manual Upload** | One-time or infrequent | 15 min | 10 min |
| **CLI Tool** | Alternative automation | 20 min | 2 min |

---

## First-Time Setup

### Prerequisites

- [ ] ESO addon is functional and tested locally
- [ ] Git repository exists (local or GitHub)
- [ ] You have an ESOUI.com account

---

### Step 1: Prepare Manifest File

Create or update `CharacterMarkdown.txt` (or `.addon` for console compatibility):

```lua
## Title: Character Markdown
## Author: @YourAccountName
## Version: 2.1.0
## AddOnVersion: 20250120
## APIVersion: 101045 101046
## Description: Generate comprehensive markdown character profiles
## SavedVariables: CharacterMarkdownSettings
## SavedVariablesPerCharacter: CharacterMarkdownData
## DependsOn: LibAddonMenu-2.0>=35

src/Main.lua
src/UI.lua
src/Collectors.lua
src/Markdown.lua
settings/Settings.lua
CharacterMarkdown.xml
```

**Key Fields:**
- `## APIVersion` - ESO API versions supported (get current: `/script d(GetAPIVersion())`)
- `## AddOnVersion` - Numeric version (format: `YYYYMMDD` or incrementing integer)
- `## DependsOn` - Required libraries (format: `LibName>=version`)

**Versioning:**
- `## Version` - Human-readable (2.1.0, 2024-01-18)
- `## AddOnVersion` - Sortable integer (20250118 or 2001000)

---

### Step 2: Create ESOUI Account

1. Go to https://www.esoui.com/
2. **Register** (top-right)
3. **Verify email** (check spam)
4. **Apply for Author Status:**
   - User Control Panel → Permissions
   - Request author permissions
   - Wait 24-48 hours for approval

---

### Step 3: Package Addon

**Create ZIP with correct structure:**

```bash
cd ~/git
zip -r CharacterMarkdown-2.1.0.zip CharacterMarkdown/ \
  -x "*.git*" \
  -x "*/.DS_Store" \
  -x "*/node_modules/*" \
  -x "*/test/*" \
  -x "*/.vscode/*"
```

**Or use Task:**
```bash
task build
```

**ZIP Structure Must Be:**
```
CharacterMarkdown-2.1.0.zip
└── CharacterMarkdown/
    ├── CharacterMarkdown.txt
    ├── src/Main.lua
    └── [other files]
```

⚠️ **Critical:** ZIP must contain a **folder** with your addon name, not loose files at root.

---

### Step 4: Manual Upload to ESOUI

1. **Navigate to:** https://www.esoui.com/downloads/upload-update.php
2. **Fill out the form:**

```
Addon Name: Character Markdown
Category: Character Advancement (or Miscellaneous)

Description: 
Generate comprehensive markdown character profiles for ESO characters.

Features:
- Complete character stats and equipment
- Champion Point allocation
- Skill bars and progression
- Multiple export formats (GitHub, Discord, VS Code)
- UESP wiki links for abilities and sets

Version: 2.1.0
Game Version: 11.0.0 (current patch, e.g., Gold Road)
Upload File: [Browse to CharacterMarkdown-2.1.0.zip]

Optional Libraries: LibAddonMenu-2.0
Tags: character, export, markdown, documentation
```

3. **Submit** and wait for approval
4. **Note the Addon ID** from the URL:
   ```
   https://www.esoui.com/downloads/info####-CharacterMarkdown.html
                                      ^^^^
                                   This is your addon ID (e.g., 3425)
   ```

---

### Step 5: Generate API Token

1. Go to: https://www.esoui.com/downloads/filecpl.php?action=apitokens
2. Click **"Generate New Token"**
3. **Copy the token** (format: `abc123def456...`)
4. **Store securely** - You'll never see it again

---

## Automated Releases

### Overview

After initial manual upload, all future releases can be automated via GitHub Actions.

### Setup Steps

#### 1. Add API Key to GitHub Secrets

1. Go to: `https://github.com/YOUR_USERNAME/CharacterMarkdown/settings/secrets/actions`
2. Click **New repository secret**
3. Name: `ESOUI_API_KEY`
4. Value: [Paste your ESOUI token]
5. Click **Add secret**

#### 2. Create Build Ignore File

Create `.build-ignore` to exclude files from ZIP:

```
.git
.github
.vscode
.DS_Store
*.md
README*
CHANGELOG*
.build-ignore
node_modules
test
docs
scripts
```

#### 3. Verify Workflow Configuration

The workflow file already exists at `.github/workflows/release.yml`. Verify:

```yaml
# Line ~95 - Update addon_id
addon_id: '####'  # ⚠️ Replace with YOUR addon ID from Step 4

# Line ~100 - Update compatibility
compatibility: '11.0.0'  # Update to current ESO version
```

#### 4. Create Release Files

**CHANGELOG.md:**
```markdown
# Changelog

All notable changes to CharacterMarkdown will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/).

## [Unreleased]

## [2.1.0] - 2025-01-20

### Added
- Champion Point allocation display
- UESP wiki links for abilities and sets
- Multiple export formats

### Fixed
- Character data collection edge cases
- Window display performance

### Changed
- Updated to API version 101046
```

**README_ESOUI.txt** (optional description):
```
Character Markdown generates comprehensive markdown profiles for your ESO characters.

FEATURES:
- Complete character stats
- Equipment with set bonuses
- Front/back bar abilities
- Champion Point allocation
- Multiple export formats

USAGE:
/markdown - Opens export window
/markdown github - Exports in GitHub format
```

---

### Triggering Releases

**Method 1: Git Tags (Recommended)**

```bash
# 1. Update version in CharacterMarkdown.txt
# 2. Update CHANGELOG.md

git add .
git commit -m "Release v2.1.1"
git tag v2.1.1
git push origin main --tags

# This automatically:
# 1. Updates manifest version
# 2. Creates ZIP
# 3. Creates GitHub release
# 4. Uploads to ESOUI
```

**Method 2: Task Command**

```bash
task release:tag
# Interactive prompts guide you through the process
```

---

### Monitoring Releases

1. **GitHub Actions:** `https://github.com/YOUR_USERNAME/CharacterMarkdown/actions`
   - Watch workflow progress (typically 2-3 minutes)
   - Check for any errors

2. **GitHub Releases:** `https://github.com/YOUR_USERNAME/CharacterMarkdown/releases`
   - Verify release created
   - Verify ZIP attached

3. **ESOUI Dashboard:** https://www.esoui.com/downloads/author.php
   - Verify upload succeeded
   - Status: "Pending Approval" or "Approved"
   - Approval usually takes 24-48 hours

---

## Manual Publishing

If you prefer not to use GitHub Actions:

### Option 1: Web Interface

1. Go to: https://www.esoui.com/downloads/filecpl.php
2. Select "Edit" for CharacterMarkdown
3. Click "Add/Update File"
4. Upload new ZIP
5. Update version and changelog
6. Submit

### Option 2: CLI Tool

**Install:**
```bash
npm install -g esoui-publish
```

**Create Script (`scripts/publish.sh`):**
```bash
#!/bin/bash

ADDON_NAME="CharacterMarkdown"
ADDON_ID="3425"  # Your ESOUI addon ID
VERSION="$1"
TOKEN="${ESOUI_TOKEN}"

if [ -z "$VERSION" ]; then
    echo "Usage: ./publish.sh <version>"
    exit 1
fi

# Create ZIP
cd ..
zip -r "${ADDON_NAME}-${VERSION}.zip" "${ADDON_NAME}/" \
  -x "*.git*" -x "*/.DS_Store" -x "*/node_modules/*"

# Upload
esoui-publish \
  --id="${ADDON_ID}" \
  --version="${VERSION}" \
  --updateFile="${ADDON_NAME}-${VERSION}.zip" \
  --changelog="CHANGELOG.md" \
  --compatibility="11.0.0" \
  --token="${TOKEN}"
```

**Usage:**
```bash
export ESOUI_TOKEN="your_token_here"
chmod +x scripts/publish.sh
./scripts/publish.sh 2.1.1
```

---

## Console Publishing

ESO now supports addons on **Xbox** and **PlayStation** (as of June 2025).

### Requirements

**1. Manifest Extension:**
- Use `.addon` instead of `.txt`
- ⚠️ **PlayStation is case-sensitive** for file paths

**2. Upload Tool:**
- Download: https://help.elderscrollsonline.com/app/answers/detail/a_id/69621
- CLI tool for console addon submission
- Documentation included in download

**3. Case-Sensitivity Checklist (PlayStation):**
```
CharacterMarkdown.addon:
CharacterMarkdown.lua         ✅ Matches case
src/Main.lua                  ✅ Matches case
charactermarkdown.lua         ❌ Would fail on PS
```

### Upload Process

**Bethesda.net:**
1. Create Bethesda.net account (if needed)
2. Use console upload tool
3. Manual upload process (no API available as of 2025)

---

## Troubleshooting

### Issue: Manifest Not Found

**Symptom:** ESO doesn't load addon

**Solution:**
```bash
# Verify manifest exists
ls CharacterMarkdown.txt

# Check syntax
cat CharacterMarkdown.txt

# Ensure no BOM (byte order mark)
file CharacterMarkdown.txt
# Should show: ASCII text
```

### Issue: GitHub Actions Fails

**Symptom:** Workflow shows red X

**Check:**
1. Click on failed workflow
2. Expand failed step
3. Read error message

**Common Causes:**
- Addon ID incorrect in workflow
- API token expired
- ZIP structure wrong
- Manifest syntax error

**Fix:**
```bash
# Test locally
task test
task lint

# Fix issues, then re-tag
git tag -d vX.X.X
git tag vX.X.X
git push --delete origin vX.X.X
git push origin vX.X.X
```

### Issue: ESOUI Upload Fails

**Check:**
1. **API Key Valid:**
   - Regenerate: https://www.esoui.com/downloads/filecpl.php?action=apitokens
   - Update GitHub secret: `ESOUI_API_KEY`

2. **Addon ID Correct:**
   - Verify in workflow: `addon_id: '####'`
   - Check ESOUI URL

3. **Workflow Logs:**
   - Check "Upload to ESOUI" step output

### Issue: ZIP Structure Invalid

**Symptom:** Upload succeeds but addon doesn't work

**Check:**
```bash
unzip -l CharacterMarkdown-2.1.0.zip

# Should show:
# CharacterMarkdown/CharacterMarkdown.txt
# CharacterMarkdown/src/Main.lua
# ...

# NOT:
# CharacterMarkdown.txt (at root)
```

**Fix:**
- Verify `.build-ignore` patterns
- Test ZIP extraction locally

---

## Best Practices

### ✅ Do

- **Test locally** before releasing
- **Update changelog** with every release
- **Use semantic versioning** consistently
- **Monitor ESOUI comments** for bug reports
- **Update API version** with ESO patches
- **Keep dependencies current**

### ❌ Don't

- **Rush releases** without testing
- **Skip changelog updates**
- **Release on ESO patch day** (wait 1-2 days)
- **Ignore CI/CD failures**
- **Forget console compatibility** (if supporting)

---

## Quick Reference

### Essential URLs

| Purpose | URL |
|---------|-----|
| Upload addon | https://www.esoui.com/downloads/upload-update.php |
| Generate API token | https://www.esoui.com/downloads/filecpl.php?action=apitokens |
| Manage addons | https://www.esoui.com/downloads/author.php |
| GitHub Action | https://github.com/marketplace/actions/esoui-addon-upload |
| Console tools | https://help.elderscrollsonline.com/app/answers/detail/a_id/69621 |

### Current ESO Versions

| Version | API | Release Date |
|---------|-----|--------------|
| Gold Road (U46) | 101046 | June 2024 |
| Update 45 | 101045 | March 2024 |

### Release Commands

```bash
# Full automated release
task release:prepare   # Validate
task release:tag       # Create and push tag

# Manual release
task build             # Create ZIP
# Upload via web or CLI

# Rollback
git tag -d vX.X.X
git push --delete origin vX.X.X
```

---

**For detailed release workflow, see [RELEASE.md](RELEASE.md)**

**Last Updated:** January 2025