-- CharacterMarkdown - Markdown Generation Engine
-- Generates markdown in multiple formats (GitHub, VSCode, Discord, Quick)

local CM = CharacterMarkdown

-- Cache for utility functions (lazy-initialized on first use)
local CreateAbilityLink, CreateSetLink, CreateRaceLink, CreateClassLink
local CreateAllianceLink, CreateMundusLink, CreateCPSkillLink, CreateSkillLineLink
local CreateCompanionLink, CreateZoneLink, CreateCampaignLink, CreateBuffLink
local FormatNumber

-- Forward declarations for section generators (defined later in file)
local GenerateQuickSummary, GenerateHeader, GenerateQuickStats, GenerateAttentionNeeded
local GenerateOverview, GenerateProgression
local GenerateCurrency, GenerateRidingSkills, GenerateInventory, GeneratePvP
local GenerateCollectibles, GenerateCrafting, GenerateAttributes, GenerateBuffs
local GenerateCustomNotes, GenerateDLCAccess, GenerateMundus, GenerateChampionPoints
local GenerateSkillBars, GenerateCombatStats, GenerateEquipment, GenerateSkills
local GenerateCompanion, GenerateFooter

-- =====================================================
-- HELPER FUNCTIONS
-- =====================================================

-- Generate a text-based progress bar
local function GenerateProgressBar(percent, width)
    width = width or 10
    local filled = math.floor((percent / 100) * width)
    local empty = width - filled
    return string.rep("█", filled) .. string.rep("░", empty)
end

-- Create a compact skill status indicator
local function GetSkillStatusEmoji(rank, progress)
    if rank >= 50 or progress >= 100 then
        return "✅"
    elseif rank >= 40 or progress >= 80 then
        return "🔶"
    elseif rank >= 20 or progress >= 40 then
        return "📈"
    else
        return "🔰"
    end
end

-- Format plural correctly
local function Pluralize(count, singular, plural)
    plural = plural or (singular .. "s")
    return count == 1 and singular or plural
end

-- =====================================================
-- SECTION GENERATOR IMPLEMENTATIONS
-- =====================================================

-- Note: These are assigned to the forward-declared variables above
-- This allows them to be called from GenerateMarkdown() before their full definitions

GenerateQuickSummary = function(characterData, equipmentData)
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

GenerateHeader = function(characterData, cpData, format)
    local markdown = ""
    
    if format == "discord" then
        markdown = markdown .. "# **" .. (characterData.name or "Unknown") .. "**\n"
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
        markdown = markdown .. "# " .. (characterData.name or "Unknown") .. "\n\n"
        local raceText = CreateRaceLink(characterData.race, format)
        local classText = CreateClassLink(characterData.class, format)
        local allianceText = CreateAllianceLink(characterData.alliance, format)
        markdown = markdown .. "**" .. raceText .. " " .. classText .. "**  \n"
        
        -- Build CP line with discipline breakdown
        local cpLine = "**Level " .. (characterData.level or 0) .. "** • **CP " .. FormatNumber(characterData.cp or 0) .. "**"
        if cpData and cpData.disciplines and #cpData.disciplines > 0 then
            local disciplineParts = {}
            for _, discipline in ipairs(cpData.disciplines) do
                table.insert(disciplineParts, discipline.name .. " " .. discipline.total)
            end
            cpLine = cpLine .. " (" .. table.concat(disciplineParts, " • ") .. ")"
        end
        markdown = markdown .. cpLine .. "  \n"
        
        markdown = markdown .. "*" .. allianceText .. "*\n\n"
        markdown = markdown .. "---\n\n"
    end
    
    return markdown
end

GenerateQuickStats = function(characterData, progressionData, currencyData, equipmentData, cpData, inventoryData, format)
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
            primarySets = table.concat(setParts, " + ")
        else
            primarySets = equipmentData.sets[1].name .. " (Partial)"
        end
    end
    
    -- Check for bank capacity warning
    local bankStatus = "OK"
    if inventoryData and inventoryData.bankPercent >= 100 then
        bankStatus = "⚠️ **FULL**"
    elseif inventoryData and inventoryData.bankPercent >= 90 then
        bankStatus = "⚠️ Nearly Full"
    end
    
    markdown = markdown .. "| Combat | Progression | Economy |\n"
    markdown = markdown .. "|:-------|:------------|:--------|\n"
    markdown = markdown .. "| **Build**: " .. primaryRole .. " | "
    markdown = markdown .. "**CP**: " .. FormatNumber(cpData.total or 0)
    if cpData.total and cpData.spent then
        local available = cpData.total - cpData.spent
        if available > 0 then
            markdown = markdown .. " (" .. available .. " available)"
        end
    end
    markdown = markdown .. " | "
    markdown = markdown .. "**Gold**: " .. FormatNumber(currencyData.gold) .. " |\n"
    
    markdown = markdown .. "| **Primary Sets**: " .. primarySets .. " | "
    markdown = markdown .. "**Skill Points**: " .. (progressionData.skillPoints or 0) 
    if progressionData.skillPoints and progressionData.skillPoints > 0 then
        markdown = markdown .. " available"
    else
        markdown = markdown .. " ✅"
    end
    markdown = markdown .. " | "
    markdown = markdown .. "**Bank**: " .. bankStatus .. " |\n"
    
    markdown = markdown .. "| **Attributes**: " .. attrs.magicka .. " / " .. attrs.health .. " / " .. attrs.stamina .. " | "
    markdown = markdown .. "**Achievements**: " .. (progressionData.achievementPercent or 0) .. "% | "
    markdown = markdown .. "**Transmutes**: " .. FormatNumber(currencyData.transmuteCrystals or 0) .. " |\n"
    
    markdown = markdown .. "\n"
    return markdown
end

GenerateAttentionNeeded = function(progressionData, inventoryData, ridingData, format)
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

GenerateOverview = function(characterData, roleData, locationData, buffsData, mundusData, ridingData, pvpData, settings, format)
    local markdown = ""
    
    markdown = markdown .. "## 📊 Character Overview\n\n"
    markdown = markdown .. "| Attribute | Value |\n"
    markdown = markdown .. "|:----------|:------|\n"
    local raceText = CreateRaceLink(characterData.race, format)
    local classText = CreateClassLink(characterData.class, format)
    local allianceText = CreateAllianceLink(characterData.alliance, format)
    markdown = markdown .. "| **Race** | " .. raceText .. " |\n"
    markdown = markdown .. "| **Class** | " .. classText .. " |\n"
    markdown = markdown .. "| **Alliance** | " .. allianceText .. " |\n"
    markdown = markdown .. "| **Level** | " .. (characterData.level or 0) .. " |\n"
    markdown = markdown .. "| **Champion Points** | " .. FormatNumber(characterData.cp or 0) .. " |\n"
    
    -- ESO Plus status
    local esoPlusStatus = characterData.esoPlus and "✅ Active" or "❌ Inactive"
    markdown = markdown .. "| **ESO Plus** | " .. esoPlusStatus .. " |\n"
    
    if characterData.title and characterData.title ~= "" then
        markdown = markdown .. "| **Title** | *" .. characterData.title .. "* |\n"
    end
    
    -- Role
    if settings.includeRole ~= false and roleData and roleData.selected ~= "None" then
        markdown = markdown .. "| **Role** | " .. roleData.emoji .. " " .. roleData.selected .. " |\n"
    end
    
    -- Location
    if settings.includeLocation ~= false and locationData then
        local zoneText = CreateZoneLink(locationData.zone, format)
        markdown = markdown .. "| **Location** | " .. zoneText .. " |\n"
    end
    
    -- Attributes
    if settings.includeAttributes ~= false and characterData.attributes then
        markdown = markdown .. "| **🎯 Attributes** | Magicka: " .. characterData.attributes.magicka .. 
                              " • Health: " .. characterData.attributes.health ..
                              " • Stamina: " .. characterData.attributes.stamina .. " |\n"
    end
    
    -- Active Buffs
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
            table.insert(buffParts, table.concat(otherBuffs, ", "))
        end
        markdown = markdown .. "| **🍖 Active Buffs** | " .. table.concat(buffParts, " • ") .. " |\n"
    end
    
    -- Riding Skills
    if settings.includeRidingSkills ~= false and ridingData then
        local ridingParts = {}
        table.insert(ridingParts, "Speed: " .. ridingData.speed .. "/60" .. (ridingData.speed >= 60 and " ✅" or ""))
        table.insert(ridingParts, "Stamina: " .. ridingData.stamina .. "/60" .. (ridingData.stamina >= 60 and " ✅" or ""))
        table.insert(ridingParts, "Capacity: " .. ridingData.capacity .. "/60" .. (ridingData.capacity >= 60 and " ✅" or ""))
        markdown = markdown .. "| **🐎 Riding** | " .. table.concat(ridingParts, " • ") .. " |\n"
    end
    
    -- PvP
    if settings.includePvP ~= false and pvpData then
        markdown = markdown .. "| **⚔️ Alliance War Rank** | " .. pvpData.rankName .. " (Rank " .. pvpData.rank .. ") |\n"
    end
    
    markdown = markdown .. "\n"
    
    return markdown
end

GenerateProgression = function(progressionData, format)
    local markdown = ""
    
    if format == "discord" then
        markdown = markdown .. "**Progression:**\n"
        if progressionData.skillPoints > 0 then
            markdown = markdown .. "• Skill Points Available: " .. progressionData.skillPoints .. "\n"
        end
        if progressionData.attributePoints > 0 then
            markdown = markdown .. "• Attribute Points Available: " .. progressionData.attributePoints .. "\n"
        end
        markdown = markdown .. "• Achievement Score: " .. FormatNumber(progressionData.achievementPoints) .. 
                              " / " .. FormatNumber(progressionData.totalAchievements) .. 
                              " (" .. progressionData.achievementPercent .. "%)\n"
        if progressionData.isVampire then
            markdown = markdown .. "• 🧛 Vampire (Stage " .. progressionData.vampireStage .. ")\n"
        end
        if progressionData.isWerewolf then
            markdown = markdown .. "• 🐺 Werewolf\n"
        end
        if progressionData.enlightenment.max > 0 then
            markdown = markdown .. "• Enlightenment: " .. FormatNumber(progressionData.enlightenment.current) .. 
                                  " / " .. FormatNumber(progressionData.enlightenment.max) .. 
                                  " (" .. progressionData.enlightenment.percent .. "%)\n"
        end
        markdown = markdown .. "\n"
    else
        markdown = markdown .. "## 📈 Character Progression\n\n"
        markdown = markdown .. "| Category | Value |\n"
        markdown = markdown .. "|:---------|:------|\n"
        if progressionData.skillPoints > 0 then
            markdown = markdown .. "| **⭐ Skill Points Available** | " .. progressionData.skillPoints .. " |\n"
        end
        if progressionData.attributePoints > 0 then
            markdown = markdown .. "| **⭐ Attribute Points Available** | " .. progressionData.attributePoints .. " |\n"
        end
        markdown = markdown .. "| **🏆 Achievement Score** | " .. FormatNumber(progressionData.achievementPoints) .. 
                              " / " .. FormatNumber(progressionData.totalAchievements) .. 
                              " (" .. progressionData.achievementPercent .. "%) |\n"
        if progressionData.isVampire then
            markdown = markdown .. "| **🧛 Vampire** | Stage " .. progressionData.vampireStage .. " |\n"
        end
        if progressionData.isWerewolf then
            markdown = markdown .. "| **🐺 Werewolf** | Active |\n"
        end
        if progressionData.enlightenment.max > 0 then
            markdown = markdown .. "| **✨ Enlightenment** | " .. FormatNumber(progressionData.enlightenment.current) .. 
                                  " / " .. FormatNumber(progressionData.enlightenment.max) .. 
                                  " (" .. progressionData.enlightenment.percent .. "%) |\n"
        end
        markdown = markdown .. "\n"
    end
    
    return markdown
end

GenerateCurrency = function(currencyData, format)
    local markdown = ""
    
    if format == "discord" then
        markdown = markdown .. "**Currency:**\n"
        markdown = markdown .. "• Gold: " .. FormatNumber(currencyData.gold) .. "\n"
        if currencyData.alliancePoints > 0 then
            markdown = markdown .. "• AP: " .. FormatNumber(currencyData.alliancePoints) .. "\n"
        end
        if currencyData.telVar > 0 then
            markdown = markdown .. "• Tel Var: " .. FormatNumber(currencyData.telVar) .. "\n"
        end
        if currencyData.transmuteCrystals > 0 then
            markdown = markdown .. "• Transmutes: " .. FormatNumber(currencyData.transmuteCrystals) .. "\n"
        end
        if currencyData.writs > 0 then
            markdown = markdown .. "• Writs: " .. FormatNumber(currencyData.writs) .. "\n"
        end
        if currencyData.eventTickets > 0 then
            markdown = markdown .. "• Event Tickets: " .. FormatNumber(currencyData.eventTickets) .. "\n"
        end
        if currencyData.undauntedKeys > 0 then
            markdown = markdown .. "• Undaunted Keys: " .. FormatNumber(currencyData.undauntedKeys) .. "\n"
        end
        markdown = markdown .. "\n"
    else
        markdown = markdown .. "## 💰 Currency & Resources\n\n"
        markdown = markdown .. "| Currency | Amount |\n"
        markdown = markdown .. "|:---------|-------:|\n"
        markdown = markdown .. "| **💰 Gold** | " .. FormatNumber(currencyData.gold) .. " |\n"
        if currencyData.alliancePoints > 0 then
            markdown = markdown .. "| **⚔️ Alliance Points** | " .. FormatNumber(currencyData.alliancePoints) .. " |\n"
        end
        if currencyData.telVar > 0 then
            markdown = markdown .. "| **🔷 Tel Var Stones** | " .. FormatNumber(currencyData.telVar) .. " |\n"
        end
        if currencyData.transmuteCrystals > 0 then
            markdown = markdown .. "| **💎 Transmute Crystals** | " .. FormatNumber(currencyData.transmuteCrystals) .. " |\n"
        end
        if currencyData.writs > 0 then
            markdown = markdown .. "| **📜 Writ Vouchers** | " .. FormatNumber(currencyData.writs) .. " |\n"
        end
        if currencyData.eventTickets > 0 then
            markdown = markdown .. "| **🎫 Event Tickets** | " .. FormatNumber(currencyData.eventTickets) .. " |\n"
        end
        if currencyData.undauntedKeys > 0 then
            markdown = markdown .. "| **🔑 Undaunted Keys** | " .. FormatNumber(currencyData.undauntedKeys) .. " |\n"
        end
        if currencyData.crowns > 0 then
            markdown = markdown .. "| **👑 Crowns** | " .. FormatNumber(currencyData.crowns) .. " |\n"
        end
        if currencyData.crownGems > 0 then
            markdown = markdown .. "| **💠 Crown Gems** | " .. FormatNumber(currencyData.crownGems) .. " |\n"
        end
        if currencyData.sealsOfEndeavor > 0 then
            markdown = markdown .. "| **🏅 Seals of Endeavor** | " .. FormatNumber(currencyData.sealsOfEndeavor) .. " |\n"
        end
        markdown = markdown .. "\n"
    end
    
    return markdown
end

GenerateRidingSkills = function(ridingData, format)
    local markdown = ""
    
    if format == "discord" then
        markdown = markdown .. "**Riding Skills:**\n"
        markdown = markdown .. "• Speed: " .. ridingData.speed .. "/60"
        if ridingData.speed >= 60 then markdown = markdown .. " ✅" end
        markdown = markdown .. "\n"
        markdown = markdown .. "• Stamina: " .. ridingData.stamina .. "/60"
        if ridingData.stamina >= 60 then markdown = markdown .. " ✅" end
        markdown = markdown .. "\n"
        markdown = markdown .. "• Capacity: " .. ridingData.capacity .. "/60"
        if ridingData.capacity >= 60 then markdown = markdown .. " ✅" end
        markdown = markdown .. "\n"
        if ridingData.allMaxed then
            markdown = markdown .. "✅ All maxed!\n"
        elseif ridingData.trainingAvailable then
            markdown = markdown .. "⚠️ Training available\n"
        end
        markdown = markdown .. "\n"
    else
        markdown = markdown .. "## 🐎 Riding Skills\n\n"
        markdown = markdown .. "| Skill | Progress | Status |\n"
        markdown = markdown .. "|:------|:---------|:-------|\n"
        local speedStatus = ridingData.speed >= 60 and "✅ Maxed" or "📈 Training"
        local staminaStatus = ridingData.stamina >= 60 and "✅ Maxed" or "📈 Training"
        local capacityStatus = ridingData.capacity >= 60 and "✅ Maxed" or "📈 Training"
        markdown = markdown .. "| **Speed** | " .. ridingData.speed .. " / 60 | " .. speedStatus .. " |\n"
        markdown = markdown .. "| **Stamina** | " .. ridingData.stamina .. " / 60 | " .. staminaStatus .. " |\n"
        markdown = markdown .. "| **Capacity** | " .. ridingData.capacity .. " / 60 | " .. capacityStatus .. " |\n"
        markdown = markdown .. "\n"
        if ridingData.allMaxed then
            markdown = markdown .. "✅ **All riding skills maxed!**\n\n"
        elseif ridingData.trainingAvailable then
            markdown = markdown .. "⚠️ **Riding training available now**\n\n"
        end
    end
    
    return markdown
end

-- Lazy initialization of cached references
local function InitializeUtilities()
    if not FormatNumber then
        CreateAbilityLink = CM.links.CreateAbilityLink
        CreateSetLink = CM.links.CreateSetLink
        CreateRaceLink = CM.links.CreateRaceLink
        CreateClassLink = CM.links.CreateClassLink
        CreateAllianceLink = CM.links.CreateAllianceLink
        CreateMundusLink = CM.links.CreateMundusLink
        CreateCPSkillLink = CM.links.CreateCPSkillLink
        CreateSkillLineLink = CM.links.CreateSkillLineLink
        CreateCompanionLink = CM.links.CreateCompanionLink
        CreateZoneLink = CM.links.CreateZoneLink
        CreateCampaignLink = CM.links.CreateCampaignLink
        CreateBuffLink = CM.links.CreateBuffLink
        FormatNumber = CM.utils.FormatNumber
    end
end

-- =====================================================
-- MAIN GENERATION FUNCTION
-- =====================================================

local function GenerateMarkdown(format)
    -- Initialize utility function cache on first call
    InitializeUtilities()
    
    format = format or "github"
    
    -- Verify collectors are loaded
    if not CM.collectors then
        d("[CharacterMarkdown] ❌ FATAL: CM.collectors namespace doesn't exist!")
        d("[CharacterMarkdown] The addon did not load correctly. Try /reloadui")
        return "ERROR: Addon not loaded. Type /reloadui and try again."
    end
    
    -- Check if a critical collector exists (test case)
    if not CM.collectors.CollectCharacterData then
        d("[CharacterMarkdown] ❌ FATAL: Collectors not loaded!")
        d("[CharacterMarkdown] Available in CM.collectors:")
        for k, v in pairs(CM.collectors) do
            d("[CharacterMarkdown]   - " .. k)
        end
        return "ERROR: Collectors not loaded. Type /reloadui and try again."
    end
    
    -- Collect all data with error handling
    local characterData = CM.collectors.CollectCharacterData()
    local dlcData = CM.collectors.CollectDLCAccess()
    local mundusData = CM.collectors.CollectMundusData()
    local buffsData = CM.collectors.CollectActiveBuffs()
    local cpData = CM.collectors.CollectChampionPointData()
    local skillBarData = CM.collectors.CollectSkillBarData()
    local statsData = CM.collectors.CollectCombatStatsData()
    local equipmentData = CM.collectors.CollectEquipmentData()
    local skillData = CM.collectors.CollectSkillProgressionData()
    local companionData = CM.collectors.CollectCompanionData()
    local currencyData = CM.collectors.CollectCurrencyData()
    local progressionData = CM.collectors.CollectProgressionData()
    local ridingData = CM.collectors.CollectRidingSkillsData()
    local inventoryData = CM.collectors.CollectInventoryData()
    local pvpData = CM.collectors.CollectPvPData()
    local roleData = CM.collectors.CollectRoleData()
    local locationData = CM.collectors.CollectLocationData()
    local collectiblesData = CM.collectors.CollectCollectiblesData()
    local craftingData = CM.collectors.CollectCraftingKnowledgeData()
    
    local settings = CharacterMarkdownSettings or {}
    
    -- QUICK FORMAT - one-line summary
    if format == "quick" then
        return GenerateQuickSummary(characterData, equipmentData)
    end
    
    -- FULL FORMATS (GitHub, VSCode, Discord)
    local markdown = ""
    
    -- Header
    markdown = markdown .. GenerateHeader(characterData, cpData, format)
    
    -- Quick Stats Summary (non-Discord only)
    if format ~= "discord" and settings.includeQuickStats ~= false then
        markdown = markdown .. GenerateQuickStats(characterData, progressionData, currencyData, equipmentData, cpData, inventoryData, format)
    end
    
    -- Attention Needed (non-Discord only)
    if format ~= "discord" and settings.includeAttentionNeeded ~= false then
        markdown = markdown .. GenerateAttentionNeeded(progressionData, inventoryData, ridingData, format)
    end
    
    -- Overview (skip for Discord) - now includes vampire/werewolf/enlightenment
    if format ~= "discord" then
        markdown = markdown .. GenerateOverview(characterData, roleData, locationData, buffsData, mundusData, ridingData, pvpData, progressionData, settings, format)
    end
    
    -- Currency
    if settings.includeCurrency ~= false then
        markdown = markdown .. GenerateCurrency(currencyData, format)
    end
    
    -- Riding Skills (Discord only - for other formats it's in Overview table)
    if format == "discord" and settings.includeRidingSkills ~= false then
        markdown = markdown .. GenerateRidingSkills(ridingData, format)
    end
    
    -- Inventory
    if settings.includeInventory ~= false then
        markdown = markdown .. GenerateInventory(inventoryData, format)
    end
    
    -- PvP (Discord only - for other formats it's in Overview table)
    if format == "discord" and settings.includePvP ~= false then
        markdown = markdown .. GeneratePvP(pvpData, format)
    end
    
    -- Collectibles
    if settings.includeCollectibles ~= false then
        markdown = markdown .. GenerateCollectibles(collectiblesData, format)
    end
    
    -- Crafting
    if settings.includeCrafting ~= false then
        markdown = markdown .. GenerateCrafting(craftingData, format)
    end
    
    -- Attributes and Buffs are now in Overview table for non-Discord formats
    -- For Discord format, still generate them as separate sections
    if format == "discord" then
        if settings.includeAttributes ~= false then
            markdown = markdown .. GenerateAttributes(characterData, format)
        end
        if settings.includeBuffs ~= false then
            markdown = markdown .. GenerateBuffs(buffsData, format)
        end
    end
    
    -- Custom Notes
    local customNotes = CharacterMarkdownData and CharacterMarkdownData.customNotes or ""
    if customNotes and customNotes ~= "" then
        markdown = markdown .. GenerateCustomNotes(customNotes, format)
    end
    
    if format ~= "discord" then
        markdown = markdown .. "---\n\n"
    end
    
    -- DLC Access
    if settings.includeDLCAccess ~= false then
        markdown = markdown .. GenerateDLCAccess(dlcData, format)
    end
    
    -- Mundus (Discord only - for other formats it's in Overview table)
    if format == "discord" then
        markdown = markdown .. GenerateMundus(mundusData, format)
    end
    
    -- Champion Points
    if settings.includeChampionPoints ~= false then
        markdown = markdown .. GenerateChampionPoints(cpData, format)
    end
    
    -- Skill Bars
    if settings.includeSkillBars ~= false then
        markdown = markdown .. GenerateSkillBars(skillBarData, format)
    end
    
    -- Combat Stats
    if settings.includeCombatStats ~= false then
        markdown = markdown .. GenerateCombatStats(statsData, format)
    end
    
    -- Equipment
    if settings.includeEquipment ~= false then
        markdown = markdown .. GenerateEquipment(equipmentData, format)
    end
    
    -- Skills
    if settings.includeSkills ~= false then
        markdown = markdown .. GenerateSkills(skillData, format)
    end
    
    -- Companion
    if settings.includeCompanion ~= false and companionData.active then
        markdown = markdown .. GenerateCompanion(companionData, format)
    end
    
    -- Footer
    markdown = markdown .. GenerateFooter(format, string.len(markdown))
    
    return markdown
end

CM.generators.GenerateMarkdown = GenerateMarkdown

-- =====================================================
-- SECTION GENERATORS
-- =====================================================

function GenerateQuickSummary(characterData, equipmentData)
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

function GenerateHeader(characterData, cpData, format)
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

function GenerateOverview(characterData, roleData, locationData, buffsData, mundusData, ridingData, pvpData, progressionData, settings, format)
    local markdown = ""
    
    markdown = markdown .. "## 📊 Character Overview\n\n"
    markdown = markdown .. "| Attribute | Value |\n"
    markdown = markdown .. "|:----------|:------|\n"
    
    -- Level row
    markdown = markdown .. "| **Level** | " .. (characterData.level or 0) .. " |\n"
    
    -- Champion Points row
    markdown = markdown .. "| **Champion Points** | " .. FormatNumber(characterData.cp or 0) .. " |\n"
    
    -- Class row with link
    local classText = CreateClassLink(characterData.class, format)
    markdown = markdown .. "| **Class** | " .. classText .. " |\n"
    
    -- Race row with link
    local raceText = CreateRaceLink(characterData.race, format)
    markdown = markdown .. "| **Race** | " .. raceText .. " |\n"
    
    -- Alliance row with link
    local allianceText = CreateAllianceLink(characterData.alliance, format)
    markdown = markdown .. "| **Alliance** | " .. allianceText .. " |\n"
    
    -- ESO Plus status (Title is now in header, so removed from here)
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

function GenerateProgression(progressionData, format)
    local markdown = ""
    
    -- Only show unique data not covered in Quick Stats/Attention Needed
    -- (Skill points, attribute points, and achievements are now handled elsewhere)
    
    if format == "discord" then
        markdown = markdown .. "**Character Status:**\n"
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
        markdown = markdown .. "## 🌙 Character Status\n\n"
        markdown = markdown .. "| Category | Value |\n"
        markdown = markdown .. "|:---------|:------|\n"
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

function GenerateCurrency(currencyData, format)
    local markdown = ""
    
    if format == "discord" then
        markdown = markdown .. "**Currency:**\n"
        markdown = markdown .. "• Gold: " .. FormatNumber(currencyData.gold) .. "\n"
        if currencyData.alliancePoints > 0 then
            markdown = markdown .. "• AP: " .. FormatNumber(currencyData.alliancePoints) .. "\n"
        end
        if currencyData.telVar > 0 then
            markdown = markdown .. "• Tel Var: " .. FormatNumber(currencyData.telVar) .. "\n"
        end
        if currencyData.transmuteCrystals > 0 then
            markdown = markdown .. "• Transmutes: " .. FormatNumber(currencyData.transmuteCrystals) .. "\n"
        end
        if currencyData.writs > 0 then
            markdown = markdown .. "• Writs: " .. FormatNumber(currencyData.writs) .. "\n"
        end
        if currencyData.eventTickets > 0 then
            markdown = markdown .. "• Event Tickets: " .. FormatNumber(currencyData.eventTickets) .. "\n"
        end
        if currencyData.undauntedKeys > 0 then
            markdown = markdown .. "• Undaunted Keys: " .. FormatNumber(currencyData.undauntedKeys) .. "\n"
        end
        markdown = markdown .. "\n"
    else
        markdown = markdown .. "## 💰 Currency & Resources\n\n"
        markdown = markdown .. "| Currency | Amount |\n"
        markdown = markdown .. "|:---------|-------:|\n"
        markdown = markdown .. "| **💰 Gold** | " .. FormatNumber(currencyData.gold) .. " |\n"
        if currencyData.alliancePoints > 0 then
            markdown = markdown .. "| **⚔️ Alliance Points** | " .. FormatNumber(currencyData.alliancePoints) .. " |\n"
        end
        if currencyData.telVar > 0 then
            markdown = markdown .. "| **🔷 Tel Var Stones** | " .. FormatNumber(currencyData.telVar) .. " |\n"
        end
        if currencyData.transmuteCrystals > 0 then
            markdown = markdown .. "| **💎 Transmute Crystals** | " .. FormatNumber(currencyData.transmuteCrystals) .. " |\n"
        end
        if currencyData.writs > 0 then
            markdown = markdown .. "| **📜 Writ Vouchers** | " .. FormatNumber(currencyData.writs) .. " |\n"
        end
        if currencyData.eventTickets > 0 then
            markdown = markdown .. "| **🎫 Event Tickets** | " .. FormatNumber(currencyData.eventTickets) .. " |\n"
        end
        if currencyData.undauntedKeys > 0 then
            markdown = markdown .. "| **🔑 Undaunted Keys** | " .. FormatNumber(currencyData.undauntedKeys) .. " |\n"
        end
        if currencyData.crowns > 0 then
            markdown = markdown .. "| **👑 Crowns** | " .. FormatNumber(currencyData.crowns) .. " |\n"
        end
        if currencyData.crownGems > 0 then
            markdown = markdown .. "| **💠 Crown Gems** | " .. FormatNumber(currencyData.crownGems) .. " |\n"
        end
        if currencyData.sealsOfEndeavor > 0 then
            markdown = markdown .. "| **🏅 Seals of Endeavor** | " .. FormatNumber(currencyData.sealsOfEndeavor) .. " |\n"
        end
        markdown = markdown .. "\n"
    end
    
    return markdown
end

function GenerateRidingSkills(ridingData, format)
    local markdown = ""
    
    if format == "discord" then
        markdown = markdown .. "**Riding Skills:**\n"
        markdown = markdown .. "• Speed: " .. ridingData.speed .. "/60"
        if ridingData.speed >= 60 then markdown = markdown .. " ✅" end
        markdown = markdown .. "\n"
        markdown = markdown .. "• Stamina: " .. ridingData.stamina .. "/60"
        if ridingData.stamina >= 60 then markdown = markdown .. " ✅" end
        markdown = markdown .. "\n"
        markdown = markdown .. "• Capacity: " .. ridingData.capacity .. "/60"
        if ridingData.capacity >= 60 then markdown = markdown .. " ✅" end
        markdown = markdown .. "\n"
        if ridingData.allMaxed then
            markdown = markdown .. "✅ All maxed!\n"
        elseif ridingData.trainingAvailable then
            markdown = markdown .. "⚠️ Training available\n"
        end
        markdown = markdown .. "\n"
    else
        markdown = markdown .. "## 🐎 Riding Skills\n\n"
        markdown = markdown .. "| Skill | Progress | Status |\n"
        markdown = markdown .. "|:------|:---------|:-------|\n"
        local speedStatus = ridingData.speed >= 60 and "✅ Maxed" or "📈 Training"
        local staminaStatus = ridingData.stamina >= 60 and "✅ Maxed" or "📈 Training"
        local capacityStatus = ridingData.capacity >= 60 and "✅ Maxed" or "📈 Training"
        markdown = markdown .. "| **Speed** | " .. ridingData.speed .. " / 60 | " .. speedStatus .. " |\n"
        markdown = markdown .. "| **Stamina** | " .. ridingData.stamina .. " / 60 | " .. staminaStatus .. " |\n"
        markdown = markdown .. "| **Capacity** | " .. ridingData.capacity .. " / 60 | " .. capacityStatus .. " |\n"
        markdown = markdown .. "\n"
        if ridingData.allMaxed then
            markdown = markdown .. "✅ **All riding skills maxed!**\n\n"
        elseif ridingData.trainingAvailable then
            markdown = markdown .. "⚠️ **Riding training available now**\n\n"
        end
    end
    
    return markdown
end

GenerateInventory = function(inventoryData, format)
    local markdown = ""
    
    if format == "discord" then
        markdown = markdown .. "**Inventory:**\n"
        markdown = markdown .. "• Backpack: " .. inventoryData.backpackUsed .. "/" .. inventoryData.backpackMax .. 
                              " (" .. inventoryData.backpackPercent .. "%)\n"
        markdown = markdown .. "• Bank: " .. inventoryData.bankUsed .. "/" .. inventoryData.bankMax .. 
                              " (" .. inventoryData.bankPercent .. "%)\n"
        if inventoryData.hasCraftingBag then
            markdown = markdown .. "• ✅ Crafting Bag (ESO Plus)\n"
        end
        markdown = markdown .. "\n"
    else
        markdown = markdown .. "## 🎒 Inventory\n\n"
        markdown = markdown .. "| Storage | Used | Max | Capacity |\n"
        markdown = markdown .. "|:--------|-----:|----:|---------:|\n"
        markdown = markdown .. "| **Backpack** | " .. inventoryData.backpackUsed .. " | " .. 
                              inventoryData.backpackMax .. " | " .. inventoryData.backpackPercent .. "% |\n"
        markdown = markdown .. "| **Bank** | " .. inventoryData.bankUsed .. " | " .. 
                              inventoryData.bankMax .. " | " .. inventoryData.bankPercent .. "% |\n"
        if inventoryData.hasCraftingBag then
            markdown = markdown .. "| **Crafting Bag** | ∞ | ∞ | ESO Plus |\n"
        end
        markdown = markdown .. "\n"
    end
    
    return markdown
end

GeneratePvP = function(pvpData, format)
    local markdown = ""
    
    if format == "discord" then
        markdown = markdown .. "**PvP:**\n"
        markdown = markdown .. "• Alliance War Rank: " .. pvpData.rankName .. " (Rank " .. pvpData.rank .. ")\n"
        if pvpData.campaignName and pvpData.campaignName ~= "None" then
            local campaignText = CreateCampaignLink(pvpData.campaignName, format)
            markdown = markdown .. "• Campaign: " .. campaignText .. "\n"
        end
        markdown = markdown .. "\n"
    else
        markdown = markdown .. "## ⚔️ PvP Information\n\n"
        markdown = markdown .. "| Category | Value |\n"
        markdown = markdown .. "|:---------|:------|\n"
        markdown = markdown .. "| **Alliance War Rank** | " .. pvpData.rankName .. " (Rank " .. pvpData.rank .. ") |\n"
        if pvpData.campaignName and pvpData.campaignName ~= "None" then
            local campaignText = CreateCampaignLink(pvpData.campaignName, format)
            markdown = markdown .. "| **Current Campaign** | " .. campaignText .. " |\n"
        end
        markdown = markdown .. "\n"
    end
    
    return markdown
end

GenerateCollectibles = function(collectiblesData, format)
    local markdown = ""
    
    -- Check if we have detailed data enabled
    local hasDetailedData = collectiblesData.hasDetailedData
    local settings = CharacterMarkdownSettings or {}
    local includeDetailed = settings.includeCollectiblesDetailed or false
    
    if format == "discord" then
        -- Discord: Always show summary counts only (no detailed lists)
        markdown = markdown .. "**Collectibles:**\n"
        
        if collectiblesData.categories then
            for _, key in ipairs({"mounts", "pets", "costumes", "houses", "emotes", "mementos", "skins", "polymorphs", "personalities"}) do
                local category = collectiblesData.categories[key]
                if category and category.total > 0 then
                    local owned = #category.owned
                    markdown = markdown .. category.emoji .. " " .. category.name .. ": (" .. owned .. " of " .. category.total .. ")\n"
                end
            end
        end
        markdown = markdown .. "\n"
    else
        -- GitHub/VSCode: Show collapsible detailed lists if enabled
        markdown = markdown .. "## 🎨 Collectibles\n\n"
        
        if not includeDetailed or not hasDetailedData then
            -- Fallback: Show simple count table if detailed not enabled
            markdown = markdown .. "| Type | Count |\n"
            markdown = markdown .. "|:-----|------:|\n"
            if collectiblesData.mounts > 0 then
                markdown = markdown .. "| **🐴 Mounts** | " .. collectiblesData.mounts .. " |\n"
            end
            if collectiblesData.pets > 0 then
                markdown = markdown .. "| **🐾 Pets** | " .. collectiblesData.pets .. " |\n"
            end
            if collectiblesData.costumes > 0 then
                markdown = markdown .. "| **👗 Costumes** | " .. collectiblesData.costumes .. " |\n"
            end
            if collectiblesData.houses > 0 then
                markdown = markdown .. "| **🏠 Houses** | " .. collectiblesData.houses .. " |\n"
            end
            markdown = markdown .. "\n"
        else
            -- Detailed mode: Show collapsible sections with (X of Y) format
            if collectiblesData.categories then
                for _, key in ipairs({"mounts", "pets", "costumes", "houses", "emotes", "mementos", "skins", "polymorphs", "personalities"}) do
                    local category = collectiblesData.categories[key]
                    if category and category.total > 0 then
                        local owned = #category.owned
                        
                        -- Collapsible section header
                        markdown = markdown .. "<details>\n"
                        markdown = markdown .. "<summary>" .. category.emoji .. " " .. category.name .. 
                                              " (" .. owned .. " of " .. category.total .. ")</summary>\n\n"
                        
                        -- List owned collectibles (alphabetically sorted)
                        if owned > 0 then
                            for _, collectible in ipairs(category.owned) do
                                markdown = markdown .. "- " .. collectible.name
                                -- Add rarity if available
                                if collectible.quality then
                                    markdown = markdown .. " [" .. collectible.quality .. "]"
                                end
                                markdown = markdown .. "\n"
                            end
                        else
                            markdown = markdown .. "*No " .. category.name:lower() .. " owned*\n"
                        end
                        
                        markdown = markdown .. "</details>\n\n"
                    end
                end
            end
        end
    end
    
    return markdown
end

GenerateCrafting = function(craftingData, format)
    local markdown = ""
    
    -- Only show section if there's data to display
    local hasData = (craftingData.motifs and craftingData.motifs.total > 0) or 
                   (craftingData.activeResearch and craftingData.activeResearch > 0)
    
    if not hasData then
        return ""
    end
    
    if format == "discord" then
        markdown = markdown .. "**Crafting:**\n"
        if craftingData.motifs and craftingData.motifs.total > 0 then
            markdown = markdown .. "• Motifs: " .. craftingData.motifs.known .. "/" .. 
                                  craftingData.motifs.total .. " (" .. craftingData.motifs.percent .. "%)\n"
        end
        if craftingData.activeResearch > 0 then
            markdown = markdown .. "• Active Research: " .. craftingData.activeResearch .. " traits\n"
        end
        markdown = markdown .. "\n"
    else
        markdown = markdown .. "## ⚒️ Crafting Knowledge\n\n"
        markdown = markdown .. "| Category | Progress |\n"
        markdown = markdown .. "|:---------|:---------|\n"
        if craftingData.motifs and craftingData.motifs.total > 0 then
            markdown = markdown .. "| **📖 Motifs (Basic)** | " .. craftingData.motifs.known .. " / " .. 
                                  craftingData.motifs.total .. " (" .. craftingData.motifs.percent .. "%) |\n"
        end
        if craftingData.activeResearch > 0 then
            markdown = markdown .. "| **🔬 Active Research** | " .. craftingData.activeResearch .. " traits |\n"
        end
        markdown = markdown .. "\n"
    end
    
    return markdown
end

GenerateAttributes = function(characterData, format)
    local markdown = ""
    
    if not characterData.attributes then
        return ""
    end
    
    if format == "discord" then
        markdown = markdown .. "```yaml\n"
        markdown = markdown .. "Attributes: Mag " .. characterData.attributes.magicka ..
                              " | HP " .. characterData.attributes.health ..
                              " | Stam " .. characterData.attributes.stamina .. "\n"
        markdown = markdown .. "```\n"
    else
        markdown = markdown .. "### 🎯 Attribute Distribution\n\n"
        markdown = markdown .. "**Magicka:** " .. characterData.attributes.magicka .. 
                              " • **Health:** " .. characterData.attributes.health ..
                              " • **Stamina:** " .. characterData.attributes.stamina .. "\n\n"
    end
    
    return markdown
end

GenerateBuffs = function(buffsData, format)
    local markdown = ""
    
    if not buffsData.food and not buffsData.potion and #buffsData.other == 0 then
        return ""
    end
    
    if format == "discord" then
        markdown = markdown .. "**Buffs:**\n"
        if buffsData.food then 
            local foodLink = CreateBuffLink(buffsData.food, format)
            markdown = markdown .. "• " .. foodLink .. "\n" 
        end
        if buffsData.potion then 
            local potionLink = CreateBuffLink(buffsData.potion, format)
            markdown = markdown .. "• " .. potionLink .. "\n" 
        end
        if #buffsData.other > 0 then
            for _, buff in ipairs(buffsData.other) do
                local buffLink = CreateBuffLink(buff, format)
                markdown = markdown .. "• " .. buffLink .. "\n"
            end
        end
        markdown = markdown .. "\n"
    else
        markdown = markdown .. "### 🍖 Active Buffs\n\n"
        if buffsData.food then
            local foodLink = CreateBuffLink(buffsData.food, format)
            markdown = markdown .. "**Food:** " .. foodLink .. "  \n"
        end
        if buffsData.potion then
            local potionLink = CreateBuffLink(buffsData.potion, format)
            markdown = markdown .. "**Potion:** " .. potionLink .. "  \n"
        end
        if #buffsData.other > 0 then
            local otherBuffs = {}
            for _, buff in ipairs(buffsData.other) do
                local buffLink = CreateBuffLink(buff, format)
                table.insert(otherBuffs, buffLink)
            end
            markdown = markdown .. "**Other:** " .. table.concat(otherBuffs, ", ") .. "  \n"
        end
        markdown = markdown .. "\n"
    end
    
    return markdown
end

GenerateCustomNotes = function(customNotes, format)
    local markdown = ""
    
    if format == "discord" then
        markdown = markdown .. "**Notes:** " .. customNotes .. "\n\n"
    else
        markdown = markdown .. "### 📝 Build Notes\n\n"
        markdown = markdown .. customNotes .. "\n\n"
    end
    
    return markdown
end

GenerateDLCAccess = function(dlcData, format)
    local markdown = ""
    
    if format == "discord" then
        if dlcData.hasESOPlus then
            markdown = markdown .. "**DLC Access:** ESO Plus (All DLCs Available)\n\n"
        elseif #dlcData.accessible > 0 or #dlcData.locked > 0 then
            markdown = markdown .. "**DLC Access:**\n"
            if #dlcData.accessible > 0 then
                for _, dlcName in ipairs(dlcData.accessible) do
                    markdown = markdown .. "✅ " .. dlcName .. "\n"
                end
            end
            if #dlcData.locked > 0 then
                for _, dlcName in ipairs(dlcData.locked) do
                    markdown = markdown .. "🔒 " .. dlcName .. "\n"
                end
            end
            markdown = markdown .. "\n"
        end
    else
        markdown = markdown .. "## 🗺️ DLC & Chapter Access\n\n"
        if dlcData.hasESOPlus then
            markdown = markdown .. "✅ **ESO Plus Active** - All DLCs accessible\n\n"
        end
        
        if #dlcData.accessible > 0 then
            markdown = markdown .. "### ✅ Accessible Content\n\n"
            for _, dlcName in ipairs(dlcData.accessible) do
                markdown = markdown .. "- ✅ " .. dlcName .. "\n"
            end
            markdown = markdown .. "\n"
        end
        
        if #dlcData.locked > 0 and not dlcData.hasESOPlus then
            markdown = markdown .. "### 🔒 Locked Content\n\n"
            for _, dlcName in ipairs(dlcData.locked) do
                markdown = markdown .. "- 🔒 " .. dlcName .. "\n"
            end
            markdown = markdown .. "\n"
        end
        
        markdown = markdown .. "---\n\n"
    end
    
    return markdown
end

GenerateMundus = function(mundusData, format)
    local markdown = ""
    
    if format == "discord" then
        if mundusData.active then
            local mundusText = CreateMundusLink(mundusData.name, format)
            markdown = markdown .. "**Mundus:** " .. mundusText .. "\n\n"
        end
    else
        markdown = markdown .. "## 🪨 Mundus Stone\n\n"
        if mundusData.active then
            local mundusText = CreateMundusLink(mundusData.name, format)
            markdown = markdown .. "✅ **Active:** " .. mundusText .. "\n\n"
        else
            markdown = markdown .. "⚠️ **No Active Mundus Stone**\n\n"
        end
        
        markdown = markdown .. "---\n\n"
    end
    
    return markdown
end

GenerateChampionPoints = function(cpData, format)
    local markdown = ""
    
    local totalCP = cpData.total or 0
    
    if format == "discord" then
        markdown = markdown .. "**Champion Points:**\n"
    else
        markdown = markdown .. "## ⭐ Champion Points\n\n"
    end
    
    if totalCP < 10 then
        markdown = markdown .. "*Champion Point system unlocks at Level 50*\n\n"
    else
        local spentCP = cpData.spent or 0
        local availableCP = totalCP - spentCP
        
        if format == "discord" then
            markdown = markdown .. "Total: " .. FormatNumber(totalCP) .. " | "
            markdown = markdown .. "Spent: " .. FormatNumber(spentCP) .. " | "
            markdown = markdown .. "Available: " .. FormatNumber(availableCP) .. "\n"
            
            if cpData.disciplines and #cpData.disciplines > 0 then
                for _, discipline in ipairs(cpData.disciplines) do
                    markdown = markdown .. (discipline.emoji or "⚔️") .. " **" .. discipline.name .. "** (" .. FormatNumber(discipline.total) .. ")\n"
                    if discipline.skills and #discipline.skills > 0 then
                        for _, skill in ipairs(discipline.skills) do
                            local skillText = CreateCPSkillLink(skill.name, format)
                            markdown = markdown .. "• " .. skillText .. ": " .. skill.points .. "\n"
                        end
                    end
                    markdown = markdown .. "\n"
                end
            end
        else
            -- Compact table format
            markdown = markdown .. "| Category | Value |\n"
            markdown = markdown .. "|:---------|------:|\n"
            markdown = markdown .. "| **Total** | " .. FormatNumber(totalCP) .. " |\n"
            markdown = markdown .. "| **Spent** | " .. FormatNumber(spentCP) .. " |\n"
            if availableCP > 0 then
                markdown = markdown .. "| **Available** | " .. FormatNumber(availableCP) .. " ⚠️ |\n"
            else
                markdown = markdown .. "| **Available** | " .. FormatNumber(availableCP) .. " |\n"
            end
            markdown = markdown .. "\n"
            
            if cpData.disciplines and #cpData.disciplines > 0 then
                -- Calculate max possible points per discipline (CP 3.0 system allows up to 660 per tree)
                local maxPerDiscipline = 660
                
                for _, discipline in ipairs(cpData.disciplines) do
                    local disciplinePercent = math.floor((discipline.total / maxPerDiscipline) * 100)
                    local progressBar = GenerateProgressBar(disciplinePercent, 12)
                    
                    markdown = markdown .. "### " .. (discipline.emoji or "⚔️") .. " " .. discipline.name .. 
                                         " (" .. FormatNumber(discipline.total) .. "/" .. maxPerDiscipline .. " points) " .. 
                                         progressBar .. " " .. disciplinePercent .. "%\n\n"
                    if discipline.skills and #discipline.skills > 0 then
                        for _, skill in ipairs(discipline.skills) do
                            local skillText = CreateCPSkillLink(skill.name, format)
                            local pointText = skill.points == 1 and "point" or "points"
                            markdown = markdown .. "- **" .. skillText .. "**: " .. skill.points .. " " .. pointText .. "\n"
                        end
                        markdown = markdown .. "\n"
                    end
                end
            end
            
            markdown = markdown .. "---\n\n"
        end
    end
    
    return markdown
end

GenerateSkillBars = function(skillBarData, format)
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

GenerateCombatStats = function(statsData, format)
    local markdown = ""
    
    if format == "discord" then
        markdown = markdown .. "\n**Stats:**\n```\n"
        markdown = markdown .. "HP: " .. FormatNumber(statsData.health or 0) .. 
                              " | Mag: " .. FormatNumber(statsData.magicka or 0) ..
                              " | Stam: " .. FormatNumber(statsData.stamina or 0) .. "\n"
        markdown = markdown .. "Weapon: " .. FormatNumber(statsData.weaponPower or 0) ..
                              " | Spell: " .. FormatNumber(statsData.spellPower or 0) .. "\n"
        markdown = markdown .. "Phys Res: " .. FormatNumber(statsData.physicalResist or 0) ..
                              " | Spell Res: " .. FormatNumber(statsData.spellResist or 0) .. "\n"
        markdown = markdown .. "```"
    else
        markdown = markdown .. "---\n\n"
        
        markdown = markdown .. "## 📈 Combat Statistics\n\n"
        markdown = markdown .. "| Category | Stat | Value |\n"
        markdown = markdown .. "|:---------|:-----|------:|\n"
        markdown = markdown .. "| 💚 **Resources** | Health | " .. FormatNumber(statsData.health or 0) .. " |\n"
        markdown = markdown .. "| | Magicka | " .. FormatNumber(statsData.magicka or 0) .. " |\n"
        markdown = markdown .. "| | Stamina | " .. FormatNumber(statsData.stamina or 0) .. " |\n"
        markdown = markdown .. "| ⚔️ **Offensive** | Weapon Power | " .. FormatNumber(statsData.weaponPower or 0) .. " |\n"
        markdown = markdown .. "| | Spell Power | " .. FormatNumber(statsData.spellPower or 0) .. " |\n"
        markdown = markdown .. "| 🛡️ **Defensive** | Physical Resist | " .. FormatNumber(statsData.physicalResist or 0) .. " |\n"
        markdown = markdown .. "| | Spell Resist | " .. FormatNumber(statsData.spellResist or 0) .. " |\n"
        markdown = markdown .. "\n"
        
        markdown = markdown .. "---\n\n"
    end
    
    return markdown
end

GenerateEquipment = function(equipmentData, format)
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

GenerateSkills = function(skillData, format)
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

GenerateCompanion = function(companionData, format)
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

GenerateFooter = function(format, currentLength)
    local markdown = ""
    
    -- Calculate character count for warnings
    local charCount = currentLength + 200  -- Approximate with footer
    
    if format == "github" then
        markdown = markdown .. "<div align=\"center\">\n\n"
        markdown = markdown .. "**Generated by Character Markdown v" .. CM.version .. "**\n\n"
        markdown = markdown .. "*Format: " .. format:upper() .. "*\n\n"
        markdown = markdown .. "</div>\n\n"
    else
        markdown = markdown .. "\n```\n"
        markdown = markdown .. string.rep("━", 80) .. "\n"
        markdown = markdown .. string.rep(" ", 20) .. "Generated by Character Markdown v" .. CM.version .. "\n"
        markdown = markdown .. string.rep(" ", 30) .. "Format: " .. format:upper() .. "\n"
        markdown = markdown .. string.rep("━", 80) .. "\n"
        markdown = markdown .. "```\n\n"
    end
    
    return markdown
end
