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
    CM.Info("=== Usage ===")
    d("  /markdown           - Generate profile (current: " .. CM.currentFormat .. ")")
    d("  /markdown github    - Generate GitHub format")
    d("  /markdown vscode    - Generate VS Code format")
    d("  /markdown discord   - Generate Discord format")
    d("  /markdown quick     - Generate quick summary")
    d("  /markdown test      - Run validation tests on generated markdown")
    d("  /markdown unittest  - Run unit tests for collectors (riding skills, skill points)")
    d("  /markdown help      - Show this help")
    d("  /markdown save      - Force save settings to file")
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
    
    -- Test command
    if args and args:lower():match("^%s*test") then
        CM.Info("Running validation tests...")
        
        if not CM.tests or not CM.tests.validation then
            CM.Error("Test validation module not loaded")
            return
        end
        
        -- Use current settings (don't enable all settings)
        CM.Info("Testing with current settings configuration...")
        
        -- Generate markdown with current settings
        local testFormat = CM.currentFormat or "github"
        local success, markdown = pcall(function()
            return CM.generators.GenerateMarkdown(testFormat)
        end)
        
        if not success or not markdown then
            CM.Error("Failed to generate markdown for testing")
            return
        end
        
        -- Handle both string and chunks array returns for testing
        local isChunksArray = type(markdown) == "table"
        if isChunksArray then
            -- Concatenate chunks for validation
            local fullMarkdown = ""
            for _, chunk in ipairs(markdown) do
                fullMarkdown = fullMarkdown .. chunk.content
            end
            markdown = fullMarkdown
        end
        
        -- Get current settings for section presence tests
        local testSettings = {}
        if CharacterMarkdownSettings then
            -- Copy current settings for testing
            for key, value in pairs(CharacterMarkdownSettings) do
                if type(value) ~= "function" and key:sub(1, 1) ~= "_" then
                    testSettings[key] = value
                end
            end
        end
        
        -- Run validation tests
        local validationResults = CM.tests.validation.ValidateMarkdown(markdown, testFormat)
        
        -- Run section presence tests (using current settings)
        local sectionResults = nil
        if CM.tests and CM.tests.sectionPresence then
            sectionResults = CM.tests.sectionPresence.ValidateSectionPresence(markdown, testFormat, testSettings)
        end
        
        -- Print validation report
        CM.tests.validation.PrintTestReport()
        
        -- Print section presence report
        if sectionResults and CM.tests.sectionPresence then
            d(" ")  -- Blank line separator
            CM.tests.sectionPresence.PrintSectionTestReport()
        end
        
        -- Summary
        local totalFailed = #validationResults.failed
        local totalWarnings = #validationResults.warnings
        if sectionResults then
            totalFailed = totalFailed + #sectionResults.failed
        end
        
        if totalFailed == 0 then
            CM.Success(string.format("All tests passed! (%d validation, %d sections)", 
                #validationResults.passed, sectionResults and #sectionResults.passed or 0))
        else
            CM.Warn(string.format("Some tests failed: %d validation passed, %d failed, %d warnings", 
                #validationResults.passed, totalFailed, totalWarnings))
        end
        
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

CM.DebugPrint("COMMANDS", "Command module loaded")
CM.DebugPrint("COMMANDS", "/markdown command registered")
