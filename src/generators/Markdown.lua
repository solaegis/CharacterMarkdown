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
        GenerateSkillMorphs = CM.generators.sections.GenerateSkillMorphs,
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
        GenerateDetailedChampionPoints = CM.generators.sections.GenerateDetailedChampionPoints,
        GenerateSlottableChampionPoints = CM.generators.sections.GenerateSlottableChampionPoints,
        -- DISABLED: Champion Diagram (experimental)
        -- GenerateChampionDiagram = CM.generators.GenerateChampionDiagram,
        GenerateCollectibles = CM.generators.sections.GenerateCollectibles,
        GenerateCrafting = CM.generators.sections.GenerateCrafting,
        GenerateAchievements = CM.generators.sections.GenerateAchievements,
        GenerateQuests = CM.generators.sections.GenerateQuests,
        GenerateEquipmentEnhancement = CM.generators.sections.GenerateEquipmentEnhancement,
        
        -- World sections
        GenerateWorldProgress = CM.generators.sections.GenerateWorldProgress,
        
        -- Tier 3-5 sections
        GenerateTitlesHousing = CM.generators.sections.GenerateTitlesHousing,
        GeneratePvPStats = CM.generators.sections.GeneratePvPStats,
        GenerateArmoryBuilds = CM.generators.sections.GenerateArmoryBuilds,
        GenerateTalesOfTribute = CM.generators.sections.GenerateTalesOfTribute,
        GenerateUndauntedPledges = CM.generators.sections.GenerateUndauntedPledges,
        
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
                return gen.GenerateAttentionNeeded(data.progression, data.inventory, data.riding, data.companion, format)
            end
        },
        
        -- Overview (non-Discord only)
        {
            name = "Overview",
            condition = format ~= "discord",
            generator = function()
                return gen.GenerateOverview(data.character, data.role, data.location, data.buffs, 
                    data.mundus, data.riding, data.pvp, data.progression, settings, format, data.cp)
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
        
        -- Riding Skills
        {
            name = "RidingSkills",
            condition = IsSettingEnabled(settings, "includeRidingSkills", true),
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
        
        -- PvP
        {
            name = "PvP",
            condition = IsSettingEnabled(settings, "includePvP", true),
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
            condition = IsSettingEnabled(settings, "includeCrafting", true),
            generator = function()
                return gen.GenerateCrafting(data.crafting, format)
            end
        },
        
        -- Achievements
        {
            name = "Achievements",
            condition = IsSettingEnabled(settings, "includeAchievements", false),
            generator = function()
                local markdown = ""
                
                -- Show basic achievement summary
                if data.achievements then
                    markdown = markdown .. gen.GenerateAchievements(data.achievements, format)
                end
                
                -- Show detailed categories if enabled
                if IsSettingEnabled(settings, "includeAchievementsDetailed", false) and data.achievements then
                    -- Additional detailed content is handled in the main generator
                    -- This is intentionally empty as detailed content is processed elsewhere
                    -- No action needed here
                end
                
                -- Show only in-progress if enabled
                if IsSettingEnabled(settings, "includeAchievementsInProgress", false) and data.achievements then
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
        
        -- Quests
        {
            name = "Quests",
            condition = IsSettingEnabled(settings, "includeQuests", false),
            generator = function()
                local markdown = ""
                
                -- Show basic quest summary
                if data.quests then
                    markdown = markdown .. gen.GenerateQuests(data.quests, format)
                end
                
                -- Show detailed categories if enabled
                if IsSettingEnabled(settings, "includeQuestsDetailed", false) and data.quests then
                    -- Additional detailed content is handled in the main generator
                    -- This is intentionally empty as detailed content is processed elsewhere
                    -- No action needed here
                end
                
                -- Show only active quests if enabled
                if IsSettingEnabled(settings, "includeQuestsActiveOnly", false) and data.quests then
                    -- Filter to show only active quests
                    local activeData = {
                        summary = data.quests.summary,
                        active = data.quests.active or {}
                    }
                    markdown = markdown .. gen.GenerateQuests(activeData, format)
                end
                
                return markdown
            end
        },
        
        -- Equipment Enhancement
        {
            name = "Equipment Enhancement",
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
                    -- Filter to show only recommendations
                    local recommendationsData = {
                        summary = data.equipmentEnhancement.summary,
                        recommendations = data.equipmentEnhancement.recommendations or {}
                    }
                    markdown = markdown .. gen.GenerateEquipmentEnhancement(recommendationsData, format)
                end
                
                return markdown
            end
        },
        
        -- World Progress
        {
            name = "World Progress",
            condition = IsSettingEnabled(settings, "includeWorldProgress", true),
            generator = function()
                return gen.GenerateWorldProgress(data.worldProgress, format)
            end
        },
        
        -- Titles & Housing
        {
            name = "Titles & Housing",
            condition = IsSettingEnabled(settings, "includeTitlesHousing", true),
            generator = function()
                return gen.GenerateTitlesHousing(data.titlesHousing, format)
            end
        },
        
        -- PvP Stats
        {
            name = "PvP Stats",
            condition = IsSettingEnabled(settings, "includePvPStats", true),
            generator = function()
                return gen.GeneratePvPStats(data.pvpStats, format)
            end
        },
        
        -- Armory Builds
        {
            name = "Armory Builds",
            condition = IsSettingEnabled(settings, "includeArmoryBuilds", true),
            generator = function()
                return gen.GenerateArmoryBuilds(data.armoryBuilds, format)
            end
        },
        
        -- Tales of Tribute
        {
            name = "Tales of Tribute",
            condition = IsSettingEnabled(settings, "includeTalesOfTribute", true),
            generator = function()
                return gen.GenerateTalesOfTribute(data.talesOfTribute, format)
            end
        },
        
        -- Undaunted Pledges
        {
            name = "Undaunted Pledges",
            condition = IsSettingEnabled(settings, "includeUndauntedPledges", true),
            generator = function()
                return gen.GenerateUndauntedPledges(data.undauntedPledges, format)
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
                local markdown = ""
                
                -- Check if we should show slottable only
                if IsSettingEnabled(settings, "includeChampionSlottableOnly", false) then
                    markdown = markdown .. gen.GenerateSlottableChampionPoints(data.cp, format)
                else
                    markdown = markdown .. gen.GenerateChampionPoints(data.cp, format)
                end
                
                -- Add detailed analysis if enabled
                if IsSettingEnabled(settings, "includeChampionDetailed", false) then
                    markdown = markdown .. gen.GenerateDetailedChampionPoints(data.cp, format)
                end
                
                return markdown
            end
        },
        
        -- Progression
        {
            name = "Progression",
            condition = IsSettingEnabled(settings, "includeProgression", true),
            generator = function()
                return gen.GenerateProgression(data.progression, format)
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
        
        -- Skill Morphs
        {
            name = "SkillMorphs",
            condition = IsSettingEnabled(settings, "includeSkillMorphs", true),
            generator = function()
                return gen.GenerateSkillMorphs(data.skillMorphs, format)
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
        quests = SafeCollect("CollectQuestData", CM.collectors.CollectQuestData),
        equipmentEnhancement = SafeCollect("CollectEquipmentEnhancementData", CM.collectors.CollectEquipmentEnhancementData),
        worldProgress = SafeCollect("CollectWorldProgressData", CM.collectors.CollectWorldProgressData),
        titlesHousing = SafeCollect("CollectTitlesHousingData", CM.collectors.CollectTitlesHousingData),
        pvpStats = SafeCollect("CollectPvPStatsData", CM.collectors.CollectPvPStatsData),
        armoryBuilds = SafeCollect("CollectArmoryBuildsData", CM.collectors.CollectArmoryBuildsData),
        talesOfTribute = SafeCollect("CollectTalesOfTributeData", CM.collectors.CollectTalesOfTributeData),
        undauntedPledges = SafeCollect("CollectUndauntedPledgesData", CM.collectors.CollectUndauntedPledgesData),
        customNotes = (CM.charData and CM.charData.customNotes) or (CharacterMarkdownData and CharacterMarkdownData.customNotes) or ""
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
        local conditionMet = false
        if type(section.condition) == "function" then
            conditionMet = section.condition()
        else
            conditionMet = section.condition
        end
        
        if conditionMet then
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
