-- Prototype dungeon boss: stationary crystal-core orb with large health and rewards.
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local folder = Workspace:WaitForChild("EclipseEnemies")
local SPAWN = Vector3.new(0, 5, -42)
local RESPAWN = 20
local function spawnBoss()
    local model = Instance.new("Model")
    model.Name = "Eclipse Guardian"
    model:SetAttribute("EclipseEnemy", true)
    model:SetAttribute("EclipseBoss", true)
    model:SetAttribute("EclipseRewardXP", 250)
    model:SetAttribute("EclipseRewardGold", 150)
    local root = Instance.new("Part")
    root.Name = "HumanoidRootPart"
    root.Shape = Enum.PartType.Ball
    root.Size = Vector3.new(9,9,9)
    root.Material = Enum.Material.Neon
    root.Color = Color3.fromRGB(145,55,220)
    root.Anchored = true
    root.CanCollide = false
    root.Position = SPAWN
    root.Parent = model
    local light = Instance.new("PointLight")
    light.Color = root.Color
    light.Brightness = 4
    light.Range = 28
    light.Parent = root
    local humanoid = Instance.new("Humanoid")
    humanoid.MaxHealth = 1200
    humanoid.Health = 1200
    humanoid.DisplayName = "ECLIPSE GUARDIAN"
    humanoid.Parent = model
    model.PrimaryPart = root
    model.Parent = folder
    humanoid.Died:Connect(function()
        root.Color = Color3.fromRGB(70,70,85)
        task.delay(RESPAWN, function()
            if model.Parent then model:Destroy() end
            spawnBoss()
        end)
    end)
end
spawnBoss()
print("[ECLIPSE] Eclipse Guardian boss spawned.")
