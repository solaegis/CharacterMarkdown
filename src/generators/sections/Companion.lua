-- CharacterMarkdown - Companion Section Generator
-- Generates companion-related markdown sections

local CM = CharacterMarkdown

-- Cache for utility functions (lazy-initialized on first use)
local CreateAbilityLink, CreateCompanionLink, Pluralize

-- Lazy initialization of cached references
local function InitializeUtilities()
    if not Pluralize then
        CreateAbilityLink = CM.links.CreateAbilityLink
        CreateCompanionLink = CM.links.CreateCompanionLink
        Pluralize = CM.generators.helpers.Pluralize
    end
end

-- =====================================================
-- COMPANION
-- =====================================================

local function GenerateCompanion(companionData, format)
    InitializeUtilities()
    
    local markdown = ""
    
    if format == "discord" then
        local companionNameLinked = CreateCompanionLink(companionData.name, format)
        markdown = markdown .. "\n**Companion:** " .. companionNameLinked .. " (L" .. (companionData.level or 0) .. ")\n"
        if companionData.skills then
            local ultimateText = CreateAbilityLink(companionData.skills.ultimate, companionData.skills.ultimateId, format)
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
                markdown = markdown .. "• " .. item.name .. " (L" .. item.level .. ", " .. item.quality .. ")\n"
            end
        end
    else
        local companionNameLinked = CreateCompanionLink(companionData.name, format)
        markdown = markdown .. "## 👥 Active Companion\n\n"
        markdown = markdown .. "### 🧙 " .. companionNameLinked .. "\n\n"
        
        -- Status table with warnings
        markdown = markdown .. "| Attribute | Status |\n"
        markdown = markdown .. "|:----------|:-------|\n"
        
        local level = companionData.level or 0
        local levelStatus = "Level " .. level
        if level < 20 then
            levelStatus = levelStatus .. " ⚠️ (Needs leveling)"
        elseif level == 20 then
            levelStatus = levelStatus .. " ✅ (Max)"
        end
        markdown = markdown .. "| **Level** | " .. levelStatus .. " |\n"
        
        -- Check equipment status
        local lowLevelGear = 0
        local maxLevel = 0
        if companionData.equipment and #companionData.equipment > 0 then
            for _, item in ipairs(companionData.equipment) do
                if item.level and item.level > maxLevel then
                    maxLevel = item.level
                end
                if item.level and item.level < level and item.level < 20 then
                    lowLevelGear = lowLevelGear + 1
                end
            end
        end
        
        local gearStatus = "Max Level: " .. maxLevel
        if lowLevelGear > 0 then
            gearStatus = gearStatus .. " ⚠️ (" .. lowLevelGear .. " outdated " .. Pluralize(lowLevelGear, "piece") .. ")"
        elseif maxLevel >= level or maxLevel >= 20 then
            gearStatus = gearStatus .. " ✅"
        end
        markdown = markdown .. "| **Equipment** | " .. gearStatus .. " |\n"
        
        -- Check for empty ability slots
        local emptySlots = 0
        local totalSlots = 0
        if companionData.skills then
            if companionData.skills.ultimate == "[Empty]" or companionData.skills.ultimate == "Empty" then
                emptySlots = emptySlots + 1
            end
            totalSlots = totalSlots + 1
            
            if companionData.skills.abilities then
                for _, ability in ipairs(companionData.skills.abilities) do
                    totalSlots = totalSlots + 1
                    if ability.name == "[Empty]" or ability.name == "Empty" then
                        emptySlots = emptySlots + 1
                    end
                end
            end
        end
        
        local abilityStatus = (totalSlots - emptySlots) .. "/" .. totalSlots .. " abilities slotted"
        if emptySlots > 0 then
            abilityStatus = abilityStatus .. " ⚠️ (" .. emptySlots .. " empty)"
        else
            abilityStatus = abilityStatus .. " ✅"
        end
        markdown = markdown .. "| **Abilities** | " .. abilityStatus .. " |\n"
        markdown = markdown .. "\n"
        
        -- Skills section
        if companionData.skills then
            local ultimateText = CreateAbilityLink(companionData.skills.ultimate, companionData.skills.ultimateId, format)
            markdown = markdown .. "**⚡ Ultimate:** " .. ultimateText .. "\n\n"
            markdown = markdown .. "**Abilities:**\n"
            for i, ability in ipairs(companionData.skills.abilities or {}) do
                local abilityText = CreateAbilityLink(ability.name, ability.id, format)
                markdown = markdown .. i .. ". " .. abilityText .. "\n"
            end
            markdown = markdown .. "\n"
        end
        
        -- Equipment section
        if companionData.equipment and #companionData.equipment > 0 then
            markdown = markdown .. "**Equipment:**\n"
            for _, item in ipairs(companionData.equipment) do
                local warning = ""
                if item.level and item.level < level and item.level < 20 then
                    warning = " ⚠️"
                end
                markdown = markdown .. "- **" .. item.slot .. "**: " .. item.name .. " (Level " .. item.level .. ", " .. item.quality .. ")" .. warning .. "\n"
            end
            markdown = markdown .. "\n"
        end

        markdown = markdown .. "---\n\n"
    end
    
    return markdown
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.generators.sections.GenerateCompanion = GenerateCompanion

