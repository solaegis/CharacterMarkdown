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

local function CollectInventoryData()
    local inventory = {}
    
    inventory.backpackUsed = CM.SafeCall(GetNumBagUsedSlots, BAG_BACKPACK) or 0
    inventory.backpackMax = CM.SafeCall(GetBagSize, BAG_BACKPACK) or 0
    inventory.backpackPercent = inventory.backpackMax > 0 and 
        math.floor((inventory.backpackUsed / inventory.backpackMax) * 100) or 0
    
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
        CM.DebugPrint("INVENTORY", string_format("Warning: Bank API unavailable (used: %s, max: %s)", 
            bankUsedSuccess and "OK" or "FAILED", bankMaxSuccess and "OK" or "FAILED"))
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
            CM.DebugPrint("INVENTORY", string_format("Bank: API returned %d, doubled to %d for ESO Plus (used: %d)", 
                originalMax, inventory.bankMax, inventory.bankUsed))
        else
            -- No ESO Plus or can't determine - use bankUsed as max to prevent invalid percentages
            -- This shouldn't happen normally, but prevents division by zero
            inventory.bankMax = inventory.bankUsed
            CM.DebugPrint("INVENTORY", string_format("Bank: Used (%d) exceeds max (%d), setting max to used", 
                inventory.bankUsed, inventory.bankMax))
        end
    elseif hasESOPlus and inventory.bankMax == 240 and inventory.bankUsed > 0 then
        -- ESO Plus is active and API returned 240 (common base size)
        -- Double it to get the actual max (480)
        local originalMax = inventory.bankMax
        inventory.bankMax = inventory.bankMax * 2
        CM.DebugPrint("INVENTORY", string_format("Bank: ESO Plus active, doubled base size from %d to %d", 
            originalMax, inventory.bankMax))
    end
    
    inventory.bankPercent = inventory.bankMax > 0 and 
        math.floor((inventory.bankUsed / inventory.bankMax) * 100) or 0
    
    inventory.hasCraftingBag = HasCraftBagAccess()
    
    return inventory
end

CM.collectors.CollectInventoryData = CollectInventoryData

-- =====================================================
-- RIDING SKILLS
-- =====================================================

local function CollectRidingSkillsData()
    local riding = {}
    
    -- GetRidingStats() returns values in order: staminaBonus, speedBonus, carryBonus
    -- But the variable names in the original code were misleading - need to swap assignments
    -- SafeCall can't handle multiple returns directly, so we use pcall and handle errors
    local success, first, second, third = pcall(GetRidingStats)
    if not success then
        first, second, third = 0, 0, 0
    end
    -- Based on user report: API returns (stamina, speed, capacity)
    -- So: first=stamina, second=speed, third=capacity
    riding.speed = second or 0  -- Second return is speed
    riding.stamina = first or 0  -- First return is stamina
    riding.capacity = third or 0  -- Third return is capacity
    
    riding.speedMax = 60
    riding.staminaMax = 60
    riding.capacityMax = 60
    
    local speedReady = (CM.SafeCall(GetTimeUntilCanBeTrained, RIDING_TRAIN_SPEED) or 1) == 0
    local staminaReady = (CM.SafeCall(GetTimeUntilCanBeTrained, RIDING_TRAIN_STAMINA) or 1) == 0
    local capacityReady = (CM.SafeCall(GetTimeUntilCanBeTrained, RIDING_TRAIN_CARRYING_CAPACITY) or 1) == 0
    
    riding.trainingAvailable = speedReady or staminaReady or capacityReady
    riding.allMaxed = (riding.speed >= 60 and riding.stamina >= 60 and riding.capacity >= 60)
    
    return riding
end

CM.collectors.CollectRidingSkillsData = CollectRidingSkillsData
