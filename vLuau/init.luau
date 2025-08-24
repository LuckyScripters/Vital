local compileSource = loadstring(game:HttpGet("https://raw.githubusercontent.com/LuckyScripters/Vital/refs/heads/main/vLuau/Yueliang.luau", true))()
local createExecutable = loadstring(game:HttpGet("https://raw.githubusercontent.com/LuckyScripters/Vital/refs/heads/main/vLuau/FiOne.luau", true))()

getfenv().script = nil

local randomGenerator = Random.new()
local checkcaller, print, pcall, table, rawget, getfenv, setfenv = checkcaller, print, pcall, table, rawget, getfenv, setfenv
local executorEnvironment, registeryEnvironment = getgenv(), getrenv()

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
    debug.setmemorycategory(scriptName)
    environment = environment or getfenv(2)
    environment.script = nil
    setmetatable(environment, {
        __index = function(_, index)
            if not checkcaller() or debug.getmemorycategory() ~= scriptName then
                return nil
            end
            if registeryEnvironment[index] then
                return registeryEnvironment[index]
            end
            if executorEnvironment[index] then
                return executorEnvironment[index]
            end
            return rawget(environment, index)
        end,
    })
    environment = table.freeze(environment)
    local success, result = pcall(function()
        local bytecode = compileSource(sourceCode, scriptName)
        executable = createExecutable(bytecode, environment)
    end)
    if success then
        return setfenv(executable, environment)
    end
    return nil, result
end
