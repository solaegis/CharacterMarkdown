-- CharacterMarkdown - Content Section Generators
-- Generates content-related markdown sections (DLC, Mundus, Champion Points, Collectibles, Crafting)

local CM = CharacterMarkdown

-- Cache for utility functions (lazy-initialized on first use)
local CreateMundusLink, CreateCPSkillLink
local FormatNumber, GenerateProgressBar

-- Lazy initialization of cached references
local function InitializeUtilities()
    if not FormatNumber then
        CreateMundusLink = CM.links.CreateMundusLink
        CreateCPSkillLink = CM.links.CreateCPSkillLink
        FormatNumber = CM.utils.FormatNumber
        GenerateProgressBar = CM.generators.helpers.GenerateProgressBar
    end
end

-- =====================================================
-- DLC ACCESS
-- =====================================================

local function GenerateDLCAccess(dlcData, format)
    local markdown = ""
    
    -- If ESO Plus active, only mention it (don't list DLCs)
    if dlcData.hasESOPlus then
        if format == "discord" then
            markdown = markdown .. "**DLC Access:** ESO Plus (All DLCs Available)\n\n"
        end
        -- For GitHub/VSCode: ESO Plus is already mentioned in Overview section
        -- No DLC section needed
        return ""
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
        markdown = markdown .. "## 🗺️ DLC & Chapter Access\n\n"
        
        if #dlcData.accessible > 0 then
            markdown = markdown .. "### ✅ Accessible Content\n\n"
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

local function GenerateCollectibles(collectiblesData, format)
    local markdown = ""
    
    -- Check if we have detailed data enabled
    local hasDetailedData = collectiblesData.hasDetailedData
    local settings = CharacterMarkdownSettings or {}
    local includeDetailed = settings.includeCollectiblesDetailed or false
    
    if format == "discord" then
        -- Discord: Always show summary counts only (no detailed lists)
        markdown = markdown .. "**Collectibles:**\n"
        
        if collectiblesData.categories then
            for _, key in ipairs({"mounts", "pets", "costumes", "houses", "emotes", "mementos", "skins", "polymorphs", "personalities"}) do
                local category = collectiblesData.categories[key]
                if category and category.total > 0 then
                    local owned = #category.owned
                    markdown = markdown .. category.emoji .. " " .. category.name .. ": (" .. owned .. " of " .. category.total .. ")\n"
                end
            end
        end
        markdown = markdown .. "\n"
    else
        -- GitHub/VSCode: Show collapsible detailed lists if enabled
        markdown = markdown .. "## 🎨 Collectibles\n\n"
        
        if not includeDetailed or not hasDetailedData then
            -- Fallback: Show simple count table if detailed not enabled
            markdown = markdown .. "| Type | Count |\n"
            markdown = markdown .. "|:-----|------:|\n"
            if collectiblesData.mounts > 0 then
                markdown = markdown .. "| **🐴 Mounts** | " .. collectiblesData.mounts .. " |\n"
            end
            if collectiblesData.pets > 0 then
                markdown = markdown .. "| **🐾 Pets** | " .. collectiblesData.pets .. " |\n"
            end
            if collectiblesData.costumes > 0 then
                markdown = markdown .. "| **👗 Costumes** | " .. collectiblesData.costumes .. " |\n"
            end
            if collectiblesData.houses > 0 then
                markdown = markdown .. "| **🏠 Houses** | " .. collectiblesData.houses .. " |\n"
            end
            markdown = markdown .. "\n"
        else
            -- Detailed mode: Show collapsible sections with (X of Y) format
            if collectiblesData.categories then
                for _, key in ipairs({"mounts", "pets", "costumes", "houses", "emotes", "mementos", "skins", "polymorphs", "personalities"}) do
                    local category = collectiblesData.categories[key]
                    if category and category.total > 0 then
                        local owned = #category.owned
                        
                        -- Collapsible section header
                        markdown = markdown .. "<details>\n"
                        markdown = markdown .. "<summary>" .. category.emoji .. " " .. category.name .. 
                                              " (" .. owned .. " of " .. category.total .. ")</summary>\n\n"
                        
                        -- List owned collectibles (alphabetically sorted)
                        if owned > 0 then
                            for _, collectible in ipairs(category.owned) do
                                markdown = markdown .. "- " .. collectible.name
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
    
    -- Only show section if there's data to display
    local hasData = (craftingData.motifs and craftingData.motifs.total > 0) or 
                   (craftingData.activeResearch and craftingData.activeResearch > 0)
    
    if not hasData then
        return ""
    end
    
    if format == "discord" then
        markdown = markdown .. "**Crafting:**\n"
        if craftingData.motifs and craftingData.motifs.total > 0 then
            markdown = markdown .. "• Motifs: " .. craftingData.motifs.known .. "/" .. 
                                  craftingData.motifs.total .. " (" .. craftingData.motifs.percent .. "%)\n"
        end
        if craftingData.activeResearch > 0 then
            markdown = markdown .. "• Active Research: " .. craftingData.activeResearch .. " traits\n"
        end
        markdown = markdown .. "\n"
    else
        markdown = markdown .. "## ⚒️ Crafting Knowledge\n\n"
        markdown = markdown .. "| Category | Progress |\n"
        markdown = markdown .. "|:---------|:---------|\n"
        if craftingData.motifs and craftingData.motifs.total > 0 then
            markdown = markdown .. "| **📖 Motifs (Basic)** | " .. craftingData.motifs.known .. " / " .. 
                                  craftingData.motifs.total .. " (" .. craftingData.motifs.percent .. "%) |\n"
        end
        if craftingData.activeResearch > 0 then
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

