-- Project ECLIPSE Alpha 0.1
-- Server-side startup. Gameplay decisions remain server-authoritative.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("GameConfig"))

local remotesFolder = ReplicatedStorage:FindFirstChild("EclipseRemotes")
if not remotesFolder then
    remotesFolder = Instance.new("Folder")
    remotesFolder.Name = "EclipseRemotes"
    remotesFolder.Parent = ReplicatedStorage
end

local function ensureRemote(name)
    local remote = remotesFolder:FindFirstChild(name)
    if not remote then
        remote = Instance.new("RemoteEvent")
        remote.Name = name
        remote.Parent = remotesFolder
    end
    return remote
end

ensureRemote("AttackRequest")
ensureRemote("CombatFeedback")

print(string.format("[%s] Server initialized — %s", GameConfig.GameName, GameConfig.Version))
print("[ECLIPSE] Combat remotes ready.")
