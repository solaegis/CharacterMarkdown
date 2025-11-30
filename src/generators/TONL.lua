-- CharacterMarkdown - TONL Generation Engine
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

    -- Collect all data with error handling
    CM.DebugPrint("TONL", "Starting data collection...")

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
        achievements = SafeCollect("CollectAchievementsData", CM.collectors.CollectAchievementsData),
        antiquities = SafeCollect("CollectAntiquitiesData", CM.collectors.CollectAntiquitiesData),
        quests = SafeCollect("CollectQuestJournalData", CM.collectors.CollectQuestJournalData),
        titles = SafeCollect("CollectTitlesData", CM.collectors.CollectTitlesData),
        housing = SafeCollect("CollectHousingData", CM.collectors.CollectHousingData),
        armoryBuilds = SafeCollect("CollectArmoryBuildsData", CM.collectors.CollectArmoryBuildsData),
        undauntedPledges = SafeCollect("CollectUndauntedPledgesData", CM.collectors.CollectUndauntedPledgesData),
        guilds = SafeCollect("CollectGuildsData", CM.collectors.CollectGuildsData),
        customNotes = (CM.charData and CM.charData.customNotes)
            or (CharacterMarkdownData and CharacterMarkdownData.customNotes)
            or "",
        customTitle = (CM.charData and CM.charData.customTitle)
            or (CharacterMarkdownData and CharacterMarkdownData.customTitle)
            or "",
        playStyle = (CM.charData and CM.charData.playStyle)
            or (CharacterMarkdownData and CharacterMarkdownData.playStyle)
            or "",
    }

    -- Add metadata
    collectedData._metadata = {
        generatedAt = GetTimeStamp(),
        addonVersion = CM.addonVersion or "unknown",
        format = "tonl",
    }

    CM.DebugPrint("TONL", "Data collection complete, encoding to TONL...")

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

    CM.DebugPrint("TONL", function()
        return string.format("TONL generation complete: %d bytes", string.len(tonlOutput))
    end)

    -- Clear collected data to help GC
    collectedData = nil
    collectgarbage("step", 1000)

    return tonlOutput
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.generators = CM.generators or {}
CM.generators.GenerateTONL = GenerateTONL

