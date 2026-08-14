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

    -- Default to markdown if no formatter specified
    formatter = formatter or "markdown"
    CM.DebugPrint("COMMAND", "Generating " .. formatter .. " output...")

    -- Markdown formatter
    if formatter == "markdown" then
        if not CM.generators or not CM.generators.GenerateMarkdown then
            CM.Error("Markdown generator not loaded!")
            CM.Error("Try /reloadui to restart the addon")
            return
        end

        -- Open window immediately so users see feedback before collection
        if CharacterMarkdown_ShowGeneratingPlaceholder then
            CharacterMarkdown_ShowGeneratingPlaceholder(formatter)
        end

        local function PresentMarkdown(markdown)
            if not markdown then
                CM.Error("Generated markdown is nil")
                return
            end

            local isChunksArray = type(markdown) == "table"
            local markdownSize = 0
            local chunkCount = 1

            if isChunksArray then
                if #markdown == 0 then
                    CM.Error("Generated markdown chunks array is empty")
                    return
                end
                chunkCount = #markdown
                for _, chunk in ipairs(markdown) do
                    markdownSize = markdownSize + string.len(chunk.content)
                end
                CM.DebugPrint(
                    "COMMAND",
                    string.format(
                        "Markdown generated: %d chars in %d chunk%s",
                        markdownSize,
                        chunkCount,
                        chunkCount == 1 and "" or "s"
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
                local sizeKb = math.floor((markdownSize / 1024) * 10 + 0.5) / 10
                CM.Info(
                    string.format(
                        "CharacterMarkdown ready — window opened (%d chunk%s, %.1f KB). Select All + Copy to paste.",
                        chunkCount,
                        chunkCount == 1 and "" or "s",
                        sizeKb
                    )
                )
            else
                CM.Warn("Window display not available")
                CM.Info("Markdown copied to clipboard")
            end
        end

        local function RunGeneration()
            local asyncLib = CM.utils and CM.utils.LibAsyncIntegration
            local useAsync = asyncLib
                and asyncLib.IsLibAsyncAvailable
                and asyncLib.IsLibAsyncAvailable()
                and CM.generators.GenerateMarkdownAsync

            if useAsync then
                CM.DebugPrint("COMMAND", "Using LibAsync generation path")
                CM.generators.GenerateMarkdownAsync(function(markdown)
                    PresentMarkdown(markdown)
                end, function(err)
                    CM.Error("Failed to generate markdown:")
                    CM.Error(tostring(err))
                end)
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

            PresentMarkdown(markdown)
        end

        -- Defer one frame so the placeholder can paint
        zo_callLater(RunGeneration, 0)
        return
    elseif formatter == "coach" then
        if not CM.generators or not CM.generators.GenerateBuildCoach then
            CM.Error("Build coach generator not loaded!")
            CM.Error("Try /reloadui to restart the addon")
            return
        end

        if CharacterMarkdown_ShowGeneratingPlaceholder then
            CharacterMarkdown_ShowGeneratingPlaceholder("markdown")
        end

        local function PresentCoach(markdown)
            if not markdown then
                CM.Error("Generated build-coach markdown is nil")
                return
            end

            local isChunksArray = type(markdown) == "table"
            local markdownSize = 0
            local chunkCount = 1

            if isChunksArray then
                if #markdown == 0 then
                    CM.Error("Generated build-coach chunks array is empty")
                    return
                end
                chunkCount = #markdown
                for _, chunk in ipairs(markdown) do
                    markdownSize = markdownSize + string.len(chunk.content)
                end
            else
                if markdown == "" then
                    CM.Error("Generated build-coach markdown is empty")
                    return
                end
                markdownSize = string.len(markdown)
            end

            CM.DebugPrint(
                "COMMAND",
                string.format(
                    "Build coach generated: %d chars in %d chunk%s",
                    markdownSize,
                    chunkCount,
                    chunkCount == 1 and "" or "s"
                )
            )

            if CharacterMarkdown_ShowWindow then
                CharacterMarkdown_ShowWindow(markdown, "markdown")
                local sizeKb = math.floor((markdownSize / 1024) * 10 + 0.5) / 10
                CM.Info(
                    string.format(
                        "Build coach ready — paste into ChatGPT/Claude (%d chunk%s, %.1f KB).",
                        chunkCount,
                        chunkCount == 1 and "" or "s",
                        sizeKb
                    )
                )
            else
                CM.Warn("Window display not available")
            end
        end

        zo_callLater(function()
            local success, markdown = pcall(function()
                return CM.generators.GenerateBuildCoach()
            end)
            if not success then
                CM.Error("Failed to generate build coach export:")
                CM.Error(tostring(markdown))
                return
            end
            PresentCoach(markdown)
        end, 0)
        return
    else
        CM.Error("Unknown formatter: " .. tostring(formatter))
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

        -- Main Command: /cm (alias: /markdown)
        local cmd = LibSlashCommander:Register({ "/cm", "/markdown" }, function(args)
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
            CM.Info("/cm - Generate Markdown profile (alias: /markdown)")
            CM.Info("/cm coach - Compact AI / build-coach export (aliases: ai, build-coach)")
            CM.Info("/cm settings - Open settings")
            CM.Info("/cm version - Show version")
            CM.Info("/cm debug - Toggle debug")
        end)
        helpCmd:SetDescription("Show available commands")

        -- Subcommand: markdown
        local mdCmd = cmd:RegisterSubCommand()
        mdCmd:AddAlias("markdown")
        mdCmd:SetCallback(function()
            GenerateOutput("markdown")
        end)
        mdCmd:SetDescription("Generate Markdown output")

        -- Subcommand: coach / ai / build-coach
        local coachCmd = cmd:RegisterSubCommand()
        coachCmd:AddAlias("coach")
        coachCmd:AddAlias("ai")
        coachCmd:AddAlias("build-coach")
        coachCmd:SetCallback(function()
            GenerateOutput("coach")
        end)
        coachCmd:SetDescription("Generate compact AI / build-coach export")

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
            elseif command == "coach" or command == "ai" or command == "build-coach" then
                GenerateOutput("coach")
            elseif command == "settings" or command == "s" then
                if rest:match("^show") then
                    settings.HandleSettingsShow()
                elseif rest:match("^get") then
                    local args = rest:match("^get%s*(.*)$") or ""
                    settings.HandleSettingsGet(args)
                elseif rest:match("^set") then
                    local args = rest:match("^set%s*(.*)$") or ""
                    settings.HandleSettingsSet(args)
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
                CM.Info("/cm - Generate Markdown profile (alias: /markdown)")
                CM.Info("/cm coach - Compact AI / build-coach export (aliases: ai, build-coach)")
                CM.Info("/cm settings - Open settings")
                CM.Info("/cm debug - Toggle debug")
                CM.Info("/cm version - Show version")
                CM.Info("/cm test - Run tests")
            else
                CM.Error("Unknown command: " .. command)
                CM.Info("Type /cm help for commands")
            end
        end

        SLASH_COMMANDS["/cm"] = ManualHandler
        SLASH_COMMANDS["/markdown"] = ManualHandler
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
