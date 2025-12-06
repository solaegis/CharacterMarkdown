-- Test script to verify node ID sanitization
local skillName = "Fortune's Favor"
local disciplineName = "Craft"

-- Simulate the sanitization logic from ChampionDiagram.lua
-- Original logic: skill.name:gsub(" ", "_")
-- New logic: skill.name:gsub("[^%w]", "_")

local sanitized = string.format("%s_%s", disciplineName:sub(1, 1), skillName:gsub("[^%w]", "_"))

print("Original Name: " .. skillName)
print("Sanitized ID: " .. sanitized)

if sanitized == "C_Fortune_s_Favor" then
    print("\nSUCCESS: Special characters replaced with underscores")
elseif sanitized == "C_Fortunes_Favor" then
     -- Depending on how gsub works with multiple matches, it might replace ' with _
     print("\nSUCCESS: Special characters removed/replaced")
else
    print("\nFAILURE: Unexpected sanitization result: " .. sanitized)
end

-- Test another case
local skillName2 = "Star-Gazer"
local sanitized2 = string.format("%s_%s", disciplineName:sub(1, 1), skillName2:gsub("[^%w]", "_"))
print("\nOriginal Name: " .. skillName2)
print("Sanitized ID: " .. sanitized2)

if sanitized2:match("[^%w_]") then
    print("\nFAILURE: Sanitized ID contains special characters")
else
    print("\nSUCCESS: Sanitized ID contains only alphanumeric and underscores")
end
