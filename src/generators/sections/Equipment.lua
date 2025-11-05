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
        CreateAbilityLink = CM.links.CreateAbilityLink
        CreateSetLink = CM.links.CreateSetLink
        CreateSkillLineLink = CM.links.CreateSkillLineLink
        FormatNumber = CM.utils.FormatNumber
        GenerateProgressBar = CM.generators.helpers.GenerateProgressBar
        markdown = CM.utils.markdown
    end
end

-- =====================================================
-- SKILL BARS
-- =====================================================

local function GenerateSkillBars(skillBarData, format)
    InitializeUtilities()
    
    local output = ""
    
    if format == "discord" then
        output = output .. "\n**Skill Bars:**\n"
        for barIdx, bar in ipairs(skillBarData) do
            output = output .. bar.name .. "\n"
            local ultimateText = CreateAbilityLink(bar.ultimate, bar.ultimateId, format)
            output = output .. "```" .. ultimateText .. "```\n"
            for i, ability in ipairs(bar.abilities) do
                local abilityText = CreateAbilityLink(ability.name, ability.id, format)
                output = output .. i .. ". " .. abilityText .. "\n"
            end
        end
    else
        output = output .. "## ⚔️ Combat Arsenal\n\n"
        
        -- Determine weapon types from bar names for better labels
        -- Using widely-supported emojis (🗡️ may not render, using ⚔️ instead)
        local barLabels = {
            {emoji = "⚔️", suffix = ""},  -- Changed from 🗡️ for better compatibility
            {emoji = "🔮", suffix = ""}
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
            local label = barLabels[barIdx] or {emoji = "⚔️", suffix = ""}
            output = output .. "### " .. label.emoji .. " " .. bar.name .. "\n\n"
            
            -- Abilities table (horizontal format - rows instead of columns)
            if #bar.abilities > 0 then
                -- Header row with slot numbers
                local headerRow = "|"
                local separatorRow = "|"
                for i = 1, #bar.abilities do
                    headerRow = headerRow .. " " .. i .. " |"
                    separatorRow = separatorRow .. ":--|"
                end
                output = output .. headerRow .. "\n"
                output = output .. separatorRow .. "\n"
                
                -- Abilities row
                local abilitiesRow = "|"
                for _, ability in ipairs(bar.abilities) do
                    local abilityText = CreateAbilityLink(ability.name, ability.id, format)
                    abilitiesRow = abilitiesRow .. " " .. abilityText .. " |"
                end
                output = output .. abilitiesRow .. "\n\n"
            end
            
            -- Ultimate separated at the end
            local ultimateText = CreateAbilityLink(bar.ultimate, bar.ultimateId, format)
            output = output .. "**⚡ Ultimate:** " .. ultimateText .. "\n\n"
        end
        
        output = output .. "---\n\n"
    end
    
    return output
end

-- =====================================================
-- EQUIPMENT
-- =====================================================

local function GenerateEquipment(equipmentData, format)
    InitializeUtilities()
    
    if not equipmentData or (CM.settings and CM.settings.includeEquipment == false) then return "" end
    
    local enhanced = CM.settings and CM.settings.enableEnhancedVisuals
    local result = ""
    
    if format == "discord" then
        -- Discord: Simple format (no enhancements)
        result = result .. "\n**Sets:**\n"
        if equipmentData.sets then
            for _, set in ipairs(equipmentData.sets) do
                local indicator = set.count >= 5 and "✅" or "⚠️"
                local setLink = CreateSetLink(set.name, format)
                result = result .. indicator .. " " .. setLink .. " (" .. set.count .. ")\n"
            end
        end
        
        if equipmentData.items and #equipmentData.items > 0 then
            result = result .. "\n**Equipment:**\n"
            for _, item in ipairs(equipmentData.items) do
                if item.name and item.name ~= "-" then
                    local setLink = CreateSetLink(item.setName, format)
                    result = result .. (item.emoji or "📦") .. " " .. item.name
                    if setLink and setLink ~= "-" then
                        result = result .. " (" .. setLink .. ")"
                    end
                    result = result .. "\n"
                end
            end
        end
        
        return result
    end
    
    -- ENHANCED HEADER
    if enhanced and markdown and markdown.CreateHeader then
        result = markdown.CreateHeader("Equipment & Active Sets", "⚔️", nil, 2) or "## 🎒 Equipment\n\n"
    else
        result = "## 🎒 Equipment\n\n"
    end
    
    -- SET DISPLAY: Classic format shows Armor Sets breakdown, Enhanced shows progress bars
    if equipmentData.sets and #equipmentData.sets > 0 then
        if not enhanced or not markdown then
            -- Classic format: Show Active Sets and Partial Sets breakdown (matches old output)
            local activeSets = {}
            local partialSets = {}
            
            for _, set in ipairs(equipmentData.sets) do
                local setLink = CreateSetLink(set.name, format)
                -- Collect slot names for this set
                local slots = {}
                if equipmentData.items then
                    for _, item in ipairs(equipmentData.items) do
                        if item.setName == set.name then
                            table.insert(slots, item.slotName or "Unknown")
                        end
                    end
                end
                local slotsStr = table.concat(slots, ", ")
                
                if set.count >= 5 then
                    table.insert(activeSets, {
                        name = set.name,
                        link = setLink,
                        count = set.count,
                        slots = slotsStr
                    })
                else
                    table.insert(partialSets, {
                        name = set.name,
                        link = setLink,
                        count = set.count,
                        slots = slotsStr
                    })
                end
            end
            
            if #activeSets > 0 then
                result = result .. "### 🛡️ Armor Sets\n\n"
                result = result .. "#### ✅ Active Sets (5-piece bonuses)\n\n"
                for _, set in ipairs(activeSets) do
                    result = result .. string.format("- ✅ **%s** (%d/5 pieces) - %s\n", set.link, set.count, set.slots)
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
                    result = result .. string.format("- ⚠️ **%s** (%d/5 pieces) - %s\n", set.link, set.count, set.slots)
                end
                result = result .. "\n"
            end
        else
            -- ENHANCED: Progress indicators (new style)
            local setLines = {}
            
            for _, set in ipairs(equipmentData.sets) do
                local maxPieces = 5
                local indicator = "•"
                if markdown.GetProgressIndicator then
                    local displayCount = math.min(set.count, maxPieces)
                    indicator = markdown.GetProgressIndicator(displayCount, maxPieces) or "•"
                end
                local setLink = CreateSetLink(set.name, format)
                
                if markdown.CreateProgressBar then
                    local progressBar = markdown.CreateProgressBar(math.min(set.count, maxPieces), maxPieces, 10, format) or ""
                    if set.count > maxPieces then
                        table.insert(setLines, string.format("%s **%s** `%d/%d` %s *(+%d extra)*", 
                            indicator, setLink, maxPieces, maxPieces, progressBar, set.count - maxPieces))
                    else
                        table.insert(setLines, string.format("%s **%s** `%d/%d` %s", 
                            indicator, setLink, set.count, maxPieces, progressBar))
                    end
                else
                    if set.count > maxPieces then
                        table.insert(setLines, string.format("%s **%s** (%d/%d pieces, +%d extra)", 
                            indicator, setLink, maxPieces, maxPieces, set.count - maxPieces))
                    else
                        table.insert(setLines, string.format("%s **%s** (%d/%d pieces)", 
                            indicator, setLink, set.count, maxPieces))
                    end
                end
            end
            
            result = result .. table.concat(setLines, "  \n") .. "\n\n"
        end
    end
    
    -- Equipment details table
    if equipmentData.items and #equipmentData.items > 0 then
        result = result .. "### 📋 Equipment Details\n\n"
        result = result .. "| Slot | Item | Set | Quality | Trait | Type |\n"
        result = result .. "|:-----|:-----|:----|:--------|:------|:-----|\n"
        
        for _, item in ipairs(equipmentData.items) do
            local setLink = CreateSetLink(item.setName, format)
            local itemType = ""
            
            -- Format armor/weapon type
            if item.armorType and item.armorType ~= ARMOR_TYPE_NONE then
                local armorTypeName = GetString("SI_ARMORTYPE", item.armorType) or "Unknown"
                itemType = armorTypeName
            elseif item.weaponType and item.weaponType ~= WEAPON_TYPE_NONE then
                local weaponTypeName = GetString("SI_WEAPONTYPE", item.weaponType) or "Unknown"
                itemType = weaponTypeName
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
            
            result = result .. "| " .. (item.emoji or "📦") .. " **" .. (item.slotName or "Unknown") .. "** | "
            result = result .. (item.name or "-") .. " | "
            result = result .. setLink .. " | "
            result = result .. (item.qualityEmoji or "⚪") .. " " .. (item.quality or "Normal") .. " | "
            result = result .. (item.trait or "None") .. " | "
            result = result .. (itemType ~= "" and itemType or "-") .. " |\n"
        end
        result = result .. "\n"
    end
    
    result = result .. "---\n\n"
    
    if enhanced and markdown and markdown.CreateCollapsible then
        -- Wrap entire equipment section in collapsible
        local collapsible = markdown.CreateCollapsible("Equipment & Active Sets", result, "⚔️", true)
        return collapsible or result
    end
    
    return result
end

-- =====================================================
-- SKILLS (keeping existing implementation)
-- =====================================================

local function GenerateSkills(skillData, format)
    InitializeUtilities()
    
    local output = ""
    
    if format == "discord" then
        -- Discord: Show all skills, compact format
        output = output .. "\n**Skill Progression:**\n"
        for _, category in ipairs(skillData) do
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
                            sanitizedName = sanitizedName:gsub("[\r\n\t]", "")  -- Remove newlines, carriage returns, tabs
                            sanitizedName = sanitizedName:gsub("^%s+", ""):gsub("%s+$", "")  -- Trim leading/trailing spaces
                            sanitizedName = sanitizedName:gsub("%s+", " ")  -- Normalize multiple spaces to single space
                            
                            local passiveName = CreateAbilityLink(sanitizedName, passive.abilityId, format)
                            -- Ensure passiveName is valid and complete (contains full URL and proper closing)
                            if passiveName and passiveName ~= "" then
                                -- Remove any control characters from the link text itself
                                passiveName = passiveName:gsub("[\r\n\t]", "")
                                -- Validate it's a complete markdown link
                                if not passiveName:find("%[.*%]%(") or not passiveName:find("%)$") or 
                                   not passiveName:find("https://en.uesp.net/wiki/Online:") then
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
        output = output .. "## 📜 Skill Progression\n\n"
        for _, category in ipairs(skillData) do
            output = output .. "### " .. (category.emoji or "⚔️") .. " " .. category.name .. "\n\n"
            if category.skills and #category.skills > 0 then
                -- Group skills by status
                local maxedSkills = {}
                local inProgressSkills = {}
                local lowLevelSkills = {}
                
                for _, skill in ipairs(category.skills) do
                    -- Handle racial skills specially - they always go to maxed section
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
                    output = output .. "#### ✅ Maxed\n"
                    output = output .. table.concat(maxedNames, ", ") .. "\n\n"
                end
                
                -- Show in-progress skills with progress bars
                if #inProgressSkills > 0 then
                    if #maxedSkills > 0 then
                        output = output .. "#### 📈 In Progress\n"
                    end
                    for _, skill in ipairs(inProgressSkills) do
                        local skillNameLinked = CreateSkillLineLink(skill.name, format)
                        local progressPercent = skill.progress or 0
                        local progressBar = GenerateProgressBar(progressPercent, 10)
                        output = output .. "- **" .. skillNameLinked .. "**: Rank " .. (skill.rank or 0) .. 
                                              " " .. progressBar .. " " .. progressPercent .. "%\n"
                    end
                    output = output .. "\n"
                end
                
                -- Show low-level skills
                if #lowLevelSkills > 0 then
                    if #maxedSkills > 0 or #inProgressSkills > 0 then
                        output = output .. "#### ⚪ Early Progress\n"  -- Changed from 🔰 to ⚪ for better compatibility
                    end
                    for _, skill in ipairs(lowLevelSkills) do
                        local skillNameLinked = CreateSkillLineLink(skill.name, format)
                        local progressPercent = skill.progress or 0
                        local progressBar = GenerateProgressBar(progressPercent, 10)
                        output = output .. "- **" .. skillNameLinked .. "**: Rank " .. (skill.rank or 0) .. 
                                              " " .. progressBar .. " " .. progressPercent .. "%\n"
                    end
                    output = output .. "\n"
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
                                skillLineName = skill.name
                            })
                        end
                    end
                end
                
                if #allPassives > 0 then
                    output = output .. "#### ✨ Passives\n"
                    for _, passive in ipairs(allPassives) do
                        -- Sanitize passive name: remove all whitespace, newlines, and control characters
                        local sanitizedName = tostring(passive.name or "Unknown")
                        sanitizedName = sanitizedName:gsub("[\r\n\t]", "")  -- Remove newlines, carriage returns, tabs
                        sanitizedName = sanitizedName:gsub("^%s+", ""):gsub("%s+$", "")  -- Trim leading/trailing spaces
                        sanitizedName = sanitizedName:gsub("%s+", " ")  -- Normalize multiple spaces to single space
                        
                        local passiveName = CreateAbilityLink(sanitizedName, passive.abilityId, format)
                        -- Ensure passiveName is valid and complete (contains full URL and proper closing)
                        if passiveName and passiveName ~= "" then
                            -- Remove any control characters from the link text itself
                            passiveName = passiveName:gsub("[\r\n\t]", "")
                            -- Validate it's a complete markdown link
                            if not passiveName:find("%[.*%]%(") or not passiveName:find("%)$") or 
                               not passiveName:find("https://en.uesp.net/wiki/Online:") then
                                -- If link is invalid, use plain text
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
                        output = output .. string.format("- %s %s%s *(from %s)*\n", 
                            passiveStatus, passiveName, rankInfo, skillLineLink)
                    end
                    output = output .. "\n"
                end
            end
        end

        output = output .. "---\n\n"
    end
    
    return output
end

-- =====================================================
-- SKILL MORPHS (keeping existing implementation)
-- =====================================================

local function GenerateSkillMorphs(skillMorphsData, format)
    InitializeUtilities()
    
    local output = ""
    
    if not skillMorphsData or #skillMorphsData == 0 then
        if format == "discord" then
            output = output .. "\n**Skill Morphs:**\n"
            output = output .. "No morphable abilities found.\n"
        else
            output = output .. "## 🌿 Skill Morphs\n\n"
            output = output .. "*No morphable abilities found.*\n\n"
            output = output .. "---\n\n"
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
            
            output = output .. "<details>\n"
            output = output .. "<summary>" .. (skillType.emoji or "⚔️") .. " " .. skillType.name .. 
                                  " (" .. totalAbilities .. " abilities with morph choices)</summary>\n\n"
            
            for _, skillLine in ipairs(skillType.skillLines) do
                output = output .. "### " .. skillLine.name .. " (Rank " .. (skillLine.rank or 0) .. ")\n\n"
                
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
                        for _, morph in ipairs(ability.morphs) do
                            local morphIcon = morph.selected and "✅" or "⚪"
                            -- Sanitize morphName: remove all whitespace, newlines, and control characters
                            local morphName = tostring(morph.name or "Unknown")
                            morphName = morphName:gsub("[\r\n\t]", "")  -- Remove newlines, carriage returns, tabs
                            morphName = morphName:gsub("^%s+", ""):gsub("%s+$", "")  -- Trim leading/trailing spaces
                            morphName = morphName:gsub("%s+", " ")  -- Normalize multiple spaces to single space
                            
                            local morphText = CreateAbilityLink(morphName, morph.abilityId, format)
                            -- Ensure morphText is valid and complete (contains full URL and proper closing)
                            if morphText and morphText ~= "" then
                                -- Remove any control characters from the link text itself
                                morphText = morphText:gsub("[\r\n\t]", "")
                                -- Validate it's a complete markdown link
                                if not morphText:find("%[.*%]%(") or not morphText:find("%)$") or 
                                   not morphText:find("https://en.uesp.net/wiki/Online:") then
                                    -- If link is invalid, use plain text
                                    morphText = morphName
                                end
                            else
                                morphText = morphName
                            end
                            local morphSlot = tostring(morph.morphSlot or "?")
                            output = output .. "  " .. morphIcon .. " **Morph " .. morphSlot .. "**: " .. morphText .. "\n"
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
            
            output = output .. "</details>\n\n"
        end
        
        output = output .. "---\n\n"
    end
    
    return output
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.generators.sections = CM.generators.sections or {}
CM.generators.sections.GenerateSkillBars = GenerateSkillBars
CM.generators.sections.GenerateSkillMorphs = GenerateSkillMorphs
CM.generators.sections.GenerateEquipment = GenerateEquipment
CM.generators.sections.GenerateSkills = GenerateSkills

CM.DebugPrint("GENERATOR", "Equipment section generators loaded (enhanced visuals)")
