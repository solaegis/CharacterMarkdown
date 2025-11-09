# Development Guide

## Setup

### Prerequisites
```bash
# Install Task (automation tool)
brew install go-task/tap/go-task

# Install development dependencies
task install:deps
```

This installs: LuaJIT, LuaRocks, Luacheck, pre-commit

### Initialize Project
```bash
# Clone repository
git clone https://github.com/yourusername/CharacterMarkdown.git
cd CharacterMarkdown

# Install pre-commit hooks
pre-commit install

# Link to ESO addons folder
task install:dev
```

---

## Daily Workflow

### 1. Make Changes
Edit files in `src/` directory

### 2. Test In-Game
```bash
# Changes are automatically reflected (symlinked)
# In ESO: /reloadui
# Test: /markdown github
```

### 3. Validate
```bash
task lint    # Run Luacheck
task test    # Full validation
```

**In-Game Testing:**
```
/markdown test        # Run validation tests
/markdown unittest    # Run collector unit tests
```

See [Testing Guide](../TESTING_GUIDE.md) for detailed testing procedures.

### 4. Commit
```bash
git add .
git commit -m "feat: description of changes"
# Pre-commit hooks run automatically
```

---

## Release Process

### 1. Update Version
```bash
# Bump version (patch/minor/major)
task version:bump -- patch

# Edit CHANGELOG.md - add release notes
```

### 2. Test
```bash
task test              # Validate
task install:live      # Install to ESO
# Test thoroughly in-game
```

### 3. Release
```bash
git add .
git commit -m "Release v2.1.2"
git tag v2.1.2
git push origin main --tags
```

GitHub Actions automatically:
- Builds release ZIP
- Creates GitHub release
- Uploads to ESOUI

---

## Project Structure

```
CharacterMarkdown/
├── src/
│   ├── Core.lua              # Namespace initialization
│   ├── Commands.lua          # /markdown command
│   ├── Events.lua            # Event handlers
│   ├── Init.lua              # Final validation
│   ├── collectors/           # Data collection
│   │   ├── Character.lua     # Basic identity, DLC
│   │   ├── Combat.lua        # Stats, attributes
│   │   ├── Equipment.lua     # Worn gear, sets
│   │   ├── Skills.lua        # Skill bars, progression
│   │   └── ...
│   ├── generators/
│   │   ├── Markdown.lua      # Main orchestrator
│   │   └── sections/         # Individual sections
│   ├── links/                # UESP URL generation
│   ├── settings/             # LibAddonMenu integration
│   ├── ui/                   # Window handler
│   └── utils/                # Helper functions
├── scripts/                  # Build/validation
└── docs/                     # Documentation
```

---

## Key Concepts

### Namespace
All code in `CharacterMarkdown` (aliased as `CM`):
```lua
local CM = CharacterMarkdown

function CM.MyFunction()
    -- Implementation
end
```

### Error Handling
Wrap ESO API calls:
```lua
local success, result = pcall(GetPlayerStat, STAT_HEALTH_MAX)
if not success then
    CM.DebugPrint("ERROR", result)
    return defaultValue
end
```

### Debug System
```lua
CM.DebugPrint(category, message)  -- Silent unless LibDebugLogger
CM.Info(message)                   -- Logged only
CM.Warn(message)                   -- Logged only
CM.Error(message)                  -- Shows in chat
```

### Performance
Cache global functions:
```lua
-- In Core.lua
CM.cached = {
    EVENT_MANAGER = EVENT_MANAGER,
    string_format = string.format,
    table_insert = table.insert,
}

-- In modules
local string_format = CM.cached.string_format
```

---

## Common Tasks

### Add New Collector
1. Create `src/collectors/NewFeature.lua`
2. Add to manifest load order
3. Export function: `CM.collectors.CollectNewFeature`
4. Call from `generators/Markdown.lua`

### Add New Format
1. Edit `generators/Markdown.lua`
2. Add format handling in `GenerateMarkdown()`
3. Create section generator in `generators/sections/`
4. Update `Commands.lua` for new format alias

### Add Setting
1. Edit `settings/Defaults.lua` - add default value
2. Edit `settings/Panel.lua` - add UI control
3. Use in code: `CharacterMarkdownSettings.yourSetting`

---

## Testing

### In-Game Testing
```bash
task install:live    # Copy to ESO
# Launch ESO
# Test all formats: /markdown github, /markdown discord, etc.
# Test settings persistence: ESC → Settings → Add-Ons
# /reloadui and verify settings saved
```

### Validation Commands
```
/markdown test        # Run markdown validation tests
/markdown unittest    # Run collector unit tests
```

### Automated Testing
```bash
task lint           # Luacheck
task validate       # Manifest + structure
task test           # All checks
```

For comprehensive testing procedures, see the [Testing Guide](../TESTING_GUIDE.md).

### Pre-Release Checklist
- [ ] All formats generate correctly
- [ ] Settings persist after /reloadui
- [ ] No errors in chat on load
- [ ] Window displays and copy works
- [ ] UESP links functional
- [ ] Works with other addons
- [ ] Version updated in manifest
- [ ] CHANGELOG.md updated

---

## Build System

### Taskfile Commands
```bash
task                    # Show all tasks
task lint              # Run Luacheck
task test              # Full validation
task build             # Create release ZIP
task install:live      # Install to ESO Live
task install:pts       # Install to ESO PTS
task version           # Show current version
task version:bump      # Bump version
task release:tag       # Tag and push release
```

### GitHub Actions
Workflow: `.github/workflows/release.yaml`

Triggers on: Git tags matching `v*`

Steps:
1. Checkout code
2. Run Luacheck
3. Validate manifest
4. Update versions
5. Create ZIP
6. Create GitHub release
7. Upload to ESOUI

---

## Code Style

### Naming
```lua
local variableName        -- camelCase
local CONSTANT_NAME       -- UPPER_SNAKE_CASE
function PublicFunction() -- PascalCase
local function private()  -- camelCase
```

### Formatting
- 4 spaces (no tabs)
- Blank line before comments
- No trailing whitespace

### Comments
```lua
-- Brief explanation

--[[
    Multi-line for:
    - Complex logic
    - Function documentation
]]

-- Explain WHY, not WHAT
local cp = GetPlayerChampionPointsEarned()  -- No comment needed
```

### Commit Messages
```
type(scope): subject

Types: feat, fix, docs, refactor, test, chore
Scopes: collectors, generators, ui, settings

Examples:
feat(collectors): add mount training data
fix(ui): prevent window from closing on copy
docs(readme): update installation instructions
```

---

## Debugging

### In-Game Debug
```lua
CM.DebugPrint("CATEGORY", "Message:", variable)
-- Only visible with LibDebugLogger installed
```

### Chat Output (Temporary)
```lua
d("Debug:", value)  -- Use sparingly, only during development
```

### Error Inspection
```
/script d(GetErrorInfo())          -- Get last error
/luaerror on                       -- Show Lua errors in chat
```

---

## Publishing

### Initial Setup (One-Time)
1. Create ESOUI account
2. Apply for author status
3. Manual upload first version
4. Note addon ID from URL
5. Generate API token
6. Add token to GitHub Secrets: `ESOUI_API_KEY`
7. Add addon ID to workflow: `addon_id: 'XXXX'`

### Subsequent Releases
All automated via GitHub Actions (tag and push)

---

## Resources

### ESO Development
- **API Docs**: https://wiki.esoui.com/
- **Source Code**: https://github.com/esoui/esoui
- **ESOUI Forums**: https://www.esoui.com/forums/

### Tools
- **Task**: https://taskfile.dev/
- **Luacheck**: https://github.com/mpeterv/luacheck
- **pre-commit**: https://pre-commit.com/

### Community
- **GitHub Issues**: Bug reports and features
- **ESOUI Comments**: User feedback
- **Discord**: Real-time help (if available)

---

## Troubleshooting

**Luacheck errors**: Fix or add to `.luacheckrc`  
**Pre-commit fails**: Run manually: `pre-commit run --all-files`  
**Build fails**: Check manifest syntax  
**ESOUI upload fails**: Verify API token and addon ID  
**Settings not saving**: Ensure SavedVariables declared in manifest

---

**Happy Developing!** 🚀
