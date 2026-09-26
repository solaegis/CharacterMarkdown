-- CharacterMarkdown - Markdown Formatter
-- Redirects to the modular, unified markdown generation engine

local CM = CharacterMarkdown

CM.formatters = CM.formatters or {}

-- Redirect to generators/Markdown.lua to prevent split-brain behavior
CM.formatters.GenerateMarkdown = function(...)
    if CM.generators and CM.generators.GenerateMarkdown then
        return CM.generators.GenerateMarkdown(...)
    else
        CM.Error("Modular generator engine not loaded!")
        return ""
    end
end

-- Shared async-aware entry (same as CM.generators.Run)
CM.formatters.Run = function(onDone, onError)
    if CM.generators and CM.generators.Run then
        return CM.generators.Run(onDone, onError)
    else
        CM.Error("Modular generator engine not loaded!")
        if type(onError) == "function" then
            onError("Modular generator engine not loaded!")
        end
    end
end
