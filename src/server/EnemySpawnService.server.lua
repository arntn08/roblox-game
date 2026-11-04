-- Project ECLIPSE Alpha 0.1
-- Creates a simple floating training enemy and gives it basic chase/attack AI.
-- This is a placeholder enemy; custom anime models and animations come later.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local folder = Workspace:FindFirstChild("EclipseEnemies")
if not folder then
    folder = Instance.new("Folder")
    folder.Name = "EclipseEnemies"
    folder.Parent = Workspace
end

local SETTINGS = {
    Name = "Eclipse Wisp",
    MaxHealth = 90,
    Speed = 7,
    AggroRange = 45,
    AttackRange = 4.5,
    AttackDamage = 8,
    AttackCooldown = 1.6,
    RespawnDelay = 5,
    RewardXP = 35,
    RewardGold = 15,
    SpawnPosition = Vector3.new(0, 4, -12),
}

local function closestPlayer(position)
    local chosen, chosenDistance
    for _, player in Players:GetPlayers() do
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if humanoid and root and humanoid.Health > 0 then
            local distance = (root.Position - position).Magnitude
            if distance <= SETTINGS.AggroRange and (not chosenDistance or distance < chosenDistance) then
                chosen, chosenDistance = player, distance
            end
        end
    end
    return chosen, chosenDistance
end

local function createEnemy()
    local model = Instance.new("Model")
    model.Name = SETTINGS.Name
    model:SetAttribute("EclipseEnemy", true)
    model:SetAttribute("EclipseRewardXP", SETTINGS.RewardXP)
    model:SetAttribute("EclipseRewardGold", SETTINGS.RewardGold)

    local root = Instance.new("Part")
    root.Name = "HumanoidRootPart"
    root.Shape = Enum.PartType.Ball
    root.Size = Vector3.new(3.5, 3.5, 3.5)
    root.Material = Enum.Material.Neon
    root.Color = Color3.fromRGB(45, 170, 255)
    root.Anchored = true
    root.CanCollide = false
    root.Position = SETTINGS.SpawnPosition
    root.Parent = model

    local light = Instance.new("PointLight")
    light.Color = root.Color
    light.Brightness = 2
    light.Range = 12
    light.Parent = root

    local humanoid = Instance.new("Humanoid")
    humanoid.MaxHealth = SETTINGS.MaxHealth
    humanoid.Health = SETTINGS.MaxHealth
    humanoid.DisplayName = SETTINGS.Name
    humanoid.Parent = model

    model.PrimaryPart = root
    model.Parent = folder

    local lastAttack = 0
    local alive = true

    humanoid.Died:Connect(function()
        alive = false
        root.Color = Color3.fromRGB(90, 90, 110)
        task.delay(SETTINGS.RespawnDelay, function()
            if model.Parent then model:Destroy() end
            createEnemy()
        end)
    end)

    task.spawn(function()
        while alive and model.Parent do
            local target, distance = closestPlayer(root.Position)
            if target and distance then
                local character = target.Character
                local targetHumanoid = character and character:FindFirstChildOfClass("Humanoid")
                local targetRoot = character and character:FindFirstChild("HumanoidRootPart")

                if targetHumanoid and targetRoot and targetHumanoid.Health > 0 then
                    if distance > SETTINGS.AttackRange then
                        local direction = targetRoot.Position - root.Position
                        local flat = Vector3.new(direction.X, 0, direction.Z)
                        if flat.Magnitude > 0.1 then
                            local step = math.min(SETTINGS.Speed * 0.1, flat.Magnitude - SETTINGS.AttackRange)
                            local nextPosition = root.Position + flat.Unit * math.max(0, step)
                            model:PivotTo(CFrame.new(nextPosition, Vector3.new(targetRoot.Position.X, nextPosition.Y, targetRoot.Position.Z)))
                        end
                    elseif os.clock() - lastAttack >= SETTINGS.AttackCooldown then
                        lastAttack = os.clock()
                        targetHumanoid:TakeDamage(SETTINGS.AttackDamage)
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end

createEnemy()
print("[ECLIPSE] Training enemy spawned.")
