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
        
        -- Generate markdown first
        local testFormat = CM.currentFormat or "github"
        local success, markdown = pcall(function()
            return CM.generators.GenerateMarkdown(testFormat)
        end)
        
        if not success or not markdown then
            CM.Error("Failed to generate markdown for testing")
            return
        end
        
        -- Run validation tests
        local results = CM.tests.validation.ValidateMarkdown(markdown, testFormat)
        
        -- Print report
        CM.tests.validation.PrintTestReport()
        
        -- Summary
        if #results.failed == 0 then
            CM.Success(string.format("All tests passed! (%d passed, %d warnings)", 
                #results.passed, #results.warnings))
        else
            CM.Warn(string.format("Some tests failed: %d passed, %d failed, %d warnings", 
                #results.passed, #results.failed, #results.warnings))
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
    
    if not markdown or markdown == "" then
        CM.Error("Generated markdown is empty")
        return
    end
    
    CM.DebugPrint("COMMAND", "Markdown generated:", string.len(markdown), "chars")
    CM.Success("Markdown generated (" .. string.len(markdown) .. " characters)")
    
    -- Run validation tests if enabled (non-blocking, debug only)
    if CM.debug and CM.tests and CM.tests.validation then
        zo_callLater(function()
            local results = CM.tests.validation.ValidateMarkdown(markdown, format)
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
