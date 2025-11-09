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
        CreateAbilityLink = (CM.links and CM.links.CreateAbilityLink) or function(name, id, fmt) return name or "" end
        CreateSetLink = (CM.links and CM.links.CreateSetLink) or function(name, fmt) return name or "" end
        CreateSkillLineLink = (CM.links and CM.links.CreateSkillLineLink) or function(name, fmt) return name or "" end
        FormatNumber = (CM.utils and CM.utils.FormatNumber) or function(num) return tostring(num or 0) end
        GenerateProgressBar = (CM.generators and CM.generators.helpers and CM.generators.helpers.GenerateProgressBar) or function(percent, width) return "" end
        markdown = (CM.utils and CM.utils.markdown) or nil
    end
end

-- =====================================================
-- HELPER: Get Set Type Badge
-- =====================================================

local function GetSetTypeBadge(setTypeName)
    if not setTypeName then return "" end
    
    local badges = {
        ["Trial"] = "🏰",  -- Changed from 🏛️ for better compatibility
        ["Dungeon"] = "🏰",
        ["Overland"] = "🌍",
        ["Crafted"] = "⚒️",
        ["Monster"] = "👹",
        ["Arena"] = "⚔️",
        ["Battleground"] = "🎯",
        ["Cyrodiil"] = "🗡️",
        ["Imperial City"] = "🏰",  -- Changed from 🏛️ for better compatibility
        ["Mythic"] = "✨",
        ["Class"] = "📚",
    }
    
    local badge = badges[setTypeName] or "📦"
    return badge .. " " .. setTypeName
end

-- =====================================================
-- SKILL BARS
-- =====================================================

local function GenerateSkillBars(skillBarData, format, skillMorphsData, skillProgressionData)
    -- Defensive: Handle nil or invalid format
    if not format then format = "github" end
    
    -- Safe initialization
    local success, err = pcall(InitializeUtilities)
    if not success then
        CM.Warn("GenerateSkillBars: InitializeUtilities failed: " .. tostring(err))
    end
    
    -- Validate input data - handle nil, non-table, or empty table
    if not skillBarData or type(skillBarData) ~= "table" or #skillBarData == 0 then
        CM.DebugPrint("EQUIPMENT", "GenerateSkillBars: No skill bar data provided")
        if format == "discord" then
            return "\n**Skill Bars:**\n*No skill bars configured*\n"
        else
            local placeholder = "## ⚔️ Combat Arsenal\n\n*No skill bars configured*\n\n---\n\n"
            CM.DebugPrint("EQUIPMENT", string.format("GenerateSkillBars: Returning placeholder (%d chars)", string.len(placeholder)))
            return placeholder
        end
    end
    
    local output = ""
    local CreateCollapsible = markdown and markdown.CreateCollapsible
    
    CM.DebugPrint("EQUIPMENT", string.format("GenerateSkillBars: format=%s, skillBarData type=%s, length=%s", 
        format, type(skillBarData), skillBarData and tostring(#skillBarData) or "nil"))
    
    if format == "discord" then
        output = output .. "\n**Skill Bars:**\n"
        for barIdx, bar in ipairs(skillBarData) do
            if bar and type(bar) == "table" then
                output = output .. (bar.name or "Unknown Bar") .. "\n"
                local ultimateText = ""
                if CreateAbilityLink then
                    ultimateText = CreateAbilityLink(bar.ultimate or "", bar.ultimateId, format) or (bar.ultimate or "[Empty]")
                else
                    ultimateText = bar.ultimate or "[Empty]"
                end
                output = output .. "```" .. ultimateText .. "```\n"
                local abilities = (bar.abilities and type(bar.abilities) == "table") and bar.abilities or {}
                for i, ability in ipairs(abilities) do
                    if ability and type(ability) == "table" then
                        local abilityText = ""
                        if CreateAbilityLink then
                            abilityText = CreateAbilityLink(ability.name or "", ability.id, format) or (ability.name or "Unknown")
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
            if bar and type(bar) == "table" then
                local label = barLabels[barIdx] or {emoji = "⚔️", suffix = ""}
                local barName = bar.name or "Unknown Bar"
                output = output .. "### " .. label.emoji .. " " .. barName .. "\n\n"
                
                -- Safely get abilities array
                local abilities = (bar.abilities and type(bar.abilities) == "table") and bar.abilities or {}
                local hasUltimate = bar.ultimate and bar.ultimate ~= ""
                
                -- Abilities table (horizontal format - rows instead of columns)
                -- Include ultimate as 6th column
                if #abilities > 0 or hasUltimate then
                    -- Header row with slot numbers (1-5 for abilities, 6 for ultimate)
                    local headerRow = "|"
                    local separatorRow = "|"
                    for i = 1, #abilities do
                        headerRow = headerRow .. " " .. i .. " |"
                        separatorRow = separatorRow .. ":--|"
                    end
                    -- Add ultimate column if present
                    if hasUltimate then
                        headerRow = headerRow .. " ⚡ |"
                        separatorRow = separatorRow .. ":--|"
                    end
                    output = output .. headerRow .. "\n"
                    output = output .. separatorRow .. "\n"
                    
                    -- Abilities row (with ultimate in 6th column)
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
                            local success_ult, ultText = pcall(CreateAbilityLink, bar.ultimate or "", ultimateId, format)
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
                end
            else
                CM.Warn("GenerateSkillBars: bar at index " .. tostring(barIdx) .. " is nil or not a table, skipping")
            end
        end
        
        -- Ensure we always have at least the header and separator
        if output == "## ⚔️ Combat Arsenal\n\n" then
            output = output .. "*No skill bars configured*\n\n"
        end
        
        output = output .. "---\n\n"
        
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
                        local success2, collapsibleContent = pcall(CreateCollapsible, "Skill Morphs", skillMorphsContent, "🌿", false)
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
        
        -- Add Skill Progression categories as collapsible subsections
        if skillProgressionData and #skillProgressionData > 0 then
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
                            categoryContent = categoryContent .. "- **" .. skillNameLinked .. "**: Rank " .. (skill.rank or 0) .. 
                                                  " " .. progressBar .. " " .. progressPercent .. "%\n"
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
                            categoryContent = categoryContent .. "- **" .. skillNameLinked .. "**: Rank " .. (skill.rank or 0) .. 
                                                  " " .. progressBar .. " " .. progressPercent .. "%\n"
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
                                    skillLineName = skill.name
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
                                if not passiveName:find("%[.*%]%(") or not passiveName:find("%)$") or 
                                   not passiveName:find("https://en.uesp.net/wiki/Online:") then
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
                            skillLineLink = tostring(skillLineLink):gsub("[\r\n\t]", ""):gsub("^%s+", ""):gsub("%s+$", "")
                            categoryContent = categoryContent .. string.format("- %s %s%s *(from %s)*\n", 
                                passiveStatus, passiveName, rankInfo, skillLineLink)
                        end
                        categoryContent = categoryContent .. "\n"
                    end
                    
                    if categoryContent ~= "" then
                        if CreateCollapsible then
                            local success3, collapsibleContent2 = pcall(CreateCollapsible, category.name, categoryContent, categoryEmoji, false)
                            if success3 and collapsibleContent2 then
                                output = output .. collapsibleContent2
                            else
                                output = output .. "### " .. categoryEmoji .. " " .. category.name .. "\n\n" .. categoryContent .. "\n\n"
                            end
                        else
                            output = output .. "### " .. categoryEmoji .. " " .. category.name .. "\n\n" .. categoryContent .. "\n\n"
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
        CM.Warn("GenerateSkillBars: output is empty/nil/whitespace-only, returning placeholder")
        if format == "discord" then
            return "\n**Skill Bars:**\n*No skill bars configured*\n"
        else
            local placeholder = "## ⚔️ Combat Arsenal\n\n*No skill bars configured*\n\n---\n\n"
            CM.DebugPrint("EQUIPMENT", string.format("GenerateSkillBars: Returning placeholder (%d chars)", string.len(placeholder)))
            return placeholder
        end
    end
    
    -- Final validation: ensure output starts with the section header
    if format ~= "discord" and not output:match("^##%s+⚔️%s+Combat%s+Arsenal") then
        CM.Warn("GenerateSkillBars: output doesn't start with expected header, prepending it")
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
    
    CM.DebugPrint("EQUIPMENT", string.format("GenerateSkillBars: Returning output (%d chars, starts with: %s)", 
        string.len(output), output:sub(1, math.min(50, string.len(output)))))
    return output
end

-- =====================================================
-- EQUIPMENT
-- =====================================================

local function GenerateEquipment(equipmentData, format)
    -- Wrap entire function body in error handling
    local function GenerateEquipmentInternal(equipmentData, format)
        -- Defensive: Handle nil or invalid format
        if not format then format = "github" end
        
        -- Safe initialization with error handling
        local success, err = pcall(InitializeUtilities)
        if not success then
            CM.Warn("GenerateEquipment: InitializeUtilities failed: " .. tostring(err))
            -- Return placeholder if initialization fails
            if format == "discord" then
                return "**Equipment & Active Sets:**\n*Error initializing equipment generator*\n\n"
            else
                return "## ⚔️ Equipment & Active Sets\n\n*Error initializing equipment generator*\n\n---\n\n"
            end
        end
        
        -- Ensure utility functions are available (defensive fallbacks)
        if not CreateSetLink then
            CreateSetLink = function(name, fmt) return name or "" end
        end
        if not CreateAbilityLink then
            CreateAbilityLink = function(name, id, fmt) return name or "" end
        end
        if not FormatNumber then
            FormatNumber = function(num) return tostring(num or 0) end
        end
        
        -- Always generate section header when called (registry handles condition check)
        local result = ""
        
        -- Check if equipmentData is nil or not a table, or if it's missing required structure
        if not equipmentData or type(equipmentData) ~= "table" or 
           (not equipmentData.sets and not equipmentData.items) then
            -- Still generate section with message
            if format == "discord" then
                result = result .. "**Equipment & Active Sets:**\n*Equipment data not available*\n\n"
                return result
            else
                if markdown and markdown.CreateHeader then
                    result = markdown.CreateHeader("Equipment & Active Sets", "⚔️", nil, 2) or "## ⚔️ Equipment & Active Sets\n\n"
                else
                    result = "## ⚔️ Equipment & Active Sets\n\n"
                end
                result = result .. "*Equipment data not available*\n\n---\n\n"
                if markdown and markdown.CreateCollapsible then
                    local success4, collapsible = pcall(markdown.CreateCollapsible, "Equipment & Active Sets", result, "⚔️", true)
                    if success4 and collapsible then
                        return collapsible
                    else
                        return result
                    end
                end
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
                            result = result .. " - Charge: " .. string.format("%d/%d (%d%%)", charge, maxCharge, chargePercent)
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
            result = markdown.CreateHeader("Equipment & Active Sets", "⚔️", nil, 2) or "## ⚔️ Equipment & Active Sets\n\n"
        else
            result = "## ⚔️ Equipment & Active Sets\n\n"
        end
        
        -- SET DISPLAY: Classic format shows Armor Sets breakdown, Enhanced shows progress bars
        -- Defensive: Ensure equipmentData and sets array exist before checking length
        if equipmentData and type(equipmentData) == "table" and 
           equipmentData.sets and type(equipmentData.sets) == "table" and #equipmentData.sets > 0 then
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
                            setInfo = set
                        })
                    else
                        table.insert(partialSets, {
                            name = set.name,
                            link = setLink,
                            count = set.count,
                            slots = slotsStr,
                            setTypeBadge = setTypeBadge,
                            setInfo = set
                        })
                    end
                end
                
                if #activeSets > 0 then
                    result = result .. "### 🛡️ Armor Sets\n\n"
                    result = result .. "#### ✅ Active Sets (5-piece bonuses)\n\n"
                    for _, set in ipairs(activeSets) do
                        local setLine = string.format("- ✅ **%s**%s (%d/5 pieces) - %s", set.link, set.setTypeBadge, set.count, set.slots)
                        result = result .. setLine .. "\n"
                        
                        -- Add LibSets information if available
                        if set.setInfo and (set.setInfo.dropLocations or set.setInfo.dropMechanicNames or set.setInfo.dlcId) then
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
                                    local mechanics = LibSetsIntegration.FormatDropMechanics(set.setInfo.dropMechanics, set.setInfo.dropMechanicNames)
                                    if mechanics then
                                        table.insert(details, "⚙️ " .. mechanics)
                                    end
                                end
                                
                                -- DLC/Chapter info
                                if set.setInfo.dlcId or set.setInfo.chapterId then
                                    local dlcInfo = LibSetsIntegration.FormatDLCInfo(set.setInfo.dlcId, set.setInfo.chapterId)
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
                        local setLine = string.format("- ⚠️ **%s**%s (%d/5 pieces) - %s", set.link, set.setTypeBadge, set.count, set.slots)
                        result = result .. setLine .. "\n"
                        
                        -- Add LibSets information if available
                        if set.setInfo and (set.setInfo.dropLocations or set.setInfo.dropMechanicNames or set.setInfo.dlcId) then
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
                                    local mechanics = LibSetsIntegration.FormatDropMechanics(set.setInfo.dropMechanics, set.setInfo.dropMechanicNames)
                                    if mechanics then
                                        table.insert(details, "⚙️ " .. mechanics)
                                    end
                                end
                                
                                -- DLC/Chapter info
                                if set.setInfo.dlcId or set.setInfo.chapterId then
                                    local dlcInfo = LibSetsIntegration.FormatDLCInfo(set.setInfo.dlcId, set.setInfo.chapterId)
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
                -- ENHANCED: Progress indicators (new style)
                local setLines = {}
                
                for _, set in ipairs(equipmentData.sets) do
                    local maxPieces = 5
                    local indicator = "•"
                    if markdown and markdown.GetProgressIndicator then
                        local success_ind, ind = pcall(markdown.GetProgressIndicator, math.min(set.count or 0, maxPieces), maxPieces)
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
                    
                    if markdown and markdown.CreateProgressBar then
                        local success_pb, progressBar = pcall(markdown.CreateProgressBar, math.min(set.count or 0, maxPieces), maxPieces, 10, format)
                        if not success_pb or not progressBar then
                            progressBar = ""
                        end
                        if set.count > maxPieces then
                            table.insert(setLines, string.format("%s **%s**%s `%d/%d` %s *(+%d extra)*", 
                                indicator, setLink, setTypeBadge, maxPieces, maxPieces, progressBar, set.count - maxPieces))
                        else
                            table.insert(setLines, string.format("%s **%s**%s `%d/%d` %s", 
                                indicator, setLink, setTypeBadge, set.count, maxPieces, progressBar))
                        end
                    else
                        if set.count > maxPieces then
                            table.insert(setLines, string.format("%s **%s**%s (%d/%d pieces, +%d extra)", 
                                indicator, setLink, setTypeBadge, maxPieces, maxPieces, set.count - maxPieces))
                        else
                            table.insert(setLines, string.format("%s **%s**%s (%d/%d pieces)", 
                                indicator, setLink, setTypeBadge, set.count, maxPieces))
                        end
                    end
                end
                
                result = result .. table.concat(setLines, "  \n") .. "\n\n"
            end
        end
        
        -- Equipment details table
        -- Defensive: Ensure equipmentData and items array exist before checking length
        if equipmentData and type(equipmentData) == "table" and 
           equipmentData.items and type(equipmentData.items) == "table" and #equipmentData.items > 0 then
            result = result .. "### 📋 Equipment Details\n\n"
            result = result .. "| Slot | Item | Set | Quality | Trait | Type | Enchantment Charge |\n"
            result = result .. "|:-----|:-----|:----|:--------|:------|:-----|:-------------------|\n"
            
            -- Create a lookup table for set info by set name
            local setInfoLookup = {}
            if equipmentData.sets and type(equipmentData.sets) == "table" then
                for _, set in ipairs(equipmentData.sets) do
                    if set.name then
                        setInfoLookup[set.name] = set
                    end
                end
            end
            
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
                
                -- Format enchantment charge
                local enchantChargeText = "-"
                if item.enchantment and item.enchantment ~= false then
                    -- CRITICAL: Ensure charge and maxCharge are numbers, not strings
                    local charge = 0
                    if item.enchantCharge ~= nil then
                        if type(item.enchantCharge) == "number" then
                            charge = item.enchantCharge
                        elseif type(item.enchantCharge) == "string" then
                            -- Try to convert string to number
                            charge = tonumber(item.enchantCharge) or 0
                        end
                    end
                    
                    local maxCharge = 0
                    if item.enchantMaxCharge ~= nil then
                        if type(item.enchantMaxCharge) == "number" then
                            maxCharge = item.enchantMaxCharge
                        elseif type(item.enchantMaxCharge) == "string" then
                            -- Try to convert string to number
                            maxCharge = tonumber(item.enchantMaxCharge) or 0
                        end
                    end
                    
                    if maxCharge > 0 then
                        local chargePercent = math.floor((charge / maxCharge) * 100)
                        enchantChargeText = string.format("%d/%d (%d%%)", charge, maxCharge, chargePercent)
                    elseif charge > 0 then
                        enchantChargeText = tostring(charge)
                    end
                end
                
                -- Defensive: Ensure all values are strings and handle nil
                local slotName = item.slotName or "Unknown"
                local itemName = item.name or "-"
                local qualityEmoji = item.qualityEmoji or "⚪"
                local quality = item.quality or "Normal"
                local trait = item.trait or "None"
                local itemTypeDisplay = (itemType ~= "" and itemType) or "-"
                
                -- Build entire table row as a single string to prevent chunking/splitting
                local tableRow = string.format("| %s **%s** | %s | %s | %s %s | %s | %s | %s |",
                    item.emoji or "📦",
                    slotName,
                    itemName,
                    setLink or "-",
                    qualityEmoji,
                    quality,
                    trait,
                    itemTypeDisplay,
                    enchantChargeText
                )
                -- CRITICAL: Ensure table row is properly formatted and never merged
                -- Step 1: Remove ALL trailing whitespace (spaces, tabs, newlines)
                tableRow = tableRow:gsub("%s+$", "")
                -- Step 2: Add exactly ONE newline - this is critical for preventing row merging
                tableRow = tableRow .. "\n"
                -- Step 3: Verify the row ends with newline (defensive check)
                if not tableRow:match("\n$") then
                    CM.Warn("GenerateEquipment: Table row missing newline, forcing add")
                    tableRow = tableRow .. "\n"
                end
                -- Step 4: Append to result - each row MUST be on its own line
                -- CRITICAL: Never allow table rows to be concatenated without newlines
                result = result .. tableRow
            end
            result = result .. "\n"
        end
        
        -- If no sets and no items, show a message
        -- Defensive: Ensure equipmentData exists and arrays exist and are tables before checking length
        local hasSets = equipmentData and type(equipmentData) == "table" and 
                       equipmentData.sets and type(equipmentData.sets) == "table" and #equipmentData.sets > 0
        local hasItems = equipmentData and type(equipmentData) == "table" and 
                        equipmentData.items and type(equipmentData.items) == "table" and #equipmentData.items > 0
        if not hasSets and not hasItems then
            result = result .. "*No equipment data available*\n\n"
        end
        
        result = result .. "---\n\n"
        
        -- CRITICAL: Ensure result is never empty before wrapping in collapsible
        if not result or result == "" or (result:gsub("%s+", "") == "") then
            CM.Error("GenerateEquipment: CRITICAL - result is empty after all checks, forcing placeholder")
            if format == "discord" then
                return "**Equipment & Active Sets:**\n*No equipment data available*\n\n"
            else
                result = "## ⚔️ Equipment & Active Sets\n\n*No equipment data available*\n\n---\n\n"
            end
        end
        
        -- Only wrap in collapsible if markdown utilities are available and result is not empty
        if markdown and markdown.CreateCollapsible and result and result ~= "" and result:gsub("%s+", "") ~= "" then
            -- Wrap entire equipment section in collapsible
            local success5, collapsible = pcall(markdown.CreateCollapsible, "Equipment & Active Sets", result, "⚔️", true)
            if success5 and collapsible and collapsible ~= "" and collapsible:gsub("%s+", "") ~= "" then
                return collapsible
            else
                if not success5 then
                    CM.Warn("GenerateEquipment: CreateCollapsible failed: " .. tostring(collapsible))
                else
                    CM.Warn("GenerateEquipment: CreateCollapsible returned empty, using original result")
                end
                return result
            end
        end
        
        return result
    end
    
    -- Call internal function with error handling
    local success, result = pcall(GenerateEquipmentInternal, equipmentData, format)
    if success then
        -- Defensive: Ensure we never return empty string
        if not result or result == "" then
            CM.Warn("GenerateEquipment: Internal function returned empty result")
            if format == "discord" then
                return "**Equipment & Active Sets:**\n*No equipment data available*\n\n"
            else
                return "## ⚔️ Equipment & Active Sets\n\n*No equipment data available*\n\n---\n\n"
            end
        end
        return result
    else
        -- Log the actual error for debugging
        local errorMsg = tostring(result) or "unknown error"
        CM.Error("GenerateEquipment: Internal function failed with error: " .. errorMsg)
        CM.Warn("GenerateEquipment: equipmentData type: " .. type(equipmentData))
        if equipmentData and type(equipmentData) == "table" then
            CM.Warn("GenerateEquipment: equipmentData.sets exists: " .. tostring(equipmentData.sets ~= nil))
            CM.Warn("GenerateEquipment: equipmentData.items exists: " .. tostring(equipmentData.items ~= nil))
        end
        if format == "discord" then
            return "**Equipment & Active Sets:**\n*Error generating equipment data*\n\n"
        else
            return "## ⚔️ Equipment & Active Sets\n\n*Error generating equipment data*\n\n---\n\n"
        end
    end
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
                    output = output .. "#### 📈 In Progress\n"
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
                    output = output .. "#### ⚪ Early Progress\n"  -- Changed from 🔰 to ⚪ for better compatibility
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
                        -- Safety check: ensure skillLineLink is never nil or empty
                        if not skillLineLink or skillLineLink == "" then
                            skillLineLink = passive.skillLineName or "Unknown"
                        end
                        -- Sanitize skillLineLink to prevent truncation issues
                        skillLineLink = tostring(skillLineLink):gsub("[\r\n\t]", ""):gsub("^%s+", ""):gsub("%s+$", "")
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
            
            -- Show skill type header directly (not collapsible)
            output = output .. "### " .. (skillType.emoji or "⚔️") .. " " .. skillType.name .. 
                                  " (" .. totalAbilities .. " abilities with morph choices)\n\n"
            
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
                            morphName = morphName:gsub("[\r\n\t]", "")  -- Remove newlines, carriage returns, tabs
                            morphName = morphName:gsub("^%s+", ""):gsub("%s+$", "")  -- Trim leading/trailing spaces
                            morphName = morphName:gsub("%s+", " ")  -- Normalize multiple spaces to single space
                            
                            local morphText = CreateAbilityLink(morphName, selectedMorph.abilityId, format)
                            -- Ensure morphText is valid and complete
                            if morphText and morphText ~= "" then
                                morphText = morphText:gsub("[\r\n\t]", "")
                                if not morphText:find("%[.*%]%(") or not morphText:find("%)$") or 
                                   not morphText:find("https://en.uesp.net/wiki/Online:") then
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
                                    if not morphText:find("%[.*%]%(") or not morphText:find("%)$") or 
                                       not morphText:find("https://en.uesp.net/wiki/Online:") then
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
        
        -- Removed hardcoded divider - dividers are handled by section registry
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
