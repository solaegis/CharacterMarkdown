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
local copyChunkIndex = 1  -- Track which chunk we're copying

-- Clear chunks to prevent memory leak
local function ClearChunks()
    markdownChunks = {}
    currentChunkIndex = 1
    currentMarkdown = ""
    CM.DebugPrint("UI", "Chunks cleared")
end

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
    
    if clipboardEditBoxControl then
        -- Configure clipboard EditBox with higher limit if possible
        clipboardEditBoxControl:SetMaxInputChars(22000)  -- Same limit as main EditBox
        clipboardEditBoxControl:SetMultiLine(true)
        clipboardEditBoxControl:SetNewLineEnabled(true)
        CM.DebugPrint("UI", "Clipboard EditBox configured")
    else
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
    
    local markdownLength = string.len(currentMarkdown)
    local CHUNKING = CM.constants and CM.constants.CHUNKING
    local EDITBOX_LIMIT = (CHUNKING and CHUNKING.EDITBOX_LIMIT) or 10000
    
    -- If markdown exceeds EditBox limit and we have chunks, copy current chunk
    if markdownLength > EDITBOX_LIMIT and #markdownChunks > 1 then
        -- Copy the currently displayed chunk
        local chunkToCopy = markdownChunks[currentChunkIndex]
        if not chunkToCopy then
            CM.Warn("Current chunk not found")
            return
        end
        
        -- Strip padding from chunk before copying (padding is only for chunking logic)
        local chunkContent = chunkToCopy.content
        local isLastChunk = (currentChunkIndex == #markdownChunks)
        local paddingSize = (CHUNKING and CHUNKING.SPACE_PADDING_SIZE) or 85
        
        -- Strip padding from all chunks (including last chunk)
        -- Padding format: content + 85 spaces + newline + newline
        local paddingPattern = string.rep(" ", paddingSize) .. "\n\n"
        -- Check if chunk ends with padding (85 spaces + newline + newline)
        if string.sub(chunkContent, -(paddingSize + 2), -1) == paddingPattern then
            -- Remove padding: keep content, remove 85 spaces + 2 newlines, keep single newline
            chunkContent = string.sub(chunkContent, 1, -(paddingSize + 2)) .. "\n"
            CM.DebugPrint("UI", string.format("Stripped padding from chunk %d/%d for copy", currentChunkIndex, #markdownChunks))
        end
        
        local chunkSize = string.len(chunkContent)
        CM.Info(string.format("Copying chunk %d of %d (%d characters, padding removed)", currentChunkIndex, #markdownChunks, chunkSize))
        
        if #markdownChunks > 1 then
            CM.Info(string.format("Total content: %d chars in %d chunks", markdownLength, #markdownChunks))
            CM.Info("Tip: Navigate to other chunks and copy each one, then paste them together")
        end
        
        -- Copy current chunk (without padding)
        editBoxControl:SetEditEnabled(true)
        editBoxControl:SetText(chunkContent)
        editBoxControl:SetColor(1, 1, 1, 1)
        editBoxControl:SetEditEnabled(false)
        
        zo_callLater(function()
            editBoxControl:SelectAll()
            editBoxControl:TakeFocus()
            
            -- Verify what's actually in the EditBox (for debugging)
            local actualText = editBoxControl:GetText()
            local actualLength = string.len(actualText)
            local expectedLength = string.len(chunkContent)
            if actualLength ~= expectedLength then
                CM.Warn(string.format("Chunk %d: EditBox text length mismatch (expected %d, got %d)", 
                    currentChunkIndex, expectedLength, actualLength))
            end
            
            -- Check if text ends with newlines (to verify SelectAll will get them)
            local lastChars = string.sub(actualText, -2, -1)
            if lastChars == "\n\n" then
                CM.DebugPrint("UI", string.format("Chunk %d: Ends with double newline - SelectAll should include both", currentChunkIndex))
            elseif string.sub(actualText, -1, -1) == "\n" then
                CM.DebugPrint("UI", string.format("Chunk %d: Ends with single newline - SelectAll should include it", currentChunkIndex))
            else
                CM.Warn(string.format("Chunk %d: Does not end with newline - may cause paste issues", currentChunkIndex))
            end
            
            CM.DebugPrint("UI", string.format("Chunk %d selected (%d chars) - Press Ctrl+C to copy", currentChunkIndex, actualLength))
        end, 100)
    else
        -- Content fits in EditBox - copy normally
        -- But still check size to be safe
        if markdownLength > EDITBOX_LIMIT then
            CM.Warn(string.format("Content size %d exceeds EditBox limit %d - may truncate", markdownLength, EDITBOX_LIMIT))
            -- Truncate at last newline before limit
            local truncated = string.sub(currentMarkdown, 1, EDITBOX_LIMIT)
            local lastNewline = nil
            for i = string.len(truncated), 1, -1 do
                if string.sub(truncated, i, i) == "\n" then
                    lastNewline = i
                    break
                end
            end
            if lastNewline then
                currentMarkdown = string.sub(truncated, 1, lastNewline)
            else
                currentMarkdown = truncated
            end
            CM.Warn(string.format("Truncated to %d chars for copying", string.len(currentMarkdown)))
        end
        
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
    
    if not markdown then
        CM.Error("Generated markdown is nil")
        return
    end
    
    -- Handle both string (single chunk) and table (chunks array) returns
    local isChunksArray = type(markdown) == "table"
    
    if isChunksArray then
        if #markdown == 0 then
            CM.Error("Generated markdown chunks array is empty")
            return
        end
        
        -- Update chunks
        markdownChunks = markdown
        currentChunkIndex = 1
        
        -- Store full markdown as concatenated chunks for clipboard operations
        -- CRITICAL: Strip padding (85 spaces + newline) when concatenating for paste
        -- Padding is only needed for chunking logic, not for final paste output
        local fullMarkdown = ""
        local CHUNKING = CM.constants and CM.constants.CHUNKING
        local paddingSize = (CHUNKING and CHUNKING.SPACE_PADDING_SIZE) or 85
        
        for i, chunk in ipairs(markdownChunks) do
            local chunkContent = chunk.content
            local isLastChunk = (i == #markdownChunks)
            
            -- Strip padding from all chunks (85 spaces + newline + newline)
            -- Padding is only needed for chunking logic, not for final paste output
            -- Padding format: content + 85 spaces + newline + newline
            local paddingPattern = string.rep(" ", paddingSize) .. "\n\n"
            -- Check if chunk ends with padding (85 spaces + newline + newline)
            if string.sub(chunkContent, -(paddingSize + 2), -1) == paddingPattern then
                -- Remove padding: keep content, remove 85 spaces + 2 newlines, keep single newline
                chunkContent = string.sub(chunkContent, 1, -(paddingSize + 2)) .. "\n"
                CM.DebugPrint("UI", string.format("Stripped padding from chunk %d/%d for paste", i, #markdownChunks))
            end
            
            -- Verify chunk ends with newline (unless it's the very last chunk)
            -- This prevents mid-line/mid-link splits when concatenating
            if not isLastChunk then
                local lastChar = string.sub(chunkContent, -1, -1)
                if lastChar ~= "\n" then
                    CM.Warn(string.format("Chunk %d/%d: Missing newline at end, adding one to prevent paste truncation", i, #markdownChunks))
                    chunkContent = chunkContent .. "\n"
                end
            end
            
            fullMarkdown = fullMarkdown .. chunkContent
        end
        currentMarkdown = fullMarkdown
        
        -- Show first chunk
        ShowChunk(1)
    else
        if markdown == "" then
            CM.Error("Generated markdown is empty")
            return
        end
        
        -- Update stored markdown
        currentMarkdown = markdown
        
        -- Wrap in chunks array format
        markdownChunks = {{content = markdown}}
        currentChunkIndex = 1
        
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
end


-- =====================================================
-- MARKDOWN CHUNKING
-- =====================================================
-- Note: Chunking is now handled in Markdown.lua after full generation
-- This module only handles displaying chunks received from the generator

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
    
    -- Safety check: ensure chunk content doesn't exceed EditBox limit
    local chunkContent = chunk.content
    local chunkSize = string.len(chunkContent)
    local CHUNKING = CM.constants and CM.constants.CHUNKING
    local EDITBOX_LIMIT = (CHUNKING and CHUNKING.EDITBOX_LIMIT) or 10000
    
    if chunkSize > EDITBOX_LIMIT then
        CM.Error(string.format("Chunk %d: Size %d exceeds EditBox limit %d, truncating!", chunkIndex, chunkSize, EDITBOX_LIMIT))
        -- Truncate at last newline before limit
        local truncated = string.sub(chunkContent, 1, EDITBOX_LIMIT)
        local lastNewline = nil
        for i = string.len(truncated), 1, -1 do
            if string.sub(truncated, i, i) == "\n" then
                lastNewline = i
                break
            end
        end
        if lastNewline then
            chunkContent = string.sub(truncated, 1, lastNewline)
        else
            chunkContent = truncated
        end
        CM.Warn(string.format("Chunk %d: Truncated from %d to %d chars", chunkIndex, chunkSize, string.len(chunkContent)))
    end
    
    -- Update EditBox
    editBoxControl:SetEditEnabled(true)
    editBoxControl:SetText(chunkContent)
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
    if not markdown then
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
    
    -- Handle both string (single chunk) and table (chunks array) returns
    local isChunksArray = type(markdown) == "table"
    
    if isChunksArray then
        -- Already chunked - use directly
        markdownChunks = markdown
        currentChunkIndex = 1
        
        -- Calculate total markdown size for storage
        local totalSize = 0
        for _, chunk in ipairs(markdownChunks) do
            totalSize = totalSize + string.len(chunk.content)
        end
        
        -- Store full markdown as concatenated chunks for clipboard operations
        -- CRITICAL: Strip padding (85 spaces + newline) when concatenating for paste
        -- Padding is only needed for chunking logic, not for final paste output
        local fullMarkdown = ""
        local CHUNKING = CM.constants and CM.constants.CHUNKING
        local paddingSize = (CHUNKING and CHUNKING.SPACE_PADDING_SIZE) or 85
        
        for i, chunk in ipairs(markdownChunks) do
            local chunkContent = chunk.content
            local isLastChunk = (i == #markdownChunks)
            
            -- Strip padding from all chunks (85 spaces + newline + newline)
            -- Padding is only needed for chunking logic, not for final paste output
            -- Padding format: content + 85 spaces + newline + newline
            local paddingPattern = string.rep(" ", paddingSize) .. "\n\n"
            -- Check if chunk ends with padding (85 spaces + newline + newline)
            if string.sub(chunkContent, -(paddingSize + 2), -1) == paddingPattern then
                -- Remove padding: keep content, remove 85 spaces + 2 newlines, keep single newline
                chunkContent = string.sub(chunkContent, 1, -(paddingSize + 2)) .. "\n"
                CM.DebugPrint("UI", string.format("Stripped padding from chunk %d/%d for paste", i, #markdownChunks))
            end
            
            -- Verify chunk ends with newline (unless it's the very last chunk)
            -- This prevents mid-line/mid-link splits when concatenating
            if not isLastChunk then
                local lastChar = string.sub(chunkContent, -1, -1)
                if lastChar ~= "\n" then
                    CM.Warn(string.format("Chunk %d/%d: Missing newline at end, adding one to prevent paste truncation", i, #markdownChunks))
                    chunkContent = chunkContent .. "\n"
                end
            end
            
            fullMarkdown = fullMarkdown .. chunkContent
        end
        currentMarkdown = fullMarkdown
        
        CM.DebugPrint("UI", string.format("Received %d chunks (total: %d characters, after padding removal)", #markdownChunks, string.len(fullMarkdown)))
    else
        -- Single string - should already be chunked by Markdown.lua if needed
        -- But handle edge case where a single string was passed that exceeds limit
        if markdown == "" then
            CM.Error("Markdown content is empty")
            return false
        end
        
        local markdownLength = string.len(markdown)
        local CHUNKING = CM.constants and CM.constants.CHUNKING
        local EDITBOX_LIMIT = (CHUNKING and CHUNKING.EDITBOX_LIMIT) or 10000
        
        -- If single string exceeds limit, chunk it (shouldn't happen if Markdown.lua is working correctly)
        if markdownLength > EDITBOX_LIMIT then
            CM.Warn(string.format("Single string exceeds limit (%d > %d) - this should have been chunked in Markdown.lua", markdownLength, EDITBOX_LIMIT))
            CM.DebugPrint("UI", "Chunking single string as fallback...")
            -- Use the consolidated chunking utility
            local Chunking = CM.utils and CM.utils.Chunking
            local SplitMarkdownIntoChunksUtil = Chunking and Chunking.SplitMarkdownIntoChunks
            if SplitMarkdownIntoChunksUtil then
                markdownChunks = SplitMarkdownIntoChunksUtil(markdown)
            else
                CM.Error("Chunking utility not available - markdown may be truncated!")
                -- Fallback: wrap as single chunk (will be truncated by EditBox)
                markdownChunks = {{content = markdown}}
            end
            currentChunkIndex = 1
            
            -- Store full markdown as concatenated chunks for clipboard operations
            -- CRITICAL: Strip padding (85 spaces + newline) when concatenating for paste
            -- Padding is only needed for chunking logic, not for final paste output
            local fullMarkdown = ""
            local CHUNKING = CM.constants and CM.constants.CHUNKING
            local paddingSize = (CHUNKING and CHUNKING.SPACE_PADDING_SIZE) or 85
            
            for i, chunk in ipairs(markdownChunks) do
                local chunkContent = chunk.content
                local isLastChunk = (i == #markdownChunks)
                
                -- Strip padding from non-last chunks (85 spaces + newline = 86 chars)
                if not isLastChunk then
                    local paddingPattern = string.rep(" ", paddingSize) .. "\n"
                    -- Remove padding from end of chunk if present
                    if string.sub(chunkContent, -(paddingSize + 1), -1) == paddingPattern then
                        chunkContent = string.sub(chunkContent, 1, -(paddingSize + 2))
                        CM.DebugPrint("UI", string.format("Stripped padding from chunk %d/%d for paste", i, #markdownChunks))
                    end
                end
                
                -- Verify chunk ends with newline (unless it's the very last chunk)
                -- This prevents mid-line/mid-link splits when concatenating
                if not isLastChunk then
                    local lastChar = string.sub(chunkContent, -1, -1)
                    if lastChar ~= "\n" then
                        CM.Warn(string.format("Chunk %d/%d: Missing newline at end, adding one to prevent paste truncation", i, #markdownChunks))
                        chunkContent = chunkContent .. "\n"
                    end
                end
                
                fullMarkdown = fullMarkdown .. chunkContent
            end
            currentMarkdown = fullMarkdown
            
            CM.DebugPrint("UI", string.format("Fallback chunked into %d chunks", #markdownChunks))
        else
            -- Store full markdown for clipboard operations
            currentMarkdown = markdown
            
            CM.DebugPrint("UI", string.format("Received single chunk (%d characters)", markdownLength))
            
            -- Wrap in chunks array format
            markdownChunks = {{content = markdown}}
            currentChunkIndex = 1
        end
    end
    
    if #markdownChunks > 1 then
        local totalSize = 0
        for _, chunk in ipairs(markdownChunks) do
            totalSize = totalSize + string.len(chunk.content)
        end
        CM.Info(string.format("📦 Split into %d chunks (content: %d chars)", 
            #markdownChunks, totalSize))
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
        ClearChunks()  -- Clear chunks to prevent memory leak
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
