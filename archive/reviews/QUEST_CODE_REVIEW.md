# Quest Section Code Review

## Overview
Comprehensive code review of `src/collectors/Quests.lua` and `src/generators/sections/Quests.lua`

---

## 🔴 Critical Issues

### 1. **Performance: Redundant API Calls in Specialized Collectors**
**File:** `src/collectors/Quests.lua` (Lines 264-478)

**Issue:** The specialized collectors (`CollectMainStoryQuests`, `CollectGuildQuests`, `CollectDailyQuests`) all call `GetNumJournalQuests()` and iterate through ALL quests again, repeating work already done in `CollectQuestData()`.

```lua
-- This is called 4 times (once per collector):
local numQuests = GetNumJournalQuests() or 0
for i = 1, numQuests do
    local success, questName, ... = pcall(GetJournalQuestInfo, i)
    -- Process quest...
end
```

**Impact:** 4x the API calls and processing time

**Recommendation:** 
- Remove specialized collectors entirely OR
- Have specialized collectors filter the data already collected by `CollectQuestData()`
- Main collector should be the single source of truth

---

### 2. **GetQuestProgress: Redundant API Call**
**File:** `src/collectors/Quests.lua` (Lines 107-129)

**Issue:** `GetQuestProgress()` calls `GetJournalQuestInfo()` again even though it was already called in the main loop.

```lua
-- Called in main loop:
local success, questName, backgroundText, activeStepText, ... = pcall(GetJournalQuestInfo, i)

-- Then immediately called again in GetQuestProgress:
local success, questName, backgroundText, activeStepText, ... = pcall(GetJournalQuestInfo, questIndex)
```

**Impact:** Doubles the API calls

**Recommendation:** Pass the already-fetched quest data as parameters instead of refetching

---

### 3. **Division by Zero Risk**
**File:** `src/generators/sections/Quests.lua` (Line 281)

**Issue:** Potential division by zero if `mainStoryData.total` is 0

```lua
markdown = markdown .. "| **Progress** | " .. CM.utils.GenerateProgressBar(math.floor((mainStoryData.active / mainStoryData.total) * 100), 12) .. " |\n"
```

**Recommendation:** Add zero check:
```lua
local progress = mainStoryData.total > 0 and math.floor((mainStoryData.active / mainStoryData.total) * 100) or 0
markdown = markdown .. "| **Progress** | " .. CM.utils.GenerateProgressBar(progress, 12) .. " |\n"
```

---

## 🟡 Major Issues

### 4. **GetQuestZone: Misleading Placeholder**
**File:** `src/collectors/Quests.lua` (Lines 131-135)

**Issue:** Always returns "Current Zone" which is not accurate and adds no value

```lua
local function GetQuestZone(questIndex)
    return "Current Zone"
end
```

**Impact:** Zone breakdown section shows meaningless data

**Recommendation:** Either implement proper zone detection using `GetJournalQuestLocationInfo()` or return `nil` and handle gracefully in the generator

---

### 5. **Code Duplication in Specialized Collectors**
**File:** `src/collectors/Quests.lua` (Lines 264-478)

**Issue:** 200+ lines of duplicated quest iteration code across 3 functions

**Recommendation:** Refactor to use a filter pattern:
```lua
local function FilterQuestsByCategory(allQuests, targetCategory)
    local filtered = {}
    for _, quest in ipairs(allQuests) do
        if quest.category == targetCategory then
            table.insert(filtered, quest)
        end
    end
    return filtered
end
```

---

### 6. **Performance: String Concatenation Instead of table.concat**
**File:** `src/generators/sections/Quests.lua` (Multiple locations)

**Issue:** Uses `markdown = markdown .. string` which creates new strings on each concatenation

**Impact:** Poor performance with large quest lists

**Recommendation:** Use table.concat pattern:
```lua
local parts = {}
table.insert(parts, "## 📝 Quest Progress\n\n")
-- ... more inserts ...
return table.concat(parts)
```

---

### 7. **Inconsistent Error Handling**
**File:** `src/collectors/Quests.lua`

**Issue:** Uses both `pcall()` directly and should use `CM.SafeCall()` per project standards

**Current:**
```lua
local success, questName, ... = pcall(GetJournalQuestInfo, i)
```

**Should be:**
```lua
local questName = CM.SafeCall(GetJournalQuestInfo, i)
```

**Note:** As per cursor rules, `CM.SafeCall()` only returns first value. If multiple return values needed, `pcall` is correct. This is actually being used correctly, but the comment in the code doesn't explain why `pcall` is necessary here.

---

## 🟢 Minor Issues

### 8. **Missing Sort for Deterministic Output**
**File:** `src/generators/sections/Quests.lua` (Lines 143, 153, 239, 248, 304, 313, 342, 351)

**Issue:** Iterating over `pairs()` produces random order for categories and zones

```lua
for categoryName, categoryData in pairs(categories) do
```

**Recommendation:** Sort keys before iteration for consistent output:
```lua
local categoryNames = {}
for name, _ in pairs(categories) do
    table.insert(categoryNames, name)
end
table.sort(categoryNames)

for _, categoryName in ipairs(categoryNames) do
    local categoryData = categories[categoryName]
    -- ...
end
```

---

### 9. **InitializeUtilities: Redundant Calls**
**File:** `src/generators/sections/Quests.lua` (Lines 88, 128, 173, 224)

**Issue:** `InitializeUtilities()` is called at the start of every helper function

**Recommendation:** Call once at module load time or at the start of `GenerateQuests()` only

---

### 10. **Category Keyword Conflicts**
**File:** `src/collectors/Quests.lua` (Lines 34, 27, 34)

**Issue:** Keywords overlap between categories:
- "Thieves" appears in both "Guild Quests" and "DLC Quests"
- "Dark Brotherhood" appears in both "Guild Quests" and "DLC Quests"

**Impact:** First match wins, which may not be the most appropriate category

**Recommendation:** Use priority-based matching or more specific keywords

---

### 11. **Missing Validation: GenerateProgressBar**
**File:** `src/generators/sections/Quests.lua` (Line 281)

**Issue:** Assumes `CM.utils.GenerateProgressBar` exists without checking

**Recommendation:** Add validation:
```lua
if CM.utils.GenerateProgressBar then
    markdown = markdown .. "| **Progress** | " .. CM.utils.GenerateProgressBar(progress, 12) .. " |\n"
else
    markdown = markdown .. "| **Progress** | " .. progress .. "% |\n"
end
```

---

### 12. **Confusing Logic: isActive Flag**
**File:** `src/collectors/Quests.lua` (Line 216)

**Issue:** `isActive = not completed` is confusing naming

```lua
isActive = not completed,
isCompleted = completed or false,
```

**Recommendation:** Be more explicit:
```lua
isActive = not (completed or false),
isCompleted = completed == true,
```

---

### 13. **Missing Section Separators**
**File:** `src/generators/sections/Quests.lua`

**Issue:** No `---` separators between subsections like other sections use

**Recommendation:** Add separators for consistency:
```lua
markdown = markdown .. "\n---\n\n"
```

---

### 14. **Guild Detection: String Matching Limitations**
**File:** `src/collectors/Quests.lua` (Lines 355-365)

**Issue:** Simple string matching could have false positives:
- A quest with "Brotherhood" in name would match Dark Brotherhood
- A quest with "fighter" would match Fighters Guild

**Recommendation:** Use more specific patterns or ESO's quest metadata if available

---

### 15. **Unused Function Return Values**
**File:** `src/collectors/Quests.lua` (Lines 192-193)

**Issue:** `GetJournalQuestInfo` returns many values that are collected but never used:
- `backgroundText`
- `activeStepTrackerOverrideText`
- `pushed`
- `questType`
- `instanceDisplayType`

**Recommendation:** Only capture needed values for clarity:
```lua
local success, questName, _, activeStepText, _, _, completed, tracked, questLevel = pcall(GetJournalQuestInfo, i)
```

---

### 16. **Missing Performance Optimization: Cached Lookups**
**File:** `src/collectors/Quests.lua`

**Issue:** Multiple `string.lower()` calls and string operations not cached

**Recommendation:** Cache at module level:
```lua
local string_lower = string.lower
local string_find = string.find
```

---

### 17. **Excessive Logging in Production**
**File:** Both files

**Issue:** Very verbose logging using `CM.Info()` which always displays

**Impact:** Spam in chat window during normal use

**Recommendation:** 
- Use `CM.DebugPrint()` for development/debugging logs
- Use `CM.Info()` only for important user-facing messages
- The recent change to use `CM.Info()` everywhere should be reverted once debugging is complete

---

## 🔵 Code Quality Issues

### 18. **Magic Numbers**
**File:** `src/generators/sections/Quests.lua` (Line 281)

**Issue:** Magic number `12` for progress bar width

**Recommendation:** Define as constant:
```lua
local PROGRESS_BAR_WIDTH = 12
```

---

### 19. **Inconsistent Nil Checks**
**File:** `src/generators/sections/Quests.lua`

**Issue:** Some functions check for nil, others assume data exists

**Recommendation:** Consistent validation at function boundaries

---

### 20. **Comment Clarity**
**File:** `src/collectors/Quests.lua` (Lines 249-250)

**Issue:** Comment states completed quests "not easily accessible" but doesn't explain why

**Recommendation:** Expand comment to explain ESO API limitations

---

## 📊 Summary

| Severity | Count | Must Fix |
|----------|-------|----------|
| 🔴 Critical | 3 | Yes |
| 🟡 Major | 7 | Recommended |
| 🟢 Minor | 10 | Optional |
| 🔵 Quality | 3 | Optional |

---

## ✅ Recommended Action Plan

### Phase 1: Critical Fixes (Do immediately)
1. Fix division by zero in GenerateMainStoryQuests
2. Remove specialized collectors or refactor to filter existing data
3. Fix GetQuestProgress to not re-fetch quest data

### Phase 2: Major Improvements (Do soon)
1. Implement proper zone detection or remove misleading "Current Zone"
2. Add table.concat for string building
3. Add sorting for deterministic output
4. Add proper nil checks and validation

### Phase 3: Polish (Do when time permits)
1. Reduce logging verbosity (revert CM.Info back to CM.DebugPrint)
2. Add section separators
3. Cache string functions
4. Define magic numbers as constants

---

## 💡 Positive Aspects

1. ✅ Good error handling with visible error messages
2. ✅ Clear section organization and comments
3. ✅ Comprehensive category system
4. ✅ Proper exports and module structure
5. ✅ Good use of helper functions for formatting
6. ✅ Consistent emoji usage across sections

---

Generated: 2025-01-11
Reviewed Files: 
- `src/collectors/Quests.lua` (495 lines)
- `src/generators/sections/Quests.lua` (466 lines)

