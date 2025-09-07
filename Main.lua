(function(debugMode)
    if VITAL_RUNNING then
        return
    end

    local Workspace = cloneref(game:GetService("Workspace"))
    local ReplicatedFirst = cloneref(game:GetService("ReplicatedFirst"))

    local cheat = {LoadedTime = Workspace:GetServerTimeNow(), DebugMode = debugMode, SendDebug = function(_, messageType, message, traceback)
        local timestamp = os.date("%Y-%m-%d %H:%M:%S")
        local source = debug.info(2, "s")
        if not source or source == "" then 
            source = "Unknown Source" 
        end
        local functionName = debug.info(2, "n")
        if not functionName or functionName == "" then 
            functionName = "Unknown Function" 
        end
        local line = debug.info(2, "l")
        if not line then 
            line = "Unknown Line" 
        end
        local formattedMessage = traceback and string.format("Vital Debug: \n - Timestamp: %s \n - Info: \n \t -> Source: %s \n \t -> Function: %s \n \t -> Line: %s \n - Message: %s", timestamp, source, functionName, line, message) or string.format("Vital Debug: \n - Timestamp: %s \n - Message: %s", timestamp, message)
        if messageType == "Output" then
            print(formattedMessage)
        elseif messageType == "Warning" then
            warn(formattedMessage)
        elseif messageType == "Error" then
            error(formattedMessage, 2)
        end
    end, Crash = function(self)
        if LPH_OBFUSCATED then
            LPH_CRASH()
        end
        while true do
            task.spawn(self.Crash)
        end
    end, MemoryCategory = table.concat((function()
        local characterList = {}
        for index = 1, 50 do
            local asciiCharacter = string.char(bit32.band(index * 3, 0x7F))
            local unicodeCharacter = utf8.char(0x20 + (index % 200))
            local bitExtractedCharacter = string.char(bit32.extract(index * 42, 2, 5))
            table.insert(characterList, asciiCharacter .. unicodeCharacter .. bitExtractedCharacter)
        end
        return characterList
    end)(), "")}
    local importedModules = {}

    if LPH_OBFUSCATED then
        local repoLink = "https://raw.githubusercontent.com/LuckyScripters/Vital/refs/heads/main/Games/"
        local compiledFile = game:HttpGet(repoLink .. tostring(game.PlaceId) .. ".luau")
        if not compiledFile then
            return nil
        end
        local executable, compileFailReason = loadstring(compiledFile)
        if not executable or typeof(executable) ~= "function" then
            if debugMode then
                cheat:SendDebug("Warning", "Error when loading the compiled file" .. " " .. "|" .. " " .. (compileFailReason or "Unknown error"), true)
            end
            return nil
        end
        local success, accessPath = pcall(executable)
        if not success then
            if debugMode then
                cheat:SendDebug("Warning", "Error when executing the compiled file" .. " " .. "|" .. " " .. (compileFailReason or "Unknown error"), true)
            end
            return nil
        end
        cheat.AccessPath = accessPath
        cheat:SendDebug("Output", "Successfully loaded Normal access", false)
    else
        local folderName = "Vital.wtf"
        local fileFullPath = folderName .. "/" .. tostring(game.GameId) .. ".lua"
        if not isfile(fileFullPath) then
            return nil
        end
        local fileContent = readfile(fileFullPath)
        local executable, compileFailReason = loadstring(fileContent)
        if not executable or typeof(executable) ~= "function" then
            if debugMode then
                cheat:SendDebug("Warning", "Error when loading the compiled file" .. "|" .. " " .. (compileFailReason or "Unknown error"), true)
            end
            return nil
        end
        local success, accessPath = pcall(executable)
        if not success then
            if debugMode then
                cheat:SendDebug("Warning", "Error when executing the compiled file" .. "|" .. " " .. (compileFailReason or "Unknown error"), true)
            end
            return nil
        end
        cheat.AccessPath = accessPath
        cheat:SendDebug("Output", "Successfully loaded Developer access", false)
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Luraph/macrosdk/main/luraphsdk.lua"))()
    end

    debug.setmemorycategory(cheat.MemoryCategory)

    getgenv().MODULE_IMPORT = LPH_NO_VIRTUALIZE(function(path)
        if debug.getmemorycategory() ~= cheat.MemoryCategory then
            return cheat:Crash()
        end
        if importedModules[path] then
            return importedModules[path]
        end
        if LPH_OBFUSCATED then
            local splittedPath = string.split(path, "/")
            for _, piecePath in splittedPath do
                accessPath = accessPath[piecePath]
                if typeof(accessPath) == "function" then
                    break
                end
            end
            if typeof(accessPath) ~= "function" then
                return nil
            end
            local success, loaded = pcall(accessPath, cheat)
            if not success then
                if debugMode then
                    local splittedPath = string.split(path, "/")
                    cheat:SendDebug("Warning", "Failed to load" .. " " .. splittedPath[table.maxn(splittedPath)] .. " | " .. (loaded or "Unknown error"))
                end
                return nil
            end
            importedModules[path] = loaded or true
        else
            local currentPath = cheat.AccessPath
            local splittedPath = string.split(path, "/")
            for _, piecePath in splittedPath do
                currentPath = currentPath[piecePath]
                if typeof(currentPath) == "function" then
                    break
                end
            end
            if typeof(currentPath) ~= "function" then
                return nil
            end
            local success, loaded = pcall(currentPath, cheat)
            if not success then
                if debugMode then
                    local splittedPath = string.split(path, "/")
                    cheat:SendDebug("Warning", "Failed to load" .. " " .. splittedPath[table.maxn(splittedPath)] .. " | " .. (loaded or "Unknown error"))
                end
                return nil
            end
            importedModules[path] = loaded or true
        end
        return importedModules[path]
    end)

    if game.GameId == 358276974 then
        local framework = require(ReplicatedFirst:WaitForChild("Framework"))
        framework:WaitForLoaded()
    
        local modules = {
            Classes = table.clone(framework.Classes),
            Configs = table.clone(framework.Configs),
            Libraries = table.clone(framework.Libraries),
            Interface = table.clone(framework.Interface)
        }
    
        getgenv().GET_MODULE = LPH_NO_VIRTUALIZE(function(path)
            setthreadidentity(6)
            if typeof(path) == "string" then
                local splittedPath = string.split(path, "/")
                if modules[splittedPath[1]] and modules[splittedPath[1]][splittedPath[2]] then
                    return modules[splittedPath[1]][splittedPath[2]]
                end
                if debugMode then
                    cheat:SendDebug("Warning", "Failed to require:" .. " " .. splittedPath[2] .. " " .. "inside" .. " " .. splittedPath[1], true)
                end
            elseif typeof(path) == "Instance" and path:IsA("ModuleScript") then
                local success, result = pcall(require, path)
                if success then
                    return result
                end
                if debugMode then
                    cheat:SendDebug("Warning", "Failed to require:" .. " " .. path:GetFullName(), true)
                end
                return nil
            else
                if debugMode then
                    cheat:SendDebug("Warning", "Invalid path:" .. " " .. (typeof(path) == "Instance" and path:GetFullName() or tostring(path)), true)
                end
                return nil
            end
        end)
    
        getgenv().GET_SERVICE = LPH_NO_VIRTUALIZE(function(service)
            local success, result = pcall(function()
                setthreadidentity(6)
                return game:GetService(service) or game:FindService(service)
            end)
            if not success then
                if debugMode then
                    cheat:SendDebug("Warning", "Error when searching" .. " " .. service .. " " .. "|" .. " " .. (result or "Unknown error"), true)
                end
                return nil
            end
            return typeof(result) == "Instance" and cloneref(result) or nil
        end)
            
        local utilities = MODULE_IMPORT("Libraries/Utilities.lua")
    
        cheat.Library = MODULE_IMPORT("Libraries/UI.lua")
        cheat.ESP = MODULE_IMPORT("Libraries/ESP.lua")
    
        utilities.General:DisableLogs()
    
        if LPH_OBFUSCATED then
            for _, tab in {"Combat", "Visuals", "Rage", "Miscellaneous", "Settings"} do
                MODULE_IMPORT("Tabs/" .. tab .. ".lua")
            end
        else
            for _, tab in {"Combat", "Visuals", "Rage", "Miscellaneous", "Settings", "Private"} do
                MODULE_IMPORT("Tabs/" .. tab .. ".lua")
            end
        end
    
        cheat.Library:Init()
    
        for _, feature in {"BulletHooks", "CharacterHooks", "MiscellaneousHooks", "NetworkHooks"} do
            MODULE_IMPORT("Features/" .. feature .. ".lua")
        end
    else
        warn("Vital doesn't support this game/place")
    end
    getgenv().VITAL_RUNNING = true
end)(Vital_DEBUG_MODE or false)