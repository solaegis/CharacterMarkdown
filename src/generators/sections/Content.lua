-- CharacterMarkdown - Content Section Generators
-- Generates content-related markdown sections (DLC, Mundus, Champion Points, Collectibles, Crafting)

local CM = CharacterMarkdown

-- Cache for utility functions (lazy-initialized on first use)
local CreateMundusLink, CreateCPSkillLink, CreateCollectibleLink
local FormatNumber, GenerateProgressBar, CreateCollapsible, GenerateAnchor
local string_format = string.format
local string_rep = string.rep

-- Lazy initialization of cached references
local function InitializeUtilities()
    if not FormatNumber then
        CreateMundusLink = CM.links.CreateMundusLink
        CreateCPSkillLink = CM.links.CreateCPSkillLink
        CreateCollectibleLink = CM.links.CreateCollectibleLink
        FormatNumber = CM.utils.FormatNumber
        GenerateProgressBar = CM.generators.helpers.GenerateProgressBar
        CreateCollapsible = (CM.utils and CM.utils.markdown and CM.utils.markdown.CreateCollapsible) or nil
        GenerateAnchor = (CM.utils and CM.utils.markdown and CM.utils.markdown.GenerateAnchor) or nil
    end
end

-- =====================================================
-- DLC ACCESS
-- =====================================================

local function GenerateDLCAccess(dlcData, format)
    local markdown = ""
    
    -- Handle nil or empty dlcData
    if not dlcData then
        dlcData = {}
    end
    
    -- Ensure accessible array exists
    if not dlcData.accessible then dlcData.accessible = {} end
    if not dlcData.locked then dlcData.locked = {} end
    
    -- If ESO Plus active, show section with ESO Plus status AND list all accessible DLCs
    if dlcData.hasESOPlus then
        if format == "discord" then
            markdown = markdown .. "**DLC Access:** ESO Plus (All DLCs Available)\n"
            if #dlcData.accessible > 0 then
                for _, dlcName in ipairs(dlcData.accessible) do
                    markdown = markdown .. "✅ " .. dlcName .. "\n"
                end
            end
            markdown = markdown .. "\n"
        else
            InitializeUtilities()
            local anchorId = GenerateAnchor and GenerateAnchor("🗺️ DLC & Chapter Access") or "dlc--chapter-access"
            markdown = markdown .. string_format('<a id="%s"></a>\n\n', anchorId)
            markdown = markdown .. "## 🗺️ DLC & Chapter Access\n\n"
            
            -- Show all accessible DLCs (purchased or via ESO Plus)
            if #dlcData.accessible > 0 then
                for _, dlcName in ipairs(dlcData.accessible) do
                    markdown = markdown .. "- ✅ " .. dlcName .. "\n"
                end
                markdown = markdown .. "\n"
            end
            
            markdown = markdown .. "**ESO Plus Active** - All DLCs and Chapters are accessible.\n\n"
            markdown = markdown .. "---\n\n"
        end
        return markdown
    end
    
    -- Only show DLC section if user does NOT have ESO Plus
    if format == "discord" then
        if #dlcData.accessible > 0 or #dlcData.locked > 0 then
            markdown = markdown .. "**DLC Access:**\n"
            if #dlcData.accessible > 0 then
                for _, dlcName in ipairs(dlcData.accessible) do
                    markdown = markdown .. "✅ " .. dlcName .. "\n"
                end
            end
            if #dlcData.locked > 0 then
                for _, dlcName in ipairs(dlcData.locked) do
                    markdown = markdown .. "🔒 " .. dlcName .. "\n"
                end
            end
            markdown = markdown .. "\n"
        end
    else
        InitializeUtilities()
        local anchorId = GenerateAnchor and GenerateAnchor("🗺️ DLC & Chapter Access") or "dlc--chapter-access"
        markdown = markdown .. string_format('<a id="%s"></a>\n\n', anchorId)
        markdown = markdown .. "## 🗺️ DLC & Chapter Access\n\n"
        
        -- Ensure accessible and locked arrays exist
        if not dlcData.accessible then dlcData.accessible = {} end
        if not dlcData.locked then dlcData.locked = {} end
        
        if #dlcData.accessible > 0 then
            for _, dlcName in ipairs(dlcData.accessible) do
                markdown = markdown .. "- ✅ " .. dlcName .. "\n"
            end
            markdown = markdown .. "\n"
        end
        
        if #dlcData.locked > 0 then
            markdown = markdown .. "### 🔒 Locked Content\n\n"
            for _, dlcName in ipairs(dlcData.locked) do
                markdown = markdown .. "- 🔒 " .. dlcName .. "\n"
            end
            markdown = markdown .. "\n"
        end
        
        -- If no accessible or locked content, show a message
        if #dlcData.accessible == 0 and #dlcData.locked == 0 then
            markdown = markdown .. "*No DLC access information available*\n\n"
        end
        
        markdown = markdown .. "---\n\n"
    end
    
    return markdown
end

-- =====================================================
-- MUNDUS STONE
-- =====================================================

local function GenerateMundus(mundusData, format)
    InitializeUtilities()
    
    local markdown = ""
    
    if format == "discord" then
        if mundusData.active then
            local mundusText = CreateMundusLink(mundusData.name, format)
            markdown = markdown .. "**Mundus:** " .. mundusText .. "\n\n"
        end
    else
        InitializeUtilities()
        local anchorId = GenerateAnchor and GenerateAnchor("🪨 Mundus Stone") or "mundus-stone"
        markdown = markdown .. string_format('<a id="%s"></a>\n\n', anchorId)
        markdown = markdown .. "## 🪨 Mundus Stone\n\n"
        if mundusData.active then
            local mundusText = CreateMundusLink(mundusData.name, format)
            markdown = markdown .. "✅ **Active:** " .. mundusText .. "\n\n"
        else
            markdown = markdown .. "⚠️ **No Active Mundus Stone**\n\n"
        end
        
        markdown = markdown .. "---\n\n"
    end
    
    return markdown
end

-- =====================================================
-- CHAMPION POINTS
-- =====================================================
-- NOTE: GenerateChampionPoints is now implemented in ChampionPoints.lua
-- This section is kept for reference but the function is exported from ChampionPoints.lua

-- =====================================================
-- COLLECTIBLES
-- =====================================================

-- Helper function to generate DLC content in collectibles format
local function GenerateDLCAsCollectible(dlcData, format)
    if not dlcData or format == "discord" or format == "quick" then
        return ""
    end
    
    local content = ""
    
    -- Handle ESO Plus case
    if dlcData.hasESOPlus then
        if dlcData.accessible and #dlcData.accessible > 0 then
            for _, dlcName in ipairs(dlcData.accessible) do
                content = content .. "- ✅ " .. dlcName .. "\n"
            end
        end
        
        content = content .. "\n**ESO Plus Active** - All DLCs and Chapters are accessible.\n\n"
    else
        -- Show accessible and locked content
        if dlcData.accessible and #dlcData.accessible > 0 then
            for _, dlcName in ipairs(dlcData.accessible) do
                content = content .. "- ✅ " .. dlcName .. "\n"
            end
            content = content .. "\n"
        end
        
        if dlcData.locked and #dlcData.locked > 0 then
            content = content .. "### 🔒 Locked Content\n\n"
            for _, dlcName in ipairs(dlcData.locked) do
                content = content .. "- 🔒 " .. dlcName .. "\n"
            end
        end
        
        if (not dlcData.accessible or #dlcData.accessible == 0) and 
           (not dlcData.locked or #dlcData.locked == 0) then
            content = content .. "*No DLC access information available*\n"
        end
    end
    
    if content == "" then
        return ""
    end
    
    -- Count total DLCs
    local totalDLCs = 0
    local accessibleCount = (dlcData.accessible and #dlcData.accessible) or 0
    local lockedCount = (dlcData.locked and #dlcData.locked) or 0
    totalDLCs = accessibleCount + lockedCount
    
    -- Create collapsible details block
    local summaryText = "🗺️ DLC & Chapter Access"
    if totalDLCs > 0 then
        summaryText = summaryText .. " (" .. accessibleCount .. " accessible"
        if lockedCount > 0 then
            summaryText = summaryText .. ", " .. lockedCount .. " locked"
        end
        summaryText = summaryText .. ")"
    end
    
    return "<details>\n<summary>" .. summaryText .. "</summary>\n\n" .. content .. "\n</details>\n\n"
end

local function GenerateCollectibles(collectiblesData, format, dlcData, lorebooksData, titlesHousingData, ridingData)
    local markdown = ""
    
    -- Check if we have detailed data enabled
    local hasDetailedData = collectiblesData.hasDetailedData
    local settings = CharacterMarkdownSettings or {}
    local includeDetailed = settings.includeCollectiblesDetailed or false
    
    -- Auto-enable detailed mode if we have any owned collectibles to show
    -- This allows users to see their collected items even if setting is disabled
    if not includeDetailed and collectiblesData.categories then
        for _, key in ipairs({"mounts", "pets", "costumes", "emotes", "mementos", "skins", "polymorphs", "personalities"}) do
            local category = collectiblesData.categories[key]
            if category and #category.owned > 0 then
                includeDetailed = true
                break
            end
        end
    end
    
    if format == "discord" then
        -- Discord: Always show summary counts only (no detailed lists)
        markdown = markdown .. "**Collectibles:**\n"
        
        if collectiblesData.categories then
            for _, key in ipairs({"mounts", "pets", "costumes", "emotes", "mementos", "skins", "polymorphs", "personalities"}) do
                local category = collectiblesData.categories[key]
                if category and category.total > 0 then
                    local owned = #category.owned
                    markdown = markdown .. category.emoji .. " " .. category.name .. ": (" .. owned .. " of " .. category.total .. ")\n"
                end
            end
        end
        
        -- Add Riding Skills for Discord format
        if ridingData and (CM.settings == nil or CM.settings.includeRidingSkills ~= false) then
            markdown = markdown .. "**Riding Skills:**\n"
            local speed = ridingData.speed or 0
            local stamina = ridingData.stamina or 0
            local capacity = ridingData.capacity or 0
            markdown = markdown .. "• Speed: " .. speed .. "/60\n"
            markdown = markdown .. "• Stamina: " .. stamina .. "/60\n"
            markdown = markdown .. "• Capacity: " .. capacity .. "/60\n"
        end
        
        markdown = markdown .. "\n"
    else
        -- GitHub/VSCode: Show collapsible detailed lists if enabled or if we have owned items
        InitializeUtilities()
        local anchorId = GenerateAnchor and GenerateAnchor("🎨 Collectibles") or "collectibles"
        markdown = markdown .. string_format('<a id="%s"></a>\n\n', anchorId)
        markdown = markdown .. "## 🎨 Collectibles\n\n"
        
        -- Add DLC as first collapsible item
        if dlcData and (CM.settings == nil or CM.settings.includeDLCAccess ~= false) then
            local dlcContent = GenerateDLCAsCollectible(dlcData, format)
            if dlcContent ~= "" then
                markdown = markdown .. dlcContent
            end
        end
        
        if includeDetailed and hasDetailedData and collectiblesData.categories then
            -- Detailed mode: Show collapsible sections with (X of Y) format
            for _, key in ipairs({"mounts", "pets", "costumes", "emotes", "mementos", "skins", "polymorphs", "personalities"}) do
                local category = collectiblesData.categories[key]
                if category and category.total > 0 then
                    local owned = #category.owned
                    
                    -- Collapsible section header
                    markdown = markdown .. "<details>\n"
                    markdown = markdown .. "<summary>" .. category.emoji .. " " .. category.name .. 
                                              " (" .. owned .. " of " .. category.total .. ")</summary>\n\n"
                    
                    -- Add progress bar
                    InitializeUtilities()
                    local progress = math.floor((owned / category.total) * 100)
                    local progressBar = GenerateProgressBar(progress, 20)
                    markdown = markdown .. "| Progress |\n"
                    markdown = markdown .. "| --- |\n"
                    markdown = markdown .. "| " .. progressBar .. " " .. progress .. "% (" .. 
                              owned .. "/" .. category.total .. ") |\n\n"
                    
                        -- List owned collectibles (alphabetically sorted)
                        if owned > 0 then
                            -- Ensure collectibles are sorted alphabetically by display name (case-insensitive)
                            -- Sort in-place to ensure consistent ordering
                            table.sort(category.owned, function(a, b)
                                local nameA = (a.name or ""):lower()
                                local nameB = (b.name or ""):lower()
                                return nameA < nameB
                            end)
                            
                            for _, collectible in ipairs(category.owned) do
                                InitializeUtilities()
                                -- Use fullName for links (UESP uses full names), display name for text
                                local linkName = collectible.fullName or collectible.name
                                local displayName = collectible.name
                                local collectibleLink = (CreateCollectibleLink and CreateCollectibleLink(linkName, format)) or displayName
                                markdown = markdown .. "- " .. collectibleLink
                                -- Add rarity if available
                                if collectible.quality then
                                    markdown = markdown .. " [" .. collectible.quality .. "]"
                                end
                                markdown = markdown .. "\n"
                            end
                        else
                            markdown = markdown .. "*No " .. category.name:lower() .. " owned*\n"
                        end
                    
                    markdown = markdown .. "</details>\n\n"
                end
            end
            
            -- Add Lorebooks section (as part of collectibles, after other categories)
            if lorebooksData and format ~= "discord" and format ~= "quick" then
                local GenerateLorebooks = CM.generators.sections.GenerateLorebooks
                if GenerateLorebooks then
                    local lorebooksContent = GenerateLorebooks(lorebooksData, format)
                    -- Content is already in collapsible format
                    if lorebooksContent ~= "" then
                        markdown = markdown .. lorebooksContent
                    end
                end
            end
        else
            -- Fallback: Show simple count table if detailed data not available
            markdown = markdown .. "| Type | Count |\n"
            markdown = markdown .. "|:-----|------:|\n"
            if collectiblesData.mounts and collectiblesData.mounts > 0 then
                markdown = markdown .. "| **🐴 Mounts** | " .. collectiblesData.mounts .. " |\n"
            end
            if collectiblesData.pets and collectiblesData.pets > 0 then
                markdown = markdown .. "| **🐾 Pets** | " .. collectiblesData.pets .. " |\n"
            end
            if collectiblesData.costumes and collectiblesData.costumes > 0 then
                markdown = markdown .. "| **👗 Costumes** | " .. collectiblesData.costumes .. " |\n"
            end
            if collectiblesData.houses and collectiblesData.houses > 0 then
                markdown = markdown .. "| **🏠 Houses** | " .. collectiblesData.houses .. " |\n"
            end
            markdown = markdown .. "\n"
        end
        
        -- Add Titles & Housing section (collapsible, like other collectibles)
        if titlesHousingData and format ~= "discord" and format ~= "quick" then
            local GenerateTitles = CM.generators.sections.GenerateTitles
            local GenerateHousing = CM.generators.sections.GenerateHousing
            if GenerateTitles and GenerateHousing then
                local titlesData = titlesHousingData.titles or {}
                local housingData = titlesHousingData.housing or {}
                
                -- Generate Titles section (collapsible)
                if titlesData and (titlesData.total and titlesData.total > 0 or (titlesData.list and #titlesData.list > 0)) then
                    local titlesContent = GenerateTitles(titlesData, format)
                    -- Remove header if present (will be in summary)
                    titlesContent = titlesContent:gsub("^###%s+👑%s+Titles%s*\n%s*\n", "")
                    
                    if titlesContent ~= "" then
                        -- Count owned titles
                        local owned = 0
                        if titlesData.list and #titlesData.list > 0 then
                            for _, title in ipairs(titlesData.list) do
                                if title.unlocked then
                                    owned = owned + 1
                                end
                            end
                        else
                            owned = titlesData.owned or 0
                        end
                        local total = titlesData.total or 0
                        
                        markdown = markdown .. "<details>\n"
                        markdown = markdown .. "<summary>👑 Titles (" .. owned .. " of " .. total .. ")</summary>\n\n"
                        markdown = markdown .. titlesContent
                        markdown = markdown .. "</details>\n\n"
                    end
                end
                
                -- Generate Housing section (collapsible)
                if housingData and housingData.total and housingData.total > 0 then
                    local housingContent = GenerateHousing(housingData, format)
                    -- Remove header if present (will be in summary)
                    housingContent = housingContent:gsub("^###%s+🏠%s+Housing%s*\n%s*\n", "")
                    
                    if housingContent ~= "" then
                        local owned = housingData.owned or 0
                        local total = housingData.total or 0
                        
                        markdown = markdown .. "<details>\n"
                        markdown = markdown .. "<summary>🏠 Housing (" .. owned .. " of " .. total .. ")</summary>\n\n"
                        markdown = markdown .. housingContent
                        markdown = markdown .. "</details>\n\n"
                    end
                end
            end
        end
    end
    
    return markdown
end

-- =====================================================
-- CRAFTING
-- =====================================================

local function GenerateCrafting(craftingData, format)
    local markdown = ""
    
    -- Defensive: Check if craftingData exists
    if not craftingData or type(craftingData) ~= "table" then
        return ""
    end
    
    -- Only show section if there's data to display
    local hasData = (craftingData.motifs and craftingData.motifs.total and craftingData.motifs.total > 0) or 
                   (craftingData.activeResearch and craftingData.activeResearch > 0)
    
    if not hasData then
        return ""
    end
    
    if format == "discord" then
        markdown = markdown .. "**Crafting:**\n"
        if craftingData.motifs and craftingData.motifs.total and craftingData.motifs.total > 0 then
            markdown = markdown .. "• Motifs: " .. (craftingData.motifs.known or 0) .. "/" .. 
                                  craftingData.motifs.total .. " (" .. (craftingData.motifs.percent or 0) .. "%)\n"
        end
        if craftingData.activeResearch and craftingData.activeResearch > 0 then
            markdown = markdown .. "• Active Research: " .. craftingData.activeResearch .. " traits\n"
        end
        markdown = markdown .. "\n"
    else
        InitializeUtilities()
        local anchorId = GenerateAnchor and GenerateAnchor("⚒️ Crafting") or "crafting"
        markdown = markdown .. string_format('<a id="%s"></a>\n\n', anchorId)
        markdown = markdown .. "## ⚒️ Crafting Knowledge\n\n"
        markdown = markdown .. "| Category | Progress |\n"
        markdown = markdown .. "|:---------|:---------|\n"
        if craftingData.motifs and craftingData.motifs.total and craftingData.motifs.total > 0 then
            markdown = markdown .. "| **📖 Motifs (Basic)** | " .. (craftingData.motifs.known or 0) .. " / " .. 
                                  craftingData.motifs.total .. " (" .. (craftingData.motifs.percent or 0) .. "%) |\n"
        end
        if craftingData.activeResearch and craftingData.activeResearch > 0 then
            markdown = markdown .. "| **🔬 Active Research** | " .. craftingData.activeResearch .. " traits |\n"
        end
        markdown = markdown .. "\n"
    end
    
    return markdown
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.generators.sections = CM.generators.sections or {}
CM.generators.sections.GenerateDLCAccess = GenerateDLCAccess
CM.generators.sections.GenerateMundus = GenerateMundus
-- GenerateChampionPoints is exported from ChampionPoints.lua (not here)
CM.generators.sections.GenerateCollectibles = GenerateCollectibles
CM.generators.sections.GenerateCrafting = GenerateCrafting

