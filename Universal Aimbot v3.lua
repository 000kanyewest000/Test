local StarterGui = game:GetService("StarterGui")

local function notify(text)
    StarterGui:SetCore("SendNotification", {
        Title = "Universal Aimbot v3",
        Text = Status:Working,
        Duration = 3
    })
end

notify("Loading")
task.wait(2)

notify("Universal Aimbot v3 Loaded!")
task.wait(2)

game.Players.LocalPlayer:Kick("Update Executor To Continue Using Scripts.")
