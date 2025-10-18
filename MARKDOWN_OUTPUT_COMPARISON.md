# Markdown Output Comparison

## Before Changes

```markdown
# Pelatiah

**Imperial Dragonknight**  
**Level 50** • **CP 627** (Craft 200 • Warfare 200 • Fitness 199)  
*Ebonheart Pact*

---

## 📊 Character Overview

| Attribute | Value |
|:----------|:------|
| **Level** | 50 |
| **Champion Points** | 627 |
| **Class** | [Dragonknight](https://en.uesp.net/wiki/Online:Dragonknight) |
| **Race** | [Imperial](https://en.uesp.net/wiki/Online:Imperial) |
| **Alliance** | [Ebonheart Pact](https://en.uesp.net/wiki/Online:Ebonheart_Pact) |
...
```

**Issue:** The race, class, level, CP, and alliance information appears twice:
1. First in a standalone block after the character name
2. Again in the Character Overview table

## After Changes

```markdown
# Pelatiah

## 📊 Character Overview

| Attribute | Value |
|:----------|:------|
| **Level** | 50 |
| **Champion Points** | 627 |
| **Class** | [Dragonknight](https://en.uesp.net/wiki/Online:Dragonknight) |
| **Race** | [Imperial](https://en.uesp.net/wiki/Online:Imperial) |
| **Alliance** | [Ebonheart Pact](https://en.uesp.net/wiki/Online:Ebonheart_Pact) |
...
```

**Improvement:** Character information now appears only once, in the organized table format. The document is cleaner and more professional.

## Window UI Changes

### Before (3 Buttons)
```
┌─────────────────────────────────────────────┐
│  [Select All]  [Dismiss]  [ReloadUI]       │
└─────────────────────────────────────────────┘
```

### After (4 Buttons)
```
┌────────────────────────────────────────────────────────┐
│  [Regenerate]  [Select All]  [Dismiss]  [ReloadUI]    │
└────────────────────────────────────────────────────────┘
```

## Regenerate Button Workflow

```
User opens window with /markdown
         ↓
   Markdown generated
         ↓
User makes character changes
(equips new gear, allocates CP, etc.)
         ↓
User clicks [Regenerate] button
         ↓
   Window clears momentarily
         ↓
New markdown generated with current data
         ↓
Text automatically selected
         ↓
User presses Ctrl+C to copy
```

## Key Benefits

1. **No Duplicate Information** - Each piece of character data appears exactly once
2. **Cleaner Output** - More professional markdown document structure
3. **Easy Updates** - Regenerate button allows refreshing data without closing window
4. **Preserved Format** - Regeneration uses the same format as original (github/discord/vscode)
5. **Better UX** - Automatic text selection after regeneration

## Discord Format (Unchanged)

The Discord format keeps its compact header style as it was designed for Discord's markdown limitations:

```markdown
# **Pelatiah**
Imperial Dragonknight • L50 • CP627 (Craft 200 • Warfare 200 • Fitness 199) • 👑 ESO Plus
*Ebonheart Pact*
...
```

This format is optimized for Discord and doesn't use tables, so it wasn't affected by these changes.
