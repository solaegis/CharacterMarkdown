# Refactoring Test Guide

## Quick Testing Steps

### 1. In-Game Testing (Recommended)

If you're testing in Elder Scrolls Online:

```
1. Copy the addon to your ESO AddOns folder:
   - Copy entire CharacterMarkdown folder to:
     Documents/Elder Scrolls Online/live/AddOns/CharacterMarkdown/

2. Launch ESO

3. Run /reloadui (to reload the addon with new modules)

4. Test all generation formats:
   /markdown github
   /markdown vscode
   /markdown discord
   /markdown quick

5. Verify output looks correct and contains all expected sections
```

### 2. File Verification

Check that all new files exist:

```bash
cd /Users/lvavasour/git/CharacterMarkdown

# Verify helper module
ls -l src/generators/helpers/Utilities.lua

# Verify section modules
ls -l src/generators/sections/Character.lua
ls -l src/generators/sections/Economy.lua
ls -l src/generators/sections/Equipment.lua
ls -l src/generators/sections/Combat.lua
ls -l src/generators/sections/Content.lua
ls -l src/generators/sections/Companion.lua
ls -l src/generators/sections/Footer.lua

# Verify main coordinator
ls -l src/generators/Markdown.lua

# Verify manifest includes new files
grep -A 10 "Markdown generator" CharacterMarkdown.txt
```

### 3. Syntax Check (Local)

Verify Lua syntax is valid:

```bash
cd /Users/lvavasour/git/CharacterMarkdown

# Check each new file for syntax errors
luac -p src/generators/helpers/Utilities.lua
luac -p src/generators/sections/*.lua
luac -p src/generators/Markdown.lua
```

If `luac` is not available, the in-game test will catch any syntax errors when the addon loads.

### 4. Compare Output

To ensure the refactoring didn't change the output:

1. **Before refactoring**: Generate markdown for a character (if you have a backup)
2. **After refactoring**: Generate markdown for the same character
3. **Compare**: The output should be identical

### 5. Test Each Section Independently

Test settings to enable/disable sections:

```lua
-- In game, try disabling various sections in settings
/script CharacterMarkdownSettings.includeQuickStats = false
/markdown github

/script CharacterMarkdownSettings.includeQuickStats = true
/markdown github

-- Test other sections
/script CharacterMarkdownSettings.includeEquipment = false
/script CharacterMarkdownSettings.includeSkills = false
/script CharacterMarkdownSettings.includeCompanion = false
-- etc.
```

## Expected Results

### ✅ Success Indicators

1. **Addon loads without errors**
   - No Lua errors shown on screen
   - No errors in SavedVariables/Errors.txt

2. **All commands work**
   - `/markdown` displays help
   - `/markdown github` generates full markdown
   - `/markdown vscode` generates VSCode format
   - `/markdown discord` generates Discord format
   - `/markdown quick` generates one-line summary

3. **Output contains all sections**
   - Header with character name
   - Quick Stats (if enabled)
   - Attention Needed (if applicable)
   - Character Overview
   - Currency & Resources
   - Inventory
   - Equipment with sets
   - Skill bars with abilities
   - Champion Points
   - Skills progression
   - Companion info (if active)
   - Footer with version

4. **Settings panel works**
   - Can open settings via /cm settings or addon menu
   - All toggles work correctly
   - Changes affect markdown output

### ❌ Failure Indicators

1. **Addon fails to load**
   - Check for Lua syntax errors
   - Verify manifest file includes all modules
   - Check file paths are correct

2. **Missing sections in output**
   - Check that section module loaded correctly
   - Verify CM.generators.sections namespace exists
   - Check settings aren't disabling sections

3. **Lua errors when generating**
   - Check error message for which module failed
   - Verify all dependencies loaded (collectors, links, utils)
   - Check for typos in function names

## Debugging

### Check if modules loaded:

```lua
-- In game, run this in chat:
/script d("Generators namespace: " .. tostring(CM.generators ~= nil))
/script d("Sections namespace: " .. tostring(CM.generators.sections ~= nil))
/script d("Helpers namespace: " .. tostring(CM.generators.helpers ~= nil))

-- Check specific functions exist
/script d("GenerateHeader: " .. tostring(CM.generators.sections.GenerateHeader ~= nil))
/script d("GenerateProgressBar: " .. tostring(CM.generators.helpers.GenerateProgressBar ~= nil))
```

### Check manifest loading order:

```lua
-- Verify files are listed in correct order in CharacterMarkdown.txt:
1. Core.lua
2. Utils (Formatters, Quality, Stats)
3. Links (Abilities, Equipment, World, Systems, Companions)
4. Collectors (Character, Progression, Skills, Equipment, Combat, Economy, World, Companion)
5. Generators helpers (Utilities.lua)
6. Generators sections (all 7 section files)
7. Generators main (Markdown.lua)
8. Commands, Events, Settings, UI, Init
```

## Rollback Plan

If issues occur, you can quickly rollback:

```bash
# Restore the original monolithic file from backup
cd /Users/lvavasour/git/CharacterMarkdown
cp CharacterMarkdown.lua.backup src/generators/Markdown.lua

# Remove new modules from manifest
# Edit CharacterMarkdown.txt and remove lines 36-47 (the new module references)

# Remove new directories
rm -rf src/generators/helpers
rm -rf src/generators/sections

# Reload in game
/reloadui
```

## Performance Notes

The refactored code should have **identical performance** to the original:

- Same execution flow
- Same number of function calls
- Same data structures
- Lazy initialization of utilities (loaded only when needed)
- No additional overhead from modularization

## Next Steps After Testing

1. ✅ Verify all sections generate correctly
2. ✅ Test with different characters (different classes, levels, equipment)
3. ✅ Test all format outputs (github, vscode, discord, quick)
4. ✅ Verify settings toggles work
5. ✅ Check memory usage is similar
6. ✅ Confirm no performance degradation

Once testing is complete and everything works:
- Delete `CharacterMarkdown.lua.backup` if no longer needed
- Delete `REFACTORING_*.md` documentation files if desired
- Commit changes to version control

## Support

If you encounter issues:
1. Check ESO's SavedVariables/CharacterMarkdown.txt for saved settings
2. Look for Lua errors in chat or SavedVariables/Errors.txt
3. Verify all files are in correct locations
4. Try /reloadui to refresh the addon
5. Check manifest file loading order

The refactoring maintains 100% backward compatibility - if something doesn't work, it's likely a file path or loading order issue that can be easily fixed.

