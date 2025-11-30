
local result = "Some content\n\n---\n\n"
local hasSeparator = result:match("%-%-%-%s*$")
print("Result: '" .. result:gsub("\n", "\\n") .. "'")
print("Has separator: " .. tostring(hasSeparator))

local result2 = "Some content\n\n---"
local hasSeparator2 = result2:match("%-%-%-%s*$")
print("Result2: '" .. result2:gsub("\n", "\\n") .. "'")
print("Has separator2: " .. tostring(hasSeparator2))

local result3 = "Some content\n\n   ---   \n\n"
local hasSeparator3 = result3:match("%-%-%-%s*$")
print("Result3: '" .. result3:gsub("\n", "\\n") .. "'")
print("Has separator3: " .. tostring(hasSeparator3))
