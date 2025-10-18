# Development Guide

> **Complete guide for local development, testing, and debugging of CharacterMarkdown**

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [Local Setup](#local-setup)
- [Development Workflow](#development-workflow)
- [Testing](#testing)
- [Debugging](#debugging)
- [Code Style](#code-style)
- [Git Workflow](#git-workflow)

---

## Prerequisites

### Required Software

1. **Elder Scrolls Online** (latest version)
   - Install from Steam, Epic Games, or ESO website
   - Create/log in to ESO account

2. **Text Editor / IDE**
   - **VS Code** (recommended) with extensions:
     - [ESO Lua Language Server](https://github.com/CrazyKnightGR/ESO-LLS)
     - [Lua](https://marketplace.visualstudio.com/items?itemName=sumneko.lua)
   - **IntelliJ IDEA** with [EmmyLua plugin](https://plugins.jetbrains.com/plugin/9768-emmylua)
   - Any text editor (Sublime, Atom, etc.)

3. **Git**
   ```bash
   # macOS
   brew install git
   
   # Verify
   git --version
   ```

### Optional Tools

- **Task** (build automation)
  ```bash
  brew install go-task/tap/go-task
  ```

- **LibAddonMenu-2.0** (settings UI)
  - Download from [ESOUI](https://www.esoui.com/downloads/info7-LibAddonMenu.html)
  - Extract to ESO AddOns folder

---

## Local Setup

### 1. Clone Repository

```bash
cd ~/git
git clone https://github.com/YOUR_USERNAME/CharacterMarkdown.git
cd CharacterMarkdown
```

### 2. Locate ESO AddOns Folder

**macOS:**
```bash
~/Documents/Elder\ Scrolls\ Online/live/AddOns/
```

**Windows:**
```
C:\Users\USERNAME\Documents\Elder Scrolls Online\live\AddOns\
```

### 3. Symlink to Development Folder

**macOS/Linux:**
```bash
# Remove existing addon (if present)
rm -rf ~/Documents/Elder\ Scrolls\ Online/live/AddOns/CharacterMarkdown

# Create symlink
ln -s ~/git/CharacterMarkdown ~/Documents/Elder\ Scrolls\ Online/live/AddOns/CharacterMarkdown

# Verify
ls -la ~/Documents/Elder\ Scrolls\ Online/live/AddOns/ | grep CharacterMarkdown
```

**Windows (PowerShell as Administrator):**
```powershell
# Remove existing addon
Remove-Item -Recurse -Force "C:\Users\USERNAME\Documents\Elder Scrolls Online\live\AddOns\CharacterMarkdown"

# Create symlink
New-Item -ItemType SymbolicLink `
  -Path "C:\Users\USERNAME\Documents\Elder Scrolls Online\live\AddOns\CharacterMarkdown" `
  -Target "C:\Users\USERNAME\git\CharacterMarkdown"
```

### 4. Verify Installation

1. Launch ESO
2. Press **Escape** → **Settings** → **Add-Ons**
3. Look for "Character Markdown" in the list
4. Check the version matches your development version

---

## Development Workflow

### Hot Reload Pattern

ESO supports hot reloading without restarting the game:

```bash
# In ESO chat window, type:
/reloadui
```

**Workflow:**
1. Edit code in your IDE
2. Save file
3. Run `/reloadui` in ESO
4. Test changes immediately

### Typical Development Cycle

```mermaid
graph LR
    A[Edit Code] --> B[Save]
    B --> C[/reloadui in ESO]
    C --> D[Test Feature]
    D --> E{Working?}
    E -->|No| F[Check Errors]
    F --> A
    E -->|Yes| G[Commit]
    G --> H[Push to GitHub]
```

### File Structure

```
CharacterMarkdown/
├── CharacterMarkdown.txt       # Manifest
├── src/
│   ├── Main.lua               # Initialization
│   ├── UI.lua                 # Window management
│   ├── Collectors.lua         # Data collection
│   └── Markdown.lua           # Markdown generation
├── settings/
│   └── Settings.lua           # LAM integration
├── CharacterMarkdown.xml      # UI layout
└── docs/                      # Documentation
```

### Making Changes

**Example: Adding a new data collector**

1. **Add function to `src/Collectors.lua`:**
   ```lua
   function CM.Collectors.CollectNewData()
       local success, data = pcall(function()
           return {
               someValue = GetSomeESO_API_Value(),
               anotherValue = GetAnotherValue()
           }
       end)
       
       if not success then
           CM.Log("ERROR: Failed to collect new data: " .. tostring(data))
           return nil
       end
       
       return data
   end
   ```

2. **Call it in `GenerateMarkdown`:**
   ```lua
   local newData = CM.Collectors.CollectNewData()
   if newData then
       markdown = markdown .. "## New Section\n\n"
       markdown = markdown .. "Value: " .. newData.someValue .. "\n"
   end
   ```

3. **Test:**
   ```bash
   /reloadui
   /markdown github
   ```

4. **Verify output in EditBox**

---

## Testing

### Manual Testing

**In-Game Testing:**

1. **Open Addon:**
   ```lua
   /markdown
   ```

2. **Test Different Formats:**
   ```lua
   /markdown github
   /markdown discord
   /markdown vscode
   /markdown quick
   ```

3. **Check Error Output:**
   - Watch chat for any Lua errors
   - Check for missing data sections

**Test Cases Checklist:**

- [ ] Character data loads correctly
- [ ] Champion Points display accurately
- [ ] Equipment shows with set bonuses
- [ ] Skill bars display front/back correctly
- [ ] UESP links are valid (spot check 3-5)
- [ ] Copy to clipboard works (Ctrl+C)
- [ ] Settings panel opens and saves preferences
- [ ] `/markdown` command works without arguments
- [ ] Window closes with X button

### Test Different Characters

1. Create test characters with different:
   - Classes (Dragonknight, Sorcerer, Nightblade, etc.)
   - Levels (low-level, max-level, CP)
   - Equipment configurations (sets, no sets, mixed)

2. Log in to each character
3. Run `/markdown github`
4. Verify output accuracy

### Automated Testing (Future)

Currently, ESO addon testing is manual. Consider:
- Creating test fixtures for data collectors
- Mocking ESO API functions for unit tests
- Documenting expected outputs for regression testing

---

## Debugging

### Built-in Debug Functions

**Chat Output:**
```lua
-- Simple debug print
d("Debug message")

-- Variable inspection
d("Player name: " .. GetPlayerName())

-- Table inspection (requires helper)
CM.Debug.PrintTable(characterData)
```

**Conditional Debugging:**
```lua
if CM.Settings.debugMode then
    d("[DEBUG] " .. message)
end
```

### Common Debugging Patterns

**1. Check if Control Exists:**
```lua
local editBox = MyWindowEditBox
if not editBox then
    d("[ERROR] EditBox control not found!")
    return
end
d("[OK] EditBox found")
```

**2. Verify API Call Results:**
```lua
local success, result = pcall(function()
    return GetPlayerStat(STAT_HEALTH_MAX)
end)

if not success then
    d("[ERROR] Failed to get health stat: " .. tostring(result))
else
    d("[OK] Health: " .. result)
end
```

**3. Inspect String Content:**
```lua
local markdown = GenerateMarkdown("GITHUB")
d("Generated markdown length: " .. string.len(markdown))
d("First 200 chars: " .. string.sub(markdown, 1, 200))
d("Last 200 chars: " .. string.sub(markdown, -200))
```

**4. Profile Performance:**
```lua
local startTime = GetFrameTimeSeconds()
local markdown = GenerateMarkdown("GITHUB")
local endTime = GetFrameTimeSeconds()

d(string.format("GenerateMarkdown took %.3fms", (endTime - startTime) * 1000))
```

### Error Tracking

**Add Error Handlers:**
```lua
function CM.GenerateMarkdown(format)
    local success, result = pcall(function()
        -- Main logic here
        return actualMarkdownString
    end)
    
    if not success then
        d("[CharacterMarkdown] ERROR: " .. tostring(result))
        return "# Error\n\nFailed to generate markdown. Check chat for details."
    end
    
    return result
end
```

### LibDebugLogger Integration (Advanced)

For advanced debugging, use [LibDebugLogger](https://www.esoui.com/downloads/info2275-LibDebugLogger.html):

```lua
-- In your addon init:
local logger = LibDebugLogger("CharacterMarkdown")

-- Throughout code:
logger:Info("Player opened window")
logger:Warn("Champion Points data missing")
logger:Error("Failed to collect equipment data")

-- View logs:
-- /ldt CharacterMarkdown
```

---

## Code Style

### Lua Conventions

**Naming:**
```lua
-- Variables: camelCase
local playerName = GetPlayerName()
local characterData = {}

-- Constants: UPPER_SNAKE_CASE
local MAX_INVENTORY_SIZE = 200

-- Functions: PascalCase for public, camelCase for private
function CM.GenerateMarkdown(format)  -- Public
    local function formatSection(data)  -- Private
        return data
    end
end

-- Namespaces: PascalCase
CharacterMarkdown = CharacterMarkdown or {}
CM = CharacterMarkdown  -- Shorthand alias
```

**Indentation:**
- Use 4 spaces (no tabs)
- Align continued lines

**Comments:**
```lua
-- Single-line comments for brief explanations

--[[
    Multi-line comments for:
    - Function documentation
    - Complex logic explanations
    - TODOs and FIXMEs
]]

--- LuaDoc-style for public functions
--- @param format string The output format (GITHUB, DISCORD, etc.)
--- @return string The generated markdown
function CM.GenerateMarkdown(format)
    -- Implementation
end
```

### Formatting Patterns

**Error Handling:**
```lua
-- Always use pcall for API calls
local success, result = pcall(function()
    return esos_api_function()
end)

if not success then
    CM.Log("ERROR: " .. tostring(result))
    return defaultValue
end
```

**String Building:**
```lua
-- For large strings, use table.concat
local parts = {}
table.insert(parts, "## Header\n\n")
table.insert(parts, "Content line 1\n")
table.insert(parts, "Content line 2\n")
local markdown = table.concat(parts)

-- For small strings, concatenation is fine
local line = "**Name:** " .. playerName .. "\n"
```

**Table Iteration:**
```lua
-- ipairs for arrays
for i, value in ipairs(arrayTable) do
    -- Process value
end

-- pairs for dictionaries
for key, value in pairs(dictTable) do
    -- Process key-value
end
```

### Linting

The project uses [luacheck](https://github.com/mpeterv/luacheck):

```bash
# Install (requires Lua)
luarocks install luacheck

# Run linter
luacheck src/

# Or use Task
task lint
```

**Configuration:** `.luacheckrc` in project root

---

## Git Workflow

### Branch Strategy

```bash
# Main branches
main            # Production-ready code
develop         # Integration branch (if using git-flow)

# Feature branches
git checkout -b feature/new-collector
git checkout -b fix/clipboard-truncation
git checkout -b docs/api-reference
```

### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```bash
# Format:
<type>(<scope>): <subject>

# Types:
feat:     # New feature
fix:      # Bug fix
docs:     # Documentation
style:    # Formatting (no code change)
refactor: # Code restructure (no behavior change)
test:     # Adding tests
chore:    # Maintenance

# Examples:
git commit -m "feat(collectors): add mount skills data collection"
git commit -m "fix(markdown): correct UESP link encoding"
git commit -m "docs(api): add EditBox usage examples"
```

### Pull Request Process

1. **Create feature branch:**
   ```bash
   git checkout -b feature/my-new-feature
   ```

2. **Make changes and commit:**
   ```bash
   git add .
   git commit -m "feat: add new feature"
   ```

3. **Push to GitHub:**
   ```bash
   git push origin feature/my-new-feature
   ```

4. **Create PR on GitHub**

5. **Wait for CI checks to pass**

6. **Request review (if applicable)**

7. **Merge after approval**

### Pre-commit Hooks

The project uses pre-commit hooks:

```bash
# Install
pip install pre-commit
pre-commit install

# Manual run
pre-commit run --all-files
```

**Hooks configured:**
- Luacheck (linting)
- Trailing whitespace removal
- YAML validation

---

## Useful Commands

### In-Game Commands

```lua
/reloadui                    -- Reload all addons
/script d(GetAPIVersion())   -- Get current API version
/markdown                    -- Open addon window
/markdown github             -- Quick export
```

### Task Commands

```bash
task build                   -- Create release ZIP
task lint                    -- Run luacheck
task test                    -- Run tests (if implemented)
task clean                   -- Remove build artifacts
```

### Git Commands

```bash
git status                   -- Check current state
git log --oneline --graph    -- View commit history
git diff                     -- View changes
git checkout main            -- Switch to main branch
git pull origin main         -- Update from remote
git push origin feature-branch  -- Push feature branch
```

---

## Troubleshooting Development Issues

### Issue: Addon Not Loading

**Check:**
1. Manifest file exists: `CharacterMarkdown.txt`
2. Manifest format is correct (no syntax errors)
3. Symlink is valid: `ls -la ~/Documents/.../AddOns/`
4. ESO recognizes addon: Settings → Add-Ons

**Fix:**
```bash
# Recreate symlink
rm ~/Documents/.../AddOns/CharacterMarkdown
ln -s ~/git/CharacterMarkdown ~/Documents/.../AddOns/CharacterMarkdown
```

### Issue: Changes Not Reflected

**Check:**
1. Did you save the file?
2. Did you run `/reloadui`?
3. Is the file in the manifest?

**Fix:**
```bash
# Force reload
/quit  # Exit ESO completely
# Restart ESO
```

### Issue: Lua Errors

**Check:**
1. Look at chat for error messages
2. Check syntax (missing `end`, `then`, etc.)
3. Verify global variables exist

**Fix:**
- Use `pcall()` to catch errors
- Add `d()` statements to trace execution
- Check API version compatibility

### Issue: SavedVariables Not Saving

**Location:**
```
~/Documents/Elder Scrolls Online/live/SavedVariables/CharacterMarkdown.lua
```

**Check:**
1. Manifest declares SavedVariables
2. Settings structure matches expected format
3. Not an `end` error preventing save

**Fix:**
```bash
# Delete corrupted file
rm ~/Documents/.../SavedVariables/CharacterMarkdown.lua
# Restart ESO (regenerates with defaults)
```

---

## Additional Resources

- [ESO Lua Documentation](https://wiki.esoui.com/)
- [ESOUI Addon Portal](https://www.esoui.com/)
- [GitHub: esoui/esoui](https://github.com/esoui/esoui)
- [Lua 5.1 Reference Manual](https://www.lua.org/manual/5.1/)

---

**Last Updated:** January 2025