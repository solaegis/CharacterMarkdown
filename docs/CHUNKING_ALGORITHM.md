# Chunking Algorithm Outline

## Overview
The chunking algorithm splits large markdown documents into smaller chunks that fit within ESO's EditBox limits, while ensuring proper formatting and preventing truncation issues.

## Constants

### Current Values (as of 2026-02)

**Source:** `src/utils/Constants.lua` — keep this doc in sync when values change.

| Constant | Value | Description |
|----------|-------|-------------|
| `CHUNKING.EDITBOX_LIMIT` | **21,500** | Trigger chunking when content exceeds this limit |
| `CHUNKING.COPY_LIMIT` | **21,500** | Safe copy limit per chunk |
| `CHUNKING.MAX_DATA_CHARS` | **20,350** | Max data per chunk (leaves room for ~60 byte marker + 550 newlines + buffer) |
| `CHUNKING.SPACE_PADDING_SIZE` | **550** | Number of newlines as padding |
| `CHUNKING.CHUNK_MARKER_SIZE` | **60** | Reserve for HTML comment marker "<!-- Chunk N (XXXXX bytes before padding) -->\n\n" |

**Key relationships:**
- `EDITBOX_LIMIT` MUST equal `COPY_LIMIT` (both 21,500) — they trigger chunking when content exceeds what can fit in one chunk
- `MAX_DATA_CHARS` (20,350) is less than `COPY_LIMIT` (21,500) because chunks include overhead (marker + padding)

### Why These Limits?

The EditBox is initialized with `SetMaxInputChars(22000)` in `src/ui/Window.lua`. Based on testing:
- **21,500** is a safe copy limit per chunk
- Chunking triggers when content exceeds `EDITBOX_LIMIT` (21,500)
- `MAX_DATA_CHARS` (20,350) leaves room for the HTML chunk marker (~60 bytes) and padding (550 newlines)

**Historical note:** Earlier testing (2025-11) suggested lower limits (~6k) due to display truncation. Further testing showed that with proper chunking and padding, the EditBox can reliably handle ~21.5k chars per chunk. See `src/utils/Constants.lua` comments for full testing history.

## Main Algorithm Steps

### 1. Initialize Chunk Boundaries
- **Calculate limits:**
  - `copyLimit = COPY_LIMIT` → **21,500 chars**
  - `paddingSize` = chunk marker (~60) + SPACE_PADDING_SIZE (550 newlines) + buffer
  - `effectiveMaxData = MAX_DATA_CHARS` → **20,350 chars** (reserve space for marker + padding)

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
  - Normalize trailing newlines in content
  - Add SPACE_PADDING_SIZE (550) newlines as padding
  - Chunk marker: `<!-- Chunk N (XXXXX bytes before padding) -->\n\n`
  - Final: `chunkContent = marker .. content .. (550 newlines)`

- **Update final size:**
  - `finalSize = finalSize + paddingSize` (marker + content + padding)

### 10. Validate Final Chunk
- **Check final size:**
  - `expectedFinalSize = finalSize + paddingSize`
  - Should be `<= copyLimit` (except for last chunk)

- **Verify chunk structure:**
  - Ends with padding (550 newlines when enabled) for paste safety
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
1. Calculate: copyLimit=21500, effectiveMaxData=20350
2. Set: potentialEnd = pos + 20350
3. Look ahead: Find upcoming header at potentialEnd + 50
4. Backtrack: chunkEnd = headerStart - 1
5. Validate: Check chunk size fits within limits ✓
6. Extract: chunkData = markdown[pos:chunkEnd]
7. Add marker: "<!-- Chunk N (XXXXX bytes before padding) -->\n\n"
8. Add padding: 550 newlines for paste safety
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
- **Small**: < 21.5k chars (single chunk)
- **Medium**: 21-40k chars (2 chunks)
- **Large**: 40-60k chars (3-4 chunks)
- **Extra Large**: 60k+ chars (4+ chunks)

Monitor for:
- ✓ No truncation when copying chunks via Ctrl+C or "Select All" button
- ✓ No truncation when pasting into external editors - **verify last line is complete!**
- ✓ All padding correctly stripped before paste
- ✓ Chunk boundaries don't split markdown structures
- ✓ Chunk sizes within limit (21,500 chars)

