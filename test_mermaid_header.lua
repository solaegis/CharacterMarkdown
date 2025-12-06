-- Test script to verify Mermaid header generation
local markdown = ""

-- Simulate the generation logic from ChampionDiagram.lua
markdown = markdown .. "```mermaid\n"
markdown = markdown
    .. "%%{init: {'theme':'base', 'themeVariables': { 'background':'transparent','fontSize':'14px','primaryColor':'#e8f4f0','primaryTextColor':'#000','primaryBorderColor':'#4a9d7f','lineColor':'#999','secondaryColor':'#f0f4f8','tertiaryColor':'#faf0f0'}}}%%\n"
markdown = markdown .. "graph LR\n"

print("Generated Markdown Header:")
print(markdown)

-- Check for the specific issue (empty line between init and graph LR)
-- Note: % is a magic character in Lua patterns, so %% matches a single %, and %%%% matches two %
if markdown:match("}}}%%%%\n\ngraph LR") then
    print("\nFAILURE: Found empty line between init and graph LR")
elseif markdown:match("}}}%%%%\ngraph LR") then
    print("\nSUCCESS: No empty line between init and graph LR")
else
    print("\nFAILURE: Unexpected format")
end
