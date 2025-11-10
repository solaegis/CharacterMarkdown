# Champion Points System - Flow Overview

## Current Architecture

### Data Flow
```
Markdown.lua (GenerateMarkdown)
  ↓
  CollectChampionPointData() [Progression.lua]
  ↓
  Returns: cpData structure
  ↓
  GenerateChampionPoints(cpData, format) [ChampionPoints.lua]
  ↓
  Returns: Markdown string
```

## Data Collection (`src/collectors/Progression.lua`)

### Main Function: `CollectChampionPointData()`

**Returns structure:**
```lua
{
  total = 0,              -- Total CP earned
  spent = 0,              -- Total CP spent across all disciplines
  available = 0,         -- Unspent CP (can be nil if API fails)
  disciplines = {},      -- Array of discipline data
  analysis = {
    slottableSkills = 0,
    passiveSkills = 0,
    maxSlottablePerDiscipline = 0,
    investmentLevel = "low"
  }
}
```

### Collection Process

1. **Get Total CP** (line 99)
   - `GetPlayerChampionPointsEarned()` - Total CP ever earned

2. **Get Available CP** (lines 103-108)
   - `GetUnitChampionPoints("player")` - Unspent CP
   - Uses `pcall` to distinguish between "returned 0" vs "API failed"
   - Can be `nil` if API fails (will calculate later)

3. **Early Return** (lines 110-112)
   - If `total < 10`, return basic structure (CP system not unlocked)

4. **Determine Slottable Limits** (lines 114-120)
   - 4 slottable per discipline at 900+ CP
   - 3 slottable per discipline below 900 CP

5. **Collect Discipline Data** (lines 122-459) - **WRAPPED IN PCALL**
   - Iterates through disciplines (Craft, Warfare, Fitness)
   - For each discipline:
     - Gets discipline ID, name, emoji
     - Gets discipline type constant (for API calls)
     - Gets total spent points in discipline (tries multiple API methods)
     - **PROBLEM AREA**: Gets `maxAllocated` (lines 154-221)
       - Tries `GetChampionPointsInDiscipline(disciplineTypeConstant)`
       - Complex logic to determine if API returns "maximum possible" vs "current allocated"
       - This is where the confusion lies - the API behavior is unclear
     - Iterates through all skills in discipline
     - Categorizes skills as slottable vs passive (hardcoded mapping)
     - Calculates discipline total from sum of skill points

6. **Ensure All 3 Disciplines** (lines 377-438)
   - Adds missing disciplines with 0 points
   - Collects all stars (including 0 points) for constellation table

7. **Calculate Totals** (lines 461-503)
   - Calculates `spent` from discipline totals
   - Validates `available + spent = total` (within 1 point tolerance)
   - Recalculates if mismatch detected

8. **Fallback Handling** (lines 504-553)
   - If main collection fails, tries alternative methods
   - Gets spent points per discipline without skill details

### Key Issues in Collection

1. **`maxAllocated` Confusion** (lines 154-221)
   - Code comments indicate uncertainty about what `GetChampionPointsInDiscipline()` returns
   - Tries to distinguish between:
     - Maximum possible CP for discipline (theoretical max = total CP / 3)
     - Current allocated CP (spent + unassigned)
   - Logic is complex and may be incorrect

2. **Multiple API Methods** (lines 64-79)
   - `GetDisciplineSpentPoints()` tries 4 different API methods
   - Returns first success, which may not be the correct value

3. **Fallback Calculations** (lines 481-497)
   - Multiple fallback paths for calculating `available` and `spent`
   - May mask underlying API issues

## Data Generation (`src/generators/sections/ChampionPoints.lua`)

### Main Function: `GenerateChampionPoints(cpData, format)`

**Process:**

1. **Initialize Utilities** (line 471)
   - Lazy loads helper functions

2. **Handle Nil Data** (lines 476-479)
   - Creates empty structure if `cpData` is nil

3. **Generate Header** (lines 485-489)
   - Always generates section header

4. **Early Return** (lines 492-498)
   - If `total < 10`, shows unlock message

5. **Calculate Values** (lines 500-502)
   - `spentCP = cpData.spent or 0`
   - `availableCP = cpData.available or (totalCP - spentCP)`

6. **Format Output** (lines 504-630)
   - **Discord format**: Simple text list
   - **Markdown format**: Table + discipline breakdowns
   - For each discipline:
     - Calculates `maxPerDiscipline` (lines 537-568)
       - Uses `discipline.maxAllocated` if available
       - Falls back to calculated value based on total CP
       - **CRITICAL**: Ensures max >= spent (line 564)
     - Generates progress bar
     - Lists all skills with points

### Key Issues in Generation

1. **`maxPerDiscipline` Calculation** (lines 537-568)
   - Complex fallback logic
   - May use incorrect `maxAllocated` from collector
   - Has safety check to ensure max >= spent, but this masks the root issue

2. **Available CP Breakdown** (function `GetAvailableCPBreakdown`, lines 91-270)
   - Tries to calculate unassigned CP per discipline
   - Complex logic trying to interpret `maxAllocated`
   - May produce incorrect results if `maxAllocated` is wrong

## ESO CP 3.0 System Understanding

### How CP 3.0 Works

1. **Total CP**: Earned through gameplay (max 3600+)
2. **Three Disciplines**: Craft, Warfare, Fitness
3. **Allocation**:
   - Each discipline can have up to 660 CP (or total CP / 3, whichever is lower)
   - CP can be allocated to disciplines (spent) or left unassigned
   - Unassigned CP can be distributed to any discipline
4. **Skills**:
   - Each discipline has multiple "stars" (skills)
   - Skills can be slottable (active) or passive
   - Points are spent on individual skills

### What the API Should Return

**Expected behavior:**
- `GetPlayerChampionPointsEarned()`: Total CP earned
- `GetUnitChampionPoints("player")`: Unspent CP (not allocated to any discipline)
- `GetChampionPointsInDiscipline(type)`: **CURRENT ALLOCATED** (spent + unassigned in that discipline)
- `GetNumSpentChampionPoints(type)`: **SPENT** points in discipline
- Unassigned = Allocated - Spent

**The Problem:**
- Code comments suggest `GetChampionPointsInDiscipline()` might return "maximum possible" instead of "current allocated"
- This would break the calculation of unassigned points per discipline

## Recommended Refactoring Approach

### 1. Simplify Data Collection

**Remove complex `maxAllocated` logic:**
- Don't try to interpret what `GetChampionPointsInDiscipline()` returns
- Instead, calculate unassigned per discipline from:
  - Total available CP (from `GetUnitChampionPoints`)
  - Spent per discipline (from `GetNumSpentChampionPoints`)
  - Distribute available CP proportionally or equally

### 2. Clear Separation of Concerns

**Collector should only collect:**
- Total CP
- Available CP (unspent)
- Spent per discipline
- Skills with points
- Don't try to calculate "max allocated" or "unassigned per discipline"

**Generator should calculate:**
- Max per discipline (simple: total CP / 3, capped at 660)
- Unassigned per discipline (from available CP distribution)
- Progress percentages

### 3. Fix Available CP Distribution

**Simple approach:**
- If user has unassigned CP, distribute equally across disciplines
- Or distribute proportionally to spent points
- Don't rely on `maxAllocated` from API

### 4. Remove Fallback Complexity

**Simplify:**
- Use primary API methods
- If they fail, return clear error state
- Don't try multiple fallback methods that may return incorrect data

## Current Output Issues

Based on the code complexity, likely issues:

1. **Incorrect `maxAllocated` values**
   - May show wrong progress percentages
   - May show wrong "available per discipline" breakdown

2. **Incorrect unassigned CP distribution**
   - `GetAvailableCPBreakdown()` may calculate wrong values
   - Based on incorrect interpretation of `maxAllocated`

3. **Inconsistent totals**
   - Multiple fallback calculations may produce inconsistent results
   - `available + spent` may not equal `total`

## Next Steps

1. **Test current output** - Identify specific incorrect values
2. **Simplify collector** - Remove `maxAllocated` interpretation logic
3. **Fix generator** - Calculate max/unassigned from simple formulas
4. **Test again** - Verify output matches expected values

