# PvP Stats - Quick Reference

## Quick Start

### Enable PvP Stats
1. Type `/markdown settings` in chat
2. Find "Include PvP Statistics" and check it
3. Type `/markdown` to generate

### Choose Your Display Level

#### 🔰 Casual PvPer (Default)
```
☑ Include PvP Statistics
☐ Show PvP Progression
☐ Show Campaign Rewards
☐ Show Leaderboards
☐ Show Battlegrounds
☐ Detailed PvP Mode
```
**Shows**: Rank, AP, Campaign name

---

#### ⚔️ Regular PvPer
```
☑ Include PvP Statistics
☑ Show PvP Progression
☑ Show Campaign Rewards
☐ Show Leaderboards
☐ Show Battlegrounds
☐ Detailed PvP Mode
```
**Adds**: Progress bars, Reward tier, Loyalty streak

---

#### 🏆 Competitive Player
```
☑ Include PvP Statistics
☑ Show PvP Progression
☑ Show Campaign Rewards
☑ Show Leaderboards
☑ Show Battlegrounds
☐ Detailed PvP Mode
```
**Adds**: Campaign ranking, BG leaderboards

---

#### 👑 PvP Main (Everything)
```
☑ Include PvP Statistics
☑ Show PvP Progression
☑ Show Campaign Rewards
☑ Show Leaderboards
☑ Show Battlegrounds
☑ Detailed PvP Mode
```
**Adds**: Emperor info, Timing, Current match stats

---

## What Each Setting Does

| Setting | What It Shows | Example |
|:--------|:--------------|:--------|
| **Include PvP Statistics** | Master toggle. Must be ON for others to work. | Rank: Tyro (Rank 5) |
| **Show PvP Progression** | Progress bar and AP needed to next grade | 2,500 / 5,000 AP ▰▰▰▰▰▱▱▱▱▱ 50% |
| **Show Campaign Rewards** | Reward tier (1-5), loyalty streak | Tier 3/5 • Loyalty: 2 campaigns |
| **Show Leaderboards** | Your campaign rank and emperor candidate status | Campaign Rank: #245 |
| **Show Battlegrounds** | Weekly BG rankings for all modes | Deathmatch: #127 (1,250 pts) |
| **Detailed PvP Mode** | Campaign timing, underpop bonus, emperor, current match | Emperor: John Doe • Reign: 2h 35m |

## Quick Settings Presets

### Casual
Enable in Settings Panel:
- Include PvP Statistics

### Regular  
Enable in Settings Panel:
- Include PvP Statistics
- Show PvP Progression
- Show Campaign Rewards

### Competitive
Enable in Settings Panel:
- Include PvP Statistics
- Show PvP Progression
- Show Campaign Rewards
- Show Leaderboards
- Show Battlegrounds

### PvP Main (Full Detail)
Enable in Settings Panel:
- Include PvP Statistics
- Show PvP Progression
- Show Campaign Rewards
- Show Leaderboards
- Show Battlegrounds
- Detailed PvP Mode

## Troubleshooting

### "Leaderboard not showing"
- Leaderboard queries are async (delayed)
- Generate markdown, wait 5 seconds, generate again
- Or disable `showLeaderboards` if not needed

### "Progress bar not showing"
- Make sure `showPvPProgression` is enabled

### "No current match stats"
- Only shows when you're in an active battleground
- Leave the battleground to hide current match section

### "Settings grayed out"
- Make sure "Include PvP Statistics" is checked
- Sub-options are disabled when parent is unchecked

## Visual Examples

### Minimal Display
```
Rank: Tyro (Rank 5)
AP: 50,000
Campaign: Blackreach
```

### With Progression
```
Rank: Tyro Grade 2 (Rank 5)
AP: 52,500
Progress: 2,500 / 5,000 AP ▰▰▰▰▰▱▱▱▱▱ 50.0%
AP Needed: 2,500
```

### With Rewards
```
Reward Tier: 3 / 5
Tier Progress: ▰▰▰▰▰▰▰▰▱▱ 75.0% to Tier 4
Loyalty Streak: 2 campaigns
```

### With Leaderboards
```
Campaign Rank: #245
Leaderboard AP: 52,500
```

### With Battlegrounds
```
Deathmatch: #127 | 1,250 pts
Flag Games: #89 | 2,100 pts
Land Grab: #156 | 980 pts
```

### Detailed Mode Extras
```
Time Remaining: 5d 12h
Underpop Bonus: Active ✓
Emperor: John Doe (@johndoe123)
Reign Duration: 2h 35m
```

## Performance Tips

- **Disable leaderboards** if you don't care about ranking (saves API queries)
- **Enable detailed mode** only when creating showcase profiles
- **Use minimal** for quick daily profiles

## Commands

```bash
/markdown                    # Generate markdown
/markdown settings           # Open settings UI
```

## Support

- Full docs: `docs/PVP_STATS_FEATURE.md`
- ESOUI page: https://www.esoui.com/downloads/info4279-CharacterMarkdown.html
- Bug reports: Use comments on ESOUI page

