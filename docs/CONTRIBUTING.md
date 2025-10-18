# Contributing to CharacterMarkdown

Thank you for considering contributing to CharacterMarkdown! This document provides guidelines and instructions for contributing.

---

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Getting Started](#getting-started)
- [Development Process](#development-process)
- [Pull Request Process](#pull-request-process)
- [Style Guidelines](#style-guidelines)
- [Community](#community)

---

## Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inclusive environment for everyone, regardless of:
- Experience level
- Gender identity and expression
- Sexual orientation
- Disability
- Personal appearance
- Body size
- Race or ethnicity
- Age
- Religion or lack thereof

### Our Standards

**Positive behaviors:**
- Using welcoming and inclusive language
- Being respectful of differing viewpoints
- Gracefully accepting constructive criticism
- Focusing on what is best for the community
- Showing empathy towards others

**Unacceptable behaviors:**
- Trolling, insulting/derogatory comments, and personal attacks
- Public or private harassment
- Publishing others' private information without permission
- Other conduct which could reasonably be considered inappropriate

### Enforcement

Project maintainers are responsible for clarifying standards and will take appropriate corrective action in response to unacceptable behavior.

---

## How Can I Contribute?

### Reporting Bugs

**Before submitting a bug report:**
1. Check the [existing issues](https://github.com/YOUR_USERNAME/CharacterMarkdown/issues)
2. Test on the latest version
3. Try disabling other addons to isolate the issue

**Bug Report Template:**

```markdown
**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '...'
3. See error

**Expected behavior**
What you expected to happen.

**Screenshots**
If applicable, add screenshots or error messages.

**Environment:**
- ESO Version: [e.g., Update 46, Gold Road]
- Addon Version: [e.g., 2.1.0]
- OS: [e.g., macOS 14.2, Windows 11]
- Other addons installed: [list relevant addons]

**Additional context**
Any other information that might be helpful.
```

### Suggesting Enhancements

**Before submitting a feature request:**
1. Check if it's already been suggested
2. Consider if it fits the addon's scope
3. Think about how it would benefit other users

**Feature Request Template:**

```markdown
**Is your feature request related to a problem?**
A clear description of the problem. Ex. "I'm always frustrated when..."

**Describe the solution you'd like**
A clear and concise description of what you want to happen.

**Describe alternatives you've considered**
Other solutions or features you've considered.

**Additional context**
Mockups, examples, or any other relevant information.
```

### Code Contributions

We welcome code contributions! Areas where help is especially appreciated:

- **Bug fixes**
- **New data collectors** (e.g., housing, antiquities)
- **Export formats** (e.g., HTML, JSON)
- **UI improvements**
- **Documentation**
- **Tests**

---

## Getting Started

### Prerequisites

1. **ESO Account & Game Client**
2. **Git**
3. **Text Editor** (VS Code recommended)
4. **Basic Lua Knowledge**

See [DEVELOPMENT.md](DEVELOPMENT.md) for detailed setup instructions.

### Fork & Clone

```bash
# Fork on GitHub (click Fork button)

# Clone your fork
git clone https://github.com/YOUR_USERNAME/CharacterMarkdown.git
cd CharacterMarkdown

# Add upstream remote
git remote add upstream https://github.com/ORIGINAL_OWNER/CharacterMarkdown.git
```

### Set Up Development Environment

```bash
# Symlink to ESO addons folder
ln -s ~/git/CharacterMarkdown ~/Documents/Elder\ Scrolls\ Online/live/AddOns/CharacterMarkdown

# Install development tools (optional)
pip install pre-commit
pre-commit install
```

---

## Development Process

### 1. Create a Branch

```bash
git checkout -b feature/my-new-feature
```

**Branch naming:**
- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation
- `refactor/` - Code restructuring
- `test/` - Adding tests

### 2. Make Changes

- Follow the [Style Guidelines](#style-guidelines)
- Test your changes in-game
- Add comments explaining complex logic
- Update documentation if needed

### 3. Test

```bash
# Manual testing in ESO
/reloadui
/markdown github

# Run linter (if configured)
luacheck src/
```

### 4. Commit

```bash
git add .
git commit -m "feat: add new collector for mount training"
```

**Commit message format:**
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Formatting
- `refactor`: Code restructure
- `test`: Adding tests
- `chore`: Maintenance

**Example:**
```
feat(collectors): add mount training data collection

- Collect speed, stamina, and capacity training levels
- Add to character overview section
- Include UESP link for mount training guide

Closes #42
```

### 5. Push

```bash
git push origin feature/my-new-feature
```

---

## Pull Request Process

### Before Submitting

**Checklist:**
- [ ] Code follows style guidelines
- [ ] Self-review of code completed
- [ ] Comments added for complex logic
- [ ] Documentation updated (if applicable)
- [ ] No new warnings or errors introduced
- [ ] Tested in-game (at least 2 different characters)
- [ ] CHANGELOG.md updated (if version bump)

### Submitting

1. **Go to GitHub** and create a Pull Request
2. **Fill out the PR template:**

```markdown
## Description
[Describe what this PR does]

## Type of Change
- [ ] Bug fix (non-breaking change fixing an issue)
- [ ] New feature (non-breaking change adding functionality)
- [ ] Breaking change (fix or feature causing existing functionality to break)
- [ ] Documentation update

## Testing
[Describe how you tested this]

## Screenshots (if applicable)
[Add screenshots demonstrating the change]

## Checklist
- [ ] My code follows the style guidelines
- [ ] I have performed a self-review
- [ ] I have commented complex code
- [ ] I have updated documentation
- [ ] My changes generate no new warnings
- [ ] I have tested in-game

## Related Issues
Closes #[issue number]
```

3. **Wait for CI checks** (if configured)
4. **Address review feedback** (if any)
5. **Merge** (done by maintainers)

### Review Process

- Reviews typically completed within 3-7 days
- Feedback may be requested for clarification
- Changes may be suggested to improve code quality
- All PRs require at least one approval before merging

---

## Style Guidelines

### Lua Code Style

**Indentation:**
- Use 4 spaces (no tabs)

**Naming Conventions:**
```lua
-- Variables: camelCase
local playerName = "Example"

-- Constants: UPPER_SNAKE_CASE
local MAX_LEVEL = 50

-- Functions: PascalCase (public), camelCase (private)
function CM.GenerateMarkdown(format)
    local function formatSection()
        -- ...
    end
end

-- Namespaces: PascalCase
CharacterMarkdown = CharacterMarkdown or {}
```

**Comments:**
```lua
-- Single-line for brief explanations

--[[
    Multi-line for:
    - Function documentation
    - Complex logic
    - TODOs
]]

--- LuaDoc-style for public APIs
--- @param format string The output format
--- @return string Generated markdown
function CM.GenerateMarkdown(format)
    -- Implementation
end
```

**Error Handling:**
```lua
-- Always use pcall for ESO API calls
local success, result = pcall(function()
    return GetPlayerStat(STAT_HEALTH_MAX)
end)

if not success then
    CM.Log("ERROR: " .. tostring(result))
    return defaultValue
end
```

### Documentation Style

**Markdown:**
- Use ATX-style headers (`#`, `##`, `###`)
- Include table of contents for long documents
- Use code fences with language tags
- Add blank lines around headers and code blocks

**Comments in Code:**
- Explain "why", not "what"
- Document gotchas and workarounds
- Reference ESO API version if relevant

### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Good examples:**
```
feat(collectors): add antiquities progress tracking
fix(markdown): escape special characters in item names
docs(api): document EditBox clipboard limitations
refactor(ui): extract window creation logic
```

**Bad examples:**
```
fixed bug
update
changes
WIP
```

---

## Community

### Communication Channels

- **GitHub Issues:** Bug reports, feature requests
- **GitHub Discussions:** General questions, ideas
- **Discord:** Real-time chat (link TBD)
- **ESOUI Comments:** Addon page comments

### Getting Help

**Stuck on something?**
1. Check [DEVELOPMENT.md](DEVELOPMENT.md)
2. Search existing issues
3. Ask in GitHub Discussions
4. Join Discord (if available)

**Need addon development help?**
- [ESO Lua Documentation](https://wiki.esoui.com/)
- [ESOUI Developer Forum](https://www.esoui.com/forums/forumdisplay.php?f=3)
- [GitHub: esoui/esoui](https://github.com/esoui/esoui)

---

## Recognition

Contributors will be recognized in:
- **CHANGELOG.md** - Major contributions listed
- **GitHub Contributors** - Automatic recognition
- **README.md** - Special mentions for significant work

---

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (see [LICENSE](../LICENSE)).

---

**Thank you for contributing to CharacterMarkdown!** 🎉

Every contribution, no matter how small, helps make this addon better for the entire ESO community.