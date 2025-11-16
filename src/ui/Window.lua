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

-- =====================================================
-- FOCUS STATE TRACKING
-- =====================================================

-- Track focus state
local isEditBoxFocused = false

-- Update focus indicator (border color)
local function UpdateFocusIndicator()
    if not windowControl or windowControl:IsHidden() then
        return
    end
    
    local bgControl = CharacterMarkdownWindowBG
    if not bgControl then
        return
    end
    
    -- Change border color based on focus state
    if isEditBoxFocused then
        -- Bright cyan/blue when focused
        bgControl:SetEdgeColor(0.0, 0.8, 1.0, 1.0)
        CM.DebugPrint("UI", "EditBox focused - border changed to cyan")
    else
        -- Default gold/bronze when not focused
        bgControl:SetEdgeColor(0.76, 0.69, 0.49, 1.0)
        CM.DebugPrint("UI", "EditBox lost focus - border changed to gold")
    end
end

-- Set focus state to focused
local function SetFocusState(focused)
    isEditBoxFocused = focused
    UpdateFocusIndicator()
end

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

-- Helper to ensure EditBox has keyboard focus for shortcuts
local function EnsureEditBoxHasKeyboardFocus()
    if windowControl and not windowControl:IsHidden() and editBoxControl then
        -- CRITICAL: EditBox must have focus to receive keyboard events
        -- All keyboard shortcuts are handled by EditBox OnKeyDown handler
        editBoxControl:SetKeyboardEnabled(true)
        editBoxControl:TakeFocus()
        
        -- Also ensure window is on top
        if windowControl.SetTopmost then
            windowControl:SetTopmost(true)
        end
        
        CM.DebugPrint("KEYBOARD", "EditBox has keyboard focus for shortcuts")
    end
end

local function LoseFocus(delayMs)
    delayMs = delayMs or 150  -- Default delay
    zo_callLater(function()
        if not windowControl:IsHidden() and editBoxControl then
            editBoxControl:LoseFocus()
        end
    end, delayMs)
end

-- Helper to select all text, take focus, and update selection state
-- Wraps the operation in zo_callLater with window/editBox checks
local function SelectAll(delayMs)
    delayMs = delayMs or 150  -- Default delay
    zo_callLater(function()
        if not windowControl:IsHidden() and editBoxControl then
            editBoxControl:TakeFocus()
            editBoxControl:SelectAll()
            SetSelectionState()
            -- LoseFocus(delayMs)
        end
    end, delayMs)
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
    
    -- Set background with solid color and nice border
    local bgControl = CharacterMarkdownWindowBG
    if bgControl then
        CM.DebugPrint("UI", "=== BACKGROUND CONFIGURATION ===")
        
        -- Use ESO's standard tooltip border for a professional look
        -- This is the same border used in many ESO UI elements
        bgControl:SetEdgeTexture("/esoui/art/tooltips/ui-border.dds", 128, 16)
        
        -- Dark gray center with 85% opacity for airy feel
        -- RGB: 0.16 = ~#2a2a2a (dark gray), Alpha: 0.85 = 85% opaque (15% transparent)
        bgControl:SetCenterColor(0.16, 0.16, 0.16, 0.85)
        
        -- Elegant gold/bronze edge for prominence (ESO standard color)
        -- RGB: 0.76, 0.69, 0.49 = ~#c2b07d (warm gold/bronze)
        bgControl:SetEdgeColor(0.76, 0.69, 0.49, 1.0)
        CM.DebugPrint("UI", "Background: dark gray (#2a2a2a) at 85% opacity with gold border")
        
        -- Set insets to control border spacing (standard ESO values)
        bgControl:SetInsets(16, 16, -16, -16)
        bgControl:SetDrawLayer(DL_BACKGROUND)
        
        CM.DebugPrint("UI", "=== END BACKGROUND CONFIGURATION ===")
    else
        CM.DebugPrint("UI", "Background control not found - using default appearance")
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
    -- CRITICAL: Keep EditEnabled TRUE to allow copy (Ctrl+C/Cmd+C) to work
    -- We prevent text input via OnChar and OnKeyDown handlers instead
    editBoxControl:SetEditEnabled(true)
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
        CM.DebugPrint("WINDOW", string.format("EditBox initialized: max input %d chars (requested 22000)", actualMaxChars))
        if actualMaxChars < 22000 then
            CM.DebugPrint("WINDOW", string.format("⚠ EditBox limited to %d by ESO (requested 22000)", actualMaxChars))
            CM.DebugPrint("WINDOW", "This may affect large character profiles. Please report if you see truncation.")
        end
        -- Log chunking configuration for validation (debug only)
        local CHUNKING = CM.constants and CM.constants.CHUNKING
        if CHUNKING then
            CM.DebugPrint("CHUNKING", string.format("Chunking limits: EDITBOX=%d, COPY=%d, MAX_DATA=%d", 
                CHUNKING.EDITBOX_LIMIT or 0,
                CHUNKING.COPY_LIMIT or 0,
                CHUNKING.MAX_DATA_CHARS or 0
            ))
        end
    else
        CM.DebugPrint("WINDOW", "⚠ Could not query EditBox max input chars - this may indicate an ESO API issue")
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

    -- FOCUS TRACKING: Update border color when EditBox gains/loses focus
    editBoxControl:SetHandler("OnFocusGained", function(self)
        SetFocusState(true)
    end)
    
    editBoxControl:SetHandler("OnFocusLost", function(self)
        SetFocusState(false)
    end)

    -- CRITICAL: Handle ALL keyboard shortcuts in EditBox OnKeyDown handler
    -- EditBox must maintain focus for this handler to receive keyboard events
    -- All shortcuts (G, S, R, X, ESC, arrows, etc.) are handled here
    editBoxControl:SetHandler("OnKeyDown", function(self, key, ctrl, alt, shift, command)
        -- Allow text input in import mode
        if windowControl and windowControl._isImportMode then
            return false -- Let EditBox process the key normally
        end
        
        -- Only handle when window is visible
        if not windowControl or windowControl:IsHidden() then
            return false
        end
        
        local modifierPressed = ctrl or command
        
        -- ESC = Close window (X without modifiers also closes)
        if key == KEY_ESCAPE or (key == KEY_X and not modifierPressed) then
            CM.DebugPrint("KEYBOARD", "ESC/X pressed - closing window")
            windowControl:SetHidden(true)
            return true -- Consume
        end
        
        -- G = Regenerate
        if key == KEY_G then
            CM.DebugPrint("KEYBOARD", "G pressed - regenerating")
            CharacterMarkdown_RegenerateMarkdown()
            return true -- Consume
        end
        
        -- S = Settings
        if key == KEY_S then
            CM.DebugPrint("KEYBOARD", "S pressed - opening settings")
            CharacterMarkdown_OpenSettings()
            return true -- Consume
        end
        
        -- R = ReloadUI
        if  key == KEY_R then
            CM.DebugPrint("KEYBOARD", "R pressed - reloading UI")
            ReloadUI()
            return true -- Consume
        end
        
        -- Navigation: Left Arrow or Comma
        if (key == KEY_LEFTARROW or key == KEY_OEM_COMMA) and not modifierPressed then
            if #markdownChunks > 1 then
                CM.DebugPrint("KEYBOARD", "Left/Comma pressed - previous chunk")
                CharacterMarkdown_PreviousChunk()
            end
            return true -- Consume
        end
        
        -- Navigation: Right Arrow or Period
        if (key == KEY_RIGHTARROW or key == KEY_OEM_PERIOD) and not modifierPressed then
            if #markdownChunks > 1 then
                CM.DebugPrint("KEYBOARD", "Right/Period pressed - next chunk")
                CharacterMarkdown_NextChunk()
            end
            return true -- Consume
        end
        
        -- Navigation: PageUp
        if key == KEY_PAGEUP and not modifierPressed then
            if #markdownChunks > 1 then
                CM.DebugPrint("KEYBOARD", "PageUp pressed - previous chunk")
                CharacterMarkdown_PreviousChunk()
            end
            return true -- Consume
        end
        
        -- Navigation: PageDown
        if key == KEY_PAGEDOWN and not modifierPressed then
            if #markdownChunks > 1 then
                CM.DebugPrint("KEYBOARD", "PageDown pressed - next chunk")
                CharacterMarkdown_NextChunk()
            end
            return true -- Consume
        end
        
        -- Ctrl+A / Cmd+A = Select All (let EditBox handle it natively)
        -- Note: Only copy (Ctrl+C/Cmd+C) uses a modifier; all other shortcuts are single keys
        if modifierPressed and key == KEY_A then
            CM.DebugPrint("KEYBOARD", "Ctrl+A/Cmd+A pressed - selecting all")
            SetSelectionState()
            return false -- Don't consume - let EditBox handle SelectAll
        end
        
        -- Ctrl+C / Cmd+C = Copy (only shortcut that uses modifier)
        if modifierPressed and key == KEY_C then
            CM.DebugPrint("KEYBOARD", "Ctrl+C/Cmd+C pressed - copying to clipboard")
            -- Text is already selected, EditBox will handle the copy
            return false -- Don't consume - let EditBox handle copy
        end
        
        -- Space or Enter = Select All / Copy
        if (key == KEY_SPACEBAR or key == KEY_ENTER) and not modifierPressed then
            CM.DebugPrint("KEYBOARD", "Space/Enter pressed - copy to clipboard")
            CharacterMarkdown_CopyToClipboard()
            return true -- Consume
        end
        
        -- CRITICAL: Consume ALL other character keys to prevent text input
        -- Only allow cursor movement keys in non-modifier mode
        if not modifierPressed then
            local isCursorKey = (
                key == KEY_UPARROW or key == KEY_DOWNARROW or 
                key == KEY_HOME or key == KEY_END or key == KEY_TAB
            )
            
            if isCursorKey then
                return false -- Allow cursor movement
            end
        end
        
        CM.DebugPrint("KEYBOARD", string.format("[EditBox] Consuming key %d to prevent text input", key))
        return true -- Consume to prevent text input
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

            -- Get OS-specific copy shortcut text
            local copyShortcut = "Ctrl+C"
            if CM.utils.Platform then
                copyShortcut = CM.utils.Platform.GetShortcutText("copy")
            elseif os.isMac then
                copyShortcut = "Cmd+C"
            end
            
            CM.DebugPrint(
                "UI",
                string.format("Chunk %d selected (%d chars) - Press %s to copy", currentChunkIndex, actualLength, copyShortcut)
            )
            
            -- Select all text, take focus, and update selection state
            if editBoxControl then
                SelectAll()
            end
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

        -- Select all text
        SelectAll(100)
        
        -- Get OS-specific copy shortcut text
        local copyShortcut = "Ctrl+C"
        if CM.utils.Platform then
            copyShortcut = CM.utils.Platform.GetShortcutText("copy")
        elseif os.isMac then
            copyShortcut = "Cmd+C"
        end
        
        CM.DebugPrint("UI", "Text selected - Press " .. copyShortcut .. " to copy")
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

    -- Use the /markdownsettings command that LAM registered for our panel
    -- This is the most reliable way to open our specific panel
    local lamHandler = SLASH_COMMANDS["/markdownsettings"]
    if lamHandler and type(lamHandler) == "function" then
        -- Call the LAM-registered handler directly
        lamHandler("")
        CM.DebugPrint("UI", "Opened settings via /markdownsettings LAM handler")
    else
        -- Fallback: Try LibAddonMenu2's OpenToPanel
        local panelId = CM.Settings and CM.Settings.Panel and CM.Settings.Panel.panelId or "CharacterMarkdownPanel"
        if LibAddonMenu2.OpenToPanel then
            LibAddonMenu2:OpenToPanel(panelId)
            CM.DebugPrint("UI", "Opened settings panel via LAM:OpenToPanel")
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
        CM.DebugPrint("UI", "Regenerated - Text selected and ready to copy")
        SelectAll(150)
    end
end

-- =====================================================
-- MARKDOWN CHUNKING
-- =====================================================
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
        local shortcutText = "Ctrl+A then Ctrl+C" -- Default fallback
        if CM.utils.Platform then
            shortcutText = CM.utils.Platform.GetShortcutText("select_copy")
        elseif os.isMac then
            shortcutText = "Cmd+A then Cmd+C"
        elseif os.isWin then
            shortcutText = "Ctrl+A then Ctrl+C"
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

    -- Auto-select text and ensure EditBox has focus for keyboard handling
    CM.DebugPrint("UI", string.format("Chunk %d/%d displayed - EditBox has focus and text selected", currentChunkIndex, #markdownChunks))
    SelectAll(150)

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
    
    -- TEXTURE DEBUG: Check background state when window opens
    local bgControl = CharacterMarkdownWindowBG
    if bgControl then
        CM.DebugPrint("WINDOW", "=== BACKGROUND CHECK ON WINDOW OPEN ===")
        local width, height = bgControl:GetDimensions()
        CM.DebugPrint("WINDOW", string.format("Background dimensions: %dx%d", width, height))
        CM.DebugPrint("WINDOW", string.format("Background hidden: %s", tostring(bgControl:IsHidden())))
        CM.DebugPrint("WINDOW", string.format("Background alpha: %.2f", bgControl:GetAlpha()))
        CM.DebugPrint("WINDOW", "=== END BACKGROUND CHECK ===")
    else
        CM.DebugPrint("WINDOW", "Background control not found on window open")
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
            CM.DebugPrint("CHUNKING", string.format("⚠ Largest chunk (%d) is >95%% of limit (%d)", maxChunkSize, EDITBOX_LIMIT))
            CM.DebugPrint("CHUNKING", "This may cause issues. Please report with /markdown test output")
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

    -- Auto-select text and give EditBox focus for keyboard handling
    zo_callLater(function()
        -- Ensure window is still visible
        if not windowControl:IsHidden() then
            -- Enable keyboard on EditBox (needed for keyboard shortcuts)
            if editBoxControl and editBoxControl.SetKeyboardEnabled then
                editBoxControl:SetKeyboardEnabled(true)
            end
        end
    end, 200) -- Delay to ensure window is fully rendered
    
    -- Give EditBox focus so it receives keyboard events
    CM.DebugPrint("UI", "Window opened - EditBox has focus and text selected, ready for keyboard shortcuts")
    SelectAll(200)

    return true
end

-- =====================================================
-- CLOSE WINDOW FUNCTION
-- =====================================================

function CharacterMarkdown_CloseWindow()
    if windowControl then
        -- Reset selection state when closing
        ResetSelectionState()
        
        -- Reset focus state when closing
        SetFocusState(false)
        
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

        -- CRITICAL: Global keyboard handler is BACKUP ONLY
        -- Primary handler is EditBox OnKeyDown - this only catches ESC if EditBox loses focus
        EVENT_MANAGER:RegisterForEvent("CharacterMarkdown_GlobalKeyboard", EVENT_KEY_DOWN, function(_, key, ctrl, alt, shift, command)
            -- Only handle when window is visible
            if not windowControl or windowControl:IsHidden() then
                return
            end
            
            -- Skip if in import mode
            if windowControl._isImportMode then
                return
            end
            
            -- Only handle ESC as a backup (EditBox already handles it)
            if key == KEY_ESCAPE then
                CM.DebugPrint("KEYBOARD", "ESC pressed (global fallback) - closing window")
                windowControl:SetHidden(true)
                return
            end
            
            -- DISABLED: Auto-focus restoration
            -- If we get here with the window open but EditBox not handling keys,
            -- it means EditBox lost focus somehow - give it back
            -- if editBoxControl and not editBoxControl:HasFocus() then
            --     CM.DebugPrint("KEYBOARD", "Global handler detected EditBox lost focus - restoring")
            --     editBoxControl:TakeFocus()
            -- end
        end)
        
        -- Start periodic update to check EditBox selection state
        EVENT_MANAGER:RegisterForUpdate("CharacterMarkdown_SelectionCheck", 200, UpdateSelectAllButtonColor)
    end, 100)
end

EVENT_MANAGER:RegisterForEvent("CharacterMarkdown_UI", EVENT_ADD_ON_LOADED, OnAddOnLoaded)


CM.DebugPrint("UI", "Window module loaded successfully")
