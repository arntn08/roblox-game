-- Project ECLIPSE Alpha 0.1
-- Procedurally builds the first training arena when the server starts.

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

if Workspace:FindFirstChild("EclipseDungeon") then
    warn("[ECLIPSE] Dungeon already exists; skipping duplicate build.")
    return
end

local map = Instance.new("Folder")
map.Name = "EclipseDungeon"
map.Parent = Workspace

local function makePart(name, size, position, color, material, parent, anchored)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.Position = position
    part.Color = color
    part.Material = material or Enum.Material.Slate
    part.Anchored = anchored ~= false
    part.TopSurface = Enum.SurfaceType.Smooth
    part.BottomSurface = Enum.SurfaceType.Smooth
    part.Parent = parent or map
    return part
end

-- Main arena floor and perimeter.
makePart("ArenaFloor", Vector3.new(100, 2, 100), Vector3.new(0, -1, 0), Color3.fromRGB(25, 31, 48), Enum.Material.Slate)
makePart("NorthWall", Vector3.new(100, 22, 3), Vector3.new(0, 10, -50), Color3.fromRGB(17, 24, 42), Enum.Material.Basalt)
makePart("SouthWall", Vector3.new(100, 22, 3), Vector3.new(0, 10, 50), Color3.fromRGB(17, 24, 42), Enum.Material.Basalt)
makePart("WestWall", Vector3.new(3, 22, 100), Vector3.new(-50, 10, 0), Color3.fromRGB(17, 24, 42), Enum.Material.Basalt)
makePart("EastWall", Vector3.new(3, 22, 100), Vector3.new(50, 10, 0), Color3.fromRGB(17, 24, 42), Enum.Material.Basalt)

-- Glowing center lane.
makePart("CentralPath", Vector3.new(12, 0.15, 68), Vector3.new(0, 0.08, -2), Color3.fromRGB(20, 76, 112), Enum.Material.Neon)
for _, z in {-28, -14, 0, 14, 28} do
    makePart("PathMark", Vector3.new(8, 0.2, 0.5), Vector3.new(0, 0.2, z), Color3.fromRGB(80, 190, 255), Enum.Material.Neon)
end

-- Four stone pillars with cyan light sources.
for _, x in {-34, 34} do
    for _, z in {-32, 32} do
        makePart("AncientPillar", Vector3.new(5, 18, 5), Vector3.new(x, 9, z), Color3.fromRGB(39, 48, 68), Enum.Material.Rock)
        local crystal = makePart("PillarCrystal", Vector3.new(2, 3, 2), Vector3.new(x, 19.5, z), Color3.fromRGB(45, 175, 255), Enum.Material.Neon)
        local light = Instance.new("PointLight")
        light.Color = crystal.Color
        light.Brightness = 1.5
        light.Range = 18
        light.Parent = crystal
    end
end

-- Portal frame at the far end of the arena.
makePart("PortalLeft", Vector3.new(3, 16, 3), Vector3.new(-8, 8, -43), Color3.fromRGB(44, 59, 88), Enum.Material.Metal)
makePart("PortalRight", Vector3.new(3, 16, 3), Vector3.new(8, 8, -43), Color3.fromRGB(44, 59, 88), Enum.Material.Metal)
makePart("PortalTop", Vector3.new(19, 3, 3), Vector3.new(0, 16, -43), Color3.fromRGB(44, 59, 88), Enum.Material.Metal)
local portal = makePart("EclipsePortal", Vector3.new(12, 12, 0.5), Vector3.new(0, 8, -41.2), Color3.fromRGB(20, 120, 210), Enum.Material.Neon)
portal.Transparency = 0.25
portal.CanCollide = false

-- Player spawn faces the training enemy, which appears near the middle.
local spawn = Instance.new("SpawnLocation")
spawn.Name = "EclipsePlayerSpawn"
spawn.Size = Vector3.new(8, 1, 8)
spawn.CFrame = CFrame.lookAt(Vector3.new(0, 0.6, 28), Vector3.new(0, 0.6, -12))
spawn.Anchored = true
spawn.Neutral = true
spawn.Duration = 0
spawn.Color = Color3.fromRGB(55, 145, 220)
spawn.Material = Enum.Material.Neon
spawn.Transparency = 0.15
spawn.Parent = map

Lighting.ClockTime = 19
Lighting.Brightness = 2
Lighting.Ambient = Color3.fromRGB(55, 65, 95)
Lighting.OutdoorAmbient = Color3.fromRGB(35, 45, 70)

local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
if not atmosphere then
    atmosphere = Instance.new("Atmosphere")
    atmosphere.Parent = Lighting
end
atmosphere.Density = 0.28
atmosphere.Offset = 0.15
atmosphere.Color = Color3.fromRGB(125, 165, 220)
atmosphere.Decay = Color3.fromRGB(35, 55, 100)
atmosphere.Glare = 0.2
atmosphere.Haze = 1.5

print("[ECLIPSE] Eclipse Training Grounds generated.")
