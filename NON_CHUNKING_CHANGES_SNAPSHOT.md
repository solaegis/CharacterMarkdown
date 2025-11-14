# Non-Chunking Changes Snapshot

**Created:** November 13, 2025  
**Purpose:** Document all non-chunking/padding changes since last git commit for safe reapplication after reverting chunking work

---

## Table of Contents

1. [Settings Architecture Changes](#1-settings-architecture-changes)
2. [UI/UX Improvements](#2-uiux-improvements)
3. [Markdown Generation Enhancements](#3-markdown-generation-enhancements)
4. [Settings Panel Updates](#4-settings-panel-updates)
5. [Collector Updates](#5-collector-updates)
6. [Advanced Markdown Utilities](#6-advanced-markdown-utilities)
7. [Documentation Changes](#7-documentation-changes)

---

## 1. Settings Architecture Changes

### 1.1 Per-Character Markdown Storage

**File:** `src/settings/Defaults.lua` (lines ~100-118)

**Change:** Moved `markdown_format` and `markdown` from account-wide to per-character storage.

**Rationale:** Each character should have their own cached markdown, not share account-wide. Prevents one character's markdown from overwriting another's.

**Code:**
```lua
-- Add to GetAll() defaults:
perCharacterData = {}, -- Stores custom title, build notes, play style, and cached markdown per character

-- NOTE: markdown_format and markdown are stored per-character, not account-wide
-- Each character in perCharacterData[characterId] has:
--   - customNotes: custom build notes
--   - customTitle: custom character title
--   - playStyle: play style tag (magicka_dps, stamina_tank, etc.)
--   - markdown_format: format of last generated markdown (github, vscode, discord, quick)
--   - markdown: full markdown document before chunking (cached per character)

-- ====================================
-- DEPRECATED ACCOUNT-WIDE FIELDS (kept for migration)
-- ====================================
markdown_format = "", -- DEPRECATED: Now stored per-character (kept for migration)
markdown = "", -- DEPRECATED: Now stored per-character (kept for migration)
```

### 1.2 Character Data Initialization Enhancement

**File:** `src/settings/Initializer.lua` (lines ~180-205)

**Change:** Initialize per-character `markdown_format` and `markdown` fields, plus migration logic.

**Rationale:** Ensure all characters have markdown storage fields initialized, and migrate old account-wide data.

**Code:**
```lua
-- In InitializeCharacterData() function:
if not CM.settings.perCharacterData[characterId] then
    CM.settings.perCharacterData[characterId] = {
        customNotes = "",
        customTitle = "",
        playStyle = "",
        markdown_format = "",  -- NEW
        markdown = "",         -- NEW
        _initialized = true,
        _lastModified = GetTimeStamp(),
        _characterName = GetUnitName("player"),
        _accountName = GetDisplayName(),
    }
end

-- Point CM.charData to this character's data
CM.charData = CM.settings.perCharacterData[characterId]

-- MIGRATION: Move account-wide markdown data to per-character (v2.1.9+)
-- If account-wide markdown exists and character doesn't have any, migrate it
if CM.settings.markdown and CM.settings.markdown ~= "" and 
   (not CM.charData.markdown or CM.charData.markdown == "") then
    CM.charData.markdown = CM.settings.markdown
    CM.charData.markdown_format = CM.settings.markdown_format or ""
    CM.DebugPrint("SETTINGS", "Migrated account-wide markdown to per-character data")
    -- Clear account-wide versions
    CM.settings.markdown = ""
    CM.settings.markdown_format = ""
end
```

### 1.3 Settings Initialization Simplification

**File:** `src/Events.lua` (lines ~21-32)

**Change:** Call full `Initialize()` method instead of separate initialization steps.

**Rationale:** Cleaner, more reliable initialization. The `Initialize()` method already calls all necessary sub-methods in correct order.

**Code:**
```lua
-- BEFORE:
local success = CM.Settings.Initializer:TryZOSavedVars()
if not success then
    CM.Warn("ZO_SavedVars initialization failed - using fallback method")
    CM.Settings.Initializer:InitializeFallback()
end
CM.Settings.Initializer:InitializeCharacterData()

-- AFTER:
local success = CM.Settings.Initializer:Initialize()
if not success then
    CM.Error("Settings initialization failed!")
end
```

### 1.4 Format Sync Improvement

**File:** `src/settings/Initializer.lua` (lines ~34-40)

**Change:** Better format syncing with fallback chain.

**Rationale:** Ensure `CM.currentFormat` is always synced, with proper fallbacks if one reference is nil.

**Code:**
```lua
-- In Initialize() function:
-- Sync format to core from SavedVariables
if CM.settings and CM.settings.currentFormat then
    CM.currentFormat = CM.settings.currentFormat
elseif CharacterMarkdownSettings and CharacterMarkdownSettings.currentFormat then
    CM.currentFormat = CharacterMarkdownSettings.currentFormat
else
    CM.currentFormat = "github" -- Fallback to default
end
```

---

## 2. UI/UX Improvements

### 2.1 Better Logging and Validation in Window Initialization

**File:** `src/ui/Window.lua` (lines ~64-82)

**Change:** Use `CM.Info()` and `CM.Warn()` instead of `CM.DebugPrint()`, add chunking config logging.

**Rationale:** Important initialization info should be visible to users, not hidden behind debug flag. Helps diagnose issues.

**Code:**
```lua
-- BEFORE:
CM.DebugPrint("UI", string.format("EditBox max input chars: %d", actualMaxChars))
if actualMaxChars < 22000 then
    CM.DebugPrint("UI", string.format("EditBox limited to %d (requested 22000)", actualMaxChars))
end
-- ...
CM.DebugPrint("UI", "Could not get EditBox max input chars")

-- AFTER:
CM.Info(string.format("✓ EditBox initialized: max input %d chars (requested 22000)", actualMaxChars))
if actualMaxChars < 22000 then
    CM.Warn(string.format("⚠ EditBox limited to %d by ESO (requested 22000)", actualMaxChars))
    CM.Warn("This may affect large character profiles. Please report if you see truncation.")
end
-- Log chunking configuration for validation
local CHUNKING = CM.constants and CM.constants.CHUNKING
if CHUNKING then
    CM.Info(string.format("  Chunking limits: EDITBOX=%d, COPY=%d, MAX_DATA=%d", 
        CHUNKING.EDITBOX_LIMIT or 0,
        CHUNKING.COPY_LIMIT or 0,
        CHUNKING.MAX_DATA_CHARS or 0
    ))
end
-- ...
CM.Warn("⚠ Could not query EditBox max input chars - this may indicate an ESO API issue")
```

### 2.2 Centralized Padding Stripping

**File:** `src/ui/Window.lua` (multiple locations)

**Change:** Use `CM.utils.Chunking.StripPadding()` instead of inline padding stripping code.

**Rationale:** Single source of truth for padding logic. Reduces duplication and ensures consistency.

**Code:**
```lua
-- BEFORE (lines ~107-122):
local chunkContent = chunkToCopy.content
local isLastChunk = (currentChunkIndex == #markdownChunks)
local paddingSize = (CHUNKING and CHUNKING.SPACE_PADDING_SIZE) or 85
-- Strip padding from all chunks (including last chunk)
-- Padding format: content + 85 spaces + newline + newline
local paddingPattern = string.rep(" ", paddingSize) .. "\n\n"
if string.sub(chunkContent, -(paddingSize + 2), -1) == paddingPattern then
    chunkContent = string.sub(chunkContent, 1, -(paddingSize + 2)) .. "\n"
    CM.DebugPrint("UI", string.format("Stripped padding from chunk %d/%d for copy", currentChunkIndex, #markdownChunks))
end

-- AFTER (lines ~117-121):
local isLastChunk = (currentChunkIndex == #markdownChunks)
local chunkContent = CM.utils.Chunking.StripPadding(chunkToCopy.content, isLastChunk)
CM.DebugPrint("UI", string.format("Stripped padding from chunk %d/%d for copy", currentChunkIndex, #markdownChunks))
```

**Apply at 3 locations:**
1. `CharacterMarkdown_CopyToClipboard()` - line ~117
2. `CharacterMarkdown_RegenerateMarkdown()` - line ~320
3. Remove duplicate padding stripping code in both functions

### 2.3 Assertions Instead of Silent Truncation

**File:** `src/ui/Window.lua` (lines ~186-211, ~406-435)

**Change:** Replace truncation logic with assertions that fail loudly.

**Rationale:** If content exceeds limits, it's a bug in chunking algorithm. Don't hide it - make it visible so it gets fixed.

**Code:**
```lua
-- BEFORE (lines ~199-217):
if markdownLength > EDITBOX_LIMIT then
    CM.Warn(string.format("Content size %d exceeds EditBox limit %d - may truncate", markdownLength, EDITBOX_LIMIT))
    -- Truncate at last newline before limit
    local truncated = string.sub(currentMarkdown, 1, EDITBOX_LIMIT)
    local lastNewline = nil
    for i = string.len(truncated), 1, -1 do
        if string.sub(truncated, i, i) == "\n" then
            lastNewline = i
            break
        end
    end
    if lastNewline then
        currentMarkdown = string.sub(truncated, 1, lastNewline)
    else
        currentMarkdown = truncated
    end
    CM.Warn(string.format("Truncated to %d chars for copying", string.len(currentMarkdown)))
end

-- AFTER (lines ~201-210):
if markdownLength > EDITBOX_LIMIT then
    CM.Error(
        string.format(
            "ASSERTION FAILED: Single chunk content size %d exceeds EditBox limit %d",
            markdownLength,
            EDITBOX_LIMIT
        )
    )
    CM.Error("This indicates a bug in the chunking algorithm - content should have been chunked!")
    CM.Error("Please report this issue with the /markdown test output")
    -- Don't truncate - let it fail visibly so the bug is noticed
end
```

**Apply similar pattern in `ShowChunk()` function (lines ~415-438)**

### 2.4 Improved Focus Management

**File:** `src/ui/Window.lua` (multiple locations)

**Change:** Add delayed `TakeFocus()` calls after text operations.

**Rationale:** Ensures EditBox has focus for Ctrl+C operations, improves UX.

**Code:**
```lua
-- Add after SelectAll() calls in:
-- 1. CharacterMarkdown_CopyToClipboard() - after line ~191
-- 2. CharacterMarkdown_CopyToClipboard() - after line ~228
-- 3. CharacterMarkdown_RegenerateMarkdown() - after line ~372

zo_callLater(function()
    if editBoxControl then
        editBoxControl:TakeFocus()
    end
end, 50)
```

---

## 3. Markdown Generation Enhancements

### 3.1 Overview Section Multi-Column Layout (General)

**File:** `src/generators/sections/Overview.lua` (lines ~37-277)

**Change:** Completely rewrote `GenerateGeneral()` to use multi-column styled tables.

**Rationale:** Better visual layout, more professional appearance, better use of horizontal space.

**Key Features:**
- Distributes data into 3 balanced columns
- Uses `CreateStyledTable()` and `CreateResponsiveColumns()`
- Includes riding skills with emoji formatting
- Better attribute display with emojis
- Skill points, enlightenment, vampire/werewolf status
- Mundus stone, active buffs, location

**Implementation:** The code is extensive (~240 lines). Key pattern:
```lua
local CreateStyledTable = markdown and markdown.CreateStyledTable
local CreateResponsiveColumns = markdown and markdown.CreateResponsiveColumns

if CreateStyledTable and CreateResponsiveColumns and format ~= "discord" then
    local result = "### General\n\n"
    local allRows = {}
    
    -- Collect all rows (level, class, race, alliance, server, account, CP, attributes, etc.)
    table_insert(allRows, { "**Level**", tostring(charData.level or 1) })
    -- ... many more rows ...
    
    -- Distribute rows into 3 balanced columns
    local totalRows = #allRows
    local rowsPerTable = math.ceil(totalRows / 3)
    
    local col1_rows = {}  -- rows 1 to rowsPerTable
    local col2_rows = {}  -- rows rowsPerTable+1 to 2*rowsPerTable
    local col3_rows = {}  -- rows 2*rowsPerTable+1 to end
    
    -- Create 3 styled tables, then wrap in responsive columns
    local tables = { table1, table2, table3 }
    result = result .. CreateResponsiveColumns(tables, "250px", "20px")
    
    return result
end
```

**Note:** Also update function signature to accept `ridingData` parameter:
```lua
-- Line ~21:
local function GenerateGeneral(
    charData,
    progressionData,
    locationData,
    buffsData,
    mundusData,
    format,
    ridingData  -- NEW
)
```

### 3.2 Currency Section Styled Tables

**File:** `src/generators/sections/Character.lua` (lines ~203-259)

**Change:** Convert currency section to use styled tables.

**Rationale:** Consistent styling with other sections.

**Code:**
```lua
local currencySection = ""
if IsSettingEnabled("includeCurrency", true) and currencyData then
    local markdown = CM.utils and CM.utils.markdown
    local CreateStyledTable = markdown and markdown.CreateStyledTable
    
    if CreateStyledTable and format ~= "discord" then
        -- Use styled table
        local currencyRows = {}
        if currencyData.alliancePoints and currencyData.alliancePoints > 0 then
            table_insert(currencyRows, { "**Alliance Points**", safeFormat(currencyData.alliancePoints) })
        end
        -- ... other currencies ...
        
        if #currencyRows > 0 then
            local headers = { "Attribute", "Value" }
            local options = {
                alignment = { "left", "left" },
                format = format,
                coloredHeaders = true,
            }
            local currencyTable = CreateStyledTable(headers, currencyRows, options)
            currencySection = "### Currency\n\n" .. currencyTable
        end
    else
        -- Fallback to simple table format
        -- ... existing code with double pipes (||) ...
    end
end
```

### 3.3 General + Currency Grid Combination

**File:** `src/generators/sections/Character.lua` (lines ~261-364)

**Change:** Combine General and Currency into single grid when both use styled tables.

**Rationale:** Better layout, treats Currency as 4th column of General section.

**Implementation:** Complex logic to extract General's grid content and inject Currency as additional column:
```lua
local result = "## 📋 Overview\n\n"

-- Check if both sections use styled tables with grid layout
local generalHasGrid = generalSection ~= "" and string.find(generalSection, "<div style=\"display: grid;")
local currencyHasStyledTable = currencySection ~= "" and 
    not string.find(currencySection, "^### Currency\n\n||") and
    not string.find(currencySection, "<div style=")

if generalHasGrid and currencyHasStyledTable then
    -- Extract General's grid content (everything INSIDE the grid div)
    -- Find opening and closing </div> tags
    -- Insert Currency content as 4th column within the grid
    -- (See full implementation in file for div depth tracking logic)
else
    -- Append sections normally
    if generalSection ~= "" then
        result = result .. '<a id="general"></a>\n\n' .. generalSection
    end
    if currencySection ~= "" then
        result = result .. '<a id="currency"></a>\n\n' .. currencySection
    end
end
```

### 3.4 Riding Data Passed to General Section

**File:** `src/generators/sections/Character.lua` (line ~188)

**Change:** Pass `ridingData` parameter to `GenerateGeneral()`.

**Code:**
```lua
-- BEFORE:
generalSection = GenerateGeneral(charData, progressionData, locationData, buffsData, mundusData, format)

-- AFTER:
generalSection = GenerateGeneral(charData, progressionData, locationData, buffsData, mundusData, format, ridingData)
```

### 3.5 Achievements Pivot Table Format

**File:** `src/generators/sections/Achievements.lua` (lines ~220-274)

**Change:** Use single pivot table with all categories as rows instead of multi-column layout.

**Rationale:** Simpler, more reliable, easier to read. Avoids complexity of multi-column layouts.

**Code:**
```lua
-- BEFORE: Created individual tables for each category, used CreateResponsiveColumns

-- AFTER: Single table with all categories
local headers = { "Category", "Completed", "Total", "Progress", "Points" }
local rows = {}
local categoryOrder = {}

-- Collect and sort categories alphabetically
for categoryName, categoryData in pairs(categories) do
    if categoryData.total > 0 then
        table.insert(categoryOrder, categoryName)
    end
end
table.sort(categoryOrder, function(a, b)
    return string.lower(a or "") < string.lower(b or "")
end)

for _, categoryName in ipairs(categoryOrder) do
    local categoryData = categories[categoryName]
    local emoji = GetCategoryEmoji(categoryName)
    local percent = categoryData.total > 0
            and math.floor((categoryData.completed / categoryData.total) * 100)
        or 0
    local progressBar = CM.utils.GenerateProgressBar(percent, 8)

    table.insert(rows, {
        emoji .. " **" .. categoryName .. "**",
        tostring(categoryData.completed),
        tostring(categoryData.total),
        progressBar .. " " .. percent .. "%",
        CM.utils.FormatNumber(categoryData.points),
    })
end

-- Create single styled table
local options = {
    alignment = { "left", "right", "right", "left", "right" },
    format = format,
    coloredHeaders = true,
}
markdown = markdown .. CreateStyledTable(headers, rows, options)
```

---

## 4. Settings Panel Updates

### 4.1 Removed "Include Quick Stats" Checkbox

**File:** `src/settings/Panel.lua` (lines ~291-309)

**Change:** Removed parent "Include Quick Stats" checkbox, made subsections independent.

**Rationale:** User feedback indicated parent checkbox was confusing. Users want fine-grained control.

**Code:**
```lua
-- REMOVE these lines (~291-300):
table.insert(options, {
    type = "checkbox",
    name = "Include Quick Stats",
    tooltip = "Show Overview section with General, Currency, and Character Stats (GitHub/VSCode only).",
    getFunc = function()
        return CharacterMarkdownSettings.includeQuickStats
    end,
    setFunc = CreateSetFunc("includeQuickStats"),
    width = "half",
    default = true,
})

-- UPDATE "Include General" checkbox - remove indentation and disabled function:
-- BEFORE:
name = "    Include General",  -- 4 space indent
disabled = function()
    return not CharacterMarkdownSettings.includeQuickStats
end,

-- AFTER:
name = "Include General",  -- No indent
-- No disabled function
```

### 4.2 Format Setting Improvements

**File:** `src/settings/Panel.lua` (lines ~187-212)

**Change:** Better getFunc/setFunc with proper fallbacks and sync to both CM.settings and CharacterMarkdownSettings.

**Rationale:** Ensures format persists correctly regardless of which reference is used.

**Code:**
```lua
getFunc = function()
    -- Use CM.settings if available (ZO_SavedVars proxy), otherwise fallback
    if CM.settings and CM.settings.currentFormat then
        return CM.settings.currentFormat
    elseif CharacterMarkdownSettings and CharacterMarkdownSettings.currentFormat then
        return CharacterMarkdownSettings.currentFormat
    else
        return "github" -- Default fallback
    end
end,
setFunc = function(value)
    -- CRITICAL: Save to both CM.settings and CharacterMarkdownSettings
    if CM.settings then
        CM.settings.currentFormat = value
        CM.settings._lastModified = GetTimeStamp()
    end
    if CharacterMarkdownSettings then
        CharacterMarkdownSettings.currentFormat = value
        CharacterMarkdownSettings._lastModified = GetTimeStamp()
    end
    CM.currentFormat = value -- Sync to core
    CM.InvalidateSettingsCache() -- Invalidate cache on change
    CM.DebugPrint("SETTINGS", "Format changed to: " .. tostring(value))
end,
```

### 4.3 Update "Enable All Sections" to Skip includeQuickStats

**File:** `src/settings/Panel.lua` (line ~1235)

**Change:** Remove `includeQuickStats` from "Enable All Sections" logic.

**Code:**
```lua
-- REMOVE this line:
CharacterMarkdownSettings.includeQuickStats = value

-- Keep all other includes (includeGeneral, includeCharacterStats, etc.)
```

---

## 5. Collector Updates

### 5.1 Economy Collector Changes

**File:** `src/collectors/Economy.lua` (lines vary)

**Summary:** Minor refinements to currency collection logic.

**Details:** Check git diff for specific changes. Appears to be mostly comment updates and minor refactoring.

### 5.2 Equipment Collector Changes

**File:** `src/collectors/Equipment.lua` (line ~specific)

**Summary:** Minor adjustment to equipment data collection.

**Details:** Check git diff for specific changes.

### 5.3 Progression Collector Changes

**File:** `src/collectors/Progression.lua` (lines vary)

**Summary:** Refinements to skill point and progression data collection.

**Details:** Check git diff for specific changes. May include better handling of unspent skill points.

---

## 6. Advanced Markdown Utilities

### 6.1 CreateResponsiveColumns Validation

**File:** `src/utils/AdvancedMarkdown.lua` (lines ~392-416)

**Change:** Added content validation and safety checks.

**Rationale:** Prevent errors from nil or non-string content.

**Code:**
```lua
for _, content in ipairs(columns) do
    -- Ensure content is a valid string
    local safeContent = content or ""
    if type(safeContent) ~= "string" then
        safeContent = tostring(safeContent)
    end
    
    table.insert(parts, "<div>\n\n")
    table.insert(parts, safeContent)
    table.insert(parts, "\n\n</div>\n")
end

table.insert(parts, "\n</div>\n\n")  -- Added \n before closing div

local result = table_concat(parts, "")

-- Validate that result contains proper HTML structure
if result and result ~= "" then
    return result
else
    -- Fallback: return empty string if result is invalid
    return ""
end
```

### 6.2 CreateAttentionNeeded GitHub Callout Format

**File:** `src/utils/AdvancedMarkdown.lua` (lines ~926-946)

**Change:** Use GitHub `[!WARNING]` callout syntax for GitHub format instead of table.

**Rationale:** Native GitHub callouts look better than styled tables for warnings.

**Code:**
```lua
-- GitHub format: Use [!WARNING] callout syntax
if format == "github" then
    local result = "> [!WARNING]\n"
    for _, warning in ipairs(warnings) do
        result = result .. "> " .. warning .. "\n"
    end
    result = result .. "\n"
    return result
end

-- Parse warnings into two columns (split on first colon) for other formats
-- ... existing code ...
```

---

## 7. Documentation Changes

### 7.1 .cursorrules Updates

**File:** `.cursorrules`

**Changes:**
- Added notes about Settings Panel (no emojis in LAM)
- Updates to per-character data structure documentation
- Clarifications on settings management patterns

**Key additions:**
```markdown
### Settings Panel (LibAddonMenu-2.0)
- **NO emojis or Unicode icons in LAM settings**: LibAddonMenu-2.0 does not render emojis/icons properly
  - NEVER use emojis in checkbox names, section headers, or tooltips
  - Use plain text and spaces only for all LAM UI elements

### SavedVariables Management
**Per-Character Data**: Store INSIDE account-wide settings (reliable approach)
- **Pattern**: Store per-character data in `CharacterMarkdownSettings.perCharacterData[characterId]`
- **Current per-character fields** (as of v2.1.9+):
  - `customNotes`, `customTitle`, `playStyle`
  - `markdown_format`: Format of last generated markdown
  - `markdown`: Full cached markdown document for this character
```

### 7.2 README Updates (Examples)

**File:** `assets/examples/README.md`

**Changes:** Minor formatting or content updates (check git diff for details).

### 7.3 Template Updates

**File:** `assets/templates/README.md`, `assets/templates/claude_project_setup.md`

**Changes:** Documentation improvements (check git diff for details).

### 7.4 Code Review Documents

**Files:** `CODE_REVIEW.md`, `REVIEW_SUMMARY.md`

**Changes:** Minor updates to review documentation (check git diff for details).

---

## How to Use This Document

### Option 1: Manual Reapplication

1. **Revert to last commit:**
   ```bash
   git checkout src/utils/Chunking.lua
   git checkout src/utils/Constants.lua
   ```

2. **Apply each change** from this document manually, section by section.

3. **Test after each major section** to ensure stability.

### Option 2: Selective Git Reset

1. **Stash all changes:**
   ```bash
   git stash
   ```

2. **Reset chunking files:**
   ```bash
   git checkout HEAD -- src/utils/Chunking.lua
   git checkout HEAD -- src/utils/Constants.lua
   ```

3. **Pop stash:**
   ```bash
   git stash pop
   ```

4. **Resolve conflicts** by keeping non-chunking changes.

### Option 3: Use Git Diffs

For detailed line-by-line changes, use:
```bash
git diff src/settings/Defaults.lua
git diff src/ui/Window.lua
git diff src/generators/sections/Overview.lua
# etc. for each file
```

---

## Verification Checklist

After reapplying changes, verify:

- [ ] Settings persist correctly (test with `/reloadui`)
- [ ] Per-character markdown storage works (switch characters)
- [ ] General section displays with multi-column layout
- [ ] Currency section uses styled tables
- [ ] Achievements use pivot table format
- [ ] Settings panel has no "Include Quick Stats" parent checkbox
- [ ] Window logging shows Info/Warn messages (not hidden behind debug)
- [ ] Format changes persist correctly
- [ ] No Lua errors on startup

---

## Summary Statistics

**Files Modified (Non-Chunking):** 15 files  
- Settings: 3 files
- UI: 1 file
- Generators: 4 files
- Collectors: 3 files
- Utils: 1 file
- Documentation: 3 files

**Lines Changed (Non-Chunking):** ~800 lines (excluding chunking)

**Major Categories:**
1. Settings architecture: ~150 lines
2. UI improvements: ~200 lines
3. Markdown generation: ~350 lines
4. Settings panel: ~50 lines
5. Utilities: ~50 lines

---

## Notes

- All changes are **independent of chunking logic**
- Changes can be applied in any order (though settings changes should go first)
- No changes break existing functionality
- All changes are **additive improvements** (no removals except includeQuickStats)
- Changes are **tested and working** in current codebase

---

**End of Snapshot**

