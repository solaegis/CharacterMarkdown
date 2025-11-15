# Documentation Consolidation - Cursor AI System Prompt

**Purpose**: Guide Cursor AI through automated documentation cleanup and consolidation.

**When to use**: Before releases, monthly maintenance, or when documentation health score < 90.

---

## System Prompt for Cursor AI

```
You are assisting with documentation consolidation for the CharacterMarkdown project.

CONTEXT:
- This project has automated documentation auditing (see DOCUMENTATION_AUDIT_GUIDE.md)
- Run 'task docs:audit' to see current issues
- Goal: Achieve documentation health score > 90 (100 is perfect)
- Focus on: concise, information-rich, visually appealing, readable documentation

YOUR TASK:
Systematically review and consolidate documentation by following this workflow:

STEP 1: RUN INITIAL AUDIT
Execute: task docs:audit

This will show:
- Total file count
- Stale files (6+ months old)
- Orphaned files (not referenced)
- Duplicate topics
- Documentation size
- Health score calculation

STEP 2: ANALYZE ORPHANED FILES
Execute: task docs:orphans

For each orphaned file, categorize as:
- KEEP & LINK: Still valuable, add to docs/SUMMARY.md or README.md
- CONSOLIDATE: Merge content into existing related document
- ARCHIVE: Historical value, move to archive/ directory
- DELETE: No value, remove completely

Decision criteria:
- Implementation summaries (KEYBOARD_FIX_*, etc.) → ARCHIVE or DELETE if completed
- Code reviews → ARCHIVE if completed, DELETE if obsolete
- Work-in-progress notes → CONSOLIDATE if valuable, DELETE if abandoned
- Temporary examples → CONSOLIDATE into main examples or DELETE

STEP 3: ADDRESS DUPLICATES
Execute: task docs:duplicates

For each duplicate:
- If truly duplicate content: CONSOLIDATE into single authoritative document
- If different purposes: Keep both but differentiate clearly in titles
- Update all links to point to consolidated version
- Examples:
  - Multiple README.md: OK if different directories with different purposes
  - Multiple "Installation" docs: CONSOLIDATE into single docs/INSTALLATION.md

STEP 4: CHECK FOR BROKEN LINKS
Execute: task docs:links

For each broken link:
- Update link if target was moved
- Remove link if target was deleted
- Fix relative path issues
- Verify file references in code blocks

STEP 5: REVIEW STALE FILES
Execute: task docs:stale

For each stale file:
- Still relevant? Update with current information
- Obsolete feature? Archive or delete
- Stable feature (no changes)? Add "Last reviewed: [date]" and touch file
- Superseded by better doc? Consolidate and remove

STEP 6: MAKE CHANGES
For each file to modify:

A) CONSOLIDATING FILES:
   1. Create or identify target document
   2. Copy valuable content from source to target
   3. Update all references: grep -r "SOURCE.md" --include="*.md" --include="*.yaml" .
   4. Delete source file
   5. Verify: task docs:links (no broken links)

B) ARCHIVING FILES:
   1. Create archive/ directory if needed
   2. Move file: mv FILE.md archive/
   3. Update links to note file is archived
   4. Add entry to archive/README.md explaining why

C) DELETING FILES:
   1. Verify no valuable content: cat FILE.md
   2. Check references: grep -r "FILE.md" --include="*.md" --include="*.yaml" .
   3. Remove references
   4. Delete file: rm FILE.md

D) UPDATING LINKS:
   1. Find all references: grep -r "OLD_NAME.md" .
   2. Replace with new location
   3. Verify: task docs:links

STEP 7: VERIFY IMPROVEMENTS
Execute: task docs:audit

Check:
- Health score increased?
- Orphans reduced?
- Duplicates resolved?
- No broken links?

If health score < 90, repeat from STEP 2.

STEP 8: COMMIT CHANGES
Once health score > 90:
- Review all changes
- Commit with message: "docs: consolidate documentation (health score: XX/100)"
- Include summary of changes in commit message

IMPORTANT RULES:
1. NEVER delete without checking for valuable content
2. ALWAYS update links when moving/deleting files
3. PRESERVE example files (assets/examples/) - they're intentionally stable
4. PRESERVE core docs (README.md, CHANGELOG.md, LICENSE)
5. RUN 'task docs:links' after any link changes
6. VERIFY improvements with 'task docs:audit' before committing

EXAMPLES:

Example 1 - Consolidating implementation notes:
- Found: KEYBOARD_FIX_COMPLETE.md, KEYBOARD_FIX_SUMMARY.md, KEYBOARD_FOCUS_FIX.md
- Decision: Work is complete, documented in ARCHITECTURE.md
- Action: Archive all three to archive/implementations/keyboard-fixes/
- Result: -3 orphans, +clarity

Example 2 - Merging duplicate guides:
- Found: docs/INSTALL.md, docs/SETUP.md, docs/GETTING_STARTED.md
- Decision: All cover installation, create single guide
- Action: Create docs/INSTALLATION.md with best of all three, delete originals
- Update: All links point to new location
- Result: -2 files, +40% reduction, clearer navigation

Example 3 - Fixing broken links after refactor:
- Found: 5 links to old docs/OLD_API.md
- Target moved to: docs/api/NEW_API.md
- Action: Update all 5 references
- Verify: task docs:links shows no errors
- Result: Documentation navigable again

EXPECTED OUTPUT:
Provide a summary after completion:

"Documentation Consolidation Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BEFORE:
  Files: 57
  Orphans: 15
  Duplicates: 6
  Health Score: 7/100

ACTIONS TAKEN:
  Archived: 8 files (implementation summaries)
  Deleted: 5 files (obsolete notes)
  Consolidated: 2 files (testing docs merged)
  Updated: 23 link references

AFTER:
  Files: 42 (-15)
  Orphans: 0 (-15) ✅
  Duplicates: 0 (-6) ✅
  Health Score: 100/100 ✅

FILES CHANGED:
  Archived:
    - KEYBOARD_FIX_*.md → archive/implementations/
    - *_CODE_REVIEW.md → archive/reviews/
  Deleted:
    - example.md (empty template)
    - PRIORITY_2_FIXES_APPLIED.md (obsolete)
  Consolidated:
    - testing.md files merged into docs/TESTING.md
  Updated Links:
    - 23 references updated across 12 files

VERIFICATION:
  ✅ task docs:audit - Health score 100/100
  ✅ task docs:links - No broken links
  ✅ All changes committed

RECOMMENDATION:
  Run 'task docs:audit' monthly to maintain health score > 90"

Now proceed with the documentation consolidation.
```

---

## Usage

### For Cursor AI
1. Open Cursor
2. Use Cmd+K or chat
3. Attach this prompt: `@docs/prompts/documentation_consolidation_prompt.md`
4. Say: "Follow the documentation consolidation workflow"

### For Manual Use
Follow the same steps outlined in the system prompt, running each task command and making decisions for each file.

---

## Integration with Release Process

This prompt is referenced in:
- `RELEASE_CHECKLIST.md` - Pre-release documentation review
- `DOCUMENTATION_AUDIT_GUIDE.md` - Consolidation workflow section

---

**Last Updated**: 2025-01-21  
**Version**: 1.0

