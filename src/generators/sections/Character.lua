-- CharacterMarkdown - Character Section Generators
-- Generates character identity, overview, and header sections

local CM = CharacterMarkdown
CM.generators = CM.generators or {}
CM.generators.sections = CM.generators.sections or {}

local string_format = string.format
local table_concat = table.concat
local table_insert = table.insert

-- Import advanced markdown utilities (with nil check)
local markdown = (CM.utils and CM.utils.markdown) or nil

-- =====================================================
-- QUICK SUMMARY (One-line format)
-- =====================================================

local function GenerateQuickSummary(charData, equipmentData)
    if not charData then
        return "ERROR: No character data"
    end

    local name = charData.name or "Unknown"
    local level = charData.level or 1
    -- Fix: Use correct field name (cp, not championPoints)
    local cp = charData.cp or 0
    local race = charData.race or "Unknown"
    local class = charData.class or "Unknown"

    -- Get top 2 sets
    local sets = {}
    if equipmentData and equipmentData.sets then
        for setName, count in pairs(equipmentData.sets) do
            if count >= 2 then
                table.insert(sets, string_format("%s(%d)", setName, count))
            end
        end
        table.sort(sets, function(a, b)
            local countA = tonumber(a:match("%((%d+)%)"))
            local countB = tonumber(b:match("%((%d+)%)"))
            return countA > countB
        end)
    end

    local setStr = #sets > 0 and (" • " .. table_concat({ sets[1], sets[2] }, ", ")) or ""

    return string_format("%s • L%d CP%d • %s %s%s", name, level, cp, race, class, setStr)
end

CM.generators.sections.GenerateQuickSummary = GenerateQuickSummary

-- =====================================================
-- ENHANCED HEADER with Badges
-- =====================================================

local function GenerateHeader(charData, format)
    if not charData then
        return "# Unknown Character\n\n"
    end

    local name = charData.name or "Unknown"
    local title = charData.title or ""
    local race = charData.race or "Unknown"
    local class = charData.class or "Unknown"
    local alliance = charData.alliance or "Unknown"
    local level = charData.level or 1
    -- Fix: Use correct field name (cp, not championPoints)
    local cp = charData.cp or 0
    local isESOPlus = charData.esoPlus or false

    -- Use character name as H1, append title if set (format: "Name" or "Name (Title)")
    local displayTitle = name
    if title ~= "" then
        displayTitle = string_format("%s (%s)", name, title)
    end

    -- Enhanced visuals are now always enabled (baseline)
    if format == "discord" or not markdown then
        -- Classic format
        local header = string_format("# %s\n\n", displayTitle)
        header = header .. string_format("**%s %s**  \n", race, class)
        header = header .. string_format("**Level %d • CP %d • %s**\n\n", level, cp, alliance)
        if isESOPlus then
            header = header .. "✨ *ESO Plus Active*\n\n"
        end
        -- Add leading newline for proper markdown formatting
        return "\n" .. header
    end

    -- ENHANCED FORMAT with badges (with nil checks)
    if not markdown.CreateBadgeRow or not markdown.CreateCenteredBlock then
        -- Fallback to classic if functions don't exist
        local header = string_format("# %s\n\n", displayTitle)
        header = header .. string_format("**%s %s**  \n", race, class)
        header = header .. string_format("**Level %d • CP %d • %s**\n\n", level, cp, alliance)
        -- Add leading newline for proper markdown formatting
        return "\n" .. header
    end

    local badges = {
        { label = "Level", value = level, color = "blue" },
        { label = "CP", value = cp, color = "purple" },
        { label = "Class", value = class:gsub(" ", "_"), color = "green" },
    }

    if isESOPlus then
        table.insert(badges, { label = "ESO+", value = "Active", color = "gold" })
    end

    local badgeRow = markdown.CreateBadgeRow(badges) or ""

    local header = markdown.CreateCenteredBlock(string_format(
        [[
# %s

%s

**%s %s • %s Alliance**
]],
        displayTitle,
        badgeRow,
        race,
        class,
        alliance
    )) or string_format("# %s\n\n**%s %s • %s Alliance**\n\n", displayTitle, race, class, alliance)

    -- Use CreateSeparator for consistent separator styling
    local CreateSeparator = markdown and markdown.CreateSeparator
    if CreateSeparator then
        header = header .. CreateSeparator("hr")
    else
        header = header .. "---\n\n"
    end

    -- Add leading newline for proper markdown formatting
    return "\n" .. header
end

CM.generators.sections.GenerateHeader = GenerateHeader

-- =====================================================
-- QUICK STATS (At-a-glance info box)
-- =====================================================

local function GenerateQuickStats(
    charData,
    statsData,
    format,
    equipmentData,
    progressionData,
    currencyData,
    cpData,
    inventoryData,
    locationData,
    buffsData,
    pvpData,
    titlesData,
    mundusData,
    ridingData,
    settings
)
    if not charData then
        return ""
    end
    if format == "discord" then
        return ""
    end -- Skip for Discord

    local formatNumber = CM.utils and CM.utils.FormatNumber
    local safeFormat = function(val)
        if formatNumber then
            return formatNumber(val)
        else
            return tostring(val)
        end
    end

    settings = settings or {}
    local IsSettingEnabled = function(settingName, defaultValue)
        if settings[settingName] == nil then
            return defaultValue ~= false
        end
        return settings[settingName] ~= false
    end

    local generalSection = ""
    if IsSettingEnabled("includeGeneral", true) then
        local GenerateGeneral = CM.generators.sections.GenerateGeneral
        if GenerateGeneral then
            generalSection = GenerateGeneral(charData, progressionData, locationData, buffsData, mundusData, format, ridingData)
        end
    end

    local characterStatsSection = ""
    if IsSettingEnabled("includeCharacterStats", true) then
        local GenerateCharacterStats = CM.generators.sections.GenerateCharacterStats
        if GenerateCharacterStats then
            characterStatsSection = GenerateCharacterStats(statsData, format)
        end
    end

    local currencySection = ""
    if IsSettingEnabled("includeCurrency", true) and currencyData then
        local markdown = CM.utils and CM.utils.markdown
        local CreateStyledTable = markdown and markdown.CreateStyledTable
        
        if CreateStyledTable and format ~= "discord" then
            -- Use styled table
            local currencyRows = {}
            if currencyData.alliancePoints and currencyData.alliancePoints > 0 then
                table_insert(currencyRows, { "**Alliance Points**", safeFormat(currencyData.alliancePoints) })
            end
            if currencyData.telVar and currencyData.telVar > 0 then
                table_insert(currencyRows, { "**Tel Var**", safeFormat(currencyData.telVar) })
            end
            if currencyData.transmuteCrystals and currencyData.transmuteCrystals > 0 then
                table_insert(currencyRows, { "**Transmute Crystals**", safeFormat(currencyData.transmuteCrystals) })
            end
            if currencyData.writs and currencyData.writs > 0 then
                table_insert(currencyRows, { "**Writs**", safeFormat(currencyData.writs) })
            end
            if currencyData.eventTickets and currencyData.eventTickets > 0 then
                table_insert(currencyRows, { "**Event Tickets**", safeFormat(currencyData.eventTickets) })
            end
            
            if #currencyRows > 0 then
                local headers = { "Attribute", "Value" }
                local options = {
                    alignment = { "left", "left" },
                    format = format,
                    coloredHeaders = true,
                }
                local currencyTable = CreateStyledTable(headers, currencyRows, options)
                currencySection = "### Currency\n\n" .. currencyTable
            end
        else
            -- Fallback to simple table format
            local currencyRows = ""
            if currencyData.alliancePoints and currencyData.alliancePoints > 0 then
                currencyRows = currencyRows
                    .. string_format("|| **Alliance Points** | %s |\n", safeFormat(currencyData.alliancePoints))
            end
            if currencyData.telVar and currencyData.telVar > 0 then
                currencyRows = currencyRows .. string_format("|| **Tel Var** | %s |\n", safeFormat(currencyData.telVar))
            end
            if currencyData.transmuteCrystals and currencyData.transmuteCrystals > 0 then
                currencyRows = currencyRows
                    .. string_format("|| **Transmute Crystals** | %s |\n", safeFormat(currencyData.transmuteCrystals))
            end
            if currencyData.writs and currencyData.writs > 0 then
                currencyRows = currencyRows .. string_format("|| **Writs** | %s |\n", safeFormat(currencyData.writs))
            end
            if currencyData.eventTickets and currencyData.eventTickets > 0 then
                currencyRows = currencyRows
                    .. string_format("|| **Event Tickets** | %s |\n", safeFormat(currencyData.eventTickets))
            end
            if currencyRows ~= "" then
                currencySection = string_format("### Currency\n\n|| Attribute | Value |\n||:----------|:------|\n%s\n", currencyRows)
            end
        end
    end

    local result = "## 📋 Overview\n\n"
    
    -- Check if General section uses styled tables (has grid layout)
    local generalHasGrid = generalSection ~= "" and string.find(generalSection, "<div style=\"display: grid;")
    -- Currency uses styled tables if it doesn't start with the fallback format (|| pipes)
    -- and doesn't have a grid wrapper (meaning it's a styled table ready to be added to grid)
    local currencyHasStyledTable = currencySection ~= "" and 
        not string.find(currencySection, "^### Currency\n\n||") and
        not string.find(currencySection, "<div style=")
    
    if generalHasGrid and currencyHasStyledTable then
        -- Both use styled tables - combine into single grid
        -- Extract General's grid content (everything INSIDE the grid div, not the grid div itself)
        local gridStartPos = string.find(generalSection, "<div style=\"display: grid;")
        if gridStartPos then
            -- Find the opening <div> tag end (after the style attribute)
            local gridDivEnd = string.find(generalSection, ">", gridStartPos)
            if gridDivEnd then
                -- Find the matching closing </div> for the grid wrapper by tracking div depth
                local divDepth = 1
                local gridClosePos = nil
                local searchStart = gridDivEnd + 1
                
                for i = searchStart, string.len(generalSection) do
                    -- Check for opening div tag
                    if string.sub(generalSection, i, i + 3) == "<div" then
                        -- Verify it's a complete div tag (check for space, >, or newline after "div")
                        local afterDiv = string.sub(generalSection, i + 4, i + 4)
                        if afterDiv == " " or afterDiv == ">" or afterDiv == "\n" then
                            divDepth = divDepth + 1
                        end
                    -- Check for closing div tag
                    elseif string.sub(generalSection, i, i + 5) == "</div>" then
                        divDepth = divDepth - 1
                        if divDepth == 0 then
                            gridClosePos = i  -- Position of </div>
                            break
                        end
                    end
                end
                
                if gridClosePos then
                    -- Extract only the content INSIDE the grid (between > and </div>)
                    local generalGridContent = string.sub(generalSection, gridDivEnd + 1, gridClosePos - 1)
                    -- Trim any leading/trailing whitespace
                    generalGridContent = string.gsub(generalGridContent, "^%s+", "")
                    generalGridContent = string.gsub(generalGridContent, "%s+$", "")
                    
                    -- Extract Currency content (remove header)
                    local currencyContent = string.gsub(currencySection, "^### Currency\n\n", "")
                    
                    -- Combine into single grid
                    result = result .. '<a id="general"></a>\n\n'
                    result = result .. '### General\n\n'
                    result = result .. '<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px;">\n'
                    result = result .. generalGridContent
                    result = result .. '<div>\n\n'
                    result = result .. '<a id="currency"></a>\n\n'
                    result = result .. '### Currency\n\n'
                    result = result .. currencyContent
                    result = result .. '</div>\n'
                    result = result .. '</div>\n\n'
                else
                    -- Fallback: couldn't find grid closing tag
                    if generalSection ~= "" then
                        result = result .. '<a id="general"></a>\n\n' .. generalSection
                    end
                    if currencySection ~= "" then
                        result = result .. '<a id="currency"></a>\n\n' .. currencySection
                    end
                end
            else
                -- Fallback: couldn't find grid div end
                if generalSection ~= "" then
                    result = result .. '<a id="general"></a>\n\n' .. generalSection
                end
                if currencySection ~= "" then
                    result = result .. '<a id="currency"></a>\n\n' .. currencySection
                end
            end
        else
            -- Fallback: append normally
            if generalSection ~= "" then
                result = result .. '<a id="general"></a>\n\n' .. generalSection
            end
            if currencySection ~= "" then
                result = result .. '<a id="currency"></a>\n\n' .. currencySection
            end
        end
    else
        -- Append sections normally
        if generalSection ~= "" then
            result = result .. '<a id="general"></a>\n\n' .. generalSection
        end
        if currencySection ~= "" then
            result = result .. '<a id="currency"></a>\n\n' .. currencySection
        end
    end
    
    if characterStatsSection ~= "" then
        result = result .. characterStatsSection
    end

    return result
end

CM.generators.sections.GenerateQuickStats = GenerateQuickStats

-- =====================================================
-- ATTENTION NEEDED (Warnings/Important Info)
-- =====================================================

-- FIX #5: Enhanced attention needed with more warnings
local function GenerateAttentionNeeded(progressionData, inventoryData, ridingData, companionData, currencyData, format)
    if format == "discord" then
        return ""
    end

    -- Enhanced visuals are now always enabled (baseline)
    local warnings = {}

    -- Check for unspent points
    if progressionData then
        if progressionData.unspentSkillPoints and progressionData.unspentSkillPoints > 0 then
            table.insert(
                warnings,
                string_format("🎯 **%d skill points available** - Ready to spend", progressionData.unspentSkillPoints)
            )
        end
        if progressionData.unspentAttributePoints and progressionData.unspentAttributePoints > 0 then
            table.insert(
                warnings,
                string_format("⚠️ **%d unspent attribute points**", progressionData.unspentAttributePoints)
            )
        end
    end

    -- Check inventory capacity warnings (>90%)
    if inventoryData then
        if inventoryData.backpackPercent and inventoryData.backpackPercent >= 90 then
            table.insert(warnings, string_format("🎒 **Backpack nearly full** (%d%%)", inventoryData.backpackPercent))
        end
        if inventoryData.bankPercent and inventoryData.bankPercent >= 90 then
            table.insert(warnings, string_format("🏦 **Bank nearly full** (%d%%)", inventoryData.bankPercent))
        end
    end

    -- Check riding skill training available
    if ridingData then
        local speed = ridingData.speed or 0
        local stamina = ridingData.stamina or 0
        local capacity = ridingData.capacity or 0
        if speed < 60 or stamina < 60 or capacity < 60 then
            local incomplete = {}
            if speed < 60 then
                table.insert(incomplete, "Speed")
            end
            if stamina < 60 then
                table.insert(incomplete, "Stamina")
            end
            if capacity < 60 then
                table.insert(incomplete, "Capacity")
            end
            table.insert(
                warnings,
                string_format("🐴 **Riding training available**: %s", table_concat(incomplete, ", "))
            )
        end
    end

    -- Check companion rapport low (keep this for rapport-specific warnings)
    if companionData and companionData.active and companionData.rapport then
        if companionData.rapport < 1000 then
            table.insert(
                warnings,
                string_format(
                    "💔 **Companion rapport low**: %s (%d)",
                    companionData.name or "Unknown",
                    companionData.rapport
                )
            )
        end
    end

    -- Check event tickets at maximum (12 is the cap in ESO)
    if currencyData then
        local eventTickets = currencyData.eventTickets or 0
        if eventTickets >= 12 then
            table.insert(
                warnings,
                string_format(
                    "🎫 **Event tickets at maximum** (%d/12) - Use tickets to avoid wasting future rewards",
                    eventTickets
                )
            )
        end
    end

    if #warnings == 0 then
        return ""
    end

    -- Add section header
    local result = "## ⚠️ Attention Needed\n\n"

    -- Use generic function for warnings (blockquote for GitHub, styled table for VSCode/Discord)
    local CreateAttentionNeeded = CM.utils.markdown and CM.utils.markdown.CreateAttentionNeeded
    if CreateAttentionNeeded then
        result = result .. CreateAttentionNeeded(warnings, format, "Attention Needed")
    else
        -- Fallback to old format if function not available
        local content = table_concat(warnings, "  \n")
        if markdown and markdown.CreateCallout then
            result = result .. markdown.CreateCallout("warning", content, format)
        else
            result = result .. content .. "\n\n"
        end
    end

    return result
end

CM.generators.sections.GenerateAttentionNeeded = GenerateAttentionNeeded


CM.generators.sections.GenerateProgression = GenerateProgression

-- =====================================================
-- CUSTOM NOTES SECTION
-- =====================================================

-- Helper function to auto-link sets and abilities in build notes
local function AutoLinkSetsAndAbilities(notes, format, equipmentData, skillBarData)
    if not notes or notes == "" then
        return notes
    end
    if format ~= "github" and format ~= "discord" then
        return notes
    end -- Only link in formats that support it

    local CreateSetLink = CM.links and CM.links.CreateSetLink
    local CreateAbilityLink = CM.links and CM.links.CreateAbilityLink

    if not CreateSetLink and not CreateAbilityLink then
        return notes
    end

    local processedNotes = notes

    -- Extract set names from equipment data
    local setNames = {}
    if equipmentData and equipmentData.sets then
        for _, set in ipairs(equipmentData.sets) do
            if set.name and set.name ~= "" and set.name ~= "-" then
                -- Escape special regex characters in set name for pattern matching
                local escapedName = set.name:gsub("([%(%)%.%+%*%?%[%]%^%$%%])", "%%%1")
                if not setNames[set.name] then
                    setNames[set.name] = true
                    -- Only link if not already linked (avoid double-linking)
                    local pattern = "%f[%w]" .. escapedName .. "%f[%W]"
                    local alreadyLinked = processedNotes:find("%[" .. escapedName .. "%]%(")
                    if not alreadyLinked then
                        local linkedName = CreateSetLink(set.name, format)
                        if linkedName and linkedName ~= set.name then
                            -- Replace set name with linked version (word boundary aware)
                            processedNotes = processedNotes:gsub(pattern, linkedName)
                        end
                    end
                end
            end
        end
    end

    -- Extract ability names from skill bar data
    local abilityNames = {}
    if skillBarData and skillBarData.bars then
        for _, bar in ipairs(skillBarData.bars) do
            if bar.abilities then
                for _, ability in ipairs(bar.abilities) do
                    if
                        ability.name
                        and ability.name ~= ""
                        and ability.name ~= "[Empty]"
                        and ability.name ~= "[Empty Slot]"
                    then
                        -- Clean ability name (remove rank suffixes like " IV")
                        local cleanName =
                            ability.name:gsub("%s+IV$", ""):gsub("%s+III$", ""):gsub("%s+II$", ""):gsub("%s+I$", "")
                        if cleanName ~= "" and not abilityNames[cleanName] then
                            abilityNames[cleanName] = true
                            -- Escape special regex characters
                            local escapedName = cleanName:gsub("([%(%)%.%+%*%?%[%]%^%$%%])", "%%%1")
                            -- Only link if not already linked
                            local pattern = "%f[%w]" .. escapedName .. "%f[%W]"
                            local alreadyLinked = processedNotes:find("%[" .. escapedName .. "%]%(")
                            if not alreadyLinked then
                                local linkedName = CreateAbilityLink(cleanName, ability.abilityId, format)
                                if linkedName and linkedName ~= cleanName then
                                    -- Replace ability name with linked version (word boundary aware)
                                    processedNotes = processedNotes:gsub(pattern, linkedName)
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return processedNotes
end

local function GenerateCustomNotes(customNotes, format, equipmentData, skillBarData)
    if not customNotes or customNotes == "" then
        return ""
    end

    -- Auto-link sets and abilities in notes
    local processedNotes = AutoLinkSetsAndAbilities(customNotes, format, equipmentData, skillBarData)

    -- Enhanced visuals are now always enabled (baseline)
    -- Use collapsible section (with nil check)
    if markdown and markdown.CreateCollapsible then
        return markdown.CreateCollapsible("Build Notes", processedNotes, "📝", true)
            or string_format("## 📝 Build Notes\n\n%s\n\n", processedNotes)
    else
        return string_format("## 📝 Build Notes\n\n%s\n\n", processedNotes)
    end
end

CM.generators.sections.GenerateCustomNotes = GenerateCustomNotes

-- =====================================================
-- DYNAMIC TABLE OF CONTENTS (from Registry)
-- =====================================================

-- Generate Table of Contents dynamically from section registry
-- This ensures TOC always matches actual output
local function GenerateDynamicTableOfContents(registry, format)
    if format == "discord" or format == "quick" then
        return ""
    end

    local tocLines = {}

    -- Helper function to generate anchor links (matches GitHub anchor generation)
    local function GenerateAnchor(text)
        if not text then
            return ""
        end

        -- Keep only ASCII letters, numbers, spaces, and basic punctuation
        -- This removes emojis and other Unicode characters
        local anchor = ""
        for i = 1, #text do
            local byte = text:byte(i)
            if
                (byte >= 48 and byte <= 57) -- 0-9
                or (byte >= 65 and byte <= 90) -- A-Z
                or (byte >= 97 and byte <= 122) -- a-z
                or byte == 32
                or byte == 45
            then -- space or hyphen
                anchor = anchor .. text:sub(i, i)
            end
        end

        -- Convert to lowercase and replace spaces with hyphens
        anchor = anchor:lower():gsub("%s+", "-")

        -- Remove leading/trailing hyphens and collapse multiple hyphens
        anchor = anchor:gsub("^%-+", ""):gsub("%-+$", ""):gsub("%-%-+", "-")

        return anchor
    end

    -- Loop through registry and build TOC for sections with tocEntry metadata
    for _, section in ipairs(registry) do
        -- Check if section has TOC entry and condition is met
        if section.tocEntry then
            local shouldInclude = false

            -- Evaluate condition (can be boolean or function)
            if type(section.condition) == "function" then
                shouldInclude = section.condition()
            else
                shouldInclude = section.condition
            end

            if shouldInclude then
                local tocEntry = section.tocEntry
                local anchor = GenerateAnchor(tocEntry.title)

                -- Main section entry
                table_insert(tocLines, string_format("- [%s](#%s)", tocEntry.title, anchor))

                -- Add subsections if present
                if tocEntry.subsections then
                    for _, subsection in ipairs(tocEntry.subsections) do
                        local subAnchor = GenerateAnchor(subsection)
                        table_insert(tocLines, string_format("  - [%s](#%s)", subsection, subAnchor))
                    end
                end
            end
        end
    end

    -- Build final TOC markdown
    if #tocLines == 0 then
        return ""
    end

    local tocContent = table_concat(tocLines, "\n")
    -- Use CreateSeparator for consistent separator styling
    local CreateSeparator = markdown and markdown.CreateSeparator
    local separator = CreateSeparator and CreateSeparator("hr") or "---\n\n"
    return string_format("## 📑 Table of Contents\n\n%s\n\n%s", tocContent, separator)
end

CM.generators.sections.GenerateDynamicTableOfContents = GenerateDynamicTableOfContents

-- =====================================================
-- MODULE INITIALIZATION
-- =====================================================

CM.DebugPrint("GENERATOR", "Character section generators loaded (enhanced visuals)")
