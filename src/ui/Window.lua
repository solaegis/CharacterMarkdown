-- CharacterMarkdown - UI Window Handler
-- Manages the display window with direct EditBox (no scroll wrapper)

d("[CharacterMarkdown] Loading UI/Window.lua module...")

local CM = CharacterMarkdown

if not CM then
    d("[CharacterMarkdown] ❌ ERROR: CharacterMarkdown namespace not found in UI/Window.lua!")
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
        d("[CharacterMarkdown] ❌ ERROR: Window control not found! XML may not have loaded.")
        return false
    end
    
    -- Get the EditBox control
    editBoxControl = CharacterMarkdownWindowTextContainerEditBox
    
    if not editBoxControl then
        d("[CharacterMarkdown] ❌ ERROR: EditBox control not found!")
        return false
    end
    
    -- Get the hidden clipboard EditBox
    clipboardEditBoxControl = CharacterMarkdownWindowTextContainerClipboardEditBox
    
    if not clipboardEditBoxControl then
        d("[CharacterMarkdown] ⚠️ WARNING: Clipboard EditBox not found - using main EditBox")
    end
    
    -- Configure EditBox with INCREASED character limit and READ-ONLY mode
    editBoxControl:SetMaxInputChars(1000000)  -- Increased from 500000 to 1 million
    editBoxControl:SetMultiLine(true)
    editBoxControl:SetNewLineEnabled(true)
    editBoxControl:SetEditEnabled(false)  -- Make READ-ONLY - cannot be edited
    
    -- Set to WHITE text on DARK background
    editBoxControl:SetFont("ZoFontChat")
    editBoxControl:SetColor(1, 1, 1, 1)  -- White text
    
    d("[CharacterMarkdown] ✅ Window controls initialized successfully")
    return true
end

-- =====================================================
-- COPY TO CLIPBOARD FUNCTION (Called from XML button)
-- =====================================================

function CharacterMarkdown_CopyToClipboard()
    if not editBoxControl or not currentMarkdown or currentMarkdown == "" then
        d("[CharacterMarkdown] ❌ ERROR: No content to copy")
        return
    end
    
    local markdownLength = string.len(currentMarkdown)
    d("[CharacterMarkdown] Preparing to copy " .. markdownLength .. " characters")
    
    -- Show the EXACT last 200 characters of the markdown
    local last200 = string.sub(currentMarkdown, -200)
    d("[CharacterMarkdown] ===== LAST 200 CHARACTERS OF MARKDOWN =====")
    d(last200)
    d("[CharacterMarkdown] ===== END OF MARKDOWN =====")
    
    -- Refresh the EditBox with full text
    editBoxControl:SetEditEnabled(true)
    editBoxControl:SetText(currentMarkdown)
    editBoxControl:SetColor(1, 1, 1, 1)
    editBoxControl:SetEditEnabled(false)
    
    zo_callLater(function()
        -- Select all and take focus
        editBoxControl:SelectAll()
        editBoxControl:TakeFocus()
        
        d("[CharacterMarkdown] ✅ Text selected!")
        d("[CharacterMarkdown] Copy workaround: Press Ctrl+A, then Ctrl+C")
        d("[CharacterMarkdown] After copying, paste and check if you have the ending shown above")
    end, 100)
end

-- =====================================================
-- SHOW WINDOW FUNCTION
-- =====================================================

function CharacterMarkdown_ShowWindow(markdown, format)
    -- Validate inputs
    if not markdown or markdown == "" then
        d("[CharacterMarkdown] ❌ ERROR: No markdown content provided to window")
        return false
    end
    
    format = format or "github"
    
    -- Initialize controls if needed
    if not InitializeWindowControls() then
        d("[CharacterMarkdown] ❌ Window initialization failed")
        return false
    end
    
    -- Store markdown for clipboard operations
    currentMarkdown = markdown
    
    -- Temporarily enable editing to set text
    editBoxControl:SetEditEnabled(true)
    editBoxControl:SetText(markdown)
    editBoxControl:SetColor(1, 1, 1, 1)  -- White text
    editBoxControl:SetEditEnabled(false)  -- Make read-only again
    
    -- Debug: Verify text was set correctly
    local textLength = string.len(markdown)
    local editBoxText = editBoxControl:GetText()
    local editBoxLength = string.len(editBoxText)
    
    d("[CharacterMarkdown] Original markdown: " .. textLength .. " characters")
    d("[CharacterMarkdown] EditBox contains: " .. editBoxLength .. " characters")
    
    if editBoxLength < textLength then
        d("[CharacterMarkdown] ⚠️ WARNING: EditBox truncated " .. (textLength - editBoxLength) .. " characters!")
        d("[CharacterMarkdown] However, 'Copy to Clipboard' will use the FULL original text.")
    end
    
    -- Show last 100 characters of original markdown
    local markdownEnd = string.sub(markdown, -100)
    d("[CharacterMarkdown] Last 100 chars of markdown: ..." .. markdownEnd)
    
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
    
    d("[CharacterMarkdown] ✅ Window opened - text should be visible as WHITE on DARK background")
    d("[CharacterMarkdown] ✅ Click 'Select All' button, then press Ctrl+C (or Cmd+C) to copy")
    
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
        d("[CharacterMarkdown] Window closed")
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

d("[CharacterMarkdown] ✅ UI/Window.lua module loaded successfully")
d("[CharacterMarkdown] CharacterMarkdown_ShowWindow: " .. tostring(CharacterMarkdown_ShowWindow))
d("[CharacterMarkdown] CharacterMarkdown_CopyToClipboard: " .. tostring(CharacterMarkdown_CopyToClipboard))
