#!/usr/bin/env lua
-- CharacterMarkdown Manifest Validator
-- Validates ESO addon manifest (.txt) file for required fields and format

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
    "Description",
}

local function validate_manifest(filepath)
    local file = io.open(filepath, "r")
    if not file then
        print("❌ Error: Cannot open manifest file: " .. filepath)
        os.exit(1)
    end
    
    local content = file:read("*all")
    file:close()
    
    local found_fields = {}
    local referenced_files = {}
    local errors = {}
    local warnings = {}
    
    -- Parse manifest line by line
    for line in content:gmatch("[^\r\n]+") do
        -- Check for field definitions
        local field, value = line:match("^##%s*(%w+):%s*(.+)$")
        if field and value then
            found_fields[field] = value
        end
        
        -- Check for file references (Lua/XML files)
        if not line:match("^##") and not line:match("^;") and line:match("%S") then
            table.insert(referenced_files, line:match("^%s*(.-)%s*$"))
        end
    end
    
    -- Validate required fields
    for _, field in ipairs(REQUIRED_FIELDS) do
        if not found_fields[field] then
            table.insert(errors, string.format("Missing required field: ## %s:", field))
        end
    end
    
    -- Validate Version format (semantic versioning or @project-version@)
    if found_fields.Version then
        local version = found_fields.Version
        -- Allow either semantic versioning or the ESOUI Git placeholder
        if version == "@project-version@" then
            -- This is the ESOUI Git-based versioning placeholder - valid!
            print("   ℹ️  Using ESOUI @project-version@ placeholder (Git-based versioning)")
        elseif not version:match("^%d+%.%d+%.%d+") then
            table.insert(warnings, string.format(
                "Version '%s' doesn't follow semantic versioning (MAJOR.MINOR.PATCH) or @project-version@",
                version
            ))
        end
    end
    
    -- Validate APIVersion format
    if found_fields.APIVersion then
        local api_versions = found_fields.APIVersion
        if not api_versions:match("^%d+") then
            table.insert(errors, string.format(
                "APIVersion '%s' is not a valid number",
                api_versions
            ))
        end
    end
    
    -- Validate AddOnVersion (should be numeric, date format, or @project-version@)
    if found_fields.AddOnVersion then
        local addon_version = found_fields.AddOnVersion
        -- Allow either numeric or the ESOUI Git placeholder
        if addon_version == "@project-version@" then
            -- This is the ESOUI Git-based versioning placeholder - valid!
            print("   ℹ️  Using ESOUI @project-version@ for AddOnVersion")
        elseif not addon_version:match("^%d+$") then
            table.insert(warnings, string.format(
                "AddOnVersion '%s' is not numeric (recommended: YYYYMMDD or @project-version@)",
                addon_version
            ))
        end
    end
    
    -- Check for file existence (basic check for .lua and .xml references)
    for _, file_path in ipairs(referenced_files) do
        -- Basic validation: ensure file path looks reasonable
        if not file_path:match("%.lua$") and not file_path:match("%.xml$") then
            table.insert(warnings, string.format(
                "Referenced file '%s' doesn't have .lua or .xml extension",
                file_path
            ))
        end
    end
    
    -- Output results
    print("📋 Validating: " .. filepath)
    print("")
    
    if #errors > 0 then
        print("❌ ERRORS:")
        for _, err in ipairs(errors) do
            print("   " .. err)
        end
        print("")
    end
    
    if #warnings > 0 then
        print("⚠️  WARNINGS:")
        for _, warn in ipairs(warnings) do
            print("   " .. warn)
        end
        print("")
    end
    
    if #errors == 0 and #warnings == 0 then
        print("✅ Manifest is valid!")
        print("")
        print("Found fields:")
        for _, field in ipairs(REQUIRED_FIELDS) do
            if found_fields[field] then
                print(string.format("   ✓ %s: %s", field, found_fields[field]))
            end
        end
        for _, field in ipairs(OPTIONAL_FIELDS) do
            if found_fields[field] then
                print(string.format("   ✓ %s: %s", field, found_fields[field]))
            end
        end
        print("")
        print(string.format("Referenced files: %d", #referenced_files))
    end
    
    -- Exit with error code if validation failed
    if #errors > 0 then
        os.exit(1)
    end
    
    -- Exit with success (warnings don't block)
    os.exit(0)
end

-- Main execution
if #arg < 1 then
    print("Usage: lua validate-manifest.lua <manifest_file.txt>")
    os.exit(1)
end

validate_manifest(arg[1])
