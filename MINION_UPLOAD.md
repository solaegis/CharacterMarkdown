# Minion Addon Upload Guide

Complete guide for automatically uploading ESO addons to Minion (ESOUI's addon manager).

---

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Manual Upload Process](#manual-upload-process)
4. [Automated Upload Options](#automated-upload-options)
5. [Package Preparation](#package-preparation)
6. [ESOUI Account Setup](#esoui-account-setup)
7. [Upload Workflow](#upload-workflow)
8. [Version Management](#version-management)
9. [Troubleshooting](#troubleshooting)
10. [Best Practices](#best-practices)

---

## Overview

**Minion** is the most popular addon manager for ESO, developed by ESOUI.com. It allows users to automatically discover, install, and update addons. To make your addon available through Minion, you must upload it to ESOUI.com.

### Key Facts

- **Platform:** https://www.esoui.com
- **File Format:** ZIP archive
- **Max File Size:** 10 MB (soft limit)
- **Update Method:** Manual upload (no official API for automation)
- **Distribution:** Automatic through Minion client after approval

---

## Prerequisites

### Required Accounts

1. **ESOUI Account**
   - Register at: https://www.esoui.com/register.php
   - Email verification required
   - Free account (no payment needed)

2. **Addon Submission Rights**
   - Automatic after account creation
   - First submission requires manual approval (~24-48 hours)

### Required Tools

```bash
# Task runner (for automation)
brew install go-task/tap/go-task

# ZIP utility (usually pre-installed)
zip --version

# Optional: Browser automation
# - Playwright (Python)
# - Selenium (multiple languages)
# - Puppeteer (Node.js)
```

### Required Files

Your addon package must include:

- `AddonName.txt` - Manifest file
- `AddonName.lua` - Main Lua file
- `AddonName.xml` - UI definition (if applicable)
- `README.md` - User documentation (recommended)
- `LICENSE` - License file (recommended)

---

## Manual Upload Process

### Step 1: Prepare Package

```bash
# Using Taskfile
task package:esoui

# Output: dist/CharacterMarkdown-v1.0.0-esoui.zip
```

**Manual Preparation:**
```bash
# Create distribution directory
mkdir -p dist/CharacterMarkdown

# Copy required files
cp CharacterMarkdown.txt \
   CharacterMarkdown.xml \
   CharacterMarkdown.lua \
   README.md \
   LICENSE \
   dist/CharacterMarkdown/

# Create ZIP
cd dist && zip -r CharacterMarkdown-v1.0.0-esoui.zip CharacterMarkdown/
```

### Step 2: Log in to ESOUI

1. Navigate to https://www.esoui.com
2. Click **Log In** (top right)
3. Enter credentials
4. Verify login successful

### Step 3: Submit Addon

**For New Addon:**

1. Go to https://www.esoui.com/downloads/upload.php
2. Click **"Upload New File"**
3. Fill out form:
   - **File Title:** Character Markdown
   - **Category:** Miscellaneous or Data Export
   - **Description:** Full addon description (supports BBCode)
   - **Version:** 1.0.0
   - **Compatible:** Check ESO API versions (101043, 101044)
   - **File:** Upload your ZIP
   - **Change Log:** Initial release
   - **Screenshots:** Optional but recommended

**For Updating Existing Addon:**

1. Go to https://www.esoui.com/downloads/
2. Find your addon
3. Click **"Update"** or **"Manage Files"**
4. Upload new version ZIP
5. Update version number
6. Add change log entry
7. Submit

### Step 4: Await Approval

- **First Upload:** 24-48 hours for manual review
- **Updates:** Usually instant or within a few hours
- **Notification:** Email when approved/live

---

## Automated Upload Options

### Option 1: Browser Automation (Playwright)

**Advantages:**
- Full control over upload process
- Handles CAPTCHA and cookies
- Most reliable for complex forms

**Setup:**

```bash
# Install Python Playwright
pip install playwright
playwright install chromium

# Create upload script
touch scripts/upload_to_esoui.py
chmod +x scripts/upload_to_esoui.py
```

**Script: `scripts/upload_to_esoui.py`**

```python
#!/usr/bin/env python3
"""
Automated ESOUI addon upload using Playwright.
Requires: playwright, python-dotenv
"""

import os
import sys
from pathlib import Path
from playwright.sync_api import sync_playwright
from dotenv import load_dotenv

load_dotenv()

ESOUI_USERNAME = os.getenv("ESOUI_USERNAME")
ESOUI_PASSWORD = os.getenv("ESOUI_PASSWORD")
ADDON_ID = os.getenv("ESOUI_ADDON_ID")  # From addon URL after first upload

def upload_addon(zip_path: str, version: str, changelog: str):
    """Upload addon to ESOUI using browser automation."""
    
    with sync_playwright() as p:
        # Launch browser
        browser = p.chromium.launch(headless=False)  # Set True for CI/CD
        context = browser.new_context()
        page = context.new_page()
        
        try:
            # Step 1: Login
            print("Logging in to ESOUI...")
            page.goto("https://www.esoui.com/login.php")
            page.fill('input[name="vb_login_username"]', ESOUI_USERNAME)
            page.fill('input[name="vb_login_password"]', ESOUI_PASSWORD)
            page.click('input[type="submit"]')
            page.wait_for_load_state("networkidle")
            
            # Verify login
            if "login" in page.url.lower():
                raise Exception("Login failed - check credentials")
            print("✓ Logged in successfully")
            
            # Step 2: Navigate to update page
            print(f"Navigating to addon #{ADDON_ID}...")
            page.goto(f"https://www.esoui.com/downloads/info{ADDON_ID}.html")
            page.click('text="Update File"')
            page.wait_for_load_state("networkidle")
            
            # Step 3: Upload new version
            print(f"Uploading {zip_path}...")
            page.set_input_files('input[type="file"]', zip_path)
            
            # Fill version field
            page.fill('input[name="version"]', version)
            
            # Fill changelog
            page.fill('textarea[name="changelog"]', changelog)
            
            # Submit
            page.click('input[type="submit"][value="Upload"]')
            page.wait_for_load_state("networkidle")
            
            # Verify success
            if "success" in page.content().lower():
                print(f"✓ Upload successful! Version {version}")
            else:
                print("⚠ Upload may have failed - check ESOUI manually")
            
        except Exception as e:
            print(f"✗ Error: {e}")
            sys.exit(1)
        finally:
            browser.close()

if __name__ == "__main__":
    if len(sys.argv) < 4:
        print("Usage: upload_to_esoui.py <zip_path> <version> <changelog>")
        sys.exit(1)
    
    zip_path = sys.argv[1]
    version = sys.argv[2]
    changelog = sys.argv[3]
    
    if not Path(zip_path).exists():
        print(f"✗ ZIP file not found: {zip_path}")
        sys.exit(1)
    
    upload_addon(zip_path, version, changelog)
```

**Environment Setup:**

```bash
# Create .env file
cat > .env << 'EOF'
ESOUI_USERNAME=your_username
ESOUI_PASSWORD=your_password
ESOUI_ADDON_ID=1234  # Get from addon URL after first upload
EOF

# Add to .gitignore
echo ".env" >> .gitignore
```

**Usage:**

```bash
# Upload using script
python3 scripts/upload_to_esoui.py \
    dist/CharacterMarkdown-v1.0.0-esoui.zip \
    1.0.0 \
    "Initial release with character data export"
```

### Option 2: ESOUI API (Unofficial)

⚠️ **Warning:** ESOUI does not provide an official API for uploads. The site uses form-based submission, which means:

1. No REST API endpoints available
2. Web scraping/automation is against some ToS
3. Browser automation is the most reliable method

### Option 3: Semi-Automated with Scripts

Create helper scripts that prepare everything but require manual upload:

```bash
# Add to Taskfile.yml
minion:upload:
  desc: Prepare and open ESOUI upload page
  deps: [package:esoui]
  cmds:
    - echo "Package ready: {{.DIST_DIR}}/{{.ADDON_NAME}}-v{{.VERSION}}-esoui.zip"
    - open "https://www.esoui.com/downloads/upload.php"
    - echo "Upload the file manually in the browser window"
```

---

## Package Preparation

### Taskfile Integration

```yaml
# Taskfile.yml tasks for Minion upload

minion:prepare:
  desc: Prepare package for Minion upload
  deps: [validate, build]
  cmds:
    - task: package:esoui
    - task: minion:verify
    - echo "Ready for upload to ESOUI"

minion:verify:
  desc: Verify package meets requirements
  cmds:
    - echo "Checking package..."
    - |
      # Check file exists
      if [ ! -f "{{.DIST_DIR}}/{{.ADDON_NAME}}-v{{.VERSION}}-esoui.zip" ]; then
        echo "✗ Package not found"
        exit 1
      fi
      
      # Check size
      SIZE=$(stat -f%z "{{.DIST_DIR}}/{{.ADDON_NAME}}-v{{.VERSION}}-esoui.zip")
      if [ $SIZE -gt 10485760 ]; then
        echo "⚠ Warning: Package larger than 10MB"
      fi
      
      # Check ZIP integrity
      unzip -t "{{.DIST_DIR}}/{{.ADDON_NAME}}-v{{.VERSION}}-esoui.zip" > /dev/null
      
      echo "✓ Package verified"

minion:upload:
  desc: Upload to ESOUI (requires setup)
  deps: [minion:prepare]
  cmds:
    - python3 scripts/upload_to_esoui.py \
        "{{.DIST_DIR}}/{{.ADDON_NAME}}-v{{.VERSION}}-esoui.zip" \
        "{{.VERSION}}" \
        "$(git log -1 --pretty=%B)"
```

### Automated Workflow

```bash
# Full release workflow
task version:bump -- patch
task git:commit -- "Release v$(task version)"
task minion:upload
task git:tag
git push && git push --tags
```

---

## ESOUI Account Setup

### 1. Register Account

```
URL: https://www.esoui.com/register.php

Required Information:
- Username
- Email address
- Password
- Timezone
- Age verification
```

### 2. Verify Email

- Check inbox for verification email
- Click verification link
- Log in to confirm

### 3. Set Up Developer Profile

1. Go to User CP → Edit Profile
2. Add developer information:
   - Contact email
   - Website/GitHub
   - Discord username (optional)

### 4. First Addon Submission

Your first addon requires manual approval:

1. Submit via upload form
2. Wait 24-48 hours
3. Check email for approval notification
4. Once approved, future updates are faster

---

## Upload Workflow

### Complete Release Process

```bash
# 1. Prepare release
task validate
task version:bump -- patch

# 2. Update changelog
vim CHANGELOG.md  # Add release notes

# 3. Commit changes
task git:commit -- "Prepare release v$(task version)"

# 4. Build package
task package:esoui

# 5. Upload to ESOUI
# Option A: Manual
task minion:prepare
open "https://www.esoui.com/downloads/upload.php"

# Option B: Automated (if configured)
task minion:upload

# 6. Create git tag
task git:tag

# 7. Push to GitHub
git push origin main
git push origin --tags

# 8. Create GitHub release
task release:github
```

### Quick Update Workflow

```bash
# For minor updates/bug fixes

# 1. Make changes
vim CharacterMarkdown.lua

# 2. Test
task install:dev
# Test in ESO with /reloadui

# 3. Validate
task validate

# 4. Bump version
task version:bump -- patch

# 5. Package and upload
task minion:prepare
# Upload manually or via script

# 6. Commit and push
task git:commit -- "Fix: description"
git push
```

---

## Version Management

### Version Numbering

Follow Semantic Versioning (semver):

```
MAJOR.MINOR.PATCH

Examples:
- 1.0.0 → Initial release
- 1.0.1 → Bug fix
- 1.1.0 → New feature
- 2.0.0 → Breaking change
```

### Update Locations

When updating version, change in:

1. **Manifest:** `CharacterMarkdown.txt`
   ```
   ## Version: 1.0.1
   ```

2. **CHANGELOG.md**
   ```markdown
   ## [1.0.1] - 2024-10-15
   ### Fixed
   - Bug description
   ```

3. **Git Tag**
   ```bash
   git tag -a v1.0.1 -m "Release 1.0.1"
   ```

4. **ESOUI Upload Form**
   - Version field: `1.0.1`
   - Change log: Copy from CHANGELOG.md

### Automated Version Bumping

```bash
# Patch version (1.0.0 → 1.0.1)
task version:bump -- patch

# Minor version (1.0.0 → 1.1.0)
task version:bump -- minor

# Major version (1.0.0 → 2.0.0)
task version:bump -- major
```

---

## Troubleshooting

### Upload Fails

**Problem:** ZIP file rejected

**Solutions:**
- Verify ZIP contains correct folder structure
- Check file size < 10 MB
- Ensure manifest is valid
- Test ZIP integrity: `unzip -t file.zip`

### Login Issues

**Problem:** Can't log in to ESOUI

**Solutions:**
- Clear browser cookies
- Use incognito/private mode
- Reset password if needed
- Check for site maintenance

### Version Conflicts

**Problem:** "Version already exists"

**Solutions:**
- Increment version number
- Delete old version in ESOUI (if allowed)
- Use different version format (e.g., 1.0.0a)

### Approval Delays

**Problem:** First submission not approved

**Solutions:**
- Wait 48 hours before following up
- Check spam folder for emails
- Contact ESOUI support via forums
- Ensure all required fields filled

### Automated Upload Fails

**Problem:** Playwright/Selenium script fails

**Solutions:**
- Run in non-headless mode to debug
- Check for CAPTCHA requirements
- Verify credentials in .env
- Update script if ESOUI changed forms

---

## Best Practices

### Before Upload

- [ ] Run `task validate` to check files
- [ ] Test addon in ESO thoroughly
- [ ] Update CHANGELOG.md with changes
- [ ] Bump version number appropriately
- [ ] Create git tag for release
- [ ] Review README.md for accuracy

### Upload Checklist

- [ ] Correct version number in manifest
- [ ] ZIP file named with version
- [ ] Change log describes updates
- [ ] Screenshots updated (if UI changed)
- [ ] README.md included in package
- [ ] LICENSE file included
- [ ] API version compatibility checked

### After Upload

- [ ] Verify addon appears on ESOUI
- [ ] Test download from ESOUI works
- [ ] Check Minion detects update
- [ ] Update GitHub release
- [ ] Notify users of update (Discord/forums)
- [ ] Monitor for user feedback/bugs

### Security

- ⚠️ Never commit `.env` with credentials
- ⚠️ Use environment variables for automation
- ⚠️ Don't share ESOUI password
- ⚠️ Enable 2FA if available
- ⚠️ Review automation scripts for security

### Documentation

- Keep CHANGELOG.md updated
- Include migration guides for breaking changes
- Document new features thoroughly
- Provide upgrade instructions when needed
- Link to GitHub for issues/support

---

## Advanced: CI/CD Integration

### GitHub Actions Example

```yaml
# .github/workflows/release.yml
name: Release to ESOUI

on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Install Task
        run: |
          sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b /usr/local/bin
      
      - name: Build package
        run: task package:esoui
      
      - name: Upload to ESOUI
        env:
          ESOUI_USERNAME: ${{ secrets.ESOUI_USERNAME }}
          ESOUI_PASSWORD: ${{ secrets.ESOUI_PASSWORD }}
          ESOUI_ADDON_ID: ${{ secrets.ESOUI_ADDON_ID }}
        run: |
          pip install playwright
          playwright install chromium
          python3 scripts/upload_to_esoui.py \
            dist/*.zip \
            ${GITHUB_REF#refs/tags/v} \
            "Release ${GITHUB_REF#refs/tags/}"
      
      - name: Create GitHub Release
        run: task release:github
```

---

## Resources

### Official Links
- **ESOUI Website:** https://www.esoui.com
- **Upload Page:** https://www.esoui.com/downloads/upload.php
- **Developer Forums:** https://www.esoui.com/forums/

### Tools
- **Task:** https://taskfile.dev
- **Playwright:** https://playwright.dev
- **Minion Client:** https://minion.mmoui.com

### Documentation
- **ESO API Wiki:** https://wiki.esoui.com/API
- **Addon Guidelines:** https://www.esoui.com/forums/showthread.php?t=1524

---

## Quick Reference

```bash
# Prepare for upload
task minion:prepare

# Verify package
task minion:verify

# Manual upload
open "https://www.esoui.com/downloads/upload.php"

# Automated upload (if configured)
task minion:upload

# Full release workflow
task release
```

---

**Last Updated:** 2024-10-14  
**Version:** 1.0.0  
**Maintainer:** lvavasour
