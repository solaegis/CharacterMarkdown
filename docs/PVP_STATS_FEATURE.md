# PvP Stats Feature Documentation

## Overview

The PvP Stats feature provides comprehensive Alliance War and Battlegrounds data for character profiles. It supports multiple display tiers from minimal to comprehensive, allowing players to show as much or as little PvP information as desired.

## Features

### Core Data Collection

#### Alliance War
- **Rank & Points**: Current Alliance War rank, name, and total AP
- **Rank Progression**: Progress to next grade with progress bars
- **Campaign Info**: Assigned campaign, ruleset, and activity status
- **Campaign Rewards**: Reward tier progress and loyalty streak
- **Leaderboard Position**: Campaign ranking (requires API query)
- **Emperor Info**: Current emperor and reign duration

#### Battlegrounds
- **Leaderboard Stats**: Rankings and points for all three modes
  - Deathmatch
  - Flag Games (Capture the Relic, Chaosball)
  - Land Grab (Domination, Crazy King)
- **Current Match**: Real-time stats if in active battleground
  - Kills, Deaths, Assists, K/D Ratio
  - Medals earned

#### Campaign Details
- **Ruleset**: Campaign type (Standard, No CP, No Proc)
- **Champion Points**: Whether CP is enabled
- **Timing**: Time remaining in campaign
- **Underpop Bonus**: Active underdog alliance bonus
- **Alliance Scores**: Current alliance standings

## Settings

### Master Toggle
- **`includePvPStats`**: Enable/disable the entire PvP section
  - Default: `false`
  - When disabled, no PvP data is shown

### Display Options (Tier Controls)

All display options are disabled when `includePvPStats` is `false`.

#### Tier 1: Minimal (Default)
No additional settings needed. Shows:
- Alliance War rank and name
- Total AP
- Campaign name and status

#### Tier 2: Enhanced
Enable these settings for more detail:

- **`showPvPProgression`** (default: `false`)
  - Adds rank progress bars
  - Shows AP needed to next grade
  - Displays percentage complete
  
- **`showCampaignRewards`** (default: `false`)
  - Current reward tier (1-5)
  - Progress to next tier
  - Loyalty streak counter

#### Tier 3: Competitive
Add these for competitive insights:

- **`showLeaderboards`** (default: `false`)
  - Campaign leaderboard position
  - AP on leaderboard
  - Emperor candidate status (if rank #1)
  - Note: Requires API query, data may not be immediate

- **`showBattlegrounds`** (default: `false`)
  - Weekly leaderboard rankings for all three BG modes
  - Total points per mode
  - Current match stats (if in battleground)

#### Tier 4: Comprehensive
For maximum detail:

- **`detailedPvP`** (default: `false`)
  - Campaign timing (time remaining)
  - Underpop bonus status
  - Campaign ruleset details
  - Emperor information (name, alliance, reign duration)
  - Current BG match stats with medals
  - All of the above plus extra contextual info

## Display Examples

### Minimal (Default)

```markdown
## ⚔️ PvP Profile

### Alliance War Status

| Category | Value |
|:---------|:------|
| **Rank** | Tyro (Rank 5) |
| **Alliance Points** | 50,000 |
| **Alliance** | Aldmeri Dominion |

### Campaign

| Category | Value |
|:---------|:------|
| **Campaign** | Blackreach 🟢 Active |
| **Ruleset** | No CP |

---
```

### Enhanced (With Progression & Rewards)

```markdown
## ⚔️ PvP Profile

### Alliance War Status

| Category | Value |
|:---------|:------|
| **Rank** | Tyro Grade 2 (Rank 5) |
| **Alliance Points** | 52,500 |
| **Progress to Next Grade** | 2,500 / 5,000 AP ▰▰▰▰▰▱▱▱▱▱ 50.0% |
| **AP Needed** | 2,500 |
| **Alliance** | Aldmeri Dominion |

### Campaign

| Category | Value |
|:---------|:------|
| **Campaign** | Blackreach 🟢 Active |
| **Ruleset** | No CP |
| **Reward Tier** | 3 / 5 |
| **Tier Progress** | ▰▰▰▰▰▰▰▰▱▱ 75.0% to Tier 4 |
| **Loyalty Streak** | 2 campaigns |

---
```

### Competitive (With Leaderboards & Battlegrounds)

```markdown
## ⚔️ PvP Profile

### Alliance War Status

| Category | Value |
|:---------|:------|
| **Rank** | Tyro Grade 2 (Rank 5) |
| **Alliance Points** | 52,500 |
| **Progress to Next Grade** | 2,500 / 5,000 AP ▰▰▰▰▰▱▱▱▱▱ 50.0% |
| **AP Needed** | 2,500 |
| **Alliance** | Aldmeri Dominion |

### Campaign

| Category | Value |
|:---------|:------|
| **Campaign** | Blackreach 🟢 Active |
| **Ruleset** | No CP |
| **Reward Tier** | 3 / 5 |
| **Tier Progress** | ▰▰▰▰▰▰▰▰▱▱ 75.0% to Tier 4 |
| **Loyalty Streak** | 2 campaigns |

### Leaderboard Standing

| Category | Value |
|:---------|:------|
| **Campaign Rank** | #245 |
| **Leaderboard AP** | 52,500 |

### Battlegrounds

| Mode | Rank | Points |
|:-----|-----:|-------:|
| **Deathmatch** | #127 | 1,250 |
| **Flag Games** | #89 | 2,100 |
| **Land Grab** | #156 | 980 |

---
```

### Comprehensive (All Details)

```markdown
## ⚔️ PvP Profile

### Alliance War Status

| Category | Value |
|:---------|:------|
| **Rank** | Tyro Grade 2 (Rank 5) |
| **Alliance Points** | 52,500 |
| **Progress to Next Grade** | 2,500 / 5,000 AP ▰▰▰▰▰▱▱▱▱▱ 50.0% |
| **AP Needed** | 2,500 |
| **Alliance** | Aldmeri Dominion |

### Campaign

| Category | Value |
|:---------|:------|
| **Campaign** | Blackreach 🟢 Active |
| **Ruleset** | Standard, No CP |
| **Underpop Bonus** | Active ✓ |
| **Time Remaining** | 5d 12h |
| **Reward Tier** | 3 / 5 |
| **Tier Progress** | ▰▰▰▰▰▰▰▰▱▱ 75.0% to Tier 4 |
| **Loyalty Streak** | 2 campaigns |
| **Emperor** | John Doe (@johndoe123) |
| **Reign Duration** | 2h 35m |

### Leaderboard Standing

| Category | Value |
|:---------|:------|
| **Campaign Rank** | #1 |
| **Leaderboard AP** | 52,500 |
| **Status** | 👑 Emperor Candidate |

### Battlegrounds

| Mode | Rank | Points |
|:-----|-----:|-------:|
| **Deathmatch** | #127 | 1,250 |
| **Flag Games** | #89 | 2,100 |
| **Land Grab** | #156 | 980 |

#### Current Match

| Stat | Value |
|:-----|------:|
| **Kills** | 12 |
| **Deaths** | 3 |
| **Assists** | 8 |
| **K/D Ratio** | 4.00 |

**Medals:**
- Triple Kill (×2)
- Killing Spree (×1)
- Damage Dealer (×3)

---
```

### Discord Format (Compact)

```markdown
**⚔️ PvP Profile:**

**Alliance War**
• Rank: Tyro Grade 2 (Rank 5) • 52,500 AP
• Progress: 2,500 / 5,000 AP to next grade (50.0%)
• Campaign: Blackreach [Active]
  No CP

**Campaign Standing**
• Reward Tier: 3/5
• Loyalty: 2 campaigns
• Rank: #245

**Battlegrounds**
• Deathmatch: #127 (1,250 pts)
• Flag Games: #89 (2,100 pts)
• Land Grab: #156 (980 pts)
```

## Usage

### In Addon Settings UI

1. Open Character Markdown settings:
   - Type `/markdown settings` in chat, or
   - Navigate to Settings → Addons → Character Markdown

2. Scroll to the "Extended Content Sections" section

3. Check "Include PvP Statistics" to enable the feature

4. Enable desired detail levels:
   - Check "Show PvP Progression" for progress bars
   - Check "Show Campaign Rewards" for tier and loyalty
   - Check "Show Leaderboards" for ranking
   - Check "Show Battlegrounds" for BG stats
   - Check "Detailed PvP Mode" for comprehensive info

### Via YAML Export/Import

Add these settings to your exported settings file:

```yaml
# PvP Settings
includePvPStats: true
showPvPProgression: true
showCampaignRewards: true
showLeaderboards: false  # Optional: requires API query
showBattlegrounds: true
detailedPvP: false  # Set true for maximum detail
```

Then import with:
```
/markdown settings:import
```

## Technical Details

### Data Collection

The collector (`src/collectors/PvPStats.lua`) gathers data from multiple ESO API sources:

#### Alliance War APIs
- `GetUnitAvARank()` - Current rank
- `GetUnitAvARankPoints()` - Total AP
- `GetAvARankProgress()` - Progress to next grade
- `GetAssignedCampaignId()` - Campaign assignment
- `GetCampaignRulesetId()` - Campaign ruleset
- `DoesCurrentCampaignRulesetAllowChampionPoints()` - CP status
- `GetPlayerCampaignRewardTierInfo()` - Reward tier
- `GetCurrentCampaignLoyaltyStreak()` - Loyalty
- `IsUnderpopBonusEnabled()` - Underpop bonus
- `DoesCampaignHaveEmperor()` - Emperor status

#### Leaderboard APIs
- `QueryCampaignLeaderboardData()` - Async query (must be called first)
- `GetNumCampaignLeaderboardEntries()` - Entry count
- `GetCampaignLeaderboardEntryInfo()` - Player position

#### Battlegrounds APIs
- `QueryBattlegroundLeaderboardData()` - Async query
- `GetBattlegroundLeaderboardLocalPlayerInfo()` - Rankings
- `IsActiveWorldBattleground()` - In match check
- `GetScoreboardLocalPlayerEntryIndex()` - Player index
- `GetScoreboardEntryScoreByType()` - Match stats
- `GetNextScoreboardEntryMedalId()` - Medal iteration
- `GetMedalInfo()` - Medal details

### Data Structure

```lua
pvpStatsData = {
    pvp = {
        rank = 5,
        rankName = "Tyro",
        rankPoints = 52500,
        alliance = 2,
        allianceName = "Aldmeri Dominion",
        campaign = {
            id = 123,
            name = "Blackreach",
            isActive = true,
            ruleset = {
                name = "Standard",
                allowsCP = false
            },
            timing = {
                secondsToEnd = 475200  -- 5.5 days
            },
            underpop = {
                hasBonus = true
            }
        },
        progression = {
            currentPoints = 52500,
            pointsToNext = 2500,
            progressPercent = 50.0
        },
        rewards = {
            earnedTier = 3,
            loyaltyStreak = 2
        }
    },
    leaderboards = {
        playerPosition = {
            found = true,
            rank = 245,
            ap = 52500
        }
    },
    battlegrounds = {
        leaderboards = {
            deathmatch = { rank = 127, score = 1250 },
            flagGames = { rank = 89, score = 2100 },
            landGrab = { rank = 156, score = 980 }
        },
        currentMatch = {
            isActive = false
        }
    }
}
```

## Performance Considerations

### API Query Notes

1. **Leaderboard Queries are Async**
   - `QueryCampaignLeaderboardData()` and `QueryBattlegroundLeaderboardData()` are asynchronous
   - Data may not be immediately available on first markdown generation
   - Re-generate markdown to get latest leaderboard data

2. **Recommended Settings**
   - For casual PvPers: Disable `showLeaderboards` to avoid unnecessary API queries
   - For competitive players: Enable all options to track performance
   - Use `detailedPvP` only when needed for comprehensive reports

### Safe API Calls

All ESO API calls use `CM.SafeCall()` for error handling, preventing addon errors from missing APIs or unexpected data.

## Future Enhancements

Potential additions for future versions:

1. **Kill Location Heat Maps**
   - Parse `GetNumKillLocations()` and `GetKillLocationPinInfo()`
   - Generate ASCII or coordinate-based heat map
   - Show favorite PvP locations

2. **Historical Campaign Performance**
   - Track AP gain per campaign
   - Compare performance across campaigns
   - Show improvement trends

3. **Former Emperor Badge**
   - Track if player was ever emperor
   - Show past emperor reigns

4. **BG Win/Loss Records**
   - Track W/L ratio per mode
   - Calculate win percentage
   - Show favorite game mode

5. **Medal Tracking**
   - Most common medals earned
   - Medal leaderboards
   - Achievement integration

## Support

For issues or feature requests related to PvP stats:
- Visit: https://www.esoui.com/downloads/info4279-CharacterMarkdown.html
- Report bugs in the comments section
- Check CHANGELOG.md for recent updates

## References

- ESO API Documentation: https://wiki.esoui.com/
- Alliance War Guide: https://en.uesp.net/wiki/Online:Alliance_War
- Battlegrounds Guide: https://en.uesp.net/wiki/Online:Battlegrounds

