-- CharacterMarkdown - Filter Manager
-- Phase 8: Advanced filtering and customization system

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
            "includeChampionDetailed", "includeChampionSlottableOnly", "includeSkillMorphs",
            "includeCollectiblesDetailed", "includeAchievementsDetailed", "includeAchievementsInProgress",
            "includeQuestsDetailed", "includeQuestsActiveOnly", "includeEquipmentAnalysis",
            "includeEquipmentRecommendations"
        }
    },
    
    -- Quality Filters
    ["Quality"] = {
        emoji = "⭐",
        description = "Quality and level filters",
        settings = {
            "minSkillRank", "hideMaxedSkills", "minEquipQuality", "hideEmptySlots"
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

local FILTER_PRESETS = {
    -- Combat Focus
    ["Combat Focus"] = {
        name = "Combat Focus",
        description = "Focus on combat-related information",
        category = "Combat",
        filters = {
            includeChampionPoints = true,
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
    -- Initialize filter manager
    CM.settings.filters = CM.settings.filters or {}
    CM.settings.filterPresets = CM.settings.filterPresets or {}
    CM.settings.activeFilter = CM.settings.activeFilter or "None"
    
    -- Initialize default filter presets
    for name, preset in pairs(FILTER_PRESETS) do
        if not CM.settings.filterPresets[name] then
            CM.settings.filterPresets[name] = preset
        end
    end
    
    CM.DebugPrint("FILTER_MANAGER", "Filter manager initialized")
end

-- =====================================================
-- FILTER OPERATIONS
-- =====================================================

function CM.Settings.FilterManager:CreateFilter(name, description, category, filters)
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
    if not CM.settings.filters[name] then
        CM.Error("Filter '" .. name .. "' not found")
        return false
    end
    
    CM.settings.filters[name] = nil
    CM.settings._lastModified = GetTimeStamp()
    
    -- If this was the active filter, switch to None
    if CM.settings.activeFilter == name then
        CM.settings.activeFilter = "None"
    end
    
    CM.Info("Filter '" .. name .. "' deleted")
    return true
end

function CM.Settings.FilterManager:ApplyFilter(name)
    local filter = CM.settings.filters[name] or FILTER_PRESETS[name]
    
    if not filter then
        CM.Error("Filter '" .. name .. "' not found")
        return false
    end
    
    -- Apply filter settings
    local applied = 0
    for key, value in pairs(filter.filters) do
        if CM.settings[key] ~= nil then
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
    return CM.settings.filters[name] or FILTER_PRESETS[name]
end

function CM.Settings.FilterManager:GetFilterList()
    local filters = {}
    
    -- Add user filters
    for name, filter in pairs(CM.settings.filters) do
        table.insert(filters, {
            name = name,
            description = filter.description,
            category = filter.category,
            created = filter.created,
            version = filter.version,
            isPreset = false
        })
    end
    
    -- Add preset filters
    for name, filter in pairs(FILTER_PRESETS) do
        table.insert(filters, {
            name = name,
            description = filter.description,
            category = filter.category,
            isPreset = true
        })
    end
    
    -- Sort by name
    table.sort(filters, function(a, b)
        if a.isPreset ~= b.isPreset then
            return not a.isPreset  -- User filters first
        end
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
    return CM.settings.activeFilter
end

-- =====================================================
-- FILTER ANALYSIS
-- =====================================================

function CM.Settings.FilterManager:AnalyzeCurrentSettings()
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
    local filter = self:GetFilter(name)
    if not filter then
        CM.Error("Filter '" .. name .. "' not found")
        return nil
    end
    
    local export = {
        version = CM.version,
        timestamp = GetTimeStamp(),
        filter = filter
    }
    
    return CM.Settings.Initializer:SerializeTable(export)
end

function CM.Settings.FilterManager:ImportFilter(importString)
    local success, data = pcall(CM.Settings.Initializer.DeserializeTable, CM.Settings.Initializer, importString)
    if not success or not data or not data.filter then
        CM.Error("Invalid filter import data")
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
    
    if not filter.filters or type(filter.filters) ~= "table" then
        table.insert(errors, "Filter settings are required")
    end
    
    -- Validate filter settings
    if filter.filters then
        for key, value in pairs(filter.filters) do
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
