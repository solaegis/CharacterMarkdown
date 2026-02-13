# Chunking Implementation Notes

## Overview

CharacterMarkdown splits large markdown documents into chunks for ESO's EditBox and clipboard limits. Two implementations exist:

- **Legacy** (`SplitMarkdownIntoChunks_Legacy`): Active, used by default
- **Section-based** (`SplitMarkdownIntoChunks_SectionBased`): Disabled due to bugs

## Section-Based Chunking (Disabled)

**Status**: `USE_SECTION_BASED_CHUNKING = false` in Constants.lua

Section-based chunking uses `MarkdownParser.ParseSections()` and `ChunkBuilder.BuildChunks()` to split by document structure. It is disabled because of the following issues:

### Known Bugs

1. **Output format mismatch**: ChunkBuilder output does not include:
   - HTML chunk markers (`<!-- Chunk N (X bytes before padding) -->`)
   - Trailing newline padding (550 newlines) for paste truncation protection
   - Legacy chunks are consumed by Window.lua and StripPadding with these expectations

2. **Size limit usage**: Section-based uses `maxSize = CHUNKING.COPY_LIMIT or 5700` directly. Legacy reserves overhead (marker ~60 bytes, padding 550 newlines, mermaid header 350) via `maxDataChars`. ChunkBuilder does not account for this overhead when grouping sections.

3. **Chunk format**: ChunkBuilder returns `{ content = string, size = number }`; legacy returns `{ content = string }` where content includes marker and padding. Window.lua and StripPadding assume the legacy format.

### Related Code

- `src/utils/Chunking.lua`: `SplitMarkdownIntoChunks_SectionBased`, routing logic
- `src/utils/MarkdownParser.lua`: `ParseSections`
- `src/utils/ChunkBuilder.lua`: `BuildChunks`

### Enabling Section-Based (Future)

To re-enable section-based chunking:

1. Apply padding and chunk markers to ChunkBuilder output to match legacy format
2. Use `maxDataChars` (or equivalent) when building chunks so total size stays within COPY_LIMIT
3. Run validation tests and in-game verification before enabling

## Legacy Chunking

See `docs/CHUNKING_ALGORITHM.md` for algorithm details. Constants have been updated; see `src/utils/Constants.lua` for current values (e.g. EDITBOX_LIMIT 21500, COPY_LIMIT 21500, SPACE_PADDING_SIZE 550).
