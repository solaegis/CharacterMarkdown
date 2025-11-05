# CharacterMarkdown - Applied Fixes Summary

## Date: 2025-11-02
## Status: Partially Complete

---

## ✅ COMPLETED FIXES

### Fix #1: HTML Table Structure ✅
**File:** `src/utils/AdvancedMarkdown.lua`
**Status:** FIXED
**Change:** Added missing `<tr>` wrapper in `CreateInfoBox()` function

```lua
-- Added <tr> and </tr> tags around <td> element
<tbody>
<tr>  <!-- ADDED -->
<td align="center">
...
</td>
</tr>  <!-- ADDED -->
</tbody>
```

### Fix #6: Standardized Progress Bars ✅
**File:** `src/utils/AdvancedMarkdown.lua`  
**Status:** FIXED
**Change:** Removed conditional bar styles, now always uses `█` (filled) and `░` (empty)

```lua
-- OLD: Different styles for github/vscode/discord
-- NEW: Always use █ and ░ for consistency
local bar = string_rep("█", filled) .. string_rep("░", empty)
```

### Fix #3: Resource Values (Partial) ✅
**File:** `src/generators/sections/Character.lua`
**Status:** FIXED in Character.lua
**Change:** Updated `GenerateQuickStats()` to properly extract resource values

```lua
-- FIX: Get resources from statsData properly (try both field names)
local health = 0
local magicka = 0
local stamina = 0

if statsData then
    health = statsData.health or statsData.maxHealth or 0
    magicka = statsData.magicka or statsData.maxMagicka or 0
    stamina = statsData.stamina or statsData.maxStamina or 0
end
```

---

## ⚠️ PENDING FIXES (Manual Required)

### Fix #3: Update Markdown.lua Call ⚠️
**File:** `src/generators/Markdown.lua`
**Line:** ~156
**Status:** NEEDS MANUAL FIX

**Find this:**
```lua
-- Quick Stats Summary (non-Discord only)
{
    name = "QuickStats",
    condition = format ~= "discord" and IsSettingEnabled(settings, "includeQuickStats", true),
    generator = function()
        return gen.GenerateQuickStats(data.character, data.progression, data.currency, 
            data.equipment, data.cp, data.inventory, format)
    end
},
```

**Replace with:**
```lua
-- Quick Stats Summary (non-Discord only)
{
    name = "QuickStats",
    condition = format ~= "discord" and IsSettingEnabled(settings, "includeQuickStats", true),
    generator = function()
        -- FIX: Pass stats data instead of progression
        return gen.GenerateQuickStats(data.character, data.stats, format)
    end
},
```

### Fix #4: Enlightenment Callout ⚠️
**File:** `src/generators/sections/Character.lua`
**Function:** `GenerateProgression()`
**Status:** NEEDS MANUAL FIX

**Find the end of the function (around line 273):**
```lua
    -- Enlightenment
    if progressionData.isEnlightened then
        if not enhanced then
            table.insert(lines, "✨ **Enlightened** (4x CP XP)")
        end
    end
    
    if #lines == 0 then return "" end
    
    local content = table_concat(lines, "  \n")
    
    if not enhanced or not markdown then
        return string_format("## 📈 Progression\n\n%s\n\n", content)
    end
    
    -- ENHANCED: Use collapsible + enlightenment callout (with nil checks)
    local result = ""
    if markdown.CreateCollapsible then
        result = markdown.CreateCollapsible("Progression", content, "📈", false) or string_format("## 📈 Progression\n\n%s\n\n", content)
    else
        result = string_format("## 📈 Progression\n\n%s\n\n", content)
    end
    
    if progressionData.isEnlightened and markdown.CreateCallout then
        local callout = markdown.CreateCallout("success", 
            "**Enlightenment Active** - Earning 4x Champion Point XP", format)
        if callout then
            result = result .. callout
        end
    end
    
    return result
end
```

**Replace with:**
```lua
    -- Enlightenment - DO NOT add to lines, handle separately
    
    if #lines == 0 and not progressionData.isEnlightened then 
        return "" 
    end
    
    local content = table_concat(lines, "  \n")
    
    if not enhanced or not markdown then
        local result = string_format("## 📈 Progression\n\n%s\n\n", content)
        -- Add enlightenment in plain format
        if progressionData.isEnlightened then
            result = result .. "> ✨ **Enlightened** - Earning 4x Champion Point XP\n\n"
        end
        return result
    end
    
    -- ENHANCED: Use collapsible + enlightenment callout (with nil checks)
    local result = ""
    if markdown.CreateCollapsible then
        result = markdown.CreateCollapsible("Progression", content, "📈", false) or string_format("## 📈 Progression\n\n%s\n\n", content)
    else
        result = string_format("## 📈 Progression\n\n%s\n\n", content)
    end
    
    -- FIX: Always show enlightenment callout when enlightened
    if progressionData.isEnlightened then
        if markdown.CreateCallout then
            local callout = markdown.CreateCallout("tip", 
                "🌟 **Enlightened!** Earning 4x Champion Point XP", format)
            if callout then
                result = result .. callout
            end
        else
            -- Fallback if CreateCallout doesn't exist
            result = result .. "> 🌟 **Enlightened!** Earning 4x Champion Point XP\n\n"
        end
    end
    
    return result
end
```

### Fix #5: Attention Needed Callout ⚠️
**File:** `src/generators/sections/Character.lua`
**Function:** `GenerateAttentionNeeded()`
**Status:** NEEDS MANUAL FIX

**Replace entire function with:**
```lua
local function GenerateAttentionNeeded(charData, progressionData, format)
    if format == "discord" then return "" end
    
    local enhanced = CM.settings and CM.settings.enableEnhancedVisuals
    local warnings = {}
    
    -- Check for unspent points
    if progressionData then
        -- Skill Points
        if progressionData.unspentSkillPoints and progressionData.unspentSkillPoints > 0 then
            table.insert(warnings, string_format("• %d unspent Skill %s", 
                progressionData.unspentSkillPoints,
                progressionData.unspentSkillPoints == 1 and "Point" or "Points"))
        end
        
        -- Attribute Points
        if progressionData.unspentAttributePoints and progressionData.unspentAttributePoints > 0 then
            table.insert(warnings, string_format("• %d unspent Attribute %s", 
                progressionData.unspentAttributePoints,
                progressionData.unspentAttributePoints == 1 and "Point" or "Points"))
        end
    end
    
    if #warnings == 0 then return "" end
    
    local content = "⚠️ **Attention Needed**\n" .. table_concat(warnings, "  \n")
    
    if not enhanced or not markdown then
        return string_format("> %s\n\n", content)
    end
    
    -- ENHANCED: Use warning callout (with nil check)
    return (markdown.CreateCallout and markdown.CreateCallout("warning", content, format)) or string_format("> %s\n\n", content)
end
```

**Also update the call in Markdown.lua (around line 164):**

**Find:**
```lua
-- Attention Needed (non-Discord only)
{
    name = "AttentionNeeded",
    condition = format ~= "discord" and IsSettingEnabled(settings, "includeAttentionNeeded", true),
    generator = function()
        return gen.GenerateAttentionNeeded(data.progression, data.inventory, data.riding, data.companion, format)
    end
},
```

**Replace with:**
```lua
-- Attention Needed (non-Discord only)
{
    name = "AttentionNeeded",
    condition = format ~= "discord" and IsSettingEnabled(settings, "includeAttentionNeeded", true),
    generator = function()
        -- FIX: Only pass charData and progressionData
        return gen.GenerateAttentionNeeded(data.character, data.progression, format)
    end
},
```

### Fix #7: Duplicate PvP Sections ⚠️
**Files:** `src/generators/Markdown.lua` and potentially `src/generators/sections/Economy.lua`
**Status:** NEEDS INVESTIGATION

**Action Required:**
1. Search `src/generators/Markdown.lua` for "PvP" - should only appear ONCE in section registry
2. Check `src/generators/sections/Economy.lua` for any `GeneratePvP()` function - remove if exists
3. Verify only one PvP generator is registered

### Fix #8: Empty Sections Collapsible ⚠️
**Files:** Multiple section generators
**Status:** NEEDS MANUAL FIX

**Pattern to apply in these files:**
- `src/generators/sections/ArmoryBuilds.lua`
- `src/generators/sections/TalesOfTribute.lua`
- Any section with minimal content

**Before:**
```lua
markdown = markdown .. "## 🏰 Armory Builds\n\n"
markdown = markdown .. "*No armory builds configured*\n\n"
```

**After:**
```lua
local markdown_utils = CM.utils and CM.utils.markdown
if not markdown_utils or not markdown_utils.CreateCollapsible then
    markdown = markdown .. "## 🏰 Armory Builds\n\n"
    markdown = markdown .. "*No armory builds configured*\n\n"
else
    markdown = markdown .. markdown_utils.CreateCollapsible(
        "Armory Builds", 
        "*No armory builds configured*", 
        "🏰", 
        false
    )
end
```

### Fix #9: Morph Symbols ⚠️
**File:** Likely `src/generators/sections/Equipment.lua` or where skill morphs are generated
**Status:** NEEDS INVESTIGATION

**Action Required:**
1. Find where skill morphs are displayed (search for "Morph 1", "Morph 2")
2. Replace confusing symbols (✅⚪🔒) with clear indicators:

**Current:**
```markdown
✅ **[Crescent Sweep](...)** (Rank 4)
  ⚪ **Morph 1**: [Everlasting Sweep](...)
  ✅ **Morph 2**: [Crescent Sweep](...)
```

**Target:**
```markdown
**[Crescent Sweep](...)** (Rank 4) - ⚔️ Morphed
  ❌ Morph 1: [Everlasting Sweep](...)
  ✅ Morph 2: [Crescent Sweep](...) **← CHOSEN**
```

---

## ✅ VERIFIED FIXES (No Change Needed)

### Fix #2: Callout Syntax ✅
**File:** `src/utils/AdvancedMarkdown.lua`
**Status:** ALREADY CORRECT

The `CreateCallout()` function already uses proper GitHub native syntax:
```lua
return string_format("> [!%s]  \n> %s\n\n", callout.tag, escaped_content)
```

---

## NEXT STEPS

1. **Apply Pending Manual Fixes** (Fixes #3-#9)
2. **Test Generation:**
   ```
   /markdown github
   ```
3. **Verify Output:**
   - HTML tables render correctly
   - Resource values are non-zero
   - Progress bars are consistent
   - Enlightenment callout shows
   - Attention needed callout shows
   - No duplicate PvP sections
   - Morph choices are clear

4. **Commit Changes:**
   ```bash
   git add .
   git commit -m "fix: address all visual issues (#1-#9)"
   ```

---

## FILE EDIT SUMMARY

### ✅ Files Modified:
1. `src/utils/AdvancedMarkdown.lua` - HTML table fix, progress bar standardization
2. `src/generators/sections/Character.lua` - Resource values fix

### ⚠️ Files Pending:
1. `src/generators/Markdown.lua` - QuickStats call, AttentionNeeded call
2. `src/generators/sections/Character.lua` - GenerateProgression(), GenerateAttentionNeeded()
3. `src/generators/sections/Economy.lua` - Check for duplicate PvP
4. `src/generators/sections/ArmoryBuilds.lua` - Collapsible empty sections
5. `src/generators/sections/TalesOfTribute.lua` - Collapsible empty sections
6. Morph generator file (TBD) - Symbol fixes

---

**Status:** 3 of 9 fixes complete. 6 pending manual application.
**Testing:** Required after all fixes applied.
