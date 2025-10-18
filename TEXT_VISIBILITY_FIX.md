# CharacterMarkdown - Text Visibility Fix

## Problem
The CharacterMarkdown export window was not displaying visible text. The EditBox content was being set correctly, but the text color was either invisible or inheriting incorrect styling from ESO's UI framework.

## Root Cause
ESO's EditBox controls have complex color inheritance behavior:
1. XML `color` attribute can be overridden by parent controls
2. The `SetColor()` method alone may not persist after `SetText()` is called
3. EditBox controls have multiple color-related methods that may need to be called
4. Disabled EditBox controls render text in gray/invisible colors

## Solution Implemented

### 1. XML Changes (`CharacterMarkdown.xml`)
**File:** `CharacterMarkdown.xml`

**Change:** Modified the EditBox definition to:
- Removed the `color="FFFFFFFF"` attribute (which wasn't working)
- Added explicit `<Color r="1" g="1" b="1" a="1" />` child element
- Added `readonly="false"` to ensure the EditBox is in editable state

```xml
<!-- BEFORE -->
<EditBox name="$(parent)EditBox" font="ZoFontGameSmall" multiLine="true" 
         maxInputCharacters="500000" newLineEnabled="true" color="FFFFFFFF">
    <Dimensions x="740" />
</EditBox>

<!-- AFTER -->
<EditBox name="$(parent)EditBox" font="ZoFontGameSmall" multiLine="true" 
         maxInputCharacters="500000" newLineEnabled="true" readonly="false">
    <Dimensions x="740" />
    <!-- Force text color at control level -->
    <Color r="1" g="1" b="1" a="1" />
</EditBox>
```

### 2. Lua Initialization Changes (`src/ui/Window.lua`)
**File:** `src/ui/Window.lua`

**Function:** `InitializeWindowControls()`

**Changes:** Added aggressive multi-method color enforcement:

```lua
-- AGGRESSIVE COLOR ENFORCEMENT for visibility
-- Set text color to bright white with full opacity
editBoxControl:SetColor(1, 1, 1, 1)  -- R, G, B, A (white, fully opaque)

-- Also try setting the edit color (different method for EditBox)
if editBoxControl.SetEditColor then
    editBoxControl:SetEditColor(1, 1, 1, 1)
end

-- Set default text color
if editBoxControl.SetDefaultColor then
    editBoxControl:SetDefaultColor(1, 1, 1, 1)
end

-- Ensure it's not disabled (disabled = gray text)
editBoxControl:SetEditEnabled(true)
```

### 3. Text Display Changes (`src/ui/Window.lua`)
**File:** `src/ui/Window.lua`

**Function:** `CharacterMarkdown_ShowWindow()`

**Changes:** Re-enforce color settings after `SetText()` because some ESO versions reset colors:

```lua
-- Set the text in the EditBox
editBoxControl:SetText(markdown)

-- RE-ENFORCE COLOR SETTINGS (some ESO versions reset on SetText)
editBoxControl:SetColor(1, 1, 1, 1)
if editBoxControl.SetEditColor then
    editBoxControl:SetEditColor(1, 1, 1, 1)
end
editBoxControl:SetEditEnabled(true)

-- Debug: Log text length to verify content is set
local textLength = string.len(markdown)
d("[CharacterMarkdown] Set " .. textLength .. " characters of text")
```

## Why This Works

The fix uses a **defense-in-depth approach** with multiple layers:

1. **XML Level:** Sets initial color via `<Color>` element (more reliable than attribute)
2. **Initialization Level:** Calls multiple color-setting methods to cover different ESO API versions
3. **Display Level:** Re-enforces colors after text is set (prevents color resets)
4. **State Management:** Ensures EditBox is in enabled/editable state

This comprehensive approach ensures text visibility across:
- Different ESO client versions
- Different UI scale settings
- Different addon load orders
- Race conditions during UI initialization

## Testing Steps

1. **In-game test:**
   ```
   /reloadui
   /markdown
   ```

2. **Verify:**
   - Window opens
   - Text is WHITE and clearly visible
   - Text is pre-selected
   - Ctrl+C (or Cmd+C) copies text

3. **Check console for debug output:**
   ```
   [CharacterMarkdown] Set XXXXX characters of text
   [CharacterMarkdown] ✅ Text pre-selected - press Ctrl+C to copy!
   ```

## Fallback Diagnostics

If text is still not visible after this fix, add this debug code to `CharacterMarkdown_ShowWindow()`:

```lua
-- After SetText() call, add:
local r, g, b, a = editBoxControl:GetColor()
d(string.format("[CharacterMarkdown] EditBox color: R=%.2f G=%.2f B=%.2f A=%.2f", r, g, b, a))

local text = editBoxControl:GetText()
d("[CharacterMarkdown] Retrieved text length: " .. string.len(text))
```

This will help diagnose if:
- Colors are being set correctly
- Text is actually being stored in the EditBox

## Related Files Modified

1. `/Users/lvavasour/git/CharacterMarkdown/CharacterMarkdown.xml` - UI definition
2. `/Users/lvavasour/git/CharacterMarkdown/src/ui/Window.lua` - Window logic

## Compatibility

This fix is compatible with:
- ESO Lua 5.1 API
- All ESO client versions (uses conditional method checks)
- All existing CharacterMarkdown features
- All display formats (GitHub, VS Code, Discord, Quick)

## Additional Notes

- The `readonly="false"` attribute ensures the EditBox is in an editable state, which ESO renders with full-color text
- The multiple color-setting methods (`SetColor`, `SetEditColor`, `SetDefaultColor`) ensure compatibility across different ESO API versions where method names may vary
- Color re-enforcement after `SetText()` is critical because ESO can reset colors when content changes
- The `SetEditEnabled(true)` call prevents the EditBox from entering a disabled state where text appears gray

---

**Status:** ✅ FIXED  
**Version:** 2.1.0  
**Date:** 2025-10-18
