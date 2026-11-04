-- Prototype dungeon boss with a simple proximity attack and respawn.
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

    local alive = true
    humanoid.Died:Connect(function()
        alive = false
        root.Color = Color3.fromRGB(70,70,85)
        task.delay(RESPAWN, function()
            if model.Parent then model:Destroy() end
            spawnBoss()
        end)
    end)

    -- Boss pulse attack: damages nearby players; defense reduces incoming damage.
    task.spawn(function()
        while alive and model.Parent do
            task.wait(2.5)
            if not alive or not model.Parent then break end
            for _, player in Players:GetPlayers() do
                local character = player.Character
                local targetHumanoid = character and character:FindFirstChildOfClass("Humanoid")
                local targetRoot = character and character:FindFirstChild("HumanoidRootPart")
                if targetHumanoid and targetRoot and targetHumanoid.Health > 0
                    and (targetRoot.Position - root.Position).Magnitude <= 18 then
                    local defense = player:GetAttribute("EclipseDefense") or 0
                    targetHumanoid:TakeDamage(math.max(1, 28 - defense))
                end
            end
        end
    end)
end

spawnBoss()
print("[ECLIPSE] Eclipse Guardian boss encounter online.")
