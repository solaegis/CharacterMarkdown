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
-- ATTRIBUTES - REMOVED (no longer relevant, info shown in Quick Stats)
-- =====================================================

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
        -- Other buffs removed (no longer relevant)
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
        -- Other buffs removed (no longer relevant)
        markdown = markdown .. "\n"
    end

    return markdown
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.generators.sections = CM.generators.sections or {}
CM.generators.sections.GenerateCombatStats = GenerateCombatStats
-- GenerateAttributes removed (no longer relevant)
CM.generators.sections.GenerateBuffs = GenerateBuffs
