# System Prompt: Continue CharacterMarkdown Settings Defaults Issue

## Task
Fix the CharacterMarkdown ESO addon so that on first install (with no saved variables file), the settings panel checkboxes show as ON (checked) instead of OFF (unchecked), matching the intended defaults.

## Current State

**Problem**: All settings show as OFF in the UI on fresh install, even though they should default to ON.

**What's Working**: 
- Addon loads and runs
- `/markdown` command works
- Settings can be manually toggled
- Clean install task: `task clean:savedvars`

**What's NOT Working**:
- Default values don't appear in Settings > Add-Ons > Character Markdown UI
- All checkboxes show as OFF/unchecked on first run

## Root Cause Discovered

ESO's saved variables system creates a special `userdata` object after our initialization code runs, which wipes out values we've set. We set `includeChampionPoints = true`, then ESO replaces the table with an empty userdata object, making it `nil` again.

See `SETTINGS_DEFAULTS_ISSUE_SUMMARY.md` for complete technical details, all approaches tried, and diagnostic data.

## Quick Context

- **Location**: `/Users/lvavasour/git/CharacterMarkdown/`
- **ESO Live AddOns**: `/Users/lvavasour/Documents/Elder Scrolls Online/live/AddOns/`
- **Key Files**: 
  - `src/settings/Initializer.lua` (has lots of debug logging)
  - `src/settings/Panel.lua` (LAM UI controls, one checkbox partially fixed)
  - `src/Events.lua` (retry logic with debug logging)
- **Test Command**: `task install:live` then `/reloadui` in game
- **Debug**: User has AUI addon, use `CHAT_SYSTEM:AddMessage()` not `d()` for debug output

## Recommended Approach

**Option 1 (Fastest)**: Update ALL checkboxes in `Panel.lua` to return defaults when values are `nil`:
```lua
getFunc = function() 
    return CharacterMarkdownSettings.someValue ~= nil 
        and CharacterMarkdownSettings.someValue 
        or true  -- default value
end
```

One checkbox (`includeChampionPoints` at line ~143) is already done this way as proof of concept.

**Option 2**: Research how other ESO addons handle first-run defaults with LAM

## Success Criteria

1. Clean install: `task clean:savedvars && task install:live`
2. Launch ESO
3. Open Settings > Add-Ons > Character Markdown
4. All checkboxes show as checked/ON
5. Values persist across sessions

## Notes

- Code currently has extensive debug logging to remove once fixed
- User is comfortable with Lua and ESO addon development
- Can test immediately in-game
- Has Task runner setup (`task --list` for commands)

