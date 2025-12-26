# PvP Stats Feature

## Overview

The PvP Stats feature provides comprehensive Alliance War and Battlegrounds data with configurable display tiers from minimal to comprehensive.

---

## Quick Start

### Enable PvP Stats
1. Type `/markdown settings` in chat
2. Check "Include PvP Statistics"
3. Type `/markdown` to generate

### Display Level Presets

| Level | Settings | Shows |
|-------|----------|-------|
| 🔰 **Casual** | `includePvPStats` only | Rank, AP, Campaign |
| ⚔️ **Regular** | + `showPvPProgression`, `showCampaignRewards` | Progress bars, Rewards |
| 🏆 **Competitive** | + `showLeaderboards`, `showBattlegrounds` | Rankings, BG stats |
| 👑 **PvP Main** | + `detailedPvP` | Emperor info, Match stats |

---

## Settings Reference

| Setting | Default | Description |
|---------|---------|-------------|
| `includePvPStats` | `false` | Master toggle |
| `showPvPProgression` | `false` | Rank progress bars |
| `showCampaignRewards` | `false` | Reward tier & loyalty |
| `showLeaderboards` | `false` | Campaign ranking |
| `showBattlegrounds` | `false` | BG leaderboards |
| `detailedPvP` | `false` | Full comprehensive mode |

---

## Available Data

### Alliance War
- **Rank & Points**: Current rank, name, total AP
- **Progression**: Progress bars, AP needed to next grade
- **Campaign**: Name, ruleset, CP status, timing
- **Rewards**: Tier (1-5), loyalty streak
- **Leaderboard**: Campaign ranking, emperor candidate status
- **Emperor**: Current emperor name, reign duration

### Battlegrounds
- **Leaderboards**: Rankings for Deathmatch, Flag Games, Land Grab
- **Current Match** (if active): Kills, Deaths, Assists, K/D, Medals

---

## Display Examples

### Minimal
```markdown
| Category | Value |
|----------|-------|
| **Rank** | Tyro (Rank 5) |
| **Alliance Points** | 50,000 |
| **Campaign** | Blackreach 🟢 Active |
```

### With Progression & Rewards
```markdown
| Category | Value |
|----------|-------|
| **Progress to Next** | 2,500 / 5,000 AP ▰▰▰▰▰▱▱▱▱▱ 50% |
| **Reward Tier** | 3 / 5 |
| **Loyalty Streak** | 2 campaigns |
```

### Battlegrounds
```markdown
| Mode | Rank | Points |
|------|-----:|-------:|
| **Deathmatch** | #127 | 1,250 |
| **Flag Games** | #89 | 2,100 |
| **Land Grab** | #156 | 980 |
```

---

## Technical Details

### Key API Functions

```lua
-- Alliance War
GetUnitAvARank("player")
GetUnitAvARankPoints("player")
GetAvARankProgress(points)
GetAssignedCampaignId()
GetPlayerCampaignRewardTierInfo(id)
GetCurrentCampaignLoyaltyStreak()

-- Leaderboards (async)
QueryCampaignLeaderboardData(alliance)
GetCampaignLeaderboardEntryInfo(id, index)

-- Battlegrounds
GetBattlegroundLeaderboardLocalPlayerInfo(type)
IsActiveWorldBattleground()
GetScoreboardEntryScoreByType(index, type)
```

### Data Structure

```lua
pvpStatsData = {
    pvp = {
        rank = 5,
        rankName = "Tyro",
        rankPoints = 52500,
        campaign = { name = "Blackreach", isActive = true },
        progression = { progressPercent = 50.0 },
        rewards = { earnedTier = 3, loyaltyStreak = 2 }
    },
    leaderboards = { playerPosition = { rank = 245 } },
    battlegrounds = {
        leaderboards = { deathmatch = { rank = 127, score = 1250 } }
    }
}
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Leaderboard not showing | Async query; regenerate after 5 seconds |
| Progress bar not showing | Enable `showPvPProgression` |
| No current match stats | Only shows in active battleground |
| Settings grayed out | Enable "Include PvP Statistics" first |

---

## Performance Notes

- **Leaderboard queries are async** – data may not be immediate on first generation
- **Disable leaderboards** if not needed to save API calls
- **Use detailed mode** only for comprehensive reports

---

## File References

| File | Purpose |
|------|---------|
| `src/collectors/PvPStats.lua` | Data collection |
| `src/generators/sections/PvPStats.lua` | Markdown generation |
| `src/settings/Defaults.lua` | Setting defaults |
| `src/settings/Panel.lua` | Settings UI |
