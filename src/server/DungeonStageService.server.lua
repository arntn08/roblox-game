-- Portal-driven stage progression. Stage 1 leads to a generated Stage 2 combat platform.
local Players=game:GetService("Players")
local Workspace=game:GetService("Workspace")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local remotes=ReplicatedStorage:WaitForChild("EclipseRemotes")
local feedback=remotes:WaitForChild("StageFeedback")
local map=Workspace:WaitForChild("EclipseDungeon")
local stages=Workspace:FindFirstChild("EclipseStages") or Instance.new("Folder")
stages.Name="EclipseStages"; stages.Parent=Workspace

local stage2=stages:FindFirstChild("Stage2")
if not stage2 then
    stage2=Instance.new("Model"); stage2.Name="Stage2"; stage2.Parent=stages
    local floor=Instance.new("Part"); floor.Name="Stage2Floor"; floor.Size=Vector3.new(90,2,90)
    floor.Position=Vector3.new(0,-1,-180); floor.Anchored=true; floor.Material=Enum.Material.Slate
    floor.Color=Color3.fromRGB(22,18,38); floor.Parent=stage2
    for _,x in {-42,42} do
        local wall=Instance.new("Part"); wall.Size=Vector3.new(3,18,90); wall.Position=Vector3.new(x,8,-180)
        wall.Anchored=true; wall.Material=Enum.Material.Basalt; wall.Color=Color3.fromRGB(35,25,55); wall.Parent=stage2
    end
    local spawn=Instance.new("Part"); spawn.Name="Stage2Spawn"; spawn.Size=Vector3.new(8,1,8)
    spawn.Position=Vector3.new(0,1,-150); spawn.Anchored=true; spawn.Transparency=1; spawn.CanCollide=false; spawn.Parent=stage2
end

local portal=map:FindFirstChild("EclipsePortal")
if portal then
    local prompt=portal:FindFirstChildOfClass("ProximityPrompt") or Instance.new("ProximityPrompt")
    prompt.ActionText="Enter Next Stage"; prompt.ObjectText="Eclipse Gate"; prompt.HoldDuration=0.5
    prompt.MaxActivationDistance=12; prompt.Parent=portal
    prompt.Triggered:Connect(function(player)
        local character=player.Character
        local root=character and character:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame=CFrame.new(0,5,-150)
            player:SetAttribute("EclipseStage",2)
            feedback:FireClient(player,{kind="Entered",stage=2,name="The Shattered Annex"})
        end
    end)
end
print("[ECLIPSE] Dungeon stage transition portal online.")
