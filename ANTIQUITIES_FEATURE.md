# Antiquities Feature Implementation

## Overview
Added a new Antiquities section to CharacterMarkdown that tracks antiquity progress, active leads, and discovered antiquities. This feature integrates with ESO's antiquities system to provide comprehensive tracking of scrying and excavation progress.

## Implementation Date
November 11, 2025

## Files Created

### 1. Collector: `src/collectors/Antiquities.lua`
**Purpose**: Collects data about antiquities, leads, and scrying progress from ESO API

**Key Functions**:
- `CollectAntiquityData()`: Main collector function
- Retrieves antiquity sets, individual antiquities, and lead status
- Tracks discovery progress and completion status
- Categorizes antiquities by quality (Common, Fine, Superior, Epic, Legendary, Mythic)

**Data Structure**:
```lua
{
    summary = {
        totalAntiquities = 0,
        discoveredAntiquities = 0,
        activeLeads = 0,
        completedAntiquities = 0,
        totalSets = 0,
        completedSets = 0
    },
    sets = {},           -- Array of antiquity sets with progress
    activeLeads = {},    -- Array of active leads (sorted by quality)
    recentDiscoveries = {}
}
```

**ESO API Functions Used**:
- `GetNumAntiquitySets()` - Get total number of antiquity sets
- `GetAntiquitySetId()` - Get set ID by index
- `GetAntiquitySetName()` - Get set name
- `GetAntiquitySetIcon()` - Get set icon
- `GetNumAntiquitySetAntiquities()` - Get count of antiquities in set
- `GetAntiquitySetAntiquityId()` - Get antiquity ID from set
- `GetAntiquityName()` - Get antiquity name
- `GetAntiquityQuality()` - Get quality level
- `GetAntiquityHasLead()` - Check if player has lead
- `GetAntiquityIsRepeatable()` - Check if repeatable
- `GetHasAntiquityBeenDiscovered()` - Check discovery status

### 2. Generator: `src/generators/sections/Antiquities.lua`
**Purpose**: Generates markdown output for antiquities data

**Key Functions**:
- `GenerateAntiquities()`: Main generator function
- `GenerateAntiquitiesSummary()`: Overview statistics
- `GenerateActiveLeads()`: Shows current active leads
- `GenerateAntiquitySets()`: Detailed set breakdown (when enabled)

**Output Format**:
- Summary table with total/discovered counts and progress
- Active leads table showing quality and repeatability
- Optional detailed sets table with progress bars
- Quality indicators using colored emoji icons:
  - ⚪ Common
  - 🟢 Fine
  - 🔵 Superior
  - 🟣 Epic
  - 🟡 Legendary
  - 🟠 Mythic

**Format Support**:
- GitHub Markdown (full tables and progress bars)
- VS Code Markdown (full tables and progress bars)
- Discord (simplified format without tables)

## Files Modified

### 1. `CharacterMarkdown.addon`
**Changes**:
- Added `src/collectors/Antiquities.lua` to collectors section
- Added `src/generators/sections/Antiquities.lua` to section generators

**Load Order**: Placed after Achievements and before other collectors/generators

### 2. `src/settings/Defaults.lua`
**Changes**:
- Added `includeAntiquities = true` - Enable/disable antiquities section
- Added `includeAntiquitiesDetailed = false` - Enable/disable detailed set breakdown

**Default Behavior**: 
- Antiquities section is enabled by default
- Detailed view is disabled by default (users can opt-in for full set tracking)

### 3. `src/generators/Markdown.lua`
**Changes**:
- Added `GenerateAntiquities` to generator function registry
- Added `antiquities = SafeCollect("CollectAntiquityData", CM.collectors.CollectAntiquityData)` to data collection
- Added antiquities section to section registry between Achievements and Quests
- Section configuration:
  ```lua
  {
      name = "Antiquities",
      tocEntry = nil,  -- Not shown in TOC
      condition = IsSettingEnabled(settings, "includeAntiquities", false),
      generator = function()
          return gen.GenerateAntiquities(data.antiquities, format)
      end
  }
  ```

### 4. `src/settings/Panel.lua`
**Changes**:
- Added checkbox for "Include Antiquities" with tooltip
- Added checkbox for "Detailed Antiquity Sets" (dependent on main setting)
- Integrated into "Enable All Sections" button logic

**UI Layout**: Placed after Achievement settings and before Quest settings

## Features

### Summary Statistics
- **Total Antiquities**: Total number of antiquities in game
- **Discovered**: Number of antiquities player has found
- **Active Leads**: Number of leads currently in player's journal
- **Completed Sets**: Number of fully completed antiquity sets

### Active Leads Display
Shows all current leads with:
- Antiquity name
- Quality level (with colored icon)
- Repeatability status

### Detailed Sets View (Optional)
When `includeAntiquitiesDetailed` is enabled:
- Lists all antiquity sets
- Shows completion progress for each set
- Progress bar visualization
- Completion percentages
- Total vs discovered counts

## Settings

### User-Configurable Options

1. **Include Antiquities** (`includeAntiquities`)
   - Default: `true`
   - Enables/disables the entire antiquities section
   - Accessible via settings panel

2. **Detailed Antiquity Sets** (`includeAntiquitiesDetailed`)
   - Default: `false`
   - Enables detailed set breakdown with progress
   - Dependent on `includeAntiquities` being enabled
   - Accessible via settings panel

## Usage

### Command Line
```lua
/markdown [github|vscode|discord|quick]
```

The antiquities section will be included automatically if:
1. `includeAntiquities` setting is enabled (default: true)
2. Player has access to the antiquities system
3. At least one antiquity exists in the database

### Settings Panel
Access via `/cmdsettings` or AddOns menu:
1. Navigate to "Extended Character Information" section
2. Check/uncheck "Include Antiquities" to enable/disable
3. Check/uncheck "Detailed Antiquity Sets" for detailed view
4. Changes take effect immediately

## Error Handling

The implementation uses the project's standard error handling patterns:

1. **SafeCall Wrapper**: All ESO API calls use `CM.SafeCall()` for error protection
2. **Safe Collection**: The collector is wrapped in `SafeCollect()` in Markdown.lua
3. **Graceful Degradation**: If the antiquities system is unavailable:
   - Collector returns empty data structure
   - Generator returns empty string
   - No errors shown to user
   - Other sections continue to work

## Performance Considerations

1. **Caching**: Local functions cache global lookups at module level
2. **Efficient Iteration**: Direct API iteration without unnecessary data copies
3. **Conditional Generation**: Detailed view only generated when explicitly enabled
4. **Smart Filtering**: Active leads pre-filtered and sorted during collection

## Lua 5.1 Compatibility

✅ **No `goto` statements used** - Following ESO Lua 5.1 requirements
✅ **Standard control flow** - Uses if-else blocks and early returns
✅ **No bitwise operators** - Not needed for this feature
✅ **Compatible string functions** - Uses standard Lua 5.1 string library

## Testing Recommendations

1. **Basic Functionality**:
   - Test with player who has antiquities access
   - Test with player who doesn't have antiquities access
   - Verify empty state handling

2. **Data Accuracy**:
   - Compare displayed counts with in-game journal
   - Verify active leads match journal
   - Check quality indicators are correct

3. **Settings Integration**:
   - Toggle main setting on/off
   - Toggle detailed setting on/off
   - Verify dependency (detailed requires main enabled)
   - Test "Enable All" button

4. **Format Support**:
   - Test GitHub format (full tables)
   - Test VS Code format (full tables)
   - Test Discord format (simplified)
   - Test Quick format (should not include antiquities)

5. **Error Scenarios**:
   - Test on character without Greymoor chapter
   - Test with corrupted/missing data
   - Verify graceful degradation

## Future Enhancements (Optional)

Potential improvements that could be added:

1. **Lead Sources**: Show where to find leads for incomplete antiquities
2. **Zone Filtering**: Filter antiquities by zone
3. **Recent Discoveries**: Track and display recently discovered antiquities
4. **Excavation Stats**: Track excavation attempts and success rates
5. **Set Rewards**: Show rewards for completing antiquity sets
6. **Mythic Focus**: Special section for mythic items only
7. **Lead Expiration**: Show time remaining on active leads

## Integration Notes

### Namespace Convention
✅ All code uses `CharacterMarkdown` namespace (aliased as `CM`)
✅ Functions exported to `CM.collectors` and `CM.generators.sections`

### Debug Logging
✅ Uses `CM.Info()` for collection progress messages
✅ Uses `CM.Warn()` for warnings (e.g., no antiquities found)
✅ Uses `CM.Error()` for critical errors

### Pattern Consistency
✅ Follows same patterns as Achievements and Quests collectors
✅ Uses same generator structure as other sections
✅ Integrates seamlessly with existing markdown generation flow

## Documentation

This implementation is fully documented with:
- Inline code comments explaining key logic
- Function headers describing purpose
- Section separators for code organization
- Error handling explanations
- ESO API usage notes

## Conclusion

The Antiquities feature is now fully integrated into CharacterMarkdown, providing users with comprehensive tracking of their antiquity collection progress. The implementation follows all project patterns and conventions, handles errors gracefully, and provides flexible output options across all supported markdown formats.

