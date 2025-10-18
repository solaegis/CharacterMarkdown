# Pending Changes - User Requested

## Changes to Implement

### 1. Remove "Other: " Prefix from Buffs ✅
**Location:** `GenerateOverview()` function  
**Line:** ~155

**Current:**
```lua
table.insert(buffParts, "Other: " .. table.concat(otherBuffs, ", "))
```

**Change to:**
```lua
table.insert(buffParts, table.concat(otherBuffs, ", "))
```

**Rationale:** "Other: " prefix adds no value when food/potion already labeled

---

### 2. Move Riding Skills into Character Overview ✅
**Action:** Integrate riding skills as rows in Overview table

**Current Structure:**
```
## 🐎 Riding Skills
| Skill | Progress | Status |
```

**New Structure (in Overview table):**
```
| **🐎 Riding** | Speed: 60/60 ✅ • Stamina: 60/60 ✅ • Capacity: 60/60 ✅ |
```

**Changes Required:**
1. Update `GenerateOverview()` - add riding data parameter & row
2. Update main flow - pass riding data to Overview
3. Keep `GenerateRidingSkills()` for Discord only
4. Remove standalone section for GitHub/VSCode

---

### 3. Move PvP into Character Overview ✅
**Action:** Integrate PvP rank as row in Overview table

**Current Structure:**
```
## ⚔️ PvP Information
| Alliance War Rank | Volunteer Grade 1 (Rank 1) |
```

**New Structure (in Overview table):**
```
| **⚔️ Alliance War Rank** | Volunteer Grade 1 (Rank 1) |
```

**Changes Required:**
1. Update `GenerateOverview()` - add pvp data parameter & row
2. Update main flow - pass pvp data to Overview
3. Keep `GeneratePvP()` for Discord only
4. Remove standalone section for GitHub/VSCode

---

### 4. Fix Default Format Setting ✅
**Problem:** Default format dropdown appears empty in settings UI

**Location:** `src/settings/Panel.lua` - line ~93

**Current:**
```lua
getFunc = function() return CharacterMarkdownSettings.currentFormat end,
```

**Issue:** Settings may not initialize `currentFormat` on first load

**Fix:** Add fallback default
```lua
getFunc = function() 
    return CharacterMarkdownSettings.currentFormat or "github" 
end,
```

---

### 5. Fix "Generate Profile Now" Button ✅
**Problem:** Button doesn't work - no response when clicked

**Location:** `src/settings/Panel.lua` - line ~450+

**Current:**
```lua
func = function()
    if CharacterMarkdown and CharacterMarkdown.CommandHandler then
        CharacterMarkdown.CommandHandler("")
    end
end,
```

**Issue:** Command handler needs proper invocation

**Diagnose:** Need to check:
1. Does `CharacterMarkdown.CommandHandler` exist?
2. What are the correct parameters?
3. Does it need to spawn UI window?

**Likely Fix:** 
```lua
func = function()
    if CharacterMarkdown and CharacterMarkdown.ui and CharacterMarkdown.ui.ShowWindow then
        CharacterMarkdown.ui.ShowWindow()
    elseif SLASH_COMMANDS["/markdown"] then
        SLASH_COMMANDS["/markdown"]("") 
    end
end,
```

---

### 6. Add "Enable All" Button ✅
**Action:** Add button to settings that sets all boolean settings to true

**Location:** `src/settings/Panel.lua` - Actions section

**Implementation:**
```lua
table.insert(options, {
    type = "button",
    name = "Enable All Sections",
    tooltip = "Turn on all content sections (Champion Points, Equipment, Currency, etc.)",
    func = function()
        -- Core sections
        CharacterMarkdownSettings.includeChampionPoints = true
        CharacterMarkdownSettings.includeSkillBars = true
        CharacterMarkdownSettings.includeSkills = true
        CharacterMarkdownSettings.includeEquipment = true
        CharacterMarkdownSettings.includeCompanion = true
        CharacterMarkdownSettings.includeCombatStats = true
        CharacterMarkdownSettings.includeBuffs = true
        CharacterMarkdownSettings.includeAttributes = true
        CharacterMarkdownSettings.includeRole = true
        CharacterMarkdownSettings.includeLocation = true
        
        -- Extended sections
        CharacterMarkdownSettings.includeDLCAccess = true
        CharacterMarkdownSettings.includeCurrency = true
        CharacterMarkdownSettings.includeProgression = true
        CharacterMarkdownSettings.includeRidingSkills = true
        CharacterMarkdownSettings.includeInventory = true
        CharacterMarkdownSettings.includePvP = true
        CharacterMarkdownSettings.includeCollectibles = true
        CharacterMarkdownSettings.includeCrafting = true
        
        -- Links
        CharacterMarkdownSettings.enableAbilityLinks = true
        CharacterMarkdownSettings.enableSetLinks = true
        
        d("[CharacterMarkdown] ✅ All sections enabled!")
        SCENE_MANAGER:Show("gameMenuInGame")  -- Refresh UI
    end,
    width = "half",
})
```

---

## Testing Checklist

### Buffs
- [ ] Verify "Other: " removed when only other buffs present
- [ ] Verify food/potion labels still work
- [ ] Verify multiple buffs display correctly

### Riding Skills
- [ ] Verify riding shows in Overview for GitHub/VS Code
- [ ] Verify format: `Speed: 60/60 ✅ • Stamina: 60/60 ✅ • Capacity: 60/60 ✅`
- [ ] Verify Discord still has standalone section
- [ ] Verify training indicator works

### PvP
- [ ] Verify PvP shows in Overview for GitHub/VS Code  
- [ ] Verify format: `Volunteer Grade 1 (Rank 1)`
- [ ] Verify campaign shows if present
- [ ] Verify Discord still has standalone section

### Settings
- [ ] Verify default format shows "GitHub" on first load
- [ ] Verify "Generate Profile Now" button works
- [ ] Verify "Enable All" button sets all toggles to true
- [ ] Verify UI refreshes after "Enable All"

---

## Implementation Order

1. ✅ Remove "Other: " prefix (simple text change)
2. ✅ Move Riding Skills into Overview
3. ✅ Move PvP into Overview  
4. ✅ Fix default format setting
5. ✅ Fix "Generate Profile Now" button
6. ✅ Add "Enable All" button

---

## Final Row Order in Overview Table

```
1. Race
2. Class
3. Alliance
4. Level
5. Champion Points
6. ESO Plus
7. Title (if present)
8. 🪨 Mundus Stone (if active)
9. Role (if enabled)
10. Location (if enabled)
11. Attributes (if enabled)
12. Active Buffs (if enabled)
13. 🐎 Riding Skills (NEW - if enabled)
14. ⚔️ Alliance War Rank (NEW - if PvP enabled)
```

**Placement Rationale:**
- Riding/PvP placed at END of Overview table
- After dynamic attributes (buffs, location)
- Still within "character status" context
- Easy to scan as last items before sections
