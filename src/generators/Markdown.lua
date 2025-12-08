-- CharacterMarkdown - Markdown Generation Engine
-- Generates markdown in standard format (GitHub-compatible)

local CM = CharacterMarkdown

-- Import section generators (these modules register themselves to CM.generators.sections)

-- Get references to imported section generators for convenience
local function GetGenerators()
    return {
        -- Character sections
        GenerateHeader = CM.generators.sections.GenerateHeader,
        GenerateGeneral = CM.generators.sections.GenerateGeneral,
        GenerateQuickStats = CM.generators.sections.GenerateQuickStats,
        GenerateOverviewSection = CM.generators.sections.GenerateOverviewSection,
        GenerateCharacterStats = CM.generators.sections.GenerateCharacterStats,
        GenerateCustomNotes = CM.generators.sections.GenerateCustomNotes,
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
        GenerateCharacterProgress = CM.generators.sections.GenerateCharacterProgress,

        -- Combat sections
        GenerateCombatStats = CM.generators.sections.GenerateCombatStats,
        GenerateAdvancedStats = CM.generators.sections.GenerateAdvancedStats,
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
        -- GenerateEquipmentEnhancement = CM.generators.sections.GenerateEquipmentEnhancement,  -- DISABLED: moved to DISABLED/

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
        -- Silently return empty data if collector not available
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

    -- Errors are logged to saved variables but not spammed to chat
    -- Users can check the error log if needed
    CM.DebugPrint("ERRORS", string.format("Encountered %d error(s) during data collection", #collectionErrors))
    for i, err in ipairs(collectionErrors) do
        CM.DebugPrint("ERRORS", string.format("  %d. %s: %s", i, err.collector, err.error))
    end
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
        CM.DebugPrint("SETTINGS",
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
        CM.DebugPrint("SETTINGS",
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

-- Generate standard markdown anchor from section title text
-- GitHub anchors: lowercase, spaces to hyphens, remove emojis and special chars
-- Must match the logic in GenerateDynamicTableOfContents
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
-- Settings parameter must be the flattened settings table
--
-- STRUCTURE:
--   Each section has:
--     - name: Unique identifier
--     - tocEntry: Table of Contents entry (nil if not in TOC)
--     - condition: Boolean or function returning boolean
--     - generator: Function that returns markdown string
--     - dynamicTOC: Optional flag for special TOC handling
local function GetSectionRegistry(settings, gen, data)
    -- Debug: Log settings at registry creation time (lazy evaluation)
    CM.DebugPrint("REGISTRY", function()
        return string.format(
            "Building section registry - includeChampionPoints: %s, includeChampionDiagram: %s",
            tostring(settings.includeChampionPoints),
            tostring(settings.includeChampionDiagram)
        )
    end)
    
    local registry = {
        -- Header (controlled by includeHeader setting, not in TOC)
        {
            name = "Header",
            tocEntry = nil, -- Not in TOC
            condition = IsSettingEnabled(settings, "includeHeader", true),
            generator = function()
                return gen.GenerateHeader(data.character, data.cp)
            end,
        },

        -- Table of Contents (non-Discord/Quick only, not in TOC itself)
        {
            name = "TableOfContents",
            tocEntry = nil, -- Not in TOC
            condition = function()
                return IsSettingEnabled(settings, "includeTableOfContents", true)
            end,
            generator = function()
                -- TOC will be generated dynamically from this registry
                -- Note: registry reference will be injected after registry is built
                return "" -- Will be replaced during generation
            end,
            dynamicTOC = true, -- Flag to indicate this needs special handling
        },

        -- ========================================
        -- SECTIONS ORGANIZED TO MATCH SETTINGS PANEL ORDER
        -- ========================================
        -- Sections are ordered to match the settings panel organization
        -- This ensures the TOC reflects the same structure as the settings UI

        -- ========================================
        -- OVERVIEW & CUSTOM NOTES (Special sections)
        -- ========================================

        -- 1. 📋 Overview (Quick Stats Summary) - Uses multiple collectors
        {
            name = "QuickStats",
            tocEntry = {
                title = "📋 Overview",
                subsections = { "General", "Currency" },
            },
            condition = function()
                -- Check if any subsection is enabled
                return IsSettingEnabled(settings, "includeGeneral", true)
                    or IsSettingEnabled(settings, "includeCurrency", true)
                    or IsSettingEnabled(settings, "includeCharacterStats", true)
            end,
            generator = function()
                -- Pass attributes data through settings for GenerateGeneral
                local settingsWithData = {}
                for k, v in pairs(settings) do
                    settingsWithData[k] = v
                end
                settingsWithData._collectedData = {
                    characterAttributes = data.characterAttributes
                }
                -- Call GenerateQuickStats which includes the section header
                return gen.GenerateQuickStats(
                    data.character,
                    data.stats,
                    nil, -- format
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
                    settingsWithData
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
                return gen.GenerateCustomNotes(data.customNotes, nil, data.equipment, data.skillBar)
            end,
        },

        -- ========================================
        -- COMBAT ARSENAL (Composite section grouping multiple collectors)
        -- ========================================


        -- 2. ⚔️ Combat Arsenal (Character Stats + Optional Skill Bars)
        -- Uses: Combat.lua - CollectCombatStatsData, Skills.lua - CollectSkillBarData
        {
            name = "CombatArsenal",
            tocEntry = {
                title = "⚔️ Combat Arsenal",
                subsections = { "Character Stats", "Advanced Stats" },
            },
            condition = function()
                local basicEnabled = IsSettingEnabled(settings, "includeBasicCombatStats", true)
                local advancedEnabled = IsSettingEnabled(settings, "includeAdvancedStats", true)
                local barsEnabled = IsSettingEnabled(settings, "includeSkillBars", true)
                
                return basicEnabled or advancedEnabled or barsEnabled
            end,
            generator = function()
                -- Ensure stats data exists
                if not data.stats then
                    if CM.collectors and CM.collectors.CollectCombatStatsData then
                        data.stats = CM.collectors.CollectCombatStatsData()
                    end
                end

                -- Start with section header
                local output = "## ⚔️ Combat Arsenal\n\n"
                
                -- Generate Basic Combat Stats
                if IsSettingEnabled(settings, "includeBasicCombatStats", true) then
                    CM.DebugPrint("STATS_GEN", "Generating Basic Combat Stats...")
                    if data.stats then
                        local success, result = pcall(gen.GenerateCombatStats, data.stats, true) -- inline=true
                        if success then
                            local statsOutput = result or ""
                            if statsOutput ~= "" then
                                CM.DebugPrint("STATS_GEN", string.format("✓ Generated %d characters of basic stats", #statsOutput))
                                output = output .. statsOutput
                            end
                        end
                    end
                end

                -- Generate Advanced Stats
                if IsSettingEnabled(settings, "includeAdvancedStats", true) then
                    CM.DebugPrint("STATS_GEN", "Generating Advanced Stats...")
                    if data.stats then
                        local success, result = pcall(gen.GenerateAdvancedStats, data.stats)
                        if success then
                            local advStatsOutput = result or ""
                            if advStatsOutput ~= "" then
                                CM.DebugPrint("STATS_GEN", string.format("✓ Generated %d characters of advanced stats", #advStatsOutput))
                                output = output .. advStatsOutput
                            end
                        end
                    end
                end

                -- Generate Skill Bars (optional)
                if IsSettingEnabled(settings, "includeSkillBars", true) then
                    local skillBarData = data.skillBar or {}
                    local success, result = pcall(gen.GenerateSkillBarsOnly, skillBarData)
                    
                    if success then
                        output = output .. (result or "")
                    end
                end

                -- If we generated nothing, return empty to skip section
                return output
            end,
        },

        -- ========================================
        -- EQUIPMENT (Equipment.lua collector)
        -- ========================================
        -- Uses: Equipment.lua - CollectEquipmentData
        -- Setting: includeEquipment

        -- 2a. Equipment & Active Sets (separate section)
        {
            name = "Equipment",
            tocEntry = nil, -- Shown in Combat Arsenal TOC via parent
            condition = IsSettingEnabled(settings, "includeEquipment", true),
            generator = function()
                local equipmentData = data.equipment or {}
                local success, result = pcall(gen.GenerateEquipment, equipmentData, false)
                if success then
                    return result or ""
                else
                    -- Silently fail - error already logged
                    return ""
                end
            end,
        },

        -- ========================================
        -- CHAMPION POINTS (Champion.lua collector)
        -- ========================================
        -- Uses: Champion.lua - CollectChampionPointData
        -- Settings: includeChampionPoints, includeChampionDiagram

        -- 2b. ⭐ Champion Points (part of Combat Arsenal)
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
                local cpResult = gen.GenerateChampionPoints(data.cp)

                -- Add Mermaid diagram if enabled
                local diagramEnabled = IsSettingEnabled(currentSettings, "includeChampionDiagram", false)
                if diagramEnabled then
                    -- Strip the trailing separator from cpResult so the diagram connects visually
                    -- Check for standard separator styles
                    if cpResult:match("%-%-%-\n\n$") then
                        cpResult = cpResult:gsub("%-%-%-\n\n$", "")
                    elseif cpResult:match("<hr%s*/>\n\n$") then
                        cpResult = cpResult:gsub("<hr%s*/>\n\n$", "")
                    end
                    
                    markdown = markdown .. cpResult
                    local diagramResult = gen.GenerateChampionDiagram(data.cp)
                    markdown = markdown .. diagramResult
                else
                    markdown = markdown .. cpResult
                end

                return markdown
            end,
        },

        -- ========================================
        -- SKILLS (Skills.lua collectors)
        -- ========================================
        -- Uses: Skills.lua - CollectSkillBarData, CollectSkillProgressionData, CollectSkillMorphsData
        -- Settings: includeSkillBars, includeSkills, includeSkillMorphs

        -- 2c. Character Progress (Summary + Skill Morphs + Status-Organized Progression)
        {
            name = "CharacterProgress",
            tocEntry = nil, -- Shown in Combat Arsenal TOC via parent
            condition = IsSettingEnabled(settings, "includeSkills", true),
            generator = function()
                local skillProgressionData = data.skill or {}
                local skillMorphsData = data.skillMorphs or {}
                
                -- Use the new consolidated generator
                return gen.GenerateCharacterProgress(skillProgressionData, skillMorphsData)
            end,
        },


        -- ========================================
        -- PVP (PvP.lua collector) - Settings Panel Order: 8
        -- ========================================
        -- Uses: PvP.lua - CollectPvPData
        -- Settings: includePvP, includePvPStats, showPvPProgression, showCampaignRewards, showLeaderboards, showBattlegrounds, detailedPvP, showAllianceWarSkills

        -- ⚔️ PvP Profile (includes Alliance War skills conditionally)
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
                -- Use unified pvp structure: data.pvp.basic and data.pvp.stats
                local pvpBasic = data.pvp and data.pvp.basic or nil
                local pvpStats = data.pvp and data.pvp.stats or nil
                return gen.GeneratePvPStats(pvpBasic, pvpStats, skillProgressionData, settings)
            end,
        },

        -- ========================================
        -- COMPANION (Companion.lua collector) - Settings Panel Order: 9
        -- ========================================
        -- Uses: Companion.lua - CollectCompanionData
        -- Setting: includeCompanion

        -- 👥 Companions (standalone section, moved from Combat Arsenal)
        {
            name = "Companion",
            tocEntry = {
                title = "👥 Companions",
            },
            condition = IsSettingEnabled(settings, "includeCompanion", true),
            generator = function()
                return gen.GenerateCompanion(data.companion)
            end,
        },

        -- ========================================
        -- COLLECTIBLES (Collectibles.lua collector) - Settings Panel Order: 10
        -- ========================================
        -- Uses: Collectibles.lua - CollectCollectiblesData, CollectDLCAccess, CollectHousingData
        -- Settings: includeCollectibles, includeCollectiblesDetailed, includeDLCAccess, includeTitlesHousing

        -- 🎨 Collectibles (includes Accessible Content, Titles & Housing as collapsible subsections)
        {
            name = "Collectibles",
            tocEntry = {
                title = "🎨 Collectibles",
            },
            condition = function()
                if not IsSettingEnabled(settings, "includeCollectibles", true) then
                    return false
                end
                -- Check if there is any collectible data to show
                local hasData = false
                if data.collectibles then
                    -- Check for simple counts
                    if (data.collectibles.mounts and data.collectibles.mounts > 0) or
                       (data.collectibles.pets and data.collectibles.pets > 0) or
                       (data.collectibles.costumes and data.collectibles.costumes > 0) or
                       (data.collectibles.houses and data.collectibles.houses > 0) then
                        hasData = true
                    end
                    -- Check for detailed categories
                    if not hasData and data.collectibles.categories then
                        for _, cat in pairs(data.collectibles.categories) do
                            if cat and cat.total and cat.total > 0 then
                                hasData = true
                                break
                            end
                        end
                    end
                end
                -- Check for DLC data if enabled
                if not hasData and IsSettingEnabled(settings, "includeDLCAccess", false) and data.dlc then
                     if (data.dlc.accessible and #data.dlc.accessible > 0) or 
                        (data.dlc.locked and #data.dlc.locked > 0) or 
                        data.dlc.hasESOPlus then
                        hasData = true
                     end
                end
                -- Check for Titles/Housing if enabled (implicit check as they are part of collectibles section)
                if not hasData and data.titlesHousing then
                    local titles = data.titlesHousing.titles
                    local housing = data.titlesHousing.housing
                    if (titles and (titles.total or 0) > 0) or (housing and (housing.total or 0) > 0) then
                        hasData = true
                    end
                end
                return hasData
            end,
            generator = function()
                local lorebooksData = (data.worldProgress and data.worldProgress.lorebooks) or nil
                return gen.GenerateCollectibles(
                    data.collectibles,
                    data.dlc,
                    lorebooksData,
                    data.titlesHousing,
                    data.riding
                )
            end,
        },

        -- ========================================
        -- INVENTORY (Inventory.lua collector) - Settings Panel Order: 6
        -- ========================================
        -- Uses: Inventory.lua - CollectInventoryData, CollectCurrencyData
        -- Settings: includeInventory, showBagContents, showBankContents, showCraftingBagContents, includeCurrency

        -- 🎒 Inventory
        {
            name = "Inventory",
            tocEntry = {
                title = "🎒 Inventory",
            },
            condition = IsSettingEnabled(settings, "includeInventory", true),
            generator = function()
                return gen.GenerateInventory(data.inventory)
            end,
        },

        -- ========================================
        -- ACHIEVEMENTS (Achievements.lua collector) - Settings Panel Order: 11
        -- ========================================
        -- Uses: Achievements.lua - CollectAchievementsData
        -- Settings: includeAchievements, showAllAchievements

        -- 🏆 Achievements (standalone section)
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
                    markdown = markdown .. gen.GenerateAchievements(data.achievements)
                else
                    -- Filter to show only in-progress achievements
                    local inProgressData = {
                        summary = data.achievements.summary,
                        inProgress = data.achievements.inProgress or {},
                        categories = data.achievements.categories, -- Include categories for consistency
                    }
                    markdown = markdown .. gen.GenerateAchievements(inProgressData)
                end

                return markdown
            end,
        },

        -- ========================================
        -- ANTIQUITIES (Antiquities.lua collector) - Settings Panel Order: 12
        -- ========================================
        -- Uses: Antiquities.lua - CollectAntiquitiesData
        -- Settings: includeAntiquities, includeAntiquitiesDetailed

        -- 🏺 Antiquities (standalone section)
        {
            name = "Antiquities",
            tocEntry = {
                title = "🏺 Antiquities",
            },
            condition = IsSettingEnabled(settings, "includeAntiquities", false) and data.antiquities and data.antiquities.summary and data.antiquities.summary.totalAntiquities > 0,
            generator = function()
                local markdown = ""

                if not data.antiquities then
                    return markdown
                end

                -- Generate antiquities section
                markdown = markdown .. gen.GenerateAntiquities(data.antiquities)

                return markdown
            end,
        },

        -- ========================================
        -- QUESTS (Quests.lua collector) - Settings Panel Order: 13
        -- ========================================
        -- Uses: Quests.lua - CollectQuestJournalData, CollectUndauntedPledgesData
        -- Settings: includeQuests (disabled), includeUndauntedPledges

        -- 📜 Quests (standalone section) - DISABLED
        --[[
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
        --]]

        -- ========================================
        -- ARMORY BUILDS (ArmoryBuilds.lua collector) - Settings Panel Order: 14
        -- ========================================
        -- Uses: ArmoryBuilds.lua - CollectArmoryBuildsData
        -- Setting: includeArmoryBuilds
        -- NOTE: Currently not in section registry, but collector exists
        -- TODO: Add Armory Builds section when generator is implemented

        -- ========================================
        -- CRAFTING (Crafting.lua collector) - Settings Panel Order: 15
        -- ========================================
        -- Uses: Crafting.lua - CollectCraftingData
        -- Setting: includeCrafting
        -- NOTE: Currently disabled in section registry
        -- TODO: Enable Crafting section when generator is implemented
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

        -- ========================================
        -- SOCIAL (Social.lua collector) - Settings Panel Order: 16
        -- ========================================
        -- Uses: Social.lua - CollectGuildsData, CollectMailData
        -- Settings: includeGuilds, includeMail

        -- 🏰 Guild Membership (includes Undaunted Active Pledges as subsection)
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
                return gen.GenerateGuilds(data.guilds, undauntedPledgesData)
            end,
        },

        -- ========================================
        -- COMBAT (Combat.lua collectors)
        -- ========================================
        -- Uses: Combat.lua - CollectCombatStatsData, CollectRoleData, CollectActiveBuffs, CollectMundusData
        -- Settings: includeCombatStats, includeRole, includeBuffs
        -- NOTE: These are shown in Overview table, not as standalone sections

        -- Buffs (standalone section, not in TOC - shown in Overview table)
        {
            name = "Buffs",
            tocEntry = nil, -- Not shown in TOC
            condition = IsSettingEnabled(settings, "includeBuffs", true),
            generator = function()
                return gen.GenerateBuffs(data.buffs)
            end,
        },

        -- Mundus (included in DLC section, not standalone)
        {
            name = "Mundus",
            tocEntry = nil, -- Not shown in TOC (included in DLC section)
            condition = false, -- Always false - Mundus is handled in DLC section
            generator = function()
            end,
        },
    }

    return registry
end

-- =====================================================
-- MAIN GENERATION FUNCTION
-- =====================================================

local function GenerateMarkdown()
    -- Default to markdown (GitHub style)

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
        characterAttributes = SafeCollect("CollectAttributesData", CM.collectors.CollectAttributesData),
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
        achievements = SafeCollect("CollectAchievementsData", CM.collectors.CollectAchievementsData),
        antiquities = SafeCollect("CollectAntiquitiesData", CM.collectors.CollectAntiquitiesData),
        quests = SafeCollect("CollectQuestJournalData", CM.collectors.CollectQuestJournalData),
        -- equipmentEnhancement = SafeCollect("CollectEquipmentEnhancementData", CM.collectors.CollectEquipmentEnhancementData),  -- DISABLED: generator returns empty
        -- worldProgress = SafeCollect("CollectWorldProgressData", CM.collectors.CollectWorldProgressData),  -- DISABLED
        titles = SafeCollect("CollectTitlesData", CM.collectors.CollectTitlesData),
        housing = SafeCollect("CollectHousingData", CM.collectors.CollectHousingData),
        armoryBuilds = SafeCollect("CollectArmoryBuildsData", CM.collectors.CollectArmoryBuildsData),
        undauntedPledges = SafeCollect("CollectUndauntedPledgesData", CM.collectors.CollectUndauntedPledgesData),
        guilds = SafeCollect("CollectGuildsData", CM.collectors.CollectGuildsData),
        mail = SafeCollect("CollectMailData", CM.collectors.CollectMailData),
        customNotes = (CM.charData and CM.charData.customNotes)
            or (CharacterMarkdownData and CharacterMarkdownData.customNotes)
            or "",
    }

    -- Add composite data structures
    collectedData.titlesHousing = {
        titles = collectedData.titles,
        housing = collectedData.housing,
        collections = collectedData.collectibles -- Pass collectibles for furniture collections if needed
    }



    -- Report any collection errors
    ReportCollectionErrors()

    -- Get settings - use CM.GetSettings() which guarantees no nil values
    -- Settings are always stored in flat format in SavedVariables
    -- CM.GetSettings() merges with defaults to ensure every setting is true or false, never nil
    local settings = CM.GetSettings() or {}
    


    -- Get section generators
    local gen = GetGenerators()

    -- Generate markdown
    CM.DebugPrint("GENERATOR", function()
        return "Generating markdown..."
    end)

    local markdown = ""

    -- Get section registry (pass flattened settings)
    local sections = GetSectionRegistry(settings, gen, collectedData)

    -- Generate all sections based on registry
    -- Generate all sections based on registry
    -- Generate sections
    local markdownChunks = {}
    
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
                    -- Set result to empty to fall through
                else
                    local success, resultTOC = pcall(gen.GenerateDynamicTableOfContents, sections)
                    if success then
                        local resultLength = resultTOC and #resultTOC or 0
                        CM.DebugPrint("GENERATOR", string.format("  ✓ %s: %d chars (dynamic)", section.name, resultLength))
                        
                        -- DIRECTLY REPLACING THE LOGIC:
                        -- If we successfully generated TOC, treat it as 'result' for the common block
                        if resultTOC and resultTOC ~= "" then
                            -- We will process this result using the common block logic by setting a flag or restructure
                            -- To minimize diff, we'll just execute the common logic here for TOC
                            
                            local result = resultTOC
                            
                            -- AUTO-ADD ANCHOR (TOC usually doesn't need anchor, but check tocEntry)
                             if section.tocEntry and section.tocEntry.title then
                                local anchor = GenerateAnchor(section.tocEntry.title)
                                if anchor and anchor ~= "" then
                                    if not result:match("^%s*<a id=") then
                                        result = string.format('<a id="%s"></a>\n\n%s', anchor, result)
                                    end
                                end
                            end

                            -- AUTO-ADD SEPARATOR
                            local hasSeparator = result:match("%-%-%-%s*$") or result:match("<hr>%s*$") or result:match("<hr%s*/>%s*$")
                            if not hasSeparator then
                                local CreateSeparator = CM.utils and CM.utils.markdown and CM.utils.markdown.CreateSeparator
                                if CreateSeparator then
                                    result = result .. CreateSeparator("hr")
                                else
                                    result = result .. "\n---\n\n"
                                end
                                CM.DebugPrint("GENERATOR", string.format("Auto-added separator for section %s", section.name))
                            end
                            
                            table.insert(markdownChunks, result)
                        end
                    else
                        CM.Error(string.format("Dynamic TOC generation failed: %s", tostring(resultTOC)))
                    end
                end
            -- Normal section generation
            elseif not section.generator or type(section.generator) ~= "function" then
                CM.DebugPrint("GENERATOR", string.format("Section '%s' has no valid generator function", section.name))
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

                            -- AUTO-ADD SEPARATOR: Ensure section ends with a separator
                            -- Check if result already ends with a separator (--- or <hr>)
                            -- Allow for trailing whitespace/newlines
                            local hasSeparator = result:match("%-%-%-%s*$") or result:match("<hr>%s*$") or result:match("<hr%s*/>%s*$")
                            
                            if not hasSeparator then
                                local CreateSeparator = CM.utils and CM.utils.markdown and CM.utils.markdown.CreateSeparator
                                if CreateSeparator then
                                    result = result .. CreateSeparator("hr")
                                else
                                    result = result .. "\n---\n\n"
                                end
                                CM.DebugPrint("GENERATOR", string.format("Auto-added separator for section %s", section.name))
                            end

                            table.insert(markdownChunks, result)
                        end
                else
                    CM.Error(string.format("  ✗ %s FAILED: %s", section.name, tostring(result)))
                    -- For critical sections, add placeholder on error
                    if section.name == "SkillBars" or section.name == "Equipment" then
                        CM.Error(string.format("CRITICAL: Section '%s' failed, adding placeholder", section.name))
                        if section.name == "SkillBars" then
                             table.insert(markdownChunks, "## ⚔️ Combat Arsenal\n\n*Error generating skill bars*\n\n---\n\n")
                        elseif section.name == "Equipment" then
                             table.insert(markdownChunks, "## ⚔️ Equipment & Active Sets\n\n*Error generating equipment data*\n\n---\n\n")
                        end
                    end
                end
            end
        end
    end
    -- Markdown generated
    
    local markdown = table.concat(markdownChunks)

    -- CRITICAL CHECK: If markdown is empty at this point, log it
    if markdown == "" or #markdown == 0 then
        CM.Error("⚠️ CRITICAL: Markdown is EMPTY after section generation!")
        CM.Error("This means all sections returned empty content or were skipped.")
        CM.Error("Please check if settings are enabled and data collectors returned data.")
    end

    -- Footer (controlled by includeFooter setting)
    if IsSettingEnabled(settings, "includeFooter", true) then
        local footerSuccess, footerResult = pcall(gen.GenerateFooter, string.len(markdown))
        if footerSuccess then
            markdown = markdown .. footerResult
            CM.DebugPrint("GENERATOR", string.format("Footer added (%d chars)", #footerResult))
        else
            CM.DebugPrint("GENERATOR", string.format("Failed to generate footer: %s", tostring(footerResult)))
        end
    end

    -- Final markdown complete

    CM.DebugPrint("GENERATOR", function()
        return string.format("Markdown generation complete: %d bytes", string.len(markdown))
    end)

    -- Store the complete markdown in a variable
    local completeMarkdown = markdown
    local markdownLength = string.len(completeMarkdown)

    -- Update character data timestamp (markdown/format no longer stored - exceeds ESO 2k char limit and unused)
    if CM.charData then
        CM.charData._lastModified = GetTimeStamp()
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
