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
    location.zoneIndex = CM.SafeCall(GetUnitZoneIndex, "player") or 0  -- Zone index/number
    
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
-- Note: Houses are excluded from collectibles since they have their own dedicated section
local COLLECTIBLE_CATEGORIES = {
    {type = COLLECTIBLE_CATEGORY_TYPE_MOUNT, key = "mounts", emoji = "🐴", name = "Mounts"},
    {type = COLLECTIBLE_CATEGORY_TYPE_VANITY_PET, key = "pets", emoji = "🐾", name = "Pets"},
    {type = COLLECTIBLE_CATEGORY_TYPE_COSTUME, key = "costumes", emoji = "👗", name = "Costumes"},
    -- {type = COLLECTIBLE_CATEGORY_TYPE_HOUSE, key = "houses", emoji = "🏠", name = "Houses"}, -- Excluded: shown in Housing section
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
            total = 0,
            ownedCount = 0  -- Count of owned collectibles
        }
        
        local success, total = pcall(function()
            return GetTotalCollectiblesByCategoryType(category.type)
        end)
        
        if success and total then
            categoryData.total = total
            
            -- Count owned collectibles by checking each one (always count, not just in detailed mode)
            local ownedCount = 0
            for i = 1, total do
                local collectibleSuccess, collectibleId = pcall(function()
                    return GetCollectibleIdFromType(category.type, i)
                end)
                
                if collectibleSuccess and collectibleId then
                    -- Check if collectible is actually owned using IsCollectibleUnlocked
                    local isOwned = false
                    local ownedSuccess, owned = pcall(IsCollectibleUnlocked, collectibleId)
                    if ownedSuccess then
                        isOwned = owned or false
                    else
                        -- Fallback: try GetCollectibleInfo (5th parameter is unlocked status)
                        local infoSuccess, name, _, _, unlocked = pcall(function()
                            return GetCollectibleInfo(collectibleId)
                        end)
                        if infoSuccess then
                            isOwned = unlocked or false
                        end
                    end
                    
                    if isOwned then
                        ownedCount = ownedCount + 1
                        
                        -- Get collectible name (always collect for potential display)
                        local name = ""
                        local infoSuccess, collectibleName = pcall(function()
                            local n = GetCollectibleInfo(collectibleId)
                            return n
                        end)
                        if infoSuccess and collectibleName then
                            name = collectibleName
                        end
                        
                        -- Always collect individual collectibles data if owned
                        -- This allows display even if includeDetailed setting is off
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
            
            categoryData.ownedCount = ownedCount
            
            -- Sort alphabetically by display name (case-insensitive) if we have owned items
            if #categoryData.owned > 0 then
                table.sort(categoryData.owned, function(a, b)
                    -- Sort by display name (what's shown), case-insensitive
                    local nameA = (a.name or ""):lower()
                    local nameB = (b.name or ""):lower()
                    return nameA < nameB
                end)
                collectibles.hasDetailedData = true
            end
        else
            categoryData.total = 0
            categoryData.ownedCount = 0
        end
        
        collectibles.categories[category.key] = categoryData
    end
    
    -- Legacy fields for backward compatibility (simple count mode)
    -- Use ownedCount (what player has) instead of total (what exists in game)
    collectibles.mounts = collectibles.categories.mounts and collectibles.categories.mounts.ownedCount or 0
    collectibles.pets = collectibles.categories.pets and collectibles.categories.pets.ownedCount or 0
    collectibles.costumes = collectibles.categories.costumes and collectibles.categories.costumes.ownedCount or 0
    collectibles.houses = collectibles.categories.houses and collectibles.categories.houses.ownedCount or 0
    
    return collectibles
end

CM.collectors.CollectCollectiblesData = CollectCollectiblesData

-- =====================================================
-- CRAFTING KNOWLEDGE
-- =====================================================

local function CollectCraftingKnowledgeData()
    local crafting = {
        motifs = {},
        recipes = {},
        research = {},
        timers = {}
    }
    
    -- ===== MOTIFS =====
    local function CollectMotifs()
        local motifs = {}
        
        -- Get all style pages
        local success, numPages = pcall(GetNumSmithingStylePages)
        if success and numPages then
            for pageIndex = 1, numPages do
                local success2, pageName, pageCategory, pageSubcategory = pcall(GetSmithingStylePageInfo, pageIndex)
                if success2 and pageName and pageName ~= "" then
                    local success3, isKnown = pcall(IsSmithingStyleKnown, pageIndex)
                    table.insert(motifs, {
                        name = pageName,
                        category = pageCategory,
                        subcategory = pageSubcategory,
                        known = (success3 and isKnown) or false,
                        pageIndex = pageIndex
                    })
                end
            end
        end
        
        return motifs
    end
    
    -- ===== RESEARCH =====
    local function CollectResearch()
        local research = {
            blacksmithing = {},
            clothing = {},
            woodworking = {},
            jewelry = {}
        }
        
        -- Get research lines for each craft
        local craftTypes = {
            {name = "blacksmithing", func = GetNumSmithingResearchLines},
            {name = "clothing", func = GetNumSmithingResearchLines},
            {name = "woodworking", func = GetNumSmithingResearchLines},
            {name = "jewelry", func = GetNumSmithingResearchLines}
        }
        
        for _, craftType in ipairs(craftTypes) do
            local success, numLines = pcall(craftType.func)
            if success and numLines then
                for lineIndex = 1, numLines do
                    local success2, lineName, numTraits, timeRequired = pcall(GetSmithingResearchLineInfo, lineIndex)
                    if success2 and lineName and lineName ~= "" then
                        local success3, traitTimes = pcall(GetSmithingResearchLineTraitTimes, lineIndex)
                        table.insert(research[craftType.name], {
                            name = lineName,
                            numTraits = numTraits or 0,
                            timeRequired = timeRequired or 0,
                            traitTimes = (success3 and traitTimes) or {},
                            lineIndex = lineIndex
                        })
                    end
                end
            end
        end
        
        return research
    end
    
    -- Collect all crafting data
    crafting.motifs = CollectMotifs()
    crafting.recipes = CollectResearch()  -- Map research to recipes for generator compatibility
    
    return crafting
end

CM.collectors.CollectCraftingKnowledgeData = CollectCraftingKnowledgeData

-- =====================================================
-- WORLD PROGRESS
-- =====================================================

-- ===== SKYSHARDS =====
local function CollectSkyshardsData()
    local skyshards = {
        total = 0,
        collected = 0,
        zones = {}
    }
    
    -- Get current zone
    local currentZone = GetUnitZone("player")
    if currentZone and currentZone ~= "" then
        local success, totalInZone = pcall(GetNumSkyshardsInZone)
        if success and totalInZone then
            skyshards.total = totalInZone
            
            -- Count collected skyshards in current zone
            local collected = 0
            for i = 1, totalInZone do
                local success2, isCollected = pcall(GetSkyshardCollectedInZone, i)
                if success2 and isCollected then
                    collected = collected + 1
                end
            end
            skyshards.collected = collected
            
            -- Store zone-specific data
            skyshards.zones[currentZone] = {
                total = totalInZone,
                collected = collected,
                percentage = totalInZone > 0 and math.floor((collected / totalInZone) * 100) or 0
            }
        end
    end
    
    return skyshards
end

-- ===== LOREBOOKS =====
local function CollectLorebooksData()
    local lorebooks = {
        total = 0,
        collected = 0,
        categories = {}
    }
    
    -- Get all lorebook categories
    local success, numCategories = pcall(GetNumLoreCategories)
    if success and numCategories then
        for categoryIndex = 1, numCategories do
            local success2, categoryName, numBooks = pcall(GetLoreCategoryInfo, categoryIndex)
            if success2 and categoryName and numBooks then
                local categoryData = {
                    name = categoryName,
                    total = numBooks,
                    collected = 0,
                    books = {}
                }
                
                -- Get books in this category
                for bookIndex = 1, numBooks do
                    local success3, bookName, isCollected = pcall(GetLoreBookInfo, categoryIndex, bookIndex)
                    if success3 and bookName then
                        if isCollected then
                            categoryData.collected = categoryData.collected + 1
                        end
                        
                        table.insert(categoryData.books, {
                            name = bookName,
                            collected = isCollected or false
                        })
                    end
                end
                
                lorebooks.categories[categoryName] = categoryData
                lorebooks.total = lorebooks.total + numBooks
                lorebooks.collected = lorebooks.collected + categoryData.collected
            end
        end
    end
    
    return lorebooks
end

-- ===== ZONE COMPLETION =====
local function CollectZoneCompletionData()
    local zoneCompletion = {
        currentZone = "",
        completionPercentage = 0,
        zones = {}
    }
    
    -- Get current zone and zone index
    local currentZone = GetUnitZone("player")
    if currentZone and currentZone ~= "" then
        zoneCompletion.currentZone = currentZone
        
        -- Get zone index for POI-based tracking
        local zoneIndex = CM.SafeCall(GetUnitZoneIndex, "player") or 0
        
        -- Try GetZoneCompletionStatus first (if it exists and works)
        local GetZoneCompletionStatusFunc = rawget(_G, "GetZoneCompletionStatus")
        if GetZoneCompletionStatusFunc and type(GetZoneCompletionStatusFunc) == "function" then
            local statusSuccess, percentage = pcall(GetZoneCompletionStatusFunc)
            if statusSuccess and percentage and type(percentage) == "number" then
                -- Accept any valid number (including 0), as 0% is still valid data
                zoneCompletion.completionPercentage = math.floor(percentage)
                -- Store and return if we got a valid percentage
                zoneCompletion.zones[currentZone] = {
                    completionPercentage = zoneCompletion.completionPercentage
                }
                return zoneCompletion
            end
        end
        
        -- Fallback: Try POI-based tracking if available
        local GetPOIInfoFunc = rawget(_G, "GetPOIInfo")
        local GetNumPOIsForDifficultyLevelAndZoneFunc = rawget(_G, "GetNumPOIsForDifficultyLevelAndZone")
        local GetCurrentMapZoneIndexFunc = rawget(_G, "GetCurrentMapZoneIndex")
        
        if GetPOIInfoFunc and type(GetPOIInfoFunc) == "function" and 
           GetNumPOIsForDifficultyLevelAndZoneFunc and type(GetNumPOIsForDifficultyLevelAndZoneFunc) == "function" and
           zoneIndex > 0 then
            -- Use POI-based tracking (more accurate)
            local poiSuccess, numPOIs = pcall(GetNumPOIsForDifficultyLevelAndZoneFunc, 1, zoneIndex) -- Difficulty 1 = normal
            if poiSuccess and numPOIs and numPOIs > 0 then
                local completedPOIs = 0
                for poiIndex = 1, numPOIs do
                    local poiInfoSuccess, _, _, _, completed = pcall(GetPOIInfoFunc, zoneIndex, poiIndex)
                    if poiInfoSuccess and completed then
                        completedPOIs = completedPOIs + 1
                    end
                end
                if numPOIs > 0 then
                    zoneCompletion.completionPercentage = math.floor((completedPOIs / numPOIs) * 100)
                end
            end
        end
        
        -- Fallback: Manual calculation from multiple sources (existing logic)
        if zoneCompletion.completionPercentage == 0 then
            local completionComponents = {
                wayshrines = 0,
                skyshards = 0,
                delves = 0,
                publicDungeons = 0
            }
            
            local totalComponents = {
                wayshrines = 0,
                skyshards = 0,
                delves = 0,
                publicDungeons = 0
            }
            
            -- Wayshrines
            local success1, numWayshrines = pcall(GetNumFastTravelNodes)
            if success1 and numWayshrines then
                totalComponents.wayshrines = numWayshrines
                for i = 1, numWayshrines do
                    local success2, known = pcall(IsFastTravelNodeKnown, i)
                    if success2 and known then
                        completionComponents.wayshrines = completionComponents.wayshrines + 1
                    end
                end
            end
            
            -- Skyshards
            local success3, numSkyshards = pcall(GetNumSkyshardsInZone)
            if success3 and numSkyshards then
                totalComponents.skyshards = numSkyshards
                for i = 1, numSkyshards do
                    local success4, collected = pcall(GetSkyshardCollectedInZone, i)
                    if success4 and collected then
                        completionComponents.skyshards = completionComponents.skyshards + 1
                    end
                end
            end
            
            -- Delves
            local success5, numDelves = pcall(GetNumDelvesInZone)
            if success5 and numDelves then
                totalComponents.delves = numDelves
                for i = 1, numDelves do
                    local success6, _, completed = pcall(GetDelveInfo, i)
                    if success6 and completed then
                        completionComponents.delves = completionComponents.delves + 1
                    end
                end
            end
            
            -- Public Dungeons
            local success7, numPublicDungeons = pcall(GetNumPublicDungeonsInZone)
            if success7 and numPublicDungeons then
                totalComponents.publicDungeons = numPublicDungeons
                for i = 1, numPublicDungeons do
                    local success8, _, completed = pcall(GetPublicDungeonInfo, i)
                    if success8 and completed then
                        completionComponents.publicDungeons = completionComponents.publicDungeons + 1
                    end
                end
            end
            
            -- Calculate weighted completion percentage
            -- Wayshrines: 25%, Skyshards: 25%, Delves: 25%, Public Dungeons: 25%
            local totalWeight = 0
            local completedWeight = 0
            
            -- Wayshrines (25%)
            if totalComponents.wayshrines > 0 then
                local weight = 25
                totalWeight = totalWeight + weight
                completedWeight = completedWeight + (weight * (completionComponents.wayshrines / totalComponents.wayshrines))
            end
            
            -- Skyshards (25%)
            if totalComponents.skyshards > 0 then
                local weight = 25
                totalWeight = totalWeight + weight
                completedWeight = completedWeight + (weight * (completionComponents.skyshards / totalComponents.skyshards))
            end
            
            -- Delves (25%)
            if totalComponents.delves > 0 then
                local weight = 25
                totalWeight = totalWeight + weight
                completedWeight = completedWeight + (weight * (completionComponents.delves / totalComponents.delves))
            end
            
            -- Public Dungeons (25%)
            if totalComponents.publicDungeons > 0 then
                local weight = 25
                totalWeight = totalWeight + weight
                completedWeight = completedWeight + (weight * (completionComponents.publicDungeons / totalComponents.publicDungeons))
            end
            
            -- Calculate final percentage
            if totalWeight > 0 then
                zoneCompletion.completionPercentage = math.floor((completedWeight / totalWeight) * 100)
            end
            
            -- If still 0, and we have at least some components, ensure minimum 1% if any progress made
            if zoneCompletion.completionPercentage == 0 and totalWeight > 0 then
                -- Check if any components were found
                if completionComponents.wayshrines > 0 or completionComponents.skyshards > 0 or 
                   completionComponents.delves > 0 or completionComponents.publicDungeons > 0 then
                    zoneCompletion.completionPercentage = 1  -- At least show some progress
                end
            end
        end
        
        -- Store current zone data
        zoneCompletion.zones[currentZone] = {
            completionPercentage = zoneCompletion.completionPercentage
        }
    end
    
    return zoneCompletion
end

-- ===== DELVES AND PUBLIC DUNGEONS =====
local function CollectDungeonProgressData()
    local dungeons = {
        delves = {
            total = 0,
            completed = 0,
            list = {}
        },
        publicDungeons = {
            total = 0,
            completed = 0,
            list = {}
        }
    }
    
    -- Get current zone for context
    local currentZone = GetUnitZone("player")
    
    -- Try to get delve information
    local success, numDelves = pcall(GetNumDelvesInZone)
    if success and numDelves then
        dungeons.delves.total = numDelves
        
        for i = 1, numDelves do
            local success2, delveName, isCompleted = pcall(GetDelveInfo, i)
            if success2 and delveName then
                if isCompleted then
                    dungeons.delves.completed = dungeons.delves.completed + 1
                end
                
                table.insert(dungeons.delves.list, {
                    name = delveName,
                    completed = isCompleted or false,
                    zone = currentZone
                })
            end
        end
    end
    
    -- Try to get public dungeon information
    local success3, numPublicDungeons = pcall(GetNumPublicDungeonsInZone)
    if success3 and numPublicDungeons then
        dungeons.publicDungeons.total = numPublicDungeons
        
        for i = 1, numPublicDungeons do
            local success4, dungeonName, isCompleted = pcall(GetPublicDungeonInfo, i)
            if success4 and dungeonName then
                if isCompleted then
                    dungeons.publicDungeons.completed = dungeons.publicDungeons.completed + 1
                end
                
                table.insert(dungeons.publicDungeons.list, {
                    name = dungeonName,
                    completed = isCompleted or false,
                    zone = currentZone
                })
            end
        end
    end
    
    return dungeons
end

-- ===== MAIN WORLD PROGRESS COLLECTOR =====
local function CollectWorldProgressData()
    return {
        skyshards = CollectSkyshardsData(),
        lorebooks = CollectLorebooksData(),
        zoneCompletion = CollectZoneCompletionData(),
        dungeons = CollectDungeonProgressData()
    }
end

CM.collectors.CollectWorldProgressData = CollectWorldProgressData
