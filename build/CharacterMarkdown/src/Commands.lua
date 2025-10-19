-- CharacterMarkdown - Command Handler
-- Slash command processing

d("[CharacterMarkdown] Loading Commands.lua module...")

local CM = CharacterMarkdown

if not CM then
    d("[CharacterMarkdown] ❌ ERROR: CharacterMarkdown namespace not found in Commands.lua!")
    return
end

d("[CharacterMarkdown] CharacterMarkdown namespace found: " .. tostring(CM))

-- =====================================================
-- COMMAND HANDLER
-- =====================================================

local function CommandHandler(args)
    local format = CM.currentFormat
    
    -- Parse arguments
    if args and args ~= "" then
        local arg = args:lower():match("^%s*(%S+)")
        if arg == "github" or arg == "gh" then
            format = "github"
            CM.currentFormat = "github"
            if CharacterMarkdownSettings then
                CharacterMarkdownSettings.currentFormat = "github"
            end
        elseif arg == "vscode" or arg == "vs" or arg == "code" then
            format = "vscode"
            CM.currentFormat = "vscode"
            if CharacterMarkdownSettings then
                CharacterMarkdownSettings.currentFormat = "vscode"
            end
        elseif arg == "discord" or arg == "dc" then
            format = "discord"
            CM.currentFormat = "discord"
            if CharacterMarkdownSettings then
                CharacterMarkdownSettings.currentFormat = "discord"
            end
        elseif arg == "quick" or arg == "q" then
            format = "quick"
            CM.currentFormat = "quick"
            if CharacterMarkdownSettings then
                CharacterMarkdownSettings.currentFormat = "quick"
            end
        elseif arg == "help" or arg == "?" then
            d("[CharacterMarkdown] Usage:")
            d("  /markdown          - Generate profile (current format: " .. CM.currentFormat .. ")")
            d("  /markdown github   - Generate GitHub-optimized profile")
            d("  /markdown vscode   - Generate VS Code-optimized profile")
            d("  /markdown discord  - Generate Discord-optimized profile")
            d("  /markdown quick    - Generate quick one-line summary")
            d("  /markdown help     - Show this help message")
            return
        else
            d("[CharacterMarkdown] Unknown option: " .. arg)
            d("[CharacterMarkdown] Use '/markdown help' for usage information")
            return
        end
    end
    
    -- Generate markdown
    d("[CharacterMarkdown] Generating " .. format .. " format...")
    
    -- Check if generator is available
    if not CM.generators or not CM.generators.GenerateMarkdown then
        d("[CharacterMarkdown] ❌ ERROR: Markdown generator not loaded!")
        d("[CharacterMarkdown] This usually means the addon didn't load correctly.")
        d("[CharacterMarkdown] Try /reloadui to restart the addon.")
        return
    end
    
    local markdown = CM.generators.GenerateMarkdown(format)
    
    if not markdown or markdown == "" then
        d("[CharacterMarkdown] ❌ Failed to generate markdown")
        return
    end
    
    d("[CharacterMarkdown] ✅ Markdown generated (" .. string.len(markdown) .. " characters)")
    d("[CharacterMarkdown] Opening display window...")
    
    -- Show window (if UI is available)
    if CharacterMarkdown_ShowWindow then
        CharacterMarkdown_ShowWindow(markdown, format)
    else
        d("[CharacterMarkdown] Window display not available, markdown copied to clipboard")
    end
end

CM.commands.CommandHandler = CommandHandler

d("[CharacterMarkdown] Registering /markdown command...")

-- Register slash command
SLASH_COMMANDS["/markdown"] = CommandHandler

d("[CharacterMarkdown] ✅ /markdown command registered successfully!")
d("[CharacterMarkdown] CommandHandler function: " .. tostring(CommandHandler))
d("[CharacterMarkdown] SLASH_COMMANDS['/markdown']: " .. tostring(SLASH_COMMANDS["/markdown"]))
