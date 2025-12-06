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
    DebugPrint = function(tag, msg) print("["..tag.."] " .. msg) end,
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

-- Create a test string
-- MAX_DATA_CHARS is 20350.
-- We want the link to straddle this boundary.
-- Let's put the link start at 20340.
local prefix_len = 20340
local prefix = string.rep("a", prefix_len)

-- The problematic line
-- We use a long URL to ensure it crosses the boundary
local line = "\n⚠️ **[Dragon Leap](https://en.uesp.net/wiki/Online:Dragon_Leap_Long_URL_To_Force_Split)**\n"
local suffix = string.rep("b", 1000)

local markdown = prefix .. line .. suffix

print("Markdown length: " .. #markdown)
print("Target split area start index: " .. prefix_len)

-- Run chunking
local chunks = Chunking.SplitMarkdownIntoChunks(markdown)

print("Number of chunks: " .. #chunks)

local chunk1 = chunks[1].content
print("Chunk 1 length: " .. #chunk1)
-- Show the end of chunk 1 (excluding padding if possible, but here we just show raw)
-- We expect the chunk comment to be inserted right in the middle of the link if bug exists
print("Chunk 1 tail (last 100 chars):")
print(string.sub(chunk1, -650)) -- Look back enough to see past padding

local chunk2 = chunks[2].content
print("Chunk 2 head (first 100 chars):")
print(string.sub(chunk2, 1, 100))

-- Check for broken link
-- The chunking adds a comment like <!-- Chunk 2 ... -->
if string.match(chunk1, "wiki/Onli") and not string.match(chunk1, "Dragon_Leap") then
     print("BUG REPRODUCED: Link split in Chunk 1")
elseif string.match(chunk2, "^ne:Dragon_Leap") or string.match(chunk2, "^n_Leap") then
     print("BUG REPRODUCED: Link split in Chunk 2")
else
    -- Check if the link is intact in either chunk
    if string.match(chunk1, "Dragon_Leap_Long_URL") then
        print("Link stayed in Chunk 1 (Good)")
    elseif string.match(chunk2, "Dragon_Leap_Long_URL") then
        print("Link moved to Chunk 2 (Good)")
    else
        print("Link status unclear (might be split differently)")
    end
end
