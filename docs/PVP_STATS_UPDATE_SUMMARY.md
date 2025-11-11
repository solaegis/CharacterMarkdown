# PvP Stats Enhancement - Update Summary

## Overview

Enhanced the PvP Stats section with comprehensive Alliance War and Battlegrounds data, supporting multiple display tiers from minimal to comprehensive.

## Files Modified

### 1. **src/collectors/PvPStats.lua** (Enhanced)
   - **Previous**: Basic rank, alliance, campaign info, and placeholder stats
   - **Updated**: Comprehensive data collection including:
     - Alliance War rank progression with AP tracking
     - Campaign reward tier and loyalty streak
     - Campaign ruleset details (CP enabled, underpop bonus, timing)
     - Emperor information
     - Leaderboard position (with API queries)
     - Battlegrounds leaderboard stats for all three modes
     - Current battleground match stats with medals

### 2. **src/generators/sections/PvPStats.lua** (Complete Rewrite)
   - **Previous**: Simple table format with basic info
   - **Updated**: Tiered display system with four levels:
     - **Minimal**: Rank, AP, campaign name (default)
     - **Enhanced**: Adds progression bars and reward tiers
     - **Competitive**: Adds leaderboard rankings and BG stats
     - **Comprehensive**: All details including emperor info, timing, current match
   - Supports both GitHub/VSCode (table format) and Discord (compact format)
   - Includes progress bars for rank progression and reward tiers
   - Formatted time remaining displays
   - Emperor candidate badges
   - Current BG match stats with K/D ratio and medals

### 3. **src/settings/Defaults.lua** (Added Settings)
   - Added new settings section: "PVP DISPLAY SETTINGS"
   - Five new boolean settings (all default `false`):
     - `showPvPProgression` - Rank progress bars
     - `showCampaignRewards` - Reward tier and loyalty
     - `showLeaderboards` - Campaign ranking
     - `showBattlegrounds` - BG leaderboard stats
     - `detailedPvP` - Full comprehensive mode

### 4. **src/settings/Panel.lua** (Added UI Controls)
   - Changed "Include PvP Statistics" to full-width checkbox
   - Added five dependent sub-options (indented with `└─` prefix):
     - "Show PvP Progression"
     - "Show Campaign Rewards"
     - "Show Leaderboards"
     - "Show Battlegrounds"
     - "Detailed PvP Mode"
   - All sub-options disabled when `includePvPStats` is `false`
   - Added new settings to "Enable/Disable All" toggle handler

### 5. **docs/PVP_STATS_FEATURE.md** (New Documentation)
   - Comprehensive feature documentation
   - Display examples for all four tiers
   - Settings explanations
   - Technical API reference
   - Data structure documentation
   - Usage instructions

## Features Added

### Alliance War Enhancements
- ✅ Rank progression with progress bars
- ✅ AP needed to next grade
- ✅ Campaign reward tier (1-5) tracking
- ✅ Loyalty streak counter
- ✅ Campaign ruleset display (CP enabled/disabled)
- ✅ Underpop bonus indicator
- ✅ Campaign timing (time remaining)
- ✅ Emperor information (name, alliance, reign duration)
- ✅ Leaderboard position with emperor candidate badge
- ✅ Active campaign indicator 🟢

### Battlegrounds Enhancements
- ✅ Leaderboard rankings for all three modes:
  - Deathmatch
  - Flag Games (Capture the Relic, Chaosball)
  - Land Grab (Domination, Crazy King)
- ✅ Points/score per mode
- ✅ Current match stats (if in battleground):
  - Kills, Deaths, Assists
  - K/D Ratio
  - Medals earned with counts

### Display Enhancements
- ✅ Progress bars using `▰▱` characters
- ✅ Percentage indicators
- ✅ Formatted numbers (e.g., "52,500" not "52500")
- ✅ Time formatting (e.g., "5d 12h" not "475200 seconds")
- ✅ Status badges (🟢 Active, 👑 Emperor Candidate)
- ✅ Discord-optimized compact format
- ✅ Hierarchical sections (Alliance War → Campaign → Leaderboard → Battlegrounds)

## Display Tiers

### Tier 1: Minimal (Default)
- Settings: `includePvPStats = true` only
- Shows: Rank, AP, Alliance, Campaign name
- Best for: Casual PvPers who want basic info

### Tier 2: Enhanced
- Settings: + `showPvPProgression`, `showCampaignRewards`
- Adds: Progress bars, reward tier, loyalty streak
- Best for: Regular PvPers tracking progression

### Tier 3: Competitive
- Settings: + `showLeaderboards`, `showBattlegrounds`
- Adds: Campaign ranking, BG leaderboards
- Best for: Competitive players tracking standings

### Tier 4: Comprehensive
- Settings: + `detailedPvP = true`
- Adds: Emperor info, timing, underpop bonus, current match stats
- Best for: Hardcore PvP mains creating detailed profiles

## API Integrations

### Alliance War APIs Used
```lua
GetUnitAvARank("player")
GetUnitAvARankPoints("player")
GetAvARankProgress(points)
GetAssignedCampaignId()
GetCampaignName(id)
GetCampaignRulesetId(id)
GetCampaignRulesetName(id)
DoesCurrentCampaignRulesetAllowChampionPoints()
GetPlayerCampaignRewardTierInfo(id)
GetCurrentCampaignLoyaltyStreak()
IsUnderpopBonusEnabled(id, alliance)
GetSecondsUntilCampaignEnd(id)
DoesCampaignHaveEmperor(id)
GetCampaignEmperorInfo(id)
GetCampaignEmperorReignDuration(id)
```

### Leaderboard APIs Used
```lua
QueryCampaignLeaderboardData(alliance)  -- Async
GetNumCampaignLeaderboardEntries(id)
GetCampaignLeaderboardEntryInfo(id, index)
```

### Battlegrounds APIs Used
```lua
QueryBattlegroundLeaderboardData(type)  -- Async
GetBattlegroundLeaderboardLocalPlayerInfo(type)
IsActiveWorldBattleground()
GetScoreboardLocalPlayerEntryIndex()
GetScoreboardEntryScoreByType(index, type)
GetNextScoreboardEntryMedalId(index, ...)
GetScoreboardEntryNumEarnedMedalsById(index, id)
GetMedalInfo(id)
```

## Safe Call Pattern

All ESO API calls wrapped with `CM.SafeCall()` for error handling:

```lua
-- Single return value
local rankPoints = CM.SafeCall(GetUnitAvARankPoints, "player") or 0

-- Multiple return values (use pcall directly)
local success, subRankStart, nextSubRank = pcall(GetAvARankProgress, rankPoints)
if success then
    -- Handle data
end
```

## Settings UI Integration

Settings panel hierarchy:
```
☑ Include PvP Statistics
  ☑ └─ Show PvP Progression
  ☑ └─ Show Campaign Rewards
  ☐ └─ Show Leaderboards
  ☑ └─ Show Battlegrounds
  ☐ └─ Detailed PvP Mode
```

All sub-options:
- Displayed with indented `└─` prefix
- Grayed out when parent is unchecked
- Half-width for compact display
- Included in "Enable/Disable All" toggle

## Backwards Compatibility

- ✅ Maintains compatibility with existing `GeneratePvP` alias
- ✅ Default settings preserve existing behavior (all new features off)
- ✅ No breaking changes to existing data structures
- ✅ Works with both new `pvpStatsData` and legacy `pvpData` sources
- ✅ Gracefully handles missing data (shows minimal info if APIs fail)

## Testing Recommendations

1. **Basic Functionality**
   ```
   /markdown
   ```
   - Enable `includePvPStats` in settings
   - Verify minimal display shows rank, AP, campaign

2. **Progression Display**
   - Enable `showPvPProgression`
   - Verify progress bar and percentage display
   - Check AP needed calculation

3. **Campaign Rewards**
   - Enable `showCampaignRewards`
   - Verify reward tier shows (1-5)
   - Check loyalty streak counter

4. **Leaderboards**
   - Enable `showLeaderboards`
   - Note: May need to regenerate after API query completes
   - Check for rank display
   - Verify emperor candidate badge if rank #1

5. **Battlegrounds**
   - Enable `showBattlegrounds`
   - Verify all three mode rankings show
   - If in BG, check current match stats
   - Verify medals display

6. **Comprehensive Mode**
   - Enable `detailedPvP`
   - Verify campaign timing shows
   - Check underpop bonus indicator
   - If emperor exists, verify emperor info
   - In BG, verify K/D ratio and medals

7. **Discord Format**
   - Change format to Discord
   - Verify compact format
   - Check all tiers in Discord format

## Known Limitations

1. **Async Queries**
   - Leaderboard data requires `QueryCampaignLeaderboardData()` async call
   - Data may not be available on first markdown generation
   - Solution: Regenerate markdown after a few seconds

2. **Current Match Stats**
   - Only available when actually in a battleground
   - Medals only show for current match, not historical

3. **Kill Location Heat Maps**
   - Not implemented in this version
   - Future enhancement (see API: `GetNumKillLocations()`)

4. **Historical Campaign Data**
   - Only shows current campaign
   - No AP gain tracking over time
   - Future enhancement

## Migration Notes

### For Users
- No action required
- New features are opt-in via settings
- Existing profiles unchanged unless settings are modified

### For Developers
- `GeneratePvPStats` is primary function
- `GeneratePvP` alias maintained for compatibility
- New data structure extends, doesn't replace old structure
- All new settings have safe defaults (`false`)

## Performance Impact

- **Minimal**: No impact (uses existing APIs only)
- **Enhanced**: Negligible (a few extra API calls)
- **Competitive**: Low (async queries called but not awaited)
- **Comprehensive**: Low to moderate (additional emperor/timing queries)

## Documentation

- **Feature Guide**: `docs/PVP_STATS_FEATURE.md`
- **API Reference**: `docs/API_REFERENCE.md` (update recommended)
- **Architecture**: `docs/ARCHITECTURE.md` (update recommended)

## Future Enhancements

Identified for future versions:
- Kill location heat maps (ASCII or coordinate-based)
- Historical campaign performance tracking
- Former emperor badge/history
- BG win/loss record tracking
- Medal leaderboards and achievements
- AP gain rate analysis
- Compare stats with alliance/guild members

## Version Compatibility

- **Lua Version**: 5.1 (ESO compatible)
- **No `goto` statements**: ✅ Follows ESO Lua 5.1 requirements
- **Safe API calls**: ✅ All calls wrapped with error handling
- **Namespace**: ✅ All code in `CharacterMarkdown` namespace

## Summary

This enhancement transforms the PvP Stats section from a basic info display into a comprehensive competitive profile tool. Players can now showcase their Alliance War progression, campaign standing, and Battlegrounds performance with configurable detail levels suitable for casual players to hardcore PvP mains.

**Lines of code changed**: ~800 lines
**New settings added**: 5
**New APIs integrated**: 20+
**Display tiers supported**: 4
**Format compatibility**: GitHub, VSCode, Discord

