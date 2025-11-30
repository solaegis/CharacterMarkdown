-- CharacterMarkdown - Chunking Tests
-- Unit tests for the Chunking module to verify splitting logic

local CM = CharacterMarkdown
CM.tests = CM.tests or {}
CM.tests.chunking = {}

local string_format = string.format
local string_rep = string.rep

-- =====================================================
-- TEST HELPERS
-- =====================================================

local function Assert(condition, message)
    if not condition then
        return false, message
    end
    return true
end

local function CreateLongString(char, length)
    return string_rep(char, length)
end

-- =====================================================
-- TESTS
-- =====================================================

local function TestBasicSplitting()
    local testName = "Basic Splitting"
    
    -- Create a string slightly larger than the limit (assuming limit is around 6000)
    -- We'll use a smaller limit for testing if possible, but we can't easily change the constant
    -- So we'll construct a string that MUST be split
    
    local limit = CM.constants.CHUNKING.COPY_LIMIT or 5700
    local part1 = CreateLongString("A", limit - 100)
    local part2 = CreateLongString("B", 200)
    local input = part1 .. "\n\n" .. part2
    
    local chunks = CM.utils.Chunking.SplitMarkdownIntoChunks(input)
    
    if #chunks < 2 then
        return false, string_format("Expected at least 2 chunks, got %d", #chunks)
    end
    
    -- Verify total content matches
    local reassembled = ""
    for _, chunk in ipairs(chunks) do
        reassembled = reassembled .. chunk.content
    end
    
    if reassembled ~= input then
        return false, "Reassembled content does not match input"
    end
    
    return true, "Split correctly"
end

local function TestHtmlBlockIntegrity()
    local testName = "HTML Block Integrity"
    
    -- Create a large HTML block that shouldn't be split
    -- Note: If the block is larger than the ABSOLUTE limit, it MUST be split, 
    -- but the chunking logic tries to avoid it if possible.
    -- We'll create a scenario where a split point falls inside an HTML block
    
    local limit = CM.constants.CHUNKING.COPY_LIMIT or 5700
    local padding = CreateLongString("P", limit - 100) -- Fill up most of the first chunk
    
    local htmlBlock = "<div>\n" .. CreateLongString("H", 200) .. "\n</div>"
    local input = padding .. "\n" .. htmlBlock
    
    local chunks = CM.utils.Chunking.SplitMarkdownIntoChunks(input)
    
    -- We expect the HTML block to be pushed to the second chunk to avoid splitting it
    -- Or if it fits, it might be in the first chunk.
    -- The key is that the HTML block string should appear intact in one of the chunks
    
    local foundIntact = false
    for _, chunk in ipairs(chunks) do
        if chunk.content:find(htmlBlock, 1, true) then
            foundIntact = true
            break
        end
    end
    
    if not foundIntact then
        return false, "HTML block was split across chunks"
    end
    
    return true, "HTML block preserved"
end

local function TestMermaidBlockIntegrity()
    local testName = "Mermaid Block Integrity"
    
    local limit = CM.constants.CHUNKING.COPY_LIMIT or 5700
    local padding = CreateLongString("P", limit - 100)
    
    local mermaidBlock = "```mermaid\ngraph TD;\nA-->B;\n" .. CreateLongString("C", 200) .. "\n```"
    local input = padding .. "\n" .. mermaidBlock
    
    local chunks = CM.utils.Chunking.SplitMarkdownIntoChunks(input)
    
    local foundIntact = false
    for _, chunk in ipairs(chunks) do
        if chunk.content:find(mermaidBlock, 1, true) then
            foundIntact = true
            break
        end
    end
    
    if not foundIntact then
        return false, "Mermaid block was split across chunks"
    end
    
    return true, "Mermaid block preserved"
end

local function TestTableIntegrity()
    local testName = "Table Integrity"
    
    local limit = CM.constants.CHUNKING.COPY_LIMIT or 5700
    local padding = CreateLongString("P", limit - 100)
    
    local tableBlock = "| Header 1 | Header 2 |\n| --- | --- |\n"
    for i = 1, 10 do
        tableBlock = tableBlock .. "| Row " .. i .. " | Data " .. i .. " |\n"
    end
    
    local input = padding .. "\n" .. tableBlock
    
    local chunks = CM.utils.Chunking.SplitMarkdownIntoChunks(input)
    
    local foundIntact = false
    for _, chunk in ipairs(chunks) do
        if chunk.content:find(tableBlock, 1, true) then
            foundIntact = true
            break
        end
    end
    
    if not foundIntact then
        return false, "Table was split across chunks"
    end
    
    return true, "Table preserved"
end

-- =====================================================
-- RUNNER
-- =====================================================

function CM.tests.chunking.RunTests()
    CM.Info("|cFFFF00=== CHUNKING TESTS ===|r")
    
    local tests = {
        { name = "Basic Splitting", func = TestBasicSplitting },
        { name = "HTML Block Integrity", func = TestHtmlBlockIntegrity },
        { name = "Mermaid Block Integrity", func = TestMermaidBlockIntegrity },
        { name = "Table Integrity", func = TestTableIntegrity },
    }
    
    local passed = 0
    local failed = 0
    
    for _, test in ipairs(tests) do
        local success, msg = test.func()
        if success then
            CM.Info(string_format("|c00FF00✅ %s: %s|r", test.name, msg))
            passed = passed + 1
        else
            CM.Info(string_format("|cFF0000❌ %s: %s|r", test.name, msg))
            failed = failed + 1
        end
    end
    
    CM.Info(string_format("Chunking Tests: %d passed, %d failed", passed, failed))
    
    return { passed = passed, failed = failed }
end

CM.DebugPrint("TESTS", "Chunking tests loaded")
