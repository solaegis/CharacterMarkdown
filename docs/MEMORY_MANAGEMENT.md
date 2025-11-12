# Memory Management Best Practices

## Overview

CharacterMarkdown implements efficient memory management practices to minimize memory usage and prevent leaks in the ESO Lua environment. This document outlines the strategies used and guidelines for maintaining good memory hygiene.

## Lua Garbage Collection

### Background

Lua 5.1 (used by ESO) employs automatic garbage collection with a mark-and-sweep algorithm:
- **Automatic**: Memory is freed automatically when objects are no longer referenced
- **Non-deterministic**: GC runs at intervals, not immediately when objects become unreachable
- **Cooperative**: You can help by explicitly dereferencing large objects

### Manual GC Hints

While automatic GC is sufficient, we provide hints after large operations:

```lua
-- After generating large markdown
collectgarbage("step", 1000)  -- Perform incremental GC step
```

**Why "step" instead of "collect"?**
- `collectgarbage("step")` - Performs incremental collection (non-blocking)
- `collectgarbage("collect")` - Full collection cycle (can cause frame hitches)
- We use `step` to avoid UI freezes while still encouraging memory cleanup

## Memory Management Patterns

### 1. Event Handler Cleanup

**Pattern**: Always unregister one-time event handlers

```lua
local function OnAddOnLoaded(event, addonName)
    if addonName ~= CM.name then return end
    
    -- Unregister immediately after handling
    EVENT_MANAGER:UnregisterForEvent(CM.name, EVENT_ADD_ON_LOADED)
    
    -- Continue initialization...
end
```

**Location**: `src/Events.lua`

### 2. Chunk Management

**Pattern**: Explicitly clear chunks when window closes or mode changes

```lua
local function ClearChunks()
    markdownChunks = {}
    currentChunkIndex = 1
    currentMarkdown = ""
    CM.DebugPrint("UI", "Chunks cleared")
end
```

**When to clear**:
- Window closed
- Switching between markdown/import/export modes
- Before displaying new content

**Location**: `src/ui/Window.lua`

### 3. Collector Data Lifecycle

**Pattern**: Collected data is ephemeral - created, used, discarded

```lua
local function GenerateMarkdown(format)
    -- Collect data (creates large tables)
    local collectedData = {
        character = SafeCollect(...),
        equipment = SafeCollect(...),
        -- ... many more collectors
    }
    
    -- Use data to generate markdown
    local markdown = BuildMarkdownFromData(collectedData)
    
    -- CRITICAL: Explicitly clear references before returning
    collectedData = nil
    settings = nil
    gen = nil
    sections = nil
    
    -- Hint to GC
    collectgarbage("step", 1000)
    
    return markdown
end
```

**Key Points**:
- Collector data is NOT cached between generations
- Each `/markdown` command creates fresh data snapshots
- Data is dereferenced immediately after use
- This ensures stale data never accumulates

**Location**: `src/generators/Markdown.lua`

### 4. Settings Cache

**Pattern**: Small, long-lived cache with explicit invalidation

```lua
local settingsCache = nil
local settingsCacheTimestamp = 0

function CM.InvalidateSettingsCache()
    settingsCache = nil
    settingsCacheTimestamp = 0
end

function CM.GetSettings()
    -- Check if cache is still valid
    if settingsCache and settingsCacheTimestamp == currentTimestamp then
        return settingsCache
    end
    
    -- Rebuild cache
    settingsCache = MergeSettingsWithDefaults()
    settingsCacheTimestamp = currentTimestamp
    
    return settingsCache
end
```

**Why cache settings?**
- Settings are accessed hundreds of times during generation
- Settings table is small (~100 boolean flags)
- Merging with defaults is expensive if done repeatedly
- Cache is invalidated when settings change

**Location**: `src/Core.lua`

### 5. String Building Optimization

**Pattern**: Use `table.concat()` instead of repeated `..` concatenation

```lua
-- ❌ BAD: Creates N temporary strings
local markdown = ""
for i = 1, 1000 do
    markdown = markdown .. line[i] .. "\n"  -- Creates garbage!
end

-- ✅ GOOD: Creates 1 final string
local parts = {}
for i = 1, 1000 do
    table.insert(parts, line[i])
    table.insert(parts, "\n")
end
local markdown = table.concat(parts)
```

**Impact**:
- String concatenation with `..` creates intermediate strings
- For 1000 lines, bad pattern creates ~1000 temporary strings
- Good pattern creates 1 final string
- Modern generator sections use this pattern

**Locations**: 
- `src/generators/sections/Quests.lua` (example of good pattern)
- `src/generators/sections/Equipment.lua` (example of good pattern)

### 6. Global Function Caching

**Pattern**: Cache frequently-used globals at module scope

```lua
-- At top of file
local GetUnitName = GetUnitName
local GetUnitRace = GetUnitRace
local GetUnitClass = GetUnitClass
local string_format = string.format
local table_insert = table.insert

-- In function
local function CollectCharacterData()
    local name = GetUnitName("player")  -- Uses cached local
    -- ...
end
```

**Benefits**:
- Avoids repeated global table lookups
- Slightly faster access
- Standard ESO addon practice

**Locations**: All collector and generator files

## Memory Leak Prevention

### Common Leak Sources

1. **Unclosed Event Handlers** ✅ PREVENTED
   - All one-time handlers call `UnregisterForEvent`
   - Persistent handlers are intentional

2. **Circular References** ✅ PREVENTED
   - No circular table structures in codebase
   - Data flows one direction: collectors → generators → output

3. **Accumulating Data** ✅ PREVENTED
   - No persistent caches of collected data
   - Chunks cleared when window closes
   - Error lists reset between generations

4. **Orphaned UI Elements** ✅ PREVENTED
   - UI controls reused, not recreated
   - Event handlers properly scoped

## Memory Usage Profile

### Typical Operation

| Phase | Memory Usage | Duration | Cleanup |
|-------|-------------|----------|---------|
| Idle | Low (~100 KB settings) | Persistent | N/A |
| Data Collection | Medium (~500 KB data) | 1-2 seconds | Auto after generation |
| Markdown Generation | High (~1-2 MB strings) | 2-3 seconds | Auto after display |
| Display | Medium (~500 KB chunks) | Until window closed | Manual on close |

### Large Character Profiles

For characters with extensive data:
- Collection phase may create 1-2 MB of temporary tables
- Generation phase may create 3-5 MB of temporary strings
- Final output is chunked into ~22KB pieces for EditBox

**All temporary data is cleared after generation completes.**

## Guidelines for Contributors

### When Adding Collectors

```lua
local function CollectNewData()
    local data = {}
    
    -- Collect data...
    for i = 1, largeAmount do
        table.insert(data.items, CollectItem(i))
    end
    
    -- Return data (will be used then cleared by caller)
    return data
end

-- DO NOT cache collected data at module scope
-- DO NOT store collected data globally
```

### When Adding Generators

```lua
local function GenerateNewSection(data, format)
    -- Use table.concat for large outputs
    local parts = {}
    
    for _, item in ipairs(data.items) do
        table.insert(parts, FormatItem(item))
    end
    
    return table.concat(parts, "\n")
end

-- DO use table.concat() for building large strings
-- DO NOT use markdown = markdown .. line in loops
```

### When Adding UI Components

```lua
local function ShowNewWindow()
    -- Clear any previous data
    previousData = nil
    
    -- Show window...
    
    -- On close, clear data
    window:SetHandler("OnHide", function()
        previousData = nil
        collectgarbage("step", 500)
    end)
end

-- DO clear data when UI closes
-- DO hint GC after large UI operations
```

## Testing Memory Behavior

### Manual Testing

1. Generate large profile: `/markdown`
2. Check UI display (Task Manager / Activity Monitor)
3. Close window
4. Wait 10 seconds for GC to run
5. Memory should return to baseline

### Automated Testing

```lua
-- Test that collectors don't cache data
local before = collectgarbage("count")
local data = CM.collectors.CollectAchievementData()
data = nil
collectgarbage("collect")
local after = collectgarbage("count")

-- Memory should return to baseline (within tolerance)
assert(math.abs(after - before) < 50)  -- 50 KB tolerance
```

## Troubleshooting Memory Issues

### Symptoms of Memory Leaks

- Memory usage grows with each `/markdown` command
- Memory doesn't decrease after closing window
- Game becomes sluggish after repeated use

### Debugging Steps

1. **Enable LibDebugLogger**
   ```lua
   CM.DebugPrint("MEMORY", "Before collection: " .. collectgarbage("count") .. " KB")
   -- ... operation ...
   CM.DebugPrint("MEMORY", "After collection: " .. collectgarbage("count") .. " KB")
   ```

2. **Force GC and Check**
   ```lua
   collectgarbage("collect")
   d(collectgarbage("count") .. " KB in use")
   ```

3. **Check for Persistent References**
   - Search for module-scope variables that grow over time
   - Verify event handlers are unregistered
   - Ensure UI callbacks don't capture large closures

## Summary

CharacterMarkdown implements comprehensive memory management:

✅ **Event handlers** - Properly registered and unregistered  
✅ **Data lifecycle** - Collected fresh, used once, cleared explicitly  
✅ **String building** - Modern patterns with `table.concat()`  
✅ **Caching** - Minimal, only for small settings data  
✅ **GC hints** - Strategic hints after large operations  
✅ **Chunk management** - Explicit clearing on window close  

**Result**: Efficient memory usage with no leaks, suitable for long gaming sessions.

## References

- [Lua 5.1 GC Documentation](https://www.lua.org/manual/5.1/manual.html#2.10)
- [ESOUI Memory Best Practices](https://wiki.esoui.com/AddOn_Performance_Tips)
- [Programming in Lua: GC](https://www.lua.org/pil/17.1.html)

