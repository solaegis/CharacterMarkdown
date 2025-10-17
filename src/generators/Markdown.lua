-- CharacterMarkdown - Markdown Generation Engine
-- Generates markdown in multiple formats (GitHub, VSCode, Discord, Quick)

local CM = CharacterMarkdown

-- Cache for utility functions (lazy-initialized on first use)
local CreateAbilityLink, CreateSetLink, CreateRaceLink, CreateClassLink
local CreateAllianceLink, CreateMundusLink, CreateCPSkillLink, CreateSkillLineLink
local CreateCompanionLink, CreateZoneLink, CreateCampaignLink, CreateBuffLink
local FormatNumber

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
    markdown = markdown .. GenerateHeader(characterData, format)
    
    -- Overview (skip for Discord)
    if format ~= "discord" then
        markdown = markdown .. GenerateOverview(characterData, roleData, locationData, settings, format)
    end
    
    -- Progression
    if settings.includeProgression ~= false then
        markdown = markdown .. GenerateProgression(progressionData, format)
    end
    
    -- Currency
    if settings.includeCurrency ~= false then
        markdown = markdown .. GenerateCurrency(currencyData, format)
    end
    
    -- Riding Skills
    if settings.includeRidingSkills ~= false then
        markdown = markdown .. GenerateRidingSkills(ridingData, format)
    end
    
    -- Inventory
    if settings.includeInventory ~= false then
        markdown = markdown .. GenerateInventory(inventoryData, format)
    end
    
    -- PvP
    if settings.includePvP ~= false then
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
    
    -- Attributes
    if settings.includeAttributes ~= false then
        markdown = markdown .. GenerateAttributes(characterData, format)
    end
    
    -- Buffs
    if settings.includeBuffs ~= false then
        markdown = markdown .. GenerateBuffs(buffsData, format)
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
    
    -- Mundus
    markdown = markdown .. GenerateMundus(mundusData, format)
    
    -- Champion Points
    if settings.includeChampionPoints ~= false then
        markdown = markdown .. GenerateChampionPoints(cpData, format)
    end
    
    -- Skill Bars
    markdown = markdown .. GenerateSkillBars(skillBarData, format)
    
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

local function GenerateQuickSummary(characterData, equipmentData)
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

local function GenerateHeader(characterData, format)
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
        markdown = markdown .. "**Level " .. (characterData.level or 0) .. "** • **CP " .. FormatNumber(characterData.cp or 0) .. "**  \n"
        markdown = markdown .. "*" .. allianceText .. "*\n\n"
        markdown = markdown .. "---\n\n"
    end
    
    return markdown
end

local function GenerateOverview(characterData, roleData, locationData, settings, format)
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
    
    markdown = markdown .. "\n"
    
    return markdown
end

local function GenerateProgression(progressionData, format)
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

local function GenerateCurrency(currencyData, format)
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

local function GenerateRidingSkills(ridingData, format)
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

local function GenerateInventory(inventoryData, format)
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

local function GeneratePvP(pvpData, format)
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

local function GenerateCollectibles(collectiblesData, format)
    local markdown = ""
    
    if format == "discord" then
        markdown = markdown .. "**Collectibles:**\n"
        if collectiblesData.mounts > 0 then
            markdown = markdown .. "• Mounts: " .. collectiblesData.mounts .. "\n"
        end
        if collectiblesData.pets > 0 then
            markdown = markdown .. "• Pets: " .. collectiblesData.pets .. "\n"
        end
        if collectiblesData.costumes > 0 then
            markdown = markdown .. "• Costumes: " .. collectiblesData.costumes .. "\n"
        end
        if collectiblesData.houses > 0 then
            markdown = markdown .. "• Houses: " .. collectiblesData.houses .. "\n"
        end
        markdown = markdown .. "\n"
    else
        markdown = markdown .. "## 🎨 Collectibles\n\n"
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
    end
    
    return markdown
end

local function GenerateCrafting(craftingData, format)
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

local function GenerateAttributes(characterData, format)
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

local function GenerateBuffs(buffsData, format)
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

local function GenerateDLCAccess(dlcData, format)
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

local function GenerateMundus(mundusData, format)
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

local function GenerateChampionPoints(cpData, format)
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
            markdown = markdown .. "| **Available** | " .. FormatNumber(availableCP) .. " |\n"
            markdown = markdown .. "\n"
            
            if cpData.disciplines and #cpData.disciplines > 0 then
                for _, discipline in ipairs(cpData.disciplines) do
                    markdown = markdown .. "### " .. (discipline.emoji or "⚔️") .. " " .. discipline.name .. 
                                         " (" .. FormatNumber(discipline.total) .. " points)\n\n"
                    if discipline.skills and #discipline.skills > 0 then
                        for _, skill in ipairs(discipline.skills) do
                            local skillText = CreateCPSkillLink(skill.name, format)
                            markdown = markdown .. "- **" .. skillText .. "**: " .. skill.points .. " points\n"
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

local function GenerateSkillBars(skillBarData, format)
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
        for barIdx, bar in ipairs(skillBarData) do
            markdown = markdown .. "### " .. bar.name .. "\n\n"
            
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
    end
    
    return markdown
end

local function GenerateCombatStats(statsData, format)
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

local function GenerateEquipment(equipmentData, format)
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
    else
        markdown = markdown .. "## 🎒 Equipment\n\n"
    
        -- Armor sets
        if equipmentData.sets and #equipmentData.sets > 0 then
            markdown = markdown .. "### 🛡️ Armor Sets\n\n"
            for _, set in ipairs(equipmentData.sets) do
                local indicator = set.count >= 5 and "✅" or set.count >= 2 and "⚠️" or "❌"
                local setLink = CreateSetLink(set.name, format)
                markdown = markdown .. "- " .. indicator .. " **" .. setLink .. "**: " .. set.count .. " pieces\n"
            end
            markdown = markdown .. "\n"
        end
    end

    -- Equipment list
    if format == "discord" and equipmentData.items and #equipmentData.items > 0 then
        -- Discord: Compact equipment list
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
    elseif format ~= "discord" and equipmentData.items and #equipmentData.items > 0 then
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
    
    if format ~= "discord" then
        markdown = markdown .. "---\n\n"
    end
    
    return markdown
end

local function GenerateSkills(skillData, format)
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
                for _, skill in ipairs(category.skills) do
                    local status = skill.maxed and "✅" or "📈"
                    local skillNameLinked = CreateSkillLineLink(skill.name, format)
                    markdown = markdown .. "- " .. status .. " **" .. skillNameLinked .. "**: Rank " .. (skill.rank or 0)
                    if skill.progress and not skill.maxed then
                        markdown = markdown .. " (" .. skill.progress .. "%)"
                    elseif skill.maxed then
                        markdown = markdown .. " (Maxed)"
                    end
                    markdown = markdown .. "\n"
                end
                markdown = markdown .. "\n"
            end
        end

        markdown = markdown .. "---\n\n"
    end
    
    return markdown
end

local function GenerateCompanion(companionData, format)
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
        markdown = markdown .. "## 👥 Companion\n\n"
        markdown = markdown .. "### 🧙 " .. companionNameLinked .. "\n\n"
        markdown = markdown .. "**Level:** " .. (companionData.level or 0) .. "\n\n"
        
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
        
        if companionData.equipment and #companionData.equipment > 0 then
            markdown = markdown .. "**Equipment:**\n"
            for _, item in ipairs(companionData.equipment) do
                markdown = markdown .. "- **" .. item.slot .. "**: " .. item.name .. " (Level " .. item.level .. ", " .. item.quality .. ")\n"
            end
            markdown = markdown .. "\n"
        end

        markdown = markdown .. "---\n\n"
    end
    
    return markdown
end

local function GenerateFooter(format, currentLength)
    local markdown = ""
    
    -- Calculate character count for warnings
    local charCount = currentLength + 200  -- Approximate with footer
    
    if format == "github" then
        markdown = markdown .. "<div align=\"center\">\n\n"
        markdown = markdown .. "**Generated by Character Markdown v" .. CM.version .. "**\n\n"
        markdown = markdown .. "*Format: " .. format:upper() .. "*\n\n"
        if charCount > 8000 then
            markdown = markdown .. "*⚠️ Large profile (" .. FormatNumber(charCount) .. " chars) - ESO clipboard may truncate*\n\n"
            markdown = markdown .. "*Tip: Disable some sections in settings to reduce size*\n\n"
        end
        markdown = markdown .. "</div>\n\n\n"
    else
        markdown = markdown .. "\n```\n"
        markdown = markdown .. string.rep("━", 80) .. "\n"
        markdown = markdown .. string.rep(" ", 20) .. "Generated by Character Markdown v" .. CM.version .. "\n"
        markdown = markdown .. string.rep(" ", 30) .. "Format: " .. format:upper() .. "\n"
        markdown = markdown .. string.rep(" ", 25) .. "Character Count: " .. FormatNumber(charCount) .. " chars\n"
        
        -- Add warnings based on size
        if format == "discord" and charCount > 2000 then
            markdown = markdown .. string.rep(" ", 18) .. "⚠️ Exceeds Discord limit - split required\n"
        end
        
        if charCount > 8000 then
            markdown = markdown .. string.rep(" ", 15) .. "⚠️ ESO clipboard may truncate at ~8,000 chars\n"
            markdown = markdown .. string.rep(" ", 15) .. "Disable sections in settings to reduce size\n"
        end
        
        markdown = markdown .. string.rep("━", 80) .. "\n"
        markdown = markdown .. "```\n\n\n"
    end
    
    return markdown
end
