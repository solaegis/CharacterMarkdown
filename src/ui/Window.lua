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
    editBoxControl:SetMaxInputChars(1000000)  -- Increased from 500000 to 1 million
    editBoxControl:SetMultiLine(true)
    editBoxControl:SetNewLineEnabled(true)
    editBoxControl:SetEditEnabled(false)  -- Make READ-ONLY - cannot be edited
    
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
    
    -- Store markdown for clipboard operations
    currentMarkdown = markdown
    
    -- Temporarily enable editing to set text
    editBoxControl:SetEditEnabled(true)
    editBoxControl:SetText(markdown)
    editBoxControl:SetColor(1, 1, 1, 1)  -- White text
    editBoxControl:SetEditEnabled(false)  -- Make read-only again
    
    -- Show window
    windowControl:SetHidden(false)
    
    -- Bring window to top
    if windowControl.SetTopmost then
        windowControl:SetTopmost(true)
    end
    
    -- Auto-select text after a delay
    zo_callLater(function()
        editBoxControl:SelectAll()
        editBoxControl:TakeFocus()
    end, 100)
    
    CM.DebugPrint("UI", "Window opened successfully")
    
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

local function OnAddOnLoaded(event, addonName)
    if addonName ~= "CharacterMarkdown" then
        return
    end
    
    zo_callLater(function()
        InitializeWindowControls()
    end, 100)
end

EVENT_MANAGER:RegisterForEvent("CharacterMarkdown_UI", EVENT_ADD_ON_LOADED, OnAddOnLoaded)

CM.DebugPrint("UI", "Window module loaded successfully")
