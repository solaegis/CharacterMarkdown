# Settings Panel Defaults Fix

## Problem

On a clean install (with no saved variables file), the settings panel was not properly honoring default values. This was because the addon was using manual initialization instead of ESO's built-in `ZO_SavedVars` system, which is required for proper LibAddonMenu integration.

## Root Cause

The previous implementation manually checked for `nil` values and set defaults, but this approach doesn't integrate properly with LibAddonMenu's (LAM) default handling system. LAM expects saved variables to be initialized using `ZO_SavedVars`, which provides:

1. Automatic default value assignment
2. Proper reset-to-defaults functionality
3. Seamless integration with LAM controls
4. Version migration support

## Solution

Updated `src/settings/Initializer.lua` to use ESO's built-in `ZO_SavedVars` system:

### Changes Made

1. **Added `BuildDefaultsTable()` function**
   - Merges all default categories (FORMAT, CORE, EXTENDED, LINKS, SKILL_FILTERS, EQUIPMENT_FILTERS) into a flat table
   - Provides proper defaults structure for `ZO_SavedVars`

2. **Updated `Initialize()` function**
   - Now uses `ZO_SavedVars:NewAccountWide()` for account-wide settings
   - Uses `ZO_SavedVars:New()` for per-character data
   - Automatically applies defaults on first load
   - Handles version migrations properly

3. **Updated `src/settings/Panel.lua`**
   - Removed unnecessary defaults table building code
   - LAM now works with the ZO_SavedVars-managed settings

## Benefits

✅ **Proper Default Handling**: On clean install, all settings automatically get correct default values  
✅ **LAM Integration**: Reset to defaults functionality works seamlessly  
✅ **Version Migration**: Built-in support for future settings migrations  
✅ **Cleaner Code**: Less manual initialization logic  
✅ **ESO Standards**: Follows ESO addon best practices  

## Testing Steps

To test the fix:

1. **Clean Install Test**:
   ```bash
   # Remove saved variables
   task clean:savedvars
   
   # Reinstall addon
   task install:live
   
   # Launch ESO and check settings panel
   # All checkboxes should show correct defaults (mostly checked)
   # Format dropdown should show "GitHub" as default
   ```

2. **In-Game Verification**:
   - Open Settings > Addons > Character Markdown
   - Verify all core sections are enabled by default
   - Verify all extended sections are enabled by default
   - Verify UESP links are enabled by default
   - Verify format is set to "GitHub"
   - Try the "Reset All Settings" button
   - Generate a profile with `/markdown` to ensure it works

3. **Migration Test** (if you have existing settings):
   - The new system should preserve your existing settings
   - Settings saved in the old format will be automatically migrated

## Clean Install Workflow

The new Taskfile includes a task to remove saved variables for clean testing:

```bash
# Remove saved variables file
task clean:savedvars

# Reinstall addon cleanly
task uninstall:live
task install:live
```

Or to do a complete clean reinstall:

```bash
task uninstall:live
task clean:savedvars
task install:live
```

## Files Modified

- `src/settings/Initializer.lua` - Now uses ZO_SavedVars
- `src/settings/Panel.lua` - Cleaned up unnecessary code
- `Taskfile.yaml` - Added `clean:savedvars` task

## Backwards Compatibility

The changes maintain backwards compatibility:
- Existing saved settings will be preserved
- Manual reset functionality still available via "Reset All Settings" button
- Legacy `InitializeAccountSettings()` function kept for manual reset

