# Documentation Reorganization Plan

## Current Structure Analysis

### Root Directory (25 .md files)
**Problem**: Cluttered with implementation notes, code reviews, and completed work summaries

### docs/ Directory (17 .md files)
**Status**: Well-organized, proper location for detailed documentation

---

## Recommended Actions

### ✅ KEEP AT ROOT (Standard Files)
These should stay at the root level (standard convention):

```
✅ README.md                      # Project overview (standard location)
✅ CHANGELOG.md                   # Version history (standard location)
✅ LICENSE                        # License file (standard location)
✅ RELEASE_CHECKLIST.md           # Release process (common at root)
```

---

### 📁 MOVE TO docs/ (Detailed Guides)

Move these documentation files to `docs/` for better organization:

```bash
# Detailed guides belong in docs/
mv DOCUMENTATION_AUDIT_GUIDE.md docs/
mv TASKFILE_ENHANCEMENTS.md docs/
```

**Rationale**:
- `DOCUMENTATION_AUDIT_GUIDE.md` - Detailed operational guide (533 lines)
- `TASKFILE_ENHANCEMENTS.md` - Development documentation

**After moving, update references in**:
- `RELEASE_CHECKLIST.md`
- Any other files that link to these

---

### 🗄️ ARCHIVE (Completed Implementation Notes)

Create `archive/` structure and move completed work:

```bash
# Create archive structure
mkdir -p archive/implementations
mkdir -p archive/reviews
mkdir -p archive/README.md

# Move implementation summaries
mv CHUNKING_CODE_REVIEW.md archive/reviews/
mv CHUNKING_CODE_REVIEW_2.md archive/reviews/
mv CODE_REVIEW.md archive/reviews/
mv GREENFIELD_IMPLEMENTATION_COMPLETE.md archive/implementations/
mv GREENFIELD_SOLUTION_DEPLOYED.md archive/implementations/
mv IMPLEMENTATION_SUMMARY.md archive/implementations/
mv KEYBOARD_FIX_COMPLETE.md archive/implementations/
mv KEYBOARD_FIX_SUMMARY.md archive/implementations/
mv KEYBOARD_FOCUS_FIX.md archive/implementations/
mv KEYBOARD_FOCUS_FIX_FINAL.md archive/implementations/
mv MEMORY_IMPROVEMENTS.md archive/implementations/
mv NON_CHUNKING_CHANGES_SNAPSHOT.md archive/implementations/
mv PRIORITY_2_FIXES_APPLIED.md archive/implementations/
mv QUEST_CODE_REVIEW.md archive/reviews/
mv REVIEW_SUMMARY.md archive/reviews/
mv SAVEDVARIABLES_CODE_REVIEW.md archive/reviews/
mv SECTION_CHUNKING_IMPLEMENTATION.md archive/implementations/
mv WINDOW_REDESIGN_COMPLETE.md archive/implementations/
mv WINDOW_REDESIGN_TEST_PLAN.md archive/implementations/
```

**Files to archive** (19 files):

**Implementation Summaries** → `archive/implementations/`:
- `GREENFIELD_IMPLEMENTATION_COMPLETE.md`
- `GREENFIELD_SOLUTION_DEPLOYED.md`
- `IMPLEMENTATION_SUMMARY.md`
- `KEYBOARD_FIX_COMPLETE.md`
- `KEYBOARD_FIX_SUMMARY.md`
- `KEYBOARD_FOCUS_FIX.md`
- `KEYBOARD_FOCUS_FIX_FINAL.md`
- `MEMORY_IMPROVEMENTS.md`
- `NON_CHUNKING_CHANGES_SNAPSHOT.md`
- `PRIORITY_2_FIXES_APPLIED.md`
- `SECTION_CHUNKING_IMPLEMENTATION.md`
- `WINDOW_REDESIGN_COMPLETE.md`
- `WINDOW_REDESIGN_TEST_PLAN.md`

**Code Reviews** → `archive/reviews/`:
- `CHUNKING_CODE_REVIEW.md`
- `CHUNKING_CODE_REVIEW_2.md`
- `CODE_REVIEW.md`
- `QUEST_CODE_REVIEW.md`
- `REVIEW_SUMMARY.md`
- `SAVEDVARIABLES_CODE_REVIEW.md`

**Rationale**:
- These are completed work artifacts
- Historical value but not needed for active development
- Archiving preserves history without cluttering root
- If needed later, they're still accessible

---

### 🗑️ DELETE (No Value)

Review and delete if no valuable content:

```bash
# Check content first
cat example.md

# If it's just a scratch file or empty template:
rm example.md
```

**File to review**:
- `example.md` - Check if it's a template, example, or scratch file

---

## After Reorganization

### Root Directory (4 files)
```
CharacterMarkdown/
├── README.md                    # Project overview
├── CHANGELOG.md                 # Version history
├── LICENSE                      # License
└── RELEASE_CHECKLIST.md         # Release process
```

### docs/ Directory (19 files)
```
docs/
├── README.md                    # Documentation index
├── SUMMARY.md                   # mdBook table of contents
├── API_REFERENCE.md
├── ARCHITECTURE.md
├── DEVELOPMENT.md
├── DOCUMENTATION_AUDIT_GUIDE.md  # ← Moved from root
├── PUBLISHING.md
├── TASKFILE_ENHANCEMENTS.md      # ← Moved from root
├── TESTING_COMMAND.md
├── MEMORY_MANAGEMENT.md
├── CHAMPION_DIAGRAM_ENHANCEMENT.md
├── CHAMPION_PATHFINDER_USAGE.md
├── CHAMPION_POINTS_FLOW.md
├── CHUNKING_ALGORITHM.md
├── CRAFT_BAG_FIX.md
├── CRAFT_BAG_SYSTEM_PROMPT.md
├── MARKDOWN_WINDOW_CREATION.md
├── PVP_QUICK_REFERENCE.md
├── PVP_STATS_FEATURE.md
└── PVP_STATS_UPDATE_SUMMARY.md
```

### archive/ Directory (19 files)
```
archive/
├── README.md                    # Explains archived content
├── implementations/             # 13 files
│   ├── GREENFIELD_*.md
│   ├── KEYBOARD_*.md
│   ├── MEMORY_IMPROVEMENTS.md
│   ├── PRIORITY_2_FIXES_APPLIED.md
│   ├── SECTION_CHUNKING_IMPLEMENTATION.md
│   └── WINDOW_REDESIGN_*.md
└── reviews/                     # 6 files
    ├── CHUNKING_CODE_REVIEW*.md
    ├── CODE_REVIEW.md
    ├── QUEST_CODE_REVIEW.md
    ├── REVIEW_SUMMARY.md
    └── SAVEDVARIABLES_CODE_REVIEW.md
```

---

## Execution Steps

### Step 1: Create Archive Structure
```bash
mkdir -p archive/implementations
mkdir -p archive/reviews
cat > archive/README.md << 'EOF'
# Archive

Historical documentation for completed implementations and code reviews.

## Purpose

This directory contains documentation that was valuable during development but is no longer needed for active work:

- **implementations/**: Summaries of completed features and fixes
- **reviews/**: Code review notes and analysis

## When to Archive

Archive documentation when:
- Feature is complete and documented in main docs
- Code review is complete and issues resolved
- Historical value but not needed for daily development

## When to Reference

Reference archived docs when:
- Understanding historical decisions
- Troubleshooting related issues
- Learning from past implementation patterns

Last Updated: 2025-01-21
EOF
```

### Step 2: Move Files to docs/
```bash
# Move detailed guides to docs/
mv DOCUMENTATION_AUDIT_GUIDE.md docs/
mv TASKFILE_ENHANCEMENTS.md docs/

# Update references
grep -r "DOCUMENTATION_AUDIT_GUIDE.md" --include="*.md" . | cut -d: -f1 | sort -u
grep -r "TASKFILE_ENHANCEMENTS.md" --include="*.md" . | cut -d: -f1 | sort -u
# Update each reference to use new path
```

### Step 3: Archive Completed Work
```bash
# Archive implementations
mv GREENFIELD_*.md archive/implementations/
mv IMPLEMENTATION_SUMMARY.md archive/implementations/
mv KEYBOARD_*.md archive/implementations/
mv MEMORY_IMPROVEMENTS.md archive/implementations/
mv NON_CHUNKING_CHANGES_SNAPSHOT.md archive/implementations/
mv PRIORITY_2_FIXES_APPLIED.md archive/implementations/
mv SECTION_CHUNKING_IMPLEMENTATION.md archive/implementations/
mv WINDOW_REDESIGN_*.md archive/implementations/

# Archive reviews
mv CHUNKING_CODE_REVIEW*.md archive/reviews/
mv CODE_REVIEW.md archive/reviews/
mv QUEST_CODE_REVIEW.md archive/reviews/
mv REVIEW_SUMMARY.md archive/reviews/
mv SAVEDVARIABLES_CODE_REVIEW.md archive/reviews/
```

### Step 4: Update References
```bash
# Update any links to moved files
# Most archived files shouldn't be referenced, but check:
task docs:links
```

### Step 5: Review and Delete
```bash
# Check example.md content
cat example.md

# If no value, delete
rm example.md
```

### Step 6: Update SUMMARY.md
```bash
# Add new docs/ entries to docs/SUMMARY.md
# Add link to archive/README.md if valuable
```

### Step 7: Verify
```bash
# Run documentation audit
task docs:audit

# Should show major improvements:
# - 19 fewer orphaned files (archived)
# - Cleaner root directory
# - Better organization
```

---

## Impact on Documentation Health

### Before Reorganization
```
📄 Documentation Files: 57 files
🔗 Orphaned Files: 15 files
📊 Root directory: 25 .md files (cluttered)
📊 Health Score: 7/100
```

### After Reorganization
```
📄 Documentation Files: 38 files (-19 archived)
🔗 Orphaned Files: 0 files (✅ all archived)
📊 Root directory: 4 .md files (clean)
📊 docs/ directory: 19 files (organized)
📊 archive/ directory: 19 files (preserved)
📊 Health Score: 100/100 (✅)
```

### Benefits
1. **Clean root**: Only 4 essential files at root
2. **Organized docs**: All documentation in docs/
3. **Preserved history**: Archived work still accessible
4. **Better navigation**: Clear structure
5. **Improved discoverability**: Proper organization
6. **No lost work**: Everything archived, not deleted

---

## Files to Update After Move

### Update these files with new paths:

1. **RELEASE_CHECKLIST.md**
   - `DOCUMENTATION_AUDIT_GUIDE.md` → `docs/DOCUMENTATION_AUDIT_GUIDE.md`

2. **docs/SUMMARY.md** (mdBook TOC)
   - Add entries for moved files

3. **README.md** (if it links to moved files)
   - Update any documentation links

4. **.cursorrules** (if it references paths)
   - Check for any path references

---

## Validation Checklist

After reorganization:

- [ ] Root directory has only 4 .md files
- [ ] All detailed guides in docs/
- [ ] All completed work in archive/
- [ ] archive/README.md explains purpose
- [ ] `task docs:audit` shows 0 orphans
- [ ] `task docs:links` shows no broken links
- [ ] docs/SUMMARY.md updated
- [ ] All references updated
- [ ] Health score > 90

---

## Automation Script

Want me to create a bash script to automate this? Would include:
- All mkdir commands
- All mv commands
- Automatic reference updating
- Verification steps

---

**Status**: 📋 Ready to execute  
**Estimated time**: 15 minutes  
**Risk**: Low (all files preserved in archive)  
**Benefit**: Clean, professional structure

**Next**: Run these commands or use Cursor AI with the documentation consolidation prompt.

