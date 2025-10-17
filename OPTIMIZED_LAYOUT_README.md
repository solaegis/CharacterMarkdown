# CharacterMarkdown Optimized Layout

## Overview

An optimized GitHub markdown layout system for the CharacterMarkdown ESO addon that reduces output size by 37-40% while improving visual clarity and information density.

## Files

- **CharacterMarkdown_OptimizedLayout.lua** - Main module with optimized generators
- **QUICK_START.md** - Fast-track integration guide (15 minutes)

## What This Provides

### Size Reduction
- **Before:** ~12,000 characters
- **After:** ~7,500 characters  
- **Savings:** 37-40% reduction

### Key Optimizations

1. **Multi-Column Overview** (7 sections → 1 table)
   - Character info, progression, currencies, riding, inventory, collectibles
   
2. **Side-by-Side Skill Bars** (2 sections → 1 unified table)
   - Front bar and back bar in same view
   
3. **Condensed Equipment** (5 columns → 3 columns)
   - Slot, Item+Set, Quality+Trait
   
4. **Smart Skill Filtering**
   - Maxed skills collapsed to summary
   - Only in-progress skills shown expanded
   
5. **Compact Champion Points**
   - Inline CP skill display
   
6. **Concise Companion**
   - All data visible but compressed

## Quick Start

Read `QUICK_START.md` for 15-minute integration guide.

**Summary:**
1. Add `useOptimizedLayout = true` to settings
2. Load module with `require("CharacterMarkdown_OptimizedLayout")`
3. Add branch logic in `GenerateMarkdown()` function
4. Test with `/reloadui` and `/markdown github`

## Example Output

### Standard Layout (12k chars)
```markdown
## 📊 Character Overview
| Attribute | Value |
|:----------|:------|
| **Race** | Imperial |
| **Class** | Templar |
| **Level** | 50 |
| **Champion Points** | 618 |
... (60+ lines across 7 sections)
```

### Optimized Layout (7.5k chars)
```markdown
## Character Overview
| | | |
|:---|:---|:---|
| **Imperial Templar** | Level 50 | CP 618 |
| ✅ ESO Plus | *Master Wizard* | Summerset |
| 59 SP available | **Achievements:** 11,635 / 71,820 (16%) | |
| **20,701 gold** | 2,027 Tel Var | 59 Transmutes, 12 Event Tickets |
| **Backpack:** 153/180 (85%) | **Bank:** 240/240 (100%) | ✅ Craft Bag |
| **Riding:** ✅ All maxed (60/60/60) | | |
| **Collectibles:** 1,767 items (684 mounts, 664 pets, 305 costumes, 114 houses) | | |
```

## Features

### Visual Style: Hybrid
- ✅ Professional table layouts
- ✅ Strategic emoji use (not excessive)
- ✅ Clean whitespace
- ✅ Better information density

### Space Optimization: Moderate
- ✅ Multi-column tables (3 columns vs 1)
- ✅ Inline summaries (currencies, stats)
- ✅ Smart filtering (only meaningful data)
- ✅ Collapsed repetitive info

### Information Density: High
- ✅ Side-by-side comparisons
- ✅ Combined sections (7-in-1 overview)
- ✅ Condensed tables (5 → 3 columns)
- ✅ Unified displays

### Smart Filtering
- ✅ Hide zero-value currencies
- ✅ Collapse maxed skills
- ✅ Show only in-progress
- ✅ Skip empty sections

## Safety

- ✅ Toggle on/off via setting
- ✅ Falls back to standard layout gracefully
- ✅ Doesn't modify core functionality
- ✅ Easy rollback (just disable setting)

## Troubleshooting

### "Module not found"
**Fix:** Verify `CharacterMarkdown_OptimizedLayout.lua` is in addon directory

### "Output size unchanged"
**Fix:** Check `useOptimizedLayout = true` and format is "github"

### "Sections missing"
**Fix:** Verify section include settings aren't false

### "Links broken"
**Fix:** Ensure link creation functions exist before module loads

## Rollback

If issues occur:

```lua
useOptimizedLayout = false,
```

Then `/reloadui` - everything returns to standard layout.

## Version

**Version:** 2.1.0  
**Last Updated:** October 16, 2025  
**Compatible With:** CharacterMarkdown v2.1.0+

## License

Same as CharacterMarkdown addon
