
-- Mock CM environment
local CM = {
    utils = {
        markdown = {},
        FormatNumber = function(n) return tostring(n) end
    },
    links = {
        CreateAllianceLink = function(name) return name end,
        CreateZoneLink = function(name) return name end
    }
}

-- Mock CreateSeparator from AdvancedMarkdown.lua
local function CreateSeparator(style, emoji)
    style = style or "hr"
    if style == "hr" then
        return "---\n\n"
    else
        return "\n\n"
    end
end
CM.utils.markdown.CreateSeparator = CreateSeparator

-- Mock CreateStyledTable (simplified)
CM.utils.markdown.CreateStyledTable = function(headers, rows, options)
    local md = "| " .. table.concat(headers, " | ") .. " |\n"
    md = md .. "| --- | --- | --- | --- |\n"
    for _, row in ipairs(rows) do
        md = md .. "| " .. table.concat(row, " | ") .. " |\n"
    end
    md = md .. "\n"
    return md
end

-- Mock GenerateGuilds logic (simplified from Guilds.lua)
local function GenerateGuilds(guildsData, format, undauntedPledgesData)
    local markdown = ""
    local guildsList = guildsData.list

    markdown = markdown .. "## 🏰 Guild Membership\n\n"

    if #guildsList > 0 then
        local headers = { "Guild Name", "Rank", "Members", "Alliance" }
        local rows = {}
        for _, guild in ipairs(guildsList) do
            table.insert(rows, {
                "**" .. (guild.name or "Unknown") .. "**",
                guild.rank or "Member",
                tostring(guild.memberCount),
                guild.alliance
            })
        end
        markdown = markdown .. CM.utils.markdown.CreateStyledTable(headers, rows)
    end

    markdown = markdown .. "---\n\n"
    return markdown
end

-- Test data
local guildsData = {
    list = {
        { name = "Guild A", rank = "Member", memberCount = 100, alliance = "Aldmeri Dominion" },
        { name = "Guild B", rank = "Officer", memberCount = 200, alliance = "Ebonheart Pact" }
    }
}

-- Generate output
local result = GenerateGuilds(guildsData, "markdown", nil)

-- Test regex from GenerateMarkdown.lua
local hasSeparator = result:match("%-%-%-%s*$") or result:match("<hr>%s*$") or result:match("<hr%s*/>%s*$")

print("Result tail: '" .. result:sub(-20):gsub("\n", "\\n") .. "'")
print("Has separator: " .. tostring(hasSeparator))

-- Debug hex
local tail = result:sub(-20)
local tailHex = ""
for i = 1, #tail do
    tailHex = tailHex .. string.format("%02X ", string.byte(tail, i))
end
print("Tail Hex: " .. tailHex)
