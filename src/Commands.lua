-- CharacterMarkdown - Command Handler

local CM = CharacterMarkdown

-- =====================================================
-- SHORTEST UNIQUE SHORTCUT CALCULATION
-- =====================================================

-- Calculate shortest unique prefix for a list of strings
-- If any command needs more than 1 character due to conflicts,
-- ALL commands use the same minimum length for consistency
local function FindShortestUniquePrefixes(strings)
    local prefixes = {}
    local sorted = {}
    
    -- Create sorted copy
    for i, str in ipairs(strings) do
        table.insert(sorted, str)
    end
    table.sort(sorted)
    
    -- First pass: find minimum length needed for each string
    local minLengths = {}
    local globalMinLen = 1
    
    for i, str in ipairs(sorted) do
        local minLen = 1
        local found = false
        
        while not found and minLen <= #str do
            local prefix = str:sub(1, minLen)
            local unique = true
            
            -- Check if this prefix is unique among all strings
            for j, otherStr in ipairs(sorted) do
                if i ~= j and otherStr:sub(1, minLen) == prefix then
                    unique = false
                    break
                end
            end
            
            if unique then
                minLengths[str] = minLen
                -- Update global minimum if this needs more characters
                if minLen > globalMinLen then
                    globalMinLen = minLen
                end
                found = true
            else
                minLen = minLen + 1
            end
        end
        
        -- If no unique prefix found, use full string length
        if not found then
            minLengths[str] = #str
            if #str > globalMinLen then
                globalMinLen = #str
            end
        end
    end
    
    -- Second pass: ensure all commands use at least globalMinLen characters
    for i, str in ipairs(sorted) do
        local requiredLen = math.max(minLengths[str], globalMinLen)
        if requiredLen <= #str then
            prefixes[str] = str:sub(1, requiredLen)
        else
            prefixes[str] = str
        end
    end
    
    return prefixes
end

-- =====================================================
-- COMMAND PARSING
-- =====================================================

-- Parse subcommand pattern: object:action or object
local function ParseSubcommand(args)
    if not args or args == "" then
        return nil, nil, ""
    end
    
    local trimmed = args:lower():match("^%s*(.-)%s*$")
    
    -- Check for object:action pattern
    local object, action = trimmed:match("^(%S+):(%S+)$")
    if object and action then
        local remaining = trimmed:match("^%S+:%S+%s+(.*)$") or ""
        return object, action, remaining
    end
    
    -- Check for object only (no colon)
    local objectOnly = trimmed:match("^(%S+)")
    if objectOnly then
        local remaining = trimmed:match("^%S+%s+(.*)$") or ""
        return objectOnly, nil, remaining
    end
    
    return nil, nil, ""
end

-- Match command with shortest unique prefix support
local function MatchCommand(input, fullCommand, shortcuts)
    if not input or not fullCommand then
        return false
    end
    
    -- Exact match
    if input == fullCommand then
        return true
    end
    
    -- Shortcut match
    if shortcuts and shortcuts[fullCommand] then
        local shortcut = shortcuts[fullCommand]
        if input == shortcut then
            return true
        end
    end
    
    -- Prefix match (for backward compatibility)
    if fullCommand:sub(1, #input) == input then
        return true
    end
    
    return false
end

-- =====================================================
-- FORMAT COMMANDS
-- =====================================================

local formatCommands = {
    "format:github",
    "format:vscode",
    "format:discord",
    "format:quick",
}

local formatShortcuts = FindShortestUniquePrefixes(formatCommands)
local formatMap = {
    ["format:github"] = "github",
    ["format:vscode"] = "vscode",
    ["format:discord"] = "discord",
    ["format:quick"] = "quick",
}

-- Parse format command
local function ParseFormatCommand(args)
    if not args or args == "" then
        return nil -- No format specified, use current
    end
    
    local object, action = ParseSubcommand(args)
    
    -- Check if it's a format command
    if object then
        -- Check if object matches "format" with shortest unique prefix
        local formatObjects = {"format"}
        local formatObjectShortcuts = FindShortestUniquePrefixes(formatObjects)
        
        if MatchCommand(object, "format", formatObjectShortcuts) then
            -- It's a format command, find the format
            if action then
                -- Build the full command string to match
                local inputCmd = "format:" .. action
                
                -- Match against full commands using shortcuts
                for fullCmd, format in pairs(formatMap) do
                    if MatchCommand(inputCmd, fullCmd, formatShortcuts) then
                        return format
                    end
                end
            end
        end
    end
    
    return nil
end

-- =====================================================
-- SUBCOMMAND ROUTING
-- =====================================================

local subcommandHandlers = {}

-- Register a subcommand handler
local function RegisterSubcommand(object, action, handler, description)
    if not subcommandHandlers[object] then
        subcommandHandlers[object] = {}
    end
    subcommandHandlers[object][action or ""] = {
        handler = handler,
        description = description,
    }
end

-- Route subcommand to appropriate handler
local function RouteSubcommand(object, action, remainingArgs)
    if not object then
        return false
    end
    
    -- Calculate object shortcuts
    local objects = {}
    for obj, _ in pairs(subcommandHandlers) do
        table.insert(objects, obj)
    end
    local objectShortcuts = FindShortestUniquePrefixes(objects)
    
    -- Try to find object by shortest unique prefix
    local foundObject = nil
    for obj, _ in pairs(subcommandHandlers) do
        if MatchCommand(object, obj, objectShortcuts) then
            foundObject = obj
            break
        end
    end
    
    if not foundObject then
        return false
    end
    
    local objectHandlers = subcommandHandlers[foundObject]
    if not objectHandlers then
        return false
    end
    
    -- Try exact action match first
    local handler = objectHandlers[action or ""]
    if handler and handler.handler then
        handler.handler(remainingArgs)
        return true
    end
    
    -- Try to find by shortest unique prefix
    if action then
        local actions = {}
        for act, _ in pairs(objectHandlers) do
            if act ~= "" then
                table.insert(actions, act)
            end
        end
        local actionShortcuts = FindShortestUniquePrefixes(actions)
        
        for act, handlerData in pairs(objectHandlers) do
            if MatchCommand(action, act, actionShortcuts) then
                handlerData.handler(remainingArgs)
                return true
            end
        end
    end
    
    return false
end

-- =====================================================
-- HELP OUTPUT
-- =====================================================

local function ShowHelp()
    CM.Info("=== CharacterMarkdown Commands ===")
    CM.Info(" ")
    CM.Info("  /markdown - Generate profile")
    CM.Info(" ")
    
    -- Collect all commands with descriptions
    local allCommands = {}
    
    -- Format commands
    for _, cmd in ipairs(formatCommands) do
        local format = formatMap[cmd]
        local shortcut = formatShortcuts[cmd] or cmd
        table.insert(allCommands, {
            command = cmd,
            shortcut = shortcut,
            description = "Generate " .. format .. " format",
            category = "format",
        })
    end
    
    -- Calculate object shortcuts
    local objects = {}
    for object, _ in pairs(subcommandHandlers) do
        table.insert(objects, object)
    end
    local objectShortcuts = FindShortestUniquePrefixes(objects)
    
    -- Subcommands
    for object, handlers in pairs(subcommandHandlers) do
        for action, handlerData in pairs(handlers) do
            local fullCmd = object
            if action and action ~= "" then
                fullCmd = object .. ":" .. action
            end
            
            -- Calculate shortcut for action
            local actions = {}
            for act, _ in pairs(handlers) do
                if act ~= "" then
                    table.insert(actions, act)
                end
            end
            local actionShortcuts = FindShortestUniquePrefixes(actions)
            local objectShort = objectShortcuts[object] or object
            local shortcut = objectShort
            if action and action ~= "" then
                local actionShort = actionShortcuts[action] or action
                shortcut = objectShort .. ":" .. actionShort
            end
            
            table.insert(allCommands, {
                command = fullCmd,
                shortcut = shortcut,
                description = handlerData.description or "",
                category = object,
            })
        end
    end
    
    -- Add help command
    table.insert(allCommands, {
        command = "help",
        shortcut = objectShortcuts["help"] or "help",
        description = "Show this help",
        category = "help",
    })
    
    -- Sort alphabetically
    table.sort(allCommands, function(a, b)
        return a.command < b.command
    end)
    
    -- Group by category and display
    CM.Info("Subcommands (alphabetically grouped):")
    local lastCategory = nil
    for _, cmdData in ipairs(allCommands) do
        if cmdData.category ~= lastCategory then
            lastCategory = cmdData.category
        end
        local displayCmd = "/markdown " .. cmdData.command
        if cmdData.shortcut ~= cmdData.command then
            displayCmd = displayCmd .. " (or " .. cmdData.shortcut .. ")"
        end
        CM.Info("  " .. displayCmd .. " - " .. cmdData.description)
    end
    
    CM.Info(" ")
    CM.Info("Settings: ESC → Settings → Add-Ons → CharacterMarkdown")
end

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
    local lamHandler = SLASH_COMMANDS["/markdownsettings"]
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
        CM.Error("Usage: /markdown settings:get <key>")
        CM.Info("Example: /markdown settings:get includeChampionPoints")
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
        CM.Error("Usage: /markdown settings:set <key> <value>")
        CM.Info("Example: /markdown settings:set includeChampionPoints true")
        return
    end
    
    local key, valueStr = args:match("^%s*(%S+)%s+(.+)$")
    if not key or not valueStr then
        CM.Error("Invalid format. Use: /markdown settings:set <key> <value>")
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

    local testFormat = CM.currentFormat or "github"
    CM.Info(string.format("Generating %s format with current settings...", testFormat))

    local success, markdown = pcall(function()
        return CM.generators.GenerateMarkdown(testFormat)
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

    local validationResults = CM.tests.validation.ValidateMarkdown(markdownString, testFormat)

    local sectionResults = nil
    if CM.tests and CM.tests.sectionPresence then
        sectionResults = CM.tests.sectionPresence.ValidateSectionPresence(markdownString, testFormat, testSettings)
    end

    CM.tests.validation.PrintTestReport()

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
-- REGISTER SUBCOMMANDS
-- =====================================================

RegisterSubcommand("debug", nil, HandleDebug, "Toggle debug mode")
RegisterSubcommand("debug", "on", HandleDebugOn, "Enable debug mode")
RegisterSubcommand("debug", "off", HandleDebugOff, "Disable debug mode")

RegisterSubcommand("help", nil, ShowHelp, "Show this help")

RegisterSubcommand("settings", nil, HandleSettings, "Open settings panel")
RegisterSubcommand("settings", "show", HandleSettingsShow, "Show SavedVariables debug info")
RegisterSubcommand("settings", "get", HandleSettingsGet, "Get current value of a setting (advanced)")
RegisterSubcommand("settings", "set", HandleSettingsSet, "Set value of a setting (advanced)")
RegisterSubcommand("settings", "reset", HandleSettingsReset, "Reset all settings to defaults (advanced)")
RegisterSubcommand("settings", "enable-all", HandleSettingsEnableAll, "Enable all boolean settings (advanced)")

RegisterSubcommand("test", nil, HandleTest, "Run comprehensive diagnostic + validation tests")
RegisterSubcommand("test", "layout", HandleTestLayout, "Run layout calculator tests")

-- =====================================================
-- MAIN COMMAND HANDLER
-- =====================================================

local function CommandHandler(args)
    if not CM.isInitialized then
        CM.Error("Addon not fully initialized. Try again in a moment or /reloadui")
        return
    end

    -- Handle help
    if args and args:lower():match("^%s*help") then
        ShowHelp()
        return
    end

    -- Parse subcommand
    local object, action, remaining = ParseSubcommand(args)
    CM.DebugPrint("COMMANDS", string.format("Parsed: object='%s' action='%s' remaining='%s'", 
        tostring(object), tostring(action), tostring(remaining)))
    
    -- Try to route as subcommand first
    if object and RouteSubcommand(object, action, remaining) then
        CM.DebugPrint("COMMANDS", "Subcommand routed successfully")
        return
    else
        CM.DebugPrint("COMMANDS", "Subcommand routing failed or no object")
    end
    
    -- Try format command
    local format = ParseFormatCommand(args)
    if format then
        CM.currentFormat = format
        if CharacterMarkdownSettings then
            CharacterMarkdownSettings.currentFormat = format
            CharacterMarkdownSettings._lastModified = GetTimeStamp()
            CM.InvalidateSettingsCache()
        end

        CM.DebugPrint("COMMAND", "Generating " .. format .. " format...")

        if not CM.generators or not CM.generators.GenerateMarkdown then
            CM.Error("Markdown generator not loaded!")
            CM.Error("Try /reloadui to restart the addon")
            return
        end

        local success, markdown = pcall(function()
            return CM.generators.GenerateMarkdown(format)
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
                local results = CM.tests.validation.ValidateMarkdown(validationMarkdown, format)
                if #results.failed > 0 then
                    CM.DebugPrint("TESTS", string.format("⚠️ %d validation test(s) failed", #results.failed))
                end
            end, 100)
        end

        if CharacterMarkdown_ShowWindow then
            CM.DebugPrint("COMMAND", "Opening display window...")
            CharacterMarkdown_ShowWindow(markdown, format)
        else
            CM.Warn("Window display not available")
            CM.Info("Markdown copied to clipboard")
        end
        return
    end

    -- No args - generate with current format
    if not args or args == "" then
        local format = CM.currentFormat
        -- Recursively call with format command
        return CommandHandler("format:" .. format)
    end

    -- Unknown command
    CM.Error("Unknown command: " .. tostring(args))
    ShowHelp()
end

CM.commands.CommandHandler = CommandHandler
CM.commands.ParseCommandArgs = ParseFormatCommand
CM.commands.ShowHelp = ShowHelp
CM.commands.ParseSubcommand = ParseSubcommand
CM.commands.RouteSubcommand = RouteSubcommand

SLASH_COMMANDS["/markdown"] = CommandHandler

CM.DebugPrint("COMMANDS", "Command module loaded")
CM.DebugPrint("COMMANDS", "/markdown command registered")
