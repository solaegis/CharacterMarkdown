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

    if not currencyData then
        return ""
    end

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
        { emoji = "💰", label = goldLabel, value = FormatNumber(currencyData.gold or 0) },
        { emoji = "⚔️", label = apLabel, value = FormatNumber(currencyData.alliancePoints or 0) },
        { emoji = "🔮", label = telVarLabel, value = FormatNumber(currencyData.telVar or 0) },
        { emoji = "💎", label = crystalsLabel, value = FormatNumber(currencyData.transmuteCrystals or 0) },
        { emoji = "📜", label = writsLabel, value = FormatNumber(currencyData.writs or 0) },
        { emoji = "🎫", label = ticketsLabel, value = FormatNumber(currencyData.eventTickets or 0) },
    }

    -- Classic format: show detailed table with bank gold, total, crowns, etc.
    if not markdown then
        local result = "## 💰 Currency & Resources\n\n"

        -- Add attention warning for event tickets at maximum
        local eventTickets = currencyData.eventTickets or 0
        if eventTickets >= 12 then
            result = result
                .. string_format(
                    "🎫 **Event tickets at maximum** (%d/12) - Use tickets to avoid wasting future rewards\n\n",
                    eventTickets
                )
        end

        -- Build table rows
        local headers = { "Currency", "Amount" }
        local rows = {}

        -- Gold (On Hand)
        local goldOnHandLink = CreateCurrencyLink and CreateCurrencyLink("Gold (On Hand)", format)
            or "💰 Gold (On Hand)"
        table.insert(rows, { goldOnHandLink, FormatNumber(currencyData.gold or 0) })

        if currencyData.goldBank and currencyData.goldBank > 0 then
            local goldBankLink = CreateCurrencyLink and CreateCurrencyLink("Gold (Bank)", format) or "💰 Gold (Bank)"
            table.insert(rows, { goldBankLink, FormatNumber(currencyData.goldBank) })
        end
        if currencyData.goldTotal and currencyData.goldTotal > 0 then
            local goldTotalLink = CreateCurrencyLink and CreateCurrencyLink("Gold (Total)", format)
                or "💰 Gold (Total)"
            table.insert(rows, { goldTotalLink, FormatNumber(currencyData.goldTotal) })
        end
        if currencyData.telVar and currencyData.telVar > 0 then
            local telVarLink = CreateCurrencyLink and CreateCurrencyLink("Tel Var Stones", format)
                or "🔷 Tel Var Stones"
            table.insert(rows, { telVarLink, FormatNumber(currencyData.telVar) })
        end
        if currencyData.transmuteCrystals and currencyData.transmuteCrystals > 0 then
            local crystalsLink = CreateCurrencyLink and CreateCurrencyLink("Transmute Crystals", format)
                or "💎 Transmute Crystals"
            table.insert(rows, { crystalsLink, FormatNumber(currencyData.transmuteCrystals) })
        end
        if currencyData.eventTickets and currencyData.eventTickets > 0 then
            local ticketsLink = CreateCurrencyLink and CreateCurrencyLink("Event Tickets", format)
                or "🎫 Event Tickets"
            table.insert(rows, { ticketsLink, FormatNumber(currencyData.eventTickets) })
        end
        if currencyData.crowns and currencyData.crowns > 0 then
            local crownsLink = CreateCurrencyLink and CreateCurrencyLink("Crowns", format) or "👑 Crowns"
            table.insert(rows, { crownsLink, FormatNumber(currencyData.crowns) })
        end
        if currencyData.crownGems and currencyData.crownGems > 0 then
            local crownGemsLink = CreateCurrencyLink and CreateCurrencyLink("Crown Gems", format) or "💠 Crown Gems"
            table.insert(rows, { crownGemsLink, FormatNumber(currencyData.crownGems) })
        end
        if currencyData.sealsOfEndeavor and currencyData.sealsOfEndeavor > 0 then
            local sealsLink = CreateCurrencyLink and CreateCurrencyLink("Seals of Endeavor", format)
                or "🏅 Seals of Endeavor"
            table.insert(rows, { sealsLink, FormatNumber(currencyData.sealsOfEndeavor) })
        end

        local CreateStyledTable = markdown and markdown.CreateStyledTable or CM.utils.markdown.CreateStyledTable
        local options = {
            alignment = { "left", "right" },
            format = format,
            coloredHeaders = true,
        }
        result = result .. CreateStyledTable(headers, rows, options)

        return result
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
    local header = ""
    if markdown and markdown.CreateHeader then
        header = markdown.CreateHeader("Currency & Resources", "💰", nil, 2) or "## 💰 Currency & Resources\n\n"
    else
        header = "## 💰 Currency & Resources\n\n"
    end

    -- Add attention warning for event tickets at maximum
    local warningStr = ""
    local eventTickets = currencyData.eventTickets or 0
    if eventTickets >= 12 then
        warningStr = string_format(
            "🎫 **Event tickets at maximum** (%d/12) - Use tickets to avoid wasting future rewards\n\n",
            eventTickets
        )
    end

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

    return header .. warningStr .. content
end

CM.generators.sections.GenerateCurrency = GenerateCurrency

-- =====================================================
-- RIDING SKILLS
-- =====================================================

local function GenerateRidingSkills(ridingData, format)
    InitializeUtilities()

    if not ridingData then
        return ""
    end

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

        local speedStatus = (speed >= 60) and "✅ Maxed" or string_format("%d/60", speed)
        local staminaStatus = (stamina >= 60) and "✅ Maxed" or string_format("%d/60", stamina)
        local capacityStatus = (capacity >= 60) and "✅ Maxed" or string_format("%d/60", capacity)

        local headers = { "Skill", "Progress", "Status" }
        local rows = {
            { "Speed", string_format("%d / 60", speed), speedStatus },
            { "Stamina", string_format("%d / 60", stamina), staminaStatus },
            { "Capacity", string_format("%d / 60", capacity), capacityStatus },
        }

        local CreateStyledTable = markdown and markdown.CreateStyledTable or CM.utils.markdown.CreateStyledTable
        local options = {
            alignment = { "left", "left", "left" },
            format = format,
            coloredHeaders = true,
        }
        result = result .. CreateStyledTable(headers, rows, options)

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
        local speedBar = string_format(
            "%8s %s%s %d%% (%d/%d)",
            "Speed:",
            string_rep("█", speedFilled),
            string_rep("░", 20 - speedFilled),
            speedPercent,
            speed,
            maxRiding
        )
        local staminaBar = string_format(
            "%8s %s%s %d%% (%d/%d)",
            "Stamina:",
            string_rep("█", staminaFilled),
            string_rep("░", 20 - staminaFilled),
            staminaPercent,
            stamina,
            maxRiding
        )
        local capacityBar = string_format(
            "%8s %s%s %d%% (%d/%d)",
            "Capacity:",
            string_rep("█", capacityFilled),
            string_rep("░", 20 - capacityFilled),
            capacityPercent,
            capacity,
            maxRiding
        )

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
        local speedBar = string_format(
            "%-8s %s%s %d%% (%d/%d)",
            "Speed:",
            string_rep("█", speedFilled),
            string_rep("░", 20 - speedFilled),
            speedPercent,
            speed,
            maxRiding
        )
        local staminaBar = string_format(
            "%-8s %s%s %d%% (%d/%d)",
            "Stamina:",
            string_rep("█", staminaFilled),
            string_rep("░", 20 - staminaFilled),
            staminaPercent,
            stamina,
            maxRiding
        )
        local capacityBar = string_format(
            "%-8s %s%s %d%% (%d/%d)",
            "Capacity:",
            string_rep("█", capacityFilled),
            string_rep("░", 20 - capacityFilled),
            capacityPercent,
            capacity,
            maxRiding
        )
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

-- Helper: Get quality emoji/symbol
local function GetQualitySymbol(quality)
    local qualityMap = {
        [0] = "⚪", -- Trash/Normal
        [1] = "⚪", -- Normal/Fine
        [2] = "🟢", -- Superior (Green)
        [3] = "🔵", -- Artifact (Blue)
        [4] = "🟣", -- Epic (Purple)
        [5] = "🟡", -- Legendary (Gold)
    }
    return qualityMap[quality] or "⚪"
end

-- Helper: Generate item list for a specific container
local function GenerateItemList(items, containerName, format)
    if not items or #items == 0 then
        return ""
    end

    local result = ""

    if format == "discord" then
        result = result .. "**" .. containerName .. " Items:**\n"
        for _, item in ipairs(items) do
            local qualitySymbol = GetQualitySymbol(item.quality)
            local stackText = item.stack > 1 and (" x" .. item.stack) or ""
            result = result .. qualitySymbol .. " " .. item.name .. stackText .. "\n"
        end
        result = result .. "\n"
    else
        -- Group items by category (itemTypeName)
        local categories = {}
        
        for _, item in ipairs(items) do
            local category = item.itemTypeName or "Other"
            if category == "" then
                category = "Other"
            end
            if not categories[category] then
                categories[category] = {}
            end
            table.insert(categories[category], item)
        end

        -- Sort categories alphabetically
        local sortedCategories = {}
        for category, categoryItems in pairs(categories) do
            table.insert(sortedCategories, { name = category, items = categoryItems })
        end
        table.sort(sortedCategories, function(a, b)
            return a.name:lower() < b.name:lower()
        end)

        result = result .. "<details>\n"
        result = result
            .. "<summary><strong>"
            .. containerName
            .. " Items</strong> ("
            .. #items
            .. " unique items)</summary>\n\n"

        -- Generate a table for each category
        local CreateStyledTable = CM.utils.markdown.CreateStyledTable
        local CreateResponsiveColumns = CM.utils.markdown.CreateResponsiveColumns
        local headers = { "Item", "Stack", "Quality" }
        local options = {
            alignment = { "left", "right", "left" },
            format = format,
            coloredHeaders = true,
        }

        -- For craft bag, use multi-column layout for better space efficiency
        -- Skip alphabetical sorting within categories for better performance
        local useMultiColumn = (containerName == "Crafting Bag") and CreateResponsiveColumns and format ~= "discord"
        
        if useMultiColumn and #sortedCategories > 1 then
            -- Multi-column layout: collect all category tables first
            local categoryTables = {}
            
            for _, categoryData in ipairs(sortedCategories) do
                local categoryName = categoryData.name
                local categoryItems = categoryData.items
                
                -- Build table for this category (no sorting for efficiency)
                local rows = {}
                for _, item in ipairs(categoryItems) do
                    local qualitySymbol = GetQualitySymbol(item.quality)
                    local stackText = item.stack > 1 and tostring(item.stack) or "1"
                    table.insert(rows, { qualitySymbol .. " " .. item.name, stackText, qualitySymbol })
                end
                
                -- Create table with category header embedded
                local categoryTable = "#### " .. categoryName .. " (" .. #categoryItems .. " items)\n\n"
                categoryTable = categoryTable .. CreateStyledTable(headers, rows, options)
                table.insert(categoryTables, categoryTable)
            end
            
            -- Use LayoutCalculator for optimal sizing
            local LayoutCalculator = CM.utils.LayoutCalculator
            local minWidth, gap
            if LayoutCalculator then
                minWidth, gap = LayoutCalculator.GetLayoutParamsWithFallback(categoryTables, "250px", "20px")
            else
                minWidth, gap = "250px", "20px"
            end
            
            -- Wrap all category tables in responsive columns
            result = result .. CreateResponsiveColumns(categoryTables, minWidth, gap) .. "\n\n"
        else
            -- Single column layout (fallback or for non-craft-bag containers)
            for _, categoryData in ipairs(sortedCategories) do
                local categoryName = categoryData.name
                local categoryItems = categoryData.items
                
                -- Sort items within category by name (only for single column)
                table.sort(categoryItems, function(a, b)
                    return a.name:lower() < b.name:lower()
                end)

                -- Ensure we have proper spacing before adding the category header
                if result ~= "" then
                    local lastChars = string.sub(result, -2, -1)
                    if lastChars ~= "\n\n" then
                        if lastChars:sub(-1, -1) ~= "\n" then
                            result = result .. "\n\n"
                        else
                            result = result .. "\n"
                        end
                    end
                end

                -- Add category header
                result = result .. "#### " .. categoryName .. " (" .. #categoryItems .. " items)\n\n"

                -- Build table for this category
                local rows = {}
                for _, item in ipairs(categoryItems) do
                    local qualitySymbol = GetQualitySymbol(item.quality)
                    local stackText = item.stack > 1 and tostring(item.stack) or "1"
                    table.insert(rows, { qualitySymbol .. " " .. item.name, stackText, qualitySymbol })
                end

                result = result .. CreateStyledTable(headers, rows, options)
                
                -- Ensure table ends with proper newlines before next section
                local lastChars = string.sub(result, -2, -1)
                if lastChars ~= "\n\n" then
                    if lastChars:sub(-1, -1) ~= "\n" then
                        result = result .. "\n\n"
                    else
                        result = result .. "\n"
                    end
                end
            end
        end

        result = result .. "</details>\n\n"
    end

    return result
end

local function GenerateInventory(inventoryData, format)
    InitializeUtilities()

    if not inventoryData then
        return ""
    end

    local result = ""

    if format == "discord" then
        result = result .. "**Inventory:**\n"
        result = result
            .. "• Backpack: "
            .. inventoryData.backpackUsed
            .. "/"
            .. inventoryData.backpackMax
            .. " ("
            .. inventoryData.backpackPercent
            .. "%)\n"
        result = result
            .. "• Bank: "
            .. inventoryData.bankUsed
            .. "/"
            .. inventoryData.bankMax
            .. " ("
            .. inventoryData.bankPercent
            .. "%)\n"
        if inventoryData.hasCraftingBag then
            result = result .. "• ✅ Crafting Bag (ESO Plus)\n"
        end
        result = result .. "\n"

        -- Add detailed bag contents if available
        if inventoryData.bagItems then
            result = result .. GenerateItemList(inventoryData.bagItems, "Backpack", format)
        end

        -- Add detailed bank contents if available
        if inventoryData.bankItems then
            result = result .. GenerateItemList(inventoryData.bankItems, "Bank", format)
        end

        -- Add detailed crafting bag contents if available
        if inventoryData.craftingBagItems then
            result = result .. GenerateItemList(inventoryData.craftingBagItems, "Crafting Bag", format)
        end
    else
        result = result .. "## 🎒 Inventory\n\n"

        -- Add attention warnings for nearly full storage
        local warnings = {}
        if inventoryData.backpackPercent and inventoryData.backpackPercent >= 90 then
            table.insert(
                warnings,
                string_format("🎒 **Backpack nearly full** (%d%%) - Clear out items", inventoryData.backpackPercent)
            )
        end
        if inventoryData.bankPercent and inventoryData.bankPercent >= 90 then
            table.insert(
                warnings,
                string_format("🏦 **Bank nearly full** (%d%%) - Clear out items", inventoryData.bankPercent)
            )
        end

        if #warnings > 0 then
            result = result .. table.concat(warnings, "  \n") .. "\n\n"
        end

        local headers = { "Storage", "Used", "Max", "Capacity" }
        
        -- Helper function to create capacity progress bar
        local function FormatCapacity(percent)
            if not percent then
                return "-"
            end
            local CreateProgressBar = CM.utils.CreateProgressBar
            if CreateProgressBar then
                return CreateProgressBar(percent, 10)
            else
                -- Fallback to percentage if progress bar not available
                return tostring(percent) .. "%"
            end
        end
        
        local rows = {
            {
                "Backpack",
                tostring(inventoryData.backpackUsed),
                tostring(inventoryData.backpackMax),
                FormatCapacity(inventoryData.backpackPercent),
            },
            {
                "Bank",
                tostring(inventoryData.bankUsed),
                tostring(inventoryData.bankMax),
                FormatCapacity(inventoryData.bankPercent),
            },
        }

        if inventoryData.hasCraftingBag then
            table.insert(rows, { "Crafting Bag", "∞", "∞", "ESO Plus" })
        end

        local CreateStyledTable = CM.utils.markdown.CreateStyledTable
        local options = {
            alignment = { "left", "right", "right", "left" },
            format = format,
            coloredHeaders = true,
        }
        result = result .. CreateStyledTable(headers, rows, options)

        -- Add detailed bag contents if available
        if inventoryData.bagItems then
            result = result .. GenerateItemList(inventoryData.bagItems, "Backpack", format)
        end

        -- Add detailed bank contents if available
        if inventoryData.bankItems then
            result = result .. GenerateItemList(inventoryData.bankItems, "Bank", format)
        end

        -- Add detailed crafting bag contents if available
        if inventoryData.craftingBagItems then
            result = result .. GenerateItemList(inventoryData.craftingBagItems, "Crafting Bag", format)
        end
    end

    return result
end

CM.generators.sections.GenerateInventory = GenerateInventory

-- =====================================================
-- PVP
-- =====================================================

local function GeneratePvP(pvpData, format)
    InitializeUtilities()

    if not pvpData then
        return ""
    end

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

        local headers = { "Category", "Value" }
        local rows = {
            { "Alliance War Rank", pvpData.rankName .. " (Rank " .. pvpData.rank .. ")" },
        }

        if pvpData.campaignName and pvpData.campaignName ~= "None" then
            local campaignText = CreateCampaignLink(pvpData.campaignName, format)
            table.insert(rows, { "Current Campaign", campaignText })
        end

        local CreateStyledTable = CM.utils.markdown.CreateStyledTable
        local options = {
            alignment = { "left", "left" },
            format = format,
            coloredHeaders = true,
        }
        result = result .. CreateStyledTable(headers, rows, options)
    end

    return result
end

CM.generators.sections.GeneratePvP = GeneratePvP

-- =====================================================
-- MERGED: CURRENCY, RESOURCES & INVENTORY
-- =====================================================

local function GenerateCurrencyResourcesInventory(currencyData, ridingData, inventoryData, format, cpData)
    InitializeUtilities()

    -- Check if any of the components have data
    local includeCurrency = currencyData ~= nil
    local includeInventory = inventoryData ~= nil

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
    result = result .. '<a id="currency"></a>\n\n### Currency\n\n'

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
