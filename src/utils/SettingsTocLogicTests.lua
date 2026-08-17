-- CharacterMarkdown - Settings / TOC logic regression tests
-- Fixture-based; no ESO APIs required

local CM = CharacterMarkdown
CM.tests = CM.tests or {}
CM.tests.settingsTocLogic = CM.tests.settingsTocLogic or {}

local function Fail(message)
    return false, message
end

local function Pass(message)
    return true, message
end

local function RunCase(name, fn)
    local ok, message = fn()
    if ok then
        CM.Info(string.format("[PASS] SettingsTocLogic: %s — %s", name, message or "ok"))
        return true
    end
    CM.Error(string.format("[FAIL] SettingsTocLogic: %s — %s", name, message or "failed"))
    return false
end

local function CharFixture()
    return {
        name = "Test",
        race = "High Elf",
        class = "Sorcerer",
        alliance = "Aldmeri Dominion",
        server = "NA",
        account = "@test",
        level = 50,
        cp = 100,
        attributes = { magicka = 64, health = 0, stamina = 0 },
    }
end

function CM.tests.settingsTocLogic.RunTests()
    local passed = 0
    local failed = 0

    local function tally(ok)
        if ok then
            passed = passed + 1
        else
            failed = failed + 1
        end
    end

    tally(RunCase("world progress endless-only has content", function()
        local GenerateWorldProgress = CM.generators
            and CM.generators.sections
            and CM.generators.sections.GenerateWorldProgress
        if not GenerateWorldProgress then
            return Fail("GenerateWorldProgress not loaded")
        end
        local md = GenerateWorldProgress({
            endlessDungeon = { score = 1200, isInstance = false, verses = {} },
        })
        if not md or md == "" or not md:find("Endless Dungeon") then
            return Fail("expected World Progress body for endlessDungeon-only payload")
        end
        return Pass("endless-only payload renders")
    end))

    tally(RunCase("collectibles has content for DLC without parent collectibles", function()
        local HasContent = CM.generators
            and CM.generators.sections
            and CM.generators.sections.CollectiblesHasContent
        if not HasContent then
            return Fail("CollectiblesHasContent not loaded")
        end
        local dlc = {
            accessible = { { name = "Greymoor" } },
            locked = {},
            hasESOPlus = false,
        }
        if
            not HasContent(nil, dlc, nil, {
                includeCollectibles = false,
                includeDLCAccess = true,
                includeHousing = false,
                includeTitlesHousing = false,
            })
        then
            return Fail("expected true when includeDLCAccess + dlc payload")
        end
        return Pass("DLC nested setting recognized")
    end))

    tally(RunCase("collectibles has content for housing without parent collectibles", function()
        local HasContent = CM.generators
            and CM.generators.sections
            and CM.generators.sections.CollectiblesHasContent
        if not HasContent then
            return Fail("CollectiblesHasContent not loaded")
        end
        local titlesHousing = {
            titles = {},
            housing = {
                summary = { totalOwned = 2, totalAvailable = 10 },
                primary = { name = "Snugpod" },
            },
        }
        if
            not HasContent(nil, nil, titlesHousing, {
                includeCollectibles = false,
                includeDLCAccess = false,
                includeHousing = true,
                includeTitlesHousing = false,
            })
        then
            return Fail("expected true when includeHousing + housing payload")
        end
        return Pass("Housing nested setting recognized")
    end))

    tally(RunCase("guilds section renders pledges when guild list empty", function()
        local GenerateGuilds = CM.generators and CM.generators.sections and CM.generators.sections.GenerateGuilds
        if not GenerateGuilds then
            return Fail("GenerateGuilds not loaded")
        end
        local md = GenerateGuilds(nil, {
            pledges = {
                active = {
                    { name = "Fungal Grotto I", difficulty = "Normal" },
                },
            },
        })
        if not md or md == "" or not md:find("Guild Membership") then
            return Fail("expected Guild Membership body for pledges-only")
        end
        if not md:find("Fungal Grotto") and not md:find("[Pp]ledge") then
            return Fail("expected pledges content in guilds output")
        end
        return Pass("pledges-only guilds output")
    end))

    tally(RunCase("overview omits attributes buffs location when settings off", function()
        local GenerateOverviewSection = CM.generators
            and CM.generators.sections
            and CM.generators.sections.GenerateOverviewSection
        if not GenerateOverviewSection then
            return Fail("GenerateOverviewSection not loaded")
        end
        local settings = {
            includeGeneral = true,
            includeCurrency = false,
            includeAttributes = false,
            includeBuffs = false,
            includeLocation = false,
            includeCharacterAttributes = false,
            includeProgression = false,
        }
        local md = GenerateOverviewSection(
            CharFixture(),
            nil,
            "github",
            nil,
            nil,
            nil,
            nil,
            nil,
            { zone = "Auridon", subzone = "Vulkhel Guard", zoneIndex = 1 },
            { food = "Witchmother's Potent Brew" },
            nil,
            nil,
            nil,
            nil,
            settings
        )
        if not md or md == "" then
            return Fail("expected Overview body")
        end
        if md:find("Attributes") or md:find("🔵") then
            return Fail("attributes row should be omitted when includeAttributes=false")
        end
        if md:find("Active Buffs") or md:find("Witchmother") then
            return Fail("buffs should be omitted when includeBuffs=false")
        end
        if md:find("Auridon") or md:find("Location") then
            return Fail("location should be omitted when includeLocation=false")
        end
        return Pass("Overview gates honor settings")
    end))

    tally(RunCase("attention needed generator returns empty without warnings", function()
        local GenerateAttentionNeeded = CM.generators
            and CM.generators.sections
            and CM.generators.sections.GenerateAttentionNeeded
        if not GenerateAttentionNeeded then
            return Fail("GenerateAttentionNeeded not loaded")
        end
        local md = GenerateAttentionNeeded(
            { unspentSkillPoints = 0, unspentAttributePoints = 0 },
            { backpackPercent = 10, bankPercent = 10 },
            { speed = 60, stamina = 60, capacity = 60 },
            nil,
            nil,
            "github"
        )
        if md and md ~= "" then
            return Fail("expected empty when no warnings")
        end
        return Pass("empty warnings omit section body")
    end))

    CM.Info(string.format("SettingsTocLogic tests: %d passed, %d failed", passed, failed))
    return failed == 0
end
