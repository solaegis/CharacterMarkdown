# Code Review: Section Output Issues

**Date:** November 10, 2025
**Scope:** Investigation of why sections (including Champion Points) are not being output as expected

## Critical Bugs Found

### 🔴 Bug #1: FilterManager Not Initialized in Main Code Path

**Severity:** CRITICAL  
**Location:** `src/settings/Initializer.lua:TryZOSavedVars()` (lines 83-94)

**Problem:**
The `FilterManager:Initialize()` was only called in the fallback initialization path (line 136) but **NOT** in the main `TryZOSavedVars()` path. This creates a critical initialization bug:

1. When ESO loads the addon, it uses `ZO_SavedVars` (the normal path)
2. Default settings include `activeFilter = "None"` (from `Defaults.lua` line 96)
3. The "None" filter is designed to turn **ALL boolean settings to false**
4. Without `FilterManager:Initialize()` being called, the "None" filter remains active
5. This causes `includeChampionPoints` and all other section toggles to be forced to `false`

**Impact:**
- All sections would be disabled by default
- User changes to settings in the UI would not persist between reloads
- The "None" filter would reapply on every addon load

**Fix Applied:**
Added FilterManager initialization to the `TryZOSavedVars()` function at lines 92-97:

```lua
-- Initialize filter manager (CRITICAL: must be done after settings are loaded)
if not CM.Settings.FilterManager then
    local FilterManager = require("src/settings/FilterManager")
    CM.Settings.FilterManager = FilterManager
    CM.Settings.FilterManager:Initialize()
end
```

This ensures the "None" filter is cleared to empty string (line 378-380 in FilterManager.lua):
```lua
if not CM.settings.activeFilter or CM.settings.activeFilter == "None" or CM.settings.activeFilter == "All" then
    CM.settings.activeFilter = ""  -- Empty means no filter applied
end
```

---

### ⚠️ Bug #2: Stale Settings in Section Registry

**Severity:** HIGH  
**Location:** `src/generators/Markdown.lua` (lines 486-529)

**Problem:**
The Champion Points section generator was using the `settings` parameter passed to `GetSectionRegistry()` instead of calling `CM.GetSettings()` to get the latest settings. The condition function correctly called `CM.GetSettings()` at runtime, but the generator used the stale `settings` parameter.

**Impact:**
- If settings changed between registry creation and generator execution, the generator would use outdated values
- This could cause mismatches between condition evaluation and generation

**Fix Applied:**
Updated the generator function to also use `CM.GetSettings()` to ensure both condition and generator use the same up-to-date values (lines 498-520).

---

## Architecture Analysis

### Settings Flow

1. **Initialization** (`Events.lua` → `Settings.Initializer`)
   - `TryZOSavedVars()` or `InitializeFallback()` loads settings from SavedVariables
   - Merges with defaults from `Defaults.lua`
   - **Now correctly initializes FilterManager in both paths**

2. **Settings Access** (`Core.lua:CM.GetSettings()`)
   - Returns merged settings (SavedVariables + Defaults)
   - Ensures no nil values - every setting is true or false
   - Handles special cases where raw `CharacterMarkdownSettings` needs to be checked

3. **Filter System** (`FilterManager.lua`)
   - Can apply filter presets that override multiple settings at once
   - **Critical:** The "None" filter sets all booleans to false
   - **Critical:** FilterManager must be initialized to clear dangerous defaults

4. **Section Registry** (`Markdown.lua:GetSectionRegistry()`)
   - Builds array of sections with conditions and generators
   - Champion Points section now correctly uses latest settings in both condition and generator

### Potential Remaining Issues

While the critical bugs have been fixed, there are some areas that could benefit from cleanup:

1. **Inconsistent Settings Access:**
   - Most sections use the `settings` parameter passed to registry
   - Champion Points section now uses `CM.GetSettings()` at runtime
   - **Recommendation:** Consider making all sections use runtime settings evaluation for consistency

2. **Defensive Sync in GenerateMarkdown:**
   - Lines 675-692 in `Markdown.lua` manually sync critical settings from raw `CharacterMarkdownSettings`
   - This suggests a lack of confidence in `CM.GetSettings()`
   - **Recommendation:** Remove this defensive code once the FilterManager fix is verified to work

3. **Filter Default Value:**
   - `activeFilter = "None"` is a dangerous default (line 96 in `Defaults.lua`)
   - **Recommendation:** Change default to `activeFilter = ""` to avoid confusion

---

## Testing Recommendations

### Test Case 1: Fresh Install
1. Delete SavedVariables
2. Reload addon
3. Verify all sections appear in default output
4. Verify `includeChampionPoints = true` in chat logs

### Test Case 2: Settings Persistence
1. Enable Champion Points in UI
2. Save settings
3. Reload addon
4. Generate markdown
5. Verify Champion Points section appears

### Test Case 3: Filter Application
1. Apply "Defaults" filter
2. Generate markdown
3. Verify sections appear as expected per filter
4. Clear filter (set to empty)
5. Verify personal settings are restored

---

## Files Modified

1. **src/generators/Markdown.lua**
   - Fixed Champion Points generator to use `CM.GetSettings()`
   - Ensures latest settings are used in both condition and generator

2. **src/settings/Initializer.lua**
   - Added FilterManager initialization to `TryZOSavedVars()` path
   - Ensures dangerous filter defaults are cleared on startup

---

## Summary

The root cause of sections not appearing was **Bug #1**: the FilterManager was not being initialized in the main code path, causing the "None" filter to remain active and turn off all sections. This has been fixed by ensuring `FilterManager:Initialize()` is called in both the ZO_SavedVars path and the fallback path.

The secondary issue (**Bug #2**) was the Champion Points generator using stale settings instead of calling `CM.GetSettings()` for the latest values. This has been fixed by updating the generator to use `CM.GetSettings()` consistently with the condition function.

After installing the updated addon and reloading ESO, all sections should now appear correctly when their settings are enabled.

