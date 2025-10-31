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
local markdownChunks = {}  -- Array of {name, content} for each section chunk
local currentChunkIndex = 1

-- =====================================================
-- MARKDOWN SPLITTING (at section boundaries)
-- =====================================================

-- Helper function to find last complete line before position
-- Returns position of last newline before maxPos, or maxPos if no newline found in search range
local function FindLastLineBoundary(text, maxPos)
    if maxPos <= 1 then return 1 end
    if maxPos > string.len(text) then maxPos = string.len(text) end
    
    -- Search backwards from maxPos for a newline
    -- Search up to 5000 chars back to find a good split point
    local searchStart = math.max(1, maxPos - 5000)
    local lastNewline = nil
    
    -- Search backwards for newline
    for i = maxPos, searchStart, -1 do
        local char = string.sub(text, i, i)
        if char == "\n" then
            lastNewline = i
            break
        end
    end
    
    -- If found, return position after the newline (so we include it)
    -- Otherwise, return maxPos but we'll handle it
    if lastNewline then
        return lastNewline
    end
    
    -- If no newline found, try to find end of markdown link pattern "](" 
    -- to avoid cutting URLs
    for i = maxPos, searchStart, -1 do
        local substr = string.sub(text, math.max(1, i - 2), i)
        if substr == ")\n" or substr == "](" then
            -- Found a link boundary, try to find newline before it
            for j = i - 1, searchStart, -1 do
                if string.sub(text, j, j) == "\n" then
                    return j
                end
            end
        end
    end
    
    -- Last resort: return maxPos (will truncate, but at least we tried)
    return maxPos
end

-- Split markdown into chunks at section headers (## )
-- Returns array of {name, content} where each chunk fits in EditBox
local function SplitMarkdownIntoSections(markdown)
    local chunks = {}
    local ESO_EDITBOX_HARD_LIMIT = 28000  -- Very conservative limit (well under 30k to avoid truncation)
    local markdownLength = string.len(markdown)
    
    -- If content fits in one chunk, return as-is
    if markdownLength <= ESO_EDITBOX_HARD_LIMIT then
        return {
            {name = "Full Export", content = markdown}
        }
    end
    
    -- Find all section headers (## )
    local sections = {}
    
    -- Check for header at the very start of file (no newline before)
    if string.sub(markdown, 1, 4) == "## " then
        local headerEnd = string.find(markdown, "\n", 1)
        if headerEnd then
            local headerLine = string.sub(markdown, 4, headerEnd - 1)
            local cleanName = headerLine:gsub("^%s+", ""):gsub("%s+$", "")
            table.insert(sections, {
                name = cleanName or "Header",
                position = 1
            })
        end
    end
    
    -- Pattern matches: newline followed by ## followed by space
    local pattern = "\n## "
    local startPos = 1
    
    while true do
        local headerPos = string.find(markdown, pattern, startPos)
        if not headerPos then
            break
        end
        
        -- Extract section name from header line
        local headerEnd = string.find(markdown, "\n", headerPos + 4)
        if headerEnd then
            local headerLine = string.sub(markdown, headerPos + 4, headerEnd - 1)
            local cleanName = headerLine:gsub("^%s+", ""):gsub("%s+$", "")
            
            -- Only add if not duplicate (avoid header at start and same position)
            local isDuplicate = false
            for _, existing in ipairs(sections) do
                if existing.position == headerPos + 1 then
                    isDuplicate = true
                    break
                end
            end
            if not isDuplicate then
                table.insert(sections, {
                    name = cleanName or "Section",
                    position = headerPos + 1  -- Include the newline
                })
            end
        end
        
        startPos = headerPos + 1
    end
    
    -- Sort sections by position
    table.sort(sections, function(a, b) return a.position < b.position end)
    
    -- If no sections found, split into fixed-size chunks
    if #sections == 0 then
        local chunkNum = 1
        local pos = 1
        while pos <= markdownLength do
            local chunkContent = string.sub(markdown, pos, math.min(pos + ESO_EDITBOX_HARD_LIMIT - 1, markdownLength))
            table.insert(chunks, {
                name = string.format("Part %d", chunkNum),
                content = chunkContent
            })
            pos = pos + ESO_EDITBOX_HARD_LIMIT
            chunkNum = chunkNum + 1
        end
        return chunks
    end
    
    -- Split at section boundaries, ensuring each chunk is safely under limit
    local chunkStart = 1
    local currentChunkContent = ""
    local currentChunkNames = {}
    local SAFETY_MARGIN = 2000  -- Increase safety margin
    
    for i, section in ipairs(sections) do
        -- Get content from current position to this section header
        local sectionContent = string.sub(markdown, chunkStart, section.position - 1)
        local sectionLength = string.len(sectionContent)
        local currentLength = string.len(currentChunkContent)
        
        -- Check if adding this section would exceed limit (with safety margin)
        -- Be more aggressive - split earlier to be safe
        local effectiveLimit = ESO_EDITBOX_HARD_LIMIT - SAFETY_MARGIN
        local wouldExceed = (currentLength + sectionLength) > effectiveLimit
        
        -- Also check if current chunk alone is getting large (split proactively)
        local shouldSplitEarly = currentLength > (effectiveLimit * 0.8) and currentChunkContent ~= ""
        
        -- Also check if section itself is too large (must split it)
        if sectionLength > effectiveLimit then
            -- Section is too large - save current chunk first if needed
            if currentChunkContent ~= "" then
                local chunkName = #currentChunkNames > 0 and table.concat(currentChunkNames, " + ") or "Header"
                table.insert(chunks, {
                    name = chunkName,
                    content = currentChunkContent
                })
                currentChunkContent = ""
                currentChunkNames = {}
            end
            
            -- Split the large section into multiple chunks
            local largeSectionStart = chunkStart
            local largeSectionEnd = section.position - 1
            local largeSectionRemaining = sectionContent
            local partNum = 1
            
            while string.len(largeSectionRemaining) > 0 do
                local maxLen = effectiveLimit
                if string.len(largeSectionRemaining) <= maxLen then
                    table.insert(chunks, {
                        name = string.format("%s (Part %d)", section.name, partNum),
                        content = largeSectionRemaining
                    })
                    break
                else
                    -- Find a good split point at a line boundary
                    local safeSplitPos = FindLastLineBoundary(largeSectionRemaining, maxLen)
                    
                    local chunkPart = string.sub(largeSectionRemaining, 1, safeSplitPos)
                    table.insert(chunks, {
                        name = string.format("%s (Part %d)", section.name, partNum),
                        content = chunkPart
                    })
                    largeSectionRemaining = string.sub(largeSectionRemaining, safeSplitPos + 1)
                    partNum = partNum + 1
                end
            end
            
            currentChunkContent = ""
            currentChunkNames = {}
        elseif (wouldExceed or shouldSplitEarly) and currentChunkContent ~= "" then
            -- Save current chunk and start new one
            local chunkName = #currentChunkNames > 0 and table.concat(currentChunkNames, " + ") or "Header"
            table.insert(chunks, {
                name = chunkName,
                content = currentChunkContent
            })
            currentChunkContent = sectionContent
            currentChunkNames = {section.name}
        else
            -- Add to current chunk
            currentChunkContent = currentChunkContent .. sectionContent
            if section.name then
                table.insert(currentChunkNames, section.name)
            end
        end
        
        chunkStart = section.position
    end
    
    -- Add remaining content (after last section)
    local remainingContent = string.sub(markdown, chunkStart)
    local remainingLength = string.len(remainingContent)
    local currentLength = string.len(currentChunkContent)
    
    local effectiveLimit = ESO_EDITBOX_HARD_LIMIT - SAFETY_MARGIN
    if (currentLength + remainingLength) <= effectiveLimit then
        currentChunkContent = currentChunkContent .. remainingContent
        local chunkName = #currentChunkNames > 0 and table.concat(currentChunkNames, " + ") or "Header"
        if currentChunkContent ~= "" then
            table.insert(chunks, {
                name = chunkName,
                content = currentChunkContent
            })
        end
    else
        -- Remaining content too large - need to split
        if currentChunkContent ~= "" then
            local chunkName = #currentChunkNames > 0 and table.concat(currentChunkNames, " + ") or "Header"
            table.insert(chunks, {
                name = chunkName,
                content = currentChunkContent
            })
        end
        
        -- Split remaining into chunks at line boundaries
        local remaining = remainingContent
        local chunkNum = #chunks + 1
        local pos = 1
        local remainingLength = string.len(remaining)
        while pos <= remainingLength do
            local maxLen = effectiveLimit
            local maxPos = math.min(pos + maxLen - 1, remainingLength)
            -- Find safe split point at line boundary (relative to remaining string start at pos)
            local relativeMaxPos = maxPos - pos + 1  -- Position relative to current pos
            local safeSplitPos = FindLastLineBoundary(string.sub(remaining, pos), relativeMaxPos)
            if safeSplitPos < 1 then safeSplitPos = relativeMaxPos end  -- Fallback if no line found
            
            local chunkContent = string.sub(remaining, pos, pos + safeSplitPos - 1)
            table.insert(chunks, {
                name = string.format("Part %d", chunkNum),
                content = chunkContent
            })
            pos = pos + safeSplitPos
            chunkNum = chunkNum + 1
        end
    end
    
    -- Verify all chunks are under limit and add newlines for easy appending
    for i, chunk in ipairs(chunks) do
        local chunkLen = string.len(chunk.content)
        if chunkLen > ESO_EDITBOX_HARD_LIMIT then
            CM.Warn(string.format("⚠️ Chunk %d '%s' is %d chars (over limit %d) - truncating at line boundary", 
                i, chunk.name, chunkLen, ESO_EDITBOX_HARD_LIMIT))
            -- Find safe truncation point at line boundary
            local safeTruncatePos = FindLastLineBoundary(chunk.content, ESO_EDITBOX_HARD_LIMIT)
            if safeTruncatePos < 1 then safeTruncatePos = ESO_EDITBOX_HARD_LIMIT end
            chunk.content = string.sub(chunk.content, 1, safeTruncatePos)
        end
        
        -- Add newline at end of each chunk for easier appending (unless already ends with newline)
        local content = chunk.content
        local lastChar = string.sub(content, -1)
        if lastChar ~= "\n" then
            chunk.content = content .. "\n"
        end
    end
    
    return chunks
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
    
    if not clipboardEditBoxControl then
        CM.Warn("Clipboard EditBox not found - using main EditBox")
    end
    
    -- Configure EditBox with INCREASED character limit and READ-ONLY mode
    -- Note: ESO EditBox may have internal limits (possibly ~50k-100k) despite SetMaxInputChars
    -- Setting very high value, but actual limit may be lower
    editBoxControl:SetMaxInputChars(1000000)  -- Attempt 1 million (may be limited internally)
    editBoxControl:SetMultiLine(true)
    editBoxControl:SetNewLineEnabled(true)
    editBoxControl:SetEditEnabled(false)  -- Make READ-ONLY - cannot be edited
    
    -- Verify the actual limit that was set
    -- Note: ESO EditBox may have hardcoded internal limits regardless of SetMaxInputChars
    local actualMaxChars = editBoxControl:GetMaxInputChars()
    if actualMaxChars then
        CM.DebugPrint("UI", string.format("EditBox max input chars: %d", actualMaxChars))
        if actualMaxChars < 1000000 then
            CM.DebugPrint("UI", string.format("EditBox limited to %d (requested 1000000)", actualMaxChars))
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
    
    -- Update instructions and ensure buttons are visible
    local instructionsLabel = CharacterMarkdownWindowInstructions
    local prevButton = CharacterMarkdownWindowButtonContainerPrevChunkButton
    local nextButton = CharacterMarkdownWindowButtonContainerNextChunkButton
    
    if instructionsLabel and #markdownChunks > 1 then
        instructionsLabel:SetText(string.format(
            "Chunk %d/%d: %s | PageUp/PageDown to navigate | Copy each chunk separately",
            currentChunkIndex, #markdownChunks, chunk.name
        ))
    end
    
    -- Ensure navigation buttons are visible when multiple chunks
    if #markdownChunks > 1 then
        if prevButton then 
            prevButton:SetHidden(false)
            prevButton:SetAlpha(1)
            -- Try to bring button to front if method exists
            if prevButton.SetDrawLevel then
                prevButton:SetDrawLevel(1)
            end
        end
        if nextButton then 
            nextButton:SetHidden(false)
            nextButton:SetAlpha(1)
            -- Try to bring button to front if method exists
            if nextButton.SetDrawLevel then
                nextButton:SetDrawLevel(1)
            end
        end
    end
    
    -- Auto-select for copying
    zo_callLater(function()
        if not windowControl:IsHidden() then
            editBoxControl:SetEditEnabled(true)
            editBoxControl:TakeFocus()
            editBoxControl:SelectAll()
            editBoxControl:SetEditEnabled(false)
            CM.DebugPrint("UI", string.format("Switched to chunk %d/%d: %s", currentChunkIndex, #markdownChunks, chunk.name))
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
    
    -- Split markdown into chunks if needed
    markdownChunks = SplitMarkdownIntoSections(markdown)
    currentChunkIndex = 1
    
    -- ESO EditBox hard limit is ~30,842 characters (cannot be overridden)
    local ESO_EDITBOX_HARD_LIMIT = 30800
    if markdownLength > ESO_EDITBOX_HARD_LIMIT then
        CM.Info(string.format("📦 Split into %d chunks (content: %d chars, limit: ~%d)", 
            #markdownChunks, markdownLength, ESO_EDITBOX_HARD_LIMIT))
        CM.Info("💡 Use PageUp/PageDown keys to navigate chunks, copy each separately")
        
        -- Log chunk info
        for i, chunk in ipairs(markdownChunks) do
            CM.DebugPrint("UI", string.format("  Chunk %d: %s (%d chars)", i, chunk.name, string.len(chunk.content)))
        end
    end
    
    -- Display first chunk (or only chunk if not split)
    local chunkToDisplay = markdownChunks[currentChunkIndex]
    if not chunkToDisplay then
        CM.Error("No chunks available to display")
        return false
    end
    
    editBoxControl:SetEditEnabled(true)
    editBoxControl:SetText(chunkToDisplay.content)
    
    -- Verify what was actually set
    local actualText = editBoxControl:GetText()
    local actualLength = actualText and string.len(actualText) or 0
    local chunkLength = string.len(chunkToDisplay.content)
    
    if actualLength < chunkLength then
        CM.Warn(string.format("Chunk %d truncated: %d/%d chars", currentChunkIndex, actualLength, chunkLength))
    else
        CM.DebugPrint("UI", string.format("Chunk %d/%d displayed: %s (%d chars)", 
            currentChunkIndex, #markdownChunks, chunkToDisplay.name, actualLength))
    end
    
    editBoxControl:SetColor(1, 1, 1, 1)  -- White text
    editBoxControl:SetEditEnabled(false)  -- Make read-only again
    
    -- Update instructions and button visibility BEFORE showing window
    local instructionsLabel = CharacterMarkdownWindowInstructions
    local prevButton = CharacterMarkdownWindowButtonContainerPrevChunkButton
    local nextButton = CharacterMarkdownWindowButtonContainerNextChunkButton
    
    -- Log button access for debugging
    if not prevButton then
        CM.Warn("PrevChunkButton not found!")
    end
    if not nextButton then
        CM.Warn("NextChunkButton not found!")
    end
    
    if #markdownChunks > 1 then
        if instructionsLabel then
            instructionsLabel:SetText(string.format(
                "Chunk %d/%d: %s | PageUp/PageDown to navigate | Copy each chunk separately",
                currentChunkIndex, #markdownChunks, chunkToDisplay.name
            ))
        end
        -- Show navigation buttons - ensure they're fully visible
        if prevButton then 
            prevButton:SetHidden(false)
            prevButton:SetAlpha(1)  -- Ensure fully visible
            -- Try to bring button to front if method exists
            if prevButton.SetDrawLevel then
                prevButton:SetDrawLevel(1)
            end
            CM.DebugPrint("UI", "Prev button shown")
        end
        if nextButton then 
            nextButton:SetHidden(false)
            nextButton:SetAlpha(1)  -- Ensure fully visible
            -- Try to bring button to front if method exists
            if nextButton.SetDrawLevel then
                nextButton:SetDrawLevel(1)
            end
            CM.DebugPrint("UI", "Next button shown")
        end
    else
        if instructionsLabel then
            instructionsLabel:SetText("Click 'Select All', then Ctrl+A, then Ctrl+C to copy!")
        end
        -- Hide navigation buttons
        if prevButton then prevButton:SetHidden(true) end
        if nextButton then nextButton:SetHidden(true) end
    end
    
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
            
            -- Try one more time after a short delay to ensure focus sticks
            zo_callLater(function()
                if not windowControl:IsHidden() then
                    editBoxControl:TakeFocus()
                    editBoxControl:SelectAll()
                    editBoxControl:SetEditEnabled(false)  -- Back to read-only
                end
            end, 50)
            
            CM.DebugPrint("UI", "Window opened successfully - Chunk ready to copy")
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
