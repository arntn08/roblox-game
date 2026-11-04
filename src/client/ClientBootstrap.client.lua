-- Project ECLIPSE Alpha 0.1
-- Mobile combat HUD, three skill buttons, and progression display.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GameConfig"))
local skills = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("SkillConfig"))
local remotes = ReplicatedStorage:WaitForChild("EclipseRemotes")
local attackRequest = remotes:WaitForChild("AttackRequest")
local combatFeedback = remotes:WaitForChild("CombatFeedback")
local skillRequest = remotes:WaitForChild("SkillRequest")
local skillFeedback = remotes:WaitForChild("SkillFeedback")

local gui = Instance.new("ScreenGui")
gui.Name = "EclipseCombatUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local function makeLabel(name, size, position, color, text, textSize)
    local label = Instance.new("TextLabel")
    label.Name = name
    label.Size = size
    label.Position = position
    label.BackgroundColor3 = Color3.fromRGB(12, 17, 31)
    label.BackgroundTransparency = 0.18
    label.TextColor3 = color
    label.Font = Enum.Font.GothamBold
    label.TextSize = textSize or 15
    label.Text = text
    label.Parent = gui
    return label
end

makeLabel("GameTitle", UDim2.fromOffset(230, 36), UDim2.fromOffset(14, 12),
    Color3.fromRGB(105, 210, 255), config.GameName .. " | " .. config.Version, 14)

local stats = makeLabel("PlayerStats", UDim2.fromOffset(230, 32), UDim2.fromOffset(14, 52),
    Color3.fromRGB(245, 220, 145), "LV 1  |  XP 0/100  |  GOLD 100", 13)

local feedback = Instance.new("TextLabel")
feedback.Name = "CombatFeedback"
feedback.Size = UDim2.fromOffset(290, 42)
feedback.Position = UDim2.new(0.5, -145, 0.66, 0)
feedback.BackgroundTransparency = 1
feedback.TextColor3 = Color3.fromRGB(255, 231, 150)
feedback.Font = Enum.Font.GothamBold
feedback.TextScaled = true
feedback.Text = "ECLIPSE READY"
feedback.Parent = gui

local function refreshStats()
    local level = player:GetAttribute("EclipseLevel") or 1
    local xp = player:GetAttribute("EclipseXP") or 0
    local needed = player:GetAttribute("EclipseXPToNextLevel") or 100
    local gold = player:GetAttribute("EclipseGold") or 100
    stats.Text = string.format("LV %d  |  XP %d/%d  |  GOLD %d", level, xp, needed, gold)
end

for _, attribute in {"EclipseLevel", "EclipseXP", "EclipseXPToNextLevel", "EclipseGold"} do
    player:GetAttributeChangedSignal(attribute):Connect(refreshStats)
end
refreshStats()

local function styleButton(button, color, round)
    button.BackgroundColor3 = color
    button.BorderSizePixel = 0
    button.TextColor3 = Color3.fromRGB(235, 245, 255)
    button.Font = Enum.Font.GothamBlack
    button.TextScaled = true
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = button
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(75, 185, 255)
    stroke.Thickness = round or 2
    stroke.Parent = button
end

local attackButton = Instance.new("TextButton")
attackButton.Name = "AttackButton"
attackButton.Size = UDim2.fromOffset(96, 96)
attackButton.Position = UDim2.new(1, -116, 1, -132)
attackButton.Text = "ATTACK"
attackButton.Parent = gui
styleButton(attackButton, Color3.fromRGB(16, 65, 105), 3)
attackButton.Activated:Connect(function()
    attackRequest:FireServer()
end)

local skillButtons = {}
local skillOrder = {"EnergySlash", "EclipseBurst", "ShadowNova"}
local skillPositions = {
    EnergySlash = UDim2.new(1, -340, 1, -112),
    EclipseBurst = UDim2.new(1, -265, 1, -112),
    ShadowNova = UDim2.new(1, -190, 1, -112),
}

local function useSkill(skillName)
    skillRequest:FireServer(skillName)
end

for _, skillName in skillOrder do
    local definition = skills.Skills[skillName]
    local button = Instance.new("TextButton")
    button.Name = skillName .. "Button"
    button.Size = UDim2.fromOffset(66, 66)
    button.Position = skillPositions[skillName]
    button.Text = definition.Key
    button.Parent = gui
    styleButton(button, definition.Color, 2)
    button.Activated:Connect(function()
        useSkill(skillName)
    end)
    skillButtons[skillName] = button
end

local function setSkillCooldown(skillName, seconds)
    local button = skillButtons[skillName]
    if not button then return end
    local endsAt = os.clock() + seconds
    button.Active = false
    task.spawn(function()
        while button.Parent and os.clock() < endsAt do
            button.Text = tostring(math.ceil(endsAt - os.clock()))
            task.wait(0.15)
        end
        if button.Parent then
            button.Text = skills.Skills[skillName].Key
            button.Active = true
        end
    end)
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.F then
        attackRequest:FireServer()
    elseif input.KeyCode == Enum.KeyCode.Z then
        useSkill("EnergySlash")
    elseif input.KeyCode == Enum.KeyCode.X then
        useSkill("EclipseBurst")
    elseif input.KeyCode == Enum.KeyCode.C then
        useSkill("ShadowNova")
    end
end)

combatFeedback.OnClientEvent:Connect(function(data)
    if typeof(data) ~= "table" then return end
    if data.kind == "Hit" then
        feedback.Text = string.format("COMBO %d | %d DAMAGE", data.combo, data.damage)
        feedback.TextColor3 = data.defeated and Color3.fromRGB(120,255,170) or Color3.fromRGB(255,231,150)
    elseif data.kind == "Swing" then
        feedback.Text = string.format("COMBO %d | MISS", data.combo)
        feedback.TextColor3 = Color3.fromRGB(150,205,255)
    elseif data.kind == "Reward" then
        feedback.Text = string.format("+%d XP   +%d GOLD", data.xp, data.gold)
        feedback.TextColor3 = Color3.fromRGB(120,255,170)
    end
end)

skillFeedback.OnClientEvent:Connect(function(data)
    if typeof(data) ~= "table" then return end
    if data.kind == "Used" then
        feedback.Text = string.format("%s  |  %d HITS", data.skill, data.hits)
        feedback.TextColor3 = Color3.fromRGB(120,220,255)
        setSkillCooldown(data.skill, data.cooldown)
    elseif data.kind == "Cooldown" then
        feedback.Text = string.format("SKILL RECHARGING  %.1fs", data.remaining)
        feedback.TextColor3 = Color3.fromRGB(255,190,110)
    elseif data.kind == "Reward" then
        feedback.Text = string.format("+%d XP   +%d GOLD", data.xp, data.gold)
        feedback.TextColor3 = Color3.fromRGB(120,255,170)
    end
end)

print("[ECLIPSE] Mobile HUD and three-skill controls ready.")
