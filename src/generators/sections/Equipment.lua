-- CharacterMarkdown - Equipment Section Generators
-- Generates equipment-related markdown sections (equipment, skill bars, skills)

local CM = CharacterMarkdown

-- Cache for utility functions (lazy-initialized on first use)
local CreateAbilityLink, CreateSetLink, CreateSkillLineLink
local FormatNumber, GenerateProgressBar
local markdown

-- Lazy initialization of cached references
local function InitializeUtilities()
    if not FormatNumber then
        -- Defensive: Check if functions exist before assigning
        CreateAbilityLink = (CM.links and CM.links.CreateAbilityLink)
            or function(name, id, fmt)
                return name or ""
            end
        CreateSetLink = (CM.links and CM.links.CreateSetLink) or function(name, fmt)
            return name or ""
        end
        CreateSkillLineLink = (CM.links and CM.links.CreateSkillLineLink)
            or function(name, fmt)
                return name or ""
            end
        FormatNumber = (CM.utils and CM.utils.FormatNumber) or function(num)
            return tostring(num or 0)
        end
        GenerateProgressBar = (CM.generators and CM.generators.helpers and CM.generators.helpers.GenerateProgressBar)
            or function(percent, width)
                return ""
            end
        markdown = (CM.utils and CM.utils.markdown) or nil
    end
end

-- =====================================================
-- HELPER: Get Set Type Badge
-- =====================================================

local function GetSetTypeBadge(setTypeName)
    if not setTypeName then
        return ""
    end

    local badges = {
        ["Trial"] = "🏰", -- Changed from 🏛️ for better compatibility
        ["Dungeon"] = "🏰",
        ["Overland"] = "🌍",
        ["Crafted"] = "⚒️",
        ["Monster"] = "👹",
        ["Arena"] = "⚔️",
        ["Battleground"] = "🎯",
        ["Cyrodiil"] = "🗡️",
        ["Imperial City"] = "🏰", -- Changed from 🏛️ for better compatibility
        ["Mythic"] = "✨",
        ["Class"] = "📚",
    }

    local badge = badges[setTypeName] or "📦"
    return badge .. " " .. setTypeName
end

-- =====================================================
-- FORWARD DECLARATIONS (for functions called before they're defined)
-- =====================================================

local GenerateEquipment
local GenerateSkillMorphs

-- =====================================================
-- SKILL BARS ONLY (Front/Back Bar tables only)
-- =====================================================

local function GenerateSkillBarsOnly(skillBarData, format)
    -- Defensive: Handle nil or invalid format
    if not format then
        format = "github"
    end

    -- Safe initialization
    local success, err = pcall(InitializeUtilities)
    if not success then
        CM.DebugPrint("GENERATOR", "GenerateSkillBarsOnly: InitializeUtilities failed: " .. tostring(err))
    end

    -- Validate input data - handle nil, non-table, or empty table
    if not skillBarData or type(skillBarData) ~= "table" or #skillBarData == 0 then
        CM.DebugPrint("EQUIPMENT", "GenerateSkillBarsOnly: No skill bar data provided")
        if format == "discord" then
            return "\n**Skill Bars:**\n*No skill bars configured*\n"
        else
            return "## ⚔️ Combat Arsenal\n\n*No skill bars configured*\n\n"
        end
    end

    local output = ""

    if format == "discord" then
        output = output .. "\n**Skill Bars:**\n"
        for barIdx, bar in ipairs(skillBarData) do
            if bar and type(bar) == "table" then
                output = output .. (bar.name or "Unknown Bar") .. "\n"
                local ultimateText = ""
                if CreateAbilityLink then
                    ultimateText = CreateAbilityLink(bar.ultimate or "", bar.ultimateId, format)
                        or (bar.ultimate or "[Empty]")
                else
                    ultimateText = bar.ultimate or "[Empty]"
                end
                output = output .. "```" .. ultimateText .. "```\n"
                local abilities = (bar.abilities and type(bar.abilities) == "table") and bar.abilities or {}
                for i, ability in ipairs(abilities) do
                    if ability and type(ability) == "table" then
                        local abilityText = ""
                        if CreateAbilityLink then
                            abilityText = CreateAbilityLink(ability.name or "", ability.id, format)
                                or (ability.name or "Unknown")
                        else
                            abilityText = ability.name or "Unknown"
                        end
                        output = output .. i .. ". " .. abilityText .. "\n"
                    end
                end
            end
        end
    else
        output = output .. "## ⚔️ Combat Arsenal\n\n"

        -- Determine weapon types from bar names for better labels
        local barLabels = {
            { emoji = "⚔️", suffix = "" },
            { emoji = "🔮", suffix = "" },
        }

        -- Try to detect weapon types from bar names
        for barIdx, bar in ipairs(skillBarData) do
            local barName = bar.name or ""
            if barName:find("Backup") or barName:find("Back Bar") then
                barLabels[barIdx].suffix = " (Backup)"
            elseif barName:find("Main") or barName:find("Front") then
                barLabels[barIdx].suffix = " (Main Hand)"
            end
        end

        for barIdx, bar in ipairs(skillBarData) do
            if bar and type(bar) == "table" then
                local label = barLabels[barIdx] or { emoji = "⚔️", suffix = "" }
                local barName = bar.name or "Unknown Bar"
                output = output .. "### " .. label.emoji .. " " .. label.emoji .. " " .. barName .. "\n\n"

                -- Safely get abilities array
                local abilities = (bar.abilities and type(bar.abilities) == "table") and bar.abilities or {}
                local hasUltimate = bar.ultimate and bar.ultimate ~= ""

                -- Abilities table (horizontal format) using CreateStyledTable
                if #abilities > 0 or hasUltimate then
                    local CreateStyledTable = CM.utils.markdown.CreateStyledTable
                    if not CreateStyledTable then
                        -- Fallback to manual table if CreateStyledTable not available
                        local headerRow = "|"
                        local separatorRow = "|"
                        for i = 1, #abilities do
                            headerRow = headerRow .. " " .. i .. " |"
                            separatorRow = separatorRow .. ":--|"
                        end
                        if hasUltimate then
                            headerRow = headerRow .. " ⚡ |"
                            separatorRow = separatorRow .. ":--|"
                        end
                        output = output .. headerRow .. "\n"
                        output = output .. separatorRow .. "\n"

                        local abilitiesRow = "|"
                        for _, ability in ipairs(abilities) do
                            if ability and type(ability) == "table" then
                                local abilityText = ""
                                if CreateAbilityLink then
                                    local success_ab, abText =
                                        pcall(CreateAbilityLink, ability.name or "Unknown", ability.id, format)
                                    if success_ab and abText then
                                        abilityText = abText
                                    else
                                        abilityText = ability.name or "Unknown"
                                    end
                                else
                                    abilityText = ability.name or "Unknown"
                                end
                                abilitiesRow = abilitiesRow .. " " .. abilityText .. " |"
                            else
                                abilitiesRow = abilitiesRow .. " - |"
                            end
                        end
                        if hasUltimate then
                            local ultimateText = ""
                            if CreateAbilityLink then
                                local success_ult, ultText =
                                    pcall(CreateAbilityLink, bar.ultimate or "", bar.ultimateId, format)
                                if success_ult and ultText then
                                    ultimateText = ultText
                                else
                                    ultimateText = bar.ultimate or "[Empty]"
                                end
                            else
                                ultimateText = bar.ultimate or "[Empty]"
                            end
                            abilitiesRow = abilitiesRow .. " " .. ultimateText .. " |"
                        end
                        output = output .. abilitiesRow .. "\n\n"
                    else
                        -- Build headers and row data
                        local headers = {}
                        local rowData = {}

                        -- Add ability column headers (1-5)
                        for i = 1, #abilities do
                            table.insert(headers, tostring(i))
                        end

                        -- Add ultimate column header
                        if hasUltimate then
                            table.insert(headers, "⚡")
                        end

                        -- Build row data
                        for _, ability in ipairs(abilities) do
                            if ability and type(ability) == "table" then
                                local abilityText = ""
                                if CreateAbilityLink then
                                    local success_ab, abText =
                                        pcall(CreateAbilityLink, ability.name or "Unknown", ability.id, format)
                                    if success_ab and abText then
                                        abilityText = abText
                                    else
                                        abilityText = ability.name or "Unknown"
                                    end
                                else
                                    abilityText = ability.name or "Unknown"
                                end
                                table.insert(rowData, abilityText)
                            else
                                table.insert(rowData, "-")
                            end
                        end

                        -- Add ultimate to row data
                        if hasUltimate then
                            local ultimateText = ""
                            if CreateAbilityLink then
                                local success_ult, ultText =
                                    pcall(CreateAbilityLink, bar.ultimate or "", bar.ultimateId, format)
                                if success_ult and ultText then
                                    ultimateText = ultText
                                else
                                    ultimateText = bar.ultimate or "[Empty]"
                                end
                            else
                                ultimateText = bar.ultimate or "[Empty]"
                            end
                            table.insert(rowData, ultimateText)
                        end

                        -- Generate table with styled headers
                        local alignment = {}
                        for i = 1, #headers do
                            table.insert(alignment, "center")
                        end
                        local options = {
                            alignment = alignment,
                            format = format,
                            coloredHeaders = true,
                            width = "100%",
                        }
                        output = output .. CreateStyledTable(headers, { rowData }, options)
                    end
                end
            end
        end

        if output == "## ⚔️ Combat Arsenal\n\n" then
            output = output .. "*No skill bars configured*\n\n"
        end
    end

    return output
end

-- =====================================================
-- SKILL BARS (LEGACY - includes Equipment and Character Progress)
-- =====================================================

local function GenerateSkillBars(skillBarData, format, skillMorphsData, skillProgressionData, equipmentData)
    -- Defensive: Handle nil or invalid format
    if not format then
        format = "github"
    end

    -- Safe initialization
    local success, err = pcall(InitializeUtilities)
    if not success then
        CM.DebugPrint("GENERATOR", "GenerateSkillBars: InitializeUtilities failed: " .. tostring(err))
    end

    -- Validate input data - handle nil, non-table, or empty table
    if not skillBarData or type(skillBarData) ~= "table" or #skillBarData == 0 then
        CM.DebugPrint("EQUIPMENT", "GenerateSkillBars: No skill bar data provided")
        if format == "discord" then
            return "\n**Skill Bars:**\n*No skill bars configured*\n"
        else
            local placeholder = "## ⚔️ Combat Arsenal\n\n*No skill bars configured*\n\n---\n\n"
            CM.DebugPrint(
                "EQUIPMENT",
                string.format("GenerateSkillBars: Returning placeholder (%d chars)", string.len(placeholder))
            )
            return placeholder
        end
    end

    local output = ""
    local CreateCollapsible = markdown and markdown.CreateCollapsible

    CM.DebugPrint(
        "EQUIPMENT",
        string.format(
            "GenerateSkillBars: format=%s, skillBarData type=%s, length=%s",
            format,
            type(skillBarData),
            skillBarData and tostring(#skillBarData) or "nil"
        )
    )

    if format == "discord" then
        output = output .. "\n**Skill Bars:**\n"
        for barIdx, bar in ipairs(skillBarData) do
            if bar and type(bar) == "table" then
                output = output .. (bar.name or "Unknown Bar") .. "\n"
                local ultimateText = ""
                if CreateAbilityLink then
                    ultimateText = CreateAbilityLink(bar.ultimate or "", bar.ultimateId, format)
                        or (bar.ultimate or "[Empty]")
                else
                    ultimateText = bar.ultimate or "[Empty]"
                end
                output = output .. "```" .. ultimateText .. "```\n"
                local abilities = (bar.abilities and type(bar.abilities) == "table") and bar.abilities or {}
                for i, ability in ipairs(abilities) do
                    if ability and type(ability) == "table" then
                        local abilityText = ""
                        if CreateAbilityLink then
                            abilityText = CreateAbilityLink(ability.name or "", ability.id, format)
                                or (ability.name or "Unknown")
                        else
                            abilityText = ability.name or "Unknown"
                        end
                        output = output .. i .. ". " .. abilityText .. "\n"
                    end
                end
            end
        end
    else
        output = output .. "## ⚔️ Combat Arsenal\n\n"

        -- Determine weapon types from bar names for better labels
        -- Using widely-supported emojis (🗡️ may not render, using ⚔️ instead)
        local barLabels = {
            { emoji = "⚔️", suffix = "" }, -- Changed from 🗡️ for better compatibility
            { emoji = "🔮", suffix = "" },
        }

        -- Try to detect weapon types from bar names
        for barIdx, bar in ipairs(skillBarData) do
            local barName = bar.name or ""
            if barName:find("Backup") or barName:find("Back Bar") then
                barLabels[barIdx].suffix = " (Backup)"
            elseif barName:find("Main") or barName:find("Front") then
                barLabels[barIdx].suffix = " (Main Hand)"
            end
        end

        for barIdx, bar in ipairs(skillBarData) do
            if bar and type(bar) == "table" then
                local label = barLabels[barIdx] or { emoji = "⚔️", suffix = "" }
                local barName = bar.name or "Unknown Bar"
                output = output .. "### " .. label.emoji .. " " .. barName .. "\n\n"

                -- Safely get abilities array
                local abilities = (bar.abilities and type(bar.abilities) == "table") and bar.abilities or {}
                local hasUltimate = bar.ultimate and bar.ultimate ~= ""

                -- Abilities table (horizontal format) using CreateStyledTable
                if #abilities > 0 or hasUltimate then
                    local CreateStyledTable = CM.utils.markdown.CreateStyledTable
                    if not CreateStyledTable then
                        -- Fallback to manual table if CreateStyledTable not available
                        local headerRow = "|"
                        local separatorRow = "|"
                        for i = 1, #abilities do
                            headerRow = headerRow .. " " .. i .. " |"
                            separatorRow = separatorRow .. ":--|"
                        end
                        if hasUltimate then
                            headerRow = headerRow .. " ⚡ |"
                            separatorRow = separatorRow .. ":--|"
                        end
                        output = output .. headerRow .. "\n"
                        output = output .. separatorRow .. "\n"

                        local abilitiesRow = "|"
                        for _, ability in ipairs(abilities) do
                            if ability and type(ability) == "table" then
                                local abilityName = ability.name or "Unknown"
                                local abilityId = ability.id
                                local abilityText = ""
                                if CreateAbilityLink then
                                    local success_ab, abText = pcall(CreateAbilityLink, abilityName, abilityId, format)
                                    if success_ab and abText then
                                        abilityText = abText
                                    else
                                        abilityText = abilityName
                                    end
                                else
                                    abilityText = abilityName
                                end
                                abilitiesRow = abilitiesRow .. " " .. abilityText .. " |"
                            else
                                abilitiesRow = abilitiesRow .. " - |"
                            end
                        end
                        -- Add ultimate in 6th column if present
                        if hasUltimate then
                            local ultimateId = bar.ultimateId
                            local ultimateText = ""
                            if CreateAbilityLink then
                                local success_ult, ultText =
                                    pcall(CreateAbilityLink, bar.ultimate or "", ultimateId, format)
                                if success_ult and ultText then
                                    ultimateText = ultText
                                else
                                    ultimateText = bar.ultimate or "[Empty]"
                                end
                            else
                                ultimateText = bar.ultimate or "[Empty]"
                            end
                            abilitiesRow = abilitiesRow .. " " .. ultimateText .. " |"
                        end
                        output = output .. abilitiesRow .. "\n\n"
                    else
                        -- Build headers and row data
                        local headers = {}
                        local rowData = {}

                        -- Add ability column headers (1-5)
                        for i = 1, #abilities do
                            table.insert(headers, tostring(i))
                        end

                        -- Add ultimate column header
                        if hasUltimate then
                            table.insert(headers, "⚡")
                        end

                        -- Build row data
                        for _, ability in ipairs(abilities) do
                            if ability and type(ability) == "table" then
                                local abilityName = ability.name or "Unknown"
                                local abilityId = ability.id
                                local abilityText = ""
                                if CreateAbilityLink then
                                    local success_ab, abText = pcall(CreateAbilityLink, abilityName, abilityId, format)
                                    if success_ab and abText then
                                        abilityText = abText
                                    else
                                        abilityText = abilityName
                                    end
                                else
                                    abilityText = abilityName
                                end
                                table.insert(rowData, abilityText)
                            else
                                table.insert(rowData, "-")
                            end
                        end

                        -- Add ultimate to row data
                        if hasUltimate then
                            local ultimateId = bar.ultimateId
                            local ultimateText = ""
                            if CreateAbilityLink then
                                local success_ult, ultText =
                                    pcall(CreateAbilityLink, bar.ultimate or "", ultimateId, format)
                                if success_ult and ultText then
                                    ultimateText = ultText
                                else
                                    ultimateText = bar.ultimate or "[Empty]"
                                end
                            else
                                ultimateText = bar.ultimate or "[Empty]"
                            end
                            table.insert(rowData, ultimateText)
                        end

                        -- Generate table with styled headers
                        local alignment = {}
                        for i = 1, #headers do
                            table.insert(alignment, "center")
                        end
                        local options = {
                            alignment = alignment,
                            format = format,
                            coloredHeaders = true,
                            width = "100%",
                        }
                        output = output .. CreateStyledTable(headers, { rowData }, options)
                    end
                end
            else
                CM.DebugPrint("GENERATOR", "GenerateSkillBars: bar at index " .. tostring(barIdx) .. " is nil or not a table, skipping")
            end
        end

        -- Ensure we always have at least the header and separator
        if output == "## ⚔️ Combat Arsenal\n\n" then
            output = output .. "*No skill bars configured*\n\n"
        end

        -- Add Equipment & Active Sets (non-collapsible) before Character Progress sections
        if equipmentData and format ~= "discord" then
            CM.Info("→ Including Equipment & Active Sets in Combat Arsenal")
            CM.DebugPrint(
                "EQUIPMENT",
                string.format("GenerateSkillBars: equipmentData exists, type=%s", type(equipmentData))
            )
            if equipmentData.sets then
                CM.DebugPrint("EQUIPMENT", string.format("equipmentData.sets count: %d", #equipmentData.sets))
            end
            if equipmentData.items then
                CM.DebugPrint("EQUIPMENT", string.format("equipmentData.items count: %d", #equipmentData.items))
            end

            -- Pass true for noWrapper parameter to skip collapsible wrapping
            local success_equip, equipmentContent = pcall(GenerateEquipment, equipmentData, format, true)

            CM.DebugPrint(
                "EQUIPMENT",
                string.format(
                    "GenerateEquipment result: success=%s, content length=%d",
                    tostring(success_equip),
                    equipmentContent and #equipmentContent or 0
                )
            )

            if success_equip and equipmentContent and equipmentContent ~= "" then
                -- Equipment content is already formatted without wrapper, just add it
                CM.Info(string.format("  ✓ Equipment content added: %d chars", #equipmentContent))
                output = output .. equipmentContent
            else
                CM.Error("GenerateSkillBars: Failed to generate Equipment content")
                CM.Error(string.format("  success=%s, content=%s", tostring(success_equip), tostring(equipmentContent)))
                -- Add placeholder so user knows equipment failed
                output = output
                    .. '<a id="equipment--active-sets"></a>\n\n## ⚔️ Equipment & Active Sets\n\n*Error generating equipment data*\n\n'
            end
        else
            CM.DebugPrint("GENERATOR",
                string.format(
                    "GenerateSkillBars: Skipping Equipment - equipmentData=%s, format=%s",
                    tostring(equipmentData ~= nil),
                    tostring(format)
                )
            )
        end

        -- Use CreateSeparator for consistent separator styling
        local CreateSeparator = markdown and markdown.CreateSeparator
        if CreateSeparator then
            output = output .. CreateSeparator("hr")
        else
            output = output .. "---\n\n"
        end

        -- Add Skill Morphs as collapsible subsection
        if skillMorphsData and type(skillMorphsData) == "table" and (#skillMorphsData > 0 or next(skillMorphsData)) then
            local success, skillMorphsContent = pcall(GenerateSkillMorphs, skillMorphsData, format)
            if success and skillMorphsContent and type(skillMorphsContent) == "string" then
                -- Remove the header from Skill Morphs content
                skillMorphsContent = skillMorphsContent:gsub("^##%s+🌿%s+Skill%s+Morphs%s*\n%s*\n", "")
                -- Remove trailing separator
                skillMorphsContent = skillMorphsContent:gsub("%-%-%-%s*\n%s*\n%s*$", "")

                if skillMorphsContent ~= "" then
                    if CreateCollapsible then
                        local success2, collapsibleContent =
                            pcall(CreateCollapsible, "Skill Morphs", skillMorphsContent, "🌿", false)
                        if success2 and collapsibleContent then
                            output = output .. collapsibleContent
                        else
                            output = output .. "### 🌿 Skill Morphs\n\n" .. skillMorphsContent .. "\n\n"
                        end
                    else
                        output = output .. "### 🌿 Skill Morphs\n\n" .. skillMorphsContent .. "\n\n"
                    end
                end
            else
                CM.DebugPrint("EQUIPMENT", "GenerateSkillBars: Failed to generate Skill Morphs content")
            end
        end

        -- Add Character Progress categories as collapsible subsections
        if skillProgressionData and #skillProgressionData > 0 then
            -- Add Character Progress section header (H2)
            output = output .. "## 📜 Character Progress\n\n"

            for _, category in ipairs(skillProgressionData) do
                if category.skills and #category.skills > 0 then
                    -- Generate content for this category only
                    local categoryContent = ""
                    local categoryEmoji = category.emoji or "⚔️"

                    -- Group skills by status
                    local maxedSkills = {}
                    local inProgressSkills = {}
                    local lowLevelSkills = {}

                    for _, skill in ipairs(category.skills) do
                        if skill.isRacial or skill.maxed or (skill.rank and skill.rank >= 50) then
                            table.insert(maxedSkills, skill)
                        elseif skill.rank and skill.rank >= 20 then
                            table.insert(inProgressSkills, skill)
                        else
                            table.insert(lowLevelSkills, skill)
                        end
                    end

                    -- Show maxed skills first (compact)
                    if #maxedSkills > 0 then
                        local maxedNames = {}
                        for _, skill in ipairs(maxedSkills) do
                            local skillNameLinked = CreateSkillLineLink(skill.name, format)
                            table.insert(maxedNames, "**" .. skillNameLinked .. "**")
                        end
                        categoryContent = categoryContent .. "#### ✅ Maxed\n"
                        categoryContent = categoryContent .. table.concat(maxedNames, ", ") .. "\n\n"
                    end

                    -- Show in-progress skills with progress bars
                    if #inProgressSkills > 0 then
                        categoryContent = categoryContent .. "#### 📈 In Progress\n"
                        for _, skill in ipairs(inProgressSkills) do
                            local skillNameLinked = CreateSkillLineLink(skill.name, format)
                            local progressPercent = skill.progress or 0
                            local progressBar = GenerateProgressBar(progressPercent, 10)
                            categoryContent = categoryContent
                                .. "- **"
                                .. skillNameLinked
                                .. "**: Rank "
                                .. (skill.rank or 0)
                                .. " "
                                .. progressBar
                                .. " "
                                .. progressPercent
                                .. "%\n"
                        end
                        categoryContent = categoryContent .. "\n"
                    end

                    -- Show low-level skills
                    if #lowLevelSkills > 0 then
                        categoryContent = categoryContent .. "#### ⚪ Early Progress\n"
                        for _, skill in ipairs(lowLevelSkills) do
                            local skillNameLinked = CreateSkillLineLink(skill.name, format)
                            local progressPercent = skill.progress or 0
                            local progressBar = GenerateProgressBar(progressPercent, 10)
                            categoryContent = categoryContent
                                .. "- **"
                                .. skillNameLinked
                                .. "**: Rank "
                                .. (skill.rank or 0)
                                .. " "
                                .. progressBar
                                .. " "
                                .. progressPercent
                                .. "%\n"
                        end
                        categoryContent = categoryContent .. "\n"
                    end

                    -- Show passives for all skills in this category
                    local allPassives = {}
                    for _, skill in ipairs(category.skills or {}) do
                        if skill.passives and #skill.passives > 0 then
                            for _, passive in ipairs(skill.passives) do
                                table.insert(allPassives, {
                                    name = passive.name,
                                    abilityId = passive.abilityId,
                                    purchased = passive.purchased,
                                    currentRank = passive.currentRank,
                                    maxRank = passive.maxRank,
                                    skillLineName = skill.name,
                                })
                            end
                        end
                    end

                    if #allPassives > 0 then
                        categoryContent = categoryContent .. "#### ✨ Passives\n"
                        for _, passive in ipairs(allPassives) do
                            local sanitizedName = tostring(passive.name or "Unknown")
                            sanitizedName = sanitizedName:gsub("[\r\n\t]", "")
                            sanitizedName = sanitizedName:gsub("^%s+", ""):gsub("%s+$", "")
                            sanitizedName = sanitizedName:gsub("%s+", " ")

                            local passiveName = CreateAbilityLink(sanitizedName, passive.abilityId, format)
                            if passiveName and passiveName ~= "" then
                                passiveName = passiveName:gsub("[\r\n\t]", "")
                                if
                                    not passiveName:find("%[.*%]%(")
                                    or not passiveName:find("%)$")
                                    or not passiveName:find("https://en.uesp.net/wiki/Online:")
                                then
                                    passiveName = sanitizedName
                                end
                            else
                                passiveName = sanitizedName
                            end

                            local passiveStatus = passive.purchased and "✅" or "🔒"
                            local rankInfo = ""
                            if passive.currentRank and passive.maxRank and passive.maxRank > 1 then
                                rankInfo = string.format(" (%d/%d)", passive.currentRank or 0, passive.maxRank)
                            end
                            local skillLineLink = CreateSkillLineLink(passive.skillLineName, format)
                            -- Safety check: ensure skillLineLink is never nil or empty
                            if not skillLineLink or skillLineLink == "" then
                                skillLineLink = passive.skillLineName or "Unknown"
                            end
                            -- Sanitize skillLineLink to prevent truncation issues
                            skillLineLink =
                                tostring(skillLineLink):gsub("[\r\n\t]", ""):gsub("^%s+", ""):gsub("%s+$", "")
                            categoryContent = categoryContent
                                .. string.format(
                                    "- %s %s%s *(from %s)*\n",
                                    passiveStatus,
                                    passiveName,
                                    rankInfo,
                                    skillLineLink
                                )
                        end
                        categoryContent = categoryContent .. "\n"
                    end

                    if categoryContent ~= "" then
                        if CreateCollapsible then
                            local success3, collapsibleContent2 =
                                pcall(CreateCollapsible, category.name, categoryContent, categoryEmoji, false)
                            if success3 and collapsibleContent2 then
                                output = output .. collapsibleContent2
                            else
                                output = output
                                    .. "### "
                                    .. categoryEmoji
                                    .. " "
                                    .. category.name
                                    .. "\n\n"
                                    .. categoryContent
                                    .. "\n\n"
                            end
                        else
                            output = output
                                .. "### "
                                .. categoryEmoji
                                .. " "
                                .. category.name
                                .. "\n\n"
                                .. categoryContent
                                .. "\n\n"
                        end
                    end
                end
            end
        end
    end

    -- Defensive check: ensure we never return empty string or nil
    -- Also check for whitespace-only content
    local outputTrimmed = output and output:gsub("%s+", "") or ""
    if not output or output == "" or outputTrimmed == "" then
        CM.DebugPrint("GENERATOR", "GenerateSkillBars: output is empty/nil/whitespace-only, returning placeholder")
        if format == "discord" then
            return "\n**Skill Bars:**\n*No skill bars configured*\n"
        else
            local placeholder = "## ⚔️ Combat Arsenal\n\n*No skill bars configured*\n\n---\n\n"
            CM.DebugPrint(
                "EQUIPMENT",
                string.format("GenerateSkillBars: Returning placeholder (%d chars)", string.len(placeholder))
            )
            return placeholder
        end
    end

    -- Final validation: ensure output starts with the section header
    if format ~= "discord" and not output:match("^##%s+⚔️%s+Combat%s+Arsenal") then
        CM.DebugPrint("GENERATOR", "GenerateSkillBars: output doesn't start with expected header, prepending it")
        output = "## ⚔️ Combat Arsenal\n\n" .. output
    end

    -- CRITICAL: Final safety check - ensure output is never empty after all processing
    if not output or output == "" or (output:gsub("%s+", "") == "") then
        CM.Error("GenerateSkillBars: CRITICAL - output is empty after all checks, forcing placeholder")
        if format == "discord" then
            return "\n**Skill Bars:**\n*No skill bars configured*\n"
        else
            return "## ⚔️ Combat Arsenal\n\n*No skill bars configured*\n\n---\n\n"
        end
    end

    CM.DebugPrint(
        "EQUIPMENT",
        string.format(
            "GenerateSkillBars: Returning output (%d chars, starts with: %s)",
            string.len(output),
            output:sub(1, math.min(50, string.len(output)))
        )
    )
    return output
end

-- =====================================================
-- EQUIPMENT
-- =====================================================

GenerateEquipment = function(equipmentData, format, noWrapper)
    -- Wrap entire function body in error handling
    local function GenerateEquipmentInternal(equipmentData, format, noWrapper)
        -- Defensive: Handle nil or invalid format
        if not format then
            format = "github"
        end

        -- Safe initialization with error handling
        local success, err = pcall(InitializeUtilities)
        if not success then
            CM.DebugPrint("GENERATOR", "GenerateEquipment: InitializeUtilities failed: " .. tostring(err))
            -- Return placeholder if initialization fails
            if format == "discord" then
                return "**Equipment & Active Sets:**\n*Error initializing equipment generator*\n\n"
            else
                return "## ⚔️ Equipment & Active Sets\n\n*Error initializing equipment generator*\n\n---\n\n"
            end
        end

        -- Ensure utility functions are available (defensive fallbacks)
        if not CreateSetLink then
            CreateSetLink = function(name, fmt)
                return name or ""
            end
        end
        if not CreateAbilityLink then
            CreateAbilityLink = function(name, id, fmt)
                return name or ""
            end
        end
        if not FormatNumber then
            FormatNumber = function(num)
                return tostring(num or 0)
            end
        end

        -- Always generate section header when called (registry handles condition check)
        local result = ""

        -- Check if equipmentData is nil or not a table, or if it's missing required structure
        if
            not equipmentData
            or type(equipmentData) ~= "table"
            or (not equipmentData.sets and not equipmentData.items)
        then
            -- Still generate section with message
            if format == "discord" then
                result = result .. "**Equipment & Active Sets:**\n*Equipment data not available*\n\n"
                return result
            else
                if markdown and markdown.CreateHeader then
                    result = markdown.CreateHeader("Equipment & Active Sets", "⚔️", nil, 2)
                        or '<a id="equipment--active-sets"></a>\n\n## ⚔️ Equipment & Active Sets\n\n'
                else
                    result = '<a id="equipment--active-sets"></a>\n\n## ⚔️ Equipment & Active Sets\n\n'
                end
                result = result .. "*Equipment data not available*\n\n---\n\n"
                return result
            end
        end

        -- Enhanced visuals are now always enabled (baseline)

        if format == "discord" then
            -- Discord: Simple format (no enhancements)
            result = result .. "**Equipment & Active Sets:**\n"
            result = result .. "\n**Sets:**\n"
            if equipmentData.sets and type(equipmentData.sets) == "table" and #equipmentData.sets > 0 then
                for _, set in ipairs(equipmentData.sets) do
                    local success_set, setLink = pcall(CreateSetLink, set.name or "", format)
                    if not success_set or not setLink then
                        setLink = set.name or "Unknown Set"
                    end
                    local indicator = (set.count and set.count >= 5) and "✅" or "⚠️"
                    local setTypeBadge = ""
                    if set.setTypeName then
                        setTypeBadge = " " .. GetSetTypeBadge(set.setTypeName)
                    end
                    local count = set.count or 0
                    result = result .. indicator .. " " .. setLink .. setTypeBadge .. " (" .. count .. ")\n"
                end
            else
                result = result .. "*No sets found*\n"
            end

            if equipmentData.items and type(equipmentData.items) == "table" and #equipmentData.items > 0 then
                result = result .. "\n**Equipment:**\n"
                for _, item in ipairs(equipmentData.items) do
                    if item.name and item.name ~= "-" then
                        local success_item, setLink = pcall(CreateSetLink, item.setName or "", format)
                        if not success_item or not setLink then
                            setLink = item.setName or ""
                        end
                        result = result .. (item.emoji or "📦") .. " " .. item.name
                        if setLink and setLink ~= "" and setLink ~= "-" then
                            result = result .. " (" .. setLink .. ")"
                        end
                        -- Add enchantment charge if available
                        if item.enchantment and item.enchantment ~= false then
                            -- CRITICAL: Ensure charge and maxCharge are numbers, not strings
                            local charge = 0
                            if item.enchantCharge ~= nil then
                                if type(item.enchantCharge) == "number" then
                                    charge = item.enchantCharge
                                elseif type(item.enchantCharge) == "string" then
                                    charge = tonumber(item.enchantCharge) or 0
                                end
                            end

                            local maxCharge = 0
                            if item.enchantMaxCharge ~= nil then
                                if type(item.enchantMaxCharge) == "number" then
                                    maxCharge = item.enchantMaxCharge
                                elseif type(item.enchantMaxCharge) == "string" then
                                    maxCharge = tonumber(item.enchantMaxCharge) or 0
                                end
                            end

                            if maxCharge > 0 then
                                local chargePercent = math.floor((charge / maxCharge) * 100)
                                result = result
                                    .. " - Charge: "
                                    .. string.format("%d/%d (%d%%)", charge, maxCharge, chargePercent)
                            elseif charge > 0 then
                                result = result .. " - Charge: " .. tostring(charge)
                            end
                        end
                        result = result .. "\n"
                    end
                end
            else
                result = result .. "\n*No equipment items found*\n"
            end

            result = result .. "\n"
            return result
        end

        -- ENHANCED HEADER (always enabled) - GitHub format
        -- Ensure markdown is available (it's initialized in InitializeUtilities)
        if not markdown then
            markdown = (CM.utils and CM.utils.markdown) or nil
        end
        if markdown and markdown.CreateHeader then
            result = markdown.CreateHeader("Equipment & Active Sets", "⚔️", nil, 2)
                or '<a id="equipment--active-sets"></a>\n\n## ⚔️ Equipment & Active Sets\n\n'
        else
            result = '<a id="equipment--active-sets"></a>\n\n## ⚔️ Equipment & Active Sets\n\n'
        end

        -- SET DISPLAY: Classic format shows Armor Sets breakdown, Enhanced shows progress bars
        -- Defensive: Ensure equipmentData and sets array exist before checking length
        if
            equipmentData
            and type(equipmentData) == "table"
            and equipmentData.sets
            and type(equipmentData.sets) == "table"
            and #equipmentData.sets > 0
        then
            if not markdown then
                -- Classic format: Show Active Sets and Partial Sets breakdown (matches old output)
                local activeSets = {}
                local partialSets = {}

                for _, set in ipairs(equipmentData.sets) do
                    local success_set2, setLink = pcall(CreateSetLink, set.name or "", format)
                    if not success_set2 or not setLink then
                        setLink = set.name or "Unknown Set"
                    end
                    -- Collect slot names for this set
                    local slots = {}
                    if equipmentData.items and type(equipmentData.items) == "table" then
                        for _, item in ipairs(equipmentData.items) do
                            if item.setName == set.name then
                                table.insert(slots, item.slotName or "Unknown")
                            end
                        end
                    end
                    local slotsStr = table.concat(slots, ", ")

                    -- Add set type badge if available
                    local setTypeBadge = ""
                    if set.setTypeName then
                        setTypeBadge = " " .. GetSetTypeBadge(set.setTypeName)
                    end

                    if set.count >= 5 then
                        table.insert(activeSets, {
                            name = set.name,
                            link = setLink,
                            count = set.count,
                            slots = slotsStr,
                            setTypeBadge = setTypeBadge,
                            setInfo = set,
                        })
                    else
                        table.insert(partialSets, {
                            name = set.name,
                            link = setLink,
                            count = set.count,
                            slots = slotsStr,
                            setTypeBadge = setTypeBadge,
                            setInfo = set,
                        })
                    end
                end

                if #activeSets > 0 then
                    result = result .. "### 🛡️ Armor Sets\n\n"
                    result = result .. "#### ✅ Active Sets (5-piece bonuses)\n\n"
                    for _, set in ipairs(activeSets) do
                        local setLine = string.format(
                            "- ✅ **%s**%s (%d/5 pieces) - %s",
                            set.link,
                            set.setTypeBadge,
                            set.count,
                            set.slots
                        )
                        result = result .. setLine .. "\n"

                        -- Add LibSets information if available
                        if
                            set.setInfo
                            and (set.setInfo.dropLocations or set.setInfo.dropMechanicNames or set.setInfo.dlcId)
                        then
                            local LibSetsIntegration = CM.utils and CM.utils.LibSetsIntegration
                            if LibSetsIntegration then
                                local details = {}

                                -- Drop locations
                                if set.setInfo.dropLocations and #set.setInfo.dropLocations > 0 then
                                    local locations = LibSetsIntegration.FormatDropLocations(set.setInfo.dropLocations)
                                    if locations then
                                        table.insert(details, "📍 " .. locations)
                                    end
                                end

                                -- Drop mechanics
                                if set.setInfo.dropMechanicNames and #set.setInfo.dropMechanicNames > 0 then
                                    local mechanics = LibSetsIntegration.FormatDropMechanics(
                                        set.setInfo.dropMechanics,
                                        set.setInfo.dropMechanicNames
                                    )
                                    if mechanics then
                                        table.insert(details, "⚙️ " .. mechanics)
                                    end
                                end

                                -- DLC/Chapter info
                                if set.setInfo.dlcId or set.setInfo.chapterId then
                                    local dlcInfo =
                                        LibSetsIntegration.FormatDLCInfo(set.setInfo.dlcId, set.setInfo.chapterId)
                                    if dlcInfo then
                                        table.insert(details, "📦 " .. dlcInfo)
                                    end
                                end

                                if #details > 0 then
                                    result = result .. "  " .. table.concat(details, " • ") .. "\n"
                                end
                            end
                        end
                    end
                    result = result .. "\n"
                end

                if #partialSets > 0 then
                    if #activeSets > 0 then
                        result = result .. "#### ⚠️ Partial Sets\n\n"
                    else
                        result = result .. "### 🛡️ Armor Sets\n\n"
                        result = result .. "#### ⚠️ Partial Sets\n\n"
                    end
                    for _, set in ipairs(partialSets) do
                        local setLine = string.format(
                            "- ⚠️ **%s**%s (%d/5 pieces) - %s",
                            set.link,
                            set.setTypeBadge,
                            set.count,
                            set.slots
                        )
                        result = result .. setLine .. "\n"

                        -- Add LibSets information if available
                        if
                            set.setInfo
                            and (set.setInfo.dropLocations or set.setInfo.dropMechanicNames or set.setInfo.dlcId)
                        then
                            local LibSetsIntegration = CM.utils and CM.utils.LibSetsIntegration
                            if LibSetsIntegration then
                                local details = {}

                                -- Drop locations
                                if set.setInfo.dropLocations and #set.setInfo.dropLocations > 0 then
                                    local locations = LibSetsIntegration.FormatDropLocations(set.setInfo.dropLocations)
                                    if locations then
                                        table.insert(details, "📍 " .. locations)
                                    end
                                end

                                -- Drop mechanics
                                if set.setInfo.dropMechanicNames and #set.setInfo.dropMechanicNames > 0 then
                                    local mechanics = LibSetsIntegration.FormatDropMechanics(
                                        set.setInfo.dropMechanics,
                                        set.setInfo.dropMechanicNames
                                    )
                                    if mechanics then
                                        table.insert(details, "⚙️ " .. mechanics)
                                    end
                                end

                                -- DLC/Chapter info
                                if set.setInfo.dlcId or set.setInfo.chapterId then
                                    local dlcInfo =
                                        LibSetsIntegration.FormatDLCInfo(set.setInfo.dlcId, set.setInfo.chapterId)
                                    if dlcInfo then
                                        table.insert(details, "📦 " .. dlcInfo)
                                    end
                                end

                                if #details > 0 then
                                    result = result .. "  " .. table.concat(details, " • ") .. "\n"
                                end
                            end
                        end
                    end
                    result = result .. "\n"
                end
            else
                -- ENHANCED: Styled table format
                local CreateStyledTable = CM.utils.markdown.CreateStyledTable
                if CreateStyledTable then
                    local headers = { "Set", "Progress" }
                    local rows = {}

                    for _, set in ipairs(equipmentData.sets) do
                        local maxPieces = 5
                        local indicator = "•"
                        if markdown and markdown.GetProgressIndicator then
                            local success_ind, ind =
                                pcall(markdown.GetProgressIndicator, math.min(set.count or 0, maxPieces), maxPieces)
                            if success_ind and ind then
                                indicator = ind
                            end
                        end
                        local success_set3, setLink = pcall(CreateSetLink, set.name or "", format)
                        if not success_set3 or not setLink then
                            setLink = set.name or "Unknown Set"
                        end

                        -- Add set type badge if available
                        local setTypeBadge = ""
                        if set.setTypeName then
                            setTypeBadge = " " .. GetSetTypeBadge(set.setTypeName)
                        end

                        local progressText = ""
                        if markdown and markdown.CreateProgressBar then
                            local success_pb, progressBar = pcall(
                                markdown.CreateProgressBar,
                                math.min(set.count or 0, maxPieces),
                                maxPieces,
                                10,
                                format
                            )
                            if success_pb and progressBar then
                                if set.count > maxPieces then
                                    progressText = string.format(
                                        "`%d/%d` %s *(+%d extra)*",
                                        maxPieces,
                                        maxPieces,
                                        progressBar,
                                        set.count - maxPieces
                                    )
                                else
                                    progressText = string.format("`%d/%d` %s", set.count, maxPieces, progressBar)
                                end
                            else
                                progressText = string.format("`%d/%d`", set.count, maxPieces)
                            end
                        else
                            if set.count > maxPieces then
                                progressText =
                                    string.format("`%d/%d` *(+%d extra)*", maxPieces, maxPieces, set.count - maxPieces)
                            else
                                progressText = string.format("`%d/%d`", set.count, maxPieces)
                            end
                        end

                        table.insert(rows, {
                            indicator .. " **" .. setLink .. "**" .. setTypeBadge,
                            progressText,
                        })
                    end

                    local options = {
                        alignment = { "left", "left" },
                        format = format,
                        coloredHeaders = true,
                    }
                    result = result .. CreateStyledTable(headers, rows, options)
                else
                    -- Fallback: Use simple markdown table if CreateStyledTable not available
                    local headers = { "Set", "Progress" }
                    local rows = {}

                    for _, set in ipairs(equipmentData.sets) do
                        local maxPieces = 5
                        local indicator = "•"
                        if markdown and markdown.GetProgressIndicator then
                            local success_ind, ind =
                                pcall(markdown.GetProgressIndicator, math.min(set.count or 0, maxPieces), maxPieces)
                            if success_ind and ind then
                                indicator = ind
                            end
                        end
                        local success_set3, setLink = pcall(CreateSetLink, set.name or "", format)
                        if not success_set3 or not setLink then
                            setLink = set.name or "Unknown Set"
                        end

                        local setTypeBadge = ""
                        if set.setTypeName then
                            setTypeBadge = " " .. GetSetTypeBadge(set.setTypeName)
                        end

                        local progressText = ""
                        if markdown and markdown.CreateProgressBar then
                            local success_pb, progressBar = pcall(
                                markdown.CreateProgressBar,
                                math.min(set.count or 0, maxPieces),
                                maxPieces,
                                10,
                                format
                            )
                            if success_pb and progressBar then
                                if set.count > maxPieces then
                                    progressText = string.format(
                                        "`%d/%d` %s *(+%d extra)*",
                                        maxPieces,
                                        maxPieces,
                                        progressBar,
                                        set.count - maxPieces
                                    )
                                else
                                    progressText = string.format("`%d/%d` %s", set.count, maxPieces, progressBar)
                                end
                            else
                                progressText = string.format("`%d/%d`", set.count, maxPieces)
                            end
                        else
                            if set.count > maxPieces then
                                progressText =
                                    string.format("`%d/%d` *(+%d extra)*", maxPieces, maxPieces, set.count - maxPieces)
                            else
                                progressText = string.format("`%d/%d`", set.count, maxPieces)
                            end
                        end

                        table.insert(rows, {
                            indicator .. " **" .. setLink .. "**" .. setTypeBadge,
                            progressText,
                        })
                    end

                    -- Create simple markdown table
                    result = result .. "| " .. table.concat(headers, " | ") .. " |\n"
                    result = result .. "| " .. string.rep("---", #headers):gsub("---", "---|") .. "\n"
                    for _, row in ipairs(rows) do
                        result = result .. "| " .. table.concat(row, " | ") .. " |\n"
                    end
                    result = result .. "\n"
                end
            end
        end

        -- Equipment details table
        -- Defensive: Ensure equipmentData and items array exist before checking length
        if
            equipmentData
            and type(equipmentData) == "table"
            and equipmentData.items
            and type(equipmentData.items) == "table"
            and #equipmentData.items > 0
        then
            result = result .. "### 📋 Equipment Details\n\n"

            -- Create a lookup table for set info by set name
            local setInfoLookup = {}
            if equipmentData.sets and type(equipmentData.sets) == "table" then
                for _, set in ipairs(equipmentData.sets) do
                    if set.name then
                        setInfoLookup[set.name] = set
                    end
                end
            end

            -- Build table rows
            local headers = { "Slot", "Item", "Set", "Quality", "Trait", "Type", "Enchantment" }
            local rows = {}

            for _, item in ipairs(equipmentData.items) do
                local success_item2, setLink = pcall(CreateSetLink, item.setName or "", format)
                if not success_item2 or not setLink then
                    setLink = item.setName or ""
                end
                local itemType = ""

                -- Add set type badge to set link if available
                local setInfo = setInfoLookup[item.setName]
                if setInfo and setInfo.setTypeName then
                    local setTypeBadge = GetSetTypeBadge(setInfo.setTypeName)
                    setLink = setLink .. " " .. setTypeBadge
                end

                -- Format armor/weapon type (with safe ESO API calls)
                if item.armorType then
                    local success_armor, armorTypeName = pcall(GetString, "SI_ARMORTYPE", item.armorType)
                    if success_armor and armorTypeName and armorTypeName ~= "" then
                        itemType = armorTypeName
                    end
                elseif item.weaponType then
                    local success_weapon, weaponTypeName = pcall(GetString, "SI_WEAPONTYPE", item.weaponType)
                    if success_weapon and weaponTypeName and weaponTypeName ~= "" then
                        itemType = weaponTypeName
                    end
                end

                -- Add indicators for crafted/stolen items
                local itemIndicators = {}
                if item.isCrafted then
                    table.insert(itemIndicators, "⚒️ Crafted")
                end
                if item.isStolen then
                    table.insert(itemIndicators, "👤 Stolen")
                end

                if #itemIndicators > 0 then
                    itemType = itemType .. (#itemType > 0 and " • " or "") .. table.concat(itemIndicators, " • ")
                end

                -- Format enchantment (name and charge)
                local enchantText = "-"
                local hasEnchantment = (item.enchantment and item.enchantment ~= false)
                    or (item.enchantCharge ~= nil and item.enchantCharge ~= 0)
                    or (item.enchantMaxCharge ~= nil and item.enchantMaxCharge ~= 0)

                if hasEnchantment then
                    -- Get enchantment name
                    local enchantName = ""
                    if item.enchantment and item.enchantment ~= false and type(item.enchantment) == "string" then
                        enchantName = item.enchantment
                    end

                    -- Get charge information
                    local charge = 0
                    if item.enchantCharge ~= nil then
                        if type(item.enchantCharge) == "number" then
                            charge = item.enchantCharge
                        elseif type(item.enchantCharge) == "string" then
                            charge = tonumber(item.enchantCharge) or 0
                        end
                    end

                    local maxCharge = 0
                    if item.enchantMaxCharge ~= nil then
                        if type(item.enchantMaxCharge) == "number" then
                            maxCharge = item.enchantMaxCharge
                        elseif type(item.enchantMaxCharge) == "string" then
                            maxCharge = tonumber(item.enchantMaxCharge) or 0
                        end
                    end

                    -- Format enchantment display: name with optional charge info
                    if enchantName ~= "" then
                        if maxCharge > 0 then
                            local chargePercent = math.floor((charge / maxCharge) * 100)
                            enchantText = string.format("%s (%d/%d)", enchantName, charge, maxCharge)
                        elseif charge > 0 then
                            enchantText = string.format("%s (%d)", enchantName, charge)
                        else
                            enchantText = enchantName
                        end
                    elseif maxCharge > 0 then
                        -- No name but we have charge data
                        local chargePercent = math.floor((charge / maxCharge) * 100)
                        enchantText = string.format("Unknown (%d/%d)", charge, maxCharge)
                    elseif charge > 0 then
                        enchantText = string.format("Unknown (%d)", charge)
                    end
                end

                -- Defensive: Ensure all values are strings and handle nil
                local slotName = item.slotName or "Unknown"
                local itemName = item.name or "-"
                local qualityEmoji = item.qualityEmoji or "⚪"
                local quality = item.quality or "Normal"
                local trait = item.trait or "None"
                local itemTypeDisplay = (itemType ~= "" and itemType) or "-"

                -- Add row to table
                table.insert(rows, {
                    (item.emoji or "📦") .. " **" .. slotName .. "**",
                    itemName,
                    setLink or "-",
                    qualityEmoji .. " " .. quality,
                    trait,
                    itemTypeDisplay,
                    enchantText,
                })
            end

            -- Create table using CreateStyledTable
            local CreateStyledTable = CM.utils.markdown.CreateStyledTable
            local options = {
                alignment = { "left", "left", "left", "left", "left", "left", "left" },
                format = format,
                coloredHeaders = true,
                width = "100%",
            }
            result = result .. CreateStyledTable(headers, rows, options)
        end

        -- If no sets and no items, show a message
        -- Defensive: Ensure equipmentData exists and arrays exist and are tables before checking length
        local hasSets = equipmentData
            and type(equipmentData) == "table"
            and equipmentData.sets
            and type(equipmentData.sets) == "table"
            and #equipmentData.sets > 0
        local hasItems = equipmentData
            and type(equipmentData) == "table"
            and equipmentData.items
            and type(equipmentData.items) == "table"
            and #equipmentData.items > 0
        if not hasSets and not hasItems then
            result = result .. "*No equipment data available*\n\n"
        end

        -- Only add trailing separator if not embedded in Combat Arsenal
        if not noWrapper then
            -- Use CreateSeparator for consistent separator styling
            local CreateSeparator = markdown and markdown.CreateSeparator
            if CreateSeparator then
                result = result .. CreateSeparator("hr")
            else
                result = result .. "---\n\n"
            end
        end

        -- CRITICAL: Ensure result is never empty before wrapping in collapsible
        if not result or result == "" or (result:gsub("%s+", "") == "") then
            CM.Error("GenerateEquipment: CRITICAL - result is empty after all checks, forcing placeholder")
            if format == "discord" then
                return "**Equipment & Active Sets:**\n*No equipment data available*\n\n"
            else
                result =
                    '<a id="equipment--active-sets"></a>\n\n## ⚔️ Equipment & Active Sets\n\n*No equipment data available*\n\n---\n\n'
            end
        end

        -- Equipment & Active Sets is no longer collapsible

        return result
    end

    -- Call internal function with error handling
    local success, result = pcall(GenerateEquipmentInternal, equipmentData, format, noWrapper)
    if success then
        -- Defensive: Ensure we never return empty string
        if not result or result == "" then
            CM.DebugPrint("GENERATOR", "GenerateEquipment: Internal function returned empty result")
            if format == "discord" then
                return "**Equipment & Active Sets:**\n*No equipment data available*\n\n"
            else
                return '<a id="equipment--active-sets"></a>\n\n## ⚔️ Equipment & Active Sets\n\n*No equipment data available*\n\n---\n\n'
            end
        end
        return result
    else
        -- Log the actual error for debugging
        local errorMsg = tostring(result) or "unknown error"
        CM.Error("GenerateEquipment: Internal function failed with error: " .. errorMsg)
        CM.DebugPrint("GENERATOR", "GenerateEquipment: equipmentData type: " .. type(equipmentData))
        if equipmentData and type(equipmentData) == "table" then
            CM.DebugPrint("GENERATOR", "GenerateEquipment: equipmentData.sets exists: " .. tostring(equipmentData.sets ~= nil))
            CM.DebugPrint("GENERATOR", "GenerateEquipment: equipmentData.items exists: " .. tostring(equipmentData.items ~= nil))
        end
        if format == "discord" then
            return "**Equipment & Active Sets:**\n*Error generating equipment data*\n\n"
        else
            return '<a id="equipment--active-sets"></a>\n\n## ⚔️ Equipment & Active Sets\n\n*Error generating equipment data*\n\n---\n\n'
        end
    end
end

-- =====================================================
-- PROGRESS SUMMARY DASHBOARD
-- =====================================================

local function GenerateProgressSummary(skillProgressionData, skillMorphsData, format)
    InitializeUtilities()

    if format == "discord" then
        -- Discord: Simple text format
        return ""
    end

    -- Calculate statistics
    local totalAbilitiesWithMorphs = 0
    local maxedSkillLines = 0
    local inProgressSkillLines = 0
    local earlyProgressSkillLines = 0

    -- Count abilities with morphs
    if skillMorphsData and #skillMorphsData > 0 then
        for _, skillType in ipairs(skillMorphsData) do
            for _, skillLine in ipairs(skillType.skillLines or {}) do
                totalAbilitiesWithMorphs = totalAbilitiesWithMorphs + #(skillLine.abilities or {})
            end
        end
    end

    -- Count skill lines by status
    if skillProgressionData and #skillProgressionData > 0 then
        for _, category in ipairs(skillProgressionData) do
            if category.skills and #category.skills > 0 then
                for _, skill in ipairs(category.skills) do
                    if skill.isRacial or skill.maxed or (skill.rank and skill.rank >= 50) then
                        maxedSkillLines = maxedSkillLines + 1
                    elseif skill.rank and skill.rank >= 20 then
                        inProgressSkillLines = inProgressSkillLines + 1
                    else
                        earlyProgressSkillLines = earlyProgressSkillLines + 1
                    end
                end
            end
        end
    end

    local totalSkillLines = maxedSkillLines + inProgressSkillLines + earlyProgressSkillLines
    local overallCompletion = totalSkillLines > 0 and math.floor((maxedSkillLines / totalSkillLines) * 100) or 0

    -- Create summary table using CreateStyledTable (pivot format - horizontal)
    local output = "### Progress Overview\n\n"
    
    local CreateStyledTable = CM.utils.markdown and CM.utils.markdown.CreateStyledTable
    if CreateStyledTable then
        -- Pivot table: stats as column headers, values in a single row
        local headers = {
            "Maxed Skill Lines",
            "In Progress",
            "Early Progress",
            "Abilities with Morphs",
            "Overall Completion",
        }
        local rows = {
            {
                tostring(maxedSkillLines),
                tostring(inProgressSkillLines),
                tostring(earlyProgressSkillLines),
                tostring(totalAbilitiesWithMorphs),
                string.format("%d%%", overallCompletion),
            },
        }
        
        local options = {
            alignment = { "right", "right", "right", "right", "right" },
            format = format,
            coloredHeaders = true,
        }
        
        output = output .. CreateStyledTable(headers, rows, options)
    else
        -- Fallback to simple markdown table if CreateStyledTable not available (pivot format)
        output = output .. "| Maxed Skill Lines | In Progress | Early Progress | Abilities with Morphs | Overall Completion |\n"
        output = output .. "|:-----------------|:-----------|:--------------|:---------------------|:------------------|\n"
        output = output .. string.format("| %d | %d | %d | %d | %d%% |\n",
            maxedSkillLines,
            inProgressSkillLines,
            earlyProgressSkillLines,
            totalAbilitiesWithMorphs,
            overallCompletion
        )
        output = output .. "\n"
    end

    return output
end

-- =====================================================
-- SKILLS (reorganized by status, with optional morph integration)
-- =====================================================

local function GenerateSkills(skillData, format, skillMorphsData)
    InitializeUtilities()

    local output = ""

    -- Filter out Alliance War category (shown in PvP section instead)
    local filteredSkillData = {}
    for _, category in ipairs(skillData) do
        if category.name ~= "Alliance War" then
            table.insert(filteredSkillData, category)
        end
    end

    if format == "discord" then
        -- Discord: Show all skills, compact format
        output = output .. "\n**Character Progress:**\n"
        for _, category in ipairs(filteredSkillData) do
            if category.skills and #category.skills > 0 then
                output = output .. (category.emoji or "⚔️") .. " **" .. category.name .. "**\n"
                for _, skill in ipairs(category.skills) do
                    local status = (skill.maxed or skill.isRacial) and "✅" or "📈"
                    local skillNameLinked = CreateSkillLineLink(skill.name, format)
                    -- For racial skills, don't show rank/progress
                    if skill.isRacial then
                        output = output .. status .. " " .. skillNameLinked .. "\n"
                    else
                        output = output .. status .. " " .. skillNameLinked .. " R" .. (skill.rank or 0)
                        if skill.progress and not skill.maxed then
                            output = output .. " (" .. skill.progress .. "%)"
                        elseif skill.maxed then
                            output = output .. " (100%)"
                        end
                        output = output .. "\n"
                    end

                    -- Show passives for this skill line
                    if skill.passives and #skill.passives > 0 then
                        for _, passive in ipairs(skill.passives) do
                            -- Sanitize passive name: remove all whitespace, newlines, and control characters
                            local sanitizedName = tostring(passive.name or "Unknown")
                            sanitizedName = sanitizedName:gsub("[\r\n\t]", "") -- Remove newlines, carriage returns, tabs
                            sanitizedName = sanitizedName:gsub("^%s+", ""):gsub("%s+$", "") -- Trim leading/trailing spaces
                            sanitizedName = sanitizedName:gsub("%s+", " ") -- Normalize multiple spaces to single space

                            local passiveName = CreateAbilityLink(sanitizedName, passive.abilityId, format)
                            -- Ensure passiveName is valid and complete (contains full URL and proper closing)
                            if passiveName and passiveName ~= "" then
                                -- Remove any control characters from the link text itself
                                passiveName = passiveName:gsub("[\r\n\t]", "")
                                -- Validate it's a complete markdown link
                                if
                                    not passiveName:find("%[.*%]%(")
                                    or not passiveName:find("%)$")
                                    or not passiveName:find("https://en.uesp.net/wiki/Online:")
                                then
                                    -- If link is invalid, use plain text
                                    passiveName = sanitizedName
                                end
                            else
                                passiveName = sanitizedName
                            end

                            local passiveStatus = passive.purchased and "✅" or "🔒"
                            local rankInfo = ""
                            if passive.currentRank and passive.maxRank then
                                if passive.maxRank > 1 then
                                    rankInfo = string.format(" (%d/%d)", passive.currentRank or 0, passive.maxRank)
                                end
                            end
                            output = output .. "  " .. passiveStatus .. " " .. passiveName .. rankInfo .. "\n"
                        end
                    end
                end
            end
        end
    else
        -- Reorganize: Group by status first, then by category
        -- Structure: Status sections (Maxed, In-Progress, Early Progress) -> Categories within each

        -- First, collect all skills organized by status and category
        local statusGroups = {
            maxed = {}, -- {categoryName = {skills = {}, emoji = "", name = ""}}
            inProgress = {}, -- same structure
            earlyProgress = {}, -- same structure
        }

        for _, category in ipairs(filteredSkillData) do
            if category.skills and #category.skills > 0 then
                -- Group skills in this category by status
                local maxedSkills = {}
                local inProgressSkills = {}
                local earlyProgressSkills = {}

                for _, skill in ipairs(category.skills) do
                    -- Handle racial skills specially - they always go to maxed section
                    if skill.isRacial or skill.maxed or (skill.rank and skill.rank >= 50) then
                        table.insert(maxedSkills, skill)
                    elseif skill.rank and skill.rank >= 20 then
                        table.insert(inProgressSkills, skill)
                    else
                        table.insert(earlyProgressSkills, skill)
                    end
                end

                -- Add to status groups if they have skills
                if #maxedSkills > 0 then
                    if not statusGroups.maxed[category.name] then
                        statusGroups.maxed[category.name] = {
                            emoji = category.emoji or "⚔️",
                            name = category.name,
                            skills = {},
                        }
                    end
                    for _, skill in ipairs(maxedSkills) do
                        table.insert(statusGroups.maxed[category.name].skills, skill)
                    end
                end

                if #inProgressSkills > 0 then
                    if not statusGroups.inProgress[category.name] then
                        statusGroups.inProgress[category.name] = {
                            emoji = category.emoji or "⚔️",
                            name = category.name,
                            skills = {},
                        }
                    end
                    for _, skill in ipairs(inProgressSkills) do
                        table.insert(statusGroups.inProgress[category.name].skills, skill)
                    end
                end

                if #earlyProgressSkills > 0 then
                    if not statusGroups.earlyProgress[category.name] then
                        statusGroups.earlyProgress[category.name] = {
                            emoji = category.emoji or "⚔️",
                            name = category.name,
                            skills = {},
                        }
                    end
                    for _, skill in ipairs(earlyProgressSkills) do
                        table.insert(statusGroups.earlyProgress[category.name].skills, skill)
                    end
                end
            end
        end

        -- Generate output organized by status
        -- Helper function to generate passives list
        local function GeneratePassivesList(skills, format)
            local allPassives = {}
            for _, skill in ipairs(skills or {}) do
                if skill.passives and #skill.passives > 0 then
                    for _, passive in ipairs(skill.passives) do
                        table.insert(allPassives, {
                            name = passive.name,
                            abilityId = passive.abilityId,
                            purchased = passive.purchased,
                            currentRank = passive.currentRank,
                            maxRank = passive.maxRank,
                            skillLineName = skill.name,
                        })
                    end
                end
            end

            if #allPassives == 0 then
                return ""
            end

            local passivesContent = ""
            for _, passive in ipairs(allPassives) do
                local sanitizedName = tostring(passive.name or "Unknown")
                sanitizedName = sanitizedName:gsub("[\r\n\t]", "")
                sanitizedName = sanitizedName:gsub("^%s+", ""):gsub("%s+$", "")
                sanitizedName = sanitizedName:gsub("%s+", " ")

                local passiveName = CreateAbilityLink(sanitizedName, passive.abilityId, format)
                if passiveName and passiveName ~= "" then
                    passiveName = passiveName:gsub("[\r\n\t]", "")
                    if
                        not passiveName:find("%[.*%]%(")
                        or not passiveName:find("%)$")
                        or not passiveName:find("https://en.uesp.net/wiki/Online:")
                    then
                        passiveName = sanitizedName
                    end
                else
                    passiveName = sanitizedName
                end

                local passiveStatus = passive.purchased and "✅" or "🔒"
                local rankInfo = ""
                if passive.currentRank and passive.maxRank and passive.maxRank > 1 then
                    rankInfo = string.format(" (%d/%d)", passive.currentRank or 0, passive.maxRank)
                end
                local skillLineLink = CreateSkillLineLink(passive.skillLineName, format)
                if not skillLineLink or skillLineLink == "" then
                    skillLineLink = passive.skillLineName or "Unknown"
                end
                skillLineLink = tostring(skillLineLink):gsub("[\r\n\t]", ""):gsub("^%s+", ""):gsub("%s+$", "")
                passivesContent = passivesContent
                    .. string.format("- %s %s%s *(from %s)*\n", passiveStatus, passiveName, rankInfo, skillLineLink)
            end

            return passivesContent
        end

        -- Generate Maxed Skills section
        local hasMaxed = false
        for categoryName, categoryData in pairs(statusGroups.maxed) do
            hasMaxed = true
            break
        end

        if hasMaxed then
            output = output .. "### ✅ Maxed Skills\n\n"

            -- Group by category
            for categoryName, categoryData in pairs(statusGroups.maxed) do
                local maxedNames = {}
                for _, skill in ipairs(categoryData.skills) do
                    local skillNameLinked = CreateSkillLineLink(skill.name, format)
                    table.insert(maxedNames, "**" .. skillNameLinked .. "**")
                end

                local categoryCount = #categoryData.skills
                local summaryText = string.format(
                    "%s %s (%d skill line%s maxed)",
                    categoryData.emoji,
                    categoryData.name,
                    categoryCount,
                    categoryCount > 1 and "s" or ""
                )

                -- Create collapsible section for this category
                local categoryContent = table.concat(maxedNames, ", ") .. "\n\n"

                -- Add passives in collapsible subsection
                local passivesContent = GeneratePassivesList(categoryData.skills, format)
                if passivesContent ~= "" then
                    categoryContent = categoryContent .. "<details>\n"
                    categoryContent = categoryContent .. "<summary>✨ Passives</summary>\n\n"
                    categoryContent = categoryContent .. passivesContent
                    categoryContent = categoryContent .. "</details>\n\n"
                end

                output = output .. "<details>\n"
                output = output .. "<summary>" .. summaryText .. "</summary>\n\n"
                output = output .. categoryContent
                output = output .. "</details>\n\n"
            end
        end

        -- Generate In-Progress Skills section
        local hasInProgress = false
        for categoryName, categoryData in pairs(statusGroups.inProgress) do
            hasInProgress = true
            break
        end

        if hasInProgress then
            output = output .. "### 📈 In-Progress Skills\n\n"

            for categoryName, categoryData in pairs(statusGroups.inProgress) do
                local categoryContent = ""
                for _, skill in ipairs(categoryData.skills) do
                    local skillNameLinked = CreateSkillLineLink(skill.name, format)
                    local progressPercent = skill.progress or 0
                    local progressBar = GenerateProgressBar(progressPercent, 10)
                    categoryContent = categoryContent
                        .. string.format(
                            "- **%s**: Rank %d %s %d%%\n",
                            skillNameLinked,
                            skill.rank or 0,
                            progressBar,
                            progressPercent
                        )
                end
                categoryContent = categoryContent .. "\n"

                -- Add passives in collapsible subsection
                local passivesContent = GeneratePassivesList(categoryData.skills, format)
                if passivesContent ~= "" then
                    categoryContent = categoryContent .. "<details>\n"
                    categoryContent = categoryContent .. "<summary>✨ Passives</summary>\n\n"
                    categoryContent = categoryContent .. passivesContent
                    categoryContent = categoryContent .. "</details>\n\n"
                end

                local categoryCount = #categoryData.skills
                local summaryText = string.format(
                    "%s %s (%d skill line%s in progress)",
                    categoryData.emoji,
                    categoryData.name,
                    categoryCount,
                    categoryCount > 1 and "s" or ""
                )

                output = output .. "<details>\n"
                output = output .. "<summary>" .. summaryText .. "</summary>\n\n"
                output = output .. categoryContent
                output = output .. "</details>\n\n"
            end
        end

        -- Generate Early Progress Skills section
        local hasEarlyProgress = false
        for categoryName, categoryData in pairs(statusGroups.earlyProgress) do
            hasEarlyProgress = true
            break
        end

        if hasEarlyProgress then
            output = output .. "### ⚪ Early Progress Skills\n\n"

            for categoryName, categoryData in pairs(statusGroups.earlyProgress) do
                local categoryContent = ""
                for _, skill in ipairs(categoryData.skills) do
                    local skillNameLinked = CreateSkillLineLink(skill.name, format)
                    local progressPercent = skill.progress or 0
                    local progressBar = GenerateProgressBar(progressPercent, 10)
                    categoryContent = categoryContent
                        .. string.format(
                            "- **%s**: Rank %d %s %d%%\n",
                            skillNameLinked,
                            skill.rank or 0,
                            progressBar,
                            progressPercent
                        )
                end
                categoryContent = categoryContent .. "\n"

                -- Add passives in collapsible subsection
                local passivesContent = GeneratePassivesList(categoryData.skills, format)
                if passivesContent ~= "" then
                    categoryContent = categoryContent .. "<details>\n"
                    categoryContent = categoryContent .. "<summary>✨ Passives</summary>\n\n"
                    categoryContent = categoryContent .. passivesContent
                    categoryContent = categoryContent .. "</details>\n\n"
                end

                local categoryCount = #categoryData.skills
                local summaryText = string.format(
                    "%s %s (%d skill line%s)",
                    categoryData.emoji,
                    categoryData.name,
                    categoryCount,
                    categoryCount > 1 and "s" or ""
                )

                output = output .. "<details>\n"
                output = output .. "<summary>" .. summaryText .. "</summary>\n\n"
                output = output .. categoryContent
                output = output .. "</details>\n\n"
            end
        end
    end

    return output
end

-- =====================================================
-- SKILL MORPHS (keeping existing implementation)
-- =====================================================

GenerateSkillMorphs = function(skillMorphsData, format)
    InitializeUtilities()

    local output = ""

    if not skillMorphsData or #skillMorphsData == 0 then
        if format == "discord" then
            output = output .. "\n**Skill Morphs:**\n"
            output = output .. "No morphable abilities found.\n"
        else
            output = output .. "## 🌿 Skill Morphs\n\n"
            output = output .. "*No morphable abilities found.*\n\n"
            -- Use CreateSeparator for consistent separator styling
            local CreateSeparator = markdown and markdown.CreateSeparator
            if CreateSeparator then
                output = output .. CreateSeparator("hr")
            else
                output = output .. "---\n\n"
            end
        end
        return output
    end

    if format == "discord" then
        output = output .. "\n**Skill Morphs:**\n"
        for _, skillType in ipairs(skillMorphsData) do
            output = output .. (skillType.emoji or "⚔️") .. " **" .. skillType.name .. "**\n"
            for _, skillLine in ipairs(skillType.skillLines) do
                output = output .. "  📋 " .. skillLine.name .. " (R" .. (skillLine.rank or 0) .. ")\n"
                for _, ability in ipairs(skillLine.abilities) do
                    local baseText = CreateAbilityLink(ability.name, nil, format)
                    local statusIcon = ability.purchased and "✅" or "🔒"
                    output = output .. "    " .. statusIcon .. " " .. baseText

                    if #ability.morphs > 0 then
                        for _, morph in ipairs(ability.morphs) do
                            if morph.selected then
                                local morphText = CreateAbilityLink(morph.name, morph.abilityId, format)
                                output = output .. " → " .. morphText
                                break
                            end
                        end
                    elseif ability.atMorphChoice then
                        output = output .. " (⚠️ morph choice available)"
                    end
                    output = output .. "\n"
                end
            end
        end
    else
        output = output .. "## 🌿 Skill Morphs\n\n"

        for _, skillType in ipairs(skillMorphsData) do
            local totalAbilities = 0
            for _, skillLine in ipairs(skillType.skillLines) do
                totalAbilities = totalAbilities + #skillLine.abilities
            end

            -- Show skill type header directly (not collapsible)
            output = output
                .. "### "
                .. (skillType.emoji or "⚔️")
                .. " "
                .. skillType.name
                .. " ("
                .. totalAbilities
                .. " abilities with morph choices)\n\n"

            for _, skillLine in ipairs(skillType.skillLines) do
                output = output .. "#### " .. skillLine.name .. " (Rank " .. (skillLine.rank or 0) .. ")\n\n"

                for _, ability in ipairs(skillLine.abilities) do
                    local baseText = CreateAbilityLink(ability.name, nil, format)
                    local statusIcon = ""

                    if ability.purchased then
                        if ability.currentMorph > 0 then
                            statusIcon = "✅ "
                        elseif ability.atMorphChoice then
                            statusIcon = "⚠️ "
                        else
                            statusIcon = "🔒 "
                        end
                    else
                        statusIcon = "🔒 "
                    end

                    output = output .. statusIcon .. "**" .. baseText .. "**"

                    if ability.currentRank and ability.currentRank > 0 then
                        output = output .. " (Rank " .. ability.currentRank .. ")"
                    end

                    output = output .. "\n\n"

                    if #ability.morphs > 0 then
                        -- Separate selected and unselected morphs
                        local selectedMorph = nil
                        local unselectedMorphs = {}

                        for _, morph in ipairs(ability.morphs) do
                            if morph.selected then
                                selectedMorph = morph
                            else
                                table.insert(unselectedMorphs, morph)
                            end
                        end

                        -- Show selected morph directly
                        if selectedMorph then
                            local morphName = tostring(selectedMorph.name or "Unknown")
                            morphName = morphName:gsub("[\r\n\t]", "") -- Remove newlines, carriage returns, tabs
                            morphName = morphName:gsub("^%s+", ""):gsub("%s+$", "") -- Trim leading/trailing spaces
                            morphName = morphName:gsub("%s+", " ") -- Normalize multiple spaces to single space

                            local morphText = CreateAbilityLink(morphName, selectedMorph.abilityId, format)
                            -- Ensure morphText is valid and complete
                            if morphText and morphText ~= "" then
                                morphText = morphText:gsub("[\r\n\t]", "")
                                if
                                    not morphText:find("%[.*%]%(")
                                    or not morphText:find("%)$")
                                    or not morphText:find("https://en.uesp.net/wiki/Online:")
                                then
                                    morphText = morphName
                                end
                            else
                                morphText = morphName
                            end
                            local morphSlot = tostring(selectedMorph.morphSlot or "?")
                            output = output .. "  ✅ **Morph " .. morphSlot .. "**: " .. morphText .. "\n"
                        end

                        -- Show unselected morphs in collapsible section
                        if #unselectedMorphs > 0 then
                            output = output .. "\n"
                            output = output .. "  <details>\n"
                            output = output .. "  <summary>Other morph options</summary>\n\n"

                            for _, morph in ipairs(unselectedMorphs) do
                                local morphName = tostring(morph.name or "Unknown")
                                morphName = morphName:gsub("[\r\n\t]", "")
                                morphName = morphName:gsub("^%s+", ""):gsub("%s+$", "")
                                morphName = morphName:gsub("%s+", " ")

                                local morphText = CreateAbilityLink(morphName, morph.abilityId, format)
                                if morphText and morphText ~= "" then
                                    morphText = morphText:gsub("[\r\n\t]", "")
                                    if
                                        not morphText:find("%[.*%]%(")
                                        or not morphText:find("%)$")
                                        or not morphText:find("https://en.uesp.net/wiki/Online:")
                                    then
                                        morphText = morphName
                                    end
                                else
                                    morphText = morphName
                                end
                                local morphSlot = tostring(morph.morphSlot or "?")
                                output = output .. "  ⚪ **Morph " .. morphSlot .. "**: " .. morphText .. "\n"
                            end

                            output = output .. "\n  </details>\n"
                        end
                    elseif ability.atMorphChoice then
                        output = output .. "  ⚠️ *Morph choice available - level up to unlock*\n"
                    else
                        if ability.purchased then
                            output = output .. "  🔒 *Morph locked - continue leveling this skill*\n"
                        else
                            output = output .. "  🔒 *Purchase this ability to unlock morphs*\n"
                        end
                    end

                    output = output .. "\n"
                end

                output = output .. "\n"
            end

            output = output .. "\n"
        end
    end

    return output
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.generators.sections = CM.generators.sections or {}
CM.generators.sections.GenerateSkillBars = GenerateSkillBars
CM.generators.sections.GenerateSkillBarsOnly = GenerateSkillBarsOnly
CM.generators.sections.GenerateSkillMorphs = GenerateSkillMorphs
CM.generators.sections.GenerateEquipment = GenerateEquipment
CM.generators.sections.GenerateSkills = GenerateSkills
CM.generators.sections.GenerateProgressSummary = GenerateProgressSummary

CM.DebugPrint("GENERATOR", "Equipment section generators loaded (enhanced visuals)")
