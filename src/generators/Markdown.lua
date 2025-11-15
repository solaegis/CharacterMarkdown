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
        GenerateGeneral = CM.generators.sections.GenerateGeneral,
        GenerateCharacterStats = CM.generators.sections.GenerateCharacterStats,
        -- GenerateProgression - not implemented (progression data used in other sections)
        GenerateCustomNotes = CM.generators.sections.GenerateCustomNotes,
        -- GenerateTableOfContents = CM.generators.sections.GenerateTableOfContents, -- DEPRECATED: Use dynamic TOC
        GenerateDynamicTableOfContents = CM.generators.sections.GenerateDynamicTableOfContents,

        -- Economy sections
        GenerateCurrency = CM.generators.sections.GenerateCurrency,
        GenerateRidingSkills = CM.generators.sections.GenerateRidingSkills,
        GenerateInventory = CM.generators.sections.GenerateInventory,
        GeneratePvP = CM.generators.sections.GeneratePvP,

        -- Equipment sections
        GenerateSkillBars = CM.generators.sections.GenerateSkillBars,
        GenerateSkillBarsOnly = CM.generators.sections.GenerateSkillBarsOnly,
        GenerateSkillMorphs = CM.generators.sections.GenerateSkillMorphs,
        GenerateEquipment = CM.generators.sections.GenerateEquipment,
        GenerateSkills = CM.generators.sections.GenerateSkills,
        GenerateProgressSummary = CM.generators.sections.GenerateProgressSummary,

        -- Combat sections
        GenerateCombatStats = CM.generators.sections.GenerateCombatStats,
        -- GenerateAttributes removed (no longer relevant)
        GenerateBuffs = CM.generators.sections.GenerateBuffs,

        -- Content sections
        GenerateDLCAccess = CM.generators.sections.GenerateDLCAccess,
        GenerateMundus = CM.generators.sections.GenerateMundus,
        GenerateChampionPoints = CM.generators.sections.GenerateChampionPoints,
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
        CM.Warn(string.format("⚠️ %s not available", collectorName))
        return {} -- Return empty data if function doesn't exist
    end

    local success, result = pcall(collectorFunc)

    if not success then
        table.insert(collectionErrors, {
            collector = collectorName,
            error = tostring(result),
        })
        CM.Error(string.format("❌ %s failed: %s", collectorName, tostring(result)))
        return {} -- Return empty data on failure
    end

    return result
end

local function ReportCollectionErrors()
    if #collectionErrors == 0 then
        return
    end

    -- Log errors to chat (always shown, not just debug mode)
    CM.Warn(string.format("Encountered %d error(s) during data collection:", #collectionErrors))
    for i, err in ipairs(collectionErrors) do
        CM.Warn(string.format("  %d. %s: %s", i, err.collector, err.error))
    end
    CM.Warn("Generated markdown may be incomplete. Try /reloadui if issues persist.")
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
        CM.Warn(
            string.format(
                "IsSettingEnabled: settings table is nil for '%s', using default: %s",
                settingName,
                tostring(defaultValue)
            )
        )
        return defaultValue
    end
    local value = settings[settingName]
    -- Settings should never be nil (CM.GetSettings() ensures this), but handle it defensively
    if value == nil then
        CM.Warn(
            string.format(
                "IsSettingEnabled: '%s' is nil (should never happen!), using default: %s",
                settingName,
                tostring(defaultValue)
            )
        )
        return defaultValue
    end
    -- Explicitly check for true - false means disabled
    return value == true
end

-- =====================================================
-- SECTION REGISTRY PATTERN
-- =====================================================

-- Generate GitHub markdown anchor from section title text
-- GitHub anchors: lowercase, spaces to hyphens, remove emojis and special chars
-- NOTE: This must match the logic in GenerateDynamicTableOfContents
local function GenerateAnchor(text)
    if not text then
        return ""
    end

    -- Keep only ASCII letters, numbers, spaces, and basic punctuation
    -- This removes emojis and other Unicode characters
    local anchor = ""
    for i = 1, #text do
        local byte = text:byte(i)
        if
            (byte >= 48 and byte <= 57) -- 0-9
            or (byte >= 65 and byte <= 90) -- A-Z
            or (byte >= 97 and byte <= 122) -- a-z
            or byte == 32
            or byte == 45
        then -- space or hyphen
            anchor = anchor .. text:sub(i, i)
        end
    end

    -- Convert to lowercase and replace spaces with hyphens
    anchor = anchor:lower():gsub("%s+", "-")

    -- Remove leading/trailing hyphens and collapse multiple hyphens
    anchor = anchor:gsub("^%-+", ""):gsub("%-+$", ""):gsub("%-%-+", "-")

    return anchor
end

-- Helper function to create a section definition
-- This simplifies section creation and ensures consistent structure
local function CreateSection(name, tocEntry, condition, generator, options)
    options = options or {}
    return {
        name = name,
        tocEntry = tocEntry,
        condition = condition,
        generator = generator,
        dynamicTOC = options.dynamicTOC or false,
    }
end

-- Section configuration: defines all sections with their conditions
-- NOTE: settings parameter must be the FLATTENED settings table
--
-- STRUCTURE:
--   Each section has:
--     - name: Unique identifier
--     - tocEntry: Table of Contents entry (nil if not in TOC)
--     - condition: Boolean or function returning boolean
--     - generator: Function that returns markdown string
--     - dynamicTOC: Optional flag for special TOC handling
--
-- TODO: Consider extracting section definitions to separate module
--       and moving condition logic to individual section modules
local function GetSectionRegistry(format, settings, gen, data)
    -- Debug: Log settings at registry creation time (lazy evaluation)
    CM.DebugPrint("REGISTRY", function()
        return string.format(
            "Building section registry - includeChampionPoints: %s, includeChampionDiagram: %s",
            tostring(settings.includeChampionPoints),
            tostring(settings.includeChampionDiagram)
        )
    end)
    return {
        -- Header (controlled by includeHeader setting, not in TOC)
        {
            name = "Header",
            tocEntry = nil, -- Not in TOC
            condition = IsSettingEnabled(settings, "includeHeader", true),
            generator = function()
                return gen.GenerateHeader(data.character, data.cp, format)
            end,
        },

        -- Table of Contents (non-Discord/Quick only, not in TOC itself)
        {
            name = "TableOfContents",
            tocEntry = nil, -- Not in TOC
            condition = function()
                return format ~= "discord"
                    and format ~= "quick"
                    and IsSettingEnabled(settings, "includeTableOfContents", true)
            end,
            generator = function()
                -- TOC will be generated dynamically from this registry
                -- Note: registry reference will be injected after registry is built
                return "" -- Will be replaced during generation
            end,
            dynamicTOC = true, -- Flag to indicate this needs special handling
        },

        -- ========================================
        -- SECTIONS IN TOC ORDER (as shown in Table of Contents)
        -- ========================================

        -- 1. 📋 Overview (Quick Stats Summary)
        {
            name = "QuickStats",
            tocEntry = {
                title = "📋 Overview",
                subsections = { "General", "Currency", "Character Stats" },
            },
            condition = function()
                -- Show Overview if format is not discord AND any subsection is enabled
                if format == "discord" then
                    return false
                end
                -- Check if any subsection is enabled
                return IsSettingEnabled(settings, "includeGeneral", true)
                    or IsSettingEnabled(settings, "includeCurrency", true)
                    or IsSettingEnabled(settings, "includeCharacterStats", true)
            end,
            generator = function()
                return gen.GenerateQuickStats(
                    data.character,
                    data.stats,
                    format,
                    data.equipment,
                    data.progression,
                    data.currency,
                    data.cp,
                    data.inventory,
                    data.location,
                    data.buffs,
                    data.pvp,
                    data.titlesHousing,
                    data.mundus,
                    data.riding,
                    settings
                )
            end,
        },

        -- 1a. Custom Notes (appears immediately after Overview, requires both setting enabled AND content present)
        {
            name = "CustomNotes",
            tocEntry = {
                title = "📝 Build Notes",
            },
            condition = IsSettingEnabled(settings, "includeBuildNotes", true)
                and data.customNotes
                and data.customNotes ~= "",
            generator = function()
                return gen.GenerateCustomNotes(data.customNotes, format)
            end,
        },

        -- 2. ⚔️ Combat Arsenal (Skill Bars Only - Front/Back Bar)
        {
            name = "SkillBars",
            tocEntry = {
                title = "⚔️ Combat Arsenal",
                subsections = { "Equipment & Active Sets", "Champion Points", "Character Progress", "Companions" },
            },
            condition = IsSettingEnabled(settings, "includeSkillBars", true),
            generator = function()
                -- Generate ONLY the skill bars (front/back bar tables)
                local skillBarData = data.skillBar or {}
                local success, result = pcall(gen.GenerateSkillBarsOnly, skillBarData, format)
                if success then
                    return result or ""
                else
                    CM.Warn("GenerateSkillBarsOnly failed: " .. tostring(result))
                    if format == "discord" then
                        return "\n**Skill Bars:**\n*Error generating skill bars*\n\n"
                    else
                        return "## ⚔️ Combat Arsenal\n\n*Error generating skill bars*\n\n"
                    end
                end
            end,
        },

        -- 2a. Equipment & Active Sets (separate section)
        {
            name = "Equipment",
            tocEntry = nil, -- Shown in Combat Arsenal TOC via parent
            condition = IsSettingEnabled(settings, "includeEquipment", true),
            generator = function()
                local equipmentData = data.equipment or {}
                local success, result = pcall(gen.GenerateEquipment, equipmentData, format, false)
                if success then
                    return result or ""
                else
                    CM.Warn("GenerateEquipment failed: " .. tostring(result))
                    return ""
                end
            end,
        },

        -- 2b. Character Progress (Summary + Skill Morphs + Status-Organized Progression)
        {
            name = "CharacterProgress",
            tocEntry = nil, -- Shown in Combat Arsenal TOC via parent
            condition = IsSettingEnabled(settings, "includeSkills", true),
            generator = function()
                -- Generate Character Progress section with summary, morphs, and status-organized skills
                local skillMorphsData = data.skillMorphs or {}
                local skillProgressionData = data.skill or {}

                local output = ""
                if format == "discord" then
                    output = "\n**Character Progress:**\n"
                else
                    output = "## 📜 Character Progress\n\n"
                end

                -- Add Progress Summary Dashboard (non-Discord only)
                if format ~= "discord" and gen.GenerateProgressSummary then
                    local success, summaryContent =
                        pcall(gen.GenerateProgressSummary, skillProgressionData, skillMorphsData, format)
                    if success and summaryContent then
                        output = output .. summaryContent
                    end
                end

                -- Add Skill Morphs (collapsible section, respects includeSkillMorphs setting)
                if IsSettingEnabled(settings, "includeSkillMorphs", false) and skillMorphsData and #skillMorphsData > 0 and format ~= "discord" then
                    local success, morphsContent = pcall(gen.GenerateSkillMorphs, skillMorphsData, format)
                    if success and morphsContent then
                        -- Strip header and separator from morphs
                        morphsContent = morphsContent:gsub("^##%s+🌿%s+Skill%s+Morphs%s*\n%s*\n", "")
                        morphsContent = morphsContent:gsub("%-%-%-%s*\n%s*$", "")

                        -- Count total abilities for summary
                        local totalAbilities = 0
                        for _, skillType in ipairs(skillMorphsData) do
                            for _, skillLine in ipairs(skillType.skillLines or {}) do
                                totalAbilities = totalAbilities + #(skillLine.abilities or {})
                            end
                        end

                        -- Wrap in collapsible section
                        output = output .. "<details>\n"
                        output = output
                            .. string.format(
                                "<summary>🌿 Skill Morphs (%d abilities with morph choices)</summary>\n\n",
                                totalAbilities
                            )
                        output = output .. morphsContent
                        output = output .. "</details>\n\n"
                    end
                elseif IsSettingEnabled(settings, "includeSkillMorphs", false) and skillMorphsData and #skillMorphsData > 0 and format == "discord" then
                    -- Discord: keep existing format
                    local success, morphsContent = pcall(gen.GenerateSkillMorphs, skillMorphsData, format)
                    if success and morphsContent then
                        output = output .. morphsContent
                    end
                end

                -- Add Skill Progression (now status-organized, with optional morph integration)
                if skillProgressionData and #skillProgressionData > 0 then
                    local success, skillsContent =
                        pcall(gen.GenerateSkills, skillProgressionData, format, skillMorphsData)
                    if success and skillsContent then
                        -- Skills no longer outputs header, so just append content
                        output = output .. skillsContent
                    end
                end

                -- Use CreateSeparator for consistent separator styling
                local CreateSeparator = CM.utils.markdown and CM.utils.markdown.CreateSeparator
                if CreateSeparator then
                    output = output .. CreateSeparator("hr")
                else
                    output = output .. "---\n\n"
                end
                return output
            end,
        },

        -- 2c. ⭐ Champion Points (part of Combat Arsenal)
        {
            name = "ChampionPoints",
            tocEntry = nil, -- Shown in Combat Arsenal TOC via parent
            condition = function()
                -- Re-evaluate condition at generation time to ensure we have latest settings
                local currentSettings = CM.GetSettings() or settings
                return IsSettingEnabled(currentSettings, "includeChampionPoints", true)
            end,
            generator = function()
                -- Use current settings from CM.GetSettings() to ensure we have latest values
                local currentSettings = CM.GetSettings() or settings
                local markdown = ""

                -- Show all Champion Points
                local cpResult = gen.GenerateChampionPoints(data.cp, format)
                markdown = markdown .. cpResult

                -- Add Mermaid diagram if enabled (GitHub/VSCode only - Mermaid doesn't render in Discord)
                local diagramEnabled = IsSettingEnabled(currentSettings, "includeChampionDiagram", false)
                if diagramEnabled and format ~= "discord" then
                    local diagramResult = gen.GenerateChampionDiagram(data.cp)
                    markdown = markdown .. diagramResult
                end

                return markdown
            end,
        },

        -- 2d. 👥 Companions (part of Combat Arsenal)
        {
            name = "Companion",
            tocEntry = nil, -- Shown in Combat Arsenal TOC via parent
            condition = IsSettingEnabled(settings, "includeCompanion", true),
            generator = function()
                return gen.GenerateCompanion(data.companion, format)
            end,
        },

        -- 3. ⚔️ PvP Profile (includes Alliance War skills conditionally)
        {
            name = "PvPStats",
            tocEntry = {
                title = "⚔️ PvP",
                subsections = IsSettingEnabled(settings, "showAllianceWarSkills", false) and { "Alliance War Skills" }
                    or nil,
            },
            condition = IsSettingEnabled(settings, "includePvPStats", false)
                or IsSettingEnabled(settings, "showAllianceWarSkills", false),
            generator = function()
                -- Pass skill progression data so PvP section can include Alliance War skills
                local skillProgressionData = data.skill or {}
                return gen.GeneratePvPStats(data.pvp, data.pvpStats, format, skillProgressionData, settings)
            end,
        },

        -- 6. 🏰 Guild Membership (includes Undaunted Active Pledges as subsection)
        {
            name = "Guilds",
            tocEntry = {
                title = "🏰 Guild Membership",
            },
            condition = IsSettingEnabled(settings, "includeGuilds", true),
            generator = function()
                local undauntedPledgesData = nil
                if IsSettingEnabled(settings, "includeUndauntedPledges", true) then
                    undauntedPledgesData = data.undauntedPledges
                end
                return gen.GenerateGuilds(data.guilds, format, undauntedPledgesData)
            end,
        },

        -- 7. 🎨 Collectibles (includes Accessible Content, Titles & Housing as collapsible subsections)
        {
            name = "Collectibles",
            tocEntry = {
                title = "🎨 Collectibles",
            },
            condition = IsSettingEnabled(settings, "includeCollectibles", true),
            generator = function()
                local lorebooksData = (data.worldProgress and data.worldProgress.lorebooks) or nil
                return gen.GenerateCollectibles(
                    data.collectibles,
                    format,
                    data.dlc,
                    lorebooksData,
                    data.titlesHousing,
                    data.riding
                )
            end,
        },

        -- ========================================
        -- ADDITIONAL SECTIONS (not in TOC)
        -- ========================================

        -- Inventory
        {
            name = "Inventory",
            tocEntry = {
                title = "🎒 Inventory",
            },
            condition = IsSettingEnabled(settings, "includeInventory", true),
            generator = function()
                return gen.GenerateInventory(data.inventory, format)
            end,
        },

        -- Crafting (DISABLED - ESO API too complex/unreliable)
        --[[
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
        --]]

        -- Achievements (standalone section)
        {
            name = "Achievements",
            tocEntry = {
                title = "🏆 Achievements",
            },
            condition = IsSettingEnabled(settings, "includeAchievements", false),
            generator = function()
                local markdown = ""

                if not data.achievements then
                    return markdown
                end

                -- Check if we should show all achievements or filter to in-progress only
                local showAllAchievements = settings.showAllAchievements ~= false -- Default to true (show all)

                if showAllAchievements then
                    -- Show all achievements (full data with categories)
                    markdown = markdown .. gen.GenerateAchievements(data.achievements, format)
                else
                    -- Filter to show only in-progress achievements
                    local inProgressData = {
                        summary = data.achievements.summary,
                        inProgress = data.achievements.inProgress or {},
                        categories = data.achievements.categories, -- Include categories for consistency
                    }
                    markdown = markdown .. gen.GenerateAchievements(inProgressData, format)
                end

                return markdown
            end,
        },

        -- Antiquities (standalone section)
        {
            name = "Antiquities",
            tocEntry = {
                title = "🏺 Antiquities",
            },
            condition = IsSettingEnabled(settings, "includeAntiquities", false),
            generator = function()
                local markdown = ""

                if not data.antiquities then
                    return markdown
                end

                -- Generate antiquities section
                markdown = markdown .. gen.GenerateAntiquities(data.antiquities, format)

                return markdown
            end,
        },

        -- Quests (standalone section)
        {
            name = "Quests",
            tocEntry = {
                title = "📜 Quests",
            },
            condition = IsSettingEnabled(settings, "includeQuests", false), -- Default to false (disabled by default)
            generator = function()
                local markdown = ""

                -- Check if quest data exists and has meaningful content
                if not data.quests or not data.quests.summary then
                    return markdown
                end

                -- Check if we should show all quests or filter to active only
                local showAllQuests = settings.showAllQuests ~= false -- Default to true (show all)

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
                        active = data.quests.active or {},
                    }
                    markdown = markdown .. gen.GenerateQuests(activeData, format)
                end

                return markdown
            end,
        },

        -- Equipment Enhancement (optional advanced section, not in default TOC)
        {
            name = "Equipment Enhancement",
            tocEntry = nil, -- Not shown in TOC
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
                if
                    IsSettingEnabled(settings, "includeEquipmentRecommendations", false) and data.equipmentEnhancement
                then
                    -- Generate recommendations only (without summary header)
                    -- Recommendations are already included in the main section above
                end

                return markdown
            end,
        },

        -- World Progress
        -- World Progress (DISABLED - ESO achievement API too complex/unreliable for skyshard tracking)
        --[[
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
        --]]

        -- Buffs (standalone section, not in TOC - shown in Overview table)
        {
            name = "Buffs",
            tocEntry = nil, -- Not shown in TOC
            condition = IsSettingEnabled(settings, "includeBuffs", true),
            generator = function()
                return gen.GenerateBuffs(data.buffs, format)
            end,
        },

        -- Mundus (Discord only, not in TOC)
        {
            name = "Mundus",
            tocEntry = nil, -- Not shown in TOC
            condition = format == "discord",
            generator = function()
                return gen.GenerateMundus(data.mundus, format)
            end,
        },

        -- Note: Progression data is used in other sections (QuickStats, General, etc.)
        -- There is no standalone Progression section generator
    }
end

-- =====================================================
-- MAIN GENERATION FUNCTION
-- =====================================================

local function GenerateMarkdown(format)
    format = format or "github"

    -- Removed verbose logging

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
            CM.Error("  - " .. k)
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
        progression = SafeCollect("CollectProgressionData", CM.collectors.CollectProgressionData),  -- Re-enabled: needed for skill points in QuickStats
        riding = SafeCollect("CollectRidingSkillsData", CM.collectors.CollectRidingSkillsData),
        inventory = SafeCollect("CollectInventoryData", CM.collectors.CollectInventoryData),
        pvp = SafeCollect("CollectPvPData", CM.collectors.CollectPvPData),
        role = SafeCollect("CollectRoleData", CM.collectors.CollectRoleData),
        location = SafeCollect("CollectLocationData", CM.collectors.CollectLocationData),
        collectibles = SafeCollect("CollectCollectiblesData", CM.collectors.CollectCollectiblesData),
        -- crafting = SafeCollect("CollectCraftingKnowledgeData", CM.collectors.CollectCraftingKnowledgeData),  -- DISABLED
        achievements = SafeCollect("CollectAchievementData", CM.collectors.CollectAchievementData),
        antiquities = SafeCollect("CollectAntiquityData", CM.collectors.CollectAntiquityData),
        quests = SafeCollect("CollectQuestData", CM.collectors.CollectQuestData),
        -- equipmentEnhancement = SafeCollect("CollectEquipmentEnhancementData", CM.collectors.CollectEquipmentEnhancementData),  -- DISABLED: generator returns empty
        -- worldProgress = SafeCollect("CollectWorldProgressData", CM.collectors.CollectWorldProgressData),  -- DISABLED
        titlesHousing = SafeCollect("CollectTitlesHousingData", CM.collectors.CollectTitlesHousingData),
        pvpStats = SafeCollect("CollectPvPStatsData", CM.collectors.CollectPvPStatsData),
        armoryBuilds = SafeCollect("CollectArmoryBuildsData", CM.collectors.CollectArmoryBuildsData),
        undauntedPledges = SafeCollect("CollectUndauntedPledgesData", CM.collectors.CollectUndauntedPledgesData),
        guilds = SafeCollect("CollectGuildData", CM.collectors.CollectGuildData),
        customNotes = (CM.charData and CM.charData.customNotes)
            or (CharacterMarkdownData and CharacterMarkdownData.customNotes)
            or "",
    }

    -- Report any collection errors
    ReportCollectionErrors()

    -- Get settings - use CM.GetSettings() which guarantees no nil values
    -- Settings are always stored in flat format in SavedVariables
    -- CM.GetSettings() merges with defaults to ensure every setting is true or false, never nil
    local settings = CM.GetSettings() or {}

    -- Get section generators
    local gen = GetGenerators()

    -- QUICK FORMAT - one-line summary
    if format == "quick" then
        local result = gen.GenerateQuickSummary(collectedData.character, collectedData.equipment)
        -- Clear collected data immediately for quick format
        collectedData = nil
        return result
    end

    -- FULL FORMATS (GitHub, VSCode, Discord)
    CM.DebugPrint("GENERATOR", function()
        return string.format("Generating markdown in %s format...", format)
    end)

    local markdown = ""

    -- Get section registry (pass flattened settings)
    local sections = GetSectionRegistry(format, settings, gen, collectedData)

    -- Generate all sections based on registry
    -- Generate sections
    for _, section in ipairs(sections) do
        local conditionMet = false
        if type(section.condition) == "function" then
            conditionMet = section.condition()
        else
            conditionMet = section.condition
        end

        if conditionMet then
            CM.DebugPrint("GENERATOR", string.format("Generating: %s", section.name))

            -- Special handling for dynamic TOC
            if section.dynamicTOC then
                CM.DebugPrint("GENERATOR", "Dynamic TOC generation triggered")

                -- Verify function exists
                if not gen.GenerateDynamicTableOfContents then
                    CM.Error("GenerateDynamicTableOfContents function not found!")
                end

                local success, result = pcall(gen.GenerateDynamicTableOfContents, sections, format)
                if success then
                    local resultLength = result and #result or 0
                    CM.DebugPrint("GENERATOR", string.format("  ✓ %s: %d chars (dynamic)", section.name, resultLength))
                    if resultLength == 0 then
                        CM.DebugPrint("GENERATOR", "Dynamic TOC returned empty string!")
                    end
                    markdown = markdown .. result
                else
                    CM.Error(string.format("Dynamic TOC generation failed: %s", tostring(result)))
                end
            -- Normal section generation
            elseif not section.generator or type(section.generator) ~= "function" then
                CM.Warn(string.format("Section '%s' has no valid generator function", section.name))
            else
                local success, result = pcall(section.generator)
                if success then
                    -- Log result for ALL sections
                    local resultLength = result and #result or 0
                    local isEmpty = result == "" or not result
                    CM.DebugPrint("GENERATOR", string.format("%s: %d chars", section.name, resultLength))

                    if isEmpty then
                        CM.DebugPrint(
                            "GENERATOR",
                            string.format("%s returned EMPTY despite condition=true", section.name)
                        )
                    end

                    -- CRITICAL: Ensure critical sections (SkillBars, Equipment) always have content
                    if section.name == "SkillBars" or section.name == "Equipment" then
                        if not result or result == "" or (result:gsub("%s+", "") == "") then
                            CM.Error(
                                string.format(
                                    "CRITICAL: Section '%s' returned empty content, this should never happen!",
                                    section.name
                                )
                            )
                            -- Force placeholder content for critical sections
                            if section.name == "SkillBars" then
                                result = "## ⚔️ Combat Arsenal\n\n*No skill bars configured*\n\n---\n\n"
                            elseif section.name == "Equipment" then
                                result = "## ⚔️ Equipment & Active Sets\n\n*No equipment data available*\n\n---\n\n"
                            end
                        end
                    end

                    -- AUTO-ADD ANCHOR: If section has a tocEntry, prepend anchor before content
                    -- IMPORTANT: Only add anchor if result has actual content (not empty or whitespace-only)
                    if result and result ~= "" and result:gsub("%s+", "") ~= "" then
                        if section.tocEntry and section.tocEntry.title then
                            local anchor = GenerateAnchor(section.tocEntry.title)
                            if anchor and anchor ~= "" then
                                -- Only add anchor if content doesn't already have one
                                if not result:match("^%s*<a id=") then
                                    result = string.format('<a id="%s"></a>\n\n%s', anchor, result)
                                    CM.DebugPrint(
                                        "MARKDOWN",
                                        string.format("Auto-added anchor: #%s for section %s", anchor, section.name)
                                    )
                                end
                            end
                        end

                        markdown = markdown .. result
                    end
                else
                    CM.Error(string.format("  ✗ %s FAILED: %s", section.name, tostring(result)))
                    -- For critical sections, add placeholder on error
                    if section.name == "SkillBars" or section.name == "Equipment" then
                        CM.Error(string.format("CRITICAL: Section '%s' failed, adding placeholder", section.name))
                        if section.name == "SkillBars" then
                            markdown = markdown
                                .. "## ⚔️ Combat Arsenal\n\n*Error generating skill bars*\n\n---\n\n"
                        elseif section.name == "Equipment" then
                            markdown = markdown
                                .. "## ⚔️ Equipment & Active Sets\n\n*Error generating equipment data*\n\n---\n\n"
                        end
                    end
                end
            end
        end
    end
    -- Markdown generated

    -- CRITICAL CHECK: If markdown is empty at this point, log it
    if markdown == "" or #markdown == 0 then
        CM.Error("⚠️ CRITICAL: Markdown is EMPTY after section generation!")
        CM.Error("This means all sections returned empty content or were skipped.")
        CM.Error("Please check if settings are enabled and data collectors returned data.")
    end

    -- Footer (controlled by includeFooter setting)
    if IsSettingEnabled(settings, "includeFooter", true) then
        local footerSuccess, footerResult = pcall(gen.GenerateFooter, format, string.len(markdown))
        if footerSuccess then
            markdown = markdown .. footerResult
            CM.DebugPrint("GENERATOR", string.format("Footer added (%d chars)", #footerResult))
        else
            CM.Warn(string.format("Failed to generate footer: %s", tostring(footerResult)))
        end
    end

    -- Final markdown complete

    CM.DebugPrint("GENERATOR", function()
        return string.format("Markdown generation complete: %d bytes", string.len(markdown))
    end)

    -- Store the complete markdown in a variable
    local completeMarkdown = markdown
    local markdownLength = string.len(completeMarkdown)

    -- Save format to per-character SavedVariables (NOT the markdown itself - too large for 2k SavedVar limit)
    if CM.charData then
        CM.charData.markdown_format = format
        CM.charData._lastModified = GetTimeStamp()
        CM.DebugPrint("GENERATOR", string.format("Saved format to per-character data: %s", format))
        
        -- ESO automatically saves CharacterMarkdownSettings to disk when modified
        -- No explicit save call needed - changes are persisted on next save cycle
    else
        CM.Warn("Character data not initialized - format not saved to SavedVariables")
    end

    -- Get EditBox limit from constants
    local CHUNKING = CM.constants and CM.constants.CHUNKING
    local DEFAULTS = CM.constants and CM.constants.DEFAULTS
    local EDITBOX_LIMIT = (CHUNKING and CHUNKING.EDITBOX_LIMIT)
        or (DEFAULTS and DEFAULTS.EDITBOX_LIMIT_FALLBACK)
        or 10000

    -- Once complete, chunk if necessary
    if markdownLength > EDITBOX_LIMIT then
        CM.DebugPrint("GENERATOR", function()
            return string.format("Markdown exceeds EditBox limit (%d > %d), chunking...", markdownLength, EDITBOX_LIMIT)
        end)

        -- Use the consolidated chunking utility (handles tables, lists, padding, etc.)
        local Chunking = CM.utils and CM.utils.Chunking
        local SplitMarkdownIntoChunks = Chunking and Chunking.SplitMarkdownIntoChunks

        if SplitMarkdownIntoChunks then
            local chunks = SplitMarkdownIntoChunks(completeMarkdown)
            CM.DebugPrint("GENERATOR", function()
                return string.format("Split into %d chunks using Chunking utility", #chunks)
            end)
            
            -- Clear references to help GC before returning
            collectedData = nil
            settings = nil
            gen = nil
            sections = nil
            completeMarkdown = nil
            
            -- Hint to Lua GC that now is a good time to collect
            -- (Large markdown generation can create significant temporary string garbage)
            collectgarbage("step", 1000)
            
            return chunks
        else
            CM.Error("Chunking utility not available - markdown may be truncated!")
            
            -- Clear references even on error path
            collectedData = nil
            settings = nil
            gen = nil
            sections = nil
            
            return completeMarkdown
        end
    end

    -- Markdown fits in one chunk - return as string
    -- Clear references to help GC
    collectedData = nil
    settings = nil
    gen = nil
    sections = nil
    
    -- Hint to Lua GC that now is a good time to collect
    -- (Large markdown generation can create significant temporary string garbage)
    collectgarbage("step", 1000)
    
    return completeMarkdown
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.generators.GenerateMarkdown = GenerateMarkdown
