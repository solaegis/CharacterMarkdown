-- CharacterMarkdown - Economy Section Generators
-- Generates economy-related markdown sections (currency, inventory, riding)

local CM = CharacterMarkdown

-- Cache for utility functions (lazy-initialized on first use)
local FormatNumber, CreateCampaignLink

-- Lazy initialization of cached references
local function InitializeUtilities()
    if not FormatNumber then
        FormatNumber = CM.utils.FormatNumber
        CreateCampaignLink = CM.links.CreateCampaignLink
    end
end

-- =====================================================
-- CURRENCY
-- =====================================================

local function GenerateCurrency(currencyData, format)
    InitializeUtilities()
    
    local markdown = ""
    
    if format == "discord" then
        markdown = markdown .. "**Currency:**\n"
        markdown = markdown .. "• Gold: " .. FormatNumber(currencyData.gold) .. "\n"
        if currencyData.goldBank and currencyData.goldBank > 0 then
            markdown = markdown .. "• Gold (Bank): " .. FormatNumber(currencyData.goldBank) .. "\n"
        end
        if currencyData.goldTotal and currencyData.goldTotal > 0 then
            markdown = markdown .. "• Gold (Total): " .. FormatNumber(currencyData.goldTotal) .. "\n"
        end
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
        markdown = markdown .. "| **💰 Gold (On Hand)** | " .. FormatNumber(currencyData.gold) .. " |\n"
        if currencyData.goldBank and currencyData.goldBank > 0 then
            markdown = markdown .. "| **💰 Gold (Bank)** | " .. FormatNumber(currencyData.goldBank) .. " |\n"
        end
        if currencyData.goldTotal and currencyData.goldTotal > 0 then
            markdown = markdown .. "| **💰 Gold (Total)** | " .. FormatNumber(currencyData.goldTotal) .. " |\n"
        end
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

-- =====================================================
-- RIDING SKILLS
-- =====================================================

local function GenerateRidingSkills(ridingData, format)
    local markdown = ""
    
    -- Check setting for showing all vs only non-maxed
    local settings = CharacterMarkdownSettings or {}
    local showAllRiding = settings.showAllRidingSkills ~= false  -- Default to true (show all)
    
    -- Build list of skills to show
    local skillsToShow = {}
    if showAllRiding or ridingData.speed < 60 then
        table.insert(skillsToShow, {name = "Speed", value = ridingData.speed, max = 60, emoji = "🏃"})
    end
    if showAllRiding or ridingData.stamina < 60 then
        table.insert(skillsToShow, {name = "Stamina", value = ridingData.stamina, max = 60, emoji = "💨"})
    end
    if showAllRiding or ridingData.capacity < 60 then
        table.insert(skillsToShow, {name = "Capacity", value = ridingData.capacity, max = 60, emoji = "📦"})
    end
    
    -- Don't show section if all skills are maxed and setting is OFF
    if not showAllRiding and #skillsToShow == 0 then
        return ""
    end
    
    if format == "discord" then
        markdown = markdown .. "**Riding Skills:**\n"
        for _, skill in ipairs(skillsToShow) do
            markdown = markdown .. "• " .. skill.name .. ": " .. skill.value .. "/" .. skill.max
            if skill.value >= skill.max then markdown = markdown .. " ✅" end
            markdown = markdown .. "\n"
        end
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
        for _, skill in ipairs(skillsToShow) do
            local status = skill.value >= skill.max and "✅ Maxed" or "📈 Training"
            markdown = markdown .. "| **" .. skill.name .. "** | " .. skill.value .. " / " .. skill.max .. " | " .. status .. " |\n"
        end
        markdown = markdown .. "\n"
        if ridingData.allMaxed then
            markdown = markdown .. "✅ **All riding skills maxed!**\n\n"
        elseif ridingData.trainingAvailable then
            markdown = markdown .. "⚠️ **Riding training available now**\n\n"
        end
    end
    
    return markdown
end

-- =====================================================
-- INVENTORY
-- =====================================================

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

-- =====================================================
-- PVP
-- =====================================================

local function GeneratePvP(pvpData, format)
    InitializeUtilities()
    
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

-- =====================================================
-- EXPORTS
-- =====================================================

CM.generators.sections = CM.generators.sections or {}
CM.generators.sections.GenerateCurrency = GenerateCurrency
CM.generators.sections.GenerateRidingSkills = GenerateRidingSkills
CM.generators.sections.GenerateInventory = GenerateInventory
CM.generators.sections.GeneratePvP = GeneratePvP

