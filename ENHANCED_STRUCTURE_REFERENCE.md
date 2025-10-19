# Enhanced Markdown Structure Reference

## 📋 Complete Section Order (Non-Discord Format)

This is the final, deduplicated structure of the markdown output:

```
# [Character Name], *[Title]* (if title exists)

## 🎯 Quick Stats                          ← NEW: At-a-glance overview
   3-column table: Combat | Progression | Economy

## ⚠️ Attention Needed                     ← NEW: Smart warnings (auto-hides if empty)
   - Unspent skill/attribute points
   - Bank/backpack capacity warnings
   - Riding training available

## 📊 Character Overview                   ← ENHANCED: Now includes vampire/werewolf/enlightenment
   Level, CP, Class, Race, Alliance
   ESO Plus Status
   Attributes (Mag/Health/Stam)
   Mundus Stone
   Active Buffs
   🧛 Vampire (conditional)
   🐺 Werewolf (conditional)
   ✨ Enlightenment (conditional)
   Location

## 💰 Currency & Resources
   Gold, Tel Var, Transmutes, etc.

## 🎒 Inventory
   Backpack, Bank, Crafting Bag

## 🎨 Collectibles
   Mounts, Pets, Costumes, Houses

---

## 🗺️ DLC & Chapter Access
   ESO Plus status + accessible content

---

## ⭐ Champion Points                      ← ENHANCED: Progress bars + percentages
   Total/Spent/Available
   
   ### Discipline 1 (XXX/660 points) ████░░░░░░░░ XX%
   - Skill list with point counts
   
   ### Discipline 2 (XXX/660 points) ████░░░░░░░░ XX%
   - Skill list with point counts
   
   ### Discipline 3 (XXX/660 points) ████░░░░░░░░ XX%
   - Skill list with point counts

---

## ⚔️ Combat Arsenal                       ← ENHANCED: Better formatting
   ### 🗡️ Front Bar (Main Hand)
   Ultimate + 5 abilities
   
   ### 🔮 Back Bar (Backup)
   Ultimate + 5 abilities

---

## 📈 Combat Statistics
   Resources, Offensive, Defensive stats

---

## 🎒 Equipment                            ← REORGANIZED: Active vs Partial
   ### 🛡️ Armor Sets
   
   #### ✅ Active Sets (5-piece bonuses)
   - Set name (X/5 pieces) - slot list
   
   #### ⚠️ Partial Sets
   - Set name (X/5 pieces) - slot list
   
   ### 📋 Equipment Details
   Full table of all equipped items

---

## 📜 Skill Progression                    ← REORGANIZED: Grouped by status
   ### 🔥 Category Name
   
   #### ✅ Maxed
   Comma-separated list
   
   #### 📈 In Progress (Rank 20-49)
   - Skill: Rank XX ████████░░ XX%
   
   #### 🔰 Early Progress (Rank 1-19)
   - Skill: Rank XX ██░░░░░░░░ XX%
   
   [Repeat for each category]

---

## 👥 Active Companion                     ← ENHANCED: Status warnings
   ### 🧙 [Companion Name]
   
   Status table with warnings:
   - Level (with warning if < 20)
   - Equipment (with outdated count)
   - Abilities (with empty slot count)
   
   Ultimate + Abilities
   Equipment list (with warnings on outdated pieces)

---

[Footer with version info]
```

---

## 🎯 Key Features

### 1. Progressive Disclosure
**Most Important → Detailed**
1. **Quick Stats** - 3-second scan
2. **Attention Needed** - Action items
3. **Character Overview** - Core identity
4. **Detailed Sections** - Deep dive

### 2. Smart Conditionals
**Only Show When Relevant**
- Title in header (if exists)
- Attention Needed section (if any warnings)
- Vampire row (if vampire)
- Werewolf row (if werewolf)
- Enlightenment row (if active)
- Empty ability slot warnings (if any)
- Outdated companion gear (if any)

### 3. Visual Hierarchy
**Easy Scanning**
- ✅ Green checks = Complete/Active
- ⚠️ Yellow triangles = Warnings/Partial
- 📈 Up arrows = In Progress
- 🔰 Shields = Early Progress
- ████░░░░░░ Progress bars

### 4. Logical Grouping
**By Status, Not Alphabetical**
- **Sets**: Active (5-piece) → Partial
- **Skills**: Maxed → In Progress → Early
- **Warnings**: All actionable items together

### 5. Zero Duplication
**Single Source of Truth**
- Each data point appears exactly once
- Conditional fields only when relevant
- Related data grouped logically

---

## 📊 Section Purposes

| Section | Purpose | Always Visible? |
|:--------|:--------|:---------------:|
| **Header** | Character name + title | ✅ |
| **Quick Stats** | Fast overview, key metrics | ✅ |
| **Attention Needed** | Action items requiring attention | Conditional |
| **Character Overview** | Core character identity & status | ✅ |
| **Currency** | Economic resources | ✅ |
| **Inventory** | Storage capacity | ✅ |
| **Collectibles** | Collection counts | ✅ |
| **DLC Access** | Available content | ✅ |
| **Champion Points** | CP allocation with progress | ✅ |
| **Combat Arsenal** | Skill bar setup | ✅ |
| **Combat Stats** | Current combat values | ✅ |
| **Equipment** | Gear sets & items | ✅ |
| **Skill Progression** | All skill lines with progress | ✅ |
| **Active Companion** | Companion status (if active) | Conditional |

---

## 🔢 Typical Line Counts

### Minimal Character (Fresh, no warnings):
- Header: 1 line
- Quick Stats: 5 lines
- Attention Needed: 0 lines (hidden)
- Character Overview: ~10 lines
- Other sections: ~150-200 lines
- **Total: ~165-215 lines**

### Average Character (like Masisi):
- Header: 1 line
- Quick Stats: 5 lines
- Attention Needed: 3 lines
- Character Overview: ~12 lines
- Other sections: ~250-300 lines
- **Total: ~270-320 lines**

### Endgame Character (max CP, vampire, full collections):
- Header: 1 line
- Quick Stats: 5 lines
- Attention Needed: 1-5 lines
- Character Overview: ~14 lines
- Other sections: ~300-400 lines
- **Total: ~320-425 lines**

---

## 🎨 Visual Examples

### Header Examples
```markdown
# Masisi
# Masisi, *Daedric Lord Slayer*
# Tanlorin, *Undaunted*
```

### Quick Stats Example
```markdown
| Combat | Progression | Economy |
|:-------|:------------|:--------|
| **Build**: Magicka DPS | **CP**: 627 (14 available) | **Gold**: 88,753 |
| **Primary Sets**: Fortified Brass + Morihaus | **Skill Points**: 3 available | **Bank**: ⚠️ **FULL** |
| **Attributes**: 49 / 15 / 0 | **Achievements**: 16% | **Transmutes**: 59 |
```

### Attention Needed Example
```markdown
## ⚠️ Attention Needed

- 🎯 **3 skill points available** - Ready to spend
- 🏦 **Bank is full** (240/240) - Clear space or items will be lost
```

### Character Overview with Vampire Example
```markdown
| **Level** | 50 |
| **Champion Points** | 627 |
| **Class** | Dragonknight |
| **Race** | Imperial |
| **Alliance** | Ebonheart Pact |
| **ESO Plus** | ✅ Active |
| **🎯 Attributes** | Magicka: 49 • Health: 15 • Stamina: 0 |
| **🪨 Mundus Stone** | The Atronach |
| **🧛 Vampire** | Stage 2 |
| **Location** | Summerset |
```

### Champion Points Example
```markdown
### 💪 Fitness (204/660 points) ████░░░░░░░░ 30%

- **Hero's Vigor**: 20 points
- **Bastion**: 9 points
- **Rejuvenation**: 50 points
```

### Skills Example
```markdown
### ⚒️ Craft

#### ✅ Maxed
**Blacksmithing**, **Clothing**, **Provisioning**, **Woodworking**

#### 📈 In Progress
- **Enchanting**: Rank 19 ██████████ 98%
- **Jewelry Crafting**: Rank 18 ████████░░ 94%

#### 🔰 Early Progress
- **Alchemy**: Rank 7 █████████░ 92%
```

### Equipment Example
```markdown
#### ✅ Active Sets (5-piece bonuses)

- ✅ **Fortified Brass** (6/5 pieces) - Head, Chest, Shoulders, Legs, Feet, Waist
- ✅ **Hide of Morihaus** (5/5 pieces) - Neck, Main Hand, Off Hand, Ring 1, Ring 2

#### ⚠️ Partial Sets

- ⚠️ **Armor of the Seducer** (3/5 pieces) - Hands, Waist, Backup Main Hand
```

---

## 🚀 Usage Tips

### For Players:
1. **Daily check**: Quick Stats + Attention Needed (top 2 sections)
2. **Gear planning**: Equipment → Active/Partial sets
3. **Skill planning**: Skills → In Progress section
4. **CP allocation**: Champion Points → Available count + progress bars

### For Build Sharers:
1. **Build identity**: Header + Quick Stats + Combat Arsenal
2. **Gear setup**: Equipment → Active Sets + Details table
3. **Skill priorities**: Skills → Maxed section shows focus

### For Alt Management:
1. **Companion status**: Check level + gear warnings
2. **Bank warning**: Attention Needed section
3. **Progress tracking**: Skills In Progress bars

---

*This structure represents the final, optimized markdown output format*
*Zero duplication • Smart conditionals • Professional presentation*

