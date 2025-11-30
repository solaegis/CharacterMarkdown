-- CharacterMarkdown - Companion Section Generator
-- Generates companion-related markdown sections

local CM = CharacterMarkdown

-- Cache for utility functions (lazy-initialized on first use)
local CreateAbilityLink, CreateCompanionLink, Pluralize, GenerateAnchor
local string_format = string.format
local table_insert = table.insert

-- Lazy initialization of cached references
local function InitializeUtilities()
    if not Pluralize then
        CreateAbilityLink = CM.links.CreateAbilityLink
        CreateCompanionLink = CM.links.CreateCompanionLink
        Pluralize = CM.generators.helpers.Pluralize
        GenerateAnchor = CM.utils and CM.utils.markdown and CM.utils.markdown.GenerateAnchor
    end
end

-- =====================================================
-- COMPANION
-- =====================================================

local function GenerateCompanion(companionData, format)
    InitializeUtilities()

    local markdown = ""

    -- For non-Discord formats, show header
    if format ~= "discord" then
        markdown = markdown .. "## 👥 Companions\n\n"
    end

    -- Show Available Companions section at the top
    -- Check both companions list and acquired list for backward compatibility
    local companionsList = companionData and (companionData.companions or companionData.acquired) or {}
    if companionData and #companionsList > 0 then
        -- Show available companions as styled table
        local CreateStyledTable = CM.utils.markdown.CreateStyledTable
        if CreateStyledTable then
            -- Sort companions by name for consistent ordering
            local sortedCompanions = {}
            for _, comp in ipairs(companionsList) do
                table_insert(sortedCompanions, comp)
            end
            table.sort(sortedCompanions, function(a, b)
                return a.name < b.name
            end)

            markdown = markdown .. "### Available Companions\n\n"

            -- Show available companions as list
            for _, comp in ipairs(sortedCompanions) do
                local companionLink = CreateCompanionLink(comp.name, format)
                markdown = markdown .. "- " .. companionLink .. "\n"
            end
            markdown = markdown .. "\n"
        else
            -- Fallback to details format if CreateStyledTable not available
            markdown = markdown .. "<details>\n"
            local summaryBold = (format == "vscode") and "<strong>" or "**"
            local summaryBoldEnd = (format == "vscode") and "</strong>" or "**"
            markdown = markdown
                .. string_format(
                    "<summary>%sAvailable Companions (%d)%s</summary>\n\n",
                    summaryBold,
                    #companionsList,
                    summaryBoldEnd
                )

            local sortedCompanions = {}
            for _, comp in ipairs(companionsList) do
                table_insert(sortedCompanions, comp)
            end
            table.sort(sortedCompanions, function(a, b)
                return a.name < b.name
            end)

            for _, comp in ipairs(sortedCompanions) do
                local companionLink = CreateCompanionLink(comp.name, format)
                markdown = markdown .. "- " .. companionLink .. " (" .. (comp.status or "Available") .. ")\n"
            end

            markdown = markdown .. "\n</details>\n\n"
        end
    elseif format ~= "discord" and (not companionData or not companionData.active) then
        -- Only show "No companions available" if there's no active companion either
        markdown = markdown .. "*No companions available*\n\n"
    end



    -- Extract active companion data
    local activeCompanion = companionData.active
    local companionName = activeCompanion.name or "Unknown"
    local companionLevel = activeCompanion.level or 0
    local skills = companionData.skills

    if format == "discord" then
        local companionNameLinked = CreateCompanionLink(companionName, format)
        markdown = markdown
            .. "\n**Companion:** "
            .. companionNameLinked
            .. " (L"
            .. companionLevel
            .. ")\n"
        if companionData.skills then
            local ultimateText =
                CreateAbilityLink(companionData.skills.ultimate, companionData.skills.ultimateId, format)
            markdown = markdown .. "```" .. ultimateText .. "```\n"
            if companionData.skills.abilities and #companionData.skills.abilities > 0 then
                for i, ability in ipairs(companionData.skills.abilities) do
                    local abilityText = CreateAbilityLink(ability.name, ability.id, format)
                    markdown = markdown .. i .. ". " .. abilityText .. "\n"
                end
            end
        end
        if companionData.equipment and #companionData.equipment > 0 then
            markdown = markdown .. "Equipment:\n"
            for _, item in ipairs(companionData.equipment) do
                local qualityDisplay = (item.qualityEmoji or "⚪") .. " " .. (item.quality or "Normal")
                local itemText = "• " .. item.name .. " (L" .. item.level .. ", " .. qualityDisplay .. ")"

                -- Add set information
                if item.hasSet and item.setName then
                    itemText = itemText .. " [Set: " .. item.setName .. "]"
                end

                -- Add trait information
                if item.traitName and item.traitName ~= "None" then
                    itemText = itemText .. " [Trait: " .. item.traitName .. "]"
                end

                -- Add enchantment information
                if item.enchantName then
                    itemText = itemText .. " [Enchant: " .. item.enchantName .. "]"
                    if item.enchantMaxCharge and item.enchantMaxCharge > 0 then
                        local chargePercent = item.enchantCharge
                                and item.enchantCharge > 0
                                and math.floor((item.enchantCharge / item.enchantMaxCharge) * 100)
                            or 0
                        itemText = itemText .. " (" .. chargePercent .. "%)"
                    end
                end

                markdown = markdown .. itemText .. "\n"
            end
        end
    else
        -- Active Companion section (only shown if there's an active companion)
        markdown = markdown .. "### Active Companion\n\n"

        local companionNameLinked = CreateCompanionLink(companionName, format)
        markdown = markdown .. "#### 🧙 " .. companionNameLinked .. "\n\n"

        -- Collect warnings for companion issues
        local warnings = {}
        local level = companionLevel

        -- Check if underleveled
        if companionLevel < 20 then
            table_insert(
                warnings,
                string_format(
                    "👥 **Companion underleveled**: %s (Level %d/20) - Needs XP",
                    companionName,
                    companionLevel
                )
            )
        end

        -- Check for outdated gear
        local outdatedGearCount = 0
        if companionData.equipment and #companionData.equipment > 0 then
            for _, item in ipairs(companionData.equipment) do
                local itemLevel = item.level or 0
                if itemLevel < companionLevel and itemLevel < 20 then
                    outdatedGearCount = outdatedGearCount + 1
                end
            end
        end
        if outdatedGearCount > 0 then
            table_insert(
                warnings,
                string_format(
                    "👥 **Companion outdated gear**: %d piece%s below level - Upgrade equipment",
                    outdatedGearCount,
                    (outdatedGearCount == 1) and "" or "s"
                )
            )
        end

        -- Check for empty ability slots
        local emptySlots = 0
        if skills then
            -- Check ultimate
            if
                skills.ultimate == "[Empty]"
                or skills.ultimate == "Empty"
                or not skills.ultimate
            then
                emptySlots = emptySlots + 1
            end
            -- Check abilities
            if skills.abilities then
                for _, ability in ipairs(skills.abilities) do
                    if ability.name == "[Empty]" or ability.name == "Empty" or not ability.name then
                        emptySlots = emptySlots + 1
                    end
                end
            end
        end
        if emptySlots > 0 then
            table_insert(
                warnings,
                string_format("👥 **Companion empty ability slots**: %d - Assign abilities", emptySlots)
            )
        end

        -- Check companion rapport low (< 1000)
        if companionData.rapport and companionData.rapport < 1000 then
            table_insert(
                warnings,
                string_format(
                    "💔 **Companion rapport low**: %s (%d) - Build relationship",
                    companionName,
                    companionData.rapport
                )
            )
        end

        -- Skills section - Front bar format (horizontal table) using CreateStyledTable
        if skills then
            local abilities = skills.abilities or {}
            local ultimate = skills.ultimate or "[Empty]"
            local ultimateId = skills.ultimateId

            -- Create Front bar table with abilities (1-5) and ultimate (⚡)
            if #abilities > 0 or ultimate then
                markdown = markdown .. "#### Front Bar\n\n"
                local CreateStyledTable = CM.utils.markdown.CreateStyledTable
                if CreateStyledTable then
                    -- Build headers and row data
                    local headers = {}
                    local rowData = {}

                    -- Add ability column headers (1-5)
                    for i = 1, 5 do
                        table_insert(headers, tostring(i))
                    end

                    -- Add ultimate column header
                    table_insert(headers, "⚡")

                    -- Build row data
                    for i = 1, 5 do
                        if abilities[i] then
                            local abilityText = CreateAbilityLink(abilities[i].name, abilities[i].id, format)
                            table_insert(rowData, abilityText)
                        else
                            table_insert(rowData, "[Empty]")
                        end
                    end

                    -- Add ultimate to row data
                    local ultimateText = CreateAbilityLink(ultimate, ultimateId, format)
                    table_insert(rowData, ultimateText)

                    -- Generate table with styled headers
                    local alignment = {}
                    for i = 1, #headers do
                        table_insert(alignment, "center")
                    end
                    local options = {
                        alignment = alignment,
                        format = format,
                        coloredHeaders = true,
                        width = "100%",
                    }
                    markdown = markdown .. CreateStyledTable(headers, { rowData }, options)
                else
                    -- Fallback to manual table if CreateStyledTable not available
                    local headerRow = "|"
                    local separatorRow = "|"

                    -- Add ability columns (1-5)
                    for i = 1, 5 do
                        headerRow = headerRow .. " " .. i .. " |"
                        separatorRow = separatorRow .. ":--|"
                    end

                    -- Add ultimate column
                    headerRow = headerRow .. " ⚡ |"
                    separatorRow = separatorRow .. ":--|"

                    markdown = markdown .. headerRow .. "\n"
                    markdown = markdown .. separatorRow .. "\n"

                    -- Abilities row (with ultimate in 6th column)
                    local abilitiesRow = "|"

                    -- Add abilities (up to 5)
                    for i = 1, 5 do
                        if abilities[i] then
                            local abilityText = CreateAbilityLink(abilities[i].name, abilities[i].id, format)
                            abilitiesRow = abilitiesRow .. " " .. abilityText .. " |"
                        else
                            abilitiesRow = abilitiesRow .. " [Empty] |"
                        end
                    end

                    -- Add ultimate in 6th column
                    local ultimateText = CreateAbilityLink(ultimate, ultimateId, format)
                    abilitiesRow = abilitiesRow .. " " .. ultimateText .. " |"

                    markdown = markdown .. abilitiesRow .. "\n\n"
                end
            end
        end

        -- Equipment section (styled table with separate columns)
        local equipment = activeCompanion.equipment or companionData.equipment
        if equipment and #equipment > 0 then
            local CreateStyledTable = CM.utils.markdown.CreateStyledTable
            if CreateStyledTable then
                -- Map slot names to emojis (companion slots)
                local slotEmojiMap = {
                    ["Main Hand"] = "⚔️",
                    ["Off Hand"] = "🛡️",
                    ["Head"] = "⛑️",
                    ["Chest"] = "🛡️",
                    ["Shoulders"] = "👑",
                    ["Hands"] = "✋",
                    ["Waist"] = "⚡",
                    ["Legs"] = "👖",
                    ["Feet"] = "👟",
                }

                local headers = { "Slot", "Item", "Quality", "Trait" }
                local rows = {}

                for _, item in ipairs(companionData.equipment) do
                    local warning = ""
                    if item.level and item.level < level and item.level < 20 then
                        warning = " ⚠️"
                    end

                    -- Get emoji for slot
                    local slotEmoji = slotEmojiMap[item.slot] or "📦"
                    local slotText = slotEmoji .. " **" .. item.slot .. "**"

                    -- Item name with level and quality
                    local qualityDisplay = (item.qualityEmoji or "⚪") .. " " .. (item.quality or "Normal")
                    local itemText = item.name .. " (Level " .. item.level .. ", " .. qualityDisplay .. ")" .. warning

                    -- Trait information
                    local traitText = item.traitName or "None"
                    if traitText == "None" then
                        traitText = "-"
                    end

                    local qualityDisplay = (item.qualityEmoji or "⚪") .. " " .. (item.quality or "Normal")
                    table_insert(rows, { slotText, itemText, qualityDisplay, traitText })
                end

                local options = {
                    alignment = { "left", "left", "left", "left" },
                    format = format,
                    coloredHeaders = true,
                    width = "100%",
                }
                markdown = markdown .. CreateStyledTable(headers, rows, options)
            else
                -- Fallback to list format if CreateStyledTable not available
                markdown = markdown .. "**Equipment:**\n"
                for _, item in ipairs(equipment) do
                    local warning = ""
                    if item.level and item.level < level and item.level < 20 then
                        warning = " ⚠️"
                    end

                    local itemText = "- **"
                        .. item.slot
                        .. "**: "
                        .. item.name
                        .. " (Level "
                        .. item.level
                        .. ", "
                        .. ((item.qualityEmoji or "⚪") .. " " .. (item.quality or "Normal"))
                        .. ")"

                    if item.hasSet and item.setName then
                        itemText = itemText .. " — *" .. item.setName .. "*"
                    end

                    if item.traitName and item.traitName ~= "None" then
                        itemText = itemText .. " — Trait: " .. item.traitName
                    end

                    if item.enchantName then
                        itemText = itemText .. " — Enchant: " .. item.enchantName
                        if item.enchantMaxCharge and item.enchantMaxCharge > 0 then
                            local chargePercent = item.enchantCharge
                                    and item.enchantCharge > 0
                                    and math.floor((item.enchantCharge / item.enchantMaxCharge) * 100)
                                or 0
                            itemText = itemText .. " (" .. chargePercent .. "% charge)"
                        end
                    end

                    markdown = markdown .. itemText .. warning .. "\n"
                end
                markdown = markdown .. "\n"
            end
        end

        -- Add warnings using generic function (after equipment section)
        if #warnings > 0 then
            local CreateAttentionNeeded = CM.utils.markdown and CM.utils.markdown.CreateAttentionNeeded
            if CreateAttentionNeeded then
                markdown = markdown .. CreateAttentionNeeded(warnings, format, "Attention Needed")
            else
                -- Fallback to blockquote if function not available
                markdown = markdown .. "> [!WARNING]\n"
                for _, warning in ipairs(warnings) do
                    markdown = markdown .. "> " .. warning .. "  \n"
                end
                markdown = markdown .. "\n"
            end
        end

        markdown = markdown .. "---\n\n"
    end

    return markdown
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.generators.sections = CM.generators.sections or {}
CM.generators.sections.GenerateCompanion = GenerateCompanion
