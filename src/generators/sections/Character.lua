-- CharacterMarkdown - Character Section Generators
-- Generates character-related markdown sections

local CM = CharacterMarkdown

-- Cache for utility functions (lazy-initialized on first use)
local CreateRaceLink, CreateClassLink, CreateAllianceLink, CreateZoneLink, CreateMundusLink, CreateBuffLink
local FormatNumber, Pluralize

-- Lazy initialization of cached references
local function InitializeUtilities()
    if not FormatNumber then
        CreateRaceLink = CM.links.CreateRaceLink
        CreateClassLink = CM.links.CreateClassLink
        CreateAllianceLink = CM.links.CreateAllianceLink
        CreateZoneLink = CM.links.CreateZoneLink
        CreateMundusLink = CM.links.CreateMundusLink
        CreateBuffLink = CM.links.CreateBuffLink
        FormatNumber = CM.utils.FormatNumber
        Pluralize = CM.generators.helpers.Pluralize
    end
end

-- =====================================================
-- QUICK SUMMARY
-- =====================================================

local function GenerateQuickSummary(characterData, equipmentData)
    InitializeUtilities()
    
    local name = characterData.name or "Unknown"
    local level = characterData.level >= 50 and "L50" or "L" .. (characterData.level or 0)
    local cp = characterData.cp > 0 and (" CP" .. FormatNumber(characterData.cp)) or ""
    local race = (characterData.race or ""):sub(1, 4)
    local class = (characterData.class or ""):sub(1, 2)
    local esoPlusIndicator = characterData.esoPlus and " 👑" or ""
    
    local sets = ""
    if equipmentData.sets and #equipmentData.sets > 0 then
        local topSets = {}
        for i = 1, math.min(2, #equipmentData.sets) do
            table.insert(topSets, equipmentData.sets[i].name .. "(" .. equipmentData.sets[i].count .. ")")
        end
        sets = " • " .. table.concat(topSets, ", ")
    end
    
    return string.format("%s • %s%s%s • %s %s%s",
        name, level, cp, esoPlusIndicator, race, class, sets)
end

-- =====================================================
-- HEADER
-- =====================================================

local function GenerateHeader(characterData, cpData, format)
    InitializeUtilities()
    
    local markdown = ""
    
    -- Build name with title if present
    local nameWithTitle = characterData.name or "Unknown"
    if characterData.title and characterData.title ~= "" then
        nameWithTitle = nameWithTitle .. ", *" .. characterData.title .. "*"
    end
    
    if format == "discord" then
        markdown = markdown .. "# **" .. nameWithTitle .. "**\n"
        local raceText = CreateRaceLink(characterData.race, format)
        local classText = CreateClassLink(characterData.class, format)
        local allianceText = CreateAllianceLink(characterData.alliance, format)
        markdown = markdown .. raceText .. " " .. classText .. 
                              " • L" .. (characterData.level or 0)
        if characterData.cp > 0 then
            markdown = markdown .. " • CP" .. FormatNumber(characterData.cp)
            -- Add CP discipline breakdown for Discord
            if cpData and cpData.disciplines and #cpData.disciplines > 0 then
                local disciplineParts = {}
                for _, discipline in ipairs(cpData.disciplines) do
                    table.insert(disciplineParts, discipline.name .. " " .. discipline.total)
                end
                markdown = markdown .. " (" .. table.concat(disciplineParts, " • ") .. ")"
            end
        end
        if characterData.esoPlus then
            markdown = markdown .. " • 👑 ESO Plus"
        end
        markdown = markdown .. "\n*" .. allianceText .. "*\n"
    else
        -- GitHub/VSCode: Character name with title as main header
        markdown = markdown .. "# " .. nameWithTitle .. "\n\n"
    end
    
    return markdown
end

-- =====================================================
-- QUICK STATS (CONSOLIDATED)
-- =====================================================

local function GenerateQuickStats(characterData, progressionData, currencyData, equipmentData, cpData, inventoryData, format)
    InitializeUtilities()
    
    local markdown = ""
    
    markdown = markdown .. "## 🎯 Quick Stats\n\n"
    
    -- Determine primary role based on attributes
    local attrs = characterData.attributes or {magicka = 0, health = 0, stamina = 0}
    local primaryRole = "Balanced"
    if attrs.magicka > attrs.stamina and attrs.magicka > attrs.health then
        primaryRole = "Magicka DPS"
    elseif attrs.stamina > attrs.magicka and attrs.stamina > attrs.health then
        primaryRole = "Stamina DPS"
    elseif attrs.health > attrs.magicka and attrs.health > attrs.stamina then
        primaryRole = "Tank"
    end
    
    -- Get primary sets
    local primarySets = "None"
    if equipmentData.sets and #equipmentData.sets > 0 then
        local setParts = {}
        for i = 1, math.min(2, #equipmentData.sets) do
            local set = equipmentData.sets[i]
            if set.count >= 5 then
                table.insert(setParts, set.name)
            end
        end
        if #setParts > 0 then
            primarySets = table.concat(setParts, " • ")
        else
            primarySets = equipmentData.sets[1].name .. " (Partial)"
        end
    end
    
    -- Bank status
    local bankStatus = "OK"
    if inventoryData and inventoryData.bankPercent >= 100 then
        bankStatus = "⚠️ FULL"
    elseif inventoryData and inventoryData.bankPercent >= 90 then
        bankStatus = "⚠️ Nearly Full"
    end
    
    -- CP available and tree breakdown
    local cpAvailable = ""
    local cpBreakdown = ""
    if cpData.total and cpData.spent then
        local available = cpData.total - cpData.spent
        if available > 0 then
            cpAvailable = " (" .. available .. " available)"
        end
    end
    
    -- Add tree breakdown if disciplines are available
    if cpData and cpData.disciplines and #cpData.disciplines > 0 then
        local craftTotal = 0
        local warfareTotal = 0
        local fitnessTotal = 0
        
        -- Extract totals for each discipline
        for _, discipline in ipairs(cpData.disciplines) do
            if discipline.name == "Craft" then
                craftTotal = discipline.total or 0
            elseif discipline.name == "Warfare" then
                warfareTotal = discipline.total or 0
            elseif discipline.name == "Fitness" then
                fitnessTotal = discipline.total or 0
            end
        end
        
        cpBreakdown = " (" .. craftTotal .. "/" .. warfareTotal .. "/" .. fitnessTotal .. ")"
    end
    
    -- Skill points status
    local skillPointStatus = (progressionData.skillPoints or 0)
    if progressionData.skillPoints and progressionData.skillPoints > 0 then
        skillPointStatus = skillPointStatus .. " available"
    else
        skillPointStatus = skillPointStatus .. " ✅"
    end
    
    -- Consolidated single table
    markdown = markdown .. "| Attribute | Value |\n"
    markdown = markdown .. "|:----------|:------|\n"
    markdown = markdown .. "| **Build** | " .. primaryRole .. " |\n"
    markdown = markdown .. "| **CP** | " .. FormatNumber(cpData.total or 0) .. cpBreakdown .. cpAvailable .. " |\n"
    markdown = markdown .. "| **Gold** | " .. FormatNumber(currencyData.gold) .. " |\n"
    markdown = markdown .. "| **Sets** | " .. primarySets .. " |\n"
    markdown = markdown .. "| **Bank** | " .. bankStatus .. " |\n"
    markdown = markdown .. "| **Skill Points** | " .. skillPointStatus .. " |\n"
    markdown = markdown .. "| **Attributes** | " .. attrs.magicka .. " / " .. attrs.health .. " / " .. attrs.stamina .. " |\n"
    markdown = markdown .. "| **Achievements** | " .. (progressionData.achievementPercent or 0) .. "% |\n"
    markdown = markdown .. "| **Transmutes** | " .. FormatNumber(currencyData.transmuteCrystals or 0) .. " |\n"
    
    markdown = markdown .. "\n"
    return markdown
end

-- =====================================================
-- ATTENTION NEEDED (WITH COMPANION WARNINGS)
-- =====================================================

local function GenerateAttentionNeeded(progressionData, inventoryData, ridingData, companionData, format)
    InitializeUtilities()
    
    local warnings = {}
    
    -- Check for skill points
    if progressionData.skillPoints and progressionData.skillPoints > 0 then
        local plural = Pluralize(progressionData.skillPoints, "point", "points")
        table.insert(warnings, "🎯 **" .. progressionData.skillPoints .. " skill " .. plural .. " available** - Ready to spend")
    end
    
    -- Check for attribute points
    if progressionData.attributePoints and progressionData.attributePoints > 0 then
        local plural = Pluralize(progressionData.attributePoints, "point", "points")
        table.insert(warnings, "⭐ **" .. progressionData.attributePoints .. " attribute " .. plural .. " available** - Allocate to Magicka/Health/Stamina")
    end
    
    -- Check for bank capacity
    if inventoryData and inventoryData.bankPercent >= 100 then
        table.insert(warnings, "🏦 **Bank is full** (" .. inventoryData.bankUsed .. "/" .. inventoryData.bankMax .. ") - Clear space or items will be lost")
    elseif inventoryData and inventoryData.bankPercent >= 95 then
        table.insert(warnings, "🏦 **Bank nearly full** (" .. inventoryData.bankUsed .. "/" .. inventoryData.bankMax .. ") - " .. (inventoryData.bankMax - inventoryData.bankUsed) .. " slots remaining")
    end
    
    -- Check for backpack capacity
    if inventoryData and inventoryData.backpackPercent >= 95 then
        table.insert(warnings, "🎒 **Backpack nearly full** (" .. inventoryData.backpackUsed .. "/" .. inventoryData.backpackMax .. ") - " .. (inventoryData.backpackMax - inventoryData.backpackUsed) .. " slots remaining")
    end
    
    -- Check for riding training
    if ridingData and ridingData.trainingAvailable and not ridingData.allMaxed then
        table.insert(warnings, "🐎 **Riding training available** - Visit a stable master")
    end
    
    -- Check companion status (MOVED FROM COMPANION SECTION)
    if companionData and companionData.active then
        local level = companionData.level or 0
        local lowLevelGear = 0
        local emptySlots = 0
        local totalSlots = 0
        
        -- Check equipment level
        if companionData.equipment and #companionData.equipment > 0 then
            for _, item in ipairs(companionData.equipment) do
                if item.level and item.level < level and item.level < 20 then
                    lowLevelGear = lowLevelGear + 1
                end
            end
        end
        
        -- Check for empty ability slots
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
        
        -- Add companion warnings
        if level < 20 then
            table.insert(warnings, "👥 **Companion underleveled**: " .. companionData.name .. " (Level " .. level .. "/20) - Needs XP")
        end
        if lowLevelGear > 0 then
            local plural = Pluralize(lowLevelGear, "piece")
            table.insert(warnings, "👥 **Companion outdated gear**: " .. lowLevelGear .. " " .. plural .. " below level - Upgrade equipment")
        end
        if emptySlots > 0 then
            local plural = Pluralize(emptySlots, "slot")
            table.insert(warnings, "👥 **Companion empty ability " .. plural .. "**: " .. emptySlots .. " - Assign abilities")
        end
    end
    
    -- Only show section if there are warnings
    if #warnings == 0 then
        return ""
    end
    
    local markdown = ""
    markdown = markdown .. "## ⚠️ Attention Needed\n\n"
    for _, warning in ipairs(warnings) do
        markdown = markdown .. "- " .. warning .. "\n"
    end
    markdown = markdown .. "\n"
    
    return markdown
end

-- =====================================================
-- OVERVIEW
-- =====================================================

local function GenerateOverview(characterData, roleData, locationData, buffsData, mundusData, ridingData, pvpData, progressionData, settings, format, cpData)
    InitializeUtilities()
    
    local markdown = ""
    
    markdown = markdown .. "## 📊 Character Overview\n\n"
    markdown = markdown .. "| Attribute | Value |\n"
    markdown = markdown .. "|:----------|:------|\n"
    
    -- Level row
    markdown = markdown .. "| **Level** | " .. (characterData.level or 0) .. " |\n"
    
    -- Champion Points row with tree breakdown
    local cpText = FormatNumber(characterData.cp or 0)
    if cpData and cpData.disciplines and #cpData.disciplines > 0 then
        local craftTotal = 0
        local warfareTotal = 0
        local fitnessTotal = 0
        
        -- Extract totals for each discipline
        for _, discipline in ipairs(cpData.disciplines) do
            if discipline.name == "Craft" then
                craftTotal = discipline.total or 0
            elseif discipline.name == "Warfare" then
                warfareTotal = discipline.total or 0
            elseif discipline.name == "Fitness" then
                fitnessTotal = discipline.total or 0
            end
        end
        
        cpText = cpText .. " (" .. craftTotal .. "/" .. warfareTotal .. "/" .. fitnessTotal .. ")"
    end
    markdown = markdown .. "| **Champion Points** | " .. cpText .. " |\n"
    
    -- Class row with link
    local classText = CreateClassLink(characterData.class, format)
    markdown = markdown .. "| **Class** | " .. classText .. " |\n"
    
    -- Race row with link
    local raceText = CreateRaceLink(characterData.race, format)
    markdown = markdown .. "| **Race** | " .. raceText .. " |\n"
    
    -- Alliance row with link
    local allianceText = CreateAllianceLink(characterData.alliance, format)
    markdown = markdown .. "| **Alliance** | " .. allianceText .. " |\n"
    
    -- ESO Plus status
    local esoPlusStatus = characterData.esoPlus and "✅ Active" or "❌ Inactive"
    markdown = markdown .. "| **ESO Plus** | " .. esoPlusStatus .. " |\n"
    
    -- Attributes row
    if settings.includeAttributes ~= false and characterData.attributes then
        markdown = markdown .. "| **🎯 Attributes** | Magicka: " .. characterData.attributes.magicka .. 
                              " • Health: " .. characterData.attributes.health ..
                              " • Stamina: " .. characterData.attributes.stamina .. " |\n"
    end
    
    -- Mundus Stone row
    if mundusData and mundusData.active then
        local mundusText = CreateMundusLink(mundusData.name, format)
        markdown = markdown .. "| **🪨 Mundus Stone** | " .. mundusText .. " |\n"
    end
    
    -- Active Buffs row
    if settings.includeBuffs ~= false and buffsData and (buffsData.food or buffsData.potion or #buffsData.other > 0) then
        local buffParts = {}
        if buffsData.food then
            local foodLink = CreateBuffLink(buffsData.food, format)
            table.insert(buffParts, "Food: " .. foodLink)
        end
        if buffsData.potion then
            local potionLink = CreateBuffLink(buffsData.potion, format)
            table.insert(buffParts, "Potion: " .. potionLink)
        end
        if #buffsData.other > 0 then
            local otherBuffs = {}
            for _, buff in ipairs(buffsData.other) do
                local buffLink = CreateBuffLink(buff, format)
                table.insert(otherBuffs, buffLink)
            end
            table.insert(buffParts, "Other: " .. table.concat(otherBuffs, ", "))
        end
        markdown = markdown .. "| **🍖 Active Buffs** | " .. table.concat(buffParts, " • ") .. " |\n"
    end
    
    -- Vampire status (if vampire)
    if progressionData and progressionData.isVampire then
        markdown = markdown .. "| **🧛 Vampire** | Stage " .. (progressionData.vampireStage or 1) .. " |\n"
    end
    
    -- Werewolf status (if werewolf)
    if progressionData and progressionData.isWerewolf then
        markdown = markdown .. "| **🐺 Werewolf** | Active |\n"
    end
    
    -- Enlightenment (if active)
    if progressionData and progressionData.enlightenment and progressionData.enlightenment.max > 0 then
        markdown = markdown .. "| **✨ Enlightenment** | " .. FormatNumber(progressionData.enlightenment.current) .. 
                              " / " .. FormatNumber(progressionData.enlightenment.max) .. 
                              " (" .. progressionData.enlightenment.percent .. "%) |\n"
    end
    
    -- Location row
    if settings.includeLocation ~= false and locationData then
        local zoneText = CreateZoneLink(locationData.zone, format)
        markdown = markdown .. "| **Location** | " .. zoneText .. " |\n"
    end
    
    markdown = markdown .. "\n"
    
    return markdown
end

-- =====================================================
-- PROGRESSION
-- =====================================================

local function GenerateProgression(progressionData, format)
    InitializeUtilities()
    
    local markdown = ""
    
    if not progressionData then
        return ""
    end
    
    -- Show progression data including achievements
    if format == "discord" then
        markdown = markdown .. "**Progression:**\n"
        if progressionData.achievementPoints and progressionData.achievementPoints > 0 then
            markdown = markdown .. "• 🏆 Achievement Points: " .. FormatNumber(progressionData.achievementPoints) .. "\n"
        end
        if progressionData.isVampire then
            markdown = markdown .. "• 🧛 Vampire (Stage " .. progressionData.vampireStage .. ")\n"
        end
        if progressionData.isWerewolf then
            markdown = markdown .. "• 🐺 Werewolf\n"
        end
        if progressionData.enlightenment and progressionData.enlightenment.max > 0 then
            markdown = markdown .. "• ✨ Enlightenment: " .. FormatNumber(progressionData.enlightenment.current) .. 
                                  " / " .. FormatNumber(progressionData.enlightenment.max) .. 
                                  " (" .. progressionData.enlightenment.percent .. "%)\n"
        end
        markdown = markdown .. "\n"
    else
        markdown = markdown .. "## 📈 Progression\n\n"
        markdown = markdown .. "| Category | Value |\n"
        markdown = markdown .. "|:---------|:------|\n"
        if progressionData.achievementPoints and progressionData.achievementPoints > 0 then
            markdown = markdown .. "| **🏆 Achievement Points** | " .. FormatNumber(progressionData.achievementPoints) .. " |\n"
        end
        if progressionData.isVampire then
            markdown = markdown .. "| **🧛 Vampire** | Stage " .. progressionData.vampireStage .. " |\n"
        end
        if progressionData.isWerewolf then
            markdown = markdown .. "| **🐺 Werewolf** | Active |\n"
        end
        if progressionData.enlightenment and progressionData.enlightenment.max > 0 then
            markdown = markdown .. "| **✨ Enlightenment** | " .. FormatNumber(progressionData.enlightenment.current) .. 
                                  " / " .. FormatNumber(progressionData.enlightenment.max) .. 
                                  " (" .. progressionData.enlightenment.percent .. "%) |\n"
        end
        markdown = markdown .. "\n"
    end
    
    return markdown
end

-- =====================================================
-- CUSTOM NOTES
-- =====================================================

local function GenerateCustomNotes(customNotes, format)
    local markdown = ""
    
    if format == "discord" then
        markdown = markdown .. "**Notes:** " .. customNotes .. "\n\n"
    else
        markdown = markdown .. "### 📝 Build Notes\n\n"
        markdown = markdown .. customNotes .. "\n\n"
    end
    
    return markdown
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.generators.sections = CM.generators.sections or {}
CM.generators.sections.GenerateQuickSummary = GenerateQuickSummary
CM.generators.sections.GenerateHeader = GenerateHeader
CM.generators.sections.GenerateQuickStats = GenerateQuickStats
CM.generators.sections.GenerateAttentionNeeded = GenerateAttentionNeeded
CM.generators.sections.GenerateOverview = GenerateOverview
CM.generators.sections.GenerateProgression = GenerateProgression
CM.generators.sections.GenerateCustomNotes = GenerateCustomNotes
