-- MarkdownParser.lua
-- Section-based markdown parsing for intelligent chunking
-- Parse markdown into hierarchical structure for natural splitting

local CM = CharacterMarkdown

CM.utils = CM.utils or {}
CM.utils.MarkdownParser = {}

-- Cached string functions for performance
local string_find = string.find
local string_sub = string.sub
local string_match = string.match
local string_gmatch = string.gmatch
local string_len = string.len
local table_insert = table.insert

---Parse markdown into sections based on headers
---@param markdown string The markdown content to parse
---@return table Array of section objects
local function ParseSections(markdown)
    if not markdown or markdown == "" then
        return {}
    end
    
    local sections = {}
    local lines = {}
    
    -- Split into lines
    for line in string_gmatch(markdown .. "\n", "([^\n]*)\n") do
        table_insert(lines, line)
    end
    
    local currentSection = nil
    local currentContent = {}
    local startLine = 1
    
    for lineNum, line in ipairs(lines) do
        -- Check if line is a header (## or ###)
        local headerLevel, headerTitle = string_match(line, "^(###+)%s+(.+)$")
        
        if headerLevel then
            -- Save previous section if exists
            if currentSection then
                currentSection.content = table.concat(currentContent, "\n")
                currentSection.endLine = lineNum - 1
                currentSection.size = string_len(currentSection.content)
                table_insert(sections, currentSection)
            end
            
            -- Start new section
            currentSection = {
                level = string_len(headerLevel),  -- ## = 2, ### = 3
                title = headerTitle,
                startLine = lineNum,
                content = "",
            }
            currentContent = { line }
        else
            -- Add line to current section
            if currentSection then
                table_insert(currentContent, line)
            else
                -- Content before first header - create implicit section
                if #currentContent == 0 then
                    currentSection = {
                        level = 0,  -- No header
                        title = "(preamble)",
                        startLine = lineNum,
                        content = "",
                    }
                end
                table_insert(currentContent, line)
            end
        end
    end
    
    -- Save final section
    if currentSection then
        currentSection.content = table.concat(currentContent, "\n")
        currentSection.endLine = #lines
        currentSection.size = string_len(currentSection.content)
        table_insert(sections, currentSection)
    end
    
    return sections
end

---Parse subsections (### headers) within a section
---@param sectionContent string The section content to parse
---@return table Array of subsection objects
local function ParseSubsections(sectionContent)
    if not sectionContent or sectionContent == "" then
        return {}
    end
    
    local subsections = {}
    local lines = {}
    
    -- Split into lines
    for line in string_gmatch(sectionContent .. "\n", "([^\n]*)\n") do
        table_insert(lines, line)
    end
    
    local currentSubsection = nil
    local currentContent = {}
    
    for lineNum, line in ipairs(lines) do
        -- Check if line is a ### header
        local headerLevel, headerTitle = string_match(line, "^(###)%s+(.+)$")
        
        if headerLevel then
            -- Save previous subsection if exists
            if currentSubsection then
                currentSubsection.content = table.concat(currentContent, "\n")
                currentSubsection.size = string_len(currentSubsection.content)
                table_insert(subsections, currentSubsection)
            end
            
            -- Start new subsection
            currentSubsection = {
                title = headerTitle,
                startLine = lineNum,
                content = "",
            }
            currentContent = { line }
        else
            -- Add line to current subsection
            if currentSubsection then
                table_insert(currentContent, line)
            else
                -- Content before first subsection
                if #currentContent == 0 then
                    currentSubsection = {
                        title = "(content)",
                        startLine = lineNum,
                        content = "",
                    }
                end
                table_insert(currentContent, line)
            end
        end
    end
    
    -- Save final subsection
    if currentSubsection then
        currentSubsection.content = table.concat(currentContent, "\n")
        currentSubsection.size = string_len(currentSubsection.content)
        table_insert(subsections, currentSubsection)
    end
    
    return subsections
end

---Find table boundaries in content
---@param content string The content to search
---@return table Array of table objects with start/end positions
local function ParseTables(content)
    if not content or content == "" then
        return {}
    end
    
    local tables = {}
    local lines = {}
    
    -- Split into lines
    for line in string_gmatch(content .. "\n", "([^\n]*)\n") do
        table_insert(lines, line)
    end
    
    local inTable = false
    local tableStart = nil
    local tableLines = {}
    
    for lineNum, line in ipairs(lines) do
        -- Check if line is a table row (contains | character)
        local isTableRow = string_find(line, "|") ~= nil
        
        if isTableRow then
            if not inTable then
                -- Start of new table
                inTable = true
                tableStart = lineNum
                tableLines = { line }
            else
                -- Continuation of table
                table_insert(tableLines, line)
            end
        else
            if inTable then
                -- End of table
                local tableContent = table.concat(tableLines, "\n")
                table_insert(tables, {
                    startLine = tableStart,
                    endLine = lineNum - 1,
                    content = tableContent,
                    size = string_len(tableContent),
                })
                inTable = false
                tableStart = nil
                tableLines = {}
            end
        end
    end
    
    -- Handle table at end of content
    if inTable and #tableLines > 0 then
        local tableContent = table.concat(tableLines, "\n")
        table_insert(tables, {
            startLine = tableStart,
            endLine = #lines,
            content = tableContent,
            size = string_len(tableContent),
        })
    end
    
    return tables
end

---Split content at paragraph boundaries (double newlines)
---@param content string The content to split
---@param maxSize number Maximum size for each chunk
---@return table Array of content chunks
local function SplitAtParagraphs(content, maxSize)
    if not content or content == "" then
        return {}
    end
    
    if string_len(content) <= maxSize then
        return { content }
    end
    
    local chunks = {}
    local lines = {}
    
    -- Split into lines
    for line in string_gmatch(content .. "\n", "([^\n]*)\n") do
        table_insert(lines, line)
    end
    
    local currentChunk = {}
    local currentSize = 0
    
    for _, line in ipairs(lines) do
        local lineSize = string_len(line) + 1  -- +1 for newline
        
        -- Check if adding this line would exceed maxSize
        if currentSize + lineSize > maxSize and currentSize > 0 then
            -- Finalize current chunk
            table_insert(chunks, table.concat(currentChunk, "\n"))
            currentChunk = { line }
            currentSize = lineSize
        else
            -- Add line to current chunk
            table_insert(currentChunk, line)
            currentSize = currentSize + lineSize
        end
    end
    
    -- Add final chunk
    if #currentChunk > 0 then
        table_insert(chunks, table.concat(currentChunk, "\n"))
    end
    
    return chunks
end

---Split a section that's too large
---@param section table The section to split
---@param maxSize number Maximum chunk size
---@return table Array of content chunks
local function SplitSection(section, maxSize)
    if not section or not section.content then
        return {}
    end
    
    local content = section.content
    
    -- If section fits, return as-is
    if string_len(content) <= maxSize then
        return { content }
    end
    
    CM.DebugPrint("CHUNKING", string.format(
        "Section '%s' (%d bytes) exceeds limit (%d), attempting to split",
        section.title or "(unknown)",
        string_len(content),
        maxSize
    ))
    
    -- Try Level 2: Split at ### subsections
    local subsections = ParseSubsections(content)
    if #subsections > 1 then
        CM.DebugPrint("CHUNKING", string.format(
            "Splitting section into %d subsections",
            #subsections
        ))
        
        local chunks = {}
        local currentChunk = ""
        
        for _, subsection in ipairs(subsections) do
            local subContent = subsection.content
            local separator = (currentChunk ~= "") and "\n\n" or ""
            
            if string_len(currentChunk) + string_len(separator) + string_len(subContent) <= maxSize then
                -- Fits in current chunk
                currentChunk = currentChunk .. separator .. subContent
            else
                -- Start new chunk
                if currentChunk ~= "" then
                    table_insert(chunks, currentChunk)
                end
                
                -- Check if subsection itself is too large
                if string_len(subContent) > maxSize then
                    -- Recursively split subsection
                    local subChunks = SplitAtParagraphs(subContent, maxSize)
                    for _, subChunk in ipairs(subChunks) do
                        table_insert(chunks, subChunk)
                    end
                    currentChunk = ""
                else
                    currentChunk = subContent
                end
            end
        end
        
        if currentChunk ~= "" then
            table_insert(chunks, currentChunk)
        end
        
        return chunks
    end
    
    -- Try Level 3: Split at table boundaries
    local tables = ParseTables(content)
    if #tables > 1 then
        CM.DebugPrint("CHUNKING", string.format(
            "Splitting section at %d table boundaries",
            #tables
        ))
        
        -- This is more complex - need to split content between tables
        -- For now, fall through to paragraph splitting
    end
    
    -- Last resort: Split at paragraph boundaries
    CM.DebugPrint("CHUNKING", "Splitting section at paragraph boundaries (last resort)")
    return SplitAtParagraphs(content, maxSize)
end

-- Export functions
CM.utils.MarkdownParser.ParseSections = ParseSections
CM.utils.MarkdownParser.ParseSubsections = ParseSubsections
CM.utils.MarkdownParser.ParseTables = ParseTables
CM.utils.MarkdownParser.SplitAtParagraphs = SplitAtParagraphs
CM.utils.MarkdownParser.SplitSection = SplitSection

