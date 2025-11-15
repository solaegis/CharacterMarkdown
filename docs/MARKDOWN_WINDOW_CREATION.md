# Markdown Window Creation - Step-by-Step Outline

## Overview
This document outlines the complete process of creating and displaying a markdown window in CharacterMarkdown, from user command to final display.

---

## Phase 1: Initialization (On Addon Load)

### 1.1 Addon Load Event
- **Location**: `src/ui/Window.lua` - `OnAddOnLoaded()`
- **Trigger**: `EVENT_ADD_ON_LOADED` when addon loads
- **Steps**:
  1. Wait for addon to fully load (`zo_callLater` with 100ms delay)
  2. Call `InitializeWindowControls()` to set up UI controls
  3. Register global keyboard handler (`EVENT_KEY_DOWN`) for shortcuts

### 1.2 Window Controls Initialization
- **Location**: `src/ui/Window.lua` - `InitializeWindowControls()`
- **Steps**:
  1. Get window control from XML (`CharacterMarkdownWindow`)
  2. Configure background control (colors, borders, textures)
  3. Get EditBox control (`CharacterMarkdownWindowTextContainerEditBox`)
  4. Configure EditBox:
     - Set max input chars (22000)
     - Enable multi-line mode
     - Enable keyboard input
     - Set text color (white)
     - Set font
  5. Register `OnChar` handler (prevents text input in normal mode)
  6. Register `OnKeyDown` handler (prevents text input, allows Ctrl+A/Ctrl+C)
  7. Return success status

---

## Phase 2: User Command

### 2.1 Command Parsing
- **Location**: `src/Commands.lua` - `CommandHandler()`
- **Trigger**: User types `/markdown [format]` or `/markdown [subcommand]`
- **Steps**:
  1. Validate addon is initialized
  2. Parse command arguments:
     - Check for `help` command
     - Check for subcommands (e.g., `filter:clear`, `test`)
     - Check for format names (e.g., `github`, `vscode`, `discord`, `quick`)
     - Default to current format if no args

### 2.2 Format Selection
- **Location**: `src/Commands.lua` - `ParseFormatCommand()`
- **Steps**:
  1. Parse format from command args
  2. Store format in `CM.currentFormat`
  3. Save format to SavedVariables
  4. Invalidate settings cache

---

## Phase 3: Markdown Generation

### 3.1 Generator Entry Point
- **Location**: `src/generators/Markdown.lua` - `GenerateMarkdown(format)`
- **Called from**: `src/Commands.lua` via `CM.generators.GenerateMarkdown(format)`
- **Steps**:
  1. Validate format (default to "github")
  2. Reset error tracking
  3. Verify collectors are loaded
  4. Collect all character data (see Phase 3.2)
  5. Generate markdown sections (see Phase 3.3)
  6. Apply chunking if needed (see Phase 3.4)
  7. Return markdown (string or chunks array)

### 3.2 Data Collection
- **Location**: `src/generators/Markdown.lua` - `GenerateMarkdown()` → `SafeCollect()`
- **Collectors Called** (in order):
  1. `CollectCharacterData` - Basic character info
  2. `CollectDLCAccess` - DLC ownership
  3. `CollectMundusData` - Mundus stone
  4. `CollectActiveBuffs` - Active buffs
  5. `CollectChampionPointData` - Champion points
  6. `CollectSkillBarData` - Active skill bar
  7. `CollectSkillMorphsData` - Skill morphs
  8. `CollectCombatStatsData` - Combat statistics
  9. `CollectEquipmentData` - Equipped items
  10. `CollectSkillProgressionData` - Skill lines
  11. `CollectCompanionData` - Companion info
  12. `CollectCurrencyData` - Currency amounts
  13. `CollectProgressionData` - Character progression
  14. `CollectRidingSkillsData` - Mount training
  15. `CollectInventoryData` - Inventory summary
  16. `CollectPvPData` - PvP statistics
  17. `CollectRoleData` - Role information
  18. `CollectLocationData` - Current location
  19. `CollectCollectiblesData` - Collectibles
  20. `CollectAchievementData` - Achievements
  21. `CollectQuestData` - Quest information
  22. `CollectCraftingData` - Crafting knowledge

### 3.3 Markdown Section Generation
- **Location**: `src/generators/Markdown.lua` - `GenerateMarkdown()` → section generators
- **Sections Generated** (in order):
  1. **Overview** - Character summary, stats, role
  2. **Champion Points** - CP allocation by discipline
  3. **Equipment** - Equipped items with traits/enchantments
  4. **Skills** - Active skill bar, skill lines, morphs
  5. **Companion** - Companion info (if applicable)
  6. **Progression** - Character progression, skill points
  7. **PvP** - PvP stats and rank
  8. **Location** - Current zone/area
  9. **Collectibles** - Collected items
  10. **Achievements** - Achievement progress
  11. **Quests** - Quest information
  12. **Crafting** - Crafting knowledge

### 3.4 Chunking (if needed)
- **Location**: `src/generators/Markdown.lua` - `GenerateMarkdown()` → `CM.utils.Chunking.SplitMarkdownIntoChunks()`
- **Trigger**: If markdown length > `EDITBOX_LIMIT` (21500 chars)
- **Steps**:
  1. Check if markdown exceeds limit
  2. If yes, call `SplitMarkdownIntoChunks(markdown)`
  3. Split at safe boundaries (end of sections, lines, links)
  4. Add padding to each chunk (550+ newlines for paste safety)
  5. Add chunk markers (HTML comments)
  6. Return array of chunk objects: `{ { content = "..." }, { content = "..." } }`
  7. If no chunking needed, return string directly

---

## Phase 4: Window Display

### 4.1 Show Window Entry Point
- **Location**: `src/ui/Window.lua` - `CharacterMarkdown_ShowWindow(markdown, format)`
- **Called from**: `src/Commands.lua` after markdown generation
- **Parameters**:
  - `markdown`: String or array of chunk objects
  - `format`: Format name (github, vscode, discord, quick)

### 4.2 Pre-Display Setup
- **Location**: `src/ui/Window.lua` - `CharacterMarkdown_ShowWindow()`
- **Steps**:
  1. Validate markdown input
  2. Clear previous state (`ClearChunks()`)
  3. Reset selection state
  4. Store format for regeneration
  5. Initialize window controls (if not already done)
  6. Re-enable all buttons (in case coming from import/export mode)
  7. Clear import mode flag

### 4.3 Markdown Processing
- **Location**: `src/ui/Window.lua` - `CharacterMarkdown_ShowWindow()`
- **Steps**:
  1. Check if markdown is string or chunks array
  2. **If chunks array**:
     - Store chunks in `markdownChunks`
     - Set `currentChunkIndex = 1`
     - Strip padding from chunks for storage
     - Concatenate chunks for full markdown storage
  3. **If string**:
     - Check if exceeds `EDITBOX_LIMIT`
     - If yes, chunk it using `SplitMarkdownIntoChunks()`
     - If no, wrap in chunks array format: `{ { content = markdown } }`
  4. Log chunk statistics (debug mode)

### 4.4 Display First Chunk
- **Location**: `src/ui/Window.lua` - `ShowChunk(chunkIndex)`
- **Steps**:
  1. Validate chunk index
  2. Get chunk content
  3. Validate chunk size (assertion check)
  4. Update EditBox with chunk content
  5. Reset selection state
  6. Update progress bar visual
  7. Update instructions label (chunk X/Y, size, status)
  8. Enable/disable navigation buttons
  9. Auto-select text (delayed 150ms)
  10. Return success

### 4.5 Window Activation
- **Location**: `src/ui/Window.lua` - `CharacterMarkdown_ShowWindow()`
- **Steps**:
  1. Show window (`windowControl:SetHidden(false)`)
  2. Bring to top (`SetTopmost(true)`)
  3. Activate window (`Activate()`)
  4. Request move to foreground (`RequestMoveToForeground()`)
  5. Push to front via scene manager (if available)

### 4.6 Final Setup (Delayed)
- **Location**: `src/ui/Window.lua` - `CharacterMarkdown_ShowWindow()` → `zo_callLater()`
- **Delay**: 200ms (ensures window is fully rendered)
- **Steps**:
  1. Enable keyboard on window (for global handler)
  2. Enable keyboard on EditBox (for Ctrl+C copy)
  3. Select all text in EditBox
  4. Update selection state (green button)
  5. Log completion message

---

## Phase 5: Keyboard Handling

### 5.1 Global Keyboard Handler
- **Location**: `src/ui/Window.lua` - Registered in `OnAddOnLoaded()`
- **Event**: `EVENT_KEY_DOWN`
- **Active**: Always when window is visible
- **Handles**:
  - ESC/X - Close window
  - G - Regenerate markdown
  - S - Open settings
  - R - Reload UI
  - Left/Comma - Previous chunk
  - Right/Period - Next chunk
  - PageUp - Previous chunk
  - PageDown - Next chunk
  - Ctrl+A - Select all
  - Ctrl+C - Copy (gives EditBox focus)
  - Space/Enter - Copy to clipboard

### 5.2 EditBox Keyboard Handler
- **Location**: `src/ui/Window.lua` - `InitializeWindowControls()` → `SetHandler("OnKeyDown")`
- **Purpose**: Prevent text input in normal mode
- **Handles**:
  - Allows Ctrl+A/Ctrl+C to pass through
  - Allows cursor movement keys
  - Consumes all other character keys

---

## Phase 6: Chunk Navigation

### 6.1 Next Chunk
- **Location**: `src/ui/Window.lua` - `CharacterMarkdown_NextChunk()`
- **Trigger**: Next button click, Right arrow, Period, PageDown
- **Steps**:
  1. Check if multiple chunks exist
  2. Calculate next index (wrap to 1 if at end)
  3. Call `ShowChunk(nextIndex)`

### 6.2 Previous Chunk
- **Location**: `src/ui/Window.lua` - `CharacterMarkdown_PreviousChunk()`
- **Trigger**: Previous button click, Left arrow, Comma, PageUp
- **Steps**:
  1. Check if multiple chunks exist
  2. Calculate previous index (wrap to last if at start)
  3. Call `ShowChunk(prevIndex)`

---

## Phase 7: Copy Operations

### 7.1 Copy to Clipboard
- **Location**: `src/ui/Window.lua` - `CharacterMarkdown_CopyToClipboard()`
- **Trigger**: Copy button click, Space, Enter
- **Steps**:
  1. Check if markdown is chunked
  2. **If chunked**:
     - Get current chunk
     - Strip padding from chunk
     - Set EditBox text to chunk content
     - Select all text
  3. **If not chunked**:
     - Set EditBox text to full markdown
     - Select all text
  4. Update selection state (green button)
  5. User presses Ctrl+C to copy

---

## Key Data Structures

### Chunks Array Format
```lua
markdownChunks = {
    { content = "chunk 1 content with padding..." },
    { content = "chunk 2 content with padding..." },
    ...
}
```

### Window State Variables
- `windowControl` - Main window control reference
- `editBoxControl` - EditBox control reference
- `markdownChunks` - Array of chunk objects
- `currentChunkIndex` - Currently displayed chunk (1-based)
- `currentMarkdown` - Full markdown (concatenated chunks, padding stripped)
- `isTextSelected` - Selection state for button color

---

## Error Handling

### Collection Errors
- Each collector wrapped in `SafeCollect()` with error handling
- Errors aggregated and logged
- Generation continues even if some collectors fail

### Validation
- Chunk size validation (assertion checks)
- EditBox limit validation
- Format validation

---

## Performance Considerations

### Delayed Operations
- Window initialization: 100ms delay
- Text selection: 150ms delay
- Final setup: 200ms delay
- Ensures UI is fully rendered before operations

### Memory Management
- Chunks cleared when window closes
- Large temporary data cleared after use
- Selection state reset on window close

---

## File Dependencies

### Core Files
- `src/Commands.lua` - Command parsing and entry point
- `src/generators/Markdown.lua` - Markdown generation
- `src/ui/Window.lua` - Window display and management
- `src/utils/Chunking.lua` - Chunking algorithm
- `CharacterMarkdown.xml` - UI definition

### Collector Files
- `src/collectors/*.lua` - Data collection modules

### Generator Files
- `src/generators/sections/*.lua` - Markdown section generators

---

## Summary Flow Diagram

```
User Command (/markdown)
    ↓
Command Handler (Commands.lua)
    ↓
Generate Markdown (Markdown.lua)
    ├─→ Collect Data (collectors/*.lua)
    ├─→ Generate Sections (generators/sections/*.lua)
    └─→ Apply Chunking (if needed)
    ↓
Show Window (Window.lua)
    ├─→ Initialize Controls
    ├─→ Process Markdown/Chunks
    ├─→ Display First Chunk
    ├─→ Activate Window
    └─→ Setup Keyboard Handlers
    ↓
Window Displayed
    ├─→ Global Keyboard Handler Active
    ├─→ EditBox Handler Active
    └─→ Ready for User Interaction
```

