-- CharacterMarkdown - Command Handler
-- Refactored: Core command registration and main generation logic
-- Debug, Settings, and Test commands extracted to src/commands/

local CM = CharacterMarkdown
CM.commands = CM.commands or {}

-- =====================================================
-- MAIN GENERATION LOGIC
-- =====================================================

local function GenerateOutput(formatter)
    if not CM.isInitialized then
        CM.Error("Addon not fully initialized. Try again in a moment or /reloadui")
        return
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

        if not tonlOutput then
            CM.Error("Generated TONL is nil")
            return
        end

        -- Handle chunked output (table) or single string
        local isChunksArray = type(tonlOutput) == "table"
        local tonlSize = 0

        if isChunksArray then
            if #tonlOutput == 0 then
                CM.Error("Generated TONL chunks array is empty")
                return
            end
            for _, chunk in ipairs(tonlOutput) do
                tonlSize = tonlSize + string.len(chunk.content)
            end
            CM.DebugPrint(
                "COMMAND",
                string.format(
                    "TONL generated: %d chars in %d chunk%s",
                    tonlSize,
                    #tonlOutput,
                    #tonlOutput == 1 and "" or "s"
                )
            )
        else
            if tonlOutput == "" then
                CM.Error("Generated TONL is empty")
                return
            end
            tonlSize = string.len(tonlOutput)
            CM.DebugPrint("COMMAND", string.format("TONL generated: %d chars", tonlSize))
        end

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
    -- Import handler modules (loaded via manifest before this file)
    local debug = CM.commands.debug or {}
    local settings = CM.commands.settings or {}
    local test = CM.commands.test or {}

    -- Check for LibSlashCommander
    if LibSlashCommander then
        CM.Info("Using LibSlashCommander for enhanced command handling")

        -- Main Command: /markdown (and /cm)
        local cmd = LibSlashCommander:Register({ "/markdown", "/cm" }, function(args)
            GenerateOutput("markdown")
        end, "Character Markdown")

        -- Subcommand: settings
        local settingsCmd = cmd:RegisterSubCommand()
        settingsCmd:AddAlias("settings")
        settingsCmd:AddAlias("s")
        settingsCmd:SetCallback(function(args)
            if not args or args == "" then
                settings.HandleSettings()
            else
                local firstArg = args:match("^(%S+)")
                if firstArg then
                    if firstArg == "show" then
                        settings.HandleSettingsShow()
                    elseif firstArg == "get" then
                        settings.HandleSettingsGet(args:sub(5))
                    elseif firstArg == "set" then
                        settings.HandleSettingsSet(args:sub(5))
                    elseif firstArg == "reset" then
                        settings.HandleSettingsReset()
                    elseif firstArg == "enable-all" then
                        settings.HandleSettingsEnableAll()
                    else
                        settings.HandleSettings()
                    end
                else
                    settings.HandleSettings()
                end
            end
        end)
        settingsCmd:SetDescription("Open settings or manage configuration")
        settingsCmd:SetAutoComplete({ "show", "get", "set", "reset", "enable-all" })

        -- Subcommand: debug
        local debugCmd = cmd:RegisterSubCommand()
        debugCmd:AddAlias("debug")
        debugCmd:SetCallback(function(args)
            if args == "on" then
                debug.HandleDebugOn()
            elseif args == "off" then
                debug.HandleDebugOff()
            else
                debug.HandleDebug()
            end
        end)
        debugCmd:SetDescription("Toggle debug mode")
        debugCmd:SetAutoComplete({ "on", "off" })

        -- Subcommand: version
        local verCmd = cmd:RegisterSubCommand()
        verCmd:AddAlias("version")
        verCmd:SetCallback(debug.HandleVersion)
        verCmd:SetDescription("Show addon version")

        -- Subcommand: help
        local helpCmd = cmd:RegisterSubCommand()
        helpCmd:AddAlias("help")
        helpCmd:SetCallback(function()
            CM.Info("/markdown - Generate Markdown profile (Alias: /cm)")
            CM.Info("/markdown tonl - Generate TONL profile")
            CM.Info("/markdown settings - Open settings")
            CM.Info("/markdown version - Show version")
            CM.Info("/markdown debug - Toggle debug")
        end)
        helpCmd:SetDescription("Show available commands")

        -- Subcommand: tonl
        local tonlCmd = cmd:RegisterSubCommand()
        tonlCmd:AddAlias("tonl")
        tonlCmd:SetCallback(function()
            GenerateOutput("tonl")
        end)
        tonlCmd:SetDescription("Generate TONL output")

        -- Subcommand: markdown
        local mdCmd = cmd:RegisterSubCommand()
        mdCmd:AddAlias("markdown")
        mdCmd:SetCallback(function()
            GenerateOutput("markdown")
        end)
        mdCmd:SetDescription("Generate Markdown output")

        -- Subcommand: test
        local testCmd = cmd:RegisterSubCommand()
        testCmd:AddAlias("test")
        testCmd:SetCallback(function(args)
            if args == "layout" then
                test.HandleTestLayout()
            elseif args == "constants" then
                debug.HandleTestConstants()
            else
                test.HandleTest()
            end
        end)
        testCmd:SetDescription("Run diagnostic tests")
        testCmd:SetAutoComplete({ "layout", "constants" })

        -- Subcommand: scan
        local scanCmd = cmd:RegisterSubCommand()
        scanCmd:AddAlias("scan")
        scanCmd:SetCallback(function(args)
            if args == "stats" then
                debug.HandleScanStats()
            end
        end)
        scanCmd:SetDescription("Scan stats (debug)")
        scanCmd:SetAutoComplete({ "stats" })

        -- Subcommand: cache
        local cacheCmd = cmd:RegisterSubCommand()
        cacheCmd:AddAlias("cache")
        cacheCmd:SetCallback(function(args)
            if args == "clear" then
                debug.HandleCacheClear()
            end
        end)
        cacheCmd:SetDescription("Manage cache")
        cacheCmd:SetAutoComplete({ "clear" })

        -- Subcommand: find
        local findCmd = cmd:RegisterSubCommand()
        findCmd:AddAlias("find")
        findCmd:SetCallback(function(args)
            if args == "names" then
                debug.HandleFindNames()
            end
        end)
        findCmd:SetDescription("Find IDs (debug)")
        findCmd:SetAutoComplete({ "names" })

        -- Register global aliases for backward compatibility
        LibSlashCommander:Register("/tonl", function()
            GenerateOutput("tonl")
        end, "Generate TONL output")
    else
        -- Fallback: Manual parsing
        CM.Info("LibSlashCommander not found - using basic command handling")

        local function ManualHandler(args)
            args = args or ""
            local command, rest = args:match("^(%S+)(.*)")
            command = command and command:lower() or ""
            rest = rest and rest:match("^%s*(.*)") or ""

            if command == "" then
                GenerateOutput("markdown")
            elseif command == "settings" or command == "s" then
                if rest:match("^show") then
                    settings.HandleSettingsShow()
                elseif rest:match("^get") then
                    settings.HandleSettingsGet(rest)
                elseif rest:match("^set") then
                    settings.HandleSettingsSet(rest)
                elseif rest:match("^reset") then
                    settings.HandleSettingsReset()
                elseif rest:match("^enable%-all") then
                    settings.HandleSettingsEnableAll()
                else
                    settings.HandleSettings()
                end
            elseif command == "debug" then
                if rest == "on" then
                    debug.HandleDebugOn()
                elseif rest == "off" then
                    debug.HandleDebugOff()
                else
                    debug.HandleDebug()
                end
            elseif command == "version" then
                debug.HandleVersion()
            elseif command == "tonl" then
                GenerateOutput("tonl")
            elseif command == "markdown" then
                GenerateOutput("markdown")
            elseif command == "test" then
                if rest == "layout" then
                    test.HandleTestLayout()
                elseif rest == "constants" then
                    debug.HandleTestConstants()
                else
                    test.HandleTest()
                end
            elseif command == "scan" and rest == "stats" then
                debug.HandleScanStats()
            elseif command == "cache" and rest == "clear" then
                debug.HandleCacheClear()
            elseif command == "find" and rest == "names" then
                debug.HandleFindNames()
            elseif command == "help" then
                CM.Info("/markdown - Generate Markdown profile (Alias: /cm)")
                CM.Info("/markdown tonl - Generate TONL profile")
                CM.Info("/markdown settings - Open settings")
                CM.Info("/markdown debug - Toggle debug")
                CM.Info("/markdown version - Show version")
                CM.Info("/markdown test - Run tests")
            else
                CM.Error("Unknown command: " .. command)
                CM.Info("Type /markdown help for commands")
            end
        end

        SLASH_COMMANDS["/markdown"] = ManualHandler
        SLASH_COMMANDS["/cm"] = ManualHandler
        SLASH_COMMANDS["/tonl"] = function()
            GenerateOutput("tonl")
        end
    end
end

-- Initialize commands
InitializeCommands()

-- Export for external use
CM.commands.CommandHandler = function(args)
    local formatter = CM.currentFormatter or "markdown"
    GenerateOutput(formatter)
end
CM.commands.GenerateOutput = GenerateOutput

CM.DebugPrint("COMMANDS", "Command module loaded")
