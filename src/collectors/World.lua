-- CharacterMarkdown - World Data Collector
-- Location, PvP, role, collectibles, crafting

local CM = CharacterMarkdown

-- =====================================================
-- LOCATION
-- =====================================================

local function CollectLocationData()
    local location = {}
    
    location.zone = GetUnitZone("player") or "Unknown"
    location.subzone = GetPlayerActiveSubzoneName() or ""
    
    return location
end

CM.collectors.CollectLocationData = CollectLocationData

-- =====================================================
-- PVP
-- =====================================================

local function CollectPvPData()
    local pvp = {}
    
    pvp.rank = GetUnitAvARank("player") or 0
    pvp.rankName = GetAvARankName(GetUnitGender("player"), pvp.rank) or "Recruit"
    
    local campaignId = GetAssignedCampaignId()
    if campaignId and campaignId > 0 then
        pvp.campaignName = GetCampaignName(campaignId) or "None"
        pvp.campaignId = campaignId
    else
        pvp.campaignName = "None"
        pvp.campaignId = nil
    end
    
    return pvp
end

CM.collectors.CollectPvPData = CollectPvPData

-- =====================================================
-- ROLE
-- =====================================================

local function CollectRoleData()
    local role = {}
    
    local selectedRole = GetGroupMemberSelectedRole("player")
    if selectedRole == LFG_ROLE_TANK then
        role.selected = "Tank"
        role.emoji = "🛡️"
    elseif selectedRole == LFG_ROLE_HEAL then
        role.selected = "Healer"
        role.emoji = "💚"
    elseif selectedRole == LFG_ROLE_DPS then
        role.selected = "DPS"
        role.emoji = "⚔️"
    else
        role.selected = "None"
        role.emoji = "❓"
    end
    
    return role
end

CM.collectors.CollectRoleData = CollectRoleData

-- =====================================================
-- COLLECTIBLES
-- =====================================================

local function CollectCollectiblesData()
    local collectibles = {}
    
    local success1, mountCount = pcall(function()
        return GetTotalCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_MOUNT)
    end)
    collectibles.mounts = (success1 and mountCount) or 0
    
    local success2, petCount = pcall(function()
        return GetTotalCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_VANITY_PET)
    end)
    collectibles.pets = (success2 and petCount) or 0
    
    local success3, costumeCount = pcall(function()
        return GetTotalCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_COSTUME)
    end)
    collectibles.costumes = (success3 and costumeCount) or 0
    
    local success4, houseCount = pcall(function()
        return GetTotalCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_HOUSE)
    end)
    collectibles.houses = (success4 and houseCount) or 0
    
    return collectibles
end

CM.collectors.CollectCollectiblesData = CollectCollectiblesData

-- =====================================================
-- CRAFTING KNOWLEDGE
-- =====================================================

local function CollectCraftingKnowledgeData()
    local crafting = {}
    
    crafting.motifs = {
        known = 0,
        total = 0,
        percent = 0
    }
    
    local researchCount = 0
    local success, count = pcall(function()
        local total = 0
        for craftingType = 1, 3 do
            local numLines = GetNumSmithingResearchLines(craftingType)
            if numLines then
                for line = 1, numLines do
                    local _, _, numTraits = GetSmithingResearchLineInfo(craftingType, line)
                    if numTraits then
                        for trait = 1, numTraits do
                            local duration, timeRemaining = GetSmithingResearchLineTraitTimes(craftingType, line, trait)
                            if duration and duration > 0 and timeRemaining and timeRemaining > 0 then
                                total = total + 1
                            end
                        end
                    end
                end
            end
        end
        return total
    end)
    
    crafting.activeResearch = (success and count) or 0
    
    return crafting
end

CM.collectors.CollectCraftingKnowledgeData = CollectCraftingKnowledgeData
