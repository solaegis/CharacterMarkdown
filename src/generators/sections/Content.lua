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
    
    if format == "discord" then
        if dlcData.hasESOPlus then
            markdown = markdown .. "**DLC Access:** ESO Plus (All DLCs Available)\n\n"
        elseif #dlcData.accessible > 0 or #dlcData.locked > 0 then
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
        if dlcData.hasESOPlus then
            markdown = markdown .. "✅ **ESO Plus Active** - All DLCs accessible\n\n"
        end
        
        if #dlcData.accessible > 0 then
            markdown = markdown .. "### ✅ Accessible Content\n\n"
            for _, dlcName in ipairs(dlcData.accessible) do
                markdown = markdown .. "- ✅ " .. dlcName .. "\n"
            end
            markdown = markdown .. "\n"
        end
        
        if #dlcData.locked > 0 and not dlcData.hasESOPlus then
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

local function GenerateChampionPoints(cpData, format)
    InitializeUtilities()
    
    local markdown = ""
    
    local totalCP = cpData.total or 0
    
    if format == "discord" then
        markdown = markdown .. "**Champion Points:**\n"
    else
        markdown = markdown .. "## ⭐ Champion Points\n\n"
    end
    
    if totalCP < 10 then
        markdown = markdown .. "*Champion Point system unlocks at Level 50*\n\n"
    else
        local spentCP = cpData.spent or 0
        local availableCP = totalCP - spentCP
        
        if format == "discord" then
            markdown = markdown .. "Total: " .. FormatNumber(totalCP) .. " | "
            markdown = markdown .. "Spent: " .. FormatNumber(spentCP) .. " | "
            markdown = markdown .. "Available: " .. FormatNumber(availableCP) .. "\n"
            
            if cpData.disciplines and #cpData.disciplines > 0 then
                for _, discipline in ipairs(cpData.disciplines) do
                    markdown = markdown .. (discipline.emoji or "⚔️") .. " **" .. discipline.name .. "** (" .. FormatNumber(discipline.total) .. ")\n"
                    if discipline.skills and #discipline.skills > 0 then
                        for _, skill in ipairs(discipline.skills) do
                            local skillText = CreateCPSkillLink(skill.name, format)
                            markdown = markdown .. "• " .. skillText .. ": " .. skill.points .. "\n"
                        end
                    end
                    markdown = markdown .. "\n"
                end
            end
        else
            -- Compact table format
            markdown = markdown .. "| Category | Value |\n"
            markdown = markdown .. "|:---------|------:|\n"
            markdown = markdown .. "| **Total** | " .. FormatNumber(totalCP) .. " |\n"
            markdown = markdown .. "| **Spent** | " .. FormatNumber(spentCP) .. " |\n"
            if availableCP > 0 then
                markdown = markdown .. "| **Available** | " .. FormatNumber(availableCP) .. " ⚠️ |\n"
            else
                markdown = markdown .. "| **Available** | " .. FormatNumber(availableCP) .. " |\n"
            end
            markdown = markdown .. "\n"
            
            if cpData.disciplines and #cpData.disciplines > 0 then
                -- Calculate max possible points per discipline (CP 3.0 system allows up to 660 per tree)
                local maxPerDiscipline = 660
                
                for _, discipline in ipairs(cpData.disciplines) do
                    local disciplinePercent = math.floor((discipline.total / maxPerDiscipline) * 100)
                    local progressBar = GenerateProgressBar(disciplinePercent, 12)
                    
                    markdown = markdown .. "### " .. (discipline.emoji or "⚔️") .. " " .. discipline.name .. 
                                         " (" .. FormatNumber(discipline.total) .. "/" .. maxPerDiscipline .. " points) " .. 
                                         progressBar .. " " .. disciplinePercent .. "%\n\n"
                    if discipline.skills and #discipline.skills > 0 then
                        for _, skill in ipairs(discipline.skills) do
                            local skillText = CreateCPSkillLink(skill.name, format)
                            local pointText = skill.points == 1 and "point" or "points"
                            markdown = markdown .. "- **" .. skillText .. "**: " .. skill.points .. " " .. pointText .. "\n"
                        end
                        markdown = markdown .. "\n"
                    end
                end
            end
            
            markdown = markdown .. "---\n\n"
        end
    end
    
    return markdown
end

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

CM.generators.sections.GenerateDLCAccess = GenerateDLCAccess
CM.generators.sections.GenerateMundus = GenerateMundus
CM.generators.sections.GenerateChampionPoints = GenerateChampionPoints
CM.generators.sections.GenerateCollectibles = GenerateCollectibles
CM.generators.sections.GenerateCrafting = GenerateCrafting

