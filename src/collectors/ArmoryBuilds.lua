-- CharacterMarkdown - Armory Builds Data Collector
-- Composition logic moved from API layer

local CM = CharacterMarkdown

local function CollectArmoryBuildsData()
    local unlocked = CM.api.armoryBuilds.GetNumUnlocked()
    local maxBuilds = CM.api.armoryBuilds.GetMaxBuilds and CM.api.armoryBuilds.GetMaxBuilds() or 10

    local data = {
        unlocked = unlocked or 0,
        builds = {},
    }

    if data.unlocked > 0 then
        for buildIndex = 1, data.unlocked do
            local buildInfo = CM.api.armoryBuilds.GetBuildInfo(buildIndex)
            if buildInfo then
                table.insert(data.builds, buildInfo)
            end
        end

        table.sort(data.builds, function(a, b)
            return (a.name or "") < (b.name or "")
        end)
    end

    local maxSlots = maxBuilds > 0 and maxBuilds or 10
    data.summary = {
        totalBuilds = #data.builds,
        unlockedSlots = data.unlocked,
        maxBuilds = maxSlots,
        utilizationPercent = math.floor((data.unlocked / maxSlots) * 100),
    }

    return data
end

CM.collectors.CollectArmoryBuildsData = CollectArmoryBuildsData

CM.DebugPrint("COLLECTOR", "ArmoryBuilds collector module loaded")
