-- CharacterMarkdown - Overview Section Generators
-- Generates General subsection and Character Stats subsection for Overview

local CM = CharacterMarkdown
CM.generators = CM.generators or {}
CM.generators.sections = CM.generators.sections or {}

local string_format = string.format
local table_concat = table.concat
local table_insert = table.insert

local markdown = (CM.utils and CM.utils.markdown) or nil

-- =====================================================
-- GENERAL SUBSECTION
-- =====================================================

local function GenerateGeneral(
    charData,
    progressionData,
    locationData,
    buffsData,
    mundusData,
    format,
    ridingData
)
    if not charData then
        return ""
    end

    local formatNumber = CM.utils and CM.utils.FormatNumber
    local safeFormat = function(val)
        if formatNumber then
            return formatNumber(val)
        else
            return tostring(val)
        end
    end

    local CreateStyledTable = markdown and markdown.CreateStyledTable
    local CreateResponsiveColumns = markdown and markdown.CreateResponsiveColumns
    
    -- Use multi-column styled tables if markdown utilities are available
    if CreateStyledTable and CreateResponsiveColumns and format ~= "discord" then
        local result = "### General\n\n"
        
        -- Collect all rows first, then distribute into three balanced tables
        local allRows = {}
        
        -- Link creation functions
        local CreateRaceLink = CM.links and CM.links.CreateRaceLink
        local CreateClassLink = CM.links and CM.links.CreateClassLink
        local CreateAllianceLink = CM.links and CM.links.CreateAllianceLink
        local CreateServerLink = CM.links and CM.links.CreateServerLink
        local CreateTitleLink = CM.links and CM.links.CreateTitleLink
        
        -- Basic Identity (always present)
        table_insert(allRows, { "**Level**", tostring(charData.level or 1) })
        
        local raceText = (CreateRaceLink and CreateRaceLink(charData.race, format)) or (charData.race or "Unknown")
        local classText = (CreateClassLink and CreateClassLink(charData.class, format)) or (charData.class or "Unknown")
        local allianceText = (CreateAllianceLink and CreateAllianceLink(charData.alliance, format))
            or (charData.alliance or "Unknown")
        
        table_insert(allRows, { "**Class**", classText })
        table_insert(allRows, { "**Race**", raceText })
        table_insert(allRows, { "**Alliance**", allianceText })
        
        local serverText = (CreateServerLink and CreateServerLink(charData.server, format))
            or (charData.server or "Unknown")
        table_insert(allRows, { "**Server**", serverText })
        table_insert(allRows, { "**Account**", charData.account or "Unknown" })
        
        -- Champion Points
        if charData.cp and charData.cp > 0 then
            table_insert(allRows, { "**Champion Points**", tostring(charData.cp) })
        end
        
        -- Attributes
        local attrs = charData.attributes or {}
        table_insert(allRows, {
            "**Attributes**",
            string_format("🔵 %d / ❤️ %d / ⚡ %d", attrs.magicka or 0, attrs.health or 0, attrs.stamina or 0)
        })
        
        -- Progression data
        if progressionData then
            local unspentSkillPoints = progressionData.unspentSkillPoints or progressionData.skillPoints or 0
            if unspentSkillPoints and unspentSkillPoints > 0 then
                table_insert(allRows, {
                    "**Skill Points**",
                    string_format("🎯 %d available - Ready to spend", unspentSkillPoints)
                })
            else
                table_insert(allRows, { "**Skill Points**", "None" })
            end
            
            if progressionData.unspentAttributePoints and progressionData.unspentAttributePoints > 0 then
                table_insert(allRows, {
                    "**Attribute Points**",
                    string_format("⚠️ %d unspent", progressionData.unspentAttributePoints)
                })
            end
            
            if progressionData.isVampire then
                local stage = progressionData.vampireStage or 1
                table_insert(allRows, {
                    "**Vampire/Werewolf Status**",
                    string_format("🧛 Vampire Stage %d", stage)
                })
            elseif progressionData.isWerewolf then
                local stage = progressionData.werewolfStage or 1
                table_insert(allRows, {
                    "**Vampire/Werewolf Status**",
                    string_format("🐺 Werewolf Stage %d", stage)
                })
            end
            
            if progressionData.enlightenment then
                local current = progressionData.enlightenment.current or 0
                local max = progressionData.enlightenment.max or 0
                if max > 0 then
                    local percent = progressionData.enlightenment.percent or 0
                    table_insert(allRows, {
                        "**Enlightenment**",
                        string_format("%s / %s (%d%%)", safeFormat(current), safeFormat(max), percent)
                    })
                end
            end
        end
        
        -- Optional fields
        if charData.title and charData.title ~= "" then
            local titleText = (CreateTitleLink and CreateTitleLink(charData.title, format)) or charData.title
            table_insert(allRows, { "**Title**", titleText })
        end
        
        if charData.age then
            table_insert(allRows, { "**Age**", charData.age })
        end
        
        if charData.esoPlus then
            table_insert(allRows, { "**ESO Plus**", "✅ Active" })
        end
        
        -- Mundus Stone
        if mundusData and mundusData.active then
            local CreateMundusLink = CM.links and CM.links.CreateMundusLink
            local mundusText = (CreateMundusLink and CreateMundusLink(mundusData.name, format)) or mundusData.name
            table_insert(allRows, { "**🪨 Mundus Stone**", mundusText })
        end
        
        -- Active Buffs
        if buffsData and (buffsData.food or buffsData.potion or (buffsData.other and #buffsData.other > 0)) then
            local CreateBuffLink = CM.links and CM.links.CreateBuffLink
            local buffLines = {}
            
            if buffsData.food then
                local foodLink = (CreateBuffLink and CreateBuffLink(buffsData.food, format)) or buffsData.food
                table_insert(buffLines, "Food: " .. foodLink)
            end
            if buffsData.potion then
                local potionLink = (CreateBuffLink and CreateBuffLink(buffsData.potion, format)) or buffsData.potion
                table_insert(buffLines, "Potion: " .. potionLink)
            end
            if buffsData.other and #buffsData.other > 0 then
                local otherBuffs = {}
                for _, buff in ipairs(buffsData.other) do
                    local buffLink = (CreateBuffLink and CreateBuffLink(buff, format)) or buff
                    table_insert(otherBuffs, buffLink)
                end
                if #otherBuffs > 0 then
                    table_insert(buffLines, "Other: " .. table_concat(otherBuffs, ", "))
                end
            end
            
            if #buffLines > 0 then
                table_insert(allRows, { "**🍖 Active Buffs**", table_concat(buffLines, " • ") })
            end
        end
        
        -- Location
        if locationData then
            local zone = locationData.zone or "Unknown"
            local subzone = locationData.subzone
            local zoneIndex = locationData.zoneIndex or 0
            
            local CreateZoneLink = CM.links and CM.links.CreateZoneLink
            local zoneLink = (CreateZoneLink and CreateZoneLink(zone, format)) or zone
            
            local locStr = zoneLink
            if subzone and subzone ~= "" then
                locStr = string_format("%s (%s)", locStr, subzone)
            elseif zoneIndex and zoneIndex > 0 then
                locStr = string_format("%s (%d)", locStr, zoneIndex)
            end
            table_insert(allRows, { "**Location**", locStr })
        end
        
        -- Riding Skills (with emojis like attributes)
        if ridingData then
            local speed = ridingData.speed or 0
            local stamina = ridingData.stamina or 0
            local capacity = ridingData.capacity or 0
            if speed > 0 or stamina > 0 or capacity > 0 then
                table_insert(allRows, {
                    "**🐴 Riding Skills**",
                    string_format("🐴 %d / 💪 %d / 🎒 %d", speed, stamina, capacity)
                })
            end
        end
        
        -- Distribute rows into three balanced tables
        local totalRows = #allRows
        local rowsPerTable = math.ceil(totalRows / 3)
        
        local col1_rows = {}
        local col2_rows = {}
        local col3_rows = {}
        
        for i = 1, totalRows do
            local tableIndex = math.ceil(i / rowsPerTable)
            if tableIndex == 1 then
                table_insert(col1_rows, allRows[i])
            elseif tableIndex == 2 then
                table_insert(col2_rows, allRows[i])
            else
                table_insert(col3_rows, allRows[i])
            end
        end
        
        -- Create three tables
        local headers = { "Attribute", "Value" }
        local options = {
            alignment = { "left", "left" },
            format = format,
            coloredHeaders = true,
        }
        
        local columns = {}
        if #col1_rows > 0 then
            table_insert(columns, CreateStyledTable(headers, col1_rows, options))
        end
        if #col2_rows > 0 then
            table_insert(columns, CreateStyledTable(headers, col2_rows, options))
        end
        if #col3_rows > 0 then
            table_insert(columns, CreateStyledTable(headers, col3_rows, options))
        end
        
        -- Create responsive multi-column layout
        local LayoutCalculator = CM.utils.LayoutCalculator
        local minWidth, gap
        if LayoutCalculator then
            minWidth, gap = LayoutCalculator.GetLayoutParamsWithFallback(
                columns,
                "250px",
                "20px"
            )
        else
            minWidth = "250px"
            gap = "20px"
        end
        local columnsLayout = CreateResponsiveColumns(columns, minWidth, gap)
        result = result .. columnsLayout
        
        return result
    elseif not markdown then
        -- Fallback to simple table format when markdown utilities are not available
        local result = "### General\n\n"
        result = result .. "|| Attribute | Value |\n"
        result = result .. "||:----------|:------|\n"
        result = result .. string_format("|| **Level** | %d |\n", charData.level or 1)

        local CreateRaceLink = CM.links and CM.links.CreateRaceLink
        local CreateClassLink = CM.links and CM.links.CreateClassLink
        local CreateAllianceLink = CM.links and CM.links.CreateAllianceLink

        local raceText = (CreateRaceLink and CreateRaceLink(charData.race, format)) or (charData.race or "Unknown")
        local classText = (CreateClassLink and CreateClassLink(charData.class, format)) or (charData.class or "Unknown")
        local allianceText = (CreateAllianceLink and CreateAllianceLink(charData.alliance, format))
            or (charData.alliance or "Unknown")

        result = result .. string_format("|| **Class** | %s |\n", classText)
        result = result .. string_format("|| **Race** | %s |\n", raceText)
        result = result .. string_format("|| **Alliance** | %s |\n", allianceText)

        local CreateServerLink = CM.links and CM.links.CreateServerLink
        local serverText = (CreateServerLink and CreateServerLink(charData.server, format))
            or (charData.server or "Unknown")
        result = result .. string_format("|| **Server** | %s |\n", serverText)
        result = result .. string_format("|| **Account** | %s |\n", charData.account or "Unknown")
        
        if charData.cp and charData.cp > 0 then
            result = result .. string_format("|| **Champion Points** | %d |\n", charData.cp)
        end
        
        if charData.title and charData.title ~= "" then
            local CreateTitleLink = CM.links and CM.links.CreateTitleLink
            local titleText = (CreateTitleLink and CreateTitleLink(charData.title, format)) or charData.title
            result = result .. string_format("|| **Title** | %s |\n", titleText)
        end
        
        if charData.age then
            result = result .. string_format("|| **Age** | %s |\n", charData.age)
        end

        if charData.esoPlus then
            result = result .. "|| **ESO Plus** | ✅ Active |\n"
        end

        local attrs = charData.attributes or {}
        result = result
            .. string_format(
                "|| **Attributes** | 🔵 %d / ❤️ %d / ⚡ %d |\n",
                attrs.magicka or 0,
                attrs.health or 0,
                attrs.stamina or 0
            )

        if progressionData then
            local unspentSkillPoints = progressionData.unspentSkillPoints or progressionData.skillPoints or 0
            if unspentSkillPoints and unspentSkillPoints > 0 then
                result = result
                    .. string_format("|| **Skill Points** | 🎯 %d available - Ready to spend |\n", unspentSkillPoints)
            else
                result = result .. "|| **Skill Points** | None |\n"
            end

            if progressionData.unspentAttributePoints and progressionData.unspentAttributePoints > 0 then
                result = result
                    .. string_format(
                        "|| **Attribute Points** | ⚠️ %d unspent |\n",
                        progressionData.unspentAttributePoints
                    )
            end

            if progressionData.isVampire then
                local stage = progressionData.vampireStage or 1
                result = result .. string_format("|| **Vampire/Werewolf Status** | 🧛 Vampire Stage %d |\n", stage)
            elseif progressionData.isWerewolf then
                local stage = progressionData.werewolfStage or 1
                result = result .. string_format("|| **Vampire/Werewolf Status** | 🐺 Werewolf Stage %d |\n", stage)
            end

            if progressionData.enlightenment then
                local current = progressionData.enlightenment.current or 0
                local max = progressionData.enlightenment.max or 0
                if max > 0 then
                    local percent = progressionData.enlightenment.percent or 0
                    result = result
                        .. string_format(
                            "|| **Enlightenment** | %s / %s (%d%%) |\n",
                            safeFormat(current),
                            safeFormat(max),
                            percent
                        )
                end
            end
        end
        
        -- Add riding skills summary if available
        if ridingData then
            local speed = ridingData.speed or 0
            local stamina = ridingData.stamina or 0
            local capacity = ridingData.capacity or 0
            if speed > 0 or stamina > 0 or capacity > 0 then
                result = result
                    .. string_format(
                        "|| **🐴 Riding Skills** | 🐴 %d / 💪 %d / 🎒 %d |\n",
                        speed,
                        stamina,
                        capacity
                    )
            end
        end

        if mundusData and mundusData.active then
            local CreateMundusLink = CM.links and CM.links.CreateMundusLink
            local mundusText = (CreateMundusLink and CreateMundusLink(mundusData.name, format)) or mundusData.name
            result = result .. string_format("|| **🪨 Mundus Stone** | %s |\n", mundusText)
        end

        if buffsData and (buffsData.food or buffsData.potion or (buffsData.other and #buffsData.other > 0)) then
            local CreateBuffLink = CM.links and CM.links.CreateBuffLink
            local buffLines = {}

            if buffsData.food then
                local foodLink = (CreateBuffLink and CreateBuffLink(buffsData.food, format)) or buffsData.food
                table.insert(buffLines, "Food: " .. foodLink)
            end
            if buffsData.potion then
                local potionLink = (CreateBuffLink and CreateBuffLink(buffsData.potion, format)) or buffsData.potion
                table.insert(buffLines, "Potion: " .. potionLink)
            end
            if buffsData.other and #buffsData.other > 0 then
                local otherBuffs = {}
                for _, buff in ipairs(buffsData.other) do
                    local buffLink = (CreateBuffLink and CreateBuffLink(buff, format)) or buff
                    table.insert(otherBuffs, buffLink)
                end
                if #otherBuffs > 0 then
                    table.insert(buffLines, "Other: " .. table_concat(otherBuffs, ", "))
                end
            end

            if #buffLines > 0 then
                result = result .. string_format("|| **🍖 Active Buffs** | %s |\n", table_concat(buffLines, " • "))
            end
        end

        if locationData then
            local zone = locationData.zone or "Unknown"
            local subzone = locationData.subzone
            local zoneIndex = locationData.zoneIndex or 0

            local CreateZoneLink = CM.links and CM.links.CreateZoneLink
            local zoneLink = (CreateZoneLink and CreateZoneLink(zone, format)) or zone

            local locStr = zoneLink
            if subzone and subzone ~= "" then
                locStr = string_format("%s (%s)", locStr, subzone)
            elseif zoneIndex and zoneIndex > 0 then
                locStr = string_format("%s (%d)", locStr, zoneIndex)
            end
            result = result .. string_format("|| **Location** | %s |\n", locStr)
        end

        return result .. "\n"
    else
        local lines = {}

        local CreateRaceLink = CM.links and CM.links.CreateRaceLink
        local CreateClassLink = CM.links and CM.links.CreateClassLink
        local CreateAllianceLink = CM.links and CM.links.CreateAllianceLink

        local raceText = (CreateRaceLink and CreateRaceLink(charData.race, format)) or (charData.race or "Unknown")
        local classText = (CreateClassLink and CreateClassLink(charData.class, format)) or (charData.class or "Unknown")
        local allianceText = (CreateAllianceLink and CreateAllianceLink(charData.alliance, format))
            or (charData.alliance or "Unknown")

        table.insert(lines, string_format("**Level:** %d", charData.level or 1))
        table.insert(lines, string_format("**Race:** %s", raceText))
        table.insert(lines, string_format("**Class:** %s", classText))
        table.insert(lines, string_format("**Alliance:** %s", allianceText))

        local CreateServerLink = CM.links and CM.links.CreateServerLink
        local serverText = (CreateServerLink and CreateServerLink(charData.server, format))
            or (charData.server or "Unknown")
        table.insert(lines, string_format("**Server:** %s", serverText))
        table.insert(lines, string_format("**Account:** %s", charData.account or "Unknown"))
        
        if charData.cp and charData.cp > 0 then
            table.insert(lines, string_format("**Champion Points:** %d", charData.cp))
        end
        
        if charData.title and charData.title ~= "" then
            local CreateTitleLink = CM.links and CM.links.CreateTitleLink
            local titleText = (CreateTitleLink and CreateTitleLink(charData.title, format)) or charData.title
            table.insert(lines, string_format("**Title:** %s", titleText))
        end
        
        if charData.age then
            table.insert(lines, string_format("**Age:** %s", charData.age))
        end

        if charData.esoPlus then
            table.insert(lines, "**ESO Plus:** ✅ Active")
        end

        local attrs = charData.attributes or {}
        table.insert(
            lines,
            string_format("**Attributes:** 🔵 %d / ❤️ %d / ⚡ %d", attrs.magicka or 0, attrs.health or 0, attrs.stamina or 0)
        )

        if progressionData then
            local unspentSkillPoints = progressionData.unspentSkillPoints or progressionData.skillPoints or 0
            if unspentSkillPoints and unspentSkillPoints > 0 then
                table.insert(
                    lines,
                    string_format("**Skill Points:** 🎯 %d available - Ready to spend", unspentSkillPoints)
                )
            else
                table.insert(lines, "**Skill Points:** None")
            end

            if progressionData.unspentAttributePoints and progressionData.unspentAttributePoints > 0 then
                table.insert(
                    lines,
                    string_format("**Attribute Points:** ⚠️ %d unspent", progressionData.unspentAttributePoints)
                )
            end

            if progressionData.isVampire then
                local stage = progressionData.vampireStage or 1
                table.insert(lines, string_format("**Vampire/Werewolf Status:** 🧛 Vampire Stage %d", stage))
            elseif progressionData.isWerewolf then
                local stage = progressionData.werewolfStage or 1
                table.insert(lines, string_format("**Vampire/Werewolf Status:** 🐺 Werewolf Stage %d", stage))
            end

            if progressionData.enlightenment then
                local current = progressionData.enlightenment.current or 0
                local max = progressionData.enlightenment.max or 0
                if max > 0 then
                    local percent = progressionData.enlightenment.percent or 0
                    table.insert(
                        lines,
                        string_format("**Enlightenment:** %s / %s (%d%%)", safeFormat(current), safeFormat(max), percent)
                    )
                end
            end
        end
        
        -- Add riding skills summary if available
        if ridingData then
            local speed = ridingData.speed or 0
            local stamina = ridingData.stamina or 0
            local capacity = ridingData.capacity or 0
            if speed > 0 or stamina > 0 or capacity > 0 then
                table.insert(
                    lines,
                    string_format("**🐴 Riding Skills:** 🐴 %d / 💪 %d / 🎒 %d", speed, stamina, capacity)
                )
            end
        end

        if mundusData and mundusData.active then
            local CreateMundusLink = CM.links and CM.links.CreateMundusLink
            local mundusText = (CreateMundusLink and CreateMundusLink(mundusData.name, format)) or mundusData.name
            table.insert(lines, string_format("**Mundus Stone:** %s", mundusText))
        end

        if buffsData and (buffsData.food or buffsData.potion or (buffsData.other and #buffsData.other > 0)) then
            local CreateBuffLink = CM.links and CM.links.CreateBuffLink
            local buffLines = {}

            if buffsData.food then
                local foodLink = (CreateBuffLink and CreateBuffLink(buffsData.food, format)) or buffsData.food
                table.insert(buffLines, "Food: " .. foodLink)
            end
            if buffsData.potion then
                local potionLink = (CreateBuffLink and CreateBuffLink(buffsData.potion, format)) or buffsData.potion
                table.insert(buffLines, "Potion: " .. potionLink)
            end
            if buffsData.other and #buffsData.other > 0 then
                local otherBuffs = {}
                for _, buff in ipairs(buffsData.other) do
                    local buffLink = (CreateBuffLink and CreateBuffLink(buff, format)) or buff
                    table.insert(otherBuffs, buffLink)
                end
                if #otherBuffs > 0 then
                    table.insert(buffLines, "Other: " .. table_concat(otherBuffs, ", "))
                end
            end

            if #buffLines > 0 then
                table.insert(lines, string_format("**Active Buffs:** %s", table_concat(buffLines, " • ")))
            end
        end

        if locationData then
            local zone = locationData.zone or "Unknown"
            local subzone = locationData.subzone
            local zoneIndex = locationData.zoneIndex or 0

            local CreateZoneLink = CM.links and CM.links.CreateZoneLink
            local zoneLink = (CreateZoneLink and CreateZoneLink(zone, format)) or zone

            local locStr = zoneLink
            if subzone and subzone ~= "" then
                locStr = string_format("%s (%s)", locStr, subzone)
            elseif zoneIndex and zoneIndex > 0 then
                locStr = string_format("%s (%d)", locStr, zoneIndex)
            end
            table.insert(lines, string_format("**Location:** %s", locStr))
        end

        local content = table_concat(lines, "  \n")
        return string_format("### General\n\n%s\n\n", content)
    end
end

CM.generators.sections.GenerateGeneral = GenerateGeneral

-- =====================================================
-- CHARACTER STATS SUBSECTION
-- =====================================================

local function GenerateCharacterStats(statsData, format)
    if not statsData then
        return ""
    end

    local GenerateCombatStats = CM.generators.sections.GenerateCombatStats
    if GenerateCombatStats then
        return GenerateCombatStats(statsData, format, true)
    end

    return ""
end

CM.generators.sections.GenerateCharacterStats = GenerateCharacterStats

CM.DebugPrint("GENERATOR", "Overview section generators loaded")

