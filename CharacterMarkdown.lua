-- CharacterMarkdown - Comprehensive character data export in markdown format
-- Author: lvavasour
-- Version: 1.0.2

local CharacterMarkdown = {}
CharacterMarkdown.name = "CharacterMarkdown"

-- =====================================================
-- UTILITY FUNCTIONS
-- =====================================================

local function FormatNumber(number)
    if not number then return "0" end
    local formatted = tostring(math.floor(number))
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

local function SafeGetPlayerStat(statType, defaultValue)
    defaultValue = defaultValue or 0
    if not statType then
        return defaultValue
    end
    local success, value = pcall(function() return GetPlayerStat(statType) end)
    if success and value then
        return value
    end
    return defaultValue
end

local function GetQualityColor(quality)
    local colors = {
        [ITEM_QUALITY_TRASH] = "Trash",
        [ITEM_QUALITY_NORMAL] = "Normal",
        [ITEM_QUALITY_MAGIC] = "Magic",
        [ITEM_QUALITY_ARCANE] = "Arcane",
        [ITEM_QUALITY_ARTIFACT] = "Artifact",
        [ITEM_QUALITY_LEGENDARY] = "Legendary",
    }
    return colors[quality] or "Unknown"
end

local function GetEquipSlotName(slotIndex)
    local slots = {
        [EQUIP_SLOT_HEAD] = "Head",
        [EQUIP_SLOT_NECK] = "Neck",
        [EQUIP_SLOT_CHEST] = "Chest",
        [EQUIP_SLOT_SHOULDERS] = "Shoulders",
        [EQUIP_SLOT_MAIN_HAND] = "Main Hand",
        [EQUIP_SLOT_OFF_HAND] = "Off Hand",
        [EQUIP_SLOT_WAIST] = "Waist",
        [EQUIP_SLOT_LEGS] = "Legs",
        [EQUIP_SLOT_FEET] = "Feet",
        [EQUIP_SLOT_COSTUME] = "Costume",
        [EQUIP_SLOT_RING1] = "Ring 1",
        [EQUIP_SLOT_RING2] = "Ring 2",
        [EQUIP_SLOT_HAND] = "Hands",
        [EQUIP_SLOT_BACKUP_MAIN] = "Backup Main Hand",
        [EQUIP_SLOT_BACKUP_OFF] = "Backup Off Hand",
    }
    return slots[slotIndex] or "Unknown"
end

-- =====================================================
-- DATA COLLECTION FUNCTIONS
-- =====================================================

local function GetCharacterIdentity()
    local markdown = "## Character Identity\n\n"
    
    local name = GetUnitName("player") or "Unknown"
    local race = GetUnitRace("player") or "Unknown"
    local class = GetUnitClass("player") or "Unknown"
    local alliance = GetAllianceName(GetUnitAlliance("player")) or "Unknown"
    local level = GetUnitLevel("player") or 0
    local cp = GetPlayerChampionPointsEarned() or 0
    local title = GetTitle(GetCurrentTitleIndex()) or ""
    
    markdown = markdown .. "- **Name:** " .. name .. "\n"
    markdown = markdown .. "- **Race:** " .. race .. "\n"
    markdown = markdown .. "- **Class:** " .. class .. "\n"
    markdown = markdown .. "- **Alliance:** " .. alliance .. "\n"
    markdown = markdown .. "- **Level:** " .. level .. "\n"
    markdown = markdown .. "- **Champion Points:** " .. FormatNumber(cp) .. "\n"
    if title and title ~= "" then
        markdown = markdown .. "- **Title:** " .. title .. "\n"
    end
    
    return markdown .. "\n"
end

local function GetMundusStone()
    local markdown = "## Mundus Stone\n\n"
    
    local numBuffs = GetNumBuffs("player") or 0
    local mundusName = "None"
    
    for i = 1, numBuffs do
        local buffName, _, _, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo("player", i)
        -- Mundus stones have ability IDs in the range 13940-13974
        if abilityId and abilityId >= 13940 and abilityId <= 13974 then
            mundusName = buffName or "Unknown"
            break
        end
    end
    
    markdown = markdown .. "- **Active Mundus:** " .. mundusName .. "\n\n"
    return markdown
end

local function GetCombatStats()
    local markdown = "## Attributes & Combat Stats\n\n"
    
    -- Primary Attributes
    local maxHealth = GetUnitPowerMax("player", POWERTYPE_HEALTH) or 0
    local maxMagicka = GetUnitPowerMax("player", POWERTYPE_MAGICKA) or 0
    local maxStamina = GetUnitPowerMax("player", POWERTYPE_STAMINA) or 0
    
    markdown = markdown .. "### Primary Attributes\n"
    markdown = markdown .. "- **Health:** " .. FormatNumber(maxHealth) .. "\n"
    markdown = markdown .. "- **Magicka:** " .. FormatNumber(maxMagicka) .. "\n"
    markdown = markdown .. "- **Stamina:** " .. FormatNumber(maxStamina) .. "\n\n"
    
    -- Try to get offensive stats (may not exist on all API versions)
    markdown = markdown .. "### Offensive Stats\n"
    
    -- Use derived stats that are more reliable
    local success1, weaponPower = pcall(GetPlayerStat, STAT_POWER, STAT_SOFT_CAP_OPTION_PENALIZED)
    weaponPower = (success1 and weaponPower) or 0
    
    local success2, spellPower = pcall(GetPlayerStat, STAT_SPELL_POWER, STAT_SOFT_CAP_OPTION_PENALIZED)
    spellPower = (success2 and spellPower) or 0
    
    markdown = markdown .. "- **Weapon Power:** " .. FormatNumber(weaponPower) .. "\n"
    markdown = markdown .. "- **Spell Power:** " .. FormatNumber(spellPower) .. "\n\n"
    
    -- Defensive stats
    markdown = markdown .. "### Defensive Stats\n"
    local success3, physicalResist = pcall(GetPlayerStat, STAT_PHYSICAL_RESIST, STAT_SOFT_CAP_OPTION_PENALIZED)
    physicalResist = (success3 and physicalResist) or 0
    
    local success4, spellResist = pcall(GetPlayerStat, STAT_SPELL_RESIST, STAT_SOFT_CAP_OPTION_PENALIZED)
    spellResist = (success4 and spellResist) or 0
    
    markdown = markdown .. "- **Physical Resistance:** " .. FormatNumber(physicalResist) .. "\n"
    markdown = markdown .. "- **Spell Resistance:** " .. FormatNumber(spellResist) .. "\n\n"
    
    return markdown
end

local function GetEquipment()
    local markdown = "## Equipment\n\n"
    markdown = markdown .. "| Slot | Item | Set | Quality | Level | Trait |\n"
    markdown = markdown .. "|------|------|-----|---------|-------|-------|\n"
    
    local equipSlots = {
        EQUIP_SLOT_HEAD,
        EQUIP_SLOT_NECK,
        EQUIP_SLOT_CHEST,
        EQUIP_SLOT_SHOULDERS,
        EQUIP_SLOT_MAIN_HAND,
        EQUIP_SLOT_OFF_HAND,
        EQUIP_SLOT_WAIST,
        EQUIP_SLOT_LEGS,
        EQUIP_SLOT_FEET,
        EQUIP_SLOT_RING1,
        EQUIP_SLOT_RING2,
        EQUIP_SLOT_HAND,
        EQUIP_SLOT_BACKUP_MAIN,
        EQUIP_SLOT_BACKUP_OFF,
    }
    
    for _, slotIndex in ipairs(equipSlots) do
        local itemName = GetItemName(BAG_WORN, slotIndex)
        local hasItem = itemName and itemName ~= ""
        
        if hasItem then
            local itemLink = GetItemLink(BAG_WORN, slotIndex)
            local hasSet, setName = GetItemLinkSetInfo(itemLink)
            local quality = GetItemLinkQuality(itemLink)
            local level = GetItemLinkRequiredLevel(itemLink) or 0
            local traitType = GetItemLinkTraitInfo(itemLink)
            local traitName = GetString("SI_ITEMTRAITTYPE", traitType) or "None"
            
            local setDisplayName = (hasSet and setName) and setName or "None"
            
            markdown = markdown .. string.format("| %s | %s | %s | %s | %d | %s |\n",
                GetEquipSlotName(slotIndex),
                itemName,
                setDisplayName,
                GetQualityColor(quality),
                level,
                traitName
            )
        else
            markdown = markdown .. string.format("| %s | Empty | - | - | - | - |\n",
                GetEquipSlotName(slotIndex)
            )
        end
    end
    
    return markdown .. "\n"
end

local function GetActiveSkills()
    local markdown = "## Active Skill Lines\n\n"
    markdown = markdown .. "| Skill Line | Type | Rank | XP Progress |\n"
    markdown = markdown .. "|------------|------|------|-------------|\n"
    
    -- Iterate through all skill types
    local numSkillTypes = GetNumSkillTypes() or 0
    for skillType = 1, numSkillTypes do
        local skillTypeName = GetSkillTypeNameById(skillType) or "Unknown"
        local numSkillLines = GetNumSkillLines(skillType) or 0
        
        for skillLineIndex = 1, numSkillLines do
            local skillLineName, skillLineRank = GetSkillLineInfo(skillType, skillLineIndex)
            
            -- Only show skill lines that have been started (rank > 0)
            if skillLineName and skillLineRank and skillLineRank > 0 then
                local lastXP, nextXP, currentXP = GetSkillLineXPInfo(skillType, skillLineIndex)
                
                local xpProgress = "Max"
                if nextXP and nextXP > 0 and currentXP then
                    local percent = math.floor((currentXP / nextXP) * 100)
                    xpProgress = string.format("%d%%", percent)
                end
                
                markdown = markdown .. string.format("| %s | %s | %d | %s |\n",
                    skillLineName,
                    skillTypeName,
                    skillLineRank,
                    xpProgress
                )
            end
        end
    end
    
    return markdown .. "\n"
end

local function GetCompanions()
    local markdown = "## Companions\n\n"
    markdown = markdown .. "| Name | Role | Status |\n"
    markdown = markdown .. "|------|------|--------|\n"
    
    -- Known companion collection IDs
    local companions = {
        {id = 1, name = "Bastian Hallix", role = "DPS"},
        {id = 2, name = "Mirri Elendis", role = "DPS"},
        {id = 3, name = "Ember", role = "DPS"},
        {id = 4, name = "Isobel Veloise", role = "Tank"},
        {id = 5, name = "Sharp-as-Night", role = "Healer"},
        {id = 6, name = "Azandar al-Cybiades", role = "DPS"},
        {id = 7, name = "Zerith-var", role = "Tank"},
        {id = 8, name = "Tanlorin", role = "Healer"},
    }
    
    for _, companion in ipairs(companions) do
        local status = "Unknown"
        
        -- Try different methods to detect companion unlock status
        local success, collectibleId = pcall(GetCollectibleIdFromType, COLLECTIBLE_CATEGORY_TYPE_COMPANION, companion.id)
        if success and collectibleId and collectibleId > 0 then
            local unlocked = IsCollectibleUnlocked(collectibleId)
            status = unlocked and "Unlocked" or "Locked"
        end
        
        markdown = markdown .. string.format("| %s | %s | %s |\n",
            companion.name,
            companion.role,
            status
        )
    end
    
    return markdown .. "\n"
end

-- =====================================================
-- MAIN EXPORT FUNCTION
-- =====================================================

local function GenerateMarkdown()
    local markdown = "# Character Data Export\n\n"
    
    -- Add timestamp
    local timeStamp = GetTimeStamp()
    if timeStamp then
        local dateStr = GetDateStringFromTimestamp(timeStamp)
        if dateStr then
            markdown = markdown .. "*Generated on: " .. dateStr .. "*\n\n"
        end
    end
    
    markdown = markdown .. "---\n\n"
    
    -- Collect all data sections with error handling
    local sections = {
        {name = "Character Identity", func = GetCharacterIdentity},
        {name = "Mundus Stone", func = GetMundusStone},
        {name = "Combat Stats", func = GetCombatStats},
        {name = "Equipment", func = GetEquipment},
        {name = "Active Skills", func = GetActiveSkills},
        {name = "Companions", func = GetCompanions},
    }
    
    for _, section in ipairs(sections) do
        local success, result = pcall(section.func)
        if success and result then
            markdown = markdown .. result
        else
            markdown = markdown .. "## " .. section.name .. "\n\n"
            markdown = markdown .. "*Error collecting data: " .. tostring(result) .. "*\n\n"
            d("[CharacterMarkdown] Error in " .. section.name .. ": " .. tostring(result))
        end
    end
    
    return markdown
end

local function ShowMarkdownWindow()
    local markdown = GenerateMarkdown()
    
    -- Get the edit box
    local editBox = CharacterMarkdownWindowTextContainerEditBox
    if editBox then
        -- Set the text
        editBox:SetText(markdown)
        
        -- Make sure it's enabled and can be edited
        editBox:SetEditEnabled(true)
        editBox:SetMouseEnabled(true)
        
        -- Select all text automatically
        editBox:SelectAll()
        
        -- Show the window
        CharacterMarkdownWindow:SetHidden(false)
        
        -- Give focus to the edit box
        editBox:TakeFocus()
        
        -- Log success
        d("[CharacterMarkdown] Data exported! Text is pre-selected - just press Ctrl+C to copy.")
    else
        d("[CharacterMarkdown] ERROR: Could not find edit box control.")
    end
end

-- =====================================================
-- INITIALIZATION
-- =====================================================

function CharacterMarkdown:Initialize()
    -- Register slash command
    SLASH_COMMANDS["/markdown"] = ShowMarkdownWindow
    
    d("[CharacterMarkdown] Loaded v1.0.2. Use /markdown to export character data.")
end

-- Event handler for addon loaded
local function OnAddOnLoaded(event, addonName)
    if addonName == CharacterMarkdown.name then
        CharacterMarkdown:Initialize()
        EVENT_MANAGER:UnregisterForEvent(CharacterMarkdown.name, EVENT_ADD_ON_LOADED)
    end
end

-- Register for addon loaded event
EVENT_MANAGER:RegisterForEvent(CharacterMarkdown.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
