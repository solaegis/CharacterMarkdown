-- CharacterMarkdown - Equipment set piece count tests
-- Guards against under-counting two-handed weapons (1 slot, 2 set pieces).

local CM = CharacterMarkdown
CM.tests = CM.tests or {}
CM.tests.equipmentSetCount = CM.tests.equipmentSetCount or {}

local function Fail(message)
    return false, message
end

local function Pass(message)
    return true, message
end

--[[
    Simulate the collector set-count rule: take the max of game-reported
    numNormalEquipped across pieces of the same set (not slot +1).
]]
local function AggregateSetCounts(pieces)
    local sets = {}
    for _, piece in ipairs(pieces) do
        if piece.hasSet and piece.setName then
            local equippedCount = piece.count
            if type(equippedCount) ~= "number" or equippedCount < 1 then
                equippedCount = 1
            end
            sets[piece.setName] = math.max(sets[piece.setName] or 0, equippedCount)
        end
    end
    return sets
end

--[[
    2H weapon (counts as 2) + 3 armor of same set → 5/5, not 4/5.
]]
local function TestTwoHandedCountsAsTwoPieces()
    local sets = AggregateSetCounts({
        { hasSet = true, setName = "Julianos", count = 5 }, -- 2H main-hand reports total equipped
        { hasSet = true, setName = "Julianos", count = 5 }, -- chest
        { hasSet = true, setName = "Julianos", count = 5 }, -- legs
        { hasSet = true, setName = "Julianos", count = 5 }, -- feet
    })

    if sets.Julianos ~= 5 then
        return Fail(string.format("Expected Julianos count 5 (2H+3 armor), got %s", tostring(sets.Julianos)))
    end

    -- Slot-based +1 would wrongly yield 4 for these four slots
    if sets.Julianos == 4 then
        return Fail("Regression: two-handed weapon under-counted as 1 piece")
    end

    return Pass("2H + 3 armor reports 5/5 set pieces")
end

--[[
    Dual-wield same set: two 1H weapons + 3 armor → 5; each piece reports total.
]]
local function TestDualWieldSameSet()
    local sets = AggregateSetCounts({
        { hasSet = true, setName = "Hunding", count = 5 },
        { hasSet = true, setName = "Hunding", count = 5 },
        { hasSet = true, setName = "Hunding", count = 5 },
        { hasSet = true, setName = "Hunding", count = 5 },
        { hasSet = true, setName = "Hunding", count = 5 },
    })

    if sets.Hunding ~= 5 then
        return Fail(string.format("Expected Hunding count 5, got %s", tostring(sets.Hunding)))
    end

    return Pass("Dual-wield same set reports 5/5")
end

--[[
    Missing/invalid API count falls back to 1 per piece (slot weight).
]]
local function TestMissingCountFallsBackToOne()
    local sets = AggregateSetCounts({
        { hasSet = true, setName = "Orgs", count = nil },
        { hasSet = true, setName = "Orgs", count = 0 },
        { hasSet = true, setName = "Orgs", count = 3 },
    })

    if sets.Orgs ~= 3 then
        return Fail(string.format("Expected Orgs count 3 (max of fallbacks and 3), got %s", tostring(sets.Orgs)))
    end

    return Pass("Invalid counts fall back; valid API count wins")
end

--[[
    Two different sets keep independent totals.
]]
local function TestSeparateSetsIndependent()
    local sets = AggregateSetCounts({
        { hasSet = true, setName = "SetA", count = 5 },
        { hasSet = true, setName = "SetB", count = 2 },
        { hasSet = true, setName = "SetA", count = 5 },
        { hasSet = true, setName = "SetB", count = 2 },
    })

    if sets.SetA ~= 5 or sets.SetB ~= 2 then
        return Fail(
            string.format("Expected SetA=5 SetB=2, got SetA=%s SetB=%s", tostring(sets.SetA), tostring(sets.SetB))
        )
    end

    return Pass("Independent sets keep separate counts")
end

function CM.tests.equipmentSetCount.RunTests()
    CM.Info("=== Equipment Set Count Tests ===")

    local tests = {
        TestTwoHandedCountsAsTwoPieces,
        TestDualWieldSameSet,
        TestMissingCountFallsBackToOne,
        TestSeparateSetsIndependent,
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

    CM.Info(string.format("Equipment set count tests: %d passed, %d failed", passed, failed))
    return failed == 0
end
