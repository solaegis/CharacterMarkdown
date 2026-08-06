-- CharacterMarkdown - LibAsync Integration Helper
-- Optional frame-yielding helpers for heavy collectors. Falls back to sync when absent.

local CM = CharacterMarkdown

local string_format = string.format
local GetGameTimeMilliseconds = GetGameTimeMilliseconds

local function IsLibAsyncAvailable()
    return LibAsync ~= nil and type(LibAsync) == "table" and type(LibAsync.Create) == "function"
end

--- Run fn and return result plus elapsed milliseconds (for DebugPrint timing).
local function TimedCall(label, fn)
    local startMs = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0
    local success, result = pcall(fn)
    local elapsed = 0
    if GetGameTimeMilliseconds then
        elapsed = GetGameTimeMilliseconds() - startMs
    end

    if CM.DebugPrint then
        CM.DebugPrint(
            "LIBASYNC",
            string_format("%s: %s in %dms", label or "call", success and "ok" or "FAIL", elapsed)
        )
    end

    return success, result, elapsed
end

--- Create a named LibAsync task, or nil when the library is missing.
local function CreateTask(name)
    if not IsLibAsyncAvailable() then
        return nil
    end
    local ok, task = pcall(function()
        return LibAsync:Create(name or "CharacterMarkdown")
    end)
    if ok then
        return task
    end
    return nil
end

--- Run a list of { name, key, enabled, fn } collector steps with optional frame yields.
-- onComplete(results) where results[key] = collector return value (or {} on failure).
-- When LibAsync is unavailable, runs all enabled steps synchronously then calls onComplete.
local function RunCollectorChain(steps, onComplete, onError)
    local results = {}
    local timings = {}

    local function finish()
        if CM.DebugPrint then
            local parts = {}
            for _, step in ipairs(steps) do
                if step.enabled and timings[step.key] then
                    table.insert(parts, string_format("%s=%dms", step.key, timings[step.key]))
                end
            end
            if #parts > 0 then
                CM.DebugPrint("LIBASYNC", "Collector timings: " .. table.concat(parts, ", "))
            end
        end
        if onComplete then
            onComplete(results, timings)
        end
    end

    local function runStep(step)
        if not step.enabled or not step.fn then
            results[step.key] = nil
            return
        end
        local success, result, elapsed = TimedCall(step.name, step.fn)
        timings[step.key] = elapsed
        if success then
            results[step.key] = result
        else
            results[step.key] = {}
            if CM.Error then
                CM.Error(string.format("[FAIL] Collect %s failed: %s", step.name, tostring(result)))
            end
            if onError then
                onError(step.name, result)
            end
        end
    end

    local task = CreateTask("CharacterMarkdown-Collectors")
    if not task then
        for _, step in ipairs(steps) do
            runStep(step)
        end
        finish()
        return false -- ran synchronously
    end

    local chain = nil
    for _, step in ipairs(steps) do
        if step.enabled and step.fn then
            local captured = step
            if not chain then
                chain = task:Call(function()
                    runStep(captured)
                end)
            else
                chain = chain:Then(function()
                    runStep(captured)
                end)
            end
        else
            results[step.key] = nil
        end
    end

    if not chain then
        finish()
        return false
    end

    chain:Then(function()
        finish()
    end)

    return true -- scheduled asynchronously
end

CM.utils = CM.utils or {}
CM.utils.LibAsyncIntegration = {
    IsLibAsyncAvailable = IsLibAsyncAvailable,
    TimedCall = TimedCall,
    CreateTask = CreateTask,
    RunCollectorChain = RunCollectorChain,
}

return CM.utils.LibAsyncIntegration
