# Testing Instructions for v2.1.0 Fixes

## Issues Fixed

### 1. **`/markdown` Command Not Working**
- **Root Cause:** Commands.lua was calling `GenerateMarkdown()` as a global function instead of using the namespace reference `CM.generators.GenerateMarkdown()`
- **Fix Applied:** Updated function call to use correct namespace + added error checking

### 2. **Settings Panel Missing**
- **Root Cause:** LibAddonMenu2 check was failing silently with minimal feedback
- **Fix Applied:** Added colorized, detailed instructions when LAM is missing

---

## Testing Steps

### **Test 1: Verify Addon Loads**
1. Start ESO
2. Check chat window for load message:
   ```
   [CharacterMarkdown] v2.1.0 loaded
   [CharacterMarkdown] Settings initialized
   ```
3. **Expected:** Both messages should appear
4. **If missing:** Check addon is enabled in Settings > Addons

---

### **Test 2: Verify `/markdown` Command Works**
1. In-game, type: `/markdown help`
2. **Expected Output:**
   ```
   [CharacterMarkdown] Usage:
     /markdown          - Generate profile (current format: github)
     /markdown github   - Generate GitHub-optimized profile
     /markdown vscode   - Generate VS Code-optimized profile
     /markdown discord  - Generate Discord-optimized profile
     /markdown quick    - Generate quick one-line summary
     /markdown help     - Show this help message
   ```

3. Type: `/markdown quick`
4. **Expected Output:**
   ```
   [CharacterMarkdown] Generating quick format...
   [CharacterMarkdown] ✅ Markdown generated (XXX characters)
   [CharacterMarkdown] Opening display window...
   ```

5. **Expected Result:** Character profile window opens with one-line summary

---

### **Test 3: Verify Full Markdown Generation**
1. Type: `/markdown github`
2. **Expected:** 
   - Loading messages in chat
   - Window opens with full character profile
   - Profile includes: name, race, class, CP, skill bars, equipment, etc.
3. **Test each format:**
   - `/markdown vscode`
   - `/markdown discord`
   - Each should generate successfully

---

### **Test 4: Settings Panel (If LAM Installed)**

**If LibAddonMenu-2.0 IS installed:**
1. Press `ESC` → Settings → Addons
2. Find "Character Markdown" in the list
3. Click to open settings panel
4. **Expected:** Full settings UI with toggles for sections, filters, etc.
5. Test a setting change:
   - Disable "Include Champion Points"
   - Generate markdown with `/markdown`
   - Verify CP section is missing from output

**If LibAddonMenu-2.0 NOT installed:**
1. Check chat window after addon loads
2. **Expected colorized message:**
   ```
   [CharacterMarkdown] ⚠️ Settings panel unavailable (red)
   LibAddonMenu-2.0 is required for the settings UI (yellow)
   To install: (white)
     1. Download from: https://www.esoui.com/downloads/info7-LibAddonMenu.html
     2. Extract to: Documents/Elder Scrolls Online/live/AddOns/
     3. Reload UI with /reloadui
   The /markdown command still works without settings UI (green)
   ```

---

### **Test 5: Error Handling**

**Simulate missing generator (shouldn't happen but tests error path):**
1. If you want to test error messages, temporarily rename `src/generators/Markdown.lua`
2. Reload UI: `/reloadui`
3. Try: `/markdown`
4. **Expected:**
   ```
   [CharacterMarkdown] ❌ ERROR: Markdown generator not loaded!
   [CharacterMarkdown] This usually means the addon didn't load correctly.
   [CharacterMarkdown] Try /reloadui to restart the addon.
   ```
5. **Restore the file** and reload again

---

## Expected Behavior After Fixes

### ✅ **Working State**
- `/markdown` commands execute successfully
- All format variations work (github, vscode, discord, quick)
- Character data is collected and formatted properly
- Settings UI appears (if LAM installed) or shows helpful message (if LAM missing)
- All UESP links are clickable in GitHub/Discord formats

### ❌ **Still Broken? Check These**

**If `/markdown` still fails:**
1. Enable Lua errors: `/luaerror on`
2. Try command again
3. Screenshot any error messages
4. Check chat for the new error messages we added

**If settings missing and LAM IS installed:**
1. Verify LAM directory: `Documents/Elder Scrolls Online/live/AddOns/LibAddonMenu-2.0/`
2. Check LAM has `LibAddonMenu-2.0.txt` manifest file
3. Ensure LAM is enabled in Settings > Addons
4. Try `/reloadui`

**If character data seems wrong:**
1. Check you're logged into a character (not character select screen)
2. Verify character is Level 1+ (fresh tutorial characters might have missing data)
3. Some sections (like companion) only show if relevant (e.g., companion summoned)

---

## Files Modified

### **src/Commands.lua**
- Line ~55: Changed `GenerateMarkdown(format)` to `CM.generators.GenerateMarkdown(format)`
- Added error checking before calling generator
- Added helpful error messages if generator is missing

### **src/settings/Panel.lua**
- Lines 15-21: Enhanced LibAddonMenu missing message
- Added colorized, multi-line instructions
- Made it clear that core functionality still works

---

## Rollback Instructions

If these fixes cause new issues, you can rollback:

```bash
cd ~/git/CharacterMarkdown
git diff src/Commands.lua
git diff src/settings/Panel.lua

# To revert:
git checkout src/Commands.lua
git checkout src/settings/Panel.lua
```

---

## Next Steps After Testing

1. ✅ Verify all commands work
2. ✅ Confirm settings panel appears (or shows helpful message)
3. ✅ Test markdown generation in all 4 formats
4. ✅ Test with/without LibAddonMenu installed
5. 📝 Report any remaining issues with:
   - Exact command used
   - Error messages (with `/luaerror on`)
   - Screenshot of output

---

## Additional Debugging Commands

```
/markdown help          -- Show all available commands
/luaerror on           -- Enable Lua error display
/reloadui              -- Reload entire UI
/cmdsettings           -- Try to open settings (may work if LAM loads late)
```

---

**Version:** Post-fix for v2.1.0  
**Date:** 2025-10-16  
**Issues Fixed:** Command handler namespace + Settings panel feedback
