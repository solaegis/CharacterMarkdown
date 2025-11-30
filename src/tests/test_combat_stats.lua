-- Test script for Combat Stats generation
-- Run with: lua src/tests/test_combat_stats.lua

-- Mock the global environment and CM namespace
CharacterMarkdown = {
    api = {
        combat = {},
        character = {}
    },
    collectors = {},
    generators = {
        sections = {}
    },
    utils = {
        FormatNumber = function(n) return tostring(n) end,
        markdown = {
            CreateSeparator = function() return "\n---\n\n" end,
            GenerateAnchor = function(s) return s:lower():gsub(" ", "-") end
        }
    },
    links = {
        CreateBuffLink = function() return "" end
    },
    Warn = function(msg) print("WARN: " .. msg) end,
    DebugPrint = function(ctx, msg) print("DEBUG [" .. ctx .. "]: " .. (type(msg) == "function" and msg() or msg)) end,
    Error = function(msg) print("ERROR: " .. msg) end
}

CM = CharacterMarkdown

-- Mock API constants
STAT_HEALTH_MAX = 1
STAT_MAGICKA_MAX = 2
STAT_STAMINA_MAX = 3

-- Mock API functions
CM.api.combat.GetStat = function(statId)
    if statId == STAT_HEALTH_MAX then return 20000 end
    if statId == STAT_MAGICKA_MAX then return 15000 end
    if statId == STAT_STAMINA_MAX then return 15000 end
    return 0
end

CM.api.combat.GetPowerStats = function()
    return {
        physical = { power = 3000, crit = 2190, penetration = 1000 },
        spell = { power = 3000, crit = 2190, penetration = 1000 },
        resistance = { physical = 10000, spell = 10000 }
    }
end

CM.api.combat.GetRegenStats = function()
    return { health = 500, magicka = 1000, stamina = 1000 }
end

CM.api.character.GetLevel = function()
    return { level = 50 }
end

CM.api.combat.GetCoreAbilityStats = function()
    return {
        lightAttackDamage = 0, -- Calculated in collector
        heavyAttackDamage = 0, -- Calculated in collector
        bashDamage = 0, -- Calculated in collector
        blockMitigation = 0, -- Calculated in collector
        blockSpeed = 0, -- Calculated in collector
        bashCost = 1000,
        blockCost = 1000,
        breakFreeCost = 2000,
        dodgeRollCost = 2000,
        sneakCost = 100,
        sneakSpeed = 0,
        sprintCost = 100,
        sprintSpeed = 0
    }
end

CM.api.combat.GetResistances = function()
    return {
        flame = 10000, shock = 10000, frost = 10000, magic = 10000,
        disease = 10000, poison = 10000, bleed = 10000, critical = 0
    }
end

CM.api.combat.GetDamageBonuses = function()
    return {
        criticalDamage = 0, -- Calculated in collector
        physical = { flat = 0, percent = 5 },
        flame = { flat = 0, percent = 5 },
        shock = { flat = 0, percent = 5 },
        frost = { flat = 0, percent = 5 },
        magic = { flat = 0, percent = 5 },
        disease = { flat = 0, percent = 5 },
        poison = { flat = 0, percent = 5 },
        bleed = { flat = 0, percent = 5 },
        oblivion = { flat = 0, percent = 0 }
    }
end

CM.api.combat.GetHealingBonuses = function()
    return {
        healingDone = { flat = 0, percent = 10 },
        healingTaken = { flat = 0, percent = 5 },
        criticalHealing = 50
    }
end

-- Load the collector
dofile("src/collectors/Combat.lua")

-- Load the generator (sections)
dofile("src/generators/sections/Combat.lua")

print("=== Running Combat Stats Test ===")

-- 1. Test Collection
print("\n1. Testing Collection...")
local stats = CM.collectors.CollectCombatStatsData()

if not stats then
    print("FAIL: CollectCombatStatsData returned nil")
    os.exit(1)
end

if stats.health ~= 20000 then
    print("FAIL: Incorrect health value: " .. tostring(stats.health))
    os.exit(1)
end

if not stats.advanced then
    print("FAIL: stats.advanced is missing")
    os.exit(1)
end

print("PASS: Data collected successfully")

-- 2. Test Basic Stats Generation
print("\n2. Testing Basic Stats Generation...")
local basicMarkdown = CM.generators.sections.GenerateCombatStats(stats, "markdown", true)
if not basicMarkdown or basicMarkdown == "" then
    print("FAIL: GenerateCombatStats returned empty string")
    os.exit(1)
end
print("PASS: Basic stats generated (" .. #basicMarkdown .. " chars)")

-- 3. Test Advanced Stats Generation
print("\n3. Testing Advanced Stats Generation...")
local advancedMarkdown = CM.generators.sections.GenerateAdvancedStats(stats, "markdown")
if not advancedMarkdown or advancedMarkdown == "" then
    print("FAIL: GenerateAdvancedStats returned empty string")
    os.exit(1)
end
print("PASS: Advanced stats generated (" .. #advancedMarkdown .. " chars)")

print("\n=== All Tests Passed ===")
