-- CharacterMarkdown - Constants
-- Centralized location for static data, lookups, and configuration constants

local CM = CharacterMarkdown

-- Define CM.constants (legacy lowercase) and alias CM.Constants (new uppercase) to it
CM.constants = CM.constants or {}
CM.Constants = CM.constants

-- =====================================================
-- CHUNKING CONSTANTS (Restored)
-- =====================================================
--
-- ESO EditBox Limits - Based on Real-World Testing:
-- - ESO's EditBox controls CANNOT DISPLAY more than ~6.5k characters
-- - Content beyond this limit is invisible and cannot be copied
-- - This is an EditBox DISPLAY limitation, not just a clipboard limitation
-- - UI scale and font metrics can affect exact limits
-- - These values are conservative to ensure reliable display/copy across configurations
--
-- Research Sources & Findings:
-- - ESOUI forum discussions on EditBox behavior
-- - Addon author observations of truncation at various sizes
-- - ACTUAL TESTING #1 (2025-11-12): 19,483 char chunk displayed ~10-11k, rest invisible
-- - ACTUAL TESTING #2 (2025-11-12): 15,447 char chunk displayed ~10-11k, rest invisible
-- - ACTUAL TESTING #3 (2025-11-12): 9,609 char chunk truncated at ~9k, missing ~600 chars
-- - ACTUAL TESTING #4 (2025-11-12): 8,691 char chunk truncated at ~8k-8.5k, incomplete copy
-- - ACTUAL TESTING #5 (2025-11-12): 7,693 char chunk truncated at ~7.5k, "Explor" vs "Exploration"
-- - ACTUAL TESTING #6 (2025-11-12): 7,101 char chunk truncated at ~7k, "Dungeons   " incomplete
-- - ACTUAL TESTING #7 (2025-11-12): 6,602 char chunk truncated at ~6.5k, "Social         " incomplete
-- - ACTUAL TESTING #8 (2025-11-12): 6,602 char chunk STILL truncated with 6.5k limit
-- - EditBox display truncation documented through in-game testing
-- - Reducing to 6.0k limit to provide adequate safety buffer
--
-- Strategy:
-- - EDITBOX_LIMIT: Set to 6.0k based on observed display truncation at 6.6k chars (with safety buffer)
-- - COPY_LIMIT: Additional 300-char margin for clipboard operations
-- - MAX_DATA_CHARS: Reserve space for padding (87 chars) to prevent paste truncation
--
CM.constants.CHUNKING = {
    EDITBOX_LIMIT = 21500, -- Trigger chunking when content exceeds COPY_LIMIT (matches actual chunk size limit)
    COPY_LIMIT = 21500, -- Safe copy limit confirmed by testing
    MAX_DATA_CHARS = 20350, -- Maximum data characters per chunk (leaves room for ~60 byte HTML comment marker + 550 newlines + buffer)
    DISABLE_PADDING = false, -- **PADDING ENABLED** - 500 byte buffer absorbs variable truncation
    USE_SECTION_BASED_CHUNKING = false, -- **DISABLED**: Section-based chunking has bugs - using legacy for now
    -- Padding constants (kept for backward compatibility if DISABLE_PADDING = false)
    PADDING_OVERHEAD_BASE = 17, -- Base overhead for padding (comment + newlines)
    PADDING_INVISIBLE_CHAR_LENGTH = 3, -- Length of invisible char (3 bytes in UTF-8)
    MIN_FINAL_CHUNK_PADDING = 50, -- Minimum padding for final chunk
    MAX_FINAL_CHUNK_PADDING = 300, -- Maximum padding for final chunk
    TARGET_CHUNK_SIZE = 5700, -- Target total size for non-final chunks
    SAFE_PADDING_RESERVE = 50, -- Reserve for padding calculation
    PADDING_COMMENT = "\n[comment]: #\n", -- Invisible markdown comment (not currently used)
    PADDING_INVISIBLE_CHAR = "\226\128\139", -- Zero-width space (U+200B) (not currently used)
    SPACE_PADDING_SIZE = 550, -- Number of NEWLINES to add as padding - safe if truncated, works in any markdown context
}

-- =====================================================
-- STRING LIMITS (Restored)
-- =====================================================

CM.constants.LIMITS = {
    MAX_CUSTOM_NOTES_SIZE = 1900, -- Maximum custom notes size (~2000 char ESO SavedVariables limit per string)
    MAX_STRING_TRUNCATE = 1000, -- Maximum string length before truncation warning
    ESO_SAVEDVAR_STRING_LIMIT = 2000, -- ESO's hard limit for individual string values in SavedVariables
}

-- =====================================================
-- FORMAT NAMES (Restored)
-- =====================================================

CM.constants.FORMATS = {
    MARKDOWN = "markdown",
    TONL = "tonl",
}

-- =====================================================
-- CHAMPION POINTS CONSTANTS (Restored)
-- =====================================================

CM.constants.CP = {
    MIN_CP_FOR_SYSTEM = 10, -- Minimum CP required for Champion Point system
    MAX_CP_PER_DISCIPLINE = 660, -- Maximum CP per discipline
    PROGRESS_BAR_LENGTH = 12, -- Length of progress bar in characters
}

-- =====================================================
-- DEFAULT VALUES (Restored)
-- =====================================================

CM.constants.DEFAULTS = {
    EDITBOX_LIMIT_FALLBACK = 10000, -- Fallback EditBox limit if CHUNKING constant not available
}

-- =====================================================
-- GAME CONSTANTS & LOOKUPS (New)
-- =====================================================

-- Race ID to name mapping (fallback if API fails)
-- ESO Race IDs: 1=Altmer, 2=Argonian, 3=Bosmer, 4=Breton, 5=Dunmer, 6=Imperial, 7=Khajiit, 8=Nord, 9=Orc, 10=Redguard
CM.constants.RACE_NAMES = {
    [1] = "Altmer",
    [2] = "Argonian",
    [3] = "Bosmer",
    [4] = "Breton",
    [5] = "Dunmer",
    [6] = "Imperial",
    [7] = "Khajiit",
    [8] = "Nord",
    [9] = "Orc",
    [10] = "Redguard",
}

-- Class ID to name mapping (fallback if API fails)
-- ESO Class IDs: 1=Dragonknight, 2=Sorcerer, 3=Nightblade, 4=Templar, 5=Warden, 6=Necromancer, 7=Arcanist
CM.constants.CLASS_NAMES = {
    [1] = "Dragonknight",
    [2] = "Sorcerer",
    [3] = "Nightblade",
    [4] = "Templar",
    [5] = "Warden",
    [6] = "Necromancer",
    [7] = "Arcanist",
}

-- Skill Type Names (Standard ESO Types)
CM.constants.SKILL_TYPE_NAMES = {
    [1] = "Class",
    [2] = "Weapon",
    [3] = "Armor",
    [4] = "World",
    [5] = "Guild",
    [6] = "Alliance War",
    [7] = "Racial",
    [8] = "Craft",
    [9] = "Champion",
}

-- Skill Type Emojis for Markdown Generation
CM.constants.SKILL_TYPE_EMOJIS = {
    ["Class"] = "⚔️",
    ["Weapon"] = "⚔️",
    ["Armor"] = "🛡️",
    ["World"] = "🌍",
    ["Guild"] = "🏰",
    ["Alliance War"] = "⚔️",
    ["Racial"] = "⭐",
    ["Craft"] = "⚒️",
    ["Champion"] = "⭐",
}

-- Default Emoji Fallback
CM.constants.DEFAULT_SKILL_EMOJI = "📜"

-- =====================================================
-- FILTERING & VALIDATION (New)
-- =====================================================

-- Invalid Skill Types to skip in processing
CM.constants.INVALID_SKILL_TYPES = {
    ["Vengeance"] = true,
    ["Racial"] = true, -- Often handled separately or hidden
}

-- Invalid Skill Lines to skip in processing
CM.constants.INVALID_SKILL_LINES = {
    ["Vengeance"] = true,
    ["Crown Store"] = true,
    [""] = true,
}

-- Class Skill Lines Mapping (Fallback / Reference)
-- Used if dynamic detection fails or for validation
CM.constants.CLASS_SKILL_LINES = {
    ["Dragonknight"] = {
        ["Ardent Flame"] = true,
        ["Draconic Power"] = true,
        ["Earthen Heart"] = true,
    },
    ["Nightblade"] = {
        ["Assassination"] = true,
        ["Shadow"] = true,
        ["Siphoning"] = true,
    },
    ["Sorcerer"] = {
        ["Daedric Summoning"] = true,
        ["Dark Magic"] = true,
        ["Storm Calling"] = true,
    },
    ["Templar"] = {
        ["Aedric Spear"] = true,
        ["Dawn's Wrath"] = true,
        ["Restoring Light"] = true,
    },
    ["Warden"] = {
        ["Animal Companions"] = true,
        ["Green Balance"] = true,
        ["Winter's Embrace"] = true,
    },
    ["Necromancer"] = {
        ["Grave Lord"] = true,
        ["Bone Tyrant"] = true,
        ["Living Death"] = true,
    },
    ["Arcanist"] = {
        ["Herald of the Tome"] = true,
        ["Apocryphal Soldier"] = true,
        ["Curative Runeforms"] = true,
    },
}

-- Order for displaying skill types
CM.constants.SKILL_TYPE_ORDER = {
    "Class",
    "Weapon",
    "Armor",
    "World",
    "Guild",
    "Alliance War",
    "Racial",
    "Craft",
}

-- =====================================================
-- UI / DISPLAY CONSTANTS (New)
-- =====================================================

CM.constants.BAR_NAMES = {
    PRIMARY = "⚔️ Front Bar (Main Hand)",
    BACKUP = "🔮 Back Bar (Backup)",
}

CM.DebugPrint("UTILS", "Constants module loaded")
