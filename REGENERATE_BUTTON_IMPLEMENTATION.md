# Regenerate Button Implementation Summary

## Overview
Added a "Regenerate" button to the CharacterMarkdown export window and removed the duplicate character overview header that was appearing above the Character Overview table.

## Changes Made

### 1. Removed Duplicate Header Block (`src/generators/Markdown.lua`)

**Problem:** 
For GitHub and VSCode formats, the markdown output included a duplicate character overview block:
```markdown
**Imperial Dragonknight**  
**Level 50** • **CP 627**  
*Ebonheart Pact*

---

## 📊 Character Overview
[Character overview table with all the same information]
```

**Solution:**
Modified the `GenerateHeader()` function to only output the character name as the main header for non-Discord formats. The detailed character information (race, class, level, CP, alliance) is now only displayed in the Character Overview table, eliminating the redundancy.

**Code Change:**
```lua
-- GitHub/VSCode: Just character name as main header
-- (The detailed overview is now fully contained in the Character Overview table)
markdown = markdown .. "# " .. (characterData.name or "Unknown") .. "\n\n"
```

### 2. Added Regenerate Button (`CharacterMarkdown.xml`)

**Added New Button:**
- Button positioned at far left of button row
- Calls `CharacterMarkdown_RegenerateMarkdown()` function
- Uses standard ESO button styling

**Button Layout (left to right):**
1. **Regenerate** (`offsetX="-240"`) - NEW
2. **Select All** (`offsetX="-80"`) - repositioned
3. **Dismiss** (`offsetX="80"`) - repositioned
4. **ReloadUI** (`offsetX="240"`) - repositioned

**XML Structure:**
```xml
<!-- Regenerate Button -->
<Button name="$(parent)RegenerateButton" inherits="ZO_DefaultButton">
    <Dimensions x="150" y="30" />
    <Anchor point="CENTER" offsetX="-240" />
    <OnClicked>
        CharacterMarkdown_RegenerateMarkdown()
    </OnClicked>
    <Controls>
        <Label name="$(parent)Label" font="ZoFontGame" text="Regenerate" color="FFFFFFFF">
            <Anchor point="CENTER" />
        </Label>
    </Controls>
</Button>
```

### 3. Implemented Regenerate Functionality (`src/ui/Window.lua`)

**New Functions:**

#### `CharacterMarkdown_RegenerateMarkdown()`
Handles the regeneration of markdown content when the user clicks the Regenerate button.

**Behavior:**
1. Clears the current window content
2. Regenerates markdown using the same format as was originally displayed
3. Updates the EditBox with new content
4. Automatically selects all text
5. Maintains window focus

**Key Features:**
- Error handling with pcall for safe execution
- Uses stored `CM.currentFormat` to regenerate with same format
- Provides user feedback via debug messages
- Automatically selects text after regeneration for easy copying

**Code Implementation:**
```lua
function CharacterMarkdown_RegenerateMarkdown()
    if not CM or not CM.generators or not CM.generators.GenerateMarkdown then
        d("[CharacterMarkdown] ❌ ERROR: Generator not available")
        return
    end
    
    d("[CharacterMarkdown] 🔄 Regenerating markdown...")
    
    -- Get current format (default to github if not stored)
    local format = CM.currentFormat or "github"
    
    -- Clear the window
    if editBoxControl then
        editBoxControl:SetText("")
    end
    
    -- Regenerate markdown
    local success, markdown = pcall(CM.generators.GenerateMarkdown, format)
    
    if not success then
        d("[CharacterMarkdown] ❌ ERROR: Failed to regenerate markdown")
        d("[CharacterMarkdown] Error: " .. tostring(markdown))
        return
    end
    
    if not markdown or markdown == "" then
        d("[CharacterMarkdown] ❌ ERROR: Generated markdown is empty")
        return
    end
    
    -- Update stored markdown
    currentMarkdown = markdown
    
    -- Update the EditBox
    editBoxControl:SetEditEnabled(true)
    editBoxControl:SetText(markdown)
    editBoxControl:SetColor(1, 1, 1, 1)
    editBoxControl:SetEditEnabled(false)
    
    -- Select all text and take focus
    zo_callLater(function()
        editBoxControl:SelectAll()
        editBoxControl:TakeFocus()
        
        local markdownLength = string.len(markdown)
        d("[CharacterMarkdown] ✅ Regenerated " .. markdownLength .. " characters")
        d("[CharacterMarkdown] ✅ Text selected and ready to copy")
    end, 100)
end
```

#### Modified `CharacterMarkdown_ShowWindow()`
Added storage of the current format for use during regeneration.

**New Code:**
```lua
-- Store current format for regeneration
CM.currentFormat = format
```

## Usage

### User Workflow:
1. Open the CharacterMarkdown window with `/markdown` command
2. Click **"Regenerate"** button to refresh the markdown with latest character data
3. Click **"Select All"** to select the text
4. Press **Ctrl+C** (or Cmd+C on Mac) to copy
5. Paste into desired location

### When to Use Regenerate:
- After making changes to character (equipment, skills, CP allocation, etc.)
- After changing addon settings
- To refresh data without closing and reopening the window
- To see updated stats after buffs/food expire or are applied

## Technical Details

### Format Preservation:
The regenerate function preserves the original format (GitHub, VSCode, Discord, or Quick) that was used when the window was initially opened.

### Error Handling:
- Validates that the generator is available before attempting regeneration
- Uses `pcall` to catch and report any errors during generation
- Checks that generated markdown is not empty before updating display
- Provides clear error messages via debug output

### User Experience:
- Text is automatically cleared before regeneration (provides visual feedback)
- Text is automatically selected after regeneration (ready to copy)
- Focus remains on the EditBox (no need to click back into window)
- Debug messages provide clear feedback about the regeneration process

## Testing Checklist

- [ ] Regenerate button appears in correct position (far left)
- [ ] Button click regenerates markdown successfully
- [ ] Text is cleared before regeneration
- [ ] New markdown appears in window
- [ ] Text is automatically selected after regeneration
- [ ] Window maintains focus
- [ ] Same format is used as original (test with github, discord, vscode)
- [ ] Error handling works if generation fails
- [ ] Duplicate header block is removed from output
- [ ] Character Overview table still contains all necessary information

## Files Modified

1. `/src/generators/Markdown.lua` - Removed duplicate header block
2. `/CharacterMarkdown.xml` - Added Regenerate button and repositioned existing buttons
3. `/src/ui/Window.lua` - Implemented regenerate functionality and format storage

## Version Compatibility

- Requires ESO API version 101045 or higher
- Compatible with all existing CharacterMarkdown features
- No breaking changes to existing functionality

---

**Implementation Date:** 2025-01-19  
**Version:** 2.1.0+  
**Status:** ✅ Complete
