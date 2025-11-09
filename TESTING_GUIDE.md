# CharacterMarkdown - Testing Guide

## Overview

This guide explains how to use the automated test validation system to verify all fixes have been properly applied.

---

## Quick Start

### Run Tests

In-game, type:
```
/markdown test
```

This will:
1. Generate markdown using your current format
2. Run all validation tests
3. Display a detailed test report in chat
4. Show pass/fail summary

---

## Test Coverage

The validation system tests all 9 fixes from `FIXES_APPLIED_SUMMARY.md`:

### Issue #1: HTML Structure ✅
- Validates that HTML tables have proper `<tr>` tags
- Checks for broken table structures
- Verifies no missing table elements

### Issue #2: Callout Syntax ✅
- Verifies GitHub-native callout syntax: `> [!NOTE]`
- Checks for old/incorrect syntax (missing `!`)
- Validates callout types are correct

### Issue #3: Resource Values ✅
- Checks that Health/Magicka/Stamina don't all show `0`
- Detects potential data collection issues
- Warns if resources appear suspicious

### Issue #4: Enlightenment Callout ✅
- Verifies `> [!TIP]` callout for Enlightenment
- Checks that old `SUCCESS` callout isn't used
- Validates proper callout type

### Issue #5: Attention Needed Warnings ✅
- Checks for warning callout presence
- Validates warning types are present:
  - Unspent skill/attribute points
  - Full inventory (>90%)
  - Incomplete riding skills
  - Low companion rapport

### Issue #6: Progress Bar Consistency ✅
- Verifies standardized characters: `█` (filled) and `░` (empty)
- Checks for old inconsistent characters (▓, ▰, ▱)
- Validates progress bars use consistent style

### Issue #7: PvP Section Duplication ✅
- Verifies only ONE PvP section appears
- Checks for duplicate "PvP Stats" sections
- Validates unified PvP data

### Issue #8: Emoji Compatibility ✅
- Checks for problematic/newer emojis that might not render
- Validates widely-supported Unicode emojis
- Warns about potentially incompatible characters

---

## Test Output

### Successful Test Run

```
[CharacterMarkdown] Running validation tests...
[CharacterMarkdown] === TEST VALIDATION REPORT ===
[CharacterMarkdown] ✅ PASSED (8):
[CharacterMarkdown]   ✅ Issue #1: HTML Structure: All 0 tables have proper <tr> tags
[CharacterMarkdown]   ✅ Issue #2: Callout Syntax: Found 2 properly formatted callout(s)
[CharacterMarkdown]   ✅ Issue #3: Resource Values: Resource values appear valid
[CharacterMarkdown]   ✅ Issue #4: Enlightenment Callout: Enlightenment uses correct TIP callout type
[CharacterMarkdown]   ✅ Issue #5: Attention Needed Warnings: Found warning callout with 2 warning type(s)
[CharacterMarkdown]   ✅ Issue #6: Progress Bar Consistency: Progress bars use standardized characters (█ and ░)
[CharacterMarkdown]   ✅ Issue #7: PvP Section Duplication: Single unified PvP section found
[CharacterMarkdown]   ✅ Emoji Compatibility: All emojis use widely-supported characters
[CharacterMarkdown] ⚠️ WARNINGS (1):
[CharacterMarkdown]   ⚠️ Issue #4: Enlightenment Callout: No enlightenment callout found (character not enlightened)
[CharacterMarkdown] Pass Rate: 100% (8/8 passed, 1 warnings)
[CharacterMarkdown] All tests passed! (8 passed, 1 warnings)
```

### Failed Test Run

```
[CharacterMarkdown] Running validation tests...
[CharacterMarkdown] === TEST VALIDATION REPORT ===
[CharacterMarkdown] ❌ FAILED (2):
[CharacterMarkdown]   ❌ Issue #3: Resource Values: All resources show 0 (likely data collection issue)
[CharacterMarkdown]   ❌ Issue #7: PvP Section Duplication: Found 2 PvP sections (should be 1)
[CharacterMarkdown] ⚠️ WARNINGS (1):
[CharacterMarkdown]   ⚠️ Issue #4: Enlightenment Callout: No enlightenment callout found (character not enlightened)
[CharacterMarkdown] Pass Rate: 75% (6/8 passed, 1 warnings)
[CharacterMarkdown] Some tests failed: 6 passed, 2 failed, 1 warnings
```

---

## Understanding Results

### ✅ PASSED
- Test validation successful
- Fix has been properly applied
- No issues detected

### ❌ FAILED
- Test validation failed
- Fix may not be properly applied
- Action required: Check the specific issue

### ⚠️ WARNINGS
- Test result is conditional (expected behavior)
- Example: "No enlightenment callout" when character isn't enlightened
- These are informational, not errors

### Pass Rate Calculation
- Pass rate is calculated as: `(passed / (passed + failed)) × 100%`
- **Warnings are excluded** from pass rate calculation since they're informational, not failures
- Example: 5 passed, 0 failed, 3 warnings = **100% pass rate** (5/5, not 5/8)

---

## Manual Testing Checklist

For comprehensive manual testing, refer to `FIXES_APPLIED_SUMMARY.md`:

### Before Testing
- [ ] Backup current CharacterMarkdown addon
- [ ] Copy updated files to addon directory
- [ ] Run `/reloadui` in ESO

### Test Cases
- [ ] **Title Display**: Verify no broken HTML, title centered properly
- [ ] **Quick Stats**: Verify Health/Magicka/Stamina show actual values (not 0)
- [ ] **Quick Stats Callout**: Verify renders as `> [!NOTE]` with blue box
- [ ] **Enlightenment**: Verify `> [!TIP]` callout appears when enlightened
- [ ] **Attention Needed**: Verify warnings appear for:
  - [ ] Unspent skill/attribute points
  - [ ] Full inventory (>90%)
  - [ ] Incomplete riding skills
  - [ ] Low companion rapport
- [ ] **PvP Section**: Verify only ONE PvP section appears
- [ ] **PvP Data**: Verify no conflicting rank/campaign information
- [ ] **Progress Bars**: Verify consistent █ and ░ characters throughout
- [ ] **Empty Sections**: Verify collapsible behavior (when implemented)
- [ ] **Morph Symbols**: Verify clear choice indicators (when implemented)

### Format Testing
- [ ] GitHub format markdown renders correctly
- [ ] VS Code format markdown renders correctly
- [ ] Discord format is compact and readable
- [ ] Quick format provides one-line summary

---

## Debug Mode

To enable automatic validation on every markdown generation (debug only):

1. Enable debug mode in settings or via code
2. Tests will run automatically after generation
3. Results logged to debug output (non-blocking)

**Note:** This is for development only. Normal users won't see test output.

---

## Troubleshooting

### Tests Not Running

**Problem:** `/markdown test` says "Test validation module not loaded"

**Solution:**
1. Check that `src/utils/TestValidation.lua` is in the addon directory
2. Verify it's listed in `CharacterMarkdown.addon` manifest
3. Run `/reloadui` to reload the addon

### False Positives

Some tests may show warnings for expected conditions:
- **No Enlightenment Callout**: Normal if character isn't enlightened
- **No Warnings**: Normal if there are no attention-needed items
- **No PvP Section**: Normal if PvP is disabled or character has no PvP data

These are informational warnings, not failures.

### Test Validation Errors

If validation itself fails:
1. Check debug output for Lua errors
2. Verify markdown was generated successfully
3. Check that test module loaded correctly

---

## Test Code Location

All test validation code is in:
- **File**: `src/utils/TestValidation.lua`
- **Namespace**: `CM.tests.validation`
- **Functions**:
  - `ValidateMarkdown(markdown, format)` - Run all tests
  - `GetTestResults()` - Get current test results
  - `PrintTestReport()` - Print formatted report

---

## Contributing Tests

To add new test cases:

1. Add validation function to `TestValidation.lua`
2. Call it from `ValidateMarkdown()` function
3. Use `AddResult()` to record pass/fail/warning
4. Update this guide with test description

---

**Last Updated:** 2025-11-02  
**Version:** CharacterMarkdown v2.1.x

