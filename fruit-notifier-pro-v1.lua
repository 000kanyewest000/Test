repeat task.wait() until game:IsLoaded()

--------------------------------------------------
-- SERVICES
--------------------------------------------------

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local placeId = game.PlaceId
local jobId = game.JobId

--------------------------------------------------
-- SETTINGS
--------------------------------------------------

local WARNING_DISTANCE = 120
local DANGER_DISTANCE = 60

local autoScan = true
local autoHopUnsafe = true

--------------------------------------------------
-- GUI BASE
--------------------------------------------------

local gui = Instance.new("ScreenGui", game.CoreGui)

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,300,0,260)
frame.Position = UDim2.new(0.02,0,0.25,0)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0.15,0)
title.Text = "Fruit Helper Pro"
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1,1,1)

local statusLabel = Instance.new("TextLabel", frame)
statusLabel.Size = UDim2.new(1,0,0.15,0)
statusLabel.Position = UDim2.new(0,0,0.15,0)
statusLabel.Text = "Scanning..."
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextScaled = true
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.new(1,1,1)

--------------------------------------------------
-- NOTIFICATIONS
--------------------------------------------------

local function notify(text)

game.StarterGui:SetCore("SendNotification",{
Title="Fruit Helper Pro",
Text=text,
Duration=4
})

end

--------------------------------------------------
-- FIND FRUIT
--------------------------------------------------

local fruit
local fruitESP

local function findFruit()

fruit=nil

for _,obj in pairs(Workspace:GetDescendants()) do

if obj:IsA("Tool")
and string.find(obj.Name:lower(),"fruit") then

fruit=obj
return obj

end
end
end

--------------------------------------------------
-- FRUIT ESP
--------------------------------------------------

local function applyFruitESP(obj)

if fruitESP then
fruitESP:Destroy()
end

if obj and obj:FindFirstChild("Handle") then

fruitESP=Instance.new("Highlight")
fruitESP.Parent=obj
fruitESP.FillColor=Color3.fromRGB(0,255,0)
fruitESP.FillTransparency=0.4

end
end

--------------------------------------------------
-- PLAYER HIGHLIGHT ESP
--------------------------------------------------

local playerHighlights={}

local function applyPlayerESP()

for _,plr in pairs(Players:GetPlayers()) do

if plr~=player
and plr.Character
and not playerHighlights[plr] then

local hl=Instance.new("Highlight")

hl.Parent=plr.Character
hl.FillColor=Color3.fromRGB(255,0,0)
hl.FillTransparency=0.6

playerHighlights[plr]=hl

end
end
end

--------------------------------------------------
-- PLAYER TRACER ESP
--------------------------------------------------

local tracerLines={}

local function createTracer(plr)

local line=Drawing.new("Line")
line.Visible=false
line.Color=Color3.fromRGB(255,0,0)
line.Thickness=2

tracerLines[plr]=line

end

for _,plr in pairs(Players:GetPlayers()) do
if plr~=player then
createTracer(plr)
end
end

--------------------------------------------------
-- SERVER HOP SYSTEM
--------------------------------------------------

local hopping=false

local function serverHop()

if hopping then return end
hopping=true

notify("Unsafe server — hopping")

local cursor=""

repeat

local url="https://games.roblox.com/v1/games/"
..placeId..
"/servers/Public?sortOrder=Asc&limit=100"

if cursor~="" then
url=url.."&cursor="..cursor
end

local success,response=pcall(function()
return game:HttpGet(url)
end)

if success then

local data=HttpService:JSONDecode(response)

for _,server in pairs(data.data) do

if server.playing<server.maxPlayers
and server.id~=jobId then

TeleportService:TeleportToPlaceInstance(
placeId,
server.id,
player
)

return

end
end

cursor=data.nextPageCursor or ""

end

task.wait(1)

until cursor==""

hopping=false

end

--------------------------------------------------
-- SAFETY RADAR
--------------------------------------------------

local function safetyCheck()

if not fruit then return end

local handle=fruit:FindFirstChild("Handle")
if not handle then return end

local closest=math.huge

for _,plr in pairs(Players:GetPlayers()) do

if plr~=player
and plr.Character
and plr.Character:FindFirstChild("HumanoidRootPart") then

local dist=(plr.Character.HumanoidRootPart.Position
-handle.Position).Magnitude

if dist<closest then
closest=dist
end
end
end

if closest<=DANGER_DISTANCE then

frame.BackgroundColor3=Color3.fromRGB(255,0,0)
statusLabel.Text="🔴 UNSAFE"

if autoHopUnsafe then
serverHop()
end

elseif closest<=WARNING_DISTANCE then

frame.BackgroundColor3=Color3.fromRGB(255,200,0)
statusLabel.Text="🟡 WARNING"

else

frame.BackgroundColor3=Color3.fromRGB(0,255,120)
statusLabel.Text="🟢 SAFE"

end
end

--------------------------------------------------
-- ISLAND TELEPORT PANEL
--------------------------------------------------

local islands={

["Starter Island"]=Vector3.new(1059,16,1547),
["Jungle"]=Vector3.new(-1602,37,153),
["Pirate Village"]=Vector3.new(-1163,44,3827),
["Desert"]=Vector3.new(1094,7,4192),
["Frozen Village"]=Vector3.new(1111,7,-1163),
["Marineford"]=Vector3.new(-4500,20,4300)

}

local y=0.32

for name,pos in pairs(islands) do

local btn=Instance.new("TextButton",frame)

btn.Size=UDim2.new(1,0,0.1,0)
btn.Position=UDim2.new(0,0,y,0)

btn.Text=name
btn.Font=Enum.Font.GothamBold
btn.TextScaled=true
btn.BackgroundColor3=Color3.fromRGB(45,45,45)
btn.TextColor3=Color3.new(1,1,1)

btn.MouseButton1Click:Connect(function()

if player.Character
and player.Character:FindFirstChild("HumanoidRootPart") then

player.Character.HumanoidRootPart.CFrame=CFrame.new(pos)

end
end)

y+=0.1

end

--------------------------------------------------
-- MAIN LOOP
--------------------------------------------------

RunService.RenderStepped:Connect(function()

applyPlayerESP()

for plr,line in pairs(tracerLines) do

if plr.Character
and plr.Character:FindFirstChild("HumanoidRootPart") then

local pos,visible=
Camera:WorldToViewportPoint(
plr.Character.HumanoidRootPart.Position
)

if visible then

line.Visible=true

line.From=Vector2.new(
Camera.ViewportSize.X/2,
Camera.ViewportSize.Y
)

line.To=Vector2.new(pos.X,pos.Y)

else

line.Visible=false

end
end
end
end)

--------------------------------------------------
-- AUTO SCAN LOOP
--------------------------------------------------

task.spawn(function()

while true do

task.wait(3)

if autoScan then

findFruit()

if fruit then

applyFruitESP(fruit)
notify("Fruit detected: "..fruit.Name)

safetyCheck()

end
end
end
end)
