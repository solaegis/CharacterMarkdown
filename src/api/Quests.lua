-- CharacterMarkdown - API Layer - Quests
-- Abstraction for quest journal and zone completion

local CM = CharacterMarkdown
CM.api = CM.api or {}
CM.api.quests = {}

local api = CM.api.quests

-- =====================================================
-- GRANULAR GETTERS
-- =====================================================

function api.GetJournalInfo()
    local numQuests = CM.SafeCall(GetNumJournalQuests) or 0
    local quests = {}

    for i = 1, numQuests do
        local success, name, bgText, stepText, stepType, override, completed, tracked, level =
            CM.SafeCallMulti(GetJournalQuestInfo, i)
        if success and name and type(name) == "string" then
            table.insert(quests, {
                index = i,
                name = name,
                level = level,
                stepText = stepText,
                isTracked = tracked,
                isCompleted = completed,
            })
        end
    end

    return quests
end

-- zoneIndex: Required parameter - must be passed from collector level
function api.GetZoneCompletion(zoneIndex)
    -- Basic Zone Guide / Map Completion data
    if not zoneIndex then
        return {
            zoneIndex = nil,
            percent = 0,
        }
    end

    local completionPercent = 0

    if zoneIndex then
        -- Some API versions support GetZoneCompletionStatus
        if GetZoneCompletionStatus then
            completionPercent = CM.SafeCall(GetZoneCompletionStatus, zoneIndex) or 0
        end
    end

    return {
        zoneIndex = zoneIndex,
        percent = completionPercent,
    }
end

-- Composition functions moved to collector level
