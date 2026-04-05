repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local placeId = game.PlaceId

local fruitFound = nil
local autoHop = false
local autoScan = false
local espHighlight = nil

--------------------------------------------------
-- GUI
--------------------------------------------------

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui

local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0,230,0,210)
Frame.Position = UDim2.new(0.02,0,0.3,0)
Frame.BackgroundTransparency = 0.2
Frame.Active = true
Frame.Draggable = true

local function makeButton(text, y)

    local btn = Instance.new("TextButton")
    btn.Parent = Frame
    btn.Size = UDim2.new(1,0,0.18,0)
    btn.Position = UDim2.new(0,0,y,0)
    btn.Text = text

    return btn

end

local ScanButton = makeButton("Scan For Fruit",0)
local TeleportButton = makeButton("Teleport To Fruit",0.2)
local ESPButton = makeButton("ESP: OFF",0.4)
local AutoScanButton = makeButton("Auto Scan: OFF",0.6)
local HopToggle = makeButton("Auto Hop: OFF",0.8)

--------------------------------------------------
-- NOTIFICATION
--------------------------------------------------

local function notify(msg)

    game.StarterGui:SetCore("SendNotification",{
        Title="Fruit Helper",
        Text=msg,
        Duration=5
    })

end

--------------------------------------------------
-- FIND FRUIT
--------------------------------------------------

local function findFruit()

    fruitFound=nil

    for _,obj in pairs(Workspace:GetDescendants()) do

        if obj:IsA("Tool") and string.find(obj.Name:lower(),"fruit") then
            fruitFound=obj
            return obj
        end

    end

end

--------------------------------------------------
-- DISTANCE CHECK
--------------------------------------------------

local function getDistance(obj)

    if not obj then return end

    local hrp=player.Character and player.Character:FindFirstChild("HumanoidRootPart")

    if not hrp then return end

    local handle=obj:FindFirstChild("Handle")

    if not handle then return end

    return math.floor((hrp.Position-handle.Position).Magnitude)

end

--------------------------------------------------
-- ESP SYSTEM
--------------------------------------------------

local function applyESP(obj)

    if espHighlight then
        espHighlight:Destroy()
        espHighlight=nil
    end

    if obj and obj:FindFirstChild("Handle") then

        espHighlight=Instance.new("Highlight")
        espHighlight.Parent=obj
        espHighlight.FillTransparency=0.5

    end

end

--------------------------------------------------
-- SERVER HOP
--------------------------------------------------

local function serverHop()

    notify("Server hopping...")

    local req=game:HttpGet(
        "https://games.roblox.com/v1/games/"
        ..placeId..
        "/servers/Public?sortOrder=Asc&limit=100"
    )

    local data=HttpService:JSONDecode(req)

    for _,server in pairs(data.data) do

        if server.playing<server.maxPlayers then

            TeleportService:TeleportToPlaceInstance(
                placeId,
                server.id,
                player
            )

            break
        end

    end

end

--------------------------------------------------
-- BUTTON EVENTS
--------------------------------------------------

ScanButton.MouseButton1Click:Connect(function()

    local fruit=findFruit()

    if fruit then

        local distance=getDistance(fruit)

        notify("Fruit: "..fruit.Name.." ("..distance.." studs)")

        if espHighlight then
            applyESP(fruit)
        end

    else

        notify("No fruit detected")

        if autoHop then
            task.wait(2)
            serverHop()
        end

    end

end)

--------------------------------------------------

TeleportButton.MouseButton1Click:Connect(function()

    if fruitFound and fruitFound:FindFirstChild("Handle") then

        player.Character.HumanoidRootPart.CFrame=
        fruitFound.Handle.CFrame+Vector3.new(0,3,0)

        notify("Teleported to "..fruitFound.Name)

    else

        notify("Scan first!")

    end

end)

--------------------------------------------------

ESPButton.MouseButton1Click:Connect(function()

    if espHighlight then

        espHighlight:Destroy()
        espHighlight=nil
        ESPButton.Text="ESP: OFF"

    else

        if fruitFound then
            applyESP(fruitFound)
        end

        ESPButton.Text="ESP: ON"

    end

end)

--------------------------------------------------

AutoScanButton.MouseButton1Click:Connect(function()

    autoScan=not autoScan

    AutoScanButton.Text=
        autoScan and "Auto Scan: ON"
        or "Auto Scan: OFF"

end)

--------------------------------------------------

HopToggle.MouseButton1Click:Connect(function()

    autoHop=not autoHop

    HopToggle.Text=
        autoHop and "Auto Hop: ON"
        or "Auto Hop: OFF"

end)

--------------------------------------------------
-- AUTO SCAN LOOP
--------------------------------------------------

RunService.RenderStepped:Connect(function()

    if autoScan then

        local fruit=findFruit()

        if fruit then

            local distance=getDistance(fruit)

            notify("Fruit detected: "..fruit.Name.." ("..distance.." studs)")

            if espHighlight then
                applyESP(fruit)
            end

            autoScan=false
            AutoScanButton.Text="Auto Scan: OFF"

        elseif autoHop then

            serverHop()

        end

        task.wait(10)

    end

end)
