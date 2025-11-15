# CharacterMarkdown Templates for Claude Projects

This directory contains templates and system prompts designed to help you use CharacterMarkdown output effectively with Claude AI for character optimization and build analysis.

## Purpose

These templates help you:
- **Ground Claude AI** with ESO knowledge and optimization principles
- **Structure character data** for effective analysis
- **Get actionable advice** based on your character markdown exports
- **Track improvements** over time with structured profiles

## Files

### Core Templates

- **`claude_system_prompt.md`** - System prompt to add to Claude projects
  - Defines Claude as an ESO optimization expert
  - Sets output standards and analysis frameworks
  - Provides meta tracking and interaction guidelines
  - Use this as your Claude project's system prompt

- **`character_profile_template.md`** - Template for manual character profiles
  - Structured format for documenting your character
  - Includes gear, skills, CP, stats, goals, and progression tracking
  - Use this to create detailed character profiles for Claude to analyze

- **`optimization_assistant.md`** - Enhanced system prompt for optimization focus
  - More detailed optimization philosophy
  - Build analysis framework
  - Output standards for gear tables, skill bars, CP distributions
  - Use this if you want Claude to focus specifically on optimization

- **`playstyle_strategy.md`** - Template for documenting playstyle strategies
  - Comprehensive playstyle documentation format
  - Stat architecture, gear strategy, rotation mechanics
  - Gap analysis and progression roadmaps
  - Use this to document specific playstyles (e.g., "Magicka Trial DPS")

## Quick Start

### Option 1: Basic Setup (Recommended)

1. **Add system prompt to Claude project:**
   - Open your Claude project settings
   - Add the contents of `claude_system_prompt.md` as the system prompt
   - Save the project

2. **Upload character markdown:**
   - Generate markdown in-game: `/markdown github`
   - Copy the output
   - Paste it into Claude chat
   - Ask for analysis: "Analyze this character and suggest improvements"

### Option 2: Advanced Setup

1. **Add optimization assistant prompt:**
   - Use `optimization_assistant.md` as system prompt instead
   - More detailed optimization focus

2. **Create character profile:**
   - Copy `character_profile_template.md`
   - Fill it out with your character details
   - Upload both the markdown export AND the filled template
   - Claude will have structured data + raw export

3. **Document playstyles:**
   - Use `playstyle_strategy.md` to document specific builds
   - Upload with character markdown for comprehensive analysis

## Workflow Examples

### Example 1: Quick Analysis

```
1. Generate markdown: /markdown github
2. Paste into Claude with system prompt active
3. Ask: "What are the top 3 improvements I should make?"
4. Get prioritized recommendations
```

### Example 2: Build Optimization

```
1. Generate markdown: /markdown github
2. Fill out character_profile_template.md with goals
3. Upload both to Claude
4. Ask: "Optimize this character for veteran trial DPS"
5. Get complete build package (gear, skills, CP, rotation)
```

### Example 3: Playstyle Development

```
1. Generate markdown: /markdown github
2. Document playstyle using playstyle_strategy.md
3. Upload both to Claude
4. Ask: "Review this playstyle strategy and suggest improvements"
5. Get detailed analysis with stat targets, rotation adjustments, etc.
```

## Best Practices

### 1. Keep Markdown Updated
- Regenerate markdown after major changes (gear, CP, skills)
- Update character profile when goals change
- Refresh playstyle strategies after patches

### 2. Be Specific in Requests
- Instead of "analyze this", ask "analyze for PvE DPS optimization"
- Specify content type: "veteran trials", "solo arenas", "PvP"
- Mention constraints: "no trial access", "limited gold", etc.

### 3. Use Structured Data
- Character profile template provides structure Claude can parse
- Playstyle strategy template helps Claude understand your goals
- Markdown export provides current state

### 4. Track Progress
- Save Claude's recommendations
- Update character profile with changes made
- Re-analyze after implementing suggestions
- Compare before/after performance

## Integration with CharacterMarkdown

These templates are designed to work seamlessly with CharacterMarkdown output:

- **GitHub format** (default) - Best for Claude analysis (rich tables, links)
- **VS Code format** - Alternative if GitHub format has issues
- **Discord format** - Too compact for detailed analysis
- **Quick format** - Not suitable for analysis

## Customization

Feel free to customize these templates:
- Add your own sections to character profile
- Modify playstyle strategy template for your needs
- Adjust system prompts to match your preferences
- Create additional templates for specific use cases

## File Naming Convention

All markdown files in this directory use underscores (`_`) instead of spaces or hyphens for consistency and compatibility across systems.

## Support

For questions about:
- **CharacterMarkdown addon**: See main README.md
- **Using templates with Claude**: Experiment and iterate
- **ESO optimization**: Consult ESO community resources








