-- CharacterMarkdown - CollectiblesHasContent unit tests
-- Fixture-shaped like CollectCollectiblesData (collections.*.count|total)
-- No ESO APIs required

local CM = CharacterMarkdown
CM.tests = CM.tests or {}
CM.tests.collectiblesHasContent = CM.tests.collectiblesHasContent or {}

local function Fail(message)
    return false, message
end

local function Pass(message)
    return true, message
end

local function CollectorShapedFixtures()
    return {
        collections = {
            costumes = {
                count = 51,
                total = 323,
                list = {
                    { name = "Mages Guild Formal Robes", fullName = "Mages Guild Formal Robes" },
                    { name = "Austere Warden Outfit", fullName = "Austere Warden Outfit" },
                },
            },
            mounts = { count = 10, total = 100, list = {} },
            pets = { count = 5, total = 80, list = {} },
        },
        summary = {
            total = 503,
            unlocked = 66,
            completionPercent = 13,
        },
    }
end

local function RunCase(name, fn)
    local ok, message = fn()
    if ok then
        CM.Info(string.format("[PASS] CollectiblesHasContent: %s — %s", name, message or "ok"))
        return true
    end
    CM.Error(string.format("[FAIL] CollectiblesHasContent: %s — %s", name, message or "failed"))
    return false
end

function CM.tests.collectiblesHasContent.RunTests()
    local HasContent = CM.generators
        and CM.generators.sections
        and CM.generators.sections.CollectiblesHasContent
    if not HasContent then
        CM.Error("[FAIL] CollectiblesHasContent: helper not loaded")
        return false
    end

    local passed = 0
    local failed = 0

    local function tally(ok)
        if ok then
            passed = passed + 1
        else
            failed = failed + 1
        end
    end

    tally(RunCase("collector-shaped costumes count", function()
        local data = CollectorShapedFixtures()
        if not HasContent(data, nil, nil, { includeCollectibles = true }) then
            return Fail("expected true for collections.costumes.count > 0")
        end
        return Pass("collections.costumes recognized")
    end))

    tally(RunCase("summary.unlocked alone", function()
        local data = {
            collections = {},
            summary = { unlocked = 3, total = 10 },
        }
        if not HasContent(data, nil, nil, {}) then
            return Fail("expected true for summary.unlocked > 0")
        end
        return Pass("summary.unlocked recognized")
    end))

    tally(RunCase("legacy flat mounts count", function()
        local data = { mounts = 12, pets = 0, costumes = 0 }
        if not HasContent(data, nil, nil, {}) then
            return Fail("expected true for legacy mounts number")
        end
        return Pass("legacy flat mounts recognized")
    end))

    tally(RunCase("empty collectibles false", function()
        local data = {
            collections = {
                costumes = { count = 0, total = 323, list = {} },
            },
            summary = { unlocked = 0, total = 323 },
        }
        if HasContent(data, nil, nil, {}) then
            return Fail("expected false when all counts are zero")
        end
        return Pass("empty collections rejected")
    end))

    tally(RunCase("DLC ESO Plus with includeDLCAccess", function()
        if not HasContent(nil, { hasESOPlus = true }, nil, { includeDLCAccess = true }) then
            return Fail("expected true for hasESOPlus when includeDLCAccess")
        end
        if HasContent(nil, { hasESOPlus = true }, nil, { includeDLCAccess = false }) then
            return Fail("expected false when includeDLCAccess is off")
        end
        return Pass("DLC gate honored")
    end))

    tally(RunCase("housing summary.totalOwned", function()
        local titlesHousing = {
            housing = {
                summary = { totalOwned = 2, totalAvailable = 10 },
                owned = { { name = "Inn Room" } },
            },
        }
        if not HasContent(nil, nil, titlesHousing, { includeHousing = true }) then
            return Fail("expected true for housing.summary.totalOwned")
        end
        -- Legacy condition used housing.total — must not be required
        if HasContent(nil, nil, { housing = { total = nil, summary = { totalOwned = 0 } } }, { includeHousing = true }) then
            return Fail("expected false when totalOwned is 0")
        end
        return Pass("housing.summary.totalOwned recognized")
    end))

    CM.Info(string.format("CollectiblesHasContent tests: %d passed, %d failed", passed, failed))
    return failed == 0
end

CM.DebugPrint("TEST", "CollectiblesHasContent tests module loaded")
