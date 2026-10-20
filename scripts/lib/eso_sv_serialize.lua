-- ESO-style SavedVariables serializer (bracket keys, 4-space indent).
-- Usage: local serialize = require("eso_sv_serialize") -- or dofile
--        local text = serialize.Dump("MyVarName", table)

local M = {}

local function is_array(t)
    local n = 0
    for k, _ in pairs(t) do
        if type(k) ~= "number" or k < 1 or k ~= math.floor(k) then
            return false
        end
        if k > n then
            n = k
        end
    end
    for i = 1, n do
        if t[i] == nil then
            return false
        end
    end
    return n > 0
end

local function escape_string(s)
    s = s:gsub("\\", "\\\\")
    s = s:gsub('"', '\\"')
    s = s:gsub("\n", "\\n")
    s = s:gsub("\r", "\\r")
    s = s:gsub("\t", "\\t")
    return s
end

local function format_key(k)
    if type(k) == "number" then
        return string.format("[%s]", tostring(k))
    end
    return string.format('["%s"]', escape_string(tostring(k)))
end

local function sorted_keys(t)
    local keys = {}
    for k in pairs(t) do
        keys[#keys + 1] = k
    end
    table.sort(keys, function(a, b)
        local ta, tb = type(a), type(b)
        if ta == tb then
            if ta == "number" then
                return a < b
            end
            return tostring(a) < tostring(b)
        end
        -- numbers first, then strings (stable-ish for SV readability)
        if ta == "number" then
            return true
        end
        if tb == "number" then
            return false
        end
        return tostring(a) < tostring(b)
    end)
    return keys
end

local function dump_value(v, indent, lines)
    local t = type(v)
    if t == "nil" then
        lines[#lines + 1] = "nil"
    elseif t == "boolean" then
        lines[#lines + 1] = v and "true" or "false"
    elseif t == "number" then
        if v ~= v then
            lines[#lines + 1] = "0" -- nan guard
        else
            lines[#lines + 1] = string.format("%.10g", v)
        end
    elseif t == "string" then
        lines[#lines + 1] = string.format('"%s"', escape_string(v))
    elseif t == "table" then
        lines[#lines + 1] = ""
        lines[#lines + 1] = string.rep("    ", indent) .. "{"
        if is_array(v) then
            for i = 1, #v do
                local prefix = string.rep("    ", indent + 1) .. format_key(i) .. " = "
                local sub = {}
                dump_value(v[i], indent + 1, sub)
                if type(v[i]) == "table" then
                    lines[#lines + 1] = prefix
                    for j = 2, #sub do
                        lines[#lines + 1] = sub[j]
                    end
                    lines[#lines] = lines[#lines] .. ","
                else
                    lines[#lines + 1] = prefix .. sub[1] .. ","
                end
            end
        else
            for _, k in ipairs(sorted_keys(v)) do
                local prefix = string.rep("    ", indent + 1) .. format_key(k) .. " = "
                local sub = {}
                dump_value(v[k], indent + 1, sub)
                if type(v[k]) == "table" then
                    lines[#lines + 1] = prefix
                    for j = 2, #sub do
                        lines[#lines + 1] = sub[j]
                    end
                    lines[#lines] = lines[#lines] .. ","
                else
                    lines[#lines + 1] = prefix .. sub[1] .. ","
                end
            end
        end
        lines[#lines + 1] = string.rep("    ", indent) .. "}"
    else
        error("unsupported type: " .. t)
    end
end

function M.Dump(global_name, root)
    local lines = { global_name .. " =", "{" }
    for _, k in ipairs(sorted_keys(root)) do
        local prefix = "    " .. format_key(k) .. " = "
        local sub = {}
        dump_value(root[k], 1, sub)
        if type(root[k]) == "table" then
            lines[#lines + 1] = prefix
            for j = 2, #sub do
                lines[#lines + 1] = sub[j]
            end
            lines[#lines] = lines[#lines] .. ","
        else
            lines[#lines + 1] = prefix .. sub[1] .. ","
        end
    end
    lines[#lines + 1] = "}"
    return table.concat(lines, "\n") .. "\n"
end

return M
