# CharacterMarkdown - Development Setup Guide

Complete guide for setting up the CI/CD development environment.

---

## Prerequisites

### Required Software

1. **Git** (version control)
   ```bash
   git --version  # Verify installed
   ```

2. **Homebrew** (package manager for macOS)
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

3. **GitHub Account**
   - Create account at https://github.com
   - Configure SSH keys or Personal Access Token

---

## Step 1: Install Development Dependencies

Run the automated installation task:

```bash
cd ~/git/CharacterMarkdown
task install:deps
```

This will install:
- **LuaJIT** - Lua 5.1 compatible JIT compiler (faster than standard Lua 5.1)
- **LuaRocks** - Lua package manager
- **Luacheck** - Lua linter
- **pre-commit** - Git hook framework

### Manual Installation (if task fails)

```bash
# Install LuaJIT (Lua 5.1 compatible, faster)
brew install luajit

# Install LuaRocks
brew install luarocks

# Install Luacheck via LuaRocks
luarocks install luacheck

# Install pre-commit
brew install pre-commit

# Verify installations
luajit -v
luacheck --version
pre-commit --version
```

**Why LuaJIT instead of Lua 5.1?**
- ✅ 100% compatible with Lua 5.1 (same API)
- ✅ 2-10x faster execution
- ✅ Better for development tooling
- ✅ ESO uses Lua 5.1, LuaJIT validates perfectly

---

## Step 2: Initialize Pre-commit Hooks

```bash
cd ~/git/CharacterMarkdown
pre-commit install
```

This installs Git hooks that run automatically before each commit:
- ✅ Luacheck linting
- ✅ Trailing whitespace removal
- ✅ End-of-file newline enforcement
- ✅ Manifest validation
- ✅ Version sync check

### Test Pre-commit Hooks

```bash
# Test on all files
pre-commit run --all-files

# Should see output like:
# Luacheck (Lua static analysis)...........................Passed
# Remove trailing whitespace...............................Passed
# Ensure newline at end of file............................Passed
# Validate CharacterMarkdown.txt manifest..................Passed
```

---

## Step 3: Verify Project Structure

Ensure your project has the required files:

```bash
cd ~/git/CharacterMarkdown
ls -la

# Expected files:
# ✓ CharacterMarkdown.txt        # Manifest (will be renamed to .addon)
# ✓ CharacterMarkdown.xml        # UI definition
# ✓ CHANGELOG.md                 # Release notes
# ✓ src/                         # Source code directory
# ✓ .github/workflows/release.yml # CI/CD pipeline
# ✓ Taskfile.yaml                # Task automation
# ✓ .pre-commit-config.yaml      # Pre-commit hooks
# ✓ .luacheckrc                  # Luacheck config
# ✓ .build-ignore                # Build exclusions
```

---

## Step 4: Rename Manifest (Console Compatibility)

ESO now requires `.addon` extension for console support:

```bash
task rename-manifest

# This creates CharacterMarkdown.addon (preserves .txt for reference)
```

**Result:**
- ✅ `CharacterMarkdown.addon` - Used by ESO (all platforms)
- ✅ `CharacterMarkdown.txt` - Preserved for compatibility

---

## Step 5: Validate Project

Run validation to ensure everything is configured correctly:

```bash
task test

# Expected output:
# 🔍 Running Luacheck...
# ✅ Lint passed
# ✅ Validating manifest...
# ✅ Manifest valid
# ✅ All tests passed
```

---

## Step 6: Configure GitHub Repository

### A) Initialize Git (if not already done)

```bash
cd ~/git/CharacterMarkdown
git init
git add .
git commit -m "Initial commit with CI/CD framework"
```

### B) Create GitHub Repository

**Option 1: GitHub CLI**
```bash
# Install GitHub CLI
brew install gh

# Authenticate
gh auth login

# Create repository
gh repo create CharacterMarkdown --public --source=. --remote=origin
```

**Option 2: GitHub Web UI**
1. Go to https://github.com/new
2. Repository name: `CharacterMarkdown`
3. Visibility: Public (or Private)
4. **Do NOT initialize** with README/LICENSE (already exists locally)
5. Click "Create repository"
6. Follow instructions to push existing repository:

```bash
git remote add origin git@github.com:YOUR_USERNAME/CharacterMarkdown.git
git branch -M main
git push -u origin main
```

---

## Step 7: Configure GitHub Secrets

GitHub Actions requires secrets for ESOUI upload.

### A) Generate ESOUI API Token

1. **Create ESOUI Account:** https://www.esoui.com/
2. **Apply for Author Status:**
   - User Control Panel → Permissions → Request author access
   - Wait for approval (24-48 hours)
3. **Generate Token:**
   - Navigate to: https://www.esoui.com/downloads/filecpl.php?action=apitokens
   - Click "Generate New Token"
   - **Copy token immediately** (only shown once)

### B) Add Token to GitHub Secrets

1. Go to your GitHub repository
2. Navigate to: **Settings → Secrets and variables → Actions**
3. Click **"New repository secret"**
4. Name: `ESOUI_API_KEY`
5. Value: [Paste your ESOUI token]
6. Click **"Add secret"**

**Security Notes:**
- ✅ Secrets are encrypted and never visible in logs
- ✅ Only accessible by GitHub Actions workflows
- ⚠️ Never commit tokens to Git

---

## Step 8: Perform First Manual Upload to ESOUI

**GitHub Actions cannot upload until you have an Addon ID.**

### A) Create Release ZIP

```bash
task build

# Output: dist/CharacterMarkdown-2.1.0.zip
```

### B) Manual Upload to ESOUI

1. Go to: https://www.esoui.com/downloads/upload-update.php
2. Fill out form:
   - **Addon Name:** CharacterMarkdown
   - **Category:** Character Advancement (or Miscellaneous)
   - **Version:** 2.1.0
   - **Game Version:** 11.0.0 (current ESO version)
   - **Description:**
     ```
     Generate comprehensive markdown character profiles with:
     - Combat stats, equipment, Champion Points
     - Skill bars with UESP links
     - Multiple export formats (GitHub, VS Code, Discord)
     - ESO Plus, DLC access, currencies, progression
     - Riding skills, inventory, PvP, collectibles
     ```
   - **Upload File:** Browse to `dist/CharacterMarkdown-2.1.0.zip`
   - **Optional Libraries:** LibAddonMenu-2.0
3. Click **"Submit"**
4. Wait for approval

### C) Get Addon ID

After upload, you'll see a confirmation page with URL:
```
https://www.esoui.com/downloads/info####-CharacterMarkdown.html
                                    ^^^^
                                 This is your Addon ID
```

**Example:** If URL is `info3425-CharacterMarkdown.html`, your Addon ID is `3425`

---

## Step 9: Configure Automated ESOUI Upload

Edit the workflow file to add your Addon ID:

```bash
# Open workflow file
code .github/workflows/release.yml

# Or with any editor:
nano .github/workflows/release.yml
```

Find this line (around line 140):
```yaml
addon_id: 'XXXX'  # TODO: Replace with your ESOUI addon ID
```

Replace with your actual ID:
```yaml
addon_id: '3425'  # Your actual addon ID from ESOUI
```

**Commit the change:**
```bash
git add .github/workflows/release.yml
git commit -m "Configure ESOUI addon ID for automated uploads"
git push origin main
```

---

## Step 10: Verify GitHub Actions

Check that GitHub Actions is enabled:

1. Go to your repository on GitHub
2. Click **"Actions"** tab
3. You should see "Release CharacterMarkdown" workflow listed
4. If disabled, click "I understand my workflows, go ahead and enable them"

---

## Step 11: Test the Pipeline

### A) Create a Test Release

```bash
# Update version in manifest (if needed)
# Edit CharacterMarkdown.txt: ## Version: 2.1.1

# Update CHANGELOG.md with new section:
cat >> CHANGELOG.md << 'EOF'

## [2.1.1] - 2025-01-20

### Changed
- Test release for CI/CD validation

EOF

# Commit changes
git add CharacterMarkdown.txt CHANGELOG.md
git commit -m "Release v2.1.1"

# Create and push tag
git tag v2.1.1
git push origin main --tags
```

### B) Monitor GitHub Actions

1. Go to: https://github.com/YOUR_USERNAME/CharacterMarkdown/actions
2. You should see "Release CharacterMarkdown" workflow running
3. Click on the running workflow to see detailed logs
4. Wait for completion (typically 2-3 minutes)

### C) Verify Outputs

After successful completion:

1. **GitHub Release:**
   - Go to: https://github.com/YOUR_USERNAME/CharacterMarkdown/releases
   - You should see "CharacterMarkdown v2.1.1"
   - ZIP artifact should be attached

2. **ESOUI Upload:**
   - Go to: https://www.esoui.com/downloads/author.php
   - Check for new version upload
   - May take a few minutes to appear

---

## Step 12: Local Development Workflow

### Daily Development

```bash
# 1. Make code changes
# 2. Test locally
task install:live     # Install to ESO Live client
# Launch ESO and test in-game

# 3. Commit changes (pre-commit hooks run automatically)
git add .
git commit -m "Add new feature"

# Pre-commit will:
# ✅ Run Luacheck
# ✅ Validate manifest
# ✅ Fix whitespace
# ✅ Check version sync
```

### Creating a Release

```bash
# 1. Update CHANGELOG.md with new version section
# 2. Update version in CharacterMarkdown.txt
# 3. Run tests
task test

# 4. Commit and tag
git commit -am "Release vX.X.X"
task release:tag  # Interactive tag creation and push

# 5. GitHub Actions automatically:
#    - Builds ZIP
#    - Creates GitHub release
#    - Uploads to ESOUI
```

---

## Troubleshooting

### Issue: Pre-commit hooks not running

```bash
# Reinstall hooks
pre-commit uninstall
pre-commit install

# Test manually
pre-commit run --all-files
```

### Issue: Luacheck not found

```bash
# Reinstall via LuaRocks
luarocks install luacheck

# Verify installation
which luacheck
luacheck --version
```

### Issue: LuaJIT not found

```bash
# Install LuaJIT
brew install luajit

# Verify
luajit -v
# Should show: LuaJIT 2.1.x

# Verify Lua 5.1 compatibility
luajit -e "print(_VERSION)"
# Should show: Lua 5.1
```

### Issue: GitHub Actions failing

**Check logs:**
1. Go to Actions tab on GitHub
2. Click on failed workflow run
3. Expand failed step to see error

**Common causes:**
- Missing `ESOUI_API_KEY` secret
- Incorrect addon ID in workflow
- Manifest validation failed
- Luacheck errors in code

### Issue: ESOUI upload fails

**Error: "Invalid API key"**
- Regenerate token at https://www.esoui.com/downloads/filecpl.php?action=apitokens
- Update `ESOUI_API_KEY` secret on GitHub

**Error: "Addon not found"**
- Verify addon ID is correct in workflow
- Ensure you completed first manual upload

### Issue: Manifest validation fails

```bash
# Run validator manually
luajit scripts/validate-manifest.lua CharacterMarkdown.txt

# Common issues:
# - Missing required fields (Title, Author, Version, APIVersion)
# - Invalid version format (use MAJOR.MINOR.PATCH)
# - Missing files referenced in manifest
```

---

## Next Steps

- ✅ **Setup complete!** You now have:
  - Automated testing with Luacheck
  - Pre-commit hooks for quality control
  - CI/CD pipeline for releases
  - Automated ESOUI uploads

- 📖 **Read Next:**
  - [docs/RELEASE.md](docs/RELEASE.md) - Release process guide
  - [CHANGELOG.md](../CHANGELOG.md) - Change history
  - [TASKFILE_MERGE_COMPLETE.md](../TASKFILE_MERGE_COMPLETE.md) - LuaJIT integration details

- 🚀 **Start Developing:**
  ```bash
  # View available tasks
  task --list
  
  # Common commands
  task lint              # Check code quality
  task test              # Run all tests
  task build             # Create release ZIP
  task install:live      # Install to ESO
  task release:prepare   # Prepare for release
  ```

---

## Quick Reference

### Essential Commands

| Command | Description |
|---------|-------------|
| `task install:deps` | Install all dependencies |
| `task lint` | Run Luacheck |
| `task test` | Run all tests |
| `task build` | Build release ZIP |
| `task install:live` | Install to ESO Live |
| `task install:pts` | Install to ESO PTS |
| `task release:prepare` | Prepare release |
| `task version` | Show current version |

### Important Files

| File | Purpose |
|------|---------|
| `Taskfile.yaml` | Task automation |
| `.github/workflows/release.yml` | CI/CD pipeline |
| `.pre-commit-config.yaml` | Git hooks config |
| `.luacheckrc` | Luacheck rules |
| `.build-ignore` | Build exclusions |
| `scripts/validate-manifest.lua` | Manifest validator |
| `scripts/validate-zip.sh` | ZIP structure checker |

### Useful Links

- **ESOUI:** https://www.esoui.com
- **ESOUI API Tokens:** https://www.esoui.com/downloads/filecpl.php?action=apitokens
- **ESOUI Author Dashboard:** https://www.esoui.com/downloads/author.php
- **GitHub Actions Docs:** https://docs.github.com/en/actions
- **Taskfile Docs:** https://taskfile.dev
- **pre-commit Docs:** https://pre-commit.com
- **LuaJIT:** https://luajit.org

---

**Setup Complete! 🎉**

You're ready to develop and release CharacterMarkdown with full CI/CD automation.
