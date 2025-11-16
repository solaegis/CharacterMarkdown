-- CharacterMarkdown - Economy Data Collector
-- Currency, inventory, riding skills

local CM = CharacterMarkdown

-- Cached globals
local IsESOPlusSubscriber = IsESOPlusSubscriber
local string_format = string.format

-- =====================================================
-- CURRENCY
-- =====================================================

local function CollectCurrencyData()
    local currencies = {}

    currencies.gold = CM.SafeCall(GetCurrentMoney) or 0
    currencies.goldBank = CM.SafeCall(GetBankedMoney) or 0
    currencies.goldTotal = currencies.gold + currencies.goldBank
    currencies.alliancePoints = CM.SafeCall(GetCurrencyAmount, CURT_ALLIANCE_POINTS, CURRENCY_LOCATION_ACCOUNT) or 0
    currencies.telVar = CM.SafeCall(GetCurrencyAmount, CURT_TELVAR_STONES, CURRENCY_LOCATION_CHARACTER) or 0
    currencies.transmuteCrystals = CM.SafeCall(GetCurrencyAmount, CURT_CHAOTIC_CREATIA, CURRENCY_LOCATION_ACCOUNT) or 0
    currencies.writs = CM.SafeCall(GetCurrencyAmount, CURT_WRIT_VOUCHERS, CURRENCY_LOCATION_ACCOUNT) or 0
    currencies.eventTickets = CM.SafeCall(GetCurrencyAmount, CURT_EVENT_TICKETS, CURRENCY_LOCATION_ACCOUNT) or 0
    currencies.undauntedKeys = CM.SafeCall(GetCurrencyAmount, CURT_UNDAUNTED_KEYS, CURRENCY_LOCATION_CHARACTER) or 0
    currencies.crowns = CM.SafeCall(GetCurrencyAmount, CURT_CROWNS, CURRENCY_LOCATION_ACCOUNT) or 0
    currencies.crownGems = CM.SafeCall(GetCurrencyAmount, CURT_CROWN_GEMS, CURRENCY_LOCATION_ACCOUNT) or 0
    currencies.sealsOfEndeavor = CM.SafeCall(GetCurrencyAmount, CURT_ENDEAVOR_SEALS, CURRENCY_LOCATION_ACCOUNT) or 0

    return currencies
end

CM.collectors.CollectCurrencyData = CollectCurrencyData

-- =====================================================
-- INVENTORY
-- =====================================================

-- Helper function to collect items from crafting bag using proper API
local function CollectCraftBagItems()
    local items = {}
    
    -- Craft bag uses BAG_VIRTUAL but requires special iteration
    -- Try using ZO_IterateBagSlots if available (ZO library function)
    if ZO_IterateBagSlots then
        CM.DebugPrint("INVENTORY", "Using ZO_IterateBagSlots for craft bag iteration")
        for slotIndex in ZO_IterateBagSlots(BAG_VIRTUAL) do
            local itemLink = CM.SafeCall(GetItemLink, BAG_VIRTUAL, slotIndex)
            if itemLink and itemLink ~= "" then
                local itemName = CM.SafeCall(GetItemName, BAG_VIRTUAL, slotIndex) or "Unknown"
                itemName = itemName:gsub("%^%w+$", "") -- Strip superscript markers
                
                local success, icon, stack, sellPrice, meetsUsageRequirement, locked, equipType, itemStyleId, quality =
                    pcall(GetItemInfo, BAG_VIRTUAL, slotIndex)
                if not success then
                    icon = nil
                    stack = 1
                    quality = 0
                end
                
                local itemType = CM.SafeCall(GetItemType, BAG_VIRTUAL, slotIndex)
                local itemTypeName = ""
                if itemType then
                    local success2, typeName = pcall(GetString, "SI_ITEMTYPE", itemType)
                    if success2 and typeName and typeName ~= "" then
                        itemTypeName = typeName
                    end
                end
                
                table.insert(items, {
                    name = itemName,
                    link = itemLink,
                    stack = stack or 1,
                    quality = quality or 0,
                    icon = icon,
                    itemType = itemType,
                    itemTypeName = itemTypeName,
                    slot = slotIndex,
                })
            end
        end
    else
        -- Fallback: Try GetNumBagUsedSlots to get count, then iterate
        CM.DebugPrint("INVENTORY", "ZO_IterateBagSlots not available, using fallback method")
        local craftBagUsedSuccess, craftBagUsedResult = pcall(GetNumBagUsedSlots, BAG_VIRTUAL)
        if craftBagUsedSuccess and craftBagUsedResult and craftBagUsedResult > 0 then
            -- If we know how many items, try iterating through slots
            -- Craft bag items might not be in sequential slots, so we need to check a wide range
            for slotIndex = 0, 10000 do
                local itemLink = CM.SafeCall(GetItemLink, BAG_VIRTUAL, slotIndex)
                if itemLink and itemLink ~= "" then
                    local itemName = CM.SafeCall(GetItemName, BAG_VIRTUAL, slotIndex) or "Unknown"
                    itemName = itemName:gsub("%^%w+$", "")
                    
                    local success, icon, stack, sellPrice, meetsUsageRequirement, locked, equipType, itemStyleId, quality =
                        pcall(GetItemInfo, BAG_VIRTUAL, slotIndex)
                    if not success then
                        icon = nil
                        stack = 1
                        quality = 0
                    end
                    
                    local itemType = CM.SafeCall(GetItemType, BAG_VIRTUAL, slotIndex)
                    local itemTypeName = ""
                    if itemType then
                        local success2, typeName = pcall(GetString, "SI_ITEMTYPE", itemType)
                        if success2 and typeName and typeName ~= "" then
                            itemTypeName = typeName
                        end
                    end
                    
                    table.insert(items, {
                        name = itemName,
                        link = itemLink,
                        stack = stack or 1,
                        quality = quality or 0,
                        icon = icon,
                        itemType = itemType,
                        itemTypeName = itemTypeName,
                        slot = slotIndex,
                    })
                    
                    -- Stop if we've found all items
                    if #items >= craftBagUsedResult then
                        break
                    end
                end
            end
        end
    end
    
    -- Sort by name (case-insensitive)
    table.sort(items, function(a, b)
        return a.name:lower() < b.name:lower()
    end)
    
    return items
end

-- Helper function to collect items from a specific bag
local function CollectBagItems(bagId)
    local items = {}
    local numSlots = CM.SafeCall(GetBagSize, bagId) or 0
    
    -- For virtual bags (like craft bag), GetBagSize might return 0 or fail
    -- In that case, iterate through slots until we find no more items
    local isVirtualBag = (bagId == BAG_VIRTUAL)
    local maxSlotsToCheck = isVirtualBag and 10000 or numSlots
    local emptySlotCount = 0
    local maxEmptySlots = 100  -- Stop after 100 consecutive empty slots

    -- Debug: Log bag type for craft bag
    if isVirtualBag then
        CM.DebugPrint("INVENTORY", string_format("CollectBagItems: Starting iteration for BAG_VIRTUAL (maxSlotsToCheck: %d)", maxSlotsToCheck))
    end
    
    for slotIndex = 0, maxSlotsToCheck - 1 do
        local itemLink = CM.SafeCall(GetItemLink, bagId, slotIndex)
        if itemLink and itemLink ~= "" then
            emptySlotCount = 0  -- Reset empty slot counter when we find an item
            -- Debug: Log first few items found for craft bag
            if isVirtualBag and #items < 3 then
                CM.DebugPrint("INVENTORY", string_format("CollectBagItems: Found item at slot %d: %s", slotIndex, itemLink:match("|H(.-)|h") or "unknown"))
            end
            -- Get item details
            local itemName = CM.SafeCall(GetItemName, bagId, slotIndex) or "Unknown"
            -- Strip superscript markers from item names (^n, ^N, ^F, ^p, etc.)
            itemName = itemName:gsub("%^%w+$", "")
            -- GetItemInfo returns multiple values, so use pcall directly
            local success, icon, stack, sellPrice, meetsUsageRequirement, locked, equipType, itemStyleId, quality =
                pcall(GetItemInfo, bagId, slotIndex)
            if not success then
                CM.DebugPrint("INVENTORY", "GetItemInfo failed for slot " .. slotIndex .. ": " .. tostring(icon))
                icon = nil
                stack = 1
                quality = 0
            end

            local itemType = CM.SafeCall(GetItemType, bagId, slotIndex)
            -- Get item type name for categorization
            local itemTypeName = ""
            if itemType then
                local success2, typeName = pcall(GetString, "SI_ITEMTYPE", itemType)
                if success2 and typeName and typeName ~= "" then
                    itemTypeName = typeName
                end
            end

            table.insert(items, {
                name = itemName,
                link = itemLink,
                stack = stack or 1,
                quality = quality or 0,
                icon = icon,
                itemType = itemType,
                itemTypeName = itemTypeName,
                slot = slotIndex,
            })
        else
            -- For virtual bags, stop iterating after many consecutive empty slots
            if isVirtualBag then
                emptySlotCount = emptySlotCount + 1
                if emptySlotCount >= maxEmptySlots then
                    break  -- Stop iterating after too many empty slots
                end
            end
        end
    end

    -- Sort by name (case-insensitive)
    table.sort(items, function(a, b)
        return a.name:lower() < b.name:lower()
    end)

    return items
end

local function CollectInventoryData()
    local inventory = {}

    inventory.backpackUsed = CM.SafeCall(GetNumBagUsedSlots, BAG_BACKPACK) or 0
    inventory.backpackMax = CM.SafeCall(GetBagSize, BAG_BACKPACK) or 0
    inventory.backpackPercent = inventory.backpackMax > 0
            and math.floor((inventory.backpackUsed / inventory.backpackMax) * 100)
        or 0

    -- Collect bag items if requested
    local settings = CM.GetSettings()
    if settings and settings.showBagContents then
        inventory.bagItems = CollectBagItems(BAG_BACKPACK)
    end

    -- Collect bank data with better error handling
    -- Note: Bank API may not be available if player hasn't accessed bank yet
    -- Use pcall to distinguish between API errors and actual 0 values
    local bankUsedSuccess, bankUsedResult = pcall(GetNumBagUsedSlots, BAG_BANK)
    local bankMaxSuccess, bankMaxResult = pcall(GetBagSize, BAG_BANK)

    if bankUsedSuccess and bankMaxSuccess then
        -- API calls succeeded - use results (could be 0 if bank is empty)
        inventory.bankUsed = bankUsedResult or 0
        inventory.bankMax = bankMaxResult or 0
        CM.DebugPrint("INVENTORY", string_format("Bank data collected: %d/%d", inventory.bankUsed, inventory.bankMax))
    else
        -- API calls failed - bank may not be accessible
        inventory.bankUsed = 0
        inventory.bankMax = 0
        CM.DebugPrint(
            "INVENTORY",
            string_format(
                "Warning: Bank API unavailable (used: %s, max: %s)",
                bankUsedSuccess and "OK" or "FAILED",
                bankMaxSuccess and "OK" or "FAILED"
            )
        )
    end

    -- ESO Plus doubles bank capacity
    -- The API may return the base size (240) instead of the doubled size (480) when ESO Plus is active
    -- If bankUsed exceeds the returned bankMax, and ESO Plus is active, double the bankMax
    local hasESOPlus = CM.SafeCall(IsESOPlusSubscriber) or false

    if inventory.bankMax < inventory.bankUsed then
        -- Bank used exceeds returned max - this can happen if API returns base size instead of doubled
        if hasESOPlus and inventory.bankMax > 0 then
            -- ESO Plus doubles bank capacity - try doubling the returned value
            local originalMax = inventory.bankMax
            inventory.bankMax = inventory.bankMax * 2
            CM.DebugPrint(
                "INVENTORY",
                string_format(
                    "Bank: API returned %d, doubled to %d for ESO Plus (used: %d)",
                    originalMax,
                    inventory.bankMax,
                    inventory.bankUsed
                )
            )
        else
            -- No ESO Plus or can't determine - use bankUsed as max to prevent invalid percentages
            -- This shouldn't happen normally, but prevents division by zero
            inventory.bankMax = inventory.bankUsed
            CM.DebugPrint(
                "INVENTORY",
                string_format(
                    "Bank: Used (%d) exceeds max (%d), setting max to used",
                    inventory.bankUsed,
                    inventory.bankMax
                )
            )
        end
    elseif hasESOPlus and inventory.bankMax == 240 and inventory.bankUsed > 0 then
        -- ESO Plus is active and API returned 240 (common base size)
        -- Double it to get the actual max (480)
        local originalMax = inventory.bankMax
        inventory.bankMax = inventory.bankMax * 2
        CM.DebugPrint(
            "INVENTORY",
            string_format("Bank: ESO Plus active, doubled base size from %d to %d", originalMax, inventory.bankMax)
        )
    end

    inventory.bankPercent = inventory.bankMax > 0 and math.floor((inventory.bankUsed / inventory.bankMax) * 100) or 0

    -- Collect bank items if requested
    if settings and settings.showBankContents and bankMaxSuccess then
        inventory.bankItems = CollectBagItems(BAG_BANK)
    end

    -- Check craft bag access - Craft Bag is ESO Plus exclusive feature
    -- Use HasCraftBagAccess if available, otherwise fall back to ESO Plus status
    local craftBagAccess = false
    local craftBagCheckSuccess, craftBagCheckResult = pcall(HasCraftBagAccess)
    if craftBagCheckSuccess then
        craftBagAccess = craftBagCheckResult or false
        CM.DebugPrint("INVENTORY", string_format("Craft bag access check: HasCraftBagAccess() = %s", tostring(craftBagAccess)))
    else
        -- HasCraftBagAccess might not exist or failed - use ESO Plus status as fallback
        craftBagAccess = hasESOPlus
        CM.DebugPrint("INVENTORY", string_format("HasCraftBagAccess() failed, using ESO Plus status: %s", tostring(craftBagAccess)))
    end
    inventory.hasCraftingBag = craftBagAccess

    -- Collect crafting bag items if requested
    -- Only attempt collection if player has ESO Plus (craft bag access)
    if settings and settings.showCraftingBagContents then
        if inventory.hasCraftingBag then
            -- Player has ESO Plus - attempt to collect craft bag items
            CM.DebugPrint("INVENTORY", "Attempting to collect crafting bag items (ESO Plus active)...")
            
            -- Use dedicated craft bag collection function
            inventory.craftingBagItems = CollectCraftBagItems()
            if #inventory.craftingBagItems > 0 then
                CM.DebugPrint("INVENTORY", string_format("Crafting bag: collected %d items", #inventory.craftingBagItems))
            else
                CM.DebugPrint("INVENTORY", "Crafting bag: no items found (bag may be empty or items not accessible)")
                -- Set to empty table so generation code knows we tried to collect
                inventory.craftingBagItems = {}
            end
        else
            -- Setting is enabled but player doesn't have ESO Plus (no craft bag access)
            CM.DebugPrint("INVENTORY", string_format("Crafting bag: setting enabled but player does not have ESO Plus (HasCraftBagAccess: %s, ESO Plus: %s). Craft Bag is ESO Plus exclusive.", 
                tostring(craftBagCheckSuccess and craftBagCheckResult or "N/A"), tostring(hasESOPlus)))
            -- Don't set craftingBagItems - generation code will skip it
            -- hasCraftingBag is already false, so craft bag row won't appear in output
        end
    else
        -- Setting is disabled - log for debugging
        if not settings then
            CM.DebugPrint("INVENTORY", "Crafting bag: settings not available")
        elseif not settings.showCraftingBagContents then
            CM.DebugPrint("INVENTORY", "Crafting bag: showCraftingBagContents setting is disabled")
        end
    end

    return inventory
end

CM.collectors.CollectInventoryData = CollectInventoryData

-- =====================================================
-- RIDING SKILLS
-- =====================================================

local function CollectRidingSkillsData()
    local riding = {}

    -- GetRidingStats() returns: speed, stamina, carryCapacity (in that order)
    -- Values are already in the 0-60 range
    local success, speed, stamina, capacity = pcall(GetRidingStats)
    if not success then
        speed, stamina, capacity = 0, 0, 0
    end
    
    riding.speed = speed or 0
    riding.stamina = stamina or 0
    riding.capacity = capacity or 0
    
    -- Ensure values are within valid range (0-60)
    riding.speed = math.max(0, math.min(60, riding.speed))
    riding.stamina = math.max(0, math.min(60, riding.stamina))
    riding.capacity = math.max(0, math.min(60, riding.capacity))

    return riding
end

CM.collectors.CollectRidingSkillsData = CollectRidingSkillsData
