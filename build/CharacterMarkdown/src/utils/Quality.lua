-- CharacterMarkdown - Quality and Emoji Utilities
-- Item quality, slot emojis, etc.

local CM = CharacterMarkdown

-- =====================================================
-- QUALITY HELPERS
-- =====================================================

-- Get quality name from quality constant
local function GetQualityColor(quality)
    local colors = {
        [ITEM_QUALITY_TRASH] = "Trash",
        [ITEM_QUALITY_NORMAL] = "Normal",
        [ITEM_QUALITY_MAGIC] = "Magic",
        [ITEM_QUALITY_ARCANE] = "Arcane",
        [ITEM_QUALITY_ARTIFACT] = "Artifact",
        [ITEM_QUALITY_LEGENDARY] = "Legendary",
    }
    return colors[quality] or "Unknown"
end

CM.utils.GetQualityColor = GetQualityColor

-- Get quality emoji from quality constant
local function GetQualityEmoji(quality)
    local emojis = {
        [ITEM_QUALITY_TRASH] = "⚪",
        [ITEM_QUALITY_NORMAL] = "⚪",
        [ITEM_QUALITY_MAGIC] = "⚡",
        [ITEM_QUALITY_ARCANE] = "🔮",
        [ITEM_QUALITY_ARTIFACT] = "⭐",
        [ITEM_QUALITY_LEGENDARY] = "👑",
    }
    return emojis[quality] or "⚪"
end

CM.utils.GetQualityEmoji = GetQualityEmoji

-- =====================================================
-- EQUIPMENT SLOT HELPERS
-- =====================================================

-- Get equipment slot name from slot index
local function GetEquipSlotName(slotIndex)
    local slots = {
        [EQUIP_SLOT_HEAD] = "Head",
        [EQUIP_SLOT_NECK] = "Neck",
        [EQUIP_SLOT_CHEST] = "Chest",
        [EQUIP_SLOT_SHOULDERS] = "Shoulders",
        [EQUIP_SLOT_MAIN_HAND] = "Main Hand",
        [EQUIP_SLOT_OFF_HAND] = "Off Hand",
        [EQUIP_SLOT_WAIST] = "Waist",
        [EQUIP_SLOT_LEGS] = "Legs",
        [EQUIP_SLOT_FEET] = "Feet",
        [EQUIP_SLOT_COSTUME] = "Costume",
        [EQUIP_SLOT_RING1] = "Ring 1",
        [EQUIP_SLOT_RING2] = "Ring 2",
        [EQUIP_SLOT_HAND] = "Hands",
        [EQUIP_SLOT_BACKUP_MAIN] = "Backup Main Hand",
        [EQUIP_SLOT_BACKUP_OFF] = "Backup Off Hand",
    }
    return slots[slotIndex] or "Unknown"
end

CM.utils.GetEquipSlotName = GetEquipSlotName

-- Get emoji for equipment slot
local function GetSlotEmoji(slotIndex)
    local emojis = {
        [EQUIP_SLOT_HEAD] = "🪖",
        [EQUIP_SLOT_NECK] = "📿",
        [EQUIP_SLOT_CHEST] = "🛡️",
        [EQUIP_SLOT_SHOULDERS] = "👑",
        [EQUIP_SLOT_MAIN_HAND] = "⚔️",
        [EQUIP_SLOT_OFF_HAND] = "🛡️",
        [EQUIP_SLOT_WAIST] = "⚡",
        [EQUIP_SLOT_LEGS] = "🦵",
        [EQUIP_SLOT_FEET] = "👢",
        [EQUIP_SLOT_RING1] = "💍",
        [EQUIP_SLOT_RING2] = "💍",
        [EQUIP_SLOT_HAND] = "🧤",
        [EQUIP_SLOT_BACKUP_MAIN] = "🔮",
        [EQUIP_SLOT_BACKUP_OFF] = "🛡️",
    }
    return emojis[slotIndex] or "📦"
end

CM.utils.GetSlotEmoji = GetSlotEmoji
