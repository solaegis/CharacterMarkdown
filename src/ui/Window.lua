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
local currentMarkdown = ""
local markdownChunks = {} -- Array of markdown chunks
local currentChunkIndex = 1
local copyChunkIndex = 1 -- Track which chunk we're copying

-- Forward declarations
local ShowChunk

-- Clear chunks to prevent memory leak
local function ClearChunks()
    markdownChunks = {}
    currentChunkIndex = 1
    copyChunkIndex = 1
    currentMarkdown = ""
    CM.DebugPrint("UI", "Chunks cleared")
end

-- =====================================================
-- SELECTION STATE TRACKING
-- =====================================================

-- Track selection state
local isTextSelected = false

-- Check if EditBox has selected text and update button color
local function UpdateSelectAllButtonColor()
    if not windowControl or windowControl:IsHidden() or not editBoxControl then
        return
    end
    
    local selectAllButton = CharacterMarkdownWindowButtonContainerSelectAllButtonLabel
    if not selectAllButton then
        return
    end
    
    -- Keep button green while text is selected
    -- Button turns green when SelectAll is called, stays green until chunk changes or window closes
    if isTextSelected then
        selectAllButton:SetColor(0, 1, 0, 1) -- Green
    else
        selectAllButton:SetColor(1, 1, 1, 1) -- White
    end
end

-- Reset selection state
local function ResetSelectionState()
    isTextSelected = false
    UpdateSelectAllButtonColor()
end

-- Set selection state to selected
local function SetSelectionState()
    isTextSelected = true
    UpdateSelectAllButtonColor()
end

-- =====================================================
-- INITIALIZE WINDOW CONTROLS
-- =====================================================

-- Helper to ensure window has keyboard focus
-- MODIFIED: Don't give EditBox focus - let global handler work instead
local function EnsureWindowHasKeyboardFocus()
    if windowControl and not windowControl:IsHidden() then
        -- CRITICAL: Enable keyboard on window only (NOT EditBox)
        windowControl:SetKeyboardEnabled(true)
        
        -- DO NOT take focus on EditBox - this would trigger EditBox OnKeyDown handler
        -- Instead, let the global EVENT_KEY_DOWN handler catch all keys
        
        -- Window focus methods
        if windowControl.TakeFocus then
            windowControl:TakeFocus()
        end
        if windowControl.SetTopmost then
            windowControl:SetTopmost(true)
        end
        
        CM.DebugPrint("KEYBOARD", "Window keyboard focus ensured (EditBox intentionally NOT focused)")
    end
end

local function InitializeWindowControls()
    if windowControl then
        return true -- Already initialized
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

    -- Configure EditBox with character limit
    -- Note: ESO EditBox may have internal limits despite SetMaxInputChars
    editBoxControl:SetMaxInputChars(22000) -- 22k character limit
    editBoxControl:SetMultiLine(true)
    editBoxControl:SetNewLineEnabled(true)
    -- CRITICAL: Disable editing to prevent text input
    editBoxControl:SetEditEnabled(false)
    -- CRITICAL: EditBox MUST have keyboard enabled to receive OnKeyDown events
    -- We prevent text input via OnChar and OnKeyDown handlers, not by disabling keyboard
    editBoxControl:SetMouseEnabled(true)
    editBoxControl:SetKeyboardEnabled(true)  -- MUST BE TRUE to receive keyboard events
    
    -- Prevent text editing by intercepting text changes (ONLY in import mode)
    editBoxControl:SetHandler("OnTextChanged", function(self)
        -- Only active in import mode - otherwise do nothing
        if windowControl and windowControl._isImportMode then
            -- Update stored text for import mode
            self._originalText = self:GetText()
        end
        -- In normal mode, OnKeyDown handler prevents text input by consuming keys
        -- So OnTextChanged should rarely fire except when we programmatically set text
    end)

    -- Verify the actual limit that was set
    -- Note: ESO EditBox may have hardcoded internal limits regardless of SetMaxInputChars
    local actualMaxChars = editBoxControl:GetMaxInputChars()
    if actualMaxChars then
        CM.Info(string.format("✓ EditBox initialized: max input %d chars (requested 22000)", actualMaxChars))
        if actualMaxChars < 22000 then
            CM.Warn(string.format("⚠ EditBox limited to %d by ESO (requested 22000)", actualMaxChars))
            CM.Warn("This may affect large character profiles. Please report if you see truncation.")
        end
        -- Log chunking configuration for validation
        local CHUNKING = CM.constants and CM.constants.CHUNKING
        if CHUNKING then
            CM.Info(string.format("  Chunking limits: EDITBOX=%d, COPY=%d, MAX_DATA=%d", 
                CHUNKING.EDITBOX_LIMIT or 0,
                CHUNKING.COPY_LIMIT or 0,
                CHUNKING.MAX_DATA_CHARS or 0
            ))
        end
    else
        CM.Warn("⚠ Could not query EditBox max input chars - this may indicate an ESO API issue")
    end

    -- Set to WHITE text on DARK background
    editBoxControl:SetFont("ZoFontChat")
    editBoxControl:SetColor(1, 1, 1, 1) -- White text

    -- CRITICAL: Block ALL character input using OnChar handler
    -- OnChar fires when a character would be added - we prevent ALL of them
    editBoxControl:SetHandler("OnChar", function(self, char)
        -- Allow character input ONLY in import mode
        if windowControl and windowControl._isImportMode then
            return false -- Allow the character
        end
        
        -- Block ALL character input in normal mode
        CM.DebugPrint("KEYBOARD", string.format("Blocked character input: %s (code: %d)", char, string.byte(char)))
        return true -- Consume event - prevents character from being added
    end)

    -- CRITICAL: OnKeyDown handler on EditBox to intercept keys BEFORE they become text input
    -- This handler fires when EditBox has focus and receives keyboard events
    editBoxControl:SetHandler("OnKeyDown", function(self, key, ctrl, alt, shift, command)
        CM.DebugPrint("KEYBOARD", string.format("[EditBox] OnKeyDown FIRED: key=%d, ctrl=%s, cmd=%s", 
            key, tostring(ctrl), tostring(command)))
        
        -- Allow text input in import mode
        if windowControl and windowControl._isImportMode then
            CM.DebugPrint("KEYBOARD", "[EditBox] In import mode - allowing key")
            return false -- Let EditBox process the key normally
        end
        
        -- Only handle when window is visible
        if not windowControl or windowControl:IsHidden() then
            CM.DebugPrint("KEYBOARD", "[EditBox] Window not visible - ignoring key")
            return false
        end
        
        local modifierPressed = ctrl or command
        
        -- ESC or X = Close window
        if key == KEY_ESCAPE or key == KEY_X then
            CM.DebugPrint("KEYBOARD", "[EditBox] ESC/X pressed - closing window")
            windowControl:SetHidden(true)
            return true -- Consume event
        end
        
        -- G = Generate (without modifiers)
        if key == KEY_G and not modifierPressed then
            CM.DebugPrint("KEYBOARD", "[EditBox] G pressed - calling RegenerateMarkdown()")
            if CharacterMarkdown_RegenerateMarkdown then
                CharacterMarkdown_RegenerateMarkdown()
                CM.DebugPrint("KEYBOARD", "[EditBox] RegenerateMarkdown() called successfully")
            else
                CM.Error("[EditBox] CharacterMarkdown_RegenerateMarkdown is nil!")
            end
            zo_callLater(EnsureWindowHasKeyboardFocus, 100)  -- Restore focus after action
            return true -- Consume event to prevent "g" from appearing
        end
        
        -- S = Settings (without modifiers)
        if key == KEY_S and not modifierPressed then
            CM.DebugPrint("KEYBOARD", "[EditBox] S pressed - calling OpenSettings()")
            if CharacterMarkdown_OpenSettings then
                CharacterMarkdown_OpenSettings()
                CM.DebugPrint("KEYBOARD", "[EditBox] OpenSettings() called successfully")
            else
                CM.Error("[EditBox] CharacterMarkdown_OpenSettings is nil!")
            end
            zo_callLater(EnsureWindowHasKeyboardFocus, 100)  -- Restore focus after action
            return true -- Consume event
        end
        
        -- R = ReloadUI (without modifiers)
        if key == KEY_R and not modifierPressed then
            CM.DebugPrint("KEYBOARD", "[EditBox] R pressed - calling ReloadUI()")
            ReloadUI()
            CM.DebugPrint("KEYBOARD", "[EditBox] ReloadUI() called")
            return true -- Consume event
        end
        
        -- Ctrl+A / Cmd+A = Select All
        if modifierPressed and key == KEY_A then
            CM.DebugPrint("KEYBOARD", "Ctrl+A pressed - selecting all")
            self:SelectAll()
            return true -- Consume event
        end
        
        -- Ctrl+C / Cmd+C = Copy (let EditBox handle it)
        if modifierPressed and key == KEY_C then
            CM.DebugPrint("KEYBOARD", "Ctrl+C pressed - allowing copy")
            return false -- Don't consume - let EditBox handle copy
        end
        
        -- Navigation: Left Arrow or Comma
        if key == KEY_LEFTARROW or key == KEY_OEM_COMMA then
            if #markdownChunks > 1 then
                CM.DebugPrint("KEYBOARD", "[EditBox] Left/Comma pressed - calling PreviousChunk()")
                if CharacterMarkdown_PreviousChunk then
                    CharacterMarkdown_PreviousChunk()
                    CM.DebugPrint("KEYBOARD", "[EditBox] PreviousChunk() called successfully")
                else
                    CM.Error("[EditBox] CharacterMarkdown_PreviousChunk is nil!")
                end
                zo_callLater(EnsureWindowHasKeyboardFocus, 100)  -- Restore focus after action
                return true -- Consume event
            end
        end
        
        -- Navigation: Right Arrow or Period
        if key == KEY_RIGHTARROW or key == KEY_OEM_PERIOD then
            if #markdownChunks > 1 then
                CM.DebugPrint("KEYBOARD", "Right/Period pressed - next chunk")
                CharacterMarkdown_NextChunk()
                zo_callLater(EnsureWindowHasKeyboardFocus, 100)  -- Restore focus after action
                return true -- Consume event
            end
        end
        
        -- Navigation: PageUp
        if key == KEY_PAGEUP then
            if #markdownChunks > 1 then
                CM.DebugPrint("KEYBOARD", "PageUp pressed - previous chunk")
                CharacterMarkdown_PreviousChunk()
                zo_callLater(EnsureWindowHasKeyboardFocus, 100)  -- Restore focus after action
                return true -- Consume event
            end
        end
        
        -- Navigation: PageDown
        if key == KEY_PAGEDOWN then
            if #markdownChunks > 1 then
                CM.DebugPrint("KEYBOARD", "PageDown pressed - next chunk")
                CharacterMarkdown_NextChunk()
                zo_callLater(EnsureWindowHasKeyboardFocus, 100)  -- Restore focus after action
                return true -- Consume event
            end
        end
        
        -- Space or Enter = Select All / Copy
        if key == KEY_SPACEBAR or key == KEY_ENTER then
            CM.DebugPrint("KEYBOARD", "[EditBox] Space/Enter pressed - calling CopyToClipboard()")
            if CharacterMarkdown_CopyToClipboard then
                CharacterMarkdown_CopyToClipboard()
                CM.DebugPrint("KEYBOARD", "[EditBox] CopyToClipboard() called successfully")
            else
                CM.Error("[EditBox] CharacterMarkdown_CopyToClipboard is nil!")
            end
            zo_callLater(EnsureWindowHasKeyboardFocus, 200)  -- Longer delay for copy action
            return true -- Consume event
        end
        
        -- CRITICAL: Consume ALL other non-modifier character keys to prevent text input
        -- Allow only navigation keys (arrows, home, end, etc.) to pass through
        if not modifierPressed then
            local isNavigationKey = (
                key == KEY_UPARROW or key == KEY_DOWNARROW or 
                key == KEY_HOME or key == KEY_END or 
                key == KEY_TAB or key == KEY_BACKSPACE or key == KEY_DELETE
            )
            
            if not isNavigationKey then
                -- This is a character key - consume it to prevent text input
                CM.DebugPrint("KEYBOARD", string.format("Consuming character key: %d", key))
                return true -- Consume to prevent text input
            end
        end
        
        -- Allow navigation and modifier keys to pass through
        return false
    end)

    CM.DebugPrint("UI", "Window controls initialized successfully")
    return true
end

-- =====================================================
-- OVERLAY VISIBILITY HELPER
-- =====================================================

-- Update overlay instructions visibility based on EditBox content
local function UpdateOverlayVisibility()
    if not editBoxControl then
        return
    end
    
    local overlayLabel = CharacterMarkdownWindowTextContainerOverlayInstructions
    if not overlayLabel then
        return
    end
    
    -- Hide overlay if EditBox has content, show if empty
    local hasContent = editBoxControl._originalText and editBoxControl._originalText ~= ""
    overlayLabel:SetHidden(hasContent)
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
        local isLastChunk = (currentChunkIndex == #markdownChunks)
        local chunkContent = CM.utils.Chunking.StripPadding(chunkToCopy.content, isLastChunk)
        CM.DebugPrint(
            "UI",
            string.format("Stripped padding from chunk %d/%d for copy", currentChunkIndex, #markdownChunks)
        )

        local chunkSize = string.len(chunkContent)
        CM.DebugPrint(
            "WINDOW",
            string.format(
                "Copying chunk %d of %d (%d characters, padding removed)",
                currentChunkIndex,
                #markdownChunks,
                chunkSize
            )
        )

        if #markdownChunks > 1 then
            CM.DebugPrint("WINDOW", string.format("Total content: %d chars in %d chunks", markdownLength, #markdownChunks))
            CM.DebugPrint("WINDOW", "Tip: Navigate to other chunks and copy each one, then paste them together")
        end

        -- Copy current chunk (without padding)
        editBoxControl:SetText(chunkContent)
        editBoxControl._originalText = chunkContent  -- Store for OnTextChanged handler
        editBoxControl:SetColor(1, 1, 1, 1)
        UpdateOverlayVisibility()

        zo_callLater(function()
            editBoxControl:SelectAll()
            -- REMOVED: Don't take focus - let global handler work
            -- editBoxControl:TakeFocus()

            -- Verify what's actually in the EditBox (for debugging)
            local actualText = editBoxControl:GetText()
            local actualLength = string.len(actualText)
            local expectedLength = string.len(chunkContent)
            if actualLength ~= expectedLength then
                CM.Warn(
                    string.format(
                        "Chunk %d: EditBox text length mismatch (expected %d, got %d)",
                        currentChunkIndex,
                        expectedLength,
                        actualLength
                    )
                )
            end

            -- Check if text ends with newlines (to verify SelectAll will get them)
            local lastChars = string.sub(actualText, -2, -1)
            if lastChars == "\n\n" then
                CM.DebugPrint(
                    "UI",
                    string.format(
                        "Chunk %d: Ends with double newline - SelectAll should include both",
                        currentChunkIndex
                    )
                )
            elseif string.sub(actualText, -1, -1) == "\n" then
                CM.DebugPrint(
                    "UI",
                    string.format("Chunk %d: Ends with single newline - SelectAll should include it", currentChunkIndex)
                )
            else
                CM.Warn(
                    string.format("Chunk %d: Does not end with newline - may cause paste issues", currentChunkIndex)
                )
            end

            CM.DebugPrint(
                "UI",
                string.format("Chunk %d selected (%d chars) - Press Ctrl+C to copy", currentChunkIndex, actualLength)
            )
            
            -- Visual feedback: Change Select All button to green and keep it green
            SetSelectionState()
            
            -- Final focus as last step
            zo_callLater(function()
                if editBoxControl then
                    -- REMOVED: Don't take focus - let global handler work
            -- editBoxControl:TakeFocus()
                end
            end, 50)
        end, 100)
    else
        -- Content fits in EditBox - copy normally
        -- ASSERTION: This code path should only be reached for single-chunk content
        -- If content exceeds limit here, it's a bug in the chunking algorithm
        if markdownLength > EDITBOX_LIMIT then
            CM.Error(
                string.format(
                    "ASSERTION FAILED: Single chunk content size %d exceeds EditBox limit %d",
                    markdownLength,
                    EDITBOX_LIMIT
                )
            )
            CM.Error("This indicates a bug in the chunking algorithm - content should have been chunked!")
            CM.Error("Please report this issue with the /markdown test output")
            -- Don't truncate - let it fail visibly so the bug is noticed
        end

        editBoxControl:SetText(currentMarkdown)
        editBoxControl._originalText = currentMarkdown  -- Store for OnTextChanged handler
        editBoxControl:SetColor(1, 1, 1, 1)
        UpdateOverlayVisibility()

        zo_callLater(function()
            -- Select all (but don't take focus - let global handler work)
            editBoxControl:SelectAll()
            -- REMOVED: Don't take focus
            -- editBoxControl:TakeFocus()

            -- Only show in chat if user explicitly wants feedback
            CM.DebugPrint("UI", "Text selected - Press Ctrl+C to copy")
            
            -- Visual feedback: Change Select All button to green and keep it green
            SetSelectionState()
            
            -- Final focus as last step
            zo_callLater(function()
                if editBoxControl then
                    -- REMOVED: Don't take focus - let global handler work
            -- editBoxControl:TakeFocus()
                end
            end, 50)
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

    -- CRITICAL: Clear previous state before generating new markdown
    ClearChunks()
    
    -- Reset selection state when regenerating
    ResetSelectionState()

    -- Get current format (default to github if not stored)
    local format = CM.currentFormat or "github"

    -- Clear the window and reset UI elements
    if editBoxControl then
        editBoxControl:SetText("")
        editBoxControl._originalText = ""  -- Store for OnTextChanged handler
        UpdateOverlayVisibility()
    end
    
    -- Reset UI elements to prevent stale data display
    local instructionsLabel = CharacterMarkdownWindowInstructions
    local statusLabel = CharacterMarkdownWindowStatusIndicator
    local prevButton = CharacterMarkdownWindowNavigationContainerPrevChunkButton
    local nextButton = CharacterMarkdownWindowNavigationContainerNextChunkButton
    
    if instructionsLabel then
        instructionsLabel:SetText("")
    end
    if statusLabel then
        statusLabel:SetHidden(true)
    end
    -- Initialize navigation buttons as disabled (will be enabled if multiple chunks)
    if prevButton then
        prevButton:SetEnabled(false)
        prevButton:SetAlpha(0.5)
    end
    if nextButton then
        nextButton:SetEnabled(false)
        nextButton:SetAlpha(0.5)
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
        -- CRITICAL: Strip padding when concatenating for paste
        -- Padding is only needed for chunking logic, not for final paste output
        local fullMarkdown = ""

        for i, chunk in ipairs(markdownChunks) do
            local isLastChunk = (i == #markdownChunks)
            local chunkContent = CM.utils.Chunking.StripPadding(chunk.content, isLastChunk)
            CM.DebugPrint("UI", string.format("Stripped padding from chunk %d/%d for paste", i, #markdownChunks))

            -- Verify chunk ends with newline (unless it's the very last chunk)
            -- This prevents mid-line/mid-link splits when concatenating
            if not isLastChunk then
                local lastChar = string.sub(chunkContent, -1, -1)
                if lastChar ~= "\n" then
                    CM.Warn(
                        string.format(
                            "Chunk %d/%d: Missing newline at end, adding one to prevent paste truncation",
                            i,
                            #markdownChunks
                        )
                    )
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
        markdownChunks = { { content = markdown } }
        currentChunkIndex = 1

        -- Update the EditBox
        editBoxControl:SetText(markdown)
        editBoxControl._originalText = markdown  -- Store for OnTextChanged handler
        editBoxControl:SetColor(1, 1, 1, 1)
        UpdateOverlayVisibility()

        -- Select all text and take focus - CRITICAL: TakeFocus() as FINAL operation
        zo_callLater(function()
            if not windowControl:IsHidden() and editBoxControl then
                editBoxControl:SelectAll()
                CM.DebugPrint("UI", "Regenerated - Text selected and ready to copy")
                
                -- CRITICAL: TakeFocus() must be the LAST operation
                -- REMOVED: Don't take focus - let global handler work
            -- editBoxControl:TakeFocus()
            end
        end, 150)
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

function ShowChunk(chunkIndex)
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

    -- ASSERTION: Validate chunk size doesn't exceed EditBox limit
    local chunkContent = chunk.content
    local chunkSize = string.len(chunkContent)
    local CHUNKING = CM.constants and CM.constants.CHUNKING
    local EDITBOX_LIMIT = (CHUNKING and CHUNKING.EDITBOX_LIMIT) or 10000

    -- This should never happen if chunking algorithm is working correctly
    if chunkSize > EDITBOX_LIMIT then
        CM.Error(
            string.format(
                "ASSERTION FAILED: Chunk %d size %d exceeds EditBox limit %d",
                chunkIndex,
                chunkSize,
                EDITBOX_LIMIT
            )
        )
        CM.Error("This indicates a bug in the chunking algorithm!")
        CM.Error("Please report this issue with chunk details:")
        CM.Error(string.format("  Total chunks: %d", #markdownChunks))
        CM.Error(string.format("  Problem chunk: %d", chunkIndex))
        CM.Error(string.format("  Chunk size: %d", chunkSize))
        CM.Error(string.format("  Limit: %d", EDITBOX_LIMIT))
        -- Don't truncate - let it fail visibly so the bug is noticed
    end

    -- Update EditBox
    editBoxControl:SetText(chunkContent)
    editBoxControl._originalText = chunkContent  -- Store for OnTextChanged handler
    editBoxControl:SetColor(1, 1, 1, 1)
    UpdateOverlayVisibility()
    
    -- Reset selection state when chunk changes
    ResetSelectionState()
    
    -- Update visual progress bar
    local CHUNKING = CM.constants and CM.constants.CHUNKING
    local COPY_LIMIT = (CHUNKING and CHUNKING.COPY_LIMIT) or 21500
    local fillPercentage = (chunkSize / COPY_LIMIT) * 100
    local segmentsToFill = math.ceil((fillPercentage / 100) * 10) -- 10 segments total
    
    for i = 1, 10 do
        local segment = _G["CharacterMarkdownWindowTextContainerProgressBarSegment" .. i]
        if segment then
            if i <= segmentsToFill then
                segment:SetHidden(false) -- Show filled segments
            else
                segment:SetHidden(true) -- Hide empty segments
            end
        end
    end

    -- Update instructions
    local instructionsLabel = CharacterMarkdownWindowInstructions
    local overlayLabel = CharacterMarkdownWindowTextContainerOverlayInstructions
    local statusLabel = CharacterMarkdownWindowStatusIndicator
    local prevButton = CharacterMarkdownWindowNavigationContainerPrevChunkButton
    local nextButton = CharacterMarkdownWindowNavigationContainerNextChunkButton
    
    -- Update overlay instructions with OS-specific shortcut
    if overlayLabel then
        local shortcutText = "Ctrl+A then Ctrl+C"
        if CM.utils.Platform then
            shortcutText = CM.utils.Platform.GetShortcutText("select_copy")
        end
        overlayLabel:SetText(string.format("Press [Space] or %s to copy", shortcutText))
    end

    -- Always update instructions label to prevent stale data from previous runs
    if instructionsLabel then
        -- Get copy limit for visual display
        local COPY_LIMIT = (CHUNKING and CHUNKING.COPY_LIMIT) or 21500
        local percentage = math.floor((chunkSize / COPY_LIMIT) * 100)
        
        -- Create visual progress bar (12 blocks for better granularity and symmetry)
        -- Using ASCII characters for ESO font compatibility
        local barLength = 12
        local filledBlocks = math.floor((chunkSize / COPY_LIMIT) * barLength)
        local progressBar = ""
        for i = 1, barLength do
            if i <= filledBlocks then
                progressBar = progressBar .. "="
            else
                progressBar = progressBar .. "-"
            end
        end
        
        -- Safety indicator with ESO color codes
        local safetyBuffer = COPY_LIMIT - chunkSize
        local statusText, statusColor
        if safetyBuffer > 1000 then
            statusText = "OK"
            statusColor = "|c00FF00" -- Green
        elseif safetyBuffer > 500 then
            statusText = "WARN"
            statusColor = "|cFFFF00" -- Yellow
        else
            statusText = "FULL"
            statusColor = "|cFF0000" -- Red
        end
        
        -- Hide the separate status label (we're showing status inline now)
        if statusLabel then
            statusLabel:SetHidden(true)
        end
        
        -- Format numbers with commas (Lua doesn't support %,d in string.format)
        local function formatNumber(n)
            local formatted = tostring(n)
            local k
            while true do
                formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
                if k == 0 then break end
            end
            return formatted
        end
        
        -- Simplified chunk info display
        -- Format: Chunk X/Y • #,### / ##,### bytes • {status}
        instructionsLabel:SetText(
            string.format(
                "Chunk %d/%d  •  %s / %s bytes  •  %s%s|r",
                currentChunkIndex,
                #markdownChunks,
                formatNumber(chunkSize),
                formatNumber(COPY_LIMIT),
                statusColor,
                statusText
            )
        )
    end

    -- Enable/disable navigation buttons (always visible, greyed when unavailable)
    if #markdownChunks > 1 then
        if prevButton then
            prevButton:SetEnabled(true)
            prevButton:SetAlpha(1.0)
        end
        if nextButton then
            nextButton:SetEnabled(true)
            nextButton:SetAlpha(1.0)
        end
    else
        if prevButton then
            prevButton:SetEnabled(false)
            prevButton:SetAlpha(0.5)
        end
        if nextButton then
            nextButton:SetEnabled(false)
            nextButton:SetAlpha(0.5)
        end
    end

    -- Auto-select for copying and ensure focus
    -- CRITICAL: Single delayed call with focus as ABSOLUTE FINAL STEP
    zo_callLater(function()
        if not windowControl:IsHidden() and editBoxControl then
            editBoxControl:SelectAll()
            CM.DebugPrint("UI", string.format("Switched to chunk %d/%d", currentChunkIndex, #markdownChunks))
            
            -- CRITICAL: TakeFocus() must be the LAST operation
            -- REMOVED: Don't take focus - let global handler work
            -- editBoxControl:TakeFocus()
            CM.DebugPrint("UI", "EditBox focus set - keyboard shortcuts ready")
        end
    end, 150)
    
    -- CRITICAL: Restore window keyboard focus after chunk switch
    zo_callLater(EnsureWindowHasKeyboardFocus, 200)

    return true
end

function CharacterMarkdown_NextChunk()
    if #markdownChunks <= 1 then
        CM.Info("Only one chunk available")
        return
    end

    local nextIndex = currentChunkIndex + 1
    if nextIndex > #markdownChunks then
        nextIndex = 1 -- Wrap to first
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
        prevIndex = #markdownChunks -- Wrap to last
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

    -- CRITICAL: Clear previous state before showing new markdown
    ClearChunks()
    
    -- Reset selection state when showing window with new content
    ResetSelectionState()

    -- Store current format for regeneration
    CM.currentFormat = format

    -- Initialize controls if needed
    if not InitializeWindowControls() then
        CM.Error("Window initialization failed")
        return false
    end
    
    -- Re-enable all buttons for normal mode (in case we're coming from import/export mode)
    local regenerateButton = CharacterMarkdownWindowButtonContainerRegenerateButton
    local selectAllButton = CharacterMarkdownWindowButtonContainerSelectAllButton
    local dismissButton = CharacterMarkdownWindowButtonContainerDismiss
    
    if regenerateButton then
        regenerateButton:SetEnabled(true)
        regenerateButton:SetAlpha(1.0)
    end
    if selectAllButton then
        selectAllButton:SetEnabled(true)
        selectAllButton:SetAlpha(1.0)
    end
    if dismissButton then
        dismissButton:SetEnabled(true)
        dismissButton:SetAlpha(1.0)
        local label = dismissButton:GetNamedChild("Label")
        if label then
            label:SetText("[X] Dismiss")
        end
        dismissButton:SetHandler("OnClicked", function()
            CharacterMarkdownWindow:SetHidden(true)
        end)
    end
    
    -- Clear import mode flag
    windowControl._isImportMode = false

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
        -- CRITICAL: Strip padding when concatenating for paste
        -- Padding is only needed for chunking logic, not for final paste output
        local fullMarkdown = ""

        for i, chunk in ipairs(markdownChunks) do
            local isLastChunk = (i == #markdownChunks)
            local chunkContent = CM.utils.Chunking.StripPadding(chunk.content, isLastChunk)
            CM.DebugPrint("UI", string.format("Stripped padding from chunk %d/%d for paste", i, #markdownChunks))

            -- Verify chunk ends with newline (unless it's the very last chunk)
            -- This prevents mid-line/mid-link splits when concatenating
            if not isLastChunk then
                local lastChar = string.sub(chunkContent, -1, -1)
                if lastChar ~= "\n" then
                    CM.Warn(
                        string.format(
                            "Chunk %d/%d: Missing newline at end, adding one to prevent paste truncation",
                            i,
                            #markdownChunks
                        )
                    )
                    chunkContent = chunkContent .. "\n"
                end
            end

            fullMarkdown = fullMarkdown .. chunkContent
        end
        currentMarkdown = fullMarkdown

        CM.DebugPrint(
            "UI",
            string.format(
                "Received %d chunks (total: %d characters, after padding removal)",
                #markdownChunks,
                string.len(fullMarkdown)
            )
        )
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
            CM.Warn(
                string.format(
                    "Single string exceeds limit (%d > %d) - this should have been chunked in Markdown.lua",
                    markdownLength,
                    EDITBOX_LIMIT
                )
            )
            CM.DebugPrint("UI", "Chunking single string as fallback...")
            -- Use the consolidated chunking utility
            local Chunking = CM.utils and CM.utils.Chunking
            local SplitMarkdownIntoChunksUtil = Chunking and Chunking.SplitMarkdownIntoChunks
            if SplitMarkdownIntoChunksUtil then
                markdownChunks = SplitMarkdownIntoChunksUtil(markdown)
            else
                CM.Error("Chunking utility not available - markdown may be truncated!")
                -- Fallback: wrap as single chunk (will be truncated by EditBox)
                markdownChunks = { { content = markdown } }
            end
            currentChunkIndex = 1

            -- Store full markdown as concatenated chunks for clipboard operations
            -- CRITICAL: Strip padding when concatenating for paste
            -- Padding is only needed for chunking logic, not for final paste output
            local fullMarkdown = ""

            for i, chunk in ipairs(markdownChunks) do
                local isLastChunk = (i == #markdownChunks)
                local chunkContent = CM.utils.Chunking.StripPadding(chunk.content, isLastChunk)
                CM.DebugPrint("UI", string.format("Stripped padding from chunk %d/%d for paste", i, #markdownChunks))

                -- Verify chunk ends with newline (unless it's the very last chunk)
                -- This prevents mid-line/mid-link splits when concatenating
                if not isLastChunk then
                    local lastChar = string.sub(chunkContent, -1, -1)
                    if lastChar ~= "\n" then
                        CM.Warn(
                            string.format(
                                "Chunk %d/%d: Missing newline at end, adding one to prevent paste truncation",
                                i,
                                #markdownChunks
                            )
                        )
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
            markdownChunks = { { content = markdown } }
            currentChunkIndex = 1
        end
    end

    if #markdownChunks > 1 then
        local totalSize = 0
        local maxChunkSize = 0
        for _, chunk in ipairs(markdownChunks) do
            local chunkSize = string.len(chunk.content)
            totalSize = totalSize + chunkSize
            maxChunkSize = math.max(maxChunkSize, chunkSize)
        end
        
        -- Runtime validation: log chunk statistics
        local CHUNKING = CM.constants and CM.constants.CHUNKING
        local EDITBOX_LIMIT = (CHUNKING and CHUNKING.EDITBOX_LIMIT) or 10000
        
        CM.DebugPrint("WINDOW", string.format("📊 Chunking Summary: %d chunks, %d total chars", #markdownChunks, totalSize))
        CM.DebugPrint("WINDOW", string.format("  Largest chunk: %d chars (limit: %d)", maxChunkSize, EDITBOX_LIMIT))
        
        -- Warn if any chunk is suspiciously close to limit
        if maxChunkSize > EDITBOX_LIMIT * 0.95 then
            CM.Warn(string.format("⚠ Largest chunk (%d) is >95%% of limit (%d)", maxChunkSize, EDITBOX_LIMIT))
            CM.Warn("This may cause issues. Please report with /markdown test output")
        end
        
        CM.DebugPrint("UI", "Use Next/Previous buttons or PageUp/PageDown to navigate chunks")

        -- Log detailed chunk info (debug only)
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
                    windowControl:SetHidden(false) -- Refresh visibility
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
            -- REMOVED: Don't take focus - let global handler work
            -- editBoxControl:TakeFocus()
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
                    -- REMOVED: Don't take focus - let global handler work
            -- editBoxControl:TakeFocus()
                    editBoxControl:SelectAll()
        -- Removed: EditBox stays enabled to receive keyboard events -- Back to read-only
                    
                    -- Final focus as last step
                    zo_callLater(function()
                        if not windowControl:IsHidden() and editBoxControl then
                            -- REMOVED: Don't take focus - let global handler work
            -- editBoxControl:TakeFocus()
                        end
                    end, 50)
                end
            end, 50)

            CM.DebugPrint("UI", "Window opened successfully - Markdown ready to copy")
        end
    end, 200) -- Increased delay to ensure window is fully rendered
    
    -- CRITICAL: Give window keyboard focus on open
    zo_callLater(EnsureWindowHasKeyboardFocus, 250)

    return true
end

-- =====================================================
-- CLOSE WINDOW FUNCTION
-- =====================================================

function CharacterMarkdown_CloseWindow()
    if windowControl then
        -- Reset selection state when closing
        ResetSelectionState()
        
        -- Reset import mode if active
        if windowControl._isImportMode then
            local dismissButton = CharacterMarkdownWindowButtonContainerDismiss
            if dismissButton then
                local label = dismissButton:GetNamedChild("Label")
                if label then
                    label:SetText("[X] Dismiss")
                end
                dismissButton:SetHandler("OnClicked", function()
                    CharacterMarkdownWindow:SetHidden(true)
                end)
            end
            windowControl._isImportMode = false
        end

        if windowControl.SetTopmost then
            windowControl:SetTopmost(false)
        end
        windowControl:SetHidden(true)
        ClearChunks() -- Clear chunks to prevent memory leak
        CM.DebugPrint("UI", "Window closed")
    end
end

-- =====================================================
-- INITIALIZE ON ADDON LOADED
-- =====================================================

local function OnAddOnLoaded(event, addonName)
    if addonName ~= "CharacterMarkdown" then
        return
    end

    zo_callLater(function()
        InitializeWindowControls()

        -- CRITICAL: Register a GLOBAL keyboard handler that's always active when window is open
        -- This bypasses the EditBox focus issue entirely
        EVENT_MANAGER:RegisterForEvent("CharacterMarkdown_GlobalKeyboard", EVENT_KEY_DOWN, function(_, key, ctrl, alt, shift, command)
            -- Only handle when window is visible
            if not windowControl or windowControl:IsHidden() then
                return
            end
            
            -- Skip if in import mode
            if windowControl._isImportMode then
                return
            end
            
            local modifierPressed = ctrl or command
            
            -- ESC or X = Close window
            if key == KEY_ESCAPE or (key == KEY_X and not modifierPressed) then
                windowControl:SetHidden(true)
                return
            end
            
            -- G = Generate (without modifiers)
            if key == KEY_G and not modifierPressed then
                CM.DebugPrint("KEYBOARD", "G pressed (global) - regenerating")
                CharacterMarkdown_RegenerateMarkdown()
                return
            end
            
            -- S = Settings (without modifiers)
            if key == KEY_S and not modifierPressed then
                CM.DebugPrint("KEYBOARD", "S pressed (global) - opening settings")
                CharacterMarkdown_OpenSettings()
                return
            end
            
            -- R = ReloadUI (without modifiers)
            if key == KEY_R and not modifierPressed then
                CM.DebugPrint("KEYBOARD", "R pressed (global) - reloading UI")
                ReloadUI()
                return
            end
            
            -- Navigation: Left Arrow or Comma
            if (key == KEY_LEFTARROW or key == KEY_OEM_COMMA) and not modifierPressed then
                if #markdownChunks > 1 then
                    CM.DebugPrint("KEYBOARD", "Left/Comma pressed (global) - previous chunk")
                    CharacterMarkdown_PreviousChunk()
                end
                return
            end
            
            -- Navigation: Right Arrow or Period
            if (key == KEY_RIGHTARROW or key == KEY_OEM_PERIOD) and not modifierPressed then
                if #markdownChunks > 1 then
                    CM.DebugPrint("KEYBOARD", "Right/Period pressed (global) - next chunk")
                    CharacterMarkdown_NextChunk()
                end
                return
            end
            
            -- Navigation: PageUp
            if key == KEY_PAGEUP and not modifierPressed then
                if #markdownChunks > 1 then
                    CM.DebugPrint("KEYBOARD", "PageUp pressed (global) - previous chunk")
                    CharacterMarkdown_PreviousChunk()
                end
                return
            end
            
            -- Navigation: PageDown
            if key == KEY_PAGEDOWN and not modifierPressed then
                if #markdownChunks > 1 then
                    CM.DebugPrint("KEYBOARD", "PageDown pressed (global) - next chunk")
                    CharacterMarkdown_NextChunk()
                end
                return
            end
            
            -- Space or Enter = Select All / Copy
            if (key == KEY_SPACEBAR or key == KEY_ENTER) and not modifierPressed then
                CM.DebugPrint("KEYBOARD", "Space/Enter pressed (global) - copy to clipboard")
                CharacterMarkdown_CopyToClipboard()
                return
            end
        end)
        
        -- Start periodic update to check EditBox selection state
        EVENT_MANAGER:RegisterForUpdate("CharacterMarkdown_SelectionCheck", 200, UpdateSelectAllButtonColor)
    end, 100)
end

EVENT_MANAGER:RegisterForEvent("CharacterMarkdown_UI", EVENT_ADD_ON_LOADED, OnAddOnLoaded)

-- =====================================================
-- SHOW SETTINGS EXPORT WINDOW
-- =====================================================

function CharacterMarkdown_ShowSettingsExport(yamlContent)
    -- Validate input
    if not yamlContent or yamlContent == "" then
        CM.Error("No YAML content provided")
        return false
    end

    -- Initialize controls if needed
    if not InitializeWindowControls() then
        CM.Error("Window initialization failed")
        return false
    end

    -- Update window title
    local titleLabel = CharacterMarkdownWindowTitleLabel
    if titleLabel then
        titleLabel:SetText("Character Markdown - Settings Export")
    end

    -- Update instructions
    local instructionsLabel = CharacterMarkdownWindowInstructions
    if instructionsLabel then
        instructionsLabel:SetText("Settings in YAML format - Text selected | Win: Ctrl+C | Mac: Cmd+C to copy")
    end

    -- Disable chunk navigation buttons (not needed for settings, but keep visible)
    local prevButton = CharacterMarkdownWindowNavigationContainerPrevChunkButton
    local nextButton = CharacterMarkdownWindowNavigationContainerNextChunkButton
    if prevButton then
        prevButton:SetEnabled(false)
        prevButton:SetAlpha(0.5)
    end
    if nextButton then
        nextButton:SetEnabled(false)
        nextButton:SetAlpha(0.5)
    end

    -- Disable regenerate button (not needed for settings, but keep visible)
    local regenerateButton = CharacterMarkdownWindowButtonContainerRegenerateButton
    if regenerateButton then
        regenerateButton:SetEnabled(false)
        regenerateButton:SetAlpha(0.5)
    end

    -- Enable dismiss button
    local dismissButton = CharacterMarkdownWindowButtonContainerDismiss
    if dismissButton then
        dismissButton:SetEnabled(true)
        dismissButton:SetAlpha(1.0)
        local label = dismissButton:GetNamedChild("Label")
        if label then
            label:SetText("[X] Dismiss")
        end
        dismissButton:SetHandler("OnClicked", function()
            CharacterMarkdownWindow:SetHidden(true)
        end)
    end

    -- Clear import mode flag
    windowControl._isImportMode = false

    -- Store YAML content
    currentMarkdown = yamlContent
    markdownChunks = { { content = yamlContent } }
    currentChunkIndex = 1

    -- Update the EditBox with YAML content
    editBoxControl:SetText(yamlContent)
    editBoxControl._originalText = yamlContent  -- Store for OnTextChanged handler
    editBoxControl:SetColor(1, 1, 1, 1)
    UpdateOverlayVisibility()

    -- Show window
    windowControl:SetHidden(false)

    -- Bring window to top
    if windowControl.SetTopmost then
        windowControl:SetTopmost(true)
    end
    if windowControl.Activate then
        windowControl:Activate()
    end
    if windowControl.RequestMoveToForeground then
        windowControl:RequestMoveToForeground()
    end

    -- Auto-select text and take focus (ready for immediate copy)
    zo_callLater(function()
        if not windowControl:IsHidden() and editBoxControl then
            -- Select all text for easy copying
            editBoxControl:SelectAll()

            CM.DebugPrint("UI", "Settings export window opened - YAML ready to copy (Ctrl+C)")
            
            -- CRITICAL: TakeFocus() must be the LAST operation
            -- REMOVED: Don't take focus - let global handler work
            -- editBoxControl:TakeFocus()
        end
    end, 150)

    return true
end

-- =====================================================
-- SHOW SETTINGS IMPORT WINDOW
-- =====================================================

function CharacterMarkdown_ShowSettingsImport()
    -- Initialize controls if needed
    if not InitializeWindowControls() then
        CM.Error("Window initialization failed")
        return false
    end

    -- Update window title
    local titleLabel = CharacterMarkdownWindowTitleLabel
    if titleLabel then
        titleLabel:SetText("Character Markdown - Settings Import")
    end

    -- Update instructions
    local instructionsLabel = CharacterMarkdownWindowInstructions
    if instructionsLabel then
        instructionsLabel:SetText("Paste YAML settings below | Win: Ctrl+V | Mac: Cmd+V | Then click 'Import'")
    end

    -- Disable chunk navigation buttons (not needed for import, but keep visible)
    local prevButton = CharacterMarkdownWindowNavigationContainerPrevChunkButton
    local nextButton = CharacterMarkdownWindowNavigationContainerNextChunkButton
    if prevButton then
        prevButton:SetEnabled(false)
        prevButton:SetAlpha(0.5)
    end
    if nextButton then
        nextButton:SetEnabled(false)
        nextButton:SetAlpha(0.5)
    end

    -- Disable regenerate button (not needed for import, but keep visible)
    local regenerateButton = CharacterMarkdownWindowButtonContainerRegenerateButton
    if regenerateButton then
        regenerateButton:SetEnabled(false)
        regenerateButton:SetAlpha(0.5)
    end

    -- Disable select all button (not needed for import, but keep visible)
    local selectAllButton = CharacterMarkdownWindowButtonContainerSelectAllButton
    if selectAllButton then
        selectAllButton:SetEnabled(false)
        selectAllButton:SetAlpha(0.5)
    end

    -- Modify dismiss button to be Import button
    local dismissButton = CharacterMarkdownWindowButtonContainerDismiss
    if dismissButton then
        dismissButton:SetEnabled(true)
        dismissButton:SetAlpha(1.0)
        local label = dismissButton:GetNamedChild("Label")
        if label then
            label:SetText("Import")
        end
        -- Store original handler and replace with import handler
        dismissButton:SetHandler("OnClicked", function()
            CharacterMarkdown_ImportSettings()
        end)
    end

    -- Clear content and make editable (import mode - allow editing)
    editBoxControl:SetText("")
    editBoxControl._originalText = ""  -- Store for OnTextChanged handler
    editBoxControl:SetColor(1, 1, 1, 1)
    UpdateOverlayVisibility()  -- Show overlay for empty import field
    -- Note: In import mode, we want to allow editing, so don't prevent text changes

    -- Store import mode flag in window control
    windowControl._isImportMode = true

    -- Show window
    windowControl:SetHidden(false)

    -- Bring window to top
    if windowControl.SetTopmost then
        windowControl:SetTopmost(true)
    end
    if windowControl.Activate then
        windowControl:Activate()
    end
    if windowControl.RequestMoveToForeground then
        windowControl:RequestMoveToForeground()
    end

    -- Take focus on EditBox (ready for immediate paste)
    zo_callLater(function()
        if not windowControl:IsHidden() and editBoxControl then
            -- Ensure EditBox is editable and focused
            editBoxControl:SetEditEnabled(true)
            -- Clear any existing selection
            editBoxControl:SetCursorPosition(0)

            CM.DebugPrint("UI", "Settings import window opened - ready for YAML paste (Ctrl+V)")
            
            -- CRITICAL: TakeFocus() must be the LAST operation
            -- REMOVED: Don't take focus - let global handler work
            -- editBoxControl:TakeFocus()
        end
    end, 150)

    return true
end

-- =====================================================
-- IMPORT SETTINGS FROM YAML
-- =====================================================

function CharacterMarkdown_ImportSettings()
    if not editBoxControl then
        CM.Error("EditBox not available")
        return false
    end

    local yamlContent = editBoxControl:GetText()
    if not yamlContent or yamlContent == "" then
        CM.Error("No YAML content provided")
        return false
    end

    -- Parse YAML
    if not CM.utils or not CM.utils.YAMLToTable then
        CM.Error("YAML parser not available")
        return false
    end

    local parsed, errorMsg = CM.utils.YAMLToTable(yamlContent)
    if not parsed then
        CM.Error("Failed to parse YAML: " .. (errorMsg or "Unknown error"))
        return false
    end

    -- Validate and enforce grouped format
    local validGroups = {
        core = true,
        links = true,
        visuals = true,
        content = true,
        extended = true,
        champion = true,
        equipment = true,
        skills = true,
        display = true,
        _metadata = true, -- Allow metadata but skip it
    }

    -- Check if this is the grouped format
    local isGroupedFormat = false
    local hasTopLevelSettings = false

    for key, value in pairs(parsed) do
        if validGroups[key] then
            isGroupedFormat = true
        elseif key ~= "_metadata" and type(value) ~= "table" then
            -- This looks like a flat format setting (direct key-value, not in a group)
            hasTopLevelSettings = true
        end
    end

    -- Enforce grouped format - reject flat format
    if hasTopLevelSettings and not isGroupedFormat then
        CM.Error("Invalid format: Settings must use grouped structure (core, links, content, etc.)")
        CM.Info("Expected format:")
        CM.Info("  core:")
        CM.Info('    currentFormat: "github"')
        CM.Info("  links:")
        CM.Info("    enableAbilityLinks: true")
        CM.Info("  ...")
        CM.Info("Use /cmdsettings export to see the correct format")
        return false
    end

    -- Flatten grouped format for processing
    local settingsToImport = {}
    if isGroupedFormat then
        if CM.utils and CM.utils.FlattenSettingsForImport then
            settingsToImport = CM.utils.FlattenSettingsForImport(parsed)
            if not settingsToImport then
                CM.Error("Failed to flatten grouped settings")
                return false
            end
        else
            CM.Error("Grouped format detected but flatten function not available")
            return false
        end
    else
        -- No valid format detected
        CM.Error("Invalid format: No recognized settings groups found")
        CM.Info(
            "Expected format with groups: core, links, content, extended, champion, equipment, skills, display, visuals"
        )
        return false
    end

    -- Validate against defaults
    local defaults = CM.Settings.Defaults:GetAll()
    if not defaults then
        CM.Error("Defaults not available")
        return false
    end

    -- Get current settings
    local settings = CM.GetSettings()
    if not settings then
        CM.Error("Settings not available")
        return false
    end

    -- Validate and apply settings (partial import - only apply provided values)
    local appliedCount = 0
    local skippedCount = 0
    local errors = {}

    -- Track which groups were provided for better feedback
    local providedGroups = {}
    for groupName, _ in pairs(parsed) do
        if validGroups[groupName] and groupName ~= "_metadata" then
            providedGroups[groupName] = true
        end
    end

    if #providedGroups > 0 then
        local groupList = {}
        for group, _ in pairs(providedGroups) do
            table.insert(groupList, group)
        end
        CM.Info(string.format("Importing settings from groups: %s", table.concat(groupList, ", ")))
    end

    -- Handle per-character fields separately (not in defaults)
    local perCharFields = { "customTitle", "customNotes", "playStyle" }
    for _, field in ipairs(perCharFields) do
        if settingsToImport[field] ~= nil then
            if CM.charData then
                CM.charData[field] = settingsToImport[field]
                CM.Info(string.format("Imported per-character field: %s", field))
            else
                CM.Warn(string.format("Cannot import %s - character data not available", field))
            end
            -- Remove from settingsToImport so it doesn't get processed as unknown
            settingsToImport[field] = nil
        end
    end

    for key, value in pairs(settingsToImport) do
        -- Skip internal keys
        if type(key) == "string" and key:sub(1, 1) == "_" then
            skippedCount = skippedCount + 1
        -- Check if key exists in defaults (partial import - only validate provided keys)
        elseif defaults[key] == nil then
            table.insert(errors, string.format("Unknown setting: %s (will be skipped)", key))
            skippedCount = skippedCount + 1
        else
            -- Validate type
            local defaultValue = defaults[key]
            if type(value) ~= type(defaultValue) then
                -- Try to convert if possible
                if type(defaultValue) == "boolean" and type(value) == "string" then
                    if value:lower() == "true" then
                        value = true
                    elseif value:lower() == "false" then
                        value = false
                    else
                        table.insert(
                            errors,
                            string.format("Invalid type for %s: expected boolean, got %s", key, type(value))
                        )
                        skippedCount = skippedCount + 1
                    end
                elseif type(defaultValue) == "number" and type(value) == "string" then
                    local num = tonumber(value)
                    if num then
                        value = num
                    else
                        table.insert(
                            errors,
                            string.format("Invalid type for %s: expected number, got %s", key, type(value))
                        )
                        skippedCount = skippedCount + 1
                    end
                else
                    table.insert(
                        errors,
                        string.format("Invalid type for %s: expected %s, got %s", key, type(defaultValue), type(value))
                    )
                    skippedCount = skippedCount + 1
                end
            end

            -- Apply setting (only if we didn't skip due to type conversion failure)
            if type(value) == type(defaultValue) then
                settings[key] = value
                appliedCount = appliedCount + 1
            end
        end
    end

    -- Report results
    if appliedCount > 0 then
        CM.Success(string.format("Imported %d setting(s) successfully (partial import)", appliedCount))
        if skippedCount > 0 then
            CM.Info(string.format("Skipped %d setting(s) (unknown keys or errors)", skippedCount))
        end
    else
        CM.Warn("No settings were imported")
    end

    -- Save settings if any were applied
    if appliedCount > 0 then
        if CharacterMarkdownSettings and CharacterMarkdownSettings.SetValue then
            CharacterMarkdownSettings:SetValue("_lastModified", GetTimeStamp())
        elseif CharacterMarkdownSettings then
            CharacterMarkdownSettings._lastModified = GetTimeStamp()
        end

        -- Also update character data timestamp if we imported per-character fields
        if CM.charData then
            CM.charData._lastModified = GetTimeStamp()
        end

        -- Invalidate cache to ensure fresh settings
        CM.InvalidateSettingsCache()

        -- Refresh settings panel if open
        if LibAddonMenu2 then
            -- Trigger refresh
            zo_callLater(function()
                CM.Info("Settings updated! You may need to refresh the settings panel to see changes.")
            end, 100)
        end
    end

    if #errors > 0 then
        CM.Warn("Validation errors:")
        for _, error in ipairs(errors) do
            CM.Warn("  " .. error)
        end
    end

    -- Close window
    windowControl:SetHidden(true)

    return true
end

CM.DebugPrint("UI", "Window module loaded successfully")
