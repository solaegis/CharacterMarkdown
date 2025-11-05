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
        
        -- Companions have 5 regular ability slots (API slots 3-7) and 1 ultimate slot (API slot 8)
        -- Slots unlock as companion levels: 2 slots at start, +1 at level 2, +1 at level 7, +1 at level 12, ultimate at level 20
        -- Slot 3 is the first ability slot (where Provoke goes), then slots 4-7 are the remaining 4 abilities
        local ultimateSlotId = GetSlotBoundId(8, HOTBAR_CATEGORY_COMPANION)
        if ultimateSlotId and ultimateSlotId > 0 then
            skills.ultimate = GetAbilityName(ultimateSlotId) or "[Empty]"
            skills.ultimateId = ultimateSlotId
        else
            skills.ultimate = "[Empty]"
        end
        
        -- Collect regular ability slots 3-7 (slot 3 is Provoke/first, then 4-7 for remaining 4)
        -- This makes API slot 3 (Provoke) display as slot 1, API slot 4 as slot 2, etc.
        for slotIndex = 3, 7 do
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
