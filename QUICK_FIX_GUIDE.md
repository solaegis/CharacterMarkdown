# Quick Fix Guide - Champion Points Not Appearing

## Problem Identified

Your SavedVariables has `activeFilter = "None"` which disables ALL sections including Champion Points.

## Solution: Run These Commands in ESO

```
/reloadui
/markdown filter:clear
/markdown test
/markdown
```

### What Each Command Does

1. **`/reloadui`** - Reloads addon with new code that auto-clears dangerous filters
2. **`/markdown filter:clear`** - Manually clears any stuck filter (backup safety)
3. **`/markdown test`** - Runs comprehensive diagnostic showing:
   - ✓ Settings values (should show green for enabled sections)
   - ✓ No active filter warning
   - ✓ Champion Points data collected
   - ✓ All sections validated
4. **`/markdown`** - Generates your character profile with all sections

## Expected Output from `/markdown test`

```
=== CharacterMarkdown Diagnostic & Validation ===

[1/4] Settings Diagnostic
✓ CharacterMarkdownSettings exists
✓ CM.GetSettings() available

Critical Setting Values:
  includeChampionPoints = true   ← Green = enabled
  includeSkillBars = true
  includeEquipment = true
  ...

✓ Settings merge working correctly
✓ No active filter (using custom settings)  ← KEY: No filter!

[2/4] Data Collection Test
✓ Champion Points data collected
  Total: 732 | Spent: 655 | Available: 77
  Disciplines: 3
    Craft: 189 CP, 29 skills
    Warfare: 224 CP, 41 skills  
    Fitness: 242 CP, 48 skills

[3/4] Markdown Generation Test
✓ Markdown generated successfully
  Total size: 15,234 chars

[4/4] Validation Tests
✓ ALL TESTS PASSED! (15 validation, 8 sections)
```

## What Was Fixed

### 1. **FilterManager Initialization** (Bug #1 - ROOT CAUSE)
- **File:** `src/settings/Initializer.lua`
- **Problem:** FilterManager wasn't initialized in the main code path
- **Fix:** Added FilterManager initialization to both ZO_SavedVars and fallback paths
- **Result:** "None" filter is now auto-cleared on `/reloadui`

### 2. **Stale Settings in Generator** (Bug #2)
- **File:** `src/generators/Markdown.lua`
- **Problem:** Champion Points generator used stale settings
- **Fix:** Updated to use `CM.GetSettings()` for latest values
- **Result:** Generator now uses current settings consistently

### 3. **Force Clear Dangerous Filters** (Enhancement)
- **File:** `src/settings/FilterManager.lua`
- **Enhancement:** Added force-save when clearing "None"/"All" filters
- **Result:** Ensures dangerous filters are permanently cleared

### 4. **Manual Filter Clear Command** (New Feature)
- **File:** `src/Commands.lua`
- **Command:** `/markdown filter:clear`
- **Purpose:** Manually clear stuck filters as backup
- **Result:** Always have a way to recover from filter issues

### 5. **Comprehensive Test Command** (Enhancement)
- **File:** `src/Commands.lua`
- **Enhancement:** Merged `test` and `diag` into one comprehensive command
- **Phases:**
  1. Settings Diagnostic - checks settings and filter status
  2. Data Collection Test - verifies CP data can be collected
  3. Markdown Generation Test - tests generation succeeds
  4. Validation Tests - validates output quality
- **Result:** Single command to diagnose all issues

## Subcommand Pattern Documentation

Updated `.cursorrules` to document the `object:action` pattern:

### Pattern Rules
- **Format:** `command object:action`
- **Object First:** The main noun/object comes before the colon
- **Action Second:** The action/verb comes after the colon

### Examples
- `test:import-export` - perform **import-export** action on **test** system
- `filter:clear` - perform **clear** action on **filter**
- `profile:save` - perform **save** action on **profile**

### Commands Using Pattern
- `/markdown filter:clear` - Clear active filter
- `/cmdsettings test:import-export` - Run import/export tests

## Verification Steps

1. **Check Filter Status:**
   ```
   /markdown test
   ```
   Look for: `✓ No active filter (using custom settings)`

2. **Check Champion Points Setting:**
   ```
   /markdown test
   ```
   Look for: `includeChampionPoints = true` (should be green)

3. **Check CP Data Collection:**
   ```
   /markdown test
   ```
   Look for Phase 2 showing your CP totals and disciplines

4. **Generate Markdown:**
   ```
   /markdown
   ```
   Should see Champion Points section in the output window

## If Issues Persist

If Champion Points still don't appear after running the fix commands:

1. **Check raw SavedVariables:**
   ```bash
   grep "activeFilter\|includeChampionPoints" ~/Documents/Elder\ Scrolls\ Online/live/SavedVariables/CharacterMarkdown.lua
   ```
   Should show:
   - `activeFilter = ""`
   - `includeChampionPoints = true`

2. **Force clear in file:**
   If the file still shows `activeFilter = "None"`, manually edit:
   ```bash
   # Backup first
   cp ~/Documents/Elder\ Scrolls\ Online/live/SavedVariables/CharacterMarkdown.lua ~/Documents/Elder\ Scrolls\ Online/live/SavedVariables/CharacterMarkdown.lua.backup
   
   # Then edit and change:
   ["activeFilter"] = "None",  → ["activeFilter"] = "",
   ```

3. **Nuclear option - Reset settings:**
   ```
   /markdown reset
   ```
   This forces CP-only mode with all other sections disabled

## Technical Details

### Why "None" Filter is Dangerous

The "None" filter was designed for testing - it sets ALL boolean settings to `false`:

```lua
-- BuildNoneFilter() in FilterManager.lua
for key, value in pairs(defaults) do
    if type(value) == "boolean" then
        noneFilters[key] = false  -- Disables EVERYTHING
    end
end
```

This is why no sections appeared - everything was forcibly disabled!

### Why It Got Stuck

1. At some point, "None" filter was applied (maybe during testing)
2. It saved to `CharacterMarkdownSettings.lua`
3. Every time addon loaded, it read `activeFilter = "None"`
4. FilterManager wasn't being initialized to clear it
5. All sections stayed disabled

### The Fix Chain

1. **Initialization Fix:** FilterManager now runs in both code paths
2. **Auto-Clear:** "None" filter is detected and cleared on init
3. **Force Save:** Uses `SetValue()` to ensure it persists
4. **Manual Command:** `/markdown filter:clear` as backup
5. **Diagnostic:** `/markdown test` shows filter status clearly

## Files Modified

1. `src/settings/Initializer.lua` - Added FilterManager init to main path
2. `src/settings/FilterManager.lua` - Enhanced filter clearing with force save
3. `src/generators/Markdown.lua` - Fixed stale settings in CP generator
4. `src/Commands.lua` - Added `filter:clear` command and comprehensive test
5. `.cursorrules` - Documented subcommand pattern

## Summary

**Root Cause:** "None" filter stuck in SavedVariables  
**Fix:** FilterManager initialization + auto-clear + manual command  
**Result:** Champion Points and all sections now appear correctly

**Action Required:** Run `/reloadui` in ESO to apply fixes!

