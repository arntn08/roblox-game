-- Project ECLIPSE Alpha 0.1
-- Touch-friendly combat button and keyboard fallback for Studio testing.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("GameConfig"))
local remotes = ReplicatedStorage:WaitForChild("EclipseRemotes")
local attackRequest = remotes:WaitForChild("AttackRequest")
local combatFeedback = remotes:WaitForChild("CombatFeedback")

local gui = Instance.new("ScreenGui")
gui.Name = "EclipseCombatUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local title = Instance.new("TextLabel")
title.Name = "GameTitle"
title.Size = UDim2.fromOffset(230, 42)
title.Position = UDim2.fromOffset(16, 16)
title.BackgroundColor3 = Color3.fromRGB(12, 17, 31)
title.BackgroundTransparency = 0.15
title.TextColor3 = Color3.fromRGB(105, 210, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Text = GameConfig.GameName .. " | " .. GameConfig.Version
title.Parent = gui

local feedback = Instance.new("TextLabel")
feedback.Name = "CombatFeedback"
feedback.Size = UDim2.fromOffset(250, 38)
feedback.Position = UDim2.new(0.5, -125, 0.68, 0)
feedback.BackgroundTransparency = 1
feedback.TextColor3 = Color3.fromRGB(255, 231, 150)
feedback.Font = Enum.Font.GothamBold
feedback.TextScaled = true
feedback.Text = "ECLIPSE READY"
feedback.Parent = gui

local attackButton = Instance.new("TextButton")
attackButton.Name = "AttackButton"
attackButton.Size = UDim2.fromOffset(104, 104)
attackButton.Position = UDim2.new(1, -132, 1, -150)
attackButton.BackgroundColor3 = Color3.fromRGB(16, 43, 72)
attackButton.BorderSizePixel = 0
attackButton.Text = "ATTACK"
attackButton.TextColor3 = Color3.fromRGB(130, 220, 255)
attackButton.Font = Enum.Font.GothamBlack
attackButton.TextSize = 19
attackButton.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = attackButton

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(54, 174, 255)
stroke.Thickness = 3
stroke.Parent = attackButton

local function attack()
    attackRequest:FireServer()
end

attackButton.Activated:Connect(attack)

UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.F then
        attack()
    end
end)

combatFeedback.OnClientEvent:Connect(function(data)
    if typeof(data) ~= "table" then return end
    if data.kind == "Hit" then
        feedback.Text = string.format("COMBO %d | %d DAMAGE", data.combo, data.damage)
        feedback.TextColor3 = data.defeated
            and Color3.fromRGB(120, 255, 170)
            or Color3.fromRGB(255, 231, 150)
    elseif data.kind == "Swing" then
        feedback.Text = string.format("COMBO %d | MISS", data.combo)
        feedback.TextColor3 = Color3.fromRGB(150, 205, 255)
    end
end)

print("[ECLIPSE] Mobile combat UI initialized.")
