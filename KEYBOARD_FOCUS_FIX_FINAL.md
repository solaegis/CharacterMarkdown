# Keyboard Focus Management Fix - FINAL SOLUTION

## Problem
After keyboard actions in the CharacterMarkdown window, the window would lose keyboard focus, requiring users to manually click back into the window before the next keyboard shortcut would work. This broke the flow of rapid keyboard navigation.

## Root Cause
**EditBox focus is unreliable in ESO.** When the EditBox loses focus (which happens easily after any action), it stops receiving OnKeyDown events. The `zo_callLater()` focus restoration attempts were queued AFTER the main function returned, so the EditBox had already lost focus by the time they executed.

## Solution: Global Keyboard Handler
Instead of relying on EditBox focus, we register a **global EVENT_KEY_DOWN handler** that's always listening when the window is open. This completely bypasses the EditBox focus issue.

### Implementation

```lua
-- In OnAddOnLoaded function:
EVENT_MANAGER:RegisterForEvent("CharacterMarkdown_GlobalKeyboard", EVENT_KEY_DOWN, function(_, key, ctrl, alt, shift, command)
    -- Only handle when window is visible
    if not windowControl or windowControl:IsHidden() then
        return
    end
    
    -- Skip if in import mode
    if windowControl._isImportMode then
        return
    end
    
    -- Handle all keyboard shortcuts here (G, S, R, arrows, PageUp/PageDown, Space/Enter)
    -- ...
end)
```

### Key Advantages
1. **Always active** - Handler receives ALL key events when window is open, regardless of EditBox focus
2. **No focus management needed** - Doesn't rely on EditBox having focus
3. **No delays** - Responds immediately to keypresses
4. **Simple and reliable** - Single event handler for all shortcuts

## Changes Made

### 1. `/src/ui/Window.lua`
- **Removed** all `zo_callLater(EnsureWindowHasKeyboardFocus, ...)` calls from keyboard shortcuts
- **Removed** `EnsureWindowHasKeyboardFocus()` function calls from ShowChunk() and ShowWindow()
- **Added** global EVENT_KEY_DOWN handler in OnAddOnLoaded
- **Kept** EditBox OnKeyDown handler for text input prevention (still needed)
- **Kept** `editBoxControl:SetKeyboardEnabled(true)` for Ctrl+C copy functionality

### 2. `/CharacterMarkdown.xml`
- **Removed** all focus restoration code from button OnClicked handlers
- Buttons now just call their functions directly

## Testing
After these changes, users can:
1. Open the window with `/markdown`
2. Press keyboard shortcuts in rapid succession without ANY clicking
3. Navigate chunks with arrow keys/PageUp/PageDown continuously
4. Press Space to copy, then immediately navigate to next chunk
5. Press G to regenerate and continue using shortcuts immediately
6. Click any button and immediately use keyboard shortcuts

## Technical Details

### Global Handler Registration
```lua
EVENT_MANAGER:RegisterForEvent(
    "CharacterMarkdown_GlobalKeyboard",  -- Unique event name
    EVENT_KEY_DOWN,                       -- Listen for ALL key down events
    function(_, key, ctrl, alt, shift, command)
        -- Handler only active when window is visible
        -- Handler skipped when in import mode
        -- All shortcuts handled here
    end
)
```

### Supported Shortcuts (Global)
- **ESC / X** - Close window
- **G** - Regenerate markdown
- **S** - Open settings
- **R** - Reload UI
- **Left / Comma** - Previous chunk
- **Right / Period** - Next chunk  
- **PageUp** - Previous chunk
- **PageDown** - Next chunk
- **Space / Enter** - Copy to clipboard

### EditBox Still Used For
- Displaying text content
- Ctrl+A (select all)
- Ctrl+C (copy to clipboard)
- Text selection visual feedback

## Files Modified
1. `/src/ui/Window.lua`: Added global keyboard handler, removed focus management
2. `/CharacterMarkdown.xml`: Removed focus restoration from buttons

## Status
✅ **COMPLETE** - Global keyboard handler eliminates focus issues entirely

## Why This Works
The global EVENT_KEY_DOWN handler receives keyboard events **before** they reach any UI controls. This means:
- Keypresses are handled even if EditBox doesn't have focus
- No delays from `zo_callLater()` queuing
- No race conditions with focus management
- Simple, predictable, reliable behavior
