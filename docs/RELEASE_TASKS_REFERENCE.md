# Release Tasks - Quick Reference

All manual git commands in the release checklist can now be done via `task` commands for consistency and safety.

---

## Version Management

### Update API Version
```bash
# Get in-game: /script d(GetAPIVersion())
task version:api -- 101049
```
**What it does**: Updates `## APIVersion:` in manifest

---

### Bump Version
```bash
task version:bump -- patch    # Bug fixes (2.1.7 → 2.1.8)
task version:bump -- minor    # New features (2.1.7 → 2.2.0)
task version:bump -- major    # Breaking changes (2.1.7 → 3.0.0)
```
**What it does**: 
- Updates CHANGELOG.md with new version entry
- Shows next steps
- Note: Manifest uses `@project-version@` (Git-based versioning)

---

### Show Current Version
```bash
task version
```
**What it does**: Shows version from Git tags or commit SHA

---

## Git Operations

### Commit Changes
```bash
task git:commit -- "Release v2.1.8"
```
**What it does**: Stages all changes and commits with message

---

### Create Git Tag
```bash
# Option 1: Interactive (recommended - prompts before push)
task release:tag

# Option 2: Just create tag (manual push)
task git:tag
git push origin main --tags
```

**`task release:tag`** (Interactive):
- Prompts: "Create tag vX.X.X? (y/N)"
- Creates tag if confirmed
- Prompts: "Push tag to origin? (y/N)"
- Pushes if confirmed
- Safe - confirms before actions

**`task git:tag`** (Non-interactive):
- Creates tag immediately
- Does NOT push
- You must push manually

---

### Check Git Status
```bash
task git:status
```
**What it does**: Shows git status and uncommitted changes

---

## Validation & Testing

### Comprehensive Pre-Release Check
```bash
task release:check
```
**What it does**: Runs entire validation suite:
- ✅ Lint check (Luacheck)
- ✅ Syntax validation (LuaJIT)
- ✅ Manifest validation
- ✅ File structure check
- ✅ CHANGELOG validation
- ✅ README badge validation
- ✅ Git state check
- ✅ Build and ZIP validation

---

### Individual Validations
```bash
task lint                   # Luacheck only
task validate               # All validations
task validate:syntax        # Lua syntax only
task validate:manifest      # Manifest only
task validate:readme        # README badges
task validate:changelog     # CHANGELOG format
task test                   # Lint + validate
```

---

### Build & Package
```bash
task build                  # Full build with validation
task build:verify           # Verify package requirements
```

---

## Documentation

### Documentation Audit
```bash
task docs:audit             # Comprehensive health check
task docs:stale             # Find outdated files
task docs:orphans           # Find unreferenced files
task docs:duplicates        # Find duplicate content
task docs:links             # Check broken links
task docs:consolidate       # Interactive cleanup workflow
```

---

## Git Hooks

### Install Pre-Push Validation
```bash
task git:hooks:install      # Install hook
task git:hooks:test         # Test hook
task git:hooks:uninstall    # Remove hook
```
**What it does**: Automatically runs validation before pushing tags

---

## Complete Release Workflows

### Option 1: Fully Guided (Easiest)
```bash
task release
```
**Interactive workflow that:**
1. Prompts for version bump type
2. Reminds to update CHANGELOG
3. Runs validation
4. Commits changes
5. Creates and pushes tag

---

### Option 2: Step-by-Step Manual
```bash
# 1. Validate
task release:check

# 2. Bump version
task version:bump -- patch

# 3. Update CHANGELOG.md manually

# 4. Validate again
task test
task build

# 5. Commit and tag
git add .
task git:commit -- "Release vX.X.X"
task release:tag

# 6. Monitor GitHub Actions
```

---

### Option 3: Minimal (For Experienced Users)
```bash
task version:bump -- patch
# Edit CHANGELOG.md
task release:check
task git:commit -- "Release vX.X.X"
task release:tag
```

---

## Task Help

### Show Available Tasks
```bash
task                        # List all tasks
task --list-all             # List all tasks (detailed)
```

---

### Release-Specific Help
```bash
task help:release           # Release workflow help
task release:checklist      # Display release checklist
```

---

## Common Patterns

### Before Release
```bash
# Check everything
task release:check
task docs:audit

# If issues found, fix and re-check
task release:check
```

---

### During Release
```bash
# Follow guided workflow
task release

# Or manual
task version:bump -- patch
# Update CHANGELOG
task release:check
task git:commit -- "Release vX.X.X"
task release:tag
```

---

### After Release
```bash
# Verify
task build:verify
task docs:audit

# Check GitHub Actions
# (automatic - just monitor)
```

---

## Safety Features

### Interactive Confirmations
- ✅ `task release:tag` - Confirms before creating/pushing
- ✅ `task release` - Prompts at each step
- ✅ `task version:bump` - Shows what will change

### Validation Before Actions
- ✅ `task build` - Runs `task test` first
- ✅ `task release:check` - Comprehensive validation
- ✅ Git hooks - Validate before push (if installed)

### Non-Destructive
- ✅ Most tasks don't modify files
- ✅ Build tasks work in `build/` directory
- ✅ Tags can be deleted if needed

---

## Troubleshooting

### Task Not Found
```bash
# Install Task if needed
brew install go-task/tap/go-task

# Or use go install
go install github.com/go-task/task/v3/cmd/task@latest
```

---

### Validation Fails
```bash
# See what failed
task lint
task validate

# Fix issues, then re-run
task release:check
```

---

### Wrong Version
```bash
# Delete local tag
git tag -d v2.1.8

# Bump version again
task version:bump -- patch

# Re-create tag
task git:tag
```

---

### Need to Undo Tag Push
```bash
# Delete remote tag (BE CAREFUL)
git push --delete origin v2.1.8

# Delete local tag
git tag -d v2.1.8

# Only do this if release hasn't been published yet!
```

---

## Comparison: Manual vs Task

### Manual Approach
```bash
# Many manual commands
grep "## APIVersion:" CharacterMarkdown.addon
vim CharacterMarkdown.addon
luacheck src/
luajit -bl src/**/*.lua
lua scripts/validate-manifest.lua CharacterMarkdown.addon
# ... many more commands
git tag -a v2.1.8 -m "Release v2.1.8"
git push origin main --tags
```

### Task Approach
```bash
# Few simple commands
task version:api -- 101049
task release:check
task release:tag
```

---

## Benefits

✅ **Consistency**: Same commands every time  
✅ **Safety**: Validation before destructive actions  
✅ **Simplicity**: One command instead of many  
✅ **Documentation**: Built-in help (`task help:release`)  
✅ **Automation**: Complex workflows simplified  
✅ **Error Prevention**: Catches issues early  

---

## Related Documentation

- [RELEASE_CHECKLIST.md](../RELEASE_CHECKLIST.md) - Full release checklist
- [Taskfile.yaml](../Taskfile.yaml) - All task definitions
- [PUBLISHING.md](PUBLISHING.md) - Publishing guide
- [DOCUMENTATION_AUDIT_GUIDE.md](DOCUMENTATION_AUDIT_GUIDE.md) - Doc maintenance

---

**Last Updated**: 2025-01-21  
**Version**: 1.0

**Quick Start**: `task release` for guided release workflow

