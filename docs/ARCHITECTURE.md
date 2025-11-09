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
│   ├── Commands.lua         # /markdown command
│   ├── Events.lua           # Event management
│   ├── Init.lua             # Final validation
│   │
│   ├── utils/               # Helper functions
│   │   ├── Formatters.lua   # Text formatting
│   │   ├── Quality.lua      # Item quality utilities
│   │   └── Stats.lua        # Stat calculations
│   │
│   ├── links/               # UESP URL generation
│   │   ├── Abilities.lua
│   │   ├── Equipment.lua
│   │   ├── World.lua
│   │   ├── Systems.lua
│   │   └── Companions.lua
│   │
│   ├── collectors/          # Data collection
│   │   ├── Character.lua    # Identity, DLC
│   │   ├── Combat.lua       # Stats, attributes
│   │   ├── Equipment.lua    # Worn gear, sets
│   │   ├── Skills.lua       # Bars, progression
│   │   ├── Economy.lua      # Currencies
│   │   ├── Progression.lua  # Achievements, riding
│   │   ├── World.lua        # Location, PvP
│   │   └── Companion.lua    # Active companion
│   │
│   ├── generators/          # Markdown generation
│   │   ├── Markdown.lua     # Main orchestrator
│   │   ├── helpers/
│   │   │   └── Utilities.lua
│   │   └── sections/        # Individual sections
│   │       ├── Character.lua
│   │       ├── Equipment.lua
│   │       ├── Combat.lua
│   │       ├── Content.lua
│   │       ├── Economy.lua
│   │       ├── Companion.lua
│   │       └── Footer.lua
│   │
│   ├── settings/            # Configuration
│   │   ├── Defaults.lua     # Default values
│   │   ├── Initializer.lua  # SavedVariables init
│   │   └── Panel.lua        # LibAddonMenu UI
│   │
│   └── ui/
│       └── Window.lua       # Display window
│
└── scripts/                 # Build tools
    ├── validate-manifest.lua
    ├── validate-zip.sh
    └── update-api-version.sh
```

---

## Load Order

Defined in `CharacterMarkdown.addon`:

```
1. Core.lua              # Initialize namespace, debug system
2. utils/*               # Helper functions (no dependencies)
3. links/*               # UESP URL generation (uses utils)
4. collectors/*          # Data collection (uses utils + links)
5. generators/helpers/*  # Generator utilities
6. generators/sections/* # Individual markdown sections
7. generators/Markdown.lua  # Main orchestrator
8. Commands.lua          # /markdown command
9. Events.lua            # Event handlers
10. settings/*           # Configuration system
11. CharacterMarkdown.xml   # UI definition
12. ui/Window.lua        # Window handler
13. Init.lua             # Final validation
```

**Critical**: Order ensures dependencies load before dependents.

---

## Core Components

### 1. Namespace (Core.lua)

```lua
CharacterMarkdown = CharacterMarkdown or {}
local CM = CharacterMarkdown

-- Sub-namespaces
CM.utils = {}
CM.links = {}
CM.collectors = {}
CM.generators = {}
CM.settings = {}

-- State
CM.currentFormat = "github"
CM.isInitialized = false

-- Debug system
CM.DebugPrint(category, message)
CM.Info(message)
CM.Warn(message)
CM.Error(message)

-- Cached globals (performance)
CM.cached = {
    EVENT_MANAGER = EVENT_MANAGER,
    string_format = string.format,
    table_insert = table.insert,
}
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
    if format ~= "github" and format ~= "discord" then
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

**Pattern**: LibAddonMenu integration with SavedVariables.

```lua
-- settings/Defaults.lua
CM.Settings.defaults = {
    currentFormat = "github",
    includeChampionPoints = true,
    enableAbilityLinks = true,
    minSkillRank = 1,
}

-- settings/Initializer.lua
function CM.Settings.Initializer:Initialize()
    -- Merge defaults with SavedVariables
    for key, value in pairs(CM.Settings.defaults) do
        if CharacterMarkdownSettings[key] == nil then
            CharacterMarkdownSettings[key] = value
        end
    end
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
1. User: /markdown github
2. Commands.lua: Parse argument → "github"
3. Commands.lua: Call CM.generators.GenerateMarkdown("github")
4. Markdown.lua: Call all collectors to gather data
5. Markdown.lua: Call section generators with data + format
6. Markdown.lua: Concatenate sections → return markdown string
7. Commands.lua: Call CharacterMarkdown_ShowWindow(markdown, "github")
8. Window.lua: Display markdown in EditBox
9. Window.lua: Auto-select text for easy copying
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
if format == "github" then
    -- Tables with full details
elseif format == "discord" then
    -- Compact, emoji-rich
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

1. Edit `generators/Markdown.lua`
2. Add format handling in section generators
3. Update `Commands.lua` for format alias

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
- **[Testing Guide](../TESTING_GUIDE.md)** - Validation and testing procedures
- **[Publishing Guide](PUBLISHING.md)** - Release and distribution process

## Resources

- **ESO API**: https://wiki.esoui.com/
- **Source Code**: https://github.com/esoui/esoui
- **LibAddonMenu**: https://www.esoui.com/downloads/info7-LibAddonMenu.html
