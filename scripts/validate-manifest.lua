#!/usr/bin/env lua
-- CharacterMarkdown Manifest Validator
-- Validates ESO addon manifest (.txt) against ESOUI Wiki + project rules
-- See docs/ESOUI_BEST_PRACTICES.md section 1

local REQUIRED_FIELDS = {
    "Title",
    "Author",
    "Version",
    "APIVersion",
}

local OPTIONAL_FIELDS = {
    "AddOnVersion",
    "SavedVariables",
    "SavedVariablesPerCharacter",
    "OptionalDependsOn",
    "DependsOn",
    "PCDependsOn",
    "ConsoleDependsOn",
    "Description",
}

local MAX_LINE_BYTES = 301
local MAX_TITLE_CHARS = 64

local function byte_len(s)
    return #s
end

local function validate_manifest(filepath)
    local file = io.open(filepath, "rb")
    if not file then
        print("Error: Cannot open manifest file: " .. filepath)
        os.exit(1)
    end

    local content = file:read("*all")
    file:close()

    local found_fields = {}
    local referenced_files = {}
    local errors = {}
    local warnings = {}

    -- UTF-8 without BOM
    if content:sub(1, 3) == "\239\187\191" then
        table.insert(errors, "Manifest has UTF-8 BOM; use UTF-8 without BOM")
    end

    local line_num = 0
    for line in (content .. "\n"):gmatch("(.-)\r?\n") do
        line_num = line_num + 1
        local len = byte_len(line)
        if len > MAX_LINE_BYTES then
            table.insert(
                errors,
                string.format(
                    "Line %d is %d bytes (max %d); ESO silently ignores overflow",
                    line_num,
                    len,
                    MAX_LINE_BYTES
                )
            )
        end

        local field, value = line:match("^##%s*(%w+):%s*(.+)$")
        if field and value then
            found_fields[field] = value
        end

        if not line:match("^##") and not line:match("^;") and not line:match("^%-%-") and line:match("%S") then
            table.insert(referenced_files, line:match("^%s*(.-)%s*$"))
        end
    end

    for _, field in ipairs(REQUIRED_FIELDS) do
        if not found_fields[field] then
            table.insert(errors, string.format("Missing required field: ## %s:", field))
        end
    end

    if found_fields.Title then
        local title = found_fields.Title
        if #title > MAX_TITLE_CHARS then
            table.insert(
                errors,
                string.format("Title is %d characters (max %d)", #title, MAX_TITLE_CHARS)
            )
        end
    end

    if found_fields.Version then
        local version = found_fields.Version
        if version == "@project-version@" then
            print("   Info: Using @project-version@ placeholder (Git-based versioning)")
        elseif not version:match("^%d+%.%d+%.%d+") then
            table.insert(
                warnings,
                string.format(
                    "Version '%s' doesn't follow semantic versioning or @project-version@",
                    version
                )
            )
        end
    end

    if found_fields.APIVersion then
        for api in found_fields.APIVersion:gmatch("%S+") do
            if not api:match("^%d%d%d%d%d%d$") then
                table.insert(
                    errors,
                    string.format("APIVersion value '%s' must be exactly six digits", api)
                )
            end
        end
    end

    if found_fields.AddOnVersion then
        local addon_version = found_fields.AddOnVersion
        if not addon_version:match("^%d+$") then
            table.insert(
                errors,
                string.format(
                    "AddOnVersion '%s' must be a positive integer (ESO atoi; no decimals)",
                    addon_version
                )
            )
        end
    else
        table.insert(warnings, "Missing ## AddOnVersion: (recommended positive integer)")
    end

    local has_disclaimer = content:find("ZeniMax", 1, true) ~= nil
        and content:find("Elder Scrolls", 1, true) ~= nil
    if not has_disclaimer then
        table.insert(errors, "Missing ZeniMax / Elder Scrolls trademark disclaimer in manifest")
    end

    local hard_dep_fields = { "DependsOn", "PCDependsOn", "ConsoleDependsOn" }
    local hard_deps = {}
    for _, field in ipairs(hard_dep_fields) do
        if found_fields[field] then
            for dep in found_fields[field]:gmatch("%S+") do
                local name = dep:match("^([^>=]+)") or dep
                table.insert(hard_deps, name)
            end
        end
    end

    if #hard_deps > 0 then
        local listing = io.open("README_ESOUI.txt", "r")
        local listing_text = listing and listing:read("*all") or ""
        if listing then
            listing:close()
        end
        for _, dep in ipairs(hard_deps) do
            if listing_text == "" or not listing_text:find(dep, 1, true) then
                table.insert(
                    errors,
                    string.format(
                        "Hard dependency '%s' must be listed in README_ESOUI.txt (prefer top of description)",
                        dep
                    )
                )
            end
        end
    end

    for _, file_path in ipairs(referenced_files) do
        if not file_path:match("%.lua$") and not file_path:match("%.xml$") then
            table.insert(
                warnings,
                string.format("Referenced file '%s' doesn't have .lua or .xml extension", file_path)
            )
        else
            local f = io.open(file_path, "r")
            if not f then
                table.insert(errors, string.format("Referenced file does not exist: %s", file_path))
            else
                f:close()
            end
        end
    end

    print("Validating: " .. filepath)
    print("")

    if #errors > 0 then
        print("ERRORS:")
        for _, err in ipairs(errors) do
            print("   " .. err)
        end
        print("")
    end

    if #warnings > 0 then
        print("WARNINGS:")
        for _, warn in ipairs(warnings) do
            print("   " .. warn)
        end
        print("")
    end

    if #errors == 0 then
        print("Manifest is valid!")
        print("")
        print("Found fields:")
        for _, field in ipairs(REQUIRED_FIELDS) do
            if found_fields[field] then
                print(string.format("   %s: %s", field, found_fields[field]))
            end
        end
        for _, field in ipairs(OPTIONAL_FIELDS) do
            if found_fields[field] then
                print(string.format("   %s: %s", field, found_fields[field]))
            end
        end
        print("")
        print(string.format("Referenced files: %d", #referenced_files))
    end

    if #errors > 0 then
        os.exit(1)
    end
    os.exit(0)
end

if #arg < 1 then
    print("Usage: lua validate-manifest.lua <manifest_file.txt>")
    os.exit(1)
end

validate_manifest(arg[1])
