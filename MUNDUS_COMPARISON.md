# Mundus Stone Display - Before & After Comparison

## Format: GitHub / VS Code

### ❌ BEFORE
```markdown
## 📊 Character Overview

| Attribute | Value |
|:----------|:------|
| **Race** | High Elf |
| **Class** | Sorcerer |
| **Alliance** | Aldmeri Dominion |
| **Level** | 50 |
| **Champion Points** | 627 |
| **ESO Plus** | ✅ Active |
| **Role** | ⚔️ DPS |
| **Location** | Stros M'Kai |
| **🎯 Attributes** | Magicka: 20,000 • Health: 18,000 • Stamina: 15,000 |

---

## 🗺️ DLC & Chapter Access
[DLC content here]

---

## 🪨 Mundus Stone

✅ **Active:** [The Thief](https://en.uesp.net/wiki/Online:The_Thief_(Mundus_Stone))

---
```

### ✅ AFTER
```markdown
## 📊 Character Overview

| Attribute | Value |
|:----------|:------|
| **Race** | High Elf |
| **Class** | Sorcerer |
| **Alliance** | Aldmeri Dominion |
| **Level** | 50 |
| **Champion Points** | 627 |
| **ESO Plus** | ✅ Active |
| **🪨 Mundus Stone** | [The Thief](https://en.uesp.net/wiki/Online:The_Thief_(Mundus_Stone)) |
| **Role** | ⚔️ DPS |
| **Location** | Stros M'Kai |
| **🎯 Attributes** | Magicka: 20,000 • Health: 18,000 • Stamina: 15,000 |

---

## 🗺️ DLC & Chapter Access
[DLC content here]

---
```

**Changes:**
- ✅ Mundus moved INTO Overview table (after ESO Plus status)
- ✅ Standalone "Mundus Stone" section removed
- ✅ One less section divider (`---`)
- ✅ More compact layout

---

## Format: Discord

### NO CHANGE (Discord keeps standalone format)

```
# **Pelatiah**
High Elf Sorcerer • L50 • CP627 • 👑 ESO Plus
*Aldmeri Dominion*

**Mundus:** The Thief

**Progression:**
• Achievement Score: 15,432 / 35,000 (44%)
• Enlightenment: 250,000 / 4,800,000 (5%)
```

**Reasoning:** Discord's compact format benefits from labeled sections for mobile readability

---

## Row Order in Overview Table

```
1. Race
2. Class  
3. Alliance
4. Level
5. Champion Points
6. ESO Plus
7. Title (if present)
8. 🪨 Mundus Stone (NEW - if active)
9. Role (if includeRole enabled)
10. Location (if includeLocation enabled)
11. Attributes (if includeAttributes enabled)
12. Active Buffs (if includeBuffs enabled)
```

**Placement Logic:**
- Mundus placed after **static attributes** (race, class, level, CP, ESO Plus, title)
- Mundus placed before **variable/optional attributes** (role, location, attributes, buffs)
- This groups "character configuration" together: race, class, and mundus are all choices that define your build

---

## Benefits

### 1. Reduced Visual Clutter
**Before:** 5 sections between Overview and Champion Points  
**After:** 4 sections (1 less standalone section)

### 2. Improved Scannability
Users can see all core character config in one table:
- Race ✓
- Class ✓
- Mundus ✓
- Role ✓
- Location ✓

### 3. Better Mobile Experience
Fewer section headers = less scrolling on narrow screens

### 4. Semantic Grouping
Mundus is a "build choice" like race/class, not a "system feature" like DLC Access

---

## Edge Cases

### Case 1: No Mundus Stone Active
```markdown
| **ESO Plus** | ✅ Active |
| **Role** | ⚔️ DPS |
```
✅ Mundus row is simply omitted (no empty row, no warning message)

### Case 2: No Title Set
```markdown
| **ESO Plus** | ✅ Active |
| **🪨 Mundus Stone** | The Lover |
| **Role** | ⚔️ DPS |
```
✅ Title row omitted, Mundus shows normally

### Case 3: Role/Location Disabled
```markdown
| **🪨 Mundus Stone** | The Serpent |
| **🎯 Attributes** | Magicka: 25,000 • Health: 18,000 • Stamina: 12,000 |
```
✅ Mundus shows regardless of other setting states

---

## Testing Scenarios

### Scenario 1: All Features Enabled
- [ ] Mundus appears in Overview table between ESO Plus and Role
- [ ] No standalone Mundus section exists
- [ ] Table formatting is correct

### Scenario 2: No Mundus Active
- [ ] Mundus row does not appear
- [ ] No error or warning shown
- [ ] Table flows naturally from ESO Plus to Role

### Scenario 3: Minimal Settings
All optional features disabled (role, location, attributes, buffs):
- [ ] Mundus still shows if active
- [ ] Table ends with Mundus row
- [ ] Next section starts properly after table

### Scenario 4: Discord Format
- [ ] Standalone Mundus section still exists
- [ ] Formatted as: `**Mundus:** The Thief`
- [ ] Appears after character header

### Scenario 5: Character With Title
- [ ] Title shows before Mundus
- [ ] Order: ESO Plus → Title → Mundus → Role

### Scenario 6: Long Mundus Name
- [ ] "The Atronach" and other long names render correctly
- [ ] No table width issues
- [ ] Link still works
