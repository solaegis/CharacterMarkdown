-- CharacterMarkdown - Constants Module
-- Centralized constants to replace magic numbers

local CM = CharacterMarkdown

-- =====================================================
-- CHUNKING CONSTANTS
-- =====================================================

CM.constants.CHUNKING = {
    EDITBOX_LIMIT = 8500, -- ESO EditBox character limit (display) - reduced for safer copy
    COPY_LIMIT = 8500, -- ESO EditBox copy limit - reduced to avoid truncation
    MAX_DATA_CHARS = 8413, -- Maximum data characters per chunk (8500 - 87 for padding: 85 spaces + 2 newlines)
    -- Padding constants (kept for reference, but padding is disabled - no longer needed with smaller limits)
    PADDING_OVERHEAD_BASE = 17, -- Base overhead for padding (comment + newlines) - DISABLED
    PADDING_INVISIBLE_CHAR_LENGTH = 3, -- Length of invisible char (3 bytes in UTF-8) - DISABLED
    MIN_FINAL_CHUNK_PADDING = 50, -- Minimum padding for final chunk - DISABLED
    MAX_FINAL_CHUNK_PADDING = 300, -- Maximum padding for final chunk - DISABLED
    TARGET_CHUNK_SIZE = 8413, -- Target total size for non-final chunks (8500 - 87 for padding: 85 spaces + 2 newlines)
    SAFE_PADDING_RESERVE = 50, -- Reserve for padding calculation - DISABLED
    PADDING_COMMENT = "\n[comment]: #\n", -- Invisible markdown comment - DISABLED
    PADDING_INVISIBLE_CHAR = "\226\128\139", -- Zero-width space (U+200B) - DISABLED
    SPACE_PADDING_SIZE = 85, -- Number of spaces to add as padding (followed by newline)
}

-- =====================================================
-- STRING LIMITS
-- =====================================================

CM.constants.LIMITS = {
    MAX_CUSTOM_NOTES_SIZE = 10240, -- Maximum custom notes size (10KB)
    MAX_STRING_TRUNCATE = 1000, -- Maximum string length before truncation warning
}

-- =====================================================
-- FORMAT NAMES
-- =====================================================

CM.constants.FORMATS = {
    GITHUB = "github",
    VSCODE = "vscode",
    DISCORD = "discord",
    QUICK = "quick",
}

-- =====================================================
-- CHAMPION POINTS CONSTANTS
-- =====================================================

CM.constants.CP = {
    MIN_CP_FOR_SYSTEM = 10, -- Minimum CP required for Champion Point system
    MAX_CP_PER_DISCIPLINE = 660, -- Maximum CP per discipline
    PROGRESS_BAR_LENGTH = 12, -- Length of progress bar in characters
}

-- =====================================================
-- DEFAULT VALUES
-- =====================================================

CM.constants.DEFAULTS = {
    EDITBOX_LIMIT_FALLBACK = 10000, -- Fallback EditBox limit if CHUNKING constant not available
}

CM.DebugPrint("UTILS", "Constants module loaded")
