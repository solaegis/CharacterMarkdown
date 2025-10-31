-- CharacterMarkdown - Companion Data Collector
-- Active companion information

local CM = CharacterMarkdown

-- =====================================================
-- COMPANION
-- =====================================================

local function CollectCompanionData()
    local companion = { active = false }
    
    if not HasActiveCompanion() then
        return companion
    end
    
    companion.active = true
    companion.name = GetUnitName("companion") or "Unknown Companion"
    companion.level = GetUnitLevel("companion") or 0
    
    -- Skills
    local success, companionSkills = pcall(function()
        local skills = { ultimate = nil, ultimateId = nil, abilities = {} }
        
        local ultimateSlotId = GetSlotBoundId(8, HOTBAR_CATEGORY_COMPANION)
        if ultimateSlotId and ultimateSlotId > 0 then
            skills.ultimate = GetAbilityName(ultimateSlotId) or "[Empty]"
            skills.ultimateId = ultimateSlotId
        else
            skills.ultimate = "[Empty]"
        end
        
        -- Companions have 8 ability slots total (excluding ultimate which is slot 8)
        -- Slots 1-7 plus potentially slot 0, or slots 1-8 (with 8 being a regular ability slot, not ultimate)
        -- Collect all 8 ability slots to match "X/8 abilities slotted" status display
        -- Note: Ultimate is handled separately (slot 8), but companions may have 8 regular ability slots
        -- Try slots 0-7 first (8 slots), if that doesn't work we'll need to investigate slot structure
        for slotIndex = 0, 7 do
            local slotId = GetSlotBoundId(slotIndex, HOTBAR_CATEGORY_COMPANION)
            if slotId and slotId > 0 then
                local abilityName = GetAbilityName(slotId)
                table.insert(skills.abilities, {
                    name = (abilityName and abilityName ~= "") and abilityName or "[Empty]",
                    id = slotId
                })
            else
                table.insert(skills.abilities, {
                    name = "[Empty]",
                    id = nil
                })
            end
        end
        
        return skills
    end)
    
    if success and companionSkills then
        companion.skills = companionSkills
    end
    
    -- Equipment
    local equipment = {}
    local equipSlots = {
        {slot = EQUIP_SLOT_MAIN_HAND, name = "Main Hand"}, 
        {slot = EQUIP_SLOT_OFF_HAND, name = "Off Hand"},
        {slot = EQUIP_SLOT_HEAD, name = "Head"}, 
        {slot = EQUIP_SLOT_CHEST, name = "Chest"},
        {slot = EQUIP_SLOT_SHOULDERS, name = "Shoulders"}, 
        {slot = EQUIP_SLOT_HAND, name = "Hands"},
        {slot = EQUIP_SLOT_WAIST, name = "Waist"}, 
        {slot = EQUIP_SLOT_LEGS, name = "Legs"},
        {slot = EQUIP_SLOT_FEET, name = "Feet"},
    }
    
    for _, slotInfo in ipairs(equipSlots) do
        local success2, itemName = pcall(function() 
            return GetItemName(BAG_COMPANION_WORN, slotInfo.slot) 
        end)
        
        if success2 and itemName and itemName ~= "" then
            local itemLink = GetItemLink(BAG_COMPANION_WORN, slotInfo.slot, LINK_STYLE_DEFAULT)
            local quality = GetItemLinkQuality(itemLink)
            local itemLevel = GetItemLinkRequiredLevel(itemLink) or 0
            
            table.insert(equipment, { 
                slot = slotInfo.name, 
                name = itemName, 
                quality = CM.utils.GetQualityColor(quality),
                level = itemLevel
            })
        end
    end
    
    companion.equipment = equipment
    
    return companion
end

CM.collectors.CollectCompanionData = CollectCompanionData
