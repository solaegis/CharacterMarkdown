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
            markdown = markdown .. "| Slot | Item | Set | Quality | Trait |\n"
            markdown = markdown .. "|:-----|:-----|:----|:--------|:------|\n"
            for _, item in ipairs(equipmentData.items) do
                local setLink = CreateSetLink(item.setName, format)
                markdown = markdown .. "| " .. (item.emoji or "📦") .. " **" .. (item.slotName or "Unknown") .. "** | "
                markdown = markdown .. (item.name or "-") .. " | "
                markdown = markdown .. setLink .. " | "
                markdown = markdown .. (item.qualityEmoji or "⚪") .. " " .. (item.quality or "Normal") .. " | "
                markdown = markdown .. (item.trait or "None") .. " |\n"
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
                    local status = skill.maxed and "✅" or "📈"
                    local skillNameLinked = CreateSkillLineLink(skill.name, format)
                    markdown = markdown .. status .. " " .. skillNameLinked .. " R" .. (skill.rank or 0)
                    if skill.progress and not skill.maxed then
                        markdown = markdown .. " (" .. skill.progress .. "%)"
                    elseif skill.maxed then
                        markdown = markdown .. " (100%)"
                    end
                    markdown = markdown .. "\n"
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
                    if skill.maxed or (skill.rank and skill.rank >= 50) then
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
            end
        end

        markdown = markdown .. "---\n\n"
    end
    
    return markdown
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.generators.sections.GenerateSkillBars = GenerateSkillBars
CM.generators.sections.GenerateEquipment = GenerateEquipment
CM.generators.sections.GenerateSkills = GenerateSkills

