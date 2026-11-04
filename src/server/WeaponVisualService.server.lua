-- Lightweight generated starter weapon visuals for R6 and R15 avatars.
-- These are prototype meshes built from Parts, not final custom assets.
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local WeaponConfig=require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("WeaponConfig"))

local function makePart(parent,name,size,color,material,cf)
    local part=Instance.new("Part")
    part.Name=name; part.Size=size; part.Color=color; part.Material=material
    part.CanCollide=false; part.CanTouch=false; part.Massless=true
    part.Anchored=false; part.CFrame=cf; part.Parent=parent
    return part
end

local function weldToHand(part,hand,offset)
    part.CFrame=hand.CFrame*offset
    local weld=Instance.new("WeldConstraint")
    weld.Part0=hand; weld.Part1=part; weld.Parent=part
end

local function buildWeapon(player,character)
    local old=character:FindFirstChild("EclipseWeaponVisual")
    if old then old:Destroy() end
    local weaponName=player:GetAttribute("EclipseWeapon")
    if not weaponName or not WeaponConfig.Weapons[weaponName] then return end
    local hand=character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
    if not hand then return end

    local model=Instance.new("Model")
    model.Name="EclipseWeaponVisual"
    model.Parent=character
    local grip=CFrame.new(0,-0.65,0)*CFrame.Angles(math.rad(90),0,0)

    if weaponName=="Eclipse Blade" then
        local handle=makePart(model,"BladeHandle",Vector3.new(0.22,0.85,0.22),Color3.fromRGB(35,40,55),Enum.Material.Metal,hand.CFrame)
        weldToHand(handle,hand,grip)
        local blade=makePart(model,"Blade",Vector3.new(0.28,2.5,0.12),Color3.fromRGB(90,205,255),Enum.Material.Neon,hand.CFrame)
        weldToHand(blade,hand,grip*CFrame.new(0,1.55,0))
        local guard=makePart(model,"Guard",Vector3.new(1,0.16,0.25),Color3.fromRGB(30,90,145),Enum.Material.Metal,hand.CFrame)
        weldToHand(guard,hand,grip*CFrame.new(0,0.55,0))
    elseif weaponName=="Astral Staff" then
        local shaft=makePart(model,"StaffShaft",Vector3.new(0.18,4.2,0.18),Color3.fromRGB(90,65,145),Enum.Material.Wood,hand.CFrame)
        weldToHand(shaft,hand,grip*CFrame.new(0,1.45,0))
        local crystal=makePart(model,"StaffCrystal",Vector3.new(0.72,0.72,0.72),Color3.fromRGB(190,105,255),Enum.Material.Neon,hand.CFrame)
        crystal.Shape=Enum.PartType.Ball
        weldToHand(crystal,hand,grip*CFrame.new(0,3.65,0))
        local glow=Instance.new("PointLight"); glow.Color=crystal.Color; glow.Brightness=1.5; glow.Range=9; glow.Parent=crystal
    elseif weaponName=="Moon Bow" then
        local gripPart=makePart(model,"BowGrip",Vector3.new(0.2,1.1,0.2),Color3.fromRGB(70,110,80),Enum.Material.Wood,hand.CFrame)
        weldToHand(gripPart,hand,grip)
        for index,offset in {{-0.42,0.72,0},{0,1.25,0},{0.42,0.72,0}} do
            local limb=makePart(model,"BowArc"..index,Vector3.new(0.16,1.05,0.18),Color3.fromRGB(125,210,160),Enum.Material.Wood,hand.CFrame)
            weldToHand(limb,hand,grip*CFrame.new(offset[1],offset[2],offset[3])*CFrame.Angles(0,0,math.rad(offset[1]*55)))
        end
    end
end

local function setupPlayer(player)
    local function onCharacter(character)
        task.wait(0.5)
        buildWeapon(player,character)
    end
    player.CharacterAdded:Connect(onCharacter)
    player:GetAttributeChangedSignal("EclipseWeapon"):Connect(function()
        if player.Character then buildWeapon(player,player.Character) end
    end)
    if player.Character then task.spawn(onCharacter,player.Character) end
end

Players.PlayerAdded:Connect(setupPlayer)
for _,player in Players:GetPlayers() do task.spawn(setupPlayer,player) end
print("[ECLIPSE] R6/R15 starter weapon visuals online.")
