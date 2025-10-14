# Taskfile Quick Start Guide

This guide shows you how to use the Task automation tool for CharacterMarkdown development.

## Installation

### Install Task

```bash
# macOS
brew install go-task/tap/go-task

# Linux
sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b ~/.local/bin

# Windows (via Scoop)
scoop install task

# Or download binary from: https://github.com/go-task/task/releases
```

Verify installation:
```bash
task --version
```

## Common Tasks

### View All Available Tasks

```bash
task --list
```

Or just:
```bash
task
```

## Development Workflow

### 1. Initial Setup

```bash
# Install addon to ESO in development mode (symlink)
task install:dev

# This creates a symlink, so edits are immediately available
# Just use /reloadui in ESO to test changes
```

### 2. Make Changes

```bash
# Edit the Lua file
vim CharacterMarkdown.lua

# In ESO:
/reloadui
/markdown
```

### 3. Validate Your Changes

```bash
# Run all validations
task validate

# Or individual checks
task validate:files      # Check required files exist
task validate:manifest   # Check manifest format
task validate:lua        # Check Lua syntax
```

### 4. Test Installation

```bash
# Test the full installation workflow
task test:install
```

## Release Workflow

### Standard Release Process

```bash
# 1. Bump version (patch, minor, or major)
task version:bump -- patch

# 2. Edit changelog
vim CHANGELOG.md

# 3. Commit changes
task git:commit -- "Release v1.0.1"

# 4. Create full release (builds, packages, tags)
task release

# 5. Push to GitHub
git push origin main --tags

# 6. Optional: Create GitHub release
task release:github
```

### Quick Bug Fix Release

```bash
# Make your fixes
vim CharacterMarkdown.lua

# Validate
task validate

# Bump patch version
task version:bump -- patch

# Package for distribution
task package

# Commit and tag
task git:commit -- "Fix: bug description"
task git:tag

# Push
git push origin main --tags
```

## Minion (ESOUI) Upload

### Setup for Automated Upload

```bash
# 1. Install Python dependencies
pip3 install -r requirements.txt
playwright install chromium

# 2. Copy environment template
cp .env.example .env

# 3. Edit .env with your credentials
vim .env

# Add:
# ESOUI_USERNAME=your_username
# ESOUI_PASSWORD=your_password
# ESOUI_ADDON_ID=1234  # Get this after first manual upload
```

### Upload to ESOUI

```bash
# Prepare package for Minion
task minion:prepare

# Verify package is ready
task minion:verify

# Upload (automated - requires setup above)
task minion:upload

# Or manual upload
task minion:prepare
open "https://www.esoui.com/downloads/upload.php"
# Upload the ZIP from dist/ folder manually
```

## Useful Tasks

### Information

```bash
# Show addon info
task info

# Show current version
task version

# Check file sizes
task size

# Show git status
task git:status
```

### Installation

```bash
# Install to ESO (copy mode)
task install

# Install to ESO (dev mode - symlink)
task install:dev

# Uninstall from ESO
task uninstall
```

### Building

```bash
# Build distribution
task build

# Create release ZIP
task package

# Create ESOUI-compatible package
task package:esoui

# Clean build artifacts
task clean
```

### Version Management

```bash
# Show current version
task version

# Bump patch version (1.0.0 → 1.0.1)
task version:bump -- patch

# Bump minor version (1.0.0 → 1.1.0)
task version:bump -- minor

# Bump major version (1.0.0 → 2.0.0)
task version:bump -- major
```

### Git Operations

```bash
# Check status
task git:status

# Commit changes
task git:commit -- "Your commit message"

# Create version tag
task git:tag
```

### Development

```bash
# Start development mode with file watching
task dev

# Lint Lua code (requires luacheck)
task dev:lint

# Check Lua syntax only
task test:syntax
```

## Task Chaining

You can run multiple tasks in sequence:

```bash
# Validate, build, and package
task validate build package

# Clean and rebuild
task clean build
```

## Help Tasks

```bash
# Installation help
task help:install

# Release workflow help
task help:release

# Development workflow help
task help:dev
```

## Customizing Tasks

### Edit Taskfile.yml

The Taskfile is written in YAML. You can add your own tasks:

```yaml
my-custom-task:
  desc: Description of what this does
  cmds:
    - echo "Hello World"
    - ls -la
```

Then run:
```bash
task my-custom-task
```

### Task Dependencies

Tasks can depend on other tasks:

```yaml
deploy:
  deps: [validate, build, package]
  cmds:
    - echo "Deploying..."
```

## Common Patterns

### Daily Development

```bash
# Morning: Set up dev environment
task install:dev

# During work: Edit → Test → Validate
vim CharacterMarkdown.lua
# In ESO: /reloadui
task validate

# End of day: Commit
task git:commit -- "Work in progress"
```

### Pre-Release Checklist

```bash
# 1. Validate everything
task validate

# 2. Test installation
task test:install

# 3. Check in ESO
# Launch ESO, test all features

# 4. Bump version
task version:bump -- minor

# 5. Update changelog
vim CHANGELOG.md

# 6. Build and package
task package

# 7. Commit and tag
task git:commit -- "Release v1.1.0"
task git:tag

# 8. Push
git push origin main --tags

# 9. Upload to ESOUI
task minion:upload
```

## Troubleshooting

### Task not found

```bash
# Make sure you're in the right directory
cd ~/git/CharacterMarkdown

# Check Taskfile exists
ls -la Taskfile.yml
```

### Task fails

```bash
# Run with verbose output
task -v your-task-name

# Check task definition
task --list
```

### Git operations fail

```bash
# Check git is configured
git config user.name
git config user.email

# Configure if needed
git config user.name "Your Name"
git config user.email "you@example.com"
```

### Upload script fails

```bash
# Check Python dependencies
pip3 list | grep playwright

# Install if missing
pip3 install -r requirements.txt
playwright install chromium

# Check .env file exists
cat .env

# Test with non-headless mode
HEADLESS=false task minion:upload
```

## Advanced Usage

### Running Tasks in CI/CD

```yaml
# Example GitHub Actions
- name: Install Task
  run: sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d

- name: Validate
  run: task validate

- name: Build
  run: task package
```

### Environment Variables

You can override task variables:

```bash
# Use different ESO directory
ESO_ADDONS_DIR=/custom/path task install

# Change dist directory
DIST_DIR=./build task package
```

## Quick Reference

```bash
# Setup
task install:dev                    # Development setup

# Development
vim CharacterMarkdown.lua           # Edit code
# /reloadui in ESO                  # Test in game
task validate                       # Check changes

# Release
task version:bump -- patch          # Bump version
task git:commit -- "message"        # Commit
task release                        # Full release
git push origin main --tags         # Push

# Upload
task minion:prepare                 # Prepare package
task minion:upload                  # Upload to ESOUI
```

## Resources

- **Task Documentation:** https://taskfile.dev
- **Task GitHub:** https://github.com/go-task/task
- **Taskfile Reference:** https://taskfile.dev/usage/

---

**Remember:** Always run `task validate` before committing changes!

**Pro Tip:** Create a git alias for common workflows:
```bash
git config alias.addon-release '!task validate && task version:bump -- patch && task release'
```

Then just run:
```bash
git addon-release
```
