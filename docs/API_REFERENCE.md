# API Reference

> **Comprehensive guide to ESO Lua API patterns, controls, and common gotchas**

---

## Table of Contents

- [ESO Lua Runtime](#eso-lua-runtime)
- [EditBox Controls](#editbox-controls)
- [Clipboard System](#clipboard-system)
- [String Handling](#string-handling)
- [Event System](#event-system)
- [API Versioning](#api-versioning)
- [Common Gotchas](#common-gotchas)
- [Troubleshooting](#troubleshooting)

---

## ESO Lua Runtime

### Base Environment

**Engine Specification:**
- **Base Version:** Lua 5.1.4 (with ZeniMax modifications)
- **Integration:** Embedded in C++ game client
- **Execution Model:** Event-driven, single-threaded per addon context
- **Memory Management:** Garbage collected (Lua's standard GC)

### Disabled Modules

```lua
-- DISABLED MODULES (return nil or throw errors)
io          -- No file I/O operations
os.execute  -- No system command execution
os.remove   -- No file deletion
os.rename   -- No file manipulation
loadfile    -- No external file loading
dofile      -- No external script execution

-- RESTRICTED MODULES
os.date     -- Available (read-only system time)
os.time     -- Available (read-only)
os.clock    -- Available (for performance timing)

-- MODIFIED BEHAVIOR
string.len  -- Returns BYTE count, not character count (UTF-8 aware separately)
table.*     -- Standard Lua behavior preserved
math.*      -- Standard Lua behavior preserved
```

### Global Namespace

ESO populates hundreds of global functions:

```lua
-- ESO API examples
GetPlayerName()
GetNumBagSlots()
GetItemLink()
-- ... ~2000+ global API functions

-- BEST PRACTICE: Use local references
local GetPlayerName = GetPlayerName  -- Cache global lookup
```

### Safe API Calls

```lua
-- Always use pcall for API calls that might fail
local function SafeGetPlayerStat(statType, defaultValue)
    local success, value = pcall(function()
        return GetPlayerStat(statType)
    end)
    return (success and value) or defaultValue
end
```

---

## EditBox Controls

### Control Hierarchy

```
Control (base)
  ↓
EditBox (inherits Control)
  ↓
  Properties:
  - text (internal C++ buffer)
  - maxInputChars (character limit)
  - multiLine (boolean)
  - readonly (boolean)
  - font (string reference)
  - color (RGBA)
```

### Core Methods

```lua
-- Text manipulation
editBox:SetText(string)                -- Set text content
editBox:GetText() → string             -- Get text content
editBox:InsertText(string)             -- Insert at cursor position

-- Selection
editBox:SelectAll()                    -- Select all text
editBox:ClearSelection()               -- Remove selection

-- Focus
editBox:TakeFocus()                    -- Give keyboard focus
editBox:LoseFocus()                    -- Remove keyboard focus

-- Configuration
editBox:SetMaxInputChars(number)       -- Set character limit
editBox:GetMaxInputChars() → number    -- Get character limit
editBox:SetMultiLine(boolean)          -- Enable multiline
editBox:IsMultiLine() → boolean        -- Check if multiline
editBox:SetNewLineEnabled(boolean)     -- Enable newline input
editBox:SetEditEnabled(boolean)        -- Enable/disable editing (readonly)

-- Visual
editBox:SetFont(string)                -- Set font (e.g., "ZoFontChat")
editBox:SetColor(r, g, b, a)          -- Set text color (0-1 range)

-- Control base methods (inherited)
editBox:SetHidden(boolean)             -- Show/hide control
editBox:IsHidden() → boolean           -- Check if hidden
editBox:GetWidth() → number            -- Get width in pixels
editBox:GetHeight() → number           -- Get height in pixels
```

### Buffer Management

**Important:** EditBox text is stored in C++ buffer, not Lua memory:

```lua
-- When you call SetText():
editBox:SetText(luaString)
-- Internally:
-- 1. Lua string (UTF-8) → C++ conversion
-- 2. UTF-8 → UTF-16/wide char conversion
-- 3. Stored in C++ buffer
-- 4. Truncation at maxInputChars BOUNDARY

-- When you call GetText():
local text = editBox:GetText()
-- Internally:
-- 1. C++ buffer → UTF-16 to UTF-8 conversion
-- 2. UTF-8 → Lua string
-- 3. New Lua string allocated
```

### Configuration for Large Text

```lua
local function ConfigureEditBoxForLargeText(editBox)
    editBox:SetMaxInputChars(1000000)  -- 1 million characters
    editBox:SetMultiLine(true)
    editBox:SetNewLineEnabled(true)
    editBox:SetEditEnabled(false)      -- Readonly
    editBox:SetFont("ZoFontChat")
    editBox:SetColor(1, 1, 1, 1)       -- White text
end
```

---

## Clipboard System

### Native Integration

ESO does **not expose direct clipboard API** to Lua. Clipboard operations happen through:

1. **User Input:** Player presses Ctrl+C / Ctrl+V
2. **Native Handler:** Game's C++ input system intercepts
3. **EditBox Bridge:** If EditBox has focus and selection, text copies

### Copy Operation Flow

```lua
-- 1. Addon sets text
editBox:SetText(markdown)

-- 2. Addon selects text
editBox:SelectAll()

-- 3. Addon gives focus
editBox:TakeFocus()

-- 4. User presses Ctrl+C (required)
-- Game's input handler intercepts and copies to OS clipboard
```

### Reliable Copy Pattern

```lua
function ReliableCopyToClipboard(editBox, text)
    -- Step 1: Enable editing temporarily
    editBox:SetEditEnabled(true)
    
    -- Step 2: Set text
    editBox:SetText(text)
    
    -- Step 3: Delayed focus (allows rendering)
    zo_callLater(function()
        editBox:TakeFocus()
        
        -- Step 4: Delayed selection
        zo_callLater(function()
            editBox:SelectAll()
            
            -- Step 5: Make readonly again
            zo_callLater(function()
                editBox:SetEditEnabled(false)
            end, 2000)  -- Give user 2 seconds to copy
            
        end, 100)
    end, 50)
end
```

### Known Limitations

- No direct clipboard API (e.g., `SetClipboardText()` doesn't exist)
- Timing-sensitive operations (focus/selection)
- Edge cases with trailing truncation (~50 chars in some scenarios)
- Platform differences (Windows vs macOS)

---

## String Handling

### UTF-8 Encoding

```lua
-- Lua strings in ESO are UTF-8 encoded
local str = "Hello 世界"  -- Valid UTF-8 string

-- Byte length vs Character length:
string.len(str)  -- Returns BYTE count: 12
-- Breakdown: "Hello " = 6 bytes, "世界" = 6 bytes
```

### Safe Truncation

```lua
local function SafeTruncate(str, byteLimit)
    if string.len(str) <= byteLimit then
        return str
    end
    
    local truncated = string.sub(str, 1, byteLimit)
    
    -- Walk back to find valid UTF-8 boundary
    while byteLimit > 0 do
        local byte = string.byte(truncated, byteLimit)
        if not byte then break end
        
        -- Check if valid UTF-8 start byte
        if byte < 128 or byte >= 192 then
            break
        end
        
        byteLimit = byteLimit - 1
    end
    
    return string.sub(str, 1, byteLimit)
end
```

### Efficient String Building

```lua
-- SLOW: Repeated concatenation
local result = ""
for i = 1, 1000 do
    result = result .. "Line " .. i .. "\n"
end

-- FAST: Table concatenation
local parts = {}
for i = 1, 1000 do
    table.insert(parts, "Line ")
    table.insert(parts, tostring(i))
    table.insert(parts, "\n")
end
local result = table.concat(parts)
```

### Newline Handling

```lua
-- ESO EditBox expects \n (LF) for newlines
editBox:SetText("Line 1\nLine 2\nLine 3")

-- Windows clipboard may convert:
-- \n → \r\n (CRLF)
-- This is NORMAL and handled by OS

-- Don't manually convert:
-- markdown = string.gsub(markdown, "\n", "\r\n")  -- ❌ Don't do this
```

---

## Event System

### Event Registration

```lua
-- Register event
EVENT_MANAGER:RegisterForEvent(
    namespace,      -- string: unique identifier
    eventId,        -- number: event constant
    callback        -- function: handler
)

-- Unregister event
EVENT_MANAGER:UnregisterForEvent(
    namespace,
    eventId
)
```

### Common Events

```lua
EVENT_ADD_ON_LOADED                    -- Addon finished loading
EVENT_PLAYER_ACTIVATED                 -- Player entered world
EVENT_INVENTORY_SINGLE_SLOT_UPDATE     -- Item changed
EVENT_SKILL_POINTS_CHANGED             -- Skills updated
EVENT_CHAMPION_POINT_UPDATE            -- CP changed
```

### Addon Initialization Pattern

```lua
local function OnAddOnLoaded(event, addonName)
    if addonName ~= "CharacterMarkdown" then return end
    
    -- At this point:
    -- ✅ XML controls exist and are accessible
    -- ✅ Global namespace is populated
    -- ✅ SavedVariables are loaded
    -- ❌ UI may not be fully rendered yet
    -- ❌ Game data may still be loading
    
    -- Recommended: Delay UI operations
    zo_callLater(function()
        -- Safe to manipulate UI controls here
    end, 100)
end

EVENT_MANAGER:RegisterForEvent("CharacterMarkdown", EVENT_ADD_ON_LOADED, OnAddOnLoaded)
```

---

## API Versioning

### Version Numbers

```lua
-- Get current API version
local apiVersion = GetAPIVersion()
-- Example: 101046 (Update 46, Gold Road)

-- Format: XXYYZZ
-- XX = Major update number
-- YY = Minor update number
-- ZZ = Patch number
```

### Manifest Declaration

```
## APIVersion: 101045 101046
```

Supports multiple versions (backward compatibility).

### Version Checking

```lua
local function IsAPIVersionSupported(requiredVersion)
    local currentVersion = GetAPIVersion()
    return currentVersion >= requiredVersion
end

if not IsAPIVersionSupported(101045) then
    d("[CharacterMarkdown] ERROR: Requires API version 101045+")
    return
end
```

---

## Common Gotchas

### 1. EditBox Focus Glitch

**Symptom:** TakeFocus() sometimes doesn't give focus

**Workaround:**
```lua
local function ReliableFocus(editBox)
    editBox:TakeFocus()
    zo_callLater(function()
        editBox:TakeFocus()  -- Call twice
    end, 50)
end
```

### 2. SelectAll Timing

**Symptom:** SelectAll() before render completes = partial selection

**Workaround:**
```lua
local function ReliableSelectAll(editBox)
    editBox:TakeFocus()
    zo_callLater(function()
        editBox:SelectAll()
    end, 100)  -- Wait for focus to settle
end
```

### 3. Global Namespace Pollution

**Issue:** ESO creates ~2000+ global functions

**Solution:**
```lua
-- Cache globals locally
local GetPlayerName = GetPlayerName
local GetNumBagSlots = GetNumBagSlots

-- Namespace your addon
CharacterMarkdown = CharacterMarkdown or {}
```

### 4. String Length Confusion

**Issue:** `string.len()` returns bytes, not characters

**Solution:**
```lua
local str = "日本語"
string.len(str)  -- Returns 9 (bytes)
-- Need custom function for character count

local function CharacterCount(str)
    local _, count = string.gsub(str, "[^\128-\193]", "")
    return count
end
```

### 5. Protected Function Restrictions

**Issue:** Some API functions disabled during combat

**Solution:**
```lua
if IsUnitInCombat("player") then
    d("Cannot perform action during combat")
    return
end

-- EditBox operations work in combat:
-- ✅ SetText()
-- ✅ GetText()
-- ✅ SelectAll()
```

---

## Troubleshooting

### Debug Output

```lua
-- d() function (ESO-specific)
d("Debug message")  -- Prints to chat

-- Table printing
local function PrintTable(tbl, indent)
    indent = indent or 0
    for k, v in pairs(tbl) do
        local formatting = string.rep("  ", indent) .. tostring(k) .. ": "
        if type(v) == "table" then
            d(formatting)
            PrintTable(v, indent + 1)
        else
            d(formatting .. tostring(v))
        end
    end
end
```

### String Inspection

```lua
local function InspectString(str)
    d("String length (bytes): " .. string.len(str))
    d("First 100: " .. string.sub(str, 1, 100))
    d("Last 100: " .. string.sub(str, -100))
    
    -- Byte dump (for encoding issues)
    local bytes = {}
    for i = 1, math.min(20, string.len(str)) do
        table.insert(bytes, string.byte(str, i))
    end
    d("First 20 bytes: " .. table.concat(bytes, " "))
end
```

### EditBox State Verification

```lua
local function VerifyEditBox(editBox)
    if not editBox then
        d("❌ EditBox is nil")
        return
    end
    
    d("✅ EditBox exists")
    d("  Hidden: " .. tostring(editBox:IsHidden()))
    d("  Text length: " .. string.len(editBox:GetText()))
    d("  Max chars: " .. tostring(editBox:GetMaxInputChars()))
    d("  MultiLine: " .. tostring(editBox:IsMultiLine()))
end
```

### Performance Profiling

```lua
local function ProfileFunction(name, func, ...)
    local startTime = GetFrameTimeSeconds()
    local result = {func(...)}
    local endTime = GetFrameTimeSeconds()
    
    d(string.format("[%s] Execution time: %.3fms", name, (endTime - startTime) * 1000))
    
    return unpack(result)
end

-- Usage:
ProfileFunction("GenerateMarkdown", GenerateMarkdown, "GITHUB")
```

---

## Global Utility Functions

```lua
-- Delayed execution
zo_callLater(function, delayMs)

-- String formatting (ESO-specific)
zo_strformat(format, ...)

-- Debugging
d(message)

-- Safe calls
pcall(function, ...)

-- Type checking
type(value) → string
tostring(value) → string
tonumber(value) → number|nil
```

---

## Additional Resources

- **ESOUI GitHub:** https://github.com/esoui/esoui
- **ESOUI Wiki:** https://wiki.esoui.com/
- **Lua 5.1 Manual:** https://www.lua.org/manual/5.1/
- **UESP Wiki (Online):** https://en.uesp.net/wiki/Online:Online

---

**Last Updated:** January 2025  
**API Version:** 101046 (Gold Road)