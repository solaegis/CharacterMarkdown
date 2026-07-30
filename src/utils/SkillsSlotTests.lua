-- CharacterMarkdown - Action bar slot index tests
-- Guards against the slot-5 / ultimate swap caused by using 0-based ESO
-- ACTION_BAR_* constants as 1-based GetSlotBoundId indices.

local CM = CharacterMarkdown
CM.tests = CM.tests or {}
CM.tests.skillsSlots = CM.tests.skillsSlots or {}

local function Fail(message)
    return false, message
end

local function Pass(message)
    return true, message
end

--[[
    When ACTION_BAR_ULTIMATE_SLOT_INDEX is 7 (0-based, normal in-game),
    GetSlotBoundId ultimate slot must be 8 — never equal to the raw constant.
]]
local function TestUltimateSlotConversion()
    local skills = CM.api and CM.api.skills
    if not skills or not skills.GetUltimateActionBarSlotIndex then
        return Fail("CM.api.skills.GetUltimateActionBarSlotIndex missing")
    end

    local zeroBased = ACTION_BAR_ULTIMATE_SLOT_INDEX or 7
    local oneBased = skills.GetUltimateActionBarSlotIndex()

    if oneBased ~= zeroBased + 1 then
        return Fail(
            string.format(
                "GetUltimateActionBarSlotIndex=%s expected %s (CONSTANT+1)",
                tostring(oneBased),
                tostring(zeroBased + 1)
            )
        )
    end

    if oneBased ~= 8 then
        return Fail(string.format("Expected ultimate API slot 8, got %s", tostring(oneBased)))
    end

    if oneBased == zeroBased then
        return Fail("Regression: using 0-based ACTION_BAR_ULTIMATE_SLOT_INDEX as 1-based slot")
    end

    return Pass(string.format("Ultimate API slot is %d (0-based constant %d + 1)", oneBased, zeroBased))
end

local function TestFirstNormalSlotConversion()
    local skills = CM.api and CM.api.skills
    if not skills or not skills.GetFirstNormalActionBarSlotIndex then
        return Fail("CM.api.skills.GetFirstNormalActionBarSlotIndex missing")
    end

    local zeroBased = ACTION_BAR_FIRST_NORMAL_SLOT_INDEX or 2
    local oneBased = skills.GetFirstNormalActionBarSlotIndex()

    if oneBased ~= zeroBased + 1 then
        return Fail(
            string.format(
                "GetFirstNormalActionBarSlotIndex=%s expected %s (CONSTANT+1)",
                tostring(oneBased),
                tostring(zeroBased + 1)
            )
        )
    end

    if oneBased ~= 3 then
        return Fail(string.format("Expected first normal API slot 3, got %s", tostring(oneBased)))
    end

    return Pass(string.format("First normal API slot is %d (0-based constant %d + 1)", oneBased, zeroBased))
end

--[[
    Slot 7 is the 5th ability; slot 8 is ultimate. Comparing to raw constant 7
    previously flipped those columns in the markdown export.
]]
local function TestIsUltimateDoesNotTreatSlot5AsUlt()
    local skills = CM.api and CM.api.skills
    if not skills or not skills.IsUltimateActionBarSlot then
        return Fail("CM.api.skills.IsUltimateActionBarSlot missing")
    end

    if skills.IsUltimateActionBarSlot(7) then
        return Fail("Slot 7 (ability 5) must not be treated as ultimate")
    end

    if not skills.IsUltimateActionBarSlot(8) then
        return Fail("Slot 8 must be treated as ultimate")
    end

    local first = skills.GetFirstNormalActionBarSlotIndex()
    local ult = skills.GetUltimateActionBarSlotIndex()
    local regularCount = ult - first
    if regularCount ~= 5 then
        return Fail(string.format("Expected 5 regular slots (3-7), got %d", regularCount))
    end

    return Pass("Slot 7 is ability 5; slot 8 is ultimate; five regular slots")
end

--[[
    Simulate collector split: abilities from 3-7, ultimate from 8.
    Ensures slot-5 skill and ultimate land in distinct fields.
]]
local function TestCollectorSplitMapping()
    local skills = CM.api and CM.api.skills
    if not skills then
        return Fail("CM.api.skills missing")
    end

    local first = skills.GetFirstNormalActionBarSlotIndex()
    local ult = skills.GetUltimateActionBarSlotIndex()

    -- Fake bar: slots 3-8 named by their API index
    local fakeSlots = {}
    for slot = first, ult do
        fakeSlots[slot] = {
            id = slot * 100,
            name = "AbilityAtSlot" .. tostring(slot),
            isUltimate = skills.IsUltimateActionBarSlot(slot),
        }
    end

    local abilities = {}
    local ultimateName, ultimateId
    for slot = first, ult - 1 do
        local ability = fakeSlots[slot]
        table.insert(abilities, {
            name = ability.name,
            id = ability.id,
            slot = slot,
        })
    end
    local ultAbility = fakeSlots[ult]
    if ultAbility then
        ultimateName = ultAbility.name
        ultimateId = ultAbility.id
    end

    if #abilities ~= 5 then
        return Fail(string.format("Expected 5 abilities, got %d", #abilities))
    end

    if abilities[5].name ~= "AbilityAtSlot7" or abilities[5].slot ~= 7 then
        return Fail(
            string.format(
                "abilities[5] should be slot 7, got slot=%s name=%s",
                tostring(abilities[5] and abilities[5].slot),
                tostring(abilities[5] and abilities[5].name)
            )
        )
    end

    if ultimateName ~= "AbilityAtSlot8" or ultimateId ~= 800 then
        return Fail(
            string.format(
                "ultimate should be slot 8, got name=%s id=%s",
                tostring(ultimateName),
                tostring(ultimateId)
            )
        )
    end

    if abilities[5].name == ultimateName then
        return Fail("Regression: slot 5 and ultimate have the same ability (swap)")
    end

    return Pass("Collector split maps slot 7 → abilities[5], slot 8 → ultimate")
end

function CM.tests.skillsSlots.RunTests()
    CM.Info("=== Action Bar Slot Index Tests ===")

    local tests = {
        TestUltimateSlotConversion,
        TestFirstNormalSlotConversion,
        TestIsUltimateDoesNotTreatSlot5AsUlt,
        TestCollectorSplitMapping,
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

    CM.Info(string.format("Action bar slot tests: %d passed, %d failed", passed, failed))
    return failed == 0
end

CM.DebugPrint("UTILS", "SkillsSlotTests module loaded")
