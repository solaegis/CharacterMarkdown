# Hotfix v1.0.1 - Update Instructions

## Issue Fixed

**Error:** `function expected instead of nil` on line 107  
**Cause:** `GetPlayerStat()` returning nil for certain STAT constants  
**Solution:** Added safe wrapper and error handling

---

## How to Update Your Installed Addon

### Option 1: Using Task (Recommended)

```bash
cd ~/git/CharacterMarkdown
task install
```

This will copy the updated files to your ESO AddOns directory.

### Option 2: Manual Copy

```bash
# Copy updated files
cp ~/git/CharacterMarkdown/CharacterMarkdown.lua \
   ~/git/CharacterMarkdown/CharacterMarkdown.txt \
   ~/Documents/Elder\ Scrolls\ Online/live/AddOns/CharacterMarkdown/
```

### Option 3: If You Used Symlink (Dev Mode)

No action needed! The symlink automatically uses the updated files.

---

## Test the Fix

1. **Launch ESO**
2. At character select, verify version shows "1.0.1"
3. **Log in to a character**
4. Type `/markdown`
5. **Window should appear** with your character data

---

## What Changed in v1.0.1

### Code Changes

1. **Added SafeGetPlayerStat() function:**
   ```lua
   local function SafeGetPlayerStat(statType, defaultValue)
       defaultValue = defaultValue or 0
       local value = GetPlayerStat(statType)
       if value == nil then
           return defaultValue
       end
       return value
   end
   ```

2. **Added nil checks everywhere:**
   - Mundus stone detection
   - Skill line data
   - All GetPlayerStat() calls

3. **Added error handling:**
   - All data collection wrapped in `pcall()`
   - Errors logged to chat
   - Partial data still displayed if one section fails

### Result

- ✅ No more crashes from nil stat values
- ✅ Graceful error handling
- ✅ Detailed error messages in chat
- ✅ Partial exports work even if one section fails

---

## Verify the Update

After updating, check the chat window for:

```
[CharacterMarkdown] Loaded v1.0.1. Use /markdown to export character data.
```

Note: Version changed from 1.0.0 to **1.0.1**

---

## If Problems Persist

### Check for Errors

```
In ESO:
/luaerror on
/markdown
```

Look for any error messages in chat.

### Get Debug Info

```
In ESO:
/script d(GetAPIVersion())
```

This shows your current ESO API version.

### Report Issues

If you still get errors, please provide:
1. Full error message
2. Your ESO API version
3. Character level/class
4. Any other addons installed

---

## Quick Commands Reference

```bash
# Update addon
task install

# Or reinstall completely
task uninstall
task install

# Check version in git
cd ~/git/CharacterMarkdown
grep "Version:" CharacterMarkdown.txt

# Check installed version
grep "Version:" ~/Documents/Elder\ Scrolls\ Online/live/AddOns/CharacterMarkdown/CharacterMarkdown.txt
```

---

## Summary

**Version:** 1.0.0 → 1.0.1  
**Fix:** Nil-safe stat retrieval  
**Status:** ✅ Ready to install  
**Update Command:** `task install`

**Your addon is now fixed and ready to use!**
