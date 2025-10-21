-- CharacterMarkdown - Markdown Generation Engine
-- Generates markdown in multiple formats (GitHub, VSCode, Discord, Quick)

local CM = CharacterMarkdown

-- Import section generators (these modules register themselves to CM.generators.sections)
-- Note: The modules are loaded via CharacterMarkdown.xml

-- Get references to imported section generators for convenience
local function GetGenerators()
    return {
        -- Character sections
        GenerateQuickSummary = CM.generators.sections.GenerateQuickSummary,
        GenerateHeader = CM.generators.sections.GenerateHeader,
        GenerateQuickStats = CM.generators.sections.GenerateQuickStats,
        GenerateAttentionNeeded = CM.generators.sections.GenerateAttentionNeeded,
        GenerateOverview = CM.generators.sections.GenerateOverview,
        GenerateProgression = CM.generators.sections.GenerateProgression,
        GenerateCustomNotes = CM.generators.sections.GenerateCustomNotes,
        
        -- Economy sections
        GenerateCurrency = CM.generators.sections.GenerateCurrency,
        GenerateRidingSkills = CM.generators.sections.GenerateRidingSkills,
        GenerateInventory = CM.generators.sections.GenerateInventory,
        GeneratePvP = CM.generators.sections.GeneratePvP,
        
        -- Equipment sections
        GenerateSkillBars = CM.generators.sections.GenerateSkillBars,
        GenerateEquipment = CM.generators.sections.GenerateEquipment,
        GenerateSkills = CM.generators.sections.GenerateSkills,
        
        -- Combat sections
        GenerateCombatStats = CM.generators.sections.GenerateCombatStats,
        GenerateAttributes = CM.generators.sections.GenerateAttributes,
        GenerateBuffs = CM.generators.sections.GenerateBuffs,
        
        -- Content sections
        GenerateDLCAccess = CM.generators.sections.GenerateDLCAccess,
        GenerateMundus = CM.generators.sections.GenerateMundus,
        GenerateChampionPoints = CM.generators.sections.GenerateChampionPoints,
        -- DISABLED: Champion Diagram (experimental)
        -- GenerateChampionDiagram = CM.generators.GenerateChampionDiagram,
        GenerateCollectibles = CM.generators.sections.GenerateCollectibles,
        GenerateCrafting = CM.generators.sections.GenerateCrafting,
        
        -- Companion sections
        GenerateCompanion = CM.generators.sections.GenerateCompanion,
        
        -- Footer
        GenerateFooter = CM.generators.sections.GenerateFooter,
    }
end

-- =====================================================
-- ERROR AGGREGATION SYSTEM
-- =====================================================

local collectionErrors = {}

local function SafeCollect(collectorName, collectorFunc)
    local success, result = pcall(collectorFunc)
    
    if not success then
        table.insert(collectionErrors, {
            collector = collectorName,
            error = tostring(result)
        })
        CM.DebugPrint("COLLECTOR", string.format("❌ %s failed: %s", collectorName, tostring(result)))
        return {}  -- Return empty data on failure
    end
    
    CM.DebugPrint("COLLECTOR", string.format("✅ %s completed", collectorName))
    return result
end

local function ReportCollectionErrors()
    if #collectionErrors == 0 then
        CM.DebugPrint("COLLECTOR", "All collectors completed successfully")
        return
    end
    
    -- Log errors to chat (always shown, not just debug mode)
    CM.Warn(string.format("Encountered %d error(s) during data collection:", #collectionErrors))
    for i, err in ipairs(collectionErrors) do
        d(string.format("  %d. %s: %s", i, err.collector, err.error))
    end
    d("[CharacterMarkdown] Generated markdown may be incomplete. Try /reloadui if issues persist.")
end

local function ResetCollectionErrors()
    collectionErrors = {}
end

-- =====================================================
-- SETTINGS HELPER
-- =====================================================

-- Helper function to check if a setting is enabled
-- Returns true if setting is true OR nil (default enabled)
-- Returns false if setting is explicitly false
local function IsSettingEnabled(settings, settingName, defaultValue)
    local value = settings[settingName]
    if value == nil then
        return defaultValue  -- Use provided default
    end
    return value == true
end

-- =====================================================
-- SECTION REGISTRY PATTERN
-- =====================================================

-- Section configuration: defines all sections with their conditions
local function GetSectionRegistry(format, settings, gen, data)
    return {
        -- Header (always included)
        {
            name = "Header",
            condition = true,
            generator = function()
                return gen.GenerateHeader(data.character, data.cp, format)
            end
        },
        
        -- Quick Stats Summary (non-Discord only)
        {
            name = "QuickStats",
            condition = format ~= "discord" and IsSettingEnabled(settings, "includeQuickStats", true),
            generator = function()
                return gen.GenerateQuickStats(data.character, data.progression, data.currency, 
                    data.equipment, data.cp, data.inventory, format)
            end
        },
        
        -- Attention Needed (non-Discord only)
        {
            name = "AttentionNeeded",
            condition = format ~= "discord" and IsSettingEnabled(settings, "includeAttentionNeeded", true),
            generator = function()
                return gen.GenerateAttentionNeeded(data.progression, data.inventory, data.riding, format)
            end
        },
        
        -- Overview (non-Discord only)
        {
            name = "Overview",
            condition = format ~= "discord",
            generator = function()
                return gen.GenerateOverview(data.character, data.role, data.location, data.buffs, 
                    data.mundus, data.riding, data.pvp, data.progression, settings, format)
            end
        },
        
        -- Currency
        {
            name = "Currency",
            condition = IsSettingEnabled(settings, "includeCurrency", true),
            generator = function()
                return gen.GenerateCurrency(data.currency, format)
            end
        },
        
        -- Riding Skills (Discord only)
        {
            name = "RidingSkills",
            condition = format == "discord" and IsSettingEnabled(settings, "includeRidingSkills", false),
            generator = function()
                return gen.GenerateRidingSkills(data.riding, format)
            end
        },
        
        -- Inventory
        {
            name = "Inventory",
            condition = IsSettingEnabled(settings, "includeInventory", true),
            generator = function()
                return gen.GenerateInventory(data.inventory, format)
            end
        },
        
        -- PvP (Discord only)
        {
            name = "PvP",
            condition = format == "discord" and IsSettingEnabled(settings, "includePvP", false),
            generator = function()
                return gen.GeneratePvP(data.pvp, format)
            end
        },
        
        -- Collectibles
        {
            name = "Collectibles",
            condition = IsSettingEnabled(settings, "includeCollectibles", true),
            generator = function()
                return gen.GenerateCollectibles(data.collectibles, format)
            end
        },
        
        -- Crafting
        {
            name = "Crafting",
            condition = IsSettingEnabled(settings, "includeCrafting", false),
            generator = function()
                return gen.GenerateCrafting(data.crafting, format)
            end
        },
        
        -- Attributes (Discord only)
        {
            name = "Attributes",
            condition = format == "discord" and IsSettingEnabled(settings, "includeAttributes", true),
            generator = function()
                return gen.GenerateAttributes(data.character, format)
            end
        },
        
        -- Buffs (Discord only)
        {
            name = "Buffs",
            condition = format == "discord" and IsSettingEnabled(settings, "includeBuffs", true),
            generator = function()
                return gen.GenerateBuffs(data.buffs, format)
            end
        },
        
        -- Custom Notes (requires both setting enabled AND content present)
        {
            name = "CustomNotes",
            condition = IsSettingEnabled(settings, "includeBuildNotes", true) 
                       and data.customNotes and data.customNotes ~= "",
            generator = function()
                return gen.GenerateCustomNotes(data.customNotes, format)
            end
        },
        
        -- Divider (non-Discord only)
        {
            name = "Divider",
            condition = format ~= "discord",
            generator = function()
                return "---\n\n"
            end
        },
        
        -- DLC Access
        {
            name = "DLCAccess",
            condition = IsSettingEnabled(settings, "includeDLCAccess", true),
            generator = function()
                return gen.GenerateDLCAccess(data.dlc, format)
            end
        },
        
        -- Mundus (Discord only)
        {
            name = "Mundus",
            condition = format == "discord",
            generator = function()
                return gen.GenerateMundus(data.mundus, format)
            end
        },
        
        -- Champion Points
        {
            name = "ChampionPoints",
            condition = IsSettingEnabled(settings, "includeChampionPoints", true),
            generator = function()
                return gen.GenerateChampionPoints(data.cp, format)
            end
        },
        
        -- Skill Bars
        {
            name = "SkillBars",
            condition = IsSettingEnabled(settings, "includeSkillBars", true),
            generator = function()
                return gen.GenerateSkillBars(data.skillBar, format)
            end
        },
        
        -- Combat Stats
        {
            name = "CombatStats",
            condition = IsSettingEnabled(settings, "includeCombatStats", true),
            generator = function()
                return gen.GenerateCombatStats(data.stats, format)
            end
        },
        
        -- Equipment
        {
            name = "Equipment",
            condition = IsSettingEnabled(settings, "includeEquipment", true),
            generator = function()
                return gen.GenerateEquipment(data.equipment, format)
            end
        },
        
        -- Skills
        {
            name = "Skills",
            condition = IsSettingEnabled(settings, "includeSkills", true),
            generator = function()
                return gen.GenerateSkills(data.skill, format)
            end
        },
        
        -- Companion
        {
            name = "Companion",
            condition = IsSettingEnabled(settings, "includeCompanion", true) and data.companion.active,
            generator = function()
                return gen.GenerateCompanion(data.companion, format)
            end
        },
    }
end

-- =====================================================
-- MAIN GENERATION FUNCTION
-- =====================================================

local function GenerateMarkdown(format)
    format = format or "github"
    
    -- Reset error tracking
    ResetCollectionErrors()
    
    -- Verify collectors are loaded
    if not CM.collectors then
        CM.Error("CM.collectors namespace doesn't exist!")
        CM.Error("The addon did not load correctly. Try /reloadui")
        return "ERROR: Addon not loaded. Type /reloadui and try again."
    end
    
    -- Check if a critical collector exists (test case)
    if not CM.collectors.CollectCharacterData then
        CM.Error("Collectors not loaded!")
        CM.Error("Available in CM.collectors:")
        for k, v in pairs(CM.collectors) do
            d("[CharacterMarkdown]   - " .. k)
        end
        return "ERROR: Collectors not loaded. Type /reloadui and try again."
    end
    
    -- Collect all data with error handling and aggregation
    CM.DebugPrint("GENERATOR", "Starting data collection...")
    
    local collectedData = {
        character = SafeCollect("CollectCharacterData", CM.collectors.CollectCharacterData),
        dlc = SafeCollect("CollectDLCAccess", CM.collectors.CollectDLCAccess),
        mundus = SafeCollect("CollectMundusData", CM.collectors.CollectMundusData),
        buffs = SafeCollect("CollectActiveBuffs", CM.collectors.CollectActiveBuffs),
        cp = SafeCollect("CollectChampionPointData", CM.collectors.CollectChampionPointData),
        skillBar = SafeCollect("CollectSkillBarData", CM.collectors.CollectSkillBarData),
        stats = SafeCollect("CollectCombatStatsData", CM.collectors.CollectCombatStatsData),
        equipment = SafeCollect("CollectEquipmentData", CM.collectors.CollectEquipmentData),
        skill = SafeCollect("CollectSkillProgressionData", CM.collectors.CollectSkillProgressionData),
        companion = SafeCollect("CollectCompanionData", CM.collectors.CollectCompanionData),
        currency = SafeCollect("CollectCurrencyData", CM.collectors.CollectCurrencyData),
        progression = SafeCollect("CollectProgressionData", CM.collectors.CollectProgressionData),
        riding = SafeCollect("CollectRidingSkillsData", CM.collectors.CollectRidingSkillsData),
        inventory = SafeCollect("CollectInventoryData", CM.collectors.CollectInventoryData),
        pvp = SafeCollect("CollectPvPData", CM.collectors.CollectPvPData),
        role = SafeCollect("CollectRoleData", CM.collectors.CollectRoleData),
        location = SafeCollect("CollectLocationData", CM.collectors.CollectLocationData),
        collectibles = SafeCollect("CollectCollectiblesData", CM.collectors.CollectCollectiblesData),
        crafting = SafeCollect("CollectCraftingKnowledgeData", CM.collectors.CollectCraftingKnowledgeData),
        customNotes = CharacterMarkdownData and CharacterMarkdownData.customNotes or ""
    }
    
    -- Report any collection errors
    ReportCollectionErrors()
    
    CM.DebugPrint("GENERATOR", string.format("Data collection completed with %d error(s)", #collectionErrors))
    
    local settings = CharacterMarkdownSettings or {}
    
    -- Get section generators
    local gen = GetGenerators()
    
    -- QUICK FORMAT - one-line summary
    if format == "quick" then
        return gen.GenerateQuickSummary(collectedData.character, collectedData.equipment)
    end
    
    -- FULL FORMATS (GitHub, VSCode, Discord)
    CM.DebugPrint("GENERATOR", string.format("Generating markdown in %s format...", format))
    
    local markdown = ""
    
    -- Get section registry
    local sections = GetSectionRegistry(format, settings, gen, collectedData)
    
    -- Generate all sections based on registry
    for _, section in ipairs(sections) do
        if section.condition then
            local success, result = pcall(section.generator)
            if success then
                markdown = markdown .. result
                CM.DebugPrint("GENERATOR", string.format("✅ Section '%s' generated", section.name))
            else
                CM.Warn(string.format("Failed to generate section '%s': %s", section.name, tostring(result)))
                CM.DebugPrint("GENERATOR", string.format("❌ Section '%s' failed: %s", section.name, tostring(result)))
            end
        else
            CM.DebugPrint("GENERATOR", string.format("⏭️  Section '%s' skipped (condition not met)", section.name))
        end
    end
    
    -- Footer (always included)
    local footerSuccess, footerResult = pcall(gen.GenerateFooter, format, string.len(markdown))
    if footerSuccess then
        markdown = markdown .. footerResult
        CM.DebugPrint("GENERATOR", "✅ Footer generated")
    else
        CM.Warn(string.format("Failed to generate footer: %s", tostring(footerResult)))
    end
    
    CM.DebugPrint("GENERATOR", string.format("Markdown generation complete: %d bytes", string.len(markdown)))
    
    return markdown
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.generators.GenerateMarkdown = GenerateMarkdown
