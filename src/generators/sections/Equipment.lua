-- CharacterMarkdown - Equipment Section Generators
-- Generates equipment-related markdown sections (equipment, skill bars, skills)

local CM = CharacterMarkdown

-- Cache for utility functions (lazy-initialized on first use)
local CreateAbilityLink, CreateSetLink, CreateSkillLineLink
local FormatNumber, GenerateProgressBar

-- Lazy initialization of cached references
local function InitializeUtilities()
    if not FormatNumber then
        CreateAbilityLink = CM.links.CreateAbilityLink
        CreateSetLink = CM.links.CreateSetLink
        CreateSkillLineLink = CM.links.CreateSkillLineLink
        FormatNumber = CM.utils.FormatNumber
        GenerateProgressBar = CM.generators.helpers.GenerateProgressBar
    end
end

-- =====================================================
-- SKILL BARS
-- =====================================================

local function GenerateSkillBars(skillBarData, format)
    InitializeUtilities()
    
    local markdown = ""
    
    if format == "discord" then
        markdown = markdown .. "\n**Skill Bars:**\n"
        for barIdx, bar in ipairs(skillBarData) do
            markdown = markdown .. bar.name .. "\n"
            local ultimateText = CreateAbilityLink(bar.ultimate, bar.ultimateId, format)
            markdown = markdown .. "```" .. ultimateText .. "```\n"
            for i, ability in ipairs(bar.abilities) do
                local abilityText = CreateAbilityLink(ability.name, ability.id, format)
                markdown = markdown .. i .. ". " .. abilityText .. "\n"
            end
        end
    else
        markdown = markdown .. "## ⚔️ Combat Arsenal\n\n"
        
        -- Determine weapon types from bar names for better labels
        local barLabels = {
            {emoji = "🗡️", suffix = ""},
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
            markdown = markdown .. "### " .. label.emoji .. " " .. bar.name .. "\n\n"
            
            -- Ultimate with link
            local ultimateText = CreateAbilityLink(bar.ultimate, bar.ultimateId, format)
            markdown = markdown .. "**⚡ Ultimate:** " .. ultimateText .. "\n\n"
            
            markdown = markdown .. "**Abilities:**\n"
            for i, ability in ipairs(bar.abilities) do
                local abilityText = CreateAbilityLink(ability.name, ability.id, format)
                markdown = markdown .. i .. ". " .. abilityText .. "\n"
            end
            markdown = markdown .. "\n"
        end
        
        markdown = markdown .. "---\n\n"
    end
    
    return markdown
end

-- =====================================================
-- EQUIPMENT
-- =====================================================

local function GenerateEquipment(equipmentData, format)
    InitializeUtilities()
    
    local markdown = ""
    
    if format == "discord" then
        -- Armor sets
        if equipmentData.sets and #equipmentData.sets > 0 then
            markdown = markdown .. "\n**Sets:**\n"
            for _, set in ipairs(equipmentData.sets) do
                local indicator = set.count >= 5 and "✅" or "⚠️"
                local setLink = CreateSetLink(set.name, format)
                markdown = markdown .. indicator .. " " .. setLink .. " (" .. set.count .. ")\n"
            end
        end
        
        -- Equipment list
        if equipmentData.items and #equipmentData.items > 0 then
            markdown = markdown .. "\n**Equipment:**\n"
            for _, item in ipairs(equipmentData.items) do
                if item.name and item.name ~= "-" then
                    local setLink = CreateSetLink(item.setName, format)
                    markdown = markdown .. (item.emoji or "📦") .. " " .. item.name
                    if setLink and setLink ~= "-" then
                        markdown = markdown .. " (" .. setLink .. ")"
                    end
                    markdown = markdown .. "\n"
                end
            end
        end
    else
        markdown = markdown .. "## 🎒 Equipment\n\n"
    
        -- Armor sets - reorganized by status
        if equipmentData.sets and #equipmentData.sets > 0 then
            markdown = markdown .. "### 🛡️ Armor Sets\n\n"
            
            -- Group sets by completion status
            local activeSets = {}
            local partialSets = {}
            
            for _, set in ipairs(equipmentData.sets) do
                if set.count >= 5 then
                    table.insert(activeSets, set)
                else
                    table.insert(partialSets, set)
                end
            end
            
            -- Show active sets (5+ pieces)
            if #activeSets > 0 then
                markdown = markdown .. "#### ✅ Active Sets (5-piece bonuses)\n\n"
                for _, set in ipairs(activeSets) do
                    local setLink = CreateSetLink(set.name, format)
                    markdown = markdown .. "- ✅ **" .. setLink .. "** (" .. set.count .. "/5 pieces)"
                    
                    -- List which slots for this set
                    if equipmentData.items then
                        local slots = {}
                        for _, item in ipairs(equipmentData.items) do
                            if item.setName == set.name then
                                table.insert(slots, item.slotName)
                            end
                        end
                        if #slots > 0 then
                            markdown = markdown .. " - " .. table.concat(slots, ", ")
                        end
                    end
                    markdown = markdown .. "\n"
                end
                markdown = markdown .. "\n"
            end
            
            -- Show partial sets
            if #partialSets > 0 then
                markdown = markdown .. "#### ⚠️ Partial Sets\n\n"
                for _, set in ipairs(partialSets) do
                    local setLink = CreateSetLink(set.name, format)
                    markdown = markdown .. "- ⚠️ **" .. setLink .. "** (" .. set.count .. "/5 pieces)"
                    
                    -- List which slots for this set
                    if equipmentData.items then
                        local slots = {}
                        for _, item in ipairs(equipmentData.items) do
                            if item.setName == set.name then
                                table.insert(slots, item.slotName)
                            end
                        end
                        if #slots > 0 then
                            markdown = markdown .. " - " .. table.concat(slots, ", ")
                        end
                    end
                    markdown = markdown .. "\n"
                end
                markdown = markdown .. "\n"
            end
        end
        
        -- Equipment details table
        if equipmentData.items and #equipmentData.items > 0 then
            markdown = markdown .. "### 📋 Equipment Details\n\n"
            markdown = markdown .. "| Slot | Item | Set | Quality | Trait | Type |\n"
            markdown = markdown .. "|:-----|:-----|:----|:--------|:------|:-----|\n"
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
                if item.craftedQuality and item.craftedQuality ~= ITEM_QUALITY_NONE and item.craftedQuality > 0 then
                    local craftedQualName = GetString("SI_ITEMQUALITY", item.craftedQuality) or ""
                    if craftedQualName ~= "" then
                        table.insert(itemIndicators, "✨ " .. craftedQualName)
                    end
                end
                if item.isStolen then
                    table.insert(itemIndicators, "👤 Stolen")
                end
                
                if #itemIndicators > 0 then
                    itemType = itemType .. (#itemType > 0 and " • " or "") .. table.concat(itemIndicators, " • ")
                end
                
                markdown = markdown .. "| " .. (item.emoji or "📦") .. " **" .. (item.slotName or "Unknown") .. "** | "
                markdown = markdown .. (item.name or "-") .. " | "
                markdown = markdown .. setLink .. " | "
                markdown = markdown .. (item.qualityEmoji or "⚪") .. " " .. (item.quality or "Normal") .. " | "
                markdown = markdown .. (item.trait or "None") .. " | "
                markdown = markdown .. (itemType ~= "" and itemType or "-") .. " |\n"
            end
            markdown = markdown .. "\n"
        end
        
        markdown = markdown .. "---\n\n"
    end
    
    return markdown
end

-- =====================================================
-- SKILLS
-- =====================================================

local function GenerateSkills(skillData, format)
    InitializeUtilities()
    
    local markdown = ""
    
    if format == "discord" then
        -- Discord: Show all skills, compact format
        markdown = markdown .. "\n**Skill Progression:**\n"
        for _, category in ipairs(skillData) do
            if category.skills and #category.skills > 0 then
                markdown = markdown .. (category.emoji or "⚔️") .. " **" .. category.name .. "**\n"
                for _, skill in ipairs(category.skills) do
                    local status = (skill.maxed or skill.isRacial) and "✅" or "📈"
                    local skillNameLinked = CreateSkillLineLink(skill.name, format)
                    -- For racial skills, don't show rank/progress
                    if skill.isRacial then
                        markdown = markdown .. status .. " " .. skillNameLinked .. "\n"
                    else
                        markdown = markdown .. status .. " " .. skillNameLinked .. " R" .. (skill.rank or 0)
                        if skill.progress and not skill.maxed then
                            markdown = markdown .. " (" .. skill.progress .. "%)"
                        elseif skill.maxed then
                            markdown = markdown .. " (100%)"
                        end
                        markdown = markdown .. "\n"
                    end
                    
                    -- Show passives for this skill line
                    if skill.passives and #skill.passives > 0 then
                        for _, passive in ipairs(skill.passives) do
                            local passiveName = CreateAbilityLink(passive.name, passive.abilityId, format)
                            local passiveStatus = passive.purchased and "✅" or "🔒"
                            local rankInfo = ""
                            if passive.currentRank and passive.maxRank then
                                if passive.maxRank > 1 then
                                    rankInfo = string.format(" (%d/%d)", passive.currentRank or 0, passive.maxRank)
                                end
                            end
                            markdown = markdown .. "  " .. passiveStatus .. " " .. passiveName .. rankInfo .. "\n"
                        end
                    end
                end
            end
        end
    else
        markdown = markdown .. "## 📜 Skill Progression\n\n"
        for _, category in ipairs(skillData) do
            markdown = markdown .. "### " .. (category.emoji or "⚔️") .. " " .. category.name .. "\n\n"
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
                        -- For racial skills, don't show rank
                        if skill.isRacial then
                            table.insert(maxedNames, "**" .. skillNameLinked .. "**")
                        else
                            table.insert(maxedNames, "**" .. skillNameLinked .. "**")
                        end
                    end
                    markdown = markdown .. "#### ✅ Maxed\n"
                    markdown = markdown .. table.concat(maxedNames, ", ") .. "\n\n"
                end
                
                -- Show in-progress skills with progress bars
                if #inProgressSkills > 0 then
                    if #maxedSkills > 0 then
                        markdown = markdown .. "#### 📈 In Progress\n"
                    end
                    for _, skill in ipairs(inProgressSkills) do
                        local skillNameLinked = CreateSkillLineLink(skill.name, format)
                        local progressPercent = skill.progress or 0
                        local progressBar = GenerateProgressBar(progressPercent, 10)
                        markdown = markdown .. "- **" .. skillNameLinked .. "**: Rank " .. (skill.rank or 0) .. 
                                              " " .. progressBar .. " " .. progressPercent .. "%\n"
                    end
                    markdown = markdown .. "\n"
                end
                
                -- Show low-level skills
                if #lowLevelSkills > 0 then
                    if #maxedSkills > 0 or #inProgressSkills > 0 then
                        markdown = markdown .. "#### 🔰 Early Progress\n"
                    end
                    for _, skill in ipairs(lowLevelSkills) do
                        local skillNameLinked = CreateSkillLineLink(skill.name, format)
                        local progressPercent = skill.progress or 0
                        local progressBar = GenerateProgressBar(progressPercent, 10)
                        markdown = markdown .. "- **" .. skillNameLinked .. "**: Rank " .. (skill.rank or 0) .. 
                                              " " .. progressBar .. " " .. progressPercent .. "%\n"
                    end
                    markdown = markdown .. "\n"
                end
                
                -- Show passives for all skills (grouped together)
                local allPassives = {}
                for _, skill in ipairs(category.skills) do
                    if skill.passives and #skill.passives > 0 then
                        for _, passive in ipairs(skill.passives) do
                            table.insert(allPassives, {
                                name = passive.name,
                                purchased = passive.purchased,
                                earnedRank = passive.earnedRank,
                                currentRank = passive.currentRank,
                                maxRank = passive.maxRank,
                                abilityId = passive.abilityId,
                                skillLine = skill.name
                            })
                        end
                    end
                end
                
                if #allPassives > 0 then
                    markdown = markdown .. "#### ✨ Passives\n"
                    for _, passive in ipairs(allPassives) do
                        local passiveName = CreateAbilityLink(passive.name, passive.abilityId, format)
                        local status = passive.purchased and "✅" or "🔒"
                        local rankInfo = ""
                        if passive.currentRank and passive.maxRank then
                            if passive.maxRank > 1 then
                                rankInfo = string.format(" (%d/%d)", passive.currentRank or 0, passive.maxRank)
                            end
                        end
                        markdown = markdown .. "- " .. status .. " " .. passiveName .. rankInfo .. 
                                              " *(from " .. CreateSkillLineLink(passive.skillLine, format) .. ")*\n"
                    end
                    markdown = markdown .. "\n"
                end
            end
        end

        markdown = markdown .. "---\n\n"
    end
    
    return markdown
end

-- =====================================================
-- SKILL MORPHS
-- =====================================================

local function GenerateSkillMorphs(skillMorphsData, format)
    InitializeUtilities()
    
    local markdown = ""
    
    -- Debug: Check if we have data
    if not skillMorphsData or #skillMorphsData == 0 then
        if format == "discord" then
            markdown = markdown .. "\n**Skill Morphs:**\n"
            markdown = markdown .. "No morphable abilities found.\n"
        else
            markdown = markdown .. "## 🌿 Skill Morphs\n\n"
            markdown = markdown .. "*No morphable abilities found.*\n\n"
            markdown = markdown .. "---\n\n"
        end
        return markdown
    end
    
    if format == "discord" then
        -- Discord: Compact format showing selected morphs
        markdown = markdown .. "\n**Skill Morphs:**\n"
        for _, skillType in ipairs(skillMorphsData) do
            markdown = markdown .. (skillType.emoji or "⚔️") .. " **" .. skillType.name .. "**\n"
            for _, skillLine in ipairs(skillType.skillLines) do
                markdown = markdown .. "  📋 " .. skillLine.name .. " (R" .. (skillLine.rank or 0) .. ")\n"
                for _, ability in ipairs(skillLine.abilities) do
                    -- Show base ability (now shows all morphable abilities, not just purchased)
                    local baseText = CreateAbilityLink(ability.name, nil, format)
                    local statusIcon = ability.purchased and "✅" or "🔒"
                    markdown = markdown .. "    " .. statusIcon .. " " .. baseText
                    
                    -- Show selected morph if any
                    if #ability.morphs > 0 then
                        for _, morph in ipairs(ability.morphs) do
                            if morph.selected then
                                local morphText = CreateAbilityLink(morph.name, morph.abilityId, format)
                                markdown = markdown .. " → " .. morphText
                                break
                            end
                        end
                    elseif ability.atMorphChoice then
                        markdown = markdown .. " (⚠️ morph choice available)"
                    end
                    markdown = markdown .. "\n"
                end
            end
        end
    else
        -- GitHub/VSCode: Detailed format with all morph options in collapsible sections
        markdown = markdown .. "## 🌿 Skill Morphs\n\n"
        
        for _, skillType in ipairs(skillMorphsData) do
            -- Count total abilities in this skill type
            local totalAbilities = 0
            for _, skillLine in ipairs(skillType.skillLines) do
                totalAbilities = totalAbilities + #skillLine.abilities
            end
            
            -- Collapsible section for each skill type
            markdown = markdown .. "<details>\n"
            markdown = markdown .. "<summary>" .. (skillType.emoji or "⚔️") .. " " .. skillType.name .. 
                                  " (" .. totalAbilities .. " abilities with morph choices)</summary>\n\n"
            
            for _, skillLine in ipairs(skillType.skillLines) do
                markdown = markdown .. "### " .. skillLine.name .. " (Rank " .. (skillLine.rank or 0) .. ")\n\n"
                
                for _, ability in ipairs(skillLine.abilities) do
                    -- Base ability header (now shows all morphable abilities, not just purchased)
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
                        statusIcon = "🔒 "  -- Unpurchased abilities
                    end
                    
                    markdown = markdown .. statusIcon .. "**" .. baseText .. "**"
                    
                    -- Show current rank if progressing
                    if ability.currentRank and ability.currentRank > 0 then
                        markdown = markdown .. " (Rank " .. ability.currentRank .. ")"
                    end
                    
                    markdown = markdown .. "\n"
                    
                    -- Show morph status
                    if #ability.morphs > 0 then
                        markdown = markdown .. "\n"
                        for _, morph in ipairs(ability.morphs) do
                            local morphIcon = morph.selected and "✅" or "⚪"
                            local morphText = CreateAbilityLink(morph.name, morph.abilityId, format)
                            markdown = markdown .. "  " .. morphIcon .. " **Morph " .. morph.morphSlot .. "**: " .. morphText .. "\n"
                        end
                    elseif ability.atMorphChoice then
                        markdown = markdown .. "  ⚠️ *Morph choice available - level up to unlock*\n"
                    else
                        if ability.purchased then
                            markdown = markdown .. "  🔒 *Morph locked - continue leveling this skill*\n"
                        else
                            markdown = markdown .. "  🔒 *Purchase this ability to unlock morphs*\n"
                        end
                    end
                    
                    markdown = markdown .. "\n"
                end
                
                markdown = markdown .. "\n"
            end
            
            markdown = markdown .. "</details>\n\n"
        end
        
        markdown = markdown .. "---\n\n"
    end
    
    return markdown
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.generators.sections = CM.generators.sections or {}
CM.generators.sections.GenerateSkillBars = GenerateSkillBars
CM.generators.sections.GenerateSkillMorphs = GenerateSkillMorphs
CM.generators.sections.GenerateEquipment = GenerateEquipment
CM.generators.sections.GenerateSkills = GenerateSkills

