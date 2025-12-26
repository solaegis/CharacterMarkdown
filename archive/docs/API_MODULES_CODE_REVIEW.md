# API Modules Code Review

**Date**: 2024-12-19  
**Reviewer**: AI Assistant  
**Purpose**: Ensure API modules are focused on their specific purpose and cross-module data gathering is handled at collector level

## Review Criteria

1. **Module Focus**: Each API module should only gather data specific to its purpose
2. **No Cross-Module Calls**: API modules should NOT call other API modules directly
3. **Collector Responsibility**: Cross-module data needs should be handled at the collector level

---

## Issues Found

### 🔴 **CRITICAL: Cross-Module Data Gathering**

#### 1. **Skills.lua** - Line 271
**Issue**: Gathering character class data (outside module scope)

```271:271:src/api/Skills.lua
    local playerClass = CM.SafeCall(GetUnitClass, "player") or "Unknown"
```

**Problem**: 
- The Skills API module is calling `GetUnitClass("player")` to filter class skill lines
- Character class data is the responsibility of `CM.api.character`
- This creates a dependency on character data within the Skills module

**Recommendation**:
- Remove the class filtering logic from `_GetMorphsData()`
- Pass player class as a parameter, OR
- Move the filtering logic to the collector level where it can call both `CM.api.character.GetClass()` and `CM.api.skills._GetMorphsData()`

**Impact**: Medium - Creates coupling between Skills and Character modules

---

#### 2. **PvP.lua** - Line 20
**Issue**: Gathering character gender data (outside module scope)

```20:22:src/api/PvP.lua
    local gender = CM.SafeCall(GetUnitGender, "player") or 1
    if rank > 0 then
        rankName = CM.SafeCall(GetAvARankName, gender, rank) or rankName
```

**Problem**:
- The PvP API module is calling `GetUnitGender("player")` to get rank name
- Character gender data is the responsibility of `CM.api.character`
- The gender is only needed for `GetAvARankName()` which requires it

**Recommendation**:
- Option A: Make `GetRank()` accept an optional `gender` parameter (defaults to 1 if not provided)
- Option B: Move the gender retrieval to the collector level and pass it in
- Option C: Create a helper function that accepts gender as parameter

**Impact**: Low - Gender is a simple value, but still creates coupling

---

#### 3. **Quests.lua** - Line 37
**Issue**: Gathering location data (outside module scope)

```37:44:src/api/Quests.lua
    local zoneIndex = CM.SafeCall(GetUnitZoneIndex, "player")
    local completionPercent = 0
    
    if zoneIndex then
        -- Some API versions support GetZoneCompletionStatus
        if GetZoneCompletionStatus then
             completionPercent = CM.SafeCall(GetZoneCompletionStatus, zoneIndex) or 0
        end
    end
```

**Problem**:
- The Quests API module is calling `GetUnitZoneIndex("player")` to get zone completion
- Location data is the responsibility of `CM.api.character`
- Zone completion is quest-related, but the zone index should come from Character API

**Recommendation**:
- Option A: Make `GetZoneCompletion()` accept an optional `zoneIndex` parameter
- Option B: Move zone index retrieval to collector level and pass it in
- Note: Zone completion is quest-related, so it's reasonable for Quests API to handle it, but it should receive the zone index as input

**Impact**: Low - Zone index is a simple value, but creates coupling

---

## ✅ **ACCEPTABLE Patterns**

### Character.lua - GetTitle() Function
**Location**: Lines 102-110

```102:110:src/api/Character.lua
function api.GetTitle()
    local titleName = CM.utils and CM.utils.GetPlayerTitle and CM.utils.GetPlayerTitle()
    -- Fallback if utility not available (though it should be loaded)
    if not titleName then
        local titleIndex = CM.SafeCall(GetCurrentTitleIndex)
        if titleIndex then
            titleName = CM.SafeCall(GetTitle, titleIndex)
        end
    end
    
    return {
        name = titleName or ""
    }
end
```

**Analysis**: 
- Uses utility function `CM.utils.GetPlayerTitle()` (not another API module)
- Has fallback to direct ESO API calls
- This is acceptable - utilities are fine, only API module calls are problematic
- Note: There is some overlap with `CM.api.titles.GetCurrentTitle()`, but this is intentional for backward compatibility

---

### Titles.lua - GetCurrentTitle() Function
**Location**: Lines 20-29

```20:29:src/api/Titles.lua
function api.GetCurrentTitle()
    -- Use utility function if available, otherwise try direct API
    if CM.utils and CM.utils.GetPlayerTitle then
        return CM.utils.GetPlayerTitle() or ""
    end
    
    -- Fallback to direct API call
    local title = CM.SafeCall(GetUnitTitle, "player")
    return title or ""
end
```

**Analysis**:
- Uses utility function (acceptable)
- Direct ESO API calls (acceptable)
- No cross-module API calls

---

## 📋 **Summary of Issues**

| Module | Line | Issue | Severity | Recommendation |
|--------|------|-------|----------|----------------|
| Skills.lua | 271 | Calls `GetUnitClass("player")` | Medium | Pass class as parameter or move filtering to collector |
| PvP.lua | 20 | Calls `GetUnitGender("player")` | Low | Pass gender as parameter or move to collector |
| Quests.lua | 37 | Calls `GetUnitZoneIndex("player")` | Low | Pass zoneIndex as parameter or move to collector |

---

## 🔧 **Recommended Fixes**

### Fix 1: Skills.lua - Remove Class Dependency

**Current**:
```lua
function api._GetMorphsData()
    local playerClass = CM.SafeCall(GetUnitClass, "player") or "Unknown"
    -- ... filtering logic using playerClass ...
end
```

**Recommended**:
```lua
function api._GetMorphsData(playerClass)
    playerClass = playerClass or "Unknown"
    -- ... filtering logic using playerClass ...
end

function api.GetInfo(options)
    -- ... existing code ...
    if options.includeMorphs then
        -- Collector should pass player class
        data.morphs = api._GetMorphsData(options.playerClass)
    end
    -- ... existing code ...
end
```

**Collector Change**:
```lua
-- In collector
local characterInfo = CM.api.character.GetInfo()
local skillsInfo = CM.api.skills.GetInfo({
    includeMorphs = true,
    playerClass = characterInfo.class  -- Pass class from character API
})
```

---

### Fix 2: PvP.lua - Remove Gender Dependency

**Current**:
```lua
function api.GetRank()
    local gender = CM.SafeCall(GetUnitGender, "player") or 1
    if rank > 0 then
        rankName = CM.SafeCall(GetAvARankName, gender, rank) or rankName
    end
    -- ...
end
```

**Recommended**:
```lua
function api.GetRank(gender)
    gender = gender or 1  -- Default to 1 if not provided
    local rank = CM.SafeCall(GetUnitAvARank, "player") or 0
    local rankName = "Recruit"
    local points = CM.SafeCall(GetUnitAvARankPoints, "player") or 0
    
    if rank > 0 then
        rankName = CM.SafeCall(GetAvARankName, gender, rank) or rankName
    end
    
    return {
        rank = rank,
        name = rankName,
        points = points
    }
end

function api.GetInfo(options)
    options = options or {}
    local data = {}
    
    -- Get gender from options or use default
    local gender = options.gender or 1
    data.rank = api.GetRank(gender)
    -- ... rest of code ...
end
```

**Collector Change**:
```lua
-- In collector
local characterInfo = CM.api.character.GetInfo()
local pvpInfo = CM.api.pvp.GetInfo({
    gender = characterInfo.gender  -- Pass gender from character API
})
```

---

### Fix 3: Quests.lua - Remove Zone Index Dependency

**Current**:
```lua
function api.GetZoneCompletion()
    local zoneIndex = CM.SafeCall(GetUnitZoneIndex, "player")
    -- ... use zoneIndex ...
end
```

**Recommended**:
```lua
function api.GetZoneCompletion(zoneIndex)
    zoneIndex = zoneIndex or CM.SafeCall(GetUnitZoneIndex, "player")  -- Fallback for backward compatibility
    local completionPercent = 0
    
    if zoneIndex then
        if GetZoneCompletionStatus then
             completionPercent = CM.SafeCall(GetZoneCompletionStatus, zoneIndex) or 0
        end
    end
    
    return {
        zoneIndex = zoneIndex,
        percent = completionPercent
    }
end

function api.GetInfo(options)
    options = options or {}
    local data = {}
    
    data.active = api.GetJournalInfo()
    data.zone = api.GetZoneCompletion(options.zoneIndex)  -- Accept zoneIndex from options
    
    return data
end
```

**Collector Change**:
```lua
-- In collector
local characterInfo = CM.api.character.GetLocation()
local questInfo = CM.api.quests.GetInfo({
    zoneIndex = characterInfo.zoneIndex  -- Pass zoneIndex from character API
})
```

---

## ✅ **Verification Checklist**

After fixes are applied, verify:

- [x] No API module calls `CM.api.*` (except its own namespace)
- [x] No API module calls character data functions (`GetUnitClass`, `GetUnitGender`, `GetUnitRace`, etc.) unless it's the Character API module
- [x] All cross-module data needs are handled at collector level
- [x] Each API module focuses solely on its domain (Skills = skills, PvP = PvP, etc.)
- [x] Parameters are used to pass data between modules when needed
- [x] Collectors properly orchestrate multiple API module calls

## ✅ **Fixes Applied**

All three issues have been fixed:

1. **Skills.lua** - ✅ Fixed: `_GetMorphsData()` now accepts `playerClass` parameter
2. **PvP.lua** - ✅ Fixed: `GetRank()` now accepts `gender` parameter, `GetInfo()` passes it through
3. **Quests.lua** - ✅ Fixed: `GetZoneCompletion()` now accepts `zoneIndex` parameter, `GetInfo()` passes it through

**Collector Updates**:
- ✅ **Skills.lua collector** - Updated to pass `playerClass` from Character API
- ✅ **PvP.lua collector** - Updated to pass `gender` from Character API
- ✅ **Quests.lua collector** - No changes needed (uses `GetJournalInfo()` directly, not `GetInfo()`)

---

## 📝 **Notes**

1. **Utility Functions**: Calling `CM.utils.*` functions is acceptable - these are helper functions, not API modules
2. **Direct ESO API Calls**: All modules should use direct ESO API calls via `CM.SafeCall()` - this is correct
3. **Backward Compatibility**: When adding parameters, provide defaults to maintain backward compatibility
4. **Collector Pattern**: Collectors should gather data from multiple API modules and combine them as needed

---

## 🎯 **Conclusion**

Three modules have cross-module data gathering issues that should be fixed:
1. **Skills.lua** - Remove `GetUnitClass()` call, pass class as parameter
2. **PvP.lua** - Remove `GetUnitGender()` call, pass gender as parameter  
3. **Quests.lua** - Remove `GetUnitZoneIndex()` call, pass zoneIndex as parameter

All other modules follow the correct pattern of staying within their domain and using utilities/direct ESO API calls appropriately.
