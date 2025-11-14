#!/usr/bin/env lua
-- Test script for section-based chunking
-- Run: lua test_section_chunking.lua

-- Mock ESO environment
_G.d = function(msg) print(msg) end

-- Create mock CharacterMarkdown namespace
CharacterMarkdown = {
    constants = {
        CHUNKING = {
            COPY_LIMIT = 5700,
            MAX_DATA_CHARS = 5600,
            EDITBOX_LIMIT = 6000,
            DISABLE_PADDING = true,
            USE_SECTION_BASED_CHUNKING = true,
        }
    },
    DebugPrint = function(category, message)
        print(string.format("[%s] %s", category, message))
    end,
    Info = function(message)
        print("[INFO] " .. message)
    end,
    Warn = function(message)
        print("[WARN] " .. message)
    end,
    Error = function(message)
        print("[ERROR] " .. message)
    end,
    utils = {}
}

-- Load the modules
dofile("src/utils/MarkdownParser.lua")
dofile("src/utils/ChunkBuilder.lua")

-- Test markdown with multiple sections
local testMarkdown = [[## Character

This is the character section with some content.
It has multiple paragraphs.

And some more text here.

## Skills

### Combat Skills

This section has subsections.

- Skill 1
- Skill 2
- Skill 3

### Crafting Skills

More skills here.

## Champion Points

This is the champion points section.

| Discipline | Points | Progress |
|------------|--------|----------|
| Craft | 660 | 100% |
| Warfare | 660 | 100% |
| Fitness | 660 | 100% |

## Achievements

Final section with achievements.
]]

print("=== Section-Based Chunking Test ===\n")

-- Test 1: Parse sections
print("Test 1: Parsing sections...")
local sections = CharacterMarkdown.utils.MarkdownParser.ParseSections(testMarkdown)
print(string.format("Parsed %d sections", #sections))
for i, section in ipairs(sections) do
    print(string.format("  Section %d: level=%d, title='%s', size=%d bytes",
        i, section.level, section.title, section.size))
end
print("")

-- Test 2: Parse subsections
print("Test 2: Parsing subsections...")
local skillsSection = "### Combat Skills\n\nContent here\n\n### Crafting Skills\n\nMore content"
local subsections = CharacterMarkdown.utils.MarkdownParser.ParseSubsections(skillsSection)
print(string.format("Parsed %d subsections", #subsections))
for i, subsection in ipairs(subsections) do
    print(string.format("  Subsection %d: title='%s', size=%d bytes",
        i, subsection.title, subsection.size))
end
print("")

-- Test 3: Build chunks
print("Test 3: Building chunks...")
local chunks = CharacterMarkdown.utils.ChunkBuilder.BuildChunks(sections, 5700, {
    preserveSections = true,
    minChunkSize = 100,
})
print(string.format("Built %d chunks", #chunks))
for i, chunk in ipairs(chunks) do
    print(string.format("  Chunk %d: %d bytes", i, chunk.size))
    if chunk.size > 5700 then
        print(string.format("    ERROR: Chunk exceeds limit!"))
    end
end
print("")

-- Test 4: Large section splitting
print("Test 4: Splitting large section...")
local largeContent = string.rep("This is a paragraph.\n\n", 300) -- ~6000 chars
local largeSection = {
    level = 2,
    title = "Large Section",
    content = "## Large Section\n\n" .. largeContent,
}
local splitChunks = CharacterMarkdown.utils.MarkdownParser.SplitSection(largeSection, 5700)
print(string.format("Split into %d chunks", #splitChunks))
for i, chunk in ipairs(splitChunks) do
    print(string.format("  Chunk %d: %d bytes", i, string.len(chunk)))
    if string.len(chunk) > 5700 then
        print(string.format("    ERROR: Chunk exceeds limit!"))
    end
end
print("")

print("=== Test Complete ===")

