═══════════════════════════════════════════════════════════════════════════════
                            CHARACTER MARKDOWN
                     Comprehensive Character Profile Exporter
═══════════════════════════════════════════════════════════════════════════════

DESCRIPTION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

CharacterMarkdown generates complete, copyable character profiles in markdown 
format with automatic UESP wiki links. Perfect for sharing builds, tracking 
progression, or documenting your character across Discord, forums, GitHub, or 
local files.

Paste your profile into AI assistants (ChatGPT, Claude, etc.) for personalized 
build optimization, gear recommendations, skill rotation advice, or gameplay 
strategy tailored to your exact character stats and progression.

Generate profiles with a single command, copy to clipboard, and paste anywhere.


FEATURES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

CHARACTER DATA
  • Complete identity (name, race, class, alliance, level)
  • ESO Plus status and owned chapters/DLCs
  • Active mundus stone and buffs (food/potions)
  • Current location (zone, subzone)
  • Companion information (if active)

COMBAT & PROGRESSION
  • Front and back skill bars with UESP-linked abilities
  • Champion Point allocation across all three disciplines
  • Full skill line progression with filtering options
  • Complete combat statistics (health, magicka, stamina, power, crit, resistances)

EQUIPMENT & INVENTORY
  • All worn gear with set bonuses, quality, and traits
  • Inventory capacity (backpack, bank, housing storage)
  • Companion equipment (if companion active)

ECONOMY & CURRENCIES
  • Gold, Alliance Points, Tel Var Stones
  • Transmute Crystals, Writ Vouchers, Crown Gems
  • Event Tickets, Endeavor Seals, Undaunted Keys

COLLECTIBLES & CRAFTING
  • Mount training progress (speed, stamina, capacity)
  • Owned mounts, pets, costumes, houses (count or full list)
  • Crafting knowledge and research status

PVP & ENDGAME
  • Alliance War rank and active campaign
  • Achievement points
  • Vampire/Werewolf status and stage


EXPORT FORMATS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

GITHUB FORMAT (Default)
  • Full tables with proper alignment
  • Collapsible sections
  • UESP wiki links for all abilities and sets
  • Best for: GitHub READMEs, wikis, documentation

DISCORD FORMAT
  • Compact layout with emoji indicators
  • No large tables (Discord-friendly)
  • Essential information only
  • Best for: Discord servers, chat sharing

VS CODE FORMAT
  • Similar to GitHub format
  • Optimized for VS Code markdown preview
  • Best for: Local markdown files, note-taking

QUICK FORMAT
  • Single-line summary
  • Format: "Name • L50 CP627 👑 • Race Class • Set1(5), Set2(5)"
  • Best for: Quick sharing, status updates


COMMANDS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/markdown          Opens window with current character data (default format)
/markdown github   Exports in GitHub-optimized format
/markdown discord  Exports in compact Discord format
/markdown vscode   Exports in VS Code-friendly format
/markdown quick    Generates single-line summary


USAGE INSTRUCTIONS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Run the /markdown command (or variant)
2. Window opens with generated markdown text
3. Text is automatically selected
4. Press Ctrl+C (Windows/Linux) or Cmd+C (Mac) to copy
5. Paste anywhere (Discord, GitHub, VS Code, forums, etc.)

The addon collects all character data when the window opens. No manual data 
entry required - everything is pulled directly from the game API.


CONFIGURATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Settings are accessed via: ESC → Settings → Add-Ons → CharacterMarkdown

SECTION TOGGLES
  • Champion Points
  • Equipment
  • Skill Bars
  • Skill Progression
  • Combat Statistics
  • Currencies
  • Companion Information
  • Collectibles
  • Crafting Knowledge
  • PvP Information

UESP WIKI LINKS
  • Enable/disable automatic wiki links for abilities, sets, races, classes
  • Links route to comprehensive UESP (Unofficial Elder Scrolls Pages) wiki

SKILL FILTERS
  • Hide maxed skills (rank 50/50)
  • Set minimum rank threshold (only show skills above rank X)
  • Class skill highlighting (filter by current class)

COLLECTIBLES OPTIONS
  • Show full lists (all mounts, pets, etc.)
  • Show counts only (more compact)

DEFAULT FORMAT
  • Choose which format to use by default when opening window


SAMPLE OUTPUT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Quick Format:
Pelatiah • L50 CP627 👑 • Impe DK • Mother's Sorrow(5), Silks of the Sun(5)

GitHub Format Excerpt:
---
# Pelatiah

**Imperial Dragonknight**
Level 50 • Champion 627 • Ebonheart Pact

ESO Plus: Active | DLCs: 15/18 owned

## ⚔️ Skill Bars

### Front Bar (Destruction Staff)
1. [Molten Whip](https://en.uesp.net/wiki/Online:Molten_Whip)
2. [Engulfing Flames](https://en.uesp.net/wiki/Online:Engulfing_Flames)
3. [Eruption](https://en.uesp.net/wiki/Online:Eruption)
4. [Wall of Elements](https://en.uesp.net/wiki/Online:Wall_of_Elements)
5. [Inner Light](https://en.uesp.net/wiki/Online:Inner_Light)
**Ultimate**: [Standard of Might](https://en.uesp.net/wiki/Online:Standard_of_Might)

## 🎒 Equipment

| Slot   | Item                    | Set              | Quality | Trait   |
|--------|-------------------------|------------------|---------|---------|
| Head   | Mother's Sorrow Hat     | Mother's Sorrow  | Epic    | Divines |
| Chest  | Silks of the Sun Robe   | Silks of the Sun | Epic    | Divines |
...
---


DEPENDENCIES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

REQUIRED: None - CharacterMarkdown works standalone

OPTIONAL:
  • LibAddonMenu-2.0 - Provides the settings panel UI
    (If not installed, addon still works but settings panel won't appear)
  
  • LibDebugLogger - Clean debug output system
    (Only needed for development/debugging)


COMPATIBILITY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

• ESO API: 101047 (Gold Road and later)
• Platforms: PC, Mac
• Console: Xbox and PlayStation (with .addon manifest support)
• Server: NA and EU megaservers


TROUBLESHOOTING
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ADDON NOT LOADING
  • Verify files exist in AddOns/CharacterMarkdown/ folder
  • Check for Lua errors: type /luaerror on in game
  • Try /reloadui command

COMMAND NOT WORKING
  • Ensure you type /markdown (not /charactermarkdown)
  • Check addon is enabled in Add-ons menu (character select screen)

SETTINGS NOT SAVING
  • Fixed in version 2.1.1 - update to latest version
  • Settings are saved per-account in SavedVariables

TEXT NOT COPYING
  • Ensure text is selected (should be automatic)
  • Try clicking in the text box first, then press Ctrl+A, Ctrl+C
  • If truncation occurs, try generating in smaller format (Discord/Quick)

MISSING DATA
  • Some data requires specific conditions:
    - Companion info only shows if companion is active
    - PvP rank requires Alliance War participation
    - Vampire/Werewolf only if infected


SUPPORT & FEEDBACK
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

• Report bugs or request features on ESOUI comments
• Source code: https://github.com/solaegis/CharacterMarkdown
• Author: @solaegis (in-game)


VERSION HISTORY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

See full changelog at: https://github.com/solaegis/CharacterMarkdown/CHANGELOG.md

v2.1.1 - January 2025
  • Fixed SavedVariables loading bug
  • Improved settings panel initialization
  • Updated for Gold Road API (101047)

v2.1.0 - January 2025
  • Added Discord export format
  • Added Quick format (one-line summary)
  • Improved UESP link generation
  • Expanded collectibles tracking
  • Added crafting knowledge section


ACKNOWLEDGMENTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

• ESO Community - Feedback and testing
• UESP Wiki - Comprehensive game data
• LibAddonMenu-2.0 Team - Settings framework
• ESOUI Platform - Addon distribution


═══════════════════════════════════════════════════════════════════════════════
                      Made for the ESO Community with ❤️
═══════════════════════════════════════════════════════════════════════════════
