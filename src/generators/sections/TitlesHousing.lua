-- CharacterMarkdown - Titles & Housing Section Generators
-- Generates titles and housing-related markdown sections

local CM = CharacterMarkdown

-- Cache for utility functions (lazy-initialized on first use)
local FormatNumber, GenerateProgressBar

-- Lazy initialization of cached references
local function InitializeUtilities()
    if not FormatNumber then
        FormatNumber = CM.utils.FormatNumber
        GenerateProgressBar = CM.generators.helpers.GenerateProgressBar
    end
end

-- =====================================================
-- TITLES
-- =====================================================

local function GenerateTitles(titlesData, format)
    InitializeUtilities()
    
    local markdown = ""
    
    if not titlesData or titlesData.total == 0 then
        return ""
    end
    
    if format == "discord" then
        markdown = markdown .. "**Titles:** " .. titlesData.owned .. "/" .. titlesData.total .. 
                  " (" .. math.floor((titlesData.owned / titlesData.total) * 100) .. "%)\n"
        
        if titlesData.current and titlesData.current ~= "" then
            markdown = markdown .. "• Current: " .. titlesData.current .. "\n"
        end
        markdown = markdown .. "\n"
    else
        markdown = markdown .. "### 👑 Titles\n\n"
        
        if titlesData.current and titlesData.current ~= "" then
            markdown = markdown .. "**Current Title:** " .. titlesData.current .. "\n\n"
        end
        
        local progress = math.floor((titlesData.owned / titlesData.total) * 100)
        local progressBar = GenerateProgressBar(progress, 20)
        markdown = markdown .. "| Progress | " .. progressBar .. " " .. progress .. "% (" .. 
                  titlesData.owned .. "/" .. titlesData.total .. ") |\n\n"
        
        -- Show some example titles (first 10 unlocked)
        local unlockedTitles = {}
        for _, title in ipairs(titlesData.list) do
            if title.unlocked then
                table.insert(unlockedTitles, title.name)
            end
        end
        
        if #unlockedTitles > 0 then
            markdown = markdown .. "**Sample Titles:**\n"
            local maxShow = math.min(10, #unlockedTitles)
            for i = 1, maxShow do
                markdown = markdown .. "• " .. unlockedTitles[i] .. "\n"
            end
            if #unlockedTitles > 10 then
                markdown = markdown .. "• ... and " .. (#unlockedTitles - 10) .. " more\n"
            end
            markdown = markdown .. "\n"
        end
    end
    
    return markdown
end

-- =====================================================
-- HOUSING
-- =====================================================

local function GenerateHousing(housingData, format)
    InitializeUtilities()
    
    local markdown = ""
    
    if not housingData or housingData.total == 0 then
        return ""
    end
    
    if format == "discord" then
        markdown = markdown .. "**Housing:** " .. housingData.owned .. "/" .. housingData.total .. 
                  " (" .. math.floor((housingData.owned / housingData.total) * 100) .. "%)\n"
        
        if housingData.primary and housingData.primary ~= "" then
            markdown = markdown .. "• Primary: " .. housingData.primary .. "\n"
        end
        markdown = markdown .. "\n"
    else
        markdown = markdown .. "### 🏠 Housing\n\n"
        
        if housingData.primary and housingData.primary ~= "" then
            markdown = markdown .. "**Primary Residence:** " .. housingData.primary .. "\n\n"
        end
        
        local progress = math.floor((housingData.owned / housingData.total) * 100)
        local progressBar = GenerateProgressBar(progress, 20)
        markdown = markdown .. "| Progress | " .. progressBar .. " " .. progress .. "% (" .. 
                  housingData.owned .. "/" .. housingData.total .. ") |\n\n"
        
        -- Show owned houses
        local ownedHouses = {}
        for _, house in ipairs(housingData.houses) do
            if house.owned then
                table.insert(ownedHouses, house.name)
            end
        end
        
        if #ownedHouses > 0 then
            markdown = markdown .. "**Owned Houses:**\n"
            for _, houseName in ipairs(ownedHouses) do
                markdown = markdown .. "• " .. houseName .. "\n"
            end
            markdown = markdown .. "\n"
        end
    end
    
    return markdown
end

-- =====================================================
-- HOUSING COLLECTIONS
-- =====================================================

local function GenerateHousingCollections(collectionsData, format)
    InitializeUtilities()
    
    local markdown = ""
    
    if not collectionsData or not collectionsData.furniture then
        return ""
    end
    
    if format == "discord" then
        local furnitureProgress = math.floor((collectionsData.furniture.owned / collectionsData.furniture.total) * 100)
        markdown = markdown .. "**Furniture:** " .. collectionsData.furniture.owned .. "/" .. 
                  collectionsData.furniture.total .. " (" .. furnitureProgress .. "%)\n"
        markdown = markdown .. "\n"
    else
        markdown = markdown .. "### 🪑 Housing Collections\n\n"
        
        -- Furniture summary
        local furnitureProgress = math.floor((collectionsData.furniture.owned / collectionsData.furniture.total) * 100)
        local furnitureProgressBar = GenerateProgressBar(furnitureProgress, 20)
        markdown = markdown .. "#### Furniture\n\n"
        markdown = markdown .. "| Progress | " .. furnitureProgressBar .. " " .. furnitureProgress .. "% (" .. 
                  collectionsData.furniture.owned .. "/" .. collectionsData.furniture.total .. ") |\n\n"
        
        -- Furniture categories
        markdown = markdown .. "| Category | Owned | Total | Progress |\n"
        markdown = markdown .. "|:---------|:------|:------|:--------|\n"
        
        for categoryName, categoryData in pairs(collectionsData.furniture.categories) do
            if categoryData.total > 0 then
                local categoryProgress = math.floor((categoryData.owned / categoryData.total) * 100)
                local categoryProgressBar = GenerateProgressBar(categoryProgress, 15)
                markdown = markdown .. "| **" .. categoryName .. "** | " .. categoryData.owned .. 
                          " | " .. categoryData.total .. " | " .. categoryProgressBar .. " " .. 
                          categoryProgress .. "% |\n"
            end
        end
        markdown = markdown .. "\n"
    end
    
    return markdown
end

-- =====================================================
-- MAIN TITLES & HOUSING GENERATOR
-- =====================================================

local function GenerateTitlesHousing(titlesHousingData, format)
    InitializeUtilities()
    
    local markdown = ""
    
    if not titlesHousingData then
        return ""
    end
    
    -- Only show the section if we have some data
    local hasData = false
    if titlesHousingData.titles and titlesHousingData.titles.total > 0 then
        hasData = true
    elseif titlesHousingData.housing and titlesHousingData.housing.total > 0 then
        hasData = true
    elseif titlesHousingData.collections and titlesHousingData.collections.furniture and titlesHousingData.collections.furniture.total > 0 then
        hasData = true
    end
    
    if not hasData then
        return ""
    end
    
    if format ~= "discord" then
        markdown = markdown .. "## 🏆 Titles & Housing\n\n"
    end
    
    -- Add each subsection
    markdown = markdown .. GenerateTitles(titlesHousingData.titles, format)
    markdown = markdown .. GenerateHousing(titlesHousingData.housing, format)
    markdown = markdown .. GenerateHousingCollections(titlesHousingData.collections, format)
    
    return markdown
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.generators.sections = CM.generators.sections or {}
CM.generators.sections.GenerateTitlesHousing = GenerateTitlesHousing
CM.generators.sections.GenerateTitles = GenerateTitles
CM.generators.sections.GenerateHousing = GenerateHousing
CM.generators.sections.GenerateHousingCollections = GenerateHousingCollections
