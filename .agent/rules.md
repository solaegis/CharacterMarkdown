# CharacterMarkdown - Project Rules

## ESO Lua Version Compatibility

**CRITICAL: ESO uses Lua 5.1, which has important limitations:**

- **NO `goto` statements**: The `goto` statement was introduced in Lua 5.2. ESO uses Lua 5.1, so `goto` and labels (`::label::`) will cause syntax errors.
  - **Solution**: Use `if-else` blocks or `continue`-like patterns instead of `goto continue`
  - **Example**: Instead of `goto continue`, wrap the processing logic in an `else` block or use early returns
  - **Error message**: If you see `= expected near 'continue'`, it means `goto` was used incorrectly

- **Other Lua 5.1 limitations to be aware of**:
  - No bitwise operators (use bit library if needed)
  - No `__pairs` and `__ipairs` metamethods
  - Some string functions may have different behavior

**Always test code in ESO's Lua 5.1 environment. Never use `goto` statements.**

---

## Protected Files - Require Developer Approval

**CRITICAL: The following files contain complex, working logic that must not be modified without explicit developer approval:**

- **src/ui/Window.lua** - Chunking, keyboard handling, copy/paste, focus management
  - Contains delicate timing with zo_callLater() that affects EditBox behavior
  - EditBox configuration pattern is non-intuitive but necessary
  - Keyboard event handling has specific event consumption patterns
  - Memory management and state tracking must remain intact

**Before modifying protected files:**
1. Ask the developer: "Can I modify [filename]? I want to [describe change]"
2. Wait for explicit approval before making ANY changes
3. If approved, follow all documented patterns in the relevant section
4. After changes, test thoroughly and have developer verify functionality

**Why this rule exists:**
- These files were difficult to implement correctly
- They solve non-obvious problems with ESO's UI system
- Small changes can break subtle functionality (timing, focus, events)
- Regression would waste significant development time

---

## Project Structure & Patterns

### Namespace Convention
- All code must be in the `CharacterMarkdown` namespace (aliased as `CM`)
- Pattern: `local CM = CharacterMarkdown` at the top of each file
- Functions: `CM.moduleName.FunctionName()` or `CM.utils.FunctionName()`
- Never pollute global namespace

### Error Handling
- **Always use `CM.SafeCall()` for ESO API calls** (not `pcall` directly):
  ```lua
  -- CM.SafeCall automatically handles errors and returns nil on failure
  local result = CM.SafeCall(ESO_API_Function, args) or defaultValue
  ```
- **EXCEPTION: Use `pcall` directly when you need multiple return values**:
  ```lua
  -- CM.SafeCall only returns the first return value
  -- When a function returns multiple values, use pcall directly
  local success, value1, value2, value3 = pcall(GetMultipleValuesFunction, args)
  if not success then
      CM.DebugPrint("ERROR", "Function failed: " .. tostring(value1))
      return defaultValue1, defaultValue2, defaultValue3
  end
  -- Use the values: value1, value2, value3
  ```
- **When to use `pcall` vs `CM.SafeCall`**:
  - **Use `CM.SafeCall()`**: Single return value, ESO API calls, simple error handling
  - **Use `pcall()` directly**: Multiple return values needed, custom error handling required, non-ESO API functions that return multiple values
- **Note**: `CM.SafeCall` only returns the first return value. For multiple returns, use `pcall` directly.

### Debug & Logging
- Use the project's debug system, not direct `d()` calls:
  - `CM.DebugPrint(category, message)` - Silent unless LibDebugLogger enabled
  - `CM.Info(message)` - Always logged
  - `CM.Warn(message)` - Warning message
  - `CM.Error(message)` - Error shown in chat
- Never use `d()` directly - use `CM.Info()` or `CM.Error()` instead

### Performance Best Practices
- Cache global function lookups at module level:
  ```lua
  local string_format = string.format
  local table_insert = table.insert
  local string_gsub = string.gsub
  ```
- Use `table.concat()` for string building instead of concatenation
- Throttle event handlers when appropriate
- Follow memory management best practices in `docs/MEMORY_MANAGEMENT.md`:
  - Clear large temporary data with `variable = nil` before returning
  - Unregister one-time event handlers immediately
  - Use `collectgarbage("step", 1000)` after large operations
  - Never cache collector data at module scope

### Module Organization
- **Collectors** (`src/collectors/`): Data gathering only, no formatting
- **Generators** (`src/generators/sections/`): Markdown creation only
- **Links** (`src/links/`): UESP URL generation only
- **Utils** (`src/utils/`): Reusable helper functions
- **Settings** (`src/settings/`): Use `CM.GetSettings()` to access, defaults in `CM.Settings.Defaults:GetAll()`
- **UI** (`src/ui/`): Window and display logic only

### Command Patterns
- **Subcommand Pattern**: Use colon notation `object:action_or_subobject` where the object comes first, then an action or subobject
  - Pattern: `command object:action` or `command object:subobject`
  - The main noun/object comes before the colon, the action/verb or subobject comes after
  - Examples:
    - `filter:clear` - perform **clear** action on **filter** object
    - `test:import-export` - test the **import-export** subsystem
    - `profile:save` - perform **save** action on **profile** object
  - **Action**: A verb that operates on the object (clear, save, delete, apply)
  - **Subobject**: A compound noun that further specifies the object (import-export, validation-report)
  - Always validate subcommands and show helpful error messages for unknown subcommands
- **Main Commands**:
  - `/markdown [format|test|unittest|filter:clear|help|save]`
  - `/cmdsettings [export|import|test:import-export]`
- **Format Commands**: Standard markdown generation is the default.
- Always validate arguments and show helpful error messages

### Settings Management
- Access settings via `CM.GetSettings()` (handles defaults automatically)
- Defaults defined in `src/settings/Defaults.lua`
- Export/Import: Use `CM.utils.TableToYAML()` and `CM.utils.YAMLToTable()`
- Settings validation: Check against defaults, validate types

### SavedVariables Management

**Account-Wide Settings**: Use `ZO_SavedVars:NewAccountWide()` for all account-wide settings
- Stored in `CharacterMarkdownSettings`
- Initialized in `EVENT_ADD_ON_LOADED` handler
- Verify reference: `CM.settings` should equal `CharacterMarkdownSettings`

**Per-Character Data**: Store INSIDE account-wide settings (reliable approach)
- **Pattern**: Store per-character data in `CharacterMarkdownSettings.perCharacterData[characterId]`
- **Why**: Account-wide SavedVariables are more reliable than per-character SavedVariables
- **Implementation**:
  ```lua
  -- In InitializeCharacterData()
  local characterId = tostring(GetCurrentCharacterId())
  
  if not CM.settings.perCharacterData then
      CM.settings.perCharacterData = {}
  end
  
  if not CM.settings.perCharacterData[characterId] then
      CM.settings.perCharacterData[characterId] = {
          customNotes = "",
          customTitle = "",
          playStyle = "",
          _initialized = true,
          _lastModified = GetTimeStamp(),
      }
  end
  
  -- Point CM.charData to this character's data
  CM.charData = CM.settings.perCharacterData[characterId]
  ```

- **When adding new per-character fields**:
  1. Add to the initialization structure in `InitializeCharacterData()`
  2. **DO NOT add per-character fields to `src/settings/Defaults.lua`** - per-character data is NOT a setting with a default
  3. No migration needed - changes are automatic when accessing `CM.charData`

- **CRITICAL: Per-Character Text Fields Must NEVER Be Reset**:
  - Only the text fields (customNotes, customTitle, playStyle) must be preserved - NOT all of perCharacterData
  - These are user-entered data that must NEVER be reset to defaults
  - When implementing "reset to defaults" functionality:
    - **ALWAYS preserve only text fields** (customNotes, customTitle, playStyle) for the current character before applying defaults
    - **Get current character ID**: `local characterId = tostring(GetCurrentCharacterId())`
    - **Preserve only**: `customNotes`, `customTitle`, `playStyle` from `CM.settings.perCharacterData[characterId]`
    - **ALWAYS exclude `perCharacterData` from the defaults loop** (check `if key ~= "perCharacterData"`)
    - **ALWAYS restore only the text fields** for the current character after applying defaults
    - **NEVER include `perCharacterData` in `src/settings/Defaults.lua`** - it has no default value
  - **LibAddonMenu Defaults Button**: When `registerForDefaults = true` in panel registration, provide a custom `defaultsFunc` handler that calls `CM.Settings.Initializer:ResetToDefaults()` to ensure only text fields are preserved
  - This prevents regression where resetting settings clears user-entered character data (customNotes, customTitle, playStyle fields in settings UI)

- **Current per-character fields** (as of v2.1.9+):
  - `customNotes`: Custom build notes entered by user
  - `customTitle`: Custom character title
  - `playStyle`: Play style tag (magicka_dps, stamina_tank, etc.)
  - `markdown_format`: Format of last generated markdown (default: markdown)
  - `markdown`: Full cached markdown document for this character
  - `_initialized`, `_lastModified`, `_characterName`, `_accountName`: Metadata fields

- **Example of adding a field**:
  ```lua
  -- In InitializeCharacterData() initialization block
  if not CM.settings.perCharacterData[characterId] then
      CM.settings.perCharacterData[characterId] = {
          customNotes = "",
          customTitle = "",
          playStyle = "",
          markdown_format = "",
          markdown = "",
          newField = "",  -- Add here
          _initialized = true,
          _lastModified = GetTimeStamp(),
      }
  end
  ```

### File Structure
- Follow the load order in `CharacterMarkdown.addon` manifest
- Core → Utils → Links → Collectors → Generators → Commands → Events → Settings → UI → Init
- New modules must be added to manifest in correct order

### File Naming Conventions
- **YAML files**: Always use `.yaml` suffix (not `.yml`)
  - Example: `config.yaml`, `book.toml` (TOML files use `.toml`)
  - This applies to all YAML configuration files, GitHub Actions workflows, etc.

### Testing
- Unit tests: `/markdown unittest` (collector tests)
- Validation tests: `/markdown test` (markdown validation)
- Export/Import tests: `/cmdsettings test:import-export`
- Test files in `src/utils/*Tests.lua`

### Chunking & Display

**CRITICAL: Chunking Constants - DO NOT CHANGE WITHOUT TESTING**

The chunking constants in `src/utils/Constants.lua` are based on extensive real-world testing. These values work and should NOT be changed without thorough testing:

- **EDITBOX_LIMIT = 21500**: This is the trigger point - when markdown exceeds this, chunking is activated. MUST equal COPY_LIMIT.
- **COPY_LIMIT = 21500**: Safe copy limit confirmed by testing. This is the maximum size a chunk can be for reliable copying.
- **MAX_DATA_CHARS = 20350**: Maximum data characters per chunk (leaves room for ~60 byte HTML comment marker + 550 newlines + buffer)

**Key Relationships:**
- `EDITBOX_LIMIT` MUST equal `COPY_LIMIT` (both 21500) - they trigger chunking when content exceeds what can fit in one chunk
- `MAX_DATA_CHARS` (20350) is less than `COPY_LIMIT` (21500) because chunks include overhead (marker + padding)
- The actual EditBox can handle 22k chars (`SetMaxInputChars(22000)`), but COPY_LIMIT is set to 21500 for safety margin
- Chunking triggers when `markdownLength > EDITBOX_LIMIT` in `src/generators/Markdown.lua:972`

**Why 21,500 and not 20,350?**
- `EDITBOX_LIMIT` is the trigger point for chunking, not the chunk size limit
- Content up to 21,500 chars can fit in a single chunk (with overhead)
- Only when content exceeds 21,500 should chunking activate
- The chunking algorithm then splits into chunks of MAX_DATA_CHARS (20,350) each

**Chunking Implementation:**
- Chunking handled in `src/utils/Chunking.lua`
- Window display in `src/ui/Window.lua` handles chunk navigation
- **Chunk markers (HTML comments like `<!-- Chunk 1 (20603 bytes before padding) -->`) are INTENTIONAL and helpful for readability** - they identify which chunk the user is viewing
- **Excessive trailing newlines (550+ newlines) are INTENTIONAL and NECESSARY** - they protect against truncation during copy/paste operations
- `StripPadding()` function exists but should NOT remove chunk markers or padding from stored chunks - these are features, not bugs
- Chunking limits should only be logged in debug mode (`CM.DebugPrint`, not `CM.Info`)

**CRITICAL: Chunk Markers and Padding Are Features, Not Bugs**
- Chunk markers (`<!-- Chunk N -->`) help users identify which chunk they're viewing/copying
- Excessive trailing newlines (550+ newlines) are a safety mechanism to prevent paste truncation
- These are consequences of the chunking process and MUST remain in the output
- Do NOT attempt to "fix" or remove these - they are working as designed

**Markdown Window:**
- EditBox initialized with `SetMaxInputChars(22000)` in `src/ui/Window.lua`
- Chunking limits logged via `CM.DebugPrint("CHUNKING", ...)` only (not visible in normal chat)
- Window handles chunk navigation, copy/paste, and chunk indicator display

### UI Window Patterns (src/ui/Window.lua)

**CRITICAL: Window.lua is protected code - changes require explicit developer approval**
- This code contains complex, working chunking and keyboard handling logic
- Implementation was difficult to get right and must not be regressed
- DO NOT modify Window.lua without explicit approval from the developer
- Before proposing changes, ask the developer if modification is allowed
- If changes are approved, follow all patterns documented below

**a) EditBox Configuration Pattern**
- Read-only display that allows Ctrl+C copy
- `SetEditEnabled(true)` + `SetKeyboardEnabled(true)` required for Ctrl+C
- Block text input via `OnChar` handler (returns true to consume)
- Block keys via `OnKeyDown` handler (returns true to consume)
- NEVER use `SetEditEnabled(false)` - breaks Ctrl+C

**b) Keyboard Event Handling Architecture**
- Primary handler: EditBox `OnKeyDown` (lines 277-390) handles ALL shortcuts
- Backup handler: Global `EVENT_KEY_DOWN` (lines 1258-1283) for ESC only
- EditBox must maintain focus for shortcuts to work
- Supported shortcuts: G (regenerate), S (settings), R (reload), X/ESC (close), arrows/comma/period (navigate), PageUp/PageDown (navigate), Ctrl+A (select all), Ctrl+C (copy), Space/Enter (copy)

**c) Focus and Selection State Management**
- `isEditBoxFocused` - tracks focus, controls border color (gold/cyan)
- `isTextSelected` - tracks selection, controls button color (white/green)
- `UpdateFocusIndicator()` - changes border color based on focus
- `UpdateSelectAllButtonColor()` - changes button color based on selection
- `ResetSelectionState()` - call on chunk change, window close
- `SetFocusState(focused)` - call on focus gain/loss

**d) Chunk Display and Navigation**
- Chunks arrive pre-chunked from `Markdown.lua` as array of `{content=...}` tables
- `ShowChunk(index)` - displays single chunk, updates UI, resets selection
- Navigation wraps around: NextChunk (1→N→1), PreviousChunk (N→1→N)
- Progress bar: 10 segments showing chunk fullness vs COPY_LIMIT
- Status display: "Chunk X/Y • #,### / ##,### bytes • {OK|WARN|FULL}"

**e) Copy Operation Pattern**
- `CharacterMarkdown_CopyToClipboard()` - main copy function
- `StripPadding()` called ONLY for copy/paste, NOT for display
- Stripping removes HTML chunk markers and normalizes trailing newlines
- `SelectAll(delayMs)` helper - delayed select+focus with 150ms default
- Auto-select triggered: after chunk navigation, window open, regenerate

**f) Import Mode vs Normal Mode**
- `windowControl._isImportMode` flag toggles behavior
- Normal mode: Block text input, show markdown, enable all buttons
- Import mode: Allow text input, accept YAML paste, disable nav/regenerate buttons
- Different OnChar/OnKeyDown behavior based on mode

**g) Memory Management Pattern**
- `ClearChunks()` - clears chunk array, resets indices, prevents leaks
- Call before: window close, regenerate, showing new content
- Reset state: `ResetSelectionState()`, `SetFocusState(false)`
- Clear stored text: `currentMarkdown = ""`, `editBoxControl._originalText = ""`

**h) Helper Functions Pattern**
- `SelectAll(delayMs)` - wraps select+focus in `zo_callLater()`, checks window visibility
- `EnsureEditBoxHasKeyboardFocus()` - forces focus for shortcuts
- Always check `windowControl:IsHidden()` before EditBox operations
- Use `zo_callLater()` for timing-sensitive operations (focus, selection)

**NEVER:**
- Use `SetEditEnabled(false)` or `SetKeyboardEnabled(false)` in normal mode - breaks Ctrl+C
- Strip padding from chunks before displaying - padding is part of display
- Handle keyboard shortcuts in global handler - EditBox handler is primary
- Change chunking constants without testing - empirically validated values
- Modify Window.lua without developer approval

**ALWAYS:**
- Block text input via `OnChar` and `OnKeyDown` handlers, not by disabling EditBox
- Call `ClearChunks()` before showing new content - prevents memory leaks
- Use `zo_callLater()` for focus/selection operations - timing matters
- Strip padding ONLY when copying to clipboard - not for display
- Check window visibility in delayed operations - window might be closed
- Ask developer before modifying Window.lua - protected file

### Multi-Column Table Layout
- **Default pattern**: When a section contains a group of 2+ contiguous (adjacent) similar tables, use multi-column styled table layout as the default
- **Use `CreateResponsiveColumns()`** to wrap multiple styled tables side-by-side:
  ```lua
  local CreateResponsiveColumns = CM.utils.markdown.CreateResponsiveColumns
  local CreateStyledTable = CM.utils.markdown.CreateStyledTable
  
  if CreateResponsiveColumns and CreateStyledTable then
      local tables = {}
      for _, data in ipairs(dataList) do
          table.insert(tables, CreateStyledTable(headers, rows, options))
      end
      
      if #tables > 1 then
          -- Use LayoutCalculator for optimal sizing
          local LayoutCalculator = CM.utils.LayoutCalculator
          local minWidth, gap
          if LayoutCalculator then
              minWidth, gap = LayoutCalculator.GetLayoutParamsWithFallback(tables, "300px", "20px")
          else
              minWidth, gap = "300px", "20px"
          end
          markdown = markdown .. CreateResponsiveColumns(tables, minWidth, gap)
      else
          -- Single table: append directly
          markdown = markdown .. tables[1]
      end
  end
  ```
- **When to use**: Groups of similar/related tables (e.g., Champion Point disciplines, Achievement categories, Crafting areas)
- **When NOT to use**: 
  - Single tables (append directly)
  - Tables separated by other content (headers, text, etc.) - only group truly contiguous tables
  - Tables separated by other content (headers, text, etc.) - only group truly contiguous tables
- **Examples**: See `ChampionPoints.lua` (disciplines), `Achievements.lua` (categories), `Overview.lua` (General columns)

### Settings Panel (LibAddonMenu-2.0)
- **NO emojis or Unicode icons in LAM settings**: LibAddonMenu-2.0 does not render emojis/icons properly
  - NEVER use emojis in checkbox names, section headers, or tooltips
  - NEVER use Unicode arrows (↳, └─, etc.) - they render as empty boxes
  - Use plain text and spaces only for all LAM UI elements
  - Example: Use "Combat & Build" not "🎯 Combat & Build"
- Organize settings by player intent and workflow, not arbitrary "core" vs "extended"
- Use plain spaces for indenting dependent/sub-options (4 spaces for first level, 8 for nested)
- Keep tooltips informative with character count estimates for large sections

### ESO API Guidelines
- Follow ESOUI best practices: https://wiki.esoui.com/
- Use ZO_SavedVars for settings persistence
- Use LibAddonMenu-2.0 for settings UI
- Use LibDebugLogger for debug output (optional dependency)

### Development Workflow

**CRITICAL: Auto-Install After Code Changes**

- **MANDATORY**: After making ANY changes to addon code files (`.lua`, `.xml`, `CharacterMarkdown.addon`, or any file in `src/`):
  - **IMMEDIATELY run `task install:live`** to install the updated code to ESO Live client
  - This must be done automatically after every code change to enable in-game testing
  - The command copies updated files to `~/Documents/Elder Scrolls Online/live/AddOns/CharacterMarkdown/`
  - After installation, user can use `/reloadui` in-game to test changes
  - **Do not skip this step** - code changes are not testable until installed

- **Alternative development mode**: Use `task install:dev` to create a symlink (files update automatically, but requires symlink support)
- **For production testing**: Use `task install:built` to install validated/release-ready files

### Release Process
- **Before every release**: Run comprehensive pre-release validation using `RELEASE_CHECKLIST.md`
- **Automated checks**: Run `./scripts/pre-release-check.sh` or use `task test` and `task build`
- **Git hooks**: Optional pre-push hook available at `scripts/git-hooks/pre-push` to validate before pushing tags
- **Documentation**: See `docs/PUBLISHING.md` for detailed release process
- **Cursor AI**: Can automatically run validation checks from the release checklist
