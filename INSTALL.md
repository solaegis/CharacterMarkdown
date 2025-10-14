# Character Markdown - Installation & Testing Guide

## Quick Start

### 1. Installation

**Method A: Manual Installation (Recommended for Testing)**

```bash
# Navigate to your ESO AddOns directory
# Windows:
cd "Documents/Elder Scrolls Online/live/AddOns/"

# Mac:
cd ~/Documents/Elder\ Scrolls\ Online/live/AddOns/

# Copy the addon folder
cp -r ~/git/CharacterMarkdown ./
```

**Method B: Symlink (Development Mode)**

```bash
# Mac/Linux - allows live editing
ln -s ~/git/CharacterMarkdown ~/Documents/Elder\ Scrolls\ Online/live/AddOns/CharacterMarkdown

# Windows (Run as Administrator)
mklink /D "Documents\Elder Scrolls Online\live\AddOns\CharacterMarkdown" "%USERPROFILE%\git\CharacterMarkdown"
```

### 2. Enable the Addon

1. Launch Elder Scrolls Online
2. At the **character select screen**, click **AddOns** (bottom left)
3. Find **Character Markdown** in the list
4. Check the box to enable it
5. Click **Apply**
6. Log in to any character

### 3. Test the Addon

```
/markdown
```

A window should appear with your character data in markdown format.

---

## Installation Verification

### Check File Structure

Your AddOns folder should look like this:

```
Elder Scrolls Online/live/AddOns/
└── CharacterMarkdown/
    ├── CharacterMarkdown.txt   (manifest)
    ├── CharacterMarkdown.xml   (UI)
    ├── CharacterMarkdown.lua   (logic)
    ├── README.md              (docs)
    ├── CHANGELOG.md           (version history)
    ├── LICENSE                (MIT)
    └── .gitignore             (git config)
```

### Verify Addon Loads

After logging in, check the chat window for:

```
[CharacterMarkdown] Loaded. Use /markdown to export character data.
```

If you don't see this message:
1. Type `/reloadui` to reload all addons
2. Check for LUA errors with `/luaerror on`
3. Verify folder name is exactly `CharacterMarkdown` (case-sensitive)

---

## Testing Checklist

### Basic Functionality
- [ ] Addon loads without errors
- [ ] `/markdown` command opens window
- [ ] Window displays character data
- [ ] Window can be moved by dragging title bar
- [ ] Close button (X) works
- [ ] ESC key closes window

### Data Validation
- [ ] Character name, race, class correct
- [ ] Level and CP values accurate
- [ ] Current mundus stone shown
- [ ] All equipment slots populated
- [ ] Set bonuses displayed correctly
- [ ] Active skill lines listed
- [ ] Companion data present

### Copy-Paste Testing
- [ ] Ctrl+A selects all text
- [ ] Ctrl+C copies to clipboard
- [ ] Paste into text editor works
- [ ] Markdown formatting preserved
- [ ] No truncation for large output

### Edge Cases
- [ ] Works with low-level character (< 50)
- [ ] Works with max CP character
- [ ] Works with empty equipment slots
- [ ] Works with no active mundus
- [ ] Works with no unlocked companions

---

## Troubleshooting

### Issue: Window doesn't appear

**Solution 1: Check AddOns are enabled**
```
1. Character select screen → AddOns button
2. Verify "Character Markdown" is checked
3. Click Apply and re-login
```

**Solution 2: Reload UI**
```
/reloadui
```

**Solution 3: Check for errors**
```
/luaerror on
/markdown
```

Look for red error messages in chat.

### Issue: Missing data sections

**Possible causes:**
- API version mismatch (check game is updated)
- Conflicting addons (disable others temporarily)
- Character hasn't unlocked certain features (companions, skill lines)

**Debug steps:**
```lua
-- Open in-game console with /script
/script d(GetAPIVersion())  -- Should return 101043 or 101044
```

### Issue: LUA Error on load

**Common errors:**

**Error: "attempt to index nil value"**
- Likely missing ESO API function
- Check API version in `CharacterMarkdown.txt`
- Update to match your game version

**Error: "bad argument to X"**
- Function called with wrong parameters
- Check ESO API documentation for changes

### Issue: Can't copy text

**Solutions:**
1. Click inside the text box first
2. Use Ctrl+A (Cmd+A on Mac) to select all
3. Use Ctrl+C (Cmd+C on Mac) to copy
4. Don't try to drag-select with mouse (unreliable)

### Issue: Text truncated

Current character limit is 50,000 characters. If you hit this:

**Workaround 1: Export to file**
```lua
-- In CharacterMarkdown.lua, add:
-- Save to SavedVariables instead of UI
```

**Workaround 2: Selective export**
```lua
-- Comment out sections you don't need
-- markdown = markdown .. GetCompanions()  -- Skip this
```

---

## Development Mode

### Live Editing Setup

1. **Use symlink installation** (see Method B above)
2. **Edit files** in `~/git/CharacterMarkdown/`
3. **Test changes** in-game with `/reloadui`

### Hot Reload Workflow

```bash
# Terminal 1: Edit code
vim ~/git/CharacterMarkdown/CharacterMarkdown.lua

# In-game: Test changes
/reloadui
/markdown
```

### Debug Output

Add debug statements:

```lua
-- In CharacterMarkdown.lua
d("DEBUG: Variable value = " .. tostring(myVar))
```

View output in chat window.

### Common Development Tasks

**Add new data section:**
```lua
-- 1. Create collection function
local function GetMyNewData()
    local markdown = "## My New Section\n\n"
    -- Collect data here
    return markdown
end

-- 2. Add to GenerateMarkdown()
markdown = markdown .. GetMyNewData()
```

**Modify window size:**
```xml
<!-- In CharacterMarkdown.xml -->
<Dimensions x="1000" y="800" />  <!-- Changed from 800x600 -->
```

**Change command:**
```lua
-- In CharacterMarkdown:Initialize()
SLASH_COMMANDS["/chardata"] = ShowMarkdownWindow  -- Instead of /markdown
```

---

## API Version Updates

When ESO updates and breaks the addon:

### Check Current API Version
```
In-game: /script d(GetAPIVersion())
```

### Update Manifest
```txt
## APIVersion: 101043 101044 101045  ## Add new version
```

### Test Compatibility
1. Load with new API version
2. Check for deprecated functions
3. Test all data collection functions
4. Verify UI displays correctly

### Common Breaking Changes

**Equipment API changes:**
- Slot indices may change
- New equipment slots added
- Set bonus detection modified

**Skill API changes:**
- Skill line indexing changes
- New skill types added
- CP system rework

**Companion API changes:**
- New companions added
- Rapport system modified
- Role assignments changed

---

## Performance Monitoring

### Check Memory Usage

```lua
-- In-game
/script d(collectgarbage("count"))  -- KB used
```

Character Markdown should use < 100 KB when window closed.

### Check Generation Time

Add timing to `GenerateMarkdown()`:

```lua
local function GenerateMarkdown()
    local startTime = GetGameTimeMilliseconds()
    
    -- ... existing code ...
    
    local endTime = GetGameTimeMilliseconds()
    d(string.format("[CharacterMarkdown] Generated in %dms", endTime - startTime))
    
    return markdown
end
```

Should complete in < 100ms on modern systems.

---

## Sharing & Distribution

### Package for Release

```bash
cd ~/git/CharacterMarkdown
zip -r CharacterMarkdown-v1.0.0.zip \
    CharacterMarkdown.txt \
    CharacterMarkdown.xml \
    CharacterMarkdown.lua \
    README.md \
    LICENSE
```

### ESOUI Upload

1. Create account at https://www.esoui.com
2. Upload ZIP file
3. Fill out addon information
4. Include screenshots
5. Add changelog

### GitHub Release

```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

Create release on GitHub with ZIP attachment.

---

## Support Resources

### ESO API Documentation
- **Official**: https://wiki.esoui.com/API
- **Community**: https://www.esoui.com/forums/

### Debugging Tools
- **zgoo**: Inspect game objects
- **LibDebugLogger**: Advanced logging
- **LibStub**: Library dependency management

### Community
- **ESOUI Forums**: https://www.esoui.com/forums/
- **Discord**: ESO UI & AddOns Community

---

## Next Steps

After successful installation and testing:

1. **Customize** output format in `CharacterMarkdown.lua`
2. **Add features** from CHANGELOG.md planned section
3. **Share** with guild/friends
4. **Contribute** improvements back to repository
5. **Publish** on ESOUI if desired

---

## Quick Reference Commands

```bash
# Installation
cp -r ~/git/CharacterMarkdown ~/Documents/Elder\ Scrolls\ Online/live/AddOns/

# In-game testing
/markdown           # Show export window
/reloadui          # Reload all addons
/luaerror on       # Show LUA errors
/script d(GetAPIVersion())  # Check API version

# Development
git status         # Check changes
git add .          # Stage changes
git commit -m "..."  # Commit changes
/reloadui          # Test in-game
```

---

**Version:** 1.0.0  
**Last Updated:** 2024-10-14  
**Platform:** ESO PC (Mac/Windows/Linux)  
**API Version:** 101043, 101044
