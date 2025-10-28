CharacterMarkdown v2.1.6
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

Usage Commands:
/markdown           - Open export window (default GitHub format)
/markdown github    - Generate GitHub format markdown
/markdown discord   - Generate Discord format markdown
/markdown vscode    - Generate VS Code format markdown
/markdown quick     - Generate one-line summary

Export Process:
1. Type /markdown in-game
2. Window opens with generated markdown
3. Click "Select All" then copy (Ctrl+C)
4. Paste anywhere - Discord, GitHub, forums, etc.

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

OUTPUT FORMATS
--------------

GitHub Format (Default):
* Full markdown tables with collapsible sections
* Rich formatting with progress bars
* Comprehensive UESP wiki links
* Perfect for GitHub README files and documentation

Discord Format:
* Compact tables optimized for Discord
* Essential information only
* Discord-compatible formatting

VS Code Format:
* Clean, readable format
* Optimized for code editors
* Minimal formatting

Quick Format:
* One-line character summary
* Perfect for status updates or quick reference

SETTINGS AND CUSTOMIZATION
---------------------------

Access Settings:
* In-game: Type /markdown then click "Settings" button
* Addon Menu: CharacterMarkdown settings panel

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

ADVANCED FEATURES
-----------------

Custom Notes:
Add personal build notes that appear in your markdown output:
/markdown notes "This is my main PvE DPS build for trials"

Profile Management:
* Save custom settings as profiles
* Import/export settings between characters
* Share profiles with other players

Error Handling:
* Comprehensive error reporting
* Graceful degradation if data is unavailable
* Debug mode for troubleshooting

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

COMMANDS REFERENCE
------------------

/markdown           - Open export window
/markdown github    - Generate GitHub format
/markdown discord   - Generate Discord format
/markdown vscode    - Generate VS Code format
/markdown quick     - Generate quick summary
/markdown notes "text" - Set custom build notes
/cmdsettings        - Open settings (if LibAddonMenu is installed)

VERSIONK
--------

v2.1.6 - Documentation cleanup and organization improvements

See CHANGELOG.md in the addon folder for complete version history.

LICENSE
-------

MIT License - See LICENSE file for details

LINKS
-----

ESOUI Download: https://www.esoui.com/downloads/info4279-CharacterMarkdown.html
UESP Wiki: https://en.uesp.net/wiki/Online:Main_Page

Made for the ESO community

