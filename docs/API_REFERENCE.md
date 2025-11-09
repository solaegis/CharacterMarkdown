# API Reference

## ESO Lua API Patterns

### Character Data

```lua
-- Identity
GetUnitName("player")              -- Character name
GetUnitRace("player")              -- Race ID → pass to GetRaceName()
GetUnitClass("player")             -- Class ID → pass to GetClassName()
GetUnitLevel("player")             -- Current level (1-50)
GetPlayerChampionPointsEarned()    -- Total CP earned

-- Alliance
local alliance = GetUnitAlliance("player")  -- Alliance ID
local allianceName = GetAllianceName(alliance)

-- Attributes
GetAttributeSpentPoints(ATTRIBUTE_HEALTH)
GetAttributeSpentPoints(ATTRIBUTE_MAGICKA)
GetAttributeSpentPoints(ATTRIBUTE_STAMINA)
```

### Combat Stats

```lua
-- Resources
GetPlayerStat(STAT_HEALTH_MAX)
GetPlayerStat(STAT_MAGICKA_MAX)
GetPlayerStat(STAT_STAMINA_MAX)

-- Power
GetPlayerStat(STAT_SPELL_POWER)
GetPlayerStat(STAT_WEAPON_POWER)

-- Critical
GetPlayerStat(STAT_SPELL_CRITICAL)
GetPlayerStat(STAT_CRITICAL_STRIKE)

-- Resistances
GetPlayerStat(STAT_PHYSICAL_RESIST)
GetPlayerStat(STAT_SPELL_RESIST)
```

### Equipment

```lua
-- Slot constants
EQUIP_SLOT_HEAD = 0
EQUIP_SLOT_NECK = 1
EQUIP_SLOT_CHEST = 2
-- ... through EQUIP_SLOT_BACKUP_POISON = 17

-- Get item in slot
local itemLink = GetItemLink(BAG_WORN, slotIndex)

-- Item details
local hasSet, setName = GetItemLinkSetInfo(itemLink)
local quality = GetItemLinkQuality(itemLink)
local trait = GetItemTrait(BAG_WORN, slotIndex)
local traitName = GetString("SI_ITEMTRAITTYPE", trait)
```

### Skills & Abilities

```lua
-- Skill bars
for slotIndex = 3, 8 do  -- Slots 3-8 (1-2 reserved)
    local abilityId = GetSlotBoundId(slotIndex, HOTBAR_CATEGORY_PRIMARY)
    local name = GetAbilityName(abilityId)
end

-- Skill lines
for skillType = 1, GetNumSkillTypes() do
    for lineIndex = 1, GetNumSkillLines(skillType) do
        local name, rank = GetSkillLineInfo(skillType, lineIndex)
        
        for abilityIndex = 1, GetNumSkillAbilities(skillType, lineIndex) do
            local abilityName = GetSkillAbilityInfo(skillType, lineIndex, abilityIndex)
        end
    end
end
```

### Champion Points

```lua
-- Disciplines
CHAMPION_DISCIPLINE_TYPE_WORLD = 1  -- Craft
CHAMPION_DISCIPLINE_TYPE_COMBAT = 2 -- Warfare
CHAMPION_DISCIPLINE_TYPE_CONDITIONING = 3 -- Fitness

-- Points in discipline
GetNumSpentChampionPoints(disciplineType)
GetChampionPointsInDiscipline(disciplineType)

-- Skills in discipline
for skillIndex = 1, GetNumChampionDisciplineSkills(disciplineType) do
    local skillId = GetChampionSkillId(disciplineType, skillIndex)
    local name = GetChampionSkillName(skillId)
    local points = GetNumPointsSpentOnChampionSkill(skillId)
end
```

### Currency

```lua
-- Currency types
CURT_MONEY = 1              -- Gold
CURT_ALLIANCE_POINTS = 2    -- AP
CURT_TELVAR_STONES = 3      -- Tel Var
CURT_WRIT_VOUCHERS = 11     -- Writ Vouchers
CURT_CHAOTIC_CREATIA = 16   -- Transmutes

-- Get amount
GetCurrencyAmount(currencyType, CURRENCY_LOCATION_CHARACTER)
```

---

## Safe API Calls

### Always Use pcall

```lua
-- BAD - Can crash addon
local stat = GetPlayerStat(STAT_HEALTH_MAX)

-- GOOD - Handles errors
local success, stat = pcall(GetPlayerStat, STAT_HEALTH_MAX)
if not success then
    stat = 0  -- Default value
end

-- BEST - Helper function
local function SafeGetPlayerStat(statType, default)
    local success, value = pcall(GetPlayerStat, statType)
    return success and value or (default or 0)
end
```

### Nested API Calls

```lua
-- BAD - No error handling
local alliance = GetUnitAlliance("player")
local name = GetAllianceName(alliance)

-- GOOD - Check intermediate results
local success, alliance = pcall(GetUnitAlliance, "player")
if success and alliance then
    local success2, name = pcall(GetAllianceName, alliance)
    if success2 then
        -- Use name
    end
end
```

---

## Performance Optimization

### Cache Global Functions

```lua
-- At module level
local GetPlayerStat = GetPlayerStat
local GetItemLink = GetItemLink
local string_format = string.format
local table_insert = table.insert

-- Use cached versions
local health = GetPlayerStat(STAT_HEALTH_MAX)
```

### Efficient String Building

```lua
-- SLOW - Creates many temp strings
local result = ""
for i = 1, 1000 do
    result = result .. "Line " .. i .. "\n"
end

-- FAST - Single allocation
local parts = {}
for i = 1, 1000 do
    table_insert(parts, "Line ")
    table_insert(parts, tostring(i))
    table_insert(parts, "\n")
end
local result = table.concat(parts)
```

### Event Filtering

```lua
-- BAD - Processes every inventory update
EVENT_MANAGER:RegisterForEvent("MyAddon", EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
    function(event, bagId, slotIndex)
        UpdateInventory()  -- Called hundreds of times
    end
)

-- GOOD - Filter and throttle
local updatePending = false
EVENT_MANAGER:RegisterForEvent("MyAddon", EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
    function(event, bagId, slotIndex)
        if bagId ~= BAG_BACKPACK then return end
        
        if not updatePending then
            updatePending = true
            zo_callLater(function()
                UpdateInventory()
                updatePending = false
            end, 100)
        end
    end
)
```

---

## UI Controls

### EditBox

```lua
-- Configure
editBox:SetMaxInputChars(1000000)
editBox:SetMultiLine(true)
editBox:SetNewLineEnabled(true)
editBox:SetEditEnabled(false)  -- Read-only

-- Set/get text
editBox:SetText(content)
local text = editBox:GetText()

-- Selection & focus
editBox:SelectAll()
editBox:TakeFocus()
editBox:LoseFocus()
```

### Window Control

```lua
-- Show/hide
window:SetHidden(false)
window:SetHidden(true)

-- Z-order
window:SetTopmost(true)

-- Dimensions
window:SetWidth(800)
window:SetHeight(600)
```

---

## SavedVariables

### Declaration (Manifest)

```
## SavedVariables: AddonSettings
## SavedVariablesPerCharacter: AddonData
```

### Structure

```lua
-- Account-wide
AddonSettings = {
    version = 1,
    enableFeature = true,
}

-- Per-character (ESO manages nesting)
AddonData = {
    customNotes = "",
    timestamp = 0,
}
```

### Initialization

```lua
-- In EVENT_ADD_ON_LOADED handler
local function Initialize()
    -- Set defaults if not exist
    AddonSettings = AddonSettings or {}
    AddonData = AddonData or {}
    
    if not AddonSettings.version then
        AddonSettings.version = 1
        AddonSettings.enableFeature = true
    end
end
```

---

## Events

### Registration

```lua
EVENT_MANAGER:RegisterForEvent("MyAddon", EVENT_ADD_ON_LOADED,
    function(event, addonName)
        if addonName ~= "MyAddon" then return end
        
        -- Initialize
        
        -- Unregister (one-time event)
        EVENT_MANAGER:UnregisterForEvent("MyAddon", EVENT_ADD_ON_LOADED)
    end
)
```

### Common Events

```lua
EVENT_ADD_ON_LOADED        -- Addon finished loading
EVENT_PLAYER_ACTIVATED     -- Player entered world
EVENT_INVENTORY_SINGLE_SLOT_UPDATE  -- Item changed
EVENT_CHAMPION_POINT_GAINED         -- CP earned
EVENT_SKILL_RANK_UPDATE             -- Skill leveled
```

---

## Constants

### Item Quality

```
ITEM_QUALITY_TRASH = 0
ITEM_QUALITY_NORMAL = 1
ITEM_QUALITY_MAGIC = 2
ITEM_QUALITY_ARCANE = 3
ITEM_QUALITY_ARTIFACT = 4
ITEM_QUALITY_LEGENDARY = 5
```

### Attributes

```
ATTRIBUTE_HEALTH = 1
ATTRIBUTE_MAGICKA = 2
ATTRIBUTE_STAMINA = 3
```

### Skill Types

```
SKILL_TYPE_CLASS = 1
SKILL_TYPE_WEAPON = 2
SKILL_TYPE_ARMOR = 3
SKILL_TYPE_WORLD = 4
SKILL_TYPE_GUILD = 5
SKILL_TYPE_AVA = 6
SKILL_TYPE_RACIAL = 7
```

---

## Limitations

### Disabled Functions

```lua
-- File I/O
io.*           -- Completely disabled

-- System
os.execute()   -- Disabled
os.remove()    -- Disabled
os.rename()    -- Disabled

-- Network
-- No socket library available
```

### Combat Restrictions

Some functions disabled during combat:
- Action bar modifications
- UI focus changes
- Certain keybind updates

Check with: `IsUnitInCombat("player")`

---

## Related Documentation

- **[Architecture](ARCHITECTURE.md)** - Code structure and design patterns
- **[Development Guide](DEVELOPMENT.md)** - Setup and contribution guidelines
- **[Testing Guide](../TESTING_GUIDE.md)** - Validation procedures

## Resources

- **Wiki**: https://wiki.esoui.com/
- **Source**: https://github.com/esoui/esoui
- **Forums**: https://www.esoui.com/forums/
