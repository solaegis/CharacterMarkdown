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

-- =====================================================
-- RIDING SKILLS
-- =====================================================

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

