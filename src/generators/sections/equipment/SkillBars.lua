-- CharacterMarkdown - Skill Bar Generators
-- Generates skill bar tables for the equipment section

local CM = CharacterMarkdown
CM.generators = CM.generators or {}
CM.generators.sections = CM.generators.sections or {}
CM.generators.sections.equipment = CM.generators.sections.equipment or {}

local helpers = CM.generators.sections.equipment
local skillbars = {}

-- =====================================================
-- SKILL BARS ONLY (Front/Back Bar tables only)
-- =====================================================

function skillbars.GenerateSkillBarsOnly(skillBarData)
    -- Safe initialization
    helpers.InitializeUtilities()
    local cache = helpers.cache

    -- Validate input data - handle nil, non-table, or empty bars
    if not skillBarData or type(skillBarData) ~= "table" then
        CM.DebugPrint("EQUIPMENT", "GenerateSkillBarsOnly: No skill bar data provided")
        return "## ⚔️ Combat Arsenal\n\n*No skill bars configured*\n\n"
    end

    -- Check if bars exist and have content
    local bars = skillBarData.bars or skillBarData -- Support both {bars=[...]} and direct array
    if not bars or type(bars) ~= "table" or #bars == 0 then
        CM.DebugPrint("EQUIPMENT", "GenerateSkillBarsOnly: No bars in skill bar data")
        return "## ⚔️ Combat Arsenal\n\n*No skill bars configured*\n\n"
    end

    local output = ""

    output = output .. "## ⚔️ Combat Arsenal\n\n"

    -- Determine weapon types from bar names for better labels
    local barLabels = {
        { emoji = "⚔️", suffix = "" },
        { emoji = "🔮", suffix = "" },
    }

    -- Try to detect weapon types from bar names
    for barIdx, bar in ipairs(bars) do
        local barName = bar.name or ""
        if barName:find("Backup") or barName:find("Back Bar") then
            barLabels[barIdx].suffix = " (Backup)"
        elseif barName:find("Main") or barName:find("Front") then
            barLabels[barIdx].suffix = " (Main Hand)"
        end
    end

    for barIdx, bar in ipairs(bars) do
        if bar and type(bar) == "table" then
            local label = barLabels[barIdx] or { emoji = "⚔️", suffix = "" }
            local barName = bar.name or "Unknown Bar"
            output = output .. "### " .. label.emoji .. " " .. label.emoji .. " " .. barName .. "\n\n"

            -- Safely get abilities array
            local abilities = (bar.abilities and type(bar.abilities) == "table") and bar.abilities or {}
            local hasUltimate = bar.ultimate and bar.ultimate ~= ""

            -- Abilities table (horizontal format) using CreateStyledTable
            if #abilities > 0 or hasUltimate then
                local markdown_utils = cache.markdown
                local CreateStyledTable = markdown_utils and markdown_utils.CreateStyledTable

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
                            if cache.CreateAbilityLink then
                                local success_ab, abText =
                                    pcall(cache.CreateAbilityLink, ability.name or "Unknown", ability.id)
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
                        if cache.CreateAbilityLink then
                            local success_ult, ultText =
                                pcall(cache.CreateAbilityLink, bar.ultimate or "", bar.ultimateId)
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
                            if cache.CreateAbilityLink then
                                local success_ab, abText =
                                    pcall(cache.CreateAbilityLink, ability.name or "Unknown", ability.id)
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
                        if cache.CreateAbilityLink then
                            local success_ult, ultText =
                                pcall(cache.CreateAbilityLink, bar.ultimate or "", bar.ultimateId)
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

    return output
end

-- =====================================================
-- SKILL BARS (LEGACY - includes Equipment and Character Progress)
-- =====================================================

function skillbars.GenerateSkillBars(skillBarData, skillMorphsData, skillProgressionData, equipmentData)
    -- Safe initialization
    helpers.InitializeUtilities()
    local cache = helpers.cache

    -- Validate input data - handle nil, non-table, or empty table
    if not skillBarData or type(skillBarData) ~= "table" or #skillBarData == 0 then
        CM.DebugPrint("EQUIPMENT", "GenerateSkillBars: No skill bar data provided")
        local placeholder = "## ⚔️ Combat Arsenal\n\n*No skill bars configured*\n\n---\n\n"
        return placeholder
    end

    local output = ""
    local markdown_utils = cache.markdown
    local CreateCollapsible = markdown_utils and markdown_utils.CreateCollapsible

    CM.DebugPrint("EQUIPMENT", string.format("GenerateSkillBars: skillBarData length=%s", tostring(#skillBarData)))

    output = output .. "## ⚔️ Combat Arsenal\n\n"

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
            output = output .. "### " .. label.emoji .. " " .. barName .. "\n\n"

            local abilities = (bar.abilities and type(bar.abilities) == "table") and bar.abilities or {}
            local hasUltimate = bar.ultimate and bar.ultimate ~= ""

            if #abilities > 0 or hasUltimate then
                local CreateStyledTable = markdown_utils and markdown_utils.CreateStyledTable
                if not CreateStyledTable then
                    -- Fallback code...
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
                            if cache.CreateAbilityLink then
                                local success_ab, abText = pcall(cache.CreateAbilityLink, abilityName, abilityId)
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
                    if hasUltimate then
                        local ultimateId = bar.ultimateId
                        local ultimateText = ""
                        if cache.CreateAbilityLink then
                            local success_ult, ultText = pcall(cache.CreateAbilityLink, bar.ultimate or "", ultimateId)
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

                    for i = 1, #abilities do
                        table.insert(headers, tostring(i))
                    end

                    if hasUltimate then
                        table.insert(headers, "⚡")
                    end

                    for _, ability in ipairs(abilities) do
                        if ability and type(ability) == "table" then
                            local abilityName = ability.name or "Unknown"
                            local abilityId = ability.id
                            local abilityText = ""
                            if cache.CreateAbilityLink then
                                local success_ab, abText = pcall(cache.CreateAbilityLink, abilityName, abilityId)
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

                    if hasUltimate then
                        local ultimateId = bar.ultimateId
                        local ultimateText = ""
                        if cache.CreateAbilityLink then
                            local success_ult, ultText = pcall(cache.CreateAbilityLink, bar.ultimate or "", ultimateId)
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

                    local alignment = {}
                    for i = 1, #headers do
                        table.insert(alignment, "center")
                    end
                    local options = {
                        alignment = alignment,
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

    -- Add Equipment & Active Sets
    if equipmentData then
        CM.Info("→ Including Equipment & Active Sets in Combat Arsenal")

        -- Use reference from CM.generators.sections
        local GenerateEquipment = CM.generators.sections.GenerateEquipment
        if GenerateEquipment then
            local success_equip, equipmentContent = pcall(GenerateEquipment, equipmentData, true)
            if success_equip and equipmentContent and equipmentContent ~= "" then
                output = output .. equipmentContent
            else
                CM.Error("GenerateSkillBars: Failed to generate Equipment content")
                output = output
                    .. '<a id="equipment--active-sets"></a>\n\n## ⚔️ Equipment & Active Sets\n\n*Error generating equipment data*\n\n'
            end
        end
    end

    local CreateSeparator = markdown_utils and markdown_utils.CreateSeparator
    if CreateSeparator then
        output = output .. CreateSeparator("hr")
    else
        output = output .. "---\n\n"
    end

    -- Add Skill Morphs as collapsible subsection
    if skillMorphsData and type(skillMorphsData) == "table" and (#skillMorphsData > 0 or next(skillMorphsData)) then
        local GenerateSkillMorphs = CM.generators.sections.GenerateSkillMorphs
        if GenerateSkillMorphs then
            local success, skillMorphsContent = pcall(GenerateSkillMorphs, skillMorphsData)
            if success and skillMorphsContent and type(skillMorphsContent) == "string" then
                skillMorphsContent = skillMorphsContent:gsub("^##%s+🌿%s+Skill%s+Morphs%s*\n%s*\n", "")
                skillMorphsContent = skillMorphsContent:gsub("%%-%%-%%-%s*\n%s*\n%s*$", "")

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
            end
        end
    end

    -- Add Character Progress categories as collapsible subsections
    if skillProgressionData and #skillProgressionData > 0 then
        output = output .. "## 📜 Character Progress\n\n"

        for _, category in ipairs(skillProgressionData) do
            if category.skills and #category.skills > 0 then
                local categoryContent = ""
                local categoryEmoji = category.emoji or "⚔️"

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

                if #maxedSkills > 0 then
                    local maxedNames = {}
                    for _, skill in ipairs(maxedSkills) do
                        local skillNameLinked = cache.CreateSkillLineLink(skill.name)
                        table.insert(maxedNames, "**" .. skillNameLinked .. "**")
                    end
                    categoryContent = categoryContent .. "#### ✅ Maxed\n"
                    categoryContent = categoryContent .. table.concat(maxedNames, ", ") .. "\n\n"
                end

                if #inProgressSkills > 0 then
                    categoryContent = categoryContent .. "#### 📈 In Progress\n"
                    for _, skill in ipairs(inProgressSkills) do
                        local skillNameLinked = cache.CreateSkillLineLink(skill.name)
                        local progressPercent = skill.progress or 0
                        local progressBar = cache.GenerateProgressBar(progressPercent, 10)
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

                if #lowLevelSkills > 0 then
                    categoryContent = categoryContent .. "#### ⚪ Early Progress\n"
                    for _, skill in ipairs(lowLevelSkills) do
                        local skillNameLinked = cache.CreateSkillLineLink(skill.name)
                        local progressPercent = skill.progress or 0
                        local progressBar = cache.GenerateProgressBar(progressPercent, 10)
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

                -- Passives
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
                        local passiveName = cache.CreateAbilityLink(passive.name, passive.abilityId)
                        local passiveStatus = passive.purchased and "✅" or "🔒"
                        local rankInfo = ""
                        if passive.currentRank and passive.maxRank and passive.maxRank > 1 then
                            rankInfo = string.format(" (%d/%d)", passive.currentRank or 0, passive.maxRank)
                        end
                        local skillLineLink = cache.CreateSkillLineLink(passive.skillLineName)
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

    return output
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.generators.sections.GenerateSkillBars = skillbars.GenerateSkillBars
CM.generators.sections.GenerateSkillBarsOnly = skillbars.GenerateSkillBarsOnly
CM.generators.sections.equipment.SkillBars = skillbars

CM.DebugPrint("GENERATOR", "Skill bars module loaded")
