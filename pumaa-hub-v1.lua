repeat task.wait() until game:IsLoaded()

--------------------------------------------------
-- SERVICES
--------------------------------------------------

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

--------------------------------------------------
-- GUI BASE
--------------------------------------------------

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "PumaaHub"

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,620,0,380)
main.Position = UDim2.new(.2,0,.2,0)
main.BackgroundColor3 = Color3.fromRGB(18,18,18)
main.Active = true
main.Draggable = true

--------------------------------------------------
-- TITLE BAR
--------------------------------------------------

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0.08,0)
title.BackgroundTransparency = 1
title.Text = "🐆 Pumaa Hub v1.1"
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(255,255,255)

--------------------------------------------------
-- SIDEBAR
--------------------------------------------------

local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.new(0,150,1,0)
sidebar.Position = UDim2.new(0,0,0,0)
sidebar.BackgroundColor3 = Color3.fromRGB(28,28,28)

--------------------------------------------------
-- CONTENT AREA
--------------------------------------------------

local content = Instance.new("Frame", main)
content.Size = UDim2.new(1,-150,1,0)
content.Position = UDim2.new(0,150,0,0)
content.BackgroundTransparency = 1

--------------------------------------------------
-- TAB SYSTEM
--------------------------------------------------

local tabs = {}

local function createTab(name)

local btn = Instance.new("TextButton", sidebar)
btn.Size = UDim2.new(1,0,0,45)
btn.Text = name
btn.Font = Enum.Font.GothamBold
btn.TextScaled = true
btn.BackgroundColor3 = Color3.fromRGB(38,38,38)
btn.TextColor3 = Color3.fromRGB(255,255,255)

local frame = Instance.new("Frame", content)
frame.Size = UDim2.new(1,0,1,0)
frame.Visible = false
frame.BackgroundTransparency = 1

tabs[name] = frame

btn.MouseButton1Click:Connect(function()

for _,f in pairs(tabs) do
f.Visible = false
end

frame.Visible = true

end)

return frame

end

--------------------------------------------------
-- CREATE TABS
--------------------------------------------------

local fruitTab = createTab("Fruit")
local playerTab = createTab("Player")
local espTab = createTab("ESP")
local teleportTab = createTab("Teleport")
local serverTab = createTab("Servers")
local radarTab = createTab("Radar")
local miscTab = createTab("Misc")

fruitTab.Visible = true

--------------------------------------------------
-- TOGGLE SWITCH CREATOR
--------------------------------------------------

local function createToggle(parent, text, ypos, callback)

local state = false

local btn = Instance.new("TextButton", parent)
btn.Size = UDim2.new(0,220,0,40)
btn.Position = UDim2.new(0,20,0,ypos)
btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
btn.Text = text.." OFF"
btn.TextScaled = true
btn.Font = Enum.Font.GothamBold
btn.TextColor3 = Color3.new(1,1,1)

btn.MouseButton1Click:Connect(function()

state = not state

btn.Text =
text.." "..(state and "ON" or "OFF")

callback(state)

end)

end

--------------------------------------------------
-- FRUIT ESP
--------------------------------------------------

local fruitESP

createToggle(
fruitTab,
"Fruit ESP",
40,
function(state)

if not state then
if fruitESP then
fruitESP:Destroy()
end
return
end

for _,v in pairs(workspace:GetDescendants()) do

if v:IsA("Tool")
and v:FindFirstChild("Handle")
and string.find(v.Name:lower(),"fruit") then

fruitESP = Instance.new("Highlight")
fruitESP.Parent = v

end
end

end)

--------------------------------------------------
-- PLAYER ESP
--------------------------------------------------

createToggle(
espTab,
"Player ESP",
40,
function(state)

for _,plr in pairs(Players:GetPlayers()) do

if plr ~= player
and plr.Character then

if state then

local hl = Instance.new("Highlight")
hl.Parent = plr.Character

else

if plr.Character:FindFirstChild("Highlight") then
plr.Character.Highlight:Destroy()
end

end

end
end

end)

--------------------------------------------------
-- WALK SPEED
--------------------------------------------------

createToggle(
playerTab,
"Speed Boost",
40,
function(state)

if player.Character then

player.Character.Humanoid.WalkSpeed =
state and 50 or 16

end

end)

--------------------------------------------------
-- INFINITE JUMP
--------------------------------------------------

local infJump = false

createToggle(
playerTab,
"Infinite Jump",
100,
function(state)

infJump = state

end)

UIS.JumpRequest:Connect(function()

if infJump then
player.Character.Humanoid:ChangeState("Jumping")
end

end)

--------------------------------------------------
-- TELEPORT BUTTON
--------------------------------------------------

local tpBtn = Instance.new("TextButton", teleportTab)
tpBtn.Size = UDim2.new(0,200,0,45)
tpBtn.Position = UDim2.new(0,20,0,40)
tpBtn.Text = "Teleport Jungle"
tpBtn.TextScaled = true
tpBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)

tpBtn.MouseButton1Click:Connect(function()

player.Character:PivotTo(
CFrame.new(-1600,35,150)
)

end)

--------------------------------------------------
-- SERVER HOP
--------------------------------------------------

local hopBtn = Instance.new("TextButton", serverTab)
hopBtn.Size = UDim2.new(0,200,0,45)
hopBtn.Position = UDim2.new(0,20,0,40)
hopBtn.Text = "Server Hop"
hopBtn.TextScaled = true
hopBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)

hopBtn.MouseButton1Click:Connect(function()

TeleportService:Teleport(game.PlaceId)

end)

--------------------------------------------------
-- RADAR ALERT
--------------------------------------------------

local radarEnabled = false

createToggle(
radarTab,
"Nearby Player Alert",
40,
function(state)

radarEnabled = state

end)

RunService.RenderStepped:Connect(function()

if not radarEnabled then return end

for _,plr in pairs(Players:GetPlayers()) do

if plr ~= player
and plr.Character
and player.Character then

local dist =
(plr.Character.HumanoidRootPart.Position
-
player.Character.HumanoidRootPart.Position).Magnitude

if dist < 80 then

game.StarterGui:SetCore("SendNotification",{
Title="Pumaa Hub",
Text="⚠ Player Nearby",
Duration=2
})

end

end
end

end)

--------------------------------------------------
-- ANTI AFK
--------------------------------------------------

createToggle(
miscTab,
"Anti AFK",
40,
function(state)

if state then

player.Idled:Connect(function()

game:GetService("VirtualUser"):Button2Down(Vector2.new())

end)

end

end)

--------------------------------------------------
-- OPEN / CLOSE KEY
--------------------------------------------------

UIS.InputBegan:Connect(function(key)

if key.KeyCode == Enum.KeyCode.RightShift then
main.Visible = not main.Visible
end

end)
