# `/cm test` - Comprehensive Diagnostic & Validation

(`/markdown` is an alias for `/cm`.)

The `/cm test` command has been significantly enhanced by merging the best diagnostic logic from both the original `test` and `diag` commands into a single comprehensive testing tool.

## Overview

The improved test command runs through **4 phases** to thoroughly validate your addon configuration and output:

1. **Settings Diagnostic** - Validates settings configuration and merge logic
2. **Data Collection Test** - Verifies data collectors are working
3. **Markdown Generation Test** - Tests markdown generation with current settings
4. **Validation Tests** - Runs comprehensive validation on generated output

## Usage

```
/cm test
```

## Output Example

```
=== CharacterMarkdown Diagnostic & Validation ===

[1/4] Settings Diagnostic

✓ CharacterMarkdownSettings exists
✓ CM.GetSettings() available

Critical Setting Values:
  includeChampionPoints = true
  includeChampionDiagram = true
  includeSkillBars = true
  includeSkills = true
  includeEquipment = true
  ...

✓ Settings merge working correctly
✓ No active filter (using custom settings)

[2/4] Data Collection Test

✓ Champion Points data collected
  Total: 732 | Spent: 655 | Available: 77
  Disciplines: 3
    Craft: 189 CP, 29 skills
    Warfare: 224 CP, 41 skills
    Fitness: 242 CP, 48 skills

[3/4] Markdown Generation Test

Generating github format with current settings...
✓ Markdown generated successfully
  Total size: 12,453 chars

[4/4] Validation Tests

Running validation tests...
  ✓ Non-empty markdown
  ✓ Valid heading hierarchy
  ✓ No broken table syntax
  ...

Running section presence tests...
  ✓ ChampionPoints section present (required: true)
  ✓ SkillBars section present (required: true)
  ...

=== Test Summary ===
✓ ALL TESTS PASSED! (15 validation, 8 sections)

Tip: Run '/cm' to see the actual generated output
```

## What Each Phase Tests

### Phase 1: Settings Diagnostic

**Purpose:** Verify settings are correctly loaded and merged

**Checks:**
- ✓ CharacterMarkdownSettings exists (not nil)
- ✓ CM.GetSettings() is available
- ✓ Critical settings values are correct
- ✓ No mismatches between raw and merged settings
- ✓ Active filter status (warns if a filter is overriding settings)

**Color Coding:**
- 🟢 Green = Setting is `true` (enabled)
- 🔴 Red = Setting is `false` (disabled)
- 🟡 Yellow = Warning/mismatch detected

### Phase 2: Data Collection Test

**Purpose:** Verify data collectors can successfully gather game data

**Tests:**
- Champion Points data collection
- Shows total/spent/available CP
- Lists all 3 disciplines with their CP totals
- Shows skill count per discipline

**Why Important:** If data collection fails here, markdown generation will produce empty/incomplete output

### Phase 3: Markdown Generation Test

**Purpose:** Test that markdown can be generated with current settings

**Verifies:**
- Markdown generation completes without errors
- Shows chunk count (if output is chunked)
- Shows total character count
- Collects current settings for validation

**Why Important:** This catches generation errors before running expensive validation tests

### Phase 4: Validation Tests

**Purpose:** Validate the generated markdown meets quality standards

**Includes:**

1. **Validation Tests** (from original `test` command)
   - Non-empty output
   - Valid heading hierarchy
   - No broken table syntax
   - No broken list syntax
   - Proper code block formatting

2. **Section Presence Tests**
   - Verifies expected sections appear based on settings
   - Checks that enabled sections are actually present
   - Warns if required sections are missing

## When to Use

### ✅ Use `/cm test` when:
- Troubleshooting missing sections
- Verifying settings are working correctly
- Debugging generation issues
- After making code changes
- Before reporting bugs
- Validating a fresh installation

### ❌ Don't use when:
- You just want to see the markdown output (use `/cm`)
- You want to copy the markdown (use `/cm` then copy from window)

## Comparison with Other Commands

| Command | Purpose | When to Use |
|---------|---------|-------------|
| `/cm test` | Comprehensive diagnostic + validation | Troubleshooting, debugging |
| `/cm` | Generate actual markdown output | Normal usage, getting markdown to copy |
| `/cm diag` | *(Legacy - redirects to test)* | Use `/cm test` instead |

## Interpreting Results

### ✓ All Tests Passed
Everything is working correctly. Your markdown output should be complete and valid.

### ⚠ Tests Passed with Warnings
Generation succeeded but there are minor issues that don't affect functionality.

**Common Warnings:**
- Optional sections missing (expected if disabled)
- Formatting inconsistencies that don't break rendering

### ✗ Tests Failed
Something is broken and needs attention.

**Common Failures:**
- Settings merge mismatches → Check FilterManager initialization
- Data collection failed → Check ESO API availability
- Generation errors → Check collector/generator code
- Missing required sections → Check settings and section conditions

## Troubleshooting

### Settings Merge Mismatches

**Problem:** Raw and merged settings don't match

**Solution:**
1. Run `/reloadui` to restart addon
2. Check if a filter is active (Phase 1 shows this)
3. Clear active filter in settings panel
4. Verify FilterManager was initialized (check logs)

### Data Collection Failed

**Problem:** Can't collect Champion Points data

**Solution:**
1. Ensure you're Level 50+ (CP system unlocked)
2. Try `/reloadui` to refresh game state
3. Check if other addons are interfering
4. Verify ESO API is available

### Missing Sections in Output

**Problem:** Sections are enabled but not appearing

**Solution:**
1. Check Phase 1 to see actual setting values (green = enabled)
2. Check Phase 4 section presence tests for specific failures
3. Verify no active filter is overriding settings
4. Check if section has additional requirements (e.g., data must exist)

## Legacy Command

The old `/cm diag` command has been merged into `/cm test`. If you run `/cm diag`, it will automatically redirect to the new comprehensive test command.

## Tips

1. **Run test after changes** - Always run `/cm test` after modifying settings to verify they took effect

2. **Check active filters** - Phase 1 shows if a filter is active. Filters override manual settings, which can be confusing.

3. **Use for bug reports** - Include `/cm test` output when reporting bugs. It provides comprehensive diagnostic info.

4. **Compare with actual output** - After test passes, run `/cm` to see the actual generated markdown and verify it looks correct.

5. **Save output** - The test output is valuable for debugging. Consider taking a screenshot if issues occur.

## Technical Details

### Settings Flow
1. Raw settings read from `CharacterMarkdownSettings` SavedVariables
2. Merged with defaults via `CM.GetSettings()`
3. Test verifies raw and merged values match
4. Warns if mismatches detected (indicates merge bug)

### Data Collection Flow
1. Calls collector functions directly (e.g., `CollectChampionPointData`)
2. Uses `pcall` to catch errors gracefully
3. Shows detailed data structure for verification

### Validation Flow
1. Generates markdown with current settings
2. Handles both string and chunked output
3. Runs syntax validation (tables, lists, headings)
4. Runs semantic validation (section presence)
5. Aggregates results into pass/fail summary

