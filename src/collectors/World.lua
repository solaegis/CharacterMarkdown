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

-- Category definitions
local COLLECTIBLE_CATEGORIES = {
    {type = COLLECTIBLE_CATEGORY_TYPE_MOUNT, key = "mounts", emoji = "🐴", name = "Mounts"},
    {type = COLLECTIBLE_CATEGORY_TYPE_VANITY_PET, key = "pets", emoji = "🐾", name = "Pets"},
    {type = COLLECTIBLE_CATEGORY_TYPE_COSTUME, key = "costumes", emoji = "👗", name = "Costumes"},
    {type = COLLECTIBLE_CATEGORY_TYPE_HOUSE, key = "houses", emoji = "🏠", name = "Houses"},
    {type = COLLECTIBLE_CATEGORY_TYPE_EMOTE, key = "emotes", emoji = "🎭", name = "Emotes"},
    {type = COLLECTIBLE_CATEGORY_TYPE_MEMENTO, key = "mementos", emoji = "🎪", name = "Mementos"},
    {type = COLLECTIBLE_CATEGORY_TYPE_SKIN, key = "skins", emoji = "🎨", name = "Skins"},
    {type = COLLECTIBLE_CATEGORY_TYPE_POLYMORPH, key = "polymorphs", emoji = "🦎", name = "Polymorphs"},
    {type = COLLECTIBLE_CATEGORY_TYPE_PERSONALITY, key = "personalities", emoji = "🎭", name = "Personalities"},
}

-- Quality names mapping (if quality info is available)
local QUALITY_NAMES = {
    [0] = "Normal",
    [1] = "Fine",
    [2] = "Superior",
    [3] = "Epic",
    [4] = "Legendary",
    [5] = "Mythic",
}

local function CollectCollectiblesData()
    local collectibles = {
        categories = {},
        hasDetailedData = false
    }
    
    -- Get settings to check if detailed collection is enabled
    local settings = CharacterMarkdownSettings or {}
    local includeDetailed = settings.includeCollectiblesDetailed or false
    
    for _, category in ipairs(COLLECTIBLE_CATEGORIES) do
        local categoryData = {
            name = category.name,
            emoji = category.emoji,
            owned = {},
            total = 0
        }
        
        local success, total = pcall(function()
            return GetTotalCollectiblesByCategoryType(category.type)
        end)
        
        if success and total then
            categoryData.total = total
            
            -- If detailed mode is enabled, collect individual collectibles
            if includeDetailed then
                for i = 1, total do
                    local collectibleSuccess, collectibleId = pcall(function()
                        return GetCollectibleIdFromType(category.type, i)
                    end)
                    
                    if collectibleSuccess and collectibleId then
                        local infoSuccess, name, _, _, unlocked = pcall(function()
                            return GetCollectibleInfo(collectibleId)
                        end)
                        
                        if infoSuccess and unlocked then
                            -- Get nickname if available (for mounts/pets)
                            local nickname = ""
                            local nicknameSuccess, nick = pcall(function()
                                return GetCollectibleNickname(collectibleId)
                            end)
                            if nicknameSuccess and nick and nick ~= "" then
                                nickname = nick
                            end
                            
                            local displayName = (nickname ~= "" and nickname) or name or "Unknown"
                            
                            -- Try to get quality/rarity if available
                            local quality = nil
                            local qualitySuccess, qual = pcall(function()
                                return GetCollectibleQuality(collectibleId)
                            end)
                            if qualitySuccess and qual then
                                quality = QUALITY_NAMES[qual] or nil
                            end
                            
                            table.insert(categoryData.owned, {
                                id = collectibleId,
                                name = displayName,
                                fullName = name,
                                quality = quality
                            })
                        end
                    end
                end
                
                -- Sort alphabetically by name
                table.sort(categoryData.owned, function(a, b)
                    return a.name < b.name
                end)
                
                collectibles.hasDetailedData = true
            end
        else
            categoryData.total = 0
        end
        
        collectibles.categories[category.key] = categoryData
    end
    
    -- Legacy fields for backward compatibility (simple count mode)
    collectibles.mounts = collectibles.categories.mounts.total or 0
    collectibles.pets = collectibles.categories.pets.total or 0
    collectibles.costumes = collectibles.categories.costumes.total or 0
    collectibles.houses = collectibles.categories.houses.total or 0
    
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
