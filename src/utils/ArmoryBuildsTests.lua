-- CharacterMarkdown - Armory Builds unit tests
-- Generator payload shape + loadout rendering (no ESO APIs required)

local CM = CharacterMarkdown
CM.tests = CM.tests or {}
CM.tests.armoryBuilds = CM.tests.armoryBuilds or {}

local function Fail(message)
    return false, message
end

local function Pass(message)
    return true, message
end

local function SampleBuild(overrides)
    local build = {
        index = 1,
        name = "Solo Mag DPS",
        skillPoints = 300,
        attributes = { health = 0, magicka = 64, stamina = 0 },
        champion = { craft = 50, warfare = 100, fitness = 80, total = 230 },
        mundus = { primary = "The Apprentice" },
        curse = "Vampire",
        outfitIndex = 2,
        sets = {
            { name = "Mother's Sorrow", count = 5 },
            { name = "Burning Spellweave", count = 5 },
        },
        equipment = {
            {
                slot = 0,
                slotName = "Head",
                emoji = "⛑️",
                state = "VALID",
                name = "Mother's Sorrow Hat",
                setName = "Mother's Sorrow",
                quality = "Legendary",
                qualityEmoji = "🟨",
                trait = "Divines",
                armorType = 3,
            },
            {
                slot = 4,
                slotName = "Main Hand",
                emoji = "⚔️",
                state = "MISSING",
                name = "[Missing]",
                setName = "-",
                quality = "-",
                qualityEmoji = "⚪",
                trait = "-",
            },
            {
                slot = 13,
                slotName = "Hands",
                emoji = "✋",
                state = "INACCESSIBLE",
                name = "[Inaccessible]",
                setName = "-",
                quality = "-",
                qualityEmoji = "⚪",
                trait = "-",
            },
        },
        hotbars = {
            {
                id = 0,
                name = "⚔️ Front Bar (Main Hand)",
                category = 0,
                abilities = {
                    { index = 1, name = "Force Pulse", id = 101 },
                    { index = 2, name = "Inner Light", id = 102 },
                    { index = 3, name = "[Empty Slot]", id = nil },
                    { index = 4, name = "Elemental Drain", id = 104 },
                    { index = 5, name = "Harness Magicka", id = 105 },
                },
                ultimate = "Shooting Star",
                ultimateId = 200,
            },
            {
                id = 1,
                name = "🔮 Back Bar (Backup)",
                category = 1,
                abilities = {
                    { index = 1, name = "Unstable Wall of Elements", id = 201 },
                    { index = 2, name = "Blockade of Elements", id = 202 },
                    { index = 3, name = "Channeled Acceleration", id = 203 },
                    { index = 4, name = "Scalding Rune", id = 204 },
                    { index = 5, name = "Mystic Orb", id = 205 },
                },
                ultimate = "Northern Storm",
                ultimateId = 300,
            },
        },
    }

    if overrides then
        for key, value in pairs(overrides) do
            build[key] = value
        end
    end

    return build
end

local function SampleArmory(overrides)
    local data = {
        unlocked = 3,
        builds = { SampleBuild() },
        summary = {
            totalBuilds = 1,
            unlockedSlots = 3,
            maxBuilds = 10,
            utilizationPercent = 30,
        },
    }
    if overrides then
        for key, value in pairs(overrides) do
            data[key] = value
        end
    end
    return data
end

local function TestFlatPayloadEmitsBuildName()
    local gen = CM.generators.sections and CM.generators.sections.GenerateArmoryBuilds
    if not gen then
        return Fail("GenerateArmoryBuilds not loaded")
    end
    local md = gen(SampleArmory())
    if not md:find("Solo Mag DPS", 1, true) then
        return Fail("Expected build name in output for flat collector payload")
    end
    if md:find("No armory data available", 1, true) then
        return Fail("Flat payload incorrectly treated as missing data")
    end
    if not md:find("## 🏰 Armory Builds", 1, true) and not md:find("Armory Builds", 1, true) then
        return Fail("Expected Armory Builds heading")
    end
    return Pass("Flat collector payload emits build name")
end

local function TestLegacyNestedPayloadStillWorks()
    local gen = CM.generators.sections.GenerateArmoryBuilds
    local md = gen({ armory = SampleArmory() })
    if not md:find("Solo Mag DPS", 1, true) then
        return Fail("Legacy nested armory payload should still render")
    end
    return Pass("Legacy nested payload accepted")
end

local function TestEmptyBuildsDistinctFromMissingData()
    local gen = CM.generators.sections.GenerateArmoryBuilds
    local emptyMd = gen({
        unlocked = 2,
        builds = {},
        summary = { unlockedSlots = 2, maxBuilds = 10, totalBuilds = 0 },
    })
    if emptyMd:find("No armory data available", 1, true) then
        return Fail("Empty builds should not use missing-data placeholder")
    end
    if not emptyMd:find("No builds configured", 1, true) then
        return Fail("Empty builds should say no builds configured")
    end

    local missingMd = gen(nil)
    if not missingMd:find("No armory data available", 1, true) then
        return Fail("Nil payload should show no armory data available")
    end
    return Pass("Empty builds vs missing data distinguished")
end

local function TestEquipmentEnrichmentAndSlotStates()
    local gen = CM.generators.sections.GenerateArmoryBuilds
    local md = gen(SampleArmory())
    if not md:find("Mother's Sorrow", 1, true) then
        return Fail("Expected set name in equipment/sets output")
    end
    if not md:find("Divines", 1, true) then
        return Fail("Expected trait in equipment details")
    end
    if not md:find("MISSING", 1, true) then
        return Fail("Expected MISSING slot state label")
    end
    if not md:find("INACCESSIBLE", 1, true) then
        return Fail("Expected INACCESSIBLE slot state label")
    end
    return Pass("Equipment enrichment and slot states present")
end

local function TestHotbarLabelsUltimateAndEmptySlots()
    local gen = CM.generators.sections.GenerateArmoryBuilds
    local md = gen(SampleArmory())
    if not md:find("Front Bar", 1, true) then
        return Fail("Expected Front Bar label")
    end
    if not md:find("Back Bar", 1, true) then
        return Fail("Expected Back Bar label")
    end
    if not md:find("Shooting Star", 1, true) then
        return Fail("Expected ultimate ability on front bar")
    end
    if not md:find("Empty Slot", 1, true) then
        return Fail("Expected empty slot placeholder preserved in bar table")
    end
    -- Ultimate column marker used by SkillBars-style tables
    if not md:find("⚡", 1, true) then
        return Fail("Expected ultimate column in skill bar table")
    end
    return Pass("Hotbar labels, ultimate, and empty slots OK")
end

function CM.tests.armoryBuilds.RunTests()
    CM.Info("=== Armory Builds Tests ===")

    local tests = {
        TestFlatPayloadEmitsBuildName,
        TestLegacyNestedPayloadStillWorks,
        TestEmptyBuildsDistinctFromMissingData,
        TestEquipmentEnrichmentAndSlotStates,
        TestHotbarLabelsUltimateAndEmptySlots,
    }

    local passed = 0
    local failed = 0

    for _, testFunc in ipairs(tests) do
        local ok, result, message = pcall(testFunc)
        if ok and result == true then
            passed = passed + 1
            CM.Info(string.format("  ✓ %s", message or "passed"))
        else
            failed = failed + 1
            local errMsg = ok and (message or tostring(result)) or tostring(result)
            CM.Error(string.format("  ✗ %s", errMsg))
        end
    end

    CM.Info(string.format("Armory builds tests: %d passed, %d failed", passed, failed))
    return failed == 0
end
