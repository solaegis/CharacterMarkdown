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
        GenerateTableOfContents = CM.generators.sections.GenerateTableOfContents,
        GenerateDynamicTableOfContents = CM.generators.sections.GenerateDynamicTableOfContents,
        
        -- Economy sections
        GenerateCurrency = CM.generators.sections.GenerateCurrency,
        GenerateRidingSkills = CM.generators.sections.GenerateRidingSkills,
        GenerateInventory = CM.generators.sections.GenerateInventory,
        GeneratePvP = CM.generators.sections.GeneratePvP,
        
        -- Equipment sections
        GenerateSkillBars = CM.generators.sections.GenerateSkillBars,
        GenerateSkillMorphs = CM.generators.sections.GenerateSkillMorphs,
        GenerateEquipment = CM.generators.sections.GenerateEquipment,
        GenerateSkills = CM.generators.sections.GenerateSkills,
        
        -- Combat sections
        GenerateCombatStats = CM.generators.sections.GenerateCombatStats,
        -- GenerateAttributes removed (no longer relevant)
        GenerateBuffs = CM.generators.sections.GenerateBuffs,
        
        -- Content sections
        GenerateDLCAccess = CM.generators.sections.GenerateDLCAccess,
        GenerateMundus = CM.generators.sections.GenerateMundus,
        GenerateChampionPoints = CM.generators.sections.GenerateChampionPoints,
        GenerateDetailedChampionPoints = CM.generators.sections.GenerateDetailedChampionPoints,
        GenerateChampionDiagram = CM.generators.sections.GenerateChampionDiagram,
        GenerateCollectibles = CM.generators.sections.GenerateCollectibles,
        GenerateCrafting = CM.generators.sections.GenerateCrafting,
        GenerateAchievements = CM.generators.sections.GenerateAchievements,
        GenerateAntiquities = CM.generators.sections.GenerateAntiquities,
        GenerateQuests = CM.generators.sections.GenerateQuests,
        GenerateEquipmentEnhancement = CM.generators.sections.GenerateEquipmentEnhancement,
        
        -- World sections
        GenerateWorldProgress = CM.generators.sections.GenerateWorldProgress,
        
        -- Tier 3-5 sections
        GenerateTitlesHousing = CM.generators.sections.GenerateTitlesHousing,
        GeneratePvPStats = CM.generators.sections.GeneratePvPStats,
        GenerateArmoryBuilds = CM.generators.sections.GenerateArmoryBuilds,
        GenerateUndauntedPledges = CM.generators.sections.GenerateUndauntedPledges,
        GenerateGuilds = CM.generators.sections.GenerateGuilds,
        
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
    -- Check if function exists before trying to call it
    if not collectorFunc or type(collectorFunc) ~= "function" then
        CM.Warn(string.format("⚠️ %s not available (function is nil)", collectorName))
        return {}  -- Return empty data if function doesn't exist
    end
    
    CM.Info(string.format("Calling collector: %s", collectorName))
    local success, result = pcall(collectorFunc)
    
    if not success then
        table.insert(collectionErrors, {
            collector = collectorName,
            error = tostring(result)
        })
        CM.Error(string.format("❌ %s failed: %s", collectorName, tostring(result)))
        -- Show the error immediately in chat for quest collector
        if collectorName == "CollectQuestData" then
            d("[CharacterMarkdown] Quest collector error: " .. tostring(result))
        end
        return {}  -- Return empty data on failure
    end
    
    if collectorName == "CollectQuestData" then
        CM.Info(string.format("✅ %s completed - result type: %s", collectorName, type(result)))
        if result then
            CM.Info(string.format("  - result.summary exists: %s", tostring(result.summary ~= nil)))
            CM.Info(string.format("  - result.active exists: %s", tostring(result.active ~= nil)))
            if result.summary then
                CM.Info(string.format("  - result.summary.activeQuests: %s", tostring(result.summary.activeQuests)))
            end
        else
            CM.Error("  - result is NIL!")
        end
    else
        CM.DebugPrint("COLLECTOR", string.format("✅ %s completed", collectorName))
    end
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
-- Settings are guaranteed to be true or false (never nil) via CM.GetSettings()
-- Returns true only if setting is explicitly true, false otherwise
local function IsSettingEnabled(settings, settingName, defaultValue)
    if not settings then
        CM.Warn(string.format("IsSettingEnabled: settings table is nil for '%s', using default: %s", settingName, tostring(defaultValue)))
        return defaultValue
    end
    local value = settings[settingName]
    -- Settings should never be nil (CM.GetSettings() ensures this), but handle it defensively
    if value == nil then
        CM.Warn(string.format("IsSettingEnabled: '%s' is nil (should never happen!), using default: %s", settingName, tostring(defaultValue)))
        return defaultValue
    end
    -- Explicitly check for true - false means disabled
    return value == true
end

-- =====================================================
-- SECTION REGISTRY PATTERN
-- =====================================================

-- Section configuration: defines all sections with their conditions
-- NOTE: settings parameter must be the FLATTENED settings table
local function GetSectionRegistry(format, settings, gen, data)
    -- Debug: Log settings at registry creation time
    CM.DebugPrint("REGISTRY", string.format("Building section registry - includeChampionPoints: %s (type: %s), includeChampionDiagram: %s (type: %s)", 
        tostring(settings.includeChampionPoints), type(settings.includeChampionPoints),
        tostring(settings.includeChampionDiagram), type(settings.includeChampionDiagram)))
    return {
        -- Header (controlled by includeHeader setting, not in TOC)
        {
            name = "Header",
            tocEntry = nil,  -- Not in TOC
            condition = IsSettingEnabled(settings, "includeHeader", true),
            generator = function()
                return gen.GenerateHeader(data.character, data.cp, format)
            end
        },
        
        -- Table of Contents (non-Discord/Quick only, not in TOC itself)
        {
            name = "TableOfContents",
            tocEntry = nil,  -- Not in TOC
            condition = function()
                local enabled = format ~= "discord" and format ~= "quick" and IsSettingEnabled(settings, "includeTableOfContents", true)
                CM.DebugPrint("TOC", string.format("TOC condition: format=%s, enabled=%s", tostring(format), tostring(enabled)))
                return enabled
            end,
            generator = function()
                -- TOC will be generated dynamically from this registry
                -- Note: registry reference will be injected after registry is built
                return ""  -- Will be replaced during generation
            end,
            dynamicTOC = true  -- Flag to indicate this needs special handling
        },
        
        -- ========================================
        -- SECTIONS IN TOC ORDER (as shown in Table of Contents)
        -- ========================================
        
        -- 1. 📋 Overview (Quick Stats Summary)
        {
            name = "QuickStats",
            tocEntry = {
                title = "📋 Overview",
                subsections = {"General", "Currency", "Character Stats"}
            },
            condition = format ~= "discord" and IsSettingEnabled(settings, "includeQuickStats", true),
            generator = function()
                return gen.GenerateQuickStats(data.character, data.stats, format, data.equipment, data.progression, data.currency, data.cp, data.inventory, data.location, data.buffs, data.pvp, data.titlesHousing, data.mundus, data.riding)
            end
        },
        
        -- 2. ⚔️ Combat Arsenal (Skill Bars + Equipment)
        {
            name = "SkillBars",
            tocEntry = {
                title = "⚔️ Combat Arsenal",
                subsections = {"Equipment & Active Sets", "🔥 Class", "⚔️ Weapon", "🛡️ Armor", "🌍 World", "🏰 Guild", "🏰 Alliance War", "⭐ Racial", "⚒️ Craft"}
            },
            condition = IsSettingEnabled(settings, "includeSkillBars", true),
            generator = function()
                -- Defensive: Ensure data exists and is valid
                local skillBarData = data.skillBar or {}
                local skillMorphsData = data.skillMorphs or {}
                local skillProgressionData = data.skill or {}
                local equipmentData = data.equipment or {}  -- Pass equipment data
                -- Wrap in pcall for extra safety
                local success, result = pcall(gen.GenerateSkillBars, skillBarData, format, skillMorphsData, skillProgressionData, equipmentData)
                if success then
                    return result or ""
                else
                    CM.Warn("GenerateSkillBars failed in generator wrapper: " .. tostring(result))
                    if format == "discord" then
                        return "\n**Skill Bars:**\n*Error generating skill bars*\n\n"
                    else
                        return "## ⚔️ Combat Arsenal\n\n*Error generating skill bars*\n\n---\n\n"
                    end
                end
            end
        },
        
        -- 3.5. ⭐ Champion Points (moved before Companion)
        {
            name = "ChampionPoints",
            tocEntry = {
                title = "⭐ Champion Points"
            },
            condition = function()
                -- Re-evaluate condition at generation time to ensure we have latest settings
                local currentSettings = CM.GetSettings() or settings
                local enabled = IsSettingEnabled(currentSettings, "includeChampionPoints", true)
                CM.DebugPrint("REGISTRY", string.format("ChampionPoints condition (runtime): %s (settings.includeChampionPoints = %s)", 
                    tostring(enabled), tostring(currentSettings.includeChampionPoints)))
                return enabled
            end,
            generator = function()
                -- Use current settings from CM.GetSettings() to ensure we have latest values
                local currentSettings = CM.GetSettings() or settings
                local cpEnabled = IsSettingEnabled(currentSettings, "includeChampionPoints", true)
                CM.DebugPrint("CHAMPION_POINTS", string.format("Section condition: %s, CP data exists: %s", tostring(cpEnabled), tostring(data.cp ~= nil)))
                if data.cp then
                    CM.DebugPrint("CHAMPION_POINTS", string.format("CP data - total: %s, spent: %s, disciplines: %s", 
                        tostring(data.cp.total), tostring(data.cp.spent), tostring(data.cp.disciplines and #data.cp.disciplines or 0)))
                end
                
                local markdown = ""
                
                -- Show all Champion Points
                local cpResult = gen.GenerateChampionPoints(data.cp, format)
                CM.DebugPrint("CHAMPION_POINTS", string.format("GenerateChampionPoints returned length: %d", #cpResult))
                markdown = markdown .. cpResult
                
                -- Add Mermaid diagram if enabled (GitHub/VSCode only - Mermaid doesn't render in Discord)
                local diagramEnabled = IsSettingEnabled(currentSettings, "includeChampionDiagram", false)
                CM.DebugPrint("CHAMPION_DIAGRAM", string.format("Diagram enabled: %s, format: %s", tostring(diagramEnabled), tostring(format)))
                if diagramEnabled and format ~= "discord" then
                    local diagramResult = gen.GenerateChampionDiagram(data.cp)
                    CM.DebugPrint("CHAMPION_DIAGRAM", string.format("Diagram generated, length: %d", #diagramResult))
                    markdown = markdown .. diagramResult
                end
                
                return markdown
            end
        },
        
        -- 4. 👥 Active Companion
        {
            name = "Companion",
            tocEntry = {
                title = "👥 Active Companion"
            },
            condition = IsSettingEnabled(settings, "includeCompanion", true) and data.companion.active,
            generator = function()
                return gen.GenerateCompanion(data.companion, format)
            end
        },
        
        -- 5. ⚔️ PvP Profile
        {
            name = "PvPStats",
            tocEntry = {
                title = "⚔️ PvP Profile"
            },
            condition = IsSettingEnabled(settings, "includePvPStats", false),
            generator = function()
                return gen.GeneratePvPStats(data.pvp, data.pvpStats, format)
            end
        },
        
        -- 6. 🏰 Guild Membership (includes Undaunted Active Pledges as subsection)
        {
            name = "Guilds",
            tocEntry = {
                title = "🏰 Guild Membership"
            },
            condition = IsSettingEnabled(settings, "includeGuilds", true),
            generator = function()
                local undauntedPledgesData = nil
                if IsSettingEnabled(settings, "includeUndauntedPledges", true) then
                    undauntedPledgesData = data.undauntedPledges
                end
                return gen.GenerateGuilds(data.guilds, format, undauntedPledgesData)
            end
        },
        
        -- 7. 🎨 Collectibles (includes Accessible Content, Titles & Housing as collapsible subsections)
        {
            name = "Collectibles",
            tocEntry = {
                title = "🎨 Collectibles"
            },
            condition = IsSettingEnabled(settings, "includeCollectibles", true),
            generator = function()
                local lorebooksData = (data.worldProgress and data.worldProgress.lorebooks) or nil
                return gen.GenerateCollectibles(data.collectibles, format, data.dlc, lorebooksData, data.titlesHousing, data.riding)
            end
        },
        
        -- ========================================
        -- ADDITIONAL SECTIONS (not in TOC)
        -- ========================================
        
        -- Attention Needed (non-Discord only, not in TOC)
        {
            name = "AttentionNeeded",
            tocEntry = nil,  -- Not shown in TOC
            condition = format ~= "discord" and IsSettingEnabled(settings, "includeAttentionNeeded", true),
            generator = function()
                return gen.GenerateAttentionNeeded(data.progression, data.inventory, data.riding, data.companion, data.currency, format)
            end
        },
        
        -- Currency (standalone section, optional in TOC if enabled)
        {
            name = "Currency",
            tocEntry = nil,  -- Not shown in TOC (already in Overview)
            condition = IsSettingEnabled(settings, "includeCurrency", true),
            generator = function()
                return gen.GenerateCurrency(data.currency, format)
            end
        },
        
        -- Riding Skills
        {
            name = "RidingSkills",
            tocEntry = {
                title = "🐎 Riding Skills"
            },
            condition = IsSettingEnabled(settings, "includeRidingSkills", true),
            generator = function()
                return gen.GenerateRidingSkills(data.riding, format)
            end
        },
        
        -- Inventory
        {
            name = "Inventory",
            tocEntry = {
                title = "🎒 Inventory"
            },
            condition = IsSettingEnabled(settings, "includeInventory", true),
            generator = function()
                return gen.GenerateInventory(data.inventory, format)
            end
        },
        
        -- Crafting
        {
            name = "Crafting",
            tocEntry = {
                title = "⚒️ Crafting"
            },
            condition = IsSettingEnabled(settings, "includeCrafting", true),
            generator = function()
                return gen.GenerateCrafting(data.crafting, format)
            end
        },
        
        -- Achievements (standalone section, not in TOC)
        {
            name = "Achievements",
            tocEntry = nil,  -- Not shown in TOC
            condition = IsSettingEnabled(settings, "includeAchievements", false),
            generator = function()
                local markdown = ""
                
                if not data.achievements then
                    return markdown
                end
                
                -- Check if we should show all achievements or filter to in-progress only
                local showAllAchievements = settings.showAllAchievements ~= false  -- Default to true (show all)
                
                if showAllAchievements then
                    -- Show all achievements (full data)
                    markdown = markdown .. gen.GenerateAchievements(data.achievements, format)
                    
                    -- Show detailed categories if enabled
                    if IsSettingEnabled(settings, "includeAchievementsDetailed", false) then
                        -- Additional detailed content is handled in the main generator
                        -- This is intentionally empty as detailed content is processed elsewhere
                        -- No action needed here
                    end
                else
                    -- Filter to show only in-progress achievements
                    local inProgressData = {
                        summary = data.achievements.summary,
                        inProgress = data.achievements.inProgress or {}
                    }
                    markdown = markdown .. gen.GenerateAchievements(inProgressData, format)
                end
                
                return markdown
            end
        },
        
        -- Antiquities (standalone section, not in TOC)
        {
            name = "Antiquities",
            tocEntry = nil,  -- Not shown in TOC
            condition = IsSettingEnabled(settings, "includeAntiquities", false),
            generator = function()
                local markdown = ""
                
                if not data.antiquities then
                    return markdown
                end
                
                -- Generate antiquities section
                markdown = markdown .. gen.GenerateAntiquities(data.antiquities, format)
                
                return markdown
            end
        },
        
        -- Quests (standalone section, not in TOC)
        {
            name = "Quests",
            tocEntry = nil,  -- Not shown in TOC
            condition = IsSettingEnabled(settings, "includeQuests", false),  -- Default to false (disabled by default)
            generator = function()
                local markdown = ""
                
                -- Check if quest data exists and has meaningful content
                if not data.quests or not data.quests.summary then
                    CM.DebugPrint("QUESTS", "GenerateQuests generator: no quest data or summary")
                    return markdown
                end
                
                CM.DebugPrint("QUESTS", string.format("GenerateQuests generator: data.quests exists, calling gen.GenerateQuests"))
                
                -- Check if we should show all quests or filter to active only
                local showAllQuests = settings.showAllQuests ~= false  -- Default to true (show all)
                
                if showAllQuests then
                    -- Show all quests (full data)
                    markdown = markdown .. gen.GenerateQuests(data.quests, format)
                    
                    -- Show detailed categories if enabled
                    if IsSettingEnabled(settings, "includeQuestsDetailed", false) then
                        -- Additional detailed content is handled in the main generator
                        -- This is intentionally empty as detailed content is processed elsewhere
                        -- No action needed here
                    end
                else
                    -- Filter to show only active quests
                    local activeData = {
                        summary = data.quests.summary,
                        active = data.quests.active or {}
                    }
                    markdown = markdown .. gen.GenerateQuests(activeData, format)
                end
                
                CM.DebugPrint("QUESTS", string.format("GenerateQuests generator: returned %d chars", #markdown))
                return markdown
            end
        },
        
        -- Equipment Enhancement (optional advanced section, not in default TOC)
        {
            name = "Equipment Enhancement",
            tocEntry = nil,  -- Not shown in TOC
            condition = IsSettingEnabled(settings, "includeEquipmentEnhancement", false),
            generator = function()
                local markdown = ""
                
                -- Show basic equipment enhancement summary
                if data.equipmentEnhancement then
                    markdown = markdown .. gen.GenerateEquipmentEnhancement(data.equipmentEnhancement, format)
                end
                
                -- Show detailed analysis if enabled
                if IsSettingEnabled(settings, "includeEquipmentAnalysis", false) and data.equipmentEnhancement then
                    -- Additional detailed content is handled in the main generator
                    -- This is intentionally empty as detailed content is processed elsewhere
                    -- No action needed here
                end
                
                -- Show only recommendations if enabled
                if IsSettingEnabled(settings, "includeEquipmentRecommendations", false) and data.equipmentEnhancement then
                    -- Generate recommendations only (without summary header)
                    -- Recommendations are already included in the main section above
                    -- This setting is deprecated - recommendations are shown in the main analysis
                    -- Keeping for backward compatibility but not generating duplicate content
                end
                
                return markdown
            end
        },
        
        -- World Progress
        {
            name = "World Progress",
            tocEntry = {
                title = "🌍 World Progress"
            },
            condition = IsSettingEnabled(settings, "includeWorldProgress", true),
            generator = function()
                return gen.GenerateWorldProgress(data.worldProgress, format)
            end
        },
        
        -- Buffs (standalone section, not in TOC - shown in Overview table)
        {
            name = "Buffs",
            tocEntry = nil,  -- Not shown in TOC
            condition = IsSettingEnabled(settings, "includeBuffs", true),
            generator = function()
                return gen.GenerateBuffs(data.buffs, format)
            end
        },
        
        -- Custom Notes (requires both setting enabled AND content present, not in TOC)
        {
            name = "CustomNotes",
            tocEntry = nil,  -- Not shown in TOC
            condition = IsSettingEnabled(settings, "includeBuildNotes", true) 
                       and data.customNotes and data.customNotes ~= "",
            generator = function()
                return gen.GenerateCustomNotes(data.customNotes, format)
            end
        },
        
        -- Mundus (Discord only, not in TOC)
        {
            name = "Mundus",
            tocEntry = nil,  -- Not shown in TOC
            condition = format == "discord",
            generator = function()
                return gen.GenerateMundus(data.mundus, format)
            end
        },
        
        -- Progression (standalone section, not in TOC)
        {
            name = "Progression",
            tocEntry = nil,  -- Not shown in TOC
            condition = IsSettingEnabled(settings, "includeProgression", true),
            generator = function()
                return gen.GenerateProgression(data.progression, data.cp, format)
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
        skillMorphs = SafeCollect("CollectSkillMorphsData", CM.collectors.CollectSkillMorphsData),
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
        achievements = SafeCollect("CollectAchievementData", CM.collectors.CollectAchievementData),
        antiquities = SafeCollect("CollectAntiquityData", CM.collectors.CollectAntiquityData),
        quests = SafeCollect("CollectQuestData", CM.collectors.CollectQuestData),
        equipmentEnhancement = SafeCollect("CollectEquipmentEnhancementData", CM.collectors.CollectEquipmentEnhancementData),
        worldProgress = SafeCollect("CollectWorldProgressData", CM.collectors.CollectWorldProgressData),
        titlesHousing = SafeCollect("CollectTitlesHousingData", CM.collectors.CollectTitlesHousingData),
        pvpStats = SafeCollect("CollectPvPStatsData", CM.collectors.CollectPvPStatsData),
        armoryBuilds = SafeCollect("CollectArmoryBuildsData", CM.collectors.CollectArmoryBuildsData),
        undauntedPledges = SafeCollect("CollectUndauntedPledgesData", CM.collectors.CollectUndauntedPledgesData),
        guilds = SafeCollect("CollectGuildData", CM.collectors.CollectGuildData),
        customNotes = (CM.charData and CM.charData.customNotes) or (CharacterMarkdownData and CharacterMarkdownData.customNotes) or ""
    }
    
    -- Report any collection errors
    ReportCollectionErrors()
    
    CM.DebugPrint("GENERATOR", string.format("Data collection completed with %d error(s)", #collectionErrors))
    
    -- Get settings - use CM.GetSettings() which guarantees no nil values
    -- Settings are always stored in flat format in SavedVariables
    -- CM.GetSettings() merges with defaults to ensure every setting is true or false, never nil
    local settings = CM.GetSettings() or {}
    
    -- CRITICAL: Also check raw CharacterMarkdownSettings to ensure we're reading the latest values
    -- This helps catch any issues with settings not being persisted or read correctly
    if CharacterMarkdownSettings then
        -- Log raw values for debugging
        CM.DebugPrint("GENERATOR", string.format("Raw CharacterMarkdownSettings - includeChampionPoints: %s, includeChampionDiagram: %s", 
            tostring(CharacterMarkdownSettings.includeChampionPoints), 
            tostring(CharacterMarkdownSettings.includeChampionDiagram)))
        
        -- Ensure critical settings are synced from raw to merged (defensive check)
        -- Force sync to ensure we use the actual saved values
        if CharacterMarkdownSettings.includeChampionPoints ~= nil then
            settings.includeChampionPoints = CharacterMarkdownSettings.includeChampionPoints
            CM.Info(string.format("Synced includeChampionPoints: %s", tostring(settings.includeChampionPoints)))
        end
        if CharacterMarkdownSettings.includeChampionDiagram ~= nil then
            settings.includeChampionDiagram = CharacterMarkdownSettings.includeChampionDiagram
            CM.Info(string.format("Synced includeChampionDiagram: %s", tostring(settings.includeChampionDiagram)))
        end
    end
    
    -- Debug: Log relevant settings for troubleshooting
    CM.DebugPrint("GENERATOR", string.format("Settings source: %s", CM.settings and "CM.settings" or "CM.GetSettings()"))
    CM.DebugPrint("GENERATOR", string.format("Final settings check - includeChampionPoints: %s (type: %s), includeChampionDiagram: %s (type: %s), includeSkillBars: %s (type: %s), includeSkills: %s (type: %s), includeEquipment: %s (type: %s), includeQuickStats: %s (type: %s), includeTableOfContents: %s (type: %s)", 
        tostring(settings.includeChampionPoints), type(settings.includeChampionPoints),
        tostring(settings.includeChampionDiagram), type(settings.includeChampionDiagram),
        tostring(settings.includeSkillBars), type(settings.includeSkillBars),
        tostring(settings.includeSkills), type(settings.includeSkills), 
        tostring(settings.includeEquipment), type(settings.includeEquipment), 
        tostring(settings.includeQuickStats), type(settings.includeQuickStats), 
        tostring(settings.includeTableOfContents), type(settings.includeTableOfContents)))
    
    -- Debug: Check if settings table has the expected keys
    local sampleKeys = {"includeChampionPoints", "includeSkillBars", "includeSkills", "includeEquipment"}
    for _, key in ipairs(sampleKeys) do
        local hasKey = settings[key] ~= nil
        CM.DebugPrint("GENERATOR", string.format("Setting '%s' exists: %s, value: %s", key, tostring(hasKey), tostring(settings[key])))
    end
    
    -- Debug: Check CP data
    if collectedData.cp then
        CM.DebugPrint("GENERATOR", string.format("CP data collected - total: %s, spent: %s, available: %s", 
            tostring(collectedData.cp.total), tostring(collectedData.cp.spent), tostring(collectedData.cp.available)))
    else
        CM.DebugPrint("GENERATOR", "WARNING: CP data is nil!")
    end
    
    -- Get section generators
    local gen = GetGenerators()
    
    -- QUICK FORMAT - one-line summary
    if format == "quick" then
        return gen.GenerateQuickSummary(collectedData.character, collectedData.equipment)
    end
    
    -- FULL FORMATS (GitHub, VSCode, Discord)
    CM.DebugPrint("GENERATOR", string.format("Generating markdown in %s format...", format))
    
    local markdown = ""
    
    -- Verify settings are accessible before building registry
    CM.DebugPrint("GENERATOR", string.format("Final settings check before registry - includeChampionPoints: %s (type: %s), includeChampionDiagram: %s (type: %s)", 
        tostring(settings.includeChampionPoints), type(settings.includeChampionPoints),
        tostring(settings.includeChampionDiagram), type(settings.includeChampionDiagram)))
    
    -- Get section registry (pass flattened settings)
    local sections = GetSectionRegistry(format, settings, gen, collectedData)
    
    -- Generate all sections based on registry
    CM.Info("=== Section Generation ===")
    for _, section in ipairs(sections) do
        local conditionMet = false
        if type(section.condition) == "function" then
            conditionMet = section.condition()
        else
            conditionMet = section.condition
        end
        
        -- Log every section's condition status
        CM.DebugPrint("GENERATOR", string.format("Section '%s' - condition: %s", section.name, tostring(conditionMet)))
        
        if conditionMet then
            CM.Info(string.format("→ Generating: %s", section.name))
            
            -- Special handling for dynamic TOC
            if section.dynamicTOC then
                CM.Info("→ Dynamic TOC generation triggered")
                CM.DebugPrint("GENERATOR", string.format("Generating dynamic TOC from registry (sections count: %d, format: %s)", #sections, format))
                
                -- Verify function exists
                if not gen.GenerateDynamicTableOfContents then
                    CM.Error("GenerateDynamicTableOfContents function not found!")
                else
                    CM.DebugPrint("GENERATOR", "GenerateDynamicTableOfContents function exists, calling it...")
                end
                
                local success, result = pcall(gen.GenerateDynamicTableOfContents, sections, format)
                if success then
                    local resultLength = result and #result or 0
                    CM.Info(string.format("  ✓ %s: %d chars (dynamic)", section.name, resultLength))
                    if resultLength == 0 then
                        CM.Warn("Dynamic TOC returned empty string!")
                    end
                    markdown = markdown .. result
                else
                    CM.Error(string.format("Dynamic TOC generation failed: %s", tostring(result)))
                end
            -- Normal section generation
            elseif not section.generator or type(section.generator) ~= "function" then
                CM.Warn(string.format("Section '%s' has no valid generator function", section.name))
                CM.DebugPrint("GENERATOR", string.format("⏭️  Section '%s' skipped (no generator)", section.name))
            else
                local success, result = pcall(section.generator)
                if success then
                    -- Log result for ALL sections
                    local resultLength = result and #result or 0
                    local isEmpty = result == "" or not result
                    CM.Info(string.format("  ✓ %s: %d chars", section.name, resultLength))
                    
                    if isEmpty then
                        CM.Warn(string.format("  ⚠ %s returned EMPTY despite condition=true!", section.name))
                    end
                    
                    -- CRITICAL: Ensure critical sections (SkillBars, Equipment) always have content
                    if (section.name == "SkillBars" or section.name == "Equipment") then
                        if not result or result == "" or (result:gsub("%s+", "") == "") then
                            CM.Error(string.format("CRITICAL: Section '%s' returned empty content, this should never happen!", section.name))
                            -- Force placeholder content for critical sections
                            if section.name == "SkillBars" then
                                result = "## ⚔️ Combat Arsenal\n\n*No skill bars configured*\n\n---\n\n"
                            elseif section.name == "Equipment" then
                                result = "## ⚔️ Equipment & Active Sets\n\n*No equipment data available*\n\n---\n\n"
                            end
                        end
                    end
                    markdown = markdown .. result
                    CM.DebugPrint("GENERATOR", string.format("✅ Section '%s' appended to markdown", section.name))
                else
                    CM.Error(string.format("  ✗ %s FAILED: %s", section.name, tostring(result)))
                    CM.DebugPrint("GENERATOR", string.format("❌ Section '%s' failed: %s", section.name, tostring(result)))
                    -- For critical sections, add placeholder on error
                    if section.name == "SkillBars" or section.name == "Equipment" then
                        CM.Error(string.format("CRITICAL: Section '%s' failed, adding placeholder", section.name))
                        if section.name == "SkillBars" then
                            markdown = markdown .. "## ⚔️ Combat Arsenal\n\n*Error generating skill bars*\n\n---\n\n"
                        elseif section.name == "Equipment" then
                            markdown = markdown .. "## ⚔️ Equipment & Active Sets\n\n*Error generating equipment data*\n\n---\n\n"
                        end
                    end
                end
            end
        else
            CM.DebugPrint("GENERATOR", string.format("⏭️  Section '%s' skipped (condition=false)", section.name))
        end
    end
    CM.Info(string.format("=== Total markdown: %d chars ===", #markdown))
    
    -- Footer (controlled by includeFooter setting)
    if IsSettingEnabled(settings, "includeFooter", true) then
        local footerSuccess, footerResult = pcall(gen.GenerateFooter, format, string.len(markdown))
        if footerSuccess then
            markdown = markdown .. footerResult
            CM.DebugPrint("GENERATOR", "✅ Footer generated")
        else
            CM.Warn(string.format("Failed to generate footer: %s", tostring(footerResult)))
        end
    else
        CM.DebugPrint("GENERATOR", "⏭️ Footer skipped (disabled in settings)")
    end
    
    CM.DebugPrint("GENERATOR", string.format("Markdown generation complete: %d bytes", string.len(markdown)))
    
    -- Store the complete markdown in a variable
    local completeMarkdown = markdown
    local markdownLength = string.len(completeMarkdown)
    
    -- Get EditBox limit from constants
    local CHUNKING = CM.constants and CM.constants.CHUNKING
    local EDITBOX_LIMIT = (CHUNKING and CHUNKING.EDITBOX_LIMIT) or 10000
    
    -- Once complete, chunk if necessary
    if markdownLength > EDITBOX_LIMIT then
        CM.DebugPrint("GENERATOR", string.format("Markdown exceeds EditBox limit (%d > %d), chunking...", markdownLength, EDITBOX_LIMIT))
        
        -- Use the consolidated chunking utility (handles tables, lists, padding, etc.)
        local Chunking = CM.utils and CM.utils.Chunking
        local SplitMarkdownIntoChunks = Chunking and Chunking.SplitMarkdownIntoChunks
        
        if SplitMarkdownIntoChunks then
            local chunks = SplitMarkdownIntoChunks(completeMarkdown)
            CM.DebugPrint("GENERATOR", string.format("Split into %d chunks using Chunking utility", #chunks))
            return chunks
        else
            CM.Error("Chunking utility not available - markdown may be truncated!")
            return completeMarkdown
        end
    end
    
    -- Markdown fits in one chunk - return as string
    return completeMarkdown
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.generators.GenerateMarkdown = GenerateMarkdown
