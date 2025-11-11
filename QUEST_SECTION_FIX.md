# Quest Section Fix Summary

## Issue
The Quests section was not generating any markdown output, even though the `includeQuests` setting was enabled (defaults to `true`).

## Root Causes (2 Issues Found)

### Issue 1: Incorrect ESO API Usage in Collector
The quest collector (`src/collectors/Quests.lua`) was using an incorrect ESO API call:

```lua
questTypeStr = GetString("SI_QUESTTYPE", questType) or "Quest"
```

### The Problem
The ESO API function `GetString()` takes a **single parameter** (a numeric string ID constant), not two parameters. The correct usage would be:

```lua
GetString(SI_QUESTTYPE0)  -- Single parameter, direct constant
```

But the code was passing:
1. A string `"SI_QUESTTYPE"` (instead of the actual constant)
2. A second parameter `questType` (which GetString doesn't accept)

This caused the API call to fail silently when wrapped in `pcall()`, which caused:
1. The collector to fail and return an empty table `{}`
2. The generator to receive `questData = {}` with no `summary` field
3. The generator's nil check to trigger and return an empty string
4. No markdown output

### Issue 2: Missing FormatNumber Utility in Generator
The quest generator (`src/generators/sections/Quests.lua`) was trying to load `FormatNumber` from the wrong location:

```lua
if not CM.utils.FormatNumber then
    local Formatters = CM.generators.helpers.Utilities  // WRONG PATH!
    CM.utils.FormatNumber = Formatters.FormatNumber     // This doesn't exist
    CM.utils.GenerateProgressBar = Formatters.GenerateProgressBar
end
```

**The Problem:**
- `FormatNumber` is defined in `src/utils/Formatters.lua` and exported as `CM.utils.FormatNumber`
- The generator was trying to load it from `CM.generators.helpers.Utilities` (which doesn't have `FormatNumber`)
- This caused `InitializeUtilities()` to fail silently
- When the utility initialization failed, the generator would try to call `CM.utils.FormatNumber()` which was `nil`
- This caused the entire generator to fail, caught by the section registry's `pcall`, returning empty output

## Fixes Applied

### Fix 1: Collector API Usage
Removed the problematic `GetString()` calls and replaced them with a simple default value:

```lua
-- Quest type string - ESO doesn't provide easy localization for quest types
-- Just use a simple "Quest" string for now
local questTypeStr = "Quest"
```

This change was applied to 4 locations in the file:
- Line 199-201 (main quest collector)
- Line 271-273 (main story quests)
- Line 336-338 (guild quests)  
- Line 419-421 (daily quests)

### Fix 2: Generator Utility Initialization
Fixed the `InitializeUtilities()` function to properly verify utilities are loaded:

```lua
local function InitializeUtilities()
    -- Verify required utilities are loaded
    -- FormatNumber is exported by src/utils/Formatters.lua as CM.utils.FormatNumber
    if not CM.utils or not CM.utils.FormatNumber then
        CM.Error("Quest generator: CM.utils.FormatNumber not available!")
        return false
    end
    
    -- Load GenerateAnchor if available
    if not CM.utils.GenerateAnchor and CM.utils.markdown and CM.utils.markdown.GenerateAnchor then
        CM.utils.GenerateAnchor = CM.utils.markdown.GenerateAnchor
    end
    
    return true
end
```

**Key Changes:**
- Removed the broken lazy-load logic that tried to load from wrong path
- Added validation that `CM.utils.FormatNumber` exists (it's already loaded by Formatters.lua)
- Returns `true`/`false` to indicate success/failure
- All 8 generator functions now check the return value and bail early if initialization fails
- Added clear error message if utilities are missing

## Expected Behavior After Fix
With the fix, the quest collector should:
1. Successfully collect quest data without failing
2. Return a proper data structure even with 0 active quests
3. Allow the generator to produce markdown output showing:
   - Quest summary table (with counts, even if 0)
   - Category breakdown (if any quests exist)
   - Active quest list (if any quests exist)
   - Zone breakdown (if any quests exist)

## Testing
To test the fix:
1. `/reloadui` to reload the addon with the fixed code
2. Run `/markdown` to generate markdown
3. The Quests section should now appear with at least a summary table

## Notes
- The quest type localization isn't critical for the addon's functionality
- ESO's API doesn't provide an easy way to get localized quest type names dynamically
- Using "Quest" as a generic type string is acceptable for now
- Future enhancement: Could map specific quest type constants if needed

