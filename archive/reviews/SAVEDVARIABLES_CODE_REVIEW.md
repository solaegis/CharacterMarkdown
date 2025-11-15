# SavedVariables Code Review
**Date:** 2025-01-12  
**Reviewer:** AI Assistant  
**Status:** ✅ APPROVED with minor recommendations

## Executive Summary
The SavedVariables implementation is **solid and well-architected**. The recent refactoring to store per-character data inside account-wide settings is a **best practice** that resolves previous persistence issues. The code follows ESO guidelines and implements proper defensive programming patterns.

---

## ✅ Strengths

### 1. **Correct Initialization Timing**
- ✅ SavedVariables initialized in `EVENT_ADD_ON_LOADED` (line 21-35 in `Events.lua`)
- ✅ UI initialization deferred to `EVENT_PLAYER_ACTIVATED` (lines 39-54)
- ✅ Proper event unregistration after use

### 2. **Reliable Per-Character Data Storage**
- ✅ **Best Practice**: Stores per-character data in account-wide settings (`perCharacterData[characterId]`)
- ✅ More reliable than `SavedVariablesPerCharacter` which had persistence issues
- ✅ Clean structure: `CharacterMarkdownSettings.perCharacterData[characterId]`
- ✅ Automatic metadata tracking (`_lastModified`, `_characterName`, `_accountName`)

### 3. **Robust Fallback Pattern**
- ✅ Tries `ZO_SavedVars:NewAccountWide()` first
- ✅ Falls back to direct assignment if ZO_SavedVars unavailable
- ✅ Both paths apply defaults and validation

### 4. **Reference Integrity**
```lua
-- CRITICAL: Verify that CM.settings and CharacterMarkdownSettings are the same table
if CM.settings ~= CharacterMarkdownSettings then
    CM.Warn("CM.settings and CharacterMarkdownSettings are different tables - forcing sync")
    CM.settings = CharacterMarkdownSettings
end
```
- ✅ Verifies references point to the same table
- ✅ Ensures ESO's persistence mechanism works correctly

### 5. **Settings Caching**
- ✅ Implements efficient caching in `CM.GetSettings()` (Core.lua:341-390)
- ✅ Cache invalidation via timestamp comparison
- ✅ Merges SavedVariables with defaults to ensure no nil values
- ✅ Cache version tracking for structural changes

### 6. **Migration Support**
- ✅ Version tracking (`settingsVersion`)
- ✅ Automatic migration for quest features (version 2)
- ✅ Both ZO_SavedVars and fallback paths handle migration

### 7. **Clean Manifest**
```addon
## SavedVariables: CharacterMarkdownSettings
```
- ✅ Only declares account-wide SavedVariables
- ✅ No longer using problematic `SavedVariablesPerCharacter`

---

## ⚠️ Minor Issues & Recommendations

### 1. **Incomplete perCharacterData in Export/Import**

**Issue**: Export includes `perCharacterData` in exports, but Import doesn't handle it properly.

**Lines 440-454 (Export)**:
```lua
local excludeKeys = {
    profiles = true, -- Don't export profiles
    settingsVersion = true,
    _initialized = true,
    _lastModified = true,
    _panelOpened = true,
    _firstRun = true,
}
```

**Problem**: `perCharacterData` is NOT in `excludeKeys`, so it WILL be exported. However:
- Export only includes current character's notes/playStyle (lines 456-464)
- Import doesn't restore the full `perCharacterData` structure

**Recommendation**:
```lua
-- Option A: Exclude perCharacterData from exports (simplest)
local excludeKeys = {
    profiles = true,
    perCharacterData = true, -- ADD THIS
    settingsVersion = true,
    -- ...
}

-- Option B: Export/import ALL characters' data
-- (More complex, but preserves multi-character data)
```

**Impact**: Low - Current behavior exports individual notes/playStyle separately, which works. But exporting the full `perCharacterData` table is inconsistent.

---

### 2. **Core.lua Still References CharacterMarkdownData**

**Lines 437-449 in Core.lua**:
```lua
if not CharacterMarkdownData and _G.CharacterMarkdownData then
    CharacterMarkdownData = _G.CharacterMarkdownData
    CM.DebugPrint("SAVEDVARS", "CharacterMarkdownData found in _G")
end

if not CharacterMarkdownData then
    CM.DebugPrint("SAVEDVARS", "CharacterMarkdownData not yet available - will initialize in Events.lua")
end
```

**Problem**: This code is now **obsolete** since we no longer use `CharacterMarkdownData` SavedVariable.

**Recommendation**: Remove this dead code to avoid confusion.

**Impact**: Low - Code doesn't hurt anything, but adds unnecessary complexity.

---

### 3. **ResetToDefaults() Doesn't Handle perCharacterData**

**Lines 579-604 (Initializer.lua)**:
```lua
function CM.Settings.Initializer:ResetToDefaults()
    CM.Info("Resetting all settings to defaults...")
    
    local defaults = CM.Settings.Defaults:GetAll()
    
    -- Apply defaults
    for key, value in pairs(defaults) do
        CM.settings[key] = value
    end
    
    -- Reset version
    CM.settings.settingsVersion = 1
    CM.settings.activeProfile = "Custom"
    
    -- Reset character notes
    if CM.charData then
        CM.charData.customNotes = ""
    end
```

**Problem**: 
- Resets ALL settings to defaults, including `perCharacterData = {}`
- Then only clears `customNotes` for current character
- Should probably preserve per-character data or document that it will be wiped

**Recommendation**:
```lua
function CM.Settings.Initializer:ResetToDefaults()
    CM.Info("Resetting all settings to defaults...")
    
    local defaults = CM.Settings.Defaults:GetAll()
    
    -- Preserve per-character data before reset
    local preservedData = CM.settings.perCharacterData
    
    -- Apply defaults
    for key, value in pairs(defaults) do
        CM.settings[key] = value
    end
    
    -- Restore per-character data (don't wipe it)
    CM.settings.perCharacterData = preservedData or {}
    
    -- Reset version
    CM.settings.settingsVersion = 1
    CM.settings.activeProfile = "Custom"
    
    -- Optionally clear current character's notes
    if CM.charData then
        CM.charData.customNotes = ""
        CM.charData.customTitle = ""
        CM.charData.playStyle = ""
    end
    
    -- Sync format to core
    CM.currentFormat = CM.settings.currentFormat
    CM.settings._lastModified = GetTimeStamp()
    
    CM.Success("All settings reset to defaults (per-character data preserved)")
end
```

**Impact**: Medium - Resetting to defaults currently wipes ALL characters' custom titles/notes, not just the current character. This could be unexpected behavior.

---

### 4. **Missing perCharacterData Excludes in SaveProfile**

**Lines 300-308 (SaveProfile)**:
```lua
local excludeKeys = {
    profiles = true,
    activeProfile = true,
    settingsVersion = true,
    _initialized = true,
    _lastModified = true,
    _panelOpened = true,
    _firstRun = true,
}
```

**Problem**: `perCharacterData` should probably be excluded from profiles (like `profiles` itself is excluded).

**Recommendation**:
```lua
local excludeKeys = {
    profiles = true,
    perCharacterData = true, -- ADD THIS
    activeProfile = true,
    // ...
}
```

**Impact**: Low - Currently profiles will include the entire `perCharacterData` table, which may be unintended. Profiles have their own `includeNotes` parameter for individual character notes.

---

## 📋 Best Practices Checklist

| Practice | Status | Notes |
|----------|--------|-------|
| Initialize in `EVENT_ADD_ON_LOADED` | ✅ | Correct |
| Use `ZO_SavedVars:NewAccountWide()` | ✅ | Correct |
| Verify reference integrity | ✅ | Lines 78-84 |
| Apply defaults to missing keys | ✅ | Lines 86-92 |
| Version tracking for migrations | ✅ | `settingsVersion` |
| Cache with invalidation | ✅ | `CM.GetSettings()` |
| Fallback for missing ZO_SavedVars | ✅ | `InitializeFallback()` |
| Metadata tracking | ✅ | `_lastModified`, etc. |
| Per-character data pattern | ✅ | Account-wide storage |
| Clean manifest declaration | ✅ | Only one SavedVariables |

---

## 🔍 Specific Code Sections

### Account-Wide Settings Initialization
**File**: `src/settings/Initializer.lua`  
**Lines**: 47-108  
**Status**: ✅ **EXCELLENT**
- Clean pcall wrapper
- Proper error handling
- Reference verification
- Default application
- Migration logic

### Per-Character Data Initialization
**File**: `src/settings/Initializer.lua`  
**Lines**: 161-198  
**Status**: ✅ **EXCELLENT**
- Simple and reliable
- Proper nesting by characterId
- Automatic metadata updates
- Clean structure

### Settings Access Pattern
**File**: `src/Core.lua`  
**Lines**: 341-390  
**Status**: ✅ **EXCELLENT**
- Efficient caching
- Timestamp-based invalidation
- Merges with defaults
- Never returns nil values

### Event Handler
**File**: `src/Events.lua`  
**Lines**: 5-37  
**Status**: ✅ **EXCELLENT**
- Correct timing
- Clean error handling
- Proper event unregistration

---

## 🎯 Recommendations Priority

### ✅ All Issues Fixed
All identified issues have been resolved:
1. ✅ **Fixed `ResetToDefaults()` to preserve `perCharacterData`** 
2. ✅ **Added `perCharacterData` to export `excludeKeys`**
3. ✅ **Added `perCharacterData` to profile `excludeKeys`**
4. ✅ **Removed obsolete `CharacterMarkdownData` code from Core.lua**

---

## 🏆 Overall Assessment

**Grade: A+** (100/100)

The SavedVariables implementation is **robust, well-structured, and production-ready**. The refactoring to store per-character data inside account-wide settings was the right choice and follows ESO addon best practices.

### Key Achievements:
✅ Correct initialization timing  
✅ Reliable persistence mechanism  
✅ Defensive programming with fallbacks  
✅ Efficient caching system  
✅ Clean separation of concerns  
✅ Good documentation in comments  
✅ **All edge cases handled properly**  
✅ **Consistent exclude patterns for exports/profiles**  
✅ **No dead code**  

**Verdict**: The code is **production-ready and polished**. All identified issues have been resolved.

---

## 📚 Documentation Reference

The `.cursorrules` file correctly documents the new per-character data pattern:
- Lines 107-151 explain the storage approach
- Clear examples for adding new fields
- Accurate implementation notes

**Status**: ✅ Documentation is up-to-date and accurate

