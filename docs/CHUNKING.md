# Chunking Implementation Notes

## Overview

CharacterMarkdown splits large markdown documents into chunks for ESO's EditBox and clipboard limits. A single consolidated implementation lives in `src/utils/Chunking.lua` (`SplitMarkdownIntoChunks`).

## Output Contract

Each chunk is `{ content = string }` where `content` includes:

- HTML chunk marker at the start: `<!-- Chunk N (X bytes before padding) -->`
- Markdown data for that chunk
- 550 trailing newlines on non-final chunks (sacrificial padding for paste truncation protection)

`StripPadding()` removes markers and normalizes trailing newlines for copy/paste reassembly. Window.lua displays chunks with markers and padding intact.

## Algorithm

See `docs/CHUNKING_ALGORITHM.md` for step-by-step details. Constants are in `src/utils/Constants.lua` (EDITBOX_LIMIT 21500, COPY_LIMIT 21500, MAX_DATA_CHARS 20350, SPACE_PADDING_SIZE 550).

## Key Rules

- Never split inside mermaid blocks, tables, lists, markdown links, or HTML grid columns when avoidable
- Backtrack or extend chunk boundaries to keep structures intact
- Mermaid blocks split mid-diagram get artificial closing fences and header prepended to the next chunk
