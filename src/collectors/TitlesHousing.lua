-- CharacterMarkdown - Titles & Housing Data Collector
-- Titles, housing collections, and housing progress

local CM = CharacterMarkdown

-- =====================================================
-- TITLES
-- =====================================================

local function CollectTitlesData()
    local titles = {
        current = "",
        total = 0,
        owned = 0,
        list = {}
    }
    
    -- Check if title API functions exist
    local GetNumTitlesFunc = rawget(_G, "GetNumTitles")
    local GetCurrentTitleFunc = rawget(_G, "GetCurrentTitle")
    local GetTitleNameFunc = rawget(_G, "GetTitleName")
    local IsTitleKnownFunc = rawget(_G, "IsTitleKnown")
    
    -- Get current title (check for custom title first)
    local customTitle = ""
    if CM.charData then
        customTitle = CM.charData.customTitle or ""
    end
    
    if customTitle and customTitle ~= "" then
        titles.current = customTitle
    else
        -- Use GetCurrentTitle() to get current title index, then GetTitleName()
        if GetCurrentTitleFunc and type(GetCurrentTitleFunc) == "function" then
            local success, currentTitleIndex = pcall(GetCurrentTitleFunc)
            if success and currentTitleIndex and currentTitleIndex > 0 then
                if GetTitleNameFunc and type(GetTitleNameFunc) == "function" then
                    local nameSuccess, titleName = pcall(GetTitleNameFunc, currentTitleIndex)
                    if nameSuccess and titleName and titleName ~= "" then
                        titles.current = titleName
                    end
                end
            end
        end
    end
    
    -- Get total number of titles using GetNumTitles() (correct API)
    if GetNumTitlesFunc and type(GetNumTitlesFunc) == "function" then
        local success2, totalTitles = pcall(GetNumTitlesFunc)
        if success2 and totalTitles then
            titles.total = totalTitles
            
            -- Get all titles using GetTitleName() and IsTitleKnown() (correct API)
            if GetTitleNameFunc and type(GetTitleNameFunc) == "function" and
               IsTitleKnownFunc and type(IsTitleKnownFunc) == "function" then
                for i = 1, totalTitles do
                    local nameSuccess, titleName = pcall(GetTitleNameFunc, i)
                    if nameSuccess and titleName and titleName ~= "" then
                        local knownSuccess, isUnlocked = pcall(IsTitleKnownFunc, i)
                        if knownSuccess and isUnlocked then
                            titles.owned = titles.owned + 1
                        end
                        
                        table.insert(titles.list, {
                            name = titleName,
                            unlocked = (knownSuccess and isUnlocked) or false,
                            index = i
                        })
                    end
                end
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
        houses = {}
    }
    
    -- Get total number of houses
    local success, numHouses = pcall(GetNumHouses)
    if success and numHouses then
        housing.total = numHouses
        
        -- Get all houses
        for i = 1, numHouses do
            local success2, houseId, houseName, isOwned = pcall(GetHouseInfo, i)
            if success2 and houseId and houseName then
                if isOwned then
                    housing.owned = housing.owned + 1
                    
                    -- Check if this is the primary residence
                    local success3, isPrimary = pcall(GetHousePrimaryResidence, houseId)
                    if success3 and isPrimary then
                        housing.primary = houseName
                    end
                end
                
                table.insert(housing.houses, {
                    id = houseId,
                    name = houseName,
                    owned = isOwned or false,
                    index = i
                })
            end
        end
        
        -- Sort by name
        table.sort(housing.houses, function(a, b)
            return a.name < b.name
        end)
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
            categories = {}
        },
        decorations = {
            total = 0,
            owned = 0,
            categories = {}
        }
    }
    
    -- Furniture categories
    local furnitureCategories = {
        {type = FURNITURE_CATEGORY_TYPE_CHAIR, name = "Chairs"},
        {type = FURNITURE_CATEGORY_TYPE_TABLE, name = "Tables"},
        {type = FURNITURE_CATEGORY_TYPE_BED, name = "Beds"},
        {type = FURNITURE_CATEGORY_TYPE_LIGHT, name = "Lights"},
        {type = FURNITURE_CATEGORY_TYPE_RUG, name = "Rugs"},
        {type = FURNITURE_CATEGORY_TYPE_DECORATIVE, name = "Decorative"},
        {type = FURNITURE_CATEGORY_TYPE_APPLIANCE, name = "Appliances"},
        {type = FURNITURE_CATEGORY_TYPE_CONTAINER, name = "Containers"}
    }
    
    for _, category in ipairs(furnitureCategories) do
        local success, numItems = pcall(GetNumFurnitureItemsInCategory, category.type)
        if success and numItems then
            local categoryData = {
                name = category.name,
                total = numItems,
                owned = 0,
                items = {}
            }
            
            for i = 1, numItems do
                local success2, itemId, itemName, isOwned = pcall(GetFurnitureItemInfo, category.type, i)
                if success2 and itemId and itemName then
                    if isOwned then
                        categoryData.owned = categoryData.owned + 1
                    end
                    
                    table.insert(categoryData.items, {
                        id = itemId,
                        name = itemName,
                        owned = isOwned or false
                    })
                end
            end
            
            collections.furniture.categories[category.name] = categoryData
            collections.furniture.total = collections.furniture.total + numItems
            collections.furniture.owned = collections.furniture.owned + categoryData.owned
        end
    end
    
    return collections
end

-- =====================================================
-- MAIN TITLES & HOUSING COLLECTOR
-- =====================================================

local function CollectTitlesHousingData()
    return {
        titles = CollectTitlesData(),
        housing = CollectHousingData(),
        collections = CollectHousingCollectionsData()
    }
end

CM.collectors.CollectTitlesHousingData = CollectTitlesHousingData
