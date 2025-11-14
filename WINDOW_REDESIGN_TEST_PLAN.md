# Window Redesign Test Plan

## Test Cases

### 1. Single Chunk Mode
**How to test**: Generate markdown for a small character with minimal data
**Expected behavior**:
- ✅ Previous button: Disabled (50% alpha, greyed out, not clickable)
- ✅ Next button: Disabled (50% alpha, greyed out, not clickable)
- ✅ Generate button: Enabled (full opacity, white text)
- ✅ Select All button: Enabled (full opacity, white text)
- ✅ Dismiss button: Enabled (full opacity, white text)
- ✅ Navigation hint shows "PageUp / PageDown" in center
- ✅ Window height: 250px

### 2. Multiple Chunks Mode
**How to test**: Generate markdown for a character with lots of data (achievements, quests, etc.)
**Expected behavior**:
- ✅ Previous button: Enabled (full opacity, clickable)
- ✅ Next button: Enabled (full opacity, clickable)
- ✅ All other buttons: Enabled (full opacity)
- ✅ Chunk info shows: "Chunk 1/N  ████░░░░ XX%  •  X,XXX / 21,500 bytes  •  (OK/WARN/FULL)"
- ✅ Navigation between chunks works with buttons, arrows, PageUp/PageDown

### 3. Settings Export Mode
**Command**: `/cmdsettings export`
**Expected behavior**:
- ✅ Previous button: Disabled (50% alpha)
- ✅ Next button: Disabled (50% alpha)
- ✅ Generate button: Disabled (50% alpha)
- ✅ Select All button: Enabled (full opacity)
- ✅ Dismiss button: Enabled, shows "Dismiss" (full opacity)
- ✅ Instructions show: "Settings in YAML format..."

### 4. Settings Import Mode
**Command**: `/cmdsettings import`
**Expected behavior**:
- ✅ Previous button: Disabled (50% alpha)
- ✅ Next button: Disabled (50% alpha)
- ✅ Generate button: Disabled (50% alpha)
- ✅ Select All button: Disabled (50% alpha)
- ✅ Dismiss button: Enabled, shows "Import" (full opacity)
- ✅ EditBox is editable (can paste YAML)
- ✅ Instructions show: "Paste YAML settings below..."

### 5. Normal Markdown Mode (after export/import)
**How to test**: Open export mode, then generate markdown
**Expected behavior**:
- ✅ All buttons properly re-enabled based on chunk count
- ✅ Dismiss button shows "Dismiss" (not "Import")
- ✅ EditBox is read-only (not editable)

### 6. Visual Layout
**Expected dimensions**:
- ✅ Window: 1000x250px
- ✅ Title bar: 40px height
- ✅ Chunk info bar: 30px height
- ✅ EditBox: 60px height (2 lines visible)
- ✅ Primary actions row: 36px height
- ✅ Navigation row: 36px height
- ✅ Bottom padding: 8px

**Button layout**:
- ✅ Primary row: [Generate (150px)] --- [Select All (180px)] --- [Dismiss (150px)]
- ✅ Navigation row: [Previous (120px)] --- [PageUp/PageDown hint] --- [Next (120px)]

### 7. Button Color Changes
**Expected behavior**:
- ✅ Disabled buttons: 50% alpha (greyed out)
- ✅ Enabled buttons: 100% alpha (white text)
- ✅ Select All button: Changes from white to green after clicking
- ✅ Status indicator: Green (OK), Yellow (WARN), Red (FULL)

### 8. Keyboard Shortcuts
**All shortcuts should still work**:
- ✅ G: Generate
- ✅ S: Settings
- ✅ R: ReloadUI
- ✅ Space/Enter: Select All
- ✅ Left/Comma: Previous chunk (if available)
- ✅ Right/Period: Next chunk (if available)
- ✅ PageUp: Previous chunk (if available)
- ✅ PageDown: Next chunk (if available)
- ✅ Esc/X: Close window

## Code Review Validation

### XML Structure ✅
- Window dimensions updated to 1000x250px
- Two button rows created (ButtonContainer and NavigationContainer)
- Navigation buttons moved to NavigationContainer
- Proper spacing and layout

### Window.lua Changes ✅
- All button visibility changes use SetEnabled/SetAlpha
- No more SetHidden() calls for buttons
- ShowChunk() properly enables/disables navigation
- ShowWindow() re-enables buttons in normal mode
- ShowSettingsExport() disables appropriate buttons
- ShowSettingsImport() disables appropriate buttons

## Testing Commands

```lua
-- Test single chunk
/markdown

-- Test multiple chunks (if character has lots of data)
/markdown github

-- Test export mode
/cmdsettings export

-- Test import mode
/cmdsettings import

-- Test regeneration from window
-- Open window, press [G] or click Generate button

-- Test chunk navigation
-- Open window with multiple chunks, use arrows/buttons/PageUp/PageDown
```

## Known Issues to Watch For
- EditBox character limits (should handle 22k chars)
- Button references might need NavigationContainer prefix in some places
- Platform-specific keyboard shortcuts (Windows Ctrl vs Mac Cmd)

