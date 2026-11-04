-- Project ECLIPSE Alpha 0.1
-- Supports both R6 and R15 avatars through Roblox character spawning.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local CharacterConfig = require(Shared:WaitForChild("CharacterConfig"))
local PlayerDataService = require(script.Parent:WaitForChild("PlayerDataService"))

local function configureCharacter(player, character)
    local humanoid = character:WaitForChild("Humanoid", 10)
    if not humanoid then
        warn("[ECLIPSE] Humanoid missing for " .. player.Name)
        return
    end

    local data = PlayerDataService.GetData(player)
    if not data then
        data = PlayerDataService.InitializePlayer(player)
    end

    local configuredHealth = player:GetAttribute("EclipseMaxHealth") or data.MaxHealth
    humanoid.MaxHealth = configuredHealth
    humanoid.Health = configuredHealth

    local rigType = humanoid.RigType.Name
    character:SetAttribute("EclipseRigType", rigType)
    character:SetAttribute("EclipseCharacterReady", true)

    print(string.format(
        "[ECLIPSE] %s spawned using %s | Level %d",
        player.Name,
        rigType,
        data.Level
    ))
end

local function onPlayerAdded(player)
    PlayerDataService.InitializePlayer(player)

    player.CharacterAdded:Connect(function(character)
        configureCharacter(player, character)
    end)

    if player.Character then
        configureCharacter(player, player.Character)
    end
end

Players.PlayerAdded:Connect(onPlayerAdded)

Players.PlayerRemoving:Connect(function(player)
    PlayerDataService.RemovePlayer(player)
end)

for _, player in Players:GetPlayers() do
    task.spawn(onPlayerAdded, player)
end

print("[ECLIPSE] Character service online. R6/R15 supported.")
