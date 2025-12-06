-- Mock CharacterMarkdown environment
CharacterMarkdown = {
    constants = {
        CHUNKING = {
            EDITBOX_LIMIT = 21500,
            COPY_LIMIT = 21500,
            MAX_DATA_CHARS = 20350,
            DISABLE_PADDING = false,
            SPACE_PADDING_SIZE = 550,
            USE_SECTION_BASED_CHUNKING = false,
        }
    },
    utils = {},
    DebugPrint = function(tag, msg) 
        if tag == "CHUNKING" and msg:match("Chunk %d+:") then
            print("["..tag.."] " .. msg)
        end
    end,
    Info = function(...) end,
    Error = function(...) print("ERROR:", ...) end,
}

-- Load Chunking.lua
local f = io.open("src/utils/Chunking.lua", "r")
local content = f:read("*all")
f:close()

local chunking_func = load(content)
chunking_func()

local Chunking = CharacterMarkdown.utils.Chunking

-- Create a test string that mimics the actual masisi.md structure
-- We want the link to be right at the boundary
local prefix_len = 20300
local prefix = string.rep("a", prefix_len)

-- Add some realistic structure before the link
local section = [[

#### Draconic Power (Rank 50)

⚠️ **[Dragon Leap](https://en.uesp.net/wiki/Online:Dragon_Leap)** (Rank 4)

  <details>
  <summary>Other morph options</summary>

  ⚪ **Morph 1**: [Take Flight](https://en.uesp.net/wiki/Online:Take_Flight)
]]

local suffix = string.rep("b", 1000)

local markdown = prefix .. section .. suffix

print("=== TEST CASE ===")
print("Markdown length: " .. #markdown)
print("Link position: starts at " .. (prefix_len + string.find(section, "Dragon_Leap") - 1))
print("")

-- Run chunking
local chunks = Chunking.SplitMarkdownIntoChunks(markdown)

print("=== RESULTS ===")
print("Number of chunks: " .. #chunks)
print("")

-- Check each chunk for the link
local link_pattern = "%[Dragon Leap%]%(https://en%.uesp%.net/wiki/Online:Dragon_Leap%)"
local broken_link_pattern1 = "%[Dragon Leap%]%(https://en%.uesp%.net/wiki/Onli$"
local broken_link_pattern2 = "^ne:Dragon_Leap%)"

for i, chunk in ipairs(chunks) do
    local content = chunk.content
    print("Chunk " .. i .. " length: " .. #content)
    
    if string.match(content, link_pattern) then
        print("✓ Chunk " .. i .. " contains COMPLETE Dragon Leap link")
    elseif string.match(content, broken_link_pattern1) then
        print("✗ Chunk " .. i .. " contains BROKEN link (truncated at end)")
        print("  Last 150 chars: " .. string.sub(content, -150))
    elseif string.match(content, broken_link_pattern2) then
        print("✗ Chunk " .. i .. " contains BROKEN link (continuation)")
        print("  First 150 chars: " .. string.sub(content, 1, 150))
    end
end

print("")
print("=== VERDICT ===")
local chunk1 = chunks[1].content
local chunk2 = chunks[2] and chunks[2].content or ""

if string.match(chunk1, link_pattern) or string.match(chunk2, link_pattern) then
    print("✓ PASS: Link is intact in one of the chunks")
elseif string.match(chunk1, "Dragon_Leap") and string.match(chunk2, "Dragon_Leap") then
    print("✗ FAIL: Link is split across chunks")
else
    print("? UNCLEAR: Cannot determine link status")
end
