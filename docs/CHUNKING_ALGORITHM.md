# Chunking Algorithm Outline

## Overview
The chunking algorithm splits large markdown documents into smaller chunks that fit within ESO's EditBox limits, while ensuring proper formatting and preventing truncation issues.

## Constants (Updated 2025-11-12)

Based on real-world testing and community research, the following limits have been established:

- `CHUNKING.EDITBOX_LIMIT`: **6,000 chars** - Based on observed EditBox display truncation at ~6.5k (with safety buffer)
- `CHUNKING.COPY_LIMIT`: **5,700 chars** - 300-char safety margin
- `CHUNKING.MAX_DATA_CHARS`: **5,613 chars** - Maximum data per chunk (COPY_LIMIT - 87 for padding)
- `CHUNKING.SPACE_PADDING_SIZE`: **85 spaces** - Padding to prevent paste truncation
- `paddingSize`: **87 chars** - (85 spaces + 2 newlines)

### Why These Limits?

#### Critical Finding (2025-11-12)
**ESO's EditBox CANNOT DISPLAY more than ~6.5k characters. Content beyond this limit is invisible.**

This is an **EditBox display limitation**, not a clipboard limitation. Testing confirmed:
- Generated chunk #1: 19,483 characters (padding removed) → EditBox displayed only ~10-11k, rest invisible ❌
- Generated chunk #2: 15,447 characters (padding removed) → EditBox displayed only ~10-11k, rest invisible ❌
- Generated chunk #3: 9,609 characters (padding removed) → EditBox displayed only ~9k, missing ~600 chars ❌
- Generated chunk #4: 8,691 characters (padding removed) → EditBox displayed only ~8k-8.5k, incomplete copy ❌
- Generated chunk #5: 7,693 characters (padding removed) → EditBox displayed only ~7.5k, "Explor" vs "Exploration" ❌
- Generated chunk #6: 7,101 characters (padding removed) → EditBox displayed only ~7k, "Dungeons   " incomplete ❌
- Generated chunk #7: 6,602 characters (padding removed) → EditBox displayed only ~6.5k, "Social         " incomplete ❌
- Generated chunk #8 (with 6.5k limit): 6,602 character chunk STILL truncated at line 572 with `</div` ❌
- User observation: "I cannot scroll the editbox" - EditBox auto-scrolls to end on display
- Copy operation: Can only copy what's visible (~6.0k chars safely)

#### Research Sources
- **ESOUI Forum Discussions**: Addon authors report EditBox display limitations
- **Real-World Testing #1**: 19,483 char chunk displayed ~10-11k chars (2025-11-12)
- **Real-World Testing #2**: 15,447 char chunk displayed ~10-11k chars (2025-11-12)
- **Real-World Testing #3**: 9,609 char chunk truncated at ~9k chars (2025-11-12)
- **Real-World Testing #4**: 8,691 char chunk truncated at ~8k-8.5k chars (2025-11-12)
- **Real-World Testing #5**: 7,693 char chunk truncated at ~7.5k chars (2025-11-12)
- **Real-World Testing #6**: 7,101 char chunk truncated at ~7k chars (2025-11-12)
- **Real-World Testing #7**: 6,602 char chunk truncated at ~6.5k chars (2025-11-12)
- **Real-World Testing #8**: 6,602 char chunk STILL truncated with 6.5k limit (2025-11-12)
- **User Feedback**: EditBox auto-selects all on open, scrolls to end, shows truncated content
- **Root Cause**: ESO EditBox display capacity hard limit at ~6.0-6.5k characters

#### Strategy
1. **EDITBOX_LIMIT (6.0k)**: Based on observed 6.5k truncation, with 500-char safety buffer
2. **COPY_LIMIT (5.7k)**: Additional 300-char buffer for safety
3. **MAX_DATA_CHARS (5.6k)**: Reserve 87 chars per chunk for padding to prevent truncation

### Limit History

| Constant | Original (2024) | Attempted #1 | Attempted #2 | Attempted #3 | Attempted #4 | Attempted #5 | Attempted #6 | Attempted #7 | Attempted #8 | Final (2025-11-12) | Notes |
|----------|----------------|--------------|--------------|--------------|--------------|--------------|--------------|--------------|--------------|-------------------|--------|
| EDITBOX_LIMIT | 8,500 | 20,000 | 16,000 | 10,000 | 9,000 | 8,000 | 7,500 | 7,000 | 6,500 | **6,000** | Display limit |
| COPY_LIMIT | 8,500 | 19,700 | 15,700 | 9,700 | 8,700 | 7,700 | 7,200 | 6,700 | 6,200 | **5,700** | Display truncation |
| MAX_DATA_CHARS | 8,413 | 19,613 | 15,613 | 9,613 | 8,613 | 7,613 | 7,113 | 6,613 | 6,113 | **5,613** | Safe for display |

**Impact**: 
- vs. Original: ~34% reduction (8.5k → 5.6k per chunk) for reliability
- Reliable display/copy without truncation ✓
- Document with 21k chars: 4 chunks (~5.6k + ~5.6k + ~5.6k + ~4.2k) instead of truncated chunks

## Main Algorithm Steps

### 1. Initialize Chunk Boundaries
- **Calculate limits:**
  - `copyLimit = COPY_LIMIT or (EDITBOX_LIMIT - 300)` → **5,700 chars**
  - `paddingSize = SPACE_PADDING_SIZE + 2` → **87 chars** (85 spaces + 2 newlines)
  - `maxSafeDataSize = copyLimit - paddingSize` → **5,613 chars** (reserve space for padding)
  - `effectiveMaxData = min(MAX_DATA_CHARS, maxSafeDataSize)` → **5,613 chars**

- **Determine if last chunk:**
  - `initialPotentialEnd = min(pos + effectiveMaxData - 1, markdownLength)`
  - `isLastChunk = (initialPotentialEnd >= markdownLength)`

- **Set initial chunk end:**
  - `potentialEnd = min(pos + effectiveMaxData - 1, markdownLength)`
  - `chunkEnd = potentialEnd`
  - `foundNewline = false`

### 2. Look-Ahead Detection (Preventive)
**Purpose:** Detect upcoming structures and end chunk before them to avoid splitting.

- **Look ahead up to 500 chars:**
  - `lookAheadStart = potentialEnd + 1`
  - `lookAheadEnd = min(potentialEnd + 500, markdownLength)`

- **Check for upcoming structures:**
  - **Headers (`####` or `#####`):**
    - If category header (`####`) found:
      - Check if subcategory header (`#####`) follows immediately
      - If both present, end chunk before category header to keep them together
      - Set `foundUpcomingStructure = true`, `structureStartPos = checkPos`
  
  - **Tables:**
    - If table detected, check if it fits in current chunk
    - If not, end chunk before table starts
    - Never chunk on the line immediately before a table
  
  - **Lists:**
    - Similar to tables - check if list fits, otherwise end before it
  
  - **Mermaid/HTML blocks:**
    - Check if block fits, otherwise end before it

- **If structure found:**
  - Find last newline before `structureStartPos`
  - Validate padding size: `ValidateChunkSizeAfterBacktrack(newEnd)`
  - If valid: set `chunkEnd = newEnd`, `foundNewline = true`
  - If invalid: continue searching for valid position

### 3. Find Safe Newline Position
**Purpose:** Find a newline position that doesn't split markdown structures.

- **If no newline found yet:**
  - Use `FindSafeNewline(markdown, searchStart, potentialEnd)` to avoid splitting inside markdown links
  - If safe newline found: `chunkEnd = safeNewline`, `foundNewline = true`
  - Otherwise: fallback to regular newline search backwards from `potentialEnd`

- **Extended search (if still no newline):**
  - Extend search range up to 5000 chars backwards
  - Try safe newline search again
  - Fallback to regular newline search

### 4. Safety Checks and Backtracking
**Purpose:** Ensure chunk doesn't split in unsafe locations.

#### 4.1 Header Protection
- **Check if chunkEnd is in middle of header line:**
  - Find line start/end around `chunkEnd`
  - If line matches `^#+%s` (header pattern):
    - Check if header has too many `#` (indicates merging)
    - Check if `chunkEnd` is in middle of header line
    - If so: backtrack to before header line
    - Validate padding: `ValidateChunkSizeAfterBacktrack(newEnd)`

- **Check for truncated headers:**
  - If `chunkEnd` is right before a `#####` header:
    - Check if current line ends with partial word (e.g., "Chara" instead of "Character")
    - Check if current line is empty header (`#### ` with no category name)
    - If detected: backtrack to before header line
    - Validate padding size

- **Check for header merging:**
  - If chunk ends after header and next chunk starts with header:
    - Backtrack to before first header to keep them together
    - Validate padding size

#### 4.2 HTML Tag Protection
- **Check if chunkEnd is inside HTML tag:**
  - Use `IsInsideHtmlTag(markdown, chunkEnd)` to detect
  - If inside tag: backtrack to before tag starts
  - Validate padding size

- **Check for incomplete HTML tags:**
  - If next char is `<` but no closing `>` found:
    - Backtrack to before incomplete tag
    - Validate padding size

- **Check if next line starts with HTML tag:**
  - If next line starts with `<div>`, `</div>`, etc.:
    - Backtrack to before chunkEnd to keep tag with previous chunk
    - Validate padding size

#### 4.3 Table Protection
- **Check if chunkEnd is after table and next line is header:**
  - If so, try to extend chunk to include closing `</div>` tag
  - If can't extend, backtrack to before table section
  - Validate padding size

- **Check if chunkEnd is after table row and before header:**
  - Backtrack to prevent merging
  - Validate padding size

#### 4.4 HTML Block Protection
- **Check if chunkEnd is inside HTML block:**
  - If HTML block fits: extend to include entire block
  - If too large: backtrack to before block starts
  - Validate padding size

#### 4.5 Link Protection
- **Check if chunkEnd is inside markdown link:**
  - Use `IsInsideMarkdownLink(markdown, chunkEnd)` to detect
  - If inside link: find safe newline position
  - Validate padding size

### 5. Extract Chunk Data
- **Extract chunk content:**
  - `chunkData = string.sub(markdown, pos, chunkEnd)`
  - `dataChars = string.len(chunkData)`
  - `chunkContent = chunkData`
  - `finalSize = string.len(chunkContent)`

### 6. Final Size Validation
- **Check if chunk (with padding) exceeds limit:**
  - `expectedFinalSize = finalSize + paddingSize`
  - If `expectedFinalSize > copyLimit`:
    - **Last chunk:** Include all content even if exceeds limit
    - **Non-last chunk:** Log warning (shouldn't happen if `maxSafeDataSize` calculated correctly)

### 7. Trailing Newline Check
- **Ensure chunk ends with newline:**
  - Check if last char is `\n`
  - If not: add newline, increment `finalSize`
  - Set `hasTrailingNewline = true`

### 8. Header+Table Protection (Final Check)
- **Check if chunk ends with header followed by table:**
  - Use `IsHeaderBeforeTable(markdown, chunkEnd, markdownLength)`
  - If detected: backtrack to before header
  - This keeps header+table together in NEXT chunk
  - Update `chunkEnd`, `chunkData`, `chunkContent`, `finalSize`

### 9. Add Padding
- **Purpose:** Add padding to prevent paste truncation
- **Padding format:**
  - Remove trailing newlines: `chunkContent = chunkContent:gsub("\n+$", "")`
  - Add spaces: `string.rep(" ", spacePaddingSize)` (85 spaces)
  - Add 2 newlines: `\n\n`
  - Final: `chunkContent = chunkContent .. string.rep(" ", spacePaddingSize) .. "\n\n"`

- **Update final size:**
  - `finalSize = finalSize + paddingSize` (already includes spaces + 2 newlines)

### 10. Validate Final Chunk
- **Check final size:**
  - `expectedFinalSize = finalSize + paddingSize`
  - Should be `<= copyLimit` (except for last chunk)

- **Verify chunk structure:**
  - Ends with exactly 2 newlines (after padding)
  - Doesn't split markdown structures
  - Doesn't truncate headers, HTML tags, or tables

### 11. Store Chunk and Continue
- **Store chunk:**
  - `table.insert(chunks, chunkContent)`
  - Increment `chunkNum`

- **Update position:**
  - `pos = chunkEnd + 1`
  - Continue to next chunk (loop back to step 1)

## Helper Functions

### `ValidateChunkSizeAfterBacktrack(newEnd)`
- **Purpose:** Validate that chunk size (with padding) fits after backtracking
- **Parameters:**
  - `newEnd`: Proposed new chunk end position
- **Returns:** `true` if valid, `false` otherwise
- **Validation:**
  - `dataSize = newEnd - pos + 1`
  - `totalSize = dataSize + paddingSize`
  - **Last chunk:** `dataSize > 0` (just ensure content exists)
  - **Non-last chunk:** `totalSize <= copyLimit AND dataSize >= 100` (minimum 100 chars)

### `IsInsideHtmlTag(markdown, pos)`
- **Purpose:** Detect if position is inside an HTML tag
- **Returns:** `isInside, tagStart, tagEnd`

### `IsInsideMarkdownLink(markdown, pos)`
- **Purpose:** Detect if position is inside a markdown link
- **Returns:** Link end position or `nil`

### `FindSafeNewline(markdown, startPos, endPos)`
- **Purpose:** Find a newline position that's not inside a markdown link
- **Returns:** Safe newline position or `nil`

### `IsHeaderBeforeTable(markdown, pos, markdownLength)`
- **Purpose:** Check if position is right before a header that's followed by a table
- **Returns:** `true` if header+table detected

## Key Principles

1. **Always reserve space for padding:** `maxSafeDataSize = copyLimit - paddingSize`
2. **Never split markdown structures:** Headers, HTML tags, tables, links must stay intact
3. **Validate after backtracking:** Always check padding constraints when moving chunk end
4. **End on complete lines:** Chunks always end at newline positions
5. **Prevent truncation:** Look ahead to detect and avoid splitting upcoming structures
6. **Keep related structures together:** Category+subcategory headers, header+table pairs

## Example Flow

```
1. Calculate: copyLimit=5700, paddingSize=87, maxSafeDataSize=5613
2. Set: potentialEnd = pos + 5613
3. Look ahead: Find upcoming header at potentialEnd + 50
4. Backtrack: chunkEnd = headerStart - 1
5. Validate: Check padding size (dataSize + 87 <= 5700) ✓
6. Extract: chunkData = markdown[pos:chunkEnd]
7. Check: finalSize + 87 <= 5700 ✓
8. Add padding: chunkContent = chunkData + " "×85 + "\n\n"
9. Store chunk, move to next: pos = chunkEnd + 1
```

## Validation & Testing

### Runtime Validation
The implementation includes runtime validation logging:
- EditBox `GetMaxInputChars()` is logged at initialization
- Chunk statistics are logged when multi-chunk content is displayed:
  - Total chunks and total character count
  - Largest chunk size vs. limit
  - Warning if any chunk exceeds 95% of limit

### Assertion Checks
Fallback truncation code has been converted to assertions:
- If single-chunk content exceeds EDITBOX_LIMIT → ERROR (chunking bug)
- If any chunk exceeds EDITBOX_LIMIT → ERROR (chunking bug)
- These should never fire in normal operation

### Testing Recommendations
Test with character profiles of varying sizes:
- **Small**: < 5.6k chars (single chunk)
- **Medium**: 10-20k chars (2-4 chunks with new limits)
- **Large**: 25-40k chars (5-8 chunks)
- **Extra Large**: 40k+ chars (8+ chunks)

Monitor for:
- ✓ No truncation in EditBox display (CRITICAL: display limit ~6.0k chars safely)
- ✓ All content visible in EditBox (EditBox auto-scrolls to end, cannot manually scroll)
- ✓ No truncation when copying chunks via Ctrl+C or "Select All" button
- ✓ No truncation when pasting into external editors - **verify last line is complete!**
- ✓ All padding correctly stripped before paste
- ✓ Chunk boundaries don't split markdown structures
- ✓ Chat log shows chunk sizes < 6,000 chars
- ✓ Warning if any chunk exceeds 95% of limit (5,700+ chars)

