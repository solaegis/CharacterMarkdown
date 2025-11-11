
# Testing Notes

## Quest Section Issue - DEBUGGING

### Problem
The Quest section was not generating any markdown output.

### Root Causes Found
1. **Incorrect ESO API call** - Fixed (GetString issue)
2. **Missing FormatNumber utility** - Fixed (utility loading)

### Latest Changes (2025-01-11)
Added better error messages and logging to diagnose the issue:

1. **Changed DebugPrint to Info** - All quest logs now always appear in chat
2. **Added visible error messages** - If quest generation fails, you'll see:
   - "Error: Quest utilities not available"
   - "Error: Quest data not collected"  
   - "Error: Quest summary missing"
   - "No active quests" (if you have no quests)

3. **Enhanced logging** - The quest collector and generator now log every step:
   - Collector logs: Number of quests found, processing status for each quest
   - Generator logs: Data structure checks, section generation progress

### Testing Instructions

1. **Install the addon:**
   ```bash
   task install:live
   ```

2. **Launch ESO and `/reloadui`**

3. **Run the command:**
   ```
   /markdown github
   ```

4. **Check the output window** - You should see one of:
   - Quest section with data (if you have active quests)
   - "## 📝 Quests\n\n*No active quests*" (if you have no quests)
   - "## 📝 Quests\n\n*Error: ...*" (if something is wrong)

5. **Check your chat window** - Look for these log messages:
   ```
   [CharacterMarkdown] ===== QUEST COLLECTOR STARTING =====
   [CharacterMarkdown] GetNumJournalQuests() returned: X
   [CharacterMarkdown] === GenerateQuests called ===
   [CharacterMarkdown] questData exists, checking structure...
   ```

### What to Look For

If the quest section is STILL empty or missing:
1. Check if `includeQuests` is enabled in settings (`/cmdsettings`)
2. Check chat for error messages
3. Share the log output from chat window

### Possible Causes
- Setting disabled: `includeQuests = false` in saved settings
- No active quests: GetNumJournalQuests() returns 0
- Collector failure: Check logs for errors

---

## Test Output (Before Fix)

<div align="center">

# Pelatiah (Emissary)

![Level](<https://img.shields.io/badge/Level-50-blue?style=flat>) ![CP](<https://img.shields.io/badge/CP-733-purple?style=flat>) ![Class](<https://img.shields.io/badge/Class-Templar-green?style=flat>) ![ESO+](<https://img.shields.io/badge/ESO+-Active-gold?style=flat>)

**Imperial Templar • Ebonheart Pact Alliance**


</div>

---

---

<div align="center">

![Format](<https://img.shields.io/badge/Format-GITHUB-blue?style=flat>) ![Size](<https://img.shields.io/badge/Size-380%20chars-purple?style=flat>)

**⚔️ CharacterMarkdown**

<sub>Generated on 11/10/2025</sub>

</div>
