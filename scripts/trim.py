#!/usr/bin/env python3
"""
Trim unnecessary newlines in markdown and tonl files without breaking syntax.

This script:
- Reduces excessive consecutive blank lines (3+ → 2)
- Removes trailing whitespace on lines
- Ensures file ends with single newline
- Removes chunk markers from CharacterMarkdown output
- Preserves code blocks, HTML blocks, and tables
"""

import re
import sys
from pathlib import Path


def is_code_fence(line: str) -> bool:
    """Check if line is a code fence (``` or ~~~)."""
    stripped = line.strip()
    return stripped.startswith('```') or stripped.startswith('~~~')


def is_html_tag(line: str) -> bool:
    """Check if line starts with HTML tag."""
    stripped = line.strip()
    return bool(re.match(r'^<[a-zA-Z/]', stripped))


def is_table_line(line: str) -> bool:
    """Check if line is part of a markdown table."""
    stripped = line.strip()
    # Table rows start with |
    # Table separator lines have | and - and :
    return (stripped.startswith('|') or 
            (bool(re.match(r'^[\|\-\s:]+$', stripped)) and '|' in stripped and '-' in stripped))


def is_chunk_marker(line: str) -> bool:
    """Check if line is a chunk marker comment from CharacterMarkdown."""
    stripped = line.strip()
    return bool(re.match(r'^<!--\s*Chunk\s+\d+.*-->$', stripped))


def is_build_notes_header(line: str) -> bool:
    """Check if line is the Build Notes section header."""
    stripped = line.strip()
    return stripped == '## 📝 Build Notes'


def is_section_separator(line: str) -> bool:
    """Check if line is a section separator (horizontal rule)."""
    stripped = line.strip()
    return stripped == '---'


def trim_mermaid_blocks(content: str) -> str:
    """
    Trim excessive blank lines inside mermaid code blocks.
    
    Mermaid blocks can have padding newlines from chunking that should be reduced.
    This function reduces 3+ consecutive blank lines to 2 inside mermaid blocks only.
    """
    lines = content.splitlines()
    result = []
    
    in_mermaid = False
    consecutive_blanks = 0
    
    for line in lines:
        stripped = line.strip()
        
        # Check for mermaid block start
        if stripped.startswith('```mermaid'):
            in_mermaid = True
            consecutive_blanks = 0
            result.append(line)
            continue
        
        # Check for code block end (while in mermaid)
        if in_mermaid and stripped == '```':
            in_mermaid = False
            # Remove trailing blanks before closing fence
            while result and result[-1].strip() == '':
                result.pop()
            result.append(line)
            consecutive_blanks = 0
            continue
        
        # Inside mermaid block: limit consecutive blanks
        if in_mermaid:
            if stripped == '':
                consecutive_blanks += 1
                # Allow max 2 consecutive blank lines
                if consecutive_blanks <= 2:
                    result.append(line)
            else:
                consecutive_blanks = 0
                result.append(line)
        else:
            # Outside mermaid: pass through unchanged
            result.append(line)
    
    return '\n'.join(result)


def trim_markdown(content: str) -> str:
    """
    Trim unnecessary newlines from markdown content.
    
    Rules:
    - Reduce 3+ consecutive blank lines to 2
    - Remove trailing whitespace on lines
    - Preserve code blocks (between ```)
    - Preserve HTML block structure
    - Preserve table spacing
    - Remove chunk markers
    - Ensure single newline at EOF
    - Preserve Build Notes section exactly as-is
    - Trim excessive blank lines inside mermaid blocks
    """
    # Pre-pass: trim mermaid block blank lines
    content = trim_mermaid_blocks(content)
    
    lines = content.splitlines()
    result = []
    
    in_code_block = False
    in_html_block = False
    in_build_notes = False
    consecutive_blanks = 0
    
    for i, line in enumerate(lines):
        # Check for Build Notes section start
        if is_build_notes_header(line):
            in_build_notes = True
            result.append(line.rstrip())
            consecutive_blanks = 0
            continue
            
        # Inside Build Notes: preserve everything exactly as-is until separator
        if in_build_notes:
            if is_section_separator(line):
                in_build_notes = False
                result.append(line.rstrip())
                consecutive_blanks = 0
            else:
                # Preserve line exactly (including trailing spaces)
                result.append(line)
            continue

        # Remove trailing whitespace
        line = line.rstrip()
        
        # Skip chunk marker lines entirely
        if is_chunk_marker(line):
            continue
        
        # Track code block state
        if is_code_fence(line):
            in_code_block = not in_code_block
            result.append(line)
            consecutive_blanks = 0
            continue
        
        # Inside code block: preserve everything as-is
        if in_code_block:
            result.append(line)
            continue
        
        # Track HTML block state
        if is_html_tag(line):
            # Check if it's an opening or closing tag
            if not line.strip().startswith('</'):
                in_html_block = True
            else:
                in_html_block = False
            result.append(line)
            consecutive_blanks = 0
            continue
        
        # Handle blank lines
        if not line:
            consecutive_blanks += 1
            
            # Allow max 2 consecutive blank lines (creates visual separation)
            # But allow up to 3 if we're transitioning between sections
            # (heading, list, table, HTML block)
            max_blanks = 2
            
            # Check if previous line was special (heading, html, table)
            if result:
                prev = result[-1].strip()
                if (prev.startswith('#') or 
                    is_html_tag(result[-1]) or 
                    is_table_line(result[-1]) or
                    prev.startswith('-') or
                    prev.startswith('*') or
                    prev.startswith('>')):
                    max_blanks = 2
            
            # Only add blank line if under limit
            if consecutive_blanks <= max_blanks:
                result.append(line)
        else:
            # Non-blank line
            consecutive_blanks = 0
            result.append(line)
    
    # Remove excessive trailing newlines (keep at most 2 blank lines at end)
    while len(result) > 0 and result[-1] == '' and result[-2:].count('') > 2:
        result.pop()
    
    # Ensure file ends with single newline
    if result and result[-1] != '':
        result.append('')
    
    return '\n'.join(result)


def process_file(filepath: Path, dry_run: bool = False) -> tuple[bool, int]:
    """
    Process a markdown file.
    
    Returns:
        tuple: (changed, lines_removed)
    """
    try:
        # Read file
        content = filepath.read_text(encoding='utf-8')
        original_lines = len(content.splitlines())
        
        # Trim markdown
        trimmed = trim_markdown(content)
        trimmed_lines = len(trimmed.splitlines())
        
        # Check if changed
        changed = content != trimmed
        lines_removed = original_lines - trimmed_lines
        
        if changed:
            if dry_run:
                print(f"  Would trim: {filepath.name} ({lines_removed} lines removed)")
            else:
                filepath.write_text(trimmed, encoding='utf-8')
                print(f"  ✓ Trimmed: {filepath.name} ({lines_removed} lines removed)")
        else:
            if not dry_run:
                print(f"  ○ No change: {filepath.name}")
        
        return changed, lines_removed
    
    except Exception as e:
        print(f"  ✗ Error processing {filepath.name}: {e}", file=sys.stderr)
        return False, 0


def main():
    """Main entry point."""
    import argparse
    
    parser = argparse.ArgumentParser(
        description='Trim unnecessary newlines in markdown and tonl files'
    )
    parser.add_argument(
        'files',
        nargs='+',
        type=Path,
        help='Files to process'
    )
    parser.add_argument(
        '--dry-run',
        action='store_true',
        help='Show what would be changed without modifying files'
    )
    
    args = parser.parse_args()
    
    # Process files
    total_files = 0
    total_changed = 0
    total_lines_removed = 0
    
    print("📝 Trimming files...")
    print()
    
    for filepath in args.files:
        if not filepath.exists():
            print(f"  ✗ Not found: {filepath}", file=sys.stderr)
            continue
        
        if not filepath.is_file():
            print(f"  ✗ Not a file: {filepath}", file=sys.stderr)
            continue
        
        if filepath.suffix.lower() not in ['.md', '.markdown', '.tonl']:
            print(f"  ✗ Not a supported file type: {filepath}", file=sys.stderr)
            continue
        
        total_files += 1
        changed, lines_removed = process_file(filepath, args.dry_run)
        
        if changed:
            total_changed += 1
            total_lines_removed += lines_removed
    
    # Summary
    print()
    print("━" * 60)
    if args.dry_run:
        print(f"Dry run: {total_changed}/{total_files} files would be changed")
        print(f"Total lines that would be removed: {total_lines_removed}")
    else:
        print(f"✅ Processed {total_files} files")
        print(f"   Changed: {total_changed}")
        print(f"   Total lines removed: {total_lines_removed}")


if __name__ == '__main__':
    main()

