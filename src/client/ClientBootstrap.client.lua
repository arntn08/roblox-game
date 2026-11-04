-- Project ECLIPSE Alpha 0.1
-- Mobile combat HUD, three skill buttons, and progression display.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GameConfig"))
local skills = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("SkillConfig"))
local classConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ClassConfig"))
local remotes = ReplicatedStorage:WaitForChild("EclipseRemotes")
local attackRequest = remotes:WaitForChild("AttackRequest")
local combatFeedback = remotes:WaitForChild("CombatFeedback")
local skillRequest = remotes:WaitForChild("SkillRequest")
local skillFeedback = remotes:WaitForChild("SkillFeedback")
local classRequest = remotes:WaitForChild("ClassRequest")
local questFeedback = remotes:WaitForChild("QuestFeedback")
local equipRequest = remotes:WaitForChild("EquipRequest")
local inventoryFeedback = remotes:WaitForChild("InventoryFeedback")
local classAttackRequest = remotes:WaitForChild("ClassAttackRequest")
local classAttackFeedback = remotes:WaitForChild("ClassAttackFeedback")
local stageFeedback = remotes:WaitForChild("StageFeedback")

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
    local class = player:GetAttribute("EclipseClass")
    if class == "Mage" or class == "Archer" then
        classAttackRequest:FireServer()
    else
        attackRequest:FireServer()
    end
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
        local class = player:GetAttribute("EclipseClass")
        if class == "Mage" or class == "Archer" then classAttackRequest:FireServer() else attackRequest:FireServer() end
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


-- Class selection buttons. The server validates class names and applies stats.
local classTitle = makeLabel("ClassTitle", UDim2.fromOffset(190, 28), UDim2.new(1, -204, 0, 12),
    Color3.fromRGB(190, 210, 255), "SELECT CLASS", 13)
local classOrder = {"Swordsman", "Mage", "Archer"}
for index, className in classOrder do
    local classInfo = classConfig.Classes[className]
    local button = Instance.new("TextButton")
    button.Name = className .. "Select"
    button.Size = UDim2.fromOffset(62, 42)
    button.Position = UDim2.new(1, -204 + ((index - 1) * 66), 0, 44)
    button.Text = classInfo.DisplayName
    button.Parent = gui
    styleButton(button, classInfo.Color, 2)
    button.Activated:Connect(function()
        classRequest:FireServer(className)
    end)
end

local questLabel = makeLabel("QuestProgress", UDim2.fromOffset(250, 30), UDim2.fromOffset(14, 90),
    Color3.fromRGB(155, 235, 190), "QUEST: DEFEAT 5 ENEMIES (0/5)", 12)

classRequest.OnClientEvent:Connect(function(data)
    if typeof(data) == "table" and data.kind == "Selected" then
        classTitle.Text = data.class .. " | " .. data.weapon
        feedback.Text = "CLASS EQUIPPED: " .. data.class
    end
end)

questFeedback.OnClientEvent:Connect(function(data)
    if typeof(data) ~= "table" then return end
    if data.kind == "Completed" then
        questLabel.Text = "QUEST COMPLETE! +" .. data.xp .. " XP  +" .. data.gold .. " GOLD"
        feedback.Text = "QUEST CLEARED!"
    else
        questLabel.Text = "QUEST: DEFEAT 5 ENEMIES (" .. data.count .. "/" .. data.target .. ")"
    end
end)


-- Update the main action label when a ranged class is selected.
local function refreshAttackLabel()
    local class = player:GetAttribute("EclipseClass")
    attackButton.Text = (class == "Mage" and "CAST") or (class == "Archer" and "SHOOT") or "ATTACK"
end
player:GetAttributeChangedSignal("EclipseClass"):Connect(refreshAttackLabel)
refreshAttackLabel()

-- Compact inventory panel. The server enforces class ownership and equipment rules.
local inventoryToggle = Instance.new("TextButton")
inventoryToggle.Name = "InventoryToggle"
inventoryToggle.Size = UDim2.fromOffset(100, 34)
inventoryToggle.Position = UDim2.new(1, -118, 0, 94)
inventoryToggle.Text = "WEAPONS"
inventoryToggle.Parent = gui
styleButton(inventoryToggle, Color3.fromRGB(35,45,75), 2)

local inventoryPanel = Instance.new("Frame")
inventoryPanel.Name = "InventoryPanel"
inventoryPanel.Size = UDim2.fromOffset(190, 150)
inventoryPanel.Position = UDim2.new(1, -208, 0, 134)
inventoryPanel.BackgroundColor3 = Color3.fromRGB(12,17,31)
inventoryPanel.BackgroundTransparency = 0.08
inventoryPanel.Visible = false
inventoryPanel.Parent = gui
local panelCorner = Instance.new("UICorner"); panelCorner.CornerRadius=UDim.new(0,10); panelCorner.Parent=inventoryPanel
local panelTitle = Instance.new("TextLabel")
panelTitle.Size=UDim2.new(1,0,0,28); panelTitle.BackgroundTransparency=1
panelTitle.Text="STARTER WEAPONS"; panelTitle.TextColor3=Color3.fromRGB(130,210,255)
panelTitle.Font=Enum.Font.GothamBold; panelTitle.TextSize=12; panelTitle.Parent=inventoryPanel

for index, weaponName in {"Eclipse Blade","Astral Staff","Moon Bow"} do
    local itemButton=Instance.new("TextButton")
    itemButton.Size=UDim2.new(1,-16,0,32)
    itemButton.Position=UDim2.fromOffset(8,30+(index-1)*37)
    itemButton.Text=weaponName
    itemButton.Parent=inventoryPanel
    styleButton(itemButton,Color3.fromRGB(27,53,78),2)
    itemButton.Activated:Connect(function()
        equipRequest:FireServer(weaponName)
    end)
end
inventoryToggle.Activated:Connect(function()
    inventoryPanel.Visible=not inventoryPanel.Visible
end)

inventoryFeedback.OnClientEvent:Connect(function(data)
    if typeof(data)~="table" then return end
    if data.kind=="Equipped" then
        feedback.Text="EQUIPPED: "..data.weapon
        refreshAttackLabel()
    elseif data.kind=="Rejected" then
        feedback.Text=data.message or "CANNOT EQUIP"
    end
end)

classAttackFeedback.OnClientEvent:Connect(function(data)
    if typeof(data)~="table" then return end
    if data.kind=="Attack" then
        feedback.Text=data.hit and (data.class.." HIT  "..data.damage) or (data.class.." SHOT MISSED")
    elseif data.kind=="Reward" then
        feedback.Text="+"..data.xp.." XP  +"..data.gold.." GOLD"
    end
end)

stageFeedback.OnClientEvent:Connect(function(data)
    if typeof(data)=="table" and data.kind=="Entered" then
        feedback.Text="DUNGEON STAGE "..data.stage..": "..data.name
    end
end)

-- Boss health bar appears when an Eclipse boss enters the world.
local bossGui
local function watchBoss(model)
    if not model:IsA("Model") or model:GetAttribute("EclipseBoss")~=true then return end
    local bossHumanoid=model:FindFirstChildOfClass("Humanoid") or model:WaitForChild("Humanoid",5)
    if not bossHumanoid then return end
    if bossGui then bossGui:Destroy() end
    bossGui=Instance.new("Frame")
    bossGui.Name="BossHealthFrame"
    bossGui.Size=UDim2.new(0.52,0,0,48)
    bossGui.Position=UDim2.new(0.24,0,0,18)
    bossGui.BackgroundColor3=Color3.fromRGB(15,12,28)
    bossGui.Parent=gui
    local title=Instance.new("TextLabel")
    title.Size=UDim2.new(1,0,0,20); title.BackgroundTransparency=1
    title.Text="ECLIPSE GUARDIAN"; title.TextColor3=Color3.fromRGB(220,185,255)
    title.Font=Enum.Font.GothamBlack; title.TextSize=13; title.Parent=bossGui
    local back=Instance.new("Frame")
    back.Size=UDim2.new(1,-12,0,14); back.Position=UDim2.fromOffset(6,26)
    back.BackgroundColor3=Color3.fromRGB(65,30,65); back.Parent=bossGui
    local fill=Instance.new("Frame")
    fill.Size=UDim2.fromScale(1,1); fill.BackgroundColor3=Color3.fromRGB(170,65,235); fill.Parent=back
    local function update()
        local ratio=math.clamp(bossHumanoid.Health/math.max(1,bossHumanoid.MaxHealth),0,1)
        fill.Size=UDim2.fromScale(ratio,1)
        title.Text=string.format("ECLIPSE GUARDIAN  %d / %d",math.max(0,math.floor(bossHumanoid.Health)),bossHumanoid.MaxHealth)
        if bossHumanoid.Health<=0 then title.Text="ECLIPSE GUARDIAN DEFEATED" end
    end
    bossHumanoid.HealthChanged:Connect(update)
    update()
    bossHumanoid.Died:Connect(function()
        task.delay(4,function() if bossGui then bossGui:Destroy(); bossGui=nil end end)
    end)
end

for _,descendant in workspace:GetDescendants() do
    if descendant:IsA("Model") and descendant:GetAttribute("EclipseBoss")==true then task.spawn(watchBoss,descendant) end
end
workspace.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("Model") and descendant:GetAttribute("EclipseBoss")==true then task.spawn(watchBoss,descendant) end
end)

print("[ECLIPSE] RPG HUD, class combat, inventory, boss bar, and stages ready.")
