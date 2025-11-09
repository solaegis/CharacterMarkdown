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
    
    -- Handle nil or inactive companion data
    if not companionData or not companionData.active then
        if format == "discord" then
            markdown = markdown .. "**Active Companion:**\n*No active companion*\n\n"
        else
            markdown = markdown .. "## 👥 Active Companion\n\n"
            markdown = markdown .. "*No active companion*\n\n---\n\n"
        end
        return markdown
    end
    
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
                local itemText = "• " .. item.name .. " (L" .. item.level .. ", " .. item.quality .. ")"
                
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
                        local chargePercent = item.enchantCharge and item.enchantCharge > 0 and math.floor((item.enchantCharge / item.enchantMaxCharge) * 100) or 0
                        itemText = itemText .. " (" .. chargePercent .. "%)"
                    end
                end
                
                markdown = markdown .. itemText .. "\n"
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
        
        -- Skills section - Front bar format (horizontal table)
        if companionData.skills then
            local abilities = companionData.skills.abilities or {}
            local ultimate = companionData.skills.ultimate or "[Empty]"
            local ultimateId = companionData.skills.ultimateId
            
            -- Create front bar table with abilities (1-5) and ultimate (⚡)
            if #abilities > 0 or ultimate then
                -- Header row with slot numbers (1-5 for abilities, ⚡ for ultimate)
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
        
        -- Equipment section
        if companionData.equipment and #companionData.equipment > 0 then
            markdown = markdown .. "**Equipment:**\n"
            for _, item in ipairs(companionData.equipment) do
                local warning = ""
                if item.level and item.level < level and item.level < 20 then
                    warning = " ⚠️"
                end
                
                local itemText = "- **" .. item.slot .. "**: " .. item.name .. " (Level " .. item.level .. ", " .. item.quality .. ")"
                
                -- Add set information
                if item.hasSet and item.setName then
                    itemText = itemText .. " — *" .. item.setName .. "*"
                end
                
                -- Add trait information
                if item.traitName and item.traitName ~= "None" then
                    itemText = itemText .. " — Trait: " .. item.traitName
                end
                
                -- Add enchantment information
                if item.enchantName then
                    itemText = itemText .. " — Enchant: " .. item.enchantName
                    if item.enchantMaxCharge and item.enchantMaxCharge > 0 then
                        local chargePercent = item.enchantCharge and item.enchantCharge > 0 and math.floor((item.enchantCharge / item.enchantMaxCharge) * 100) or 0
                        itemText = itemText .. " (" .. chargePercent .. "% charge)"
                    end
                end
                
                markdown = markdown .. itemText .. warning .. "\n"
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

CM.generators.sections = CM.generators.sections or {}
CM.generators.sections.GenerateCompanion = GenerateCompanion

