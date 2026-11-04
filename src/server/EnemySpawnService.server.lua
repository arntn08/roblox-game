-- Prototype enemy roster with three enemy archetypes and basic pursuit AI.
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local folder = Workspace:FindFirstChild("EclipseEnemies") or Instance.new("Folder")
folder.Name = "EclipseEnemies"
folder.Parent = Workspace

local TYPES = {
    {Name="Eclipse Wisp",Health=90,Speed=7,Damage=8,Range=45,AttackRange=4.5,Cooldown=1.6,XP=35,Gold=15,Size=3.5,Color=Color3.fromRGB(45,170,255),Position=Vector3.new(0,4,-12)},
    {Name="Void Stalker",Health=180,Speed=10,Damage=13,Range=55,AttackRange=5,Cooldown=1.35,XP=65,Gold=30,Size=4.5,Color=Color3.fromRGB(210,65,125),Position=Vector3.new(-13,4,-18)},
    {Name="Abyss Brute",Health=360,Speed=5,Damage=22,Range=48,AttackRange=6,Cooldown=2.1,XP=110,Gold=55,Size=6,Color=Color3.fromRGB(155,85,55),Position=Vector3.new(13,4,-18)},
}

local function closestPlayer(position, maxRange)
    local chosen, best
    for _, player in Players:GetPlayers() do
        local character=player.Character
        local humanoid=character and character:FindFirstChildOfClass("Humanoid")
        local root=character and character:FindFirstChild("HumanoidRootPart")
        if humanoid and root and humanoid.Health>0 then
            local distance=(root.Position-position).Magnitude
            if distance<=maxRange and (not best or distance<best) then chosen,best=player,distance end
        end
    end
    return chosen,best
end

local function spawnEnemy(settings)
    local model=Instance.new("Model")
    model.Name=settings.Name
    model:SetAttribute("EclipseEnemy",true)
    model:SetAttribute("EclipseRewardXP",settings.XP)
    model:SetAttribute("EclipseRewardGold",settings.Gold)
    local root=Instance.new("Part")
    root.Name="HumanoidRootPart"
    root.Shape=Enum.PartType.Ball
    root.Size=Vector3.new(settings.Size,settings.Size,settings.Size)
    root.Material=Enum.Material.Neon
    root.Color=settings.Color
    root.Anchored=true
    root.CanCollide=false
    root.Position=settings.Position
    root.Parent=model
    local light=Instance.new("PointLight")
    light.Color=settings.Color
    light.Brightness=2
    light.Range=settings.Size*4
    light.Parent=root
    local humanoid=Instance.new("Humanoid")
    humanoid.MaxHealth=settings.Health
    humanoid.Health=settings.Health
    humanoid.DisplayName=settings.Name
    humanoid.Parent=model
    model.PrimaryPart=root
    model.Parent=folder

    local alive=true
    local lastAttack=0
    humanoid.Died:Connect(function()
        alive=false
        root.Color=Color3.fromRGB(75,75,90)
        task.delay(7,function()
            if model.Parent then model:Destroy() end
            spawnEnemy(settings)
        end)
    end)
    task.spawn(function()
        while alive and model.Parent do
            local target,distance=closestPlayer(root.Position,settings.Range)
            local character=target and target.Character
            local targetHumanoid=character and character:FindFirstChildOfClass("Humanoid")
            local targetRoot=character and character:FindFirstChild("HumanoidRootPart")
            if targetHumanoid and targetRoot and targetHumanoid.Health>0 then
                if distance>settings.AttackRange then
                    local delta=targetRoot.Position-root.Position
                    local flat=Vector3.new(delta.X,0,delta.Z)
                    if flat.Magnitude>0.1 then
                        local step=math.min(settings.Speed*0.1,math.max(0,flat.Magnitude-settings.AttackRange))
                        local nextPos=root.Position+flat.Unit*step
                        model:PivotTo(CFrame.new(nextPos,Vector3.new(targetRoot.Position.X,nextPos.Y,targetRoot.Position.Z)))
                    end
                elseif os.clock()-lastAttack>=settings.Cooldown then
                    lastAttack=os.clock()
                    local defense=target:GetAttribute("EclipseDefense") or 0
                    targetHumanoid:TakeDamage(math.max(1,settings.Damage-defense))
                end
            end
            task.wait(0.1)
        end
    end)
end

for _, settings in TYPES do spawnEnemy(settings) end
print("[ECLIPSE] Wisp, Stalker, and Brute enemy roster spawned.")
