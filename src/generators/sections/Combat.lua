-- CharacterMarkdown - Combat Section Generators
-- Generates combat-related markdown sections (stats, attributes, buffs)

local CM = CharacterMarkdown

-- Cache for utility functions (lazy-initialized on first use)
local CreateBuffLink, FormatNumber

-- Lazy initialization of cached references
local function InitializeUtilities()
    if not FormatNumber then
        CreateBuffLink = CM.links.CreateBuffLink
        FormatNumber = CM.utils.FormatNumber
    end
end

-- =====================================================
-- COMBAT STATS
-- =====================================================

local function GenerateCombatStats(statsData, format)
    InitializeUtilities()
    
    local markdown = ""
    
    if format == "discord" then
        markdown = markdown .. "\n**Stats:**\n```\n"
        -- Resources
        markdown = markdown .. "HP: " .. FormatNumber(statsData.health or 0) .. 
                              " | Mag: " .. FormatNumber(statsData.magicka or 0) ..
                              " | Stam: " .. FormatNumber(statsData.stamina or 0) .. "\n"
        -- Power
        markdown = markdown .. "Weapon: " .. FormatNumber(statsData.weaponPower or 0) ..
                              " | Spell: " .. FormatNumber(statsData.spellPower or 0) .. "\n"
        -- Crit
        markdown = markdown .. "W.Crit: " .. FormatNumber(statsData.weaponCritRating or 0) .. 
                              " (" .. (statsData.weaponCritChance or 0) .. "%)" ..
                              " | S.Crit: " .. FormatNumber(statsData.spellCritRating or 0) ..
                              " (" .. (statsData.spellCritChance or 0) .. "%)\n"
        -- Penetration
        markdown = markdown .. "Phys Pen: " .. FormatNumber(statsData.physicalPenetration or 0) ..
                              " | Spell Pen: " .. FormatNumber(statsData.spellPenetration or 0) .. "\n"
        -- Resistance
        markdown = markdown .. "Phys Res: " .. FormatNumber(statsData.physicalResist or 0) ..
                              " (" .. (statsData.physicalMitigation or 0) .. "%)" ..
                              " | Spell Res: " .. FormatNumber(statsData.spellResist or 0) ..
                              " (" .. (statsData.spellMitigation or 0) .. "%)\n"
        -- Recovery
        markdown = markdown .. "HP Rec: " .. FormatNumber(statsData.healthRecovery or 0) ..
                              " | Mag Rec: " .. FormatNumber(statsData.magickaRecovery or 0) ..
                              " | Stam Rec: " .. FormatNumber(statsData.staminaRecovery or 0) .. "\n"
        markdown = markdown .. "```"
    else
        markdown = markdown .. "---\n\n"
        
        markdown = markdown .. "## 📈 Combat Statistics\n\n"
        markdown = markdown .. "| Category | Stat | Value |\n"
        markdown = markdown .. "|:---------|:-----|------:|\n"
        
        -- Resources
        markdown = markdown .. "| 💚 **Resources** | Health | " .. FormatNumber(statsData.health or 0) .. " |\n"
        markdown = markdown .. "| | Magicka | " .. FormatNumber(statsData.magicka or 0) .. " |\n"
        markdown = markdown .. "| | Stamina | " .. FormatNumber(statsData.stamina or 0) .. " |\n"
        
        -- Offensive Power
        markdown = markdown .. "| ⚔️ **Offensive** | Weapon Power | " .. FormatNumber(statsData.weaponPower or 0) .. " |\n"
        markdown = markdown .. "| | Spell Power | " .. FormatNumber(statsData.spellPower or 0) .. " |\n"
        
        -- Critical Strike
        markdown = markdown .. "| 🎯 **Critical** | Weapon Crit | " .. 
                              FormatNumber(statsData.weaponCritRating or 0) .. 
                              " (" .. (statsData.weaponCritChance or 0) .. "%) |\n"
        markdown = markdown .. "| | Spell Crit | " .. 
                              FormatNumber(statsData.spellCritRating or 0) ..
                              " (" .. (statsData.spellCritChance or 0) .. "%) |\n"
        
        -- Penetration
        markdown = markdown .. "| 🗡️ **Penetration** | Physical | " .. FormatNumber(statsData.physicalPenetration or 0) .. " |\n"
        markdown = markdown .. "| | Spell | " .. FormatNumber(statsData.spellPenetration or 0) .. " |\n"
        
        -- Defensive
        markdown = markdown .. "| 🛡️ **Defensive** | Physical Resist | " .. 
                              FormatNumber(statsData.physicalResist or 0) ..
                              " (" .. (statsData.physicalMitigation or 0) .. "%) |\n"
        markdown = markdown .. "| | Spell Resist | " .. 
                              FormatNumber(statsData.spellResist or 0) ..
                              " (" .. (statsData.spellMitigation or 0) .. "%) |\n"
        
        -- Recovery
        markdown = markdown .. "| ♻️ **Recovery** | Health | " .. FormatNumber(statsData.healthRecovery or 0) .. " |\n"
        markdown = markdown .. "| | Magicka | " .. FormatNumber(statsData.magickaRecovery or 0) .. " |\n"
        markdown = markdown .. "| | Stamina | " .. FormatNumber(statsData.staminaRecovery or 0) .. " |\n"
        
        markdown = markdown .. "\n"
        markdown = markdown .. "---\n\n"
    end
    
    return markdown
end

-- =====================================================
-- ATTRIBUTES
-- =====================================================

local function GenerateAttributes(characterData, format)
    local markdown = ""
    
    if not characterData.attributes then
        return ""
    end
    
    if format == "discord" then
        markdown = markdown .. "```yaml\n"
        markdown = markdown .. "Attributes: Mag " .. characterData.attributes.magicka ..
                              " | HP " .. characterData.attributes.health ..
                              " | Stam " .. characterData.attributes.stamina .. "\n"
        markdown = markdown .. "```\n"
    else
        markdown = markdown .. "### 🎯 Attribute Distribution\n\n"
        markdown = markdown .. "**Magicka:** " .. characterData.attributes.magicka .. 
                              " • **Health:** " .. characterData.attributes.health ..
                              " • **Stamina:** " .. characterData.attributes.stamina .. "\n\n"
    end
    
    return markdown
end

-- =====================================================
-- BUFFS
-- =====================================================

local function GenerateBuffs(buffsData, format)
    InitializeUtilities()
    
    local markdown = ""
    
    if not buffsData.food and not buffsData.potion and #buffsData.other == 0 then
        return ""
    end
    
    if format == "discord" then
        markdown = markdown .. "**Buffs:**\n"
        if buffsData.food then 
            local foodLink = CreateBuffLink(buffsData.food, format)
            markdown = markdown .. "• " .. foodLink .. "\n" 
        end
        if buffsData.potion then 
            local potionLink = CreateBuffLink(buffsData.potion, format)
            markdown = markdown .. "• " .. potionLink .. "\n" 
        end
        if #buffsData.other > 0 then
            for _, buff in ipairs(buffsData.other) do
                local buffLink = CreateBuffLink(buff, format)
                markdown = markdown .. "• " .. buffLink .. "\n"
            end
        end
        markdown = markdown .. "\n"
    else
        markdown = markdown .. "### 🍖 Active Buffs\n\n"
        if buffsData.food then
            local foodLink = CreateBuffLink(buffsData.food, format)
            markdown = markdown .. "**Food:** " .. foodLink .. "  \n"
        end
        if buffsData.potion then
            local potionLink = CreateBuffLink(buffsData.potion, format)
            markdown = markdown .. "**Potion:** " .. potionLink .. "  \n"
        end
        if #buffsData.other > 0 then
            local otherBuffs = {}
            for _, buff in ipairs(buffsData.other) do
                local buffLink = CreateBuffLink(buff, format)
                table.insert(otherBuffs, buffLink)
            end
            markdown = markdown .. "**Other:** " .. table.concat(otherBuffs, ", ") .. "  \n"
        end
        markdown = markdown .. "\n"
    end
    
    return markdown
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.generators.sections = CM.generators.sections or {}
CM.generators.sections.GenerateCombatStats = GenerateCombatStats
CM.generators.sections.GenerateAttributes = GenerateAttributes
CM.generators.sections.GenerateBuffs = GenerateBuffs
