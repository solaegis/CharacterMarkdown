-- CharacterMarkdown - TONL Formatter
-- Generates TONL (Token-Oriented Object Notation) output from collected character data

local CM = CharacterMarkdown

-- Import TONL encoder
local TONL = CM.utils and CM.utils.tonl
local EncodeTONL = TONL and TONL.Encode

-- =====================================================
-- DATA COLLECTION HELPERS
-- =====================================================

-- Safe collect wrapper (reused from Markdown.lua pattern)
local function SafeCollect(collectorName, collectorFunc)
    if not collectorFunc or type(collectorFunc) ~= "function" then
        CM.Warn(string.format("⚠️ %s not available", collectorName))
        return {} -- Return empty data if function doesn't exist
    end

    local success, result = pcall(collectorFunc)

    if not success then
        CM.Error(string.format("❌ %s failed: %s", collectorName, tostring(result)))
        return {} -- Return empty data on failure
    end

    return result
end

-- =====================================================
-- MAIN GENERATION FUNCTION
-- =====================================================

-- Helper function to check if a setting is enabled
-- Settings are guaranteed to be true or false (never nil) via CM.GetSettings()
-- Returns true only if setting is explicitly true, false otherwise
local function IsSettingEnabled(settings, settingName, defaultValue)
    if not settings then
        return defaultValue
    end
    local value = settings[settingName]
    -- Settings should never be nil (CM.GetSettings() ensures this), but handle it defensively
    if value == nil then
        return defaultValue
    end
    -- Explicitly check for true - false means disabled
    return value == true
end

-- =====================================================
-- MAIN GENERATION FUNCTION
-- =====================================================

local function GenerateTONL()
    -- Verify collectors are loaded
    if not CM.collectors then
        CM.Error("CM.collectors namespace doesn't exist!")
        CM.Error("The addon did not load correctly. Try /reloadui")
        return "ERROR: Addon not loaded. Type /reloadui and try again."
    end

    -- Check if a critical collector exists
    if not CM.collectors.CollectCharacterData then
        CM.Error("Collectors not loaded!")
        CM.Error("Available in CM.collectors:")
        for k, v in pairs(CM.collectors) do
            CM.Error("  - " .. k)
        end
        return "ERROR: Collectors not loaded. Type /reloadui and try again."
    end

    -- Verify TONL encoder is available
    if not EncodeTONL then
        CM.Error("TONL encoder not available!")
        return "ERROR: TONL encoder not loaded. Type /reloadui and try again."
    end

    -- Get settings
    local settings = CM.GetSettings() or {}

    -- Collect all data with error handling
    CM.DebugPrint("FORMATTER", "Starting data collection...")

    -- Conditionally collect data based on settings
    -- If a setting is disabled, the key will be nil and omitted from the table
    local collectedData = {
        character = SafeCollect("CollectCharacterData", CM.collectors.CollectCharacterData), -- Always include base character data

        dlc = IsSettingEnabled(settings, "includeDLCAccess", false)
                and SafeCollect("CollectDLCAccess", CM.collectors.CollectDLCAccess)
            or nil,

        mundus = IsSettingEnabled(settings, "includeGeneral", true)
                and SafeCollect("CollectMundusData", CM.collectors.CollectMundusData)
            or nil,

        buffs = IsSettingEnabled(settings, "includeBuffs", true)
                and SafeCollect("CollectActiveBuffs", CM.collectors.CollectActiveBuffs)
            or nil,

        cp = IsSettingEnabled(settings, "includeChampionPoints", true)
                and SafeCollect("CollectChampionPointData", CM.collectors.CollectChampionPointData)
            or nil,

        skillBar = IsSettingEnabled(settings, "includeSkillBars", true)
                and SafeCollect("CollectSkillBarData", CM.collectors.CollectSkillBarData)
            or nil,

        skillMorphs = IsSettingEnabled(settings, "includeSkills", true)
                and SafeCollect("CollectSkillMorphsData", CM.collectors.CollectSkillMorphsData)
            or nil,

        stats = IsSettingEnabled(settings, "includeCombatStats", true)
                and SafeCollect("CollectCombatStatsData", CM.collectors.CollectCombatStatsData)
            or nil,

        equipment = IsSettingEnabled(settings, "includeEquipment", true)
                and SafeCollect("CollectEquipmentData", CM.collectors.CollectEquipmentData)
            or nil,

        skill = IsSettingEnabled(settings, "includeSkills", true)
                and SafeCollect("CollectSkillProgressionData", CM.collectors.CollectSkillProgressionData)
            or nil,

        companion = IsSettingEnabled(settings, "includeCompanion", true)
                and SafeCollect("CollectCompanionData", CM.collectors.CollectCompanionData)
            or nil,

        currency = IsSettingEnabled(settings, "includeCurrency", true)
                and SafeCollect("CollectCurrencyData", CM.collectors.CollectCurrencyData)
            or nil,

        progression = IsSettingEnabled(settings, "includeProgression", false)
                and SafeCollect("CollectProgressionData", CM.collectors.CollectProgressionData)
            or nil,

        riding = IsSettingEnabled(settings, "includeRidingSkills", false)
                and SafeCollect("CollectRidingSkillsData", CM.collectors.CollectRidingSkillsData)
            or nil,

        inventory = IsSettingEnabled(settings, "includeInventory", true)
                and SafeCollect("CollectInventoryData", CM.collectors.CollectInventoryData)
            or nil,

        pvp = IsSettingEnabled(settings, "includePvPStats", false)
                and SafeCollect("CollectPvPData", CM.collectors.CollectPvPData)
            or nil,

        role = IsSettingEnabled(settings, "includeRole", true)
                and SafeCollect("CollectRoleData", CM.collectors.CollectRoleData)
            or nil,

        location = IsSettingEnabled(settings, "includeLocation", true)
                and SafeCollect("CollectLocationData", CM.collectors.CollectLocationData)
            or nil,

        collectibles = IsSettingEnabled(settings, "includeCollectibles", true)
                and SafeCollect("CollectCollectiblesData", CM.collectors.CollectCollectiblesData)
            or nil,

        achievements = IsSettingEnabled(settings, "includeAchievements", false)
                and SafeCollect("CollectAchievementsData", CM.collectors.CollectAchievementsData)
            or nil,

        antiquities = IsSettingEnabled(settings, "includeAntiquities", false)
                and SafeCollect("CollectAntiquitiesData", CM.collectors.CollectAntiquitiesData)
            or nil,

        quests = IsSettingEnabled(settings, "includeQuests", false)
                and SafeCollect("CollectQuestJournalData", CM.collectors.CollectQuestJournalData)
            or nil,

        titlesHousing = IsSettingEnabled(settings, "includeTitlesHousing", false)
                and SafeCollect("CollectTitlesData", CM.collectors.CollectTitlesData)
            or nil,

        armoryBuilds = IsSettingEnabled(settings, "includeArmoryBuilds", false)
                and SafeCollect("CollectArmoryBuildsData", CM.collectors.CollectArmoryBuildsData)
            or nil,

        undauntedPledges = IsSettingEnabled(settings, "includeUndauntedPledges", false)
                and SafeCollect("CollectUndauntedPledgesData", CM.collectors.CollectUndauntedPledgesData)
            or nil,

        guilds = IsSettingEnabled(settings, "includeGuilds", true)
                and SafeCollect("CollectGuildsData", CM.collectors.CollectGuildsData)
            or nil,

        customNotes = IsSettingEnabled(settings, "includeBuildNotes", true)
                and ((CM.charData and CM.charData.customNotes) or (CharacterMarkdownData and CharacterMarkdownData.customNotes) or "")
            or nil,

        customTitle = IsSettingEnabled(settings, "includeCharacterAttributes", true)
                and ((CM.charData and CM.charData.customTitle) or (CharacterMarkdownData and CharacterMarkdownData.customTitle) or "")
            or nil,

        playStyle = IsSettingEnabled(settings, "includeCharacterAttributes", true)
                and ((CM.charData and CM.charData.playStyle) or (CharacterMarkdownData and CharacterMarkdownData.playStyle) or "")
            or nil,
    }

    -- Add metadata
    collectedData._metadata = {
        generatedAt = GetTimeStamp(),
        addonVersion = CM.version or "unknown",
        formatter = "tonl",
    }

    CM.DebugPrint("FORMATTER", "Data collection complete, encoding to TONL...")

    -- Encode to TONL format
    local success, tonlOutput = pcall(EncodeTONL, collectedData)

    if not success then
        CM.Error("Failed to encode data to TONL: " .. tostring(tonlOutput))
        return "ERROR: Failed to encode data to TONL format."
    end

    if not tonlOutput or tonlOutput == "" then
        CM.Error("TONL encoding returned empty result")
        return "ERROR: TONL encoding returned empty result."
    end

    CM.DebugPrint("FORMATTER", function()
        return string.format("TONL generation complete: %d bytes", string.len(tonlOutput))
    end)

    -- Clear collected data to help GC
    collectedData = nil

    -- Check if chunking is needed
    local tonlLength = string.len(tonlOutput)
    local CHUNKING = CM.constants and CM.constants.CHUNKING
    local DEFAULTS = CM.constants and CM.constants.DEFAULTS
    local EDITBOX_LIMIT = (CHUNKING and CHUNKING.EDITBOX_LIMIT)
        or (DEFAULTS and DEFAULTS.EDITBOX_LIMIT_FALLBACK)
        or 10000

    -- Chunk if necessary
    if tonlLength > EDITBOX_LIMIT then
        CM.DebugPrint("FORMATTER", function()
            return string.format("TONL exceeds EditBox limit (%d > %d), chunking...", tonlLength, EDITBOX_LIMIT)
        end)

        -- Use the consolidated chunking utility
        local Chunking = CM.utils and CM.utils.Chunking
        local SplitMarkdownIntoChunks = Chunking and Chunking.SplitMarkdownIntoChunks

        if SplitMarkdownIntoChunks then
            local chunks = SplitMarkdownIntoChunks(tonlOutput)
            CM.DebugPrint("FORMATTER", function()
                return string.format("TONL chunked into %d chunks", #chunks)
            end)

            -- Clear intermediate reference
            tonlOutput = nil

            -- Hint to Lua GC
            collectgarbage("step", 1000)

            return chunks
        else
            CM.Error("Chunking utility not available - TONL may be truncated!")

            -- Clear references even on error path
            collectgarbage("step", 1000)

            return tonlOutput
        end
    end

    -- Hint to Lua GC
    collectgarbage("step", 1000)

    return tonlOutput
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.formatters = CM.formatters or {}
CM.formatters.GenerateTONL = GenerateTONL
