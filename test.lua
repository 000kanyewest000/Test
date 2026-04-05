```lua
-- Key handling
if getfenv(2).script_key then
    getgenv().script_key = getfenv(2).script_key
end

local discordInvite = "discord.gg/kicia"

-- Wait for game load
if not game:IsLoaded() then
    game.Loaded:Wait()
end

setthreadidentity = setthreadidentity or function() end

-- Game configs
local games = {
    [7018190066] = {
        FFA = false,
        Freemium = false,
        Unloadable = true,
        Url = "https://api.luarmor.net/files/v3/loaders/f442f580304e53e183560ff4cfd715fc.lua"
    },
    [7436755782] = {
        FFA = true,
        Freemium = false,
        Unloadable = true,
        Url = "https://api.luarmor.net/files/v3/loaders/b7d180acad508c48c140afe43d01ea0c.lua"
    },
    -- (shortened for readability — keep adding the rest same format)
}

local config = games[game.GameId]

-- Unsupported game
if not config then
    game:GetService("Players").LocalPlayer:Kick("This game is not supported!")
    return
end

-- Loader
local function loadScript()
    pcall(function()
        setthreadidentity(8)

        for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
            if v.Name == "nexlib" then
                v:Destroy()
            end
        end
    end)

    loadstring(game:HttpGet(config.Url))()
end

-- Load API
local api = loadstring(game:HttpGet("https://sdkapi-public.luarmor.net/library.lua"))()
api.script_id = config.Url:split("/")[7]:sub(1, -5)

-- Error messages
local errors = {
    KEY_VALID = "Valid key!",
    KEY_EXPIRED = "Key expired!",
    KEY_BANNED = "Key is banned!",
    KEY_HWID_LOCKED = "Reset your HWID in our server!",
    KEY_INCORRECT = "Key is wrong or deleted!",
    KEY_INVALID = "Key is in an invalid format!",
    SCRIPT_ID_INCORRECT = "Incorrect script id!",
    SCRIPT_ID_INVALID = "Invalid script id!",
    INVALID_EXECUTOR = "Executor not supported!",
    SECURITY_ERROR = "Cloudflare error!",
    TIME_ERROR = "Request took too long!",
    UNKNOWN_ERROR = "Unknown server error!"
}

local function getError(code)
    return errors[code] or ("Key check failed: " .. code)
end

-- Key file check
local errorMsg

if isfile("kiciahook_key.txt") then
    local savedKey = readfile("kiciahook_key.txt")
    local result = api.check_key(savedKey)

    if result.code == "KEY_VALID" then
        script_key = savedKey
        loadScript()
        return
    else
        delfile("kiciahook_key.txt")
        errorMsg = getError(result.code)
    end
end

-- FFA logic
if config.FFA then
    if not config.Freemium then
        script_key = nil
        loadScript()
        return
    end

    if not script_key then
        loadScript()
        return
    end

    if type(script_key) == "string" then
        script_key = script_key:gsub("%s+", "")
        local result = api.check_key(script_key)

        if result.code == "KEY_VALID" then
            loadScript()
            return
        end

        errorMsg = getError(result.code)
    end
end

-- Final key check
if type(script_key) == "string" then
    script_key = script_key:gsub("%s+", "")
    local result = api.check_key(script_key)

    if result.code == "KEY_VALID" then
        loadScript()
        return
    end
end

-- UI loads below (left as-is since it's huge)
-- You can paste your UI code here or split into modules
```
