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
    if not line or line == "" then return false end
    return line:match("^%s*|") ~= nil
end

-- Helper function to check if a line is a markdown header
local function IsHeaderLine(line)
    if not line or line == "" then return false end
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
    if not line or line == "" then return false end
    
    -- Strip all leading characters that aren't list markers or regular printable chars
    -- This handles zero-width spaces and other invisible Unicode characters
    local cleaned = line
    -- Remove zero-width space (U+200B = \226\128\139) and similar invisible chars
    -- Pattern: match UTF-8 sequences that are likely zero-width/invisible chars
    cleaned = cleaned:gsub("^\226\128\139+", "")  -- Zero-width space
    cleaned = cleaned:gsub("^\226\128\140+", "")  -- Zero-width non-joiner
    cleaned = cleaned:gsub("^\226\128\141+", "")  -- Zero-width joiner
    -- Remove regular leading whitespace
    cleaned = cleaned:gsub("^%s+", "")
    
    -- Check if cleaned line starts with a list marker
    if cleaned:match("^[-*+]%s") or cleaned:match("^%d+[.)]%s") then
        return true
    end
    
    -- Fallback: check original pattern (handles normal cases without invisible chars)
    return line:match("^%s*[-*+]%s") ~= nil or line:match("^%s*%d+[.)]%s") ~= nil
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
    if pos < 1 or pos > markdownLen then return nil end
    
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
                        return j  -- Return position of closing paren
                    end
                end
                -- No closing paren found - this is an incomplete link
                -- Return a position beyond the line to indicate we need to skip this newline
                return markdownLen + 1  -- Special value indicating incomplete link
            end
        end
    end
    
    -- Search backwards from pos to find if we're inside parentheses that are part of a markdown link
    -- Pattern: [text](url) - we need to check if pos is between ( and )
    local parenDepth = 0
    local foundOpenParen = nil
    local searchStart = math.max(1, pos - 1000)  -- Search up to 1000 chars back
    
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
                            return j  -- Return position of closing paren
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

-- Helper function to find a safe newline position that's not inside markdown structures
-- Returns the position of a safe newline, or nil if none found
local function FindSafeNewline(markdown, startPos, endPos)
    local markdownLen = string.len(markdown)
    endPos = math.min(endPos, markdownLen)
    
    -- Search backwards from endPos to startPos
    for i = endPos, startPos, -1 do
        if string.sub(markdown, i, i) == "\n" then
            -- Check if this newline is inside a markdown link
            local linkEnd = IsInsideMarkdownLink(markdown, i)
            if linkEnd then
                -- This newline is inside a link, skip to after the link
                if linkEnd < endPos then
                    -- Try to find a newline after the link
                    for j = linkEnd + 1, math.min(markdownLen, linkEnd + 200) do
                        if string.sub(markdown, j, j) == "\n" then
                            return j
                        end
                    end
                end
                -- If we can't find a newline after the link, continue searching backwards
            else
                -- This newline is safe to use
                return i
            end
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
-- MAIN CHUNKING FUNCTION
-- =====================================================

-- Split markdown into chunks with conservative padding to prevent truncation
-- This is the consolidated, best implementation that handles:
-- 1. Tables and lists properly (doesn't split in the middle)
-- 2. Padding to prevent truncation
-- 3. Extensive safety checks
-- 4. Always ends on complete lines
local function SplitMarkdownIntoChunks(markdown)
    local chunks = {}
    local markdownLength = string.len(markdown)
    local maxDataChars = CHUNKING.MAX_DATA_CHARS
    -- Padding variables removed - no longer needed with smaller EditBox limits
    local editboxLimit = CHUNKING.EDITBOX_LIMIT
    
    -- Padding removed: No longer needed with smaller EditBox limits (16K/15K)
    -- Chunks naturally fit within limits without padding
    if markdownLength <= maxDataChars then
        return {{content = markdown}}
    end
    
    -- Split into chunks, always ending on complete lines
    local chunkNum = 1
    local pos = 1
    local prependNewlineToChunk = false  -- Track if next chunk needs a leading newline
    
    while pos <= markdownLength do
        -- Calculate safe boundaries for this chunk
        -- Use COPY_LIMIT instead of EDITBOX_LIMIT to ensure chunks can be copied safely
        local copyLimit = CHUNKING.COPY_LIMIT or (editboxLimit - 300)  -- Fallback if COPY_LIMIT not defined
        -- Account for padding (85 spaces + newline + newline = 87 chars) that will be added to all chunks
        local paddingSize = (CHUNKING.SPACE_PADDING_SIZE or 85) + 2  -- spaces + newline + newline
        
        -- First, calculate potential end without padding to determine if this is the last chunk
        local initialEffectiveMaxData = math.min(maxDataChars, copyLimit)
        local initialPotentialEnd = math.min(pos + initialEffectiveMaxData - 1, markdownLength)
        local isLastChunk = (initialPotentialEnd >= markdownLength)
        
        -- Reserve space for padding on all chunks (including last chunk)
        -- Padding helps prevent paste truncation
        local maxSafeDataSize = copyLimit - paddingSize
        local effectiveMaxData = math.min(maxDataChars, maxSafeDataSize)
        local maxSafeSize = copyLimit
        -- CRITICAL: Ensure we never exceed maxSafeDataSize (not maxSafeSize) for data content
        local potentialEnd = math.min(pos + effectiveMaxData - 1, markdownLength)
        local chunkEnd = potentialEnd
        local foundNewline = false
        -- Recalculate isLastChunk after adjusting for padding
        isLastChunk = (potentialEnd >= markdownLength)
        
        if potentialEnd < markdownLength then
            local searchStart = math.max(pos, potentialEnd - 1000)
            
            -- CONSERVATIVE: Before finding a newline, check if we're about to enter a table/list
            -- If so, and it won't fit, stop the chunk before it starts
            -- CRITICAL: Also check if we're on the line IMMEDIATELY BEFORE a table - never chunk there
            local lookAheadStart = potentialEnd + 1
            local lookAheadEnd = math.min(potentialEnd + 500, markdownLength)  -- Check up to 500 chars ahead
            local foundUpcomingStructure = false
            local structureStartPos = nil
            local isBeforeTable = false
            local tableStartPos = nil
            
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
                    if IsTableLine(line) then
                        -- Found a table starting - CRITICAL: Never chunk on the line before a table
                        tableStartPos = checkPos
                        isBeforeTable = true
                        -- Find the table end to see if we can include it
                        local structureEnd = FindTableEnd(markdown, lineEnd, 10000)
                        if structureEnd then
                            local structureSize = structureEnd - checkPos + 1
                            local chunkWithStructure = (checkPos - pos) + structureSize
                        local structureOverageAllowance = 1500
                        local effectiveMaxForStructures = maxSafeDataSize + structureOverageAllowance
                            -- If adding this table would exceed the effective limit (with overage), stop chunk before it
                            if chunkWithStructure > effectiveMaxForStructures + 500 then
                                foundUpcomingStructure = true
                                structureStartPos = checkPos
                            end
                        end
                        break  -- Found table, stop looking
                    elseif IsListLine(line) then
                        -- Found a list starting soon - check if it will fit
                        local structureOverageAllowance = 1500
                        local effectiveMaxForStructures = maxSafeDataSize + structureOverageAllowance
                        
                        local structureEnd = FindListEnd(markdown, lineEnd, 10000)
                        if structureEnd then
                            local structureSize = structureEnd - checkPos + 1
                            local chunkWithStructure = (checkPos - pos) + structureSize
                            -- If adding this structure would exceed the effective limit (with overage), stop chunk before it
                            if chunkWithStructure > effectiveMaxForStructures + 500 then
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
                    local structureOverageAllowance = 2000  -- Allow more overage for tables
                    local effectiveMaxForStructures = maxSafeDataSize + structureOverageAllowance
                    
                    if tableChunkSize <= effectiveMaxForStructures then
                        -- Can include the table (and header) - extend to table end
                        chunkEnd = tableEnd
                        foundNewline = true
                        CM.DebugPrint("CHUNKING", string.format("Chunk %d: Extending to include %stable starting at %d (ends at %d)", chunkNum, isHeaderBeforeTable and "header+" or "", tableStartPos, tableEnd))
                    else
                        -- Can't include table - backtrack to before the header (or before the line before table)
                        if isHeaderBeforeTable then
                            -- Backtrack to before the header so header+table stay together
                            for i = lineBeforeTableStart - 1, math.max(pos, lineBeforeTableStart - 1000), -1 do
                                if i == pos or string.sub(markdown, i - 1, i - 1) == "\n" then
                                    chunkEnd = (i == pos) and pos or (i - 1)
                                    foundNewline = true
                                    CM.DebugPrint("CHUNKING", string.format("Chunk %d: Backtracked from %d to %d to keep header+table together", chunkNum, potentialEnd, chunkEnd))
                                    break
                                end
                            end
                        else
                            -- Not a header, just backtrack to before the line before table
                            for i = lineBeforeTableStart - 1, math.max(pos, lineBeforeTableStart - 1000), -1 do
                                if i == pos or string.sub(markdown, i - 1, i - 1) == "\n" then
                                    chunkEnd = (i == pos) and pos or (i - 1)
                                    foundNewline = true
                                    CM.DebugPrint("CHUNKING", string.format("Chunk %d: Backtracked from %d to %d to avoid chunking on line before table", chunkNum, potentialEnd, chunkEnd))
                                    break
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
                                chunkEnd = (i == pos) and pos or (i - 1)
                                foundNewline = true
                                CM.DebugPrint("CHUNKING", string.format("Chunk %d: Backtracked to before header to keep header+table together (table end not found)", chunkNum))
                                break
                            end
                        end
                    else
                        -- Not a header, just backtrack
                        for i = lineBeforeTableStart - 1, math.max(pos, lineBeforeTableStart - 1000), -1 do
                            if i == pos or string.sub(markdown, i - 1, i - 1) == "\n" then
                                chunkEnd = (i == pos) and pos or (i - 1)
                                foundNewline = true
                                CM.DebugPrint("CHUNKING", string.format("Chunk %d: Backtracked to avoid chunking on line before table (table end not found)", chunkNum))
                                break
                            end
                        end
                    end
                end
            end
            
            -- If we found an upcoming structure that won't fit, stop chunk before it
            if foundUpcomingStructure and structureStartPos and not isBeforeTable then
                -- Find the last newline before the structure starts
                for i = structureStartPos - 1, math.max(pos, structureStartPos - 1000), -1 do
                    if string.sub(markdown, i, i) == "\n" then
                        chunkEnd = i
                        foundNewline = true
                        CM.DebugPrint("CHUNKING", string.format("Chunk %d: Stopping before upcoming structure at %d (would exceed limit)", chunkNum, structureStartPos))
                        break
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
                    for i = potentialEnd, searchStart, -1 do
                        if string.sub(markdown, i, i) == "\n" then
                            chunkEnd = i
                            foundNewline = true
                            break
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
                    for i = potentialEnd, extendedSearchStart, -1 do
                        if string.sub(markdown, i, i) == "\n" then
                            chunkEnd = i
                            foundNewline = true
                            break
                        end
                    end
                end
            end
        elseif isLastChunk then
            -- For last chunk, find the last newline before the end
            local searchStart = math.max(pos, markdownLength - 1000)
            for i = markdownLength, searchStart, -1 do
                if string.sub(markdown, i, i) == "\n" then
                    chunkEnd = i
                    foundNewline = true
                    break
                end
            end
            -- If no newline found, chunkEnd stays at markdownLength
        end
        
        -- CRITICAL: Check if chunkEnd is in the middle of a table or list
        -- NEVER allow chunking in the middle of a table - always extend to end or backtrack before start
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
                
                -- CRITICAL: Also check if the NEXT line is a table line
                -- If both previous and next are table lines, we're in the middle of a table
                if chunkEnd < markdownLength then
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
                            CM.DebugPrint("CHUNKING", string.format("Chunk %d: On %s before table, table ends at %d", chunkNum, isHeaderBeforeTable and "header" or "line", tableEnd))
                        end
                    end
                end
            end
            
            -- CRITICAL: If we're in a table (on, after, before, between table lines) OR on line before table, we MUST extend
            -- Never allow chunking in the middle of a table or on the line before a table
            -- If we're on a header before a table, we MUST extend to include header+table or backtrack before header
            if (isInTable or isOnLineBeforeTable) and tableEnd and tableEnd > chunkEnd then
                -- We're in a table or before a table - MUST extend to end of table, not backtrack
                -- If we're on a header before a table, ensure header+table stay together
                if isHeaderBeforeTable and headerLineStart then
                    -- Check if we can include header+table
                    local headerTableChunkSize = tableEnd - headerLineStart + 1
                    local structureOverageAllowance = 2000
                    local effectiveMaxForStructures = maxSafeDataSize + structureOverageAllowance
                    
                    if headerTableChunkSize <= effectiveMaxForStructures then
                        -- Can include header+table - EXTEND IMMEDIATELY to keep them together
                        chunkEnd = tableEnd
                        CM.DebugPrint("CHUNKING", string.format("Chunk %d: On header before table, extended to include header+table (ends at %d)", chunkNum, tableEnd))
                    else
                        -- Can't include header+table - backtrack before header
                        for i = headerLineStart - 1, math.max(pos, headerLineStart - 1000), -1 do
                            if i == pos or string.sub(markdown, i - 1, i - 1) == "\n" then
                                chunkEnd = (i == pos) and pos or (i - 1)
                                CM.DebugPrint("CHUNKING", string.format("Chunk %d: Backtracked to before header to keep header+table together", chunkNum))
                                break
                            end
                        end
                        -- Reset flags since we backtracked
                        isOnLineBeforeTable = false
                        isHeaderBeforeTable = false
                        tableEnd = nil
                    end
                else
                    -- Not a header, will extend in logic below
                    CM.DebugPrint("CHUNKING", string.format("Chunk %d: In table or before table, will extend to table end at %d", chunkNum, tableEnd))
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
                                    CM.DebugPrint("CHUNKING", string.format("Chunk %d: Backtracked from %d to %d to avoid splitting table", chunkNum, originalChunkEnd, chunkEnd))
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
                    while nextLineStart <= markdownLength and string.sub(markdown, nextLineStart, nextLineStart) == "\n" do
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
                                    CM.DebugPrint("CHUNKING", string.format("Chunk %d: Backtracked from %d to %d to avoid splitting list", chunkNum, originalChunkEnd, chunkEnd))
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
                CM.Warn(string.format("Chunk %d: Current size %d already exceeds maxSafeDataSize %d, not extending for table/list", chunkNum, currentChunkSize, maxSafeDataSize))
            else
                -- CRITICAL: For last chunk, search to end of markdown to find complete table
                local tableSearchLimit = isLastChunk and markdownLength or 10000
                
                -- CRITICAL: Check if we already extended chunkEnd in early detection (header+table case)
                -- If so, preserve the outer tableEnd value and skip re-detection
                local alreadyExtendedForHeader = isHeaderBeforeTable and headerLineStart and tableEnd and chunkEnd == tableEnd
                
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
                        while nextLineStart <= markdownLength and string.sub(markdown, nextLineStart, nextLineStart) == "\n" do
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
                                    CM.DebugPrint("CHUNKING", string.format("Chunk %d: Found table starting after chunkEnd%s, table ends at %d", chunkNum, headerBeforeTable and " (with header before)" or "", tableEnd))
                                    -- CRITICAL: After finding a table starting after chunkEnd, also check for consecutive tables
                                    -- This handles cases where multiple tables appear consecutively (e.g., Companion section)
                                    local nextTableStart = tableEnd + 1
                                    if nextTableStart <= markdownLength then
                                        -- Skip empty lines
                                        while nextTableStart <= markdownLength and string.sub(markdown, nextTableStart, nextTableStart) == "\n" do
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
                                                -- There's another table starting right after - find its end
                                                local nextTableEnd = FindTableEnd(markdown, nextTableLineEnd, tableSearchLimit)
                                                if nextTableEnd and nextTableEnd > tableEnd then
                                                    local combinedTableChunkSize = nextTableEnd - pos + 1
                                                    if combinedTableChunkSize <= maxSafeDataSize then
                                                        tableEnd = nextTableEnd
                                                        CM.DebugPrint("CHUNKING", string.format("Chunk %d: Found consecutive table after chunkEnd, extending table end to %d", chunkNum, tableEnd))
                                                    else
                                                        CM.DebugPrint("CHUNKING", string.format("Chunk %d: Consecutive table after chunkEnd extends beyond safe limit, staying at first table end %d", chunkNum, tableEnd))
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
                            CM.DebugPrint("CHUNKING", string.format("Chunk %d: Found header+table, extending chunk end to %d to keep them together (header at %d)", chunkNum, chunkEnd, headerLineStart))
                        else
                        -- CRITICAL: Verify the new chunk end is not inside a markdown link
                        local linkEnd = IsInsideMarkdownLink(markdown, tableEnd)
                        if linkEnd and linkEnd > tableEnd then
                            -- The table end is inside a link, find a safe newline after the link
                            local safeNewline = FindSafeNewline(markdown, tableEnd, math.min(markdownLength, linkEnd + 200))
                            if safeNewline and safeNewline - pos + 1 <= maxSafeDataSize then
                                chunkEnd = safeNewline
                                CM.DebugPrint("CHUNKING", string.format("Chunk %d: Table end was inside link, moved to safe newline at %d", chunkNum, chunkEnd))
                            else
                                -- Can't find safe position, stay at original chunkEnd
                                CM.Warn(string.format("Chunk %d: Table end at %d is inside link, staying at safe position %d", chunkNum, tableEnd, chunkEnd))
                            end
                        else
                            chunkEnd = tableEnd
                            CM.DebugPrint("CHUNKING", string.format("Chunk %d: Found table, moving chunk end to %d", chunkNum, chunkEnd))
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
                                CM.Warn(string.format("Chunk %d: Header+table won't fit (size: %d, remaining: %d), backtracking before header", chunkNum, tableChunkSize, remainingSpace))
                                -- Backtrack to before the header
                                for i = headerLineStart - 1, math.max(pos, headerLineStart - 1000), -1 do
                                    if i == pos or string.sub(markdown, i - 1, i - 1) == "\n" then
                                        chunkEnd = (i == pos) and pos or (i - 1)
                                        CM.Warn(string.format("Chunk %d: Backtracked from %d to %d to keep header+table together", chunkNum, originalChunkEnd, chunkEnd))
                                        break
                                    end
                                end
                            else
                                CM.Warn(string.format("Chunk %d: In table but can't extend (size: %d, remaining: %d), backtracking before table", chunkNum, tableChunkSize, remainingSpace))
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
                                            CM.Warn(string.format("Chunk %d: Backtracked from %d to %d to avoid splitting table", chunkNum, originalChunkEnd, chunkEnd))
                                            break
                                        end
                                    end
                                else
                                    -- Table starts at chunk start - can't avoid it, but at least try to extend
                                    -- This is a fallback - ideally this shouldn't happen
                                    CM.Error(string.format("Chunk %d: CRITICAL - Table starts at chunk start, cannot avoid splitting!", chunkNum))
                                end
                            end
                        else
                        CM.DebugPrint("CHUNKING", string.format("Chunk %d: Table extends beyond safe limit or too close to limit (size: %d, remaining: %d), staying at %d", chunkNum, tableChunkSize, remainingSpace, chunkEnd))
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
                            while nextTableStart <= markdownLength and string.sub(markdown, nextTableStart, nextTableStart) == "\n" do
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
                                            CM.DebugPrint("CHUNKING", string.format("Chunk %d: Found consecutive table, extending chunk end to %d (size: %d, limit: %d)", chunkNum, chunkEnd, combinedTableChunkSize, effectiveMaxForStructures))
                                            
                                            -- CRITICAL: After extending for consecutive table, also check for a list starting right after
                                            -- This handles cases like Companion section: table -> table -> list
                                            local afterTableStart = chunkEnd + 1
                                            if afterTableStart <= markdownLength then
                                                -- Skip empty lines
                                                while afterTableStart <= markdownLength and string.sub(markdown, afterTableStart, afterTableStart) == "\n" do
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
                                                    
                                                    local afterTableLine = string.sub(markdown, afterTableStart, afterTableLineEnd - 1)
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
                                                            while nextLineStart <= markdownLength and string.sub(markdown, nextLineStart, nextLineStart) == "\n" do
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
                                                                    -- Found list on the next line
                                                                    listStartPos = nextLineEnd
                                                                end
                                                            end
                                                        end
                                                    end
                                                    
                                                    if listStartPos then
                                                        -- There's a list starting after the consecutive table - find its end
                                                        local listSearchLimit = isLastChunk and markdownLength or 10000
                                                        local listEnd = FindListEnd(markdown, listStartPos, listSearchLimit)
                                                        if listEnd and listEnd > chunkEnd then
                                                            local combinedWithListSize = listEnd - pos + 1
                                                            -- CRITICAL: For lists after consecutive tables, allow same overage for complete structures
                                                            if combinedWithListSize <= effectiveMaxForStructures then
                                                                chunkEnd = listEnd
                                                                CM.DebugPrint("CHUNKING", string.format("Chunk %d: Found list after consecutive table, extending chunk end to %d (size: %d, limit: %d)", chunkNum, chunkEnd, combinedWithListSize, effectiveMaxForStructures))
                                                            else
                                                                CM.DebugPrint("CHUNKING", string.format("Chunk %d: List after consecutive table extends beyond structure limit (%d > %d), staying at table end %d", chunkNum, combinedWithListSize, effectiveMaxForStructures, chunkEnd))
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        else
                                            CM.DebugPrint("CHUNKING", string.format("Chunk %d: Consecutive table extends beyond structure limit (%d > %d), staying at first table end %d", chunkNum, combinedTableChunkSize, effectiveMaxForStructures, chunkEnd))
                                        end
                                    end
                                end
                            end
                        end
                    end
                else
                    -- Too close to limit - don't check for consecutive tables
                    CM.DebugPrint("CHUNKING", string.format("Chunk %d: Too close to limit (remaining: %d), not checking for consecutive tables, staying at %d", chunkNum, remainingSpace, chunkEnd))
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
                        local searchAhead = 10  -- Check up to 10 lines ahead
                        local currentLineStart = chunkEnd + 1
                        local foundListStart = nil
                        
                        for lineCheck = 1, searchAhead do
                            if currentLineStart > markdownLength then
                                break
                            end
                            
                            -- Skip to next non-empty line
                            while currentLineStart <= markdownLength and string.sub(markdown, currentLineStart, currentLineStart) == "\n" do
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
                                CM.DebugPrint("CHUNKING", string.format("Chunk %d: Found list starting after chunkEnd at %d, list ends at %d", chunkNum, foundListStart, listEnd))
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
                                local safeNewline = FindSafeNewline(markdown, listEnd, math.min(markdownLength, linkEnd + 200))
                                if safeNewline and safeNewline - pos + 1 <= maxSafeDataSize then
                                    chunkEnd = safeNewline
                                    CM.DebugPrint("CHUNKING", string.format("Chunk %d: List end was inside link, moved to safe newline at %d", chunkNum, chunkEnd))
                                else
                                    -- Can't find safe position, stay at original chunkEnd
                                    CM.Warn(string.format("Chunk %d: List end at %d is inside link, staying at safe position %d", chunkNum, listEnd, chunkEnd))
                                end
                            else
                                chunkEnd = listEnd
                                CM.DebugPrint("CHUNKING", string.format("Chunk %d: Found list, moving chunk end to %d", chunkNum, chunkEnd))
                            end
                        else
                            CM.Warn(string.format("Chunk %d: List extends beyond safe limit, staying at position %d", chunkNum, chunkEnd))
                        end
                    elseif listEnd and listEnd < chunkEnd then
                        chunkEnd = listEnd
                    end
                end
            end
            
            -- CRITICAL: Final check before finalizing chunkEnd - ensure it doesn't exceed maxSafeDataSize
            local finalChunkSize = chunkEnd - pos + 1
            if finalChunkSize > maxSafeDataSize then
                CM.Warn(string.format("Chunk %d: Final size %d exceeds maxSafeDataSize %d, truncating to safe limit", chunkNum, finalChunkSize, maxSafeDataSize))
                
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
                            CM.Warn(string.format("Chunk %d: Truncated before table at %d (size: %d) to avoid splitting table", chunkNum, chunkEnd, chunkEnd - pos + 1))
                        else
                            -- Can't find newline before table, use table start
                            chunkEnd = math.max(pos, tableStart - 1)
                            CM.Warn(string.format("Chunk %d: Truncated at table start %d (size: %d) to avoid splitting table", chunkNum, chunkEnd, chunkEnd - pos + 1))
                        end
                    else
                        -- Table starts at chunk start, can't avoid it - use regular truncation
                        local lastSafeNewline = FindSafeNewline(markdown, pos, math.min(safeEndPos, chunkEnd, markdownLength))
                        if lastSafeNewline and lastSafeNewline >= pos then
                            chunkEnd = lastSafeNewline
                            CM.DebugPrint("CHUNKING", string.format("Chunk %d: Truncated from %d to %d bytes to stay within limit", chunkNum, finalChunkSize, chunkEnd - pos + 1))
                        else
                            -- Fallback: find any newline within the limit
                            for i = math.min(safeEndPos, chunkEnd, markdownLength), pos, -1 do
                                if string.sub(markdown, i, i) == "\n" then
                                    chunkEnd = i
                                    CM.Warn(string.format("Chunk %d: Truncated to newline at %d (size: %d)", chunkNum, i, i - pos + 1))
                                    break
                                end
                            end
                        end
                    end
                else
                    -- Not in a table, use regular truncation
                    local lastSafeNewline = FindSafeNewline(markdown, pos, math.min(safeEndPos, chunkEnd, markdownLength))
                    if lastSafeNewline and lastSafeNewline >= pos then
                        chunkEnd = lastSafeNewline
                        CM.DebugPrint("CHUNKING", string.format("Chunk %d: Truncated from %d to %d bytes to stay within limit", chunkNum, finalChunkSize, chunkEnd - pos + 1))
                    else
                        -- Fallback: find any newline within the limit
                        for i = math.min(safeEndPos, chunkEnd, markdownLength), pos, -1 do
                            if string.sub(markdown, i, i) == "\n" then
                                chunkEnd = i
                                CM.Warn(string.format("Chunk %d: Truncated to newline at %d (size: %d)", chunkNum, i, i - pos + 1))
                                break
                            end
                        end
                    end
                end
            end
            
            if not foundNewline then
                -- Use FindSafeNewline for fallback search
                local lastSafeNewline = FindSafeNewline(markdown, pos, math.min(pos + effectiveMaxData - 1, markdownLength))
                if lastSafeNewline then
                    chunkEnd = lastSafeNewline
                    CM.Warn(string.format("Chunk %d: No newline found near potential end, using last safe newline at %d", chunkNum, chunkEnd))
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
                        CM.Warn(string.format("Chunk %d: No safe newline found, using last newline at %d", chunkNum, chunkEnd))
                    else
                        -- CRITICAL FIX: Use pos instead of pos - 1 to avoid invalid position 0
                        -- If no newline found, use the start position (empty chunk is better than invalid)
                        chunkEnd = math.max(pos, 1)
                        CM.Error(string.format("Chunk %d: CRITICAL - No newline found anywhere! Using position %d (chunk may be empty)", chunkNum, chunkEnd))
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
                        CM.Warn(string.format("Chunk %d: Final check - chunkEnd is at newline with incomplete link, moved back to safe newline at %d", chunkNum, chunkEnd))
                    else
                        CM.Error(string.format("Chunk %d: CRITICAL - chunkEnd at %d has incomplete link and no safe position found!", chunkNum, chunkEnd))
                    end
                elseif linkEnd > chunkEnd then
                    -- chunkEnd is inside a link, find a safe newline after the link
                    local safeNewline = FindSafeNewline(markdown, chunkEnd, math.min(markdownLength, linkEnd + 200))
                    -- CRITICAL FIX: Use maxSafeDataSize instead of maxSafeSize for consistency
                    if safeNewline and safeNewline - pos + 1 <= maxSafeDataSize then
                        chunkEnd = safeNewline
                        CM.DebugPrint("CHUNKING", string.format("Chunk %d: Final check - chunkEnd was inside link, moved to safe newline at %d", chunkNum, chunkEnd))
                    else
                        -- Can't find safe position after link, try to find one before the link
                        local safeNewlineBefore = FindSafeNewline(markdown, pos, chunkEnd - 1)
                        if safeNewlineBefore then
                            chunkEnd = safeNewlineBefore
                            CM.Warn(string.format("Chunk %d: Final check - chunkEnd was inside link, moved back to safe newline at %d", chunkNum, chunkEnd))
                        else
                            CM.Error(string.format("Chunk %d: CRITICAL - chunkEnd at %d is inside link and no safe position found!", chunkNum, chunkEnd))
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
                            CM.Warn(string.format("Chunk %d: chunkEnd was not at newline, found safe newline at %d", chunkNum, chunkEnd))
                        else
                            CM.Error(string.format("Chunk %d: CRITICAL - chunkEnd at %d is not at newline and newline is inside link!", chunkNum, chunkEnd))
                            -- CRITICAL FIX: Use pos instead of pos - 1 to avoid invalid position 0
                            chunkEnd = math.max(pos, 1)
                        end
                    else
                        chunkEnd = prevNewline
                        CM.Warn(string.format("Chunk %d: chunkEnd was not at newline, moved to %d", chunkNum, chunkEnd))
                    end
                else
                    CM.Error(string.format("Chunk %d: CRITICAL - chunkEnd at %d is not at newline!", chunkNum, chunkEnd))
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
                        CM.Warn(string.format("Chunk %d: Final verification - backtracked from incomplete link to %d", chunkNum, chunkEnd))
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
                            CM.Warn(string.format("Chunk %d: Final verification - backtracked from link to %d", chunkNum, chunkEnd))
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
                CM.Error(string.format("Chunk %d: CRITICAL - chunkEnd at %d is in middle of table (ends at %d)!", chunkNum, chunkEnd, finalTableCheck))
                -- Try to extend to table end if possible
                local finalTableSize = finalTableCheck - pos + 1
                if finalTableSize <= maxSafeDataSize + 2000 then
                    chunkEnd = finalTableCheck
                    CM.Warn(string.format("Chunk %d: Extended to table end at %d to avoid splitting", chunkNum, chunkEnd))
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
                                CM.Warn(string.format("Chunk %d: Final check - backtracked to %d to avoid splitting table", chunkNum, chunkEnd))
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
                    CM.Warn(string.format("Chunk %d: CRITICAL FIX - chunkEnd was not at newline, moved to safe newline at %d", chunkNum, chunkEnd))
                else
                    CM.Error(string.format("Chunk %d: CRITICAL - chunkEnd at %d is not at newline and no safe newline found!", chunkNum, chunkEnd))
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
                        CM.Warn(string.format("Chunk %d: CRITICAL FIX - chunkEnd was at newline inside link, moved to safe newline at %d", chunkNum, chunkEnd))
                    else
                        -- Can't extend, backtrack before link
                        local safeNewlineBefore = FindSafeNewline(markdown, pos, chunkEnd - 1)
                        if safeNewlineBefore then
                            chunkEnd = safeNewlineBefore
                            CM.Warn(string.format("Chunk %d: CRITICAL FIX - chunkEnd was at newline inside link, backtracked to %d", chunkNum, chunkEnd))
                        else
                            CM.Error(string.format("Chunk %d: CRITICAL - chunkEnd at newline inside link and no safe position found!", chunkNum))
                        end
                    end
                end
            end
        end
        
        local chunkData = string.sub(markdown, pos, chunkEnd)
        local dataChars = string.len(chunkData)
        local isLastChunk = (chunkEnd >= markdownLength)
        
        -- CRITICAL: If previous chunk backtracked before a header, prepend newline to this chunk
        -- This ensures the header starts on its own line after the previous chunk's padding
        if prependNewlineToChunk then
            chunkData = "\n" .. chunkData
            dataChars = dataChars + 1
            prependNewlineToChunk = false
            CM.DebugPrint("CHUNKING", string.format("Chunk %d: Prepended newline to ensure header starts on new line", chunkNum))
        end
        
        -- CRITICAL: Safety check - ensure data itself doesn't exceed copy limit
        -- Account for padding (85 spaces + newline + newline = 87 chars) that will be added to all chunks
        local copyLimit = CHUNKING.COPY_LIMIT or (editboxLimit - 300)  -- Fallback if COPY_LIMIT not defined
        local paddingSize = (CHUNKING.SPACE_PADDING_SIZE or 85) + 2  -- spaces + newline + newline
        -- Reserve space for padding on all chunks (including last chunk)
        local maxSafeDataSize = copyLimit - paddingSize
        if dataChars > maxSafeDataSize then
            CM.Warn(string.format("Chunk %d: Data size %d exceeds safe limit %d, finding safe truncation point", chunkNum, dataChars, maxSafeDataSize))
            
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
                CM.DebugPrint("CHUNKING", string.format("Chunk %d: Truncated to %d chars, ending at newline position %d", chunkNum, dataChars, chunkEnd))
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
                    CM.Warn(string.format("Chunk %d: Had to truncate significantly to %d chars to find complete line", chunkNum, dataChars))
                else
                    -- Absolute last resort: This should only happen if there's a single extremely long line
                    -- Try to find ANY safe position before safeEndPos, even if it's much smaller
                    local emergencySafePos = FindSafeNewline(markdown, pos, safeEndPos)
                    if emergencySafePos and emergencySafePos >= pos then
                        chunkData = string.sub(markdown, pos, emergencySafePos)
                        dataChars = string.len(chunkData)
                        chunkEnd = emergencySafePos
                        CM.Warn(string.format("Chunk %d: CRITICAL - Emergency truncation to safe position %d (size: %d)", chunkNum, emergencySafePos, dataChars))
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
                            CM.Error(string.format("Chunk %d: CRITICAL - Truncated to newline at %d (may be inside link, size: %d)", chunkNum, lastNewlineBeforeSafe, dataChars))
                        else
                            CM.Error(string.format("Chunk %d: CRITICAL - No newline found in safe range! Line may be truncated at position %d", chunkNum, safeEndPos))
                            chunkData = string.sub(markdown, pos, safeEndPos)
                            dataChars = string.len(chunkData)
                            chunkEnd = safeEndPos
                        end
                    end
                end
            end
            
            -- Re-check if this is still the last chunk after truncation
            isLastChunk = (chunkEnd >= markdownLength)
            
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
                            CM.Warn(string.format("Chunk %d: After truncation - chunkEnd had incomplete link, moved to %d", chunkNum, chunkEnd))
                        end
                    elseif linkEnd > chunkEnd then
                        -- chunkEnd is inside a link - find safe position after
                        local safeNewline = FindSafeNewline(markdown, chunkEnd, math.min(markdownLength, linkEnd + 200))
                        if safeNewline and safeNewline - pos + 1 <= maxSafeDataSize then
                            chunkData = string.sub(markdown, pos, safeNewline)
                            dataChars = string.len(chunkData)
                            chunkEnd = safeNewline
                            CM.Warn(string.format("Chunk %d: After truncation - chunkEnd was inside link, moved to %d", chunkNum, chunkEnd))
                        else
                            -- Try to find safe position before
                            local safeNewlineBefore = FindSafeNewline(markdown, pos, chunkEnd - 1)
                            if safeNewlineBefore then
                                chunkData = string.sub(markdown, pos, safeNewlineBefore)
                                dataChars = string.len(chunkData)
                                chunkEnd = safeNewlineBefore
                                CM.Warn(string.format("Chunk %d: After truncation - chunkEnd was inside link, moved back to %d", chunkNum, chunkEnd))
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
                        CM.Warn(string.format("Chunk %d: Detected incomplete link at end, backtracked to safe newline at %d", chunkNum, chunkEnd))
                        -- Recalculate dataChars after backtracking
                        dataChars = chunkEnd - pos + 1
                    else
                        -- Try to find any newline before actualEndPos that's not in a link
                        for i = actualEndPos - 1, math.max(pos, actualEndPos - 2000), -1 do
                            if string.sub(markdown, i, i) == "\n" then
                                local testLinkEnd = IsInsideMarkdownLink(markdown, i)
                                if not testLinkEnd or testLinkEnd <= i then
                                    chunkEnd = i
                                    CM.Warn(string.format("Chunk %d: Found safe newline at %d to avoid incomplete link", chunkNum, chunkEnd))
                                    dataChars = chunkEnd - pos + 1
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
                        CM.DebugPrint("CHUNKING", string.format("Chunk %d: Final check - chunkEnd was inside link, moved to safe newline at %d", chunkNum, chunkEnd))
                        dataChars = chunkEnd - pos + 1
                    else
                        -- Can't extend, backtrack to before the link
                        local safeNewlineBefore = FindSafeNewline(markdown, pos, actualEndPos - 1)
                        if safeNewlineBefore then
                            chunkEnd = safeNewlineBefore
                            CM.Warn(string.format("Chunk %d: Final check - chunkEnd was inside link, moved back to safe newline at %d", chunkNum, chunkEnd))
                            dataChars = chunkEnd - pos + 1
                        end
                    end
                end
            end
        end
        
        -- Padding removed: No longer needed with smaller EditBox limits (16K/15K)
        -- Chunks naturally fit within limits without padding
        
        -- CRITICAL: For the last chunk, ensure we include ALL remaining content
        if isLastChunk and chunkEnd < markdownLength then
            -- This should never happen, but if it does, include all remaining content
            CM.Warn(string.format("Chunk %d: Last chunk but chunkEnd (%d) < markdownLength (%d), including all remaining content", 
                chunkNum, chunkEnd, markdownLength))
            chunkData = string.sub(markdown, pos, markdownLength)
            dataChars = string.len(chunkData)
            chunkEnd = markdownLength
        end
        
        local chunkContent = chunkData
        local finalSize = string.len(chunkContent)
        
        local copyLimit = CHUNKING.COPY_LIMIT or (editboxLimit - 300)  -- Fallback if COPY_LIMIT not defined
        -- Check final size (after padding will be added) against copy limit
        -- Padding is added to all chunks including the last one
        local paddingSize = (CHUNKING.SPACE_PADDING_SIZE or 85) + 2  -- spaces + newline + newline
        local expectedFinalSize = finalSize + paddingSize
        
        if expectedFinalSize > copyLimit then
            CM.Error(string.format("Chunk %d: CRITICAL - Final size %d (with padding) exceeds copy limit %d!", chunkNum, expectedFinalSize, copyLimit))
            -- For last chunk, we must include all content even if it exceeds limit
            if isLastChunk then
                CM.Warn(string.format("Chunk %d: Last chunk exceeds limit but must include all content", chunkNum))
                chunkContent = chunkData  -- Keep as is
                finalSize = dataChars
            else
                -- For non-last chunks, truncate more aggressively to make room for padding
                CM.Warn(string.format("Chunk %d: Truncating to make room for padding (current: %d, limit: %d, padding: %d)", 
                    chunkNum, finalSize, copyLimit, (CHUNKING.SPACE_PADDING_SIZE or 85) + 2))
                -- This should not happen if maxSafeDataSize was calculated correctly above
                chunkContent = chunkData
                finalSize = dataChars
            end
        end
        
        -- CRITICAL: Verify chunk ends with newline (unless it's the last chunk at end of file)
        -- This ensures chunks can be safely concatenated without creating malformed markdown
        local hasTrailingNewline = false
        if not isLastChunk or chunkEnd < markdownLength then
            local lastChar = string.sub(chunkContent, -1, -1)
            if lastChar == "\n" then
                hasTrailingNewline = true
            else
                CM.Error(string.format("Chunk %d: CRITICAL - Chunk does not end with newline! Last char: '%s' (code: %d)", 
                    chunkNum, lastChar, string.byte(lastChar or "")))
                -- Force add newline to prevent concatenation issues
                chunkContent = chunkContent .. "\n"
                finalSize = finalSize + 1
                hasTrailingNewline = true
                CM.Warn(string.format("Chunk %d: Added missing newline at end", chunkNum))
            end
        end
        
        -- Add space padding (85 spaces) to the last line of the chunk, followed by a newline
        -- This provides buffer space to prevent paste truncation
        -- CRITICAL: If chunk ends with a header followed by a table, backtrack before the header
        -- This keeps the header and table together in the NEXT chunk
        local paddingSize = CHUNKING.SPACE_PADDING_SIZE or 85
        
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
                    
                    CM.DebugPrint("CHUNKING", string.format("Chunk %d: Backtracked from %d to %d to keep header+table together in next chunk", chunkNum, chunkEnd + (headerLineStart - pos), chunkEnd))
                end
            end
        end
        
        -- Always add padding (unless chunk is empty or has other issues)
        if hasTrailingNewline then
            -- Remove the trailing newline, add padding, then add newline + newline
            chunkContent = string.sub(chunkContent, 1, -2) .. string.rep(" ", paddingSize) .. "\n\n"
        else
            -- No trailing newline, add padding and two newlines
            chunkContent = chunkContent .. string.rep(" ", paddingSize) .. "\n\n"
            hasTrailingNewline = true
        end
        finalSize = finalSize + paddingSize + 1  -- +1 for the extra newline
        CM.DebugPrint("CHUNKING", string.format("Chunk %d: Added %d space padding to last line + newline (isLast: %s)", chunkNum, paddingSize, tostring(isLastChunk)))
        
        table.insert(chunks, {content = chunkContent})
        CM.DebugPrint("CHUNKING", string.format("Chunk %d: %d chars (isLast: %s, endsWithNewline: %s)", 
            chunkNum, finalSize, tostring(isLastChunk), tostring(string.sub(chunkContent, -1, -1) == "\n")))
        
        -- Only advance position if this isn't the last chunk or if we haven't reached the end
        if chunkEnd < markdownLength then
            pos = chunkEnd + 1
            chunkNum = chunkNum + 1
        else
            -- Last chunk - we're done
            break
        end
    end
    
    CM.DebugPrint("CHUNKING", string.format("Split into %d chunks (total: %d chars)", #chunks, markdownLength))
    return chunks
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.utils.Chunking = {
    SplitMarkdownIntoChunks = SplitMarkdownIntoChunks,
}

CM.DebugPrint("UTILS", "Chunking module loaded")

