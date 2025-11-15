# Keyboard Focus Management Fix

## Problem
After keyboard actions in the CharacterMarkdown window, the window would lose keyboard focus, requiring users to manually click back into the window before the next keyboard shortcut would work. This broke the flow of rapid keyboard navigation.

## Root Cause
ESO windows lose keyboard focus easily after actions like:
- Chunk navigation
- Settings panel opening
- Markdown regeneration
- Copy operations

The focus needs to be **aggressively and repeatedly reclaimed** after every action.

## Solution
Added aggressive keyboard focus restoration using the `EnsureWindowHasKeyboardFocus()` helper function after every keyboard action:

### Changes Made

1. **Focus Restoration After Every Action**
   - Added `zo_callLater(EnsureWindowHasKeyboardFocus, 100)` after each keyboard shortcut action
   - Longer delay (200ms) for copy operations
   
2. **Modified Keyboard Actions** (in EditBox OnKeyDown handler):
   - **G** (Generate): Added focus restoration
   - **S** (Settings): Added focus restoration
   - **Left/Comma** (Previous chunk): Added focus restoration
   - **Right/Period** (Next chunk): Added focus restoration
   - **PageUp** (Previous chunk): Added focus restoration
   - **PageDown** (Next chunk): Added focus restoration
   - **Space/Enter** (Copy): Added focus restoration with longer delay

3. **Modified Navigation Functions**:
   - **ShowChunk()**: Added `zo_callLater(EnsureWindowHasKeyboardFocus, 200)` at end
   - **CharacterMarkdown_ShowWindow()**: Added `zo_callLater(EnsureWindowHasKeyboardFocus, 250)` at end

### Code Pattern
```lua
-- Example: Navigation action with focus restoration
if key == KEY_RIGHTARROW or key == KEY_OEM_PERIOD then
    if #markdownChunks > 1 then
        CM.DebugPrint("KEYBOARD", "Right/Period pressed - next chunk")
        CharacterMarkdown_NextChunk()
        zo_callLater(EnsureWindowHasKeyboardFocus, 100)  -- CRITICAL: Restore focus
        return true -- Consume event
    end
end
```

## Testing
After these changes, users should be able to:
1. Open the window with `/markdown`
2. Press keyboard shortcuts in rapid succession without clicking
3. Navigate chunks with arrow keys/PageUp/PageDown continuously
4. Press Space to copy, then immediately navigate to next chunk
5. Press G to regenerate and continue using shortcuts immediately

## Technical Details

### EnsureWindowHasKeyboardFocus() Function
```lua
local function EnsureWindowHasKeyboardFocus()
    if windowControl and not windowControl:IsHidden() then
        -- Multiple methods to ensure focus
        windowControl:SetKeyboardEnabled(true)
        if windowControl.TakeFocus then
            windowControl:TakeFocus()
        end
        if windowControl.SetTopmost then
            windowControl:SetTopmost(true)
        end
        CM.DebugPrint("KEYBOARD", "Window keyboard focus ensured")
    end
end
```

### Focus Restoration Delays
- **Standard actions** (navigation, generate, settings): 100ms delay
- **Copy operations**: 200ms delay (longer to ensure clipboard operation completes)
- **ShowChunk()**: 200ms delay (after EditBox operations)
- **ShowWindow()**: 250ms delay (longest to ensure window fully rendered)

## Files Modified
1. `/src/ui/Window.lua`:
   - Fixed `EnsureWindowHasKeyboardFocus()` to enable keyboard on both window AND EditBox
   - Changed `editBoxControl:SetKeyboardEnabled(false)` to `true` in initialization
   - Added focus restoration calls after every keyboard action

2. `/CharacterMarkdown.xml`:
   - Added focus restoration to ALL button `OnClicked` handlers
   - Each button now calls `editBox:TakeFocus()` after its action

## Root Cause Found
The EditBox was initialized with `SetKeyboardEnabled(false)` which prevented it from receiving ANY keyboard events after the first action. This needed to be `true` for the EditBox to continuously receive OnKeyDown events.

## Status
✅ **COMPLETE** - All keyboard AND button actions now restore focus automatically
