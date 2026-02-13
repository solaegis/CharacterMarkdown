# Architecture

## Overview

CharacterMarkdown uses a modular architecture with clear separation of concerns:

```
Data Collection → Markdown Generation → UI Display
```

---

## Directory Structure

```
CharacterMarkdown/
├── CharacterMarkdown.addon   # Manifest (load order)
├── CharacterMarkdown.xml     # UI definition
├── src/
│   ├── Core.lua             # Namespace & debug system
│   ├── Commands.lua         # /markdown command (orchestrator)
│   ├── Events.lua           # Event management
│   ├── Init.lua             # Final validation
│   │
│   ├── commands/            # Command submodules
│   │   ├── Debug.lua        # Debug/diagnostic commands
│   │   ├── Settings.lua     # Settings management commands
│   │   └── Test.lua         # Test/validation commands
│   │
│   ├── utils/               # Helper functions
│   │   ├── Formatters.lua   # Text formatting
│   │   ├── Constants.lua    # Chunking limits, format names
│   │   ├── ChunkingHelpers.lua  # Line-type detection for chunking
│   │   ├── Chunking.lua     # Split large markdown into chunks
│   │   ├── TONL.lua         # TONL encode + MinimizeForTONL
│   │   ├── AdvancedMarkdown.lua # Advanced styling
│   │   └── Stats.lua        # Stat calculations
│   │
│   ├── api/                 # API layer (ESO API abstraction)
│   │   ├── Character.lua    # Identity, race, class, level
│   │   ├── Combat.lua       # Stats, attributes, resistances
│   │   ├── Equipment.lua    # Worn gear, sets
│   │   ├── Champion.lua    # CP disciplines
│   │   ├── Skills.lua       # Skill bars, morphs
│   │   └── ...              # PvP, Quests, Achievements, etc.
│   │
│   ├── links/               # UESP URL generation
│   │   ├── Abilities.lua
│   │   ├── Equipment.lua
│   │   ├── World.lua
│   │   ├── Systems.lua
│   │   └── Companions.lua
│   │
│   ├── collectors/          # Data collection (uses api layer)
│   │   ├── Character.lua    # Identity, titles, DLC
│   │   ├── Combat.lua       # Stats, attributes
│   │   ├── Champion.lua     # CP data
│   │   ├── Skills.lua       # Bars, morphs, progression
│   │   ├── Equipment.lua   # Worn gear, sets
│   │   ├── Economy.lua      # Currencies
│   │   ├── Progression.lua # Riding, age
│   │   ├── PvP.lua          # PvP stats, campaigns
│   │   ├── Achievements.lua # Achievement categories
│   │   ├── Collectibles.lua # Collections, housing
│   │   ├── Quests.lua       # Quest journal, pledges
│   │   ├── Companion.lua    # Active companion
│   │   ├── Crafting.lua    # Crafting knowledge
│   │   └── ...
│   │
│   ├── generators/          # Markdown generation
│   │   ├── Markdown.lua     # Main orchestrator
│   │   ├── helpers/
│   │   │   └── Utilities.lua
│   │   └── sections/        # Individual sections
│   │       ├── Character.lua, Overview.lua
│   │       ├── Equipment.lua, equipment/   # Skill bars, morphs, gear table
│   │       ├── Combat.lua, ChampionPoints.lua, ChampionDiagram.lua
│   │       ├── Crafting.lua, Economy.lua
│   │       ├── DLCAndMundus.lua, PvPStats.lua
│   │       ├── Achievements.lua, Antiquities.lua
│   │       ├── TitlesHousing.lua, Quests.lua, World.lua
│   │       ├── Guilds.lua, Companion.lua
│   │       └── Footer.lua
│   │
│   ├── formatters/          # Output formatters
│   │   ├── Markdown.lua     # Markdown output (format selection)
│   │   └── TONL.lua         # TONL output (minimal for LLM)
│   │
│   ├── settings/            # Configuration
│   │   ├── Defaults.lua     # Default values
│   │   ├── Initializer.lua  # SavedVariables init
│   │   └── Panel.lua        # LibAddonMenu UI
│   │
│   └── ui/
│       └── Window.lua       # Display window
│
├── scripts/                 # Build tools
│   ├── validate-manifest.lua
│   ├── validate-zip.sh
│   └── update-api-version.sh
│
└── taskfiles/               # Modular task definitions
    ├── Dev.yaml             # Development tasks
    ├── Build.yaml           # Build & package tasks
    ├── Release.yaml         # Release workflow tasks
    └── Install.yaml         # ESO installation tasks
```

---

## Load Order

Defined in `CharacterMarkdown.addon`:

```
1. Core.lua              # Initialize namespace, debug system
2. utils/*               # Helper functions (Constants, ChunkingHelpers, Chunking, TONL, etc.)
3. api/*                 # API layer (Character, Combat, Equipment, Skills, Champion, etc.)
4. links/*               # UESP URL generation (uses utils)
5. collectors/*          # Data collection (uses api + utils + links)
6. generators/helpers/*  # Generator utilities
7. generators/sections/* # Individual markdown sections
8. generators/Markdown.lua  # Main markdown orchestrator
9. formatters/*          # Output formatters (Markdown.lua, TONL.lua)
10. commands/*          # Command submodules
11. Commands.lua         # /markdown, /tonl command orchestration
12. Events.lua           # Event handlers
13. settings/*           # Configuration (Defaults, Initializer, Panel)
14. CharacterMarkdown.xml   # UI definition
15. ui/Window.lua        # Window handler
16. Init.lua             # Final validation
```

**Critical**: Order ensures dependencies load before dependents. Access settings via `CM.GetSettings()`.

---

## Core Components

### 1. Namespace (Core.lua)

```lua
CharacterMarkdown = CharacterMarkdown or {}
local CM = CharacterMarkdown

-- Sub-namespaces
CM.utils = {}
CM.api = {}           # API layer (ESO API abstraction)
CM.links = {}
CM.collectors = {}
CM.generators = {}
CM.settings = {}

-- State
CM.isInitialized = false

-- Debug system
CM.DebugPrint(category, message)
CM.Info(message)
CM.Warn(message)
CM.Error(message)

-- Settings: access via CM.GetSettings() (merged with defaults)
```

### 2. Data Collection

**Pattern**: Each collector exports a function returning structured data.

```lua
-- collectors/Character.lua
function CM.collectors.CollectCharacterData()
    return {
        name = GetUnitName("player"),
        race = GetUnitRace("player"),
        class = GetUnitClass("player"),
        level = GetUnitLevel("player"),
        cp = GetPlayerChampionPointsEarned(),
    }
end

-- All ESO API calls wrapped in pcall for safety
local success, value = pcall(GetPlayerStat, STAT_HEALTH_MAX)
```

### 3. Markdown Generation

**Pattern**: Orchestrator calls section generators.

```lua
-- generators/Markdown.lua
function CM.generators.GenerateMarkdown(format)
    local markdown = {}
    
    -- Collect all data
    local data = {
        character = CM.collectors.CollectCharacterData(),
        combat = CM.collectors.CollectCombatStatsData(),
        equipment = CM.collectors.CollectEquipmentData(),
        -- ... etc
    }
    
    -- Generate sections
    table.insert(markdown, GenerateCharacterSection(data, format))
    table.insert(markdown, GenerateEquipmentSection(data, format))
    -- ... etc
    
    return table.concat(markdown, "\n")
end
```

### 4. Link Generation

**Pattern**: Convert ESO entity names to UESP URLs.

```lua
-- links/Abilities.lua
function CM.links.GetAbilityLink(name, format)
    if format ~= "markdown" then
        return name  -- No links in other formats
    end
    
    -- Clean name (remove rank suffixes)
    local cleanName = name:gsub(" IV$", ""):gsub(" III$", "")
    
    -- URL encode
    local urlName = cleanName:gsub(" ", "_")
    
    -- Generate link
    return string.format("[%s](https://en.uesp.net/wiki/Online:%s)",
        name, urlName)
end
```

### 5. Settings System

**Pattern**: LibAddonMenu integration with SavedVariables. Access via `CM.GetSettings()`.

```lua
-- settings/Defaults.lua
CM.Settings.Defaults:GetAll()  -- Returns default values

-- settings/Initializer.lua
-- Initializes CharacterMarkdownSettings (account-wide SavedVariables)
-- Merges defaults, handles per-character data in perCharacterData[characterId]

-- Access: CM.GetSettings() returns merged settings (defaults + saved)
local settings = CM.GetSettings()
if settings.includeChampionPoints then
    -- ...
end

-- settings/Panel.lua
-- Creates LibAddonMenu UI panel
```

### 6. UI Window

**Pattern**: XML defines structure, Lua handles behavior.

```xml
<!-- CharacterMarkdown.xml -->
<TopLevelControl name="CharacterMarkdownWindow">
    <Controls>
        <EditBox name="$(parent)TextContainerEditBox"
                 multiLine="true"
                 readonly="true">
        </EditBox>
    </Controls>
</TopLevelControl>
```

```lua
-- ui/Window.lua
function CharacterMarkdown_ShowWindow(markdown, format)
    editBox:SetText(markdown)
    editBox:SelectAll()
    editBox:TakeFocus()
    window:SetHidden(false)
end
```

---

## Data Flow

### User Executes Command

```
1. User: /markdown github  (or /tonl)
2. Commands.lua: Parse argument → format name or "tonl"
3. Formatter: formatters/Markdown.lua or formatters/TONL.lua
4. Formatter: Call collectors to gather data (conditionally based on settings)
5. Markdown: Call section generators; TONL: MinimizeForTONL then Encode
6. Chunking: If output exceeds limit, split into chunks
7. Commands.lua: Call CharacterMarkdown_ShowWindow(content, format)
8. Window.lua: Display in EditBox, auto-select for copy
```

---

## Key Design Patterns

### 1. Namespace Protection

All code in `CharacterMarkdown` namespace, no global pollution.

### 2. Error Handling

All ESO API calls wrapped in `pcall`:
```lua
local success, result = pcall(ESO_API_Function, args)
if not success then
    return defaultValue
end
```

### 3. Performance Optimization

- Cache global function lookups
- Use table.concat for string building
- Throttle event handlers

### 4. Modular Design

Each module has single responsibility:
- Collectors: Data gathering only
- Generators: Markdown creation only
- Links: URL generation only
- UI: Display only

### 5. Format Flexibility

Format-specific logic isolated in generators:
```lua
if format == "markdown" then
    -- Tables with full details
elseif format == "tonl" then
    -- Structured data output
end
```

---

## Extension Points

### Add New Collector

1. Create `src/collectors/NewFeature.lua`
2. Export function: `CM.collectors.CollectNewFeature`
3. Add to manifest load order
4. Call from `generators/Markdown.lua`

### Add New Format

1. Create `src/formatters/NewFormat.lua` or add format handling in `formatters/Markdown.lua`
2. Add format-specific logic in section generators
3. Update `Commands.lua` for format alias
4. Register in manifest if new formatter file

### Add New Section

1. Create `src/generators/sections/NewSection.lua`
2. Export function: `GenerateNewSection(data, format)`
3. Call from `generators/Markdown.lua`

---

## Testing Strategy

### Unit Tests (Manual)

Test individual collectors in-game:
```lua
/script d(CharacterMarkdown.collectors.CollectCharacterData())
```

### Integration Tests

Test full generation:
```lua
/markdown github
-- Verify all sections present
-- Check UESP links functional
-- Test with different characters
```

### Validation

Automated via Taskfile:
- Luacheck (static analysis)
- Manifest validation
- ZIP structure verification

---

## Related Documentation

- **[User Guide](README.md)** - Usage instructions and troubleshooting
- **[Development Guide](DEVELOPMENT.md)** - Setup, workflow, and contribution guidelines
- **[API Reference](API_REFERENCE.md)** - ESO Lua API patterns and best practices
- **[Testing Guide](TESTING_COMMAND.md)** - Validation and testing procedures
- **[Publishing Guide](PUBLISHING.md)** - Release and distribution process

## Resources

- **ESO API**: https://wiki.esoui.com/
- **Source Code**: https://github.com/esoui/esoui
- **LibAddonMenu**: https://www.esoui.com/downloads/info7-LibAddonMenu.html
