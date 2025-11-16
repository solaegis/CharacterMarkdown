-- CharacterMarkdown - Titles & Housing Data Collector
-- Titles, housing collections, and housing progress

local CM = CharacterMarkdown

-- Cached globals - standard ESO APIs
local GetNumTitles = GetNumTitles
local GetTitle = GetTitle
local GetTitles = GetTitles
local GetCollectibleName = GetCollectibleName
local GetCollectibleCategoryType = GetCollectibleCategoryType
local IsCollectibleUnlocked = IsCollectibleUnlocked
-- GetUnitTitle and GetPrimaryHouse may be newer APIs, handled via rawget for safety

-- =====================================================
-- TITLES
-- =====================================================

local function CollectTitlesData()
    local titles = {
        current = "",
        total = 0,
        owned = 0,
        list = {},
    }

    -- Get current title using shared utility function
    titles.current = CM.utils.GetPlayerTitle() or ""

    -- Get titles using GetTitles() API function to get owned title IDs
    local ownedTitleIds = CM.SafeCall(GetTitles)
    if ownedTitleIds and #ownedTitleIds > 0 then
        -- Get title names for owned titles using GetTitle()
        for _, titleId in ipairs(ownedTitleIds) do
            local titleName = CM.SafeCall(GetTitle, titleId)
            if titleName and titleName ~= "" then
                titles.owned = titles.owned + 1
                table.insert(titles.list, {
                    name = titleName,
                    unlocked = true,
                    index = titleId,
                })
            end
        end

        -- Get total number of titles for progress calculation
        local totalTitles = CM.SafeCall(GetNumTitles)
        if totalTitles then
            titles.total = totalTitles
        end

        -- Sort by name
        table.sort(titles.list, function(a, b)
            return a.name < b.name
        end)
    else
        -- Fallback: Use GetNumTitles() and iterate through all title indices
        -- Note: GetNumTitles() returns the maximum title index, but indices are sparse (gaps for unlocked titles)
        -- GetTitle(i) only returns non-empty strings for unlocked titles, so we skip gaps automatically
        local maxTitleIndex = CM.SafeCall(GetNumTitles)
        if maxTitleIndex then
            titles.total = maxTitleIndex

            -- Iterate through all possible indices (including gaps)
            -- GetTitle(i) returns empty string for locked titles, so we only process non-empty results
            for i = 1, maxTitleIndex do
                local titleName = CM.SafeCall(GetTitle, i)
                if titleName and titleName ~= "" then
                    -- Title is unlocked (GetTitle only returns non-empty for unlocked titles)
                    titles.owned = titles.owned + 1
                    table.insert(titles.list, {
                        name = titleName,
                        unlocked = true,
                        index = i,
                    })
                end
                -- Note: We intentionally skip empty strings (locked titles with gaps in index)
            end

            -- Sort by name
            table.sort(titles.list, function(a, b)
                return a.name < b.name
            end)
        end
    end

    return titles
end

-- =====================================================
-- HOUSING
-- =====================================================

local function CollectHousingData()
    local housing = {
        total = 0,
        owned = 0,
        primary = "",
        houses = {},
    }

    -- Use collectibles API to get houses
    -- Iterate through collectibles to find houses
    -- Note: Constants are always available if referenced
    if COLLECTIBLE_CATEGORY_TYPE_HOUSE then
        -- Iterate through collectible IDs to find houses
        local MAX_COLLECTIBLE_ID = 10000
        for collectibleId = 1, MAX_COLLECTIBLE_ID do
            local name = CM.SafeCall(GetCollectibleName, collectibleId)
            if name and name ~= "" then
                local categoryType = CM.SafeCall(GetCollectibleCategoryType, collectibleId)
                if categoryType == COLLECTIBLE_CATEGORY_TYPE_HOUSE then
                    housing.total = housing.total + 1

                    local isUnlocked = CM.SafeCall(IsCollectibleUnlocked, collectibleId)
                    if isUnlocked then
                        housing.owned = housing.owned + 1

                        table.insert(housing.houses, {
                            id = collectibleId,
                            name = name,
                            owned = true,
                            index = collectibleId,
                        })
                    else
                        -- Track locked houses too for total count
                        table.insert(housing.houses, {
                            id = collectibleId,
                            name = name,
                            owned = false,
                            index = collectibleId,
                        })
                    end
                end
            end
        end

        -- Try to get primary residence using housing API (if available)
        -- Note: GetPrimaryHouse may be a newer API function
        local GetPrimaryHouseFunc = rawget(_G, "GetPrimaryHouse")
        if GetPrimaryHouseFunc and type(GetPrimaryHouseFunc) == "function" then
            local primaryHouseId = CM.SafeCall(GetPrimaryHouseFunc)
            if primaryHouseId then
                -- Find the house name from our collected houses
                for _, house in ipairs(housing.houses) do
                    if house.id == primaryHouseId then
                        housing.primary = house.name
                        break
                    end
                end
            end
        end

        -- Sort by name
        table.sort(housing.houses, function(a, b)
            return a.name < b.name
        end)
    else
        -- Fallback to old housing API if collectibles API not available
        -- Note: These are deprecated APIs that may not exist
        local GetNumHousesFunc = rawget(_G, "GetNumHouses")
        local GetHouseInfoFunc = rawget(_G, "GetHouseInfo")
        local GetHousePrimaryResidenceFunc = rawget(_G, "GetHousePrimaryResidence")

        if GetNumHousesFunc and GetHouseInfoFunc then
            local numHouses = CM.SafeCall(GetNumHousesFunc)
            if numHouses then
                housing.total = numHouses

                -- Get all houses
                for i = 1, numHouses do
                    local houseId, houseName, isOwned = CM.SafeCall(GetHouseInfoFunc, i)
                    if houseId and houseName then
                        if isOwned then
                            housing.owned = housing.owned + 1

                            -- Check if this is the primary residence
                            if GetHousePrimaryResidenceFunc then
                                local isPrimary = CM.SafeCall(GetHousePrimaryResidenceFunc, houseId)
                                if isPrimary then
                                    housing.primary = houseName
                                end
                            end
                        end

                        table.insert(housing.houses, {
                            id = houseId,
                            name = houseName,
                            owned = isOwned or false,
                            index = i,
                        })
                    end
                end

                -- Sort by name
                table.sort(housing.houses, function(a, b)
                    return a.name < b.name
                end)
            end
        end
    end

    return housing
end

-- =====================================================
-- HOUSING COLLECTIONS
-- =====================================================

local function CollectHousingCollectionsData()
    local collections = {
        furniture = {
            total = 0,
            owned = 0,
            categories = {},
        },
        decorations = {
            total = 0,
            owned = 0,
            categories = {},
        },
        furnishingPacks = {
            total = 0,
            owned = 0,
            items = {},
        },
    }

    -- Use collectibles API to get housing collectibles (furnishings, furnishing packs, decorations)
    -- Note: Constants are always available if referenced
    -- Iterate through collectible IDs to find housing collectibles
    local MAX_COLLECTIBLE_ID = 10000
    for collectibleId = 1, MAX_COLLECTIBLE_ID do
        local name = CM.SafeCall(GetCollectibleName, collectibleId)
        if name and name ~= "" then
            local isUnlocked = CM.SafeCall(IsCollectibleUnlocked, collectibleId)
            if isUnlocked then
                local categoryType = CM.SafeCall(GetCollectibleCategoryType, collectibleId)
                if categoryType then
                    -- Skip non-housing categories explicitly
                    if
                        categoryType == COLLECTIBLE_CATEGORY_TYPE_MOUNT
                        or categoryType == COLLECTIBLE_CATEGORY_TYPE_VANITY_PET
                        or categoryType == COLLECTIBLE_CATEGORY_TYPE_HOUSE
                        or categoryType == COLLECTIBLE_CATEGORY_TYPE_COSTUME
                        or categoryType == COLLECTIBLE_CATEGORY_TYPE_EMOTE
                        or categoryType == COLLECTIBLE_CATEGORY_TYPE_MEMENTO
                        or categoryType == COLLECTIBLE_CATEGORY_TYPE_SKIN
                        or categoryType == COLLECTIBLE_CATEGORY_TYPE_POLYMORPH
                        or categoryType == COLLECTIBLE_CATEGORY_TYPE_PERSONALITY
                    then
                        -- Skip this collectible - not a housing item
                        -- Group by category type
                    elseif categoryType == COLLECTIBLE_CATEGORY_TYPE_FURNISHING then
                        collections.furniture.total = collections.furniture.total + 1
                        collections.furniture.owned = collections.furniture.owned + 1

                        -- Group into categories if we can determine the type (for now, just store all)
                        if not collections.furniture.categories["All"] then
                            collections.furniture.categories["All"] = {
                                name = "All",
                                total = 0,
                                owned = 0,
                                items = {},
                            }
                        end
                        table.insert(collections.furniture.categories["All"].items, {
                            id = collectibleId,
                            name = name,
                            owned = true,
                        })
                        collections.furniture.categories["All"].total = collections.furniture.categories["All"].total
                            + 1
                        collections.furniture.categories["All"].owned = collections.furniture.categories["All"].owned
                            + 1
                    elseif categoryType == COLLECTIBLE_CATEGORY_TYPE_FURNISHING_PACK then
                        collections.furnishingPacks.total = collections.furnishingPacks.total + 1
                        collections.furnishingPacks.owned = collections.furnishingPacks.owned + 1

                        table.insert(collections.furnishingPacks.items, {
                            id = collectibleId,
                            name = name,
                            owned = true,
                        })
                    else
                        -- Check if it's a housing decoration (might have a different category type)
                        -- For now, track unknown housing-related categories
                        local categoryStr = tostring(categoryType)
                        if not collections.decorations.categories[categoryStr] then
                            collections.decorations.categories[categoryStr] = {
                                name = "Category " .. categoryStr,
                                total = 0,
                                owned = 0,
                                items = {},
                            }
                        end
                        collections.decorations.total = collections.decorations.total + 1
                        collections.decorations.owned = collections.decorations.owned + 1
                        table.insert(collections.decorations.categories[categoryStr].items, {
                            id = collectibleId,
                            name = name,
                            owned = true,
                        })
                        collections.decorations.categories[categoryStr].total = collections.decorations.categories[categoryStr].total
                            + 1
                        collections.decorations.categories[categoryStr].owned = collections.decorations.categories[categoryStr].owned
                            + 1
                    end
                end
            end
        end
    end

    -- Sort items by name in each category
    for _, categoryData in pairs(collections.furniture.categories) do
        table.sort(categoryData.items, function(a, b)
            return a.name < b.name
        end)
    end
    for _, categoryData in pairs(collections.decorations.categories) do
        table.sort(categoryData.items, function(a, b)
            return a.name < b.name
        end)
    end
    table.sort(collections.furnishingPacks.items, function(a, b)
        return a.name < b.name
    end)

    -- Note: Fallback to old furniture API removed - collectibles API is standard

    return collections
end

-- =====================================================
-- MAIN TITLES & HOUSING COLLECTOR
-- =====================================================

local function CollectTitlesHousingData()
    return {
        titles = CollectTitlesData(),
        housing = CollectHousingData(),
        collections = CollectHousingCollectionsData(),
    }
end

CM.collectors.CollectTitlesHousingData = CollectTitlesHousingData
