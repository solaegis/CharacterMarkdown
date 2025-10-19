# Settings Defaults Not Applying - Issue Summary

## Problem Statement

On a clean install of the CharacterMarkdown addon (with no saved variables file), the settings panel shows all checkboxes as **OFF** instead of **ON** (the intended defaults). The text in the settings panel correctly says "All sections are enabled by default" but the actual checkbox controls display as unchecked/disabled.

## Environment

- **ESO Client**: Live server (macOS)
- **User has**: Advanced UI (AUI) addon installed (filters some debug messages)
- **Addon Version**: 2.1.0
- **LibAddonMenu**: v2.0 (LAM2) - Required for settings UI

## Root Cause Analysis

Through extensive debugging, we discovered:

1. **The addon IS loading** - Files execute, event handlers fire
2. **Settings initialization code DOES run** - We can see it in debug logs
3. **Values ARE being set initially** - `includeChampionPoints = true` is set in memory
4. **Values become `nil` shortly after** - Something clears them

### Key Discovery: ESO Saved Variables Behavior

```
[17:18] IMMEDIATE check after loop: includeChampionPoints = true
[17:18] CharacterMarkdownSettings table = userdata: 0x7fb77628a9e0
[17:18] CHARACTER MARKDOWN: Defaults set! includeChampionPoints = nil
```

**Critical Issue**: `CharacterMarkdownSettings` changes from a regular Lua `table` to ESO's special `userdata` type after we set values, and when it does, our values are lost.

### The ESO Saved Variables System

ESO's saved variables work as follows:

1. **Manifest Declaration**: `## SavedVariables: CharacterMarkdownSettings` in `.txt` file
2. **EVENT_ADD_ON_LOADED**: Fires when addon loads
3. **Saved Variables Creation**: ESO creates a special `userdata` object (NOT a regular Lua table)
4. **File Loading**: ESO loads values from disk AFTER event handler completes
5. **If no file exists**: ESO creates empty userdata object with no values

**Problem**: If we set values in a manually-created table `{}`, ESO later replaces it with its userdata object, wiping our defaults. If we wait for ESO's userdata to exist, it's already empty with no defaults.

## What We've Tried

### Approach 1: Manual Initialization with `nil` checks
```lua
CharacterMarkdownSettings = CharacterMarkdownSettings or {}
for key, defaultValue in pairs(defaults.CORE) do
    if CharacterMarkdownSettings[key] == nil then
        CharacterMarkdownSettings[key] = defaultValue
    end
end
```
**Result**: ❌ Values set but then cleared when ESO finalizes saved variables

### Approach 2: Using ZO_SavedVars
```lua
CharacterMarkdownSettings = ZO_SavedVars:NewAccountWide(
    "CharacterMarkdownSettings", 1, nil, defaultsTable
)
```
**Result**: ❌ All settings showed as OFF in UI

### Approach 3: Delayed Initialization
Tried delaying initialization by 100ms, 200ms, up to 1 second to let ESO finish
**Result**: ❌ ESO never creates the table (stays `nil` for all attempts)

### Approach 4: Manual Table Creation
Created `CharacterMarkdownSettings = {}` ourselves if ESO didn't create it
**Result**: ❌ Values set, then ESO replaces with empty userdata

### Approach 5: Panel First, Then Initialize
Register LAM panel first, then set defaults (thinking LAM might help finalize saved vars)
**Result**: ⏸️ In progress when we stopped

## Current State of Code

### Files Modified (with extensive debug logging still present)

1. **`src/Events.lua`**
   - Retries initialization up to 5 times with delays
   - Checks for saved variables readiness
   - Uses `CHAT_SYSTEM:AddMessage()` for debug (bypasses AUI filters)
   - Registers panel before initializing data

2. **`src/settings/Initializer.lua`**
   - Detects first run via `settingsVersion` field
   - Sets all defaults on first run
   - Has extensive debug logging with `zo_callLater()` and `CHAT_SYSTEM`
   - Logs immediate values vs. delayed values to show when they're cleared

3. **`src/settings/Panel.lua`**
   - One checkbox (`includeChampionPoints`) modified with nil-check in `getFunc`
   - Returns `true` if value is `nil` instead of returning `nil`
   - Other checkboxes still need same fix

4. **`Taskfile.yaml`**
   - Added `clean:savedvars` task to remove saved variables file

## Potential Solutions to Try Next

### Option 1: Fix ALL LAM Controls' getFunc
Modify every checkbox/control in `Panel.lua` to return defaults when values are `nil`:
```lua
getFunc = function() 
    return CharacterMarkdownSettings.includeChampionPoints ~= nil 
        and CharacterMarkdownSettings.includeChampionPoints 
        or true  -- default
end
```
**Pros**: UI will show correct values even if saved vars are empty
**Cons**: Doesn't fix underlying issue, just masks it; need to update ~20+ controls

### Option 2: Use LAM's Built-in Defaults System
Research how other addons properly integrate defaults with LAM. LAM might have a mechanism we're not using.

### Option 3: Force Saved Variables File Creation
Create a minimal saved variables file on disk that ESO will load:
```bash
echo 'CharacterMarkdownSettings = { settingsVersion = 1 }' > SavedVariables/CharacterMarkdown.lua
```
Then let initialization fill in missing values.

### Option 4: React to LAM's Reset Defaults Button
If the built-in defaults don't work automatically, at least ensure the "Reset All Settings" button works by properly calling `Initializer:ResetToDefaults()`.

### Option 5: Event-Based Approach
Listen for a later event (e.g., `EVENT_PLAYER_ACTIVATED`) when saved variables are definitely ready, instead of using `EVENT_ADD_ON_LOADED`.

### Option 6: Console Workflow Documentation
Document that users need to:
1. Load game once (creates empty saved vars)
2. Click "Reset All Settings" button
3. Settings now work correctly

## Debug Commands for Testing

```lua
-- Check if saved vars exist and their type
/script d("Type: " .. type(CharacterMarkdownSettings))

-- Check a specific value
/script d("includeChampionPoints = " .. tostring(CharacterMarkdownSettings.includeChampionPoints))

-- Manually set to see if UI updates
/script CharacterMarkdownSettings.includeChampionPoints = true

-- Check if globals set by LoadTest (now removed)
/script d(tostring(_G["CharacterMarkdown_LoadTest_Executed"]))
```

## Files to Review

- `src/settings/Defaults.lua` - Default values definition (correct)
- `src/settings/Initializer.lua` - Initialization logic (has debug code)
- `src/settings/Panel.lua` - LAM UI controls (needs getFunc fixes)
- `src/Events.lua` - Event handling and timing (has retry logic)
- `CharacterMarkdown.txt` - Manifest (SavedVariables declaration correct)

## Known Working Features

- ✅ Addon loads successfully
- ✅ `/markdown` command works
- ✅ Markdown generation works
- ✅ UI window displays
- ✅ Settings panel appears in Settings > Add-Ons
- ✅ Settings can be manually toggled and saved
- ✅ `clean:savedvars` task works

## The Mystery

Why doesn't ESO create `CharacterMarkdownSettings` automatically from the manifest declaration? Other addons work fine. Possible reasons:
- Manifest format issue (but it looks correct)
- File loading order
- Race condition in ESO's saved variables system
- Something specific to how LAM expects saved variables to work

## Recommended Next Steps

1. **Quick Fix**: Update all LAM controls' `getFunc` to handle `nil` → return defaults (Option 1)
2. **Research**: Look at other ESO addons' source code to see how they handle first-run defaults
3. **Test**: Try creating a minimal saved variables file manually to see if ESO loads it
4. **Simplify**: Remove all debug logging once working solution is found

## Clean Installation Test Procedure

```bash
# Clean slate
cd /Users/lvavasour/git/CharacterMarkdown
task clean:savedvars
task install:live

# In ESO
/reloadui
# Open Settings > Add-Ons > Character Markdown
# Check if boxes are ON (they should be but currently aren't)
```

## Context for AI Assistant

When resuming this issue:
- User is experienced developer, comfortable with Lua and ESO addon development
- Has full dev environment with Task runner
- Can test changes immediately in game
- Advanced UI addon filters basic `d()` debug calls - use `CHAT_SYSTEM:AddMessage()` instead
- Files have extensive debug logging that should be removed once issue is solved
- The Taskfile has helpful commands: `task install:live`, `task clean:savedvars`, etc.

