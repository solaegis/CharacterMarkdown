-- CharacterMarkdown - Filter Manager
-- Advanced filtering and customization system

local CM = CharacterMarkdown

-- =====================================================
-- FILTER CATEGORIES
-- =====================================================

local FILTER_CATEGORIES = {
    -- Content Filters
    ["Content"] = {
        emoji = "📄",
        description = "Content section filters",
        settings = {
            "includeChampionPoints", "includeSkillBars", "includeSkills", "includeEquipment",
            "includeCompanion", "includeCombatStats", "includeBuffs", "includeAttributes",
            "includeRole", "includeLocation", "includeBuildNotes"
        }
    },
    
    -- Extended Filters
    ["Extended"] = {
        emoji = "🔍",
        description = "Extended information filters",
        settings = {
            "includeDLCAccess", "includeCurrency", "includeProgression", "includeRidingSkills",
            "includeInventory", "includePvP", "includeCollectibles", "includeCrafting",
            "includeAchievements", "includeQuests", "includeEquipmentEnhancement"
        }
    },
    
    -- Detail Filters
    ["Details"] = {
        emoji = "⚙️",
        description = "Detailed information filters",
        settings = {
            "includeChampionDetailed", "includeChampionConstellationTable", "includeChampionPointStarTables", "includeSkillMorphs",
            "includeCollectiblesDetailed", "includeAchievementsDetailed", "showAllAchievements",
            "includeQuestsDetailed", "showAllQuests", "includeEquipmentAnalysis",
            "includeEquipmentRecommendations"
        }
    },
    
    -- Quality Filters
    ["Quality"] = {
        emoji = "⭐",
        description = "Quality and level filters",
        settings = {
            "minSkillRank", "showMaxedSkills", "minEquipQuality", "hideEmptySlots"
        }
    },
    
    -- Link Filters
    ["Links"] = {
        emoji = "🔗",
        description = "Link and reference filters",
        settings = {
            "enableAbilityLinks", "enableSetLinks"
        }
    },
    
    -- Format Filters
    ["Format"] = {
        emoji = "📝",
        description = "Output format filters",
        settings = {
            "currentFormat"
        }
    }
}

-- =====================================================
-- FILTER PRESETS
-- =====================================================

-- Build "None" filter dynamically - turns off ALL boolean settings
local function BuildNoneFilter()
    local defaults = CM.Settings.Defaults:GetAll()
    local noneFilters = {
        currentFormat = "github",  -- Keep format setting
    }
    
    -- Turn off all boolean settings
    for key, value in pairs(defaults) do
        -- Skip internal settings
        if key ~= "filters" and key ~= "filterPresets" and key ~= "activeFilter" and
           key ~= "profiles" and key ~= "settingsVersion" and key ~= "_initialized" and
           key ~= "_lastModified" and key ~= "_panelOpened" and key ~= "_firstRun" then
            
            if type(value) == "boolean" then
                -- All booleans set to false (including includeSkillMorphs)
                noneFilters[key] = false
            elseif type(value) == "number" then
                -- For numeric filters that control visibility, set to hide everything
                if key == "minSkillRank" or key == "minEquipQuality" then
                    noneFilters[key] = 999  -- High value to hide everything
                else
                    noneFilters[key] = value  -- Keep other numeric defaults
                end
            elseif type(value) == "string" then
                -- Keep string settings (like currentFormat)
                noneFilters[key] = value
            end
        end
    end
    
    -- Special handling for inverse boolean pairs
    if noneFilters.hideMaxedSkills ~= nil then
        noneFilters.hideMaxedSkills = true  -- Hide maxed skills
    end
    if noneFilters.showMaxedSkills ~= nil then
        noneFilters.showMaxedSkills = false  -- Don't show maxed skills
    end
    if noneFilters.hideEmptySlots ~= nil then
        noneFilters.hideEmptySlots = true  -- Hide empty slots
    end
    
    -- Verify includeSkillMorphs is included
    if noneFilters.includeSkillMorphs == nil then
        CM.Warn("BuildNoneFilter: includeSkillMorphs not found in defaults!")
        noneFilters.includeSkillMorphs = false  -- Force it to false
    end
    
    return noneFilters
end

local FILTER_PRESETS = {
    -- Defaults (Reset to Default Values)
    ["Defaults"] = {
        name = "Defaults",
        description = "Reset all settings to their default values",
        category = "System",
        filters = {
            -- Format
            currentFormat = "github",
            -- Core sections
            includeChampionPoints = true,
            includeChampionDetailed = false,
            includeChampionConstellationTable = false,
            includeChampionPointStarTables = false,
            includeSkillBars = true,
            includeSkills = true,
            includeSkillMorphs = false,
            includeEquipment = true,
            includeCombatStats = true,
            includeCompanion = true,
            includeBuffs = true,
            includeAttributes = true,
            includeDLCAccess = true,
            includeRole = true,
            includeLocation = true,
            includeBuildNotes = true,
            includeQuickStats = true,
            includeAttentionNeeded = true,
            includeTableOfContents = true,
            -- Extended sections
            includeCurrency = true,
            includeProgression = false,
            includeRidingSkills = false,
            includeInventory = true,
            includePvP = false,
            includeCollectibles = true,
            includeCollectiblesDetailed = false,
            includeCrafting = false,
            includeAchievements = false,
            includeAchievementsDetailed = false,
            showAllAchievements = true,
            includeQuests = false,
            includeQuestsDetailed = false,
            showAllQuests = true,
            includeEquipmentEnhancement = false,
            includeEquipmentAnalysis = false,
            includeEquipmentRecommendations = false,
            includeWorldProgress = false,
            includeTitlesHousing = false,
            includePvPStats = false,
            includeArmoryBuilds = false,
            includeTalesOfTribute = false,
            includeUndauntedPledges = false,
            includeGuilds = false,
            -- Links
            enableAbilityLinks = true,
            enableSetLinks = true,
            -- Quality filters
            minSkillRank = 1,
            showMaxedSkills = true,
            showAllRidingSkills = true,
            minEquipQuality = 0,
            hideEmptySlots = false
        }
    },
    
    -- Combat Focus
    ["Combat Focus"] = {
        name = "Combat Focus",
        description = "Focus on combat-related information",
        category = "Combat",
        filters = {
            includeChampionPoints = true,
            includeChampionDetailed = false,
            includeChampionConstellationTable = false,
            includeChampionPointStarTables = false,
            includeSkillBars = true,
            includeSkills = true,
            includeEquipment = true,
            includeCombatStats = true,
            includeBuffs = true,
            includeAttributes = true,
            includeRole = true,
            includeCompanion = false,
            includeLocation = false,
            includeBuildNotes = true,
            includeDLCAccess = false,
            includeCurrency = false,
            includeProgression = false,
            includeRidingSkills = false,
            includeInventory = false,
            includePvP = true,
            includeCollectibles = false,
            includeCrafting = false,
            includeAchievements = false,
            includeQuests = false,
            includeEquipmentEnhancement = true,
            minEquipQuality = 4,  -- Purple+
            hideEmptySlots = true
        }
    },
    
    -- Crafting Focus
    ["Crafting Focus"] = {
        name = "Crafting Focus",
        description = "Focus on crafting and progression",
        category = "Crafting",
        filters = {
            includeChampionPoints = true,
            includeChampionDetailed = false,
            includeChampionConstellationTable = false,
            includeChampionPointStarTables = false,
            includeSkillBars = false,
            includeSkills = false,
            includeEquipment = true,
            includeCompanion = false,
            includeCombatStats = false,
            includeBuffs = false,
            includeAttributes = false,
            includeRole = false,
            includeLocation = false,
            includeBuildNotes = true,
            includeDLCAccess = true,
            includeCurrency = true,
            includeProgression = true,
            includeRidingSkills = false,
            includeInventory = true,
            includePvP = false,
            includeCollectibles = false,
            includeCrafting = true,
            includeAchievements = true,
            includeQuests = false,
            includeEquipmentEnhancement = true,
            minEquipQuality = 0,
            hideEmptySlots = false
        }
    },
    
    -- Social Focus
    ["Social Focus"] = {
        name = "Social Focus",
        description = "Focus on social and collection aspects",
        category = "Social",
        filters = {
            includeChampionPoints = true,
            includeChampionDetailed = false,
            includeChampionConstellationTable = false,
            includeChampionPointStarTables = false,
            includeSkillBars = false,
            includeSkills = false,
            includeEquipment = true,
            includeCompanion = true,
            includeCombatStats = false,
            includeBuffs = false,
            includeAttributes = false,
            includeRole = true,
            includeLocation = true,
            includeBuildNotes = true,
            includeDLCAccess = true,
            includeCurrency = true,
            includeProgression = true,
            includeRidingSkills = true,
            includeInventory = true,
            includePvP = false,
            includeCollectibles = true,
            includeCrafting = true,
            includeAchievements = true,
            includeQuests = true,
            includeEquipmentEnhancement = false,
            minEquipQuality = 0,
            hideEmptySlots = false
        }
    },
    
    -- Minimal Focus
    ["Minimal Focus"] = {
        name = "Minimal Focus",
        description = "Minimal information display",
        category = "Minimal",
        filters = {
            includeChampionPoints = true,
            includeChampionDetailed = false,
            includeChampionConstellationTable = false,
            includeChampionPointStarTables = false,
            includeSkillBars = true,
            includeSkills = false,
            includeEquipment = true,
            includeCompanion = false,
            includeCombatStats = false,
            includeBuffs = false,
            includeAttributes = false,
            includeRole = true,
            includeLocation = false,
            includeBuildNotes = false,
            includeDLCAccess = false,
            includeCurrency = false,
            includeProgression = false,
            includeRidingSkills = false,
            includeInventory = false,
            includePvP = false,
            includeCollectibles = false,
            includeCrafting = false,
            includeAchievements = false,
            includeQuests = false,
            includeEquipmentEnhancement = false,
            minEquipQuality = 4,  -- Purple+
            hideEmptySlots = true
        }
    }
}

-- =====================================================
-- FILTER MANAGER CLASS
-- =====================================================

CM.Settings.FilterManager = {}

function CM.Settings.FilterManager:Initialize()
    -- Ensure CM.settings exists
    if not CM.settings then
        CM.Error("CM.settings not initialized - cannot initialize FilterManager")
        return
    end
    
    -- Initialize filter manager
    CM.settings.filters = CM.settings.filters or {}
    CM.settings.filterPresets = CM.settings.filterPresets or {}
    CM.settings.activeFilter = CM.settings.activeFilter or ""  -- Empty means no filter applied
    
    -- Clean up: Remove any user-created filters that conflict with preset names
    -- (Presets take priority, so user filters with same names should be removed)
    local presetNames = {}
    for name, _ in pairs(FILTER_PRESETS) do
        presetNames[name] = true
    end
    
    local removedCount = 0
    for name, _ in pairs(CM.settings.filters) do
        if presetNames[name] then
            CM.settings.filters[name] = nil
            removedCount = removedCount + 1
            CM.DebugPrint("FILTER_MANAGER", "Removed user filter '" .. name .. "' (conflicts with preset)")
        end
    end
    
    if removedCount > 0 then
        CM.settings._lastModified = GetTimeStamp()
    end
    
    -- CRITICAL: Always clear dangerous filters on initialization
    -- "None" and "All" filters were removed but may still exist in old SavedVariables
    if not CM.settings.activeFilter or CM.settings.activeFilter == "None" or CM.settings.activeFilter == "All" then
        CM.DebugPrint("FILTER_MANAGER", string.format("Clearing dangerous filter: '%s'", tostring(CM.settings.activeFilter)))
        CM.settings.activeFilter = ""  -- Empty means no filter applied
        CM.settings._lastModified = GetTimeStamp()
        
        -- Force save to ensure it persists
        if CM.settings.SetValue then
            CM.settings:SetValue("activeFilter", "")
        end
    end
    
    -- Initialize default filter presets
    for name, preset in pairs(FILTER_PRESETS) do
        if not CM.settings.filterPresets[name] then
            CM.settings.filterPresets[name] = preset
        end
    end
    
    CM.DebugPrint("FILTER_MANAGER", "Filter manager initialized" .. (removedCount > 0 and (" (" .. removedCount .. " conflicting filters removed)") or ""))
end

-- =====================================================
-- FILTER OPERATIONS
-- =====================================================

function CM.Settings.FilterManager:CreateFilter(name, description, category, filters)
    if not CM.settings then
        CM.Error("CM.settings not initialized")
        return false
    end
    
    if CM.settings.filters[name] then
        CM.Error("Filter '" .. name .. "' already exists")
        return false
    end
    
    local filter = {
        name = name,
        description = description or "",
        category = category or "Custom",
        filters = filters or {},
        created = GetTimeStamp(),
        version = CM.version
    }
    
    CM.settings.filters[name] = filter
    CM.settings._lastModified = GetTimeStamp()
    
    CM.Info("Filter '" .. name .. "' created")
    return true
end

function CM.Settings.FilterManager:UpdateFilter(name, updates)
    if not CM.settings then
        CM.Error("CM.settings not initialized")
        return false
    end
    
    if not CM.settings.filters[name] then
        CM.Error("Filter '" .. name .. "' not found")
        return false
    end
    
    local filter = CM.settings.filters[name]
    
    -- Update filter properties
    if updates.name then filter.name = updates.name end
    if updates.description then filter.description = updates.description end
    if updates.category then filter.category = updates.category end
    if updates.filters then filter.filters = updates.filters end
    
    filter.modified = GetTimeStamp()
    CM.settings._lastModified = GetTimeStamp()
    
    CM.Info("Filter '" .. name .. "' updated")
    return true
end

function CM.Settings.FilterManager:DeleteFilter(name)
    if not CM.settings then
        CM.Error("CM.settings not initialized")
        return false
    end
    
    if not CM.settings.filters[name] then
        CM.Error("Filter '" .. name .. "' not found")
        return false
    end
    
    CM.settings.filters[name] = nil
    CM.settings._lastModified = GetTimeStamp()
    
    -- If this was the active filter, clear it
    if CM.settings.activeFilter == name then
        CM.settings.activeFilter = ""
    end
    
    CM.Info("Filter '" .. name .. "' deleted")
    return true
end

function CM.Settings.FilterManager:ApplyFilter(name)
    if not CM.settings then
        CM.Error("CM.settings not initialized")
        return false
    end
    
    -- Handle empty filter (no filter applied)
    if not name or name == "" then
        CM.settings.activeFilter = ""
        CM.settings._lastModified = GetTimeStamp()
        CM.DebugPrint("FILTER_MANAGER", "Active filter cleared (no filter applied)")
        return true
    end
    
    local filter = CM.settings.filters[name] or FILTER_PRESETS[name]
    
    if not filter then
        CM.Error("Filter '" .. name .. "' not found")
        return false
    end
    
    -- Get filters (handle lazy loading for "None" filter)
    local filters = filter.filters
    if type(filters) == "function" then
        filters = filters()
    end
    
    -- Apply filter settings
    -- Apply all filter settings, even if they don't exist in CM.settings yet
    -- This allows filters to add new settings
    local applied = 0
    for key, value in pairs(filters) do
        -- Skip internal settings
        if key ~= "filters" and key ~= "filterPresets" and key ~= "activeFilter" then
            CM.settings[key] = value
            applied = applied + 1
        end
    end
    
    -- Update active filter
    CM.settings.activeFilter = name
    CM.settings._lastModified = GetTimeStamp()
    
    -- Sync format to core
    CM.currentFormat = CM.settings.currentFormat
    
    CM.Info("Filter '" .. name .. "' applied (" .. applied .. " settings changed)")
    return true
end

function CM.Settings.FilterManager:SaveCurrentAsFilter(name, description, category)
    if not CM.settings then
        CM.Error("CM.settings not initialized")
        return false
    end
    
    if CM.settings.filters[name] then
        CM.Error("Filter '" .. name .. "' already exists")
        return false
    end
    
    -- Create filter from current settings
    local filters = {}
    for key, value in pairs(CM.settings) do
        if key ~= "filters" and key ~= "filterPresets" and key ~= "activeFilter" and
           key ~= "profiles" and key ~= "settingsVersion" and key ~= "_initialized" and
           key ~= "_lastModified" and key ~= "_panelOpened" and key ~= "_firstRun" then
            filters[key] = value
        end
    end
    
    return self:CreateFilter(name, description, category, filters)
end

-- =====================================================
-- FILTER QUERIES
-- =====================================================

function CM.Settings.FilterManager:GetFilter(name)
    if not CM.settings then
        return FILTER_PRESETS[name]
    end
    return CM.settings.filters[name] or FILTER_PRESETS[name]
end

function CM.Settings.FilterManager:GetFilterList()
    local filters = {}
    local seenNames = {}  -- Track names to prevent duplicates
    
    -- Add preset filters first (these take priority)
    for name, filter in pairs(FILTER_PRESETS) do
        if not seenNames[name] then
            table.insert(filters, {
                name = name,
                description = filter.description,
                category = filter.category,
                isPreset = true
            })
            seenNames[name] = true
        end
    end
    
    -- Add user filters (skip any that conflict with preset names)
    if CM.settings and CM.settings.filters then
        for name, filter in pairs(CM.settings.filters) do
            -- Skip if this name already exists as a preset OR if we've already seen it
            if not FILTER_PRESETS[name] and not seenNames[name] then
                table.insert(filters, {
                    name = name,
                    description = filter.description,
                    category = filter.category,
                    created = filter.created,
                    version = filter.version,
                    isPreset = false
                })
                seenNames[name] = true
            end
        end
    end
    
    -- Sort with priority order: Defaults first, then others alphabetically
    local function GetFilterPriority(name)
        if name == "Defaults" then return 1
        else return 2  -- All other filters
        end
    end
    
    table.sort(filters, function(a, b)
        -- Both are same type (preset or user)
        local aPriority = GetFilterPriority(a.name)
        local bPriority = GetFilterPriority(b.name)
        
        -- If both have priority, sort by priority
        if aPriority ~= bPriority then
            return aPriority < bPriority
        end
        
        -- Both are regular filters, sort alphabetically
        return a.name < b.name
    end)
    
    return filters
end

function CM.Settings.FilterManager:GetFiltersByCategory(category)
    local filters = {}
    
    for _, filter in ipairs(self:GetFilterList()) do
        if filter.category == category then
            table.insert(filters, filter)
        end
    end
    
    return filters
end

function CM.Settings.FilterManager:GetActiveFilter()
    if not CM.settings then
        return ""
    end
    return CM.settings.activeFilter or ""
end

-- Reset active filter when settings are manually changed
function CM.Settings.FilterManager:ResetIfFilterActive()
    if CM.settings and CM.settings.activeFilter and CM.settings.activeFilter ~= "" then
        CM.settings.activeFilter = ""
        CM.settings._lastModified = GetTimeStamp()
        CM.DebugPrint("FILTER_MANAGER", "Active filter reset due to manual setting change")
        return true
    end
    return false
end

-- =====================================================
-- FILTER ANALYSIS
-- =====================================================

function CM.Settings.FilterManager:AnalyzeCurrentSettings()
    if not CM.settings then
        CM.Error("CM.settings not initialized")
        return {
            enabledSections = 0,
            totalSections = 0,
            categories = {},
            recommendations = {}
        }
    end
    
    local analysis = {
        enabledSections = 0,
        totalSections = 0,
        categories = {},
        recommendations = {}
    }
    
    -- Count enabled sections
    for category, data in pairs(FILTER_CATEGORIES) do
        local enabled = 0
        local total = #data.settings
        
        for _, setting in ipairs(data.settings) do
            if CM.settings[setting] then
                enabled = enabled + 1
            end
        end
        
        analysis.categories[category] = {
            enabled = enabled,
            total = total,
            percentage = total > 0 and math.floor((enabled / total) * 100) or 0
        }
        
        analysis.enabledSections = analysis.enabledSections + enabled
        analysis.totalSections = analysis.totalSections + total
    end
    
    -- Generate recommendations
    if analysis.categories["Content"] and analysis.categories["Content"].percentage < 50 then
        table.insert(analysis.recommendations, {
            type = "Content",
            message = "Consider enabling more content sections for comprehensive character display",
            priority = "Medium"
        })
    end
    
    if analysis.categories["Extended"] and analysis.categories["Extended"].percentage > 80 then
        table.insert(analysis.recommendations, {
            type = "Performance",
            message = "Many extended sections enabled - consider using a more focused filter",
            priority = "Low"
        })
    end
    
    return analysis
end

-- =====================================================
-- FILTER EXPORT/IMPORT
-- =====================================================

function CM.Settings.FilterManager:ExportFilter(name)
    if not CM.Settings.Initializer or not CM.Settings.Initializer.SerializeTable then
        CM.Error("SerializeTable function not available")
        return nil
    end
    
    local filter = self:GetFilter(name)
    if not filter then
        CM.Error("Filter '" .. name .. "' not found")
        return nil
    end
    
    -- Get filters (handle lazy loading) - create a copy for export
    local filterCopy = {}
    for k, v in pairs(filter) do
        filterCopy[k] = v
    end
    
    -- Resolve lazy-loaded filters
    if type(filter.filters) == "function" then
        filterCopy.filters = filter.filters()
    end
    
    local export = {
        version = CM.version,
        timestamp = GetTimeStamp(),
        filter = filterCopy
    }
    
    return CM.Settings.Initializer:SerializeTable(export)
end

function CM.Settings.FilterManager:ImportFilter(importString)
    if not CM.settings then
        CM.Error("CM.settings not initialized")
        return false
    end
    
    if not CM.Settings.Initializer or not CM.Settings.Initializer.DeserializeTable then
        CM.Error("DeserializeTable function not available")
        return false
    end
    
    local success, data = pcall(function()
        return CM.Settings.Initializer:DeserializeTable(importString)
    end)
    
    if not success or not data or not data.filter then
        CM.Error("Invalid filter import data: " .. (data or "unknown error"))
        return false
    end
    
    local filter = data.filter
    local name = filter.name
    
    -- Check if filter already exists
    if CM.settings.filters[name] then
        CM.Error("Filter '" .. name .. "' already exists")
        return false
    end
    
    -- Import filter
    CM.settings.filters[name] = filter
    CM.settings._lastModified = GetTimeStamp()
    
    CM.Info("Filter '" .. name .. "' imported successfully")
    return true
end

-- =====================================================
-- FILTER VALIDATION
-- =====================================================

function CM.Settings.FilterManager:ValidateFilter(filter)
    local errors = {}
    
    if not filter.name or filter.name == "" then
        table.insert(errors, "Filter name is required")
    end
    
    -- Get filters (handle lazy loading)
    local filters = filter.filters
    if type(filters) == "function" then
        filters = filters()
    end
    
    if not filters or type(filters) ~= "table" then
        table.insert(errors, "Filter settings are required")
    end
    
    -- Validate filter settings
    if filters then
        for key, value in pairs(filters) do
            if type(value) ~= "boolean" and type(value) ~= "number" and type(value) ~= "string" then
                table.insert(errors, "Invalid value for setting '" .. key .. "'")
            end
        end
    end
    
    return #errors == 0, errors
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.Settings.FilterManager.FILTER_CATEGORIES = FILTER_CATEGORIES
CM.Settings.FilterManager.FILTER_PRESETS = FILTER_PRESETS

return CM.Settings.FilterManager
