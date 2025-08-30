local compileSource = loadstring(game:HttpGet("https://raw.githubusercontent.com/LuckyScripters/Vital/refs/heads/main/vLuau/Yueliang.luau", true))()
local createExecutable = loadstring(game:HttpGet("https://raw.githubusercontent.com/LuckyScripters/Vital/refs/heads/main/vLuau/FiOne.luau", true))()

local randomGenerator = Random.new()
local checkcaller, print, pcall, rawget, getfenv, setfenv = checkcaller, print, pcall, rawget, getfenv, setfenv
local executorEnvironment, registeryEnvironment = table.clone(getgenv()), table.clone(getrenv())

local function generateScriptName(length)
    local name = {}
    local characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    for _ = 1, length do
        local index = randomGenerator:NextInteger(1, string.len(characters))
        table.insert(name, string.sub(characters, index, index))
    end
    return "[" .. table.concat(name, "", 1, table.maxn(name)) .. "]"
end

return function(sourceCode, environment)
    local executable = nil
    local scriptName = generateScriptName(randomGenerator:NextInteger(5, 10))
    environment = environment or getfenv(2)
    local success, result = pcall(function()
        local bytecode = compileSource(sourceCode, scriptName)
        executable = createExecutable(bytecode, environment)
    end)
    if success then
        return setfenv(executable, environment)
    end
    return nil, result
end
