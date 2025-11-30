-- CharacterMarkdown - Combat Section Generators
-- Generates combat-related markdown sections (stats, attributes, buffs)

local CM = CharacterMarkdown

-- Cache for utility functions (lazy-initialized on first use)
local CreateBuffLink, FormatNumber, GenerateAnchor

-- Lazy initialization of cached references
local function InitializeUtilities()
    if not FormatNumber then
        CreateBuffLink = CM.links.CreateBuffLink
        FormatNumber = CM.utils.FormatNumber
        GenerateAnchor = CM.utils and CM.utils.markdown and CM.utils.markdown.GenerateAnchor
    end
end

-- =====================================================
-- COMBAT STATS
-- =====================================================

local function GenerateCombatStats(statsData, format, inline)
    InitializeUtilities()

    -- inline parameter: if true, generate just the table without section header/divider (for overview section)
    inline = inline or false

    local markdown = ""

    if format == "discord" then
        markdown = markdown .. "\n**Stats:**\n```\n"
        -- Resources
        markdown = markdown
            .. "HP: "
            .. FormatNumber(statsData.health or 0)
            .. " | Mag: "
            .. FormatNumber(statsData.magicka or 0)
            .. " | Stam: "
            .. FormatNumber(statsData.stamina or 0)
            .. "\n"
        -- Power
        markdown = markdown
            .. "Weapon: "
            .. FormatNumber(statsData.weaponPower or 0)
            .. " | Spell: "
            .. FormatNumber(statsData.spellPower or 0)
            .. "\n"
        -- Crit
        markdown = markdown
            .. "W.Crit: "
            .. FormatNumber(statsData.weaponCritRating or 0)
            .. " ("
            .. (statsData.weaponCritChance or 0)
            .. "%)"
            .. " | S.Crit: "
            .. FormatNumber(statsData.spellCritRating or 0)
            .. " ("
            .. (statsData.spellCritChance or 0)
            .. "%)\n"
        -- Penetration
        markdown = markdown
            .. "Phys Pen: "
            .. FormatNumber(statsData.physicalPenetration or 0)
            .. " | Spell Pen: "
            .. FormatNumber(statsData.spellPenetration or 0)
            .. "\n"
        -- Resistance
        markdown = markdown
            .. "Phys Res: "
            .. FormatNumber(statsData.physicalResist or 0)
            .. " ("
            .. (statsData.physicalMitigation or 0)
            .. "%)"
            .. " | Spell Res: "
            .. FormatNumber(statsData.spellResist or 0)
            .. " ("
            .. (statsData.spellMitigation or 0)
            .. "%)\n"
        -- Recovery
        markdown = markdown
            .. "HP Rec: "
            .. FormatNumber(statsData.healthRecovery or 0)
            .. " | Mag Rec: "
            .. FormatNumber(statsData.magickaRecovery or 0)
            .. " | Stam Rec: "
            .. FormatNumber(statsData.staminaRecovery or 0)
            .. "\n"
        markdown = markdown .. "```"
    else
        if not inline then
            -- Use CreateSeparator for consistent separator styling
            local CreateSeparator = CM.utils.markdown and CM.utils.markdown.CreateSeparator
            if CreateSeparator then
                markdown = markdown .. CreateSeparator("hr")
            else
                markdown = markdown .. "---\n\n"
            end
            local anchorId = GenerateAnchor and GenerateAnchor("📈 Combat Statistics") or "combat-statistics"
            markdown = markdown .. string.format('<a id="%s"></a>\n\n', anchorId)
            markdown = markdown .. "## 📈 Combat Statistics\n\n"
        else
            markdown = markdown .. '\n<a id="character-stats"></a>\n\n### Character Stats\n\n'
            
            -- For inline mode, use 3-column layout if markdown utilities are available
            local CreateStyledTable = CM.utils.markdown and CM.utils.markdown.CreateStyledTable
            local CreateResponsiveColumns = CM.utils.markdown and CM.utils.markdown.CreateResponsiveColumns
            
            if CreateStyledTable and CreateResponsiveColumns and format ~= "discord" then
                -- COLUMN 1: Resources & Offensive
                local col1_headers = { "Category", "Stat", "Value" }
                local col1_rows = {
                    { "💚 **Resources**", "Health", FormatNumber(statsData.health or 0) },
                    { "", "Magicka", FormatNumber(statsData.magicka or 0) },
                    { "", "Stamina", FormatNumber(statsData.stamina or 0) },
                    { "⚔️ **Offensive**", "Weapon Power", FormatNumber(statsData.weaponPower or 0) },
                    { "", "Spell Power", FormatNumber(statsData.spellPower or 0) },
                }
                
                local options1 = {
                    alignment = { "left", "left", "right" },
                    format = format,
                    coloredHeaders = true,
                }
                local column1 = CreateStyledTable(col1_headers, col1_rows, options1)
                
                -- COLUMN 2: Critical & Penetration
                local col2_headers = { "Category", "Stat", "Value" }
                local col2_rows = {
                    { "🎯 **Critical**", "Weapon Crit", FormatNumber(statsData.weaponCritRating or 0) .. " (" .. (statsData.weaponCritChance or 0) .. "%)" },
                    { "", "Spell Crit", FormatNumber(statsData.spellCritRating or 0) .. " (" .. (statsData.spellCritChance or 0) .. "%)" },
                    { "⚔️ **Penetration**", "Physical", FormatNumber(statsData.physicalPenetration or 0) },
                    { "", "Spell", FormatNumber(statsData.spellPenetration or 0) },
                }
                
                local options2 = {
                    alignment = { "left", "left", "right" },
                    format = format,
                    coloredHeaders = true,
                }
                local column2 = CreateStyledTable(col2_headers, col2_rows, options2)
                
                -- COLUMN 3: Defensive & Recovery
                local col3_headers = { "Category", "Stat", "Value" }
                local col3_rows = {
                    { "🛡️ **Defensive**", "Physical Resist", FormatNumber(statsData.physicalResist or 0) .. " (" .. (statsData.physicalMitigation or 0) .. "%)" },
                    { "", "Spell Resist", FormatNumber(statsData.spellResist or 0) .. " (" .. (statsData.spellMitigation or 0) .. "%)" },
                    { "♻️ **Recovery**", "Health", FormatNumber(statsData.healthRecovery or 0) },
                    { "", "Magicka", FormatNumber(statsData.magickaRecovery or 0) },
                    { "", "Stamina", FormatNumber(statsData.staminaRecovery or 0) },
                }
                
                local options3 = {
                    alignment = { "left", "left", "right" },
                    format = format,
                    coloredHeaders = true,
                }
                local column3 = CreateStyledTable(col3_headers, col3_rows, options3)
                
                -- Create responsive 3-column layout
                local LayoutCalculator = CM.utils.LayoutCalculator
                local minWidth, gap
                if LayoutCalculator then
                    minWidth, gap = LayoutCalculator.GetLayoutParamsWithFallback(
                        { column1, column2, column3 },
                        "250px",
                        "20px"
                    )
                else
                    minWidth = "250px"
                    gap = "20px"
                end
                local columnsLayout = CreateResponsiveColumns({ column1, column2, column3 }, minWidth, gap)
                markdown = markdown .. columnsLayout
            else
                -- Fallback to single table format
                markdown = markdown .. "| Category | Stat | Value |\n"
                markdown = markdown .. "|:---------|:-----|------:|\n"

                -- Resources
                markdown = markdown .. "| 💚 **Resources** | Health | " .. FormatNumber(statsData.health or 0) .. " |\n"
                markdown = markdown .. "| | Magicka | " .. FormatNumber(statsData.magicka or 0) .. " |\n"
                markdown = markdown .. "| | Stamina | " .. FormatNumber(statsData.stamina or 0) .. " |\n"

                -- Offensive Power
                markdown = markdown
                    .. "| ⚔️ **Offensive** | Weapon Power | "
                    .. FormatNumber(statsData.weaponPower or 0)
                    .. " |\n"
                markdown = markdown .. "| | Spell Power | " .. FormatNumber(statsData.spellPower or 0) .. " |\n"

                -- Critical Strike
                markdown = markdown
                    .. "| 🎯 **Critical** | Weapon Crit | "
                    .. FormatNumber(statsData.weaponCritRating or 0)
                    .. " ("
                    .. (statsData.weaponCritChance or 0)
                    .. "%) |\n"
                markdown = markdown
                    .. "| | Spell Crit | "
                    .. FormatNumber(statsData.spellCritRating or 0)
                    .. " ("
                    .. (statsData.spellCritChance or 0)
                    .. "%) |\n"

                -- Penetration
                markdown = markdown
                    .. "| ⚔️ **Penetration** | Physical | "
                    .. FormatNumber(statsData.physicalPenetration or 0)
                    .. " |\n"
                markdown = markdown .. "| | Spell | " .. FormatNumber(statsData.spellPenetration or 0) .. " |\n"

                -- Defensive
                markdown = markdown
                    .. "| 🛡️ **Defensive** | Physical Resist | "
                    .. FormatNumber(statsData.physicalResist or 0)
                    .. " ("
                    .. (statsData.physicalMitigation or 0)
                    .. "%) |\n"
                markdown = markdown
                    .. "| | Spell Resist | "
                    .. FormatNumber(statsData.spellResist or 0)
                    .. " ("
                    .. (statsData.spellMitigation or 0)
                    .. "%) |\n"

                -- Recovery
                markdown = markdown
                    .. "| ♻️ **Recovery** | Health | "
                    .. FormatNumber(statsData.healthRecovery or 0)
                    .. " |\n"
                markdown = markdown .. "| | Magicka | " .. FormatNumber(statsData.magickaRecovery or 0) .. " |\n"
                markdown = markdown .. "| | Stamina | " .. FormatNumber(statsData.staminaRecovery or 0) .. " |\n"
            end
        end

        -- Generate table for non-inline mode
        if not inline then
            markdown = markdown .. "| Category | Stat | Value |\n"
            markdown = markdown .. "|:---------|:-----|------:|\n"

            -- Resources
            markdown = markdown .. "| 💚 **Resources** | Health | " .. FormatNumber(statsData.health or 0) .. " |\n"
            markdown = markdown .. "| | Magicka | " .. FormatNumber(statsData.magicka or 0) .. " |\n"
            markdown = markdown .. "| | Stamina | " .. FormatNumber(statsData.stamina or 0) .. " |\n"

            -- Offensive Power
            markdown = markdown
                .. "| ⚔️ **Offensive** | Weapon Power | "
                .. FormatNumber(statsData.weaponPower or 0)
                .. " |\n"
            markdown = markdown .. "| | Spell Power | " .. FormatNumber(statsData.spellPower or 0) .. " |\n"

            -- Critical Strike
            markdown = markdown
                .. "| 🎯 **Critical** | Weapon Crit | "
                .. FormatNumber(statsData.weaponCritRating or 0)
                .. " ("
                .. (statsData.weaponCritChance or 0)
                .. "%) |\n"
            markdown = markdown
                .. "| | Spell Crit | "
                .. FormatNumber(statsData.spellCritRating or 0)
                .. " ("
                .. (statsData.spellCritChance or 0)
                .. "%) |\n"

            -- Penetration
            markdown = markdown
                .. "| ⚔️ **Penetration** | Physical | "
                .. FormatNumber(statsData.physicalPenetration or 0)
                .. " |\n"
            markdown = markdown .. "| | Spell | " .. FormatNumber(statsData.spellPenetration or 0) .. " |\n"

            -- Defensive
            markdown = markdown
                .. "| 🛡️ **Defensive** | Physical Resist | "
                .. FormatNumber(statsData.physicalResist or 0)
                .. " ("
                .. (statsData.physicalMitigation or 0)
                .. "%) |\n"
            markdown = markdown
                .. "| | Spell Resist | "
                .. FormatNumber(statsData.spellResist or 0)
                .. " ("
                .. (statsData.spellMitigation or 0)
                .. "%) |\n"

            -- Recovery
            markdown = markdown
                .. "| ♻️ **Recovery** | Health | "
                .. FormatNumber(statsData.healthRecovery or 0)
                .. " |\n"
            markdown = markdown .. "| | Magicka | " .. FormatNumber(statsData.magickaRecovery or 0) .. " |\n"
            markdown = markdown .. "| | Stamina | " .. FormatNumber(statsData.staminaRecovery or 0) .. " |\n"
            markdown = markdown .. "\n"
            -- Use CreateSeparator for consistent separator styling
            local CreateSeparator = CM.utils.markdown and CM.utils.markdown.CreateSeparator
            if CreateSeparator then
                markdown = markdown .. CreateSeparator("hr")
            else
                markdown = markdown .. "---\n\n"
            end
        end
    end

    return markdown
end

-- =====================================================
-- BUFFS
-- =====================================================

local function GenerateBuffs(buffsData, format)
    InitializeUtilities()

    local markdown = ""

    if not buffsData.food and not buffsData.potion then
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
        markdown = markdown .. "\n"
    end

    return markdown
end

-- =====================================================
-- ADVANCED STATS
-- =====================================================

local function GenerateAdvancedStats(statsData, format)
    InitializeUtilities()
    
    if not statsData or not statsData.advanced then
        return ""
    end
    
    if format == "discord" then
        -- Discord formatting not implemented for advanced stats
        return ""
    end

    local advanced = statsData.advanced
    local markdown = ""

    -- Helper for formatting numbers
    local function fmt(val)
        return FormatNumber(val or 0)
    end

    -- Helper for formatting percentages
    local function fmtPct(val)
        return (val or 0) .. "%"
    end

    -- Helper for damage/healing bonuses
    local function fmtBonus(bonus)
        if not bonus then return "0" end
        local flat = bonus.flat or 0
        local percent = bonus.percent or 0
        
        if flat == 0 and percent == 0 then return "0" end
        if flat == 0 then return percent .. "%" end
        if percent == 0 then return fmt(flat) end
        return string.format("%s (+%s%%)", fmt(flat), percent)
    end

    markdown = markdown .. "\n<a id=\"advanced-stats\"></a>\n\n### Advanced Stats\n\n"
    
    -- Grid Layout Start
    markdown = markdown .. "<div style=\"display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px;\">\n"
    
    -- Column 1: Core Abilities
    markdown = markdown .. "<div>\n\n"
    markdown = markdown .. "| **Ability** | **Cost/Value** |\n"
    markdown = markdown .. "|:---|---:|\n"
    if advanced.core then
        local core = advanced.core
        markdown = markdown .. "| ⚔️ **Light Attack** | " .. fmt(core.lightAttackDamage) .. " dmg |\n"
        markdown = markdown .. "| ⚔️ **Heavy Attack** | " .. fmt(core.heavyAttackDamage) .. " dmg |\n"
        
        local bashStr = ""
        if core.bashCost > 0 then bashStr = fmt(core.bashCost) .. " cost, " end
        markdown = markdown .. "| ⚔️ **Bash** | " .. bashStr .. fmt(core.bashDamage) .. " dmg |\n"
        
        local blockStr = ""
        if core.blockCost > 0 then blockStr = fmt(core.blockCost) .. " cost, " end
        markdown = markdown .. "| 🛡️ **Block** | " .. blockStr .. fmtPct(core.blockMitigation) .. " mit, " .. fmtPct(core.blockSpeed) .. " spd |\n"
        
        if core.breakFreeCost > 0 then
            markdown = markdown .. "| 🔓 **Break Free** | " .. fmt(core.breakFreeCost) .. " cost |\n"
        end
        if core.dodgeRollCost > 0 then
            markdown = markdown .. "| 🏃 **Dodge Roll** | " .. fmt(core.dodgeRollCost) .. " cost |\n"
        end
        
        local sneakStr = ""
        if core.sneakCost > 0 then sneakStr = fmt(core.sneakCost) .. " cost, " end
        markdown = markdown .. "| 🐾 **Sneak** | " .. sneakStr .. fmtPct(core.sneakSpeed) .. " spd |\n"
        
        local sprintStr = ""
        if core.sprintCost > 0 then sprintStr = fmt(core.sprintCost) .. " cost, " end
        markdown = markdown .. "| 🏃‍♂️ **Sprint** | " .. sprintStr .. fmtPct(core.sprintSpeed) .. " spd |\n"
    end
    markdown = markdown .. "\n</div>\n"

    -- Column 2: Resistances
    markdown = markdown .. "<div>\n\n"
    markdown = markdown .. "| **Resistance** | **Value** |\n"
    markdown = markdown .. "|:---|---:|\n"
    if advanced.resistances then
        local res = advanced.resistances
        -- Use the calculated percent if available (new structure), otherwise fallback
        local function getResVal(key)
            if type(res[key]) == "table" then
                return fmtPct(res[key].percent)
            else
                return fmt(res[key]) -- Fallback for old data structure
            end
        end
        
        markdown = markdown .. "| 🔥 **Flame** | " .. getResVal("flame") .. " |\n"
        markdown = markdown .. "| ⚡ **Shock** | " .. getResVal("shock") .. " |\n"
        markdown = markdown .. "| ❄️ **Frost** | " .. getResVal("frost") .. " |\n"
        markdown = markdown .. "| 🔮 **Magic** | " .. getResVal("magic") .. " |\n"
        markdown = markdown .. "| 🦠 **Disease** | " .. getResVal("disease") .. " |\n"
        markdown = markdown .. "| ☠️ **Poison** | " .. getResVal("poison") .. " |\n"
        markdown = markdown .. "| 🩸 **Bleed** | " .. getResVal("bleed") .. " |\n"
    end
    markdown = markdown .. "\n</div>\n"

    -- Column 3: Damage Bonuses
    markdown = markdown .. "<div>\n\n"
    markdown = markdown .. "| **Damage Type** | **Bonus** |\n"
    markdown = markdown .. "|:---|---:|\n"
    if advanced.damage then
        local dmg = advanced.damage
        markdown = markdown .. "| 💥 **Critical Damage** | " .. fmtPct(dmg.criticalDamage) .. " |\n"
        markdown = markdown .. "| ⚔️ **Physical** | " .. fmtBonus(dmg.physical) .. " |\n"
        markdown = markdown .. "| 🔥 **Flame** | " .. fmtBonus(dmg.flame) .. " |\n"
        markdown = markdown .. "| ⚡ **Shock** | " .. fmtBonus(dmg.shock) .. " |\n"
        markdown = markdown .. "| ❄️ **Frost** | " .. fmtBonus(dmg.frost) .. " |\n"
        markdown = markdown .. "| 🔮 **Magic** | " .. fmtBonus(dmg.magic) .. " |\n"
        markdown = markdown .. "| 🦠 **Disease** | " .. fmtBonus(dmg.disease) .. " |\n"
        markdown = markdown .. "| ☠️ **Poison** | " .. fmtBonus(dmg.poison) .. " |\n"
        markdown = markdown .. "| 🩸 **Bleed** | " .. fmtBonus(dmg.bleed) .. " |\n"
        markdown = markdown .. "| 🌌 **Oblivion** | " .. fmtBonus(dmg.oblivion) .. " |\n"
    end
    markdown = markdown .. "\n</div>\n"

    -- Column 4: Healing Bonuses
    markdown = markdown .. "<div>\n\n"
    markdown = markdown .. "| **Healing** | **Value** |\n"
    markdown = markdown .. "|:---|---:|\n"
    if advanced.healing then
        local heal = advanced.healing
        markdown = markdown .. "| 💚 **Healing Done** | " .. fmtBonus(heal.healingDone) .. " |\n"
        markdown = markdown .. "| 💖 **Healing Taken** | " .. fmtBonus(heal.healingTaken) .. " |\n"
        markdown = markdown .. "| ✨ **Critical Healing** | " .. fmtPct(heal.criticalHealing) .. " |\n"
    end
    markdown = markdown .. "\n</div>\n"

    -- Grid Layout End
    markdown = markdown .. "</div>\n\n"
    
    return markdown
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.generators.sections = CM.generators.sections or {}
CM.generators.sections.GenerateCombatStats = GenerateCombatStats
CM.generators.sections.GenerateBuffs = GenerateBuffs
CM.generators.sections.GenerateAdvancedStats = GenerateAdvancedStats

-- =====================================================
-- CHARACTER STATS WRAPPER
-- =====================================================

local function GenerateCharacterStats(statsData, format)
    if not statsData then
        CM.Warn("GenerateCharacterStats: statsData is nil")
        return ""
    end
    
    CM.DebugPrint("STATS_GEN", "GenerateCharacterStats called with format: " .. tostring(format))
    
    local result = ""
    
    -- Generate Combat Stats (inline=true for table-only output)
    local combatStats = GenerateCombatStats(statsData, format, true)
    CM.DebugPrint("STATS_GEN", string.format("Combat stats generated: %d chars", #combatStats))
    result = result .. combatStats
    
    -- Generate Advanced Stats
    local advancedStats = GenerateAdvancedStats(statsData, format)
    CM.DebugPrint("STATS_GEN", string.format("Advanced stats generated: %d chars, has advanced: %s", 
        #advancedStats, tostring(statsData.advanced ~= nil)))
    result = result .. advancedStats

    CM.DebugPrint("STATS_GEN", string.format("Total GenerateCharacterStats output: %d chars", #result))
    return result
end

CM.generators.sections.GenerateCharacterStats = GenerateCharacterStats
