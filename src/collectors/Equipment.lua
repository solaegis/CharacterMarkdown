-- CharacterMarkdown - Equipment Data Collector (Tier 1 Enhanced)
-- Gear, sets, mundus stones, active buffs, enchantments, item details

local CM = CharacterMarkdown

-- =====================================================
-- EQUIPMENT (TIER 1 COMPLETE)
-- =====================================================

local function CollectEquipmentData()
    local equipment = { sets = {}, items = {} }
    
    local equipSlots = {
        EQUIP_SLOT_HEAD, EQUIP_SLOT_NECK, EQUIP_SLOT_CHEST, EQUIP_SLOT_SHOULDERS,
        EQUIP_SLOT_MAIN_HAND, EQUIP_SLOT_OFF_HAND, EQUIP_SLOT_WAIST, EQUIP_SLOT_LEGS,
        EQUIP_SLOT_FEET, EQUIP_SLOT_RING1, EQUIP_SLOT_RING2, EQUIP_SLOT_HAND,
        EQUIP_SLOT_BACKUP_MAIN, EQUIP_SLOT_BACKUP_OFF,
    }
    
    -- Collect set information
    local sets = {}
    for _, slotIndex in ipairs(equipSlots) do
        local itemName = GetItemName(BAG_WORN, slotIndex)
        if itemName and itemName ~= "" then
            local itemLink = GetItemLink(BAG_WORN, slotIndex)
            local hasSet, setName = GetItemLinkSetInfo(itemLink)
            if hasSet and setName then
                sets[setName] = (sets[setName] or 0) + 1
            end
        end
    end
    
    -- Format sets array
    for setName, count in pairs(sets) do
        table.insert(equipment.sets, { name = setName, count = count })
    end
    
    -- Collect equipment items with extended details
    for _, slotIndex in ipairs(equipSlots) do
        local itemName = GetItemName(BAG_WORN, slotIndex)
        if itemName and itemName ~= "" then
            local itemLink = GetItemLink(BAG_WORN, slotIndex)
            local hasSet, setName = GetItemLinkSetInfo(itemLink)
            local quality = GetItemLinkQuality(itemLink)
            local traitType = GetItemLinkTraitInfo(itemLink)
            local traitName = GetString("SI_ITEMTRAITTYPE", traitType) or "None"
            
            -- ===== NEW: ENCHANTMENT INFO =====
            local enchantName, enchantIcon, enchantCharge, enchantMaxCharge = nil, nil, 0, 0
            local success1, name, icon, charge, maxCharge = pcall(GetItemLinkEnchantInfo, itemLink)
            if success1 and name and name ~= "" then
                enchantName = name
                enchantIcon = icon
                enchantCharge = charge or 0
                enchantMaxCharge = maxCharge or 0
            end
            
            -- ===== NEW: ITEM STYLE =====
            local itemStyle = 0
            local success2, style = pcall(GetItemLinkItemStyle, itemLink)
            if success2 and style then
                itemStyle = style
            end
            
            -- ===== NEW: REQUIRED LEVEL/CP =====
            local requiredLevel, requiredCP = 0, 0
            local success3, level = pcall(GetItemLinkRequiredLevel, itemLink)
            if success3 and level then
                requiredLevel = level
            end
            
            local success4, cp = pcall(GetItemLinkRequiredChampionPoints, itemLink)
            if success4 and cp then
                requiredCP = cp
            end
            
            -- ===== NEW: BIND TYPE =====
            local bindType = BIND_TYPE_NONE
            local success5, bind = pcall(GetItemLinkBindType, itemLink)
            if success5 and bind then
                bindType = bind
            end
            
            -- ===== NEW: ITEM VALUE =====
            local itemValue = 0
            local success6, value = pcall(GetItemLinkValue, itemLink, false)
            if success6 and value then
                itemValue = value
            end
            
            -- ===== NEW: CRAFTED STATUS =====
            local isCrafted = false
            local success7, crafted = pcall(IsItemLinkCrafted, itemLink)
            if success7 then
                isCrafted = crafted
            end
            
            -- ===== NEW: ITEM CLASSIFICATION =====
            local armorType = ARMOR_TYPE_NONE
            local weaponType = WEAPON_TYPE_NONE
            local craftedQuality = ITEM_QUALITY_NONE
            local isStolen = false
            
            local success8, armor = pcall(GetItemLinkArmorType, itemLink)
            if success8 and armor then
                armorType = armor
            end
            
            local success9, weapon = pcall(GetItemLinkWeaponType, itemLink)
            if success9 and weapon then
                weaponType = weapon
            end
            
            local success10, craftedQual = pcall(GetItemLinkCraftedQuality, itemLink)
            if success10 and craftedQual then
                craftedQuality = craftedQual
            end
            
            local success11, stolen = pcall(GetItemLinkStolen, itemLink)
            if success11 then
                isStolen = stolen
            end
            
            -- ===== NEW: ITEM DETAILS =====
            local flavorText = ""
            local originalItemLink = ""
            
            local success12, flavor = pcall(GetItemLinkFlavorText, itemLink)
            if success12 and flavor and flavor ~= "" then
                flavorText = flavor
            end
            
            local success13, originalItem = pcall(GetItemLinkClothierOriginalItem, itemLink)
            if success13 and originalItem and originalItem ~= "" then
                originalItemLink = originalItem
            end
            
            table.insert(equipment.items, {
                slotIndex = slotIndex,
                slotName = CM.utils.GetEquipSlotName(slotIndex),
                emoji = CM.utils.GetSlotEmoji(slotIndex),
                name = itemName,
                setName = (hasSet and setName) and setName or "-",
                quality = CM.utils.GetQualityColor(quality),
                qualityEmoji = CM.utils.GetQualityEmoji(quality),
                trait = traitName,
                isEmpty = false,
                -- NEW FIELDS (Tier 1)
                enchantment = enchantName or false,
                enchantIcon = enchantIcon,
                enchantCharge = enchantCharge,
                enchantMaxCharge = enchantMaxCharge,
                style = itemStyle,
                requiredLevel = requiredLevel,
                requiredCP = requiredCP,
                bindType = bindType,
                value = itemValue,
                isCrafted = isCrafted,
                -- NEW FIELDS (Item Classification)
                armorType = armorType,
                weaponType = weaponType,
                craftedQuality = craftedQuality,
                isStolen = isStolen,
                -- NEW FIELDS (Item Details)
                flavorText = flavorText,
                originalItemLink = originalItemLink
            })
        end
    end
    
    return equipment
end

CM.collectors.CollectEquipmentData = CollectEquipmentData

-- =====================================================
-- MUNDUS STONE
-- =====================================================

local function CollectMundusData()
    local data = { active = false, name = nil }
    
    local mundusStones = {
        ["The Apprentice"] = true, ["The Atronach"] = true, ["The Lady"] = true,
        ["The Lord"] = true, ["The Lover"] = true, ["The Mage"] = true,
        ["The Ritual"] = true, ["The Serpent"] = true, ["The Shadow"] = true,
        ["The Steed"] = true, ["The Thief"] = true, ["The Tower"] = true,
        ["The Warrior"] = true,
        ["Boon: The Apprentice"] = "The Apprentice",
        ["Boon: The Atronach"] = "The Atronach",
        ["Boon: The Lady"] = "The Lady",
        ["Boon: The Lord"] = "The Lord",
        ["Boon: The Lover"] = "The Lover",
        ["Boon: The Mage"] = "The Mage",
        ["Boon: The Ritual"] = "The Ritual",
        ["Boon: The Serpent"] = "The Serpent",
        ["Boon: The Shadow"] = "The Shadow",
        ["Boon: The Steed"] = "The Steed",
        ["Boon: The Thief"] = "The Thief",
        ["Boon: The Tower"] = "The Tower",
        ["Boon: The Warrior"] = "The Warrior",
    }
    
    local numBuffs = GetNumBuffs("player") or 0
    
    for i = 1, numBuffs do
        local buffName = GetUnitBuffInfo("player", i)
        
        if buffName then
            local mundusMatch = mundusStones[buffName]
            if mundusMatch then
                data.active = true
                data.name = type(mundusMatch) == "string" and mundusMatch or buffName
                break
            end
        end
    end
    
    return data
end

CM.collectors.CollectMundusData = CollectMundusData

-- =====================================================
-- ACTIVE BUFFS
-- =====================================================

local function CollectActiveBuffs()
    local buffs = { food = nil, potion = nil, other = {} }
    
    local foodKeywords = {"Food", "Drink", "Broth", "Stew", "Soup", "Meal", "Feast"}
    local potionKeywords = {"Potion", "Elixir", "Draught", "Tonic"}
    
    local numBuffs = GetNumBuffs("player") or 0
    
    for i = 1, numBuffs do
        local buffName = GetUnitBuffInfo("player", i)
        
        if buffName and buffName ~= "" then
            local isFood = false
            local isPotion = false
            
            for _, keyword in ipairs(foodKeywords) do
                if buffName:find(keyword) then
                    isFood = true
                    break
                end
            end
            
            if not isFood then
                for _, keyword in ipairs(potionKeywords) do
                    if buffName:find(keyword) then
                        isPotion = true
                        break
                    end
                end
            end
            
            if isFood and not buffs.food then
                buffs.food = buffName
            elseif isPotion and not buffs.potion then
                buffs.potion = buffName
            elseif not isFood and not isPotion and #buffs.other < 5 then
                local isMundus = buffName:find("^The ") or buffName:find("^Boon:")
                if not isMundus then
                    table.insert(buffs.other, buffName)
                end
            end
        end
    end
    
    return buffs
end

CM.collectors.CollectActiveBuffs = CollectActiveBuffs
