-- CharacterMarkdown - Layout Calculator Tests
-- Test suite for smart column layout calculation

local CM = CharacterMarkdown
CM.utils = CM.utils or {}
CM.utils.LayoutCalculatorTests = CM.utils.LayoutCalculatorTests or {}

-- Localize functions
local LayoutCalculator = CM.utils.LayoutCalculator
local TableAnalyzer = CM.utils.TableAnalyzer
local string_format = string.format

--[[
    Generate a sample markdown table for testing
    @param width number - Approximate character width
    @param rows number - Number of data rows
    @param title string - Table title
    @return string - Markdown table
]]
local function GenerateSampleTable(width, rows, title)
    title = title or "Sample"
    local lines = {}

    -- Header
    table.insert(lines, "#### " .. title .. "\n")
    table.insert(lines, "| Metric | Value |")
    table.insert(lines, "|:-------|------:|")

    -- Generate rows to approximate target width
    for i = 1, rows do
        local padding = string.rep("x", math.max(0, width - 40)) -- Pad to reach width
        table.insert(lines, string.format("| Item %d%s | %d |", i, padding, i * 100))
    end

    return table.concat(lines, "\n")
end

local function AssertLayout(layout, testName, minColumns, maxColumns)
    if not layout then
        return false, testName .. ": layout is nil"
    end
    if not layout.minWidth or not layout.minWidth:match("^%d+px$") then
        return false, testName .. ": invalid minWidth " .. tostring(layout.minWidth)
    end
    if not layout.gap or not layout.gap:match("^%d+px$") then
        return false, testName .. ": invalid gap " .. tostring(layout.gap)
    end
    if type(layout.columnCount) ~= "number" then
        return false, testName .. ": columnCount missing"
    end
    if layout.columnCount < minColumns or layout.columnCount > maxColumns then
        return false, string_format(
            "%s: columnCount %d outside expected range %d-%d",
            testName,
            layout.columnCount,
            minColumns,
            maxColumns
        )
    end
    return true, testName .. " passed"
end

--[[
    Test 1: Small item count (2-3 tables)
]]
local function TestSmallItemCount()
    CM.Info("=== Test 1: Small Item Count (2-3 tables) ===")

    local tables = {
        GenerateSampleTable(50, 3, "Category A"),
        GenerateSampleTable(50, 3, "Category B"),
        GenerateSampleTable(50, 3, "Category C"),
    }

    local layout = LayoutCalculator.CalculateOptimalLayout(tables)

    CM.Info(string.format("  Tables: %d", #tables))
    CM.Info(string.format("  MinWidth: %s", layout.minWidth))
    CM.Info(string.format("  Gap: %s", layout.gap))
    CM.Info(string.format("  Column Count: %d", layout.columnCount))
    CM.Info(string.format("  Reason: %s", layout.metadata.reason or "unknown"))

    return AssertLayout(layout, "Small item count", 1, 3)
end

--[[
    Test 2: Medium item count (6 tables)
]]
local function TestMediumItemCount()
    CM.Info("=== Test 2: Medium Item Count (6 tables) ===")

    local tables = {}
    for i = 1, 6 do
        table.insert(tables, GenerateSampleTable(60, 4, "Category " .. i))
    end

    local layout = LayoutCalculator.CalculateOptimalLayout(tables)

    CM.Info(string.format("  Tables: %d", #tables))
    CM.Info(string.format("  MinWidth: %s", layout.minWidth))
    CM.Info(string.format("  Column Count: %d", layout.columnCount))

    return AssertLayout(layout, "Medium item count", 2, 6)
end

--[[
    Test 3: Large item count (12+ tables)
]]
local function TestLargeItemCount()
    CM.Info("=== Test 3: Large Item Count (12 tables) ===")

    local tables = {}
    for i = 1, 12 do
        table.insert(tables, GenerateSampleTable(55, 3, "Category " .. i))
    end

    local layout = LayoutCalculator.CalculateOptimalLayout(tables)

    CM.Info(string.format("  Tables: %d", #tables))
    CM.Info(string.format("  MinWidth: %s", layout.minWidth))
    CM.Info(string.format("  Column Count: %d", layout.columnCount))

    return AssertLayout(layout, "Large item count", 2, 12)
end

--[[
    Test 4: Varying table widths (high variance)
]]
local function TestVaryingWidths()
    CM.Info("=== Test 4: Varying Table Widths (High Variance) ===")

    local tables = {
        GenerateSampleTable(100, 3, "Wide Table 1"),
        GenerateSampleTable(40, 2, "Narrow 1"),
        GenerateSampleTable(120, 4, "Very Wide"),
        GenerateSampleTable(45, 2, "Narrow 2"),
        GenerateSampleTable(90, 3, "Wide Table 2"),
        GenerateSampleTable(50, 2, "Medium"),
    }

    local analysis = TableAnalyzer.AnalyzeTables(tables)
    local layout = LayoutCalculator.CalculateOptimalLayout(tables)

    CM.Info(string.format("  Tables: %d", #tables))
    CM.Info(string.format("  Min Width: %d chars", analysis.stats.minWidth))
    CM.Info(string.format("  Max Width: %d chars", analysis.stats.maxWidth))
    CM.Info(string.format("  Median Width: %d chars", analysis.stats.medianWidth))
    CM.Info(string.format("  Calculated MinWidth: %s", layout.minWidth))
    CM.Info(string.format("  Column Count: %d", layout.columnCount))

    if analysis.stats.maxWidth <= analysis.stats.minWidth then
        return false, "Varying widths: expected maxWidth > minWidth"
    end

    return AssertLayout(layout, "Varying widths", 2, 6)
end

--[[
    Test 5: Similar table widths (low variance)
]]
local function TestSimilarWidths()
    CM.Info("=== Test 5: Similar Table Widths (Low Variance) ===")

    local tables = {}
    for i = 1, 8 do
        table.insert(tables, GenerateSampleTable(55, 3, "Category " .. i))
    end

    local analysis = TableAnalyzer.AnalyzeTables(tables)
    local layout = LayoutCalculator.CalculateOptimalLayout(tables)

    CM.Info(string.format("  Tables: %d", #tables))
    CM.Info(string.format("  Min Width: %d chars", analysis.stats.minWidth))
    CM.Info(string.format("  Max Width: %d chars", analysis.stats.maxWidth))
    CM.Info(string.format("  Width Variance: %.2f", layout.metadata.widthRatio or 0))
    CM.Info(string.format("  Calculated MinWidth: %s", layout.minWidth))
    CM.Info(string.format("  Column Count: %d", layout.columnCount))

    if (layout.metadata.widthRatio or 0) <= 0 then
        return false, "Similar widths: expected positive widthRatio metadata"
    end

    return AssertLayout(layout, "Similar widths", 2, 8)
end

--[[
    Test 6: Edge cases
]]
local function TestEdgeCases()
    CM.Info("=== Test 6: Edge Cases ===")

    -- Empty array
    CM.Info("  6a. Empty array:")
    local layout1 = LayoutCalculator.CalculateOptimalLayout({})
    CM.Info(string.format("    MinWidth: %s, Reason: %s", layout1.minWidth, layout1.metadata.reason))
    if layout1.columnCount ~= 1 or layout1.metadata.reason ~= "empty_input" then
        return false, "Edge case empty array: expected single column with reason empty_input"
    end

    -- Single table
    CM.Info("  6b. Single table:")
    local layout2 = LayoutCalculator.CalculateOptimalLayout({
        GenerateSampleTable(60, 3, "Solo"),
    })
    CM.Info(string.format("    MinWidth: %s, Reason: %s", layout2.minWidth, layout2.metadata.reason))
    if layout2.columnCount ~= 1 then
        return false, "Edge case single table: expected columnCount 1"
    end

    -- Very narrow tables
    CM.Info("  6c. Very narrow tables:")
    local narrowTables = {}
    for i = 1, 4 do
        table.insert(narrowTables, GenerateSampleTable(20, 2, "Tiny " .. i))
    end
    local layout3 = LayoutCalculator.CalculateOptimalLayout(narrowTables)
    CM.Info(string.format("    MinWidth: %s (should be clamped to min)", layout3.minWidth))
    local narrowWidth = tonumber((layout3.minWidth or ""):match("^(%d+)"))
    if not narrowWidth or narrowWidth < 250 then
        return false, "Edge case narrow tables: minWidth should be clamped to minimum"
    end

    -- Very wide tables
    CM.Info("  6d. Very wide tables:")
    local wideTables = {}
    for i = 1, 3 do
        table.insert(wideTables, GenerateSampleTable(200, 5, "Huge " .. i))
    end
    local layout4 = LayoutCalculator.CalculateOptimalLayout(wideTables)
    CM.Info(string.format("    MinWidth: %s (should be clamped to max)", layout4.minWidth))
    local wideWidth = tonumber((layout4.minWidth or ""):match("^(%d+)"))
    if not wideWidth or wideWidth > 450 then
        return false, "Edge case wide tables: minWidth should be clamped to maximum"
    end

    return true, "Edge cases passed"
end

--[[
    Run all layout calculator tests
]]
local function RunAllTests()
    CM.Info("========================================")
    CM.Info("Layout Calculator Test Suite")
    CM.Info("========================================\n")

    if not LayoutCalculator or not TableAnalyzer then
        CM.Error("LayoutCalculator or TableAnalyzer not loaded!")
        return false
    end

    local tests = {
        TestSmallItemCount,
        TestMediumItemCount,
        TestLargeItemCount,
        TestVaryingWidths,
        TestSimilarWidths,
        TestEdgeCases,
    }

    local passed = 0
    local failed = 0

    for _, testFunc in ipairs(tests) do
        local success, okOrErr, message = pcall(testFunc)
        if success and okOrErr == true then
            passed = passed + 1
            CM.Info(string.format("  ✓ %s\n", message or "Test passed"))
        else
            failed = failed + 1
            local errMsg = success and (message or tostring(okOrErr)) or tostring(okOrErr)
            CM.Error(string.format("  ✗ Test failed: %s\n", errMsg))
        end
    end

    CM.Info("========================================")
    CM.Info(string.format("Tests completed: %d passed, %d failed", passed, failed))
    CM.Info("========================================")

    return failed == 0
end

CM.utils.LayoutCalculatorTests.RunAllTests = RunAllTests
CM.utils.LayoutCalculatorTests.GenerateSampleTable = GenerateSampleTable

-- Export individual tests for targeted testing
CM.utils.LayoutCalculatorTests.TestSmallItemCount = TestSmallItemCount
CM.utils.LayoutCalculatorTests.TestMediumItemCount = TestMediumItemCount
CM.utils.LayoutCalculatorTests.TestLargeItemCount = TestLargeItemCount
CM.utils.LayoutCalculatorTests.TestVaryingWidths = TestVaryingWidths
CM.utils.LayoutCalculatorTests.TestSimilarWidths = TestSimilarWidths
CM.utils.LayoutCalculatorTests.TestEdgeCases = TestEdgeCases

CM.DebugPrint("UTILS", "LayoutCalculatorTests module loaded with test suite")
