local compileSource = loadstring(game:HttpGet("https://raw.githubusercontent.com/LuckyScripters/Vital/refs/heads/main/vLuau/Yueliang.luau", true))()
local createExecutable = loadstring(game:HttpGet("https://raw.githubusercontent.com/LuckyScripters/Vital/refs/heads/main/vLuau/FiOne.luau", true))()

getfenv().script = nil

return function(sourceCode, environment)
    environment = environment or getfenv(2)
    local executable = nil
    local scriptName = environment.script and environment.script:GetFullName()
    local success, result = pcall(function()
        local bytecode = compileSource(sourceCode, scriptName)
        executable = createExecutable(bytecode, environment)
    end)
    if success then
        return setfenv(executable, environment)
    end
    return nil, result
end
