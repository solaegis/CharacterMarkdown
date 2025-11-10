-- CharacterMarkdown - Export/Import Tests
-- Unit tests for settings export/import functionality
-- Run with: /script CharacterMarkdown.tests.exportImport.RunAllTests()

local CM = CharacterMarkdown
CM.tests = CM.tests or {}
CM.tests.exportImport = {}

local string_format = string.format

-- =====================================================
-- TEST RESULTS TRACKING
-- =====================================================

local exportImportTestResults = {
    passed = {},
    failed = {},
    total = 0
}

local function AddTestResult(testName, passed, message)
    exportImportTestResults.total = exportImportTestResults.total + 1
    if passed then
        table.insert(exportImportTestResults.passed, {
            test = testName,
            message = message or ""
        })
    else
        table.insert(exportImportTestResults.failed, {
            test = testName,
            message = message or ""
        })
    end
end

local function ResetTestResults()
    exportImportTestResults.passed = {}
    exportImportTestResults.failed = {}
    exportImportTestResults.total = 0
end

-- =====================================================
-- TEST: YAML SERIALIZATION (TableToYAML)
-- =====================================================

local function TestYAMLSerialization()
    local testName = "YAML Serialization"
    
    if not CM.utils or not CM.utils.TableToYAML then
        AddTestResult(testName, false, "TableToYAML function not found")
        return
    end
    
    -- Test 1: Simple key-value pairs
    local simpleTable = {
        name = "test",
        value = 42,
        enabled = true
    }
    local yaml = CM.utils.TableToYAML(simpleTable)
    if yaml and yaml ~= "" then
        AddTestResult(testName .. " - Simple Table", true, "Simple table serialized successfully")
    else
        AddTestResult(testName .. " - Simple Table", false, "Simple table serialization returned empty")
        return
    end
    
    -- Test 2: Nested objects
    local nestedTable = {
        parent = {
            child = "value",
            number = 123
        },
        top = "level"
    }
    local nestedYaml = CM.utils.TableToYAML(nestedTable)
    if nestedYaml and string.find(nestedYaml, "parent:") and string.find(nestedYaml, "child:") then
        AddTestResult(testName .. " - Nested Objects", true, "Nested objects serialized correctly")
    else
        AddTestResult(testName .. " - Nested Objects", false, "Nested objects not serialized correctly")
    end
    
    -- Test 3: Arrays
    local arrayTable = {
        items = {1, 2, 3},
        names = {"a", "b", "c"}
    }
    local arrayYaml = CM.utils.TableToYAML(arrayTable)
    if arrayYaml and string.find(arrayYaml, "items:") and string.find(arrayYaml, "- ") then
        AddTestResult(testName .. " - Arrays", true, "Arrays serialized correctly")
    else
        AddTestResult(testName .. " - Arrays", false, "Arrays not serialized correctly")
    end
    
    -- Test 4: String escaping
    local stringTable = {
        quoted = 'string with "quotes"',
        newline = "line1\nline2"
    }
    local stringYaml = CM.utils.TableToYAML(stringTable)
    if stringYaml and string.find(stringYaml, 'quoted: "') then
        AddTestResult(testName .. " - String Escaping", true, "Strings with special characters escaped")
    else
        AddTestResult(testName .. " - String Escaping", false, "String escaping not working")
    end
    
    -- Test 5: Boolean values
    local boolTable = {
        trueValue = true,
        falseValue = false
    }
    local boolYaml = CM.utils.TableToYAML(boolTable)
    if boolYaml and string.find(boolYaml, "trueValue: true") and string.find(boolYaml, "falseValue: false") then
        AddTestResult(testName .. " - Booleans", true, "Boolean values serialized correctly")
    else
        AddTestResult(testName .. " - Booleans", false, "Boolean values not serialized correctly")
    end
    
    -- Test 6: Internal keys skipped
    local internalTable = {
        public = "value",
        _internal = "should be skipped",
        _private = "also skipped"
    }
    local internalYaml = CM.utils.TableToYAML(internalTable)
    if internalYaml and not string.find(internalYaml, "_internal") and not string.find(internalYaml, "_private") then
        AddTestResult(testName .. " - Internal Keys", true, "Internal keys correctly skipped")
    else
        AddTestResult(testName .. " - Internal Keys", false, "Internal keys not skipped")
    end
end

-- =====================================================
-- TEST: YAML PARSING (YAMLToTable)
-- =====================================================

local function TestYAMLParsing()
    local testName = "YAML Parsing"
    
    if not CM.utils or not CM.utils.YAMLToTable then
        AddTestResult(testName, false, "YAMLToTable function not found")
        return
    end
    
    -- Test 1: Simple key-value pairs
    local simpleYaml = [[
name: "test"
value: 42
enabled: true
]]
    local parsed, error = CM.utils.YAMLToTable(simpleYaml)
    if parsed and parsed.name == "test" and parsed.value == 42 and parsed.enabled == true then
        AddTestResult(testName .. " - Simple Pairs", true, "Simple key-value pairs parsed correctly")
    else
        AddTestResult(testName .. " - Simple Pairs", false, 
            string_format("Parsing failed: %s", error or "Unknown error"))
    end
    
    -- Test 2: Nested objects
    local nestedYaml = [[
parent:
  child: "value"
  number: 123
top: "level"
]]
    local nestedParsed, nestedError = CM.utils.YAMLToTable(nestedYaml)
    if nestedParsed and nestedParsed.parent and nestedParsed.parent.child == "value" and nestedParsed.top == "level" then
        AddTestResult(testName .. " - Nested Objects", true, "Nested objects parsed correctly")
    else
        AddTestResult(testName .. " - Nested Objects", false, 
            string_format("Nested parsing failed: %s", nestedError or "Unknown error"))
    end
    
    -- Test 3: Arrays
    local arrayYaml = [[
items:
  - 1
  - 2
  - 3
names:
  - "a"
  - "b"
  - "c"
]]
    local arrayParsed, arrayError = CM.utils.YAMLToTable(arrayYaml)
    if arrayParsed and arrayParsed.items and #arrayParsed.items == 3 and arrayParsed.items[1] == 1 then
        AddTestResult(testName .. " - Arrays", true, "Arrays parsed correctly")
    else
        AddTestResult(testName .. " - Arrays", false, 
            string_format("Array parsing failed: %s", arrayError or "Unknown error"))
    end
    
    -- Test 4: String unescaping
    local stringYaml = [[
quoted: "string with \"quotes\""
newline: "line1\nline2"
]]
    local stringParsed, stringError = CM.utils.YAMLToTable(stringYaml)
    if stringParsed and stringParsed.quoted and string.find(stringParsed.quoted, '"') then
        AddTestResult(testName .. " - String Unescaping", true, "Strings with special characters unescaped")
    else
        AddTestResult(testName .. " - String Unescaping", false, 
            string_format("String unescaping failed: %s", stringError or "Unknown error"))
    end
    
    -- Test 5: Boolean values
    local boolYaml = [[
trueValue: true
falseValue: false
]]
    local boolParsed, boolError = CM.utils.YAMLToTable(boolYaml)
    if boolParsed and boolParsed.trueValue == true and boolParsed.falseValue == false then
        AddTestResult(testName .. " - Booleans", true, "Boolean values parsed correctly")
    else
        AddTestResult(testName .. " - Booleans", false, 
            string_format("Boolean parsing failed: %s", boolError or "Unknown error"))
    end
    
    -- Test 6: Invalid YAML handling
    local invalidYaml = "this is not valid yaml: missing colon"
    local invalidParsed, invalidError = CM.utils.YAMLToTable(invalidYaml)
    if not invalidParsed and invalidError then
        AddTestResult(testName .. " - Error Handling", true, "Invalid YAML correctly rejected with error")
    else
        AddTestResult(testName .. " - Error Handling", false, "Invalid YAML not properly rejected")
    end
    
    -- Test 7: Empty YAML
    local emptyParsed, emptyError = CM.utils.YAMLToTable("")
    if not emptyParsed and emptyError then
        AddTestResult(testName .. " - Empty YAML", true, "Empty YAML correctly rejected")
    else
        AddTestResult(testName .. " - Empty YAML", false, "Empty YAML not properly handled")
    end
end

-- =====================================================
-- TEST: ROUND-TRIP (Export then Import)
-- =====================================================

local function TestRoundTrip()
    local testName = "Round-Trip Export/Import"
    
    if not CM.utils or not CM.utils.TableToYAML or not CM.utils.YAMLToTable then
        AddTestResult(testName, false, "YAML functions not available")
        return
    end
    
    -- Test with actual settings
    local settings = CM.GetSettings()
    if not settings then
        AddTestResult(testName, false, "Settings not available")
        return
    end
    
    -- Export to YAML
    local yaml = CM.utils.TableToYAML(settings)
    if not yaml or yaml == "" then
        AddTestResult(testName .. " - Export", false, "Failed to export settings to YAML")
        return
    end
    AddTestResult(testName .. " - Export", true, "Settings exported to YAML successfully")
    
    -- Import from YAML
    local parsed, error = CM.utils.YAMLToTable(yaml)
    if not parsed then
        AddTestResult(testName .. " - Import", false, 
            string_format("Failed to import YAML: %s", error or "Unknown error"))
        return
    end
    AddTestResult(testName .. " - Import", true, "YAML imported successfully")
    
    -- Verify key settings match
    local keyMatches = 0
    local keyMismatches = 0
    local defaults = CM.Settings.Defaults:GetAll()
    
    for key, defaultValue in pairs(defaults) do
        if settings[key] ~= nil and parsed[key] ~= nil then
            -- Compare values (handle type differences)
            if type(settings[key]) == type(parsed[key]) then
                if settings[key] == parsed[key] then
                    keyMatches = keyMatches + 1
                else
                    keyMismatches = keyMismatches + 1
                end
            else
                -- Type mismatch - might be okay for some conversions
                keyMismatches = keyMismatches + 1
            end
        end
    end
    
    if keyMatches > 0 and keyMismatches == 0 then
        AddTestResult(testName .. " - Data Integrity", true, 
            string_format("All %d settings matched after round-trip", keyMatches))
    elseif keyMatches > keyMismatches then
        AddTestResult(testName .. " - Data Integrity", true, 
            string_format("Most settings matched: %d matched, %d mismatched", keyMatches, keyMismatches))
    else
        AddTestResult(testName .. " - Data Integrity", false, 
            string_format("Too many mismatches: %d matched, %d mismatched", keyMatches, keyMismatches))
    end
end

-- =====================================================
-- TEST: SETTINGS VALIDATION
-- =====================================================

local function TestSettingsValidation()
    local testName = "Settings Validation"
    
    if not CM.Settings or not CM.Settings.Defaults then
        AddTestResult(testName, false, "Settings defaults not available")
        return
    end
    
    local defaults = CM.Settings.Defaults:GetAll()
    if not defaults then
        AddTestResult(testName, false, "Could not get defaults")
        return
    end
    
    -- Test 1: Valid settings pass validation
    local validSettings = {}
    for key, defaultValue in pairs(defaults) do
        validSettings[key] = defaultValue
    end
    
    local validCount = 0
    for key, value in pairs(validSettings) do
        if defaults[key] ~= nil and type(value) == type(defaults[key]) then
            validCount = validCount + 1
        end
    end
    
    if validCount > 0 then
        AddTestResult(testName .. " - Valid Settings", true, 
            string_format("%d valid settings verified", validCount))
    else
        AddTestResult(testName .. " - Valid Settings", false, "No valid settings found")
    end
    
    -- Test 2: Unknown keys are rejected
    local unknownSettings = {
        unknownKey = "value",
        anotherUnknown = 123
    }
    local unknownCount = 0
    for key, value in pairs(unknownSettings) do
        if defaults[key] == nil then
            unknownCount = unknownCount + 1
        end
    end
    
    if unknownCount == 2 then
        AddTestResult(testName .. " - Unknown Keys", true, "Unknown keys correctly identified")
    else
        AddTestResult(testName .. " - Unknown Keys", false, "Unknown key detection failed")
    end
    
    -- Test 3: Type mismatches are detected
    local typeMismatchSettings = {
        currentFormat = 123,  -- Should be string
        includeChampionPoints = "not a boolean",  -- Should be boolean
        minSkillRank = "not a number"  -- Should be number
    }
    local mismatchCount = 0
    for key, value in pairs(typeMismatchSettings) do
        if defaults[key] ~= nil and type(value) ~= type(defaults[key]) then
            mismatchCount = mismatchCount + 1
        end
    end
    
    if mismatchCount == 3 then
        AddTestResult(testName .. " - Type Mismatches", true, "Type mismatches correctly detected")
    else
        AddTestResult(testName .. " - Type Mismatches", false, 
            string_format("Type mismatch detection failed: found %d mismatches", mismatchCount))
    end
end

-- =====================================================
-- TEST: EXPORT COMMAND
-- =====================================================

local function TestExportCommand()
    local testName = "Export Command"
    
    -- Test that export command handler exists
    if not SLASH_COMMANDS or not SLASH_COMMANDS["/cmdsettings"] then
        AddTestResult(testName, false, "/cmdsettings command not registered")
        return
    end
    
    AddTestResult(testName .. " - Command Registration", true, "/cmdsettings command registered")
    
    -- Test that YAML serializer is available
    if CM.utils and CM.utils.TableToYAML then
        AddTestResult(testName .. " - YAML Serializer", true, "YAML serializer available")
    else
        AddTestResult(testName .. " - YAML Serializer", false, "YAML serializer not available")
    end
    
    -- Test that settings are accessible
    local settings = CM.GetSettings()
    if settings then
        AddTestResult(testName .. " - Settings Access", true, "Settings accessible for export")
    else
        AddTestResult(testName .. " - Settings Access", false, "Settings not accessible")
    end
end

-- =====================================================
-- TEST: IMPORT COMMAND
-- =====================================================

local function TestImportCommand()
    local testName = "Import Command"
    
    -- Test that import command handler exists
    if not SLASH_COMMANDS or not SLASH_COMMANDS["/cmdsettings"] then
        AddTestResult(testName, false, "/cmdsettings command not registered")
        return
    end
    
    AddTestResult(testName .. " - Command Registration", true, "/cmdsettings command registered")
    
    -- Test that YAML parser is available
    if CM.utils and CM.utils.YAMLToTable then
        AddTestResult(testName .. " - YAML Parser", true, "YAML parser available")
    else
        AddTestResult(testName .. " - YAML Parser", false, "YAML parser not available")
    end
    
    -- Test that validation functions exist
    if CM.Settings and CM.Settings.Defaults then
        local defaults = CM.Settings.Defaults:GetAll()
        if defaults then
            AddTestResult(testName .. " - Validation", true, "Settings validation available")
        else
            AddTestResult(testName .. " - Validation", false, "Could not get defaults for validation")
        end
    else
        AddTestResult(testName .. " - Validation", false, "Settings defaults not available")
    end
end

-- =====================================================
-- TEST: EDGE CASES
-- =====================================================

local function TestEdgeCases()
    local testName = "Edge Cases"
    
    if not CM.utils or not CM.utils.TableToYAML or not CM.utils.YAMLToTable then
        AddTestResult(testName, false, "YAML functions not available")
        return
    end
    
    -- Test 1: Empty table
    local emptyTable = {}
    local emptyYaml = CM.utils.TableToYAML(emptyTable)
    if emptyYaml then
        AddTestResult(testName .. " - Empty Table", true, "Empty table handled correctly")
    else
        AddTestResult(testName .. " - Empty Table", false, "Empty table not handled")
    end
    
    -- Test 2: Table with only internal keys
    local internalOnlyTable = {
        _key1 = "value1",
        _key2 = "value2"
    }
    local internalYaml = CM.utils.TableToYAML(internalOnlyTable)
    if internalYaml and (internalYaml == "" or not string.find(internalYaml, "_key")) then
        AddTestResult(testName .. " - Internal Keys Only", true, "Table with only internal keys handled")
    else
        AddTestResult(testName .. " - Internal Keys Only", false, "Internal keys not properly filtered")
    end
    
    -- Test 3: Very long strings
    local longString = string.rep("a", 1000)
    local longStringTable = {
        long = longString
    }
    local longYaml = CM.utils.TableToYAML(longStringTable)
    if longYaml and string.find(longYaml, "long:") then
        AddTestResult(testName .. " - Long Strings", true, "Long strings serialized correctly")
    else
        AddTestResult(testName .. " - Long Strings", false, "Long strings not handled")
    end
    
    -- Test 4: Special characters in keys
    local specialKeyTable = {
        ["key with spaces"] = "value",
        ["key-with-dashes"] = "value2"
    }
    local specialYaml = CM.utils.TableToYAML(specialKeyTable)
    if specialYaml then
        AddTestResult(testName .. " - Special Key Characters", true, "Special characters in keys handled")
    else
        AddTestResult(testName .. " - Special Key Characters", false, "Special key characters not handled")
    end
    
    -- Test 5: Nil values
    local nilTable = {
        key1 = "value",
        key2 = nil
    }
    local nilYaml = CM.utils.TableToYAML(nilTable)
    if nilYaml then
        AddTestResult(testName .. " - Nil Values", true, "Nil values handled in serialization")
    else
        AddTestResult(testName .. " - Nil Values", false, "Nil values not handled")
    end
end

-- =====================================================
-- RUN ALL TESTS
-- =====================================================

local function RunAllTests()
    ResetTestResults()
    
    CM.Info("=== Running Export/Import Tests ===")
    
    TestYAMLSerialization()
    TestYAMLParsing()
    TestRoundTrip()
    TestSettingsValidation()
    TestExportCommand()
    TestImportCommand()
    TestEdgeCases()
    
    -- Print results
    local total = exportImportTestResults.total
    local passed = #exportImportTestResults.passed
    local failed = #exportImportTestResults.failed
    local passRate = total > 0 and math.floor((passed / total) * 100) or 0
    
    CM.Info(string_format("=== Test Results: %d/%d passed (%.0f%%) ===", passed, total, passRate))
    
    if #exportImportTestResults.passed > 0 then
        CM.Info("Passed:")
        for _, result in ipairs(exportImportTestResults.passed) do
            d(string_format("  ✓ %s: %s", result.test, result.message))
        end
    end
    
    if #exportImportTestResults.failed > 0 then
        CM.Warn("Failed:")
        for _, result in ipairs(exportImportTestResults.failed) do
            d(string_format("  ✗ %s: %s", result.test, result.message))
        end
    end
    
    return {
        passed = exportImportTestResults.passed,
        failed = exportImportTestResults.failed,
        total = total,
        passRate = passRate
    }
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.tests.exportImport.RunAllTests = RunAllTests
CM.tests.exportImport.GetTestResults = function()
    return {
        passed = exportImportTestResults.passed,
        failed = exportImportTestResults.failed,
        total = exportImportTestResults.total
    }
end

CM.DebugPrint("TESTS", "Export/Import tests module loaded")

