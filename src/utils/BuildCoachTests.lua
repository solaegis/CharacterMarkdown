-- CharacterMarkdown - Build Coach export unit tests
-- Gap detectors + schema headings + size budget (no ESO APIs required)

local CM = CharacterMarkdown
CM.tests = CM.tests or {}
CM.tests.buildCoach = CM.tests.buildCoach or {}

local function Fail(message)
    return false, message
end

local function Pass(message)
    return true, message
end

local function HasGapContaining(gaps, needle)
    for _, gap in ipairs(gaps or {}) do
        if tostring(gap):find(needle, 1, true) then
            return true
        end
    end
    return false
end

local function SampleData(overrides)
    local data = {
        character = {
            name = "Test Character",
            class = "Necromancer",
            race = "Dark Elf",
            level = 50,
            cp = 1200,
            title = "Master Wizard",
        },
        playStyle = "stamina_dps",
        customTitle = "Bone Shepherd",
        customNotes = "Focus on solo arena clears.",
        role = { selected = "Damage" },
        mundus = { active = true, name = "The Thief" },
        stats = {
            health = 20000,
            magicka = 15000,
            stamina = 30000,
            weaponPower = 4500,
            spellPower = 2000,
            weaponCritChance = 50,
            weaponCritRating = 3000,
            spellCritChance = 20,
            spellCritRating = 1000,
            physicalPenetration = 5000,
            spellPenetration = 1000,
            physicalResist = 15000,
            spellResist = 12000,
        },
        skillBar = {
            bars = {
                {
                    id = 0,
                    name = "Front Bar",
                    abilities = {
                        { index = 1, name = "Rapid Strikes", id = 1 },
                        { index = 2, name = "Barbed Trap", id = 2 },
                        { index = 3, name = "Poison Injection", id = 3 },
                        { index = 4, name = "Relentless Focus", id = 4 },
                        { index = 5, name = "Camouflaged Hunter", id = 5 },
                    },
                    ultimate = "Dawnbreaker",
                },
                {
                    id = 1,
                    name = "Back Bar",
                    abilities = {
                        { index = 1, name = "Endless Hail", id = 6 },
                        { index = 2, name = "Poison Injection", id = 7 },
                        { index = 3, name = "Resolving Vigor", id = 8 },
                        { index = 4, name = "Razor Caltrops", id = 9 },
                        { index = 5, name = "Consuming Trap", id = 10 },
                    },
                    ultimate = "Flawless Dawnbreaker",
                },
            },
        },
        equipment = {
            sets = {
                { name = "Hunding's Rage", count = 5 },
                { name = "Briarheart", count = 5 },
                { name = "Slimecraw", count = 1, setTypeName = "Monster Set" },
            },
            items = {
                {
                    slotIndex = 0,
                    slotName = "Head",
                    setName = "Slimecraw",
                    trait = "Divines",
                    enchantment = "Max Stamina",
                },
                {
                    slotIndex = 4,
                    slotName = "Main Hand",
                    setName = "Hunding's Rage",
                    trait = "Precise",
                    enchantment = "Poison",
                },
            },
        },
        cp = {
            total = 1200,
            available = 0,
            disciplines = {
                {
                    name = "Warfare",
                    spent = 400,
                    slottableSkills = {
                        { name = "Master-at-Arms", points = 50 },
                        { name = "Fighting Finesse", points = 50 },
                    },
                    passiveSkills = {
                        { name = "Precision", points = 20 },
                    },
                },
            },
        },
        progression = {
            unspentSkillPoints = 0,
            unspentAttributePoints = 0,
        },
    }

    if overrides then
        for k, v in pairs(overrides) do
            data[k] = v
        end
    end
    return data
end

local function TestEmptySkillSlotGap()
    local detect = CM.generators.BuildCoachDetectGaps
    if not detect then
        return Fail("BuildCoachDetectGaps not loaded")
    end

    local data = SampleData({
        skillBar = {
            bars = {
                {
                    id = 0,
                    name = "Front Bar",
                    abilities = {
                        { index = 1, name = "Rapid Strikes", id = 1 },
                        { index = 2, name = "[Empty Slot]", id = nil },
                        { index = 3, name = "X", id = 3 },
                        { index = 4, name = "Y", id = 4 },
                        { index = 5, name = "Z", id = 5 },
                    },
                    ultimate = "Dawnbreaker",
                },
            },
        },
    })
    local gaps = detect(data)
    if not HasGapContaining(gaps, "Empty skill slot") then
        return Fail("Expected empty skill slot gap")
    end
    return Pass("Detects empty skill slots")
end

local function TestIncompleteSetGap()
    local detect = CM.generators.BuildCoachDetectGaps
    local data = SampleData()
    local gaps = detect(data)
    if not HasGapContaining(gaps, "Incomplete monster set Slimecraw") then
        return Fail("Expected incomplete monster set gap for Slimecraw 1/2")
    end
    return Pass("Detects incomplete monster sets")
end

local function TestUnspentCpGap()
    local detect = CM.generators.BuildCoachDetectGaps
    local data = SampleData({
        cp = { total = 1200, available = 42, disciplines = {} },
    })
    local gaps = detect(data)
    if not HasGapContaining(gaps, "Unspent Champion Points: 42") then
        return Fail("Expected unspent CP gap")
    end
    return Pass("Detects unspent CP")
end

local function TestEmptyNotesGap()
    local detect = CM.generators.BuildCoachDetectGaps
    local data = SampleData({ customNotes = "" })
    local gaps = detect(data)
    if not HasGapContaining(gaps, "Build Notes empty") then
        return Fail("Expected empty Build Notes gap")
    end
    return Pass("Detects empty Build Notes")
end

local function TestSchemaHeadings()
    local gen = CM.generators.GenerateBuildCoachMarkdown
    if not gen then
        return Fail("GenerateBuildCoachMarkdown not loaded")
    end
    local md = gen(SampleData())
    local required = {
        "<!-- CharacterMarkdown build-coach v1 -->",
        "## Identity",
        "## Stats snapshot",
        "## Skill bars",
        "## Sets / gear",
        "## Champion Points",
        "## Notes",
        "## Gaps",
        "Ask: review this build",
    }
    for _, needle in ipairs(required) do
        if not md:find(needle, 1, true) then
            return Fail("Missing required content: " .. needle)
        end
    end
    return Pass("Coach schema headings present")
end

local function TestSizeBudget()
    local gen = CM.generators.GenerateBuildCoachMarkdown
    local md = gen(SampleData())
    local len = #md
    if len > 12000 then
        return Fail(string.format("Sample coach export too large: %d bytes (budget 12000)", len))
    end
    return Pass(string.format("Sample coach export size OK (%d bytes)", len))
end

function CM.tests.buildCoach.RunTests()
    CM.Info("=== Build Coach Tests ===")

    local tests = {
        TestEmptySkillSlotGap,
        TestIncompleteSetGap,
        TestUnspentCpGap,
        TestEmptyNotesGap,
        TestSchemaHeadings,
        TestSizeBudget,
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

    CM.Info(string.format("Build coach tests: %d passed, %d failed", passed, failed))
    return failed == 0
end
