# Chunking & Padding Code Review
*Complete analysis of CharacterMarkdown chunking implementation*

**Review Date:** November 13, 2025  
**Reviewer:** AI Code Review  
**Scope:** `src/utils/Chunking.lua` and `src/utils/Constants.lua`

---

## Executive Summary

### Current Status: ⚠️ **CRITICAL ISSUES IDENTIFIED**

The chunking algorithm has **multiple critical bugs** that cause it to produce oversized chunks (4x+ the limit). While recent fixes addressed some issues, the algorithm has **fundamental architectural problems** that make it unreliable.

### Key Findings

1. ✅ **FIXED**: Padding can now be disabled via `DISABLE_PADDING` flag
2. ✅ **FIXED**: `isLastChunk` recalculation bug
3. ✅ **FIXED**: Loop exit logic for oversized chunks
4. ❌ **CRITICAL**: Missing size validation after backtracking operations
5. ❌ **CRITICAL**: Inconsistent enforcement of `maxSafeDataSize`
6. ❌ **MAJOR**: Debug logging claims to add padding even when disabled
7. ⚠️ **WARNING**: Complex control flow makes it difficult to verify correctness

---

## 1. Constants Configuration

### File: `src/utils/Constants.lua`

```lua
CM.constants.CHUNKING = {
    EDITBOX_LIMIT = 6000,      -- Display limit
    COPY_LIMIT = 5700,         -- Copy limit (300 char safety margin)
    MAX_DATA_CHARS = 5700,     -- Maximum data per chunk
    DISABLE_PADDING = true,    -- TEST FLAG
    SPACE_PADDING_SIZE = 85,   -- Spaces to add when padding enabled
    -- ... other padding constants
}
```

### ✅ GOOD

1. **Clear separation of concerns**: Display vs copy limits
2. **Conservative safety margins**: 300-char buffer between display and copy
3. **Feature flag**: `DISABLE_PADDING` allows testing without padding
4. **Well-documented**: Comments explain the rationale

### ⚠️ ISSUES

1. **MAX_DATA_CHARS = COPY_LIMIT**: When padding is disabled, these are equal
   - **Problem**: No buffer for overhead (prepended newlines, etc.)
   - **Recommendation**: `MAX_DATA_CHARS` should be `COPY_LIMIT - 100` minimum

2. **DISABLE_PADDING as test flag**: Should this be a user setting?
   - Currently in constants (requires code change)
   - Consider moving to settings if padding remains problematic

### Recommendation

```lua
MAX_DATA_CHARS = 5600,  -- Leave 100-char buffer for overhead even when padding disabled
```

---

## 2. Padding Logic

### Implementation (Lines 4257-4268)

```lua
-- Add padding only if enabled
if not CHUNKING.DISABLE_PADDING then
    chunkContent = chunkContent:gsub("\n+$", "") .. string.rep(" ", spacePaddingSize) .. "\n\n"
    finalSize = finalSize + paddingSize
else
    -- When padding is disabled, just normalize trailing newlines to exactly 1 newline
    chunkContent = chunkContent:gsub("\n+$", "\n")
    -- No size adjustment needed since we're just normalizing existing newlines
end
```

### ✅ GOOD

1. **Conditional application**: Padding only added when flag is enabled
2. **Newline normalization**: Always ensures consistent trailing newlines
3. **Size accounting**: Correctly updates `finalSize` when padding is added

### ❌ CRITICAL ISSUE: Misleading Debug Log

**Line 4269-4277:**
```lua
CM.DebugPrint(
    "CHUNKING",
    string.format(
        "Chunk %d: Added %d space padding to last line + newline (isLast: %s)",
        chunkNum,
        paddingSize,  -- ← WRONG: paddingSize is 0 when disabled!
        tostring(isLastChunk)
    )
)
```

**Problem**: This debug message ALWAYS says "Added X space padding" even when `paddingSize = 0` and no padding was added!

**Impact**: 
- Makes debugging impossible (logs claim padding was added when it wasn't)
- Led to user confusion ("I thought we disabled padding")

**Fix Required:**
```lua
if not CHUNKING.DISABLE_PADDING then
    CM.DebugPrint(
        "CHUNKING",
        string.format(
            "Chunk %d: Added %d space padding + 2 newlines (total: %d bytes, isLast: %s)",
            chunkNum,
            spacePaddingSize,
            paddingSize,
            tostring(isLastChunk)
        )
    )
else
    CM.DebugPrint(
        "CHUNKING",
        string.format(
            "Chunk %d: Padding disabled - normalized trailing newlines (isLast: %s)",
            chunkNum,
            tostring(isLastChunk)
        )
    )
end
```

### StripPadding Function (Lines 976-1003)

```lua
local function StripPadding(content, isLastChunk)
    if not content or content == "" then
        return content
    end
    
    local CHUNKING = CM.constants.CHUNKING
    local paddingSize = 0
    if not CHUNKING.DISABLE_PADDING then
        paddingSize = (CHUNKING and CHUNKING.SPACE_PADDING_SIZE) or 85
    end
    
    local paddingPattern = ""
    if paddingSize > 0 then
        paddingPattern = string.rep(" ", paddingSize) .. "\n\n"
    end
    
    if string.sub(content, -(paddingSize + 2), -1) == paddingPattern then
        return string.sub(content, 1, -(paddingSize + 2)) .. "\n"
    end
    
    return content
end
```

### ✅ GOOD

1. **Conditional behavior**: Only strips padding if it was enabled
2. **Safe fallback**: Returns content unchanged if no padding found

### ⚠️ MINOR ISSUE

**Line 996:** `string.sub(content, -(paddingSize + 2), -1)`
- When `paddingSize = 0`, this becomes `string.sub(content, -2, -1)` (checks last 2 chars)
- Compares against `paddingPattern = ""` (empty string)
- Will never match, but wastes a string operation

**Recommendation**: Add early return when padding disabled
```lua
if CHUNKING.DISABLE_PADDING or paddingSize == 0 then
    return content  -- No stripping needed
end
```

---

## 3. Main Chunking Algorithm

### Structure Overview

```
SplitMarkdownIntoChunks(markdown)
├── Initialize limits and padding size (ONCE)
├── Early return if markdown fits in one chunk
└── Main loop: while pos <= markdownLength
    ├── Calculate chunk boundaries
    ├── Find safe break point (tables, lists, links, headers)
    ├── Validate chunk size (SHOULD enforce maxSafeDataSize)
    ├── Apply padding if enabled
    └── Advance position or exit
```

### ✅ GOOD: Single Padding Calculation

**Lines 1022-1028:**
```lua
-- Calculate padding size once (conditional based on DISABLE_PADDING flag)
local paddingSize = 0  -- Default: no padding
if not CHUNKING.DISABLE_PADDING then
    paddingSize = (CHUNKING.SPACE_PADDING_SIZE or 85) + 2 -- spaces + 2 newlines
end
```

This is **excellent** - padding size is calculated once and reused throughout the function.

### ❌ CRITICAL ISSUE #1: No Buffer for Overhead

**Problem**: `MAX_DATA_CHARS = 5700` and `COPY_LIMIT = 5700` when padding disabled
- Algorithm prepends `"\n"` to chunks after the first (line 3780)
- No buffer reserved for this overhead!
- Chunks can exceed copy limit even without padding

**Example**:
```
Chunk 1: 5700 bytes (no prepended newline) ✅ OK
Chunk 2: "\n" + 5700 bytes = 5701 bytes ❌ EXCEEDS LIMIT
```

**Fix Required**: Lower `MAX_DATA_CHARS` to account for overhead
```lua
MAX_DATA_CHARS = 5600,  -- Reserve 100 bytes for prepended newlines and other overhead
```

---

## 4. Size Validation Issues

### ❌ CRITICAL ISSUE #2: Backtracking Without Size Checks

The algorithm performs **multiple backtracking operations** that adjust `chunkEnd` without verifying the new size is safe.

#### Example 1: Header-Before-Table Backtracking (Lines 4213-4255)

```lua
if IsHeaderBeforeTable(markdown, chunkEnd, markdownLength) then
    -- Find header start
    local headerLineStart = chunkEnd
    for i = chunkEnd - 1, math.max(pos, chunkEnd - 1000), -1 do
        if i == pos or string.sub(markdown, i - 1, i - 1) == "\n" then
            headerLineStart = (i == pos) and pos or i
            break
        end
    end
    
    if headerLineStart > pos then
        local newChunkEnd = headerLineStart - 1
        -- ❌ NO SIZE CHECK HERE!
        chunkEnd = newChunkEnd
        chunkData = string.sub(markdown, pos, chunkEnd)
        dataChars = string.len(chunkData)
        -- ... updates continue ...
    end
end
```

**Problem**: After backtracking to before the header, the chunk size is never validated!
- `chunkData` could now be smaller than minimum viable chunk size
- `chunkData` could theoretically exceed limits if the backtracking logic is wrong
- No validation that `dataChars + paddingSize <= COPY_LIMIT`

#### Example 2: Table Extension (Lines 1272-1285)

```lua
if tableChunkSize <= effectiveMaxForStructures then
    // Can include the table (and header) - extend to table end
    chunkEnd = tableEnd  // ❌ NO FINAL SIZE CHECK!
    foundNewline = true
    CM.DebugPrint(...)
end
```

**Problem**: Extends chunk to include full table but:
1. Never validates that `(tableEnd - pos + 1) + paddingSize <= COPY_LIMIT`
2. Uses `effectiveMaxForStructures` (with overage allowance) instead of strict limit
3. Could produce chunks larger than `COPY_LIMIT`

### ValidateChunkSizeAfterBacktrack Function (Lines 1062-1077)

```lua
local function ValidateChunkSizeAfterBacktrack(newEnd)
    if newEnd < pos then
        return false
    end
    local dataSize = newEnd - pos + 1
    local totalSize = dataSize + paddingSize
    
    if isLastChunk then
        return dataSize > 0 and totalSize <= copyLimit
    else
        return totalSize <= copyLimit and dataSize >= 100
    end
end
```

### ✅ GOOD

1. **Checks both minimum and maximum**: `dataSize >= 100` and `totalSize <= copyLimit`
2. **Accounts for padding**: Uses `totalSize = dataSize + paddingSize`
3. **Different logic for last chunk**: More lenient for final chunk

### ❌ CRITICAL ISSUE #3: Function Not Called Everywhere

**Problem**: `ValidateChunkSizeAfterBacktrack` is only called in ONE place (line 1371)!

**Locations that backtrack WITHOUT validation:**
1. **Lines 1272-1285**: Table extension
2. **Lines 1289-1305**: Backtrack before header+table
3. **Lines 4213-4255**: Header-before-table backtracking at end of chunk

**Impact**: These operations can produce chunks that:
- Exceed copy limit (causing 26k+ char chunks)
- Are too small (causing excessive fragmentation)

**Fix Required**: Call `ValidateChunkSizeAfterBacktrack` after EVERY operation that modifies `chunkEnd`

---

## 5. Size Calculation Inconsistencies

### Multiple Max Size Variables

The algorithm uses **THREE different max size calculations**:

1. **`maxSafeDataSize`** (Line 1050):
   ```lua
   local maxSafeDataSize = copyLimit - paddingSize  -- 5700 - 0 = 5700 (padding disabled)
   ```

2. **`effectiveMaxData`** (Line 1051):
   ```lua
   local effectiveMaxData = math.min(maxDataChars, maxSafeDataSize)  -- min(5700, 5700) = 5700
   ```

3. **`effectiveMaxForStructures`** (Lines 1208, 1219, 1270):
   ```lua
   local structureOverageAllowance = 1500  -- or 2000 for tables
   local effectiveMaxForStructures = maxSafeDataSize + structureOverageAllowance  -- 7200
   ```

### ❌ CRITICAL ISSUE #4: Overage Allowance Bypasses Limits

**Problem**: `effectiveMaxForStructures` allows chunks up to **7200 bytes** (with 2000 byte overage)
- This is **1500 bytes OVER the COPY_LIMIT of 5700**!
- When padding is disabled, this creates chunks that **exceed ESO's copy limit**

**Example**:
```lua
// Lines 1208-1213
if chunkWithStructure > effectiveMaxForStructures + 500 then  // > 7700 bytes
    foundUpcomingStructure = true
    structureStartPos = checkPos
end
```

This means a chunk up to **7699 bytes** would be considered acceptable, which is **35% over the copy limit**!

### Why This Causes 26k+ Char Chunks

1. Algorithm calculates `chunkEnd` can extend to include large structure (~7k)
2. `foundNewline = true` (line 1275) prevents further searching
3. Later size checks see chunk exceeds limit, set `isLastChunk = false` (line 4156)
4. Loop tries to continue from `pos = chunkEnd + 1` (line 4298)
5. But `chunkEnd` is already way past safe boundaries
6. Creates a runaway effect where chunks keep exceeding limits

**Fix Required**: Remove overage allowance entirely or drastically reduce it
```lua
// Option 1: No overage (safest)
local effectiveMaxForStructures = maxSafeDataSize

// Option 2: Small overage only (100-200 bytes for edge cases)
local structureOverageAllowance = 100
local effectiveMaxForStructures = maxSafeDataSize + structureOverageAllowance
```

---

## 6. isLastChunk Logic

### Recent Fixes ✅

1. **Line 3775**: Removed recalculation that was shadowing earlier logic
2. **Line 3932**: Only recalculate if still marked as last chunk
3. **Lines 4295-4306**: Continue loop even if at end when `isLastChunk = false`

### ✅ GOOD

These fixes prevent the algorithm from incorrectly treating oversized chunks as "final" and forcing all remaining content into them.

### ⚠️ REMAINING ISSUE: Complex State Management

`isLastChunk` is modified in **at least 6 different locations**:

1. Line 1046: Initial calculation
2. Line 1058: Recalculation after padding adjustment
3. Line 3932: Conditional recalculation after truncation
4. Line 4122: Set to `false` when remaining content too large
5. Line 4156: Set to `false` when expected size exceeds limit

**Problem**: Very difficult to trace and verify correctness
- Easy to introduce bugs when modifying chunking logic
- Multiple exit conditions make it hard to reason about loop termination

**Recommendation**: Consider refactoring to make state management clearer

---

## 7. Debug Logging Issues

### ❌ ISSUE #1: Misleading Padding Message

Already covered in Section 2 - line 4269 always says padding was added.

### ⚠️ ISSUE #2: Inconsistent Terminology

**Lines use different terms for the same concept:**
- "data size" vs "chunk size" vs "final size"
- "safe limit" vs "copy limit" vs "effective max"
- "backtracked" vs "truncated" vs "adjusted"

**Recommendation**: Standardize terminology in debug messages

### ⚠️ ISSUE #3: Missing Critical Information

Debug messages don't always show:
- Current `paddingSize` value
- Whether padding is enabled/disabled
- Actual vs expected sizes after operations

**Recommendation**: Add more context to critical debug points

---

## 8. Edge Cases

### ✅ HANDLED WELL

1. **Empty markdown**: Early return (line 1030)
2. **Markdown links**: `FindSafeNewline` prevents splitting inside `[text](url)`
3. **HTML blocks**: `IsInsideHtmlBlock` checks
4. **Mermaid blocks**: Special handling to avoid splits
5. **Tables and lists**: Extensive logic to keep intact

### ❌ NOT HANDLED

1. **Single line longer than limit**: Could produce chunks over limit
2. **Excessive prepended newlines**: Could accumulate overhead
3. **Recursive backtracking**: Could get stuck in infinite loop (not verified)

---

## 9. Correctness Concerns

### Can We Trust This Implementation?

**NO - The algorithm has too many ways to bypass size limits:**

1. ❌ Overage allowance permits chunks 35% over limit
2. ❌ Backtracking operations don't validate sizes
3. ❌ Multiple max size calculations (which one is authoritative?)
4. ❌ Complex control flow makes verification difficult
5. ❌ Missing size checks after chunk data modifications

### Test Results

**User reported**: "Chunk 9 is 26,781 characters - over 4x the limit!"

This confirms the algorithm has **fundamental correctness issues** that our recent fixes did not address.

---

## 10. Root Cause Analysis

### Why Did 26k Chunks Happen?

**Primary Cause**: Overage allowance + missing size validation

```
1. Algorithm sees large table at position X
2. Calculates: chunkWithStructure = 7500 bytes
3. Checks: 7500 <= effectiveMaxForStructures (7200)? NO
4. Checks: 7500 > effectiveMaxForStructures + 500 (7700)? NO
5. Conclusion: Chunk is acceptable! ❌ WRONG
6. Sets chunkEnd = tableEnd (way past safe limit)
7. Later finds chunk exceeds copyLimit
8. Sets isLastChunk = false, tries to continue
9. But pos is now in wrong position
10. Subsequent chunks also malformed
```

### Secondary Causes

1. **No final size check** after table extension (line 1274)
2. **No validation** after header-before-table backtracking (line 4227)
3. **Debug logging** claims padding added when it wasn't (line 4272)
4. **MAX_DATA_CHARS** has no buffer for overhead (equals COPY_LIMIT)

---

## 11. Recommended Fixes

### Priority 1: Critical Fixes (Required for Correctness)

#### Fix #1: Remove Overage Allowance
```lua
-- Line 1208 and similar locations
-- BEFORE:
local structureOverageAllowance = 1500
local effectiveMaxForStructures = maxSafeDataSize + structureOverageAllowance

-- AFTER:
local effectiveMaxForStructures = maxSafeDataSize  -- No overage!
```

#### Fix #2: Add Size Validation After Table Extension
```lua
-- After line 1274
if tableChunkSize <= effectiveMaxForStructures then
    chunkEnd = tableEnd
    foundNewline = true
    
    -- ✅ ADD THIS: Validate final size
    local actualChunkSize = chunkEnd - pos + 1
    if actualChunkSize + paddingSize > copyLimit then
        -- Revert extension, use previous chunkEnd
        CM.DebugPrint("CHUNKING", string.format(
            "Chunk %d: Table extension would exceed limit, reverting",
            chunkNum
        ))
        -- Need to restore previous chunkEnd value (requires saving it)
        foundNewline = false  -- Continue searching for safe break
    end
end
```

#### Fix #3: Add Size Validation After Header Backtracking
```lua
-- After line 4227
if headerLineStart > pos then
    local newChunkEnd = headerLineStart - 1
    chunkEnd = newChunkEnd
    chunkData = string.sub(markdown, pos, chunkEnd)
    dataChars = string.len(chunkData)
    
    -- ✅ ADD THIS: Validate size
    if dataChars + paddingSize > copyLimit then
        CM.DebugPrint("CHUNKING", string.format(
            "Chunk %d: Header backtracking would exceed limit, skipping",
            chunkNum
        ))
        -- Revert to previous chunkEnd
        -- (This may require refactoring to save previous value)
    else
        chunkContent = chunkData
        finalSize = string.len(chunkContent)
        -- ... rest of logic
    end
end
```

#### Fix #4: Lower MAX_DATA_CHARS
```lua
-- In Constants.lua, line 39
MAX_DATA_CHARS = 5600,  -- Was 5700 - reserve 100 bytes for overhead
```

#### Fix #5: Fix Misleading Debug Log
```lua
-- Replace lines 4269-4277
if not CHUNKING.DISABLE_PADDING then
    CM.DebugPrint("CHUNKING", string.format(
        "Chunk %d: Added padding (%d spaces + 2 newlines = %d bytes, isLast: %s)",
        chunkNum, spacePaddingSize, paddingSize, tostring(isLastChunk)
    ))
else
    CM.DebugPrint("CHUNKING", string.format(
        "Chunk %d: Padding disabled - normalized trailing newlines only (isLast: %s)",
        chunkNum, tostring(isLastChunk)
    ))
end
```

### Priority 2: Important Improvements

#### Improvement #1: Call ValidateChunkSizeAfterBacktrack Everywhere
- After table extension (line 1274)
- After header+table backtracking (line 1305)
- After header-before-table backtracking (line 4227)

#### Improvement #2: Add Early Return to StripPadding
```lua
-- After line 980
if CHUNKING.DISABLE_PADDING then
    return content  -- No padding to strip
end
```

#### Improvement #3: Standardize Debug Terminology
- Use "data size" for chunk content without padding
- Use "total size" for chunk content with padding
- Use "copyLimit" consistently (not "safe limit" or "effective max")

### Priority 3: Refactoring (Long-term)

#### Refactor #1: Simplify State Management
- Consider state machine pattern for chunk lifecycle
- Reduce number of places `isLastChunk` is modified
- Make loop exit conditions explicit and verifiable

#### Refactor #2: Extract Validation Logic
```lua
local function ValidateFinalChunkSize(chunkData, paddingSize, copyLimit)
    local dataSize = string.len(chunkData)
    local totalSize = dataSize + paddingSize
    if totalSize > copyLimit then
        CM.DebugPrint("CHUNKING", string.format(
            "VALIDATION FAILED: totalSize (%d) > copyLimit (%d)",
            totalSize, copyLimit
        ))
        return false, dataSize, totalSize
    end
    return true, dataSize, totalSize
end

-- Use everywhere a chunk is finalized
```

#### Refactor #3: Separate Concerns
- Split `SplitMarkdownIntoChunks` into smaller functions:
  - `CalculateChunkBoundary(pos, markdown, maxSize)`
  - `FindSafeBreakPoint(markdown, startPos, endPos)`
  - `ValidateChunkSize(chunkData, paddingSize, copyLimit)`
  - `ApplyPadding(chunkContent, spacePaddingSize)`
  - `FinalizeChunk(chunkData, isLastChunk, chunkNum)`

---

## 12. Testing Recommendations

### Test Case 1: Large Tables
- Generate markdown with tables > 7000 bytes
- Verify chunks never exceed `COPY_LIMIT`
- Verify tables aren't split mid-table

### Test Case 2: Padding Disabled
- Verify no padding added when `DISABLE_PADDING = true`
- Verify debug logs correctly report padding status
- Verify chunks still stay within limits

### Test Case 3: Edge of Limit
- Generate markdown that produces chunks near 5700 bytes
- Verify no chunks exceed `COPY_LIMIT` by even 1 byte
- Verify prepended newlines don't push chunks over limit

### Test Case 4: Minimum Chunk Size
- Verify no chunks smaller than 100 bytes (except truly last chunk)
- Verify algorithm doesn't create excessive fragmentation

### Test Case 5: Long Lines
- Test with single lines > 5700 bytes
- Verify graceful handling (may need to break mid-line)

---

## 13. Conclusion

### Current State: ❌ **NOT PRODUCTION READY**

The chunking algorithm has **critical correctness issues** that allow it to produce chunks over 4x the intended limit.

### Primary Issues

1. **Overage allowance** bypasses size limits (allows 7700 byte chunks)
2. **Missing validation** after backtracking operations
3. **No buffer** in `MAX_DATA_CHARS` for overhead (prepended newlines)
4. **Misleading debug logs** claim padding added when disabled
5. **Complex control flow** makes verification difficult

### Required Actions

1. ✅ **Implement Priority 1 fixes immediately** (Fixes #1-5 above)
2. ⚠️ **Test thoroughly** with real-world markdown files
3. 📝 **Add unit tests** for chunking edge cases
4. 🔄 **Consider refactoring** for long-term maintainability

### Risk Assessment

**Without fixes:**
- ❌ Users will continue to get oversized chunks that can't be copied
- ❌ Some chunks may be truncated by ESO's EditBox
- ❌ Markdown formatting may be broken by incorrect splits

**With Priority 1 fixes:**
- ✅ Chunks should stay within limits (pending testing)
- ⚠️ May still have edge cases due to complex logic
- 📝 Should be validated with comprehensive tests

### Next Steps

1. Implement Priority 1 fixes (see Section 11)
2. Test with `korianthas.md` and other large files
3. Verify chunk sizes in ESO in-game
4. Consider Priority 2 and 3 improvements based on results

---

## Appendix A: Key Code Locations

| Issue | File | Lines | Description |
|-------|------|-------|-------------|
| Overage Allowance | Chunking.lua | 1208, 1219, 1270 | Allows 1500-2000 byte overage |
| Table Extension | Chunking.lua | 1272-1285 | Extends chunk without size check |
| Header Backtracking | Chunking.lua | 4213-4255 | Backtracks without validation |
| Misleading Debug Log | Chunking.lua | 4269-4277 | Claims padding added when disabled |
| MAX_DATA_CHARS | Constants.lua | 39 | No buffer for overhead |
| Padding Calculation | Chunking.lua | 1022-1028 | Calculated once (good) |
| ValidateChunkSizeAfterBacktrack | Chunking.lua | 1062-1077 | Only called once (bad) |

---

## Appendix B: Test Commands

```lua
-- In ESO, with LibDebugLogger enabled:
/script CharacterMarkdown.constants.CHUNKING.DISABLE_PADDING = true
/reloadui
/markdown github

-- Check chunk sizes in chat:
-- Look for "Chunk X: Y chars" messages
-- Verify NO chunks exceed 5700 bytes
```

---

*End of Code Review*

