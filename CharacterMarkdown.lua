-- CharacterMarkdown - Comprehensive character data export in markdown format
-- Author: lvavasour
-- Version: 1.0.0

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
    
    local name = GetUnitName("player")
    local race = GetUnitRace("player")
    local class = GetUnitClass("player")
    local alliance = GetAllianceName(GetUnitAlliance("player"))
    local level = GetUnitLevel("player")
    local cp = GetPlayerChampionPointsEarned()
    local title = GetTitle(GetCurrentTitleIndex())
    
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
    
    local numBuffs = GetNumBuffs("player")
    local mundusName = "None"
    
    for i = 1, numBuffs do
        local buffName, _, _, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo("player", i)
        -- Mundus stones have ability IDs in the range 13940-13974
        if abilityId >= 13940 and abilityId <= 13974 then
            mundusName = buffName
            break
        end
    end
    
    markdown = markdown .. "- **Active Mundus:** " .. mundusName .. "\n\n"
    return markdown
end

local function GetCombatStats()
    local markdown = "## Attributes & Combat Stats\n\n"
    
    -- Primary Attributes
    local maxHealth = GetUnitPowerMax("player", POWERTYPE_HEALTH)
    local maxMagicka = GetUnitPowerMax("player", POWERTYPE_MAGICKA)
    local maxStamina = GetUnitPowerMax("player", POWERTYPE_STAMINA)
    
    markdown = markdown .. "### Primary Attributes\n"
    markdown = markdown .. "- **Health:** " .. FormatNumber(maxHealth) .. "\n"
    markdown = markdown .. "- **Magicka:** " .. FormatNumber(maxMagicka) .. "\n"
    markdown = markdown .. "- **Stamina:** " .. FormatNumber(maxStamina) .. "\n\n"
    
    -- Offensive Stats
    local weaponDamage = GetPlayerStat(STAT_POWER)
    local spellDamage = GetPlayerStat(STAT_SPELL_POWER)
    local weaponCrit = GetPlayerStat(STAT_CRITICAL_STRIKE)
    local spellCrit = GetPlayerStat(STAT_SPELL_CRITICAL)
    
    markdown = markdown .. "### Offensive Stats\n"
    markdown = markdown .. "- **Weapon Damage:** " .. FormatNumber(weaponDamage) .. "\n"
    markdown = markdown .. "- **Spell Damage:** " .. FormatNumber(spellDamage) .. "\n"
    markdown = markdown .. "- **Weapon Critical:** " .. FormatNumber(weaponCrit) .. "\n"
    markdown = markdown .. "- **Spell Critical:** " .. FormatNumber(spellCrit) .. "\n\n"
    
    -- Defensive Stats
    local physicalResist = GetPlayerStat(STAT_PHYSICAL_RESIST)
    local spellResist = GetPlayerStat(STAT_SPELL_RESIST)
    local critResist = GetPlayerStat(STAT_CRITICAL_RESISTANCE)
    
    markdown = markdown .. "### Defensive Stats\n"
    markdown = markdown .. "- **Physical Resistance:** " .. FormatNumber(physicalResist) .. "\n"
    markdown = markdown .. "- **Spell Resistance:** " .. FormatNumber(spellResist) .. "\n"
    markdown = markdown .. "- **Critical Resistance:** " .. FormatNumber(critResist) .. "\n\n"
    
    -- Penetration
    local physicalPen = GetPlayerStat(STAT_PHYSICAL_PENETRATION)
    local spellPen = GetPlayerStat(STAT_SPELL_PENETRATION)
    
    markdown = markdown .. "### Penetration\n"
    markdown = markdown .. "- **Physical Penetration:** " .. FormatNumber(physicalPen) .. "\n"
    markdown = markdown .. "- **Spell Penetration:** " .. FormatNumber(spellPen) .. "\n\n"
    
    return markdown
end

local function GetEquipment()
    local markdown = "## Equipment\n\n"
    markdown = markdown .. "| Slot | Item | Set | Quality | Level | Trait | Enchantment |\n"
    markdown = markdown .. "|------|------|-----|---------|-------|-------|-------------|\n"
    
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
        local hasItem = GetItemName(BAG_WORN, slotIndex) ~= ""
        
        if hasItem then
            local itemName = GetItemName(BAG_WORN, slotIndex)
            local itemLink = GetItemLink(BAG_WORN, slotIndex)
            local hasSet, setName = GetItemLinkSetInfo(itemLink)
            local quality = GetItemLinkQuality(itemLink)
            local level = GetItemLinkRequiredLevel(itemLink)
            local trait = GetItemTrait(BAG_WORN, slotIndex)
            local traitName = GetString("SI_ITEMTRAITTYPE", trait)
            
            -- Get enchantment
            local enchantName = "None"
            local enchantType, enchantValue = GetItemEnchantInfo(BAG_WORN, slotIndex)
            if enchantType and enchantType ~= ENCHANT_TYPE_INVALID then
                enchantName = GetString("SI_ENCHANTMENTTYPE", enchantType)
                if enchantValue and enchantValue > 0 then
                    enchantName = enchantName .. " (" .. FormatNumber(enchantValue) .. ")"
                end
            end
            
            local setDisplayName = hasSet and setName or "None"
            
            markdown = markdown .. string.format("| %s | %s | %s | %s | %d | %s | %s |\n",
                GetEquipSlotName(slotIndex),
                itemName,
                setDisplayName,
                GetQualityColor(quality),
                level,
                traitName,
                enchantName
            )
        else
            markdown = markdown .. string.format("| %s | Empty | - | - | - | - | - |\n",
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
    for skillType = 1, GetNumSkillTypes() do
        local skillTypeName = GetSkillTypeNameById(skillType)
        local numSkillLines = GetNumSkillLines(skillType)
        
        for skillLineIndex = 1, numSkillLines do
            local skillLineName, skillLineRank = GetSkillLineInfo(skillType, skillLineIndex)
            local lastXP, nextXP, currentXP = GetSkillLineXPInfo(skillType, skillLineIndex)
            
            -- Only show skill lines that have been started (rank > 0)
            if skillLineRank > 0 then
                local xpProgress = "Max"
                if nextXP > 0 then
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
    markdown = markdown .. "| Name | Role | Rapport Level | Status |\n"
    markdown = markdown .. "|------|------|---------------|--------|\n"
    
    -- Known companion collection IDs (these may need adjustment based on game version)
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
        -- Try to get companion data (this is a simplified approach)
        -- Note: ESO's companion API is complex; this attempts basic detection
        local isUnlocked = false
        local rapportLevel = "Unknown"
        
        -- Check if companion collectible is unlocked
        local collectibleId = GetCollectibleIdFromType(COLLECTIBLE_CATEGORY_TYPE_COMPANION, companion.id)
        if collectibleId and collectibleId > 0 then
            isUnlocked = IsCollectibleUnlocked(collectibleId)
            
            if isUnlocked then
                -- Try to get rapport (this is approximate - actual API varies)
                -- Rapport levels: 0-1000 (Stranger), 1000-2500 (Acquaintance), 2500-4000 (Friend), 4000+ (Ally)
                local rapport = 0 -- Would need GetActiveCompanionRapport() or similar
                
                if rapport >= 4000 then
                    rapportLevel = "Ally"
                elseif rapport >= 2500 then
                    rapportLevel = "Friend"
                elseif rapport >= 1000 then
                    rapportLevel = "Acquaintance"
                else
                    rapportLevel = "Stranger"
                end
            end
        end
        
        local status = isUnlocked and "Unlocked" or "Locked"
        
        markdown = markdown .. string.format("| %s | %s | %s | %s |\n",
            companion.name,
            companion.role,
            rapportLevel,
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
    markdown = markdown .. "*Generated on: " .. GetDateStringFromTimestamp(GetTimeStamp()) .. "*\n\n"
    markdown = markdown .. "---\n\n"
    
    -- Collect all data sections
    markdown = markdown .. GetCharacterIdentity()
    markdown = markdown .. GetMundusStone()
    markdown = markdown .. GetCombatStats()
    markdown = markdown .. GetEquipment()
    markdown = markdown .. GetActiveSkills()
    markdown = markdown .. GetCompanions()
    
    return markdown
end

local function ShowMarkdownWindow()
    local markdown = GenerateMarkdown()
    
    -- Set the text in the edit box
    local editBox = CharacterMarkdownWindowTextContainerEditBox
    if editBox then
        editBox:SetText(markdown)
        editBox:SetCursorPosition(0)
        
        -- Show the window
        CharacterMarkdownWindow:SetHidden(false)
        
        -- Log success
        d("[CharacterMarkdown] Data exported successfully! Use Ctrl+A to select all, then Ctrl+C to copy.")
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
    
    d("[CharacterMarkdown] Loaded. Use /markdown to export character data.")
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
