-- CharacterMarkdown - Economy Data Collector
-- Currency, inventory, riding skills

local CM = CharacterMarkdown

-- =====================================================
-- CURRENCY
-- =====================================================

local function CollectCurrencyData()
    local currencies = {}
    
    currencies.gold = GetCurrentMoney() or 0
    currencies.alliancePoints = GetCurrencyAmount(CURT_ALLIANCE_POINTS, CURRENCY_LOCATION_ACCOUNT) or 0
    currencies.telVar = GetCurrencyAmount(CURT_TELVAR_STONES, CURRENCY_LOCATION_CHARACTER) or 0
    currencies.transmuteCrystals = GetCurrencyAmount(CURT_CHAOTIC_CREATIA, CURRENCY_LOCATION_ACCOUNT) or 0
    currencies.writs = GetCurrencyAmount(CURT_WRIT_VOUCHERS, CURRENCY_LOCATION_ACCOUNT) or 0
    currencies.eventTickets = GetCurrencyAmount(CURT_EVENT_TICKETS, CURRENCY_LOCATION_ACCOUNT) or 0
    currencies.undauntedKeys = GetCurrencyAmount(CURT_UNDAUNTED_KEYS, CURRENCY_LOCATION_CHARACTER) or 0
    currencies.crowns = GetCurrencyAmount(CURT_CROWNS, CURRENCY_LOCATION_ACCOUNT) or 0
    currencies.crownGems = GetCurrencyAmount(CURT_CROWN_GEMS, CURRENCY_LOCATION_ACCOUNT) or 0
    currencies.sealsOfEndeavor = GetCurrencyAmount(CURT_ENDEAVOR_SEALS, CURRENCY_LOCATION_ACCOUNT) or 0
    
    return currencies
end

CM.collectors.CollectCurrencyData = CollectCurrencyData

-- =====================================================
-- INVENTORY
-- =====================================================

local function CollectInventoryData()
    local inventory = {}
    
    inventory.backpackUsed = GetNumBagUsedSlots(BAG_BACKPACK) or 0
    inventory.backpackMax = GetBagSize(BAG_BACKPACK) or 0
    inventory.backpackPercent = inventory.backpackMax > 0 and 
        math.floor((inventory.backpackUsed / inventory.backpackMax) * 100) or 0
    
    inventory.bankUsed = GetNumBagUsedSlots(BAG_BANK) or 0
    inventory.bankMax = GetBagSize(BAG_BANK) or 0
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
    
    local speedBonus, staminaBonus, carryBonus = GetRidingStats()
    riding.speed = speedBonus or 0
    riding.stamina = staminaBonus or 0
    riding.capacity = carryBonus or 0
    
    riding.speedMax = 60
    riding.staminaMax = 60
    riding.capacityMax = 60
    
    local speedReady = GetTimeUntilCanBeTrained(RIDING_TRAIN_SPEED) == 0
    local staminaReady = GetTimeUntilCanBeTrained(RIDING_TRAIN_STAMINA) == 0
    local capacityReady = GetTimeUntilCanBeTrained(RIDING_TRAIN_CARRYING_CAPACITY) == 0
    
    riding.trainingAvailable = speedReady or staminaReady or capacityReady
    riding.allMaxed = (riding.speed >= 60 and riding.stamina >= 60 and riding.capacity >= 60)
    
    return riding
end

CM.collectors.CollectRidingSkillsData = CollectRidingSkillsData
