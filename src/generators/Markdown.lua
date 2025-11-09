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
        CM.DebugPrint("COLLECTOR", string.format("⚠️ %s not available (function is nil)", collectorName))
        return {}  -- Return empty data if function doesn't exist
    end
    
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
        
        -- Table of Contents (non-Discord/Quick only) - First section after header
        {
            name = "TableOfContents",
            condition = format ~= "discord" and format ~= "quick" and IsSettingEnabled(settings, "includeTableOfContents", true),
            generator = function()
                return gen.GenerateTableOfContents(format)
            end
        },
        
        -- Quick Stats Summary (non-Discord only) - Now includes Character Overview merged in
        {
            name = "QuickStats",
            condition = format ~= "discord" and IsSettingEnabled(settings, "includeQuickStats", true),
            generator = function()
                return gen.GenerateQuickStats(data.character, data.stats, format, data.equipment, data.progression, data.currency, data.cp, data.inventory, data.location, data.buffs, data.pvp, data.titlesHousing, data.mundus)
            end
        },
        
        -- Skill Bars (Combat Arsenal) - Always enabled, moved after Overview
        {
            name = "SkillBars",
            condition = true,  -- Always enabled
            generator = function()
                -- Defensive: Ensure data exists and is valid
                local skillBarData = data.skillBar or {}
                local skillMorphsData = data.skillMorphs or {}
                local skillProgressionData = data.skill or {}
                -- Wrap in pcall for extra safety
                local success, result = pcall(gen.GenerateSkillBars, skillBarData, format, skillMorphsData, skillProgressionData)
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
        
        -- Attention Needed (non-Discord only)
        {
            name = "AttentionNeeded",
            condition = format ~= "discord" and IsSettingEnabled(settings, "includeAttentionNeeded", true),
            generator = function()
                return gen.GenerateAttentionNeeded(data.progression, data.inventory, data.riding, data.companion, data.currency, format)
            end
        },
        
        -- Overview section disabled - merged into QuickStats above
        -- {
        --     name = "Overview",
        --     condition = false, -- Disabled: merged into QuickStats
        --     generator = function()
        --         return ""
        --     end
        -- },
        
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
        
        -- FIX #7: Merged PvP section (removed duplicate)
        -- PvP section disabled - removed per user request
        -- {
        --     name = "PvP",
        --     condition = false,  -- Disabled
        --     generator = function()
        --         return ""
        --     end
        -- },
        
        -- Collectibles (includes Titles & Housing as collapsible subsections)
        {
            name = "Collectibles",
            condition = IsSettingEnabled(settings, "includeCollectibles", true),
            generator = function()
                local lorebooksData = (data.worldProgress and data.worldProgress.lorebooks) or nil
                return gen.GenerateCollectibles(data.collectibles, format, data.dlc, lorebooksData, data.titlesHousing, data.riding)
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
        
        -- Quests
        {
            name = "Quests",
            condition = IsSettingEnabled(settings, "includeQuests", false),
            generator = function()
                local markdown = ""
                
                if not data.quests then
                    return markdown
                end
                
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
            condition = IsSettingEnabled(settings, "includeWorldProgress", true),
            generator = function()
                return gen.GenerateWorldProgress(data.worldProgress, format)
            end
        },
        
        -- Titles & Housing - Disabled: Now included in Collectibles section as collapsible subsections
        -- {
        --     name = "Titles & Housing",
        --     condition = false,  -- Disabled: moved to Collectibles
        --     generator = function()
        --         return ""
        --     end
        -- },
        
        -- FIX #7: REMOVED DUPLICATE - Merged into single PvP section above
        
        -- Armory Builds - disabled per user request
        {
            name = "Armory Builds",
            condition = false,  -- Disabled
            generator = function()
                return ""
            end
        },
        
        -- Tales of Tribute - disabled per user request
        -- {
        --     name = "Tales of Tribute",
        --     condition = false, -- Disabled
        --     generator = function()
        --         return ""
        --     end
        -- },
        
        -- Guilds (includes Undaunted Active Pledges as subsection)
        {
            name = "Guilds",
            condition = IsSettingEnabled(settings, "includeGuilds", true),
            generator = function()
                local undauntedPledgesData = nil
                if IsSettingEnabled(settings, "includeUndauntedPledges", true) then
                    undauntedPledgesData = data.undauntedPledges
                end
                return gen.GenerateGuilds(data.guilds, format, undauntedPledgesData)
            end
        },
        
        -- Attributes - disabled (duplicative, info already shown in Quick Stats)
        {
            name = "Attributes",
            condition = false,  -- Disabled: duplicative
            generator = function()
                return ""
            end
        },
        
        -- Buffs
        {
            name = "Buffs",
            condition = IsSettingEnabled(settings, "includeBuffs", true),
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
        
        -- DLC Access - Disabled: Now included in Collectibles section as first collapsible
        -- {
        --     name = "DLCAccess",
        --     condition = false,  -- Disabled: moved to Collectibles
        --     generator = function()
        --         return ""
        --     end
        -- },
        
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
                
                -- Show all Champion Points
                markdown = markdown .. gen.GenerateChampionPoints(data.cp, format)
                
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
                return gen.GenerateProgression(data.progression, data.cp, format)
            end
        },
        
        -- Skill Morphs - disabled: now shown as subsection within Equipment section
        {
            name = "SkillMorphs",
            condition = false,  -- Disabled: shown in Equipment section instead
            generator = function()
                return ""
            end
        },
        
        -- Combat Stats - Disabled: Now included in overview section as Stats subsection
        {
            name = "CombatStats",
            condition = false,  -- Disabled: moved to overview section
            generator = function()
                return ""
            end
        },
        
        -- Equipment
        {
            name = "Equipment",
            condition = IsSettingEnabled(settings, "includeEquipment", true),
            generator = function()
                -- Defensive: Ensure data exists and is valid
                local equipmentData = data.equipment or {}
                -- Wrap in pcall for extra safety
                local success, result = pcall(gen.GenerateEquipment, equipmentData, format)
                if success then
                    return result or ""
                else
                    CM.Warn("GenerateEquipment failed in generator wrapper: " .. tostring(result))
                    if format == "discord" then
                        return "**Equipment & Active Sets:**\n*Error generating equipment data*\n\n"
                    else
                        return "## ⚔️ Equipment & Active Sets\n\n*Error generating equipment data*\n\n---\n\n"
                    end
                end
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
        guilds = SafeCollect("CollectGuildData", CM.collectors.CollectGuildData),
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
            -- Defensive: Check if generator function exists
            if not section.generator or type(section.generator) ~= "function" then
                CM.Warn(string.format("Section '%s' has no valid generator function", section.name))
                CM.DebugPrint("GENERATOR", string.format("⏭️  Section '%s' skipped (no generator)", section.name))
            else
                local success, result = pcall(section.generator)
                if success then
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
                    CM.DebugPrint("GENERATOR", string.format("✅ Section '%s' generated", section.name))
                else
                    CM.Warn(string.format("Failed to generate section '%s': %s", section.name, tostring(result)))
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
