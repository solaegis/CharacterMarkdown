-- CharacterMarkdown - Economy Section Generators
-- Generates economy-related markdown sections (currency, inventory, riding)

local CM = CharacterMarkdown

-- Cache for utility functions (lazy-initialized on first use)
local FormatNumber, CreateCampaignLink, CreateCurrencyLink, markdown
local string_format = string.format
local string_rep = string.rep

-- Lazy initialization of cached references
local function InitializeUtilities()
    if not FormatNumber then
        FormatNumber = CM.utils.FormatNumber
        CreateCampaignLink = CM.links.CreateCampaignLink
        CreateCurrencyLink = CM.links.CreateCurrencyLink
        markdown = CM.utils.markdown
    end
end

-- =====================================================
-- CURRENCY
-- =====================================================

local function GenerateCurrency(currencyData, format)
    InitializeUtilities()
    
    if not currencyData or (CM.settings and CM.settings.includeCurrency == false) then return "" end
    
    -- Enhanced visuals are now always enabled (baseline)
    -- Build currency items for grid (enhanced visuals are baseline)
    -- Use CreateCurrencyLink for labels if available
    local goldLabel = (CreateCurrencyLink and CreateCurrencyLink("Gold", format)) or "Gold"
    local apLabel = (CreateCurrencyLink and CreateCurrencyLink("Alliance Points", format)) or "AP"
    local telVarLabel = (CreateCurrencyLink and CreateCurrencyLink("Tel Var", format)) or "Tel Var"
    local crystalsLabel = (CreateCurrencyLink and CreateCurrencyLink("Crystals", format)) or "Crystals"
    local writsLabel = (CreateCurrencyLink and CreateCurrencyLink("Writs", format)) or "Writs"
    local ticketsLabel = (CreateCurrencyLink and CreateCurrencyLink("Tickets", format)) or "Tickets"
    
    local items = {
        {emoji = "💰", label = goldLabel, value = FormatNumber(currencyData.gold or 0)},
        {emoji = "⚔️", label = apLabel, value = FormatNumber(currencyData.alliancePoints or 0)},
        {emoji = "🔮", label = telVarLabel, value = FormatNumber(currencyData.telVar or 0)},
        {emoji = "💎", label = crystalsLabel, value = FormatNumber(currencyData.transmuteCrystals or 0)},
        {emoji = "📜", label = writsLabel, value = FormatNumber(currencyData.writs or 0)},
        {emoji = "🎫", label = ticketsLabel, value = FormatNumber(currencyData.eventTickets or 0)},
    }
    
    -- Classic format: show detailed table with bank gold, total, crowns, etc.
    if not markdown then
        local result = "## 💰 Currency & Resources\n\n"
        result = result .. "| Currency | Amount |\n"
        result = result .. "|:---------|-------:|\n"
        
        -- Gold (On Hand)
        local goldOnHandLink = CreateCurrencyLink and CreateCurrencyLink("Gold (On Hand)", format) or "💰 Gold (On Hand)"
        result = result .. string_format("| **%s** | %s |\n", goldOnHandLink, FormatNumber(currencyData.gold or 0))
        
        if currencyData.goldBank and currencyData.goldBank > 0 then
            local goldBankLink = CreateCurrencyLink and CreateCurrencyLink("Gold (Bank)", format) or "💰 Gold (Bank)"
            result = result .. string_format("| **%s** | %s |\n", goldBankLink, FormatNumber(currencyData.goldBank))
        end
        if currencyData.goldTotal and currencyData.goldTotal > 0 then
            local goldTotalLink = CreateCurrencyLink and CreateCurrencyLink("Gold (Total)", format) or "💰 Gold (Total)"
            result = result .. string_format("| **%s** | %s |\n", goldTotalLink, FormatNumber(currencyData.goldTotal))
        end
        if currencyData.telVar and currencyData.telVar > 0 then
            local telVarLink = CreateCurrencyLink and CreateCurrencyLink("Tel Var Stones", format) or "🔷 Tel Var Stones"
            result = result .. string_format("| **%s** | %s |\n", telVarLink, FormatNumber(currencyData.telVar))
        end
        if currencyData.transmuteCrystals and currencyData.transmuteCrystals > 0 then
            local crystalsLink = CreateCurrencyLink and CreateCurrencyLink("Transmute Crystals", format) or "💎 Transmute Crystals"
            result = result .. string_format("| **%s** | %s |\n", crystalsLink, FormatNumber(currencyData.transmuteCrystals))
        end
        if currencyData.eventTickets and currencyData.eventTickets > 0 then
            local ticketsLink = CreateCurrencyLink and CreateCurrencyLink("Event Tickets", format) or "🎫 Event Tickets"
            result = result .. string_format("| **%s** | %s |\n", ticketsLink, FormatNumber(currencyData.eventTickets))
        end
        if currencyData.crowns and currencyData.crowns > 0 then
            local crownsLink = CreateCurrencyLink and CreateCurrencyLink("Crowns", format) or "👑 Crowns"
            result = result .. string_format("| **%s** | %s |\n", crownsLink, FormatNumber(currencyData.crowns))
        end
        if currencyData.crownGems and currencyData.crownGems > 0 then
            local crownGemsLink = CreateCurrencyLink and CreateCurrencyLink("Crown Gems", format) or "💠 Crown Gems"
            result = result .. string_format("| **%s** | %s |\n", crownGemsLink, FormatNumber(currencyData.crownGems))
        end
        if currencyData.sealsOfEndeavor and currencyData.sealsOfEndeavor > 0 then
            local sealsLink = CreateCurrencyLink and CreateCurrencyLink("Seals of Endeavor", format) or "🏅 Seals of Endeavor"
            result = result .. string_format("| **%s** | %s |\n", sealsLink, FormatNumber(currencyData.sealsOfEndeavor))
        end
        
        return result .. "\n"
    end
    
    if format == "discord" then
        -- Discord: Simple list format
        local result = "**Currency:**\n"
        for _, item in ipairs(items) do
            result = result .. item.emoji .. " **" .. item.label .. "**: " .. item.value .. "\n"
        end
        return result .. "\n"
    end
    
    -- ENHANCED: Compact grid layout (left-aligned for consistency with other sections)
    local content = ""
    if markdown and markdown.CreateCompactGrid then
        content = markdown.CreateCompactGrid(items, 3, format, "left") or ""
    end
    if content == "" then
        -- Fallback if CreateCompactGrid fails
        local lines = {}
        for _, item in ipairs(items) do
            table.insert(lines, item.emoji .. " **" .. item.label .. ":** " .. item.value)
        end
        content = table.concat(lines, "  \n") .. "\n\n"
    end
    
    local header = ""
    if markdown and markdown.CreateHeader then
        header = markdown.CreateHeader("Currency & Resources", "💰", nil, 2) or "## 💰 Currency & Resources\n\n"
    else
        header = "## 💰 Currency & Resources\n\n"
    end
    
    return header .. content
end

CM.generators.sections.GenerateCurrency = GenerateCurrency

-- =====================================================
-- RIDING SKILLS
-- =====================================================

local function GenerateRidingSkills(ridingData, format)
    InitializeUtilities()
    
    if not ridingData or (CM.settings and CM.settings.includeRidingSkills == false) then return "" end
    
    -- Enhanced visuals are now always enabled (baseline)
    local speed = ridingData.speed or 0
    local stamina = ridingData.stamina or 0
    local capacity = ridingData.capacity or 0
    local maxRiding = 60
    
    if format == "discord" then
        -- Discord: Simple format
        local result = "**Riding Skills:**\n"
        result = result .. "• Speed: " .. speed .. "/60\n"
        result = result .. "• Stamina: " .. stamina .. "/60\n"
        result = result .. "• Capacity: " .. capacity .. "/60\n"
        return result .. "\n"
    end
    
    if not markdown then
        -- Classic table format (matches old output)
        local result = "## 🐎 Riding Skills\n\n"
        result = result .. "| Skill | Progress | Status |\n"
        result = result .. "|:------|:---------|:-------|\n"
        
        local speedStatus = (speed >= 60) and "✅ Maxed" or string_format("%d/60", speed)
        local staminaStatus = (stamina >= 60) and "✅ Maxed" or string_format("%d/60", stamina)
        local capacityStatus = (capacity >= 60) and "✅ Maxed" or string_format("%d/60", capacity)
        
        result = result .. string_format("| **Speed** | %d / 60 | %s |\n", speed, speedStatus)
        result = result .. string_format("| **Stamina** | %d / 60 | %s |\n", stamina, staminaStatus)
        result = result .. string_format("| **Capacity** | %d / 60 | %s |\n", capacity, capacityStatus)
        
        if speed >= 60 and stamina >= 60 and capacity >= 60 then
            result = result .. "\n✅ **All riding skills maxed!**\n\n"
        else
            result = result .. "\n"
        end
        
        return result
    end
    
    -- ENHANCED: Progress bars (with nil checks)
    local progressBars = {}
    if markdown and markdown.CreateProgressBar then
        -- Calculate progress bars manually with aligned labels
        local speedPercent = math.floor((speed / maxRiding) * 100)
        local staminaPercent = math.floor((stamina / maxRiding) * 100)
        local capacityPercent = math.floor((capacity / maxRiding) * 100)
        
        local speedFilled = math.floor((speedPercent / 100) * 20)
        local staminaFilled = math.floor((staminaPercent / 100) * 20)
        local capacityFilled = math.floor((capacityPercent / 100) * 20)
        
        -- Align colons: "Speed:" (5) + 3 spaces = 8, "Stamina:" (7) + 1 space = 8, "Capacity:" (8) = 8
        local speedBar = string_format("%8s %s%s %d%% (%d/%d)", 
            "Speed:", string_rep("█", speedFilled), string_rep("░", 20 - speedFilled),
            speedPercent, speed, maxRiding)
        local staminaBar = string_format("%8s %s%s %d%% (%d/%d)", 
            "Stamina:", string_rep("█", staminaFilled), string_rep("░", 20 - staminaFilled),
            staminaPercent, stamina, maxRiding)
        local capacityBar = string_format("%8s %s%s %d%% (%d/%d)", 
            "Capacity:", string_rep("█", capacityFilled), string_rep("░", 20 - capacityFilled),
            capacityPercent, capacity, maxRiding)
        
        table.insert(progressBars, speedBar)
        table.insert(progressBars, staminaBar)
        table.insert(progressBars, capacityBar)
    else
        -- Fallback: Use fixed-width format for alignment
        local speedPercent = math.floor((speed / maxRiding) * 100)
        local staminaPercent = math.floor((stamina / maxRiding) * 100)
        local capacityPercent = math.floor((capacity / maxRiding) * 100)
        
        local speedFilled = math.floor((speedPercent / 100) * 20)
        local staminaFilled = math.floor((staminaPercent / 100) * 20)
        local capacityFilled = math.floor((capacityPercent / 100) * 20)
        
        -- Align colons: "Speed:" (6) + 2 spaces = 8, "Stamina:" (7) + 1 space = 8, "Capacity:" (8) = 8
        -- Use left-alignment (%-8s) to pad labels on the right, aligning colons
        local speedBar = string_format("%-8s %s%s %d%% (%d/%d)", 
            "Speed:", string_rep("█", speedFilled), string_rep("░", 20 - speedFilled),
            speedPercent, speed, maxRiding)
        local staminaBar = string_format("%-8s %s%s %d%% (%d/%d)", 
            "Stamina:", string_rep("█", staminaFilled), string_rep("░", 20 - staminaFilled),
            staminaPercent, stamina, maxRiding)
        local capacityBar = string_format("%-8s %s%s %d%% (%d/%d)", 
            "Capacity:", string_rep("█", capacityFilled), string_rep("░", 20 - capacityFilled),
            capacityPercent, capacity, maxRiding)
        table.insert(progressBars, speedBar)
        table.insert(progressBars, staminaBar)
        table.insert(progressBars, capacityBar)
    end
    
    local content = table.concat(progressBars, "  \n")
    
    if markdown.CreateCollapsible then
        local collapsible = markdown.CreateCollapsible("Riding Skills", content, "🐴", false)
        return collapsible or (string.format("## 🐴 Riding Skills\n\n%s\n\n", content))
    else
        return string.format("## 🐴 Riding Skills\n\n%s\n\n", content)
    end
end

CM.generators.sections.GenerateRidingSkills = GenerateRidingSkills

-- =====================================================
-- INVENTORY
-- =====================================================

local function GenerateInventory(inventoryData, format)
    InitializeUtilities()
    
    if not inventoryData or CM.settings.includeInventory == false then return "" end
    
    local result = ""
    
    if format == "discord" then
        result = result .. "**Inventory:**\n"
        result = result .. "• Backpack: " .. inventoryData.backpackUsed .. "/" .. inventoryData.backpackMax .. 
                              " (" .. inventoryData.backpackPercent .. "%)\n"
        result = result .. "• Bank: " .. inventoryData.bankUsed .. "/" .. inventoryData.bankMax .. 
                              " (" .. inventoryData.bankPercent .. "%)\n"
        if inventoryData.hasCraftingBag then
            result = result .. "• ✅ Crafting Bag (ESO Plus)\n"
        end
        result = result .. "\n"
    else
        result = result .. "## 🎒 Inventory\n\n"
        result = result .. "| Storage | Used | Max | Capacity |\n"
        result = result .. "|:--------|-----:|----:|---------:|\n"
        result = result .. "| **Backpack** | " .. inventoryData.backpackUsed .. " | " .. 
                              inventoryData.backpackMax .. " | " .. inventoryData.backpackPercent .. "% |\n"
        result = result .. "| **Bank** | " .. inventoryData.bankUsed .. " | " .. 
                              inventoryData.bankMax .. " | " .. inventoryData.bankPercent .. "% |\n"
        if inventoryData.hasCraftingBag then
            result = result .. "| **Crafting Bag** | ∞ | ∞ | ESO Plus |\n"
        end
        result = result .. "\n"
    end
    
    return result
end

CM.generators.sections.GenerateInventory = GenerateInventory

-- =====================================================
-- PVP
-- =====================================================

local function GeneratePvP(pvpData, format)
    InitializeUtilities()
    
    if not pvpData or CM.settings.includePvP == false then return "" end
    
    local result = ""
    
    if format == "discord" then
        result = result .. "**PvP:**\n"
        result = result .. "• Alliance War Rank: " .. pvpData.rankName .. " (Rank " .. pvpData.rank .. ")\n"
        if pvpData.campaignName and pvpData.campaignName ~= "None" then
            local campaignText = CreateCampaignLink(pvpData.campaignName, format)
            result = result .. "• Campaign: " .. campaignText .. "\n"
        end
        result = result .. "\n"
    else
        result = result .. "## ⚔️ PvP Information\n\n"
        result = result .. "| Category | Value |\n"
        result = result .. "|:---------|:------|\n"
        result = result .. "| **Alliance War Rank** | " .. pvpData.rankName .. " (Rank " .. pvpData.rank .. ") |\n"
        if pvpData.campaignName and pvpData.campaignName ~= "None" then
            local campaignText = CreateCampaignLink(pvpData.campaignName, format)
            result = result .. "| **Current Campaign** | " .. campaignText .. " |\n"
        end
        result = result .. "\n"
    end
    
    return result
end

CM.generators.sections.GeneratePvP = GeneratePvP

-- =====================================================
-- MERGED: CURRENCY, RESOURCES & INVENTORY
-- =====================================================

local function GenerateCurrencyResourcesInventory(currencyData, ridingData, inventoryData, format, cpData)
    InitializeUtilities()
    
    -- Check if any of the components should be included
    local includeCurrency = currencyData and (CM.settings == nil or CM.settings.includeCurrency ~= false)
    local includeInventory = inventoryData and (CM.settings == nil or CM.settings.includeInventory ~= false)
    
    if not includeCurrency and not includeInventory then
        return ""
    end
    
    local result = ""
    
    if format == "discord" then
        -- Discord: Simple format, combine all
        if includeCurrency then
            local currencyResult = GenerateCurrency(currencyData, format)
            result = result .. currencyResult
        end
        if includeInventory then
            local inventoryResult = GenerateInventory(inventoryData, format)
            result = result .. inventoryResult
        end
        return result
    end
    
    -- Non-Discord: Create merged section without headers (headers removed for Overview section)
    -- Add Currency title
    result = result .. "### Currency\n\n"
    
    -- Currency & Resources subsection
    if includeCurrency then
        -- Get currency content without header
        local currencyContent = GenerateCurrency(currencyData, format)
        -- Remove the header line (## 💰 Currency & Resources)
        currencyContent = currencyContent:gsub("^##%s+💰%s+Currency%s+&%s+Resources%s*\n%s*\n", "")
        result = result .. currencyContent
    end
    
    -- Inventory subsection
    if includeInventory then
        local inventoryContent = GenerateInventory(inventoryData, format)
        -- Remove the header line (## 🎒 Inventory)
        inventoryContent = inventoryContent:gsub("^##%s+🎒%s+Inventory%s*\n%s*\n", "")
        result = result .. inventoryContent
    end
    
    return result
end

CM.generators.sections.GenerateCurrencyResourcesInventory = GenerateCurrencyResourcesInventory

-- =====================================================
-- MODULE INITIALIZATION
-- =====================================================

CM.DebugPrint("GENERATOR", "Economy section generators loaded (enhanced visuals)")
