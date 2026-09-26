-- CharacterMarkdown - Set Dump Command Handlers
-- /cm sets:dump  - scan every item set via the game API into SavedVariables
-- /cm sets:clear - drop the dump (it is ~0.5-1 MB; don't carry it around)
-- /cm sets       - show dump status
--
-- Feeds Phase 3 of the set database (docs/SET_DATABASE_PLAN.md): the Python
-- reconciler joins this against the UESP-derived data/sets/sets.json to assign
-- in-game set IDs and verify the wiki's bonus lines. Stored in its own SavedVariables
-- global (not CM.settings) so it never touches settings, profiles or exports.

local CM = CharacterMarkdown
CM.commands = CM.commands or {}
CM.commands.sets = {}

local GetItemSetInfo = GetItemSetInfo
local GetItemSetBonusInfo = GetItemSetBonusInfo
local GetItemSetType = GetItemSetType
local GetItemSetUnperfectedSetId = GetItemSetUnperfectedSetId
local GetItemSetClassRestrictions = GetItemSetClassRestrictions
local GetItemSetCollectionCategoryId = GetItemSetCollectionCategoryId
local GetItemSetCollectionCategoryName = GetItemSetCollectionCategoryName
local GetItemSetCollectionCategoryParentId = GetItemSetCollectionCategoryParentId
local GetNumItemSetCollectionPieces = GetNumItemSetCollectionPieces
local zo_callLater = zo_callLater
local string_format = string.format

local DUMP_VERSION = 1
-- Set IDs are sparse; the highest live ID is well under this. Scanning past the
-- end is cheap (GetItemSetInfo returns hasSet=false).
local MAX_SET_ID = 2000
local BATCH_SIZE = 100
local BATCH_DELAY_MS = 10
-- SavedVariables silently drop any single string of 2000+ characters.
-- Longest known bonus text is ~500 chars; this is a safety net.
local MAX_SV_STRING = 1900

local scanning = false

local function CategoryPath(categoryId)
    if not categoryId or categoryId == 0 then
        return nil
    end
    local parts = {}
    local guard = 0
    while categoryId and categoryId ~= 0 and guard < 5 do
        local name = GetItemSetCollectionCategoryName(categoryId)
        if name and name ~= "" then
            table.insert(parts, 1, name)
        end
        categoryId = GetItemSetCollectionCategoryParentId(categoryId)
        guard = guard + 1
    end
    return #parts > 0 and table.concat(parts, " > ") or nil
end

local function LibSetsType(setId)
    if not (LibSets and type(LibSets.GetSetType) == "function") then
        return nil
    end
    local ok, setType = pcall(LibSets.GetSetType, setId)
    if not ok or setType == nil then
        return nil
    end
    if type(LibSets.GetSetTypeName) == "function" then
        local okName, name = pcall(LibSets.GetSetTypeName, setType)
        if okName and name then
            return name
        end
    end
    return tostring(setType)
end

local function ReadSet(setId)
    local hasSet, setName, numBonuses, _, _, maxEquipped = GetItemSetInfo(setId)
    if not hasSet or not setName or setName == "" then
        return nil
    end

    local bonuses = {}
    for i = 1, numBonuses or 0 do
        local numRequired, description, isPerfected = GetItemSetBonusInfo(setId, i)
        local bonus = { pieces = numRequired, perfected = isPerfected or false }
        if description and #description > MAX_SV_STRING then
            -- SavedVariables drop strings of 2000+ chars; split (the reconciler rejoins textParts)
            local parts = {}
            for pos = 1, #description, MAX_SV_STRING do
                parts[#parts + 1] = description:sub(pos, pos + MAX_SV_STRING - 1)
            end
            bonus.textParts = parts
        else
            bonus.text = description
        end
        bonuses[#bonuses + 1] = bonus
    end

    local hasRestrictions, _, allowedNames = GetItemSetClassRestrictions(setId)
    local categoryId = GetItemSetCollectionCategoryId(setId)
    local unperfected = GetItemSetUnperfectedSetId(setId)

    return {
        id = setId,
        name = setName,
        apiType = GetItemSetType(setId),
        libSetsType = LibSetsType(setId),
        maxEquipped = maxEquipped,
        unperfectedId = (unperfected and unperfected ~= 0 and unperfected ~= setId) and unperfected or nil,
        classes = hasRestrictions and allowedNames or nil,
        category = CategoryPath(categoryId),
        collectionPieces = GetNumItemSetCollectionPieces(setId),
        bonuses = bonuses,
    }
end

local function BuildMeta(count)
    local cp = GetUnitChampionPoints and GetUnitChampionPoints("player") or 0
    return {
        dumpVersion = DUMP_VERSION,
        apiVersion = GetAPIVersion and GetAPIVersion() or nil,
        gameVersion = GetESOVersionString and GetESOVersionString() or nil,
        server = GetWorldName and GetWorldName() or nil,
        language = GetCVar and GetCVar("language.2") or nil,
        timestamp = GetTimeStamp and GetTimeStamp() or nil,
        -- Bonus values render at each set's default drop quality (not CP160 gold), and
        -- proc/heal tooltips use this character's stats; the reconciler accounts for both.
        level = GetUnitLevel and GetUnitLevel("player") or nil,
        championPoints = cp,
        maxSetIdScanned = MAX_SET_ID,
        setCount = count,
    }
end

local function HandleDump()
    if scanning then
        CM.Warn("Set dump already running")
        return
    end
    scanning = true

    CM.Info(string_format("Scanning item sets 1-%d...", MAX_SET_ID))

    local sets = {}
    local count = 0
    local nextId = 1

    local function Step()
        local last = math.min(nextId + BATCH_SIZE - 1, MAX_SET_ID)
        for setId = nextId, last do
            local ok, record = pcall(ReadSet, setId)
            if ok and record then
                sets[#sets + 1] = record
                count = count + 1
            elseif not ok then
                CM.DebugPrint("SETS", string_format("set %d failed: %s", setId, tostring(record)))
            end
        end
        nextId = last + 1

        if nextId <= MAX_SET_ID then
            zo_callLater(Step, BATCH_DELAY_MS)
            return
        end

        CharacterMarkdownSetDump = { meta = BuildMeta(count), sets = sets }
        scanning = false
        CM.Info(string_format("Set dump complete: %d sets. Type /reloadui to write SavedVariables to disk.", count))
    end

    Step()
end

local function HandleClear()
    CharacterMarkdownSetDump = nil
    CM.Info("Set dump cleared. Type /reloadui to remove it from SavedVariables.")
end

local function HandleStatus()
    local dump = CharacterMarkdownSetDump
    if scanning then
        CM.Info("Set dump in progress...")
    elseif type(dump) == "table" and type(dump.meta) == "table" then
        CM.Info(
            string_format(
                "Set dump: %d sets (API %s, CP %s). /cm sets:dump to refresh, /cm sets:clear to remove.",
                dump.meta.setCount or 0,
                tostring(dump.meta.apiVersion),
                tostring(dump.meta.championPoints)
            )
        )
    else
        CM.Info("No set dump. /cm sets:dump scans every item set into SavedVariables.")
    end
end

--- Dispatch "dump" / "clear" / "" (status).
local function HandleSets(action)
    action = (action or ""):lower():match("^%s*(%S*)")
    if action == "dump" then
        HandleDump()
    elseif action == "clear" then
        HandleClear()
    else
        HandleStatus()
    end
end

CM.commands.sets.HandleSets = HandleSets
CM.commands.sets.HandleDump = HandleDump
CM.commands.sets.HandleClear = HandleClear

CM.DebugPrint("COMMANDS", "Set dump commands module loaded")
