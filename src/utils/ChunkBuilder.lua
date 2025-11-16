-- ChunkBuilder.lua
-- Build chunks from parsed markdown sections
-- Intelligently groups sections while respecting size limits

local CM = CharacterMarkdown

CM.utils = CM.utils or {}
CM.utils.ChunkBuilder = {}

-- Cached functions
local string_len = string.len
local table_insert = table.insert
local table_concat = table.concat

---Check if new content can fit in current chunk
---@param currentContent string Current chunk content
---@param newContent string Content to add
---@param maxSize number Maximum chunk size
---@return boolean True if content fits
local function CanFitInChunk(currentContent, newContent, maxSize)
    local currentSize = string_len(currentContent)
    local newSize = string_len(newContent)
    
    -- Account for separator between sections
    local separator = (currentSize > 0) and "\n\n" or ""
    local separatorSize = string_len(separator)
    
    return (currentSize + separatorSize + newSize) <= maxSize
end

---Build chunks from parsed sections
---@param sections table Array of section objects from MarkdownParser
---@param maxSize number Maximum chunk size
---@param options table Options for chunk building
---@return table Array of chunk objects
local function BuildChunks(sections, maxSize, options)
    if not sections or #sections == 0 then
        return {}
    end
    
    -- Default options
    options = options or {}
    local preserveSections = options.preserveSections ~= false  -- default true
    local minChunkSize = options.minChunkSize or 100
    
    local chunks = {}
    local currentChunk = ""
    local chunkNum = 0
    
    CM.DebugPrint("CHUNKING", string.format(
        "Building chunks from %d sections (maxSize: %d)",
        #sections,
        maxSize
    ))
    
    for sectionIndex, section in ipairs(sections) do
        local sectionContent = section.content
        local sectionSize = string_len(sectionContent)
        
        CM.DebugPrint("CHUNKING", string.format(
            "Section %d/%d: '%s' (%d bytes, level %d)",
            sectionIndex,
            #sections,
            section.title or "(unknown)",
            sectionSize,
            section.level or 0
        ))
        
        -- Check if section fits in current chunk
        if CanFitInChunk(currentChunk, sectionContent, maxSize) then
            -- Add to current chunk
            local separator = (currentChunk ~= "") and "\n\n" or ""
            currentChunk = currentChunk .. separator .. sectionContent
            
            CM.DebugPrint("CHUNKING", string.format(
                "Added section to current chunk (now %d bytes)",
                string_len(currentChunk)
            ))
        else
            -- Section doesn't fit - finalize current chunk
            if currentChunk ~= "" and string_len(currentChunk) >= minChunkSize then
                chunkNum = chunkNum + 1
                table_insert(chunks, {
                    content = currentChunk,
                    size = string_len(currentChunk),
                    number = chunkNum,
                })
                
                CM.DebugPrint("CHUNKING", string.format(
                    "Finalized chunk %d: %d bytes",
                    chunkNum,
                    string_len(currentChunk)
                ))
                
                currentChunk = ""
            end
            
            -- Check if section itself is too large
            if sectionSize > maxSize then
                CM.DebugPrint("CHUNKING", string.format(
                    "Section too large (%d > %d), splitting",
                    sectionSize,
                    maxSize
                ))
                
                -- Split section into smaller chunks
                local SplitSection = CM.utils.MarkdownParser.SplitSection
                if SplitSection then
                    local subChunks = SplitSection(section, maxSize)
                    
                    for _, subChunk in ipairs(subChunks) do
                        chunkNum = chunkNum + 1
                        table_insert(chunks, {
                            content = subChunk,
                            size = string_len(subChunk),
                            number = chunkNum,
                        })
                        
                        CM.DebugPrint("CHUNKING", string.format(
                            "Created chunk %d from split section: %d bytes",
                            chunkNum,
                            string_len(subChunk)
                        ))
                    end
                else
                    CM.DebugPrint("CHUNKING", "MarkdownParser.SplitSection not available - section may be oversized")
                    chunkNum = chunkNum + 1
                    table_insert(chunks, {
                        content = sectionContent,
                        size = sectionSize,
                        number = chunkNum,
                    })
                end
            else
                -- Section fits, start new chunk with it
                currentChunk = sectionContent
                
                CM.DebugPrint("CHUNKING", string.format(
                    "Started new chunk with section (%d bytes)",
                    sectionSize
                ))
            end
        end
    end
    
    -- Add final chunk
    if currentChunk ~= "" then
        chunkNum = chunkNum + 1
        table_insert(chunks, {
            content = currentChunk,
            size = string_len(currentChunk),
            number = chunkNum,
        })
        
        CM.DebugPrint("CHUNKING", string.format(
            "Finalized final chunk %d: %d bytes",
            chunkNum,
            string_len(currentChunk)
        ))
    end
    
    -- HTML comment markers removed - they were causing mid-line insertions
    -- Chunk sizes are logged to debug output instead
    
    CM.DebugPrint("CHUNKING", string.format(
        "Built %d chunks from %d sections (with boundary markers)",
        #chunks,
        #sections
    ))
    
    return chunks
end

-- Export functions
CM.utils.ChunkBuilder.CanFitInChunk = CanFitInChunk
CM.utils.ChunkBuilder.BuildChunks = BuildChunks

