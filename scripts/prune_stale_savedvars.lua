-- Prune stale character data from live ESO SavedVariables.
-- Invoked by prune_stale_savedvars.py with args:
--   <sv_dir> <report_json_path> <apply:0|1>

local sv_dir = assert(arg[1], "sv_dir required")
local report_path = assert(arg[2], "report_path required")
local apply = (arg[3] == "1")

local script_dir = debug.getinfo(1, "S").source:match("^@(.*/)") or "./"
package.path = script_dir .. "lib/?.lua;" .. package.path
local serialize = require("eso_sv_serialize")

local STALE_SEA_WOLF = "8798292100773940"
local KEEP_SEA_WOLF = "8798292100774412"
local MASISI_NA = "8796093036412335"
local MASISI_EU = "8798292071266932"

-- name -> { account, megaserver, id? }
-- id optional except when multiple IDs share a name
local ROSTER = {
    -- EU @SOLAEGIS
    ["Alpha Top"] = { account = "@SOLAEGIS", megaserver = "EU Megaserver" },
    ["Dolu-tanesi"] = { account = "@SOLAEGIS", megaserver = "EU Megaserver" },
    ["karakadin"] = { account = "@SOLAEGIS", megaserver = "EU Megaserver" },
    ["Lord Elric of Melniboné"] = { account = "@SOLAEGIS", megaserver = "EU Megaserver" },
    ["S'Katib-Asrar"] = { account = "@SOLAEGIS", megaserver = "EU Megaserver" },
    ["Sea-Wolf"] = { account = "@SOLAEGIS", megaserver = "EU Megaserver", id = KEEP_SEA_WOLF },
    ["Siyahi Boksör"] = { account = "@SOLAEGIS", megaserver = "EU Megaserver" },
    ["Taranis Kotu"] = { account = "@SOLAEGIS", megaserver = "EU Megaserver" },
    ["Zirhli"] = { account = "@SOLAEGIS", megaserver = "EU Megaserver" },
    ["Sol Aegis"] = { account = "@SOLAEGIS", megaserver = "EU Megaserver" },
    ["Sjelhøsteren"] = { account = "@SOLAEGIS", megaserver = "EU Megaserver" },
    -- NA @SOLAEGIS
    ["Dextera Dei"] = { account = "@SOLAEGIS", megaserver = "NA Megaserver" },
    ["Dolu-tenasi"] = { account = "@SOLAEGIS", megaserver = "NA Megaserver" },
    ["Heka-Ankh"] = { account = "@SOLAEGIS", megaserver = "NA Megaserver" },
    ["Hya'cinthe"] = { account = "@SOLAEGIS", megaserver = "NA Megaserver" },
    ["Karakedi"] = { account = "@SOLAEGIS", megaserver = "NA Megaserver" },
    ["Karakum"] = { account = "@SOLAEGIS", megaserver = "NA Megaserver" },
    ["Brontanax"] = { account = "@SOLAEGIS", megaserver = "NA Megaserver" },
    ["Lætha"] = { account = "@SOLAEGIS", megaserver = "NA Megaserver" },
    ["Lei-Tun"] = { account = "@SOLAEGIS", megaserver = "NA Megaserver" },
    ["Nekhtarhebi"] = { account = "@SOLAEGIS", megaserver = "NA Megaserver" },
    ["Pelatiah"] = { account = "@SOLAEGIS", megaserver = "NA Megaserver" },
    ["Rilis Toxil"] = { account = "@SOLAEGIS", megaserver = "NA Megaserver" },
    ["Silent-Snow-Falls"] = { account = "@SOLAEGIS", megaserver = "NA Megaserver" },
    ["Stoirmgheal"] = { account = "@SOLAEGIS", megaserver = "NA Megaserver" },
    ["Talon Valois"] = { account = "@SOLAEGIS", megaserver = "NA Megaserver" },
    ["Tziyad"] = { account = "@SOLAEGIS", megaserver = "NA Megaserver" },
    -- NA @vavasour
    ["Asili Kabir"] = { account = "@vavasour", megaserver = "NA Megaserver" },
    ["Brikolaka"] = { account = "@vavasour", megaserver = "NA Megaserver" },
    ["Hadriān"] = { account = "@vavasour", megaserver = "NA Megaserver" },
    ["Loïc d'Lyon"] = { account = "@vavasour", megaserver = "NA Megaserver" },
    ["Lysara Vormaer"] = { account = "@vavasour", megaserver = "NA Megaserver" },
    ["Ringil of Eskiath"] = { account = "@vavasour", megaserver = "NA Megaserver" },
    ["Siyah-ayi"] = { account = "@vavasour", megaserver = "NA Megaserver" },
    ["Spymaster Walsingham"] = { account = "@vavasour", megaserver = "NA Megaserver" },
    ["Xee-Keshti"] = { account = "@vavasour", megaserver = "NA Megaserver" },
}

-- Masisi dual-id special-cased below

local report = {
    apply = apply,
    stale_sea_wolf_id = STALE_SEA_WOLF,
    keep_sea_wolf_id = KEEP_SEA_WOLF,
    zo = {},
    character_markdown = {},
    addons = {},
}

local function read_file(path)
    local f = assert(io.open(path, "rb"))
    local data = f:read("*a")
    f:close()
    return data
end

local function write_file(path, data)
    local f = assert(io.open(path, "wb"))
    f:write(data)
    f:close()
end

local function load_sv(path)
    local src = read_file(path)
    local env = {}
    local chunk, err = load(src, path, "t", env)
    if not chunk then
        error("load failed " .. path .. ": " .. tostring(err))
    end
    chunk()
    return env
end

local function is_char_id(k)
    return type(k) == "string" and #k == 16 and k:match("^%d+$") ~= nil
end

local function score_pcd(entry)
    if type(entry) ~= "table" then
        return -1
    end
    local score = 0
    if type(entry.customNotes) == "string" and entry.customNotes ~= "" then
        score = score + 100 + #entry.customNotes
    end
    if type(entry.customTitle) == "string" and entry.customTitle ~= "" then
        score = score + 50 + #entry.customTitle
    end
    if type(entry.playStyle) == "string" and entry.playStyle ~= "" then
        score = score + 25
    end
    if entry._lastModified then
        score = score + 1
    end
    return score
end

local function collect_pcd(node, out)
    if type(node) ~= "table" then
        return
    end
    local pcd = node.perCharacterData
    if type(pcd) == "table" then
        for id, entry in pairs(pcd) do
            if is_char_id(id) and type(entry) == "table" then
                local name = entry._characterName
                local account = entry._accountName
                out[#out + 1] = {
                    id = id,
                    name = name,
                    account = account,
                    entry = entry,
                    score = score_pcd(entry),
                }
            end
        end
    end
    for k, v in pairs(node) do
        if type(v) == "table" and k ~= "perCharacterData" then
            collect_pcd(v, out)
        end
    end
end

local function roster_slot(name, id)
    if name == "Masisi" then
        if id == MASISI_NA then
            return "@SOLAEGIS", "NA Megaserver"
        elseif id == MASISI_EU then
            return "@SOLAEGIS", "EU Megaserver"
        else
            return nil, nil
        end
    end
    local r = ROSTER[name]
    if not r then
        return nil, nil
    end
    if r.id and r.id ~= id then
        return nil, nil
    end
    return r.account, r.megaserver
end

local function shallow_copy_pcd(entry)
    local copy = {}
    for k, v in pairs(entry) do
        if type(v) ~= "table" then
            copy[k] = v
        end
    end
    return copy
end

local function json_escape(s)
    s = tostring(s)
    s = s:gsub("\\", "\\\\")
    s = s:gsub('"', '\\"')
    s = s:gsub("\n", "\\n")
    return s
end

local function to_json(value, indent)
    indent = indent or 0
    local t = type(value)
    if t == "nil" then
        return "null"
    elseif t == "boolean" then
        return value and "true" or "false"
    elseif t == "number" then
        return string.format("%.10g", value)
    elseif t == "string" then
        return '"' .. json_escape(value) .. '"'
    elseif t == "table" then
        -- array if consecutive integer keys from 1
        local n = #value
        local is_arr = n > 0
        if is_arr then
            for i = 1, n do
                if value[i] == nil then
                    is_arr = false
                    break
                end
            end
        end
        local pad = string.rep("  ", indent)
        local pad1 = string.rep("  ", indent + 1)
        if is_arr then
            local parts = { "[" }
            for i = 1, n do
                parts[#parts + 1] = pad1 .. to_json(value[i], indent + 1) .. (i < n and "," or "")
            end
            parts[#parts + 1] = pad .. "]"
            return table.concat(parts, "\n")
        end
        local keys = {}
        for k in pairs(value) do
            keys[#keys + 1] = k
        end
        table.sort(keys, function(a, b)
            return tostring(a) < tostring(b)
        end)
        local parts = { "{" }
        for i, k in ipairs(keys) do
            local comma = i < #keys and "," or ""
            parts[#parts + 1] = pad1
                .. '"'
                .. json_escape(k)
                .. '": '
                .. to_json(value[k], indent + 1)
                .. comma
        end
        parts[#parts + 1] = pad .. "}"
        return table.concat(parts, "\n")
    end
    return "null"
end

-- ---------- ZO live ids ----------
local zo_path = sv_dir .. "/ZO_Ingame.lua"
local zo_env = load_sv(zo_path)
local zo_root = zo_env.ZO_Ingame_SavedVariables
local live_ids = {}
local live_names = {}
local zo_stale_maps = {}

for account, av in pairs(zo_root.Default or {}) do
    if type(account) == "string" and account:sub(1, 1) == "@" and type(av) == "table" then
        for name, nv in pairs(av) do
            if type(name) == "string" and name ~= "$AccountWide" and type(nv) == "table" then
                live_names[name] = true
            end
        end
        local aw = av["$AccountWide"]
        local namechange = aw and aw.NameChange
        if type(namechange) == "table" then
            if namechange[STALE_SEA_WOLF] ~= nil then
                zo_stale_maps[#zo_stale_maps + 1] = account
            end
            for id, char_name in pairs(namechange) do
                if is_char_id(id) and type(char_name) == "string" and id ~= STALE_SEA_WOLF then
                    live_ids[id] = char_name
                    live_names[char_name] = true
                end
            end
        end
    end
end

local zo_stale_present = #zo_stale_maps > 0
report.zo = {
    live_id_count = (function()
        local n = 0
        for _ in pairs(live_ids) do
            n = n + 1
        end
        return n
    end)(),
    stale_sea_wolf_present = zo_stale_present,
    stale_in_accounts = zo_stale_maps,
    removed = zo_stale_present and { STALE_SEA_WOLF } or {},
}

if apply and zo_stale_present then
    for _, account in ipairs(zo_stale_maps) do
        local nc = zo_root.Default[account]["$AccountWide"].NameChange
        nc[STALE_SEA_WOLF] = nil
    end
    write_file(zo_path, serialize.Dump("ZO_Ingame_SavedVariables", zo_root))
end

-- ---------- CharacterMarkdown ----------
local cm_path = sv_dir .. "/CharacterMarkdown.lua"
local cm_env = load_sv(cm_path)
local cm_root = cm_env.CharacterMarkdownSettings
assert(type(cm_root) == "table", "CharacterMarkdownSettings missing")

local all_pcd = {}
collect_pcd(cm_root, all_pcd)

local before_counts = {}
local function count_pcd_at(account, megaserver)
    local aw = cm_root.Default
        and cm_root.Default[account]
        and cm_root.Default[account]["$AccountWide"]
    local ms = aw and aw[megaserver]
    local pcd = ms and ms.perCharacterData
    if type(pcd) ~= "table" then
        return 0
    end
    local n = 0
    for id in pairs(pcd) do
        if is_char_id(id) then
            n = n + 1
        end
    end
    return n
end

for _, account in ipairs({ "@SOLAEGIS", "@vavasour" }) do
    for _, megaserver in ipairs({ "NA Megaserver", "EU Megaserver" }) do
        local key = account .. " / " .. megaserver
        before_counts[key] = count_pcd_at(account, megaserver)
    end
end

-- Best entry per target slot id
local best = {} -- key = account\0megaserver\0id -> {score, entry, name}
local rejected = {}
for _, item in ipairs(all_pcd) do
    local id, name = item.id, item.name
    if id == STALE_SEA_WOLF or not live_ids[id] then
        rejected[#rejected + 1] = {
            id = id,
            name = name,
            reason = "not_in_live_ids",
        }
    else
        local account, megaserver = roster_slot(name, id)
        if not account then
            rejected[#rejected + 1] = {
                id = id,
                name = name,
                reason = "not_in_roster_or_wrong_id",
            }
        else
            local key = account .. "\0" .. megaserver .. "\0" .. id
            local prev = best[key]
            if not prev or item.score > prev.score then
                local entry = shallow_copy_pcd(item.entry)
                entry._accountName = account
                entry._characterName = name
                best[key] = { score = item.score, entry = entry, name = name, account = account, megaserver = megaserver, id = id }
            end
        end
    end
end

-- Ensure every live roster character has a PCD stub if missing
local function ensure_stub(name, id, account, megaserver)
    local key = account .. "\0" .. megaserver .. "\0" .. id
    if best[key] then
        return
    end
    best[key] = {
        score = 0,
        account = account,
        megaserver = megaserver,
        id = id,
        name = name,
        entry = {
            customNotes = "",
            customTitle = "",
            playStyle = "",
            _initialized = true,
            _accountName = account,
            _characterName = name,
        },
    }
end

for id, name in pairs(live_ids) do
    local account, megaserver = roster_slot(name, id)
    if account then
        ensure_stub(name, id, account, megaserver)
    end
end

-- Rebuild CM structure
local nested_removed = 0
local new_default = {}
for _, account in ipairs({ "@SOLAEGIS", "@vavasour" }) do
    local old_aw = cm_root.Default
        and cm_root.Default[account]
        and cm_root.Default[account]["$AccountWide"]
    new_default[account] = { ["$AccountWide"] = {} }
    for _, megaserver in ipairs({ "NA Megaserver", "EU Megaserver" }) do
        local old_ms = old_aw and old_aw[megaserver]
        local slice
        if type(old_ms) == "table" then
            slice = {}
            for k, v in pairs(old_ms) do
                if k ~= "perCharacterData" and k ~= "Default" then
                    -- drop nested account trees only; keep real settings tables
                    if k == "Default" then
                        -- already skipped
                    else
                        slice[k] = v
                    end
                end
            end
            if old_ms.Default ~= nil then
                nested_removed = nested_removed + 1
            end
        else
            -- only create EU for @SOLAEGIS if we have PCD; always keep existing
            slice = nil
        end

        local pcd = {}
        local pcd_n = 0
        for key, info in pairs(best) do
            if info.account == account and info.megaserver == megaserver then
                pcd[info.id] = info.entry
                pcd_n = pcd_n + 1
            end
        end

        if slice or pcd_n > 0 then
            slice = slice or {}
            slice.perCharacterData = pcd
            new_default[account]["$AccountWide"][megaserver] = slice
        end
    end
end

local after_counts = {}
local kept_list = {}
for key, info in pairs(best) do
    local ck = info.account .. " / " .. info.megaserver
    after_counts[ck] = (after_counts[ck] or 0) + 1
    kept_list[#kept_list + 1] = {
        account = info.account,
        megaserver = info.megaserver,
        id = info.id,
        name = info.name,
    }
end
table.sort(kept_list, function(a, b)
    if a.account ~= b.account then
        return a.account < b.account
    end
    if a.megaserver ~= b.megaserver then
        return a.megaserver < b.megaserver
    end
    return a.name < b.name
end)

local had_legacy = cm_root._legacyFlatSnapshot ~= nil

report.character_markdown = {
    had_legacy_flat_snapshot = had_legacy,
    nested_default_slices_cleared = nested_removed,
    pcd_sources_scanned = #all_pcd,
    rejected_count = #rejected,
    rejected_sample = (function()
        local s = {}
        for i = 1, math.min(20, #rejected) do
            s[i] = rejected[i]
        end
        return s
    end)(),
    before_counts = before_counts,
    after_counts = after_counts,
    kept = kept_list,
}

if apply then
    local new_root = {
        _serverSvMigrated = true,
        Default = new_default,
    }
    write_file(cm_path, serialize.Dump("CharacterMarkdownSettings", new_root))
end

-- ---------- Other addon SVs: remove stale char-id keys ----------
local function prune_stale_ids(node, removed)
    if type(node) ~= "table" then
        return
    end
    local to_nil = {}
    for k, v in pairs(node) do
        if is_char_id(k) and not live_ids[k] then
            to_nil[#to_nil + 1] = k
        elseif type(v) == "table" then
            prune_stale_ids(v, removed)
        end
    end
    for _, k in ipairs(to_nil) do
        node[k] = nil
        removed[#removed + 1] = k
    end
end

local skip_files = {
    ["CharacterMarkdown.lua"] = true,
    ["ZO_Ingame.lua"] = true,
}

local addon_reports = {}
local pfile = io.popen('ls -1 "' .. sv_dir .. '"/*.lua 2>/dev/null')
if pfile then
    for line in pfile:lines() do
        local base = line:match("([^/]+)$")
        if base and not base:find("bak", 1, true) and not skip_files[base] then
            local path = line
            local ok, env_or_err = pcall(load_sv, path)
            if ok then
                local env = env_or_err
                -- Some addons emit multiple root globals in one file
                -- (e.g. CraftStore_Account + CraftStore_Character).
                local globals = {}
                for k, v in pairs(env) do
                    if type(v) == "table" then
                        globals[#globals + 1] = k
                    end
                end
                table.sort(globals)
                local removed = {}
                for _, gname in ipairs(globals) do
                    prune_stale_ids(env[gname], removed)
                end
                if #removed > 0 then
                    local uniq = {}
                    local counts = {}
                    for _, id in ipairs(removed) do
                        counts[id] = (counts[id] or 0) + 1
                        uniq[id] = true
                    end
                    local uniq_list = {}
                    for id in pairs(uniq) do
                        uniq_list[#uniq_list + 1] = id
                    end
                    table.sort(uniq_list)
                    addon_reports[#addon_reports + 1] = {
                        file = base,
                        removed_key_count = #removed,
                        unique_ids = uniq_list,
                        id_counts = counts,
                        globals = globals,
                    }
                    if apply then
                        local chunks = {}
                        for _, gname in ipairs(globals) do
                            chunks[#chunks + 1] = serialize.Dump(gname, env[gname])
                        end
                        write_file(path, table.concat(chunks, "\n"))
                    end
                end
            else
                addon_reports[#addon_reports + 1] = {
                    file = base,
                    error = tostring(env_or_err),
                }
            end
        end
    end
    pfile:close()
end

table.sort(addon_reports, function(a, b)
    return (a.file or "") < (b.file or "")
end)
report.addons = addon_reports

write_file(report_path, to_json(report) .. "\n")
print(apply and "APPLY complete" or "DRY-RUN complete")
print("report: " .. report_path)
