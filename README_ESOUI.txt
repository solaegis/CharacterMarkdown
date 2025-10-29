CharacterMarkdown v2.1.8
========================

Export your Elder Scrolls Online character data in beautiful, shareable markdown format. 
Generate comprehensive character profiles with clickable UESP wiki links for abilities, sets, 
races, classes, zones, and more.

FEATURES
--------

* Complete Character Profile - Export level, CP, attributes, skills, equipment, and combat stats
* Multiple Output Formats - GitHub (default), Discord, VS Code, and Quick summary formats
* Smart Wiki Links - Automatic UESP links for abilities, sets, races, classes, zones
* Customizable Settings - Extensive configuration options and built-in profiles
* Rich Output - Tables, progress bars, and collapsible sections for GitHub
* Easy Sharing - One-click copy to clipboard for Discord, forums, or documentation

QUICK START
-----------

Installation:
1. Via Minion: Search "CharacterMarkdown" and install
2. Manual: Extract the ZIP to your ESO AddOns folder

Export Process:
1. Type /markdown in-game (opens export window)
2. Click "Select All" then copy (Ctrl+C)
3. Paste anywhere - Discord, GitHub, forums, etc.

WHAT'S INCLUDED
---------------

Core Character Data:
* Name, race, class, alliance, level, CP
* Attribute allocations (Magicka, Health, Stamina)
* Combat stats (resources, power, resistances, recovery)
* Equipment with set bonuses and traits
* Mundus stone and active buffs
* All skill bars with morphs and progression

Extended Information:
* Economy - Gold, currencies, inventory capacity
* Progression - Achievement score, riding skills, enlightenment
* DLC Access - ESO Plus status, owned chapters and DLC
* Collectibles - Active collectibles and achievements
* PvP - Alliance War rank and active campaign
* Companion - Active companion stats and equipment
* Crafting - Research progress and crafting knowledge

OUTPUT FORMATS & COMMANDS
-------------------------

Available Commands:
/markdown           - Open export window (default GitHub format)
/markdown github    - Generate GitHub format markdown
/markdown discord   - Generate Discord format markdown  
/markdown vscode    - Generate VS Code format markdown
/markdown quick     - Generate one-line summary
/markdown notes "text" - Set custom build notes
/cmdsettings        - Open settings (if LibAddonMenu is installed)

Format Details:
* GitHub (Default) - Full markdown tables with collapsible sections, rich formatting, comprehensive UESP wiki links
* Discord - Compact tables optimized for Discord, essential information only
* VS Code - Clean, readable format optimized for code editors
* Quick - One-line character summary for status updates

SETTINGS AND CUSTOMIZATION
---------------------------

Access Settings:
* In-game: Type /markdown then click "Settings" button
* Addon Menu: CharacterMarkdown settings panel
* Command: /cmdsettings (if LibAddonMenu is installed)

Key Settings Options:
* Sections - Enable/disable specific data sections
* Links - Toggle UESP links for abilities and sets
* Filters - Set minimum skill ranks, equipment quality thresholds
* Profiles - Save and load different configuration sets

Built-in Profiles:
* Full Documentation - Everything enabled (maximum detail)
* PvE Build - Focused on trials/dungeons
* PvP Build - Optimized for Cyrodiil/Battlegrounds
* Discord Share - Compact format for Discord
* Quick Reference - Essentials only

Advanced Features:
* Custom Notes - Add personal build notes with /markdown notes "text"
* Profile Management - Save/import/export settings between characters
* Error Handling - Comprehensive error reporting with debug mode

USE CASES
---------

* Share Builds - Export complete character builds for forums or Discord
* Document Progress - Track your character's progression over time
* Build Guides - Create comprehensive build documentation
* AI Integration - Use with ChatGPT or Claude for build analysis
* Guild Roster - Document your character for guild applications
* Personal Reference - Quick access to your character details

REQUIREMENTS
------------

* Elder Scrolls Online
* ESO API Version 101047
* Optional: LibAddonMenu-2.0 (recommended)
* Optional: LibDebugLogger (for debugging)

INSTALLATION LOCATION
---------------------

Extract to:
Documents\Elder Scrolls Online\live\AddOns\

Or use Minion for automatic installation and updates.

REPORTING ISSUES
----------------

If you encounter any issues or have suggestions:
* Check the changelog for recent updates
* Review settings to ensure options are configured correctly
* Use /markdown debug for additional troubleshooting information

VERSION
-------

See CHANGELOG.md in the addon folder for complete version history.

LICENSE
-------

MIT License - See LICENSE file for details

LINKS
-----

ESOUI Download: https://www.esoui.com/downloads/info4279-CharacterMarkdown.html
UESP Wiki: https://en.uesp.net/wiki/Online:Main_Page

Made for the ESO community

