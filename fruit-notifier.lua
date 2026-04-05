-- Blox Fruits Fruit Notifier + Auto Server Hop
-- Made for loader-based hubs

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local placeId = game.PlaceId

-- SETTINGS
local checkDelay = 10 -- seconds between checks
local notifyDuration = 5

-- SIMPLE NOTIFICATION FUNCTION
local function notify(text)
    game.StarterGui:SetCore("SendNotification", {
        Title = "Fruit Notifier",
        Text = text,
        Duration = notifyDuration
    })
end

-- CHECK FOR FRUITS
local function fruitExists()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if string.find(obj.Name:lower(), "fruit") then
            return true
        end
    end
    return false
end

-- SERVER HOP FUNCTION
local function serverHop()
    notify("No fruit found. Server hopping...")
    wait(2)

    local servers = {}
    local req = game:HttpGet(
        "https://games.roblox.com/v1/games/" ..
        placeId ..
        "/servers/Public?sortOrder=Asc&limit=100"
    )

    local data = game:GetService("HttpService"):JSONDecode(req)

    for _, server in pairs(data.data) do
        if server.playing < server.maxPlayers then
            TeleportService:TeleportToPlaceInstance(
                placeId,
                server.id,
                player
            )
            break
        end
    end
end

-- MAIN LOOP
while true do
    task.wait(checkDelay)

    if fruitExists() then
        notify("Fruit detected in server!")
        break
    else
        serverHop()
    end
end
