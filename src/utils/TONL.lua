-- CharacterMarkdown - TONL (Token-Oriented Object Notation) Utilities
-- Encodes Lua data structures to TONL format for LLM-friendly output
-- TONL is a compact format that reduces token usage compared to JSON

local CM = CharacterMarkdown
CM.utils = CM.utils or {}
CM.utils.tonl = CM.utils.tonl or {}

-- Localize frequently used functions for performance
local string_format = string.format
local string_rep = string.rep
local table_concat = table.concat
local table_insert = table.insert
local type = type
local tostring = tostring
local tonumber = tonumber

-- =====================================================
-- TONL ENCODING
-- =====================================================

-- Escape special characters in strings
local function EscapeString(str)
    if not str then
        return ""
    end
    
    str = tostring(str)
    
    -- Escape backslashes first
    str = str:gsub("\\", "\\\\")
    -- Escape newlines
    str = str:gsub("\n", "\\n")
    -- Escape carriage returns
    str = str:gsub("\r", "\\r")
    -- Escape tabs
    str = str:gsub("\t", "\\t")
    -- Escape quotes
    str = str:gsub('"', '\\"')
    
    return str
end

-- Check if an array contains uniform objects (all same keys)
local function IsUniformObjectArray(arr)
    if not arr or #arr == 0 then
        return false
    end
    
    -- Get keys from first object
    local firstKeys = {}
    local firstItem = arr[1]
    if type(firstItem) ~= "table" then
        return false
    end
    
    for k, _ in pairs(firstItem) do
        firstKeys[k] = true
    end
    
    -- Check if all items have the same keys
    for i = 2, #arr do
        local item = arr[i]
        if type(item) ~= "table" then
            return false
        end
        
        -- Check all keys match
        local keyCount = 0
        for k, _ in pairs(item) do
            if not firstKeys[k] then
                return false
            end
            keyCount = keyCount + 1
        end
        
        -- Check key count matches
        local firstKeyCount = 0
        for _ in pairs(firstKeys) do
            firstKeyCount = firstKeyCount + 1
        end
        
        if keyCount ~= firstKeyCount then
            return false
        end
    end
    
    return true, firstKeys
end

-- Encode a value to TONL format
local function EncodeValue(value, indent, visited)
    indent = indent or 0
    visited = visited or {}
    local indentStr = string_rep("  ", indent)
    
    local valueType = type(value)
    
    if valueType == "nil" then
        return "null"
    elseif valueType == "boolean" then
        return value and "true" or "false"
    elseif valueType == "number" then
        return tostring(value)
    elseif valueType == "string" then
        -- Check if string needs quoting (contains special chars, spaces, or is empty)
        if value == "" or value:match("[%s:,\\[\\]{}]") or value:match("^%d") then
            return string_format('"%s"', EscapeString(value))
        else
            return value
        end
    elseif valueType == "table" then
        -- Prevent circular references
        if visited[value] then
            return '"[circular reference]"'
        end
        visited[value] = true
        
        -- Check if it's an array (sequential numeric indices starting at 1)
        local isArray = true
        local maxIndex = 0
        local keyCount = 0
        
        for k, v in pairs(value) do
            keyCount = keyCount + 1
            if type(k) == "number" and k >= 1 and k == math.floor(k) then
                if k > maxIndex then
                    maxIndex = k
                end
            else
                isArray = false
            end
        end
        
        -- Only treat as array if all keys are sequential 1..n
        if isArray and keyCount > 0 then
            for i = 1, maxIndex do
                if value[i] == nil then
                    isArray = false
                    break
                end
            end
        else
            isArray = false
        end
        
        if isArray then
            -- Check if array contains uniform objects (can use tabular format)
            local isUniform, keys = IsUniformObjectArray(value)
            
            if isUniform and #value > 1 then
                -- Tabular format: declare fields once, then list values
                local lines = {}
                table_insert(lines, string_format("%s[", indentStr))
                
                -- Header row with field names
                local fieldNames = {}
                for k, _ in pairs(keys) do
                    table_insert(fieldNames, k)
                end
                table.sort(fieldNames) -- Sort for consistency
                
                local headerLine = indentStr .. "  "
                local headerParts = {}
                for _, fieldName in ipairs(fieldNames) do
                    table_insert(headerParts, fieldName)
                end
                headerLine = headerLine .. table_concat(headerParts, " ")
                table_insert(lines, headerLine)
                
                -- Data rows
                for i, item in ipairs(value) do
                    local rowParts = {}
                    for _, fieldName in ipairs(fieldNames) do
                        local fieldValue = item[fieldName]
                        local encoded = EncodeValue(fieldValue, 0, visited)
                        table_insert(rowParts, encoded)
                    end
                    local rowLine = indentStr .. "  " .. table_concat(rowParts, " ")
                    table_insert(lines, rowLine)
                end
                
                table_insert(lines, string_format("%s]", indentStr))
                return table_concat(lines, "\n")
            else
                -- Regular array format
                local lines = {}
                table_insert(lines, string_format("%s[", indentStr))
                
                for i, item in ipairs(value) do
                    local encoded = EncodeValue(item, indent + 1, visited)
                    local isLast = (i == #value)
                    local line = string_format("%s  %s", indentStr, encoded)
                    if not isLast or encoded:match("\n") then
                        -- Multi-line or not last item
                        table_insert(lines, line)
                    else
                        -- Single-line format for simple arrays
                        if #lines == 1 then
                            -- First item, check if we can do inline
                            local allSimple = true
                            for j = 1, #value do
                                local itemType = type(value[j])
                                if itemType == "table" or (itemType == "string" and #value[j] > 20) then
                                    allSimple = false
                                    break
                                end
                            end
                            
                            if allSimple and #value <= 5 then
                                -- Inline format
                                local inlineParts = {}
                                for j = 1, #value do
                                    table_insert(inlineParts, EncodeValue(value[j], 0, visited))
                                end
                                return string_format("%s[%s]", indentStr, table_concat(inlineParts, " "))
                            end
                        end
                        table_insert(lines, line)
                    end
                end
                
                table_insert(lines, string_format("%s]", indentStr))
                return table_concat(lines, "\n")
            end
        else
            -- Object format (key-value pairs)
            local lines = {}
            local isFirst = true
            
            -- Sort keys for consistent output
            local sortedKeys = {}
            for k, _ in pairs(value) do
                table_insert(sortedKeys, k)
            end
            table.sort(sortedKeys, function(a, b)
                -- Numbers first, then strings
                local aNum = tonumber(a)
                local bNum = tonumber(b)
                if aNum and bNum then
                    return aNum < bNum
                elseif aNum then
                    return true
                elseif bNum then
                    return false
                else
                    return tostring(a) < tostring(b)
                end
            end)
            
            for _, k in ipairs(sortedKeys) do
                local v = value[k]
                local keyStr = type(k) == "string" and (k:match("^[%a_][%a%d_]*$") and k or string_format('"%s"', EscapeString(k))) or tostring(k)
                local encodedValue = EncodeValue(v, indent + 1, visited)
                
                if encodedValue:match("\n") then
                    -- Multi-line value
                    if not isFirst then
                        table_insert(lines, "")
                    end
                    table_insert(lines, string_format("%s%s:", indentStr, keyStr))
                    table_insert(lines, encodedValue)
                else
                    -- Single-line value
                    table_insert(lines, string_format("%s%s: %s", indentStr, keyStr, encodedValue))
                end
                isFirst = false
            end
            
            if #lines == 0 then
                return "{}"
            end
            
            return table_concat(lines, "\n")
        end
    else
        return string_format('"[unhandled type: %s]"', valueType)
    end
end

-- Main encoding function
local function Encode(data)
    if data == nil then
        return "null"
    end
    
    return EncodeValue(data, 0, {})
end

CM.utils.tonl.Encode = Encode

-- =====================================================
-- MODULE INITIALIZATION
-- =====================================================

CM.DebugPrint("UTILS", "TONL module loaded")

return {
    Encode = Encode,
}

