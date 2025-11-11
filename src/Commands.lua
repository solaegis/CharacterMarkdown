-- CharacterMarkdown - Command Handler

local CM = CharacterMarkdown

local function ParseCommandArgs(args)
    if not args or args == "" then
        return CM.currentFormat
    end
    
    local arg = args:lower():match("^%s*(%S+)")
    
    local formatMap = {
        github = "github", gh = "github",
        vscode = "vscode", vs = "vscode", code = "vscode",
        discord = "discord", dc = "discord",
        quick = "quick", q = "quick",
    }
    
    return formatMap[arg] or nil
end

local function ShowHelp()
    CM.Info("=== CharacterMarkdown Commands ===")
    d("  /markdown           - Generate profile (current: " .. CM.currentFormat .. ")")
    d("  /markdown github    - Generate GitHub format")
    d("  /markdown vscode    - Generate VS Code format")
    d("  /markdown discord   - Generate Discord format")
    d("  /markdown quick     - Generate quick summary")
    d("  /markdown test      - Run diagnostic + validation tests (comprehensive)")
    d("  /markdown unittest  - Run unit tests for collectors")
    d("  /markdown debug     - Toggle debug mode (current: " .. tostring(CM.debug) .. ")")
    d("  /markdown help      - Show this help")
    d("  /markdown save      - Force save settings to file")
    d(" ")
    d("  /cmdsettings export - Export settings to YAML (grouped format)")
    d("  /cmdsettings import - Import settings from YAML (supports partial import)")
    d("  /cmdsettings test:import-export - Run export/import tests")
    d("  /cmdsettings        - Open settings panel")
    d(" ")
    d("Settings: ESC → Settings → Add-Ons → CharacterMarkdown")
end

local function CommandHandler(args)
    if not CM.isInitialized then
        CM.Error("Addon not fully initialized. Try again in a moment or /reloadui")
        return
    end
    
    local format = ParseCommandArgs(args)
    
    if args and args:lower():match("^%s*help") then
        ShowHelp()
        return
    end
    
    -- Debug command - toggle debug mode
    if args and args:lower():match("^%s*debug") then
        CM.debug = not CM.debug
        if CM.debug then
            CM.Success("Debug mode ENABLED - debug output will show in chat")
            d("Run /markdown again to see debug output for quest collection")
        else
            CM.Success("Debug mode DISABLED")
        end
        return
    end
    
    -- Test command - comprehensive diagnostic and validation
    if args and args:lower():match("^%s*test") then
        CM.Info("=== CharacterMarkdown Diagnostic & Validation ===")
        d(" ")
        
        -- ================================================
        -- PHASE 1: SETTINGS DIAGNOSTIC
        -- ================================================
        CM.Info("|cFFD700[1/4] Settings Diagnostic|r")
        d(" ")
        
        -- Check if SavedVariables exist
        if not CharacterMarkdownSettings then
            CM.Error("CharacterMarkdownSettings is NIL!")
            d("  This means your settings aren't being saved")
            d("  Try: /reloadui")
            return
        end
        CM.Success("✓ CharacterMarkdownSettings exists")
        
        -- Check CM.GetSettings()
        if not CM.GetSettings then
            CM.Error("✗ CM.GetSettings() not available")
            return
        end
        CM.Success("✓ CM.GetSettings() available")
        
        -- Check critical settings
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
        
        d(" ")
        d("Critical Setting Values:")
        local merged = CM.GetSettings()
        local hasMismatch = false
        
        for _, setting in ipairs(criticalSettings) do
            local raw = CharacterMarkdownSettings[setting]
            local merged_val = merged[setting]
            
            if raw ~= merged_val then
                d(string.format("  |cFFFF00⚠ %s = %s (raw) vs %s (merged)|r", 
                    setting, tostring(raw), tostring(merged_val)))
                hasMismatch = true
            else
                local color = raw == true and "|c00FF00" or "|cFF0000"
                d(string.format("  %s%s = %s|r", color, setting, tostring(raw)))
            end
        end
        
        if hasMismatch then
            d(" ")
            CM.Warn("⚠ Settings merge has mismatches - this may cause issues")
        else
            d(" ")
            CM.Success("✓ Settings merge working correctly")
        end
        
        
        -- ================================================
        -- PHASE 2: DATA COLLECTION TEST
        -- ================================================
        d(" ")
        CM.Info("|cFFD700[2/4] Data Collection Test|r")
        
        -- Test CP data collection
        if CM.collectors and CM.collectors.CollectChampionPointData then
            local success, cpData = pcall(CM.collectors.CollectChampionPointData)
            if success and cpData then
                CM.Success("✓ Champion Points data collected")
                d(string.format("  Total: %d | Spent: %d | Available: %d", 
                    cpData.total or 0, cpData.spent or 0, (cpData.total or 0) - (cpData.spent or 0)))
                
                if cpData.disciplines and #cpData.disciplines > 0 then
                    d(string.format("  Disciplines: %d", #cpData.disciplines))
                    for _, disc in ipairs(cpData.disciplines) do
                        local skillCount = 0
                        if disc.allStars then
                            skillCount = #disc.allStars
                        elseif disc.slottableSkills and disc.passiveSkills then
                            skillCount = #disc.slottableSkills + #disc.passiveSkills
                        end
                        d(string.format("    %s: %d CP, %d skills", disc.name or "Unknown", disc.total or 0, skillCount))
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
        d(" ")
        CM.Info("|cFFD700[3/4] Markdown Generation Test|r")
        
        if not CM.tests or not CM.tests.validation then
            CM.Error("✗ Test validation module not loaded")
            return
        end
        
        -- Generate markdown with current settings
        local testFormat = CM.currentFormat or "github"
        d(string.format("Generating %s format with current settings...", testFormat))
        
        local success, markdown = pcall(function()
            return CM.generators.GenerateMarkdown(testFormat)
        end)
        
        if not success or not markdown then
            CM.Error("✗ Failed to generate markdown: " .. tostring(markdown))
            return
        end
        
        CM.Success("✓ Markdown generated successfully")
        
        -- Handle both string and chunks array returns
        local isChunksArray = type(markdown) == "table"
        local markdownString = markdown
        if isChunksArray then
            d(string.format("  Generated %d chunks", #markdown))
            local fullMarkdown = ""
            for _, chunk in ipairs(markdown) do
                fullMarkdown = fullMarkdown .. chunk.content
            end
            markdownString = fullMarkdown
        end
        
        d(string.format("  Total size: %d chars", #markdownString))
        
        -- Get current settings for section presence tests
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
        d(" ")
        CM.Info("|cFFD700[4/4] Validation Tests|r")
        
        -- Run validation tests
        local validationResults = CM.tests.validation.ValidateMarkdown(markdownString, testFormat)
        
        -- Run section presence tests
        local sectionResults = nil
        if CM.tests and CM.tests.sectionPresence then
            sectionResults = CM.tests.sectionPresence.ValidateSectionPresence(markdownString, testFormat, testSettings)
        end
        
        -- Print validation report
        CM.tests.validation.PrintTestReport()
        
        -- Print section presence report
        if sectionResults and CM.tests.sectionPresence then
            CM.tests.sectionPresence.PrintSectionTestReport()
        end
        
        -- ================================================
        -- FINAL SUMMARY
        -- ================================================
        d(" ")
        CM.Info("=== Test Summary ===")
        
        local totalFailed = #validationResults.failed
        local totalWarnings = #validationResults.warnings
        if sectionResults then
            totalFailed = totalFailed + #sectionResults.failed
        end
        
        if totalFailed == 0 and totalWarnings == 0 then
            CM.Success(string.format("✓ ALL TESTS PASSED! (%d validation, %d sections)", 
                #validationResults.passed, sectionResults and #sectionResults.passed or 0))
        elseif totalFailed == 0 then
            CM.Warn(string.format("⚠ Tests passed with %d warnings", totalWarnings))
        else
            CM.Error(string.format("✗ TESTS FAILED: %d validation passed, %d failed, %d warnings", 
                #validationResults.passed, totalFailed, totalWarnings))
        end
        d("Tip: Run '/markdown' to see the actual generated output")
        
        return
    end
    
    -- Unit test command
    if args and args:lower():match("^%s*unittest") then
        CM.Info("Running collector unit tests...")
        
        if not CM.tests or not CM.tests.unit then
            CM.Error("Unit test module not loaded")
            return
        end
        
        local results = CM.tests.unit.RunAllTests()
        
        if results.failed and #results.failed == 0 then
            CM.Success(string.format("All unit tests passed! (%d/%d)", #results.passed, results.total))
        else
            CM.Warn(string.format("Some unit tests failed: %d passed, %d failed out of %d total", 
                #results.passed, #results.failed, results.total))
        end
        
        return
    end
    
    -- Legacy diag command - redirect to test
    if args and args:lower():match("^%s*diag") then
        CM.Info("Note: '/markdown diag' has been merged into '/markdown test'")
        d("Redirecting to comprehensive test command...")
        d(" ")
        -- Recursively call with test argument
        return CommandHandler("test")
    end
    
    -- Reset command - force CP-only settings
    if args and args:lower():match("^%s*reset") then
        CM.Info("=== RESETTING TO CP-ONLY ===")
        d(" ")
        
        if not CharacterMarkdownSettings then
            CM.Error("CharacterMarkdownSettings not available!")
            return
        end
        
        -- Disable everything
        CharacterMarkdownSettings.includeSkillBars = false
        CharacterMarkdownSettings.includeSkills = false
        CharacterMarkdownSettings.includeEquipment = false
        CharacterMarkdownSettings.includeCompanion = false
        CharacterMarkdownSettings.includeCombatStats = false
        CharacterMarkdownSettings.includeBuffs = false
        CharacterMarkdownSettings.includeAttributes = false
        CharacterMarkdownSettings.includeDLCAccess = false
        CharacterMarkdownSettings.includeRole = false
        CharacterMarkdownSettings.includeLocation = false
        CharacterMarkdownSettings.includeBuildNotes = false
        CharacterMarkdownSettings.includeQuickStats = false
        CharacterMarkdownSettings.includeAttentionNeeded = false
        CharacterMarkdownSettings.includeTableOfContents = false
        CharacterMarkdownSettings.includeCurrency = false
        CharacterMarkdownSettings.includeProgression = false
        CharacterMarkdownSettings.includeRidingSkills = false
        CharacterMarkdownSettings.includeInventory = false
        CharacterMarkdownSettings.includePvP = false
        CharacterMarkdownSettings.includeCollectibles = false
        CharacterMarkdownSettings.includeCrafting = false
        CharacterMarkdownSettings.includeGuilds = false
        CharacterMarkdownSettings.includeUndauntedPledges = false
        CharacterMarkdownSettings.includeWorldProgress = false
        
        -- Enable ONLY CP
        CharacterMarkdownSettings.includeChampionPoints = true
        CharacterMarkdownSettings.includeChampionDiagram = true
        
        CM.Success("|c00FF00Settings reset to CP-only!|r")
        d(" ")
        d("Now try: /markdown")
        return
    end
    
    
    if args and args:lower():match("^%s*save") then
        if CharacterMarkdownSettings then
            if CharacterMarkdownSettings.SetValue then
                CharacterMarkdownSettings:SetValue("_lastSaved", GetTimeStamp())
                CM.Success("Settings saved using ZO_SavedVars! File should be created immediately.")
            else
                CharacterMarkdownSettings._lastSaved = GetTimeStamp()
                CM.Success("Settings marked for save! File will be created on next logout/zone change.")
            end
            CM.Info("Tip: Open the settings panel (ESC → Settings → Add-Ons → CharacterMarkdown) to ensure save")
        else
            CM.Error("Settings not available - addon may not be fully loaded")
        end
        return
    end
    
    if not format then
        CM.Error("Unknown option: " .. tostring(args))
        ShowHelp()
        return
    end
    
    CM.currentFormat = format
    if CharacterMarkdownSettings then
        CharacterMarkdownSettings.currentFormat = format
    end
    
    CM.Info("Generating " .. format .. " format...")
    
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
    
    -- Handle both string (single chunk) and table (chunks array) returns
    local isChunksArray = type(markdown) == "table"
    local markdownSize = 0
    
    if isChunksArray then
        if #markdown == 0 then
            CM.Error("Generated markdown chunks array is empty")
            return
        end
        -- Calculate total size
        for _, chunk in ipairs(markdown) do
            markdownSize = markdownSize + string.len(chunk.content)
        end
        CM.DebugPrint("COMMAND", "Markdown generated:", markdownSize, "chars in", #markdown, "chunks")
        CM.Success(string.format("Markdown generated (%d characters in %d chunk%s)", 
            markdownSize, #markdown, #markdown == 1 and "" or "s"))
    else
        if markdown == "" then
            CM.Error("Generated markdown is empty")
            return
        end
        markdownSize = string.len(markdown)
        CM.DebugPrint("COMMAND", "Markdown generated:", markdownSize, "chars")
        CM.Success("Markdown generated (" .. markdownSize .. " characters)")
    end
    
    -- Run validation tests if enabled (non-blocking, debug only)
    if CM.debug and CM.tests and CM.tests.validation then
        zo_callLater(function()
            -- Handle both string and chunks array for validation
            local validationMarkdown = markdown
            if isChunksArray then
                -- Concatenate chunks for validation
                validationMarkdown = ""
                for _, chunk in ipairs(markdown) do
                    validationMarkdown = validationMarkdown .. chunk.content
                end
            end
            local results = CM.tests.validation.ValidateMarkdown(validationMarkdown, format)
            if #results.failed > 0 then
                CM.DebugPrint("TESTS", string.format("⚠️ %d validation test(s) failed", #results.failed))
            end
        end, 100)  -- Delay to avoid blocking main generation
    end
    
    if CharacterMarkdown_ShowWindow then
        CM.DebugPrint("COMMAND", "Opening display window...")
        CharacterMarkdown_ShowWindow(markdown, format)
    else
        CM.Warn("Window display not available")
        CM.Info("Markdown copied to clipboard")
    end
end

CM.commands.CommandHandler = CommandHandler
CM.commands.ParseCommandArgs = ParseCommandArgs
CM.commands.ShowHelp = ShowHelp

SLASH_COMMANDS["/markdown"] = CommandHandler

-- =====================================================
-- SETTINGS EXPORT COMMAND
-- =====================================================

local function SettingsExportCommandHandler(args)
    if not CM.isInitialized then
        CM.Error("Addon not fully initialized. Try again in a moment or /reloadui")
        return
    end
    
    -- Get all settings
    local settings = CM.GetSettings()
    if not settings then
        CM.Error("Settings not available")
        return
    end
    
    -- Format settings for readable export
    if not CM.utils or not CM.utils.FormatSettingsForExport then
        CM.Error("Settings formatter not available")
        return
    end
    
    local formattedSettings = CM.utils.FormatSettingsForExport(settings)
    if not formattedSettings then
        CM.Error("Failed to format settings")
        return
    end
    
    -- Convert to YAML
    if not CM.utils.TableToYAML then
        CM.Error("YAML serializer not available")
        return
    end
    
    local yamlContent = CM.utils.TableToYAML(formattedSettings)
    
    if not yamlContent or yamlContent == "" then
        CM.Error("Failed to generate YAML")
        return
    end
    
    CM.Info("Opening settings export window...")
    
    -- Show settings in window
    if CharacterMarkdown_ShowSettingsExport then
        CharacterMarkdown_ShowSettingsExport(yamlContent)
    else
        CM.Error("Settings export window not available")
    end
end

-- =====================================================
-- SETTINGS IMPORT COMMAND
-- =====================================================

local function SettingsImportCommandHandler(args)
    if not CM.isInitialized then
        CM.Error("Addon not fully initialized. Try again in a moment or /reloadui")
        return
    end
    
    CM.Info("Opening settings import window...")
    
    -- Show import dialog
    if CharacterMarkdown_ShowSettingsImport then
        CharacterMarkdown_ShowSettingsImport()
    else
        CM.Error("Settings import window not available")
    end
end


-- Register command handler after LibAddonMenu has registered (if it exists)
-- This ensures our handler wraps LibAddonMenu's handler
local isRegistered = false
local function RegisterCmdSettingsCommand()
    -- Prevent double registration
    if isRegistered then
        CM.DebugPrint("COMMANDS", "/cmdsettings command already registered, skipping")
        return
    end
    
    -- Store LibAddonMenu's handler BEFORE we overwrite it
    local lamHandler = SLASH_COMMANDS["/cmdsettings"]
    
    -- Register our handler (will wrap LibAddonMenu's if it exists)
    SLASH_COMMANDS["/cmdsettings"] = function(args)
        -- Check if this is one of our commands first
        if args and args ~= "" then
            local trimmedArgs = args:lower():match("^%s*(.-)%s*$")
            
            -- Check for subcommand pattern: command:subcommand
            local command, subcommand = trimmedArgs:match("^(%S+):(%S+)$")
            if not command then
                -- Try simple command without colon
                command = trimmedArgs:match("^(%S+)")
            end
            
            if command == "export" then
                SettingsExportCommandHandler(args)
                return
            elseif command == "import" then
                SettingsImportCommandHandler(args)
                return
            elseif command == "test" and subcommand == "import-export" then
                -- Export/Import test command
                CM.Info("Running export/import tests...")
                
                if not CM.tests or not CM.tests.exportImport then
                    CM.Error("Export/Import test module not loaded")
                    return
                end
                
                local results = CM.tests.exportImport.RunAllTests()
                
                if results.failed and #results.failed == 0 then
                    CM.Success(string.format("All export/import tests passed! (%d/%d)", #results.passed, results.total))
                else
                    CM.Warn(string.format("Some export/import tests failed: %d passed, %d failed out of %d total", 
                        #results.passed, #results.failed, results.total))
                end
                return
            end
        end
        
        -- Not one of our commands - delegate to LibAddonMenu's handler if it exists
        if lamHandler and type(lamHandler) == "function" then
            lamHandler(args)
        elseif LibAddonMenu2 then
            -- Fallback: open settings panel manually
            SCENE_MANAGER:Show("gameMenuInGame")
            PlaySound(SOUNDS.MENU_SHOW)
            zo_callLater(function()
                local mainMenu = SYSTEMS:GetObject("mainMenu")
                if mainMenu then
                    mainMenu:ShowCategory(MENU_CATEGORY_ADDONS)
                end
            end, 100)
        else
            CM.Info("Usage:")
            CM.Info("  /cmdsettings export - Export settings to YAML")
            CM.Info("  /cmdsettings import - Import settings from YAML")
            CM.Info("  /cmdsettings test:import-export - Run export/import tests")
            CM.Info("Or use: ESC → Settings → Add-Ons → CharacterMarkdown")
        end
    end
    
    isRegistered = true
    CM.DebugPrint("COMMANDS", "/cmdsettings command registered (wrapped LibAddonMenu handler)")
end

-- Export function to register command after Panel initialization
CM.commands.RegisterCmdSettingsCommand = RegisterCmdSettingsCommand

CM.DebugPrint("COMMANDS", "Command module loaded")
CM.DebugPrint("COMMANDS", "/markdown command registered")
