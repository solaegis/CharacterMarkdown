# Documentation Audit & Consolidation Guide

## Overview

Automated system for maintaining clean, concise, and up-to-date documentation. Run this regularly to identify issues before they accumulate.

**Philosophy**: Documentation should be information-rich, visually appealing, readable, and free of duplication or obsolete content.

---

## 🚀 Quick Start

```bash
# Run comprehensive audit
task docs:audit

# Interactive consolidation workflow
task docs:consolidate

# Individual checks
task docs:stale         # Find outdated files
task docs:orphans       # Find unreferenced files
task docs:duplicates    # Find duplicate content
task docs:links         # Check for broken links
```

---

## 📋 Available Tasks

### `task docs:audit`
**Purpose**: Comprehensive overview of documentation health

**Checks**:
- 📄 Total documentation file count
- 📅 Stale files (6+ months old)
- 🔗 Orphaned files (not referenced anywhere)
- 📋 Duplicate filenames
- 📊 Total documentation size

**When to run**: Weekly or before major releases

**Output**:
```
📚 Documentation Audit
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📄 Documentation Files:
   Total: 57 files

📅 Stale Documentation (6+ months old):
   ✓ No stale files found

🔗 Checking for Orphaned Files:
   ⚠️  ./QUEST_CODE_REVIEW.md (not referenced)
   ⚠️  ./MEMORY_IMPROVEMENTS.md (not referenced)
   ...

📋 Potential Duplicate Topics:
   ⚠️  README.md appears in 4 locations
   ⚠️  testing.md appears in 2 locations

📊 Documentation Size:
   Total: .70MB
   Total: 24510 lines
```

---

### `task docs:stale`
**Purpose**: Find documentation not updated in 6+ months

**Details**:
- Shows age in days and months
- Shows file size (line count)
- Shows last modification date

**Questions to ask**:
- Is this still relevant?
- Does it need updating?
- Should it be archived?
- Can it be consolidated?

**Example**:
```
📄 ./docs/OLD_FEATURE.md
   Age: 243 days (~8 months)
   Size: 156 lines
   Last modified: 2024-04-15
```

---

### `task docs:orphans`
**Purpose**: Find files not referenced anywhere else

**What it checks**:
- Markdown files (`.md`)
- Not linked in other docs
- Not mentioned in config files
- Not referenced in `SUMMARY.md` or `book.toml`

**Common causes**:
- Old documents left behind
- Work-in-progress files
- Temporary notes
- Documentation replaced but not deleted

**Actions**:
- Add to `docs/SUMMARY.md` if valuable
- Consolidate into existing docs
- Delete if obsolete

---

### `task docs:duplicates`
**Purpose**: Find duplicate or similar content

**Checks**:
- Files with same name in different locations
- Files with same H1 heading (topic duplication)

**Output**:
```
Files with similar names:
  ⚠️  README.md (found in 4 locations)
     ./README.md
     ./docs/README.md
     ./assets/README.md
     ./scripts/README.md

Checking for duplicate topics (by heading analysis):
  ⚠️  "Installation Guide" appears in 2 files:
     ./docs/INSTALLATION.md
     ./README.md
```

**Resolution strategies**:
1. **Consolidate**: Merge into single authoritative document
2. **Differentiate**: If both needed, make purpose clear in title
3. **Cross-reference**: Link to canonical version
4. **Remove**: Delete outdated version

---

### `task docs:links`
**Purpose**: Check for broken internal links

**Checks**:
- Markdown links `[text](file.md)`
- File references `` `file.lua` ``
- Relative paths
- Absolute paths

**Does NOT check**: External URLs (use `task docs:links:external` for that)

**Output**:
```
❌ Broken link in ./docs/ARCHITECTURE.md
   Link: ../removed_file.md
   Target not found: /path/to/removed_file.md

⚠️  Referenced file may not exist: scripts/validate.sh
   Mentioned in: ./docs/DEVELOPMENT.md
```

---

### `task docs:links:external`
**Purpose**: Check external HTTP(S) links (requires network)

**Warning**: 
- Requires network connectivity
- Can be slow for many links
- May timeout on slow sites

**Use case**: Before releases to ensure external references are valid

---

### `task docs:consolidate`
**Purpose**: Interactive guided workflow

**Process**:
1. Runs comprehensive audit
2. Prompts for each type of review
3. Guides through consolidation decisions
4. Suggests re-running audit to verify

**Best for**: Quarterly documentation cleanup

---

## 📅 Recommended Schedule

### Weekly (Developer)
```bash
task docs:audit          # Quick health check
```

### Before Release
```bash
task docs:audit          # Full audit
task docs:links          # Check all links
task docs:stale          # Review outdated content
```

### Monthly Cleanup
```bash
task docs:consolidate    # Interactive workflow
```

### Quarterly Deep Clean
```bash
task docs:consolidate           # Full interactive review
task docs:links:external        # Check external links
# Then manually review and consolidate
task docs:audit                 # Verify improvements
```

---

## 🎯 Documentation Quality Goals

### Concise
- Remove redundant information
- Merge related topics
- Eliminate cruft

### Information-Rich
- Focus on value, not volume
- Every document should have clear purpose
- No "TODO" placeholders left indefinitely

### Visually Appealing
- Use headings, lists, tables
- Break up walls of text
- Add examples and code blocks

### Readable
- Clear, direct language
- Logical organization
- Good navigation (TOC, links)

### Up-to-Date
- Regular reviews
- Update on code changes
- Remove obsolete content

---

## 🔄 Consolidation Workflow

### 1. Identify Issues
```bash
task docs:audit
```

### 2. Categorize Files

**Keep & Update**: Still relevant, needs refresh
- Update dates, versions, examples
- Fix broken links
- Improve clarity

**Consolidate**: Overlapping content
- Merge into single authoritative doc
- Add cross-references
- Update all links to merged doc

**Archive**: Historical value but not current
- Move to `archive/` directory
- Add note explaining why archived
- Remove from navigation

**Delete**: No value
- Old scratch files
- Superseded by better docs
- Outdated approach/feature docs

### 3. Execute Changes

**For each file**:
```bash
# Check what references it
grep -r "FILENAME.md" --include="*.md" --include="*.yaml" .

# If consolidating, update all references
# If deleting, remove references
# If archiving, update links to point to canonical doc
```

### 4. Verify
```bash
task docs:audit          # Should show improvements
task docs:links          # No broken links
```

---

## 🛠️ Technical Details

### What Gets Scanned

**Included**:
- `*.md` files (all markdown)
- `*.txt` files (text documentation)
- All directories except exclusions

**Excluded**:
- `node_modules/` (dependencies)
- `book/` (generated mdBook output)
- `.task/` (task cache)
- `dist/` and `build/` (build artifacts)

### Staleness Threshold

**Default**: 6 months (180 days)

**Rationale**: 
- Active projects should update docs quarterly
- 6 months gives buffer for stable features
- Exceptions: `assets/examples/` (intentionally stable)

**Adjust if needed**: Edit `-mtime +180` in task

### Orphan Detection

**Considered orphaned if**:
- Not referenced in any `.md` file
- Not referenced in `.yaml` config files
- Not referenced in `book.toml`
- Not a standard file (README, CHANGELOG, LICENSE)

**Exceptions**: Examples in `assets/examples/` (intentionally standalone)

### Duplicate Detection

**Method 1**: Filename matching
- Finds files with same name in different locations
- Common for README.md in subdirectories

**Method 2**: Heading analysis
- Extracts H1 headings (`# Title`)
- Finds same heading in multiple files
- Indicates potential topic duplication

---

## 📊 Example Audit Results

### Initial State (Before Cleanup)
```
📄 Documentation Files: 57 files
📊 Documentation Size: 0.70MB, 24510 lines
🔗 Orphaned Files: 15 files
📋 Duplicate Topics: 6 instances
```

### After Consolidation
```
📄 Documentation Files: 42 files (-15)
📊 Documentation Size: 0.52MB (-26%), 18420 lines (-25%)
🔗 Orphaned Files: 0 files (✅)
📋 Duplicate Topics: 0 instances (✅)
```

### Results
- **26% reduction** in documentation size
- **15 obsolete files** removed
- **6 topics** consolidated
- **100% linkage** - all docs referenced
- **Improved clarity** - no duplication

---

## 💡 Tips & Best Practices

### 1. Regular Audits Prevent Accumulation
Don't let documentation debt build up. Weekly audits take 2 minutes.

### 2. Delete Aggressively
If uncertain about value, it's probably not valuable. Keep only what's clearly useful.

### 3. Single Source of Truth
One authoritative doc per topic. Everything else links to it.

### 4. Update on Code Changes
When code changes, update docs in the same commit.

### 5. Link Everything
Orphaned docs are invisible. Link from `README.md` or `docs/SUMMARY.md`.

### 6. Use Dates
Add "Last updated: YYYY-MM-DD" to long-lived docs.

### 7. Archive, Don't Delete (Initially)
If uncertain, move to `archive/` first. Delete after 1-2 releases.

### 8. Consolidate Related Topics
"Installation", "Setup", "Getting Started" should probably be one doc.

### 9. Review PRs for Doc Changes
Ensure code changes include doc updates.

### 10. Measure Progress
Run `task docs:audit` before and after cleanup to see improvement.

---

## 🔗 Integration with Development Workflow

### Pre-Release Checklist
Add to `RELEASE_CHECKLIST.md`:
```markdown
- [ ] Documentation audit clean (`task docs:audit`)
- [ ] No broken links (`task docs:links`)
- [ ] No stale files (`task docs:stale`)
```

### CI/CD Integration (Optional)
```yaml
# .github/workflows/docs-check.yaml
- name: Check documentation links
  run: task docs:links
```

### Git Hook (Optional)
```bash
# .git/hooks/pre-commit
# Warn on orphaned docs
task docs:orphans | grep -q "⚠️" && echo "Warning: Orphaned docs detected"
```

---

## 📈 Metrics to Track

### Documentation Health Score

**Formula**: `100 - (orphans × 5) - (duplicates × 3) - (stale_files × 2)`

**Example**:
- Orphans: 3 files → -15 points
- Duplicates: 2 topics → -6 points
- Stale: 1 file → -2 points
- **Score**: 77/100 (Good)

**Targets**:
- 90+: Excellent
- 75-89: Good
- 60-74: Needs attention
- <60: Priority cleanup needed

### Track Over Time
```bash
# Monthly
echo "$(date +%Y-%m-%d), $(task docs:audit | grep 'Total:' | wc -l)" >> docs_metrics.csv
```

---

## 🚨 Common Issues & Solutions

### Issue: Too Many Orphaned Files
**Cause**: Docs not linked from navigation
**Solution**: Add to `docs/SUMMARY.md` or `README.md`

### Issue: Duplicate README files
**Cause**: Each subdirectory has its own README
**Solution**: Acceptable if they serve different purposes (directory vs project)

### Issue: Stale files but still relevant
**Cause**: Stable features don't change often
**Solution**: Add "Last reviewed: DATE" comment, touch file to update timestamp

### Issue: Broken links after refactoring
**Cause**: Files moved/renamed without updating links
**Solution**: Run `task docs:links` before committing

### Issue: Large documentation size
**Cause**: Accumulated cruft, verbose writing
**Solution**: Consolidate, rewrite for concision, remove duplication

---

## 📚 Related Documentation

- [RELEASE_CHECKLIST.md](RELEASE_CHECKLIST.md) - Pre-release documentation checks
- [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md) - Development workflow
- [docs/PUBLISHING.md](docs/PUBLISHING.md) - Publishing process

---

## 🎓 Examples

### Consolidation Example

**Before**:
- `docs/INSTALL.md` (50 lines)
- `docs/SETUP.md` (40 lines)
- `docs/GETTING_STARTED.md` (30 lines)

**After**:
- `docs/INSTALLATION.md` (80 lines, consolidated best of all three)
- Updated all links to point to new location

**Result**: 40% reduction, clearer navigation, single source of truth

### Archival Example

**Before**:
- `docs/OLD_API.md` (ESO API 100043, outdated)
- `docs/LEGACY_APPROACH.md` (superseded implementation)

**After**:
- Moved to `archive/historical/`
- Added `archive/README.md` explaining context
- Removed from navigation

**Result**: No clutter in main docs, history preserved if needed

---

**Last Updated**: 2025-01-21  
**Version**: 1.0

**Maintained by**: CharacterMarkdown Team  
**Questions**: See [docs/README.md](docs/README.md)

