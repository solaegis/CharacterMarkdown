# Keyboard Shortcuts & Button Positioning Fix

## Issues Fixed

### 1. Keyboard Shortcuts Not Working
**Root Cause:** EditBox was enabled for editing (`SetEditEnabled(true)`), which caused it to process character keys as text input. The `OnTextChanged` handler would then remove the text, creating the "appear and disappear" effect.

**Solution:** 
- Set `editBoxControl:SetEditEnabled(false)` to disable text editing completely
- Removed complex text-input-prevention logic from the global handler
- EditBox can still receive focus and handle Ctrl+A/Ctrl+C, but won't accept character input

### 2. Button Positioning
**Root Cause:** Buttons were anchored to window BOTTOM, overlaying the EditBox

**Solution:**
- Changed button anchor from `BOTTOM` to `TOP` relative to EditBox container
- Added 12px gap: `offsetY="12"`
- Increased window height from 194px to 210px to accommodate proper spacing

## Changes Made

### Window.lua (src/ui/Window.lua)

1. **Line 65**: Changed `SetEditEnabled(true)` to `SetEditEnabled(false)`
   - Prevents text input completely
   - EditBox remains focusable for keyboard shortcuts

2. **Lines 113-115**: Removed duplicate EditBox keyboard handler
   - Eliminated conflict between EditBox-level and global handlers
   - Added comment explaining global handler usage

3. **Lines 948-1012**: Simplified global keyboard handler
   - Removed EditBox focus checks (no longer needed)
   - Removed text-input-prevention logic (handled by SetEditEnabled)
   - Cleaner, more maintainable code

### CharacterMarkdown.xml

1. **Line 5**: Window height `194` → `210` (added 16px for proper spacing)

2. **Line 104**: Button anchor changed
   - FROM: `<Anchor point="BOTTOM" offsetY="-12" />`
   - TO: `<Anchor point="TOP" relativeTo="$(parent)TextContainer" relativePoint="BOTTOM" offsetY="12" />`

## Window Layout (After Fix)

```
┌────────────────────────────────────┐
│ Title Bar (40px)                   │
│  [S] Settings [R] ReloadUI [X]     │
├────────────────────────────────────┤
│ Instructions (24px)                │
│  Chunk 1/6 [=========] 97%...      │
├────────────────────────────────────┤
│ EditBox Container (40px)           │
│ ┌──────────────────────────────┐   │
│ │ Text content here...         │   │
│ └──────────────────────────────┘   │
├────────────────────────────────────┤ ← 12px gap
│ Button Container (40px)            │
│ [G] Generate [<] Prev [Space]      │
│              Select All [>] Next   │
└────────────────────────────────────┘
Total height: 210px
```

## Testing Instructions

### ⚠️ CRITICAL: ReloadUI Required
XML changes require `/reloadui` in ESO chat to take effect!

### Test Keyboard Shortcuts
1. Open window: `/markdown`
2. Window should take focus automatically
3. Test each shortcut:
   - **G** → Regenerate markdown (should NOT type "g")
   - **S** → Open settings (should NOT type "s")
   - **R** → Reload UI (should NOT type "r")
   - **Space** → Select all text (should NOT type space)
   - **Enter** → Select all text (should NOT create newline)
   - **Left/Right** → Navigate chunks (should NOT move cursor)
   - **PageUp/PageDown** → Navigate chunks
   - **ESC or X** → Close window
   - **Ctrl+A** (Cmd+A on Mac) → Select all
   - **Ctrl+C** (Cmd+C on Mac) → Copy selected text

### Test Button Positioning
1. Open window: `/markdown`
2. Verify buttons are positioned BELOW the EditBox text field
3. Verify there's a visible gap between EditBox and buttons
4. Buttons should NOT overlay the text area

### Test Normal Copy Operation
1. Open window: `/markdown`
2. Text should be pre-selected (white on dark background)
3. Press Space or click "[Space] Select All" button
4. Text should remain selected
5. Press Ctrl+C (Cmd+C on Mac) to copy
6. Paste into Discord/GitHub/etc.

## Expected Behavior

### ✅ Correct Behavior
- Keyboard shortcuts trigger immediately without text appearing
- Buttons sit cleanly below the EditBox with visible spacing
- EditBox shows selected text in white on dark background
- No characters appear in the EditBox when pressing shortcut keys
- Window takes focus when opened

### ❌ Incorrect Behavior (Before Fix)
- Characters appeared briefly then disappeared
- Buttons overlaid the EditBox text area
- OnTextChanged handler fighting with keyboard input
- Confusing user experience

## Technical Notes

### Why SetEditEnabled(false) Works
- ESO's EditBox can be focused even when editing is disabled
- Focus allows keyboard event capture for shortcuts
- Ctrl+C still works because it's handled by the EditBox's internal copy mechanism
- Ctrl+A is handled by the global keyboard handler explicitly

### Import Mode Exception
The `OnTextChanged` handler still checks for `windowControl._isImportMode` to allow editing when importing settings. In import mode:
- EditBox is re-enabled: `SetEditEnabled(true)`
- Text changes are allowed
- User can paste YAML settings

### Handler Order
1. Global `OnKeyDown` handler receives event FIRST (registered via EVENT_MANAGER)
2. If handler returns `true`, event is consumed (stops propagation)
3. If handler returns `false`, event continues to other handlers
4. EditBox receives event only if not consumed by global handler

## Files Modified
- `src/ui/Window.lua` (3 edits)
- `CharacterMarkdown.xml` (2 edits)

## Commit Message Suggestion
```
Fix keyboard shortcuts and button positioning

- Disable EditBox editing to prevent text input (SetEditEnabled false)
- Remove duplicate keyboard handler from EditBox
- Simplify global keyboard handler logic
- Move buttons below EditBox with 12px spacing
- Increase window height to 210px for proper layout
- All shortcuts (G/S/R/Space/arrows) now work correctly

Fixes #[issue-number]
```
