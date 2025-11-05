-- CharacterMarkdown - UI Window Handler
-- Manages the display window with direct EditBox (no scroll wrapper)
-- ESO Guideline Compliant - Uses LibDebugLogger for debug output

local CM = CharacterMarkdown

if not CM then
    CM.Error("CharacterMarkdown namespace not found in UI/Window.lua!")
    return
end

-- =====================================================
-- WINDOW CONTROLS CACHE
-- =====================================================

local windowControl = nil
local editBoxControl = nil
local clipboardEditBoxControl = nil
local currentMarkdown = ""
local markdownChunks = {}  -- Array of markdown chunks
local currentChunkIndex = 1

-- =====================================================
-- INITIALIZE WINDOW CONTROLS
-- =====================================================

local function InitializeWindowControls()
    if windowControl then
        return true  -- Already initialized
    end
    
    -- Get window control from XML
    windowControl = CharacterMarkdownWindow
    
    if not windowControl then
        CM.Error("Window control not found! XML may not have loaded.")
        return false
    end
    
    -- Get the EditBox control
    editBoxControl = CharacterMarkdownWindowTextContainerEditBox
    
    if not editBoxControl then
        CM.Error("EditBox control not found!")
        return false
    end
    
    -- Get the hidden clipboard EditBox
    clipboardEditBoxControl = CharacterMarkdownWindowTextContainerClipboardEditBox
    
    if not clipboardEditBoxControl then
        CM.Warn("Clipboard EditBox not found - using main EditBox")
    end
    
    -- Configure EditBox with character limit and READ-ONLY mode
    -- Note: ESO EditBox may have internal limits despite SetMaxInputChars
    editBoxControl:SetMaxInputChars(22000)  -- 22k character limit
    editBoxControl:SetMultiLine(true)
    editBoxControl:SetNewLineEnabled(true)
    editBoxControl:SetEditEnabled(false)  -- Make READ-ONLY - cannot be edited
    
    -- Verify the actual limit that was set
    -- Note: ESO EditBox may have hardcoded internal limits regardless of SetMaxInputChars
    local actualMaxChars = editBoxControl:GetMaxInputChars()
    if actualMaxChars then
        CM.DebugPrint("UI", string.format("EditBox max input chars: %d", actualMaxChars))
        if actualMaxChars < 22000 then
            CM.DebugPrint("UI", string.format("EditBox limited to %d (requested 22000)", actualMaxChars))
        end
    else
        CM.DebugPrint("UI", "Could not get EditBox max input chars")
    end
    
    -- Set to WHITE text on DARK background
    editBoxControl:SetFont("ZoFontChat")
    editBoxControl:SetColor(1, 1, 1, 1)  -- White text
    
    CM.DebugPrint("UI", "Window controls initialized successfully")
    return true
end

-- =====================================================
-- COPY TO CLIPBOARD FUNCTION (Called from XML button)
-- =====================================================

function CharacterMarkdown_CopyToClipboard()
    if not editBoxControl or not currentMarkdown or currentMarkdown == "" then
        CM.Warn("No content to copy")
        return
    end
    
    -- Refresh the EditBox with full text
    editBoxControl:SetEditEnabled(true)
    editBoxControl:SetText(currentMarkdown)
    editBoxControl:SetColor(1, 1, 1, 1)
    editBoxControl:SetEditEnabled(false)
    
    zo_callLater(function()
        -- Select all and take focus
        editBoxControl:SelectAll()
        editBoxControl:TakeFocus()
        
        -- Only show in chat if user explicitly wants feedback
        CM.DebugPrint("UI", "Text selected - Press Ctrl+C to copy")
    end, 100)
end

-- =====================================================
-- OPEN SETTINGS FUNCTION (Called from XML button)
-- =====================================================

function CharacterMarkdown_OpenSettings()
    if not LibAddonMenu2 then
        CM.Warn("LibAddonMenu-2.0 is not available. Settings panel cannot be opened.")
        CM.Info("To access settings: ESC → Settings → Add-Ons → CharacterMarkdown")
        return
    end
    
    -- Use a simpler approach: execute the slash command that LibAddonMenu registered
    -- This is the same as typing /cmdsettings in chat
    if SLASH_COMMANDS and SLASH_COMMANDS["/cmdsettings"] then
        SLASH_COMMANDS["/cmdsettings"]("")
        CM.DebugPrint("UI", "Opened settings via /cmdsettings command")
    else
        -- Fallback: open game menu to Add-Ons section
        SCENE_MANAGER:Show("gameMenuInGame")
        PlaySound(SOUNDS.MENU_SHOW)
        
        zo_callLater(function()
            local mainMenu = SYSTEMS:GetObject("mainMenu")
            if mainMenu then
                mainMenu:ShowCategory(MENU_CATEGORY_ADDONS)
                CM.Info("Please select 'Character Markdown' from the Add-Ons list.")
            end
        end, 100)
    end
end

-- =====================================================
-- REGENERATE MARKDOWN FUNCTION (Called from XML button)
-- =====================================================

function CharacterMarkdown_RegenerateMarkdown()
    if not CM or not CM.generators or not CM.generators.GenerateMarkdown then
        CM.Error("Generator not available")
        return
    end
    
    CM.DebugPrint("UI", "Regenerating markdown...")
    
    -- Get current format (default to github if not stored)
    local format = CM.currentFormat or "github"
    
    -- Clear the window
    if editBoxControl then
        editBoxControl:SetText("")
    end
    
    -- Regenerate markdown
    local success, markdown = pcall(CM.generators.GenerateMarkdown, format)
    
    if not success then
        CM.Error("Failed to regenerate markdown: " .. tostring(markdown))
        return
    end
    
    if not markdown or markdown == "" then
        CM.Error("Generated markdown is empty")
        return
    end
    
    -- Update stored markdown
    currentMarkdown = markdown
    
    -- Update the EditBox
    editBoxControl:SetEditEnabled(true)
    editBoxControl:SetText(markdown)
    editBoxControl:SetColor(1, 1, 1, 1)
    editBoxControl:SetEditEnabled(false)
    
    -- Select all text and take focus
    zo_callLater(function()
        editBoxControl:SelectAll()
        editBoxControl:TakeFocus()
        CM.DebugPrint("UI", "Regenerated - Text selected and ready to copy")
    end, 100)
end


-- =====================================================
-- MARKDOWN CHUNKING
-- =====================================================

-- Split markdown into chunks with new strategy:
-- 1. Each chunk no larger than 21,200 characters of data
-- 2. Always ends on a complete line (never split a line)
-- 3. After last line, pad with spaces up to 21,500 total characters
-- Formula: 21500 = x (data chars) + y (spaces)
local function SplitMarkdownIntoChunks(markdown)
    local chunks = {}
    local markdownLength = string.len(markdown)
    local maxDataChars = 21200  -- Maximum data characters per chunk
    local targetChunkSize = 21500  -- Target total size (data + padding)
    
    -- If content fits in one chunk, return as-is (no padding for single/final chunk)
    if markdownLength <= maxDataChars then
        return {
            {content = markdown}
        }
    end
    
    -- Split into chunks, always ending on complete lines
    local chunkNum = 1
    local pos = 1
    
    while pos <= markdownLength do
        -- Calculate potential end position (maxDataChars from current position)
        local potentialEnd = math.min(pos + maxDataChars - 1, markdownLength)
        
        -- Find the last newline before or at the potential end
        -- CRITICAL: Always end on a complete line, never split a line
        local chunkEnd = potentialEnd
        
        if potentialEnd < markdownLength then
            -- Search backwards for a newline within the chunk
            -- Search up to 1000 chars back to find a safe break point
            local searchStart = math.max(pos, potentialEnd - 1000)
            local foundNewline = false
            
            for i = potentialEnd, searchStart, -1 do
                local char = string.sub(markdown, i, i)
                if char == "\n" then
                    chunkEnd = i
                    foundNewline = true
                    break
                end
            end
            
            -- If no newline found within search range, search further back
            if not foundNewline and potentialEnd > pos then
                local extendedSearchStart = math.max(pos, potentialEnd - 5000)
                for i = potentialEnd, extendedSearchStart, -1 do
                    local char = string.sub(markdown, i, i)
                    if char == "\n" then
                        chunkEnd = i
                        foundNewline = true
                        break
                    end
                end
            end
            
            -- Last resort: if still no newline found, use potentialEnd but warn
            if not foundNewline then
                CM.Warn(string.format("Chunk %d: No newline found within safe range, using position %d", chunkNum, potentialEnd))
                chunkEnd = potentialEnd
            end
        end
        
        -- Extract the chunk data (complete lines only)
        local chunkData = string.sub(markdown, pos, chunkEnd)
        local dataChars = string.len(chunkData)
        
        -- Check if this is the last chunk (reached end of markdown)
        local isLastChunk = (chunkEnd >= markdownLength)
        
        -- Calculate padding: targetChunkSize = dataChars + spaces
        -- Formula: 21500 = x (data chars) + y (spaces)
        -- IMPORTANT: Do NOT apply padding to the final chunk
        local spacesNeeded = 0
        if not isLastChunk then
            spacesNeeded = targetChunkSize - dataChars
            
            -- Ensure we don't have negative padding (shouldn't happen, but safety check)
            if spacesNeeded < 0 then
                CM.Warn(string.format("Chunk %d: Data exceeds target size (%d > %d), no padding added", chunkNum, dataChars, targetChunkSize))
                spacesNeeded = 0
            end
        end
        
        -- Pad with spaces to reach exactly 21,500 characters (except for last chunk)
        local padding = (spacesNeeded > 0) and string.rep(" ", spacesNeeded) or ""
        local chunkContent = chunkData .. padding
        
        -- Verify final chunk size
        -- Non-last chunks should be exactly 21,500; last chunk is unpadded
        local finalSize = string.len(chunkContent)
        if not isLastChunk and finalSize ~= targetChunkSize then
            CM.Warn(string.format("Chunk %d: Final size mismatch (expected %d, got %d)", chunkNum, targetChunkSize, finalSize))
        elseif isLastChunk then
            CM.DebugPrint("UI", string.format("Chunk %d (final): %d chars (no padding applied)", chunkNum, finalSize))
        end
        
        table.insert(chunks, {
            content = chunkContent
        })
        
        -- Move to next chunk (start after the newline)
        pos = chunkEnd + 1
        chunkNum = chunkNum + 1
        
        -- Safety check to prevent infinite loop
        if pos > markdownLength then
            break
        end
    end
    
    -- Log chunking results
    if #chunks > 1 then
        CM.DebugPrint("UI", string.format("Split markdown into %d chunks (total: %d chars)", #chunks, markdownLength))
        for i, chunk in ipairs(chunks) do
            local chunkLen = string.len(chunk.content)
            local dataLen = chunkLen
            -- Try to detect padding (trailing spaces)
            local paddingMatch = chunk.content:match("%s+$")
            if paddingMatch then
                dataLen = chunkLen - string.len(paddingMatch)
            end
            CM.DebugPrint("UI", string.format("  Chunk %d: %d total chars (%d data + %d padding)", 
                i, chunkLen, dataLen, chunkLen - dataLen))
        end
    end
    
    return chunks
end

-- =====================================================
-- CHUNK NAVIGATION
-- =====================================================

local function ShowChunk(chunkIndex)
    if not markdownChunks or #markdownChunks == 0 then
        return false
    end
    
    if chunkIndex < 1 or chunkIndex > #markdownChunks then
        CM.Warn(string.format("Invalid chunk index: %d (range: 1-%d)", chunkIndex, #markdownChunks))
        return false
    end
    
    currentChunkIndex = chunkIndex
    local chunk = markdownChunks[currentChunkIndex]
    
    if not chunk then
        CM.Error("Chunk not found")
        return false
    end
    
    -- Update EditBox
    editBoxControl:SetEditEnabled(true)
    editBoxControl:SetText(chunk.content)
    editBoxControl:SetColor(1, 1, 1, 1)
    editBoxControl:SetEditEnabled(false)
    
    -- Update instructions
    local instructionsLabel = CharacterMarkdownWindowInstructions
    local prevButton = CharacterMarkdownWindowButtonContainerPrevChunkButton
    local nextButton = CharacterMarkdownWindowButtonContainerNextChunkButton
    
    if instructionsLabel and #markdownChunks > 1 then
        instructionsLabel:SetText(string.format(
            "Chunk %d/%d | PageUp/PageDown to navigate | Copy each chunk separately",
            currentChunkIndex, #markdownChunks
        ))
    end
    
    -- Show/hide navigation buttons
    if #markdownChunks > 1 then
        if prevButton then 
            prevButton:SetHidden(false)
            prevButton:SetAlpha(1)
        end
        if nextButton then 
            nextButton:SetHidden(false)
            nextButton:SetAlpha(1)
        end
    else
        if prevButton then prevButton:SetHidden(true) end
        if nextButton then nextButton:SetHidden(true) end
    end
    
    -- Auto-select for copying
    zo_callLater(function()
        if not windowControl:IsHidden() then
            editBoxControl:SetEditEnabled(true)
            editBoxControl:TakeFocus()
            editBoxControl:SelectAll()
            editBoxControl:SetEditEnabled(false)
            CM.DebugPrint("UI", string.format("Switched to chunk %d/%d", currentChunkIndex, #markdownChunks))
        end
    end, 50)
    
    return true
end

function CharacterMarkdown_NextChunk()
    if #markdownChunks <= 1 then
        CM.Info("Only one chunk available")
        return
    end
    
    local nextIndex = currentChunkIndex + 1
    if nextIndex > #markdownChunks then
        nextIndex = 1  -- Wrap to first
    end
    
    ShowChunk(nextIndex)
end

function CharacterMarkdown_PreviousChunk()
    if #markdownChunks <= 1 then
        CM.Info("Only one chunk available")
        return
    end
    
    local prevIndex = currentChunkIndex - 1
    if prevIndex < 1 then
        prevIndex = #markdownChunks  -- Wrap to last
    end
    
    ShowChunk(prevIndex)
end

-- =====================================================
-- SHOW WINDOW FUNCTION
-- =====================================================

function CharacterMarkdown_ShowWindow(markdown, format)
    -- Validate inputs
    if not markdown or markdown == "" then
        CM.Error("No markdown content provided to window")
        return false
    end
    
    format = format or "github"
    
    -- Store current format for regeneration
    CM.currentFormat = format
    
    -- Initialize controls if needed
    if not InitializeWindowControls() then
        CM.Error("Window initialization failed")
        return false
    end
    
    -- Store full markdown for clipboard operations
    currentMarkdown = markdown
    
    -- Log markdown length for debugging
    local markdownLength = string.len(markdown)
    CM.DebugPrint("UI", string.format("Setting markdown text (%d characters)", markdownLength))
    
    -- Split markdown into chunks
    markdownChunks = SplitMarkdownIntoChunks(markdown)
    currentChunkIndex = 1
    
    if #markdownChunks > 1 then
        CM.Info(string.format("📦 Split into %d chunks (content: %d chars)", 
            #markdownChunks, markdownLength))
        CM.Info("💡 Use Next/Previous buttons or PageUp/PageDown to navigate chunks")
        
        -- Log chunk info
        for i, chunk in ipairs(markdownChunks) do
            CM.DebugPrint("UI", string.format("  Chunk %d: %d chars", i, string.len(chunk.content)))
        end
    end
    
    -- Display first chunk
    ShowChunk(1)
    
    -- Show window
    windowControl:SetHidden(false)
    
    -- Bring window to top and activate
    if windowControl.SetTopmost then
        windowControl:SetTopmost(true)
    end
    
    -- Try to activate the window (ESO-specific)
    if windowControl.Activate then
        windowControl:Activate()
    end
    
    -- Request focus immediately
    if windowControl.RequestMoveToForeground then
        windowControl:RequestMoveToForeground()
    end
    
    -- Try to push to front using scene manager if available
    if SCENE_MANAGER and SCENE_MANAGER.GetCurrentScene then
        local currentScene = SCENE_MANAGER:GetCurrentScene()
        if currentScene and currentScene.PushActionLayerByName then
            -- This helps bring the window to front
            zo_callLater(function()
                if not windowControl:IsHidden() then
                    windowControl:SetHidden(false)  -- Refresh visibility
                end
            end, 50)
        end
    end
    
    -- Auto-select text and take focus after a delay (increased delay to ensure window is visible)
    zo_callLater(function()
        -- Ensure window is still visible
        if not windowControl:IsHidden() then
            -- Try multiple methods to get focus
            -- Method 1: Set topmost and take focus on window
            if windowControl.SetTopmost then
                windowControl:SetTopmost(true)
            end
            if windowControl.RequestMoveToForeground then
                windowControl:RequestMoveToForeground()
            end
            
            -- Method 2: Take focus on EditBox
            editBoxControl:SetEditEnabled(true)  -- Temporarily enable to take focus
            editBoxControl:TakeFocus()
            editBoxControl:SelectAll()
            
            -- Method 3: Try keyboard focus method
            if editBoxControl.SetKeyboardEnabled then
                editBoxControl:SetKeyboardEnabled(true)
            end
            
            -- Try one more time after a short delay to ensure focus sticks
            zo_callLater(function()
                if not windowControl:IsHidden() then
                    -- Refresh window state
                    windowControl:SetHidden(false)
                    if windowControl.SetTopmost then
                        windowControl:SetTopmost(true)
                    end
                    if windowControl.RequestMoveToForeground then
                        windowControl:RequestMoveToForeground()
                    end
                    
                    -- Final focus attempt
                    editBoxControl:TakeFocus()
                    editBoxControl:SelectAll()
                    editBoxControl:SetEditEnabled(false)  -- Back to read-only
                end
            end, 50)
            
            CM.DebugPrint("UI", "Window opened successfully - Markdown ready to copy")
        end
    end, 200)  -- Increased delay to ensure window is fully rendered
    
    return true
end

-- =====================================================
-- CLOSE WINDOW FUNCTION
-- =====================================================

function CharacterMarkdown_CloseWindow()
    if windowControl then
        if windowControl.SetTopmost then
            windowControl:SetTopmost(false)
        end
        windowControl:SetHidden(true)
        currentMarkdown = ""
        CM.DebugPrint("UI", "Window closed")
    end
end

-- =====================================================
-- INITIALIZE ON ADDON LOADED
-- =====================================================


-- Keyboard navigation handler
local function OnKeyDown(eventCode, ctrlPressed, shiftPressed, altPressed, commandPressed)
    -- Only handle when window is visible and has multiple chunks
    if not windowControl or windowControl:IsHidden() or #markdownChunks <= 1 then
        return
    end
    
    -- Check if EditBox has focus
    if editBoxControl and editBoxControl:HasFocus() then
        if eventCode == KEY_PAGE_UP or eventCode == KEY_MOUSE_WHEEL_UP then
            CharacterMarkdown_PreviousChunk()
        elseif eventCode == KEY_PAGE_DOWN or eventCode == KEY_MOUSE_WHEEL_DOWN then
            CharacterMarkdown_NextChunk()
        end
    end
end

local function OnAddOnLoaded(event, addonName)
    if addonName ~= "CharacterMarkdown" then
        return
    end
    
    zo_callLater(function()
        InitializeWindowControls()
        
        -- Register keyboard navigation
        if EVENT_MANAGER then
            EVENT_MANAGER:RegisterForEvent("CharacterMarkdown_KeyNav", EVENT_KEYBOARD_KEY_DOWN, OnKeyDown)
        end
    end, 100)
end

EVENT_MANAGER:RegisterForEvent("CharacterMarkdown_UI", EVENT_ADD_ON_LOADED, OnAddOnLoaded)

CM.DebugPrint("UI", "Window module loaded successfully")
