-- CharacterMarkdown - World Section Generators
-- Generates world progress-related markdown sections (Skyshards, Lorebooks, Zone Completion, Dungeons)

local CM = CharacterMarkdown

-- Cache for utility functions (lazy-initialized on first use)
local FormatNumber, GenerateProgressBar, CreateZoneLink

-- Lazy initialization of cached references
local function InitializeUtilities()
    if not FormatNumber then
        FormatNumber = CM.utils.FormatNumber
        GenerateProgressBar = CM.generators.helpers.GenerateProgressBar
        CreateZoneLink = CM.links.CreateZoneLink
    end
end

-- =====================================================
-- SKYSHARDS
-- =====================================================

local function GenerateSkyshards(skyshardsData, format)
    InitializeUtilities()
    
    local markdown = ""
    
    if not skyshardsData or skyshardsData.total == 0 then
        return ""
    end
    
    if format == "discord" then
        markdown = markdown .. "**Skyshards:** " .. skyshardsData.collected .. "/" .. skyshardsData.total .. 
                  " (" .. math.floor((skyshardsData.collected / skyshardsData.total) * 100) .. "%)\n"
        
        -- Show zone-specific data if available
        for zoneName, zoneData in pairs(skyshardsData.zones) do
            if zoneData.total > 0 then
                markdown = markdown .. "• " .. zoneName .. ": " .. zoneData.collected .. "/" .. zoneData.total .. 
                          " (" .. zoneData.percentage .. "%)\n"
            end
        end
        markdown = markdown .. "\n"
    else
        markdown = markdown .. "### 🌟 Skyshards\n\n"
        markdown = markdown .. "| Zone | Collected | Total | Progress |\n"
        markdown = markdown .. "|:-----|:----------|:------|:--------|\n"
        
        -- Show zone-specific data
        for zoneName, zoneData in pairs(skyshardsData.zones) do
            if zoneData.total > 0 then
                local progressBar = GenerateProgressBar(zoneData.percentage, 20)
                markdown = markdown .. "| **" .. zoneName .. "** | " .. zoneData.collected .. 
                          " | " .. zoneData.total .. " | " .. progressBar .. " " .. zoneData.percentage .. "% |\n"
            end
        end
        
        -- Overall summary
        local overallProgress = math.floor((skyshardsData.collected / skyshardsData.total) * 100)
        local overallProgressBar = GenerateProgressBar(overallProgress, 20)
        markdown = markdown .. "| **Total** | " .. skyshardsData.collected .. " | " .. skyshardsData.total .. 
                  " | " .. overallProgressBar .. " " .. overallProgress .. "% |\n\n"
    end
    
    return markdown
end

-- =====================================================
-- LOREBOOKS
-- =====================================================

local function GenerateLorebooks(lorebooksData, format)
    InitializeUtilities()
    
    local markdown = ""
    
    if not lorebooksData or lorebooksData.total == 0 then
        return ""
    end
    
    if format == "discord" then
        markdown = markdown .. "**Lorebooks:** " .. lorebooksData.collected .. "/" .. lorebooksData.total .. 
                  " (" .. math.floor((lorebooksData.collected / lorebooksData.total) * 100) .. "%)\n"
        
        -- Show category breakdown
        for categoryName, categoryData in pairs(lorebooksData.categories) do
            if categoryData.total > 0 then
                local categoryPercent = math.floor((categoryData.collected / categoryData.total) * 100)
                markdown = markdown .. "• " .. categoryName .. ": " .. categoryData.collected .. "/" .. 
                          categoryData.total .. " (" .. categoryPercent .. "%)\n"
            end
        end
        markdown = markdown .. "\n"
    else
        markdown = markdown .. "### 📚 Lorebooks\n\n"
        markdown = markdown .. "| Category | Collected | Total | Progress |\n"
        markdown = markdown .. "|:---------|:----------|:------|:--------|\n"
        
        -- Show category breakdown
        for categoryName, categoryData in pairs(lorebooksData.categories) do
            if categoryData.total > 0 then
                local categoryPercent = math.floor((categoryData.collected / categoryData.total) * 100)
                local progressBar = GenerateProgressBar(categoryPercent, 20)
                markdown = markdown .. "| **" .. categoryName .. "** | " .. categoryData.collected .. 
                          " | " .. categoryData.total .. " | " .. progressBar .. " " .. categoryPercent .. "% |\n"
            end
        end
        
        -- Overall summary
        local overallProgress = math.floor((lorebooksData.collected / lorebooksData.total) * 100)
        local overallProgressBar = GenerateProgressBar(overallProgress, 20)
        markdown = markdown .. "| **Total** | " .. lorebooksData.collected .. " | " .. lorebooksData.total .. 
                  " | " .. overallProgressBar .. " " .. overallProgress .. "% |\n\n"
    end
    
    return markdown
end

-- =====================================================
-- ZONE COMPLETION
-- =====================================================

local function GenerateZoneCompletion(zoneCompletionData, format)
    InitializeUtilities()
    
    local markdown = ""
    
    if not zoneCompletionData or zoneCompletionData.currentZone == "" then
        return ""
    end
    
    -- Create zone link if available (conditional based on settings)
    local zoneName = zoneCompletionData.currentZone
    local zoneLink = (CreateZoneLink and CreateZoneLink(zoneName, format)) or zoneName
    
    if format == "discord" then
        markdown = markdown .. "**Zone Completion:** " .. zoneLink .. 
                  " (" .. zoneCompletionData.completionPercentage .. "%)\n\n"
    else
        markdown = markdown .. "### 🗺️ Zone Completion\n\n"
        markdown = markdown .. "| Zone | Completion |\n"
        markdown = markdown .. "|:-----|:----------|\n"
        
        local progressBar = GenerateProgressBar(zoneCompletionData.completionPercentage, 20)
        markdown = markdown .. "| **" .. zoneLink .. "** | " .. 
                  progressBar .. " " .. zoneCompletionData.completionPercentage .. "% |\n\n"
    end
    
    return markdown
end

-- =====================================================
-- DUNGEONS (DELVES & PUBLIC DUNGEONS)
-- =====================================================

local function GenerateDungeonProgress(dungeonData, format)
    InitializeUtilities()
    
    local markdown = ""
    
    if not dungeonData then
        return ""
    end
    
    local hasDelves = dungeonData.delves and dungeonData.delves.total > 0
    local hasPublicDungeons = dungeonData.publicDungeons and dungeonData.publicDungeons.total > 0
    
    if not hasDelves and not hasPublicDungeons then
        return ""
    end
    
    if format == "discord" then
        if hasDelves then
            local delvePercent = math.floor((dungeonData.delves.completed / dungeonData.delves.total) * 100)
            markdown = markdown .. "**Delves:** " .. dungeonData.delves.completed .. "/" .. dungeonData.delves.total .. 
                      " (" .. delvePercent .. "%)\n"
        end
        
        if hasPublicDungeons then
            local dungeonPercent = math.floor((dungeonData.publicDungeons.completed / dungeonData.publicDungeons.total) * 100)
            markdown = markdown .. "**Public Dungeons:** " .. dungeonData.publicDungeons.completed .. "/" .. 
                      dungeonData.publicDungeons.total .. " (" .. dungeonPercent .. "%)\n"
        end
        markdown = markdown .. "\n"
    else
        markdown = markdown .. "### 🏰 Dungeon Progress\n\n"
        
        if hasDelves then
            markdown = markdown .. "#### Delves\n\n"
            markdown = markdown .. "| Delve | Status |\n"
            markdown = markdown .. "|:------|:-------|\n"
            
            for _, delve in ipairs(dungeonData.delves.list) do
                local status = delve.completed and "✅ Completed" or "⏳ Pending"
                markdown = markdown .. "| " .. delve.name .. " | " .. status .. " |\n"
            end
            markdown = markdown .. "\n"
        end
        
        if hasPublicDungeons then
            markdown = markdown .. "#### Public Dungeons\n\n"
            markdown = markdown .. "| Dungeon | Status |\n"
            markdown = markdown .. "|:--------|:-------|\n"
            
            for _, dungeon in ipairs(dungeonData.publicDungeons.list) do
                local status = dungeon.completed and "✅ Completed" or "⏳ Pending"
                markdown = markdown .. "| " .. dungeon.name .. " | " .. status .. " |\n"
            end
            markdown = markdown .. "\n"
        end
    end
    
    return markdown
end

-- =====================================================
-- MAIN WORLD PROGRESS GENERATOR
-- =====================================================

local function GenerateWorldProgress(worldProgressData, format)
    InitializeUtilities()
    
    local markdown = ""
    
    if not worldProgressData then
        return ""
    end
    
    -- Only show the section if we have some data
    local hasData = false
    if worldProgressData.skyshards and worldProgressData.skyshards.total > 0 then
        hasData = true
    elseif worldProgressData.lorebooks and worldProgressData.lorebooks.total > 0 then
        hasData = true
    elseif worldProgressData.zoneCompletion and worldProgressData.zoneCompletion.currentZone ~= "" then
        hasData = true
    elseif worldProgressData.dungeons and 
           ((worldProgressData.dungeons.delves and worldProgressData.dungeons.delves.total > 0) or
            (worldProgressData.dungeons.publicDungeons and worldProgressData.dungeons.publicDungeons.total > 0)) then
        hasData = true
    end
    
    if not hasData then
        return ""
    end
    
    if format ~= "discord" then
        markdown = markdown .. "## 🌍 World Progress\n\n"
    end
    
    -- Add each subsection
    markdown = markdown .. GenerateSkyshards(worldProgressData.skyshards, format)
    markdown = markdown .. GenerateLorebooks(worldProgressData.lorebooks, format)
    -- Zone Completion disabled - not working correctly
    -- markdown = markdown .. GenerateZoneCompletion(worldProgressData.zoneCompletion, format)
    markdown = markdown .. GenerateDungeonProgress(worldProgressData.dungeons, format)
    
    return markdown
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.generators.sections = CM.generators.sections or {}
CM.generators.sections.GenerateWorldProgress = GenerateWorldProgress
CM.generators.sections.GenerateSkyshards = GenerateSkyshards
CM.generators.sections.GenerateLorebooks = GenerateLorebooks
CM.generators.sections.GenerateZoneCompletion = GenerateZoneCompletion
CM.generators.sections.GenerateDungeonProgress = GenerateDungeonProgress
