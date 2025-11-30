-- CharacterMarkdown - Command Handler

local CM = CharacterMarkdown

-- =====================================================
-- COMMAND HANDLERS
-- =====================================================

local function DebugSavedVarsState()
    CM.Info("|c00FFFF[CM] ===== SAVEDVARIABLES DEBUG INFO =====|r")
    CM.Info("|c00FFFF[CM] CharacterMarkdownSettings exists: " .. tostring(_G.CharacterMarkdownSettings ~= nil) .. "|r")
    CM.Info("|c00FFFF[CM] CharacterMarkdownData exists: " .. tostring(_G.CharacterMarkdownData ~= nil) .. "|r")
    CM.Info("|c00FFFF[CM] CM.settings exists: " .. tostring(CM.settings ~= nil) .. "|r")
    CM.Info("|c00FFFF[CM] CM.charData exists: " .. tostring(CM.charData ~= nil) .. "|r")
    
    if CM.settings then
        CM.Info("|c00FF00[CM] CM.settings type: " .. type(CM.settings) .. "|r")
    end
    
    if CM.charData then
        CM.Info("|c00FF00[CM] CM.charData type: " .. type(CM.charData) .. "|r")
        CM.Info("|c00FFFF[CM] CM.charData contents:|r")
        for k, v in pairs(CM.charData) do
            CM.Info(string.format("|c00FFFF[CM]   %s = %s (%s)|r", tostring(k), tostring(v), type(v)))
        end
    else
        CM.Error("|cFF0000[CM] ERROR: CM.charData is NIL!|r")
    end
    
    if _G.CharacterMarkdownData then
        CM.Info("|c00FF00[CM] CharacterMarkdownData structure:|r")
        local keyCount = 0
        for k, v in pairs(_G.CharacterMarkdownData) do
            keyCount = keyCount + 1
            CM.Info(string.format("|c00FF00[CM]   [%s] = %s|r", tostring(k), type(v)))
        end
        CM.Info("|c00FF00[CM] Total keys: " .. keyCount .. "|r")
    else
        CM.Error("|cFF0000[CM] ERROR: CharacterMarkdownData is NIL!|r")
    end
    
    CM.Info("|c00FFFF[CM] Character ID: " .. tostring(GetCurrentCharacterId()) .. "|r")
    CM.Info("|c00FFFF[CM] Account: " .. tostring(GetDisplayName()) .. "|r")
    CM.Info("|c00FFFF[CM] =====================================|r")
end

-- Debug handlers
local function HandleDebug(args)
    CM.debug = not CM.debug
    if CM.debug then
        CM.Success("Debug mode ENABLED - debug output will show in chat")
        CM.Info("Run /markdown again to see debug output for quest collection")
    else
        CM.Success("Debug mode DISABLED")
    end
end

local function HandleDebugOn(args)
    CM.debug = true
    CM.Success("Debug mode ENABLED")
end

local function HandleDebugOff(args)
    CM.debug = false
    CM.Success("Debug mode DISABLED")
end

-- Settings handlers
local function HandleSettings(args)
    CM.DebugPrint("COMMANDS", "HandleSettings called")
    
    -- Open settings panel
    if not LibAddonMenu2 then
        CM.Error("Settings panel not available - LibAddonMenu-2.0 is required")
        CM.Info("To install LibAddonMenu-2.0:")
        CM.Info("  Download from: https://www.esoui.com/downloads/info7-LibAddonMenu.html")
        return
    end
    
    -- Use the /markdownsettings command that LAM registered for our panel
    -- This is the most reliable way to open our specific panel
    local lamHandler = SLASH_COMMANDS["/markdown_settings"]
    if lamHandler and type(lamHandler) == "function" then
        -- Call the LAM-registered handler directly
        lamHandler("")
        CM.DebugPrint("COMMANDS", "Opened settings via /markdownsettings LAM handler")
    else
        -- Fallback: Try LibAddonMenu2's OpenToPanel
        local panelId = CM.Settings and CM.Settings.Panel and CM.Settings.Panel.panelId or "CharacterMarkdownPanel"
        if LibAddonMenu2.OpenToPanel then
            LibAddonMenu2:OpenToPanel(panelId)
            CM.DebugPrint("COMMANDS", "Opened settings panel via LAM:OpenToPanel")
        else
            -- Last resort: Open Add-Ons category and show instructions
            SCENE_MANAGER:Show("gameMenuInGame")
            PlaySound(SOUNDS.MENU_SHOW)
            zo_callLater(function()
                local mainMenu = SYSTEMS:GetObject("mainMenu")
                if mainMenu and mainMenu.ShowCategory and MENU_CATEGORY_ADDONS then
                    pcall(function() mainMenu:ShowCategory(MENU_CATEGORY_ADDONS) end)
                end
                CM.Info("Please select 'Character Markdown' from the Add-Ons list")
            end, 100)
        end
    end
end


local function HandleSettingsShow(args)
    DebugSavedVarsState()
end

local function HandleSettingsGet(args)
    if not args or args == "" then
        CM.Error("Usage: /markdown settings get <key>")
        CM.Info("Example: /markdown settings get includeChampionPoints")
        return
    end
    
    local key = args:match("^%s*(%S+)")
    if not key then
        CM.Error("Invalid key")
        return
    end
    
    -- Get defaults to validate key exists
    local defaults = CM.Settings and CM.Settings.Defaults and CM.Settings.Defaults:GetAll() or {}
    if defaults[key] == nil then
        CM.Error("Unknown setting: " .. key)
        CM.Info("Settings must be defined in defaults")
        return
    end
    
    -- Get raw and merged values
    local rawValue = CharacterMarkdownSettings and CharacterMarkdownSettings[key] or nil
    local mergedValue = CM.GetSettings()[key]
    
    CM.Info("Setting: " .. key)
    CM.Info("  Type: " .. type(defaults[key]))
    CM.Info("  Default: " .. tostring(defaults[key]))
    CM.Info("  Raw (SavedVariables): " .. tostring(rawValue))
    CM.Info("  Merged (Current): " .. tostring(mergedValue))
end

local function HandleSettingsSet(args)
    if not args or args == "" then
        CM.Error("Usage: /markdown settings set <key> <value>")
        CM.Info("Example: /markdown settings set includeChampionPoints true")
        return
    end
    
    local key, valueStr = args:match("^%s*(%S+)%s+(.+)$")
    if not key or not valueStr then
        CM.Error("Invalid format. Use: /markdown settings set <key> <value>")
        return
    end
    
    -- Get defaults to validate key and type
    local defaults = CM.Settings and CM.Settings.Defaults and CM.Settings.Defaults:GetAll() or {}
    if defaults[key] == nil then
        CM.Error("Unknown setting: " .. key)
        return
    end
    
    local expectedType = type(defaults[key])
    local value
    
    -- Convert value to correct type
    if expectedType == "boolean" then
        value = (valueStr:lower() == "true" or valueStr:lower() == "1" or valueStr:lower() == "yes")
    elseif expectedType == "number" then
        value = tonumber(valueStr)
        if not value then
            CM.Error("Invalid number: " .. valueStr)
            return
        end
    elseif expectedType == "string" then
        value = valueStr
    else
        CM.Error("Unsupported type: " .. expectedType)
        return
    end
    
    -- Set value
    if not CharacterMarkdownSettings then
        CM.Error("Settings not available")
        return
    end
    
    CharacterMarkdownSettings[key] = value
    CharacterMarkdownSettings._lastModified = GetTimeStamp()
    CM.InvalidateSettingsCache()
    
    CM.Success("Setting updated: " .. key .. " = " .. tostring(value))
end

local function HandleSettingsReset(args)
    if not CharacterMarkdownSettings then
        CM.Error("Settings not available")
        return
    end
    
    local defaults = CM.Settings and CM.Settings.Defaults and CM.Settings.Defaults:GetAll() or {}
    local count = 0
    
    -- CRITICAL: Preserve only text fields (customNotes, customTitle, playStyle) for current character
    -- These are user-entered data that must NEVER be reset
    local characterId = tostring(GetCurrentCharacterId())
    local preservedTextFields = nil
    if CharacterMarkdownSettings.perCharacterData and CharacterMarkdownSettings.perCharacterData[characterId] then
        preservedTextFields = {
            customNotes = CharacterMarkdownSettings.perCharacterData[characterId].customNotes,
            customTitle = CharacterMarkdownSettings.perCharacterData[characterId].customTitle,
            playStyle = CharacterMarkdownSettings.perCharacterData[characterId].playStyle,
        }
    end
    
    -- Reset all settings to defaults (preserve internal metadata and per-character data)
    for key, defaultValue in pairs(defaults) do
        -- Skip internal metadata (starts with _) and per-character data
        -- perCharacterData is NOT a setting with a default - it's a data structure that accumulates
        if key:sub(1, 1) ~= "_" and key ~= "perCharacterData" then
            CharacterMarkdownSettings[key] = defaultValue
            count = count + 1
        end
    end
    
    -- Restore only the text fields for current character (preserve customNotes, customTitle, playStyle)
    if preservedTextFields then
        -- Ensure perCharacterData structure exists
        if not CharacterMarkdownSettings.perCharacterData then
            CharacterMarkdownSettings.perCharacterData = {}
        end
        if not CharacterMarkdownSettings.perCharacterData[characterId] then
            CharacterMarkdownSettings.perCharacterData[characterId] = {}
        end
        -- Restore only the text fields
        CharacterMarkdownSettings.perCharacterData[characterId].customNotes = preservedTextFields.customNotes
        CharacterMarkdownSettings.perCharacterData[characterId].customTitle = preservedTextFields.customTitle
        CharacterMarkdownSettings.perCharacterData[characterId].playStyle = preservedTextFields.playStyle
    end
    
    CharacterMarkdownSettings._lastModified = GetTimeStamp()
    CM.InvalidateSettingsCache()
    
    CM.Success("Reset " .. count .. " settings to defaults (text fields preserved)")
end

local function HandleSettingsEnableAll(args)
    if not CharacterMarkdownSettings then
        CM.Error("Settings not available")
        return
    end
    
    local defaults = CM.Settings and CM.Settings.Defaults and CM.Settings.Defaults:GetAll() or {}
    local count = 0
    
    -- Enable all boolean settings
    for key, defaultValue in pairs(defaults) do
        if type(defaultValue) == "boolean" and key:sub(1, 1) ~= "_" then
            CharacterMarkdownSettings[key] = true
            count = count + 1
        end
    end
    
    CharacterMarkdownSettings._lastModified = GetTimeStamp()
    CM.InvalidateSettingsCache()
    
    CM.Success("Enabled " .. count .. " boolean settings")
end

-- Test handlers
local function HandleTest(args)
    CM.Info("=== CharacterMarkdown Diagnostic & Validation ===")
    CM.Info(" ")

    -- ================================================
    -- PHASE 1: SETTINGS DIAGNOSTIC
    -- ================================================
    CM.Info("|cFFD700[1/4] Settings Diagnostic|r")
    CM.Info(" ")

    if not CharacterMarkdownSettings then
        CM.Error("CharacterMarkdownSettings is NIL!")
        CM.Info("  This means your settings aren't being saved")
        CM.Info("  Try: /reloadui")
        return
    end
    CM.Success("✓ CharacterMarkdownSettings exists")

    if not CM.GetSettings then
        CM.Error("✗ CM.GetSettings() not available")
        return
    end
    CM.Success("✓ CM.GetSettings() available")

    local criticalSettings = {
        "includeChampionPoints",
        "includeChampionDiagram",
        "includeSkillBars",
        "includeSkills",
        "includeEquipment",
        "includeCompanion",
        "includeCurrency",
        "includeInventory",
        "includeCollectibles",
        "includeQuickStats",
        "includeTableOfContents",
    }

    CM.Info(" ")
    CM.Info("Critical Setting Values:")
    local merged = CM.GetSettings()
    local hasMismatch = false

    for _, setting in ipairs(criticalSettings) do
        local raw = CharacterMarkdownSettings[setting]
        local merged_val = merged[setting]

        if raw ~= merged_val then
            CM.Info(
                string.format(
                    "  |cFFFF00⚠ %s = %s (raw) vs %s (merged)|r",
                    setting,
                    tostring(raw),
                    tostring(merged_val)
                )
            )
            hasMismatch = true
        else
            local color = raw == true and "|c00FF00" or "|cFF0000"
            CM.Info(string.format("  %s%s = %s|r", color, setting, tostring(raw)))
        end
    end

    if hasMismatch then
        CM.Info(" ")
        CM.DebugPrint("TEST", "⚠ Settings merge has mismatches - this may cause issues")
        CM.Warn("|cFFAA00⚠ Settings merge has mismatches - this may cause issues|r")
    else
        CM.Info(" ")
        CM.Success("✓ Settings merge working correctly")
    end

    -- ================================================
    -- PHASE 2: DATA COLLECTION TEST
    -- ================================================
    CM.Info(" ")
    CM.Info("|cFFD700[2/4] Data Collection Test|r")

    if CM.collectors and CM.collectors.CollectChampionPointData then
        local success, cpData = pcall(CM.collectors.CollectChampionPointData)
        if success and cpData then
            CM.Success("✓ Champion Points data collected")
            CM.Info(
                string.format(
                    "  Total: %d | Spent: %d | Available: %d",
                    cpData.total or 0,
                    cpData.spent or 0,
                    (cpData.total or 0) - (cpData.spent or 0)
                )
            )

            if cpData.disciplines and #cpData.disciplines > 0 then
                CM.Info(string.format("  Disciplines: %d", #cpData.disciplines))
                for _, disc in ipairs(cpData.disciplines) do
                    local skillCount = 0
                    if disc.allStars then
                        skillCount = #disc.allStars
                    elseif disc.slottableSkills and disc.passiveSkills then
                        skillCount = #disc.slottableSkills + #disc.passiveSkills
                    end
                    CM.Info(
                        string.format(
                            "    %s: %d CP, %d skills",
                            disc.name or "Unknown",
                            disc.total or 0,
                            skillCount
                        )
                    )
                end
            else
                CM.Warn("  ⚠ No disciplines data")
            end
        else
            CM.Error("✗ Failed to collect CP data: " .. tostring(cpData))
        end
    else
        CM.Error("✗ CollectChampionPointData not available")
    end

    -- ================================================
    -- PHASE 3: MARKDOWN GENERATION TEST
    -- ================================================
    CM.Info(" ")
    CM.Info("|cFFD700[3/4] Markdown Generation Test|r")

    if not CM.tests or not CM.tests.validation then
        CM.Error("✗ Test validation module not loaded")
        return
    end

    local testFormatter = CM.currentFormatter or "markdown"
    CM.Info(string.format("Generating %s formatter with current settings...", testFormatter))

    local success, markdown = pcall(function()
        if testFormatter == "tonl" then
            return CM.formatters.GenerateTONL()
        else
            return CM.formatters.GenerateMarkdown()
        end
    end)

    if not success or not markdown then
        CM.Error("✗ Failed to generate markdown: " .. tostring(markdown))
        return
    end

    local isChunksArray = type(markdown) == "table"
    local markdownString = markdown
    if isChunksArray then
        CM.Info(string.format("  Generated %d chunks", #markdown))
        local fullMarkdown = ""
        for _, chunk in ipairs(markdown) do
            fullMarkdown = fullMarkdown .. chunk.content
        end
        markdownString = fullMarkdown
    end

    CM.Info(string.format("  Total size: %d chars", #markdownString))

    local testSettings = {}
    if CharacterMarkdownSettings then
        for key, value in pairs(CharacterMarkdownSettings) do
            if type(value) ~= "function" and key:sub(1, 1) ~= "_" then
                testSettings[key] = value
            end
        end
    end

    -- ================================================
    -- PHASE 4: VALIDATION TESTS
    -- ================================================
    CM.Info(" ")
    CM.Info("|cFFD700[4/4] Validation Tests|r")

    local validationResults = CM.tests.validation.ValidateMarkdown(markdownString, testFormatter)

    local sectionResults = nil
    if CM.tests and CM.tests.sectionPresence then
        sectionResults = CM.tests.sectionPresence.ValidateSectionPresence(markdownString, testFormatter, testSettings)
    end

    CM.tests.validation.PrintTestReport()

    -- ================================================
    -- PHASE 5: UNIT TESTS
    -- ================================================
    CM.Info(" ")
    CM.Info("|cFFD700[5/5] Unit Tests|r")
    
    if CM.tests.chunking then
        CM.tests.chunking.RunTests()
    else
        CM.Warn("Chunking tests not available")
    end

    if sectionResults and CM.tests.sectionPresence then
        CM.tests.sectionPresence.PrintSectionTestReport()
    end

    CM.Info(" ")
    CM.Info("=== Test Summary ===")

    local totalFailed = #validationResults.failed
    local totalWarnings = #validationResults.warnings
    if sectionResults then
        totalFailed = totalFailed + #sectionResults.failed
    end

    if totalFailed == 0 and totalWarnings == 0 then
        CM.Success(
            string.format(
                "✓ ALL TESTS PASSED! (%d validation, %d sections)",
                #validationResults.passed,
                sectionResults and #sectionResults.passed or 0
            )
        )
    elseif totalFailed == 0 then
        CM.Warn(string.format("⚠ Tests passed with %d warnings", totalWarnings))
    else
        CM.Error(
            string.format(
                "✗ TESTS FAILED: %d passed, %d failed, %d warnings",
                #validationResults.passed,
                totalFailed,
                totalWarnings
            )
        )
    end
    CM.Info("Tip: Run '/markdown' to see the actual generated output")
end

local function HandleTestLayout(args)
    CM.Info("=== Layout Calculator Test Suite ===")
    CM.Info(" ")
    
    local LayoutCalculatorTests = CM.utils and CM.utils.LayoutCalculatorTests
    if LayoutCalculatorTests and LayoutCalculatorTests.RunAllTests then
        local success = LayoutCalculatorTests.RunAllTests()
        if success then
            CM.Success("All layout calculator tests passed!")
        else
            CM.DebugPrint("TEST", "Some layout calculator tests failed - see output above")
            CM.Warn("|cFFAA00⚠ Some layout calculator tests failed - see output above|r")
        end
    else
        CM.Error("LayoutCalculatorTests not loaded!")
        CM.Info("  Make sure the addon is fully initialized")
    end
end

-- =====================================================
-- STAT SCANNER (DEBUG UTILITY)
-- =====================================================

local function HandleScanStats(args)
    CM.Info("|cFFD700=== STAT Scanner ===|r")
    CM.Info("Scanning STAT_ IDs 1-200 for non-zero values...")
    CM.Info("This may take a moment...")
    CM.Info(" ")
    
    local foundStats = {}
    local totalFound = 0
    
    -- Scan range - try without bonus option first
    for i = 1, 200 do
        local value = GetPlayerStat(i)
        if value and value > 0 then
            totalFound = totalFound + 1
            table.insert(foundStats, {id = i, value = value})
        end
    end
    
    -- Display results
    if totalFound == 0 then
        CM.Warn("No non-zero stats found in range 1-200")
    else
        CM.Success(string.format("Found %d non-zero stats:", totalFound))
        CM.Info(" ")
        CM.Info("|cFFFFFFID  | Value|r")
        CM.Info("|cFFFFFF----|------|r")
        
        for _, stat in ipairs(foundStats) do
            CM.Info(string.format("|cFFFFFF%-4d| %s|r", stat.id, CM.utils.FormatNumber(stat.value)))
        end
        
        CM.Info(" ")
        CM.Info("|cFFD700Compare these IDs to your screenshot values:|r")
        CM.Info("  Bash Cost: 696")
        CM.Info("  Block Cost: 1757")
        CM.Info("  Break Free Cost: 4590")
        CM.Info("  Dodge Roll Cost: 3802")
        CM.Info("  Sneak Cost: 119")
        CM.Info("  Sprint Cost: 475")
        CM.Info(" ")
        CM.Info("Once you find matching IDs, let me know!")
    end
end

local function HandleTestConstants(args)
    CM.Info("|cFFD700=== Testing Core Ability Costs ===|r")
    CM.Info("Trying GetAbilityCost() with common ability IDs...")
    CM.Info(" ")
    
    -- Expanded list of ability IDs to test for Sneak/Sprint
    local abilitiesToTest = {
        {name = "Bash (21970)", id = 21970},
        {name = "Break Free (16565)", id = 16565},
        {name = "Dodge Roll (28549)", id = 28549},
        {name = "Sprint (15000)", id = 15000},
        {name = "Sprint (973)", id = 973},
        {name = "Sprint (1000)", id = 1000},
        {name = "Sneak (20299)", id = 20299},
        {name = "Sneak (20000)", id = 20000},
        {name = "Sneak (19999)", id = 19999},
    }
    
    for _, ability in ipairs(abilitiesToTest) do
        local cost = GetAbilityCost(ability.id, COMBAT_MECHANIC_FLAGS_STAMINA)
        if cost and cost > 0 then
            CM.Info(string.format("|cFFFFFF%s: %d|r", ability.name, cost))
        else
            CM.Warn(string.format("%s: No cost found", ability.name))
        end
    end
    
    CM.Info(" ")
    CM.Info("|cFFD700=== Testing Damage/Crit Bonus Stats ===|r")
    
    -- Test various stat IDs that might be damage bonuses
    -- Based on scan, we saw IDs like 49=100, 50=200 which might be percentages
    local bonusStatsToTest = {
        {name = "ID 48", id = 48},
        {name = "ID 49", id = 49},
        {name = "ID 50", id = 50},
        {name = "ID 78 (Crit Damage?)", id = 78},
        {name = "ID 79", id = 79},
        {name = "ID 80", id = 80},
    }
    
    for _, stat in ipairs(bonusStatsToTest) do
        local value = GetPlayerStat(stat.id)
        if value and value > 0 then
            -- Try to interpret as percentage
            local asPercent = value / 100
            CM.Info(string.format("|cFFFFFF%s: %d (%.1f%%)|r", stat.name, value, asPercent))
        else
            CM.Warn(string.format("%s: 0 or nil", stat.name))
        end
    end
    
    CM.Info(" ")
    CM.Info("|cFFD700=== Done ===|r")
end

local function HandleFindNames(args)
    CM.Info("|cFFD700=== Testing GetAdvancedStatValue (Corrected) ===|r")
    
    local advancedStats = {
        {name = "Sneak Cost", id = ADVANCED_STAT_DISPLAY_TYPE_SNEAK_COST},
        {name = "Sprint Cost", id = ADVANCED_STAT_DISPLAY_TYPE_SPRINT_COST},
        {name = "Crit Damage", id = ADVANCED_STAT_DISPLAY_TYPE_CRITICAL_DAMAGE},
        {name = "Physical Bonus", id = ADVANCED_STAT_DISPLAY_TYPE_PHYSICAL_DAMAGE}, -- Verify this exists
        {name = "Flame Bonus", id = ADVANCED_STAT_DISPLAY_TYPE_FIRE_DAMAGE},
        {name = "Shock Bonus", id = ADVANCED_STAT_DISPLAY_TYPE_SHOCK_DAMAGE}, -- Verify this exists
        {name = "Magic Bonus", id = ADVANCED_STAT_DISPLAY_TYPE_MAGIC_DAMAGE},
        {name = "Disease Bonus", id = ADVANCED_STAT_DISPLAY_TYPE_DISEASE_DAMAGE},
        {name = "Poison Bonus", id = ADVANCED_STAT_DISPLAY_TYPE_POISON_DAMAGE},
        {name = "Bleed Bonus", id = ADVANCED_STAT_DISPLAY_TYPE_BLEED_DAMAGE},
    }
    
    for _, stat in ipairs(advancedStats) do
        if stat.id then
            -- API returns: displayFormat, flatValue, percentValue
            local format, flat, pct = GetAdvancedStatValue(stat.id)
            flat = flat or 0
            pct = pct or 0
            CM.Info(string.format("%s: Flat=%d, Pct=%.1f%% (Format: %d)", stat.name, flat, pct, format or -1))
        else
            CM.Info(string.format("%s: Constant NIL", stat.name))
        end
    end
end

-- =====================================================
-- CACHE COMMANDS
-- =====================================================

local function HandleCacheClear(args)
    local cleared = {}
    local count = 0
    
    -- Clear all API module caches
    if CM.api and CM.api.skills and CM.api.skills.ClearCache then
        CM.api.skills.ClearCache()
        table.insert(cleared, "Skills")
        count = count + 1
    end
    
    if CM.api and CM.api.collectibles and CM.api.collectibles.ClearCache then
        CM.api.collectibles.ClearCache()
        table.insert(cleared, "Collectibles")
        count = count + 1
    end
    
    if CM.api and CM.api.titles and CM.api.titles.ClearCache then
        CM.api.titles.ClearCache()
        table.insert(cleared, "Titles")
        count = count + 1
    end
    
    if CM.api and CM.api.antiquities and CM.api.antiquities.ClearCache then
        CM.api.antiquities.ClearCache()
        table.insert(cleared, "Antiquities")
        count = count + 1
    end
    
    if count > 0 then
        CM.Success("Cleared " .. count .. " cache(s): " .. table.concat(cleared, ", "))
    else
        CM.Info("No caches available to clear")
    end
end

-- =====================================================
-- MAIN GENERATION LOGIC
-- =====================================================

local function GenerateOutput(formatter)
    if not CM.isInitialized then
        CM.Error("Addon not fully initialized. Try again in a moment or /reloadui")
        return
    end

    CM.currentFormatter = formatter
    if CharacterMarkdownSettings then
        CharacterMarkdownSettings.currentFormatter = formatter
        CharacterMarkdownSettings._lastModified = GetTimeStamp()
        CM.InvalidateSettingsCache()
    end

    CM.DebugPrint("COMMAND", "Generating " .. formatter .. " output...")

    -- TONL formatter
    if formatter == "tonl" then
        if not CM.formatters or not CM.formatters.GenerateTONL then
            CM.Error("TONL formatter not loaded!")
            CM.Error("Try /reloadui to restart the addon")
            return
        end

        local success, tonlOutput = pcall(function()
            return CM.formatters.GenerateTONL()
        end)

        if not success then
            CM.Error("Failed to generate TONL:")
            CM.Error(tostring(tonlOutput))
            return
        end

        if not tonlOutput or tonlOutput == "" then
            CM.Error("Generated TONL is empty or nil")
            return
        end

        local tonlSize = string.len(tonlOutput)
        CM.DebugPrint("COMMAND", string.format("TONL generated: %d chars", tonlSize))

        if CharacterMarkdown_ShowWindow then
            CM.DebugPrint("COMMAND", "Opening display window...")
            CharacterMarkdown_ShowWindow(tonlOutput, formatter)
        else
            CM.Warn("Window display not available")
            CM.Info("TONL copied to clipboard")
        end
        return
    end

    -- Markdown formatter
    if formatter == "markdown" then
        if not CM.generators or not CM.generators.GenerateMarkdown then
            CM.Error("Markdown generator not loaded!")
            CM.Error("Try /reloadui to restart the addon")
            return
        end

        local success, markdown = pcall(function()
            return CM.generators.GenerateMarkdown()
        end)

        if not success then
            CM.Error("Failed to generate markdown:")
            CM.Error(tostring(markdown))
            return
        end

        if not markdown then
            CM.Error("Generated markdown is nil")
            return
        end

        local isChunksArray = type(markdown) == "table"
        local markdownSize = 0

        if isChunksArray then
            if #markdown == 0 then
                CM.Error("Generated markdown chunks array is empty")
                return
            end
            for _, chunk in ipairs(markdown) do
                markdownSize = markdownSize + string.len(chunk.content)
            end
            CM.DebugPrint(
                "COMMAND",
                string.format(
                    "Markdown generated: %d chars in %d chunk%s",
                    markdownSize,
                    #markdown,
                    #markdown == 1 and "" or "s"
                )
            )
        else
            if markdown == "" then
                CM.Error("Generated markdown is empty")
                return
            end
            markdownSize = string.len(markdown)
            CM.DebugPrint("COMMAND", string.format("Markdown generated: %d chars", markdownSize))
        end

        if CM.debug and CM.tests and CM.tests.validation then
            zo_callLater(function()
                local validationMarkdown = markdown
                if isChunksArray then
                    validationMarkdown = ""
                    for _, chunk in ipairs(markdown) do
                        validationMarkdown = validationMarkdown .. chunk.content
                    end
                end
                local results = CM.tests.validation.ValidateMarkdown(validationMarkdown, formatter)
                if #results.failed > 0 then
                    CM.DebugPrint("TESTS", string.format("⚠️ %d validation test(s) failed", #results.failed))
                end
            end, 100)
        end

        if CharacterMarkdown_ShowWindow then
            CM.DebugPrint("COMMAND", "Opening display window...")
            CharacterMarkdown_ShowWindow(markdown, formatter)
        else
            CM.Warn("Window display not available")
            CM.Info("Markdown copied to clipboard")
        end
        return
    end
end

-- =====================================================
-- COMMAND REGISTRATION
-- =====================================================

local function InitializeCommands()
    -- Check for LibSlashCommander
    if LibSlashCommander then
        CM.Info("Using LibSlashCommander for enhanced command handling")
        
        -- Main Command: /markdown (and /cm)
        local cmd = LibSlashCommander:Register({"/markdown", "/cm"}, function(args)
            -- Default action: Generate with current formatter
            local formatter = CM.currentFormatter or "markdown"
            GenerateOutput(formatter)
        end, "Character Markdown")
        
        -- Subcommand: settings
        local settingsCmd = cmd:RegisterSubCommand()
        settingsCmd:AddAlias("settings")
        settingsCmd:AddAlias("s")
        settingsCmd:SetCallback(function(args)
            -- If no args, open settings
            if not args or args == "" then
                HandleSettings()
            else
                -- Route to specific settings subcommands manually or register them deeper?
                -- LibSlashCommander supports nested subcommands.
                -- For now, let's keep it simple and route manually if needed, 
                -- BUT LibSlashCommander is best used with nested structure.
                
                -- Let's register nested subcommands for settings
                -- Note: We can't easily mix "callback with args" and "nested subcommands" on the same node 
                -- if we want auto-completion for the nested ones.
                -- However, LibSlashCommander allows a callback AND subcommands.
                
                -- Actually, the best way is to register subcommands for 'show', 'get', etc.
                -- But since we already have the handler functions that parse args, 
                -- we might just want to delegate.
                -- BUT to get auto-completion, we should register them.
                
                -- Let's try to parse the first arg and route, or fallback to HandleSettings
                local firstArg = args:match("^(%S+)")
                if firstArg then
                    -- If it matches a known subcommand, it should have been routed by LibSlashCommander 
                    -- IF we registered it.
                    -- If we are here, it means it didn't match a registered subcommand (or we haven't registered them yet).
                    
                    -- For 'settings', let's just use the manual handler for simplicity 
                    -- as 'get'/'set' take dynamic args.
                    if firstArg == "show" then HandleSettingsShow() 
                    elseif firstArg == "get" then HandleSettingsGet(args:sub(5))
                    elseif firstArg == "set" then HandleSettingsSet(args:sub(5))
                    elseif firstArg == "reset" then HandleSettingsReset()
                    elseif firstArg == "enable-all" then HandleSettingsEnableAll()
                    else HandleSettings() end
                else
                    HandleSettings()
                end
            end
        end)
        settingsCmd:SetDescription("Open settings or manage configuration")
        settingsCmd:SetAutoComplete({
            "show", "get", "set", "reset", "enable-all"
        })
        
        -- Subcommand: debug
        local debugCmd = cmd:RegisterSubCommand()
        debugCmd:AddAlias("debug")
        debugCmd:SetCallback(function(args)
            if args == "on" then HandleDebugOn()
            elseif args == "off" then HandleDebugOff()
            else HandleDebug() end
        end)
        debugCmd:SetDescription("Toggle debug mode")
        debugCmd:SetAutoComplete({"on", "off"})
        
        -- Subcommand: tonl
        local tonlCmd = cmd:RegisterSubCommand()
        tonlCmd:AddAlias("tonl")
        tonlCmd:SetCallback(function() GenerateOutput("tonl") end)
        tonlCmd:SetDescription("Generate TONL output")
        
        -- Subcommand: markdown
        local mdCmd = cmd:RegisterSubCommand()
        mdCmd:AddAlias("markdown")
        mdCmd:SetCallback(function() GenerateOutput("markdown") end)
        mdCmd:SetDescription("Generate Markdown output")
        
        -- Subcommand: test
        local testCmd = cmd:RegisterSubCommand()
        testCmd:AddAlias("test")
        testCmd:SetCallback(function(args)
            if args == "layout" then HandleTestLayout()
            elseif args == "constants" then HandleTestConstants()
            else HandleTest() end
        end)
        testCmd:SetDescription("Run diagnostic tests")
        testCmd:SetAutoComplete({"layout", "constants"})
        
        -- Subcommand: scan
        local scanCmd = cmd:RegisterSubCommand()
        scanCmd:AddAlias("scan")
        scanCmd:SetCallback(function(args)
            if args == "stats" then HandleScanStats() end
        end)
        scanCmd:SetDescription("Scan stats (debug)")
        scanCmd:SetAutoComplete({"stats"})
        
        -- Subcommand: cache
        local cacheCmd = cmd:RegisterSubCommand()
        cacheCmd:AddAlias("cache")
        cacheCmd:SetCallback(function(args)
            if args == "clear" then HandleCacheClear() end
        end)
        cacheCmd:SetDescription("Manage cache")
        cacheCmd:SetAutoComplete({"clear"})
        
        -- Subcommand: find
        local findCmd = cmd:RegisterSubCommand()
        findCmd:AddAlias("find")
        findCmd:SetCallback(function(args)
            if args == "names" then HandleFindNames() end
        end)
        findCmd:SetDescription("Find IDs (debug)")
        findCmd:SetAutoComplete({"names"})
        
        -- Register global aliases for backward compatibility
        -- /tonl
        LibSlashCommander:Register("/tonl", function() GenerateOutput("tonl") end, "Generate TONL output")
        
    else
        -- Fallback: Manual parsing
        CM.Info("LibSlashCommander not found - using basic command handling")
        
        local function ManualHandler(args)
            args = args or ""
            local command, rest = args:match("^(%S+)(.*)")
            command = command and command:lower() or ""
            rest = rest and rest:match("^%s*(.*)") or ""
            
            if command == "" then
                local formatter = CM.currentFormatter or "markdown"
                GenerateOutput(formatter)
            elseif command == "settings" or command == "s" then
                if rest:match("^show") then HandleSettingsShow()
                elseif rest:match("^get") then HandleSettingsGet(rest)
                elseif rest:match("^set") then HandleSettingsSet(rest)
                elseif rest:match("^reset") then HandleSettingsReset()
                elseif rest:match("^enable%-all") then HandleSettingsEnableAll()
                else HandleSettings() end
            elseif command == "debug" then
                if rest == "on" then HandleDebugOn()
                elseif rest == "off" then HandleDebugOff()
                else HandleDebug() end
            elseif command == "tonl" then
                GenerateOutput("tonl")
            elseif command == "markdown" then
                GenerateOutput("markdown")
            elseif command == "test" then
                if rest == "layout" then HandleTestLayout()
                elseif rest == "constants" then HandleTestConstants()
                else HandleTest() end
            elseif command == "scan" and rest == "stats" then
                HandleScanStats()
            elseif command == "cache" and rest == "clear" then
                HandleCacheClear()
            elseif command == "find" and rest == "names" then
                HandleFindNames()
            elseif command == "help" then
                CM.Info("/markdown - Generate profile")
                CM.Info("/markdown settings - Open settings")
                CM.Info("/markdown debug - Toggle debug")
                CM.Info("/markdown tonl - Generate TONL")
                CM.Info("/markdown test - Run tests")
            else
                CM.Error("Unknown command: " .. command)
                CM.Info("Type /markdown help for commands")
            end
        end
        
        SLASH_COMMANDS["/markdown"] = ManualHandler
        SLASH_COMMANDS["/cm"] = ManualHandler
        SLASH_COMMANDS["/tonl"] = function() GenerateOutput("tonl") end
    end
end

-- Initialize
InitializeCommands()

-- Export for external use if needed
CM.commands.CommandHandler = function(args)
    -- This is a bit tricky with LibSlashCommander as it takes over.
    -- But we can just expose the GenerateOutput for programmatic use.
    local formatter = CM.currentFormatter or "markdown"
    GenerateOutput(formatter)
end
CM.commands.GenerateOutput = GenerateOutput

CM.DebugPrint("COMMANDS", "Command module loaded")
