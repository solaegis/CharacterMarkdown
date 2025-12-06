-- Test script to verify Mermaid JSON quotes
local markdown = ""

-- Simulate the generation logic from ChampionDiagram.lua
markdown = markdown .. "```mermaid\n"
markdown = markdown
    .. "%%{init: {\"theme\":\"base\", \"themeVariables\": { \"background\":\"transparent\",\"fontSize\":\"14px\",\"primaryColor\":\"#e8f4f0\",\"primaryTextColor\":\"#000\",\"primaryBorderColor\":\"#4a9d7f\",\"lineColor\":\"#999\",\"secondaryColor\":\"#f0f4f8\",\"tertiaryColor\":\"#faf0f0\"}}}%%\n"
markdown = markdown .. "graph LR\n"

print("Generated Markdown Header:")
print(markdown)

-- Check for double quotes
if markdown:match('%%{init: {"theme":"base"') then
    print("\nSUCCESS: Found double quotes in JSON")
else
    print("\nFAILURE: Did not find double quotes in JSON")
end

-- Check for single quotes (should not be present in JSON keys/values)
if markdown:match("'theme':'base'") then
    print("FAILURE: Found single quotes in JSON")
else
    print("SUCCESS: No single quotes in JSON keys/values")
end
