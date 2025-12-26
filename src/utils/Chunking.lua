-- CharacterMarkdown - Chunking Utilities
-- Handles splitting large markdown into chunks for ESO EditBox limits

local CM = CharacterMarkdown

-- Import constants
local CHUNKING = CM.constants.CHUNKING

-- =====================================================
-- HELPER FUNCTIONS
-- =====================================================

-- Helper function to check if a line is part of a markdown table
local function IsTableLine(line)
    if not line or line == "" then
        return false
    end
    return line:match("^%s*|") ~= nil
end

-- Helper function to check if a line is a markdown header
local function IsHeaderLine(line)
    if not line or line == "" then
        return false
    end
    return line:match("^#+%s") ~= nil
end

-- Helper function to check if a position is at a newline between a header and a table
-- Returns true if: current line is a header AND next non-empty line is a table
local function IsHeaderBeforeTable(markdown, pos, markdownLength)
    if pos >= markdownLength or string.sub(markdown, pos, pos) ~= "\n" then
        return false
    end

    -- Find the line ending at pos (the header line)
    local lineStart = pos
    for i = pos - 1, math.max(1, pos - 1000), -1 do
        if i == 1 or string.sub(markdown, i - 1, i - 1) == "\n" then
            lineStart = i
            break
        end
    end

    local headerLine = string.sub(markdown, lineStart, pos - 1)
    if not IsHeaderLine(headerLine) then
        return false
    end

    -- Check if the next non-empty line is a table
    local nextLineStart = pos + 1
    -- Skip empty lines
    while nextLineStart <= markdownLength and string.sub(markdown, nextLineStart, nextLineStart) == "\n" do
        nextLineStart = nextLineStart + 1
    end

    if nextLineStart > markdownLength then
        return false
    end

    -- Find the end of the next line
    local nextLineEnd = nextLineStart
    for i = nextLineStart, math.min(markdownLength, nextLineStart + 500) do
        if string.sub(markdown, i, i) == "\n" then
            nextLineEnd = i
            break
        end
    end

    local nextLine = string.sub(markdown, nextLineStart, nextLineEnd - 1)
    return IsTableLine(nextLine)
end

-- Helper function to check if a line is part of a markdown list
local function IsListLine(line)
    if not line or line == "" then
        return false
    end

    -- Strip all leading characters that aren't list markers or regular printable chars
    -- This handles zero-width spaces and other invisible Unicode characters
    local cleaned = line
    -- Remove zero-width space (U+200B = \226\128\139) and similar invisible chars
    -- Pattern: match UTF-8 sequences that are likely zero-width/invisible chars
    cleaned = cleaned:gsub("^\226\128\139+", "") -- Zero-width space
    cleaned = cleaned:gsub("^\226\128\140+", "") -- Zero-width non-joiner
    cleaned = cleaned:gsub("^\226\128\141+", "") -- Zero-width joiner
    -- Remove regular leading whitespace
    cleaned = cleaned:gsub("^%s+", "")

    -- Check if cleaned line starts with a list marker
    if cleaned:match("^[-*+]%s") or cleaned:match("^%d+[.)]%s") then
        return true
    end

    -- Fallback: check original pattern (handles normal cases without invisible chars)
    return line:match("^%s*[-*+]%s") ~= nil or line:match("^%s*%d+[.)]%s") ~= nil
end

-- Helper function to check if a position is inside an HTML block (like <div>)
local function IsInsideHtmlBlock(markdown, pos)
    local markdownLen = string.len(markdown)

    -- Search backwards for opening <div> tags
    local divStart = nil
    local searchStart = math.max(1, pos - 5000) -- Search up to 5000 chars back

    for i = pos, searchStart, -1 do
        local substr = string.sub(markdown, i, math.min(markdownLen, i + 4))
        if substr:match("^<div") then
            divStart = i
            break
        end
    end

    -- If we found a <div>, check if we're inside it by finding the closing </div>
    if divStart then
        local divEnd = nil
        local divDepth = 0 -- Track nested divs

        -- Start from divStart and track nesting
        for i = divStart, math.min(markdownLen, divStart + 20000) do
            local openSubstr = string.sub(markdown, i, math.min(markdownLen, i + 4))
            local closeSubstr = string.sub(markdown, i, math.min(markdownLen, i + 5))

            if openSubstr:match("^<div") then
                divDepth = divDepth + 1
            elseif closeSubstr:match("^</div>") then
                divDepth = divDepth - 1
                if divDepth == 0 then
                    divEnd = i + 5 -- Position after </div>
                    break
                end
            end
        end

        if divEnd and pos >= divStart and pos <= divEnd then
            return true, divStart, divEnd
        end
    end

    return false, nil, nil
end

-- Helper function to check if a position is in the middle of an HTML tag
-- Returns true if pos is between < and > of an HTML tag
local function IsInsideHtmlTag(markdown, pos)
    local markdownLen = string.len(markdown)

    -- Search backwards for the opening <
    local tagStart = nil
    local searchStart = math.max(1, pos - 100) -- HTML tags are usually short

    for i = pos, searchStart, -1 do
        if string.sub(markdown, i, i) == "<" then
            tagStart = i
            break
        elseif string.sub(markdown, i, i) == ">" then
            -- Found a closing > before an opening <, so we're not in a tag
            return false, nil, nil
        end
    end

    -- If we found a <, check if there's a matching > after it
    if tagStart then
        for i = tagStart + 1, math.min(markdownLen, tagStart + 200) do
            if string.sub(markdown, i, i) == ">" then
                -- Found the closing >, check if pos is between < and >
                if pos >= tagStart and pos <= i then
                    return true, tagStart, i
                else
                    return false, nil, nil
                end
            elseif string.sub(markdown, i, i) == "<" then
                -- Found another < before closing >, this is malformed or nested
                -- But we're still technically "inside" a tag
                return true, tagStart, nil
            end
        end
        -- No closing > found, but we have an opening <, so we're in an incomplete tag
        return true, tagStart, nil
    end

    return false, nil, nil
end

-- Helper function to check if a position is inside a Mermaid code block or subgraph
local function IsInsideMermaidBlock(markdown, pos)
    local markdownLen = string.len(markdown)

    -- First, check if we're inside a ```mermaid code block
    local mermaidStart = nil
    local codeBlockStart = nil

    -- Search backwards for code block markers
    for i = pos, 1, -1 do
        local substr = string.sub(markdown, math.max(1, i - 10), i)
        if substr:match("```mermaid") then
            mermaidStart = i - 9 -- Position of start of ```mermaid
            break
        elseif substr:match("```") and not substr:match("```mermaid") then
            -- Found a code block marker, but need to check if it's closing or opening
            -- Look a bit further back to see if there's a newline before it
            local checkPos = math.max(1, i - 11)
            if string.sub(markdown, checkPos, checkPos) == "\n" or checkPos == 1 then
                codeBlockStart = i - 2 -- Position of start of ```
                break
            end
        end
    end

    -- If we found a mermaid code block, check if we're inside it
    if mermaidStart then
        -- Look forwards from mermaidStart to find the closing ```
        local blockEnd = nil
        for i = mermaidStart + 10, markdownLen do
            local substr = string.sub(markdown, i, math.min(markdownLen, i + 2))
            if substr == "```" then
                -- Check if it's at start of line or after newline
                if i == 1 or string.sub(markdown, i - 1, i - 1) == "\n" then
                    blockEnd = i + 2 -- Position of end of closing ```
                    break
                end
            end
        end

        if blockEnd and pos >= mermaidStart and pos <= blockEnd then
            -- We're inside a mermaid code block - now check for subgraphs
            -- Search backwards from pos to find if we're inside a subgraph
            local subgraphStart = nil
            local subgraphEnd = nil

            -- Find the start of the current subgraph (if any) by searching backwards line by line
            -- Look for "subgraph" keyword (may have leading whitespace)
            local lineStart = pos
            -- Find the start of the current line
            for k = pos, math.max(1, pos - 1000), -1 do
                if k == 1 or string.sub(markdown, k - 1, k - 1) == "\n" then
                    lineStart = k
                    break
                end
            end

            -- Search backwards line by line from current position
            local searchPos = lineStart - 1
            while searchPos >= mermaidStart + 10 do
                -- Find the start of this line
                local currentLineStart = searchPos + 1
                for k = searchPos, math.max(1, searchPos - 1000), -1 do
                    if k == 1 or string.sub(markdown, k - 1, k - 1) == "\n" then
                        currentLineStart = k
                        break
                    end
                end

                -- Find the end of this line
                local currentLineEnd = searchPos
                for k = searchPos + 1, math.min(markdownLen, searchPos + 500) do
                    if string.sub(markdown, k, k) == "\n" then
                        currentLineEnd = k
                        break
                    end
                end

                local line = string.sub(markdown, currentLineStart, currentLineEnd - 1)

                -- Check if this line contains "subgraph"
                if line:match("subgraph%s") then
                    subgraphStart = currentLineStart

                    -- Now find the matching "end" for this subgraph
                    -- Count subgraph depth to handle nested subgraphs
                    -- Search more aggressively - up to 50000 chars or end of mermaid block, whichever comes first
                    local depth = 1
                    local searchStart = currentLineEnd + 1
                    local extendedSearchEnd = math.min(markdownLen, math.max(blockEnd, subgraphStart + 50000))

                    -- Search forwards line by line
                    local forwardPos = searchStart
                    while forwardPos < extendedSearchEnd do
                        -- Find the start of this line (for accurate line detection)
                        local forwardLineStart = forwardPos
                        for k = forwardPos, math.max(1, forwardPos - 1000), -1 do
                            if k == 1 or string.sub(markdown, k - 1, k - 1) == "\n" then
                                forwardLineStart = k
                                break
                            end
                        end

                        -- Find the end of this line
                        local forwardLineEnd = forwardPos
                        for k = forwardPos, math.min(markdownLen, forwardPos + 500) do
                            if string.sub(markdown, k, k) == "\n" then
                                forwardLineEnd = k
                                break
                            end
                        end

                        local forwardLine = string.sub(markdown, forwardLineStart, forwardLineEnd - 1)

                        -- Check if line contains "subgraph" or "end" (with optional leading whitespace)
                        if forwardLine:match("subgraph%s") then
                            depth = depth + 1
                        elseif
                            forwardLine:match("%send%s")
                            or forwardLine:match("%send$")
                            or forwardLine:match("%send\n")
                        then
                            depth = depth - 1
                            if depth == 0 then
                                -- Found matching end
                                subgraphEnd = forwardLineEnd
                                break
                            end
                        end

                        -- Move to next line (skip to end of current line + 1)
                        if forwardLineEnd > forwardPos then
                            forwardPos = forwardLineEnd + 1
                        else
                            -- No newline found, move forward by 1 to avoid infinite loop
                            forwardPos = forwardPos + 1
                        end
                    end
                    break
                end

                -- Move to previous line
                searchPos = currentLineStart - 1
            end

            -- If we're inside a subgraph, return subgraph boundaries
            -- Even if we can't find the end yet, if we found a start and pos is after it, we're in a subgraph
            if subgraphStart and pos >= subgraphStart then
                if subgraphEnd then
                    -- We found both start and end - return subgraph boundaries
                    if pos <= subgraphEnd then
                        return true, subgraphStart, subgraphEnd
                    end
                else
                    -- We're in a subgraph but haven't found the end yet
                    -- Search more aggressively for the end (might be beyond blockEnd if subgraph is large)
                    -- Search up to 50000 chars forward to find the matching end
                    local extendedSearchEnd = math.min(markdownLen, subgraphStart + 50000)
                    local depth = 1
                    local searchStart = subgraphStart + 9 -- After "subgraph "

                    for j = searchStart, extendedSearchEnd do
                        -- Find start of line
                        local lineStart = j
                        for k = j, math.max(1, j - 1000), -1 do
                            if k == 1 or string.sub(markdown, k - 1, k - 1) == "\n" then
                                lineStart = k
                                break
                            end
                        end

                        -- Find end of line
                        local lineEnd = j
                        for k = j, math.min(markdownLen, j + 500) do
                            if string.sub(markdown, k, k) == "\n" then
                                lineEnd = k
                                break
                            end
                        end

                        local line = string.sub(markdown, lineStart, lineEnd - 1)

                        if line:match("subgraph%s") then
                            depth = depth + 1
                        elseif line:match("%send%s") or line:match("%send$") or line:match("%send\n") then
                            depth = depth - 1
                            if depth == 0 then
                                subgraphEnd = lineEnd
                                break
                            end
                        end

                        j = lineEnd -- Skip to next line
                    end

                    if subgraphEnd then
                        -- Found the end - return subgraph boundaries
                        return true, subgraphStart, subgraphEnd
                    else
                        -- Still can't find end - return subgraph start and code block end
                        -- This tells the chunking logic to extend to the end of the code block
                        return true, subgraphStart, blockEnd
                    end
                end
            end

            -- Not in a subgraph, return code block boundaries
            return true, mermaidStart, blockEnd
        end
    end

    -- Not inside a mermaid block
    return false, nil, nil
end

-- Helper function to find the end of a Mermaid code block or subgraph starting at a given position
local function FindMermaidBlockEnd(markdown, startPos, maxSearch)
    local markdownLen = string.len(markdown)
    local searchEnd = math.min(startPos + maxSearch, markdownLen)

    -- First check if we're looking at a subgraph
    local subgraphStart = nil
    for i = startPos, math.min(startPos + 100, markdownLen) do
        local substr = string.sub(markdown, i, math.min(markdownLen, i + 8))
        if substr:match("^subgraph%s") then
            subgraphStart = i
            break
        end
    end

    if subgraphStart then
        -- Find the matching "end" for this subgraph
        -- Count subgraph depth to find matching end
        local depth = 1
        local searchStart = subgraphStart + 9 -- After "subgraph "

        for i = searchStart, searchEnd do
            -- Find start of line
            local lineStart = i
            for k = i, math.max(1, i - 100), -1 do
                if k == 1 or string.sub(markdown, k - 1, k - 1) == "\n" then
                    lineStart = k
                    break
                end
            end

            -- Get the line content
            local lineEnd = i
            for k = i, math.min(markdownLen, i + 100) do
                if string.sub(markdown, k, k) == "\n" then
                    lineEnd = k
                    break
                end
            end
            local line = string.sub(markdown, lineStart, lineEnd - 1)

            -- Check if line contains "subgraph" or "end" (with optional leading whitespace)
            if line:match("subgraph%s") then
                depth = depth + 1
            elseif line:match("%send%s") or line:match("%send$") or line:match("%send\n") then
                depth = depth - 1
                if depth == 0 then
                    -- Found matching end - return end of line
                    return lineEnd
                end
            end
        end
        -- Subgraph not closed within search range - return nil
        return nil
    end

    -- Not a subgraph - look for ```mermaid opening
    local blockStart = nil
    for i = startPos, math.min(startPos + 100, markdownLen) do
        local substr = string.sub(markdown, i, math.min(markdownLen, i + 9))
        if substr == "```mermaid" then
            blockStart = i
            break
        end
    end

    if not blockStart then
        return nil
    end

    -- Find the closing ```
    for i = blockStart + 10, searchEnd do
        local substr = string.sub(markdown, i, math.min(markdownLen, i + 2))
        if substr == "```" then
            -- Check if it's at start of line or after newline
            if i == 1 or string.sub(markdown, i - 1, i - 1) == "\n" then
                return i + 2 -- Return position after closing ```
            end
        end
    end

    return nil
end

-- Helper function to find the end of a list starting at a given position
local function FindListEnd(markdown, startPos, maxSearch)
    local markdownLen = string.len(markdown)
    local searchEnd = math.min(startPos + maxSearch, markdownLen)

    local lineStart = startPos
    for i = startPos, math.max(1, startPos - 1000), -1 do
        if i == 1 or string.sub(markdown, i - 1, i - 1) == "\n" then
            lineStart = i
            break
        end
    end

    local line = string.sub(markdown, lineStart, startPos - 1)
    if not IsListLine(line) then
        return nil
    end

    local lastListLineEnd = startPos
    local currentPos = startPos + 1

    while currentPos <= searchEnd do
        local nextNewline = nil
        for i = currentPos, searchEnd do
            if string.sub(markdown, i, i) == "\n" then
                nextNewline = i
                break
            end
        end

        if not nextNewline then
            break
        end

        local lineContent = string.sub(markdown, currentPos, nextNewline - 1)

        if IsListLine(lineContent) then
            lastListLineEnd = nextNewline
            currentPos = nextNewline + 1
        elseif lineContent:match("^%s*$") then
            return lastListLineEnd
        else
            return lastListLineEnd
        end
    end

    if lastListLineEnd <= markdownLen and string.sub(markdown, lastListLineEnd, lastListLineEnd) == "\n" then
        return lastListLineEnd
    else
        return startPos
    end
end

-- Helper function to check if a position is inside a markdown link [text](url)
-- Returns the position of the closing parenthesis if inside a link, nil otherwise
-- Also checks if we're at the end of a line that contains an incomplete link
local function IsInsideMarkdownLink(markdown, pos)
    local markdownLen = string.len(markdown)
    if pos < 1 or pos > markdownLen then
        return nil
    end

    -- If pos is at a newline, check the line ending at that newline for incomplete links
    if string.sub(markdown, pos, pos) == "\n" then
        -- Find the start of the line
        local lineStart = pos
        for i = pos - 1, math.max(1, pos - 500), -1 do
            if string.sub(markdown, i, i) == "\n" then
                lineStart = i + 1
                break
            end
        end
        if lineStart == pos then
            lineStart = 1
        end

        -- Check if the line contains an incomplete markdown link
        local lineContent = string.sub(markdown, lineStart, pos - 1)
        -- Look for pattern: [text](url where url is incomplete (no closing paren)
        local openParenPos = nil
        local openBracketPos = nil

        -- Find the last opening parenthesis in the line
        for i = pos - 1, lineStart, -1 do
            if string.sub(markdown, i, i) == "(" then
                openParenPos = i
                break
            end
        end

        if openParenPos then
            -- Check if there's a markdown link pattern [text](url
            -- Look backwards for a closing bracket ] that comes after an opening bracket [
            local bracketDepth = 0
            for i = openParenPos - 1, lineStart, -1 do
                local char = string.sub(markdown, i, i)
                if char == "]" then
                    bracketDepth = bracketDepth + 1
                elseif char == "[" then
                    if bracketDepth == 0 then
                        -- Found opening bracket, this is a markdown link pattern
                        openBracketPos = i
                        break
                    else
                        bracketDepth = bracketDepth - 1
                    end
                end
            end

            if openBracketPos then
                -- Found a markdown link pattern [text](url
                -- Check if the closing paren is after pos (incomplete link)
                for j = pos + 1, math.min(markdownLen, openParenPos + 2000) do
                    if string.sub(markdown, j, j) == ")" then
                        return j -- Return position of closing paren
                    end
                end
                -- No closing paren found - this is an incomplete link
                -- Return a position beyond the line to indicate we need to skip this newline
                return markdownLen + 1 -- Special value indicating incomplete link
            end
        end
    end

    -- Search backwards from pos to find if we're inside parentheses that are part of a markdown link
    -- Pattern: [text](url) - we need to check if pos is between ( and )
    local parenDepth = 0
    local foundOpenParen = nil
    local searchStart = math.max(1, pos - 1000) -- Search up to 1000 chars back

    -- First, find if we're inside parentheses by counting backwards
    for i = pos, searchStart, -1 do
        local char = string.sub(markdown, i, i)
        if char == ")" then
            parenDepth = parenDepth + 1
        elseif char == "(" then
            if parenDepth == 0 then
                -- Found an opening parenthesis - check if it's part of a markdown link
                foundOpenParen = i
                break
            else
                parenDepth = parenDepth - 1
            end
        end
    end

    -- If we found an opening parenthesis, check if it's part of a markdown link [text](url)
    if foundOpenParen then
        -- Look backwards from the opening paren for a closing bracket ]
        local bracketDepth = 0
        for i = foundOpenParen - 1, math.max(1, foundOpenParen - 500), -1 do
            local char = string.sub(markdown, i, i)
            if char == "]" then
                bracketDepth = bracketDepth + 1
            elseif char == "[" then
                if bracketDepth == 0 then
                    -- Found a markdown link pattern [text](url)
                    -- Now find the closing parenthesis
                    for j = foundOpenParen + 1, math.min(markdownLen, foundOpenParen + 2000) do
                        if string.sub(markdown, j, j) == ")" then
                            return j -- Return position of closing paren
                        end
                    end
                    return nil
                else
                    bracketDepth = bracketDepth - 1
                end
            end
        end
    end

    return nil
end

-- Helper function to check if a position is inside a table
-- Returns the position of the newline after the table end if inside a table, nil otherwise
-- This function considers a position "inside" a table if:
-- 1. It's on a table line, OR
-- 2. It's at a newline between table rows (after one table line and before another)
local function IsInsideTable(markdown, pos)
    local markdownLen = string.len(markdown)
    if pos < 1 or pos > markdownLen then
        return nil
    end

    -- Find the start of the line containing pos
    local lineStart = pos
    for i = pos - 1, math.max(1, pos - 1000), -1 do
        if i == 1 or string.sub(markdown, i - 1, i - 1) == "\n" then
            lineStart = i
            break
        end
    end
    if lineStart == pos then
        lineStart = 1
    end

    -- Find the end of the line containing pos
    local lineEnd = pos
    for i = pos, math.min(markdownLen, pos + 500) do
        if string.sub(markdown, i, i) == "\n" then
            lineEnd = i
            break
        end
    end
    if lineEnd == pos then
        lineEnd = markdownLen
    end

    -- Check if this line is a table line
    local lineContent = string.sub(markdown, lineStart, lineEnd - 1)
    local isOnTableLine = IsTableLine(lineContent)

    -- If pos is at a newline, also check if we're between table rows
    local isBetweenTableRows = false
    if string.sub(markdown, pos, pos) == "\n" and not isOnTableLine then
        -- Check if previous line is a table line
        local prevLineStart = lineStart
        if prevLineStart > 1 then
            for i = prevLineStart - 1, math.max(1, prevLineStart - 1000), -1 do
                if i == 1 or string.sub(markdown, i - 1, i - 1) == "\n" then
                    prevLineStart = i
                    break
                end
            end
            local prevLineEnd = lineStart - 1
            local prevLineContent = string.sub(markdown, prevLineStart, prevLineEnd - 1)
            local prevIsTableLine = IsTableLine(prevLineContent)

            -- Check if next line is a table line
            local nextLineStart = lineEnd + 1
            if nextLineStart <= markdownLen then
                -- Skip empty lines
                while nextLineStart <= markdownLen and string.sub(markdown, nextLineStart, nextLineStart) == "\n" do
                    nextLineStart = nextLineStart + 1
                end
                if nextLineStart <= markdownLen then
                    local nextLineEnd = nextLineStart
                    for i = nextLineStart, math.min(markdownLen, nextLineStart + 500) do
                        if string.sub(markdown, i, i) == "\n" then
                            nextLineEnd = i
                            break
                        end
                    end
                    local nextLineContent = string.sub(markdown, nextLineStart, nextLineEnd - 1)
                    local nextIsTableLine = IsTableLine(nextLineContent)

                    -- We're between table rows if both previous and next are table lines
                    isBetweenTableRows = prevIsTableLine and nextIsTableLine
                end
            end
        end
    end

    if not isOnTableLine and not isBetweenTableRows then
        return nil -- Not in a table
    end

    -- We're in a table - find where the table ends
    -- Search forward to find the end of the table (first non-table, non-empty line)
    local tableEnd = lineEnd
    local currentPos = lineEnd + 1
    local maxSearch = math.min(markdownLen, currentPos + 10000) -- Search up to 10k chars ahead

    while currentPos <= maxSearch do
        local nextNewline = nil
        for i = currentPos, maxSearch do
            if string.sub(markdown, i, i) == "\n" then
                nextNewline = i
                break
            end
        end

        if not nextNewline then
            -- Reached end of markdown - table ends here
            return markdownLen
        end

        local nextLineContent = string.sub(markdown, currentPos, nextNewline - 1)

        if IsTableLine(nextLineContent) then
            -- Still in table, continue
            tableEnd = nextNewline
            currentPos = nextNewline + 1
        elseif nextLineContent:match("^%s*$") then
            -- Empty line - table might continue after it, or it might be the end
            -- Check the next non-empty line
            local checkPos = nextNewline + 1
            while checkPos <= maxSearch do
                local checkNewline = nil
                for i = checkPos, maxSearch do
                    if string.sub(markdown, i, i) == "\n" then
                        checkNewline = i
                        break
                    end
                end
                if not checkNewline then
                    -- End of markdown
                    return markdownLen
                end
                local checkLine = string.sub(markdown, checkPos, checkNewline - 1)
                if not checkLine:match("^%s*$") then
                    -- Found non-empty line
                    if IsTableLine(checkLine) then
                        -- Table continues
                        tableEnd = checkNewline
                        currentPos = checkNewline + 1
                        break
                    else
                        -- Table ends at the empty line
                        return tableEnd
                    end
                end
                checkPos = checkNewline + 1
            end
            -- If we didn't find a non-empty line, table ends at empty line
            return tableEnd
        else
            -- Non-table, non-empty line - table ends before this
            return tableEnd
        end
    end

    -- If we reach here, table extends beyond search limit
    return tableEnd
end

-- Helper function to find a safe newline position that's not inside markdown structures
-- Returns the position of a safe newline, or nil if none found
-- Helper function to check if a newline position is right before a header
-- Returns true if the next non-empty line after newlinePos is a header
local function IsNewlineBeforeHeader(markdown, newlinePos, markdownLen)
    if newlinePos >= markdownLen then
        return false
    end

    -- Find the next non-empty line after this newline
    local nextLineStart = newlinePos + 1
    -- Skip empty lines
    while nextLineStart <= markdownLen and string.sub(markdown, nextLineStart, nextLineStart) == "\n" do
        nextLineStart = nextLineStart + 1
    end

    if nextLineStart > markdownLen then
        return false
    end

    -- Find the end of this line
    local nextLineEnd = nextLineStart
    for i = nextLineStart, math.min(markdownLen, nextLineStart + 200) do
        if string.sub(markdown, i, i) == "\n" then
            nextLineEnd = i
            break
        elseif i == markdownLen then
            nextLineEnd = markdownLen
            break
        end
    end

    -- Check if this line is a header (#### or #####)
    local nextLine = string.sub(markdown, nextLineStart, nextLineEnd - 1)
    return nextLine:match("^####%s") ~= nil or nextLine:match("^#####%s") ~= nil
end

-- Helper function to check if a position is inside a code block (```...```)
-- Returns a table with {blockStart, blockEnd} if inside one, nil otherwise
-- blockStart = position of newline BEFORE the opening ```
-- blockEnd = position of newline AFTER the closing ```
local function IsInsideCodeBlock(markdown, pos)
    local markdownLen = string.len(markdown)
    if pos < 1 or pos > markdownLen then
        return nil
    end

    -- OPTIMIZATION: Use pattern matching instead of character-by-character scanning
    -- to avoid O(n²) performance issues that can crash ESO

    -- Search backwards to find if we're inside a code block
    local searchStart = math.max(1, pos - 5000) -- Limit search window to 5k chars
    local beforePos = string.sub(markdown, searchStart, pos - 1)

    -- Find the LAST ``` before pos (opening marker)
    local lastBacktickPos = nil
    local searchPos = 1
    while true do
        local found = string.find(beforePos, "\n```", searchPos, true)
        if not found then
            break
        end
        lastBacktickPos = found
        searchPos = found + 1
    end

    -- Also check if document starts with ```
    local docStartsWithBacktick = false
    if string.sub(markdown, 1, 3) == "```" and pos > 3 then
        docStartsWithBacktick = true
    end

    -- If we found an opening ```, check if there's a closing one after it
    if lastBacktickPos or docStartsWithBacktick then
        local blockStart
        if docStartsWithBacktick and (not lastBacktickPos or searchStart == 1) then
            blockStart = 0 -- Document starts with code block
        else
            blockStart = searchStart + lastBacktickPos - 1 -- Absolute position of newline before ```
        end

        -- Now search forward from pos to find closing ```
        local afterPos = string.sub(markdown, pos, math.min(markdownLen, pos + 5000))
        local closingPos = string.find(afterPos, "\n```", 1, true)
        if closingPos then
            -- Found closing ```, return block boundaries
            local blockEnd = pos + closingPos + 3 -- Position after closing ```\n
            return { blockStart, blockEnd }
        else
            -- No closing ``` found - assume we're inside a block that extends beyond search window
            -- Return blockStart so we can split BEFORE the block
            return { blockStart, markdownLen }
        end
    end

    return nil
end
-- Helper function to get the Mermaid header (e.g., "graph TD" or "flowchart LR") from a block
-- This function handles blocks with %%{init:...}%% comments and empty lines before the directive
local function GetMermaidHeader(markdown, blockStart)
    -- blockStart is the newline before ```
    -- So ``` starts at blockStart + 1
    local markdownLen = string.len(markdown)
    
    -- Find the end of the line containing ```mermaid
    local lineEnd = string.find(markdown, "\n", blockStart + 1)
    if not lineEnd then
        return "flowchart LR" -- Default fallback
    end

    local firstLine = string.sub(markdown, blockStart + 1, lineEnd - 1)
    -- Check if header is on the same line: ```mermaid flowchart LR
    local sameLineHeader = firstLine:match("```mermaid%s+(.+)")
    if sameLineHeader then
        return sameLineHeader
    end

    -- Header is on a subsequent line - search up to 10 lines for a diagram directive
    -- (handles %%{init:...}%% comments and empty lines before the flowchart/graph directive)
    local currentLineStart = lineEnd + 1
    local headerLines = {} -- Collect init comments and directives
    
    for _ = 1, 10 do -- Search up to 10 lines
        if currentLineStart > markdownLen then
            break
        end
        
        local currentLineEnd = string.find(markdown, "\n", currentLineStart)
        if not currentLineEnd then
            currentLineEnd = markdownLen + 1
        end
        
        local line = string.sub(markdown, currentLineStart, currentLineEnd - 1)
        local trimmedLine = line:match("^%s*(.-)%s*$") or ""
        
        -- Check if this line is a diagram directive (flowchart, graph, sequenceDiagram, etc.)
        if trimmedLine:match("^flowchart") or 
           trimmedLine:match("^graph%s") or 
           trimmedLine:match("^sequenceDiagram") or
           trimmedLine:match("^gantt") or
           trimmedLine:match("^classDiagram") or
           trimmedLine:match("^stateDiagram") or
           trimmedLine:match("^erDiagram") or
           trimmedLine:match("^pie") or
           trimmedLine:match("^journey") then
            -- Found the diagram directive - collect everything before it plus the directive
            table.insert(headerLines, line)
            return table.concat(headerLines, "\n")
        elseif trimmedLine:match("^%%") then
            -- This is a mermaid comment (like %%{init:...}%%) - include it
            table.insert(headerLines, line)
        elseif trimmedLine == "" then
            -- Empty line - include it but keep searching
            table.insert(headerLines, line)
        else
            -- Unrecognized line - stop searching and return what we have plus this line
            table.insert(headerLines, line)
            return table.concat(headerLines, "\n")
        end
        
        currentLineStart = currentLineEnd + 1
    end

    -- Fallback if no directive found
    if #headerLines > 0 then
        return table.concat(headerLines, "\n")
    end
    return "flowchart LR"
end

local function FindSafeNewline(markdown, startPos, endPos)
    local markdownLen = string.len(markdown)
    endPos = math.min(endPos, markdownLen)

    -- Search backwards from endPos to startPos
    local i = endPos
    while i >= startPos do
        if string.sub(markdown, i, i) == "\n" then
            -- Check if this newline is inside a code block (CRITICAL: must check this first!)
            local codeBlock = IsInsideCodeBlock(markdown, i)
            if codeBlock then
                -- This newline is inside a code block
                local blockStart = codeBlock[1]

                -- Check if it's a Mermaid block
                local isMermaid, mStart, mEnd = IsInsideMermaidBlock(markdown, i)

                if isMermaid then
                    -- It is a Mermaid block. Check if we are inside a subgraph.
                    -- IsInsideMermaidBlock returns the innermost structure boundaries.
                    -- If mStart points to "subgraph", we are inside a subgraph.
                    -- If mStart points to "```mermaid", we are at top level.

                    -- Check the line at mStart
                    local checkLen = 20
                    local checkStr = string.sub(markdown, math.max(1, mStart), math.min(markdownLen, mStart + checkLen))

                    if checkStr:match("subgraph") then
                        -- Inside subgraph - NOT safe to split here.
                        -- Jump to before the subgraph starts
                        i = mStart - 1
                    else
                        -- Top level Mermaid block - SAFE to split here!
                        -- Return this position
                        return i
                    end
                else
                    -- Not a Mermaid block (or logic failed) - standard behavior
                    -- CRITICAL: Search BACKWARDS to split BEFORE the code block, not after
                    -- (Code blocks can be huge - 474+ lines - can't keep them in one chunk)

                    -- Jump to before the code block and continue searching
                    i = blockStart - 1
                end

                if i < startPos then
                    -- Can't split before the block within our search range
                    break
                end
            else
                -- Check if this newline is inside a table
                local tableEnd = IsInsideTable(markdown, i)
                if tableEnd then
                    -- This newline is inside a table, skip to after the table
                    if tableEnd < endPos then
                        -- Try to find a newline after the table
                        for j = tableEnd + 1, math.min(markdownLen, tableEnd + 200) do
                            if string.sub(markdown, j, j) == "\n" then
                                -- Check if this newline is before a header
                                if not IsNewlineBeforeHeader(markdown, j, markdownLen) then
                                    return j
                                end
                            end
                        end
                    end
                    -- If we can't find a newline after the table, skip past the table
                    -- and continue searching backwards from before the table
                    i = tableEnd - 1
                    if i < startPos then
                        break
                    end
                else
                    -- Check if this newline is inside a markdown link
                    local linkEnd = IsInsideMarkdownLink(markdown, i)
                    if linkEnd then
                        -- This newline is inside a link, skip to after the link
                        if linkEnd < endPos then
                            -- Try to find a newline after the link
                            for j = linkEnd + 1, math.min(markdownLen, linkEnd + 200) do
                                if string.sub(markdown, j, j) == "\n" then
                                    -- Check if this newline is before a header
                                    if not IsNewlineBeforeHeader(markdown, j, markdownLen) then
                                        return j
                                    end
                                end
                            end
                        end
                        -- If we can't find a newline after the link, continue searching backwards
                        i = i - 1
                    else
                        -- Check if this newline is right before a header
                        if not IsNewlineBeforeHeader(markdown, i, markdownLen) then
                            -- This newline is safe to use (not before a header, not in table/link)
                            return i
                        else
                            -- This newline is before a header, skip it and continue searching
                            i = i - 1
                        end
                    end
                end
            end -- Close the code block else block
        else
            i = i - 1
        end
    end

    return nil
end

-- Helper function to find the end of a table starting at a given position
local function FindTableEnd(markdown, startPos, maxSearch)
    local markdownLen = string.len(markdown)
    local searchEnd = math.min(startPos + maxSearch, markdownLen)

    local lineStart = startPos
    for i = startPos, math.max(1, startPos - 1000), -1 do
        if i == 1 or string.sub(markdown, i - 1, i - 1) == "\n" then
            lineStart = i
            break
        end
    end

    local line = string.sub(markdown, lineStart, startPos - 1)
    if not IsTableLine(line) then
        return nil
    end

    local lastTableLineEnd = startPos
    local currentPos = startPos + 1

    while currentPos <= searchEnd do
        local nextNewline = nil
        for i = currentPos, searchEnd do
            if string.sub(markdown, i, i) == "\n" then
                nextNewline = i
                break
            end
        end

        if not nextNewline then
            break
        end

        local lineContent = string.sub(markdown, currentPos, nextNewline - 1)

        if IsTableLine(lineContent) then
            lastTableLineEnd = nextNewline
            currentPos = nextNewline + 1
        elseif lineContent:match("^%s*$") then
            return lastTableLineEnd
        else
            return lastTableLineEnd
        end
    end

    if lastTableLineEnd <= markdownLen and string.sub(markdown, lastTableLineEnd, lastTableLineEnd) == "\n" then
        return lastTableLineEnd
    else
        return startPos
    end
end

-- =====================================================
-- PADDING UTILITIES
-- =====================================================

-- Strip padding from chunk content for paste/copy operations
-- Padding format: content + 85 spaces + newline + newline
-- This function removes the padding that was added during chunking
local function StripPadding(content, isLastChunk)
    if not content or content == "" then
        return content
    end

    local CHUNKING = CM.constants.CHUNKING

    local stripped = content

    -- Strip chunk marker at the beginning (e.g., "<!-- Chunk 1 (20448 bytes before padding) -->\n\n")
    -- Pattern matches: <!-- Chunk N (optional text) --> followed by optional whitespace/newlines
    stripped = stripped:gsub("^%s*<!%-%-%s*Chunk%s+%d+%s*%([^%)]*%)%s*-%->%s*\n*\n*", "")

    -- Early return if padding is disabled - only chunk marker was stripped
    if CHUNKING.DISABLE_PADDING then
        CM.DebugPrint(
            "CHUNKING",
            string.format(
                "StripPadding: removed chunk marker (original: %d bytes, stripped: %d bytes)",
                string.len(content),
                string.len(stripped)
            )
        )
        return stripped
    end

    -- For newline padding: just normalize excessive trailing newlines to 1-2
    -- We can't reliably detect "padding newlines" vs "content newlines", so just normalize
    -- Markdown renderers ignore excessive newlines anyway, but this keeps output clean
    stripped = stripped:gsub("\n\n+$", "\n\n") -- Collapse 3+ trailing newlines to 2

    CM.DebugPrint(
        "CHUNKING",
        string.format(
            "StripPadding: removed chunk marker and normalized trailing newlines (original: %d bytes, stripped: %d bytes)",
            string.len(content),
            string.len(stripped)
        )
    )

    return stripped
end

-- =====================================================
-- MAIN CHUNKING FUNCTION
-- =====================================================

-- Split markdown into chunks with conservative padding to prevent truncation
-- This is the consolidated, best implementation that handles:
-- 1. Tables and lists properly (doesn't split in the middle)
-- 2. Padding to prevent truncation
-- 3. Extensive safety checks
-- 4. Always ends on complete lines
local function SplitMarkdownIntoChunks_Legacy(markdown)
    -- Legacy chunking is the current stable implementation (section-based is experimental/buggy)
    CM.DebugPrint("CHUNKING", "Using legacy chunking algorithm (section-based disabled)")

    local chunks = {}
    local markdownLength = string.len(markdown)
    local maxDataChars = CHUNKING.MAX_DATA_CHARS
    local editboxLimit = CHUNKING.EDITBOX_LIMIT
    local copyLimit = CHUNKING.COPY_LIMIT or (editboxLimit - 300)

    -- Calculate overhead for padding + HTML marker + potential mermaid header
    -- When disabled: only account for marker, no padding
    -- When enabled: account for both marker and padding
    local markerSize = 60 -- Reserve space for HTML comment marker "<!-- Chunk N (XXXXX bytes before padding) -->\n\n"
    -- Reserve space for potential mermaid header (continuation chunks may need this)
    -- Header can include: "```mermaid\n" + "%%{init:...}%%\n" + empty line + "flowchart LR\n"
    local mermaidHeaderReserve = 350 -- Conservative estimate for large init configs
    local paddingSize = 0 -- Default: no padding
    if not CHUNKING.DISABLE_PADDING then
        paddingSize = (CHUNKING.SPACE_PADDING_SIZE or 500) -- newlines for padding
    end
    local totalOverhead = markerSize + paddingSize + mermaidHeaderReserve -- Total bytes to reserve


    if markdownLength <= maxDataChars then
        return { { content = markdown } }
    end

    -- Split into chunks, always ending on complete lines
    local chunkNum = 1
    local pos = 1
    local prependNewlineToChunk = false -- Track if next chunk needs a leading newline
    local prependMermaidHeader = nil -- Track if next chunk needs a Mermaid header

    while pos <= markdownLength do
        -- Calculate safe boundaries for this chunk
        -- Use COPY_LIMIT to ensure chunks can be copied safely

        -- First, calculate potential end without padding to determine if this is the last chunk
        local initialEffectiveMaxData = math.min(maxDataChars, copyLimit)
        local initialPotentialEnd = math.min(pos + initialEffectiveMaxData - 1, markdownLength)
        local isLastChunk = (initialPotentialEnd >= markdownLength)

        -- Reserve space for marker + padding on all chunks (including last chunk)
        -- Marker + padding help prevent paste truncation and provide chunk identification
        local maxSafeDataSize = copyLimit - totalOverhead
        local effectiveMaxData = math.min(maxDataChars, maxSafeDataSize)
        local maxSafeSize = copyLimit
        -- CRITICAL: Ensure we never exceed maxSafeDataSize (not maxSafeSize) for data content
        local potentialEnd = math.min(pos + effectiveMaxData - 1, markdownLength)
        local chunkEnd = potentialEnd
        local foundNewline = false
        -- Recalculate isLastChunk after adjusting for padding
        isLastChunk = (potentialEnd >= markdownLength)

        -- Helper function to validate chunk size after backtracking
        -- Returns true if the chunk at newEnd position (with marker + padding) fits within limits
        local function ValidateChunkSizeAfterBacktrack(newEnd)
            if newEnd < pos then
                return false -- Can't backtrack before start
            end
            local dataSize = newEnd - pos + 1
            local totalSize = dataSize + totalOverhead
            -- Always ensure chunk fits within limits (even for last chunk)
            if isLastChunk then
                -- For last chunk, allow it to be close to limit but not exceed it
                return dataSize > 0 and totalSize <= copyLimit
            else
                -- For non-last chunks, ensure total size (data + padding) fits within copyLimit
                -- But also ensure we have a reasonable minimum chunk size
                return totalSize <= copyLimit and dataSize >= 100 -- Minimum 100 chars to avoid tiny chunks
            end
        end

        -- CRITICAL: Check if we're inside a Mermaid block or HTML block
        isInsideMermaid, mermaidBlockStart, mermaidBlockEnd = IsInsideMermaidBlock(markdown, potentialEnd)
        local isInsideHtml, htmlBlockStart, htmlBlockEnd = IsInsideHtmlBlock(markdown, potentialEnd)

        if potentialEnd < markdownLength then
            local searchStart = math.max(pos, potentialEnd - 1000)

            -- CONSERVATIVE: Before finding a newline, check if we're about to enter a table/list/Mermaid block
            -- If so, and it won't fit, stop the chunk before it starts
            -- CRITICAL: Also check if we're on the line IMMEDIATELY BEFORE a table - never chunk there
            -- CRITICAL: Never split Mermaid code blocks - they must be contiguous
            local lookAheadStart = potentialEnd + 1
            local lookAheadEnd = math.min(potentialEnd + 500, markdownLength) -- Check up to 500 chars ahead
            local foundUpcomingStructure = false
            local structureStartPos = nil
            local isBeforeTable = false
            local tableStartPos = nil
            local isInsideMermaid = false
            local mermaidBlockStart = nil
            local mermaidBlockEnd = nil

            -- Skip empty lines and check for upcoming table/list
            local checkPos = lookAheadStart
            while checkPos <= lookAheadEnd do
                if string.sub(markdown, checkPos, checkPos) == "\n" then
                    checkPos = checkPos + 1
                else
                    -- Find the end of this line
                    local lineEnd = checkPos
                    for i = checkPos, math.min(lookAheadEnd, checkPos + 500) do
                        if string.sub(markdown, i, i) == "\n" then
                            lineEnd = i
                            break
                        end
                    end

                    local line = string.sub(markdown, checkPos, lineEnd - 1)
                    -- CRITICAL: Check if this is a header line (#### or #####)
                    -- If so, we should end the chunk before it to avoid truncating headers
                    if line:match("^####%s") then
                        -- Found a category header (####) - end chunk before it to avoid truncation
                        -- Also check if there's a subcategory header (#####) right after it
                        -- If so, we need to keep them together
                        local nextLineAfterHeader = lineEnd + 1
                        -- Skip empty lines
                        while
                            nextLineAfterHeader <= markdownLength
                            and string.sub(markdown, nextLineAfterHeader, nextLineAfterHeader) == "\n"
                        do
                            nextLineAfterHeader = nextLineAfterHeader + 1
                        end
                        if nextLineAfterHeader <= markdownLength then
                            local nextLineEnd = nextLineAfterHeader
                            for i = nextLineAfterHeader, math.min(markdownLength, nextLineAfterHeader + 100) do
                                if string.sub(markdown, i, i) == "\n" then
                                    nextLineEnd = i
                                    break
                                elseif i == markdownLength then
                                    nextLineEnd = markdownLength
                                    break
                                end
                            end
                            local nextLine = string.sub(markdown, nextLineAfterHeader, nextLineEnd - 1)
                            if nextLine:match("^#####%s") then
                                -- Category header followed by subcategory - keep them together
                                -- End chunk before the category header
                                foundUpcomingStructure = true
                                structureStartPos = checkPos
                                CM.DebugPrint(
                                    "CHUNKING",
                                    string.format(
                                        "Chunk %d: Found upcoming category+subcategory headers at %d, ending chunk before them to avoid truncation",
                                        chunkNum,
                                        checkPos
                                    )
                                )
                                break -- Found headers, stop looking
                            else
                                -- Just a category header without immediate subcategory
                                foundUpcomingStructure = true
                                structureStartPos = checkPos
                                CM.DebugPrint(
                                    "CHUNKING",
                                    string.format(
                                        "Chunk %d: Found upcoming category header at %d, ending chunk before it to avoid truncation",
                                        chunkNum,
                                        checkPos
                                    )
                                )
                                break -- Found header, stop looking
                            end
                        else
                            -- Just a category header
                            foundUpcomingStructure = true
                            structureStartPos = checkPos
                            CM.DebugPrint(
                                "CHUNKING",
                                string.format(
                                    "Chunk %d: Found upcoming category header at %d, ending chunk before it to avoid truncation",
                                    chunkNum,
                                    checkPos
                                )
                            )
                            break -- Found header, stop looking
                        end
                    elseif line:match("^#####%s") then
                        -- Found a subcategory header (#####) without a category header before it
                        -- This is a problem - we should have ended before the category header
                        -- Check if there's a category header in the previous chunk
                        foundUpcomingStructure = true
                        structureStartPos = checkPos
                        CM.DebugPrint(
                            "CHUNKING",
                            string.format(
                                "Chunk %d: Found upcoming subcategory header at %d (missing category header?), ending chunk before it",
                                chunkNum,
                                checkPos
                            )
                        )
                        break -- Found header, stop looking
                    -- Check for Mermaid code block start or subgraph
                    -- Note: Mermaid blocks can be chunked normally (no special restrictions)
                    elseif IsTableLine(line) then
                        -- Found a table starting - CRITICAL: Never chunk on the line before a table
                        tableStartPos = checkPos
                        isBeforeTable = true
                        -- Find the table end to see if we can include it
                        local structureEnd = FindTableEnd(markdown, lineEnd, 10000)
                        if structureEnd then
                            local structureSize = structureEnd - checkPos + 1
                            local chunkWithStructure = (checkPos - pos) + structureSize
                            -- CRITICAL FIX: No overage allowance - strict size enforcement
                            local effectiveMaxForStructures = maxSafeDataSize
                            -- If adding this table would exceed the limit, stop chunk before it
                            if chunkWithStructure > effectiveMaxForStructures then
                                foundUpcomingStructure = true
                                structureStartPos = checkPos
                            end
                        end
                        break -- Found table, stop looking
                    elseif IsListLine(line) then
                        -- Found a list starting soon - check if it will fit
                        -- CRITICAL FIX: No overage allowance - strict size enforcement
                        local effectiveMaxForStructures = maxSafeDataSize

                        local structureEnd = FindListEnd(markdown, lineEnd, 10000)
                        if structureEnd then
                            local structureSize = structureEnd - checkPos + 1
                            local chunkWithStructure = (checkPos - pos) + structureSize
                            -- If adding this structure would exceed the limit, stop chunk before it
                            if chunkWithStructure > effectiveMaxForStructures then
                                foundUpcomingStructure = true
                                structureStartPos = checkPos
                                break
                            end
                        end
                    end

                    checkPos = lineEnd + 1
                end
            end

            -- CRITICAL: If we're on the line immediately before a table, we MUST extend or backtrack
            -- Never allow chunking on the line before a table starts
            -- If that line is a header (starts with #), chunk BEFORE the header so header+table stay together
            if isBeforeTable and tableStartPos then
                -- Find the line before the table (the one we're currently on)
                local lineBeforeTableStart = tableStartPos
                for i = tableStartPos - 1, math.max(pos, tableStartPos - 1000), -1 do
                    if i == pos or string.sub(markdown, i - 1, i - 1) == "\n" then
                        lineBeforeTableStart = (i == pos) and pos or i
                        break
                    end
                end
                local lineBeforeTableEnd = tableStartPos - 1
                local lineBeforeTable = string.sub(markdown, lineBeforeTableStart, lineBeforeTableEnd)

                -- Check if the line before the table is a header (starts with #)
                local isHeaderBeforeTable = lineBeforeTable:match("^#+%s") ~= nil

                -- Check if we can extend to include the table (and header if present)
                local tableLineEnd = tableStartPos
                for i = tableStartPos, math.min(markdownLength, tableStartPos + 500) do
                    if string.sub(markdown, i, i) == "\n" then
                        tableLineEnd = i
                        break
                    end
                end
                local tableEnd = FindTableEnd(markdown, tableLineEnd, 10000)
                if tableEnd then
                    -- Include header in size calculation if present
                    local contentStart = isHeaderBeforeTable and lineBeforeTableStart or tableStartPos
                    local tableChunkSize = tableEnd - contentStart + 1
                    -- CRITICAL FIX: No overage allowance - strict size enforcement
                    local effectiveMaxForStructures = maxSafeDataSize

                    if tableChunkSize <= effectiveMaxForStructures then
                        -- CRITICAL FIX: Validate final chunk size before accepting extension
                        local proposedChunkSize = tableEnd - pos + 1
                        if proposedChunkSize + paddingSize <= copyLimit then
                            -- Can include the table (and header) - extend to table end
                            chunkEnd = tableEnd
                            foundNewline = true
                            CM.DebugPrint(
                                "CHUNKING",
                                string.format(
                                    "Chunk %d: Extending to include %stable starting at %d (ends at %d, size: %d + %d padding = %d)",
                                    chunkNum,
                                    isHeaderBeforeTable and "header+" or "",
                                    tableStartPos,
                                    tableEnd,
                                    proposedChunkSize,
                                    paddingSize,
                                    proposedChunkSize + paddingSize
                                )
                            )
                        else
                            CM.DebugPrint(
                                "CHUNKING",
                                string.format(
                                    "Chunk %d: Table extension would exceed copy limit (%d + %d = %d > %d), skipping",
                                    chunkNum,
                                    proposedChunkSize,
                                    paddingSize,
                                    proposedChunkSize + paddingSize,
                                    copyLimit
                                )
                            )
                            -- Don't extend - will use backtracking logic below
                        end
                    else
                        -- Can't include table - backtrack to before the header (or before the line before table)
                        if isHeaderBeforeTable then
                            -- Backtrack to before the header so header+table stay together
                            for i = lineBeforeTableStart - 1, math.max(pos, lineBeforeTableStart - 1000), -1 do
                                if i == pos or string.sub(markdown, i - 1, i - 1) == "\n" then
                                    local newEnd = (i == pos) and pos or (i - 1)
                                    -- CRITICAL FIX: Validate size before accepting backtrack
                                    if ValidateChunkSizeAfterBacktrack(newEnd) then
                                        chunkEnd = newEnd
                                        foundNewline = true
                                        CM.DebugPrint(
                                            "CHUNKING",
                                            string.format(
                                                "Chunk %d: Backtracked from %d to %d to keep header+table together",
                                                chunkNum,
                                                potentialEnd,
                                                chunkEnd
                                            )
                                        )
                                        break
                                    else
                                        CM.DebugPrint(
                                            "CHUNKING",
                                            string.format(
                                                "Chunk %d: Cannot backtrack to %d (would violate size constraints), trying previous position",
                                                chunkNum,
                                                newEnd
                                            )
                                        )
                                        -- Continue loop to try previous position
                                    end
                                end
                            end
                        else
                            -- Not a header, just backtrack to before the line before table
                            for i = lineBeforeTableStart - 1, math.max(pos, lineBeforeTableStart - 1000), -1 do
                                if i == pos or string.sub(markdown, i - 1, i - 1) == "\n" then
                                    local newEnd = (i == pos) and pos or (i - 1)
                                    -- CRITICAL FIX: Validate size before accepting backtrack
                                    if ValidateChunkSizeAfterBacktrack(newEnd) then
                                        chunkEnd = newEnd
                                        foundNewline = true
                                        CM.DebugPrint(
                                            "CHUNKING",
                                            string.format(
                                                "Chunk %d: Backtracked from %d to %d to avoid chunking on line before table",
                                                chunkNum,
                                                potentialEnd,
                                                chunkEnd
                                            )
                                        )
                                        break
                                    else
                                        CM.DebugPrint(
                                            "CHUNKING",
                                            string.format(
                                                "Chunk %d: Cannot backtrack to %d (would violate size constraints), trying previous position",
                                                chunkNum,
                                                newEnd
                                            )
                                        )
                                        -- Continue loop to try previous position
                                    end
                                end
                            end
                        end
                    end
                else
                    -- Can't find table end - backtrack to be safe
                    if isHeaderBeforeTable then
                        -- Backtrack to before the header
                        for i = lineBeforeTableStart - 1, math.max(pos, lineBeforeTableStart - 1000), -1 do
                            if i == pos or string.sub(markdown, i - 1, i - 1) == "\n" then
                                local newEnd = (i == pos) and pos or (i - 1)
                                -- CRITICAL FIX: Validate size before accepting backtrack
                                if ValidateChunkSizeAfterBacktrack(newEnd) then
                                    chunkEnd = newEnd
                                    foundNewline = true
                                    CM.DebugPrint(
                                        "CHUNKING",
                                        string.format(
                                            "Chunk %d: Backtracked to before header to keep header+table together (table end not found)",
                                            chunkNum
                                        )
                                    )
                                    break
                                else
                                    CM.DebugPrint(
                                        "CHUNKING",
                                        string.format(
                                            "Chunk %d: Cannot backtrack to %d (would violate size constraints), trying previous position",
                                            chunkNum,
                                            newEnd
                                        )
                                    )
                                    -- Continue loop to try previous position
                                end
                            end
                        end
                    else
                        -- Not a header, just backtrack
                        for i = lineBeforeTableStart - 1, math.max(pos, lineBeforeTableStart - 1000), -1 do
                            if i == pos or string.sub(markdown, i - 1, i - 1) == "\n" then
                                local newEnd = (i == pos) and pos or (i - 1)
                                -- CRITICAL FIX: Validate size before accepting backtrack
                                if ValidateChunkSizeAfterBacktrack(newEnd) then
                                    chunkEnd = newEnd
                                    foundNewline = true
                                    CM.DebugPrint(
                                        "CHUNKING",
                                        string.format(
                                            "Chunk %d: Backtracked to avoid chunking on line before table (table end not found)",
                                            chunkNum
                                        )
                                    )
                                    break
                                else
                                    CM.DebugPrint(
                                        "CHUNKING",
                                        string.format(
                                            "Chunk %d: Cannot backtrack to %d (would violate size constraints), trying previous position",
                                            chunkNum,
                                            newEnd
                                        )
                                    )
                                    -- Continue loop to try previous position
                                end
                            end
                        end
                    end
                end
            end

            -- If we found an upcoming structure that won't fit, stop chunk before it
            if foundUpcomingStructure and structureStartPos and not isBeforeTable then
                -- Find the last newline before the structure starts, but validate padding size
                for i = structureStartPos - 1, math.max(pos, structureStartPos - 1000), -1 do
                    if string.sub(markdown, i, i) == "\n" then
                        local newEnd = i
                        -- Validate that this chunk size (with padding) will fit
                        if ValidateChunkSizeAfterBacktrack(newEnd) then
                            chunkEnd = newEnd
                            foundNewline = true
                            CM.DebugPrint(
                                "CHUNKING",
                                string.format(
                                    "Chunk %d: Stopping before upcoming structure at %d (would exceed limit)",
                                    chunkNum,
                                    structureStartPos
                                )
                            )
                            break
                        else
                            -- Can't end here - try to find a closer valid position
                            CM.DebugPrint(
                                "CHUNKING",
                                string.format(
                                    "Chunk %d: WARNING - Cannot end at %d (would violate padding constraints), continuing search",
                                    chunkNum,
                                    newEnd
                                )
                            )
                            -- Continue searching for a valid position
                        end
                    end
                end
            end

            -- Use FindSafeNewline to avoid splitting inside markdown links
            if not foundNewline then
                local safeNewline = FindSafeNewline(markdown, searchStart, potentialEnd)
                if safeNewline then
                    chunkEnd = safeNewline
                    foundNewline = true
                else
                    -- Fallback to regular newline search if no safe newline found
                    -- But still check for headers and links to avoid truncation
                    for i = potentialEnd, searchStart, -1 do
                        if string.sub(markdown, i, i) == "\n" then
                            -- Check if this newline is right before a header
                            if not IsNewlineBeforeHeader(markdown, i, markdownLength) then
                                -- CRITICAL: Also check if this newline is inside a markdown link
                                if not IsInsideMarkdownLink(markdown, i) then
                                    chunkEnd = i
                                    foundNewline = true
                                    break
                                end
                            end
                            -- If it's before a header or inside a link, continue searching for a better position
                        end
                    end
                end
            end

            if not foundNewline and potentialEnd > pos then
                local extendedSearchStart = math.max(pos, potentialEnd - 5000)
                -- Try safe newline search in extended range
                local safeNewline = FindSafeNewline(markdown, extendedSearchStart, potentialEnd)
                if safeNewline then
                    chunkEnd = safeNewline
                    foundNewline = true
                else
                    -- Fallback to regular newline search
                    -- But still check for headers and links to avoid truncation
                    for i = potentialEnd, extendedSearchStart, -1 do
                        if string.sub(markdown, i, i) == "\n" then
                            -- Check if this newline is right before a header
                            if not IsNewlineBeforeHeader(markdown, i, markdownLength) then
                                -- CRITICAL: Also check if this newline is inside a markdown link
                                if not IsInsideMarkdownLink(markdown, i) then
                                    chunkEnd = i
                                    foundNewline = true
                                    break
                                end
                            end
                            -- If it's before a header or inside a link, continue searching for a better position
                        end
                    end
                end
            end
        elseif isLastChunk then
            -- For last chunk, find the last newline before the end
            -- But still check for headers to avoid truncation
            local searchStart = math.max(pos, markdownLength - 1000)
            for i = markdownLength, searchStart, -1 do
                if string.sub(markdown, i, i) == "\n" then
                    -- Check if this newline is right before a header
                    if not IsNewlineBeforeHeader(markdown, i, markdownLength) then
                        chunkEnd = i
                        foundNewline = true
                        break
                    end
                    -- If it's before a header, continue searching for a better position
                end
            end
            -- If no newline found, chunkEnd stays at markdownLength
        end

        -- Note: Mermaid blocks can be chunked normally (no special restrictions)
        -- Previously we tried to keep subgraphs contiguous, but that's not necessary

        -- CRITICAL: Check if chunkEnd is in the middle of a header line (starts with #)
        -- If so, backtrack to before the header starts or extend to after it ends
        local isInHeaderLine = false
        local headerLineStart = nil
        local headerLineEnd = nil
        if chunkEnd > 1 and chunkEnd < markdownLength then
            -- Find the start of the current line
            local lineStart = chunkEnd
            for i = chunkEnd, math.max(pos, chunkEnd - 500), -1 do
                if i == pos or string.sub(markdown, i - 1, i - 1) == "\n" then
                    lineStart = (i == pos) and pos or i
                    break
                end
            end

            -- Find the end of the current line
            local lineEnd = chunkEnd
            for i = chunkEnd, math.min(markdownLength, chunkEnd + 500) do
                if string.sub(markdown, i, i) == "\n" then
                    lineEnd = i
                    break
                elseif i == markdownLength then
                    lineEnd = markdownLength
                    break
                end
            end

            -- Check if this line is a header (starts with # followed by space)
            local line = string.sub(markdown, lineStart, lineEnd - 1)
            if line:match("^#+%s") then
                -- This is a header line
                -- Check if it has too many # characters (more than 6 indicates merging)
                local headerMatch = line:match("^(#+)%s")
                if headerMatch and string.len(headerMatch) > 6 then
                    -- Header has too many # characters - likely merged headers
                    -- This happens when category header (####) and subcategory header (#####) get merged
                    isInHeaderLine = true
                    headerLineStart = lineStart
                    headerLineEnd = lineEnd
                    CM.DebugPrint(
                        "CHUNKING",
                        string.format(
                            "Chunk %d: Detected merged header with %d # characters at %d (should be 4 or 5)",
                            chunkNum,
                            string.len(headerMatch),
                            lineStart
                        )
                    )
                elseif chunkEnd > lineStart and chunkEnd < lineEnd then
                    -- chunkEnd is in the middle of the header line
                    isInHeaderLine = true
                    headerLineStart = lineStart
                    headerLineEnd = lineEnd
                elseif chunkEnd == lineEnd - 1 or chunkEnd == lineEnd then
                    -- chunkEnd is right at the end of a header line
                    -- Check if next line is also a header (would indicate missing category header)
                    local nextLineStart = lineEnd + 1
                    while
                        nextLineStart <= markdownLength
                        and string.sub(markdown, nextLineStart, nextLineStart) == "\n"
                    do
                        nextLineStart = nextLineStart + 1
                    end
                    if nextLineStart <= markdownLength then
                        local nextLineEnd = nextLineStart
                        for i = nextLineStart, math.min(markdownLength, nextLineStart + 200) do
                            if string.sub(markdown, i, i) == "\n" then
                                nextLineEnd = i
                                break
                            elseif i == markdownLength then
                                nextLineEnd = markdownLength
                                break
                            end
                        end
                        local nextLine = string.sub(markdown, nextLineStart, nextLineEnd - 1)
                        -- If current line is a subcategory (#####) and next line is also a header, we might be missing a category header
                        if line:match("^#####%s") and (nextLine:match("^####%s") or nextLine:match("^#####%s")) then
                            -- Ending right after a subcategory header - might be missing category header in next chunk
                            -- Backtrack to before this subcategory header to keep it with its category
                            isInHeaderLine = true
                            headerLineStart = lineStart
                            headerLineEnd = lineEnd
                            CM.DebugPrint(
                                "CHUNKING",
                                string.format(
                                    "Chunk %d: Ending right after subcategory header at %d, next line is also header - backtracking to prevent missing category header",
                                    chunkNum,
                                    lineStart
                                )
                            )
                        end
                    end
                end
            end

            -- CRITICAL: Also check if chunkEnd is right before what looks like a header continuation
            -- This catches cases where "Character" gets truncated to "Chara" and merged with "#####"
            if chunkEnd >= lineStart and chunkEnd <= lineEnd then
                -- Check if the line after this one starts with ##### (subcategory header)
                -- and if the current line ends with a partial word (suggesting truncation)
                local nextLineStart = lineEnd + 1
                -- Skip empty lines
                while nextLineStart <= markdownLength and string.sub(markdown, nextLineStart, nextLineStart) == "\n" do
                    nextLineStart = nextLineStart + 1
                end
                if nextLineStart <= markdownLength then
                    local nextLineEnd = nextLineStart
                    for i = nextLineStart, math.min(markdownLength, nextLineStart + 100) do
                        if string.sub(markdown, i, i) == "\n" then
                            nextLineEnd = i
                            break
                        elseif i == markdownLength then
                            nextLineEnd = markdownLength
                            break
                        end
                    end
                    local nextLine = string.sub(markdown, nextLineStart, nextLineEnd - 1)
                    -- Check if next line is a ##### header (subcategory)
                    if nextLine:match("^#####%s") then
                        -- Check if current line looks like a truncated header (ends with partial word)
                        local currentLine = string.sub(markdown, lineStart, chunkEnd)
                        -- Check if we're ending right after "#### " (empty header) or in the middle of a category name
                        if currentLine:match("^####%s*$") then
                            -- Empty header - category name is missing
                            isInHeaderLine = true
                            headerLineStart = lineStart
                            headerLineEnd = lineEnd
                            CM.DebugPrint(
                                "CHUNKING",
                                string.format(
                                    "Chunk %d: Detected empty header at %d (category name missing before ##### header)",
                                    chunkNum,
                                    chunkEnd
                                )
                            )
                        elseif currentLine:match("%w+$") and not currentLine:match("%s+$") then
                            -- Current line ends with a partial word - likely truncated header
                            -- Check if the full line would be a valid header
                            local fullLine = string.sub(markdown, lineStart, lineEnd - 1)
                            if fullLine:match("^####%s+") then
                                -- This is a header line that got truncated
                                isInHeaderLine = true
                                headerLineStart = lineStart
                                headerLineEnd = lineEnd
                                CM.DebugPrint(
                                    "CHUNKING",
                                    string.format(
                                        "Chunk %d: Detected truncated header at %d (ends with partial word '%s' before ##### header)",
                                        chunkNum,
                                        chunkEnd,
                                        currentLine:match("(%w+)$") or ""
                                    )
                                )
                            end
                        end
                    end
                end
            end
        end

        if isInHeaderLine and headerLineStart then
            -- Backtrack to before the header line, but validate padding size
            for i = headerLineStart - 1, math.max(pos, headerLineStart - 1000), -1 do
                if i == pos or string.sub(markdown, i - 1, i - 1) == "\n" then
                    local newEnd = (i == pos) and pos or (i - 1)
                    if ValidateChunkSizeAfterBacktrack(newEnd) then
                        chunkEnd = newEnd
                        foundNewline = true
                        CM.DebugPrint(
                            "CHUNKING",
                            string.format(
                                "Chunk %d: Backtracked to %d to avoid splitting header line (header starts at %d)",
                                chunkNum,
                                chunkEnd,
                                headerLineStart
                            )
                        )
                        break
                    else
                        -- Can't backtrack that far - keep original position but log warning
                        CM.DebugPrint(
                            "CHUNKING",
                            string.format(
                                "Chunk %d: WARNING - Cannot backtrack to %d (would violate padding constraints), keeping chunkEnd at %d",
                                chunkNum,
                                newEnd,
                                chunkEnd
                            )
                        )
                        break
                    end
                end
            end
        end

        -- CRITICAL: Check if chunkEnd is right after a header line and next chunk starts with a header
        -- This prevents headers from merging when chunks are concatenated
        if chunkEnd < markdownLength and foundNewline then
            -- Check if the line ending at chunkEnd is a header
            local prevLineStart = chunkEnd
            for i = chunkEnd - 1, math.max(pos, chunkEnd - 500), -1 do
                if i == pos or string.sub(markdown, i - 1, i - 1) == "\n" then
                    prevLineStart = (i == pos) and pos or i
                    break
                end
            end
            local prevLine = string.sub(markdown, prevLineStart, chunkEnd - 1)
            local isPrevLineHeader = prevLine:match("^#+%s") ~= nil

            -- Check if the next line (after chunkEnd) is also a header
            local nextLineStart = chunkEnd + 1
            -- Skip empty lines
            while nextLineStart <= markdownLength and string.sub(markdown, nextLineStart, nextLineStart) == "\n" do
                nextLineStart = nextLineStart + 1
            end
            if nextLineStart <= markdownLength then
                local nextLineEnd = nextLineStart
                for i = nextLineStart, math.min(markdownLength, nextLineStart + 500) do
                    if string.sub(markdown, i, i) == "\n" then
                        nextLineEnd = i
                        break
                    elseif i == markdownLength then
                        nextLineEnd = markdownLength
                        break
                    end
                end
                local nextLine = string.sub(markdown, nextLineStart, nextLineEnd - 1)
                local isNextLineHeader = nextLine:match("^#+%s") ~= nil

                -- If both are headers, backtrack to before the first header to keep them together
                if isPrevLineHeader and isNextLineHeader then
                    for i = prevLineStart - 1, math.max(pos, prevLineStart - 1000), -1 do
                        if i == pos or string.sub(markdown, i - 1, i - 1) == "\n" then
                            local newEnd = (i == pos) and pos or (i - 1)
                            if ValidateChunkSizeAfterBacktrack(newEnd) then
                                chunkEnd = newEnd
                                foundNewline = true
                                CM.DebugPrint(
                                    "CHUNKING",
                                    string.format(
                                        "Chunk %d: Backtracked to %d to avoid merging headers (prev header at %d, next header at %d)",
                                        chunkNum,
                                        chunkEnd,
                                        prevLineStart,
                                        nextLineStart
                                    )
                                )
                                break
                            else
                                -- Can't backtrack that far - keep original position but log warning
                                CM.DebugPrint(
                                    "CHUNKING",
                                    string.format(
                                        "Chunk %d: WARNING - Cannot backtrack to %d (would violate padding constraints), keeping chunkEnd at %d",
                                        chunkNum,
                                        newEnd,
                                        chunkEnd
                                    )
                                )
                                break
                            end
                        end
                    end
                end
            end
        end

        -- CRITICAL: Check if chunkEnd is in the middle of an HTML tag
        -- If so, backtrack to before the tag starts
        local isInsideHtmlTag, htmlTagStart, htmlTagEnd = IsInsideHtmlTag(markdown, chunkEnd)
        if isInsideHtmlTag and htmlTagStart then
            -- Backtrack to before the HTML tag, but validate padding size
            for i = htmlTagStart - 1, math.max(pos, htmlTagStart - 1000), -1 do
                if i == pos or string.sub(markdown, i - 1, i - 1) == "\n" then
                    local newEnd = (i == pos) and pos or (i - 1)
                    if ValidateChunkSizeAfterBacktrack(newEnd) then
                        chunkEnd = newEnd
                        foundNewline = true
                        CM.DebugPrint(
                            "CHUNKING",
                            string.format(
                                "Chunk %d: Backtracked to %d to avoid splitting HTML tag (tag starts at %d)",
                                chunkNum,
                                chunkEnd,
                                htmlTagStart
                            )
                        )
                        break
                    else
                        -- Can't backtrack that far - keep original position but log warning
                        CM.DebugPrint(
                            "CHUNKING",
                            string.format(
                                "Chunk %d: WARNING - Cannot backtrack to %d (would violate padding constraints), keeping chunkEnd at %d",
                                chunkNum,
                                newEnd,
                                chunkEnd
                            )
                        )
                        break
                    end
                end
            end
        end

        -- CRITICAL: Check if chunkEnd is right before an incomplete HTML tag (like <div without >)
        -- This catches cases where the tag starts but doesn't have a closing >
        if chunkEnd < markdownLength then
            local nextChar = string.sub(markdown, chunkEnd + 1, chunkEnd + 1)
            if nextChar == "<" then
                -- Check if this is an incomplete HTML tag
                local tagEnd = chunkEnd + 1
                local foundClosingBracket = false
                for i = chunkEnd + 2, math.min(markdownLength, chunkEnd + 20) do
                    if string.sub(markdown, i, i) == ">" then
                        foundClosingBracket = true
                        break
                    elseif string.sub(markdown, i, i) == "\n" or string.sub(markdown, i, i) == "<" then
                        -- Found newline or another < before closing > - incomplete tag
                        break
                    end
                end
                if not foundClosingBracket then
                    -- Incomplete HTML tag - backtrack to before it, but validate padding size
                    for i = chunkEnd, math.max(pos, chunkEnd - 1000), -1 do
                        if i == pos or string.sub(markdown, i - 1, i - 1) == "\n" then
                            local newEnd = (i == pos) and pos or (i - 1)
                            if ValidateChunkSizeAfterBacktrack(newEnd) then
                                chunkEnd = newEnd
                                foundNewline = true
                                CM.DebugPrint(
                                    "CHUNKING",
                                    string.format(
                                        "Chunk %d: Backtracked to %d to avoid incomplete HTML tag",
                                        chunkNum,
                                        chunkEnd
                                    )
                                )
                                break
                            else
                                -- Can't backtrack that far - keep original position but log warning
                                CM.DebugPrint(
                                    "CHUNKING",
                                    string.format(
                                        "Chunk %d: WARNING - Cannot backtrack to %d (would violate padding constraints), keeping chunkEnd at %d",
                                        chunkNum,
                                        newEnd,
                                        chunkEnd
                                    )
                                )
                                break
                            end
                        end
                    end
                end
            end
        end

        -- CRITICAL: Also check if the next line (after chunkEnd) starts with an HTML tag
        -- This prevents splitting right before an HTML tag
        if chunkEnd < markdownLength and foundNewline then
            local nextLineStart = chunkEnd + 1
            -- Skip empty lines
            while nextLineStart <= markdownLength and string.sub(markdown, nextLineStart, nextLineStart) == "\n" do
                nextLineStart = nextLineStart + 1
            end
            if nextLineStart <= markdownLength then
                -- Check if next line starts with <
                if string.sub(markdown, nextLineStart, nextLineStart) == "<" then
                    -- Check if it's an HTML tag (like <div>, </div>, etc.)
                    local tagEnd = nextLineStart
                    for i = nextLineStart + 1, math.min(markdownLength, nextLineStart + 10) do
                        if
                            string.sub(markdown, i, i) == ">"
                            or string.sub(markdown, i, i) == "\n"
                            or string.sub(markdown, i, i) == " "
                        then
                            tagEnd = i
                            break
                        end
                    end
                    local tagText = string.sub(markdown, nextLineStart, tagEnd - 1)
                    -- Check if it looks like an HTML tag (starts with < and contains letters)
                    if tagText:match("^<[a-zA-Z]") or tagText:match("^</[a-zA-Z]") then
                        -- This is an HTML tag - backtrack to before chunkEnd to keep it with previous chunk
                        for i = chunkEnd - 1, math.max(pos, chunkEnd - 1000), -1 do
                            if i == pos or string.sub(markdown, i - 1, i - 1) == "\n" then
                                local newEnd = (i == pos) and pos or (i - 1)
                                if ValidateChunkSizeAfterBacktrack(newEnd) then
                                    chunkEnd = newEnd
                                    foundNewline = true
                                    CM.DebugPrint(
                                        "CHUNKING",
                                        string.format(
                                            "Chunk %d: Backtracked to %d to avoid splitting before HTML tag (tag starts at %d)",
                                            chunkNum,
                                            chunkEnd,
                                            nextLineStart
                                        )
                                    )
                                    break
                                else
                                    -- Can't backtrack that far - keep original position but log warning
                                    CM.DebugPrint(
                                        "CHUNKING",
                                        string.format(
                                            "Chunk %d: WARNING - Cannot backtrack to %d (would violate padding constraints), keeping chunkEnd at %d",
                                            chunkNum,
                                            newEnd,
                                            chunkEnd
                                        )
                                    )
                                    break
                                end
                            end
                        end
                    end
                else
                    -- Check if next line starts with a header (#### or #####)
                    -- If so, and we're ending after a table, we need to ensure we include the closing </div>
                    local nextLineEnd = nextLineStart
                    for i = nextLineStart, math.min(markdownLength, nextLineStart + 500) do
                        if string.sub(markdown, i, i) == "\n" then
                            nextLineEnd = i
                            break
                        elseif i == markdownLength then
                            nextLineEnd = markdownLength
                            break
                        end
                    end
                    local nextLine = string.sub(markdown, nextLineStart, nextLineEnd - 1)
                    if nextLine:match("^####%s") or nextLine:match("^#####%s") then
                        -- Next line is a header - check if we're ending after a table
                        -- If so, we need to backtrack to include the closing </div> tag
                        local prevLineStart = chunkEnd
                        for i = chunkEnd - 1, math.max(pos, chunkEnd - 1000), -1 do
                            if i == pos or string.sub(markdown, i - 1, i - 1) == "\n" then
                                prevLineStart = (i == pos) and pos or i
                                break
                            end
                        end
                        local prevLine = string.sub(markdown, prevLineStart, chunkEnd - 1)
                        -- Check if previous line is a table line or if we're right after a table
                        if
                            IsTableLine(prevLine)
                            or (
                                prevLineStart > 1
                                and IsTableLine(
                                    string.sub(markdown, math.max(1, prevLineStart - 500), prevLineStart - 1)
                                )
                            )
                        then
                            -- We're ending after a table and next chunk starts with a header
                            -- Backtrack to before the table section to keep it together, but validate padding size
                            for i = chunkEnd - 1, math.max(pos, chunkEnd - 2000), -1 do
                                -- Look for the closing </div> tag
                                if i >= 6 and string.sub(markdown, i - 5, i) == "</div>" then
                                    -- Found closing </div> - extend to include it, but validate padding size
                                    local newEnd = i
                                    if ValidateChunkSizeAfterBacktrack(newEnd) then
                                        chunkEnd = newEnd
                                        foundNewline = true
                                        CM.DebugPrint(
                                            "CHUNKING",
                                            string.format(
                                                "Chunk %d: Extended to %d to include closing </div> before header",
                                                chunkNum,
                                                chunkEnd
                                            )
                                        )
                                        break
                                    else
                                        -- Can't extend that far - try to find a closer position
                                        CM.DebugPrint(
                                            "CHUNKING",
                                            string.format(
                                                "Chunk %d: WARNING - Cannot extend to %d (would violate padding constraints)",
                                                chunkNum,
                                                newEnd
                                            )
                                        )
                                        -- Continue searching for a valid position
                                    end
                                elseif i == pos or string.sub(markdown, i - 1, i - 1) == "\n" then
                                    -- Backtrack to before the table section, but validate padding size
                                    local newEnd = (i == pos) and pos or (i - 1)
                                    if ValidateChunkSizeAfterBacktrack(newEnd) then
                                        chunkEnd = newEnd
                                        foundNewline = true
                                        CM.DebugPrint(
                                            "CHUNKING",
                                            string.format(
                                                "Chunk %d: Backtracked to %d to keep table section with header",
                                                chunkNum,
                                                chunkEnd
                                            )
                                        )
                                        break
                                    else
                                        -- Can't backtrack that far - keep original position but log warning
                                        CM.DebugPrint(
                                            "CHUNKING",
                                            string.format(
                                                "Chunk %d: WARNING - Cannot backtrack to %d (would violate padding constraints), keeping chunkEnd at %d",
                                                chunkNum,
                                                newEnd,
                                                chunkEnd
                                            )
                                        )
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        -- CRITICAL: Check if chunkEnd is inside an HTML block
        -- If so, backtrack to before the HTML block start
        if isInsideHtml and htmlBlockStart and htmlBlockEnd then
            local htmlBlockSize = htmlBlockEnd - htmlBlockStart + 1
            local structureOverageAllowance = 5000 -- Allow more overage for HTML blocks
            local effectiveMaxForStructures = maxSafeDataSize + structureOverageAllowance

            if htmlBlockSize <= effectiveMaxForStructures then
                -- Can include the whole HTML block - extend to its end
                chunkEnd = htmlBlockEnd
                foundNewline = true
                CM.DebugPrint(
                    "CHUNKING",
                    string.format(
                        "Chunk %d: Extending to include HTML block at %d (ends at %d)",
                        chunkNum,
                        htmlBlockStart,
                        htmlBlockEnd
                    )
                )
            else
                -- HTML block is too large - backtrack to before it
                for i = htmlBlockStart - 1, math.max(pos, htmlBlockStart - 1000), -1 do
                    if i == pos or string.sub(markdown, i - 1, i - 1) == "\n" then
                        chunkEnd = (i == pos) and pos or (i - 1)
                        foundNewline = true
                        CM.DebugPrint(
                            "CHUNKING",
                            string.format(
                                "Chunk %d: Backtracked to %d to avoid splitting HTML block",
                                chunkNum,
                                chunkEnd
                            )
                        )
                        break
                    end
                end
            end
        end

        -- CRITICAL: Check if chunkEnd is in the middle of a table or list
        -- NEVER allow chunking in the middle of these structures - always extend to end or backtrack before start
        if foundNewline or isLastChunk then
            -- Check if we're in the middle of a table
            -- First check if chunkEnd is actually on a table line
            local isOnTableLine = false
            local lineStart = chunkEnd
            for i = chunkEnd, math.max(pos, chunkEnd - 1000), -1 do
                if i == pos or string.sub(markdown, i - 1, i - 1) == "\n" then
                    lineStart = (i == pos) and pos or i
                    break
                end
            end
            local lineEnd = chunkEnd
            for i = lineStart, math.min(chunkEnd + 500, markdownLength) do
                if string.sub(markdown, i, i) == "\n" then
                    lineEnd = i
                    break
                end
            end
            local currentLine = string.sub(markdown, lineStart, lineEnd - 1)
            isOnTableLine = IsTableLine(currentLine)

            -- CRITICAL: Also check if chunkEnd is at a newline BETWEEN table rows
            -- In this case, we're still in the middle of a table and should extend or backtrack
            local isAfterTableLine = false
            local isBeforeTableLine = false
            local prevTableLine = nil
            local nextTableLine = nil
            local isBeforeHeader = false
            if chunkEnd > 1 and string.sub(markdown, chunkEnd, chunkEnd) == "\n" and not isOnTableLine then
                -- chunkEnd is at a newline - check if the previous line is a table line
                local prevLineStart = chunkEnd
                for i = chunkEnd - 1, math.max(pos, chunkEnd - 1000), -1 do
                    if i == pos or string.sub(markdown, i - 1, i - 1) == "\n" then
                        prevLineStart = (i == pos) and pos or i
                        break
                    end
                end
                prevTableLine = string.sub(markdown, prevLineStart, chunkEnd - 1)
                isAfterTableLine = IsTableLine(prevTableLine)

                -- CRITICAL: Check if the next non-empty line after chunkEnd is a header
                -- If so, and we're after a table line, we need to extend or backtrack to avoid merging
                if isAfterTableLine and chunkEnd < markdownLength then
                    local nextLineStart = chunkEnd + 1
                    -- Skip empty lines
                    while
                        nextLineStart <= markdownLength
                        and string.sub(markdown, nextLineStart, nextLineStart) == "\n"
                    do
                        nextLineStart = nextLineStart + 1
                    end

                    if nextLineStart <= markdownLength then
                        local nextLineEnd = nextLineStart
                        for i = nextLineStart, math.min(markdownLength, nextLineStart + 500) do
                            if string.sub(markdown, i, i) == "\n" then
                                nextLineEnd = i
                                break
                            end
                        end
                        local nextLine = string.sub(markdown, nextLineStart, nextLineEnd - 1)
                        isBeforeHeader = nextLine:match("^#+%s") ~= nil
                    end
                end

                -- CRITICAL: Also check if the NEXT line is a table line
                -- If both previous and next are table lines, we're in the middle of a table
                if chunkEnd < markdownLength then
                    local nextLineStart = chunkEnd + 1
                    -- Skip empty lines
                    while
                        nextLineStart <= markdownLength
                        and string.sub(markdown, nextLineStart, nextLineStart) == "\n"
                    do
                        nextLineStart = nextLineStart + 1
                    end

                    if nextLineStart <= markdownLength then
                        local nextLineEnd = nextLineStart
                        for i = nextLineStart, math.min(markdownLength, nextLineStart + 500) do
                            if string.sub(markdown, i, i) == "\n" then
                                nextLineEnd = i
                                break
                            end
                        end
                        nextTableLine = string.sub(markdown, nextLineStart, nextLineEnd - 1)
                        isBeforeTableLine = IsTableLine(nextTableLine)
                    end
                end
            end

            -- CRITICAL: If we're between table rows (after one table line and before another), we're in a table
            local isBetweenTableRows = isAfterTableLine and isBeforeTableLine

            -- Find table end - search more aggressively if we're on, after, before, or between table lines
            local isInTable = isOnTableLine or isAfterTableLine or isBeforeTableLine or isBetweenTableRows
            local tableSearchLimit = isInTable and (isLastChunk and markdownLength or 20000) or 10000

            -- CRITICAL: If we're between table rows, we need to find the table by checking the next line
            local tableEnd = nil
            if isBetweenTableRows or isBeforeTableLine then
                -- We're at a newline before a table line - find the table end starting from the next table line
                if chunkEnd < markdownLength then
                    local nextLineStart = chunkEnd + 1
                    -- Skip empty lines
                    while
                        nextLineStart <= markdownLength
                        and string.sub(markdown, nextLineStart, nextLineStart) == "\n"
                    do
                        nextLineStart = nextLineStart + 1
                    end
                    if nextLineStart <= markdownLength then
                        local nextLineEnd = nextLineStart
                        for i = nextLineStart, math.min(markdownLength, nextLineStart + 500) do
                            if string.sub(markdown, i, i) == "\n" then
                                nextLineEnd = i
                                break
                            end
                        end
                        tableEnd = FindTableEnd(markdown, nextLineEnd, tableSearchLimit)
                    end
                end
            else
                tableEnd = FindTableEnd(markdown, chunkEnd, tableSearchLimit)
            end

            -- CRITICAL: Also check if chunkEnd is on a line immediately BEFORE a table starts
            -- This catches cases where the look-ahead didn't catch it
            -- If that line is a header (starts with #), we need to backtrack before the header
            local isOnLineBeforeTable = false
            local isHeaderBeforeTable = false
            local headerLineStart = nil
            if not isInTable and chunkEnd < markdownLength then
                -- First, find the line we're currently on
                local currentLineStart = chunkEnd
                for i = chunkEnd, math.max(pos, chunkEnd - 1000), -1 do
                    if i == pos or string.sub(markdown, i - 1, i - 1) == "\n" then
                        currentLineStart = (i == pos) and pos or i
                        break
                    end
                end
                local currentLineEnd = chunkEnd
                for i = currentLineStart, math.min(chunkEnd + 500, markdownLength) do
                    if string.sub(markdown, i, i) == "\n" then
                        currentLineEnd = i
                        break
                    end
                end
                local currentLine = string.sub(markdown, currentLineStart, currentLineEnd - 1)

                -- Check if current line is a header
                isHeaderBeforeTable = currentLine:match("^#+%s") ~= nil
                if isHeaderBeforeTable then
                    headerLineStart = currentLineStart
                end

                -- Check if next line is a table
                local nextLineStart = chunkEnd + 1
                -- Skip empty lines
                while nextLineStart <= markdownLength and string.sub(markdown, nextLineStart, nextLineStart) == "\n" do
                    nextLineStart = nextLineStart + 1
                end
                if nextLineStart <= markdownLength then
                    local nextLineEnd = nextLineStart
                    for i = nextLineStart, math.min(markdownLength, nextLineStart + 500) do
                        if string.sub(markdown, i, i) == "\n" then
                            nextLineEnd = i
                            break
                        end
                    end
                    local nextLine = string.sub(markdown, nextLineStart, nextLineEnd - 1)
                    if IsTableLine(nextLine) then
                        isOnLineBeforeTable = true
                        -- Find the table end
                        tableEnd = FindTableEnd(markdown, nextLineEnd, tableSearchLimit)
                        if tableEnd and tableEnd > chunkEnd then
                            CM.DebugPrint(
                                "CHUNKING",
                                string.format(
                                    "Chunk %d: On %s before table, table ends at %d",
                                    chunkNum,
                                    isHeaderBeforeTable and "header" or "line",
                                    tableEnd
                                )
                            )
                        end
                    end
                end
            end

            -- CRITICAL: If we're after a table row and before a header, backtrack to avoid merging
            if isAfterTableLine and isBeforeHeader and not isInTable then
                -- Backtrack to before the table row to avoid merging table row with header
                for i = chunkEnd - 1, math.max(pos, chunkEnd - 1000), -1 do
                    if i == pos or string.sub(markdown, i - 1, i - 1) == "\n" then
                        chunkEnd = (i == pos) and pos or (i - 1)
                        foundNewline = true
                        CM.DebugPrint(
                            "CHUNKING",
                            string.format(
                                "Chunk %d: Backtracked to %d to avoid merging table row with header",
                                chunkNum,
                                chunkEnd
                            )
                        )
                        break
                    end
                end
            end

            -- CRITICAL: If we're in a table (on, after, before, between table lines) OR on line before table, we MUST extend
            -- Exception: If table is VERY large (too big to fit in chunk), allow chunking within table at row boundaries
            -- Never allow chunking in the middle of a table or on the line before a table
            -- If we're on a header before a table, we MUST extend to include header+table or backtrack before header
            if (isInTable or isOnLineBeforeTable) and tableEnd and tableEnd > chunkEnd then
                -- We're in a table or before a table - MUST extend to end of table, not backtrack
                -- Exception: If table is too large, allow chunking within table
                local tableSize = tableEnd - chunkEnd + 1
                local structureOverageAllowance = 2000
                local effectiveMaxForStructures = maxSafeDataSize + structureOverageAllowance

                -- If we're on a header before a table, ensure header+table stay together
                if isHeaderBeforeTable and headerLineStart then
                    -- Check if we can include header+table
                    local headerTableChunkSize = tableEnd - headerLineStart + 1

                    if headerTableChunkSize <= effectiveMaxForStructures then
                        -- Can include header+table - EXTEND IMMEDIATELY to keep them together
                        chunkEnd = tableEnd
                        CM.DebugPrint(
                            "CHUNKING",
                            string.format(
                                "Chunk %d: On header before table, extended to include header+table (ends at %d)",
                                chunkNum,
                                tableEnd
                            )
                        )
                    else
                        -- Can't include header+table - backtrack before header
                        for i = headerLineStart - 1, math.max(pos, headerLineStart - 1000), -1 do
                            if i == pos or string.sub(markdown, i - 1, i - 1) == "\n" then
                                chunkEnd = (i == pos) and pos or (i - 1)
                                CM.DebugPrint(
                                    "CHUNKING",
                                    string.format(
                                        "Chunk %d: Backtracked to before header to keep header+table together",
                                        chunkNum
                                    )
                                )
                                break
                            end
                        end
                        -- Reset flags since we backtracked
                        isOnLineBeforeTable = false
                        isHeaderBeforeTable = false
                        tableEnd = nil
                    end
                elseif tableSize > effectiveMaxForStructures then
                    -- Table is too large to fit in one chunk - allow chunking within table at row boundaries
                    -- Verify chunkEnd is at a newline between table rows (not in middle of a row)
                    if string.sub(markdown, chunkEnd, chunkEnd) == "\n" then
                        -- Already at a newline - verify it's between table rows
                        local isAtRowBoundary = (isAfterTableLine or isBetweenTableRows)
                        if isAtRowBoundary then
                            CM.DebugPrint(
                                "CHUNKING",
                                string.format(
                                    "Chunk %d: Table too large (%d chars), allowing chunk at row boundary (pos %d)",
                                    chunkNum,
                                    tableSize,
                                    chunkEnd
                                )
                            )
                            -- OK to chunk here - we're at a row boundary in a very large table
                        else
                            -- Not at row boundary - find previous row boundary
                            for i = chunkEnd - 1, math.max(pos, chunkEnd - 2000), -1 do
                                if string.sub(markdown, i, i) == "\n" then
                                    -- Check if this is between table rows
                                    local prevLine = nil
                                    local prevLineStart = i
                                    for j = i - 1, math.max(pos, i - 500), -1 do
                                        if j == pos or string.sub(markdown, j - 1, j - 1) == "\n" then
                                            prevLineStart = (j == pos) and pos or j
                                            break
                                        end
                                    end
                                    prevLine = string.sub(markdown, prevLineStart, i - 1)
                                    if IsTableLine(prevLine) then
                                        chunkEnd = i
                                        CM.DebugPrint(
                                            "CHUNKING",
                                            string.format(
                                                "Chunk %d: Large table - moved to row boundary at %d",
                                                chunkNum,
                                                chunkEnd
                                            )
                                        )
                                        break
                                    end
                                end
                            end
                        end
                    else
                        -- Not at newline - find previous newline between table rows
                        for i = chunkEnd - 1, math.max(pos, chunkEnd - 2000), -1 do
                            if string.sub(markdown, i, i) == "\n" then
                                -- Check if this is between table rows
                                local prevLine = nil
                                local prevLineStart = i
                                for j = i - 1, math.max(pos, i - 500), -1 do
                                    if j == pos or string.sub(markdown, j - 1, j - 1) == "\n" then
                                        prevLineStart = (j == pos) and pos or j
                                        break
                                    end
                                end
                                prevLine = string.sub(markdown, prevLineStart, i - 1)
                                if IsTableLine(prevLine) then
                                    chunkEnd = i
                                    CM.DebugPrint(
                                        "CHUNKING",
                                        string.format(
                                            "Chunk %d: Large table - moved to row boundary at %d",
                                            chunkNum,
                                            chunkEnd
                                        )
                                    )
                                    break
                                end
                            end
                        end
                    end
                else
                    -- Table is not too large, will extend in logic below
                    CM.DebugPrint(
                        "CHUNKING",
                        string.format(
                            "Chunk %d: In table or before table, will extend to table end at %d",
                            chunkNum,
                            tableEnd
                        )
                    )
                end
            elseif tableEnd and tableEnd > chunkEnd and not isInTable and not isOnLineBeforeTable then
                -- We're in the middle of a table but didn't detect it properly - find where it started
                local tableStart = chunkEnd
                for i = chunkEnd, math.max(pos, chunkEnd - 5000), -1 do
                    if i == pos or string.sub(markdown, i - 1, i - 1) == "\n" then
                        local lineStart = (i == pos) and pos or i
                        local lineEnd = chunkEnd
                        for j = lineStart, math.min(chunkEnd, lineStart + 500) do
                            if string.sub(markdown, j, j) == "\n" then
                                lineEnd = j
                                break
                            end
                        end
                        local line = string.sub(markdown, lineStart, lineEnd - 1)
                        if IsTableLine(line) then
                            -- Found the start of the table - backtrack to before it
                            local originalChunkEnd = chunkEnd
                            for k = lineStart - 1, math.max(pos, lineStart - 1000), -1 do
                                if k == pos or string.sub(markdown, k - 1, k - 1) == "\n" then
                                    chunkEnd = (k == pos) and pos or (k - 1)
                                    CM.DebugPrint(
                                        "CHUNKING",
                                        string.format(
                                            "Chunk %d: Backtracked from %d to %d to avoid splitting table",
                                            chunkNum,
                                            originalChunkEnd,
                                            chunkEnd
                                        )
                                    )
                                    break
                                end
                            end
                            break
                        end
                    end
                end
            end

            -- Check if we're in the middle of a list
            -- First check if chunkEnd is actually on a list line
            local isOnListLine = false
            local listLineStart = chunkEnd
            for i = chunkEnd, math.max(pos, chunkEnd - 1000), -1 do
                if i == pos or string.sub(markdown, i - 1, i - 1) == "\n" then
                    listLineStart = (i == pos) and pos or i
                    break
                end
            end
            local listLineEnd = chunkEnd
            for i = listLineStart, math.min(chunkEnd + 500, markdownLength) do
                if string.sub(markdown, i, i) == "\n" then
                    listLineEnd = i
                    break
                end
            end
            local currentListLine = string.sub(markdown, listLineStart, listLineEnd - 1)
            isOnListLine = IsListLine(currentListLine)

            -- CRITICAL: Also check if chunkEnd is at a newline AFTER a list line
            -- In this case, we're still in the middle of a list and should backtrack
            local isAfterListLine = false
            local prevListLine = nil
            if chunkEnd > 1 and string.sub(markdown, chunkEnd, chunkEnd) == "\n" then
                -- chunkEnd is at a newline - check if the previous line is a list line
                local prevLineStart = chunkEnd
                for i = chunkEnd - 1, math.max(pos, chunkEnd - 1000), -1 do
                    if i == pos or string.sub(markdown, i - 1, i - 1) == "\n" then
                        prevLineStart = (i == pos) and pos or i
                        break
                    end
                end
                prevListLine = string.sub(markdown, prevLineStart, chunkEnd - 1)
                isAfterListLine = IsListLine(prevListLine)
            end

            -- Check if list continues after chunkEnd
            local listEnd = nil
            if isAfterListLine then
                -- chunkEnd is at a newline after a list line - check if list continues
                -- Look ahead to see if there are more list items
                local nextLineStart = chunkEnd + 1
                if nextLineStart <= markdownLength then
                    -- Skip empty lines
                    while
                        nextLineStart <= markdownLength
                        and string.sub(markdown, nextLineStart, nextLineStart) == "\n"
                    do
                        nextLineStart = nextLineStart + 1
                    end

                    if nextLineStart <= markdownLength then
                        -- Find the end of this line
                        local nextLineEnd = nextLineStart
                        for i = nextLineStart, math.min(markdownLength, nextLineStart + 500) do
                            if string.sub(markdown, i, i) == "\n" then
                                nextLineEnd = i
                                break
                            end
                        end

                        local nextLine = string.sub(markdown, nextLineStart, nextLineEnd - 1)
                        if IsListLine(nextLine) then
                            -- List continues - find where it ends
                            listEnd = FindListEnd(markdown, nextLineEnd, 10000)
                        end
                    end
                end
            else
                listEnd = FindListEnd(markdown, chunkEnd, 10000)
            end

            -- Backtrack if:
            -- 1. We're in the middle (list continues after chunkEnd) AND
            -- 2. We're NOT on a list line (if we're on a list line, we should extend, not backtrack)
            if listEnd and listEnd > chunkEnd and not isOnListLine then
                -- We're in the middle of a list - find where it started
                local listStart = chunkEnd
                for i = chunkEnd, math.max(pos, chunkEnd - 5000), -1 do
                    if i == pos or string.sub(markdown, i - 1, i - 1) == "\n" then
                        local lineStart = (i == pos) and pos or i
                        local lineEnd = chunkEnd
                        for j = lineStart, math.min(chunkEnd, lineStart + 500) do
                            if string.sub(markdown, j, j) == "\n" then
                                lineEnd = j
                                break
                            end
                        end
                        local line = string.sub(markdown, lineStart, lineEnd - 1)
                        if IsListLine(line) then
                            -- Found the start of the list - backtrack to before it
                            local originalChunkEnd = chunkEnd
                            for k = lineStart - 1, math.max(pos, lineStart - 1000), -1 do
                                if k == pos or string.sub(markdown, k - 1, k - 1) == "\n" then
                                    chunkEnd = (k == pos) and pos or (k - 1)
                                    CM.DebugPrint(
                                        "CHUNKING",
                                        string.format(
                                            "Chunk %d: Backtracked from %d to %d to avoid splitting list",
                                            chunkNum,
                                            originalChunkEnd,
                                            chunkEnd
                                        )
                                    )
                                    break
                                end
                            end
                            break
                        end
                    end
                end
            end

            local currentChunkSize = chunkEnd - pos + 1
            -- CRITICAL: Check current size BEFORE extending for tables/lists
            if currentChunkSize > maxSafeDataSize then
                -- Current chunk already exceeds limit, don't extend further
                CM.DebugPrint(
                    "CHUNKING",
                    string.format(
                        "Chunk %d: Current size %d already exceeds maxSafeDataSize %d, not extending for table/list",
                        chunkNum,
                        currentChunkSize,
                        maxSafeDataSize
                    )
                )
            else
                -- CRITICAL: For last chunk, search to end of markdown to find complete table
                local tableSearchLimit = isLastChunk and markdownLength or 10000

                -- CRITICAL: Check if we already extended chunkEnd in early detection (header+table case)
                -- If so, preserve the outer tableEnd value and skip re-detection
                local alreadyExtendedForHeader = isHeaderBeforeTable
                    and headerLineStart
                    and tableEnd
                    and chunkEnd == tableEnd

                if not alreadyExtendedForHeader then
                    -- Only re-detect if we haven't already extended for header+table
                    tableEnd = FindTableEnd(markdown, chunkEnd, tableSearchLimit)
                end

                -- CRITICAL: Also check if there's a table starting right after chunkEnd
                -- (FindTableEnd only works if chunkEnd is already in a table)
                -- Skip this check if we already extended for header+table
                if not alreadyExtendedForHeader and (not tableEnd or tableEnd <= chunkEnd) then
                    -- Check if the next line after chunkEnd is a table line
                    local nextLineStart = chunkEnd + 1
                    if nextLineStart <= markdownLength then
                        -- Skip empty lines
                        while
                            nextLineStart <= markdownLength
                            and string.sub(markdown, nextLineStart, nextLineStart) == "\n"
                        do
                            nextLineStart = nextLineStart + 1
                        end

                        if nextLineStart <= markdownLength then
                            -- Find the end of this line
                            local nextLineEnd = nextLineStart
                            for i = nextLineStart, math.min(markdownLength, nextLineStart + 500) do
                                if string.sub(markdown, i, i) == "\n" then
                                    nextLineEnd = i
                                    break
                                end
                            end

                            local nextLine = string.sub(markdown, nextLineStart, nextLineEnd - 1)
                            if IsTableLine(nextLine) then
                                -- There's a table starting after chunkEnd - find its end
                                -- CRITICAL: Check if chunkEnd is on a header line - if so, include header in calculation
                                local headerBeforeTable = false
                                local headerLineStart = nil
                                if chunkEnd > pos then
                                    -- Find the line chunkEnd is on
                                    local currentLineStart = chunkEnd
                                    for i = chunkEnd, math.max(pos, chunkEnd - 1000), -1 do
                                        if i == pos or string.sub(markdown, i - 1, i - 1) == "\n" then
                                            currentLineStart = (i == pos) and pos or i
                                            break
                                        end
                                    end
                                    local currentLineEnd = chunkEnd
                                    for i = currentLineStart, math.min(chunkEnd + 500, markdownLength) do
                                        if string.sub(markdown, i, i) == "\n" then
                                            currentLineEnd = i
                                            break
                                        end
                                    end
                                    local currentLine = string.sub(markdown, currentLineStart, currentLineEnd - 1)
                                    -- Check if current line is a header (starts with #)
                                    if currentLine:match("^#+%s") ~= nil then
                                        headerBeforeTable = true
                                        headerLineStart = currentLineStart
                                    end
                                end

                                local foundTableEnd = FindTableEnd(markdown, nextLineEnd, tableSearchLimit)
                                if foundTableEnd and foundTableEnd > chunkEnd then
                                    tableEnd = foundTableEnd
                                    CM.DebugPrint(
                                        "CHUNKING",
                                        string.format(
                                            "Chunk %d: Found table starting after chunkEnd%s, table ends at %d",
                                            chunkNum,
                                            headerBeforeTable and " (with header before)" or "",
                                            tableEnd
                                        )
                                    )
                                    -- CRITICAL: After finding a table starting after chunkEnd, also check for consecutive tables
                                    -- This handles cases where multiple tables appear consecutively (e.g., Companion section)
                                    local nextTableStart = tableEnd + 1
                                    if nextTableStart <= markdownLength then
                                        -- Skip empty lines
                                        while
                                            nextTableStart <= markdownLength
                                            and string.sub(markdown, nextTableStart, nextTableStart) == "\n"
                                        do
                                            nextTableStart = nextTableStart + 1
                                        end

                                        if nextTableStart <= markdownLength then
                                            -- Find the end of this line
                                            local nextTableLineEnd = nextTableStart
                                            for i = nextTableStart, math.min(markdownLength, nextTableStart + 500) do
                                                if string.sub(markdown, i, i) == "\n" then
                                                    nextTableLineEnd = i
                                                    break
                                                end
                                            end

                                            local nextTableLine =
                                                string.sub(markdown, nextTableStart, nextTableLineEnd - 1)
                                            if IsTableLine(nextTableLine) then
                                                -- There's another table starting right after - find its end
                                                local nextTableEnd =
                                                    FindTableEnd(markdown, nextTableLineEnd, tableSearchLimit)
                                                if nextTableEnd and nextTableEnd > tableEnd then
                                                    local combinedTableChunkSize = nextTableEnd - pos + 1
                                                    -- CRITICAL FIX: Account for padding in size check
                                                    if combinedTableChunkSize + paddingSize <= copyLimit then
                                                        tableEnd = nextTableEnd
                                                        CM.DebugPrint(
                                                            "CHUNKING",
                                                            string.format(
                                                                "Chunk %d: Found consecutive table after chunkEnd, extending table end to %d (size: %d + %d padding = %d)",
                                                                chunkNum,
                                                                tableEnd,
                                                                combinedTableChunkSize,
                                                                paddingSize,
                                                                combinedTableChunkSize + paddingSize
                                                            )
                                                        )
                                                    else
                                                        CM.DebugPrint(
                                                            "CHUNKING",
                                                            string.format(
                                                                "Chunk %d: Consecutive table after chunkEnd extends beyond safe limit, staying at first table end %d",
                                                                chunkNum,
                                                                tableEnd
                                                            )
                                                        )
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end

                if tableEnd and tableEnd > chunkEnd then
                    -- CRITICAL: If there's a header before the table, include it in size calculation
                    -- Check both the earlier detection (isHeaderBeforeTable) and the detection in the look-ahead section
                    local contentStart = pos
                    -- First check the earlier detection
                    if isHeaderBeforeTable and headerLineStart and headerLineStart >= pos then
                        contentStart = headerLineStart
                    else
                        -- Also check if chunkEnd itself is on a header line (from the look-ahead detection)
                        if chunkEnd > pos then
                            local currentLineStart = chunkEnd
                            for i = chunkEnd, math.max(pos, chunkEnd - 1000), -1 do
                                if i == pos or string.sub(markdown, i - 1, i - 1) == "\n" then
                                    currentLineStart = (i == pos) and pos or i
                                    break
                                end
                            end
                            local currentLineEnd = chunkEnd
                            for i = currentLineStart, math.min(chunkEnd + 500, markdownLength) do
                                if string.sub(markdown, i, i) == "\n" then
                                    currentLineEnd = i
                                    break
                                end
                            end
                            local currentLine = string.sub(markdown, currentLineStart, currentLineEnd - 1)
                            if currentLine:match("^#+%s") ~= nil then
                                -- chunkEnd is on a header line - check if next line is a table
                                local nextLineStart = chunkEnd + 1
                                while
                                    nextLineStart <= markdownLength
                                    and string.sub(markdown, nextLineStart, nextLineStart) == "\n"
                                do
                                    nextLineStart = nextLineStart + 1
                                end
                                if nextLineStart <= markdownLength then
                                    local nextLineEnd = nextLineStart
                                    for i = nextLineStart, math.min(markdownLength, nextLineStart + 500) do
                                        if string.sub(markdown, i, i) == "\n" then
                                            nextLineEnd = i
                                            break
                                        end
                                    end
                                    local nextLine = string.sub(markdown, nextLineStart, nextLineEnd - 1)
                                    if IsTableLine(nextLine) then
                                        -- Header before table - include header in size
                                        contentStart = currentLineStart
                                        isHeaderBeforeTable = true
                                        headerLineStart = currentLineStart
                                    end
                                end
                            end
                        end
                    end

                    local tableChunkSize = tableEnd - contentStart + 1
                    local currentChunkSize = chunkEnd - pos + 1
                    local remainingSpace = maxSafeDataSize - currentChunkSize

                    -- CRITICAL: If we're in a table (on, after, before, between table lines) OR on line before table, we MUST extend
                    -- Never allow chunking in the middle of a table or on the line before a table
                    -- CRITICAL: If there's a header before a table, we MUST extend to include header+table or backtrack before header
                    local mustExtendForTable = isInTable or isOnLineBeforeTable or isHeaderBeforeTable

                    -- CRITICAL: Use maxSafeDataSize (not maxSafeSize) to ensure data doesn't exceed copy limit
                    -- The clipboard safety buffer is already applied in padding calculation
                    -- For tables, allow small overage (up to 2000 bytes) to prevent splitting
                    local tableOverageAllowance = mustExtendForTable and 2000 or 0
                    local effectiveMaxForTable = maxSafeDataSize + tableOverageAllowance

                    if mustExtendForTable or (tableChunkSize <= effectiveMaxForTable and remainingSpace > 1000) then
                        -- CRITICAL: If there's a header before the table, we MUST include it
                        -- Never allow chunking between a header and its table
                        if isHeaderBeforeTable and headerLineStart then
                            -- Always extend to include header+table when header is detected
                            -- This ensures header and table stay together regardless of chunkEnd position
                            chunkEnd = tableEnd
                            CM.DebugPrint(
                                "CHUNKING",
                                string.format(
                                    "Chunk %d: Found header+table, extending chunk end to %d to keep them together (header at %d)",
                                    chunkNum,
                                    chunkEnd,
                                    headerLineStart
                                )
                            )
                        else
                            -- CRITICAL: Verify the new chunk end is not inside a markdown link
                            local linkEnd = IsInsideMarkdownLink(markdown, tableEnd)
                            if linkEnd and linkEnd > tableEnd then
                                -- The table end is inside a link, find a safe newline after the link
                                local safeNewline =
                                    FindSafeNewline(markdown, tableEnd, math.min(markdownLength, linkEnd + 200))
                                if safeNewline and safeNewline - pos + 1 <= maxSafeDataSize then
                                    chunkEnd = safeNewline
                                    CM.DebugPrint(
                                        "CHUNKING",
                                        string.format(
                                            "Chunk %d: Table end was inside link, moved to safe newline at %d",
                                            chunkNum,
                                            chunkEnd
                                        )
                                    )
                                else
                                    -- Can't find safe position, stay at original chunkEnd
                                    CM.DebugPrint(
                                        "CHUNKING",
                                        string.format(
                                            "Chunk %d: Table end at %d is inside link, staying at safe position %d",
                                            chunkNum,
                                            tableEnd,
                                            chunkEnd
                                        )
                                    )
                                end
                            else
                                chunkEnd = tableEnd
                                CM.DebugPrint(
                                    "CHUNKING",
                                    string.format("Chunk %d: Found table, moving chunk end to %d", chunkNum, chunkEnd)
                                )
                            end
                        end
                    else
                        -- Too close to limit or table won't fit
                        -- CRITICAL: If we're on or after a table line, we MUST extend or backtrack
                        -- Never allow chunking in the middle of a table
                        -- CRITICAL: If there's a header before the table, we MUST backtrack before the header
                        if mustExtendForTable or isHeaderBeforeTable then
                            -- We're in a table or before a table with header - must backtrack before table/header starts
                            local originalChunkEnd = chunkEnd
                            if isHeaderBeforeTable and headerLineStart then
                                CM.DebugPrint(
                                    "CHUNKING",
                                    string.format(
                                        "Chunk %d: Header+table won't fit (size: %d, remaining: %d), backtracking before header",
                                        chunkNum,
                                        tableChunkSize,
                                        remainingSpace
                                    )
                                )
                                -- Backtrack to before the header
                                for i = headerLineStart - 1, math.max(pos, headerLineStart - 1000), -1 do
                                    if i == pos or string.sub(markdown, i - 1, i - 1) == "\n" then
                                        chunkEnd = (i == pos) and pos or (i - 1)
                                        CM.DebugPrint(
                                            "CHUNKING",
                                            string.format(
                                                "Chunk %d: Backtracked from %d to %d to keep header+table together",
                                                chunkNum,
                                                originalChunkEnd,
                                                chunkEnd
                                            )
                                        )
                                        break
                                    end
                                end
                            else
                                CM.DebugPrint(
                                    "CHUNKING",
                                    string.format(
                                        "Chunk %d: In table but can't extend (size: %d, remaining: %d), backtracking before table",
                                        chunkNum,
                                        tableChunkSize,
                                        remainingSpace
                                    )
                                )
                                -- Find where table started
                                local tableStart = chunkEnd
                                for i = chunkEnd, math.max(pos, chunkEnd - 5000), -1 do
                                    if i == pos or string.sub(markdown, i - 1, i - 1) == "\n" then
                                        local lineStart = (i == pos) and pos or i
                                        local lineEnd = chunkEnd
                                        for j = lineStart, math.min(chunkEnd, lineStart + 500) do
                                            if string.sub(markdown, j, j) == "\n" then
                                                lineEnd = j
                                                break
                                            end
                                        end
                                        local line = string.sub(markdown, lineStart, lineEnd - 1)
                                        if IsTableLine(line) then
                                            tableStart = lineStart
                                        else
                                            break
                                        end
                                    end
                                end
                                -- Backtrack to before table
                                if tableStart > pos then
                                    for k = tableStart - 1, math.max(pos, tableStart - 1000), -1 do
                                        if k == pos or string.sub(markdown, k - 1, k - 1) == "\n" then
                                            chunkEnd = (k == pos) and pos or (k - 1)
                                            CM.DebugPrint(
                                                "CHUNKING",
                                                string.format(
                                                    "Chunk %d: Backtracked from %d to %d to avoid splitting table",
                                                    chunkNum,
                                                    originalChunkEnd,
                                                    chunkEnd
                                                )
                                            )
                                            break
                                        end
                                    end
                                else
                                    -- Table starts at chunk start - can't avoid it, but at least try to extend
                                    -- This is a fallback - ideally this shouldn't happen
                                    CM.DebugPrint(
                                        "CHUNKING",
                                        string.format(
                                            "Chunk %d: CRITICAL - Table starts at chunk start, cannot avoid splitting!",
                                            chunkNum
                                        )
                                    )
                                end
                            end
                        else
                            CM.DebugPrint(
                                "CHUNKING",
                                string.format(
                                    "Chunk %d: Table extends beyond safe limit or too close to limit (size: %d, remaining: %d), staying at %d",
                                    chunkNum,
                                    tableChunkSize,
                                    remainingSpace,
                                    chunkEnd
                                )
                            )
                        end
                    end
                elseif tableEnd and tableEnd < chunkEnd then
                    chunkEnd = tableEnd
                end

                -- CRITICAL: After extending for a table (or if chunkEnd is already at table end), check for consecutive tables
                -- This handles cases where multiple tables appear consecutively (e.g., Companion section)
                -- CONSERVATIVE: Only extend for consecutive tables if we have enough remaining space
                -- If we're already close to the limit, stop at the current table end and let the next chunk handle it
                local currentChunkSize = chunkEnd - pos + 1
                local remainingSpace = maxSafeDataSize - currentChunkSize

                -- Only check for consecutive tables if we have at least 2000 bytes remaining
                -- This ensures we don't extend when we're already close to the limit
                if remainingSpace > 2000 then
                    local structureOverageAllowance = 1500
                    local effectiveMaxForStructures = maxSafeDataSize + structureOverageAllowance
                    -- Check for consecutive tables if we're within the effective max (including overage)
                    if currentChunkSize <= effectiveMaxForStructures then
                        local nextTableStart = chunkEnd + 1
                        if nextTableStart <= markdownLength then
                            -- Skip empty lines
                            while
                                nextTableStart <= markdownLength
                                and string.sub(markdown, nextTableStart, nextTableStart) == "\n"
                            do
                                nextTableStart = nextTableStart + 1
                            end

                            if nextTableStart <= markdownLength then
                                -- Find the end of this line
                                local nextTableLineEnd = nextTableStart
                                for i = nextTableStart, math.min(markdownLength, nextTableStart + 500) do
                                    if string.sub(markdown, i, i) == "\n" then
                                        nextTableLineEnd = i
                                        break
                                    end
                                end

                                local nextTableLine = string.sub(markdown, nextTableStart, nextTableLineEnd - 1)
                                if IsTableLine(nextTableLine) then
                                    -- There's another table starting right after the current one - find its end
                                    local nextTableEnd = FindTableEnd(markdown, nextTableLineEnd, tableSearchLimit)
                                    if nextTableEnd and nextTableEnd > chunkEnd then
                                        local combinedTableChunkSize = nextTableEnd - pos + 1
                                        -- CRITICAL: For consecutive tables, allow small overage to include complete structures
                                        -- Complete structures (table -> table -> list) are better than truncated ones
                                        -- Allow up to 1500 bytes overage for complete consecutive structures

                                        if combinedTableChunkSize <= effectiveMaxForStructures then
                                            chunkEnd = nextTableEnd
                                            CM.DebugPrint(
                                                "CHUNKING",
                                                string.format(
                                                    "Chunk %d: Found consecutive table, extending chunk end to %d (size: %d, limit: %d)",
                                                    chunkNum,
                                                    chunkEnd,
                                                    combinedTableChunkSize,
                                                    effectiveMaxForStructures
                                                )
                                            )

                                            -- CRITICAL: After extending for consecutive table, also check for a list starting right after
                                            -- This handles cases like Companion section: table -> table -> list
                                            local afterTableStart = chunkEnd + 1
                                            if afterTableStart <= markdownLength then
                                                -- Skip empty lines
                                                while
                                                    afterTableStart <= markdownLength
                                                    and string.sub(markdown, afterTableStart, afterTableStart)
                                                        == "\n"
                                                do
                                                    afterTableStart = afterTableStart + 1
                                                end

                                                if afterTableStart <= markdownLength then
                                                    -- Find the end of this line
                                                    local afterTableLineEnd = afterTableStart
                                                    for i = afterTableStart, math.min(markdownLength, afterTableStart + 500) do
                                                        if string.sub(markdown, i, i) == "\n" then
                                                            afterTableLineEnd = i
                                                            break
                                                        end
                                                    end

                                                    local afterTableLine =
                                                        string.sub(markdown, afterTableStart, afterTableLineEnd - 1)
                                                    local listStartPos = nil

                                                    if IsListLine(afterTableLine) then
                                                        -- Found list starting immediately
                                                        listStartPos = afterTableLineEnd
                                                    else
                                                        -- Not a list line - might be a heading or text before a list (e.g., "**Equipment:**")
                                                        -- Check the next line
                                                        local nextLineStart = afterTableLineEnd + 1
                                                        if nextLineStart <= markdownLength then
                                                            -- Skip empty lines
                                                            while
                                                                nextLineStart <= markdownLength
                                                                and string.sub(
                                                                        markdown,
                                                                        nextLineStart,
                                                                        nextLineStart
                                                                    )
                                                                    == "\n"
                                                            do
                                                                nextLineStart = nextLineStart + 1
                                                            end

                                                            if nextLineStart <= markdownLength then
                                                                -- Find the end of this line
                                                                local nextLineEnd = nextLineStart
                                                                for i = nextLineStart, math.min(markdownLength, nextLineStart + 500) do
                                                                    if string.sub(markdown, i, i) == "\n" then
                                                                        nextLineEnd = i
                                                                        break
                                                                    end
                                                                end

                                                                local nextLine =
                                                                    string.sub(markdown, nextLineStart, nextLineEnd - 1)
                                                                if IsListLine(nextLine) then
                                                                    -- Found list on the next line
                                                                    listStartPos = nextLineEnd
                                                                end
                                                            end
                                                        end
                                                    end

                                                    if listStartPos then
                                                        -- There's a list starting after the consecutive table - find its end
                                                        local listSearchLimit = isLastChunk and markdownLength or 10000
                                                        local listEnd =
                                                            FindListEnd(markdown, listStartPos, listSearchLimit)
                                                        if listEnd and listEnd > chunkEnd then
                                                            local combinedWithListSize = listEnd - pos + 1
                                                            -- CRITICAL: For lists after consecutive tables, allow same overage for complete structures
                                                            if combinedWithListSize <= effectiveMaxForStructures then
                                                                chunkEnd = listEnd
                                                                CM.DebugPrint(
                                                                    "CHUNKING",
                                                                    string.format(
                                                                        "Chunk %d: Found list after consecutive table, extending chunk end to %d (size: %d, limit: %d)",
                                                                        chunkNum,
                                                                        chunkEnd,
                                                                        combinedWithListSize,
                                                                        effectiveMaxForStructures
                                                                    )
                                                                )
                                                            else
                                                                CM.DebugPrint(
                                                                    "CHUNKING",
                                                                    string.format(
                                                                        "Chunk %d: List after consecutive table extends beyond structure limit (%d > %d), staying at table end %d",
                                                                        chunkNum,
                                                                        combinedWithListSize,
                                                                        effectiveMaxForStructures,
                                                                        chunkEnd
                                                                    )
                                                                )
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        else
                                            CM.DebugPrint(
                                                "CHUNKING",
                                                string.format(
                                                    "Chunk %d: Consecutive table extends beyond structure limit (%d > %d), staying at first table end %d",
                                                    chunkNum,
                                                    combinedTableChunkSize,
                                                    effectiveMaxForStructures,
                                                    chunkEnd
                                                )
                                            )
                                        end
                                    end
                                end
                            end
                        end
                    end
                else
                    -- Too close to limit - don't check for consecutive tables
                    CM.DebugPrint(
                        "CHUNKING",
                        string.format(
                            "Chunk %d: Too close to limit (remaining: %d), not checking for consecutive tables, staying at %d",
                            chunkNum,
                            remainingSpace,
                            chunkEnd
                        )
                    )
                end

                -- Check list extension only if we haven't already exceeded the limit
                if chunkEnd - pos + 1 <= maxSafeDataSize then
                    -- CRITICAL: When chunkEnd is at a newline, check if the previous line is a list line
                    -- If so, we're in a list and should find its end
                    local listEnd = nil
                    local checkPos = chunkEnd
                    if checkPos > 1 and string.sub(markdown, checkPos, checkPos) == "\n" then
                        -- chunkEnd is at a newline - check if the line before it is a list line
                        local prevLineStart = checkPos
                        for i = checkPos - 1, math.max(1, checkPos - 1000), -1 do
                            if i == 1 or string.sub(markdown, i - 1, i - 1) == "\n" then
                                prevLineStart = i
                                break
                            end
                        end
                        local prevLine = string.sub(markdown, prevLineStart, checkPos - 1)
                        if IsListLine(prevLine) then
                            -- We're at the end of a list line - find the end of the entire list
                            listEnd = FindListEnd(markdown, checkPos, 10000)
                        end
                    end

                    -- If we didn't find a list yet, try the normal approach
                    if not listEnd or listEnd <= chunkEnd then
                        listEnd = FindListEnd(markdown, chunkEnd, 10000)
                    end

                    -- CRITICAL: Also check if there's a list starting right after chunkEnd
                    -- (FindListEnd only works if chunkEnd is already in a list)
                    if not listEnd or listEnd <= chunkEnd then
                        -- Check if there's a list starting after chunkEnd (may be separated by empty lines)
                        -- Look ahead up to 10 lines to find a list
                        local searchAhead = 10 -- Check up to 10 lines ahead
                        local currentLineStart = chunkEnd + 1
                        local foundListStart = nil

                        for lineCheck = 1, searchAhead do
                            if currentLineStart > markdownLength then
                                break
                            end

                            -- Skip to next non-empty line
                            while
                                currentLineStart <= markdownLength
                                and string.sub(markdown, currentLineStart, currentLineStart) == "\n"
                            do
                                currentLineStart = currentLineStart + 1
                            end

                            if currentLineStart > markdownLength then
                                break
                            end

                            -- Find the end of this line
                            local currentLineEnd = currentLineStart
                            for i = currentLineStart, math.min(markdownLength, currentLineStart + 500) do
                                if string.sub(markdown, i, i) == "\n" then
                                    currentLineEnd = i
                                    break
                                end
                            end

                            local currentLine = string.sub(markdown, currentLineStart, currentLineEnd - 1)
                            if IsListLine(currentLine) then
                                -- Found a list starting after chunkEnd - find its end
                                foundListStart = currentLineEnd
                                break
                            elseif currentLine:match("^%s*$") then
                                -- Empty line, continue searching
                                currentLineStart = currentLineEnd + 1
                            else
                                -- Non-empty, non-list line - stop searching
                                break
                            end
                        end

                        if foundListStart then
                            local listSearchLimit = isLastChunk and markdownLength or 10000
                            listEnd = FindListEnd(markdown, foundListStart, listSearchLimit)
                            if listEnd and listEnd > chunkEnd then
                                CM.DebugPrint(
                                    "CHUNKING",
                                    string.format(
                                        "Chunk %d: Found list starting after chunkEnd at %d, list ends at %d",
                                        chunkNum,
                                        foundListStart,
                                        listEnd
                                    )
                                )
                            end
                        end
                    end

                    if listEnd and listEnd > chunkEnd then
                        local listChunkSize = listEnd - pos + 1
                        -- CRITICAL: Use maxSafeDataSize (not maxSafeSize) to ensure data doesn't exceed copy limit
                        if listChunkSize <= maxSafeDataSize then
                            -- CRITICAL: Verify the new chunk end is not inside a markdown link
                            local linkEnd = IsInsideMarkdownLink(markdown, listEnd)
                            if linkEnd and linkEnd > listEnd then
                                -- The list end is inside a link, find a safe newline after the link
                                local safeNewline =
                                    FindSafeNewline(markdown, listEnd, math.min(markdownLength, linkEnd + 200))
                                if safeNewline and safeNewline - pos + 1 <= maxSafeDataSize then
                                    chunkEnd = safeNewline
                                    CM.DebugPrint(
                                        "CHUNKING",
                                        string.format(
                                            "Chunk %d: List end was inside link, moved to safe newline at %d",
                                            chunkNum,
                                            chunkEnd
                                        )
                                    )
                                else
                                    -- Can't find safe position, stay at original chunkEnd
                                    CM.DebugPrint(
                                        "CHUNKING",
                                        string.format(
                                            "Chunk %d: List end at %d is inside link, staying at safe position %d",
                                            chunkNum,
                                            listEnd,
                                            chunkEnd
                                        )
                                    )
                                end
                            else
                                chunkEnd = listEnd
                                CM.DebugPrint(
                                    "CHUNKING",
                                    string.format("Chunk %d: Found list, moving chunk end to %d", chunkNum, chunkEnd)
                                )
                            end
                        else
                            CM.DebugPrint(
                                "CHUNKING",
                                string.format(
                                    "Chunk %d: List extends beyond safe limit, staying at position %d",
                                    chunkNum,
                                    chunkEnd
                                )
                            )
                        end
                    elseif listEnd and listEnd < chunkEnd then
                        chunkEnd = listEnd
                    end
                end
            end

            -- CRITICAL: Final check before finalizing chunkEnd - ensure it doesn't exceed maxSafeDataSize
            local finalChunkSize = chunkEnd - pos + 1
            if finalChunkSize > maxSafeDataSize then
                CM.DebugPrint(
                    "CHUNKING",
                    string.format(
                        "Chunk %d: Final size %d exceeds maxSafeDataSize %d, truncating to safe limit",
                        chunkNum,
                        finalChunkSize,
                        maxSafeDataSize
                    )
                )

                -- CRITICAL: Check if truncation point is in the middle of a table - if so, truncate before table starts
                local safeEndPos = pos + maxSafeDataSize - 1

                -- Find the line at the truncation point
                local lineStartAtTruncation = safeEndPos
                for i = safeEndPos, math.max(pos, safeEndPos - 1000), -1 do
                    if i == pos or string.sub(markdown, i - 1, i - 1) == "\n" then
                        lineStartAtTruncation = i == pos and pos or i
                        break
                    end
                end

                -- Find the end of this line
                local lineEndAtTruncation = safeEndPos
                for i = safeEndPos, math.min(markdownLength, safeEndPos + 500) do
                    if string.sub(markdown, i, i) == "\n" then
                        lineEndAtTruncation = i
                        break
                    end
                end

                local lineAtTruncation = string.sub(markdown, lineStartAtTruncation, lineEndAtTruncation - 1)
                local isInTable = IsTableLine(lineAtTruncation)

                if isInTable then
                    -- We're in the middle of a table - find where the table starts
                    local tableStart = lineStartAtTruncation
                    for i = lineStartAtTruncation - 1, math.max(pos, lineStartAtTruncation - 2000), -1 do
                        if i == pos or string.sub(markdown, i - 1, i - 1) == "\n" then
                            local lineStart = i == pos and pos or i
                            local lineEnd = lineStartAtTruncation
                            for j = i, math.min(markdownLength, i + 500) do
                                if string.sub(markdown, j, j) == "\n" then
                                    lineEnd = j
                                    break
                                end
                            end
                            local line = string.sub(markdown, lineStart, lineEnd - 1)
                            if IsTableLine(line) then
                                tableStart = lineStart
                            else
                                break
                            end
                        end
                    end

                    -- Truncate BEFORE the table starts, not in the middle
                    if tableStart > pos then
                        -- Find the last newline before the table
                        local lastNewlineBeforeTable = nil
                        for i = tableStart - 1, pos, -1 do
                            if string.sub(markdown, i, i) == "\n" then
                                lastNewlineBeforeTable = i
                                break
                            end
                        end
                        if lastNewlineBeforeTable and lastNewlineBeforeTable >= pos then
                            chunkEnd = lastNewlineBeforeTable
                            CM.DebugPrint(
                                "CHUNKING",
                                string.format(
                                    "Chunk %d: Truncated before table at %d (size: %d) to avoid splitting table",
                                    chunkNum,
                                    chunkEnd,
                                    chunkEnd - pos + 1
                                )
                            )
                        else
                            -- Can't find newline before table, use table start
                            chunkEnd = math.max(pos, tableStart - 1)
                            CM.DebugPrint(
                                "CHUNKING",
                                string.format(
                                    "Chunk %d: Truncated at table start %d (size: %d) to avoid splitting table",
                                    chunkNum,
                                    chunkEnd,
                                    chunkEnd - pos + 1
                                )
                            )
                        end
                    else
                        -- Table starts at chunk start, can't avoid it - use regular truncation
                        local lastSafeNewline =
                            FindSafeNewline(markdown, pos, math.min(safeEndPos, chunkEnd, markdownLength))
                        if lastSafeNewline and lastSafeNewline >= pos then
                            chunkEnd = lastSafeNewline
                            CM.DebugPrint(
                                "CHUNKING",
                                string.format(
                                    "Chunk %d: Truncated from %d to %d bytes to stay within limit",
                                    chunkNum,
                                    finalChunkSize,
                                    chunkEnd - pos + 1
                                )
                            )
                        else
                            -- Fallback: find any newline within the limit
                            for i = math.min(safeEndPos, chunkEnd, markdownLength), pos, -1 do
                                if string.sub(markdown, i, i) == "\n" then
                                    chunkEnd = i
                                    CM.DebugPrint(
                                        "CHUNKING",
                                        string.format(
                                            "Chunk %d: Truncated to newline at %d (size: %d)",
                                            chunkNum,
                                            i,
                                            i - pos + 1
                                        )
                                    )
                                    break
                                end
                            end
                        end
                    end
                else
                    -- Not in a table, use regular truncation
                    local lastSafeNewline =
                        FindSafeNewline(markdown, pos, math.min(safeEndPos, chunkEnd, markdownLength))
                    if lastSafeNewline and lastSafeNewline >= pos then
                        chunkEnd = lastSafeNewline
                        CM.DebugPrint(
                            "CHUNKING",
                            string.format(
                                "Chunk %d: Truncated from %d to %d bytes to stay within limit",
                                chunkNum,
                                finalChunkSize,
                                chunkEnd - pos + 1
                            )
                        )
                    else
                        -- Fallback: find any newline within the limit
                        for i = math.min(safeEndPos, chunkEnd, markdownLength), pos, -1 do
                            if string.sub(markdown, i, i) == "\n" then
                                chunkEnd = i
                                CM.DebugPrint(
                                    "CHUNKING",
                                    string.format(
                                        "Chunk %d: Truncated to newline at %d (size: %d)",
                                        chunkNum,
                                        i,
                                        i - pos + 1
                                    )
                                )
                                break
                            end
                        end
                    end
                end
            end

            if not foundNewline then
                -- Use FindSafeNewline for fallback search
                local lastSafeNewline =
                    FindSafeNewline(markdown, pos, math.min(pos + effectiveMaxData - 1, markdownLength))
                if lastSafeNewline then
                    chunkEnd = lastSafeNewline
                    CM.DebugPrint(
                        "CHUNKING",
                        string.format(
                            "Chunk %d: No newline found near potential end, using last safe newline at %d",
                            chunkNum,
                            chunkEnd
                        )
                    )
                else
                    -- Final fallback: regular newline search
                    local lastNewlineBeforePos = nil
                    for i = math.min(pos + effectiveMaxData - 1, markdownLength), pos, -1 do
                        if string.sub(markdown, i, i) == "\n" then
                            lastNewlineBeforePos = i
                            break
                        end
                    end

                    if lastNewlineBeforePos then
                        chunkEnd = lastNewlineBeforePos
                        CM.DebugPrint(
                            "CHUNKING",
                            string.format(
                                "Chunk %d: No safe newline found, using last newline at %d",
                                chunkNum,
                                chunkEnd
                            )
                        )
                    else
                        -- CRITICAL FIX: Use pos instead of pos - 1 to avoid invalid position 0
                        -- If no newline found, use the start position (empty chunk is better than invalid)
                        chunkEnd = math.max(pos, 1)
                        CM.DebugPrint(
                            "CHUNKING",
                            string.format(
                                "Chunk %d: CRITICAL - No newline found anywhere! Using position %d (chunk may be empty)",
                                chunkNum,
                                chunkEnd
                            )
                        )
                    end
                end
            end
        end

        -- CRITICAL: Final safety check - ensure chunkEnd is not inside a markdown link
        if chunkEnd < markdownLength then
            local linkEnd = IsInsideMarkdownLink(markdown, chunkEnd)
            if linkEnd then
                if linkEnd > markdownLength then
                    -- Special case: incomplete link detected (newline at end of line with incomplete link)
                    -- Find a safe newline before this position
                    local safeNewlineBefore = FindSafeNewline(markdown, pos, chunkEnd - 1)
                    if safeNewlineBefore then
                        chunkEnd = safeNewlineBefore
                        CM.DebugPrint(
                            "CHUNKING",
                            string.format(
                                "Chunk %d: Final check - chunkEnd is at newline with incomplete link, moved back to safe newline at %d",
                                chunkNum,
                                chunkEnd
                            )
                        )
                    else
                        CM.DebugPrint(
                            "CHUNKING",
                            string.format(
                                "Chunk %d: CRITICAL - chunkEnd at %d has incomplete link and no safe position found!",
                                chunkNum,
                                chunkEnd
                            )
                        )
                    end
                elseif linkEnd > chunkEnd then
                    -- chunkEnd is inside a link, find a safe newline after the link
                    local safeNewline = FindSafeNewline(markdown, chunkEnd, math.min(markdownLength, linkEnd + 200))
                    -- CRITICAL FIX: Use maxSafeDataSize instead of maxSafeSize for consistency
                    if safeNewline and safeNewline - pos + 1 <= maxSafeDataSize then
                        chunkEnd = safeNewline
                        CM.DebugPrint(
                            "CHUNKING",
                            string.format(
                                "Chunk %d: Final check - chunkEnd was inside link, moved to safe newline at %d",
                                chunkNum,
                                chunkEnd
                            )
                        )
                    else
                        -- Can't find safe position after link, try to find one before the link
                        local safeNewlineBefore = FindSafeNewline(markdown, pos, chunkEnd - 1)
                        if safeNewlineBefore then
                            chunkEnd = safeNewlineBefore
                            CM.DebugPrint(
                                "CHUNKING",
                                string.format(
                                    "Chunk %d: Final check - chunkEnd was inside link, moved back to safe newline at %d",
                                    chunkNum,
                                    chunkEnd
                                )
                            )
                        else
                            CM.DebugPrint(
                                "CHUNKING",
                                string.format(
                                    "Chunk %d: CRITICAL - chunkEnd at %d is inside link and no safe position found!",
                                    chunkNum,
                                    chunkEnd
                                )
                            )
                        end
                    end
                end
            end
        end

        -- Verify chunkEnd is at a newline
        if chunkEnd < markdownLength then
            if string.sub(markdown, chunkEnd, chunkEnd) ~= "\n" then
                local prevNewline = nil
                for i = chunkEnd, pos, -1 do
                    if string.sub(markdown, i, i) == "\n" then
                        prevNewline = i
                        break
                    end
                end
                if prevNewline then
                    -- CRITICAL: Also verify this newline is not inside a link
                    local linkEnd = IsInsideMarkdownLink(markdown, prevNewline)
                    if linkEnd and linkEnd > prevNewline then
                        -- The newline is inside a link, find a safe one before it
                        local safeNewline = FindSafeNewline(markdown, pos, prevNewline - 1)
                        if safeNewline then
                            chunkEnd = safeNewline
                            CM.DebugPrint(
                                "CHUNKING",
                                string.format(
                                    "Chunk %d: chunkEnd was not at newline, found safe newline at %d",
                                    chunkNum,
                                    chunkEnd
                                )
                            )
                        else
                            CM.DebugPrint(
                                "CHUNKING",
                                string.format(
                                    "Chunk %d: CRITICAL - chunkEnd at %d is not at newline and newline is inside link!",
                                    chunkNum,
                                    chunkEnd
                                )
                            )
                            -- CRITICAL FIX: Use pos instead of pos - 1 to avoid invalid position 0
                            chunkEnd = math.max(pos, 1)
                        end
                    else
                        chunkEnd = prevNewline
                        CM.DebugPrint(
                            "CHUNKING",
                            string.format("Chunk %d: chunkEnd was not at newline, moved to %d", chunkNum, chunkEnd)
                        )
                    end
                else
                    CM.DebugPrint(
                        "CHUNKING",
                        string.format("Chunk %d: CRITICAL - chunkEnd at %d is not at newline!", chunkNum, chunkEnd)
                    )
                    -- CRITICAL FIX: Use pos instead of pos - 1 to avoid invalid position 0
                    chunkEnd = math.max(pos, 1)
                end
            end
        end

        -- CRITICAL: Final verification - ensure chunkEnd is at a safe newline and not in a link
        -- This must happen BEFORE extracting chunkData to ensure we don't truncate mid-link
        if chunkEnd < markdownLength then
            -- Verify chunkEnd is at a newline
            if string.sub(markdown, chunkEnd, chunkEnd) ~= "\n" then
                -- Find the last newline before chunkEnd
                for i = chunkEnd, math.max(pos, chunkEnd - 2000), -1 do
                    if string.sub(markdown, i, i) == "\n" then
                        chunkEnd = i
                        break
                    end
                end
            end

            -- Final check: ensure we're not in a link
            local linkEnd = IsInsideMarkdownLink(markdown, chunkEnd)
            if linkEnd then
                if linkEnd > markdownLength then
                    -- Incomplete link - backtrack
                    local safeNewlineBefore = FindSafeNewline(markdown, pos, chunkEnd - 1)
                    if safeNewlineBefore then
                        chunkEnd = safeNewlineBefore
                        CM.DebugPrint(
                            "CHUNKING",
                            string.format(
                                "Chunk %d: Final verification - backtracked from incomplete link to %d",
                                chunkNum,
                                chunkEnd
                            )
                        )
                    end
                elseif linkEnd > chunkEnd then
                    -- Inside link - try to extend or backtrack
                    local safeNewline = FindSafeNewline(markdown, chunkEnd, math.min(markdownLength, linkEnd + 200))
                    if safeNewline and safeNewline - pos + 1 <= maxSafeDataSize then
                        chunkEnd = safeNewline
                    else
                        local safeNewlineBefore = FindSafeNewline(markdown, pos, chunkEnd - 1)
                        if safeNewlineBefore then
                            chunkEnd = safeNewlineBefore
                            CM.DebugPrint(
                                "CHUNKING",
                                string.format(
                                    "Chunk %d: Final verification - backtracked from link to %d",
                                    chunkNum,
                                    chunkEnd
                                )
                            )
                        end
                    end
                end
            end
        end

        -- CRITICAL: Final safety check - ensure chunkEnd is ALWAYS at a safe newline before extraction
        -- This prevents truncation mid-line, mid-link, mid-word, or mid-table
        if chunkEnd < markdownLength then
            -- Check 0: CRITICAL - Ensure we're not in the middle of a table
            local finalTableCheck = FindTableEnd(markdown, chunkEnd, 10000)
            if finalTableCheck and finalTableCheck > chunkEnd then
                -- We're in the middle of a table - this should never happen, but handle it
                CM.DebugPrint(
                    "CHUNKING",
                    string.format(
                        "Chunk %d: CRITICAL - chunkEnd at %d is in middle of table (ends at %d)!",
                        chunkNum,
                        chunkEnd,
                        finalTableCheck
                    )
                )
                -- Try to extend to table end if possible
                local finalTableSize = finalTableCheck - pos + 1
                -- CRITICAL FIX: Strict size enforcement - no overage allowance
                if finalTableSize + paddingSize <= copyLimit then
                    chunkEnd = finalTableCheck
                    CM.DebugPrint(
                        "CHUNKING",
                        string.format(
                            "Chunk %d: Extended to table end at %d to avoid splitting (size: %d + %d padding = %d)",
                            chunkNum,
                            chunkEnd,
                            finalTableSize,
                            paddingSize,
                            finalTableSize + paddingSize
                        )
                    )
                else
                    -- Can't extend - backtrack before table
                    local tableStart = chunkEnd
                    for i = chunkEnd, math.max(pos, chunkEnd - 5000), -1 do
                        if i == pos or string.sub(markdown, i - 1, i - 1) == "\n" then
                            local lineStart = (i == pos) and pos or i
                            local lineEnd = chunkEnd
                            for j = lineStart, math.min(chunkEnd, lineStart + 500) do
                                if string.sub(markdown, j, j) == "\n" then
                                    lineEnd = j
                                    break
                                end
                            end
                            local line = string.sub(markdown, lineStart, lineEnd - 1)
                            if IsTableLine(line) then
                                tableStart = lineStart
                            else
                                break
                            end
                        end
                    end
                    if tableStart > pos then
                        for k = tableStart - 1, math.max(pos, tableStart - 1000), -1 do
                            if k == pos or string.sub(markdown, k - 1, k - 1) == "\n" then
                                chunkEnd = (k == pos) and pos or (k - 1)
                                CM.DebugPrint(
                                    "CHUNKING",
                                    string.format(
                                        "Chunk %d: Final check - backtracked to %d to avoid splitting table",
                                        chunkNum,
                                        chunkEnd
                                    )
                                )
                                break
                            end
                        end
                    end
                end
            end

            -- Check 1: Ensure chunkEnd is at a newline
            if string.sub(markdown, chunkEnd, chunkEnd) ~= "\n" then
                -- chunkEnd is not at a newline - find the last safe newline before it
                local lastSafeNewline = FindSafeNewline(markdown, math.max(pos, chunkEnd - 5000), chunkEnd)
                if not lastSafeNewline then
                    -- Fallback to any newline
                    for i = chunkEnd, math.max(pos, chunkEnd - 5000), -1 do
                        if string.sub(markdown, i, i) == "\n" then
                            lastSafeNewline = i
                            break
                        end
                    end
                end
                if lastSafeNewline and lastSafeNewline >= pos then
                    chunkEnd = lastSafeNewline
                    CM.DebugPrint(
                        "CHUNKING",
                        string.format(
                            "Chunk %d: CRITICAL FIX - chunkEnd was not at newline, moved to safe newline at %d",
                            chunkNum,
                            chunkEnd
                        )
                    )
                else
                    CM.DebugPrint(
                        "CHUNKING",
                        string.format(
                            "Chunk %d: CRITICAL - chunkEnd at %d is not at newline and no safe newline found!",
                            chunkNum,
                            chunkEnd
                        )
                    )
                    -- Emergency: use pos (will create empty or very small chunk, but safe)
                    chunkEnd = pos
                end
            else
                -- Check 2: Even if at newline, ensure we're not inside a link
                local linkEnd = IsInsideMarkdownLink(markdown, chunkEnd)
                if linkEnd and linkEnd > chunkEnd then
                    -- We're at a newline but inside a link - find safe newline after link
                    local copyLimit = CHUNKING.COPY_LIMIT or (editboxLimit - 300)
                    local safeNewline = FindSafeNewline(markdown, chunkEnd, math.min(markdownLength, linkEnd + 200))
                    if safeNewline and safeNewline - pos + 1 <= copyLimit then
                        chunkEnd = safeNewline
                        CM.DebugPrint(
                            "CHUNKING",
                            string.format(
                                "Chunk %d: CRITICAL FIX - chunkEnd was at newline inside link, moved to safe newline at %d",
                                chunkNum,
                                chunkEnd
                            )
                        )
                    else
                        -- Can't extend, backtrack before link
                        local safeNewlineBefore = FindSafeNewline(markdown, pos, chunkEnd - 1)
                        if safeNewlineBefore then
                            chunkEnd = safeNewlineBefore
                            CM.DebugPrint(
                                "CHUNKING",
                                string.format(
                                    "Chunk %d: CRITICAL FIX - chunkEnd was at newline inside link, backtracked to %d",
                                    chunkNum,
                                    chunkEnd
                                )
                            )
                        else
                            CM.DebugPrint(
                                "CHUNKING",
                                string.format(
                                    "Chunk %d: CRITICAL - chunkEnd at newline inside link and no safe position found!",
                                    chunkNum
                                )
                            )
                        end
                    end
                end
            end
        end

        local chunkData = string.sub(markdown, pos, chunkEnd)
        local dataChars = string.len(chunkData)
        -- isLastChunk was already calculated earlier and may have been adjusted
        -- Don't recalculate it here or we'll override important logic
        -- local isLastChunk = (chunkEnd >= markdownLength) -- REMOVED - was causing oversized chunks

        -- CRITICAL: Prepend newline to chunks after the first one
        -- This ensures proper markdown formatting when chunks are split
        if chunkNum > 1 then
            chunkData = "\n" .. chunkData
            dataChars = dataChars + 1
            CM.DebugPrint("CHUNKING", string.format("Chunk %d: Prepended newline (chunk after first)", chunkNum))
        end

        -- CRITICAL: If previous chunk backtracked before a header, prepend newline to this chunk
        -- This ensures the header starts on its own line after the previous chunk's padding
        if prependNewlineToChunk then
            chunkData = "\n" .. chunkData
            dataChars = dataChars + 1
            prependNewlineToChunk = false
            CM.DebugPrint(
                "CHUNKING",
                string.format("Chunk %d: Prepended newline to ensure header starts on new line", chunkNum)
            )
        end

        -- CRITICAL: Safety check - ensure data itself doesn't exceed copy limit
        -- Reserve space for padding on all chunks (including last chunk)
        -- paddingSize is calculated once at the top of the function
        local maxSafeDataSize = copyLimit - paddingSize
        if dataChars > maxSafeDataSize then
            CM.DebugPrint(
                "CHUNKING",
                string.format(
                    "Chunk %d: Data size %d exceeds safe limit %d, finding safe truncation point",
                    chunkNum,
                    dataChars,
                    maxSafeDataSize
                )
            )

            -- Find the last complete line within the safe limit
            -- Search backwards from safeEndPos to find a newline (always use absolute positions)
            local safeEndPos = pos + maxSafeDataSize - 1
            local lastNewlinePos = nil

            -- Search backwards from safeEndPos to find the last safe newline
            local searchStart = math.min(safeEndPos, chunkEnd, markdownLength)
            -- Use FindSafeNewline to avoid splitting inside markdown links
            lastNewlinePos = FindSafeNewline(markdown, pos, searchStart)
            if not lastNewlinePos then
                -- Fallback to regular newline search
                for i = searchStart, pos, -1 do
                    if string.sub(markdown, i, i) == "\n" then
                        lastNewlinePos = i
                        break
                    end
                end
            end

            if lastNewlinePos and lastNewlinePos >= pos then
                -- Found a newline within safe range - use it
                chunkData = string.sub(markdown, pos, lastNewlinePos)
                dataChars = string.len(chunkData)
                chunkEnd = lastNewlinePos
                CM.DebugPrint(
                    "CHUNKING",
                    string.format(
                        "Chunk %d: Truncated to %d chars, ending at newline position %d",
                        chunkNum,
                        dataChars,
                        chunkEnd
                    )
                )
            else
                -- CRITICAL: No newline found in safe range
                -- This should be extremely rare - try to find ANY safe newline before safeEndPos
                local extendedSearchStart = math.max(pos, safeEndPos - 10000)
                lastNewlinePos = FindSafeNewline(markdown, extendedSearchStart, safeEndPos)
                if not lastNewlinePos then
                    -- Fallback to regular newline search
                    for i = safeEndPos, extendedSearchStart, -1 do
                        if string.sub(markdown, i, i) == "\n" then
                            lastNewlinePos = i
                            break
                        end
                    end
                end

                if lastNewlinePos and lastNewlinePos >= pos then
                    chunkData = string.sub(markdown, pos, lastNewlinePos)
                    dataChars = string.len(chunkData)
                    chunkEnd = lastNewlinePos
                    CM.DebugPrint(
                        "CHUNKING",
                        string.format(
                            "Chunk %d: Had to truncate significantly to %d chars to find complete line",
                            chunkNum,
                            dataChars
                        )
                    )
                else
                    -- Absolute last resort: This should only happen if there's a single extremely long line
                    -- Try to find ANY safe position before safeEndPos, even if it's much smaller
                    local emergencySafePos = FindSafeNewline(markdown, pos, safeEndPos)
                    if emergencySafePos and emergencySafePos >= pos then
                        chunkData = string.sub(markdown, pos, emergencySafePos)
                        dataChars = string.len(chunkData)
                        chunkEnd = emergencySafePos
                        CM.DebugPrint(
                            "CHUNKING",
                            string.format(
                                "Chunk %d: CRITICAL - Emergency truncation to safe position %d (size: %d)",
                                chunkNum,
                                emergencySafePos,
                                dataChars
                            )
                        )
                    else
                        -- Last resort: Find the last newline before safeEndPos, even if it's inside a link
                        -- This is better than truncating in the middle of a line
                        local lastNewlineBeforeSafe = nil
                        for i = safeEndPos, math.max(pos, safeEndPos - 10000), -1 do
                            if string.sub(markdown, i, i) == "\n" then
                                lastNewlineBeforeSafe = i
                                break
                            end
                        end
                        if lastNewlineBeforeSafe and lastNewlineBeforeSafe >= pos then
                            chunkData = string.sub(markdown, pos, lastNewlineBeforeSafe)
                            dataChars = string.len(chunkData)
                            chunkEnd = lastNewlineBeforeSafe
                            CM.DebugPrint(
                                "CHUNKING",
                                string.format(
                                    "Chunk %d: CRITICAL - Truncated to newline at %d (may be inside link, size: %d)",
                                    chunkNum,
                                    lastNewlineBeforeSafe,
                                    dataChars
                                )
                            )
                        else
                            CM.DebugPrint(
                                "CHUNKING",
                                string.format(
                                    "Chunk %d: CRITICAL - No newline found in safe range! Line may be truncated at position %d",
                                    chunkNum,
                                    safeEndPos
                                )
                            )
                            chunkData = string.sub(markdown, pos, safeEndPos)
                            dataChars = string.len(chunkData)
                            chunkEnd = safeEndPos
                        end
                    end
                end
            end

            -- Re-check if this is still the last chunk after truncation
            -- Only recalculate if we haven't explicitly disabled it for size constraints
            if isLastChunk then
                isLastChunk = (chunkEnd >= markdownLength)
            end

            -- CRITICAL: After truncation, verify chunkEnd is still safe (not inside a link)
            if chunkEnd < markdownLength then
                local linkEnd = IsInsideMarkdownLink(markdown, chunkEnd)
                if linkEnd then
                    if linkEnd > markdownLength then
                        -- Incomplete link detected - find safe position before
                        local safeNewlineBefore = FindSafeNewline(markdown, pos, chunkEnd - 1)
                        if safeNewlineBefore then
                            chunkData = string.sub(markdown, pos, safeNewlineBefore)
                            dataChars = string.len(chunkData)
                            chunkEnd = safeNewlineBefore
                            CM.DebugPrint(
                                "CHUNKING",
                                string.format(
                                    "Chunk %d: After truncation - chunkEnd had incomplete link, moved to %d",
                                    chunkNum,
                                    chunkEnd
                                )
                            )
                        end
                    elseif linkEnd > chunkEnd then
                        -- chunkEnd is inside a link - find safe position after
                        local safeNewline = FindSafeNewline(markdown, chunkEnd, math.min(markdownLength, linkEnd + 200))
                        if safeNewline and safeNewline - pos + 1 <= maxSafeDataSize then
                            chunkData = string.sub(markdown, pos, safeNewline)
                            dataChars = string.len(chunkData)
                            chunkEnd = safeNewline
                            CM.DebugPrint(
                                "CHUNKING",
                                string.format(
                                    "Chunk %d: After truncation - chunkEnd was inside link, moved to %d",
                                    chunkNum,
                                    chunkEnd
                                )
                            )
                        else
                            -- Try to find safe position before
                            local safeNewlineBefore = FindSafeNewline(markdown, pos, chunkEnd - 1)
                            if safeNewlineBefore then
                                chunkData = string.sub(markdown, pos, safeNewlineBefore)
                                dataChars = string.len(chunkData)
                                chunkEnd = safeNewlineBefore
                                CM.DebugPrint(
                                    "CHUNKING",
                                    string.format(
                                        "Chunk %d: After truncation - chunkEnd was inside link, moved back to %d",
                                        chunkNum,
                                        chunkEnd
                                    )
                                )
                            end
                        end
                    end
                end
            end
        end

        -- CRITICAL: Before calculating padding, ensure chunk doesn't end in the middle of a link
        -- This is a final safety check to prevent truncation during copy
        -- Check both at chunkEnd and at the last newline before chunkEnd
        if chunkEnd < markdownLength then
            -- First, ensure chunkEnd is at a newline (if not, find the previous newline)
            local actualEndPos = chunkEnd
            if string.sub(markdown, chunkEnd, chunkEnd) ~= "\n" then
                -- Find the last newline before chunkEnd
                for i = chunkEnd, math.max(pos, chunkEnd - 2000), -1 do
                    if string.sub(markdown, i, i) == "\n" then
                        actualEndPos = i
                        break
                    end
                end
            end

            -- Check if we're inside a link at the actual end position
            local linkEnd = IsInsideMarkdownLink(markdown, actualEndPos)
            if linkEnd then
                if linkEnd > markdownLength then
                    -- Incomplete link detected (special return value from IsInsideMarkdownLink)
                    -- Backtrack to previous safe newline
                    local safeNewlineBefore = FindSafeNewline(markdown, pos, actualEndPos - 1)
                    if safeNewlineBefore then
                        chunkEnd = safeNewlineBefore
                        CM.DebugPrint(
                            "CHUNKING",
                            string.format(
                                "Chunk %d: Detected incomplete link at end, backtracked to safe newline at %d",
                                chunkNum,
                                chunkEnd
                            )
                        )
                        -- CRITICAL: Re-extract chunk data after adjusting chunkEnd
                        chunkData = string.sub(markdown, pos, chunkEnd)
                        dataChars = string.len(chunkData)
                    else
                        -- Try to find any newline before actualEndPos that's not in a link
                        for i = actualEndPos - 1, math.max(pos, actualEndPos - 2000), -1 do
                            if string.sub(markdown, i, i) == "\n" then
                                local testLinkEnd = IsInsideMarkdownLink(markdown, i)
                                if not testLinkEnd or testLinkEnd <= i then
                                    chunkEnd = i
                                    CM.DebugPrint(
                                        "CHUNKING",
                                        string.format(
                                            "Chunk %d: Found safe newline at %d to avoid incomplete link",
                                            chunkNum,
                                            chunkEnd
                                        )
                                    )
                                    -- CRITICAL: Re-extract chunk data after adjusting chunkEnd
                                    chunkData = string.sub(markdown, pos, chunkEnd)
                                    dataChars = string.len(chunkData)
                                    break
                                end
                            end
                        end
                    end
                elseif linkEnd > actualEndPos then
                    -- actualEndPos is inside a link - find a safe newline after the link
                    local safeNewline = FindSafeNewline(markdown, actualEndPos, math.min(markdownLength, linkEnd + 200))
                    if safeNewline and safeNewline - pos + 1 <= maxSafeDataSize then
                        chunkEnd = safeNewline
                        CM.DebugPrint(
                            "CHUNKING",
                            string.format(
                                "Chunk %d: Final check - chunkEnd was inside link, moved to safe newline at %d",
                                chunkNum,
                                chunkEnd
                            )
                        )
                        -- CRITICAL: Re-extract chunk data after adjusting chunkEnd
                        chunkData = string.sub(markdown, pos, chunkEnd)
                        dataChars = string.len(chunkData)
                    else
                        -- Can't extend, backtrack to before the link
                        local safeNewlineBefore = FindSafeNewline(markdown, pos, actualEndPos - 1)
                        if safeNewlineBefore then
                            chunkEnd = safeNewlineBefore
                            CM.DebugPrint(
                                "CHUNKING",
                                string.format(
                                    "Chunk %d: Final check - chunkEnd was inside link, moved back to safe newline at %d",
                                    chunkNum,
                                    chunkEnd
                                )
                            )
                            -- CRITICAL: Re-extract chunk data after adjusting chunkEnd
                            chunkData = string.sub(markdown, pos, chunkEnd)
                            dataChars = string.len(chunkData)
                        end
                    end
                end
            end
        end

        -- Padding removed: No longer needed with smaller EditBox limits (16K/15K)
        -- Chunks naturally fit within limits without padding

        -- CRITICAL: For the last chunk, ensure we include ALL remaining content ONLY if it fits within limits
        if isLastChunk and chunkEnd < markdownLength then
            local remainingLength = markdownLength - pos + 1
            -- Only include all content if it fits within limits (accounting for padding)
            if remainingLength + paddingSize <= copyLimit then
                CM.DebugPrint(
                    "CHUNKING",
                    string.format(
                        "Chunk %d: Last chunk but chunkEnd (%d) < markdownLength (%d), including all remaining content (%d bytes)",
                        chunkNum,
                        chunkEnd,
                        markdownLength,
                        remainingLength
                    )
                )
                chunkData = string.sub(markdown, pos, markdownLength)
                dataChars = string.len(chunkData)
                chunkEnd = markdownLength
            else
                -- Remaining content is too large - DON'T force it all in, let normal chunking continue
                CM.DebugPrint(
                    "CHUNKING",
                    string.format(
                        "Chunk %d: Remaining content (%d bytes) exceeds limit (%d), continuing normal chunking",
                        chunkNum,
                        remainingLength,
                        copyLimit
                    )
                )
                -- Mark this as NOT the last chunk so we continue chunking
                isLastChunk = false
            end
        end

        local chunkContent = chunkData
        local finalSize = string.len(chunkContent)

        -- Check final size (after marker + padding will be added) against copy limit
        -- totalOverhead is calculated once at the top of the function
        local expectedFinalSize = finalSize + totalOverhead

        if expectedFinalSize > copyLimit then
            CM.DebugPrint(
                "CHUNKING",
                string.format(
                    "Chunk %d: CRITICAL - Final size %d (with padding) exceeds copy limit %d!",
                    chunkNum,
                    expectedFinalSize,
                    copyLimit
                )
            )
            -- NEVER bypass size limits, even for last chunk
            -- If we're here, the chunk is too large and needs to be split
            -- Mark as NOT last chunk so the loop continues
            if isLastChunk then
                CM.DebugPrint(
                    "CHUNKING",
                    string.format(
                        "Chunk %d: Last chunk exceeds limit (%d > %d), will continue chunking instead of forcing oversized chunk",
                        chunkNum,
                        expectedFinalSize,
                        copyLimit
                    )
                )
                isLastChunk = false
            end
            -- For all chunks (including what was thought to be last), truncate to fit within limits
            CM.DebugPrint(
                "CHUNKING",
                string.format(
                    "Chunk %d: Truncating to fit within limits (current: %d, limit: %d, padding: %d)",
                    chunkNum,
                    finalSize,
                    copyLimit,
                    paddingSize
                )
            )
            -- This should not happen if maxSafeDataSize was calculated correctly above
            -- but if it does, we need to continue with what we have
            chunkContent = chunkData
            finalSize = dataChars
        end

        -- CRITICAL: Verify chunk ends with newline (unless it's the last chunk at end of file)
        -- This ensures chunks can be safely concatenated without creating malformed markdown
        local hasTrailingNewline = false
        if not isLastChunk or chunkEnd < markdownLength then
            local lastChar = string.sub(chunkContent, -1, -1)
            if lastChar == "\n" then
                hasTrailingNewline = true
            else
                CM.DebugPrint(
                    "CHUNKING",
                    string.format(
                        "Chunk %d: CRITICAL - Chunk does not end with newline! Last char: '%s' (code: %d)",
                        chunkNum,
                        lastChar,
                        string.byte(lastChar or "")
                    )
                )
                -- Force add newline to prevent concatenation issues
                chunkContent = chunkContent .. "\n"
                finalSize = finalSize + 1
                hasTrailingNewline = true
                CM.DebugPrint("CHUNKING", string.format("Chunk %d: Added missing newline at end", chunkNum))
            end
        end

        -- Add space padding to the last line of the chunk, followed by newlines
        -- This provides buffer space to prevent paste truncation
        -- CRITICAL: If chunk ends with a header followed by a table, backtrack before the header
        -- This keeps the header and table together in the NEXT chunk
        -- For the actual padding string, we need just the spaces part (not including the 2 newlines)
        local spacePaddingSize = 0 -- Default: no padding
        if not CHUNKING.DISABLE_PADDING then
            spacePaddingSize = CHUNKING.SPACE_PADDING_SIZE or 85
        end

        -- Check if we're ending on a header that's followed by a table
        if hasTrailingNewline and chunkEnd < markdownLength then
            if IsHeaderBeforeTable(markdown, chunkEnd, markdownLength) then
                -- Find the start of the header line
                local headerLineStart = chunkEnd
                for i = chunkEnd - 1, math.max(pos, chunkEnd - 1000), -1 do
                    if i == pos or string.sub(markdown, i - 1, i - 1) == "\n" then
                        headerLineStart = (i == pos) and pos or i
                        break
                    end
                end

                -- Backtrack to just before the header
                if headerLineStart > pos then
                    -- Find the newline before the header
                    local newChunkEnd = headerLineStart - 1
                    local proposedDataChars = newChunkEnd - pos + 1

                    -- CRITICAL FIX: Validate size before accepting backtrack
                    if proposedDataChars + paddingSize <= copyLimit and proposedDataChars >= 100 then
                        -- Update chunkEnd, chunkData, and related variables
                        chunkEnd = newChunkEnd
                        chunkData = string.sub(markdown, pos, chunkEnd)
                        dataChars = string.len(chunkData)
                        chunkContent = chunkData
                        finalSize = string.len(chunkContent)

                        -- Verify the new chunkEnd is at a newline
                        if string.sub(markdown, chunkEnd, chunkEnd) == "\n" then
                            hasTrailingNewline = true
                        else
                            hasTrailingNewline = false
                        end

                        -- CRITICAL: Set flag to prepend newline to next chunk
                        -- This ensures the header starts on its own line after padding
                        prependNewlineToChunk = true

                        CM.DebugPrint(
                            "CHUNKING",
                            string.format(
                                "Chunk %d: Backtracked from %d to %d to keep header+table together in next chunk (size: %d + %d padding = %d)",
                                chunkNum,
                                chunkEnd + (headerLineStart - pos),
                                chunkEnd,
                                proposedDataChars,
                                paddingSize,
                                proposedDataChars + paddingSize
                            )
                        )
                    else
                        -- Backtracking would create invalid chunk size
                        if proposedDataChars + paddingSize > copyLimit then
                            CM.DebugPrint(
                                "CHUNKING",
                                string.format(
                                    "Chunk %d: Header backtracking would exceed copy limit (%d + %d = %d > %d), skipping",
                                    chunkNum,
                                    proposedDataChars,
                                    paddingSize,
                                    proposedDataChars + paddingSize,
                                    copyLimit
                                )
                            )
                        else
                            CM.DebugPrint(
                                "CHUNKING",
                                string.format(
                                    "Chunk %d: Header backtracking would create too-small chunk (%d < 100), skipping",
                                    chunkNum,
                                    proposedDataChars
                                )
                            )
                        end
                    end
                end
            end
        end

        -- Prepend newline if needed (from previous chunk split)
        if prependNewlineToChunk then
            chunkContent = "\n" .. chunkContent
            prependNewlineToChunk = false
        end

        -- Prepend Mermaid header if needed
        if prependMermaidHeader then
            -- CRITICAL: Check if chunkContent already starts with the header content
            -- This can happen when the chunk starts right after ``` and includes init/flowchart
            -- If so, we only prepend ```mermaid (the opening fence)
            local trimmedContent = chunkContent:match("^%s*(.-)") or ""
            local startsWithInit = trimmedContent:match("^%%{init:")
            local startsWithFlowchart = trimmedContent:match("^flowchart") 
                                     or trimmedContent:match("^graph%s")
                                     or trimmedContent:match("^sequenceDiagram")
                                     or trimmedContent:match("^gantt")
                                     or trimmedContent:match("^classDiagram")
                                     or trimmedContent:match("^stateDiagram")
                                     or trimmedContent:match("^erDiagram")
                                     or trimmedContent:match("^pie")
                                     or trimmedContent:match("^journey")
            
            if startsWithInit or startsWithFlowchart then
                -- Chunk already has the header content, only prepend the opening fence
                chunkContent = "```mermaid\n" .. chunkContent
                CM.DebugPrint("CHUNKING", "Chunk already contains mermaid header, only prepending fence")
            else
                -- Chunk doesn't have header, prepend full header
                chunkContent = prependMermaidHeader .. chunkContent
            end
            prependMermaidHeader = nil
        end


        -- Add HTML comment marker at START of chunk (safe, won't be truncated, ignored by renderers)
        local contentSizeBeforePadding = string.len(chunkContent)
        local chunkMarker =
            string.format("<!-- Chunk %d (%d bytes before padding) -->\n\n", chunkNum, contentSizeBeforePadding)
        chunkContent = chunkMarker .. chunkContent
        finalSize = string.len(chunkContent)

        -- Check if we split inside a Mermaid block
        -- If so, we need to close this block and prepare header for next block
        local inMermaid, mStart, mEnd = IsInsideMermaidBlock(markdown, chunkEnd)
        -- Only if we are strictly inside (chunkEnd < mEnd)
        -- Note: mEnd might be the end of the block ```
        if inMermaid and chunkEnd < mEnd then
            -- Check if we are really inside the block (not just at the end)
            -- If chunkEnd points to the newline before ```, we are effectively at the end?
            -- IsInsideMermaidBlock returns blockEnd as position AFTER ```

            -- If chunkEnd is inside, append closing backticks
            chunkContent = chunkContent .. "\n```\n"

            -- Prepare header for next chunk
            -- We need to find the start of the MAIN mermaid block to get the header
            -- mStart might be a subgraph start. We need the block start.
            -- Search backwards from mStart for ```mermaid
            local blockStart = mStart
            local searchLimit = math.max(1, mStart - 50000)
            -- If mStart is subgraph, search back. If mStart is ```mermaid, we are good.
            local checkStr = string.sub(markdown, math.max(1, mStart), math.min(markdownLength, mStart + 20))
            if checkStr:match("subgraph") then
                -- We are in a subgraph, need to find main block start
                -- This is expensive but necessary if we split inside subgraph (fallback case)
                -- Or if we split at top level but IsInsideMermaidBlock returns top level range

                -- Wait, if we are at top level, mStart IS the block start (or close to it).
                -- IsInsideMermaidBlock returns `mermaidStart` which is `i - 9` (start of ```mermaid).
                -- So checkStr should match ```mermaid.
            end

            -- If we are in a subgraph, we might have trouble finding the header easily if we don't search back.
            -- But let's assume for now we split at top level or close enough.
            -- If we can't find ```mermaid at mStart, we search back.

            if not string.sub(markdown, mStart, mStart + 10):match("```mermaid") then
                -- Search back for ```mermaid
                for k = mStart, searchLimit, -1 do
                    if string.sub(markdown, k, k + 9) == "```mermaid" then
                        blockStart = k
                        break
                    end
                end
            end

            local header = GetMermaidHeader(markdown, blockStart)
            prependMermaidHeader = "```mermaid\n" .. header .. "\n"

            CM.DebugPrint(
                "CHUNKING",
                string.format(
                    "Split inside Mermaid block. Appended closing backticks and prepared header '%s' for next chunk.",
                    header:gsub("\n", "\\n")
                )
            )
        end

        -- Add padding only if enabled
        if not CHUNKING.DISABLE_PADDING then
            -- CRITICAL: Use NEWLINES as padding (not spaces or HTML comments)
            -- Newlines are safe if truncated, work in any markdown context, and are invisible in rendered output
            -- Normalize trailing newlines to single newline, then add padding newlines
            chunkContent = chunkContent:gsub("\n+$", "\n") .. string.rep("\n", spacePaddingSize)
            finalSize = string.len(chunkContent)
            CM.DebugPrint(
                "CHUNKING",
                string.format(
                    "Chunk %d: Added padding (%d newlines = %d bytes total, isLast: %s)",
                    chunkNum,
                    spacePaddingSize,
                    paddingSize,
                    tostring(isLastChunk)
                )
            )
        else
            -- When padding is disabled, just normalize trailing newlines to exactly 1 newline
            chunkContent = chunkContent:gsub("\n+$", "\n")
            -- No size adjustment needed since we're just normalizing existing newlines
            CM.DebugPrint(
                "CHUNKING",
                string.format(
                    "Chunk %d: Padding disabled - normalized trailing newlines only (isLast: %s)",
                    chunkNum,
                    tostring(isLastChunk)
                )
            )
        end

        -- CRITICAL SAFETY NET: Ensure chunk ends on complete line
        -- If chunk doesn't end with newline, truncate to last newline
        if not isLastChunk and string.sub(chunkContent, -1, -1) ~= "\n" then
            local lastNewline = string.find(chunkContent, "\n[^\n]*$")
            if lastNewline then
                local originalSize = finalSize
                chunkContent = string.sub(chunkContent, 1, lastNewline)
                finalSize = string.len(chunkContent)
                CM.Warn(
                    string.format(
                        "Chunk %d: SAFETY TRUNCATION - chunk didn't end on newline, truncated from %d to %d bytes",
                        chunkNum,
                        originalSize,
                        finalSize
                    )
                )
            else
                CM.Error(string.format("Chunk %d: CRITICAL - chunk has no newlines, cannot truncate safely!", chunkNum))
            end
        end

        table.insert(chunks, { content = chunkContent })
        CM.DebugPrint(
            "CHUNKING",
            string.format(
                "Chunk %d: %d chars (isLast: %s, endsWithNewline: %s)",
                chunkNum,
                finalSize,
                tostring(isLastChunk),
                tostring(string.sub(chunkContent, -1, -1) == "\n")
            )
        )

        -- Advance position for next chunk, or exit if truly done
        if chunkEnd < markdownLength then
            pos = chunkEnd + 1
            chunkNum = chunkNum + 1
        elseif not isLastChunk then
            -- We set isLastChunk=false due to size constraints
            -- Continue chunking from next position
            pos = chunkEnd + 1
            chunkNum = chunkNum + 1
            CM.DebugPrint(
                "CHUNKING",
                string.format("Chunk %d: Continuing chunking despite reaching end (chunk was too large)", chunkNum)
            )
        else
            -- Truly the last chunk - we're done
            break
        end
    end

    CM.DebugPrint("CHUNKING", string.format("Split into %d chunks (total: %d chars)", #chunks, markdownLength))
    return chunks
end

-- =====================================================
-- SECTION-BASED CHUNKING (NEW APPROACH)
-- =====================================================

---New section-based chunking implementation
---Uses natural document structure for intelligent splitting
---@param markdown string The markdown content to chunk
---@return table Array of chunk objects
local function SplitMarkdownIntoChunks_SectionBased(markdown)
    local chunks = {}
    local markdownLength = string.len(markdown)
    local maxSize = CHUNKING.COPY_LIMIT or 5700

    -- VISIBLE MESSAGE TO USER
    CM.Info("✨ Using NEW section-based chunking algorithm")
    CM.DebugPrint("CHUNKING", "Using SECTION-BASED chunking algorithm")
    CM.DebugPrint("CHUNKING", string.format("Input: %d chars, maxSize: %d", markdownLength, maxSize))

    -- Early exit: single chunk
    if markdownLength <= maxSize then
        CM.DebugPrint("CHUNKING", "Content fits in single chunk")
        return { { content = markdown, size = markdownLength } }
    end

    -- Parse markdown structure
    local MarkdownParser = CM.utils.MarkdownParser
    if not MarkdownParser or not MarkdownParser.ParseSections then
        CM.DebugPrint("CHUNKING", "MarkdownParser not available - falling back to legacy chunking")
        return SplitMarkdownIntoChunks_Legacy(markdown)
    end

    local sections = MarkdownParser.ParseSections(markdown)
    CM.DebugPrint("CHUNKING", string.format("Parsed %d sections", #sections))

    -- Build chunks from sections
    local ChunkBuilder = CM.utils.ChunkBuilder
    if not ChunkBuilder or not ChunkBuilder.BuildChunks then
        CM.DebugPrint("CHUNKING", "ChunkBuilder not available - falling back to legacy chunking")
        return SplitMarkdownIntoChunks_Legacy(markdown)
    end

    chunks = ChunkBuilder.BuildChunks(sections, maxSize, {
        preserveSections = true,
        preserveSubsections = true,
        preserveTables = true,
        minChunkSize = 100,
    })

    -- Validate all chunks
    local allValid = true
    for i, chunk in ipairs(chunks) do
        if chunk.size > maxSize then
            CM.Error(string.format("ASSERTION FAILED: Chunk %d exceeds limit: %d > %d", i, chunk.size, maxSize))
            allValid = false
        end

        CM.DebugPrint("CHUNKING", string.format("Chunk %d: %d chars", i, chunk.size))
    end

    if not allValid then
        CM.Error("Section-based chunking produced oversized chunks - falling back to legacy")
        return SplitMarkdownIntoChunks_Legacy(markdown)
    end

    CM.DebugPrint("CHUNKING", string.format("Section-based chunking complete: %d chunks, all within limits", #chunks))

    return chunks
end

---Main entry point - routes to section-based or legacy chunking
---@param markdown string The markdown content to chunk
---@return table Array of chunk objects
local function SplitMarkdownIntoChunks(markdown)
    -- Check feature flag
    if CHUNKING.USE_SECTION_BASED_CHUNKING then
        return SplitMarkdownIntoChunks_SectionBased(markdown)
    else
        CM.DebugPrint("CHUNKING", "Using LEGACY chunking algorithm (feature flag disabled)")
        return SplitMarkdownIntoChunks_Legacy(markdown)
    end
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.utils.Chunking = {
    SplitMarkdownIntoChunks = SplitMarkdownIntoChunks,
    SplitMarkdownIntoChunks_Legacy = SplitMarkdownIntoChunks_Legacy,
    SplitMarkdownIntoChunks_SectionBased = SplitMarkdownIntoChunks_SectionBased,
    StripPadding = StripPadding,
}

CM.DebugPrint("UTILS", "Chunking module loaded")
