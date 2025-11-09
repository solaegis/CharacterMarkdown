-- CharacterMarkdown - Section Presence Test Utilities
-- Validates that all expected sections appear in generated markdown output
-- Tests section presence when all settings are enabled

local CM = CharacterMarkdown
CM.tests = CM.tests or {}
CM.tests.sectionPresence = {}

local string_find = string.find
local string_match = string.match
local string_gsub = string.gsub
local string_format = string.format

-- Helper function to check if a setting is enabled (matches Markdown.lua logic)
-- Returns true if setting is true OR nil (default enabled)
-- Returns false if setting is explicitly false
local function IsSettingEnabled(settings, settingName, defaultValue)
    local value = settings[settingName]
    if value == nil then
        return defaultValue  -- Use provided default
    end
    return value == true
end

-- Get default value for a setting
local function GetDefaultSetting(settingName)
    local defaults = CM.Settings and CM.Settings.Defaults and CM.Settings.Defaults:GetAll()
    if defaults and defaults[settingName] ~= nil then
        return defaults[settingName]
    end
    -- Fallback defaults for sections not in defaults
    return true  -- Most sections default to enabled
end

-- Map section names to their setting names (for special cases)
local SECTION_SETTING_MAP = {
    ["Titles & Housing"] = "includeTitlesHousing",
    ["Equipment Enhancement"] = "includeEquipmentEnhancement",
    ["ChampionPoints"] = "includeChampionPoints",
    ["CustomNotes"] = "includeBuildNotes",
    ["DLCAccess"] = "includeDLCAccess",
    ["PvP"] = "includePvP",
    ["PvPStats"] = "includePvPStats",  -- Note: PvPStats is merged into PvP section
}

-- Get setting name for a section
local function GetSettingNameForSection(sectionName)
    -- Check mapping first
    if SECTION_SETTING_MAP[sectionName] then
        return SECTION_SETTING_MAP[sectionName]
    end
    -- Default pattern: "include" + section name (spaces and & removed)
    return "include" .. sectionName:gsub(" ", ""):gsub("&", "")
end

-- =====================================================
-- TEST RESULTS TRACKING
-- =====================================================

local testResults = {
    passed = {},
    failed = {},
    optional = {}  -- Optional sections (e.g., Companion only if active)
}

local function AddResult(sectionName, passed, message, optional)
    if optional then
        table.insert(testResults.optional, {
            section = sectionName,
            message = message or ""
        })
    elseif passed then
        table.insert(testResults.passed, {
            section = sectionName,
            message = message or ""
        })
    else
        table.insert(testResults.failed, {
            section = sectionName,
            message = message or ""
        })
    end
end

local function ResetResults()
    testResults.passed = {}
    testResults.failed = {}
    testResults.optional = {}
end

-- =====================================================
-- SECTION DETECTION PATTERNS
-- =====================================================

-- Define detection patterns for each section
-- Format: { name, patterns = { github = {...}, discord = {...}, fallback = {...} } }
local SECTION_PATTERNS = {
    {
        name = "Header",
        always = true,  -- Always present
        patterns = {
            github = { "^# [^#\n]+", "##.*Character" },
            discord = { "^# [^#\n]+", "**Character" },
            fallback = { "^# " }
        }
    },
    {
        name = "QuickStats",
        formatSpecific = { "github", "vscode" },  -- Not in discord
        patterns = {
            github = { "##.*Quick Stats", "> %[!NOTE%].*Health", "Level.*CP.*Alliance" },
            vscode = { "##.*Quick Stats", "> %[!NOTE%].*Health", "Level.*CP.*Alliance" },
            fallback = { "Quick Stats", "Level.*CP" }
        }
    },
    {
        name = "AttentionNeeded",
        formatSpecific = { "github", "vscode" },  -- Not in discord
        conditional = true,  -- Only appears if there are warnings
        patterns = {
            github = { "##.*⚠️.*Attention", "> %[!WARNING%]", "Attention Needed" },
            vscode = { "##.*⚠️.*Attention", "> %[!WARNING%]", "Attention Needed" },
            fallback = { "Attention Needed", "> %[!WARNING%]" }
        }
    },
    {
        name = "Currency",
        patterns = {
            github = { "##.*💰.*Currency", "Currency & Resources", "Gold.*Amount" },
            discord = { "**Currency:**", "💰.*Gold" },
            fallback = { "Currency", "Gold" }
        }
    },
    {
        name = "RidingSkills",
        patterns = {
            github = { "##.*🐴.*Riding", "Riding Skills", "Speed.*Capacity.*Stamina" },
            discord = { "**Riding:**", "🐴.*Speed" },
            fallback = { "Riding", "Speed" }
        }
    },
    {
        name = "Inventory",
        patterns = {
            github = { "##.*🎒.*Inventory", "Inventory", "Backpack.*%d+/%d+" },
            discord = { "**Inventory:**", "🎒.*Backpack" },
            fallback = { "Inventory", "Backpack" }
        }
    },
    {
        name = "PvP",
        patterns = {
            github = { "##.*⚔️.*PvP", "PvP Stats", "Campaign", "Rank" },
            discord = { "**PvP:**", "⚔️.*Campaign" },
            fallback = { "PvP", "Campaign" }
        }
    },
    {
        name = "Collectibles",
        patterns = {
            github = { "##.*🎨.*Collectibles", "Collectibles", "Collectible" },
            discord = { "**Collectibles:**", "🎨.*Collectible" },
            fallback = { "Collectibles" }
        }
    },
    {
        name = "Crafting",
        patterns = {
            github = { "##.*🔨.*Crafting", "Crafting", "Blacksmithing.*Enchanting" },
            discord = { "**Crafting:**", "🔨.*Blacksmithing" },
            fallback = { "Crafting", "Blacksmithing" }
        }
    },
    {
        name = "Achievements",
        patterns = {
            github = { "##.*🏆.*Achievements", "Achievements", "Achievement Points" },
            discord = { "**Achievements:**", "🏆.*Achievement" },
            fallback = { "Achievements" }
        }
    },
    {
        name = "Quests",
        patterns = {
            github = { "##.*📜.*Quests", "Quests", "Quest.*Progress" },
            discord = { "**Quests:**", "📜.*Quest" },
            fallback = { "Quests" }
        }
    },
    {
        name = "Equipment Enhancement",
        patterns = {
            github = { "##.*⚙️.*Equipment", "Equipment Enhancement", "Enhancement.*Quality" },
            discord = { "**Equipment Enhancement:**", "⚙️.*Enhancement" },
            fallback = { "Equipment Enhancement", "Enhancement" }
        }
    },
    {
        name = "World Progress",
        patterns = {
            github = { "##.*🗺️.*World", "World Progress", "Zone.*Progress" },
            discord = { "**World Progress:**", "🗺️.*World" },
            fallback = { "World Progress", "Zone" }
        }
    },
    {
        name = "Titles & Housing",
        patterns = {
            github = { "##.*🏆.*Titles", "Titles & Housing", "Title.*Housing" },
            discord = { "**Titles & Housing:**", "🏆.*Title" },
            fallback = { "Titles", "Housing" }
        }
    },
    {
        name = "Armory Builds",
        patterns = {
            github = { "##.*🎯.*Armory", "Armory Builds", "Armory" },
            discord = { "**Armory Builds:**", "🎯.*Armory" },
            fallback = { "Armory" }
        }
    },
    {
        name = "Undaunted Pledges",
        patterns = {
            github = { "##.*⚔️.*Undaunted", "Undaunted Pledges", "Pledge" },
            discord = { "**Undaunted Pledges:**", "⚔️.*Undaunted" },
            fallback = { "Undaunted", "Pledge" }
        }
    },
    {
        name = "Guilds",
        patterns = {
            github = { "##.*👥.*Guilds", "Guilds", "Guild.*Membership" },
            discord = { "**Guilds:**", "👥.*Guild" },
            fallback = { "Guilds", "Guild" }
        }
    },
    {
        name = "Attributes",
        patterns = {
            github = { "##.*⚡.*Attributes", "Attributes", "Magicka.*Health.*Stamina" },
            discord = { "**Attributes:**", "⚡.*Magicka" },
            fallback = { "Attributes", "Magicka" }
        }
    },
    {
        name = "Buffs",
        patterns = {
            github = { "##.*✨.*Buffs", "Buffs", "Active.*Buff" },
            discord = { "**Buffs:**", "✨.*Buff" },
            fallback = { "Buffs", "Buff" }
        }
    },
    {
        name = "CustomNotes",
        optional = true,  -- Only if customNotes content exists
        patterns = {
            github = { "##.*📝.*Notes", "Custom Notes", "Build Notes" },
            discord = { "**Custom Notes:**", "📝.*Notes" },
            fallback = { "Custom Notes", "Build Notes" }
        }
    },
    {
        name = "DLCAccess",
        conditional = true,  -- Only appears if ESO Plus is NOT active
        patterns = {
            github = { "##.*🗺️.*DLC", "DLC & Chapter Access", "DLC Access" },
            discord = { "**DLC Access:**", "DLC Access" },
            fallback = { "DLC", "Chapter" }
        }
    },
    {
        name = "Mundus",
        formatSpecific = { "discord" },  -- Discord only
        patterns = {
            discord = { "**Mundus:**", "Mundus" },
            fallback = { "Mundus" }
        }
    },
    {
        name = "ChampionPoints",
        patterns = {
            github = { "##.*⭐.*Champion Points", "Champion Points", "Total.*Spent.*Available" },
            discord = { "**Champion Points:**", "⭐.*Champion" },
            fallback = { "Champion Points", "CP.*Total" }
        }
    },
    {
        name = "Progression",
        patterns = {
            github = { "##.*📈.*Progression", "Progression", "Unspent.*Skill.*Points" },
            discord = { "**Progression:**", "📈.*Progression" },
            fallback = { "Progression", "Unspent" }
        }
    },
    {
        name = "SkillBars",
        patterns = {
            github = { "##.*🎮.*Skill Bars", "Skill Bars", "Bar.*Slot" },
            discord = { "**Skill Bars:**", "🎮.*Skill" },
            fallback = { "Skill Bars", "Bar" }
        }
    },
    {
        name = "SkillMorphs",
        patterns = {
            github = { "##.*🔀.*Skill Morphs", "Skill Morphs", "Morph.*Choice" },
            discord = { "**Skill Morphs:**", "🔀.*Morph" },
            fallback = { "Skill Morphs", "Morph" }
        }
    },
    {
        name = "CombatStats",
        patterns = {
            github = { "##.*📈.*Combat Statistics", "Combat Statistics", "Weapon.*Spell.*Power" },
            discord = { "**Stats:**", "HP.*Mag.*Stam" },
            fallback = { "Combat", "Weapon Power" }
        }
    },
    {
        name = "Equipment",
        patterns = {
            github = { "##.*⚔️.*Equipment", "Equipment", "Head.*Chest.*Shoulders" },
            discord = { "**Equipment:**", "⚔️.*Equipment" },
            fallback = { "Equipment", "Head" }
        }
    },
    {
        name = "Skills",
        patterns = {
            github = { "##.*📜.*Skill Progression", "Skill Progression", "Skill.*Line" },
            discord = { "**Skill Progression:**", "Skill Progression" },
            fallback = { "Skill Progression", "Skills" }
        }
    },
    {
        name = "Companion",
        optional = true,  -- Only if companion is active
        patterns = {
            github = { "##.*👤.*Companion", "Companion", "Companion.*Rapport" },
            discord = { "**Companion:**", "👤.*Companion" },
            fallback = { "Companion", "Rapport" }
        }
    },
    {
        name = "Footer",
        always = true,  -- Always present
        patterns = {
            github = { "Generated by CharacterMarkdown", "Total size", "CharacterMarkdown" },
            discord = { "Generated by CharacterMarkdown", "Total size" },
            fallback = { "CharacterMarkdown", "Generated" }
        }
    }
}

-- =====================================================
-- SECTION DETECTION FUNCTIONS
-- =====================================================

-- Check if a section is present in markdown using its patterns
local function DetectSection(sectionConfig, markdown, format)
    local sectionName = sectionConfig.name
    
    -- Check if section is format-specific
    if sectionConfig.formatSpecific then
        local isFormatSpecific = false
        for _, fmt in ipairs(sectionConfig.formatSpecific) do
            if fmt == format then
                isFormatSpecific = true
                break
            end
        end
        if not isFormatSpecific then
            -- This section shouldn't appear in this format
            return nil, "format-specific"
        end
    end
    
    -- Get patterns for this format
    local patterns = sectionConfig.patterns[format] or sectionConfig.patterns.fallback or {}
    
    -- Try each pattern
    for _, pattern in ipairs(patterns) do
        if string_find(markdown, pattern) then
            return true, "found"
        end
    end
    
    return false, "not found"
end

-- =====================================================
-- MAIN TEST FUNCTION
-- =====================================================

-- Test all sections for presence in markdown
local function ValidateSectionPresence(markdown, format, settings)
    format = format or "github"
    settings = settings or {}
    
    ResetResults()
    
    CM.DebugPrint("SECTION_TESTS", "Starting section presence validation...")
    
    -- Count expected sections
    local expectedCount = 0
    local optionalCount = 0
    
    for _, sectionConfig in ipairs(SECTION_PATTERNS) do
        -- Skip if format-specific and not for this format
        local shouldSkip = false
        if sectionConfig.formatSpecific then
            local isFormatSpecific = false
            for _, fmt in ipairs(sectionConfig.formatSpecific) do
                if fmt == format then
                    isFormatSpecific = true
                    break
                end
            end
            if not isFormatSpecific then
                -- Skip format-specific sections for wrong format
                shouldSkip = true
            end
        end
        
        if not shouldSkip then
            -- Check if section should be enabled based on settings
            local settingName = GetSettingNameForSection(sectionConfig.name)
            local isEnabled = true
            
            -- Special handling for conditional sections
            if sectionConfig.name == "QuickStats" or sectionConfig.name == "AttentionNeeded" then
                -- These are format-specific and check setting
                if format == "github" or format == "vscode" then
                    local defaultValue = GetDefaultSetting(settingName)
                    isEnabled = IsSettingEnabled(settings, settingName, defaultValue)
                else
                    isEnabled = false  -- Not for this format
                end
            elseif sectionConfig.name == "CustomNotes" then
                -- CustomNotes requires both setting AND content
                local defaultValue = GetDefaultSetting("includeBuildNotes")
                isEnabled = IsSettingEnabled(settings, "includeBuildNotes", defaultValue)
            elseif sectionConfig.name == "Companion" then
                -- Companion requires both setting AND active companion
                local defaultValue = GetDefaultSetting("includeCompanion")
                isEnabled = IsSettingEnabled(settings, "includeCompanion", defaultValue)
            elseif not sectionConfig.always then
                -- Check setting for this section with proper default handling
                local defaultValue = GetDefaultSetting(settingName)
                isEnabled = IsSettingEnabled(settings, settingName, defaultValue)
            end
            
            if isEnabled then
                -- Test section presence
                local found, reason = DetectSection(sectionConfig, markdown, format)
                
                if sectionConfig.optional then
                    optionalCount = optionalCount + 1
                    if found then
                        AddResult(sectionConfig.name, true, "Optional section found", true)
                    else
                        AddResult(sectionConfig.name, false, string_format("Optional section not found (%s)", reason), true)
                    end
                elseif sectionConfig.conditional then
                    -- Conditional sections only appear under certain conditions
                    -- Treat as optional (warning, not failure)
                    optionalCount = optionalCount + 1
                    if found then
                        AddResult(sectionConfig.name, true, "Conditional section found", true)
                    else
                        AddResult(sectionConfig.name, false, string_format("Conditional section not found - may not be applicable (%s)", reason), true)
                    end
                elseif sectionConfig.always or isEnabled then
                    expectedCount = expectedCount + 1
                    if found then
                        AddResult(sectionConfig.name, true, "Section found")
                    else
                        AddResult(sectionConfig.name, false, string_format("Section not found (%s)", reason))
                    end
                end
            end
        end
    end
    
    CM.DebugPrint("SECTION_TESTS", string_format("Validation complete: %d expected, %d optional, %d passed, %d failed", 
        expectedCount, optionalCount, #testResults.passed, #testResults.failed))
    
    return {
        passed = testResults.passed,
        failed = testResults.failed,
        optional = testResults.optional,
        total = expectedCount + optionalCount,
        expected = expectedCount,
        optionalCount = optionalCount
    }
end

-- Get test results
local function GetSectionTestResults()
    return {
        passed = testResults.passed,
        failed = testResults.failed,
        optional = testResults.optional,
        total = #testResults.passed + #testResults.failed + #testResults.optional
    }
end

-- Print test report
local function PrintSectionTestReport()
    local results = GetSectionTestResults()
    
    -- Always print to chat (not just debug)
    d("|cFFFF00=== SECTION PRESENCE TEST ===|r")
    
    if #results.passed > 0 then
        d(string_format("|c00FF00✅ PASSED (%d):|r", #results.passed))
        local sectionNames = {}
        for _, test in ipairs(results.passed) do
            table.insert(sectionNames, test.section)
        end
        d(string_format("  %s", table.concat(sectionNames, ", ")))
    end
    
    if #results.failed > 0 then
        d(string_format("|cFF0000❌ MISSING (%d):|r", #results.failed))
        for _, test in ipairs(results.failed) do
            d(string_format("  |cFF0000❌|r |cFFFFFF%s:|r %s", test.section, test.message))
        end
    end
    
    if #results.optional > 0 then
        d(string_format("|cFFAA00⚠️ OPTIONAL (%d):|r", #results.optional))
        for _, test in ipairs(results.optional) do
            local status = test.message:find("found") and "|c00FF00✅|r" or "|cFFAA00⚠️|r"
            d(string_format("  %s |cFFFFFF%s:|r %s", status, test.section, test.message))
        end
    end
    
    local passRate = results.total > 0 and (math.floor((#results.passed / results.total) * 100)) or 0
    local passColor = (#results.failed == 0) and "|c00FF00" or "|cFFAA00"
    d(string_format("%sPass Rate: %d%% (%d/%d sections found)|r", passColor, passRate, #results.passed, results.total))
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.tests.sectionPresence.ValidateSectionPresence = ValidateSectionPresence
CM.tests.sectionPresence.GetSectionTestResults = GetSectionTestResults
CM.tests.sectionPresence.PrintSectionTestReport = PrintSectionTestReport

CM.DebugPrint("SECTION_TESTS", "Section presence test module loaded")

return CM.tests.sectionPresence

