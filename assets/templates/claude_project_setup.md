# Setting Up Claude Projects with CharacterMarkdown

This guide explains how to configure Claude AI projects to effectively analyze and optimize ESO characters using CharacterMarkdown exports.

## Overview

CharacterMarkdown generates comprehensive character data in markdown format. When combined with Claude AI and the provided templates, you can get:
- **Build optimization** recommendations
- **Gear upgrade** paths
- **Skill rotation** analysis
- **CP distribution** optimization
- **Stat breakpoint** analysis
- **Progression roadmaps**

## Step-by-Step Setup

### Step 1: Choose Your System Prompt

You have two options for the system prompt:

#### Option A: General ESO Assistant (Recommended for beginners)
- **File**: `claude_system_prompt.md`
- **Best for**: General character analysis, build help, optimization questions
- **Use when**: You want Claude to be helpful with all aspects of ESO

#### Option B: Optimization Specialist (Recommended for advanced users)
- **File**: `optimization_assistant.md`
- **Best for**: Deep optimization, min-max analysis, meta builds
- **Use when**: You want Claude to focus specifically on optimization

**How to add:**
1. Open your Claude project settings
2. Find "System Prompt" or "Instructions" section
3. Copy the entire contents of your chosen file
4. Paste into the system prompt field
5. Save the project

### Step 2: Create Your Character Profile (Optional but Recommended)

The character profile template helps Claude understand your goals and current state:

1. **Copy the template:**
   - Open `character_profile_template.md`
   - Copy the entire template

2. **Fill it out:**
   - Add your character's basic information
   - Document current gear, skills, CP
   - List your goals and priorities
   - Note any constraints (no trial access, limited gold, etc.)

3. **Save it:**
   - Save as `[character_name]_profile.md` in your Claude project
   - Or keep it in a notes/document management system

4. **Upload when needed:**
   - Upload the profile along with markdown exports
   - Claude will use both for comprehensive analysis

### Step 3: Generate Character Markdown

In ESO, generate your character markdown:

```
/markdown github
```

**Important:** Use **GitHub format** (default) for Claude analysis. Other formats are too compact or lack structure.

### Step 4: Upload and Analyze

1. **Copy the markdown:**
   - From the CharacterMarkdown window, click "Select All"
   - Copy (Ctrl+C / Cmd+C)

2. **Paste into Claude:**
   - Start a new conversation or continue existing one
   - Paste the markdown
   - Optionally upload your character profile if you created one

3. **Ask for analysis:**
   - "Analyze this character and suggest the top 5 improvements"
   - "Optimize this build for veteran trial DPS"
   - "What gear should I farm next?"
   - "Review my CP distribution and suggest changes"

## Advanced Workflows

### Workflow 1: Complete Build Optimization

**Goal:** Get a complete optimized build package

**Steps:**
1. Generate markdown: `/markdown github`
2. Fill out character profile with goals
3. Upload both to Claude
4. Ask: "Create a complete optimized build for [playstyle]. Include gear sets, traits, enchants, skills, CP distribution, and rotation."
5. Save Claude's response as your build guide

### Workflow 2: Playstyle Strategy Development

**Goal:** Document and optimize a specific playstyle

**Steps:**
1. Generate markdown: `/markdown github`
2. Fill out `playstyle_strategy.md` template
3. Upload both to Claude
4. Ask: "Review this playstyle strategy and optimize it. Update the template with your recommendations."
5. Use the updated strategy as your build guide

### Workflow 3: Progression Tracking

**Goal:** Track improvements over time

**Steps:**
1. Generate markdown: `/markdown github`
2. Upload to Claude with previous analysis
3. Ask: "Compare this character to the previous analysis. What improvements have been made? What's next?"
4. Update your character profile with changes
5. Repeat monthly or after major changes

### Workflow 4: Patch Impact Analysis

**Goal:** Understand how patches affect your build

**Steps:**
1. Generate markdown: `/markdown github`
2. Upload to Claude with patch notes
3. Ask: "How do these patch changes affect my character? What adjustments should I make?"
4. Get prioritized list of changes needed

## Best Practices

### 1. Be Specific in Requests

**Bad:**
- "Analyze this character"

**Good:**
- "Analyze this character for veteran trial DPS optimization. Focus on gear upgrades and CP distribution."
- "What are the top 3 improvements I can make with my current resources?"
- "Compare this build to the current meta for magicka sorcerer DPS."

### 2. Provide Context

Always mention:
- **Content type**: Trials, dungeons, PvP, solo, etc.
- **Difficulty**: Normal, veteran, hardmode
- **Constraints**: No trial access, limited gold, specific preferences
- **Goals**: DPS target, survivability needs, etc.

### 3. Use Structured Data

- Character profile provides goals and constraints
- Playstyle strategy provides detailed build documentation
- Markdown export provides current state
- Upload all relevant documents together

### 4. Iterate and Refine

- Start with general analysis
- Ask follow-up questions
- Request specific optimizations
- Compare alternatives
- Get implementation steps

### 5. Save Important Responses

- Save build recommendations
- Document changes made
- Track performance improvements
- Build a knowledge base over time

## Example Prompts

### Initial Analysis
```
Analyze this character markdown and provide:
1. Current build assessment
2. Top 5 improvement priorities
3. Quick wins (easy changes with high impact)
4. Long-term optimization path
```

### Gear Optimization
```
Based on this character markdown, recommend:
1. Best-in-slot gear sets for [playstyle]
2. Alternative sets if I don't have access to trials
3. Upgrade priority (what to gold first)
4. Trait and enchantment optimization
```

### CP Optimization
```
Review my champion point distribution and:
1. Identify any wasted points
2. Recommend optimal slottables for [playstyle]
3. Suggest passive point allocations
4. Explain the reasoning for each recommendation
```

### Skill Rotation Analysis
```
Analyze my skill bars and:
1. Identify rotation issues
2. Suggest skill swaps for better DPS/survivability
3. Recommend morph choices
4. Provide a rotation priority list
```

### Progression Planning
```
Create a progression roadmap for this character:
1. Phase 1: Immediate improvements (this week)
2. Phase 2: Short-term goals (this month)
3. Phase 3: Long-term optimization (next 3 months)
Include farming priorities, gold requirements, and expected performance gains.
```

## Troubleshooting

### Claude Doesn't Understand ESO Terms

**Solution:** Make sure you've added the system prompt. The system prompts include ESO terminology and context.

### Recommendations Seem Generic

**Solution:** 
- Be more specific in your requests
- Upload character profile with goals
- Mention specific content or constraints
- Ask for alternatives and trade-offs

### Claude Suggests Sets You Can't Get

**Solution:**
- Mention your constraints upfront: "I don't have trial access"
- Ask for alternatives: "What are dungeon/overland alternatives?"
- Request budget options: "What's a good starter set?"

### Analysis Doesn't Match Current Meta

**Solution:**
- Mention current patch: "This is for Update 41"
- Ask about meta changes: "Is this still optimal for current patch?"
- Request patch-aware analysis: "Review this considering recent balance changes"

## Integration Tips

### With Other Tools

- **CMX (Combat Metrics)**: Upload parse data along with markdown
- **UESP**: Claude can reference UESP links in markdown
- **Build Sites**: Compare Claude's recommendations with build sites
- **Guild Resources**: Combine with guild build guides

### With CharacterMarkdown Settings

- **Full Documentation Profile**: Use for comprehensive analysis
- **PvE Build Profile**: Use for trial/dungeon optimization
- **PvP Build Profile**: Use for PvP-specific analysis
- **Custom Profiles**: Create profiles for specific use cases

## Maintenance

### Keep Templates Updated

- Review templates after major ESO patches
- Update system prompts if meta changes significantly
- Adjust character profile template as needed

### Refresh Character Data

- Regenerate markdown after major changes
- Update character profile when goals change
- Re-analyze after implementing recommendations

### Track Performance

- Save Claude's recommendations
- Document changes made
- Track parse improvements
- Compare before/after stats

## File Organization

Recommended structure for your Claude project:

```
claude-project/
├── system-prompt.md (claude_system_prompt.md or optimization_assistant.md)
├── characters/
│   ├── character1_profile.md
│   ├── character1_markdown_2025-01-15.md
│   ├── character1_analysis_2025-01-15.md
│   └── character1_build_guide.md
└── playstyles/
    ├── playstyle1_strategy.md
    └── playstyle2_strategy.md
```

## Next Steps

1. **Set up your Claude project** with a system prompt
2. **Generate your first markdown** export
3. **Try a simple analysis** request
4. **Create a character profile** for deeper analysis
5. **Develop a playstyle strategy** for your main build
6. **Iterate and improve** based on Claude's recommendations

## Support

- **CharacterMarkdown Issues**: See main README.md
- **Claude Usage**: Experiment and iterate
- **ESO Optimization**: Consult ESO community resources
- **Template Questions**: Modify templates to fit your needs

Remember: These templates are starting points. Customize them to match your workflow and preferences!









