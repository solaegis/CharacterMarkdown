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
    
    -- Always show section if enabled, even if collector failed
    -- Check if we have a current title OR any titles data
    if not titlesData then
        titlesData = {}
    end
    
    -- Fallback: Try to get title from character data if collector failed
    if (not titlesData.current or titlesData.current == "") and CM.charData then
        local customTitle = CM.charData.customTitle or ""
        if customTitle ~= "" then
            titlesData.current = customTitle
        else
            -- Try API directly as last resort (using correct API functions)
            local GetCurrentTitleFunc = rawget(_G, "GetCurrentTitle")
            local GetTitleNameFunc = rawget(_G, "GetTitleName")
            if GetCurrentTitleFunc and type(GetCurrentTitleFunc) == "function" and
               GetTitleNameFunc and type(GetTitleNameFunc) == "function" then
                local success, currentTitleIndex = pcall(GetCurrentTitleFunc)
                if success and currentTitleIndex and currentTitleIndex > 0 then
                    local nameSuccess, apiTitle = pcall(GetTitleNameFunc, currentTitleIndex)
                    if nameSuccess and apiTitle and apiTitle ~= "" then
                        titlesData.current = apiTitle
                    end
                end
            end
        end
    end
    
    -- Always show section if we have a current title, even if collector failed
    if titlesData.current and titlesData.current ~= "" then
        -- We have a title, show the section - continue below
    elseif not titlesData.total or titlesData.total == 0 then
        -- No titles data available at all
        if format ~= "discord" then
            markdown = markdown .. "### 👑 Titles\n\n"
            markdown = markdown .. "*No titles available*\n\n"
        end
        return markdown
    end
    
    if format == "discord" then
        if titlesData.current and titlesData.current ~= "" then
            markdown = markdown .. "**Titles:**\n"
            markdown = markdown .. "• Current: " .. titlesData.current .. "\n"
            
            if titlesData.total and titlesData.total > 0 then
                markdown = markdown .. "• Owned: " .. (titlesData.owned or 0) .. "/" .. titlesData.total .. 
                          " (" .. math.floor(((titlesData.owned or 0) / titlesData.total) * 100) .. "%)\n"
            end
        else
            if titlesData.total and titlesData.total > 0 then
                markdown = markdown .. "**Titles:** " .. (titlesData.owned or 0) .. "/" .. titlesData.total .. 
                          " (" .. math.floor(((titlesData.owned or 0) / titlesData.total) * 100) .. "%)\n"
            else
                markdown = markdown .. "**Titles:** *No titles available*\n"
            end
        end
        markdown = markdown .. "\n"
    else
        markdown = markdown .. "### 👑 Titles\n\n"
        
        if titlesData.current and titlesData.current ~= "" then
            markdown = markdown .. "**Current Title:** " .. titlesData.current .. "\n\n"
        end
        
        if titlesData.total and titlesData.total > 0 then
            local progress = math.floor(((titlesData.owned or 0) / titlesData.total) * 100)
            local progressBar = GenerateProgressBar(progress, 20)
            markdown = markdown .. "| Progress | " .. progressBar .. " " .. progress .. "% (" .. 
                      (titlesData.owned or 0) .. "/" .. titlesData.total .. ") |\n\n"
            
            -- Show some example titles (first 10 unlocked)
            local unlockedTitles = {}
            if titlesData.list and #titlesData.list > 0 then
                for _, title in ipairs(titlesData.list) do
                    if title.unlocked then
                        table.insert(unlockedTitles, title.name)
                    end
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
        elseif titlesData.current and titlesData.current ~= "" then
            -- We have a current title but no total count - collector may have failed
            markdown = markdown .. "*Total count unavailable (collector may have failed, but you have the title: " .. titlesData.current .. ")*\n\n"
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
    
    if not housingData or not housingData.total or housingData.total == 0 then
        -- Show placeholder when section enabled but no housing
        if format ~= "discord" then
            markdown = markdown .. "### 🏠 Housing\n\n"
            markdown = markdown .. "*No houses owned*\n\n"
        end
        return markdown
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
    
    if not collectionsData or not collectionsData.furniture or not collectionsData.furniture.total or collectionsData.furniture.total == 0 then
        -- Show placeholder when section enabled but no furniture
        if format ~= "discord" then
            markdown = markdown .. "### 🪑 Housing Collections\n\n"
            markdown = markdown .. "*No furniture collections data available*\n\n"
        end
        return markdown
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
        -- Show placeholder when enabled but no data available
        if format ~= "discord" then
            markdown = markdown .. "## 🏆 Titles & Housing\n\n"
            markdown = markdown .. "*No titles or housing data available*\n\n---\n\n"
        end
        return markdown
    end
    
    -- Always show the section when enabled (even if data is minimal/zero)
    if format ~= "discord" then
        markdown = markdown .. "## 🏆 Titles & Housing\n\n"
    end
    
    -- Add each subsection (they handle their own empty states)
    -- Ensure we have data structures even if collector failed
    local titlesData = titlesHousingData and titlesHousingData.titles or {}
    local housingData = titlesHousingData and titlesHousingData.housing or {}
    local collectionsData = titlesHousingData and titlesHousingData.collections or {}
    
    markdown = markdown .. GenerateTitles(titlesData, format)
    markdown = markdown .. GenerateHousing(housingData, format)
    markdown = markdown .. GenerateHousingCollections(collectionsData, format)
    
    -- Add divider for GitHub/VSCode format
    if format ~= "discord" then
        markdown = markdown .. "---\n\n"
    end
    
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
